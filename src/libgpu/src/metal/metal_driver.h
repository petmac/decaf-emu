#pragma once

#ifdef DECAF_METAL

#include "gpu_metaldriver.h"

namespace metal
{
    class Driver : public gpu::MetalDriver
    {
    public:
        Driver();
        virtual ~Driver() = default;
        
        void run() override;
        void stop() override;
        float getAverageFPS() override;
        
        void notifyCpuFlush(void *ptr, uint32_t size) override;
        void notifyGpuFlush(void *ptr, uint32_t size) override;
    };
} // namespace metal

#endif // DECAF_METAL
