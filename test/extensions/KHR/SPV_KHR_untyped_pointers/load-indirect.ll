; RUN: llvm-as %s -o %t.bc
; RUN: llvm-spirv %t.bc --spirv-ext=+SPV_KHR_untyped_pointers -o %t.spv
; RUN: spirv-val %t.spv
; RUN: llvm-spirv %t.bc --spirv-ext=+SPV_KHR_untyped_pointers -spirv-text -o %t.spt
; RUN: FileCheck < %t.spt %s --check-prefix=CHECK-SPIRV

; RUN: llvm-spirv -r %t.spv -o %t.rev.bc
; RUN: llvm-dis < %t.rev.bc
; RUN: llvm-dis %t.rev.bc -o %t.rev.ll
; R/UN: FileCheck < %t.rev.ll %s --check-prefix=CHECK-LLVM

target datalayout = "e-p:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024"
target triple = "spir-unknown-unknown"

; CHECK-SPIRV-DAG: TypeInt [[#INT:]] 32 0
; CHECK-SPIRV-DAG: TypeInt [[#CHAR:]] 8 0
; CHECK-SPIRV-DAG: TypeUntypedPointerKHR [[#UNTYPEDPTR:]] 7
; CHECK-SPIRV-DAG: TypeFloat [[#FLOAT:]] 32

; Function Attrs: nounwind
define spir_kernel void @foo() {
; CHECK-SPIRV: UntypedVariableKHR [[#UNTYPEDPTR]] [[#IPTR:]] 7 [[#INT]]
; CHECK-SPIRV: UntypedVariableKHR [[#UNTYPEDPTR]] [[#PPTR:]] 7 [[#UNTYPEDPTR]]
; CHECK-SPIRV: Store [[#PPTR]] [[#IPTR]]
; CHECK-SPIRV: Load [[#UNTYPEDPTR]] [[#LOAD1:]] [[#PPTR]]
; CHECK-SPIRV: Bitcast [[#UNTYPEDPTR]] [[#LOADPTR2:]] [[#LOAD1]]
; CHECK-SPIRV: Load [[#FLOAT]] [[#LOAD2:]] [[#LOADPTR2]]
entry:
  %iptr = alloca i32, align 4
  %pptr = alloca ptr, align 4
  store ptr %iptr, ptr %pptr, align 8
  %0 = load ptr, ptr %pptr, align 8
  %1 = load float, ptr %0, align 4
  store ptr null, ptr %iptr, align 8
  store ptr null, ptr poison, align 8
  store ptr %pptr, ptr %pptr, align 8
  ret void
}
