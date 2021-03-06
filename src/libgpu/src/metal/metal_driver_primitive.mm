#ifdef DECAF_METAL

#include "metal_driver.h"

#include <common/byte_swap.h>
#include <common/decaf_assert.h>

#include <algorithm>

#import <Metal/MTLCommandQueue.h>
#import <Metal/MTLRenderCommandEncoder.h>

using namespace latte;
using namespace metal;

template <typename IndexType>
void
Driver::drawIndexedPrimities(const IndexType *src, NSUInteger count, MTLIndexType indexType)
{
    decaf_check(renderPass != nil);
    
    uint8_t temp[4096];
    const NSUInteger length = count * sizeof(IndexType);
    id<MTLBuffer> indexBuffer = [commandQueue.device newBufferWithLength:length
                                                                 options:MTLCPUCacheModeWriteCombined];
    std::transform(&src[0],
                   &src[count],
                   static_cast<IndexType *>(indexBuffer.contents),
                   byte_swap<uint32_t>);
    
    [renderPass setVertexBytes:temp length:sizeof(temp) atIndex:0];
    [renderPass drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                           indexCount:count
                            indexType:indexType
                          indexBuffer:indexBuffer
                    indexBufferOffset:0];
}

template void Driver::drawIndexedPrimities<uint16_t>(const uint16_t *, NSUInteger, MTLIndexType);
template void Driver::drawIndexedPrimities<uint32_t>(const uint32_t *, NSUInteger, MTLIndexType);

#endif // DECAF_METAL
