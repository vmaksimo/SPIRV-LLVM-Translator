; RUN: llvm-spirv %s --spirv-ext=+SPV_KHR_fma -o %t.spv
; RUN: llvm-spirv %t.spv -to-text -o %t.spt
; RUN: FileCheck < %t.spt %s --check-prefix=CHECK-SPIRV
; RUN: llvm-spirv -r %t.spv -o %t.rev.bc
; RUN: llvm-dis < %t.rev.bc | FileCheck %s --check-prefix=CHECK-LLVM

; RUN: llvm-spirv %s -spirv-text -o %t.spt
; RUN: FileCheck < %t.spt %s --check-prefix=CHECK-SPIRV-NO-EXT
; RUN: llvm-spirv %s -o %t.spv
; RUN: spirv-val %t.spv
; RUN: llvm-spirv -r %t.spv -o %t.rev.bc
; RUN: llvm-dis < %t.rev.bc | FileCheck %s --check-prefix=CHECK-LLVM-NO-EXT

; CHECK-SPIRV: Capability FmaKHR
; CHECK-SPIRV: Extension "SPV_KHR_fma"
; CHECK-SPIRV: TypeFloat [[TYPE_FLOAT:[0-9]+]] 32
; CHECK-SPIRV: TypeVector [[TYPE_VEC:[0-9]+]] [[TYPE_FLOAT]] 4
; CHECK-SPIRV: FmaKHR [[TYPE_FLOAT]] [[RESULT_SCALAR:[0-9]+]]
; CHECK-SPIRV: FmaKHR [[TYPE_VEC]] [[RESULT_VEC:[0-9]+]]

; CHECK-LLVM: %{{.*}} = call float @llvm.fma.f32(float %{{.*}}, float %{{.*}}, float %{{.*}})
; CHECK-LLVM: %{{.*}} = call <4 x float> @llvm.fma.v4f32(<4 x float> %{{.*}}, <4 x float> %{{.*}}, <4 x float> %{{.*}})

; CHECK-SPIRV-NO-EXT-NOT: Capability FmaKHR
; CHECK-SPIRV-NO-EXT-NOT: Extension "SPV_KHR_fma"
; CHECK-SPIRV-NO-EXT: TypeFloat [[TYPE_FLOAT:[0-9]+]] 32
; CHECK-SPIRV-NO-EXT: TypeVector [[TYPE_VEC:[0-9]+]] [[TYPE_FLOAT]] 4
; CHECK-SPIRV-NO-EXT: ExtInst [[TYPE_FLOAT]] [[RESULT_SCALAR:[0-9]+]] {{[0-9]+}} 26
; CHECK-SPIRV-NO-EXT: ExtInst [[TYPE_VEC]] [[RESULT_VEC:[0-9]+]] {{[0-9]+}} 26

; CHECK-LLVM-NO-EXT: %{{.*}} = call float @llvm.fma.f32(float %{{.*}}, float %{{.*}}, float %{{.*}})
; CHECK-LLVM-NO-EXT: %{{.*}} = call <4 x float> @llvm.fma.v4f32(<4 x float> %{{.*}}, <4 x float> %{{.*}}, <4 x float> %{{.*}})

target datalayout = "e-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024"
target triple = "spir64-unknown-unknown"

define spir_func float @test_fma_scalar(float %a, float %b, float %c) {
entry:
  %result = call float @llvm.fma.f32(float %a, float %b, float %c)
  ret float %result
}

define spir_func <4 x float> @test_fma_vector(<4 x float> %a, <4 x float> %b, <4 x float> %c) {
entry:
  %result = call <4 x float> @llvm.fma.v4f32(<4 x float> %a, <4 x float> %b, <4 x float> %c)
  ret <4 x float> %result
}

declare float @llvm.fma.f32(float, float, float)
declare <4 x float> @llvm.fma.v4f32(<4 x float>, <4 x float>, <4 x float>)
