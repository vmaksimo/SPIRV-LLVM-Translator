; REQUIRES: spirv-dis
; RUN: llvm-spirv %s -o %t.spv
; RUN: spirv-val %t.spv
; RUN: spirv-dis %t.spv | FileCheck %s --check-prefix=CHECK-SPIRV
; RUN: llvm-spirv %t.spv -o %t.rev.bc -r --spirv-target-env=SPV-IR
; RUN: llvm-dis %t.rev.bc -o %t.rev.ll
; RUN: FileCheck --input-file=%t.rev.ll %s --check-prefix=CHECK-LLVM

; Branch weight metadata (as produced by __builtin_expect, [[likely]]/
; [[unlikely]], or PGO) is translated to and from the optional Branch
; Weights operands of OpBranchConditional.

target datalayout = "e-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-G1"
target triple = "spir64-unknown-unknown"

; CHECK-SPIRV: %weighted_branch = OpFunction
; CHECK-SPIRV: OpBranchConditional %cmp %if_then %if_else 2000 1
define spir_func i32 @weighted_branch(i32 %x) {
entry:
  %cmp = icmp sgt i32 %x, 10
  br i1 %cmp, label %if.then, label %if.else, !prof !0

if.then:
  ret i32 %x

if.else:
  ret i32 %x
}

; CHECK-SPIRV: %unweighted_branch = OpFunction
; CHECK-SPIRV: OpBranchConditional %cmp_0 %if_then_0 %if_else_0{{$}}
define spir_func i32 @unweighted_branch(i32 %x) {
entry:
  %cmp = icmp sgt i32 %x, 10
  br i1 %cmp, label %if.then, label %if.else

if.then:
  ret i32 %x

if.else:
  ret i32 %x
}

; CHECK-LLVM-LABEL: define spir_func i32 @weighted_branch
; CHECK-LLVM: br i1 %{{.*}}, label %{{.*}}, label %{{.*}}, !prof ![[#PROF:]]

; CHECK-LLVM-LABEL: define spir_func i32 @unweighted_branch
; CHECK-LLVM-NOT: !prof

; CHECK-LLVM: ![[#PROF]] = !{!"branch_weights", i32 2000, i32 1}

!0 = !{!"branch_weights", i32 2000, i32 1}
