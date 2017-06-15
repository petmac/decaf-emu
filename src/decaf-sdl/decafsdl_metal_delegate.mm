#ifdef DECAF_METAL

#include "decafsdl_metal_delegate.h"

#include <libdecaf/decaf_metaldebugger.h>
#include <libgpu/gpu_metaldriver.h>

using namespace decaf;
using namespace gpu;

static NSString *const blitSource =
@"#include <metal_stdlib>\n"
@"using namespace metal;\n"
@"struct Vertex {\n"
@"float2 pos;\n"
@"float2 uv;\n"
@"};\n"
@"struct FragVert {\n"
@"float4 pos [[position]];\n"
@"float2 uv;\n"
@"};\n"
@"vertex FragVert vertexShader(const device Vertex *vertices [[buffer(0)]], uint v_id [[vertex_id]]) {\n"
@"const Vertex in = vertices[v_id];\n"
@"FragVert out;\n"
@"out.pos = float4(in.pos, 0, 1);\n"
@"out.uv = float2(in.uv);\n"
@"return out;\n"
@"}\n"
@"constexpr sampler s;\n"
@"fragment float4 fragmentShader(FragVert in [[stage_in]], texture2d<float> tex [[texture(0)]]) {\n"
@"return float4(tex.sample(s, in.uv).rgba);\n"
@"}\n";

@interface MetalDelegate ()
@property (nonatomic, readonly) id<MTLCommandQueue> commandQueue;
@property (nonatomic, readonly) id<MTLRenderPipelineState> blitPipeline;
@end

static id<MTLRenderPipelineState> createBlitPipeline(id<MTLDevice> device)
{
    NSError *error = nil;
    id<MTLLibrary> library = [device newLibraryWithSource:blitSource options:nil error:&error];
    
    MTLRenderPipelineDescriptor *desc = [MTLRenderPipelineDescriptor new];
    desc.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    desc.fragmentFunction = [library newFunctionWithName:@"fragmentShader"];
    desc.label = @"Blit";
    desc.vertexFunction = [library newFunctionWithName:@"vertexShader"];
    
    return [device newRenderPipelineStateWithDescriptor:desc error:&error];
}

static void blit(id<MTLRenderCommandEncoder> pass, id<MTLTexture> source, const CGRect &destination, const CGSize &screenSize)
{
    if (source == nil)
    {
        return;
    }
    
    struct Vertex
    {
        float pos[2];
        float uv[2];
    };
    
    const float scale[2] =
    {
        2 / static_cast<float>(screenSize.width),
        2 / static_cast<float>(screenSize.height)
    };
    
    const float extents[2][2] =
    {
        {
            static_cast<float>(CGRectGetMinX(destination)) * scale[0] - 1,
            static_cast<float>(CGRectGetMinY(destination)) * scale[1] - 1
        }, {
            static_cast<float>(CGRectGetMaxX(destination)) * scale[0] - 1,
            static_cast<float>(CGRectGetMaxY(destination)) * scale[1] - 1
        }
    };
    
    const Vertex vertices[4] =
    {
        { { extents[0][0], extents[0][1] }, { 0, 0 } },
        { { extents[0][0], extents[1][1] }, { 0, 1 } },
        { { extents[1][0], extents[0][1] }, { 1, 0 } },
        { { extents[1][0], extents[1][1] }, { 1, 1 } }
    };
    
    [pass setFragmentTexture:source atIndex:0];
    [pass setVertexBytes:&vertices length:sizeof(vertices) atIndex:0];
    [pass drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
}

@implementation MetalDelegate

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        MetalDriver *metalDriver = static_cast<MetalDriver *>(createMetalDriver());
        MetalDebugUiRenderer *metalDebugRenderer = static_cast<MetalDebugUiRenderer *>(createDebugMetalRenderer());
        
        _device = MTLCreateSystemDefaultDevice();
        _driver = std::shared_ptr<MetalDriver>(metalDriver);
        _debugRenderer = std::shared_ptr<MetalDebugUiRenderer>(metalDebugRenderer);
        _commandQueue = [self.device newCommandQueue];
        _blitPipeline = createBlitPipeline(_device);
        
        self.driver->initialise(_commandQueue);
        self.debugRenderer->initialise(_device);
    }
    
    return self;
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
}

- (void)drawInMTKView:(nonnull MTKView *)view {
    self.driver->draw();
    
    id<MTLTexture> tvTexture = nil;
    id<MTLTexture> drcTexture = nil;
    self.driver->getFrontBuffers(&tvTexture, &drcTexture);
    
    CAMetalLayer *layer = static_cast<CAMetalLayer *>(view.layer);
    id<CAMetalDrawable> drawable = [layer nextDrawable];
    const CGSize screenSize = CGSizeMake(drawable.texture.width, drawable.texture.height);
    
    MTLRenderPassDescriptor *passDesc = [MTLRenderPassDescriptor new];
    passDesc.colorAttachments[0].texture = drawable.texture;
    passDesc.colorAttachments[0].loadAction = MTLLoadActionClear;
    passDesc.colorAttachments[0].clearColor = MTLClearColorMake(0.7, 0.3, 0.3, 1);
    
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    commandBuffer.label = @"Blit TV and DRC to window";
    id<MTLRenderCommandEncoder> pass = [commandBuffer renderCommandEncoderWithDescriptor:passDesc];
    [pass setRenderPipelineState:self.blitPipeline];
    blit(pass, tvTexture, self.tvViewport, screenSize);
    blit(pass, drcTexture, self.drcViewport, screenSize);
    self.debugRenderer->draw(drawable.texture.width, drawable.texture.height, pass);
    [pass endEncoding];
    
    [commandBuffer presentDrawable:drawable];
    [commandBuffer commit];
}

@end

#endif // DECAF_METAL
