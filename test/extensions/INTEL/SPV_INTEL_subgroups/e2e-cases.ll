; RUN: llvm-spirv %s -o %t.spt -spirv-text --spirv-ext=+SPV_INTEL_subgroups,+SPV_KHR_untyped_pointers
; RUN: FileCheck < %t.spt %s --check-prefix=CHECK-SPIRV
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

; CHECK-SPIRV: TypeInt [[#Int:]] 32 0
; CHECK-SPIRV-DAG: TypeVector [[#IntVec2:]] [[#Int]] 2
; CHECK-SPIRV-DAG: TypeUntypedPointerKHR [[#Ptr:]] 5
; CHECK-SPIRV-DAG: TypePointer [[#IntPtr:]] 5 [[#Int]]
; CHECK-SPIRV-DAG: TypeVector [[#IntVec4:]] [[#Int]] 4

; CHECK-SPIRV: Function

; CHECK-SPIRV: Bitcast [[#IntPtr]] [[#TypedPtr:]] [[#ParamPtr:]]
; CHECK-SPIRV: SubgroupBlockReadINTEL [[#IntVec2]] [[#Res:]] [[#TypedPtr]]
; CHECK-SPIRV: Bitcast [[#IntPtr]] [[#TypedPtr:]] [[#ParamPtr]]
; CHECK-SPIRV: SubgroupBlockWriteINTEL [[#TypedPtr]] [[#Res]]

; CHECK-SPIRV: SubgroupBlockReadINTEL
; CHECK-SPIRV: SubgroupBlockWriteINTEL

; CHECK-SPIRV: Bitcast [[#IntPtr]] [[#TypedPtr2:]] [[#ParamPtr2:]]
; CHECK-SPIRV: SubgroupBlockReadINTEL [[#IntVec4]] [[#Res2:]] [[#TypedPtr2]]

target datalayout = "e-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024"
target triple = "spir64"

; Function Attrs: convergent nounwind
define spir_kernel void @test_subgroup_block_write(<2 x float> %x, i32 %c, ptr addrspace(1) %p, ptr addrspace(1) %sp, ptr addrspace(1) %cp, ptr addrspace(1) %lp) local_unnamed_addr {
; CHECK-LLVM-LABEL: @test_subgroup_block_write(
; CHECK-LLVM-NEXT:  entry:
; CHECK-LLVM-NEXT:    [[P0:%.*]] = bitcast ptr addrspace(1) [[P:%.*]] to ptr addrspace(1)
; CHECK-LLVM-NEXT:    [[CALL5:%.*]] = call spir_func <2 x i32> @_Z27intel_sub_group_block_read2PU3AS1Kj(ptr addrspace(1) [[P0]])
; CHECK-LLVM-NEXT:    [[P1:%.*]] = bitcast ptr addrspace(1) [[P]] to ptr addrspace(1)
; CHECK-LLVM-NEXT:    call spir_func void @_Z28intel_sub_group_block_write2PU3AS1jDv2_j(ptr addrspace(1) [[P1]], <2 x i32> [[CALL5]])

; CHECK-LLVM-NEXT:    [[CP0:%.*]] = bitcast ptr addrspace(1) [[CP:%.*]] to ptr addrspace(1)
; CHECK-LLVM-NEXT:    [[CALL13:%.*]] = call spir_func <16 x i8> @_Z31intel_sub_group_block_read_uc16PU3AS1Kh(ptr addrspace(1) [[CP0]])
; CHECK-LLVM-NEXT:    [[CP1:%.*]] = bitcast ptr addrspace(1) [[CP]] to ptr addrspace(1)
; CHECK-LLVM-NEXT:    call spir_func void @_Z32intel_sub_group_block_write_uc16PU3AS1hDv16_h(ptr addrspace(1) [[CP1]], <16 x i8> [[CALL13]])
; CHECK-LLVM-NEXT:    ret void

; CHECK-LLVM-SPIRV: call spir_func <2 x i32> @_Z36__spirv_SubgroupBlockReadINTEL_Rint2PU3AS1Kj(
; CHECK-LLVM-SPIRV: call spir_func void @_Z31__spirv_SubgroupBlockWriteINTELPU3AS1jDv2_j(
; CHECK-LLVM-SPIRV: call spir_func <16 x i8> @_Z38__spirv_SubgroupBlockReadINTEL_Rchar16PU3AS1Kh(
; CHECK-LLVM-SPIRV: call spir_func void @_Z31__spirv_SubgroupBlockWriteINTELPU3AS1hDv16_h(

entry:
  %call5 = tail call spir_func <2 x i32> @_Z27intel_sub_group_block_read2PU3AS1Kj(ptr addrspace(1) %p) #2
  tail call spir_func void @_Z28intel_sub_group_block_write2PU3AS1jDv2_j(ptr addrspace(1) %p, <2 x i32> %call5) #2

  %call13 = tail call spir_func <16 x i8> @_Z31intel_sub_group_block_read_uc16PU3AS1Kh(ptr addrspace(1) %cp) #2
  tail call spir_func void @_Z32intel_sub_group_block_write_uc16PU3AS1hDv16_h(ptr addrspace(1) %cp, <16 x i8> %call13) #2

  ret void
}

define spir_kernel void @test_group_load_fortified(ptr addrspace(1) noundef align 4 %_arg_Ptr) {
; CHECK-LLVM-LABEL: @test_group_load_fortified(
; CHECK-LLVM:       call spir_func <4 x i32> @_Z27intel_sub_group_block_read4PU3AS1Kj
; CHECK-LLVM-SPIRV: call spir_func <4 x i32> @_Z36__spirv_SubgroupBlockReadINTEL_Rint4PU3AS1Kj
entry:
  %0 = addrspacecast ptr addrspace(1) %_arg_Ptr to ptr addrspace(4)
  %call.i.i = tail call spir_func noundef ptr addrspace(1) @_Z41__spirv_GenericCastToPtrExplicit_ToGlobalPvi(ptr addrspace(4) noundef %0, i32 noundef 5)
  %call9.i.i = tail call spir_func noundef <4 x i32> @_Z30__spirv_SubgroupBlockReadINTELIDv4_jET_PU3AS1Kj(ptr addrspace(1) noundef nonnull %call.i.i)
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

; Function Attrs: convergent mustprogress nofree nounwind willreturn memory(none)
declare spir_func noundef ptr addrspace(1) @_Z41__spirv_GenericCastToPtrExplicit_ToGlobalPvi(ptr addrspace(4) noundef, i32 noundef)

; Function Attrs: convergent nounwind
declare spir_func noundef <4 x i32> @_Z30__spirv_SubgroupBlockReadINTELIDv4_jET_PU3AS1Kj(ptr addrspace(1) noundef)

attributes #0 = { convergent nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "denorms-are-zero"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="128" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "uniform-work-group-size"="true" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { convergent "correctly-rounded-divide-sqrt-fp-math"="false" "denorms-are-zero"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { convergent nounwind }

!opencl.ocl.version = !{!0}
!opencl.spir.version = !{!0}

!0 = !{i32 1, i32 2}
!1 = !{i32 0, i32 0, i32 1, i32 1, i32 0, i32 1, i32 1, i32 1, i32 1}
!2 = !{!"none", !"none", !"read_only", !"write_only", !"none", !"none", !"none", !"none", !"none"}
!3 = !{!"float2", !"uint", !"image2d_t", !"image2d_t", !"int2", !"uint*", !"ushort*", !"uchar*", !"ulong*"}
!4 = !{!"float __attribute__((ext_vector_type(2)))", !"uint", !"image2d_t", !"image2d_t", !"int __attribute__((ext_vector_type(2)))", !"uint*", !"ushort*", !"uchar*", !"ulong*"}
!5 = !{!"", !"", !"", !"", !"", !"", !"", !"", !""}
!6 = !{!"x", !"c", !"image_in", !"image_out", !"coord", !"p", !"sp", !"cp", !"lp"}
