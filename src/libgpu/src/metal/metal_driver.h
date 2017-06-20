#pragma once

#ifdef DECAF_METAL

#include "gpu_metaldriver.h"
#include "pm4_processor.h"

#include <map>
#include <tuple>
#include <vector>

#import <Metal/MTLStageInputOutputDescriptor.h>

@protocol MTLBlitCommandEncoder;
@protocol MTLCommandBuffer;
@protocol MTLCommandEncoder;
@protocol MTLRenderCommandEncoder;

namespace metal
{
    class Driver : public gpu::MetalDriver, Pm4Processor
    {
    public:
        Driver();
        virtual ~Driver() override;
        
        // MetalDriver
        void initialise(id<MTLCommandQueue> commandQueue) override;
        void draw() override;
        void getFrontBuffers(id<MTLTexture> *tv, id<MTLTexture> *drc) override;
        
        // GraphicsDriver
        void run() override;
        void stop() override;
        float getAverageFPS() override;
        void notifyCpuFlush(void *ptr, uint32_t size) override;
        void notifyGpuFlush(void *ptr, uint32_t size) override;
        
    private:
        typedef std::vector<id<MTLTexture>> ScanBufferChain;
        typedef std::tuple<uint32_t, uint32_t, uint32_t> ColorBufferKey;
        typedef std::map<ColorBufferKey, id<MTLTexture>> ColorBuffers;
        
        MTLRenderPassDescriptor *renderPassDesc = nullptr;
        MTLRenderPipelineDescriptor *renderPipelineDesc = nullptr;
        id<MTLCommandQueue> commandQueue = nullptr;
        id<MTLCommandBuffer> currentCommandBuffer = nullptr;
        id<MTLBlitCommandEncoder> blitPass = nullptr;
        id<MTLRenderCommandEncoder> renderPass = nullptr;
        id<MTLCommandEncoder> pass = nullptr;
        ScanBufferChain tvScanBuffers;
        ScanBufferChain drcScanBuffers;
        ColorBuffers colorBuffers;
        bool renderPipelineStateSet = false;
        
        // Pm4Processor.
        void decafSetBuffer(const DecafSetBuffer &data) override;
        void decafCopyColorToScan(const DecafCopyColorToScan &data) override;
        void decafSwapBuffers(const DecafSwapBuffers &data) override;
        void decafCapSyncRegisters(const DecafCapSyncRegisters &data) override;
        void decafClearColor(const DecafClearColor &data) override;
        void decafClearDepthStencil(const DecafClearDepthStencil &data) override;
        void decafDebugMarker(const DecafDebugMarker &data) override;
        void decafOSScreenFlip(const DecafOSScreenFlip &data) override;
        void decafCopySurface(const DecafCopySurface &data) override;
        void decafSetSwapInterval(const DecafSetSwapInterval &data) override;
        void drawIndexAuto(const DrawIndexAuto &data) override;
        void drawIndex2(const DrawIndex2 &data) override;
        void drawIndexImmd(const DrawIndexImmd &data) override;
        void memWrite(const MemWrite &data) override;
        void eventWrite(const EventWrite &data) override;
        void eventWriteEOP(const EventWriteEOP &data) override;
        void pfpSyncMe(const PfpSyncMe &data) override;
        void streamOutBaseUpdate(const StreamOutBaseUpdate &data) override;
        void streamOutBufferUpdate(const StreamOutBufferUpdate &data) override;
        void surfaceSync(const SurfaceSync &data) override;
        void applyRegister(latte::Register reg) override;
        
        // Buffer management.
        id<MTLTexture> getColorBuffer(latte::CB_COLORN_BASE base, latte::CB_COLORN_SIZE size, latte::CB_COLORN_INFO info);
        
        // Pass management.
        void beginBlitPass();
        void beginRenderPass();
        void beginPass();
        void endPass();
        
        // Primitive rendering.
        template <typename IndexType>
        void drawIndexedPrimities(const IndexType *src, NSUInteger count, MTLIndexType indexType);
    };
} // namespace metal

#endif // DECAF_METAL
