## 练习一

### 问题

+ 操作系统镜像文件ucore.img是如何一步一步生成的？(需要比较详细地解释Makefile中每一条相关命令和命令参数的含义，以及说明命令导致的结果)
+ 一个被系统认为是符合规范的硬盘主引导扇区的特征是什么？



### 问题一的解答

#### 设置环境变量

第1行至第146行大部分是变量环境和编译选项的设置，不过特别的需要关注第125行`$(call add_files_cc,$(call listf_cc,$(LIBDIR)),libs,)`和第144行`$(call add_files_cc,$(call listf_cc,$(KSRCDIR)),kernel,$(KCFLAGS))`



1. 第125行的`$(call add_files_cc,$(call listf_cc,$(LIBDIR)),libs,)`设置了libs文件下obj文件名，可以看出调用了`add_files_cc`函数，有两个输入参数`listf_cc(LIBDIR)`和`libs`（目录名）

   以下是一些基本的溯源，方便查看

   ```makefile
   $(call add_files_cc,$(call listf_cc,$(LIBDIR)),libs,)
   add_files_cc = $(call add_files,$(1),$(CC),$(CFLAGS) $(3),$(2),$(4))
   
   add_files = $(eval $(call do_add_files_to_packet,$(1),$(2),$(3),$(4),$(5)))#do_add_files_to_packet的作用是生成obj文件
   
   listf_cc = $(call listf,$(1),$(CTYPE)) #*$(1)目录下，满足`%.c %.S`的文件,因为lab1中的libs文件中只存在.c文件和.h文件，最终返回的就是.c文件
   
   listf = $(filter $(if $(2),$(addprefix %.,$(2)),%),\
   		$(wildcard $(addsuffix $(SLASH)*,$(1)))) ## `wildcard`找到满足pattern的所有文件列表。
   ```

2. `add_files_cc`函数溯源后，代换变量，化简得到的结果是`add_files(libs/*.c, gcc, $(CFLAGS), libs)`

3. 同样对`add_files`溯源，此时`add_files`在tools/function.mk中，得到最后的结果是`__objs_libs = obj/libs/**/*.o`

同理，第144行的`$(call add_files_cc,$(call listf_cc,$(KSRCDIR)),kernel,$(KCFLAGS))`函数经过溯源化简后的结果是`__objs_kernel = obj/kern/**/*.o`

#### 生成kernel文件

1. 设置kernel目标名为bin/kernel

   ```makefile
   kernel = $(call totarget,kernel)
   totarget = $(addprefix $(BINDIR)$(SLASH),$(1)) #给输入参数增加前缀"bin/"
   $(addprefix fixstring,string1 string2 ...)#addprefix用于添加前缀
   BINDIR	:= bin
   SLASH	:= /
   ```

2. kernel目标文件需要依赖tools/kernel.ld

   ```makefile
   $(kernel): tools/kernel.ld
   ```

3. kernel目标文件需要依赖的obj文件，`KOBJS=obj/libs/*.o obj/kern/**/*.o`

   ```makefile
   $(kernel): $(KOBJS)
   KOBJS   = $(call read_packet,kernel libs)
   read_packet = $(foreach p,$(call packetname,$(1)),$($(p)))
   packetname = $(if $(1),$(addprefix $(OBJPREFIX),$(1)),$(OBJPREFIX))
   OBJPREFIX	:= __objs_
   ```

4. 打印kernel目标文件名，输出+ ld bin/kernel

   ```makefile
   @echo + ld $@
   ```

5. 链接所有生成的obj文件得到kernel文件

   ```makefile
   $(V)$(LD) $(LDFLAGS) -T tools/kernel.ld -o $@ $(KOBJS)
   V       := @
   LD      := $(GCCPREFIX)ld
   #GCCPREFIX = i386-elf- or ''
   #LDFLAGS := -m elf_i386
   ```

6. 对kernel目标文件反汇编，等于objdump -S bin/kernel > obj/kernel.asm，-S选项是交替显示将C源码和汇编代码。

   ```makefile
   @$(OBJDUMP) -S $@ > $(call asmfile,kernel)
   ```

7. 解析kernel文件，得到符号表，等于 objdump -t bin/kernel > obj/kernel.sym

   ```makefile
   @$(OBJDUMP) -t $@ | $(SED) '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > $(call symfile,kernel)
   ```

8. 老实说，没看懂

   ```makefile
   $(call create_target,kernel)
   create_target = $(eval $(call do_create_target,$(1),$(2),$(3),$(4),$(5)))
   ```

#### 生成bootblock

1. 结果为bootfiles=boot/\*.c boot/\*.S

   ```makefile
   bootfiles = $(call listf_cc,boot)
   ```

2. 编译bootfiles生成.o文件

   ```makefile
   $(foreach f,$(bootfiles),$(call cc_compile,$(f),$(CC),$(CFLAGS) -Os -nostdinc))
   ```

3. 结果为bootblock="bin/bootblock"

   ```makefile
   bootblock = $(call totarget,bootblock) #totarget为加上前缀bin/
   ```

4. bin/bootblock依赖于obj/boot/*.o 和bin/sign文件

   ```makefile
   $(bootblock): $(call toobj,$(bootfiles)) | $(call totarget,sign)
   
   toobj = $(addprefix $(OBJDIR)$(SLASH)$(if $(2),$(2)$(SLASH)),\
   		$(addsuffix .o,$(basename $(1)))) #加上前缀obj/并将后缀改为.o
   ```

5. 链接所有.o文件以生成obj/bootblock.o

   ```makefile
   $(V)$(LD) $(LDFLAGS) -N -e start -Ttext 0x7C00 $^ -o $(call toobj,bootblock)
   ```

6. 反汇编.o得到.asm，用objcopy将.o转换成.out，使用bin/sign工具将obj/bootblock.out转换生成bin/bootblock目标文件并利用sign工具将输入文件拷贝到输出文件，控制输出文件的大小为512字节，并将最后两个字节设置为0x55AA

   ```makefile
   	@$(OBJDUMP) -S $(call objfile,bootblock) > $(call asmfile,bootblock)
   	@$(OBJCOPY) -S -O binary $(call objfile,bootblock) $(call outfile,bootblock) #-S表示转换时去掉重定位和符号信息
   	@$(call totarget,sign) $(call outfile,bootblock) $(bootblock)
   ```

7. 还是没看懂

   ```makefile
   $(call create_target,bootblock)
   ```

#### 生成sign工具

1. 生成.o文件

   ```makefile
   $(call add_files_host,tools/sign.c,sign,sign)
   
   add_files_host = $(call add_files,$(1),$(HOSTCC),$(HOSTCFLAGS),$(2),$(3))
   HOSTCC		:= gcc
   HOSTCFLAGS	:= -g -Wall -O2
   
   add_files = $(eval $(call do_add_files_to_packet,$(1),$(2),$(3),$(4),$(5)))
   #\_\_objs\_sign = obj/sign/tools/sign.o
   ```

2. 生成obj/sign/tools/sign.o

   ```makefile
   $(call create_target_host,sign,sign)
   
   create_target_host = $(call create_target,$(1),$(2),$(3),$(HOSTCC),$(HOSTCFLAGS))
   
   create_target = $(eval $(call do_create_target,$(1),$(2),$(3),$(4),$(5)))
   ```

#### 生成ucore.img

1. UCOREIMG = bin/ucore.img

   ```makefile
   UCOREIMG	:= $(call totarget,ucore.img)
   ```

2. bin/ucore.img依赖于bin/kernel和bin/bootblock

   ```makefile
   $(UCOREIMG): $(kernel) $(bootblock)
   ```

3. 为bin/ucore.img分配10000个block的内存空间，并全初始化为0. block大小默认为512字节，总大小为5G

   ```makefile
   $(V)dd if=/dev/zero of=$@ count=10000
   ```

4. bin/bootblock复制到bin/ucore.img

   ```makefile
   $(V)dd if=$(bootblock) of=$@ conv=notrunc
   ```

5. bin/kernel复制到bin/ucore.img

   ```makefile
   $(V)dd if=$(kernel) of=$@ seek=1 conv=notrunc
   ```

6. 没懂

   ```makefile
   $(call create_target,ucore.img)
   ```

#### 总结

+ 编译libs和kern下所有的.S和.c文件，得到.o文件，链接所有.o文件，得到bin/kernel文件
+ 编译boot下所有.S和.c文件，得到.o文件，链接所有.o文件，得到bin/bootblock.out文件
+ 编译生成sign文件
+ 使用bin/sign工具将obj/bootblock.out转换生成512字节的bin/bootblock目标文件，并将bin/bootblock的最后两个字节设置为0x55AA
+ 为bin/ucore.img分配5G空间，将bin/bootblock复制到ucore.img第一个block，将bin.kernel复制到ucore.img第二个block

### 问题二

一个被系统认为是符合规范的硬盘主引导扇区的特征是什么？

+ 大小为512字节
+ 最后以0x55AA结尾

## 练习二

### 踩了一个深坑

在你安装了pwndbg的情况下，gdb+qemu启动是会出现问题的，gdb会自启pwndbg，然后就导致如下局面，乱码+你的gdb出不来

![img](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/]J}`7T3RSY1{3CY_%W~LHC7.png)

个人的解决办法是在找到你的pwndbg文件夹（我的文件夹位置就在~/pwndbg），把里面的gdbinit.py给剪切到外面去，这样就会因为找不到，转而启动gdb了。结果如下图

![image-20200805004654537](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200805004654537.png)

### 练习正题

1. 从CPU加电后执行的第一条指令开始，单步跟踪BIOS的执行。
2. 在初始化位置0x7c00设置实地址断点,测试断点正常。
3. 从0x7c00开始跟踪代码运行,将单步跟踪反汇编得到的代码与bootasm.S和 bootblock.asm进行比较。
4. 自己找一个bootloader或内核中的代码位置，设置断点并进行测试。

前情提要：

lab1/tools/gdbinit文件实际上有两个版本，实验楼里的是

```
file bin/kernel
target remote :1234
break kern_init
continue
```

此版本相当于b *0x100000，不符合实验要求

在github上clone下来的版本是

```
file bin/kernel
target remote :1234
set architecture i8086
b *0x7c00
continue
x /2i $pc
# break kern_init
# continue
```

所以此处练习，实验楼版本的需要对gdbinit进行一下修改，改成github版本。

此时make debug，第一步，第二步练习就完成了。

#### 第三小题

因为本人有点懒，也不大会改makefile，就直接用笨办法，在gdb里来查看汇编代码了

```
x /16i $eip
=> 0x7c00:      cli
   0x7c01:      cld
   0x7c02:      xor    %ax,%ax
   0x7c04:      mov    %ax,%ds
   0x7c06:      mov    %ax,%es
   0x7c08:      mov    %ax,%ss
   0x7c0a:      in     $0x64,%al
   0x7c0c:      test   $0x2,%al
   0x7c0e:      jne    0x7c0a
   0x7c10:      mov    $0xd1,%al
   0x7c12:      out    %al,$0x64
   0x7c14:      in     $0x64,%al
   0x7c16:      test   $0x2,%al
   0x7c18:      jne    0x7c14
```

bootasm.S和 bootblock.asm比较后，发现是差不多的。

#### 第四小题

断点测试就不记录了。

## 练习三

**实模式：**

+ 软件可访问的物理内存空间不能超过1MB，且无法发挥Intel 80386以上级别的32位CPU的4GB内存管理能力。

+ 实模式将整个物理内存看成分段的区域，程序代码和数据位于不同区域，操作系统和用户程序并没有区别对待，而且每一个指针都是指向实际的物理地址。这样，用户程序的一个指针如果指向了操作系统区域或其他用户程序区域，并修改了内容，那么其后果就很可能是灾难性的。通过修改A20地址线可以完成从实模式到保护模式的转换。

**保护模式：**

+ 可寻址高达4G字节的线性地址空间和物理地址空间，可访问64TB（有2^14个段，每个段最大空间为2^32字节）的逻辑地址空间，可采用分段存储管理机制和分页存储管理机制。

+ 通过提供4个特权级和完善的特权检查机制，既能实现资源共享又能保证代码数据的安全及任务的隔离。

**A20 Gate：**

+ Intel早期的8086 CPU提供了20根地址线，可寻址空间范围为1MB，pc机的寻址结构是segment:offset，将segment<<4 + offset得到20位地址，寻址空间最大为0x0ffff0 + 0x0ffff = 0x10ffefh = 1088kb。超出了1MB，所以当寻址超出时会发生“回卷”，即不会发生异常

+ 但是基于Intel 80286 CPU的PC AT计算机系统提供了24根地址线，寻址范围变成了16MB，就不会发生超出问题，故不会“回卷”，就造成了向下不兼容，故此出现了A20 Gate来解决这种问题

+ **A20 Gate**的作用是做到和Intel早期的8086 CPU的回卷一样的效果，0，关闭，就指明超出1MB的全被回卷，1，开启才能访问4GB的内存

  在保护模式下，由于使用32位地址线，如果A20恒等于0（第21位地址线），那么系统只能访问奇数兆的内存，即只能访问0--1M、2-3M、4-5M，因为xxxx xxxx xxx0 xxxx xxxx xxxx xxxx xxxx，第21位恒为0，故此只能访问奇数位。

### 为何开启A20，以及如何开启A20

根据ucore实验手册的附录A”关于A20 Gate"总结可得

开启A20是为了能够在保护模式下正常访问超出1MB的内存且不会发生回卷，否则在保护模式下只能访问奇数位的内存

打开A20 Gate的具体步骤大致如下：

1. 等待8042 Input buffer为空
2. 发送Write 8042 Output Port （P2） 命令到8042 Input buffer
3. 等待8042 Input buffer为空
4. 将8042 Output Port（P2） 对应字节的第2位置1，然后写入8042 Input buffer

seta20.1是往端口0x64写数据0xd1，告诉CPU我要往8042芯片的P2端口写数据；seta20.2是往端口0x60写数据0xdf，从而将8042芯片的P2端口设置为1



**注：**为什么要把数据设置成0xd1，0xdf，能不能是其他的只要能把bit 1置1的数据就可以，经过一番查阅，发现是不行的，0xd1和0xdf相当于特定的指令，不能改动

书上是这样的，怀疑0xdf这个指令就是书上指令的总和。

![img](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/4B7A_]{@CHMX{~4E0TV_`9Y.png)

```
seta20.1:
    inb $0x64, %al            # Wait for not busy(8042 input buffer empty).
    testb $0x2, %al
    jnz seta20.1

    movb $0xd1, %al           # 0xd1 -> port 0x64
    outb %al, $0x64           # 0xd1 means: write data to 8042's P2 port

seta20.2:
    inb $0x64, %al            # Wait for not busy(8042 input buffer empty).
    testb $0x2, %al
    jnz seta20.2

    movb $0xdf, %al           # 0xdf -> port 0x60
    outb %al, $0x60           # 0xdf = 11011111, means set P2's A20 bit(the 1 bit) to 1
```

### 如何初始化GDT表

1. 载入GDT表

```
lgdt gdtdesc       //载入GDT表

gdtdesc:
    .word 0x17                                      # sizeof(gdt) - 1
    .long gdt                                       # address gdt
    
gdt:
    SEG_NULLASM                                     # null seg
    SEG_ASM(STA_X|STA_R, 0x0, 0xffffffff)           # code seg for bootloader and kernel
    SEG_ASM(STA_W, 0x0, 0xffffffff)                 # data seg for bootloader and kernel    
    
    #define SEG_ASM(type,base,lim)                                  \
    .word (((lim) >> 12) & 0xffff), ((base) & 0xffff);          \
    .byte (((base) >> 16) & 0xff), (0x90 | (type)),             \
        (0xC0 | (((lim) >> 28) & 0xf)), (((base) >> 24) & 0xff)
```

+ **gdt**给出了全局描述符表的具体内容，共三项，每项8字节，第一项为NULL，后两项分别为代码段和数据段的描述符，它们的base都设置为0，limit都设置为0xffffffff，长度均为4G，代码段可读可执行，数据段可读可写（按书上的解释，好像一旦开启可写权限，可读权限也一并开启）

  ![image-20200805181259905](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200805181259905.png)

+ `lgdt gdtdesc`把全局描述符表的大小和地址共8字节加载到全局描述符寄存器GDTR中

### 如何使能和进入保护模式

将cr0的最低为设置为1

```
    movl %cr0, %eax
    orl $CR0_PE_ON, %eax
    movl %eax, %cr0
    
    .set CR0_PE_ON,             0x1                     # protected mode enable flag
```

## 练习四

### bootloader如何读取硬盘扇区

当前 硬盘数据是储存到硬盘扇区中，一个扇区大小为512字节。

读一个扇区的流程，ucore的实验手册指明了源码地址（boot/bootmain.c中readsect函数实现）

也给出了流程：

1. 等待磁盘准备好
2. 发出读取扇区的命令
3. 等待磁盘准备好
4. 把磁盘扇区数据读到指定内存

接下来就对readsect函数进行分析

```c
static void
readsect(void *dst, uint32_t secno) {
    // wait for disk to be ready
    waitdisk();

    outb(0x1F2, 1);                         // count = 1
    outb(0x1F3, secno & 0xFF);
    outb(0x1F4, (secno >> 8) & 0xFF);
    outb(0x1F5, (secno >> 16) & 0xFF);
    outb(0x1F6, ((secno >> 24) & 0xF) | 0xE0);
    outb(0x1F7, 0x20);                      // cmd 0x20 - read sectors

    // wait for disk to be ready
    waitdisk();

    // read a sector
    insl(0x1F0, dst, SECTSIZE / 4);
}
```

+ 等待磁盘空闲

  ```c
  waitdisk(void) {
      while ((inb(0x1F7) & 0xC0) != 0x40)
          /* do nothing */;
  }
  ```

  不断取0x1F7寄存器八位中的最高两位与0x40匹配，只有最高两位变成01才返回

+ 读写一个扇区，扇区的起始编号共32位，分成四部分，每部分8位存在0x1F3-0x1F6寄存器中，发出读写扇区命令

+ 再次等待磁盘空闲

+ 从0x1F0寄存器读数据，dst在此处猜测是一处内存地址。同时，insl以4字节为单位，故SECTSIZE(512)需要除以4

### bootloader如何加载ELF格式的OS

在bootmain函数中

```c
bootmain(void) {
    // 读取ELF头部，也就是ELF结构的magic
    readseg((uintptr_t)ELFHDR, SECTSIZE * 8, 0);

    // magic是否是7f 45 4c 46
    if (ELFHDR->e_magic != ELF_MAGIC) {
        goto bad;
    }

    struct proghdr *ph, *eph;

    // 获取程序头表在在ELF文件结构中的偏移，获取程序头表表项的数量
    // 程序头表是一个结构数组，每一个数组元素就是一个表项（应该是有8项）
    // 因为可执行文件需要将.init节，.text节，.radata节，.data节，.bss节映射到存储空间的相应的段里面（代码段，数据段）
    ph = (struct proghdr *)((uintptr_t)ELFHDR + ELFHDR->e_phoff);
    eph = ph + ELFHDR->e_phnum;
    // 将ELF文件内数据载入内存
    // ELF文件0x1000位置后面的0xd1ec比特被载入内存0x00100000
    // ELF文件0xf000位置后面的0x1d20比特被载入内存0x0010e000
    for (; ph < eph; ph ++) {
        readseg(ph->p_va & 0xFFFFFF, ph->p_memsz, ph->p_offset);
    }

    // 根据程序起始位置，找到内核入口
    // 可执行目标文件中e_entry给出执行程序时第一条指令的地址（0x8048580)
    // 可重定位文件中e_entry为0
    ((void (*)(void))(ELFHDR->e_entry & 0xFFFFFF))();

bad:
    outw(0x8A00, 0x8A00);
    outw(0x8A00, 0x8E00);

    /* do nothing */
    while (1);
}
```

程序头表的结构，属于什么节，节在文件当中起始位置，虚拟地址，物理地址，文件长度，虚拟空间长度等。

![image-20200805232611755](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200805232611755.png)

### 调试代码

尴尬，0x7d0d入口处，si 手都按烂了，源码还是没出来

## 练习五

要求完善print_stackframe函数，该函数的定义文件位置在lab1/kern/debug/kdebug.c

文件中函数里的注释十分清楚的写明了实现过程，照着抄。

实现过程：

1. 通过`read_ebp()`和`read_eip()`函数来获取当前ebp寄存器和eip 寄存器的信息，变量类型为uint_32t
2. 输出四个参数
3. 打印函数信息，更新eip，ebp

随手找了个题目的汇编代码

![image-20200806173254587](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200806173254587.png)

基本操作就是

```
	push ebp （举例，0x08048561这个值压栈)
	mov  ebp esp （举例，0x7f667802被赋给ebp寄存器）
    sub  esp 40h  
```

直接借用了ida里面的栈情况

| ret地址 （0x08048561） | 高地址 （0x7f667802） |
| :--------------------: | :-------------------: |
|  ebp值 （0x7f667802）  |                       |
|         参数一         |                       |
|         参数二         |                       |
|         ......         |                       |
|                        |      **低地址**       |

至于ucore的实验手册那里的图，看了半天才看懂，这个图画的属实怪，把中间给画出来了。它是这样的，它这里的高低位对应的是高地址和低地址，然后这个栈是什么情况呢，就相当于你main函数里调用了一个其他函数（假设是A函数）形成的堆栈情况，上一层[ebp]里的值其实是main里栈的ebp，在A函数开头又执行了一次push ebp ;mov ebp esp 

简约一点，这张图显示的是main函数和A函数栈的交界处，参数321是main的，这个返回地址其实记录的是main的栈中esp的返回地址

![image-20200806183702318](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200806183702318.png)

```c
    uint32_t ebp = read_ebp(), eip = read_eip();
    int i,j;
    for ( i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++){
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
        uint32_t *args = (uint32_t *) ebp + 2; //参数首地址
        for (j = 0; j < 4 ; j++){
            cprintf("0x%08x",args[j]); //打印四个参数
        }
        cprintf("\n");
        print_debuginfo(eip-1); // 打印函数信息
        eip = ((uint32_t *)ebp)[1];
        ebp = ((uint32_t *)ebp)[0]; 
    }
```

## 练习六

### 问题一

中断描述符表（也可简称为保护模式下的中断向量表）中一个表项占多少字节？其中哪几位代表中断处理代码的入口？

表结构如下，中断描述符表一个表项占8个字节

```c
struct gatedesc {
    unsigned gd_off_15_0 : 16;        // low 16 bits of offset in segment
    unsigned gd_ss : 16;            // segment selector
    unsigned gd_args : 5;            // # args, 0 for interrupt/trap gates
    unsigned gd_rsv1 : 3;            // reserved(should be zero I guess)
    unsigned gd_type : 4;            // type(STS_{TG,IG32,TG32})
    unsigned gd_s : 1;                // must be 0 (system)
    unsigned gd_dpl : 2;            // descriptor(meaning new) privilege level
    unsigned gd_p : 1;                // Present
    unsigned gd_off_31_16 : 16;        // high bits of offset in segment
};
```

中间是中断门描述符，其中0~15位和48~63位分别为offset的低16位和高16位。16~31位为段选择子。通过段选择子获得段基址，加上段内偏移量即可得到中断处理代码的入口。

![image-20200806223329141](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200806223329141.png)

### 问题二：完善idt_init函数

idt_init函数的任务是初始化IDT表。IDT表可以说与GDT表类似，是一个数组，每一个数组元素对应一个中断类型的处理调用。元素中记录了一个中断向量的属性（段选择子，门类型，DPL等）

SETGATE函数

```
#define SETGATE(gate, istrap, sel, off, dpl) {            \
    (gate).gd_off_15_0 = (uint32_t)(off) & 0xffff;        \
    (gate).gd_ss = (sel);                                \
    (gate).gd_args = 0;                                    \
    (gate).gd_rsv1 = 0;                                    \
    (gate).gd_type = (istrap) ? STS_TG32 : STS_IG32;    \
    (gate).gd_s = 0;                                    \
    (gate).gd_dpl = (dpl);                                \
    (gate).gd_p = 1;                                    \
    (gate).gd_off_31_16 = (uint32_t)(off) >> 16;        \
}
```



```c
    extern uintptr_t __vectors[]; // 保存vectors.S中256个中断处理例程的入口地址数组
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
        // 第二个参数0代表中断门，第三个参数是中断处理例程的代码段GD_KTEXT，第四个参数是对应的偏移量，第五个参数是特权级
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
    }
	// 从用户态切换到内核态
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
	// 将中断门描述符表的起始地址装入IDTR寄存器中
    lidt(&idt_pd);
```

### 问题三：完善trap函数

trap调用了trap_dispatch函数，所以主要处理trap_dispatch函数

```c
trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
```

在trap_dispatch函数中添加

```c
    case IRQ_OFFSET + IRQ_TIMER:	
		ticks ++;
        if (ticks % TICK_NUM == 0) {
            print_ticks();
        }
```

至于这个ticks全局变量在哪设置的，猜测是clock.h中的