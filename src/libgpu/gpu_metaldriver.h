#pragma once

#ifdef DECAF_METAL

#include "gpu_graphicsdriver.h"

@protocol CAMetalDrawable;
@protocol MTLCommandQueue;

namespace gpu
{
    class MetalDriver : public GraphicsDriver
    {
    public:
        virtual ~MetalDriver() override;
        
        virtual void initialise(id<MTLCommandQueue> commandQueue) = 0;
        virtual void draw(id<CAMetalDrawable> drawable) = 0;
    };
} // namespace decaf

#endif // DECAF_METAL
