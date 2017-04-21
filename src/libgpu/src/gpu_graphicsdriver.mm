#include "gpu_graphicsdriver.h"

#include "metal/metal_driver.h"

namespace gpu
{
#ifdef DECAF_METAL
GraphicsDriver *
createMetalDriver()
{
   return new metal::Driver();
}
#endif
} // namespace gpu
