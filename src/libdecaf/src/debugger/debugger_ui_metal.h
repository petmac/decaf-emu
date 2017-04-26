#pragma once

#include "decaf_metaldebugger.h"

namespace debugger
{
    namespace ui
    {
        class RendererMetal : public decaf::MetalDebugUiRenderer
        {
        public:
            virtual ~RendererMetal() override;
            
            // MetalDebugUiRenderer
            void initialise(id<MTLCommandQueue> commandQueue) override;
            
        private:
            id<MTLCommandQueue> commandQueue = nullptr;
        };
    } // namespace ui
} // namespace debugger
