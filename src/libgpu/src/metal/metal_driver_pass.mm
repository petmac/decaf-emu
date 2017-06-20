#ifdef DECAF_METAL

#include "metal_driver.h"

#include "latte/latte_constants.h"

#import <Metal/MTLBlitCommandEncoder.h>
#import <Metal/MTLRenderCommandEncoder.h>

using namespace latte;
using namespace metal;

void Driver::beginBlitPass()
{
    if (blitPass != nullptr) {
        return;
    }
    
    [pass endEncoding];
    
    blitPass = [commandBuffer blitCommandEncoder];
    blitPass.label = @"Blit pass";
    renderPass = nullptr;
    pass = blitPass;
}

void Driver::beginRenderPass()
{
    if (renderPass == nullptr) {
        [pass endEncoding];
        
        for (size_t i = 0; i < MaxRenderTargets; ++i) {
            const CB_COLORN_BASE base = getRegister<CB_COLORN_BASE>(Register::CB_COLOR0_BASE + (i * 4));
            const CB_COLORN_SIZE size = getRegister<CB_COLORN_SIZE>(Register::CB_COLOR0_SIZE + (i * 4));
            const CB_COLORN_INFO info = getRegister<CB_COLORN_INFO>(Register::CB_COLOR0_INFO + (i * 4));
            
            MTLRenderPassColorAttachmentDescriptor *const attachment = renderPassDesc.colorAttachments[i];
            attachment.texture = (size.PITCH_TILE_MAX() != 0) ? getColorBuffer(base, size, info) : nullptr;
        }
        
        blitPass = nullptr;
        renderPass = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDesc];
        renderPass.label = @"Render pass";
        pass = renderPass;
        renderPipelineStateSet = false;
    }
    
    if (!renderPipelineStateSet) {
        id<MTLDevice> device = commandBuffer.device;
        NSError *error = nil;
        id<MTLRenderPipelineState> pipelineState = [device newRenderPipelineStateWithDescriptor:renderPipelineDesc
                                                                                          error:&error];
        [renderPass setRenderPipelineState:pipelineState];
        renderPipelineStateSet = true;
    }
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
