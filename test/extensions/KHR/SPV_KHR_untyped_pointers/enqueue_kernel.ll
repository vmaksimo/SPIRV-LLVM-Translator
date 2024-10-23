; Compiled copy of enqueue_kernel.cl

; RUN: llvm-as %s -o %t.bc
; RUN: llvm-spirv %t.bc --spirv-ext=+SPV_KHR_untyped_pointers -o %t.spv
; RUN: spirv-val %t.spv
; RUN: llvm-spirv %t.bc -spirv-text --spirv-ext=+SPV_KHR_untyped_pointers -o %t.spv.txt
; RUN: FileCheck < %t.spv.txt %s --check-prefix=CHECK-SPIRV
; RUN: llvm-spirv -r %t.spv --spirv-target-env CL2.0 -o %t.rev.bc
; RUN: llvm-dis %t.rev.bc
; RUN: FileCheck < %t.rev.ll %s --check-prefix=CHECK-LLVM
; RUN: llvm-spirv -r %t.spv --spirv-target-env SPV-IR -o %t.rev.bc
; RUN: llvm-dis %t.rev.bc
; RUN: FileCheck < %t.rev.ll %s --check-prefix=CHECK-SPV-IR

; CHECK-SPIRV: EntryPoint {{[0-9]+}} [[BlockKer1:[0-9]+]] "__device_side_enqueue_block_invoke_kernel"
; CHECK-SPIRV: EntryPoint {{[0-9]+}} [[BlockKer2:[0-9]+]] "__device_side_enqueue_block_invoke_2_kernel"
; CHECK-SPIRV: EntryPoint {{[0-9]+}} [[BlockKer3:[0-9]+]] "__device_side_enqueue_block_invoke_3_kernel"
; CHECK-SPIRV: EntryPoint {{[0-9]+}} [[BlockKer4:[0-9]+]] "__device_side_enqueue_block_invoke_4_kernel"
; CHECK-SPIRV: EntryPoint {{[0-9]+}} [[BlockKer5:[0-9]+]] "__device_side_enqueue_block_invoke_5_kernel"
; CHECK-SPIRV: Name [[BlockGlb1:[0-9]+]] "__block_literal_global"
; CHECK-SPIRV: Name [[BlockGlb2:[0-9]+]] "__block_literal_global.1"

; CHECK-SPIRV: TypeInt [[Int32Ty:[0-9]+]] 32
; CHECK-SPIRV: TypeInt [[Int8Ty:[0-9]+]] 8
; CHECK-SPIRV: Constant [[Int32Ty]] [[ConstInt0:[0-9]+]] 0
; CHECK-SPIRV: Constant [[Int32Ty]] [[ConstInt17:[0-9]+]] 21
; CHECK-SPIRV: Constant [[Int32Ty]] [[ConstInt2:[0-9]+]] 2
; CHECK-SPIRV: Constant [[Int32Ty]] [[ConstInt8:[0-9]+]] 8
; CHECK-SPIRV: Constant [[Int32Ty]] [[ConstInt20:[0-9]+]] 24

; CHECK-SPIRV: TypeUntypedPointerKHR [[PtrGenTy:[0-9]+]] 8
; CHECK-SPIRV: TypeVoid [[VoidTy:[0-9]+]]
; CHECK-SPIRV: TypeUntypedPointerKHR [[Int32LocPtrTy:[0-9]+]] 7
; CHECK-SPIRV: TypeDeviceEvent [[EventTy:[0-9]+]]
; C/HECK-SPIRV: TypePointer [[PtrGenTy:[0-9]+]] 8 [[EventTy]]
; CHECK-SPIRV: TypeFunction [[BlockTy1:[0-9]+]] [[VoidTy]] [[PtrGenTy]]
; CHECK-SPIRV: TypeFunction [[BlockTy2:[0-9]+]] [[VoidTy]] [[PtrGenTy]]
; CHECK-SPIRV: TypeFunction [[BlockTy3:[0-9]+]] [[VoidTy]] [[PtrGenTy]]
; CHECK-SPIRV: ConstantNull [[PtrGenTy]] [[EventNull:[0-9]+]]

; CHECK-LLVM: [[BlockTy1:%[0-9a-z\.]+]] = type { i32, i32, ptr addrspace(4) }
; CHECK-LLVM: [[BlockTy2:%[0-9a-z\.]+]] = type <{ i32, i32, ptr addrspace(4), ptr addrspace(1), i32, i8 }>
; CHECK-LLVM: [[BlockTy3:%[0-9a-z\.]+]] = type <{ i32, i32, ptr addrspace(4), ptr addrspace(1), i32, ptr addrspace(1) }>

; CHECK-LLVM: @__block_literal_global = internal addrspace(1) constant [[BlockTy1]] { i32 12, i32 4, ptr addrspace(4) null }, align 4
; CHECK-LLVM: @__block_literal_global.1 = internal addrspace(1) constant [[BlockTy1]] { i32 12, i32 4, ptr addrspace(4) null }, align 4


target datalayout = "e-p:32:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-G1"
target triple = "spir-unknown-unknown"

%struct.ndrange_t = type { i32 }

@__block_literal_global = internal addrspace(1) constant { i32, i32, ptr addrspace(4) } { i32 12, i32 4, ptr addrspace(4) addrspacecast (ptr @__device_side_enqueue_block_invoke_3 to ptr addrspace(4)) }, align 4 #0
@__block_literal_global.1 = internal addrspace(1) constant { i32, i32, ptr addrspace(4) } { i32 12, i32 4, ptr addrspace(4) addrspacecast (ptr @__device_side_enqueue_block_invoke_4 to ptr addrspace(4)) }, align 4 #0

; Function Attrs: convergent noinline norecurse nounwind optnone
define dso_local spir_kernel void @device_side_enqueue(ptr addrspace(1) noundef align 4 %a, ptr addrspace(1) noundef align 4 %b, i32 noundef %i, i8 noundef signext %c0) #1 !kernel_arg_addr_space !3 !kernel_arg_access_qual !4 !kernel_arg_type !5 !kernel_arg_base_type !5 !kernel_arg_type_qual !6 {
entry:
  %a.addr = alloca ptr addrspace(1), align 4
  %b.addr = alloca ptr addrspace(1), align 4
  %i.addr = alloca i32, align 4
  %c0.addr = alloca i8, align 1
  %default_queue = alloca target("spirv.Queue"), align 4
  %flags = alloca i32, align 4
  %ndrange = alloca %struct.ndrange_t, align 4
  %clk_event = alloca target("spirv.DeviceEvent"), align 4
  %event_wait_list = alloca target("spirv.DeviceEvent"), align 4
  %event_wait_list2 = alloca [1 x target("spirv.DeviceEvent")], align 4
  %tmp = alloca %struct.ndrange_t, align 4
  %block = alloca <{ i32, i32, ptr addrspace(4), ptr addrspace(1), i32, i8 }>, align 4
  %tmp3 = alloca %struct.ndrange_t, align 4
  %block4 = alloca <{ i32, i32, ptr addrspace(4), ptr addrspace(1), i32, ptr addrspace(1) }>, align 4
  %c = alloca i8, align 1
  %tmp11 = alloca %struct.ndrange_t, align 4
  %block_sizes = alloca [1 x i32], align 4
  %tmp12 = alloca %struct.ndrange_t, align 4
  %block_sizes13 = alloca [3 x i32], align 4
  %tmp14 = alloca %struct.ndrange_t, align 4
  %block15 = alloca <{ i32, i32, ptr addrspace(4), ptr addrspace(1), i32, ptr addrspace(1) }>, align 4
  store ptr addrspace(1) %a, ptr %a.addr, align 4
  store ptr addrspace(1) %b, ptr %b.addr, align 4
  store i32 %i, ptr %i.addr, align 4
  store i8 %c0, ptr %c0.addr, align 1
  store i32 0, ptr %flags, align 4
  %0 = load target("spirv.DeviceEvent"), ptr %clk_event, align 4
  store target("spirv.DeviceEvent") %0, ptr %event_wait_list2, align 4
  %1 = load target("spirv.Queue"), ptr %default_queue, align 4
  %2 = load i32, ptr %flags, align 4
  call void @llvm.memcpy.p0.p0.i32(ptr align 4 %tmp, ptr align 4 %ndrange, i32 4, i1 false)
  %block.size = getelementptr inbounds nuw <{ i32, i32, ptr addrspace(4), ptr addrspace(1), i32, i8 }>, ptr %block, i32 0, i32 0
  store i32 21, ptr %block.size, align 4
  %block.align = getelementptr inbounds nuw <{ i32, i32, ptr addrspace(4), ptr addrspace(1), i32, i8 }>, ptr %block, i32 0, i32 1
  store i32 4, ptr %block.align, align 4
  %block.invoke = getelementptr inbounds nuw <{ i32, i32, ptr addrspace(4), ptr addrspace(1), i32, i8 }>, ptr %block, i32 0, i32 2
  store ptr addrspace(4) addrspacecast (ptr @__device_side_enqueue_block_invoke to ptr addrspace(4)), ptr %block.invoke, align 4
  %block.captured = getelementptr inbounds nuw <{ i32, i32, ptr addrspace(4), ptr addrspace(1), i32, i8 }>, ptr %block, i32 0, i32 3
  %3 = load ptr addrspace(1), ptr %a.addr, align 4
  store ptr addrspace(1) %3, ptr %block.captured, align 4
  %block.captured1 = getelementptr inbounds nuw <{ i32, i32, ptr addrspace(4), ptr addrspace(1), i32, i8 }>, ptr %block, i32 0, i32 4
  %4 = load i32, ptr %i.addr, align 4
  store i32 %4, ptr %block.captured1, align 4
  %block.captured2 = getelementptr inbounds nuw <{ i32, i32, ptr addrspace(4), ptr addrspace(1), i32, i8 }>, ptr %block, i32 0, i32 5
  %5 = load i8, ptr %c0.addr, align 1
  store i8 %5, ptr %block.captured2, align 4
  %6 = addrspacecast ptr %block to ptr addrspace(4)
  %7 = call spir_func i32 @__enqueue_kernel_basic(target("spirv.Queue") %1, i32 %2, ptr byval(%struct.ndrange_t) %tmp, ptr addrspace(4) addrspacecast (ptr @__device_side_enqueue_block_invoke_kernel to ptr addrspace(4)), ptr addrspace(4) %6)
  %8 = load target("spirv.Queue"), ptr %default_queue, align 4
  %9 = load i32, ptr %flags, align 4
  call void @llvm.memcpy.p0.p0.i32(ptr align 4 %tmp3, ptr align 4 %ndrange, i32 4, i1 false)
  %10 = addrspacecast ptr %event_wait_list to ptr addrspace(4)
  %11 = addrspacecast ptr %clk_event to ptr addrspace(4)
  %block.size5 = getelementptr inbounds nuw <{ i32, i32, ptr addrspace(4), ptr addrspace(1), i32, ptr addrspace(1) }>, ptr %block4, i32 0, i32 0
  store i32 24, ptr %block.size5, align 4
  %block.align6 = getelementptr inbounds nuw <{ i32, i32, ptr addrspace(4), ptr addrspace(1), i32, ptr addrspace(1) }>, ptr %block4, i32 0, i32 1
  store i32 4, ptr %block.align6, align 4
  %block.invoke7 = getelementptr inbounds nuw <{ i32, i32, ptr addrspace(4), ptr addrspace(1), i32, ptr addrspace(1) }>, ptr %block4, i32 0, i32 2
  store ptr addrspace(4) addrspacecast (ptr @__device_side_enqueue_block_invoke_2 to ptr addrspace(4)), ptr %block.invoke7, align 4
  %block.captured8 = getelementptr inbounds nuw <{ i32, i32, ptr addrspace(4), ptr addrspace(1), i32, ptr addrspace(1) }>, ptr %block4, i32 0, i32 3
  %12 = load ptr addrspace(1), ptr %a.addr, align 4
  store ptr addrspace(1) %12, ptr %block.captured8, align 4
  %block.captured9 = getelementptr inbounds nuw <{ i32, i32, ptr addrspace(4), ptr addrspace(1), i32, ptr addrspace(1) }>, ptr %block4, i32 0, i32 4
  %13 = load i32, ptr %i.addr, align 4
  store i32 %13, ptr %block.captured9, align 4
  %block.captured10 = getelementptr inbounds nuw <{ i32, i32, ptr addrspace(4), ptr addrspace(1), i32, ptr addrspace(1) }>, ptr %block4, i32 0, i32 5
  %14 = load ptr addrspace(1), ptr %b.addr, align 4
  store ptr addrspace(1) %14, ptr %block.captured10, align 4
  %15 = addrspacecast ptr %block4 to ptr addrspace(4)
  %16 = call spir_func i32 @__enqueue_kernel_basic_events(target("spirv.Queue") %8, i32 %9, ptr %tmp3, i32 2, ptr addrspace(4) %10, ptr addrspace(4) %11, ptr addrspace(4) addrspacecast (ptr @__device_side_enqueue_block_invoke_2_kernel to ptr addrspace(4)), ptr addrspace(4) %15)
  %17 = load target("spirv.Queue"), ptr %default_queue, align 4
  %18 = load i32, ptr %flags, align 4
  call void @llvm.memcpy.p0.p0.i32(ptr align 4 %tmp11, ptr align 4 %ndrange, i32 4, i1 false)
  %arraydecay = getelementptr inbounds [1 x target("spirv.DeviceEvent")], ptr %event_wait_list2, i32 0, i32 0
  %19 = addrspacecast ptr %arraydecay to ptr addrspace(4)
  %20 = addrspacecast ptr %clk_event to ptr addrspace(4)
  %21 = getelementptr [1 x i32], ptr %block_sizes, i32 0, i32 0
  %22 = load i8, ptr %c, align 1
  %23 = zext i8 %22 to i32
  store i32 %23, ptr %21, align 4
  %24 = call spir_func i32 @__enqueue_kernel_events_varargs(target("spirv.Queue") %17, i32 %18, ptr %tmp11, i32 2, ptr addrspace(4) %19, ptr addrspace(4) %20, ptr addrspace(4) addrspacecast (ptr @__device_side_enqueue_block_invoke_3_kernel to ptr addrspace(4)), ptr addrspace(4) addrspacecast (ptr addrspace(1) @__block_literal_global to ptr addrspace(4)), i32 1, ptr %21)
  %25 = load target("spirv.Queue"), ptr %default_queue, align 4
  %26 = load i32, ptr %flags, align 4
  call void @llvm.memcpy.p0.p0.i32(ptr align 4 %tmp12, ptr align 4 %ndrange, i32 4, i1 false)
  %27 = getelementptr [3 x i32], ptr %block_sizes13, i32 0, i32 0
  store i32 1, ptr %27, align 4
  %28 = getelementptr [3 x i32], ptr %block_sizes13, i32 0, i32 1
  store i32 2, ptr %28, align 4
  %29 = getelementptr [3 x i32], ptr %block_sizes13, i32 0, i32 2
  store i32 4, ptr %29, align 4
  %30 = call spir_func i32 @__enqueue_kernel_varargs(target("spirv.Queue") %25, i32 %26, ptr %tmp12, ptr addrspace(4) addrspacecast (ptr @__device_side_enqueue_block_invoke_4_kernel to ptr addrspace(4)), ptr addrspace(4) addrspacecast (ptr addrspace(1) @__block_literal_global.1 to ptr addrspace(4)), i32 3, ptr %27)
  %31 = load target("spirv.Queue"), ptr %default_queue, align 4
  %32 = load i32, ptr %flags, align 4
  call void @llvm.memcpy.p0.p0.i32(ptr align 4 %tmp14, ptr align 4 %ndrange, i32 4, i1 false)
  %33 = addrspacecast ptr %clk_event to ptr addrspace(4)
  %block.size16 = getelementptr inbounds nuw <{ i32, i32, ptr addrspace(4), ptr addrspace(1), i32, ptr addrspace(1) }>, ptr %block15, i32 0, i32 0
  store i32 24, ptr %block.size16, align 4
  %block.align17 = getelementptr inbounds nuw <{ i32, i32, ptr addrspace(4), ptr addrspace(1), i32, ptr addrspace(1) }>, ptr %block15, i32 0, i32 1
  store i32 4, ptr %block.align17, align 4
  %block.invoke18 = getelementptr inbounds nuw <{ i32, i32, ptr addrspace(4), ptr addrspace(1), i32, ptr addrspace(1) }>, ptr %block15, i32 0, i32 2
  store ptr addrspace(4) addrspacecast (ptr @__device_side_enqueue_block_invoke_5 to ptr addrspace(4)), ptr %block.invoke18, align 4
  %block.captured19 = getelementptr inbounds nuw <{ i32, i32, ptr addrspace(4), ptr addrspace(1), i32, ptr addrspace(1) }>, ptr %block15, i32 0, i32 3
  %34 = load ptr addrspace(1), ptr %a.addr, align 4
  store ptr addrspace(1) %34, ptr %block.captured19, align 4
  %block.captured20 = getelementptr inbounds nuw <{ i32, i32, ptr addrspace(4), ptr addrspace(1), i32, ptr addrspace(1) }>, ptr %block15, i32 0, i32 4
  %35 = load i32, ptr %i.addr, align 4
  store i32 %35, ptr %block.captured20, align 4
  %block.captured21 = getelementptr inbounds nuw <{ i32, i32, ptr addrspace(4), ptr addrspace(1), i32, ptr addrspace(1) }>, ptr %block15, i32 0, i32 5
  %36 = load ptr addrspace(1), ptr %b.addr, align 4
  store ptr addrspace(1) %36, ptr %block.captured21, align 4
  %37 = addrspacecast ptr %block15 to ptr addrspace(4)
  %38 = call spir_func i32 @__enqueue_kernel_basic_events(target("spirv.Queue") %31, i32 %32, ptr %tmp14, i32 0, ptr addrspace(4) null, ptr addrspace(4) %33, ptr addrspace(4) addrspacecast (ptr @__device_side_enqueue_block_invoke_5_kernel to ptr addrspace(4)), ptr addrspace(4) %37)
  ret void
}

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i32(ptr noalias nocapture writeonly, ptr noalias nocapture readonly, i32, i1 immarg) #2

; Function Attrs: convergent noinline nounwind optnone
define internal spir_func void @__device_side_enqueue_block_invoke(ptr addrspace(4) noundef %.block_descriptor) #3 {
entry:
  %.block_descriptor.addr = alloca ptr addrspace(4), align 4
  %block.addr = alloca ptr addrspace(4), align 4
  store ptr addrspace(4) %.block_descriptor, ptr %.block_descriptor.addr, align 4
  store ptr addrspace(4) %.block_descriptor, ptr %block.addr, align 4
  %block.capture.addr = getelementptr inbounds nuw <{ i32, i32, ptr addrspace(4), ptr addrspace(1), i32, i8 }>, ptr addrspace(4) %.block_descriptor, i32 0, i32 5
  %0 = load i8, ptr addrspace(4) %block.capture.addr, align 4
  %conv = sext i8 %0 to i32
  %block.capture.addr1 = getelementptr inbounds nuw <{ i32, i32, ptr addrspace(4), ptr addrspace(1), i32, i8 }>, ptr addrspace(4) %.block_descriptor, i32 0, i32 3
  %1 = load ptr addrspace(1), ptr addrspace(4) %block.capture.addr1, align 4
  %block.capture.addr2 = getelementptr inbounds nuw <{ i32, i32, ptr addrspace(4), ptr addrspace(1), i32, i8 }>, ptr addrspace(4) %.block_descriptor, i32 0, i32 4
  %2 = load i32, ptr addrspace(4) %block.capture.addr2, align 4
  %arrayidx = getelementptr inbounds i32, ptr addrspace(1) %1, i32 %2
  store i32 %conv, ptr addrspace(1) %arrayidx, align 4
  ret void
}

; Function Attrs: convergent nounwind
define spir_kernel void @__device_side_enqueue_block_invoke_kernel(ptr addrspace(4) %0) #4 {
entry:
  call spir_func void @__device_side_enqueue_block_invoke(ptr addrspace(4) %0)
  ret void
}

declare spir_func i32 @__enqueue_kernel_basic(target("spirv.Queue"), i32, ptr, ptr addrspace(4), ptr addrspace(4))

; Function Attrs: convergent noinline nounwind optnone
define internal spir_func void @__device_side_enqueue_block_invoke_2(ptr addrspace(4) noundef %.block_descriptor) #3 {
entry:
  %.block_descriptor.addr = alloca ptr addrspace(4), align 4
  %block.addr = alloca ptr addrspace(4), align 4
  store ptr addrspace(4) %.block_descriptor, ptr %.block_descriptor.addr, align 4
  store ptr addrspace(4) %.block_descriptor, ptr %block.addr, align 4
  %block.capture.addr = getelementptr inbounds nuw <{ i32, i32, ptr addrspace(4), ptr addrspace(1), i32, ptr addrspace(1) }>, ptr addrspace(4) %.block_descriptor, i32 0, i32 5
  %0 = load ptr addrspace(1), ptr addrspace(4) %block.capture.addr, align 4
  %block.capture.addr1 = getelementptr inbounds nuw <{ i32, i32, ptr addrspace(4), ptr addrspace(1), i32, ptr addrspace(1) }>, ptr addrspace(4) %.block_descriptor, i32 0, i32 4
  %1 = load i32, ptr addrspace(4) %block.capture.addr1, align 4
  %arrayidx = getelementptr inbounds i32, ptr addrspace(1) %0, i32 %1
  %2 = load i32, ptr addrspace(1) %arrayidx, align 4
  %block.capture.addr2 = getelementptr inbounds nuw <{ i32, i32, ptr addrspace(4), ptr addrspace(1), i32, ptr addrspace(1) }>, ptr addrspace(4) %.block_descriptor, i32 0, i32 3
  %3 = load ptr addrspace(1), ptr addrspace(4) %block.capture.addr2, align 4
  %block.capture.addr3 = getelementptr inbounds nuw <{ i32, i32, ptr addrspace(4), ptr addrspace(1), i32, ptr addrspace(1) }>, ptr addrspace(4) %.block_descriptor, i32 0, i32 4
  %4 = load i32, ptr addrspace(4) %block.capture.addr3, align 4
  %arrayidx4 = getelementptr inbounds i32, ptr addrspace(1) %3, i32 %4
  store i32 %2, ptr addrspace(1) %arrayidx4, align 4
  ret void
}

; Function Attrs: convergent nounwind
define spir_kernel void @__device_side_enqueue_block_invoke_2_kernel(ptr addrspace(4) %0) #4 {
entry:
  call spir_func void @__device_side_enqueue_block_invoke_2(ptr addrspace(4) %0)
  ret void
}

declare spir_func i32 @__enqueue_kernel_basic_events(target("spirv.Queue"), i32, ptr, i32, ptr addrspace(4), ptr addrspace(4), ptr addrspace(4), ptr addrspace(4))

; Function Attrs: convergent noinline nounwind optnone
define internal spir_func void @__device_side_enqueue_block_invoke_3(ptr addrspace(4) noundef %.block_descriptor, ptr addrspace(3) noundef %p) #3 {
entry:
  %.block_descriptor.addr = alloca ptr addrspace(4), align 4
  %p.addr = alloca ptr addrspace(3), align 4
  %block.addr = alloca ptr addrspace(4), align 4
  store ptr addrspace(4) %.block_descriptor, ptr %.block_descriptor.addr, align 4
  store ptr addrspace(3) %p, ptr %p.addr, align 4
  store ptr addrspace(4) %.block_descriptor, ptr %block.addr, align 4
  ret void
}

; Function Attrs: convergent nounwind
define spir_kernel void @__device_side_enqueue_block_invoke_3_kernel(ptr addrspace(4) %0, ptr addrspace(3) %1) #4 {
entry:
  call spir_func void @__device_side_enqueue_block_invoke_3(ptr addrspace(4) %0, ptr addrspace(3) %1)
  ret void
}

declare spir_func i32 @__enqueue_kernel_events_varargs(target("spirv.Queue"), i32, ptr, i32, ptr addrspace(4), ptr addrspace(4), ptr addrspace(4), ptr addrspace(4), i32, ptr)

; Function Attrs: convergent noinline nounwind optnone
define internal spir_func void @__device_side_enqueue_block_invoke_4(ptr addrspace(4) noundef %.block_descriptor, ptr addrspace(3) noundef %p1, ptr addrspace(3) noundef %p2, ptr addrspace(3) noundef %p3) #3 {
entry:
  %.block_descriptor.addr = alloca ptr addrspace(4), align 4
  %p1.addr = alloca ptr addrspace(3), align 4
  %p2.addr = alloca ptr addrspace(3), align 4
  %p3.addr = alloca ptr addrspace(3), align 4
  %block.addr = alloca ptr addrspace(4), align 4
  store ptr addrspace(4) %.block_descriptor, ptr %.block_descriptor.addr, align 4
  store ptr addrspace(3) %p1, ptr %p1.addr, align 4
  store ptr addrspace(3) %p2, ptr %p2.addr, align 4
  store ptr addrspace(3) %p3, ptr %p3.addr, align 4
  store ptr addrspace(4) %.block_descriptor, ptr %block.addr, align 4
  ret void
}

; Function Attrs: convergent nounwind
define spir_kernel void @__device_side_enqueue_block_invoke_4_kernel(ptr addrspace(4) %0, ptr addrspace(3) %1, ptr addrspace(3) %2, ptr addrspace(3) %3) #4 {
entry:
  call spir_func void @__device_side_enqueue_block_invoke_4(ptr addrspace(4) %0, ptr addrspace(3) %1, ptr addrspace(3) %2, ptr addrspace(3) %3)
  ret void
}

declare spir_func i32 @__enqueue_kernel_varargs(target("spirv.Queue"), i32, ptr, ptr addrspace(4), ptr addrspace(4), i32, ptr)

; Function Attrs: convergent noinline nounwind optnone
define internal spir_func void @__device_side_enqueue_block_invoke_5(ptr addrspace(4) noundef %.block_descriptor) #3 {
entry:
  %.block_descriptor.addr = alloca ptr addrspace(4), align 4
  %block.addr = alloca ptr addrspace(4), align 4
  store ptr addrspace(4) %.block_descriptor, ptr %.block_descriptor.addr, align 4
  store ptr addrspace(4) %.block_descriptor, ptr %block.addr, align 4
  %block.capture.addr = getelementptr inbounds nuw <{ i32, i32, ptr addrspace(4), ptr addrspace(1), i32, ptr addrspace(1) }>, ptr addrspace(4) %.block_descriptor, i32 0, i32 5
  %0 = load ptr addrspace(1), ptr addrspace(4) %block.capture.addr, align 4
  %block.capture.addr1 = getelementptr inbounds nuw <{ i32, i32, ptr addrspace(4), ptr addrspace(1), i32, ptr addrspace(1) }>, ptr addrspace(4) %.block_descriptor, i32 0, i32 4
  %1 = load i32, ptr addrspace(4) %block.capture.addr1, align 4
  %arrayidx = getelementptr inbounds i32, ptr addrspace(1) %0, i32 %1
  %2 = load i32, ptr addrspace(1) %arrayidx, align 4
  %block.capture.addr2 = getelementptr inbounds nuw <{ i32, i32, ptr addrspace(4), ptr addrspace(1), i32, ptr addrspace(1) }>, ptr addrspace(4) %.block_descriptor, i32 0, i32 3
  %3 = load ptr addrspace(1), ptr addrspace(4) %block.capture.addr2, align 4
  %block.capture.addr3 = getelementptr inbounds nuw <{ i32, i32, ptr addrspace(4), ptr addrspace(1), i32, ptr addrspace(1) }>, ptr addrspace(4) %.block_descriptor, i32 0, i32 4
  %4 = load i32, ptr addrspace(4) %block.capture.addr3, align 4
  %arrayidx4 = getelementptr inbounds i32, ptr addrspace(1) %3, i32 %4
  store i32 %2, ptr addrspace(1) %arrayidx4, align 4
  ret void
}

; Function Attrs: convergent nounwind
define spir_kernel void @__device_side_enqueue_block_invoke_5_kernel(ptr addrspace(4) %0) #4 {
entry:
  call spir_func void @__device_side_enqueue_block_invoke_5(ptr addrspace(4) %0)
  ret void
}

attributes #0 = { "objc_arc_inert" }
attributes #1 = { convergent noinline norecurse nounwind optnone "no-trapping-math"="true" "stack-protector-buffer-size"="8" "uniform-work-group-size"="false" }
attributes #2 = { nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #3 = { convergent noinline nounwind optnone "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #4 = { convergent nounwind "no-trapping-math"="true" "stack-protector-buffer-size"="8" }

!llvm.module.flags = !{!0}
!opencl.ocl.version = !{!1}
!opencl.spir.version = !{!1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 2, i32 0}
!2 = !{!"clang version 20.0.0git (https:;github.com/llvm/llvm-project.git e8dd95e97bd45c8ee3cc2a3d95c9a6198a970d80)"}
!3 = !{i32 1, i32 1, i32 0, i32 0}
!4 = !{!"none", !"none", !"none", !"none"}
!5 = !{!"int*", !"int*", !"int", !"char"}
!6 = !{!"", !"", !"", !""}


  ; CHECK-SPIRV: Bitcast [[PtrGenTy]] [[BlockLit1:[0-9]+]]
  ; CHECK-SPIRV: EnqueueKernel [[Int32Ty]] {{[0-9]+}} {{[0-9]+}} {{[0-9]+}} {{[0-9]+}}
  ;                            [[ConstInt0]] [[EventNull]] [[EventNull]]
  ;                            [[BlockKer1]] [[BlockLit1]] [[ConstInt17]] [[ConstInt8]]

  ; CHECK-LLVM: [[Block2:%[0-9]+]] = addrspacecast ptr %block to ptr addrspace(4)
  ; CHECK-LLVM: [[Block2Ptr:%[0-9]+]] = bitcast ptr addrspace(4) [[Block2]] to ptr addrspace(4)
  ; CHECK-LLVM: [[BlockInv2:%[0-9]+]] = addrspacecast ptr @__device_side_enqueue_block_invoke_kernel to ptr addrspace(4)
  ; CHECK-LLVM: call spir_func i32 @__enqueue_kernel_basic(ptr {{.*}}, i32 {{.*}}, ptr {{.*}}, ptr addrspace(4) [[BlockInv2]], ptr addrspace(4) [[Block2Ptr]])
  ; CHECK-SPV-IR: call spir_func i32 @_Z21__spirv_EnqueueKernelP13__spirv_Queuei9ndrange_tiPU3AS4P19__spirv_DeviceEventS5_U13block_pointerFvvEPU3AS4cii(target("spirv.Queue") {{.*}}, i32 {{.*}}, ptr {{.*}}, i32 0, ptr addrspace(4) null, ptr addrspace(4) null, ptr @__device_side_enqueue_block_invoke_kernel, ptr addrspace(4) {{.*}}, i32 {{.*}}, i32 {{.*}})
                                    ; _Z21__spirv_EnqueueKernelP13__spirv_Queuei9ndrange_tiPU3AS4cS3_U13block_pointerFvvES3_ii

  ; CHECK-SPIRV: PtrCastToGeneric [[PtrGenTy]] [[Event1:[0-9]+]]
  ; CHECK-SPIRV: PtrCastToGeneric [[PtrGenTy]] [[Event2:[0-9]+]]

  ; CHECK-SPIRV: Bitcast [[PtrGenTy]] [[BlockLit2:[0-9]+]]
  ; CHECK-SPIRV: EnqueueKernel [[Int32Ty]] {{[0-9]+}} {{[0-9]+}} {{[0-9]+}} {{[0-9]+}}
  ;                            [[ConstInt2]] [[Event1]] [[Event2]]
  ;                            [[BlockKer2]] [[BlockLit2]] [[ConstInt20]] [[ConstInt8]]

  ; CHECK-LLVM: [[Block3:%[0-9]+]] = addrspacecast ptr %block4 to ptr addrspace(4)
  ; CHECK-LLVM: [[Block3Ptr:%[0-9]+]] = bitcast ptr addrspace(4) [[Block3]] to ptr addrspace(4)
  ; CHECK-LLVM: [[BlockInv3:%[0-9]+]] = addrspacecast ptr @__device_side_enqueue_block_invoke_2_kernel to ptr addrspace(4)
  ; CHECK-LLVM: call spir_func i32 @__enqueue_kernel_basic_events(ptr {{.*}}, i32 {{.*}}, ptr {{.*}}, i32 2, ptr addrspace(4) {{.*}}, ptr addrspace(4) {{.*}}, ptr addrspace(4) [[BlockInv3]], ptr addrspace(4) [[Block3Ptr]])
  ; CHECK-SPV-IR: call spir_func i32 @_Z21__spirv_EnqueueKernelP13__spirv_Queuei9ndrange_tiPU3AS4P19__spirv_DeviceEventS5_U13block_pointerFvvEPU3AS4cii(target("spirv.Queue") {{.*}}, i32 {{.*}}, ptr {{.*}}, i32 2, ptr addrspace(4) {{.*}}, ptr addrspace(4) {{.*}}, ptr @__device_side_enqueue_block_invoke_2_kernel, ptr addrspace(4) %{{.*}}, i32 {{.*}}, i32 {{.*}})


  ; CHECK-SPIRV: UntypedPtrAccessChainKHR [[Int32LocPtrTy]] [[LocalBuf31:[0-9]+]]
  ; CHECK-SPIRV: PtrCastToGeneric {{[0-9]+}} [[BlockLit3Tmp:[0-9]+]] [[BlockGlb1:[0-9]+]]
  ; CHECK-SPIRV: Bitcast [[PtrGenTy]] [[BlockLit3:[0-9]+]] [[BlockLit3Tmp]]
  ; CHECK-SPIRV: EnqueueKernel [[Int32Ty]] {{[0-9]+}} {{[0-9]+}} {{[0-9]+}} {{[0-9]+}}
  ;                            [[ConstInt2]] [[Event1]] [[Event2]]
  ;                            [[BlockKer3]] [[BlockLit3]] [[ConstInt8]] [[ConstInt8]]
  ;                            [[LocalBuf31]]

  ; CHECK-LLVM: [[Block0Tmp:%[0-9]+]] = addrspacecast ptr addrspace(1) @__block_literal_global to ptr addrspace(4)
  ; CHECK-LLVM: [[Block0:%[0-9]+]] = bitcast ptr addrspace(4) [[Block0Tmp]] to ptr addrspace(4)
  ; CHECK-LLVM: [[BlockInv0:%[0-9]+]] = addrspacecast ptr @__device_side_enqueue_block_invoke_3_kernel to ptr addrspace(4)
  ; CHECK-LLVM: call spir_func i32 @__enqueue_kernel_events_varargs(ptr {{.*}}, i32 {{.*}}, ptr {{.*}}, i32 2, ptr addrspace(4) {{.*}}, ptr addrspace(4) {{.*}}, ptr addrspace(4) [[BlockInv0]], ptr addrspace(4) [[Block0]], i32 1, ptr {{.*}})
  ; CHECK-SPV-IR: call spir_func i32 @_Z21__spirv_EnqueueKernelP13__spirv_Queuei9ndrange_tiPU3AS4P19__spirv_DeviceEventS5_U13block_pointerFvvEPU3AS4ciiPi(target("spirv.Queue") {{.*}}, i32 {{.*}}, ptr {{.*}}, i32 2, ptr addrspace(4) {{.*}}, ptr addrspace(4) {{.*}}, ptr @__device_side_enqueue_block_invoke_3_kernel, ptr addrspace(4) {{.*}}, i32 {{.*}}, i32 {{.*}}, ptr {{.*}})


  ; CHECK-SPIRV: UntypedPtrAccessChainKHR [[Int32LocPtrTy]] [[LocalBuf41:[0-9]+]]
  ; CHECK-SPIRV: UntypedPtrAccessChainKHR [[Int32LocPtrTy]] [[LocalBuf42:[0-9]+]]
  ; CHECK-SPIRV: UntypedPtrAccessChainKHR [[Int32LocPtrTy]] [[LocalBuf43:[0-9]+]]
  ; CHECK-SPIRV: PtrCastToGeneric {{[0-9]+}} [[BlockLit4Tmp:[0-9]+]] [[BlockGlb2:[0-9]+]]
  ; CHECK-SPIRV: Bitcast [[PtrGenTy]] [[BlockLit4:[0-9]+]] [[BlockLit4Tmp]]
  ; CHECK-SPIRV: EnqueueKernel [[Int32Ty]] {{[0-9]+}} {{[0-9]+}} {{[0-9]+}} {{[0-9]+}}


  ; CHECK-LLVM: [[Block1Tmp:%[0-9]+]] = addrspacecast ptr addrspace(1) @__block_literal_global.1 to ptr addrspace(4)
  ; CHECK-LLVM: [[Block1:%[0-9]+]] = bitcast ptr addrspace(4) [[Block1Tmp]] to ptr addrspace(4)
  ; CHECK-LLVM: [[BlockInv1:%[0-9]+]] = addrspacecast ptr @__device_side_enqueue_block_invoke_4_kernel to ptr addrspace(4)
  ; CHECK-LLVM: call spir_func i32 @__enqueue_kernel_varargs(ptr {{.*}}, i32 {{.*}}, ptr {{.*}}, ptr addrspace(4) [[BlockInv1]], ptr addrspace(4) [[Block1]], i32 3, ptr {{.*}})
  ; CHECK-SPV-IR: call spir_func i32 @_Z21__spirv_EnqueueKernelP13__spirv_Queuei9ndrange_tiPU3AS4P19__spirv_DeviceEventS5_U13block_pointerFvvEPU3AS4ciiPiSA_SA_(target("spirv.Queue") {{.*}}, i32 {{.*}}, ptr {{.*}}, i32 0, ptr addrspace(4) null, ptr addrspace(4) null, ptr @__device_side_enqueue_block_invoke_4_kernel, ptr addrspace(4) {{.*}}, i32 {{.*}}, i32 {{.*}}, ptr {{.*}}, ptr {{.*}}, ptr {{.*}})

  ; CHECK-SPIRV: PtrCastToGeneric [[PtrGenTy]] [[Event1:[0-9]+]]

  ; CHECK-SPIRV: Bitcast [[PtrGenTy]] [[BlockLit2:[0-9]+]]
  ; CHECK-SPIRV: EnqueueKernel [[Int32Ty]] {{[0-9]+}} {{[0-9]+}} {{[0-9]+}} {{[0-9]+}}

  ; CHECK-LLVM: [[Block5:%[0-9]+]] = addrspacecast ptr %block15 to ptr addrspace(4)
  ; CHECK-LLVM: [[Block5Ptr:%[0-9]+]] = bitcast ptr addrspace(4) [[Block5]] to ptr addrspace(4)
  ; CHECK-LLVM: [[BlockInv5:%[0-9]+]] = addrspacecast ptr @__device_side_enqueue_block_invoke_5_kernel to ptr addrspace(4)
  ; CHECK-LLVM: call spir_func i32 @__enqueue_kernel_basic_events(ptr {{.*}}, i32 {{.*}}, ptr {{.*}}, i32 0, ptr addrspace(4) null, ptr addrspace(4) {{.*}}, ptr addrspace(4) [[BlockInv5]], ptr addrspace(4) [[Block5Ptr]])
  ; CHECK-SPV-IR: call spir_func i32 @_Z21__spirv_EnqueueKernelP13__spirv_Queuei9ndrange_tiPU3AS4P19__spirv_DeviceEventS5_U13block_pointerFvvEPU3AS4cii(target("spirv.Queue") {{.*}}, i32 {{.*}}, ptr {{.*}}, i32 0, ptr addrspace(4) null, ptr addrspace(4) {{.*}}, ptr @__device_side_enqueue_block_invoke_5_kernel, ptr addrspace(4) {{.*}}, i32 {{.*}}, i32 {{.*}})

; CHECK-SPIRV-DAG: Function [[VoidTy]] [[BlockKer1]] 0 [[BlockTy1]]
; CHECK-SPIRV-DAG: Function [[VoidTy]] [[BlockKer2]] 0 [[BlockTy1]]
; CHECK-SPIRV-DAG: Function [[VoidTy]] [[BlockKer3]] 0 [[BlockTy2]]
; CHECK-SPIRV-DAG: Function [[VoidTy]] [[BlockKer4]] 0 [[BlockTy3]]
; CHECK-SPIRV-DAG: Function [[VoidTy]] [[BlockKer5]] 0 [[BlockTy1]]

; CHECK-LLVM-DAG: define spir_kernel void @__device_side_enqueue_block_invoke_kernel(ptr addrspace(4){{.*}})
; CHECK-LLVM-DAG: define spir_kernel void @__device_side_enqueue_block_invoke_2_kernel(ptr addrspace(4){{.*}})
; CHECK-LLVM-DAG: define spir_kernel void @__device_side_enqueue_block_invoke_3_kernel(ptr addrspace(4){{.*}}, ptr addrspace(3){{.*}})
; CHECK-LLVM-DAG: define spir_kernel void @__device_side_enqueue_block_invoke_4_kernel(ptr addrspace(4){{.*}}, ptr addrspace(3){{.*}}, ptr addrspace(3){{.*}}, ptr addrspace(3){{.*}})
; CHECK-LLVM-DAG: define spir_kernel void @__device_side_enqueue_block_invoke_5_kernel(ptr addrspace(4){{.*}})

