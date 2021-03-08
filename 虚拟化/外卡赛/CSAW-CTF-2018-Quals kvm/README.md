KVM chal

Author: Toshi
Points: 500
Give competitors `kvm/challenge`

Building:

1. `make -C chal`     (generates guest.img)
2. Run binja script on guest.img to make a better obfuscated one
   and to generate guest-tbl.c
3. `make -C chal tbl` (generates guest-tbl.o)
4. `make -C kvm`

在进行完上面的构筑后，我们对/kvm/challenge文件进行逆向，但是先来检索一下/usr/include/linux/kvm.h，来看看这个**0x0000AE00**的操作的宏定义

```c
#define KVMIO 0xAE

/*
 * ioctls for /dev/kvm fds:
 */
#define KVM_GET_API_VERSION _IO(KVMIO, 0x00)
#define KVM_CREATE_VM       _IO(KVMIO, 0x01) /* returns a VM fd */
#define KVM_CHECK_EXTENSION       _IO(KVMIO,   0x03)
#define KVM_GET_VCPU_MMAP_SIZE    _IO(KVMIO,   0x04) /* in bytes */
#define KVM_CREATE_VCPU           _IO(KVMIO,   0x41)
#define KVM_SET_TSS_ADDR          _IO(KVMIO,   0x47)
#define KVM_SET_USER_MEMORY_REGION _IOW(KVMIO, 0x46, \
					struct kvm_userspace_memory_region)
#define KVM_GET_SREGS             _IOR(KVMIO,  0x83, struct kvm_sregs)
#define KVM_SET_SREGS             _IOW(KVMIO,  0x84, struct kvm_sregs)
#define KVM_GET_REGS              _IOR(KVMIO,  0x81, struct kvm_regs)
#define KVM_SET_REGS              _IOW(KVMIO,  0x82, struct kvm_regs)
```

逆向

```c
int __fastcall sub_400916(__int64 a1, __int64 a2)
{
  int result; // eax
  __int64 len; // [rsp+0h] [rbp-40h]
  int v4; // [rsp+10h] [rbp-30h]
  int v5; // [rsp+14h] [rbp-2Ch]
  __int64 v6; // [rsp+18h] [rbp-28h]
  __int64 v7; // [rsp+20h] [rbp-20h]
  __int64 v8; // [rsp+28h] [rbp-18h]
  int v9; // [rsp+3Ch] [rbp-4h]
  // 打开句柄
  *(_DWORD *)a1 = open("/dev/kvm", 2, a2);
  if ( *(_DWORD *)a1 < 0 )
  {
    perror("open /dev/kvm");
    exit(1);
  }
  // 获取kvm api版本号
  v9 = ioctl(*(_DWORD *)a1, 0xAE00uLL, 0LL); //ioctl(a1,KVM_GET_API_VERSION,0)
  if ( v9 < 0 )
  {
    perror("KVM_GET_API_VERSION");
    exit(1);
  }
  // 对kvm api版本进行检测
  if ( v9 != 12 )
  {
    fprintf(stderr, "Got KVM api version %d, expected %d\n", (unsigned int)v9, 12LL);
    exit(1);
  }
  // 创建虚拟机
  *(_DWORD *)(a1 + 4) = ioctl(*(_DWORD *)a1, 0xAE01uLL, 0LL); //ioctl(a1,KVM_CREATE_VM, 0LL)
  if ( *(_DWORD *)(a1 + 4) < 0 )
  {
    perror("KVM_CREATE_VM");
    exit(1);
  }
  // 初始化TSS内存区域（Intel架构专用）
  // ioctl(*(a1 + 4),KVM_SET_TSS_ADDR, 0xFFFBD000LL)
  if ( ioctl(*(_DWORD *)(a1 + 4), 0xAE47uLL, 0xFFFBD000LL) < 0 )
  {
    perror("KVM_SET_TSS_ADDR");
    exit(1);
  }
  *(_QWORD *)(a1 + 8) = mmap(0LL, len, 3, 16418, -1, 0LL);
  if ( *(_QWORD *)(a1 + 8) == -1LL )
  {
    perror("mmap mem");
    exit(1);
  }
  madvise(*(void **)(a1 + 8), len, 12);
  v4 = 0;
  v5 = 0;
  v6 = 0LL;
  v7 = len;
  v8 = *(_QWORD *)(a1 + 8);
  // 为虚拟机映射内存
  result = ioctl(*(_DWORD *)(a1 + 4), 0x4020AE46uLL, &v4); // KVM_SET_USER_MEMORY_REGION
  if ( result < 0 )
  {
    perror("KVM_SET_USER_MEMORY_REGION");
    exit(1);
  }
  return result;
}

__int64 __fastcall sub_400B24(int *a1, __int64 a2)
{
  int v2; // eax
  __int64 result; // rax
  __int64 v4; // [rsp+0h] [rbp-20h]
  int v5; // [rsp+1Ch] [rbp-4h]
  // 创建vcpu
  v2 = ioctl(a1[1], 0xAE41uLL, 0LL, a2); // KVM_CREATE_VCPU
  *(_DWORD *)v4 = v2;
  if ( *(_DWORD *)v4 < 0 )
  {
    perror("KVM_CREATE_VCPU");
    exit(1);
  }
  // 用户态程序需要将这段空间映射到用户空间，调用ioctl(KVM_GET_VCPU_MMAP_SIZE)得到这个结构大小
  v5 = ioctl(*a1, 0xAE04uLL, 0LL);
  if ( v5 <= 0 )
  {
    perror("KVM_GET_VCPU_MMAP_SIZE");
    exit(1);
  }
  // 给其分派空间
  *(_QWORD *)(v4 + 8) = mmap(0LL, v5, 3, 1, *(_DWORD *)v4, 0LL);
  result = *(_QWORD *)(v4 + 8);
  if ( result == -1 )
  {
    perror("mmap kvm_run");
    exit(1);
  }
  return result;
}

__int64 __fastcall sub_401103(__int64 a1, int *a2)
{
  int *v3; // [rsp+0h] [rbp-1E0h]
  char s; // [rsp+10h] [rbp-1D0h]
  __int64 v5; // [rsp+40h] [rbp-1A0h]
  __int64 v6; // [rsp+90h] [rbp-150h]
  __int64 v7; // [rsp+98h] [rbp-148h]
  char v8; // [rsp+A0h] [rbp-140h]
  
  // 读取段寄存器和控制寄存器等特殊寄存器
  if ( ioctl(*a2, 0x8138AE83uLL, &v8, a2) < 0 )
  {
    perror("KVM_GET_SREGS");
    exit(1);
  }
  sub_401027(a1, &v8);
  // 设置段寄存器和控制寄存器等特殊寄存器
  if ( ioctl(*v3, 0x4138AE84uLL, &v8) < 0 )
  {
    perror("KVM_SET_SREGS");
    exit(1);
  }
  memset(&s, 0, 0x90uLL);
  v7 = 2LL;
  v6 = 0LL;
  v5 = 0x200000LL;
  // 设置通用寄存器
  if ( ioctl(*v3, 0x4090AE82uLL, &s) < 0 )
  {
    perror("KVM_SET_REGS");
    exit(1);
  }
  memcpy(*(void **)(a1 + 8), &unk_602174, &unk_60348C - &unk_602174);
  return sub_400CA9(a1, (__int64)v3);
}
```

这里的大致源码其实可以参考这简易qemu实现

```c
int main(){
	struct kvm_sregssregs;
	int ret;
	int kvmfd = open("/dev/kvm",O_RDWR);			//获取系统中KVM子系统的文件描述符kvmfd
	ioctl(kvmfd,KVM_GET_API_VERSION,NULL);			//获取KVM版本号
	int vmfd = ioctl(kvmfd,KVM_CREATE_VM,0);		//创建一个虚拟机
	unsigned char *ram = mmap(NULL,0x1000,PROT_READ|PROT_WRITE,MAP_SHARED|MAP_ANONYMUS,-1,0);			//为虚拟机分配内存
	int kfd = open("test.bin",O_RDONLY);			//打开第一个例子的程序
	read(kfd,ram,4096);				//把程序的读入到虚拟机中，这样等会虚拟机运行的时候就会先开始执行这个打开的程序了
	struct kvm_userspace_memory_region mem = {
		.slot = 0,
		.guest_phys_addr = 0,
		.memory_size = 0x1000,
		.userspace_addr = (unsigned long)ram,
	};								//设置虚拟机内存布局
	ret = ioctl(vmfd,KVM_SET_USER_MEMORY_REGION,&mem);				//分配虚拟机内存
	int vcpufd = ioctl(vmfd,KVM_CREATE_VCPU,0);				//创建虚拟CPU
	int mmap_size = ioctl(kvmfd,KVM_GET_VCPU,0);			//获取虚拟CPU对应的kvm_run结构的大小
	struct kvm_run *run = mmap(NULL,mmap_size,PROT_READ|PROT_WRITE,MAP_SHARED,vcpufd,0);				//给虚拟CPU分配内存空间
	ret = ioctl(vcpufd,KVM_GET_SREGS,&sregs);				//获取特殊寄存器
	sregs.cs.base = 0;										
	sregs.cs.selector = 0;
	ret = ioctl(vcpufd,KVM_SET_SREGS,&sregs);				//设置特殊寄存器的值
	struct kvm_regs regs = {
		.rip = 0;
	};
	ret = ioctl(vcpufd,KVM_SET_REGS,&regs);					//设置通用寄存器的值
	while(1){
		ret = ioctl(vcpufd,KVM_RUN,NULL);					//开始运行虚拟机
		if(ret == -1){
			printf("exit unknown\n");
			return -1;
		}
		switch(run->exit_reason){							//检测虚拟机退出的原因
			case "KVM_EXIT_HLT":
				puts("KVM_EXIT_HLT");
				return 0;
			case "KVM_EXIT_IO":
				putchar(*(((char *)run) + run->io.data_offset));
				break;
			case "KVM_EXIT_FAIL_ENTRY":
				puts("entry error");
				return -1;
			default:
				puts("other error");
				printf("exit_reason： %d\n",run->exit_reason);
			return -1;
		}
	}
}
```

当然，还有另外一种方法，利用linux里的`strace`命令，strace常用来跟踪进程执行时的系统调用和所接收的信号。通过strace可以知道应用进程打开了哪些文件，内容，时间以及返回值等。

```shell
$ strace -v ./challenge
```

接下来，我们主要来关注IDA里面的这个函数

```c
memcpy(*(void **)(a1 + 8), &unk_602174, &unk_60348C - &unk_602174);
```

我们可以观察到，将size为0x1318的从0x602174起的数据传入了虚拟机里面。那么我们利用py脚本来获取这段数据

```python
code_size = 0x60348c-0x602174
with open("challenge","rb") as fd:
	fd.seek(0x2174)
	content = fd.read(code_size)

with open("content","wb") as fd:
	fd.write(content)
```

利用IDA对获取到的数据进行反汇编，这是一开始的汇编代码，

```
seg000:0000000000000000                 push    rbp
seg000:0000000000000001                 mov     rbp, rsp
seg000:0000000000000004                 sub     rsp, 2810h
seg000:000000000000000B                 lea     rax, [rbp-2810h]
seg000:0000000000000012                 mov     esi, 2800h
seg000:0000000000000017                 mov     rdi, rax
seg000:000000000000001A                 call    sub_D1
```

主要来看SUB_D1，读取端口0xE9里面的数据，然后将其放入buf中。当虚拟化代码执行I / O操作时，kvm将停止虚拟机，并在*kvm_run*结构的*exit_reason*成员中设置**KVM_EXIT_IO**。

```c
void __usercall SUB_D1(char *buf@<rdi>, signed int len@<esi>)
{
  unsigned __int8 input_char; // al
  signed int i; // [rsp+18h] [rbp-4h]

  for ( i = 0; i < len; ++i )
  {
    input_char = __inbyte(0xE9u);
    buf[i] = input_char;
  }
}
```

继续来分析SUB_118函数，实现的是类似于strncmp的功能，一共判断rdx位数据，判断rdi和rsi里面的数据是否是一样的

```c
signed __int64 __usercall sub_118@<rax>(unsigned __int64 a1@<rdx>, __int64 a2@<rdi>, __int64 a3@<rsi>)
{
  int i; // [rsp+24h] [rbp-4h]

  for ( i = 0; i < a1; ++i )
  {
    if ( *(i + a2) != *(i + a3) )
      return 1i64;
  }
  return 0i64;
}
```

接着回到程序开头，我们继续来观察

```
seg000:0000000000000028
seg000:0000000000000028 loc_28:                                 ; CODE XREF: sub_0:loc_60↓j
seg000:0000000000000028                 mov     eax, [rbp+var_4]
seg000:000000000000002B                 cdqe
seg000:000000000000002D
seg000:000000000000002D loc_2D:                                 ; DATA XREF: seg000:0000000000000EC0↓o
seg000:000000000000002D                                         ; seg000:0000000000001180↓o
seg000:000000000000002D                 movzx   eax, [rbp+rax+buf]
seg000:0000000000000035
seg000:0000000000000035 loc_35:                                 ; DATA XREF: seg000:0000000000000B40↓o
seg000:0000000000000035                                         ; seg000:0000000000001120↓o ...
seg000:0000000000000035                 movsx   eax, al
seg000:0000000000000038                 mov     esi, 1300h
seg000:000000000000003D                 mov     edi, eax
seg000:000000000000003F
seg000:000000000000003F loc_3F:                                 ; DATA XREF: seg000:off_D60↓o
seg000:000000000000003F                 call    sub_1E0
```

此处将在sub_D1函数里进行循环读，将数据放入buf，然后将其传递给`sub_1E0`

同时注意这一个地方`mov     esi, 1300h`，我们来跟踪一下，0x1300地址里面是什么

![image-20201102182550000](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20201102182550000.png)

似乎是一种二叉树结构，转化为c代码就是

```c
typedef struct node_t
{
	uint64_t value;
	uint64_t left;
	uint64_t right;
}
```

再回来观察sub_1E0函数，发现有一个hlt，因此*kvm_run*结构的*exit_reason*成员采用值**KVM_EXIT_HLT**。

```
seg000:00000000000001E0                 push    rbp
seg000:00000000000001E1                 mov     rbp, rsp
seg000:00000000000001E4                 sub     rsp, 60h
seg000:00000000000001E8                 mov     al, dil
seg000:00000000000001EB                 mov     [rbp+var_9], al
seg000:00000000000001EE                 mov     [rbp+var_18], rsi
seg000:00000000000001F2                 mov     rsi, [rbp+var_18]
seg000:00000000000001F6                 movsx   edi, byte ptr [rsi]
seg000:00000000000001F9                 mov     [rbp+var_4], edi
seg000:00000000000001FC                 mov     eax, 3493310Dh
seg000:0000000000000201                 hlt
seg000:0000000000000201 sub_1E0         endp
```

在我们的challenge程序中处理了这种情况

![image-20201102183331298](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20201102183331298.png)

```c
#define KVM_EXIT_HLT              5
```

但是下面有一个可疑的函数sub_400c11，我们来观察一下这个函数执行了什么。

```c
__int64 __fastcall sub_400C11(int a1)
{
  __int64 *v1; // rdx
  __int64 v2; // rdx
  __int64 result; // rax
  int i; // [rsp+1Ch] [rbp-14h]

  for ( i = 0; ; ++i )
  {
    if ( i >= dword_602170 )
    {
      fwrite("Error - bug the organizer\n", 1uLL, 0x1AuLL, stderr);
      exit(1);
    }
    if ( dword_6020A0[4 * i] == a1 )
      break;
  }
  v1 = (__int64 *)&dword_6020A0[4 * i];
  result = *v1;
  v2 = v1[1];
  return (unsigned int)result;
}
```

根据分析，我们可以观察到这里存在一个结构体：

- 在hlt指令之前放置在*eax中的**id*值
- *reg_rip*地址在*hlt*指令后跳转

```
typedef struct ret_if{
	uint64_t id;
	uint64_t reg_rip;
}
```

可以看到，这个函数在对虚拟机中获取的rax值进行匹配，如果匹配成功就将其替换为reg_rip。实际上，参考其他人的wp，在上面获取的那段数据里面，实际是一个哈夫曼编码的过程，将其输入的数据流压缩成二进制编码，但是我逆向太差劲了，没办法逆，这步骤进行不下去。

这里总结一下程序流：将用户的输入进行二进制压缩，然后将其存储在二叉树上。

那么将两个程序结合一下，总体流程就是根据我们的输入去遍历二叉树，遍历的叶子节点去填充buf，然后这个buf跟正确的值去比较，如果比较通过，就成功输出。（这种解法大部分靠爆破，沉思，靠天吃饭）

#### 另一种思路

我们将压缩的密码用脚本读取下来，根据其数据一次放到正确的树的叶子节点上，然后运用哈夫曼解码脚本将其跑出来



怎么说，感觉这题，逆向哈夫曼树，也太......感觉像是为了出题而出题？