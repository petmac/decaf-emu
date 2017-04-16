#ifdef DECAF_METAL

#include "decafsdl_metal.h"

#include "clilog.h"
#include <common/decaf_assert.h>

DecafSDLMetal::DecafSDLMetal()
{
}

DecafSDLMetal::~DecafSDLMetal()
{
}

bool
DecafSDLMetal::initialise(int width, int height)
{
    mWindow = SDL_CreateWindow("Decaf",
                               SDL_WINDOWPOS_UNDEFINED,
                               SDL_WINDOWPOS_UNDEFINED,
                               width, height,
                               SDL_WINDOW_ALLOW_HIGHDPI | SDL_WINDOW_RESIZABLE);
    if (!mWindow) {
        gCliLog->error("Failed to create GL SDL window");
        return false;
    }
    
    auto metalDriver = gpu::createMetalDriver();
    decaf_check(metalDriver);
    mDecafDriver = std::unique_ptr<gpu::GraphicsDriver>(metalDriver);
    
    auto metalDebugUiRenderer = decaf::createDebugMetalRenderer();
    decaf_check(metalDebugUiRenderer);
    mDebugUiRenderer = std::unique_ptr<decaf::DebugUiRenderer>(metalDebugUiRenderer);
    
    return true;
}

void
DecafSDLMetal::shutdown()
{
}

void
DecafSDLMetal::renderFrame(Viewport &tv, Viewport &drc)
{
}

gpu::GraphicsDriver *
DecafSDLMetal::getDecafDriver()
{
    return mDecafDriver.get();
}

decaf::DebugUiRenderer *
DecafSDLMetal::getDecafDebugUiRenderer()
{
    return mDebugUiRenderer.get();
}

#endif // DECAF_METAL
