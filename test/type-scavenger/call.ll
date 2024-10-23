; RUN: llvm-as %s -o %t.bc
; RUN: llvm-spirv %t.bc -spirv-text -o - | FileCheck %s --check-prefixes=CHECK,CHECK-TYPED-PTR
; RUN: llvm-spirv %t.bc -o %t.spv
; RUN: spirv-val %t.spv

; RUN: llvm-spirv --spirv-ext=+SPV_KHR_untyped_pointers %t.bc -spirv-text -o - | FileCheck %s --check-prefixes=CHECK,CHECK-UNTYPED-PTR
; RUN: llvm-spirv --spirv-ext=+SPV_KHR_untyped_pointers %t.bc -o %t.spv
; RUN: spirv-val %t.spv

target datalayout = "e-p:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024"
target triple = "spir-unknown-unknown"

; CHECK: Name [[CALL:[0-9]+]] "call"
; CHECK: TypeInt [[INT:[0-9]+]] 32 0
; CHECK-TYPED-PTR: TypePointer [[INTPTR:[0-9]+]] 7 [[INT]]
; CHECK-UNTYPED-PTR: TypeUntypedPointerKHR [[PTR:[0-9]+]] 7
; CHECK: TypeFloat [[FLOAT:[0-9]+]] 32
; CHECK-TYPED-PTR: TypePointer [[FLOATPTR:[0-9]+]] 7 [[FLOAT]]
; CHECK-TYPED-PTR: TypeFunction [[CALLTY:[0-9]+]] [[INTPTR]] [[INTPTR]]
; CHECK-UNTYPED-PTR: TypeFunction [[CALLTY:[0-9]+]] [[PTR]] [[PTR]]

; Function Attrs: nounwind
define spir_kernel void @foo() {
; CHECK-TYPED-PTR: Variable [[INTPTR]] [[IPTR:[0-9]+]] 7
; CHECK-UNTYPED-PTR: UntypedVariableKHR [[PTR]] [[IPTR:[0-9]+]] 7 [[INT]]
; CHECK-TYPED-PTR: Variable [[FLOATPTR]] [[FPTR:[0-9]+]] 7
; CHECK-UNTYPED-PTR: UntypedVariableKHR [[PTR]] [[FPTR:[0-9]+]] 7 [[FLOAT]]
; CHECK-TYPED-PTR: FunctionCall [[INTPTR]] [[IPTR1:[0-9]+]] [[CALL]] [[IPTR]]
; CHECK-UNTYPED-PTR: FunctionCall [[PTR]] [[IPTR1:[0-9]+]] [[CALL]] [[IPTR]]
; CHECK: Store [[IPTR1]]
; CHECK-TYPED-PTR: Bitcast [[INTPTR]] [[FPTR1:[0-9]+]] [[FPTR]]
; CHECK-UNTYPED-PTR: Bitcast [[PTR]] [[FPTR1:[0-9]+]] [[FPTR]]
; CHECK-TYPED-PTR: FunctionCall [[INTPTR]] [[FPTR2:[0-9]+]] [[CALL]] [[FPTR1]]
; CHECK-UNTYPED-PTR: FunctionCall [[PTR]] [[FPTR2:[0-9]+]] [[CALL]] [[FPTR1]]
; CHECK-TYPED-PTR: Bitcast [[FLOATPTR]] [[FPTR3:[0-9]+]] [[FPTR2]]
; CHECK-UNTYPED-PTR: Bitcast [[PTR]] [[FPTR3:[0-9]+]] [[FPTR2]]
; CHECK: Store [[FPTR3]]
entry:
  %iptr = alloca i32, align 4
  %fptr = alloca float, align 4
  %iptr.call = call spir_func ptr @call(ptr %iptr)
  store i32 0, ptr %iptr.call
  %fptr.call = call spir_func ptr @call(ptr %fptr)
  store float 0.0, ptr %fptr.call
  ret void
}

define spir_func ptr @call(ptr %a) {
  ret ptr %a
}
