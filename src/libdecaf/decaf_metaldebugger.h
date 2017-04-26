#pragma once

#include "decaf_debugger.h"

@protocol MTLCommandQueue;

namespace decaf
{
    class MetalDebugUiRenderer : public DebugUiRenderer
    {
    public:
        virtual ~MetalDebugUiRenderer() override;
        
        virtual void initialise(id<MTLCommandQueue> commandQueue) = 0;
        
        // DebugUiRenderer
        void initialise() override;
        void draw(unsigned width, unsigned height) override;
    };
} // namespace decaf
