#ifdef DECAF_METAL

#include "decafsdl_metal_delegate.h"

#include <libdecaf/decaf_metaldebugger.h>
#include <libgpu/gpu_metaldriver.h>

using namespace decaf;
using namespace gpu;

@implementation MetalDelegate

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        MetalDriver *metalDriver = static_cast<MetalDriver *>(createMetalDriver());
        MetalDebugUiRenderer *metalDebugRenderer = static_cast<MetalDebugUiRenderer *>(createDebugMetalRenderer());
        
        _device = MTLCreateSystemDefaultDevice();
        _driver = std::shared_ptr<MetalDriver>(metalDriver);
        _debugRenderer = std::shared_ptr<MetalDebugUiRenderer>(metalDebugRenderer);
        
        id<MTLCommandQueue> commandQueue = [self.device newCommandQueue];
        self.driver->initialise(commandQueue);
        self.debugRenderer->initialise(commandQueue);
    }
    
    return self;
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
}

- (void)drawInMTKView:(nonnull MTKView *)view {
    CAMetalLayer *layer = static_cast<CAMetalLayer *>(view.layer);
    self.driver->draw(layer.nextDrawable);
    self.debugRenderer->draw(layer.bounds.size.width, layer.bounds.size.height);
}

@end

#endif // DECAF_METAL
