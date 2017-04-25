#ifdef DECAF_METAL

#include "decafsdl_metal_delegate.h"
#include <libgpu/gpu_metaldriver.h>

using namespace gpu;

@implementation MetalDelegate

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        MetalDriver *metalDriver = static_cast<MetalDriver *>(createMetalDriver());
        _driver = std::shared_ptr<MetalDriver>(metalDriver);
    }
    
    return self;
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
}

- (void)drawInMTKView:(nonnull MTKView *)view {
    CAMetalLayer *layer = static_cast<CAMetalLayer *>(view.layer);
    self.driver->draw(layer.nextDrawable);
}

@end

#endif // DECAF_METAL
