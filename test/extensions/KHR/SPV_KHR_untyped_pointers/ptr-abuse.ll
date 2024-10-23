; Check that pointers whose types change are correctly handled by the
; translator.
; RUN: llvm-as %s -o %t.bc
; RUN: llvm-spirv %t.bc --spirv-ext=+SPV_KHR_untyped_pointers -o %t.spv
; RUN: spirv-val %t.spv
; RUN: llvm-spirv %t.bc --spirv-ext=+SPV_KHR_untyped_pointers -spirv-text -o %t.spt
; RUN: FileCheck < %t.spt %s --check-prefix=CHECK-SPIRV

; RUN: llvm-spirv -r %t.spv -o %t.rev.bc
; RUN: llvm-dis %t.rev.bc
; RUN: llvm-dis %t.rev.bc -o %t.rev.ll
; R/UN: FileCheck < %t.rev.ll %s --check-prefix=CHECK-LLVM

target datalayout = "e-p:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024"
target triple = "spir-unknown-unknown"

; CHECK-SPIRV: TypeInt [[#INT:]] 32 0
; CHECK-SPIRV: TypeUntypedPointerKHR [[#PTRTY:]] 7
; CHECK-SPIRV: TypeFloat [[#FLOAT:]] 32

; Function Attrs: nounwind
define spir_kernel void @foo() {
; CHECK-SPIRV: UntypedVariableKHR [[#PTRTY]] [[#IPTR:]] 7 [[#INT]]
; CHECK-SPIRV: UntypedVariableKHR [[#PTRTY]] [[#FPTR:]] 7 [[#FLOAT]]
; CHECK-SPIRV: Bitcast [[#PTRTY]] [[#LOADB:]] [[#FPTR]]
; CHECK-SPIRV: Load [[#INT]] [[#LOAD:]] [[#LOADB]]
; CHECK-SPIRV: Bitcast [[#PTRTY]] [[#STOREB:]] [[#IPTR]]
; CHECK-SPIRV: Store [[#STOREB]] {{[0-9]+}}
; CHECK-SPIRV: Bitcast [[#PTRTY]] [[#CMPB:]] [[#FPTR]]
; CHECK-SPIRV: PtrEqual [[#]] [[#]] [[#IPTR]] [[#CMPB]]
entry:
  %iptr = alloca i32, align 4
  %fptr = alloca float, align 4
  %0 = load i32, ptr %fptr, align 4
  %1 = bitcast i32 %0 to float
  store float %1, ptr %iptr, align 4
  %cmp = icmp eq ptr %iptr, %fptr
  ret void
}
