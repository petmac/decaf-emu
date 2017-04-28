#pragma once

#include "decaf_debugger.h"

@protocol MTLDevice;
@protocol MTLRenderCommandEncoder;

namespace decaf
{
    class MetalDebugUiRenderer : public DebugUiRenderer
    {
    public:
        virtual ~MetalDebugUiRenderer() override;
        
        virtual void initialise(id<MTLDevice> device) = 0;
        virtual void draw(unsigned width, unsigned height, id<MTLRenderCommandEncoder> pass) = 0;
        
        // DebugUiRenderer
        void initialise() override;
        void draw(unsigned width, unsigned height) override;
    };
} // namespace decaf
