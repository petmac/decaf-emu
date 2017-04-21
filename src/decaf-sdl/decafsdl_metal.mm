#ifdef DECAF_METAL

#include "decafsdl_metal.h"

#include "clilog.h"
#include <common/decaf_assert.h>
#include <libgpu/gpu_metaldriver.h>

#include <SDL_syswm.h>
#include <MetalKit/MTKView.h>

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
    
    gpu::MetalDriver *metalDriver = static_cast<gpu::MetalDriver *>(gpu::createMetalDriver());
    decaf_check(metalDriver);
    mDecafDriver = std::unique_ptr<gpu::MetalDriver>(metalDriver);
    
    SDL_SysWMinfo windowInfo {};
    SDL_GetWindowWMInfo(mWindow, &windowInfo);
    NSWindow *window = windowInfo.info.cocoa.window;
    
    MTKView *metalView = [[MTKView alloc] initWithFrame:window.contentView.bounds device:mDecafDriver->device()];
    metalView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    metalView.delegate = mDecafDriver->delegate();
    metalView.enableSetNeedsDisplay = NO;
    metalView.paused = YES;
    
    [window.contentView addSubview:metalView];
    
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
    SDL_SysWMinfo windowInfo {};
    SDL_GetWindowWMInfo(mWindow, &windowInfo);
    NSWindow *window = windowInfo.info.cocoa.window;
    MTKView *metalView = window.contentView.subviews.firstObject;
    [metalView draw];
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
