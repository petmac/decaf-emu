#ifdef DECAF_METAL

#include "metal_driver.h"

#include "gpu_event.h"
#include "gpu_ringbuffer.h"

#import <Metal/MTLCommandQueue.h>

using namespace gpu;
using namespace metal;
using namespace ringbuffer;

void
Driver::initialise(id<MTLCommandQueue> commandQueue)
{
    renderState = [[MTLRenderPassDescriptor alloc] init];
    this->commandQueue = commandQueue;
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
    
    finishCurrentPass();
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
