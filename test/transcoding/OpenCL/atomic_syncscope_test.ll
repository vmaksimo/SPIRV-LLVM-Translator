; RUN: llvm-as %s -o %t.bc
; RUN: llvm-spirv %t.bc --spirv-ext=+SPV_EXT_shader_atomic_float_add -o %t.spv
; RUN: spirv-val %t.spv
; RUN: llvm-spirv %t.spv -to-text -o %t.spt
; RUN: FileCheck < %t.spt %s -check-prefix=CHECK-SPIRV
; RUN: llvm-spirv %t.spv -r --spirv-target-env=CL2.0 -o - | llvm-dis -o %t.rev.ll
; RUN: FileCheck < %t.rev.ll %s -check-prefix=CHECK-LLVM

target datalayout = "e-p:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024"
target triple = "spir64"

@j = local_unnamed_addr addrspace(1) global i32 0, align 4

; 0 - ScopeCrossDevice (all svm devices)
; 1 - ScopeDevice
; 2 - ScopeWorkGroup
; 3 - ScopeSubgroup
; 4 - ScopeInvocation (mapped from work item)
; CHECK-SPIRV-DAG: Constant [[#]] [[#ConstInt0:]] 0
; CHECK-SPIRV-DAG: Constant [[#]] [[#SequentiallyConsistent:]] 16
; CHECK-SPIRV-DAG: Constant [[#]] [[#ConstInt1:]] 1
; CHECK-SPIRV-DAG: Constant [[#]] [[#ConstInt2:]] 2
; CHECK-SPIRV-DAG: Constant [[#]] [[#ConstInt3:]] 3

; CHECK-SPIRV: AtomicLoad [[#]] [[#]] [[#]] [[#ConstInt2]] [[#SequentiallyConsistent]]
; CHECK-SPIRV: AtomicLoad [[#]] [[#]] [[#]] [[#ConstInt1]] [[#SequentiallyConsistent]]
; CHECK-SPIRV: AtomicLoad [[#]] [[#]] [[#]] [[#ConstInt1]] [[#SequentiallyConsistent]]
; CHECK-SPIRV: AtomicLoad [[#]] [[#]] [[#]] [[#ConstInt3]] [[#SequentiallyConsistent]]

; CHECK-SPIRV: AtomicStore [[#]] [[#ConstInt3]] [[#SequentiallyConsistent]] [[#ConstInt1]]
; CHECK-SPIRV: AtomicStore [[#]] [[#ConstInt2]] [[#SequentiallyConsistent]] [[#ConstInt1]]

; CHECK-LLVM: call spir_func i32 @_Z20atomic_load_explicitPU3AS4VU7_Atomici12memory_order12memory_scope

; Function Attrs: mustprogress nofree norecurse nounwind willreturn memory(argmem: readwrite)
define dso_local void @fi1(ptr addrspace(4) nocapture noundef readonly %i) local_unnamed_addr #0 {
entry:
  %0 = load atomic i32, ptr addrspace(4) %i syncscope("workgroup") seq_cst, align 4
  %1 = load atomic i32, ptr addrspace(4) %i syncscope("device") seq_cst, align 4
  %2 = load atomic i32, ptr addrspace(4) %i seq_cst, align 4
  %3 = load atomic i32, ptr addrspace(4) %i syncscope("subgroup") seq_cst, align 4
  ret void
}

; ; Function Attrs: mustprogress nofree norecurse nounwind willreturn memory(argmem: readwrite)
; define dso_local void @fi2(ptr nocapture noundef writeonly %i) local_unnamed_addr #0 {
; entry:
;   store atomic i32 1, ptr %i syncscope("workgroup") seq_cst, align 4
;   ret void
; }

; Function Attrs: mustprogress nofree norecurse nounwind willreturn memory(argmem: readwrite)
define dso_local void @test_addr(ptr addrspace(1) nocapture noundef writeonly %ig, ptr addrspace(5) nocapture noundef writeonly %ip, ptr addrspace(3) nocapture noundef writeonly %il) local_unnamed_addr #0 {
entry:
; 2
  ; store atomic i32 1, ptr addrspace(1) %ig syncscope("workgroup") seq_cst, align 4
; 3  
  store atomic i32 1, ptr addrspace(5) %ip syncscope("subgroup") seq_cst, align 4
  store atomic i32 1, ptr addrspace(3) %il syncscope("workgroup") seq_cst, align 4
  ret void
}

; Function Attrs: mustprogress nofree norecurse nounwind willreturn memory(argmem: readwrite)
define dso_local void @fi3(ptr nocapture noundef %i, ptr nocapture noundef %ui) local_unnamed_addr #0 {
entry:
  %0 = atomicrmw and ptr %i, i32 1 syncscope("workgroup") seq_cst, align 4
  %1 = atomicrmw min ptr %i, i32 1 syncscope("workgroup") seq_cst, align 4
  %2 = atomicrmw max ptr %i, i32 1 syncscope("workgroup") seq_cst, align 4
  %3 = atomicrmw umin ptr %ui, i32 1 syncscope("workgroup") seq_cst, align 4
  %4 = atomicrmw umax ptr %ui, i32 1 syncscope("workgroup") seq_cst, align 4
  ret void
}

; Function Attrs: mustprogress nofree norecurse nounwind willreturn memory(argmem: readwrite)
define dso_local zeroext i1 @fi4(ptr nocapture noundef %i) local_unnamed_addr #0 {
entry:
  %0 = cmpxchg ptr %i, i32 0, i32 1 syncscope("workgroup") acquire acquire, align 4
  %1 = extractvalue { i32, i1 } %0, 1
  ret i1 %1
}

; Function Attrs: mustprogress nofree norecurse nounwind willreturn memory(argmem: readwrite)
define dso_local float @ff1(ptr addrspace(1) nocapture noundef readonly %d) local_unnamed_addr #0 {
entry:
  %0 = load atomic i32, ptr addrspace(1) %d syncscope("workgroup") monotonic, align 4
  %1 = bitcast i32 %0 to float
  ret float %1
}

; Function Attrs: mustprogress nofree norecurse nounwind willreturn memory(argmem: readwrite)
define dso_local void @ff2(ptr nocapture noundef writeonly %d) local_unnamed_addr #0 {
entry:
  store atomic i32 1065353216, ptr %d syncscope("workgroup") release, align 4
  ret void
}

; ; Function Attrs: mustprogress nofree norecurse nounwind willreturn memory(argmem: readwrite)
define dso_local float @ff3(ptr nocapture noundef %d) local_unnamed_addr #0 {
entry:
  %0 = atomicrmw xchg ptr %d, i32 1073741824 syncscope("workgroup") seq_cst, align 4
  %1 = bitcast i32 %0 to float
  ret float %1
}

; Function Attrs: mustprogress nofree norecurse nounwind willreturn memory(argmem: readwrite)
define dso_local float @ff4(ptr addrspace(1) nocapture noundef %d, float noundef %a) local_unnamed_addr #0 {
entry:
  %0 = atomicrmw fadd ptr addrspace(1) %d, float %a syncscope("workgroup") monotonic, align 4
  ret float %0
}

; Function Attrs: mustprogress nofree norecurse nounwind willreturn memory(argmem: readwrite)
define dso_local float @ff5(ptr addrspace(1) nocapture noundef %d, double noundef %a) local_unnamed_addr #0 {
entry:
  %0 = atomicrmw fadd ptr addrspace(1) %d, double %a syncscope("workgroup") monotonic, align 8
  %conv = fptrunc double %0 to float
  ret float %conv
}

; ; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(write, argmem: none, inaccessiblemem: none)
; define dso_local void @atomic_init_foo() local_unnamed_addr #1 {
; entry:
;   store i32 42, ptr addrspace(1) @j, align 4
;   ret void
; }

; define dso_local spir_kernel void @test_atomic_kernel(ptr addrspace(3) %ff) local_unnamed_addr #0 !kernel_arg_addr_space !2 !kernel_arg_access_qual !3 !kernel_arg_type !4 !kernel_arg_base_type !5 !kernel_arg_type_qual !6 {
define dso_local void @atomic_init_foo() local_unnamed_addr #1 {
entry:
  ; %0 = addrspacecast ptr addrspace(3) %ff to ptr addrspace(4)
  tail call spir_func void @_Z11atomic_initPU3AS4VU7_Atomicff(ptr addrspace(1) @j, i32 42)
  ret void
}

; Function Attrs: convergent
declare spir_func void @_Z11atomic_initPU3AS4VU7_Atomicff(ptr addrspace(1), i32) local_unnamed_addr

attributes #0 = { mustprogress nofree norecurse nounwind willreturn memory(argmem: readwrite) "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #1 = { mustprogress nofree norecurse nosync nounwind willreturn memory(write, argmem: none, inaccessiblemem: none) "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #2 = { mustprogress nofree norecurse nounwind willreturn memory(argmem: readwrite, inaccessiblemem: readwrite) "no-trapping-math"="true" "stack-protector-buffer-size"="8" }

; !llvm.module.flags = !{!0, !1}
!llvm.module.flags = !{!1}
!opencl.ocl.version = !{!2}
!llvm.ident = !{!3}

; !0 = !{i32 1, !"amdgpu_code_object_version", i32 400}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 2, i32 0}
!3 = !{!"clang version 18.0.0 (https://github.com/llvm/llvm-project.git 7ce613fc77af092dd6e9db71ce3747b75bc5616e)"}
!4 = !{!5, !5, i64 0}
!5 = !{!"omnipotent char", !6, i64 0}
!6 = !{!"Simple C/C++ TBAA"}
