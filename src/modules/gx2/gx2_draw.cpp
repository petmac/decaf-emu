#include "gx2_draw.h"
#include "gpu/pm4_writer.h"

namespace gx2
{

void
GX2SetAttribBuffer(uint32_t index,
                   uint32_t size,
                   uint32_t stride,
                   void *buffer)
{
   pm4::SetVtxResource res;
   memset(&res, 0, sizeof(pm4::SetVtxResource));
   res.id = (index * 7) + latte::SQ_VS_ATTRIB_RESOURCE_0;
   res.baseAddress = buffer;
   res.size = size - 1;

   res.word2 = res.word2
      .STRIDE().set(stride);

   res.word6 = res.word6
      .TYPE().set(latte::SQ_TEX_VTX_VALID_BUFFER);

   pm4::write(res);
}

void
GX2DrawEx(GX2PrimitiveMode mode,
          uint32_t numVertices,
          uint32_t offset,
          uint32_t numInstances)
{
   auto vgt_dma_index_type = latte::VGT_DMA_INDEX_TYPE::get(0)
      .INDEX_TYPE().set(static_cast<latte::VGT_INDEX>(GX2IndexType::U32));

   auto vgt_draw_initiator = latte::VGT_DRAW_INITIATOR::get(0);

   pm4::write(pm4::SetControlConstant { latte::Register::SQ_VTX_BASE_VTX_LOC, offset });
   pm4::write(pm4::SetConfigReg { latte::Register::VGT_PRIMITIVE_TYPE, mode });
   pm4::write(pm4::IndexType { vgt_dma_index_type });
   pm4::write(pm4::NumInstances { numInstances });
   pm4::write(pm4::DrawIndexAuto { numVertices, vgt_draw_initiator });
}

void
GX2DrawIndexedEx(GX2PrimitiveMode mode,
                 uint32_t numVertices,
                 GX2IndexType indexType,
                 void *indices,
                 uint32_t offset,
                 uint32_t numInstances)
{
   auto vgt_dma_index_type = latte::VGT_DMA_INDEX_TYPE::get(0)
      .INDEX_TYPE().set(static_cast<latte::VGT_INDEX>(indexType));

   auto vgt_draw_initiator = latte::VGT_DRAW_INITIATOR::get(0);

   pm4::write(pm4::SetControlConstant { latte::Register::SQ_VTX_BASE_VTX_LOC, offset });
   pm4::write(pm4::SetConfigReg { latte::Register::VGT_PRIMITIVE_TYPE, mode });
   pm4::write(pm4::IndexType { vgt_dma_index_type });
   pm4::write(pm4::NumInstances { numInstances });
   pm4::write(pm4::DrawIndex2 { static_cast<uint32_t>(-1), indices, numVertices, vgt_draw_initiator });
}

void
GX2SetPrimitiveRestartIndex(uint32_t index)
{
   pm4::write(pm4::SetContextReg { latte::Register::VGT_MULTI_PRIM_IB_RESET_INDX, index });
}

} // namespace gx2
