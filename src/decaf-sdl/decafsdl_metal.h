#pragma once

#ifdef DECAF_METAL

#include "decafsdl_graphics.h"
#include <memory>

class DecafSDLMetal : public DecafSDLGraphics
{
public:
    DecafSDLMetal();
    ~DecafSDLMetal() override;
    
    bool
    initialise(int width, int height) override;
    
    void
    shutdown() override;
    
    void
    renderFrame(Viewport &tv, Viewport &drc) override;
    
    gpu::GraphicsDriver *
    getDecafDriver() override;
    
    decaf::DebugUiRenderer *
    getDecafDebugUiRenderer() override;
    
protected:
    std::unique_ptr<gpu::GraphicsDriver> mDecafDriver;
    std::unique_ptr<decaf::DebugUiRenderer> mDebugUiRenderer;
};

#endif // DECAF_METAL
