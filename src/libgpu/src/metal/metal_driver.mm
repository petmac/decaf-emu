#ifdef DECAF_METAL

#include "metal_driver.h"

#include "metal_delegate.h"

using namespace metal;

Driver::Driver()
{
    delegate_ = [[MetalDelegate alloc] initWithDriver:this];
    device_ = MTLCreateSystemDefaultDevice();
    commandQueue = [device_ newCommandQueue];
}

Driver::~Driver()
{
}

#endif // DECAF_METAL
