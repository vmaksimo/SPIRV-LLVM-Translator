; RUN: llvm-as < %s -o %t.bc
; RUN: llvm-spirv %t.bc --spirv-ext=+SPV_KHR_cooperative_matrix -o %t.spv
; TODO: Validation is disabled till the moment the tools in CI are updated (passes locally)
; R/UN: spirv-val %t.spv
; RUN: llvm-spirv %t.spv -to-text -o %t.spt
; RUN: FileCheck < %t.spt %s --check-prefix=CHECK-SPIRV

; RUN: llvm-spirv -r --spirv-target-env=SPV-IR %t.spv -o %t.rev.bc
; RUN: llvm-dis %t.rev.bc 
; RUN: FileCheck < %t.rev.ll %s --check-prefix=CHECK-LLVM

target datalayout = "e-p:32:32:32-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v16:16:16-v24:32:32-v32:32:32-v48:64:64-v64:64:64-v96:128:128-v128:128:128-v192:256:256-v256:256:256-v512:512:512-v1024:1024:1024"
target triple = "spir-unknown-unknown"

; C/HECK-SPIRV: SNegate
; define spir_kernel void @testSNegate(i32 %a) #0 !kernel_arg_addr_space !10 !kernel_arg_access_qual !11 !kernel_arg_type !12 !kernel_arg_type_qual !9 !kernel_arg_base_type !12 {
;   %r1 = sub i32 0, %a
;   %r2 = sub nsw i32 0, %a
;   ret void
; }

; CHECK-SPIRV: FNegate
; CHECK-LLVM: fneg
define spir_kernel void @testFNeg(float %a) local_unnamed_addr #0 !kernel_arg_addr_space !2 !kernel_arg_access_qual !3 !kernel_arg_type !4 !kernel_arg_base_type !4 !kernel_arg_type_qual !9 {
entry:
;   %r1 = fneg float %a
;   %r2 = fneg nnan float %a
;   %r3 = fneg ninf float %a
;   %r4 = fneg nsz float %a
;   %r5 = fneg arcp float %a
;   %r6 = fneg fast float %a
;   %r7 = fneg nnan ninf float %a
  %0 = tail call spir_func noundef target("spirv.CooperativeMatrixKHR", float, 3, 12, 12, 3) @_Z26__spirv_CompositeConstructFloat(float 0.000000e+00)
  %call = call spir_func target("spirv.CooperativeMatrixKHR", float, 3, 12, 12, 3) @_Z15__spirv_FNegate(target("spirv.CooperativeMatrixKHR", float, 3, 12, 12, 3) %0)
  ret void
}

; CHECK-SPIRV: IAdd

define spir_kernel void @testIAdd(i32 %a, i32 %b) #0 !kernel_arg_addr_space !4 !kernel_arg_access_qual !5 !kernel_arg_type !6 !kernel_arg_type_qual !7 !kernel_arg_base_type !6 {
;   %r1 = add i32 %a, %b
  %1 = tail call spir_func noundef target("spirv.CooperativeMatrixKHR", i32, 3, 12, 12, 3) @_Z26__spirv_CompositeConstructInt32(i32 0)
  %2 = tail call spir_func noundef target("spirv.CooperativeMatrixKHR", i32, 3, 12, 12, 3) @_Z26__spirv_CompositeConstructInt32(i32 0)
  %call = call spir_func target("spirv.CooperativeMatrixKHR", i32, 3, 12, 12, 3) @_Z12__spirv_IAdd(target("spirv.CooperativeMatrixKHR", i32, 3, 12, 12, 3) %1, target("spirv.CooperativeMatrixKHR", i32, 3, 12, 12, 3) %2)
;   %r2 = add nsw i32 %a, %b
;   %r3 = add nuw i32 %a, %b
;   %r4 = add nuw nsw i32 %a, %b
  ret void
}


; CHECK-SPIRV: IMul
define spir_kernel void @testIMul(i32 %a, i32 %b) #0 !kernel_arg_addr_space !4 !kernel_arg_access_qual !5 !kernel_arg_type !6 !kernel_arg_type_qual !7 !kernel_arg_base_type !6 {
;   %r1 = mul i32 %a, %b
  %r2 = mul nsw i32 %a, %b
;   %r3 = mul nuw i32 %a, %b
;   %r4 = mul nuw nsw i32 %a, %b
  ret void
}

; CHECK-SPIRV: ISub
define spir_kernel void @testISub(i32 %a, i32 %b) #0 !kernel_arg_addr_space !4 !kernel_arg_access_qual !5 !kernel_arg_type !6 !kernel_arg_type_qual !7 !kernel_arg_base_type !6 {
;   %r1 = sub i32 %a, %b
;   %r2 = sub nsw i32 %a, %b
  %r3 = sub nuw i32 %a, %b
;   %r4 = sub nuw nsw i32 %a, %b
  ret void
}


; CHECK-SPIRV: FAdd
define spir_kernel void @testFAdd(float %a, float %b) local_unnamed_addr #0 !kernel_arg_addr_space !2 !kernel_arg_access_qual !3 !kernel_arg_type !4 !kernel_arg_base_type !4 !kernel_arg_type_qual !5 {
entry:
  %r1 = fadd float %a, %b
;   %r2 = fadd nnan float %a, %b
;   %r3 = fadd ninf float %a, %b
;   %r4 = fadd nsz float %a, %b
;   %r5 = fadd arcp float %a, %b
;   %r6 = fadd fast float %a, %b
;   %r7 = fadd nnan ninf float %a, %b
  ret void
}

; CHECK-SPIRV: FSub
define spir_kernel void @testFSub(float %a, float %b) local_unnamed_addr #0 !kernel_arg_addr_space !2 !kernel_arg_access_qual !3 !kernel_arg_type !4 !kernel_arg_base_type !4 !kernel_arg_type_qual !5 {
entry:
  %r1 = fsub float %a, %b
;   %r2 = fsub nnan float %a, %b
;   %r3 = fsub ninf float %a, %b
;   %r4 = fsub nsz float %a, %b
;   %r5 = fsub arcp float %a, %b
;   %r6 = fsub fast float %a, %b
;   %r7 = fsub nnan ninf float %a, %b
  ret void
}

; CHECK-SPIRV: FMul
define spir_kernel void @testFMul(float %a, float %b) local_unnamed_addr #0 !kernel_arg_addr_space !2 !kernel_arg_access_qual !3 !kernel_arg_type !4 !kernel_arg_base_type !4 !kernel_arg_type_qual !5 {
entry:
  %r1 = fmul float %a, %b
;   %r2 = fmul nnan float %a, %b
;   %r3 = fmul ninf float %a, %b
;   %r4 = fmul nsz float %a, %b
;   %r5 = fmul arcp float %a, %b
;   %r6 = fmul fast float %a, %b
;   %r7 = fmul nnan ninf float %a, %b
  ret void
}

; CHECK-SPIRV: FDiv
define spir_kernel void @testFDiv(float %a, float %b) local_unnamed_addr #0 !kernel_arg_addr_space !2 !kernel_arg_access_qual !3 !kernel_arg_type !4 !kernel_arg_base_type !4 !kernel_arg_type_qual !5 {
entry:
  %r1 = fdiv float %a, %b
;   %r2 = fdiv nnan float %a, %b
;   %r3 = fdiv ninf float %a, %b
;   %r4 = fdiv nsz float %a, %b
;   %r5 = fdiv arcp float %a, %b
;   %r6 = fdiv fast float %a, %b
;   %r7 = fdiv nnan ninf float %a, %b
  ret void
}

; CHECK-SPIRV: SDiv
define i32 @scalar_sdiv(i32 %a, i32 %b) {
    %c = sdiv i32 %a, %b
    ret i32 %c
}

; CHECK-SPIRV: UDiv
define i32 @scalar_udiv(i32 %a, i32 %b) {
    %c = udiv i32 %a, %b
    ret i32 %c
}

declare spir_func noundef target("spirv.CooperativeMatrixKHR", float, 3, 12, 12, 3) @_Z26__spirv_CompositeConstructFloat(float noundef)
declare spir_func noundef target("spirv.CooperativeMatrixKHR", i32, 3, 12, 12, 3) @_Z26__spirv_CompositeConstructInt32(i32 noundef)

declare spir_func noundef target("spirv.CooperativeMatrixKHR", float, 3, 12, 12, 3) @_Z15__spirv_FNegate(target("spirv.CooperativeMatrixKHR", float, 3, 12, 12, 3) noundef)
declare spir_func noundef target("spirv.CooperativeMatrixKHR", i32, 3, 12, 12, 3) @_Z12__spirv_IAdd(target("spirv.CooperativeMatrixKHR", i32, 3, 12, 12, 3) noundef, target("spirv.CooperativeMatrixKHR", i32, 3, 12, 12, 3) noundef)

attributes #0 = { nounwind }

!spirv.MemoryModel = !{!0}
!opencl.enable.FP_CONTRACT = !{}
!spirv.Source = !{!1}
!opencl.spir.version = !{!0}
!opencl.ocl.version = !{!0}
!opencl.used.extensions = !{!2}
!opencl.used.optional.core.features = !{!2}
!spirv.Generator = !{!3}

!0 = !{i32 1, i32 2}
!1 = !{i32 3, i32 102000}
!2 = !{}
!3 = !{i16 7, i16 0}
!4 = !{i32 0, i32 0}
!5 = !{!"none", !"none"}
!6 = !{!"int", !"int"}
!7 = !{!"", !""}
!8 = !{!2, !2}
!9 = !{!""}
!10 = !{i32 0}
!11 = !{!"none"}
!12 = !{!"int"}
