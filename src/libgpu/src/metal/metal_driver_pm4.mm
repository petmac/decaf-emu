#ifdef DECAF_METAL

#include "metal_driver.h"

#include "metal_unimplemented.h"

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
    unimplemented(__FUNCTION__);
}

void
Driver::decafSwapBuffers(const DecafSwapBuffers &data)
{
    if (!tvScanBuffers.empty())
    {
        std::rotate(tvScanBuffers.begin(), tvScanBuffers.end() - 1, tvScanBuffers.end());
    }
    if (!drcScanBuffers.empty())
    {
        std::rotate(drcScanBuffers.begin(), drcScanBuffers.end() - 1, drcScanBuffers.end());
    }
}

void
Driver::decafCapSyncRegisters(const DecafCapSyncRegisters &data)
{
    unimplemented(__FUNCTION__);
}

void
Driver::decafClearColor(const DecafClearColor &data)
{
    unimplemented(__FUNCTION__);
}

void
Driver::decafClearDepthStencil(const DecafClearDepthStencil &data)
{
    unimplemented(__FUNCTION__);
}

void
Driver::decafDebugMarker(const DecafDebugMarker &data)
{
    unimplemented(__FUNCTION__);
}

void
Driver::decafOSScreenFlip(const DecafOSScreenFlip &data)
{
    unimplemented(__FUNCTION__);
}

void
Driver::decafCopySurface(const DecafCopySurface &data)
{
    unimplemented(__FUNCTION__);
}

void
Driver::decafSetSwapInterval(const DecafSetSwapInterval &data)
{
    unimplemented(__FUNCTION__);
}

void
Driver::drawIndexAuto(const DrawIndexAuto &data)
{
    unimplemented(__FUNCTION__);
}

void
Driver::drawIndex2(const DrawIndex2 &data)
{
    unimplemented(__FUNCTION__);
}

void
Driver::drawIndexImmd(const DrawIndexImmd &data)
{
    unimplemented(__FUNCTION__);
}

void
Driver::memWrite(const MemWrite &data)
{
    unimplemented(__FUNCTION__);
}

void
Driver::eventWrite(const EventWrite &data)
{
    unimplemented(__FUNCTION__);
}

void
Driver::eventWriteEOP(const EventWriteEOP &data)
{
    unimplemented(__FUNCTION__);
}

void
Driver::pfpSyncMe(const PfpSyncMe &data)
{
    unimplemented(__FUNCTION__);
}

void
Driver::streamOutBaseUpdate(const StreamOutBaseUpdate &data)
{
    unimplemented(__FUNCTION__);
}

void
Driver::streamOutBufferUpdate(const StreamOutBufferUpdate &data)
{
    unimplemented(__FUNCTION__);
}

void
Driver::surfaceSync(const SurfaceSync &data)
{
    unimplemented(__FUNCTION__);
}

void
Driver::applyRegister(Register reg)
{
    unimplemented(__FUNCTION__);
}

#endif // DECAF_METAL
