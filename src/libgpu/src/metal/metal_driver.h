#pragma once

#ifdef DECAF_METAL

#include "gpu_metaldriver.h"
#include "pm4_processor.h"

@protocol MTLCommandBuffer;
@protocol MTLCommandQueue;

namespace metal
{
    class Driver : public gpu::MetalDriver, Pm4Processor
    {
    public:
        Driver();
        virtual ~Driver() override;
        
        // MetalDriver
        id<MTLDevice> device() const override;
        void draw(id<CAMetalDrawable> drawable) override;
        
        // GraphicsDriver
        void run() override;
        void stop() override;
        float getAverageFPS() override;
        void notifyCpuFlush(void *ptr, uint32_t size) override;
        void notifyGpuFlush(void *ptr, uint32_t size) override;
        
    private:
        id<MTLDevice> device_ = nullptr;
        id<MTLCommandQueue> commandQueue = nullptr;
        id<MTLCommandBuffer> currentCommandBuffer = nullptr;
        
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
    };
} // namespace metal

#endif // DECAF_METAL
