; RUN: llvm-spirv %s -o %t.spt -spirv-text --spirv-ext=+SPV_INTEL_subgroups,+SPV_KHR_untyped_pointers
; R/UN: FileCheck < %t.spt %s --check-prefix=CHECK-SPIRV
; RUN: llvm-spirv %s -o %t.spv --spirv-ext=+SPV_INTEL_subgroups,+SPV_KHR_untyped_pointers
; RUN: spirv-val %t.spv
; RUN: llvm-spirv -r %t.spv -o %t.rev.bc
; RUN: llvm-dis < %t.rev.bc | FileCheck %s --check-prefix=CHECK-LLVM
; RUN: llvm-spirv -r %t.spv -o %t.rev.bc --spirv-target-env=SPV-IR
; RUN: llvm-dis < %t.rev.bc | FileCheck %s --check-prefix=CHECK-LLVM-SPIRV

target datalayout = "e-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024"
target triple = "spir64"

; CHECK-SPIRV: Capability SubgroupBufferBlockIOINTEL
; CHECK-SPIRV: Extension "SPV_INTEL_subgroups"

; CHECK-SPIRV: TypeInt [[#Int32:]] 32 0
; CHECK-SPIRV: TypeInt [[#Int64:]] 64 0
; CHECK-SPIRV-DAG: TypeVector [[#IntVec2:]] [[#Int32]] 2
; CHECK-SPIRV-DAG: TypeUntypedPointerKHR [[#PtrTy:]] 5
; CHECK-SPIRV-DAG: TypePointer [[#Int32Ptr:]] 5 [[#Int32]]
; CHECK-SPIRV-DAG: TypePointer [[#Int64Ptr:]] 5 [[#Int64]]

; CHECK-SPIRV: Function
; CHECK-SPIRV: FunctionParameter [[#PtrTy]] [[#ParamPtr:]]

; CHECK-SPIRV: Bitcast [[#Int32Ptr]] [[#TypedPtr:]] [[#]]
; CHECK-SPIRV: SubgroupBlockReadINTEL [[#IntVec2]] [[#Res:]] [[#TypedPtr]]
; CHECK-SPIRV: Bitcast [[#Int32Ptr]] [[#TypedPtr:]] [[#ParamPtr]]
; CHECK-SPIRV: SubgroupBlockWriteINTEL [[#TypedPtr]] [[#Res]]

; CHECK-SPIRV: SubgroupBlockReadINTEL
; CHECK-SPIRV: SubgroupBlockWriteINTEL

; CHECK-SPIRV: Function
; CHECK-SPIRV: Bitcast [[#Int64Ptr]] [[#TypedPtr:]] [[#]]
; CHECK-SPIRV: SubgroupBlockReadINTEL [[#Int64]] [[#Res:]] [[#TypedPtr]]

target datalayout = "e-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024"
target triple = "spir64"

; Function Attrs: convergent nounwind
define spir_kernel void @test_subgroup_block_read_write(<2 x float> %x, i32 %c, ptr addrspace(1) %p, ptr addrspace(1) %sp, ptr addrspace(1) %cp, ptr addrspace(1) %lp) local_unnamed_addr {
; CHECK-LLVM-LABEL: @test_subgroup_block_read_write(
; CHECK-LLVM-NEXT:  entry:
; CHECK-LLVM:    [[P0:%.*]] = bitcast ptr addrspace(1) [[P:%.*]] to ptr addrspace(1)
; CHECK-LLVM:    [[CALL5:%.*]] = call spir_func <2 x i32> @_Z27intel_sub_group_block_read2PU3AS1Kj(ptr addrspace(1) [[P0]])
; without fix                                             @_Z27intel_sub_group_block_read2PU3AS1Kh
; CHECK-LLVM-NEXT:    [[P1:%.*]] = bitcast ptr addrspace(1) [[P]] to ptr addrspace(1)
; CHECK-LLVM-NEXT:    call spir_func void @_Z28intel_sub_group_block_write2PU3AS1jDv2_j(ptr addrspace(1) [[P1]], <2 x i32> [[CALL5]])
; without fix                             @_Z28intel_sub_group_block_write2PU3AS1hDv2_j

; CHECK-LLVM-NEXT:    [[CP0:%.*]] = bitcast ptr addrspace(1) [[CP:%.*]] to ptr addrspace(1)
; CHECK-LLVM-NEXT:    [[CALL13:%.*]] = call spir_func <16 x i8> @_Z31intel_sub_group_block_read_uc16PU3AS1Kh(ptr addrspace(1) [[CP0]])
; CHECK-LLVM-NEXT:    [[CP1:%.*]] = bitcast ptr addrspace(1) [[CP]] to ptr addrspace(1)
; CHECK-LLVM-NEXT:    call spir_func void @_Z32intel_sub_group_block_write_uc16PU3AS1hDv16_h(ptr addrspace(1) [[CP1]], <16 x i8> [[CALL13]])
; CHECK-LLVM-NEXT:    ret void

; CHECK-LLVM-SPIRV: call spir_func <2 x i32> @_Z36__spirv_SubgroupBlockReadINTEL_Rint2PU3AS1Kj(
                               ; without fix: _Z36__spirv_SubgroupBlockReadINTEL_Rint2PU3AS1Kh
; CHECK-LLVM-SPIRV: call spir_func void @_Z31__spirv_SubgroupBlockWriteINTELPU3AS1jDv2_j(
; CHECK-LLVM-SPIRV: call spir_func <16 x i8> @_Z38__spirv_SubgroupBlockReadINTEL_Rchar16PU3AS1Kh(
; CHECK-LLVM-SPIRV: call spir_func void @_Z31__spirv_SubgroupBlockWriteINTELPU3AS1hDv16_h(

entry:
  %0 = addrspacecast ptr addrspace(1) %p to ptr addrspace(4)
  %call.i.i = call spir_func ptr addrspace(1) @__to_global(ptr addrspace(4) %0)
  %call5 = tail call spir_func <2 x i32> @_Z27intel_sub_group_block_read2PU3AS1Kj(ptr addrspace(1) %call.i.i) #2
  tail call spir_func void @_Z28intel_sub_group_block_write2PU3AS1jDv2_j(ptr addrspace(1) %p, <2 x i32> %call5) #2

  %call13 = tail call spir_func <16 x i8> @_Z31intel_sub_group_block_read_uc16PU3AS1Kh(ptr addrspace(1) %cp) #2
  tail call spir_func void @_Z32intel_sub_group_block_write_uc16PU3AS1hDv16_h(ptr addrspace(1) %cp, <16 x i8> %call13) #2

  ret void
}

; sub_group_as_vec
; CHECK-LLVM: _Z29intel_sub_group_block_read_ulPU3AS1Km
; bad case: _Z29intel_sub_group_block_read_ulPU3AS1Kh
;           _Z30intel_sub_group_block_write_ulPU3AS1hm
%"class.sycl::_V1::id" = type { %"class.sycl::_V1::detail::array" }
%"class.sycl::_V1::detail::array" = type { [1 x i64] }

define spir_kernel void @test_load_store_long( ptr addrspace(1) noundef align 8 %_arg_acc, ptr noundef byval(%"class.sycl::_V1::id") align 8 %_arg_acc6) {
entry:
  %1 = load i64, ptr %_arg_acc6, align 8
  %add.ptr.i34 = getelementptr inbounds nuw i64, ptr addrspace(1) %_arg_acc, i64 %1
  %2 = getelementptr i64, ptr addrspace(1) %add.ptr.i34, i64 0
  %arrayidx.i60 = getelementptr i64, ptr addrspace(1) %2, i64 0
  %arrayidx.ascast.i61 = addrspacecast ptr addrspace(1) %arrayidx.i60 to ptr addrspace(4)
  %call.i.i = tail call spir_func noundef ptr addrspace(1) @_Z41__spirv_GenericCastToPtrExplicit_ToGlobalPvi(ptr addrspace(4) noundef %arrayidx.ascast.i61, i32 noundef 5)
  %call1.i.i = tail call spir_func noundef i64 @_Z30__spirv_SubgroupBlockReadINTELImET_PU3AS1Km(ptr addrspace(1) noundef %call.i.i)
  ret void
}

; Function Attrs: convergent
declare spir_func <2 x i32> @_Z27intel_sub_group_block_read2PU3AS1Kj(ptr addrspace(1)) local_unnamed_addr #1

; Function Attrs: convergent
declare spir_func void @_Z28intel_sub_group_block_write2PU3AS1jDv2_j(ptr addrspace(1), <2 x i32>) local_unnamed_addr #1


; Function Attrs: convergent
declare spir_func <16 x i8> @_Z31intel_sub_group_block_read_uc16PU3AS1Kh(ptr addrspace(1)) #1

; Function Attrs: convergent
declare spir_func void @_Z32intel_sub_group_block_write_uc16PU3AS1hDv16_h(ptr addrspace(1), <16 x i8>) #1

; Function Attrs: nounwind
declare spir_func ptr addrspace(1) @__to_global(ptr addrspace(4))

declare dso_local spir_func noundef ptr addrspace(1) @_Z41__spirv_GenericCastToPtrExplicit_ToGlobalPvi(ptr addrspace(4) noundef, i32 noundef)
declare dso_local spir_func noundef i64 @_Z30__spirv_SubgroupBlockReadINTELImET_PU3AS1Km(ptr addrspace(1) noundef)
declare dso_local spir_func void @_Z31__spirv_SubgroupBlockWriteINTELPU3AS1mm(ptr addrspace(1) noundef, i64 noundef)


attributes #0 = { convergent nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "denorms-are-zero"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="128" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { convergent "correctly-rounded-divide-sqrt-fp-math"="false" "denorms-are-zero"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { convergent nounwind }

!opencl.ocl.version = !{!0}
!opencl.spir.version = !{!0}

!0 = !{i32 1, i32 2}
!1 = !{i32 0, i32 0, i32 1, i32 1, i32 0, i32 1, i32 1, i32 1, i32 1}
!2 = !{!"none", !"none", !"read_only", !"write_only", !"none", !"none", !"none", !"none", !"none"}
!3 = !{!"float2", !"uint", !"image2d_t", !"image2d_t", !"int2", !"uint*", !"ushort*", !"uchar*", !"ulong*"}
!4 = !{!"float __attribute__((ext_vector_type(2)))", !"uint", !"image2d_t", !"image2d_t", !"Int32 __attribute__((ext_vector_type(2)))", !"uint*", !"ushort*", !"uchar*", !"ulong*"}
!5 = !{!"", !"", !"", !"", !"", !"", !"", !"", !""}
!6 = !{!"x", !"c", !"image_in", !"image_out", !"coord", !"p", !"sp", !"cp", !"lp"}
