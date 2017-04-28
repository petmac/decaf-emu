#pragma once

#include "decaf_metaldebugger.h"

@protocol MTLRenderPipelineState;
@protocol MTLTexture;

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
            void draw(unsigned width, unsigned height, id<MTLRenderCommandEncoder> pass) override;
            
        private:
            id<MTLTexture> font = nullptr;
            id<MTLRenderPipelineState> pipeline = nullptr;
        };
    } // namespace ui
} // namespace debugger
