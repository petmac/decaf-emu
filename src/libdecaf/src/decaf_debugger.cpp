#include "debugger/debugger_ui_opengl.h"
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

#ifndef DECAF_METAL
DebugUiRenderer *
createDebugMetalRenderer()
{
   decaf_abort("libdecaf was built with Metal support disabled");
   return nullptr;
}
#endif // DECAF_METAL

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
