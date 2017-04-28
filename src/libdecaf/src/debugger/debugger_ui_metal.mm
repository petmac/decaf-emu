#ifdef DECAF_METAL

#include "debugger_ui_metal.h"

#include "debugger.h"

#include <imgui.h>

#import <Metal/MTLRenderCommandEncoder.h>
#import <Metal/MTLRenderPipeline.h>

using namespace debugger;
using namespace ui;

struct Uniforms
{
    float scale[2];
    float offset[2];
};

static NSString *const librarySource =
@"#include <metal_stdlib>\n"
@"using namespace metal;\n"
@"struct Uniforms {"
@"float2 scale;"
@"float2 offset;"
@"};\n"
@"struct ImDrawVert {"
@"packed_float2 pos;"
@"packed_float2 uv;"
@"uint col;"
@"};\n"
@"struct FragVert {"
@"float4 pos [[position]];"
@"float2 uv;"
@"float4 col;"
@"};\n"
@"vertex FragVert vertexShader(const device ImDrawVert *vertices [[buffer(0)]], uint v_id [[vertex_id]], constant Uniforms *u [[buffer(1)]]) {"
@"const ImDrawVert in = vertices[v_id];"
@"float2 pos = float2(in.pos[0], in.pos[1]) * u->scale + u->offset;"
@"FragVert out;"
@"out.pos = float4(pos, 0, 1);"
@"out.uv = float2(in.uv[0], in.uv[1]);"
@"out.col = unpack_unorm4x8_to_float(in.col);"
@"return out;"
@"}\n"
@"constexpr sampler s;\n"
@"fragment float4 fragmentShader(FragVert in [[stage_in]], texture2d<float> tex [[texture(0)]]) {"
@"const float alpha = tex.sample(s, in.uv).w * in.col.w;"
@"return float4(in.col.xyz, alpha);"
@"}\n"
@"";

RendererMetal::~RendererMetal()
{
}

void RendererMetal::initialise(id<MTLDevice> device)
{
    ImGuiIO &io = ImGui::GetIO();
    unsigned char *fontPixels = nullptr;
    int fontWidth = 0;
    int fontHeight = 0;
    io.Fonts->GetTexDataAsAlpha8(&fontPixels, &fontWidth, &fontHeight);
    
    MTLTextureDescriptor *fontDesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatA8Unorm width:fontWidth height:fontHeight mipmapped:NO];
    font = [device newTextureWithDescriptor:fontDesc];
    [font replaceRegion:MTLRegionMake2D(0, 0, fontWidth, fontHeight) mipmapLevel:0 withBytes:fontPixels bytesPerRow:fontWidth];
    io.Fonts->SetTexID((__bridge void *)font);
    
    NSError *error = nil;
    id<MTLLibrary> library = [device newLibraryWithSource:librarySource options:nil error:&error];
    
    MTLRenderPipelineDescriptor *pipelineDesc = [MTLRenderPipelineDescriptor new];
    pipelineDesc.fragmentFunction = [library newFunctionWithName:@"fragmentShader"];
    pipelineDesc.vertexFunction = [library newFunctionWithName:@"vertexShader"];
    
    MTLRenderPipelineColorAttachmentDescriptor *colorAttachment = pipelineDesc.colorAttachments[0];
    colorAttachment.blendingEnabled = YES;
    colorAttachment.destinationAlphaBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
    colorAttachment.destinationRGBBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
    colorAttachment.pixelFormat = MTLPixelFormatBGRA8Unorm;
    colorAttachment.sourceAlphaBlendFactor = MTLBlendFactorSourceAlpha;
    colorAttachment.sourceRGBBlendFactor = MTLBlendFactorSourceAlpha;
    
    pipeline = [device newRenderPipelineStateWithDescriptor:pipelineDesc error:&error];
}

void RendererMetal::draw(unsigned width, unsigned height, id<MTLRenderCommandEncoder> pass)
{
    debugger::draw(width, height);
    
    ImGuiIO &io = ImGui::GetIO();
    ImDrawData *drawData = ImGui::GetDrawData();
    drawData->ScaleClipRects(io.DisplayFramebufferScale);
    
    [pass setRenderPipelineState:pipeline];
    
    const Uniforms uniforms =
    {
        { 2.0f / width, -2.0f / height },
        { -1, 1 }
    };
    [pass setVertexBytes:&uniforms length:sizeof(uniforms) atIndex:1];
    
    for (auto n = 0; n < drawData->CmdListsCount; n++)
    {
        const ImDrawList *cmdList = drawData->CmdLists[n];
        NSUInteger indexBufferOffset = 0;
        
        id<MTLBuffer> indexBuffer = [pass.device newBufferWithBytes:cmdList->IdxBuffer.Data
                                                             length:cmdList->IdxBuffer.size() * sizeof(ImDrawIdx)
                                                            options:kNilOptions];
        id<MTLBuffer> vertexBuffer = [pass.device newBufferWithBytes:cmdList->VtxBuffer.Data
                                                              length:cmdList->VtxBuffer.size() * sizeof(ImDrawVert)
                                                             options:kNilOptions];
        [pass setVertexBuffer:vertexBuffer offset:0 atIndex:0];
        
        for (auto pcmd = cmdList->CmdBuffer.begin(); pcmd != cmdList->CmdBuffer.end(); pcmd++)
        {
            if (pcmd->UserCallback)
            {
                pcmd->UserCallback(cmdList, pcmd);
            }
            else
            {
                const MTLScissorRect scissorRect = {
                    static_cast<NSUInteger>(pcmd->ClipRect.x),
                    static_cast<NSUInteger>(pcmd->ClipRect.y),
                    static_cast<NSUInteger>(pcmd->ClipRect.z - pcmd->ClipRect.x),
                    static_cast<NSUInteger>(pcmd->ClipRect.w - pcmd->ClipRect.y)
                };
                [pass setScissorRect:scissorRect];
                [pass setFragmentTexture:(__bridge id<MTLTexture>)pcmd->TextureId atIndex:0];
                [pass drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                                 indexCount:pcmd->ElemCount
                                  indexType:sizeof(ImDrawIdx) == 2 ? MTLIndexTypeUInt16 : MTLIndexTypeUInt32
                                indexBuffer:indexBuffer
                          indexBufferOffset:indexBufferOffset];
            }
            
            indexBufferOffset += (pcmd->ElemCount * sizeof(ImDrawIdx));
        }
    }
}

#endif // DECAF_METAL
