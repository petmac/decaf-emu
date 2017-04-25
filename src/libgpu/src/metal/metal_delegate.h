#pragma once

#import <MetalKit/MTKView.h>
#undef MIN

namespace metal {
    class Driver;
}

@interface MetalDelegate: NSObject<MTKViewDelegate>

- (instancetype)initWithDriver:(metal::Driver *)driver;

@end
