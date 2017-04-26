#include "decaf_debugger.h"
#include "debugger/debugger_ui_metal.h"

namespace decaf
{
#ifdef DECAF_METAL
DebugUiRenderer *
createDebugMetalRenderer()
{
   return new ::debugger::ui::RendererMetal { };
}
#endif // DECAF_METAL
} // namespace decaf
