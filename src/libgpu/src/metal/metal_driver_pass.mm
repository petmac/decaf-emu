#ifdef DECAF_METAL

#include "metal_driver.h"

#import <Metal/MTLBlitCommandEncoder.h>
#import <Metal/MTLCommandBuffer.h>
#import <Metal/MTLRenderCommandEncoder.h>

using namespace metal;

void Driver::beginBlitPass()
{
    if (blitPass != nullptr) {
        return;
    }
    
    [pass endEncoding];
    
    blitPass = [currentCommandBuffer blitCommandEncoder];
    blitPass.label = @"Blit pass";
    renderPass = nullptr;
    pass = blitPass;
}

void Driver::beginRenderPass()
{
    if (renderPass != nullptr) {
        return;
    }
    
    [pass endEncoding];
    
    blitPass = nullptr;
    renderPass = [currentCommandBuffer renderCommandEncoderWithDescriptor:renderState];
    renderPass.label = @"Render pass";
    pass = renderPass;
}

void Driver::beginPass()
{
    if (pass != nullptr) {
        return;
    }
    
    beginBlitPass();
}

void Driver::endPass()
{
    if (pass == nullptr) {
        return;
    }
    
    [pass endEncoding];
    blitPass = nullptr;
    renderPass = nullptr;
    pass = nullptr;
}

#endif // DECAF_METAL
