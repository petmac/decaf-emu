#ifdef DECAF_METAL

#include "metal_driver.h"

#include "gpu_event.h"
#include "gpu_ringbuffer.h"

#include <Metal/MTLCommandQueue.h>

using namespace gpu;
using namespace metal;
using namespace ringbuffer;

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

#endif // DECAF_METAL
