#include "debugger/debugger_ui_opengl.h"
#include "debugger/debugger_ui_metal.h"
#include "decaf_debugger.h"
#include <common/decaf_assert.h>

namespace decaf
{

static DebugUiRenderer *
sUiRenderer = nullptr;

DebugUiRenderer *
createDebugGLRenderer()
{
#ifdef DECAF_GL
   return new ::debugger::ui::RendererOpenGL { };
#else
   decaf_abort("libdecaf was built with OpenGL support disabled");
#endif // ifdef DECAF_GL
}

DebugUiRenderer *
createDebugMetalRenderer()
{
#ifdef DECAF_METAL
   return new ::debugger::ui::RendererMetal { };
#else
   decaf_abort("libdecaf was built with Metal support disabled");
#endif // DECAF_METAL
}

void
setDebugUiRenderer(DebugUiRenderer *renderer)
{
   sUiRenderer = renderer;
}

DebugUiRenderer *
getDebugUiRenderer()
{
   return sUiRenderer;
}

} // namespace decaf
