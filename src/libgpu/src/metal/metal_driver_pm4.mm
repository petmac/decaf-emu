#ifdef DECAF_METAL

#include "metal_driver.h"

#include "gpu_event.h"

#import <Metal/MTLBlitCommandEncoder.h>
#import <Metal/MTLCommandQueue.h>

#include <algorithm>

using namespace latte;
using namespace metal;

void
Driver::decafSetBuffer(const DecafSetBuffer &data)
{
    MTLTextureDescriptor *textureDesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatBGRA8Unorm
                                                                                           width:data.width
                                                                                          height:data.height
                                                                                       mipmapped:NO];
    textureDesc.usage = MTLTextureUsageShaderRead | MTLTextureUsageRenderTarget;
    
    ScanBufferChain &chain = data.isTv ? tvScanBuffers : drcScanBuffers;
    NSString *labelPrefix = data.isTv ? @"TV" : @"DRC";
    
    chain.clear();
    for (unsigned int i = 0; i < data.numBuffers; ++i)
    {
        id<MTLTexture> texture = [commandQueue.device newTextureWithDescriptor:textureDesc];
        texture.label = [NSString stringWithFormat:@"%@ framebuffer %u", labelPrefix, i];
        
        chain.push_back(texture);
    }
}

void
Driver::decafCopyColorToScan(const DecafCopyColorToScan &data)
{
    beginBlitPass();
    [pass pushDebugGroup:[NSString stringWithUTF8String:__FUNCTION__]];
    
    const id<MTLTexture> src = getColorBuffer(data.cb_color_base, data.cb_color_size, data.cb_color_info);
    const id<MTLTexture> dst = (data.scanTarget == 1) ? tvScanBuffers.back() : drcScanBuffers.back();
    
    [blitPass copyFromTexture:src
                  sourceSlice:data.cb_color_view.SLICE_START()
                  sourceLevel:0
                 sourceOrigin:MTLOriginMake(0, 0, 0)
                   sourceSize:MTLSizeMake(data.width, data.height, 1)
                    toTexture:dst
             destinationSlice:0
             destinationLevel:0
            destinationOrigin:MTLOriginMake(0, 0, 0)];
    [pass popDebugGroup];
}

void
Driver::decafSwapBuffers(const DecafSwapBuffers &data)
{
    beginPass();
    [pass pushDebugGroup:[NSString stringWithUTF8String:__FUNCTION__]];
    [pass popDebugGroup];
    endPass();
    
    if (!tvScanBuffers.empty())
    {
        std::rotate(tvScanBuffers.begin(), tvScanBuffers.end() - 1, tvScanBuffers.end());
    }
    if (!drcScanBuffers.empty())
    {
        std::rotate(drcScanBuffers.begin(), drcScanBuffers.end() - 1, drcScanBuffers.end());
    }
    
    gpu::onFlip();
}

void
Driver::decafCapSyncRegisters(const DecafCapSyncRegisters &data)
{
    beginPass();
    [pass pushDebugGroup:[NSString stringWithUTF8String:__FUNCTION__]];
    [pass popDebugGroup];
    
    gpu::onSyncRegisters(mRegisters.data(), static_cast<uint32_t>(mRegisters.size()));
}

void
Driver::decafClearColor(const DecafClearColor &data)
{
    endPass();
    
    MTLRenderPassDescriptor *desc = [[MTLRenderPassDescriptor alloc] init];
    MTLRenderPassColorAttachmentDescriptor *attachment = desc.colorAttachments[0];
    attachment.texture = getColorBuffer(data.cb_color_base, data.cb_color_size, data.cb_color_info);
    attachment.loadAction = MTLLoadActionClear;
    attachment.clearColor = MTLClearColorMake(data.red, data.green, data.blue, data.alpha);
    attachment.storeAction = MTLStoreActionStore;
    
    id<MTLRenderCommandEncoder> pass = [currentCommandBuffer renderCommandEncoderWithDescriptor:desc];
    pass.label = [NSString stringWithUTF8String:__FUNCTION__];
    [pass endEncoding];
}

void
Driver::decafClearDepthStencil(const DecafClearDepthStencil &data)
{
    beginPass();
    [pass pushDebugGroup:[NSString stringWithUTF8String:__FUNCTION__]];
    [pass popDebugGroup];
}

void
Driver::decafDebugMarker(const DecafDebugMarker &data)
{
    beginPass();
    [pass insertDebugSignpost:[NSString stringWithUTF8String:data.key.data()]];
}

void
Driver::decafOSScreenFlip(const DecafOSScreenFlip &data)
{
    beginPass();
    [pass pushDebugGroup:[NSString stringWithUTF8String:__FUNCTION__]];
    [pass popDebugGroup];
}

void
Driver::decafCopySurface(const DecafCopySurface &data)
{
    beginPass();
    [pass pushDebugGroup:[NSString stringWithUTF8String:__FUNCTION__]];
    [pass popDebugGroup];
}

void
Driver::decafSetSwapInterval(const DecafSetSwapInterval &data)
{
    beginPass();
    [pass pushDebugGroup:[NSString stringWithUTF8String:__FUNCTION__]];
    [pass popDebugGroup];
}

void
Driver::drawIndexAuto(const DrawIndexAuto &data)
{
    beginRenderPass();
    [pass pushDebugGroup:[NSString stringWithUTF8String:__FUNCTION__]];
    [pass popDebugGroup];
}

void
Driver::drawIndex2(const DrawIndex2 &data)
{
    beginRenderPass();
    [pass pushDebugGroup:[NSString stringWithUTF8String:__FUNCTION__]];
    [pass popDebugGroup];
}

void
Driver::drawIndexImmd(const DrawIndexImmd &data)
{
    beginRenderPass();
    [pass pushDebugGroup:[NSString stringWithUTF8String:__FUNCTION__]];
    [pass popDebugGroup];
}

void
Driver::memWrite(const MemWrite &data)
{
    beginPass();
    [pass pushDebugGroup:[NSString stringWithUTF8String:__FUNCTION__]];
    [pass popDebugGroup];
}

void
Driver::eventWrite(const EventWrite &data)
{
    beginPass();
    [pass pushDebugGroup:[NSString stringWithUTF8String:__FUNCTION__]];
    [pass popDebugGroup];
}

void
Driver::eventWriteEOP(const EventWriteEOP &data)
{
    beginPass();
    [pass pushDebugGroup:[NSString stringWithUTF8String:__FUNCTION__]];
    [pass popDebugGroup];
}

void
Driver::pfpSyncMe(const PfpSyncMe &data)
{
    beginPass();
    [pass pushDebugGroup:[NSString stringWithUTF8String:__FUNCTION__]];
    [pass popDebugGroup];
}

void
Driver::streamOutBaseUpdate(const StreamOutBaseUpdate &data)
{
    beginPass();
    [pass pushDebugGroup:[NSString stringWithUTF8String:__FUNCTION__]];
    [pass popDebugGroup];
}

void
Driver::streamOutBufferUpdate(const StreamOutBufferUpdate &data)
{
    beginPass();
    [pass pushDebugGroup:[NSString stringWithUTF8String:__FUNCTION__]];
    [pass popDebugGroup];
}

void
Driver::surfaceSync(const SurfaceSync &data)
{
    beginPass();
    [pass pushDebugGroup:[NSString stringWithUTF8String:__FUNCTION__]];
    [pass popDebugGroup];
}

void
Driver::applyRegister(Register reg)
{
    endPass();
 
    const uint32_t value = getRegister<uint32_t>(reg);
    
    switch (reg) {
        case latte::Register_::CB_COLOR0_BASE:
            break;
    }
}

#endif // DECAF_METAL
