#ifdef DECAF_METAL

#include "metal_driver.h"

#include "gpu_event.h"
#include "gpu_ringbuffer.h"
#include "latte/latte_constants.h"

#import <Metal/MTLCommandQueue.h>

using namespace gpu;
using namespace latte;
using namespace metal;
using namespace ringbuffer;

void
Driver::initialise(id<MTLCommandQueue> commandQueue)
{
    renderPassDesc = [[MTLRenderPassDescriptor alloc] init];
    renderPipelineDesc = [[MTLRenderPipelineDescriptor alloc] init];
    this->commandQueue = commandQueue;
    
    for (size_t i = 0; i < MaxRenderTargets; ++i) {
        MTLRenderPassColorAttachmentDescriptor *const attachment = renderPassDesc.colorAttachments[i];
        attachment.loadAction = MTLLoadActionLoad;
        attachment.storeAction = MTLStoreActionStore;
    }
    
    for (auto i = 0u; i < mRegisters.size(); ++i) {
        applyRegister(static_cast<latte::Register>(i * 4));
    }
}

void
Driver::draw()
{
    currentCommandBuffer = [commandQueue commandBuffer];
    currentCommandBuffer.label = @"Run GPU commands";
    
    for (Item item = dequeueItem(); item.numWords > 0; item = dequeueItem())
    {
        runCommandBuffer(item.buffer, item.numWords);
        onRetire(item.context);
    }
    
    endPass();
    [currentCommandBuffer commit];
    currentCommandBuffer = nil;
}

void
Driver::getFrontBuffers(id<MTLTexture> *tv, id<MTLTexture> *drc)
{
    *tv = tvScanBuffers.empty() ? nil : tvScanBuffers.front();
    *drc = drcScanBuffers.empty() ? nil : drcScanBuffers.front();
}

#endif // DECAF_METAL
