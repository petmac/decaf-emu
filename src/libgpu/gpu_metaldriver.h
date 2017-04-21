#pragma once

#ifdef DECAF_METAL

#include "gpu_graphicsdriver.h"

@protocol MTKViewDelegate;

namespace gpu
{
    class MetalDriver : public GraphicsDriver
    {
    public:
        virtual ~MetalDriver() override;
        
        virtual id<MTKViewDelegate> delegate() const = 0;
    };
} // namespace decaf

#endif // DECAF_METAL
