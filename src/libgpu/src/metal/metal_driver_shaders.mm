#ifdef DECAF_METAL

#include "metal_driver.h"

#include <common/decaf_assert.h>

#import <Metal/MTLCommandQueue.h>

using namespace gpu;
using namespace metal;

static NSString *const fragmentShaderSource =
@"#include <metal_stdlib>\n"
@"using namespace metal;\n"
@"fragment float4 frag(float4 pos [[position]]) {\n"
@"return float4(1, 1, 0, 1);\n"
@"}\n";

static NSString *const vertexShaderSource =
@"#include <metal_stdlib>\n"
@"using namespace metal;\n"
@"vertex float4 vert(const device float4 *vertices [[buffer(0)]], uint vid [[vertex_id]]) {\n"
@"return vertices[vid];\n"
@"}\n";

id<MTLFunction>
Driver::getFragmentShader()
{
    id<MTLDevice> device = commandQueue.device;
    NSError *error = nil;
    id<MTLLibrary> library = [device newLibraryWithSource:fragmentShaderSource
                                                  options:nil
                                                    error:&error];
    const id<MTLFunction> function = [library newFunctionWithName:@"frag"];
    decaf_assert(function != nil, error.localizedDescription.UTF8String);
    
    return function;
}

id<MTLFunction>
Driver::getVertexShader()
{
    id<MTLDevice> device = commandQueue.device;
    NSError *error = nil;
    id<MTLLibrary> library = [device newLibraryWithSource:vertexShaderSource
                                                  options:nil
                                                    error:&error];
    const id<MTLFunction> function = [library newFunctionWithName:@"vert"];
    decaf_assert(function != nil, error.localizedDescription.UTF8String);
    
    return function;
}

#endif // DECAF_METAL
