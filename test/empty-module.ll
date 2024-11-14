; RUN: llvm-as %s -o %t.bc
; RUN: llvm-spirv --spirv-ext=+SPV_KHR_untyped_pointers %t.bc -spirv-text -o - | FileCheck %s
; RUN: llvm-spirv --spirv-ext=+SPV_KHR_untyped_pointers %t.bc -o %t.spv
; RUN: spirv-val %t.spv

; CHECK: 119734787 {{[0-9]*}} {{[0-9]*}} {{[0-9]*}} 0
; CHECK: Capability Addresses
; CHECK: Capability Linkage
; CHECK: Capability Kernel
; CHECK: ExtInstImport 1 "OpenCL.std"
; CHECK: MemoryModel 2 2
; CHECK: Source 0 0
