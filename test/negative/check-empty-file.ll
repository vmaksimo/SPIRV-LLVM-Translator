; RUN: not llvm-spirv --spirv-ext=+SPV_KHR_untyped_pointers %S/empty-file.bc -o - 2>&1 | FileCheck %s

; CHECK: Can't translate, file is empty
