; This LLVM IR was generated using Intel SYCL Clang compiler (https://github.com/intel/llvm)

; RUN: llvm-as %s -o %t.bc
; RUN: llvm-spirv %t.bc -o %t.spv --spirv-ext=+SPV_INTEL_arbitrary_precision_integers,+SPV_INTEL_vector_compute
; RUN: llvm-spirv %t.spv -to-text -o %t.spt
; RUN: FileCheck < %t.spt %s --check-prefix=CHECK-SPIRV
; RUN: llvm-spirv -r %t.spv -o %t.rev.bc
; RUN: llvm-dis < %t.rev.bc | FileCheck %s --check-prefix=CHECK-LLVM

target datalayout = "e-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-n8:16:32:64"
target triple = "spir64"

; @.str.1 = private unnamed_addr addrspace(1) constant [1 x i8] zeroinitializer, align 1

; CHECK-SPIRV: Constant [[#]] [[#CONSTANT:]] 65793
; CHECK-SPIRV: ConstantComposite [[#]] [[#COMPOS:]] [[#CONSTANT]]
; CHECK-SPIRV: SpecConstantOp
; CHECK-SPIRV:
; CHECK-SPIRV:
; CHECK-SPIRV:
; CHECK-SPIRV:
; CHECK-SPIRV:
; CHECK-SPIRV: ConstantComposite
; CHECK-SPIRV: SpecConstantOp

; C/HECK-SPIRV: DebugLocalVariable
; C/HECK-SPIRV: DebugLocalVariable

define linkonce_odr hidden spir_func void @foo() {
entry:
  call void @llvm.dbg.value(
    metadata <4 x i8> <
        i8 extractelement (<3 x i8> bitcast (<1 x i24> <i24 65793> to <3 x i8>), i32 0),
        i8 extractelement (<3 x i8> bitcast (<1 x i24> <i24 65793> to <3 x i8>), i32 1),
        i8 extractelement (<3 x i8> bitcast (<1 x i24> <i24 65793> to <3 x i8>), i32 2),
        i8 undef>,
    metadata !3881, metadata !DIExpression()), !dbg !14
  call void @llvm.dbg.value(
      metadata <4 x half> <
      half fadd (
          half extractelement (<4 x half> bitcast (<1 x i64> <i64 65971704314880> to <4 x half>), i32 0),
          half extractelement (<4 x half> bitcast (<1 x i64> <i64 70369817935872> to <4 x half>), i32 0)),
      half fadd (
          half extractelement (<4 x half> bitcast (<1 x i64> <i64 65971704314880> to <4 x half>), i32 1),
          half extractelement (<4 x half> bitcast (<1 x i64> <i64 70369817935872> to <4 x half>), i32 1)),
      half fadd (
          half extractelement (<4 x half> bitcast (<1 x i64> <i64 65971704314880> to <4 x half>), i32 2),
          half extractelement (<4 x half> bitcast (<1 x i64> <i64 70369817935872> to <4 x half>), i32 2)),
      half undef>,
      metadata !4478, metadata !DIExpression()), !dbg !13
  ret void
}

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare void @llvm.dbg.value(metadata, metadata, metadata)


!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!3, !4}
!opencl.used.extensions = !{!2}
!opencl.used.optional.core.features = !{!2}
!opencl.compiler.options = !{!2}
!llvm.ident = !{!5}


!4465 = !{}

!0 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus_14, file: !1, producer: "clang version 13.0.0 (https://github.com/intel/llvm.git)", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, nameTableKind: None)
!1 = !DIFile(filename: "<stdin>", directory: "/export/users")
!2 = !{}
!3 = !{i32 2, !"Debug Info Version", i32 3}
!4 = !{i32 1, !"wchar_size", i32 4}
!5 = !{!"clang version 13.0.0"}
!6 = distinct !DISubprogram(name: "main", scope: !7, file: !7, line: 4, type: !8, scopeLine: 4, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !2)
!66 = distinct !DISubprogram(name: "main2", scope: !7, file: !7, line: 1, type: !8, scopeLine: 4, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !2)
!7 = !DIFile(filename: "main.cpp", directory: "/export/users")
!8 = !DISubroutineType(types: !9)
!9 = !{!10}
!10 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!13 = !DILocation(line: 1, scope: !66, inlinedAt: !4513)
!14 = !DILocation(line: 0, scope: !6, inlinedAt: !4512)

!65 = !DIBasicType(name: "signed char", size: 8, encoding: DW_ATE_signed_char)
!3881 = !DILocalVariable(name: "resVec2", scope: !6, file: !7, line: 0, type: !433)
!433 = distinct !DICompositeType(tag: DW_TAG_class_type, name: "vec<signed char, 3>", scope: !6, file: !7, line: 0, size: 32, flags: DIFlagTypePassByValue, elements: !2, identifier: "_ZTSN2cl4sycl3vecIaLi3EEE")

!4478 = !DILocalVariable(name: "resVec", scope: !66, file: !7, line: 1, type: !669)
!669 = distinct !DICompositeType(tag: DW_TAG_class_type, name: "vec<cl::sycl::detail::half_impl::half, 3>", scope: !66, file: !7, line: 1, size: 64, flags: DIFlagTypePassByValue, elements: !2, identifier: "_ZTSN2cl4sycl3vecINS0_6detail9half_impl4halfELi3EEE")
!4512 = !DILocation(line: 0, column: 0, scope: !6)
!4513 = !DILocation(line: 1, column: 0, scope: !66)