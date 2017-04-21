#pragma once

#ifdef DECAF_METAL

#include "gpu_metaldriver.h"

@protocol MTLCommandQueue;

namespace metal
{
    class Driver : public gpu::MetalDriver
    {
    public:
        Driver();
        virtual ~Driver() override;
        
        // MetalDriver
        id<MTKViewDelegate> delegate() const override;
        id<MTLDevice> device() const override;
        void draw(id<CAMetalDrawable> drawable) override;
        
        // GraphicsDriver
        void run() override;
        void stop() override;
        float getAverageFPS() override;
        void notifyCpuFlush(void *ptr, uint32_t size) override;
        void notifyGpuFlush(void *ptr, uint32_t size) override;
        
    private:
        id<MTKViewDelegate> delegate_ = nullptr;
        id<MTLDevice> device_ = nullptr;
        id<MTLCommandQueue> commandQueue = nullptr;
    };
} // namespace metal

#endif // DECAF_METAL
