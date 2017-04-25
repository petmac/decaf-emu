#pragma once

#import <MetalKit/MTKView.h>
#undef MIN

#include <memory>

namespace decaf
{
    class DebugUiRenderer;
}

namespace gpu
{
    class MetalDriver;
}

@protocol MTLDevice;

@interface MetalDelegate: NSObject<MTKViewDelegate>

@property (nonatomic, readonly) id<MTLDevice> device;
@property (nonatomic, readonly) std::shared_ptr<gpu::MetalDriver> driver;
@property (nonatomic, readonly) std::shared_ptr<decaf::DebugUiRenderer> debugRenderer;

@end
