; RUN: llvm-as < %s -o %t.bc
; RUN: llvm-spirv %t.bc --spirv-ext=+SPV_INTEL_joint_matrix -o %t.spv
; RUN: llvm-spirv %t.spv -to-text -o %t.spt
; RUN: FileCheck < %t.spt %s --check-prefix=CHECK-SPIRV

; RUN: llvm-spirv -r %t.spv -o %t.rev.bc
; RUN: llvm-dis < %t.rev.bc | FileCheck %s --check-prefix=CHECK-LLVM

; Test that PackedCooperativeMatrixINTEL capability is emitted when using
; PackedA (layout=2) or PackedB (layout=3) matrix layouts.

; CHECK-SPIRV-DAG: Capability JointMatrixINTEL
; CHECK-SPIRV-DAG: Capability PackedCooperativeMatrixINTEL
; CHECK-SPIRV-DAG: Extension "SPV_INTEL_joint_matrix"
; CHECK-SPIRV-DAG: TypeInt [[#Int8Ty:]] 8 0
; CHECK-SPIRV-DAG: TypeInt [[#Int32Ty:]] 32 0
; CHECK-SPIRV-DAG: Constant [[#Int32Ty]] [[#Const12:]] 12
; CHECK-SPIRV-DAG: Constant [[#Int32Ty]] [[#Const48:]] 48
; CHECK-SPIRV-DAG: Constant [[#Int32Ty]] [[#Const3:]] 3
; CHECK-SPIRV-DAG: Constant [[#Int32Ty]] [[#Const2:]] 2
; CHECK-SPIRV-DAG: Constant [[#Int32Ty]] [[#Const0:]] 0
; Layout 2 = PackedA, Layout 3 = PackedB
; TypeJointMatrixINTEL: Result Type Rows Cols Layout Scope Use
; CHECK-SPIRV-DAG: TypeJointMatrixINTEL [[#MatTyA:]] [[#Int8Ty]] [[#Const12]] [[#Const48]] [[#Const2]] [[#Const3]] [[#Const0]]
; CHECK-SPIRV-DAG: TypeJointMatrixINTEL [[#MatTyB:]] [[#Int8Ty]] [[#Const48]] [[#Const12]] [[#Const3]] [[#Const3]] {{[0-9]+}}

; CHECK-SPIRV: JointMatrixLoadINTEL [[#MatTyA]]
; CHECK-SPIRV: JointMatrixLoadINTEL [[#MatTyB]]

; CHECK-LLVM: call spir_func target("spirv.JointMatrixINTEL", i8, 12, 48, 2, 3, 0)
; CHECK-LLVM: call spir_func target("spirv.JointMatrixINTEL", i8, 48, 12, 3, 3, 1)

; ModuleID = 'joint_matrix_packed.bc'
source_filename = "joint_matrix_packed.cpp"
target datalayout = "e-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-n8:16:32:64"
target triple = "spir64-unknown-unknown"

define weak_odr dso_local spir_kernel void @test_packed_matrix(ptr addrspace(1) noundef align 1 %_arg_accA, ptr addrspace(1) noundef align 1 %_arg_accB, i64 noundef %_arg_K) {
entry:
  %call.ascast.i.a = addrspacecast ptr addrspace(1) %_arg_accA to ptr addrspace(4)
  %call.ascast.i.b = addrspacecast ptr addrspace(1) %_arg_accB to ptr addrspace(4)
  ; Load matrix A with PackedA layout (layout=2)
  %matrixA = tail call spir_func noundef target("spirv.JointMatrixINTEL", i8, 12, 48, 2, 3, 0) @_Z28__spirv_JointMatrixLoadINTEL_PackedA(ptr addrspace(4) noundef %call.ascast.i.a, i64 noundef %_arg_K, i32 noundef 2, i32 noundef 3, i32 noundef 0) #1
  ; Load matrix B with PackedB layout (layout=3)
  %matrixB = tail call spir_func noundef target("spirv.JointMatrixINTEL", i8, 48, 12, 3, 3, 1) @_Z28__spirv_JointMatrixLoadINTEL_PackedB(ptr addrspace(4) noundef %call.ascast.i.b, i64 noundef %_arg_K, i32 noundef 3, i32 noundef 3, i32 noundef 0) #1
  ret void
}

; Function declaration for loading matrix with PackedA layout
declare dso_local spir_func noundef target("spirv.JointMatrixINTEL", i8, 12, 48, 2, 3, 0) @_Z28__spirv_JointMatrixLoadINTEL_PackedA(ptr addrspace(4) noundef, i64 noundef, i32 noundef, i32 noundef, i32 noundef) #0

; Function declaration for loading matrix with PackedB layout
declare dso_local spir_func noundef target("spirv.JointMatrixINTEL", i8, 48, 12, 3, 3, 1) @_Z28__spirv_JointMatrixLoadINTEL_PackedB(ptr addrspace(4) noundef, i64 noundef, i32 noundef, i32 noundef, i32 noundef) #0

attributes #0 = { convergent "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #1 = { convergent }
