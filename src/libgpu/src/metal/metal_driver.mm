#ifdef DECAF_METAL

#include "metal_driver.h"

#include "gpu_event.h"
#include "gpu_ringbuffer.h"
#include "metal_delegate.h"

#include <MetalKit/MetalKit.h>

using namespace gpu;
using namespace metal;
using namespace ringbuffer;

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
    currentCommandBuffer = [commandQueue commandBuffer];
    
    for (Item item = dequeueItem(); item.numWords > 0; item = dequeueItem())
    {
        runCommandBuffer(item.buffer, item.numWords);
        onRetire(item.context);
    }
    
    [currentCommandBuffer commit];
    currentCommandBuffer = nil;
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

void
Driver::decafSetBuffer(const DecafSetBuffer &data)
{
}

void
Driver::decafCopyColorToScan(const DecafCopyColorToScan &data)
{
}

void
Driver::decafSwapBuffers(const DecafSwapBuffers &data)
{
}

void
Driver::decafCapSyncRegisters(const DecafCapSyncRegisters &data)
{
}

void
Driver::decafClearColor(const DecafClearColor &data)
{
}

void
Driver::decafClearDepthStencil(const DecafClearDepthStencil &data)
{
}

void
Driver::decafDebugMarker(const DecafDebugMarker &data)
{
}

void
Driver::decafOSScreenFlip(const DecafOSScreenFlip &data)
{
}

void
Driver::decafCopySurface(const DecafCopySurface &data)
{
}

void
Driver::decafSetSwapInterval(const DecafSetSwapInterval &data)
{
}

void
Driver::drawIndexAuto(const DrawIndexAuto &data)
{
}

void
Driver::drawIndex2(const DrawIndex2 &data)
{
}

void
Driver::drawIndexImmd(const DrawIndexImmd &data)
{
}

void
Driver::memWrite(const MemWrite &data)
{
}

void
Driver::eventWrite(const EventWrite &data)
{
}

void
Driver::eventWriteEOP(const EventWriteEOP &data)
{
}

void
Driver::pfpSyncMe(const PfpSyncMe &data)
{
}

void
Driver::streamOutBaseUpdate(const StreamOutBaseUpdate &data)
{
}

void
Driver::streamOutBufferUpdate(const StreamOutBufferUpdate &data)
{
}

void
Driver::surfaceSync(const SurfaceSync &data)
{
}

void
Driver::applyRegister(latte::Register reg)
{
}


#endif // DECAF_METAL
