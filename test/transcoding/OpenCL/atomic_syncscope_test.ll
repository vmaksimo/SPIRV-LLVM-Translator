; RUN: llvm-as %s -o %t.bc
; RUN: llvm-spirv %t.bc --spirv-ext=+SPV_EXT_shader_atomic_float_add -o %t.spv
; RUN: spirv-val %t.spv
; RUN: llvm-spirv %t.spv -to-text -o %t.spt
; RUN: FileCheck < %t.spt %s -check-prefix=CHECK-SPIRV
; R/UN: llvm-spirv %t.spv -r --spirv-target-env=CL2.0 -o - | llvm-dis -o %t.rev.ll
; RUN: llvm-spirv %t.spv -r -o - | llvm-dis -o %t.rev.ll
; RUN: FileCheck < %t.rev.ll %s -check-prefix=CHECK-LLVM

; ModuleID = '/localdisk2/vmaksimo/llvm-project/llvm/projects/SPIRV-LLVM-Translator/test/transcoding/OpenCL/atomic_syncscope.cl'
; source_filename = "/localdisk2/vmaksimo/llvm-project/llvm/projects/SPIRV-LLVM-Translator/test/transcoding/OpenCL/atomic_syncscope.cl"
target datalayout = "e-p:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024"
target triple = "spir64"

@j = local_unnamed_addr addrspace(1) global i32 0, align 4
; @llvm.amdgcn.abi.version = weak_odr hidden local_unnamed_addr addrspace(4) constant i32 400

; 0 - ScopeInvocation (mapped from work item)
; 1 - ScopeWorkGroup
; 2 - ScopeDevice
; 3 - ScopeCrossDevice (all svm devices)
; 4 - ScopeSubgroup
; CHECK-SPIRV-DAG: Constant [[#]] [[#ConstInt0:]] 0
; CHECK-SPIRV-DAG: Constant [[#]] [[#ConstInt1:]] 1
; CHECK-SPIRV-DAG: Constant [[#]] [[#SequentiallyConsistent:]] 16
; CHECK-SPIRV-DAG: Constant [[#]] [[#ConstInt2:]] 2
; CHECK-SPIRV-DAG: Constant [[#]] [[#ConstInt3:]] 3

; CHECK-SPIRV: AtomicLoad [[#]] [[#]] [[#]] [[#ConstInt1]] [[#SequentiallyConsistent]]
; CHECK-SPIRV: AtomicLoad [[#]] [[#]] [[#]] [[#ConstInt0]] [[#SequentiallyConsistent]]
; CHECK-SPIRV: AtomicLoad [[#]] [[#]] [[#]] [[#ConstInt2]] [[#SequentiallyConsistent]]
; CHECK-SPIRV: AtomicLoad [[#]] [[#]] [[#]] [[#ConstInt3]] [[#SequentiallyConsistent]]

; CHECK-LLVM: call spir_func i32 @_Z10atomic_addPVii

; Function Attrs: mustprogress nofree norecurse nounwind willreturn memory(argmem: readwrite)
define dso_local void @fi1(ptr nocapture noundef readonly %i) local_unnamed_addr #0 {
entry:
  %0 = load atomic i32, ptr %i syncscope("workgroup") seq_cst, align 4
  %1 = load atomic i32, ptr %i syncscope("device") seq_cst, align 4
  %2 = load atomic i32, ptr %i seq_cst, align 4
  %3 = load atomic i32, ptr %i syncscope("subgroup") seq_cst, align 4
  ret void
}

; ; Function Attrs: mustprogress nofree norecurse nounwind willreturn memory(argmem: readwrite)
; define dso_local void @fi2(ptr nocapture noundef writeonly %i) local_unnamed_addr #0 {
; entry:
;   store atomic i32 1, ptr %i syncscope("workgroup") seq_cst, align 4
;   ret void
; }

; ; Function Attrs: mustprogress nofree norecurse nounwind willreturn memory(argmem: readwrite)
; define dso_local void @test_addr(ptr addrspace(1) nocapture noundef writeonly %ig, ptr addrspace(5) nocapture noundef writeonly %ip, ptr addrspace(3) nocapture noundef writeonly %il) local_unnamed_addr #0 {
; entry:
;   store atomic i32 1, ptr addrspace(1) %ig syncscope("workgroup") seq_cst, align 4
;   store atomic i32 1, ptr addrspace(5) %ip syncscope("workgroup") seq_cst, align 4
;   store atomic i32 1, ptr addrspace(3) %il syncscope("workgroup") seq_cst, align 4
;   ret void
; }

; ; Function Attrs: mustprogress nofree norecurse nounwind willreturn memory(argmem: readwrite)
; define dso_local void @fi3(ptr nocapture noundef %i, ptr nocapture noundef %ui) local_unnamed_addr #0 {
; entry:
;   %0 = atomicrmw and ptr %i, i32 1 syncscope("workgroup") seq_cst, align 4
;   %1 = atomicrmw min ptr %i, i32 1 syncscope("workgroup") seq_cst, align 4
;   %2 = atomicrmw max ptr %i, i32 1 syncscope("workgroup") seq_cst, align 4
;   %3 = atomicrmw umin ptr %ui, i32 1 syncscope("workgroup") seq_cst, align 4
;   %4 = atomicrmw umax ptr %ui, i32 1 syncscope("workgroup") seq_cst, align 4
;   ret void
; }

; Function Attrs: mustprogress nofree norecurse nounwind willreturn memory(argmem: readwrite)
; define dso_local zeroext i1 @fi4(ptr nocapture noundef %i) local_unnamed_addr #0 {
; entry:
;   %0 = cmpxchg ptr %i, i32 0, i32 1 syncscope("workgroup-one-as") acquire acquire, align 4
;   %1 = extractvalue { i32, i1 } %0, 1
;   ret i1 %1
; }

; ; Function Attrs: mustprogress nofree norecurse nounwind willreturn memory(argmem: readwrite)
; define dso_local void @fi5(ptr nocapture noundef readonly %i, i32 noundef %scope) local_unnamed_addr #0 {
; entry:
;   switch i32 %scope, label %opencl_allsvmdevices [
;     i32 1, label %opencl_workgroup
;     i32 2, label %opencl_device
;     i32 4, label %opencl_subgroup
;   ]

; opencl_workgroup:                                 ; preds = %entry
;   %0 = load atomic i32, ptr %i syncscope("workgroup") seq_cst, align 4
;   br label %atomic.scope.continue

; opencl_device:                                    ; preds = %entry
;   %1 = load atomic i32, ptr %i syncscope("device") seq_cst, align 4
;   br label %atomic.scope.continue

; opencl_allsvmdevices:                             ; preds = %entry
;   %2 = load atomic i32, ptr %i seq_cst, align 4
;   br label %atomic.scope.continue

; opencl_subgroup:                                  ; preds = %entry
;   %3 = load atomic i32, ptr %i syncscope("subgroup") seq_cst, align 4
;   br label %atomic.scope.continue

; atomic.scope.continue:                            ; preds = %opencl_subgroup, %opencl_allsvmdevices, %opencl_device, %opencl_workgroup
;   ret void
; }

; ; Function Attrs: mustprogress nofree norecurse nounwind willreturn memory(argmem: readwrite)
; define dso_local void @fi6(ptr nocapture noundef readonly %i, i32 noundef %order, i32 noundef %scope) local_unnamed_addr #0 {
; entry:
;   switch i32 %order, label %monotonic [
;     i32 1, label %acquire
;     i32 2, label %acquire
;     i32 5, label %seqcst
;   ]

; monotonic:                                        ; preds = %entry
;   switch i32 %scope, label %opencl_allsvmdevices [
;     i32 1, label %opencl_workgroup
;     i32 2, label %opencl_device
;     i32 4, label %opencl_subgroup
;   ]

; acquire:                                          ; preds = %entry, %entry
;   switch i32 %scope, label %opencl_allsvmdevices3 [
;     i32 1, label %opencl_workgroup1
;     i32 2, label %opencl_device2
;     i32 4, label %opencl_subgroup4
;   ]

; seqcst:                                           ; preds = %entry
;   switch i32 %scope, label %opencl_allsvmdevices8 [
;     i32 1, label %opencl_workgroup6
;     i32 2, label %opencl_device7
;     i32 4, label %opencl_subgroup9
;   ]

; atomic.continue:                                  ; preds = %opencl_workgroup6, %opencl_device7, %opencl_allsvmdevices8, %opencl_subgroup9, %opencl_workgroup1, %opencl_device2, %opencl_allsvmdevices3, %opencl_subgroup4, %opencl_workgroup, %opencl_device, %opencl_allsvmdevices, %opencl_subgroup
;   ret void

; opencl_workgroup:                                 ; preds = %monotonic
;   %0 = load atomic i32, ptr %i syncscope("workgroup-one-as") monotonic, align 4
;   br label %atomic.continue

; opencl_device:                                    ; preds = %monotonic
;   %1 = load atomic i32, ptr %i syncscope("device-one-as") monotonic, align 4
;   br label %atomic.continue

; opencl_allsvmdevices:                             ; preds = %monotonic
;   %2 = load atomic i32, ptr %i syncscope("one-as") monotonic, align 4
;   br label %atomic.continue

; opencl_subgroup:                                  ; preds = %monotonic
;   %3 = load atomic i32, ptr %i syncscope("subgroup-one-as") monotonic, align 4
;   br label %atomic.continue

; opencl_workgroup1:                                ; preds = %acquire
;   %4 = load atomic i32, ptr %i syncscope("workgroup-one-as") acquire, align 4
;   br label %atomic.continue

; opencl_device2:                                   ; preds = %acquire
;   %5 = load atomic i32, ptr %i syncscope("device-one-as") acquire, align 4
;   br label %atomic.continue

; opencl_allsvmdevices3:                            ; preds = %acquire
;   %6 = load atomic i32, ptr %i syncscope("one-as") acquire, align 4
;   br label %atomic.continue

; opencl_subgroup4:                                 ; preds = %acquire
;   %7 = load atomic i32, ptr %i syncscope("subgroup-one-as") acquire, align 4
;   br label %atomic.continue

; opencl_workgroup6:                                ; preds = %seqcst
;   %8 = load atomic i32, ptr %i syncscope("workgroup") seq_cst, align 4
;   br label %atomic.continue

; opencl_device7:                                   ; preds = %seqcst
;   %9 = load atomic i32, ptr %i syncscope("device") seq_cst, align 4
;   br label %atomic.continue

; opencl_allsvmdevices8:                            ; preds = %seqcst
;   %10 = load atomic i32, ptr %i seq_cst, align 4
;   br label %atomic.continue

; opencl_subgroup9:                                 ; preds = %seqcst
;   %11 = load atomic i32, ptr %i syncscope("subgroup") seq_cst, align 4
;   br label %atomic.continue
; }

; ; Function Attrs: mustprogress nofree norecurse nounwind willreturn memory(argmem: readwrite)
; define dso_local float @ff1(ptr addrspace(1) nocapture noundef readonly %d) local_unnamed_addr #0 {
; entry:
;   %0 = load atomic i32, ptr addrspace(1) %d syncscope("workgroup-one-as") monotonic, align 4
;   %1 = bitcast i32 %0 to float
;   ret float %1
; }

; ; Function Attrs: mustprogress nofree norecurse nounwind willreturn memory(argmem: readwrite)
; define dso_local void @ff2(ptr nocapture noundef writeonly %d) local_unnamed_addr #0 {
; entry:
;   store atomic i32 1065353216, ptr %d syncscope("workgroup-one-as") release, align 4
;   ret void
; }

; ; Function Attrs: mustprogress nofree norecurse nounwind willreturn memory(argmem: readwrite)
; define dso_local float @ff3(ptr nocapture noundef %d) local_unnamed_addr #0 {
; entry:
;   %0 = atomicrmw xchg ptr %d, i32 1073741824 syncscope("workgroup") seq_cst, align 4
;   %1 = bitcast i32 %0 to float
;   ret float %1
; }

; Function Attrs: mustprogress nofree norecurse nounwind willreturn memory(argmem: readwrite)
; define dso_local float @ff4(ptr addrspace(1) nocapture noundef %d, float noundef %a) local_unnamed_addr #0 {
; entry:
;   %0 = atomicrmw fadd ptr addrspace(1) %d, float %a syncscope("workgroup-one-as") monotonic, align 4
;   ret float %0
; }

; ; ; Function Attrs: mustprogress nofree norecurse nounwind willreturn memory(argmem: readwrite)
; ; define dso_local float @ff5(ptr addrspace(1) nocapture noundef %d, double noundef %a) local_unnamed_addr #0 {
; ; entry:
; ;   %0 = atomicrmw fadd ptr addrspace(1) %d, double %a syncscope("workgroup-one-as") monotonic, align 8
; ;   %conv = fptrunc double %0 to float
; ;   ret float %conv
; ; }

; ; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(write, argmem: none, inaccessiblemem: none)
; define dso_local void @atomic_init_foo() local_unnamed_addr #1 {
; entry:
;   store i32 42, ptr addrspace(1) @j, align 4, !tbaa !4
;   ret void
; }

; ; Function Attrs: mustprogress nofree norecurse nounwind willreturn memory(argmem: readwrite)
; define dso_local void @failureOrder(ptr nocapture noundef %ptr, ptr nocapture noundef %ptr2) local_unnamed_addr #0 {
; entry:
;   %0 = load i32, ptr %ptr2, align 4
;   %1 = cmpxchg ptr %ptr, i32 %0, i32 43 syncscope("workgroup-one-as") acquire monotonic, align 4
;   %2 = extractvalue { i32, i1 } %1, 1
;   br i1 %2, label %entry.cmpxchg.continue_crit_edge, label %cmpxchg.store_expected

; entry.cmpxchg.continue_crit_edge:                 ; preds = %entry
;   %.pre = load i32, ptr %ptr2, align 4
;   br label %cmpxchg.continue

; cmpxchg.store_expected:                           ; preds = %entry
;   %3 = extractvalue { i32, i1 } %1, 0
;   store i32 %3, ptr %ptr2, align 4
;   br label %cmpxchg.continue

; cmpxchg.continue:                                 ; preds = %entry.cmpxchg.continue_crit_edge, %cmpxchg.store_expected
;   %4 = phi i32 [ %.pre, %entry.cmpxchg.continue_crit_edge ], [ %3, %cmpxchg.store_expected ]
;   %5 = cmpxchg weak ptr %ptr, i32 %4, i32 43 syncscope("workgroup") seq_cst acquire, align 4
;   %6 = extractvalue { i32, i1 } %5, 1
;   br i1 %6, label %cmpxchg.continue4, label %cmpxchg.store_expected3

; cmpxchg.store_expected3:                          ; preds = %cmpxchg.continue
;   %7 = extractvalue { i32, i1 } %5, 0
;   store i32 %7, ptr %ptr2, align 4
;   br label %cmpxchg.continue4

; cmpxchg.continue4:                                ; preds = %cmpxchg.store_expected3, %cmpxchg.continue
;   ret void
; }

; ; Function Attrs: mustprogress nofree norecurse nounwind willreturn memory(argmem: readwrite)
; define dso_local void @generalFailureOrder(ptr nocapture noundef %ptr, ptr nocapture noundef %ptr2, i32 noundef %success, i32 noundef %fail) local_unnamed_addr #0 {
; entry:
;   switch i32 %success, label %monotonic [
;     i32 1, label %acquire
;     i32 2, label %acquire
;     i32 3, label %release
;     i32 4, label %acqrel
;     i32 5, label %seqcst
;   ]

; monotonic:                                        ; preds = %entry
;   switch i32 %fail, label %monotonic_fail [
;     i32 1, label %acquire_fail
;     i32 2, label %acquire_fail
;     i32 5, label %seqcst_fail
;   ]

; acquire:                                          ; preds = %entry, %entry
;   switch i32 %fail, label %monotonic_fail8 [
;     i32 1, label %acquire_fail9
;     i32 2, label %acquire_fail9
;     i32 5, label %seqcst_fail10
;   ]

; release:                                          ; preds = %entry
;   switch i32 %fail, label %monotonic_fail21 [
;     i32 1, label %acquire_fail22
;     i32 2, label %acquire_fail22
;     i32 5, label %seqcst_fail23
;   ]

; acqrel:                                           ; preds = %entry
;   switch i32 %fail, label %monotonic_fail34 [
;     i32 1, label %acquire_fail35
;     i32 2, label %acquire_fail35
;     i32 5, label %seqcst_fail36
;   ]

; seqcst:                                           ; preds = %entry
;   switch i32 %fail, label %monotonic_fail47 [
;     i32 1, label %acquire_fail48
;     i32 2, label %acquire_fail48
;     i32 5, label %seqcst_fail49
;   ]

; atomic.continue.sink.split:                       ; preds = %seqcst_fail49, %acquire_fail48, %monotonic_fail47, %seqcst_fail36, %acquire_fail35, %monotonic_fail34, %seqcst_fail23, %acquire_fail22, %monotonic_fail21, %seqcst_fail10, %acquire_fail9, %monotonic_fail8, %seqcst_fail, %acquire_fail, %monotonic_fail
;   %.sink74 = phi { i32, i1 } [ %2, %monotonic_fail ], [ %5, %acquire_fail ], [ %8, %seqcst_fail ], [ %11, %monotonic_fail8 ], [ %14, %acquire_fail9 ], [ %17, %seqcst_fail10 ], [ %20, %monotonic_fail21 ], [ %23, %acquire_fail22 ], [ %26, %seqcst_fail23 ], [ %29, %monotonic_fail34 ], [ %32, %acquire_fail35 ], [ %35, %seqcst_fail36 ], [ %38, %monotonic_fail47 ], [ %41, %acquire_fail48 ], [ %44, %seqcst_fail49 ]
;   %0 = extractvalue { i32, i1 } %.sink74, 0
;   store i32 %0, ptr %ptr2, align 4
;   br label %atomic.continue

; atomic.continue:                                  ; preds = %atomic.continue.sink.split, %seqcst_fail49, %acquire_fail48, %monotonic_fail47, %seqcst_fail36, %acquire_fail35, %monotonic_fail34, %seqcst_fail23, %acquire_fail22, %monotonic_fail21, %seqcst_fail10, %acquire_fail9, %monotonic_fail8, %seqcst_fail, %acquire_fail, %monotonic_fail
;   ret void

; monotonic_fail:                                   ; preds = %monotonic
;   %1 = load i32, ptr %ptr2, align 4
;   %2 = cmpxchg ptr %ptr, i32 %1, i32 42 syncscope("workgroup-one-as") monotonic monotonic, align 4
;   %3 = extractvalue { i32, i1 } %2, 1
;   br i1 %3, label %atomic.continue, label %atomic.continue.sink.split

; acquire_fail:                                     ; preds = %monotonic, %monotonic
;   %4 = load i32, ptr %ptr2, align 4
;   %5 = cmpxchg ptr %ptr, i32 %4, i32 42 syncscope("workgroup-one-as") monotonic acquire, align 4
;   %6 = extractvalue { i32, i1 } %5, 1
;   br i1 %6, label %atomic.continue, label %atomic.continue.sink.split

; seqcst_fail:                                      ; preds = %monotonic
;   %7 = load i32, ptr %ptr2, align 4
;   %8 = cmpxchg ptr %ptr, i32 %7, i32 42 syncscope("workgroup-one-as") monotonic seq_cst, align 4
;   %9 = extractvalue { i32, i1 } %8, 1
;   br i1 %9, label %atomic.continue, label %atomic.continue.sink.split

; monotonic_fail8:                                  ; preds = %acquire
;   %10 = load i32, ptr %ptr2, align 4
;   %11 = cmpxchg ptr %ptr, i32 %10, i32 42 syncscope("workgroup-one-as") acquire monotonic, align 4
;   %12 = extractvalue { i32, i1 } %11, 1
;   br i1 %12, label %atomic.continue, label %atomic.continue.sink.split

; acquire_fail9:                                    ; preds = %acquire, %acquire
;   %13 = load i32, ptr %ptr2, align 4
;   %14 = cmpxchg ptr %ptr, i32 %13, i32 42 syncscope("workgroup-one-as") acquire acquire, align 4
;   %15 = extractvalue { i32, i1 } %14, 1
;   br i1 %15, label %atomic.continue, label %atomic.continue.sink.split

; seqcst_fail10:                                    ; preds = %acquire
;   %16 = load i32, ptr %ptr2, align 4
;   %17 = cmpxchg ptr %ptr, i32 %16, i32 42 syncscope("workgroup-one-as") acquire seq_cst, align 4
;   %18 = extractvalue { i32, i1 } %17, 1
;   br i1 %18, label %atomic.continue, label %atomic.continue.sink.split

; monotonic_fail21:                                 ; preds = %release
;   %19 = load i32, ptr %ptr2, align 4
;   %20 = cmpxchg ptr %ptr, i32 %19, i32 42 syncscope("workgroup-one-as") release monotonic, align 4
;   %21 = extractvalue { i32, i1 } %20, 1
;   br i1 %21, label %atomic.continue, label %atomic.continue.sink.split

; acquire_fail22:                                   ; preds = %release, %release
;   %22 = load i32, ptr %ptr2, align 4
;   %23 = cmpxchg ptr %ptr, i32 %22, i32 42 syncscope("workgroup-one-as") release acquire, align 4
;   %24 = extractvalue { i32, i1 } %23, 1
;   br i1 %24, label %atomic.continue, label %atomic.continue.sink.split

; seqcst_fail23:                                    ; preds = %release
;   %25 = load i32, ptr %ptr2, align 4
;   %26 = cmpxchg ptr %ptr, i32 %25, i32 42 syncscope("workgroup-one-as") release seq_cst, align 4
;   %27 = extractvalue { i32, i1 } %26, 1
;   br i1 %27, label %atomic.continue, label %atomic.continue.sink.split

; monotonic_fail34:                                 ; preds = %acqrel
;   %28 = load i32, ptr %ptr2, align 4
;   %29 = cmpxchg ptr %ptr, i32 %28, i32 42 syncscope("workgroup-one-as") acq_rel monotonic, align 4
;   %30 = extractvalue { i32, i1 } %29, 1
;   br i1 %30, label %atomic.continue, label %atomic.continue.sink.split

; acquire_fail35:                                   ; preds = %acqrel, %acqrel
;   %31 = load i32, ptr %ptr2, align 4
;   %32 = cmpxchg ptr %ptr, i32 %31, i32 42 syncscope("workgroup-one-as") acq_rel acquire, align 4
;   %33 = extractvalue { i32, i1 } %32, 1
;   br i1 %33, label %atomic.continue, label %atomic.continue.sink.split

; seqcst_fail36:                                    ; preds = %acqrel
;   %34 = load i32, ptr %ptr2, align 4
;   %35 = cmpxchg ptr %ptr, i32 %34, i32 42 syncscope("workgroup-one-as") acq_rel seq_cst, align 4
;   %36 = extractvalue { i32, i1 } %35, 1
;   br i1 %36, label %atomic.continue, label %atomic.continue.sink.split

; monotonic_fail47:                                 ; preds = %seqcst
;   %37 = load i32, ptr %ptr2, align 4
;   %38 = cmpxchg ptr %ptr, i32 %37, i32 42 syncscope("workgroup") seq_cst monotonic, align 4
;   %39 = extractvalue { i32, i1 } %38, 1
;   br i1 %39, label %atomic.continue, label %atomic.continue.sink.split

; acquire_fail48:                                   ; preds = %seqcst, %seqcst
;   %40 = load i32, ptr %ptr2, align 4
;   %41 = cmpxchg ptr %ptr, i32 %40, i32 42 syncscope("workgroup") seq_cst acquire, align 4
;   %42 = extractvalue { i32, i1 } %41, 1
;   br i1 %42, label %atomic.continue, label %atomic.continue.sink.split

; seqcst_fail49:                                    ; preds = %seqcst
;   %43 = load i32, ptr %ptr2, align 4
;   %44 = cmpxchg ptr %ptr, i32 %43, i32 42 syncscope("workgroup") seq_cst seq_cst, align 4
;   %45 = extractvalue { i32, i1 } %44, 1
;   br i1 %45, label %atomic.continue, label %atomic.continue.sink.split
; }

; ; Function Attrs: mustprogress nofree norecurse nounwind willreturn memory(argmem: readwrite, inaccessiblemem: readwrite)
; define dso_local i32 @test_volatile(ptr noundef %i) local_unnamed_addr #2 {
; entry:
;   %0 = load atomic volatile i32, ptr %i syncscope("workgroup") seq_cst, align 4
;   ret i32 %0
; }

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
