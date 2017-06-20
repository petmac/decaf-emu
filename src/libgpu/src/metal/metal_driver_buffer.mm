#ifdef DECAF_METAL

#include "metal_driver.h"

#include "latte/latte_formats.h"

#import <Metal/MTLCommandQueue.h>

using namespace latte;
using namespace metal;

id<MTLTexture> Driver::getColorBuffer(CB_COLORN_BASE base, CB_COLORN_SIZE size, CB_COLORN_INFO info)
{
    const ColorBufferKey key(base.value, size.value, info.value);
    const ColorBuffers::const_iterator found = colorBuffers.find(key);
    if (found != colorBuffers.end()) {
        return found->second;
    }
    
    auto baseAddress = (base.BASE_256B() << 8) & 0xFFFFF800;
    auto pitch_tile_max = size.PITCH_TILE_MAX();
    auto slice_tile_max = size.SLICE_TILE_MAX();
    
    auto pitch = static_cast<uint32_t>((pitch_tile_max + 1) * latte::MicroTileWidth);
    auto height = static_cast<uint32_t>(((slice_tile_max + 1) * (latte::MicroTileWidth * latte::MicroTileHeight)) / pitch);
    
    auto cbNumberType = info.NUMBER_TYPE();
    auto cbFormat = info.FORMAT();
    auto format = static_cast<latte::SQ_DATA_FORMAT>(cbFormat);
    
    auto numFormat = latte::SQ_NUM_FORMAT::NORM;
    auto formatComp = latte::SQ_FORMAT_COMP::UNSIGNED;
    auto degamma = 0u;
    
    switch (cbNumberType) {
        case latte::CB_NUMBER_TYPE::UNORM:
            numFormat = latte::SQ_NUM_FORMAT::NORM;
            formatComp = latte::SQ_FORMAT_COMP::UNSIGNED;
            degamma = 0;
            break;
        case latte::CB_NUMBER_TYPE::SNORM:
            numFormat = latte::SQ_NUM_FORMAT::NORM;
            formatComp = latte::SQ_FORMAT_COMP::SIGNED;
            degamma = 0;
            break;
        case latte::CB_NUMBER_TYPE::UINT:
            numFormat = latte::SQ_NUM_FORMAT::INT;
            formatComp = latte::SQ_FORMAT_COMP::UNSIGNED;
            degamma = 0;
            break;
        case latte::CB_NUMBER_TYPE::SINT:
            numFormat = latte::SQ_NUM_FORMAT::INT;
            formatComp = latte::SQ_FORMAT_COMP::SIGNED;
            degamma = 0;
            break;
        case latte::CB_NUMBER_TYPE::FLOAT:
            numFormat = latte::SQ_NUM_FORMAT::SCALED;
            formatComp = latte::SQ_FORMAT_COMP::UNSIGNED;
            degamma = 0;
            break;
        case latte::CB_NUMBER_TYPE::SRGB:
            numFormat = latte::SQ_NUM_FORMAT::NORM;
            formatComp = latte::SQ_FORMAT_COMP::UNSIGNED;
            degamma = 1;
            break;
        default:
            decaf_abort(fmt::format("Color buffer with unsupported number type {}", cbNumberType));
    }
    
    auto tileMode = latte::getArrayModeTileMode(info.ARRAY_MODE());
    
    MTLTextureDescriptor *textureDesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatBGRA8Unorm
                                                                                           width:pitch
                                                                                          height:height
                                                                                       mipmapped:NO];
    textureDesc.usage = MTLTextureUsageShaderRead | MTLTextureUsageRenderTarget;
    
    const id<MTLTexture> colorBuffer = [commandQueue.device newTextureWithDescriptor:textureDesc];
    colorBuffers.insert(ColorBuffers::value_type(key, colorBuffer));
    
    return colorBuffer;
}

#endif // DECAF_METAL
