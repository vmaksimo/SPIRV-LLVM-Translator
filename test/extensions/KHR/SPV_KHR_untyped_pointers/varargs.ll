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

@.str = internal unnamed_addr addrspace(2) constant [11 x i8] c"Value: %p\0A\00", align 1


; CHECK-SPIRV-DAG: TypeInt [[#INT:]] 32 0
; CHECK-SPIRV-DAG: TypeInt [[#CHAR:]] 8 0
; CHECK-SPIRV-DAG: TypeUntypedPointerKHR [[#UNTYPEDPTR_FUNC:]] 7
; CHECK-SPIRV-DAG: TypeUntypedPointerKHR [[#UNTYPEDPTR_UNIFORM:]] 0

; CHECK-SPIRV: Variable [[#]] [[#STR:]] 0

; CHECK-SPIRV: UntypedVariableKHR [[#UNTYPEDPTR_FUNC]] [[#UPTR:]] 7 [[#INT]]
; CHECK-SPIRV: Bitcast [[#UNTYPEDPTR_UNIFORM]] [[#I8STR:]] [[#STR]]
; CHECK-SPIRV: Bitcast [[#UNTYPEDPTR_FUNC]] [[#VAR8:]] [[#UPTR]]
; CHECK-SPIRV: ExtInst [[#INT]] [[#]] [[#]] printf [[#I8STR]] [[#VAR8]]

; Function Attrs: nounwind
define spir_kernel void @foo() {
  %iptr = alloca i32, align 4
  %res = call spir_func i32 (ptr addrspace(2), ...) @_Z18__spirv_ocl_printfPU3AS2cz(ptr addrspace(2) @.str, ptr %iptr)
  ret void
}

declare spir_func i32 @_Z18__spirv_ocl_printfPU3AS2cz(ptr addrspace(2), ...)
