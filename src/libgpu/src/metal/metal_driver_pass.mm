#ifdef DECAF_METAL

#include "metal_driver.h"

#import <Metal/MTLRenderCommandEncoder.h>

using namespace metal;

void Driver::finishCurrentPass()
{
    if (currentPass != nullptr) {
        [currentPass endEncoding];
        currentPass = nullptr;
    }
}

void Driver::startPass()
{
    if (currentPass != nullptr) {
        return;
    }
    
    if (renderState.colorAttachments[0].texture == nullptr) {
        renderState.colorAttachments[0].texture = tvScanBuffers.back();
    }
    
    currentPass = [currentCommandBuffer renderCommandEncoderWithDescriptor:renderState];
    currentPass.label = @"GPU command batch";
}

#endif // DECAF_METAL
