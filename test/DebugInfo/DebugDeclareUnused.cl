// Check that we can translate llvm.dbg.declare for a local variable which was
// deleted by mem2reg pass(disabled by default in llvm-spirv --spirv-ext=+SPV_KHR_untyped_pointers)

// RUN: %clang_cc1 %s -triple spir -disable-llvm-passes -debug-info-kind=standalone -emit-llvm-bc -o - | llvm-spirv --spirv-ext=+SPV_KHR_untyped_pointers -spirv-mem2reg -o %t.spv
// RUN: llvm-spirv --spirv-ext=+SPV_KHR_untyped_pointers -r %t.spv -o - | llvm-dis -o - | FileCheck %s --check-prefix=CHECK-LLVM

// RUN: %clang_cc1 %s -triple spir -disable-llvm-passes -debug-info-kind=standalone -emit-llvm-bc -o - | llvm-spirv --spirv-ext=+SPV_KHR_untyped_pointers -spirv-mem2reg -o %t.spv
// RUN: llvm-spirv --spirv-ext=+SPV_KHR_untyped_pointers -r --experimental-debuginfo-iterators=1 %t.spv -o - | llvm-dis -o - | FileCheck %s --check-prefix=CHECK-LLVM


void foo() {
  int a;
}

// CHECK-SPIRV: Undef [[#]] [[#Undef:]]
// CHECK-SPIRV: ExtInst [[#]] [[#]] [[#]] DebugDeclare [[#]] [[#Undef]] [[#]]
// CHECK-LLVM:  #dbg_declare(ptr undef, ![[#]], !DIExpression(DW_OP_constu, 0, DW_OP_swap, DW_OP_xderef), ![[#]])
