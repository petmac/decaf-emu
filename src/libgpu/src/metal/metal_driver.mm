#ifdef DECAF_METAL

#include "metal_driver.h"
#include "metal_delegate.h"

#include <MetalKit/MetalKit.h>

using namespace metal;

static NSString *const source =
@"#include <metal_stdlib>\n"
@"using namespace metal;"
@"typedef struct { float2 position;} Triangle;"
@"typedef struct { float4 position [[position]]; } TriangleOutput;"
@"vertex TriangleOutput VertexColor(const device Triangle *Vertices [[buffer(0)]], const uint index [[vertex_id]]) {"
@"    TriangleOutput out;"
@"    out.position = float4(Vertices[index].position, 0.0, 1.0);"
@"    return out;"
@"}"
@"fragment half4 FragmentColor(void) {"
@"  return half4(1.0, 0.0, 0.0, 1.0);"
@"}";

static const float triangle[3][2] = {
    { -1, -1 },
    { 1, -1 },
    { 0, 1 }
};

Driver::Driver()
{
    delegate_ = [[MetalDelegate alloc] initWithDriver:this];
    device_ = MTLCreateSystemDefaultDevice();
    commandQueue = [device_ newCommandQueue];
    vertexBuffer = [device_ newBufferWithBytes:&triangle length:sizeof(triangle) options:MTLResourceCPUCacheModeDefaultCache];
    
    NSError *error = nil;
    id<MTLLibrary> lib = [device_ newLibraryWithSource:source options:nil error:&error];
    
    MTLRenderPipelineDescriptor *rpd = [MTLRenderPipelineDescriptor new];
    rpd.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    rpd.fragmentFunction = [lib newFunctionWithName:@"FragmentColor"];
    rpd.vertexFunction = [lib newFunctionWithName:@"VertexColor"];
    
    pipeline = [device_ newRenderPipelineStateWithDescriptor:rpd error:&error];
}

Driver::~Driver()
{
}

id<MTKViewDelegate>
Driver::delegate() const
{
    return delegate_;
}

id<MTLDevice>
Driver::device() const
{
    return device_;
}

void
Driver::draw(id<CAMetalDrawable> drawable)
{
    MTLRenderPassDescriptor *pass = [MTLRenderPassDescriptor new];
    pass.colorAttachments[0].texture = drawable.texture;
    pass.colorAttachments[0].loadAction = MTLLoadActionClear;
    pass.colorAttachments[0].clearColor = MTLClearColorMake(0.0625, 0.125, 0.25, 1);

    id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];
    id<MTLRenderCommandEncoder> command = [commandBuffer renderCommandEncoderWithDescriptor:pass];
    [command setRenderPipelineState:pipeline];
    [command setVertexBuffer:vertexBuffer offset:0 atIndex:0];
    [command drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:3];
    [command endEncoding];
    
    [commandBuffer presentDrawable:drawable];
    [commandBuffer commit];
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
