#ifdef DECAF_METAL

#include "debugger_ui_metal.h"

using namespace debugger;
using namespace ui;

RendererMetal::~RendererMetal()
{
}

void RendererMetal::initialise(id<MTLDevice> device)
{
    this->device = device;
}

void RendererMetal::draw(id<MTLRenderCommandEncoder> pass)
{
}

#endif // DECAF_METAL
