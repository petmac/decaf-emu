#pragma once

#ifdef DECAF_METAL

#include "gpu_graphicsdriver.h"

#ifdef __OBJC__
#if !__has_feature(objc_arc)
#error ARC is disabled.
#endif
@protocol MTKViewDelegate;
typedef id<MTKViewDelegate> MetalDelegatePtr;
#else
typedef struct MetalDelegate *MetalDelegatePtr;
#endif

namespace gpu
{
    class MetalDriver : public GraphicsDriver
    {
    public:
        MetalDelegatePtr delegate = nullptr;
        
        virtual ~MetalDriver() = default;
    };
} // namespace decaf

#endif // DECAF_METAL
