#include "decaf.h"
#include "decaf_config.h"
#include "decaf_graphics.h"
#include "decaf_input.h"
#include "decaf_sound.h"
#include "debugger/debugger.h"
#include "debugger/debugger_ui.h"
#include "filesystem/filesystem.h"
#include "input/input.h"
#include "kernel/kernel.h"
#include "kernel/kernel_filesystem.h"
#include "kernel/kernel_hlefunction.h"
#include "libcpu/cpu.h"
#include "libcpu/mem.h"
#include "modules/coreinit/coreinit_fs.h"
#include "modules/coreinit/coreinit_scheduler.h"
#include "modules/swkbd/swkbd_core.h"

#include <common/platform.h>
#include <common/platform_dir.h>
#include <condition_variable>
#include <mutex>

#ifdef PLATFORM_WINDOWS
#include <WinSock2.h>
#endif

namespace decaf
{

static ClipboardTextGetCallback
sClipboardTextGetCallbackFn = nullptr;

static ClipboardTextSetCallback
sClipboardTextSetCallbackFn = nullptr;

class LogFormatter : public spdlog::formatter
{
public:
   void format(spdlog::details::log_msg& msg) override
   {
      auto tm_time = spdlog::details::os::localtime(spdlog::log_clock::to_time_t(msg.time));
      auto duration = msg.time.time_since_epoch();
      auto micros = std::chrono::duration_cast<std::chrono::microseconds>(duration).count() % 1000000;

      msg.formatted << '[' << fmt::pad(static_cast<unsigned int>(tm_time.tm_min), 2, '0') << ':'
         << fmt::pad(static_cast<unsigned int>(tm_time.tm_sec), 2, '0') << '.'
         << fmt::pad(static_cast<unsigned int>(micros), 6, '0');

      msg.formatted << ' ';
      msg.formatted << spdlog::level::to_str(msg.level);
      msg.formatted << ':';

      auto core = cpu::this_core::state();
      if (core) {
         auto thread = coreinit::internal::getCurrentThread();
         if (thread) {
            msg.formatted.write("w{:01X}{:02X}", core->id, static_cast<uint16_t>(thread->id));
         } else {
            msg.formatted.write("w{:01X}{:02X}", core->id, 0xFF);
         }
      } else {
         msg.formatted << msg.thread_id;
      }

      msg.formatted << "] ";
      msg.formatted << fmt::StringRef(msg.raw.data(), msg.raw.size());
      msg.formatted.write(spdlog::details::os::eol, spdlog::details::os::eol_size);
   }
};

std::string
makeConfigPath(const std::string &filename)
{
   return fs::HostPath { platform::getConfigDirectory() }
      .join("decaf")
      .join(filename)
      .path();
}

bool
createConfigDirectory()
{
   return platform::createParentDirectories(makeConfigPath("."));
}

void
initialiseLogging(const std::string &filename)
{
   std::vector<spdlog::sink_ptr> sinks;
   auto logLevel = spdlog::level::info;

   if (decaf::config::log::to_stdout) {
      sinks.push_back(spdlog::sinks::stdout_sink_st::instance());
   }

   if (decaf::config::log::to_file) {
      auto path = decaf::config::log::directory + "/" + filename;
      sinks.push_back(std::make_shared<spdlog::sinks::daily_file_sink_st>(path, "txt", 23, 59));
   }

   for (int i = spdlog::level::trace; i <= spdlog::level::off; i++) {
      auto level = static_cast<spdlog::level::level_enum>(i);

      if (spdlog::level::to_str(level) == decaf::config::log::level) {
         logLevel = level;
         break;
      }
   }

   gLog = std::make_shared<spdlog::logger>("decaf", begin(sinks), end(sinks));
   gLog->set_level(logLevel);
   gLog->set_formatter(std::make_shared<LogFormatter>());

   if (decaf::config::log::async) {
      spdlog::set_async_mode(1024);
   } else {
      spdlog::set_sync_mode();
      gLog->flush_on(spdlog::level::trace);
   }
}

bool
initialise(const std::string &gamePath)
{
   if (!getInputDriver()) {
      gLog->error("No input driver set");
      return false;
   }

   if (!getGraphicsDriver()) {
      gLog->error("No graphics driver set");
      return false;
   }

#ifdef PLATFORM_WINDOWS
   WSADATA wsaInitData;
   WSAStartup(MAKEWORD(2, 2), &wsaInitData);
#endif

   // Setup core
   cpu::initialise();
   kernel::initialise();
   debugger::initialise(makeConfigPath("imgui.ini"),
                        sClipboardTextGetCallbackFn,
                        sClipboardTextSetCallbackFn);

   // Setup filesystem
   auto filesystem = std::make_unique<fs::FileSystem>();

   // Find a valid application to run
   auto path = fs::HostPath { gamePath };
   auto volPath = fs::HostPath { };
   auto rpxPath = fs::HostPath { };

   if (platform::isDirectory(path.path())) {
      if (platform::isFile(path.join("code").join("cos.xml").path())) {
         // Found path/code/cos.xml
         volPath = path.path();
      } else if (platform::isFile(path.join("data").join("code").join("cos.xml").path())) {
         // Found path/data/code/cos.xml
         volPath = path.join("data").path();
      }
   } else if (platform::isFile(path.path())) {
      auto parent1 = fs::HostPath { path.parentPath() };
      auto parent2 = fs::HostPath { parent1.parentPath() };

      if (platform::isFile(parent2.join("code").join("cos.xml").path())) {
         // Found file/../code/cos.xml
         volPath = parent2.path();
      } else if (path.extension().compare("rpx") == 0) {
         // Found file.rpx
         rpxPath = path.path();
      }
   }

   if (!volPath.path().empty()) {
      filesystem->mountHostFolder("/vol/code", volPath.join("code"), fs::Permissions::Read);
      filesystem->mountHostFolder("/vol/content", volPath.join("content"), fs::Permissions::Read);
      filesystem->mountHostFolder("/vol/meta", volPath.join("meta"), fs::Permissions::Read);
   } else if (!rpxPath.path().empty()) {
      auto volCodePath = rpxPath.parentPath();
      filesystem->mountHostFolder("/vol/code", volCodePath, fs::Permissions::Read);

      if (!decaf::config::system::content_path.empty()) {
         filesystem->mountHostFolder("/vol/content", decaf::config::system::content_path, fs::Permissions::Read);
      }

      kernel::setExecutableFilename(rpxPath.filename());
   } else {
      gLog->error("Could not find valid application at {}", path.path());
      return false;
   }

   // Add device folder
   filesystem->makeFolder("/dev");

   // Ensure mlc_path exists
   platform::createDirectory(decaf::config::system::mlc_path);

   // Mount mlc
   auto mlcPath = fs::HostPath { decaf::config::system::mlc_path };
   filesystem->mountHostFolder("/vol/storage_mlc01", mlcPath, fs::Permissions::Read);
   filesystem->mountHostFolder("/vol/storage_hfiomlc01", mlcPath, fs::Permissions::Read);

   // Setup kernel
   kernel::setFileSystem(std::move(filesystem));
   return true;
}

void
start()
{
   cpu::start();

   volatile int zero = 0;
   if (zero) {
      tracePrint(nullptr, 0, 0);
      traceReg(nullptr, 0, 0);
      traceRegStart(nullptr, 0, 0);
      traceRegNext(0);
      traceRegContinue();
   }
}

bool
hasExited()
{
   return kernel::hasExited();
}

int
waitForExit()
{
   // Wait for CPU to finish
   cpu::join();

   // Make sure we clean up
   decaf::shutdown();

   return kernel::getExitCode();
}

void
shutdown()
{
   // Shut down debugger
   debugger::shutdown();

   // Shut down CPU
   cpu::halt();

   // Wait for CPU to finish
   cpu::join();

   // Stop any kernel threads
   kernel::shutdown();

   // Stop graphics driver
   auto graphicsDriver = getGraphicsDriver();

   if (graphicsDriver) {
      graphicsDriver->stop();
   }

   setGraphicsDriver(nullptr);

   // Stop sound driver
   auto soundDriver = getSoundDriver();

   if (soundDriver) {
      soundDriver->stop();
   }

   setSoundDriver(nullptr);
}

void
injectMouseButtonInput(input::MouseButton button,
                       input::MouseAction action)
{
   debugger::ui::onMouseAction(button, action);
}

void
injectMousePos(float x,
               float y)
{
   debugger::ui::onMouseMove(x, y);
}

void
injectScrollInput(float xoffset,
                  float yoffset)
{
   debugger::ui::onMouseScroll(xoffset, yoffset);
}

void
injectKeyInput(input::KeyboardKey key,
               input::KeyboardAction action)
{
   if (!debugger::ui::onKeyAction(key, action)) {
      nn::swkbd::internal::injectKeyInput(key, action);
   }
}

void
injectTextInput(const char *text)
{
   if (!debugger::ui::onText(text)) {
      nn::swkbd::internal::injectTextInput(text);
   }
}

void
setClipboardTextCallbacks(ClipboardTextGetCallback getter,
                          ClipboardTextSetCallback setter)
{
   sClipboardTextGetCallbackFn = getter;
   sClipboardTextSetCallbackFn = setter;
}

} // namespace decaf
