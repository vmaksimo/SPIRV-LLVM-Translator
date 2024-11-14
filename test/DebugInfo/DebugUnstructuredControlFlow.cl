// RUN: %clang_cc1 -triple spir64-unknown-unknown -cl-std=CL2.0 -O0 -debug-info-kind=standalone -gno-column-info -emit-llvm-bc %s -o %t.bc
// RUN: llvm-spirv --spirv-ext=+SPV_KHR_untyped_pointers %t.bc --spirv-ext=+SPV_INTEL_unstructured_loop_controls -o %t.spv
// RUN: llvm-spirv --spirv-ext=+SPV_KHR_untyped_pointers %t.spv --to-text -o %t.spt
// RUN: llvm-spirv --spirv-ext=+SPV_KHR_untyped_pointers -r %t.spv -o %t.bc
// RUN: llvm-dis < %t.bc | FileCheck %s --check-prefix=CHECK-LLVM

// Test that no debug info instruction is inserted between LoopControlINTEL and
// Branch instructions. Otherwise, debug info interferes with SPIRVToLLVM
// translation of structured flow control

kernel
void sample() {
  #pragma clang loop unroll(full)
  for(;;);
}

// Check that all Line items are retained
// CHECK-SPIRV: Line [[File:[0-9]+]] 15 0
// Loop control
// CHECK-SPIRV: LoopControlINTEL 257 1
// CHECK-SPIRV-NEXT: Branch

// CHECK-LLVM: br label %{{.*}}, !dbg !{{[0-9]+}}, !llvm.loop ![[MD:[0-9]+]]
// CHECK-LLVM: ![[MD]] = distinct !{![[MD]], ![[MD_unroll:[0-9]+]]}
// CHECK-LLVM: ![[MD_unroll]] = !{!"llvm.loop.unroll.full"}
