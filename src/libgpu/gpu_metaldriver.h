#pragma once

#ifdef DECAF_METAL

#include "gpu_graphicsdriver.h"

@protocol MTLCommandQueue;
@protocol MTLTexture;

namespace gpu
{
    class MetalDriver : public GraphicsDriver
    {
    public:
        virtual ~MetalDriver() override;
        
        virtual void initialise(id<MTLCommandQueue> commandQueue) = 0;
        virtual void draw() = 0;
        virtual void getFrontBuffers(id<MTLTexture> *tv, id<MTLTexture> *drc) = 0;
    };
} // namespace decaf

#endif // DECAF_METAL
