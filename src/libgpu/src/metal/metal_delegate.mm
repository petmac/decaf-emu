#ifdef DECAF_METAL

#include "metal_delegate.h"
#include "metal_driver.h"

using namespace metal;

@interface MetalDelegate ()
@property (nonatomic, readonly) Driver *driver;
@end

@implementation MetalDelegate

- (instancetype)initWithDriver:(Driver *)driver {
    self = [super init];
    if (self != nil) {
        _driver = driver;
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
