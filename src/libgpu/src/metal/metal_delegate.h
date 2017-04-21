#pragma once

#import <MetalKit/MTKView.h>

namespace metal {
    class Driver;
}

@interface MetalDelegate: NSObject<MTKViewDelegate>

- (instancetype)initWithDriver:(metal::Driver *)driver;

@end
