#ifdef DECAF_METAL

#include "metal_driver.h"
#include "metal_delegate.h"

#include <MetalKit/MetalKit.h>

using namespace metal;

Driver::Driver()
{
    delegate_ = [[MetalDelegate alloc] initWithDriver:this];
    device_ = MTLCreateSystemDefaultDevice();
    commandQueue = [device_ newCommandQueue];
}

Driver::~Driver()
{
}

id<MTKViewDelegate>
Driver::delegate() const
{
    return delegate_;
}

id<MTLDevice>
Driver::device() const
{
    return device_;
}

void
Driver::draw(id<CAMetalDrawable> drawable)
{
    MTLRenderPassDescriptor *pass = [MTLRenderPassDescriptor new];
    pass.colorAttachments[0].texture = drawable.texture;
    pass.colorAttachments[0].loadAction = MTLLoadActionClear;
    pass.colorAttachments[0].clearColor = MTLClearColorMake(0.0625, 0.125, 0.25, 1);

    id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];
    id<MTLRenderCommandEncoder> command = [commandBuffer renderCommandEncoderWithDescriptor:pass];
    [command endEncoding];
    
    [commandBuffer presentDrawable:drawable];
    [commandBuffer commit];
}

void
Driver::run()
{
}

void
Driver::stop()
{
}

float
Driver::getAverageFPS()
{
    return 0.0f;
}

void
Driver::notifyCpuFlush(void *ptr, uint32_t size)
{
}

void
Driver::notifyGpuFlush(void *ptr, uint32_t size)
{
}

#endif // DECAF_METAL
