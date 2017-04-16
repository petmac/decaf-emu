#pragma once

#ifdef DECAF_METAL

#include "gpu_graphicsdriver.h"

namespace metal
{
    class Driver : public gpu::GraphicsDriver
    {
    public:
        Driver();
        virtual ~Driver() = default;
        
        void run() override;
        void stop() override;
        float getAverageFPS() override;
        
        void notifyCpuFlush(void *ptr, uint32_t size) override;
        void notifyGpuFlush(void *ptr, uint32_t size) override;
        
    private:
        
    };
} // namespace metal

#endif // DECAF_METAL
