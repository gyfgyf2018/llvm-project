; RUN: llc -mtriple=i686-- -verify-machineinstrs < %s | FileCheck %s

; A test for asm-goto output

; CHECK-LABEL: test1:
; CHECK:       movl 4(%esp), %eax
; CHECK-NEXT:  addl $4, %eax
; CHECK-NEXT:  #APP
; CHECK-NEXT:  xorl %eax, %eax
; CHECK-NEXT:  jmp .Ltmp0
; CHECK-NEXT:  #NO_APP
; CHECK-NEXT:  .LBB0_1:
; CHECK-NEXT:  retl
; CHECK-NEXT:  .Ltmp0:
define i32 @test1(i32 %x) {
entry:
  %add = add nsw i32 %x, 4
  %ret = callbr i32 asm "xorl $1, $0; jmp ${2:l}", "=r,r,X,~{dirflag},~{fpsr},~{flags}"(i32 %add, i8* blockaddress(@test1, %abnormal))
          to label %normal [label %abnormal]

normal:
  ret i32 %ret

abnormal:
  ret i32 1
}

; CHECK-LABEL: test2:
; CHECK:       # %bb.1: # %if.then
; CHECK-NEXT:      #APP
; CHECK-NEXT:      testl %esi, %esi
; CHECK-NEXT:      testl %edi, %esi
; CHECK-NEXT:      jne .Ltmp1
; CHECK-NEXT:      #NO_APP
; CHECK-NEXT:  .LBB1_2:
; CHECK-NEXT:      jmp .LBB1_4
; CHECK-NEXT:  .LBB1_3: # %if.else
; CHECK-NEXT:      #APP
; CHECK-NEXT:      testl %esi, %edi
; CHECK-NEXT:      testl %esi, %edi
; CHECK-NEXT:      jne .Ltmp2
; CHECK-NEXT:      #NO_APP
; CHECK-NEXT:  .LBB1_4:
; CHECK-NEXT:      movl %esi, %eax
; CHECK-NEXT:      addl %edi, %eax
; CHECK-NEXT:      jmp .LBB1_6
; CHECK-NEXT:  .Ltmp1:
; CHECK-NEXT:  .LBB1_5: # %label_true
; CHECK-NEXT:      movl $-2, %eax
; CHECK-NEXT:  .Ltmp2:
; CHECK-NEXT:  .LBB1_6: # %return
define i32 @test2(i32 %out1, i32 %out2) {
entry:
  %cmp = icmp slt i32 %out1, %out2
  br i1 %cmp, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  %0 = callbr { i32, i32 } asm sideeffect "testl $0, $0; testl $1, $2; jne ${5:l}", "={si},={di},r,0,1,X,X,~{dirflag},~{fpsr},~{flags}"(i32 %out1, i32 %out1, i32 %out2, i8* blockaddress(@test2, %label_true), i8* blockaddress(@test2, %return))
          to label %if.end [label %label_true, label %return]

if.else:                                          ; preds = %entry
  %1 = callbr { i32, i32 } asm sideeffect "testl $0, $1; testl $2, $3; jne ${7:l}", "={si},={di},r,r,0,1,X,X,~{dirflag},~{fpsr},~{flags}"(i32 %out1, i32 %out2, i32 %out1, i32 %out2, i8* blockaddress(@test2, %label_true), i8* blockaddress(@test2, %return))
          to label %if.end [label %label_true, label %return]

if.end:                                           ; preds = %if.else, %if.then
  %.sink11 = phi { i32, i32 } [ %0, %if.then ], [ %1, %if.else ]
  %asmresult3 = extractvalue { i32, i32 } %.sink11, 0
  %asmresult4 = extractvalue { i32, i32 } %.sink11, 1
  %add = add nsw i32 %asmresult4, %asmresult3
  br label %return

label_true:                                       ; preds = %if.else, %if.then
  br label %return

return:                                           ; preds = %if.then, %if.else, %label_true, %if.end
  %retval.0 = phi i32 [ %add, %if.end ], [ -2, %label_true ], [ -1, %if.else ], [ -1, %if.then ]
  ret i32 %retval.0
}

; CHECK-LABEL: test3:
; CHECK:       # %bb.1:                                # %true
; CHECK-NEXT:      #APP
; CHECK-NEXT:      .short %esi
; CHECK-NEXT:      .short %edi
; CHECK-NEXT:      #NO_APP
; CHECK-NEXT:  .LBB2_2:
; CHECK-NEXT:      movl %edi, %eax
; CHECK-NEXT:      jmp .LBB2_5
; CHECK-NEXT:  .LBB2_3:                                # %false
; CHECK-NEXT:      #APP
; CHECK-NEXT:      .short %eax
; CHECK-NEXT:      .short %edx
; CHECK-NEXT:      #NO_APP
; CHECK-NEXT:  .LBB2_4:
; CHECK-NEXT:      movl %edx, %eax
; CHECK-NEXT:      jmp .LBB2_5
; CHECK-NEXT:  .Ltmp3:                                 # Block address taken
; CHECK-NEXT:  .LBB2_6:                                # %indirect
; CHECK-NEXT:      movl $42, %eax
; CHECK-NEXT:  .LBB2_5:                                # %asm.fallthrough
define i32 @test3(i1 %cmp) {
entry:
  br i1 %cmp, label %true, label %false

true:
  %0 = callbr { i32, i32 } asm sideeffect ".word $0, $1", "={si},={di},X" (i8* blockaddress(@test3, %indirect)) to label %asm.fallthrough [label %indirect]

false:
  %1 = callbr { i32, i32 } asm sideeffect ".word $0, $1", "={ax},={dx},X" (i8* blockaddress(@test3, %indirect)) to label %asm.fallthrough [label %indirect]

asm.fallthrough:
  %vals = phi { i32, i32 } [ %0, %true ], [ %1, %false ]
  %v = extractvalue { i32, i32 } %vals, 1
  ret i32 %v

indirect:
  ret i32 42
}
