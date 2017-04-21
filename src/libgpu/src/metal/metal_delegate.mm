#ifdef DECAF_METAL

#include "metal_delegate.h"

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
}

@end

#endif // DECAF_METAL
