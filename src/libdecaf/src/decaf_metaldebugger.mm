#ifdef DECAF_METAL

#include "decaf_metaldebugger.h"

#include <common/decaf_assert.h>

using namespace decaf;

MetalDebugUiRenderer::~MetalDebugUiRenderer()
{
}

void MetalDebugUiRenderer::initialise()
{
    decaf_abort("Do not call.");
}

void MetalDebugUiRenderer::draw(unsigned int width, unsigned int height)
{
    decaf_abort("Do not call.");
}

#endif // DECAF_METAL
