#ifdef DECAF_METAL

#include "decafsdl_metal_delegate.h"

#include <libdecaf/decaf_metaldebugger.h>
#include <libgpu/gpu_metaldriver.h>

using namespace decaf;
using namespace gpu;

@interface MetalDelegate ()
@property (nonatomic, readonly) id<MTLCommandQueue> commandQueue;
@end

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
        
        self.driver->initialise(_commandQueue);
        self.debugRenderer->initialise(_device);
    }
    
    return self;
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
}

- (void)drawInMTKView:(nonnull MTKView *)view {
    self.driver->draw();
    
    CAMetalLayer *layer = static_cast<CAMetalLayer *>(view.layer);
    id<CAMetalDrawable> drawable = [layer nextDrawable];
    
    MTLRenderPassDescriptor *passDesc = [MTLRenderPassDescriptor new];
    passDesc.colorAttachments[0].texture = drawable.texture;
    passDesc.colorAttachments[0].loadAction = MTLLoadActionClear;
    passDesc.colorAttachments[0].clearColor = MTLClearColorMake(0.7, 0.3, 0.3, 1);
    
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    id<MTLRenderCommandEncoder> pass = [commandBuffer renderCommandEncoderWithDescriptor:passDesc];
    self.debugRenderer->draw(drawable.texture.width, drawable.texture.height, pass);
    [pass endEncoding];
    
    [commandBuffer presentDrawable:drawable];
    [commandBuffer commit];
}

@end

#endif // DECAF_METAL
