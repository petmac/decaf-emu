#ifdef DECAF_METAL

#include "metal_driver.h"
#include "metal_delegate.h"

#include <MetalKit/MetalKit.h>

using namespace metal;

Driver::Driver()
{
    delegate_ = [[MetalDelegate alloc] initWithDriver:this];
}

Driver::~Driver()
{
}

id<MTKViewDelegate>
Driver::delegate() const
{
    return delegate_;
}

void
Driver::run()
{
}

void
Driver::stop()
{
}

float
Driver::getAverageFPS()
{
    return 0.0f;
}

void
Driver::notifyCpuFlush(void *ptr, uint32_t size)
{
}

void
Driver::notifyGpuFlush(void *ptr, uint32_t size)
{
}

#endif // DECAF_METAL
