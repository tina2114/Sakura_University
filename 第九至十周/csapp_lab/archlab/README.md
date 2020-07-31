### 前言

X86-64是一种标准的CISC，而Y86-64既有CISC指令集的属性，也有RISC指令集的属性。Y86-64可以看成是采用CISC指令集(x86)，但又根据某些RISC的原理进行了简化。

X86-64代码是由GCC编译器产生的。Y86-64代码与之类似，但有以下不同点：

+ Y86-64在算术指令中不能使用立即数，所以其将常数加载到寄存器中
+ 要实现从内存读取一个数值并将其与一个寄存器相加，Y86-64代码需要两条指令，X86-64只需要一条add指令
+ Y86-64代码必须用andq指令在进入循环之前设置条件码

### Part A

要求将c源码翻译成Y86-64

```c
typedef struct ELE {

  long val;

  struct ELE *next;

} *list_ptr;
```

下面三题都遵循着此处的链表结构

#### 第一题

原c函数源码，可以看出是一个简单的链表数值累加。

```c
long sum_list(list_ptr ls)
{
    long val = 0;
    while (ls) {
	val += ls->val;
	ls = ls->next;
    }
    return val;
}
```

编写sum.ys，使用`make sum.yo`或`./yas sum.ys`进行编译，使用`./yis sum.yo`查看模拟器运行结果

```
#   Execution begins at address 0
        .pos 0                      #告诉汇编器应该从地址0开始生产代码
        irmovq stack, %rsp          #初始化栈指针
        call main                   #调用main
        halt                        #终止程序
#   Sample linked list
        .align 8
    ele1:
        .quad 0x00a                 #quad = quard word
        .quad ele2
    ele2:
        .quad 0x0b0
        .quad ele3
    ele3:
        .quad 0xc00
        .quad 0
main:
    irmoveq ele1,%rdi               #传参数值
    call sumlist
    ret

sumlist:
        xorq    %rax,%rax           # 设置 sum 初值为 0，long val = 0
        andq    %rdi,%rdi           # 判断ls(链表指针是否为0)
        je      end                 # ls=0直接返回
loop:
        mrmoveq (%rdi),%rcx         # 循环:保存 ls->val值
        addq    %rcx,%rax           # 给sum累加值(val += ls->val)
        irmoveq $8,%rbx             # 保存8
        addq    %rbx,%rdi           # 链表指针+8，也就是ls->next
        mrmoveq (%rdi),%rdi         # ls=ls->next
        andq    %rdi,%rdi           # 判断ls(链表指针是否为0)
        jne     loop                # ls != 0时循环
end:
        ret                         # 返回


#   stack starts here and grows to lower address
.pos 0x200 #此处说明了栈会从这个地址开始，向低地址增长
stack:
```

运行结果

```
Stopped in 31 steps at PC = 0x13.  Status 'HLT', CC Z=1 S=0 O=0
Changes to registers:
%rax:	0x0000000000000000	0x0000000000000cba
%rcx:	0x0000000000000000	0x0000000000000c00
%rbx:	0x0000000000000000	0x0000000000000008
%rsp:	0x0000000000000000	0x0000000000000200

Changes to memory:
0x01f0:	0x0000000000000000	0x000000000000005b
0x01f8:	0x0000000000000000	0x0000000000000013
```

模拟输出的第一行总结了执行以及PC和程序状态的结果值。模拟器打印出的值，左边是原始值(此处全为0)，右边是最终的值。从此处可以看到寄存器%rax的值为0xcba，也就是链表数值之合。

#### 第二题

原c函数源码，可以看出是递归实现的链表数值累加。

```c
long rsum_list(list_ptr ls)
{
    if (!ls)
	return 0;
    else {
	long val = ls->val;
	long rest = rsum_list(ls->next);
	return val + rest;
    }
}
```

编写rsum.ys

```
rsumlist:
        pushq   %rcx            # 调用者保存的寄存器
        andq    %rdi,%rdi       # 判断条件
        je      end
        mrmoveq (%rdi),%rcx     # ls->val
        irmoveq $8,%rbx         
        addq    %rbx,%rdi       # ls->next
        mrmoveq (%rdi),%rdi     # ls = ls->next
        call    rsumlist
        addq    %rcx,%rax       # return val+rest
end:
        popq    %rcx
        ret
```

#### 第三题

实现一个将源数组（src）复制到目标数组（dest）的函数，并计算原数组中所有项的异或（Xor）值

```c
long copy_block(long *src, long *dest, long len)
{
    long result = 0;
    while (len > 0) {
	long val = *src++;
	*dest++ = val;
	result ^= val;
	len--;
    }
    return result;
}
```

编写copy_block.ys

```
#   Execution begins at address 0
        .pos 0                      #告诉汇编器应该从地址0开始生产代码
        irmovq stack, %rsp          #初始化栈指针
        call main                   #调用main
        halt                        #终止程序
#   Sample linked list
        .align 8
    ele1:
        .quad 0x00a                 #quad = quard word
        .quad ele2
    ele2:
        .quad 0x0b0
        .quad ele3
    ele3:
        .quad 0xc00
        .quad 0
main:
    irmoveq src,%rdi               #传参数
    irmoveq dest,%rsi              #传参数
    irmoveq $3,%rdx                #传参数 
    call copyblock
    ret

copyblock:
        xorq    %rax,%rax           # 设置 sum 初值为 0，long val = 0
loop:
        addq    %rdx,%rdx           # linked
        jle     end                 # 判断len是否>0
        mrmoveq (%rdi),%rcx         # long val = *src
        irmoveq $8,%rbx             # 保存8
        addq    %rbx,%rdi           # src++
        rmmoveq %rcx,(%rsi)         # *dest = val
        addq    %rbx,%rsi           # dest++
        xorq    %rcx,%rax           # result ^= val
        irmoveq $1,%rbx             
        subq    %rbx,%rdx           # len--
        jmp     loop                
end:
        ret                         # 返回


#   stack starts here and grows to lower address
.pos 0x200 #此处说明了栈会从这个地址开始，向低地址增长
stack:
```

### Part B

这里用到了SEQ处理器，处理器各阶段的简略描述：

+ **取指**(fetch)：取指阶段从内存读取指令字节，地址为程序计数器的值。从指令中抽取出指令指示符字节的两个四位部分，称为指令代码(icode)和指令功能(ifun)。它按顺序方式计算当前指令的下一条指令的地址valP。也就是说，valP等于PC的值加上已取出指令的长度
+ **译码**(decode)：从寄存器文件读入最多两个操作数，得到valA 和/或 valB。通常，它读入指令rA和rB字段指明的寄存器，但是也有指令是读寄存器%rsp
+ **执行**(execute)：计算内存引用的有效地址，减少或增加栈指针，设置条件码
+ **访存**(memory)：将数据写入内存或从内存读取数据
+ **写回**(write back)：最多写两个结果到寄存器文件
+ **更新PC**(PC update)：将PC设置成下一条指令的地址



iaddq指令的描述

| **state** |       **do**       |
| :-------: | :----------------: |
|   fetch   | icode:ifun<-M1[PC] |
|           |  rA,rB<-M1[PC+1]   |
|           |   valC<-M1[PC+2]   |
|           |    ValP<-PC+10     |
|  decode   |    valB<-R[rB]     |
|  execute  |  ValE<-ValB+ValC   |
|  memory   |                    |
| writeback |    R[rB]<-ValE     |
|           |      PC<-valP      |

修改seq-full.hcl文件，添加iaddq指令，照着改，存在OPQ的地方加一个IIADDQ(此处学的不是很懂，有机会返工)，参与运算的值不是valA而是valC

```
# 取指
# 指令是否有效
bool instr_valid = icode in 
	{ INOP, IHALT, IRRMOVQ, IIRMOVQ, IRMMOVQ, IMRMOVQ,
	       IOPQ, IJXX, ICALL, IRET, IPUSHQ, IPOPQ, IIADDQ};

# Does fetched instruction require a regid byte?
bool need_regids =
	icode in { IRRMOVQ, IOPQ, IPUSHQ, IPOPQ, 
		     IIRMOVQ, IRMMOVQ, IMRMOVQ, IIADDQ};

# Does fetched instruction require a constant word?
bool need_valC =
	icode in { IIRMOVQ, IRMMOVQ, IMRMOVQ, IJXX, ICALL, IIADDQ};

################ Decode Stage    ###################################

# 译码和写回，指定读入和写入
## What register should be used as the A source?
word srcA = [
	icode in { IRRMOVQ, IRMMOVQ, IOPQ, IPUSHQ  } : rA;
	icode in { IPOPQ, IRET } : RRSP;
	1 : RNONE; # Don't need register
];

## What register should be used as the B source?
word srcB = [
	icode in { IOPQ, IRMMOVQ, IMRMOVQ, IIADDQ } : rB;
	icode in { IPUSHQ, IPOPQ, ICALL, IRET } : RRSP;
	1 : RNONE;  # Don't need register
];

## What register should be used as the E destination?
word dstE = [
	icode in { IRRMOVQ } && Cnd : rB;
	icode in { IIRMOVQ, IOPQ, IIADDQ} : rB;
	icode in { IPUSHQ, IPOPQ, ICALL, IRET } : RRSP;
	1 : RNONE;  # Don't write any register
];

## What register should be used as the M destination?
word dstM = [
	icode in { IMRMOVQ, IPOPQ } : rA;
	1 : RNONE;  # Don't write any register
];

################ Execute Stage   ###################################
# 执行
## Select input A to ALU
word aluA = [
	icode in { IRRMOVQ, IOPQ } : valA;
	icode in { IIRMOVQ, IRMMOVQ, IMRMOVQ, IIADDQ} : valC;
	icode in { ICALL, IPUSHQ } : -8;
	icode in { IRET, IPOPQ } : 8;
	# Other instructions don't need ALU
];

## Select input B to ALU
word aluB = [
	icode in { IRMMOVQ, IMRMOVQ, IOPQ, ICALL, 
		      IPUSHQ, IRET, IPOPQ, IIADDQ} : valB;
	icode in { IRRMOVQ, IIRMOVQ } : 0;
	# Other instructions don't need ALU
];

## Set the ALU function
word alufun = [
	icode == IOPQ : ifun;
	1 : ALUADD;
];

## Should the condition codes be updated?
bool set_cc = icode in { IOPQ, IIADDQ};
```

### Part3

程序优化，做不到......

等后续有机会返工吧