#ifdef DECAF_METAL

#include "decafsdl_metal.h"
#include "decafsdl_metal_delegate.h"

#include "clilog.h"
#include <common/decaf_assert.h>
#include <libgpu/gpu_metaldriver.h>

#include <SDL_syswm.h>

#import <MetalKit/MTKView.h>

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
    
    mDelegate = [MetalDelegate new];
    
    SDL_SysWMinfo windowInfo {};
    SDL_GetWindowWMInfo(mWindow, &windowInfo);
    NSWindow *window = windowInfo.info.cocoa.window;
    
    MTKView *metalView = [[MTKView alloc] initWithFrame:window.contentView.bounds device:mDelegate.driver->device()];
    metalView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    metalView.delegate = mDelegate;
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
    return mDelegate.driver.get();
}

decaf::DebugUiRenderer *
DecafSDLMetal::getDecafDebugUiRenderer()
{
    return mDebugUiRenderer.get();
}

#endif // DECAF_METAL
