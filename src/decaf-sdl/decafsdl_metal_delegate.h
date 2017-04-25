#pragma once

#import <MetalKit/MTKView.h>
#undef MIN

#include <memory>

namespace gpu {
    class MetalDriver;
}

@interface MetalDelegate: NSObject<MTKViewDelegate>

@property (nonatomic, readonly) std::shared_ptr<gpu::MetalDriver> driver;

@end
