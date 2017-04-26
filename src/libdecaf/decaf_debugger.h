#pragma once

namespace decaf
{

class DebugUiRenderer
{
public:
   virtual ~DebugUiRenderer() = default;
   virtual void initialise() = 0;
   virtual void draw(unsigned width, unsigned height) = 0;
};

DebugUiRenderer *
createDebugGLRenderer();

DebugUiRenderer *
createDebugMetalRenderer();

void
setDebugUiRenderer(DebugUiRenderer *renderer);

DebugUiRenderer *
getDebugUiRenderer();

} // namespace decaf
