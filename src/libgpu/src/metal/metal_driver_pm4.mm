#ifdef DECAF_METAL

#include "metal_driver.h"

#include "gpu_event.h"

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
    beginPass();
    [currentPass pushDebugGroup:[NSString stringWithUTF8String:__FUNCTION__]];
    [currentPass popDebugGroup];
}

void
Driver::decafSwapBuffers(const DecafSwapBuffers &data)
{
    beginPass();
    [currentPass pushDebugGroup:[NSString stringWithUTF8String:__FUNCTION__]];
    [currentPass popDebugGroup];
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
    [currentPass pushDebugGroup:[NSString stringWithUTF8String:__FUNCTION__]];
    [currentPass popDebugGroup];
    
    gpu::onSyncRegisters(mRegisters.data(), static_cast<uint32_t>(mRegisters.size()));
}

void
Driver::decafClearColor(const DecafClearColor &data)
{
    beginPass();
    [currentPass pushDebugGroup:[NSString stringWithUTF8String:__FUNCTION__]];
    [currentPass popDebugGroup];
}

void
Driver::decafClearDepthStencil(const DecafClearDepthStencil &data)
{
    beginPass();
    [currentPass pushDebugGroup:[NSString stringWithUTF8String:__FUNCTION__]];
    [currentPass popDebugGroup];
}

void
Driver::decafDebugMarker(const DecafDebugMarker &data)
{
    beginPass();
    [currentPass insertDebugSignpost:[NSString stringWithUTF8String:data.key.data()]];
}

void
Driver::decafOSScreenFlip(const DecafOSScreenFlip &data)
{
    beginPass();
    [currentPass pushDebugGroup:[NSString stringWithUTF8String:__FUNCTION__]];
    [currentPass popDebugGroup];
}

void
Driver::decafCopySurface(const DecafCopySurface &data)
{
    beginPass();
    [currentPass pushDebugGroup:[NSString stringWithUTF8String:__FUNCTION__]];
    [currentPass popDebugGroup];
}

void
Driver::decafSetSwapInterval(const DecafSetSwapInterval &data)
{
    beginPass();
    [currentPass pushDebugGroup:[NSString stringWithUTF8String:__FUNCTION__]];
    [currentPass popDebugGroup];
}

void
Driver::drawIndexAuto(const DrawIndexAuto &data)
{
    beginPass();
    [currentPass pushDebugGroup:[NSString stringWithUTF8String:__FUNCTION__]];
    [currentPass popDebugGroup];
}

void
Driver::drawIndex2(const DrawIndex2 &data)
{
    beginPass();
    [currentPass pushDebugGroup:[NSString stringWithUTF8String:__FUNCTION__]];
    [currentPass popDebugGroup];
}

void
Driver::drawIndexImmd(const DrawIndexImmd &data)
{
    beginPass();
    [currentPass pushDebugGroup:[NSString stringWithUTF8String:__FUNCTION__]];
    [currentPass popDebugGroup];
}

void
Driver::memWrite(const MemWrite &data)
{
    beginPass();
    [currentPass pushDebugGroup:[NSString stringWithUTF8String:__FUNCTION__]];
    [currentPass popDebugGroup];
}

void
Driver::eventWrite(const EventWrite &data)
{
    beginPass();
    [currentPass pushDebugGroup:[NSString stringWithUTF8String:__FUNCTION__]];
    [currentPass popDebugGroup];
}

void
Driver::eventWriteEOP(const EventWriteEOP &data)
{
    beginPass();
    [currentPass pushDebugGroup:[NSString stringWithUTF8String:__FUNCTION__]];
    [currentPass popDebugGroup];
}

void
Driver::pfpSyncMe(const PfpSyncMe &data)
{
    beginPass();
    [currentPass pushDebugGroup:[NSString stringWithUTF8String:__FUNCTION__]];
    [currentPass popDebugGroup];
}

void
Driver::streamOutBaseUpdate(const StreamOutBaseUpdate &data)
{
    beginPass();
    [currentPass pushDebugGroup:[NSString stringWithUTF8String:__FUNCTION__]];
    [currentPass popDebugGroup];
}

void
Driver::streamOutBufferUpdate(const StreamOutBufferUpdate &data)
{
    beginPass();
    [currentPass pushDebugGroup:[NSString stringWithUTF8String:__FUNCTION__]];
    [currentPass popDebugGroup];
}

void
Driver::surfaceSync(const SurfaceSync &data)
{
    beginPass();
    [currentPass pushDebugGroup:[NSString stringWithUTF8String:__FUNCTION__]];
    [currentPass popDebugGroup];
}

void
Driver::applyRegister(Register reg)
{
}

#endif // DECAF_METAL
