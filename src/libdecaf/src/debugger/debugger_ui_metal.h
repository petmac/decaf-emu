#pragma once

#ifdef DECAF_METAL

#include "decaf_debugger.h"

namespace debugger
{
    namespace ui
    {
        class RendererMetal : public decaf::DebugUiRenderer
        {
        public:
            void initialise() override;
            void draw(unsigned width, unsigned height)  override;
        };
    } // namespace ui
} // namespace debugger

#endif // DECAF_METAL
