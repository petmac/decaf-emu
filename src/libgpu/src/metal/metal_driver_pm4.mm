#ifdef DECAF_METAL

#include "metal_driver.h"

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
}

void
Driver::decafClearColor(const DecafClearColor &data)
{
}

void
Driver::decafClearDepthStencil(const DecafClearDepthStencil &data)
{
}

void
Driver::decafDebugMarker(const DecafDebugMarker &data)
{
}

void
Driver::decafOSScreenFlip(const DecafOSScreenFlip &data)
{
}

void
Driver::decafCopySurface(const DecafCopySurface &data)
{
}

void
Driver::decafSetSwapInterval(const DecafSetSwapInterval &data)
{
}

void
Driver::drawIndexAuto(const DrawIndexAuto &data)
{
}

void
Driver::drawIndex2(const DrawIndex2 &data)
{
}

void
Driver::drawIndexImmd(const DrawIndexImmd &data)
{
}

void
Driver::memWrite(const MemWrite &data)
{
}

void
Driver::eventWrite(const EventWrite &data)
{
}

void
Driver::eventWriteEOP(const EventWriteEOP &data)
{
}

void
Driver::pfpSyncMe(const PfpSyncMe &data)
{
}

void
Driver::streamOutBaseUpdate(const StreamOutBaseUpdate &data)
{
}

void
Driver::streamOutBufferUpdate(const StreamOutBufferUpdate &data)
{
}

void
Driver::surfaceSync(const SurfaceSync &data)
{
}

void
Driver::applyRegister(Register reg)
{
}

#endif // DECAF_METAL
