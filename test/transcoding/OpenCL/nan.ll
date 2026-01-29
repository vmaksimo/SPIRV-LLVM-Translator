; RUN: llvm-spirv %s -o %t.spv
; RUN: llvm-spirv %t.spv -to-text -o %t.spt
; RUN: FileCheck < %t.spt %s --check-prefix=CHECK-SPIRV

; RUN: llvm-spirv -r %t.spv -o %t.rev.bc
; RUN: llvm-dis < %t.rev.bc | FileCheck %s --check-prefixes=CHECK-LLVM
; RUN: llvm-spirv -r %t.spv --spirv-target-env=SPV-IR -o %t.rev.bc
; RUN: llvm-dis < %t.rev.bc | FileCheck %s --check-prefixes=CHECK-SPV-IR

; Check OpenCL built-in nan translation.

target datalayout = "e-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-n8:16:32:64-G1"
target triple = "spir64"

; CHECK-SPIRV-COUNT-2: ExtInst [[#]] [[#]] [[#]] nan

; CHECK-LLVM: call spir_func float @_Z3nanj(
; CHECK-LLVM: call spir_func half @_Z3nant(

; CHECK-SPV-IR: call spir_func float @_Z22__spirv_ocl_nan_Rfloatj(
; CHECK-SPV-IR: call spir_func half @_Z21__spirv_ocl_nan_Rhalft(

define dso_local spir_kernel void @test(ptr addrspace(1) align 4 %a, i32 %b) {
entry:
  %call = tail call spir_func float @_Z3nanj(i32 %b)
  store float %call, ptr addrspace(1) %a, align 4
  ret void
}

; Test nan builtin with half return type
define dso_local spir_kernel void @test_half(ptr addrspace(1) align 2 %a, i16 %b) {
entry:
  %call = tail call spir_func half @_Z3nant(i16 %b)
  store half %call, ptr addrspace(1) %a, align 2
  ret void
}

declare spir_func float @_Z3nanj(i32)
declare spir_func half @_Z3nant(i16)

!opencl.ocl.version = !{!0}

!0 = !{i32 3, i32 0}
