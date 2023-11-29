; RUN: llvm-as %s -o %t.bc
; RUN: llvm-spirv %t.bc -spirv-text
; RUN: FileCheck < %t.spt %s
; RUN: llvm-spirv %t.bc -o %t.spv
; R/UN: spirv-val %t.spv
; RUN: llvm-spirv -r %t.spv -o %t.rev.bc
; RUN: llvm-dis %t.rev.bc

target datalayout = "e-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024"
target triple = "spir64-unknown-unknown"

; CHECK: ExtInst [[#]] [[#]] [[#]] frexp [[#]]

declare { float, i32 } @llvm.frexp.f32.i32(float)
declare { <2 x float>, <2 x i32> } @llvm.frexp.v2f32.v2i32(<2 x float>)
declare { <4 x float>, <4 x i32> } @llvm.frexp.v4f32.v4i32(<4 x float>)

define { float, i32 } @frexp_frexp(float %x) {
  %frexp0 = call { float, i32 } @llvm.frexp.f32.i32(float %x)
  %frexp0.0 = extractvalue { float, i32 } %frexp0, 0
  %frexp1 = call { float, i32 } @llvm.frexp.f32.i32(float %frexp0.0)
  ret { float, i32 } %frexp1
}

define { <2 x float>, <2 x i32> } @frexp_frexp_vector(<2 x float> %x) {
  %frexp0 = call { <2 x float>, <2 x i32> } @llvm.frexp.v2f32.v2i32(<2 x float> %x)
  %frexp0.0 = extractvalue { <2 x float>, <2 x i32> } %frexp0, 0
  %frexp1 = call { <2 x float>, <2 x i32> } @llvm.frexp.v2f32.v2i32(<2 x float> %frexp0.0)
  ret { <2 x float>, <2 x i32> } %frexp1
}

define { float, i32 } @frexp_frexp_const(float %x) {
  %frexp0 = call { float, i32 } @llvm.frexp.f32.i32(float 42.0)
  %frexp0.0 = extractvalue { float, i32 } %frexp0, 0
  %frexp1 = call { float, i32 } @llvm.frexp.f32.i32(float %frexp0.0)
  ret { float, i32 } %frexp1
}

define { float, i32 } @frexp_poison() {
  %ret = call { float, i32 } @llvm.frexp.f32.i32(float poison)
  ret { float, i32 } %ret
}

define { <2 x float>, <2 x i32> } @frexp_poison_vector() {
  %ret = call { <2 x float>, <2 x i32> } @llvm.frexp.v2f32.v2i32(<2 x float> poison)
  ret { <2 x float>, <2 x i32> } %ret
}

define { float, i32 } @frexp_undef() {
  %ret = call { float, i32 } @llvm.frexp.f32.i32(float undef)
  ret { float, i32 } %ret
}
define { <2 x float>, <2 x i32> } @frexp_undef_vector() {
  %ret = call { <2 x float>, <2 x i32> } @llvm.frexp.v2f32.v2i32(<2 x float> undef)
  ret { <2 x float>, <2 x i32> } %ret
}

define { <2 x float>, <2 x i32> } @frexp_zero_vector() {
  %ret = call { <2 x float>, <2 x i32> } @llvm.frexp.v2f32.v2i32(<2 x float> zeroinitializer)
  ret { <2 x float>, <2 x i32> } %ret
}

define { <2 x float>, <2 x i32> } @frexp_zero_negzero_vector() {
  %ret = call { <2 x float>, <2 x i32> } @llvm.frexp.v2f32.v2i32(<2 x float> <float 0.0, float -0.0>)
  ret { <2 x float>, <2 x i32> } %ret
}

define { <4 x float>, <4 x i32> } @frexp_nonsplat_vector() {
  %ret = call { <4 x float>, <4 x i32> } @llvm.frexp.v4f32.v4i32(<4 x float> <float 16.0, float -32.0, float undef, float 9999.0>)
  ret { <4 x float>, <4 x i32> } %ret
}

define { float, i32 } @frexp_zero() {
  %ret = call { float, i32 } @llvm.frexp.f32.i32(float 0.0)
  ret { float, i32 } %ret
}

define { float, i32 } @frexp_negzero() {
  %ret = call { float, i32 } @llvm.frexp.f32.i32(float -0.0)
  ret { float, i32 } %ret
}

define { float, i32 } @frexp_one() {
  %ret = call { float, i32 } @llvm.frexp.f32.i32(float 1.0)
  ret { float, i32 } %ret
}

define { float, i32 } @frexp_negone() {
  %ret = call { float, i32 } @llvm.frexp.f32.i32(float -1.0)
  ret { float, i32 } %ret
}

define { float, i32 } @frexp_two() {
  %ret = call { float, i32 } @llvm.frexp.f32.i32(float 2.0)
  ret { float, i32 } %ret
}

define { float, i32 } @frexp_negtwo() {
  %ret = call { float, i32 } @llvm.frexp.f32.i32(float -2.0)
  ret { float, i32 } %ret
}

define { float, i32 } @frexp_inf() {
  %ret = call { float, i32 } @llvm.frexp.f32.i32(float 0x7FF0000000000000)
  ret { float, i32 } %ret
}

define { float, i32 } @frexp_neginf() {
  %ret = call { float, i32 } @llvm.frexp.f32.i32(float 0xFFF0000000000000)
  ret { float, i32 } %ret
}

define { float, i32 } @frexp_qnan() {
  %ret = call { float, i32 } @llvm.frexp.f32.i32(float 0x7FF8000000000000)
  ret { float, i32 } %ret
}

define { float, i32 } @frexp_snan() {
  %ret = call { float, i32 } @llvm.frexp.f32.i32(float bitcast (i32 2139095041 to float))
  ret { float, i32 } %ret
}

define { float, i32 } @frexp_pos_denorm() {
  %ret = call { float, i32 } @llvm.frexp.f32.i32(float bitcast (i32 8388607 to float))
  ret { float, i32 } %ret
}

define { float, i32 } @frexp_neg_denorm() {
  %ret = call { float, i32 } @llvm.frexp.f32.i32(float bitcast (i32 -2139095041 to float))
  ret { float, i32 } %ret
}

define { <2 x float>, <2 x i32> } @frexp_splat_4() {
  %ret = call { <2 x float>, <2 x i32> } @llvm.frexp.v2f32.v2i32(<2 x float> <float 4.0, float 4.0>)
  ret { <2 x float>, <2 x i32> } %ret
}

define { <2 x float>, <2 x i32> } @frexp_splat_qnan() {
  %ret = call { <2 x float>, <2 x i32> } @llvm.frexp.v2f32.v2i32(<2 x float> <float 0x7FF8000000000000, float 0x7FF8000000000000>)
  ret { <2 x float>, <2 x i32> } %ret
}

define { <2 x float>, <2 x i32> } @frexp_splat_inf() {
  %ret = call { <2 x float>, <2 x i32> } @llvm.frexp.v2f32.v2i32(<2 x float> <float 0x7FF0000000000000, float 0x7FF0000000000000>)
  ret { <2 x float>, <2 x i32> } %ret
}

define { <2 x float>, <2 x i32> } @frexp_splat_neginf() {
  %ret = call { <2 x float>, <2 x i32> } @llvm.frexp.v2f32.v2i32(<2 x float> <float 0xFFF0000000000000, float 0xFFF0000000000000>)
  ret { <2 x float>, <2 x i32> } %ret
}

define { <2 x float>, <2 x i32> } @frexp_splat_undef_inf() {
  %ret = call { <2 x float>, <2 x i32> } @llvm.frexp.v2f32.v2i32(<2 x float> <float undef, float 0x7FF0000000000000>)
  ret { <2 x float>, <2 x i32> } %ret
}
