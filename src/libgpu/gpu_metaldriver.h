#pragma once

#ifdef DECAF_METAL

#include "gpu_graphicsdriver.h"

@protocol CAMetalDrawable;
@protocol MTKViewDelegate;
@protocol MTLDevice;

namespace gpu
{
    class MetalDriver : public GraphicsDriver
    {
    public:
        virtual ~MetalDriver() override;
        
        virtual id<MTKViewDelegate> delegate() const = 0;
        virtual id<MTLDevice> device() const = 0;
        virtual void draw(id<CAMetalDrawable> drawable) = 0;
    };
} // namespace decaf

#endif // DECAF_METAL
