; RUN: llvm-as %s -o %t.bc
; RUN: llvm-spirv %t.bc --spirv-ext=+SPV_INTEL_task_sequence -o %t.spv
; R/UN: spirv-val %t.spv
; RUN: llvm-spirv %t.spv -to-text -o %t.spt
; RUN: FileCheck < %t.spt %s --check-prefix=CHECK-SPIRV

; RUN: llvm-spirv -r %t.spv -o %t.rev.bc
; RUN: llvm-dis %t.rev.bc
; RUN: FileCheck < %t.rev.ll %s --check-prefix=CHECK-LLVM

target datalayout = "e-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-n8:16:32:64"
target triple = "spir64-unknown-unknown"

%"class.task_sequence" = type { target("spirv.TaskSequenceINTEL") }
%struct.DataStruct = type <{ float, i8, [3 x i8] }>

$_ZTS8MyKernel = comdat any


; CHECK-SPIRV: FuncParamAttr 38
; CHECK-SPIRV: TaskSequenceAsyncINTEL

; CHECK-LLVM: byval(%struct.DataStruct)

; Function Attrs: convergent mustprogress norecurse nounwind
define weak_odr dso_local spir_kernel void @_ZTS8MyKernel(ptr addrspace(1) noundef align 4 %_arg_in, ptr addrspace(1) noundef readonly align 4 %_arg_in_acc_struct, ptr addrspace(1) noundef align 4 %_arg_res) local_unnamed_addr #0 comdat !srcloc !5 !kernel_arg_buffer_location !6 !sycl_fixed_targets !7 !sycl_kernel_omit_args !8 !stall_enable !9 {
entry:
  %agg.tmp.i67 = alloca %struct.DataStruct, align 4
  ; %arrayidx.i = getelementptr inbounds i32, ptr addrspace(1) %_arg_in, i64 0
  ; %0 = load i32, ptr addrspace(1) %arrayidx.i, align 4
  %myMultTask.i = alloca %"class.task_sequence", align 8
  %0 = load i64, ptr addrspace(1) %_arg_in, align 8
  %add.ptr.i = getelementptr inbounds %struct.DataStruct, ptr addrspace(1) %_arg_in_acc_struct, i64 %0
  %4 = load i64, ptr addrspace(1) %add.ptr.i, align 4
  store i64 %4, ptr %agg.tmp.i67, align 4
  ; store i32 0, ptr %myMultTask.i, align 8
  ; %call.i1 = call spir_func noundef target("spirv.TaskSequenceINTEL") @_Z31__spirv_TaskSequenceCreateINTEL(ptr noundef nonnull @_Z4multii, i32 noundef 10, i32 noundef -1, i32 noundef 17, i32 noundef zeroext -1) #3
  %id.i = getelementptr inbounds %"class.task_sequence", ptr %myMultTask.i, i64 0, i32 0
  ; store target("spirv.TaskSequenceINTEL") %call.i1, ptr %id.i, align 8
  %5 = load target("spirv.TaskSequenceINTEL"), ptr %id.i, align 8
  call spir_func void @_Z30__spirv_TaskSequenceAsyncINTELIJiiEEvmDpT_(target("spirv.TaskSequenceINTEL") noundef %5, ptr noundef nonnull byval(%struct.DataStruct) align 4 %agg.tmp.i67)
  ret void
}

; Function Attrs: mustprogress norecurse nounwind
define linkonce_odr dso_local spir_func noundef i32 @_Z4multii(i32 noundef %a, i32 noundef %b) #1 !srcloc !10 {
entry:
  %mul = mul nsw i32 %a, %b
  ret i32 %mul
}

; Function Attrs: convergent nounwind
; declare dso_local spir_func noundef target("spirv.TaskSequenceINTEL") @_Z31__spirv_TaskSequenceCreateINTEL(ptr noundef, i32 noundef, i32 noundef, i32 noundef, i32 noundef zeroext) local_unnamed_addr #2

; Function Attrs: convergent nounwind
; declare dso_local spir_func void @_Z30__spirv_TaskSequenceAsyncINTELIJiiEEvmDpT_(target("spirv.TaskSequenceINTEL") noundef, i32 noundef, i32 noundef) local_unnamed_addr #2

declare dso_local spir_func void @_Z30__spirv_TaskSequenceAsyncINTELIJiiEEvmDpT_(target("spirv.TaskSequenceINTEL") noundef, ptr noundef byval(%struct.DataStruct) align 4) local_unnamed_addr

attributes #0 = { convergent mustprogress norecurse nounwind "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "sycl-fpga-cluster"="1" "sycl-module-id"="test.cpp" "sycl-optlevel"="2" "sycl-single-task" "uniform-work-group-size"="true" }
attributes #1 = { mustprogress norecurse nounwind "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "sycl-optlevel"="2" }
attributes #2 = { convergent nounwind "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #3 = { convergent nounwind }

!opencl.spir.version = !{!0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0}
!spirv.Source = !{!1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1}
!llvm.ident = !{!2, !2, !2, !2, !2, !2, !2, !2, !2, !2, !2, !2, !2, !2, !2, !2, !2, !2, !2, !2, !2}
!llvm.module.flags = !{!3, !4}
!sycl.specialization-constants = !{}
!sycl.specialization-constants-default-values = !{}

!0 = !{i32 1, i32 2}
!1 = !{i32 4, i32 100000}
!2 = !{!"clang version 18.0.0git"}
!3 = !{i32 1, !"wchar_size", i32 4}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{i32 5445863}
!6 = !{i32 -1, i32 -1}
!7 = !{}
!8 = !{i1 false, i1 false}
!9 = !{i1 true}
!10 = !{i32 5445350}
