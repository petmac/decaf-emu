#ifdef DECAF_METAL

#include "metal_driver.h"

#import <Metal/MTLBlitCommandEncoder.h>
#import <Metal/MTLCommandBuffer.h>

using namespace metal;

void Driver::beginPass()
{
    if (currentPass != nullptr) {
        return;
    }
    
    currentPass = [currentCommandBuffer blitCommandEncoder];
    currentPass.label = @"GPU command batch";
}

void Driver::endPass()
{
    if (currentPass != nullptr) {
        [currentPass endEncoding];
        currentPass = nullptr;
    }
}

#endif // DECAF_METAL
