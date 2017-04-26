#ifdef DECAF_METAL

#include "debugger_ui_metal.h"

using namespace debugger;
using namespace ui;

RendererMetal::~RendererMetal()
{
}

void RendererMetal::initialise(id<MTLCommandQueue> commandQueue)
{
    this->commandQueue = commandQueue;
}

#endif // DECAF_METAL
