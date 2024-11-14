; RUN: not llvm-spirv --spirv-ext=+SPV_KHR_untyped_pointers -s %s 2>&1 | FileCheck %s
; CHECK: Invalid bitcode signature
