; RUN: llvm-spirv %s --spirv-ext=+SPV_KHR_bfloat16 -o %t.spv
; RUN: llvm-spirv %t.spv -to-text -o %t.spt
; RUN: FileCheck < %t.spt %s --check-prefix=CHECK-SPIRV

; RUN: llvm-spirv -r %t.spv --spirv-target-env=SPV-IR -o %t.rev.bc
; RUN: llvm-dis %t.rev.bc 
; RUN: FileCheck < %t.rev.ll %s --check-prefixes=CHECK-SPV-IR

; Check OpenCL built-in nan translation.
; Verify it's possible to distinguish between bfloat and half versions of nan builtin.

target datalayout = "e-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-n8:16:32:64-G1"
target triple = "spir64"

; CHECK-SPIRV-COUNT-2: ExtInst [[#]] [[#]] [[#]] nan

; CHECK-SPV-IR: call spir_func bfloat @_Z23__spirv_ocl_nan_RDF16bt(
; CHECK-SPV-IR: call spir_func half @_Z21__spirv_ocl_nan_Rhalft(


; Test nan builtin with bfloat return type
define dso_local spir_kernel void @test_bfloat(ptr addrspace(1) align 2 %a, i16 %b) {
entry:
  %call = tail call spir_func bfloat @_Z23__spirv_ocl_nan_RDF16bt(i16 %b)
  %call2 = tail call spir_func half @_Z21__spirv_ocl_nan_Rhalft(i16 %b)
  ret void
}

declare spir_func bfloat @_Z23__spirv_ocl_nan_RDF16bt(i16)
declare spir_func half @_Z21__spirv_ocl_nan_Rhalft(i16)


!opencl.ocl.version = !{!0}

!0 = !{i32 3, i32 0}
