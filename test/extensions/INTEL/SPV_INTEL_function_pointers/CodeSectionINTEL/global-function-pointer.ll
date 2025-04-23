; RUN: llvm-as %s -o %t.bc
; RUN: llvm-spirv -spirv-ext=+SPV_INTEL_function_pointers %t.bc -o %t.spv
; RUN: llvm-spirv %t.spv -spirv-ext=+SPV_INTEL_function_pointers -to-text -o - | FileCheck %s --check-prefixes=CHECK-SPIRV,CHECK-SPIRV-TYPED-PTR
; RUN: llvm-spirv -r %t.spv -o - | llvm-dis | FileCheck %s --check-prefix=CHECK-LLVM

; RUN: llvm-spirv -spirv-ext=+SPV_INTEL_function_pointers,+SPV_KHR_untyped_pointers -spirv-text %t.bc -o - | FileCheck %s --check-prefixes=CHECK-SPIRV,CHECK-SPIRV-UNTYPED-PTR
; RUN: llvm-spirv -spirv-ext=+SPV_INTEL_function_pointers,+SPV_KHR_untyped_pointers %t.bc -o %t.spv
; RUN: llvm-spirv -r -spirv-emit-function-ptr-addr-space %t.spv -o - | llvm-dis -o - | FileCheck %s --check-prefix=CHECK-LLVM

target datalayout = "e-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-n8:16:32:64"
target triple = "spir64"


; CHECK-SPIRV: Capability FunctionPointersINTEL
; CHECK-SPIRV: Extension "SPV_INTEL_function_pointers"
; CHECK-SPIRV-UNTYPED-PTR: TypeUntypedPointerKHR [[#FOO_TY_PTR:]] [[#]]
; CHECK-SPIRV: TypeFunction [[#FOO_TY:]] [[#]] [[#]]
; CHECK-SPIRV-TYPED-PTR: TypePointer [[#FOO_TY_PTR:]] [[#]] [[#FOO_TY]]
; CHECK-SPIRV: ConstantFunctionPointerINTEL [[#FOO_TY_PTR]] [[#FOO_PTR:]] [[#FOO:]]
; CHECK-SPIRV: Function [[#]] [[#]] [[#]] [[#FOO_TY]]

; CHECK-LLVM: @two = internal addrspace(1) global ptr @_Z4barrii
; CHECK-LLVM: define spir_func i32 @_Z4barrii(i32 %[[#]], i32 %[[#]])

@two = internal addrspace(1) global ptr @_Z4barrii, align 8

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn writeonly
define protected spir_func noundef i32 @_Z4barrii(i32 %0, i32 %1) {
entry:
  ret i32 1
}
