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
            void initialise(id<MTLDevice> device) override;
            void draw(id<MTLRenderCommandEncoder> pass) override;
            
        private:
            id<MTLDevice> device = nullptr;
        };
    } // namespace ui
} // namespace debugger
