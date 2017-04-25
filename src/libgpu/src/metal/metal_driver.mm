#ifdef DECAF_METAL

#include "metal_driver.h"

using namespace metal;

#import <Metal/MTLDevice.h>

Driver::Driver()
{
    device_ = MTLCreateSystemDefaultDevice();
    commandQueue = [device_ newCommandQueue];
}

Driver::~Driver()
{
}

#endif // DECAF_METAL
