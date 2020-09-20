
obj/__user_forktree.out：     文件格式 elf32-i386


Disassembly of section .text:

00800020 <__panic>:
#include <stdio.h>
#include <ulib.h>
#include <error.h>

void
__panic(const char *file, int line, const char *fmt, ...) {
  800020:	55                   	push   %ebp
  800021:	89 e5                	mov    %esp,%ebp
  800023:	83 ec 28             	sub    $0x28,%esp
    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  800026:	8d 45 14             	lea    0x14(%ebp),%eax
  800029:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("user panic at %s:%d:\n    ", file, line);
  80002c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80002f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800033:	8b 45 08             	mov    0x8(%ebp),%eax
  800036:	89 44 24 04          	mov    %eax,0x4(%esp)
  80003a:	c7 04 24 a0 10 80 00 	movl   $0x8010a0,(%esp)
  800041:	e8 db 02 00 00       	call   800321 <cprintf>
    vcprintf(fmt, ap);
  800046:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800049:	89 44 24 04          	mov    %eax,0x4(%esp)
  80004d:	8b 45 10             	mov    0x10(%ebp),%eax
  800050:	89 04 24             	mov    %eax,(%esp)
  800053:	e8 96 02 00 00       	call   8002ee <vcprintf>
    cprintf("\n");
  800058:	c7 04 24 ba 10 80 00 	movl   $0x8010ba,(%esp)
  80005f:	e8 bd 02 00 00       	call   800321 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800064:	c7 04 24 f6 ff ff ff 	movl   $0xfffffff6,(%esp)
  80006b:	e8 8f 01 00 00       	call   8001ff <exit>

00800070 <__warn>:
}

void
__warn(const char *file, int line, const char *fmt, ...) {
  800070:	55                   	push   %ebp
  800071:	89 e5                	mov    %esp,%ebp
  800073:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  800076:	8d 45 14             	lea    0x14(%ebp),%eax
  800079:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("user warning at %s:%d:\n    ", file, line);
  80007c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80007f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800083:	8b 45 08             	mov    0x8(%ebp),%eax
  800086:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008a:	c7 04 24 bc 10 80 00 	movl   $0x8010bc,(%esp)
  800091:	e8 8b 02 00 00       	call   800321 <cprintf>
    vcprintf(fmt, ap);
  800096:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800099:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009d:	8b 45 10             	mov    0x10(%ebp),%eax
  8000a0:	89 04 24             	mov    %eax,(%esp)
  8000a3:	e8 46 02 00 00       	call   8002ee <vcprintf>
    cprintf("\n");
  8000a8:	c7 04 24 ba 10 80 00 	movl   $0x8010ba,(%esp)
  8000af:	e8 6d 02 00 00       	call   800321 <cprintf>
    va_end(ap);
}
  8000b4:	90                   	nop
  8000b5:	c9                   	leave  
  8000b6:	c3                   	ret    

008000b7 <syscall>:
#include <syscall.h>

#define MAX_ARGS            5

static inline int
syscall(int num, ...) {
  8000b7:	55                   	push   %ebp
  8000b8:	89 e5                	mov    %esp,%ebp
  8000ba:	57                   	push   %edi
  8000bb:	56                   	push   %esi
  8000bc:	53                   	push   %ebx
  8000bd:	83 ec 20             	sub    $0x20,%esp
    va_list ap;
    va_start(ap, num);
  8000c0:	8d 45 0c             	lea    0xc(%ebp),%eax
  8000c3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    uint32_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
  8000c6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8000cd:	eb 15                	jmp    8000e4 <syscall+0x2d>
        a[i] = va_arg(ap, uint32_t);
  8000cf:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8000d2:	8d 50 04             	lea    0x4(%eax),%edx
  8000d5:	89 55 e8             	mov    %edx,-0x18(%ebp)
  8000d8:	8b 10                	mov    (%eax),%edx
  8000da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8000dd:	89 54 85 d4          	mov    %edx,-0x2c(%ebp,%eax,4)
syscall(int num, ...) {
    va_list ap;
    va_start(ap, num);
    uint32_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
  8000e1:	ff 45 f0             	incl   -0x10(%ebp)
  8000e4:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
  8000e8:	7e e5                	jle    8000cf <syscall+0x18>
    asm volatile (
        "int %1;"
        : "=a" (ret)
        : "i" (T_SYSCALL),
          "a" (num),
          "d" (a[0]),
  8000ea:	8b 55 d4             	mov    -0x2c(%ebp),%edx
          "c" (a[1]),
  8000ed:	8b 4d d8             	mov    -0x28(%ebp),%ecx
          "b" (a[2]),
  8000f0:	8b 5d dc             	mov    -0x24(%ebp),%ebx
          "D" (a[3]),
  8000f3:	8b 7d e0             	mov    -0x20(%ebp),%edi
          "S" (a[4])
  8000f6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
    for (i = 0; i < MAX_ARGS; i ++) {
        a[i] = va_arg(ap, uint32_t);
    }
    va_end(ap);

    asm volatile (
  8000f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8000fc:	cd 80                	int    $0x80
  8000fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
          "c" (a[1]),
          "b" (a[2]),
          "D" (a[3]),
          "S" (a[4])
        : "cc", "memory");
    return ret;
  800101:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
  800104:	83 c4 20             	add    $0x20,%esp
  800107:	5b                   	pop    %ebx
  800108:	5e                   	pop    %esi
  800109:	5f                   	pop    %edi
  80010a:	5d                   	pop    %ebp
  80010b:	c3                   	ret    

0080010c <sys_exit>:

int
sys_exit(int error_code) {
  80010c:	55                   	push   %ebp
  80010d:	89 e5                	mov    %esp,%ebp
  80010f:	83 ec 08             	sub    $0x8,%esp
    return syscall(SYS_exit, error_code);
  800112:	8b 45 08             	mov    0x8(%ebp),%eax
  800115:	89 44 24 04          	mov    %eax,0x4(%esp)
  800119:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800120:	e8 92 ff ff ff       	call   8000b7 <syscall>
}
  800125:	c9                   	leave  
  800126:	c3                   	ret    

00800127 <sys_fork>:

int
sys_fork(void) {
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	83 ec 04             	sub    $0x4,%esp
    return syscall(SYS_fork);
  80012d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800134:	e8 7e ff ff ff       	call   8000b7 <syscall>
}
  800139:	c9                   	leave  
  80013a:	c3                   	ret    

0080013b <sys_wait>:

int
sys_wait(int pid, int *store) {
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	83 ec 0c             	sub    $0xc,%esp
    return syscall(SYS_wait, pid, store);
  800141:	8b 45 0c             	mov    0xc(%ebp),%eax
  800144:	89 44 24 08          	mov    %eax,0x8(%esp)
  800148:	8b 45 08             	mov    0x8(%ebp),%eax
  80014b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80014f:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  800156:	e8 5c ff ff ff       	call   8000b7 <syscall>
}
  80015b:	c9                   	leave  
  80015c:	c3                   	ret    

0080015d <sys_yield>:

int
sys_yield(void) {
  80015d:	55                   	push   %ebp
  80015e:	89 e5                	mov    %esp,%ebp
  800160:	83 ec 04             	sub    $0x4,%esp
    return syscall(SYS_yield);
  800163:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  80016a:	e8 48 ff ff ff       	call   8000b7 <syscall>
}
  80016f:	c9                   	leave  
  800170:	c3                   	ret    

00800171 <sys_kill>:

int
sys_kill(int pid) {
  800171:	55                   	push   %ebp
  800172:	89 e5                	mov    %esp,%ebp
  800174:	83 ec 08             	sub    $0x8,%esp
    return syscall(SYS_kill, pid);
  800177:	8b 45 08             	mov    0x8(%ebp),%eax
  80017a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017e:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  800185:	e8 2d ff ff ff       	call   8000b7 <syscall>
}
  80018a:	c9                   	leave  
  80018b:	c3                   	ret    

0080018c <sys_getpid>:

int
sys_getpid(void) {
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	83 ec 04             	sub    $0x4,%esp
    return syscall(SYS_getpid);
  800192:	c7 04 24 12 00 00 00 	movl   $0x12,(%esp)
  800199:	e8 19 ff ff ff       	call   8000b7 <syscall>
}
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    

008001a0 <sys_putc>:

int
sys_putc(int c) {
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	83 ec 08             	sub    $0x8,%esp
    return syscall(SYS_putc, c);
  8001a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ad:	c7 04 24 1e 00 00 00 	movl   $0x1e,(%esp)
  8001b4:	e8 fe fe ff ff       	call   8000b7 <syscall>
}
  8001b9:	c9                   	leave  
  8001ba:	c3                   	ret    

008001bb <sys_pgdir>:

int
sys_pgdir(void) {
  8001bb:	55                   	push   %ebp
  8001bc:	89 e5                	mov    %esp,%ebp
  8001be:	83 ec 04             	sub    $0x4,%esp
    return syscall(SYS_pgdir);
  8001c1:	c7 04 24 1f 00 00 00 	movl   $0x1f,(%esp)
  8001c8:	e8 ea fe ff ff       	call   8000b7 <syscall>
}
  8001cd:	c9                   	leave  
  8001ce:	c3                   	ret    

008001cf <sys_gettime>:

int
sys_gettime(void) {
  8001cf:	55                   	push   %ebp
  8001d0:	89 e5                	mov    %esp,%ebp
  8001d2:	83 ec 04             	sub    $0x4,%esp
    return syscall(SYS_gettime);
  8001d5:	c7 04 24 11 00 00 00 	movl   $0x11,(%esp)
  8001dc:	e8 d6 fe ff ff       	call   8000b7 <syscall>
}
  8001e1:	c9                   	leave  
  8001e2:	c3                   	ret    

008001e3 <sys_lab6_set_priority>:

void
sys_lab6_set_priority(uint32_t priority)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	83 ec 08             	sub    $0x8,%esp
    syscall(SYS_lab6_set_priority, priority);
  8001e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f0:	c7 04 24 ff 00 00 00 	movl   $0xff,(%esp)
  8001f7:	e8 bb fe ff ff       	call   8000b7 <syscall>
}
  8001fc:	90                   	nop
  8001fd:	c9                   	leave  
  8001fe:	c3                   	ret    

008001ff <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8001ff:	55                   	push   %ebp
  800200:	89 e5                	mov    %esp,%ebp
  800202:	83 ec 18             	sub    $0x18,%esp
    sys_exit(error_code);
  800205:	8b 45 08             	mov    0x8(%ebp),%eax
  800208:	89 04 24             	mov    %eax,(%esp)
  80020b:	e8 fc fe ff ff       	call   80010c <sys_exit>
    cprintf("BUG: exit failed.\n");
  800210:	c7 04 24 d8 10 80 00 	movl   $0x8010d8,(%esp)
  800217:	e8 05 01 00 00       	call   800321 <cprintf>
    while (1);
  80021c:	eb fe                	jmp    80021c <exit+0x1d>

0080021e <fork>:
}

int
fork(void) {
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	83 ec 08             	sub    $0x8,%esp
    return sys_fork();
  800224:	e8 fe fe ff ff       	call   800127 <sys_fork>
}
  800229:	c9                   	leave  
  80022a:	c3                   	ret    

0080022b <wait>:

int
wait(void) {
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	83 ec 18             	sub    $0x18,%esp
    return sys_wait(0, NULL);
  800231:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800238:	00 
  800239:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800240:	e8 f6 fe ff ff       	call   80013b <sys_wait>
}
  800245:	c9                   	leave  
  800246:	c3                   	ret    

00800247 <waitpid>:

int
waitpid(int pid, int *store) {
  800247:	55                   	push   %ebp
  800248:	89 e5                	mov    %esp,%ebp
  80024a:	83 ec 18             	sub    $0x18,%esp
    return sys_wait(pid, store);
  80024d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800250:	89 44 24 04          	mov    %eax,0x4(%esp)
  800254:	8b 45 08             	mov    0x8(%ebp),%eax
  800257:	89 04 24             	mov    %eax,(%esp)
  80025a:	e8 dc fe ff ff       	call   80013b <sys_wait>
}
  80025f:	c9                   	leave  
  800260:	c3                   	ret    

00800261 <yield>:

void
yield(void) {
  800261:	55                   	push   %ebp
  800262:	89 e5                	mov    %esp,%ebp
  800264:	83 ec 08             	sub    $0x8,%esp
    sys_yield();
  800267:	e8 f1 fe ff ff       	call   80015d <sys_yield>
}
  80026c:	90                   	nop
  80026d:	c9                   	leave  
  80026e:	c3                   	ret    

0080026f <kill>:

int
kill(int pid) {
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	83 ec 18             	sub    $0x18,%esp
    return sys_kill(pid);
  800275:	8b 45 08             	mov    0x8(%ebp),%eax
  800278:	89 04 24             	mov    %eax,(%esp)
  80027b:	e8 f1 fe ff ff       	call   800171 <sys_kill>
}
  800280:	c9                   	leave  
  800281:	c3                   	ret    

00800282 <getpid>:

int
getpid(void) {
  800282:	55                   	push   %ebp
  800283:	89 e5                	mov    %esp,%ebp
  800285:	83 ec 08             	sub    $0x8,%esp
    return sys_getpid();
  800288:	e8 ff fe ff ff       	call   80018c <sys_getpid>
}
  80028d:	c9                   	leave  
  80028e:	c3                   	ret    

0080028f <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  80028f:	55                   	push   %ebp
  800290:	89 e5                	mov    %esp,%ebp
  800292:	83 ec 08             	sub    $0x8,%esp
    sys_pgdir();
  800295:	e8 21 ff ff ff       	call   8001bb <sys_pgdir>
}
  80029a:	90                   	nop
  80029b:	c9                   	leave  
  80029c:	c3                   	ret    

0080029d <gettime_msec>:

unsigned int
gettime_msec(void) {
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
  8002a0:	83 ec 08             	sub    $0x8,%esp
    return (unsigned int)sys_gettime();
  8002a3:	e8 27 ff ff ff       	call   8001cf <sys_gettime>
}
  8002a8:	c9                   	leave  
  8002a9:	c3                   	ret    

008002aa <lab6_set_priority>:

void
lab6_set_priority(uint32_t priority)
{
  8002aa:	55                   	push   %ebp
  8002ab:	89 e5                	mov    %esp,%ebp
  8002ad:	83 ec 18             	sub    $0x18,%esp
    sys_lab6_set_priority(priority);
  8002b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b3:	89 04 24             	mov    %eax,(%esp)
  8002b6:	e8 28 ff ff ff       	call   8001e3 <sys_lab6_set_priority>
}
  8002bb:	90                   	nop
  8002bc:	c9                   	leave  
  8002bd:	c3                   	ret    

008002be <_start>:
.text
.globl _start
_start:
    # set ebp for backtrace
    movl $0x0, %ebp
  8002be:	bd 00 00 00 00       	mov    $0x0,%ebp

    # move down the esp register
    # since it may cause page fault in backtrace
    subl $0x20, %esp
  8002c3:	83 ec 20             	sub    $0x20,%esp

    # call user-program function
    call umain
  8002c6:	e8 cb 00 00 00       	call   800396 <umain>
1:  jmp 1b
  8002cb:	eb fe                	jmp    8002cb <_start+0xd>

008002cd <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  8002cd:	55                   	push   %ebp
  8002ce:	89 e5                	mov    %esp,%ebp
  8002d0:	83 ec 18             	sub    $0x18,%esp
    sys_putc(c);
  8002d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d6:	89 04 24             	mov    %eax,(%esp)
  8002d9:	e8 c2 fe ff ff       	call   8001a0 <sys_putc>
    (*cnt) ++;
  8002de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002e1:	8b 00                	mov    (%eax),%eax
  8002e3:	8d 50 01             	lea    0x1(%eax),%edx
  8002e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002e9:	89 10                	mov    %edx,(%eax)
}
  8002eb:	90                   	nop
  8002ec:	c9                   	leave  
  8002ed:	c3                   	ret    

008002ee <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  8002f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8002fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800302:	8b 45 08             	mov    0x8(%ebp),%eax
  800305:	89 44 24 08          	mov    %eax,0x8(%esp)
  800309:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80030c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800310:	c7 04 24 cd 02 80 00 	movl   $0x8002cd,(%esp)
  800317:	e8 06 07 00 00       	call   800a22 <vprintfmt>
    return cnt;
  80031c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80031f:	c9                   	leave  
  800320:	c3                   	ret    

00800321 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  800321:	55                   	push   %ebp
  800322:	89 e5                	mov    %esp,%ebp
  800324:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  800327:	8d 45 0c             	lea    0xc(%ebp),%eax
  80032a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int cnt = vcprintf(fmt, ap);
  80032d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800330:	89 44 24 04          	mov    %eax,0x4(%esp)
  800334:	8b 45 08             	mov    0x8(%ebp),%eax
  800337:	89 04 24             	mov    %eax,(%esp)
  80033a:	e8 af ff ff ff       	call   8002ee <vcprintf>
  80033f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);

    return cnt;
  800342:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800345:	c9                   	leave  
  800346:	c3                   	ret    

00800347 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
  80034a:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  80034d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  800354:	eb 13                	jmp    800369 <cputs+0x22>
        cputch(c, &cnt);
  800356:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  80035a:	8d 55 f0             	lea    -0x10(%ebp),%edx
  80035d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800361:	89 04 24             	mov    %eax,(%esp)
  800364:	e8 64 ff ff ff       	call   8002cd <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
  800369:	8b 45 08             	mov    0x8(%ebp),%eax
  80036c:	8d 50 01             	lea    0x1(%eax),%edx
  80036f:	89 55 08             	mov    %edx,0x8(%ebp)
  800372:	0f b6 00             	movzbl (%eax),%eax
  800375:	88 45 f7             	mov    %al,-0x9(%ebp)
  800378:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  80037c:	75 d8                	jne    800356 <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
  80037e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800381:	89 44 24 04          	mov    %eax,0x4(%esp)
  800385:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  80038c:	e8 3c ff ff ff       	call   8002cd <cputch>
    return cnt;
  800391:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  800394:	c9                   	leave  
  800395:	c3                   	ret    

00800396 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800396:	55                   	push   %ebp
  800397:	89 e5                	mov    %esp,%ebp
  800399:	83 ec 28             	sub    $0x28,%esp
    int ret = main();
  80039c:	e8 de 0c 00 00       	call   80107f <main>
  8003a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    exit(ret);
  8003a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8003a7:	89 04 24             	mov    %eax,(%esp)
  8003aa:	e8 50 fe ff ff       	call   8001ff <exit>

008003af <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  8003af:	55                   	push   %ebp
  8003b0:	89 e5                	mov    %esp,%ebp
  8003b2:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  8003b5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  8003bc:	eb 03                	jmp    8003c1 <strlen+0x12>
        cnt ++;
  8003be:	ff 45 fc             	incl   -0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
  8003c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c4:	8d 50 01             	lea    0x1(%eax),%edx
  8003c7:	89 55 08             	mov    %edx,0x8(%ebp)
  8003ca:	0f b6 00             	movzbl (%eax),%eax
  8003cd:	84 c0                	test   %al,%al
  8003cf:	75 ed                	jne    8003be <strlen+0xf>
        cnt ++;
    }
    return cnt;
  8003d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8003d4:	c9                   	leave  
  8003d5:	c3                   	ret    

008003d6 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  8003d6:	55                   	push   %ebp
  8003d7:	89 e5                	mov    %esp,%ebp
  8003d9:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  8003dc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  8003e3:	eb 03                	jmp    8003e8 <strnlen+0x12>
        cnt ++;
  8003e5:	ff 45 fc             	incl   -0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  8003e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8003eb:	3b 45 0c             	cmp    0xc(%ebp),%eax
  8003ee:	73 10                	jae    800400 <strnlen+0x2a>
  8003f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f3:	8d 50 01             	lea    0x1(%eax),%edx
  8003f6:	89 55 08             	mov    %edx,0x8(%ebp)
  8003f9:	0f b6 00             	movzbl (%eax),%eax
  8003fc:	84 c0                	test   %al,%al
  8003fe:	75 e5                	jne    8003e5 <strnlen+0xf>
        cnt ++;
    }
    return cnt;
  800400:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800403:	c9                   	leave  
  800404:	c3                   	ret    

00800405 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  800405:	55                   	push   %ebp
  800406:	89 e5                	mov    %esp,%ebp
  800408:	57                   	push   %edi
  800409:	56                   	push   %esi
  80040a:	83 ec 20             	sub    $0x20,%esp
  80040d:	8b 45 08             	mov    0x8(%ebp),%eax
  800410:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800413:	8b 45 0c             	mov    0xc(%ebp),%eax
  800416:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  800419:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80041c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80041f:	89 d1                	mov    %edx,%ecx
  800421:	89 c2                	mov    %eax,%edx
  800423:	89 ce                	mov    %ecx,%esi
  800425:	89 d7                	mov    %edx,%edi
  800427:	ac                   	lods   %ds:(%esi),%al
  800428:	aa                   	stos   %al,%es:(%edi)
  800429:	84 c0                	test   %al,%al
  80042b:	75 fa                	jne    800427 <strcpy+0x22>
  80042d:	89 fa                	mov    %edi,%edx
  80042f:	89 f1                	mov    %esi,%ecx
  800431:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  800434:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800437:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  80043a:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
  80043d:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  80043e:	83 c4 20             	add    $0x20,%esp
  800441:	5e                   	pop    %esi
  800442:	5f                   	pop    %edi
  800443:	5d                   	pop    %ebp
  800444:	c3                   	ret    

00800445 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  800445:	55                   	push   %ebp
  800446:	89 e5                	mov    %esp,%ebp
  800448:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  80044b:	8b 45 08             	mov    0x8(%ebp),%eax
  80044e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  800451:	eb 1e                	jmp    800471 <strncpy+0x2c>
        if ((*p = *src) != '\0') {
  800453:	8b 45 0c             	mov    0xc(%ebp),%eax
  800456:	0f b6 10             	movzbl (%eax),%edx
  800459:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80045c:	88 10                	mov    %dl,(%eax)
  80045e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800461:	0f b6 00             	movzbl (%eax),%eax
  800464:	84 c0                	test   %al,%al
  800466:	74 03                	je     80046b <strncpy+0x26>
            src ++;
  800468:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
  80046b:	ff 45 fc             	incl   -0x4(%ebp)
  80046e:	ff 4d 10             	decl   0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
  800471:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800475:	75 dc                	jne    800453 <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
  800477:	8b 45 08             	mov    0x8(%ebp),%eax
}
  80047a:	c9                   	leave  
  80047b:	c3                   	ret    

0080047c <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  80047c:	55                   	push   %ebp
  80047d:	89 e5                	mov    %esp,%ebp
  80047f:	57                   	push   %edi
  800480:	56                   	push   %esi
  800481:	83 ec 20             	sub    $0x20,%esp
  800484:	8b 45 08             	mov    0x8(%ebp),%eax
  800487:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80048a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80048d:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
  800490:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800493:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800496:	89 d1                	mov    %edx,%ecx
  800498:	89 c2                	mov    %eax,%edx
  80049a:	89 ce                	mov    %ecx,%esi
  80049c:	89 d7                	mov    %edx,%edi
  80049e:	ac                   	lods   %ds:(%esi),%al
  80049f:	ae                   	scas   %es:(%edi),%al
  8004a0:	75 08                	jne    8004aa <strcmp+0x2e>
  8004a2:	84 c0                	test   %al,%al
  8004a4:	75 f8                	jne    80049e <strcmp+0x22>
  8004a6:	31 c0                	xor    %eax,%eax
  8004a8:	eb 04                	jmp    8004ae <strcmp+0x32>
  8004aa:	19 c0                	sbb    %eax,%eax
  8004ac:	0c 01                	or     $0x1,%al
  8004ae:	89 fa                	mov    %edi,%edx
  8004b0:	89 f1                	mov    %esi,%ecx
  8004b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8004b5:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  8004b8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
  8004bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
  8004be:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  8004bf:	83 c4 20             	add    $0x20,%esp
  8004c2:	5e                   	pop    %esi
  8004c3:	5f                   	pop    %edi
  8004c4:	5d                   	pop    %ebp
  8004c5:	c3                   	ret    

008004c6 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  8004c6:	55                   	push   %ebp
  8004c7:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  8004c9:	eb 09                	jmp    8004d4 <strncmp+0xe>
        n --, s1 ++, s2 ++;
  8004cb:	ff 4d 10             	decl   0x10(%ebp)
  8004ce:	ff 45 08             	incl   0x8(%ebp)
  8004d1:	ff 45 0c             	incl   0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  8004d4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8004d8:	74 1a                	je     8004f4 <strncmp+0x2e>
  8004da:	8b 45 08             	mov    0x8(%ebp),%eax
  8004dd:	0f b6 00             	movzbl (%eax),%eax
  8004e0:	84 c0                	test   %al,%al
  8004e2:	74 10                	je     8004f4 <strncmp+0x2e>
  8004e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e7:	0f b6 10             	movzbl (%eax),%edx
  8004ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ed:	0f b6 00             	movzbl (%eax),%eax
  8004f0:	38 c2                	cmp    %al,%dl
  8004f2:	74 d7                	je     8004cb <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  8004f4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8004f8:	74 18                	je     800512 <strncmp+0x4c>
  8004fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fd:	0f b6 00             	movzbl (%eax),%eax
  800500:	0f b6 d0             	movzbl %al,%edx
  800503:	8b 45 0c             	mov    0xc(%ebp),%eax
  800506:	0f b6 00             	movzbl (%eax),%eax
  800509:	0f b6 c0             	movzbl %al,%eax
  80050c:	29 c2                	sub    %eax,%edx
  80050e:	89 d0                	mov    %edx,%eax
  800510:	eb 05                	jmp    800517 <strncmp+0x51>
  800512:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800517:	5d                   	pop    %ebp
  800518:	c3                   	ret    

00800519 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  800519:	55                   	push   %ebp
  80051a:	89 e5                	mov    %esp,%ebp
  80051c:	83 ec 04             	sub    $0x4,%esp
  80051f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800522:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  800525:	eb 13                	jmp    80053a <strchr+0x21>
        if (*s == c) {
  800527:	8b 45 08             	mov    0x8(%ebp),%eax
  80052a:	0f b6 00             	movzbl (%eax),%eax
  80052d:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800530:	75 05                	jne    800537 <strchr+0x1e>
            return (char *)s;
  800532:	8b 45 08             	mov    0x8(%ebp),%eax
  800535:	eb 12                	jmp    800549 <strchr+0x30>
        }
        s ++;
  800537:	ff 45 08             	incl   0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
  80053a:	8b 45 08             	mov    0x8(%ebp),%eax
  80053d:	0f b6 00             	movzbl (%eax),%eax
  800540:	84 c0                	test   %al,%al
  800542:	75 e3                	jne    800527 <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
  800544:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800549:	c9                   	leave  
  80054a:	c3                   	ret    

0080054b <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  80054b:	55                   	push   %ebp
  80054c:	89 e5                	mov    %esp,%ebp
  80054e:	83 ec 04             	sub    $0x4,%esp
  800551:	8b 45 0c             	mov    0xc(%ebp),%eax
  800554:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  800557:	eb 0e                	jmp    800567 <strfind+0x1c>
        if (*s == c) {
  800559:	8b 45 08             	mov    0x8(%ebp),%eax
  80055c:	0f b6 00             	movzbl (%eax),%eax
  80055f:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800562:	74 0f                	je     800573 <strfind+0x28>
            break;
        }
        s ++;
  800564:	ff 45 08             	incl   0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
  800567:	8b 45 08             	mov    0x8(%ebp),%eax
  80056a:	0f b6 00             	movzbl (%eax),%eax
  80056d:	84 c0                	test   %al,%al
  80056f:	75 e8                	jne    800559 <strfind+0xe>
  800571:	eb 01                	jmp    800574 <strfind+0x29>
        if (*s == c) {
            break;
  800573:	90                   	nop
        }
        s ++;
    }
    return (char *)s;
  800574:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800577:	c9                   	leave  
  800578:	c3                   	ret    

00800579 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  800579:	55                   	push   %ebp
  80057a:	89 e5                	mov    %esp,%ebp
  80057c:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  80057f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  800586:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  80058d:	eb 03                	jmp    800592 <strtol+0x19>
        s ++;
  80058f:	ff 45 08             	incl   0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  800592:	8b 45 08             	mov    0x8(%ebp),%eax
  800595:	0f b6 00             	movzbl (%eax),%eax
  800598:	3c 20                	cmp    $0x20,%al
  80059a:	74 f3                	je     80058f <strtol+0x16>
  80059c:	8b 45 08             	mov    0x8(%ebp),%eax
  80059f:	0f b6 00             	movzbl (%eax),%eax
  8005a2:	3c 09                	cmp    $0x9,%al
  8005a4:	74 e9                	je     80058f <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
  8005a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8005a9:	0f b6 00             	movzbl (%eax),%eax
  8005ac:	3c 2b                	cmp    $0x2b,%al
  8005ae:	75 05                	jne    8005b5 <strtol+0x3c>
        s ++;
  8005b0:	ff 45 08             	incl   0x8(%ebp)
  8005b3:	eb 14                	jmp    8005c9 <strtol+0x50>
    }
    else if (*s == '-') {
  8005b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b8:	0f b6 00             	movzbl (%eax),%eax
  8005bb:	3c 2d                	cmp    $0x2d,%al
  8005bd:	75 0a                	jne    8005c9 <strtol+0x50>
        s ++, neg = 1;
  8005bf:	ff 45 08             	incl   0x8(%ebp)
  8005c2:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  8005c9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8005cd:	74 06                	je     8005d5 <strtol+0x5c>
  8005cf:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  8005d3:	75 22                	jne    8005f7 <strtol+0x7e>
  8005d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d8:	0f b6 00             	movzbl (%eax),%eax
  8005db:	3c 30                	cmp    $0x30,%al
  8005dd:	75 18                	jne    8005f7 <strtol+0x7e>
  8005df:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e2:	40                   	inc    %eax
  8005e3:	0f b6 00             	movzbl (%eax),%eax
  8005e6:	3c 78                	cmp    $0x78,%al
  8005e8:	75 0d                	jne    8005f7 <strtol+0x7e>
        s += 2, base = 16;
  8005ea:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  8005ee:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  8005f5:	eb 29                	jmp    800620 <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
  8005f7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8005fb:	75 16                	jne    800613 <strtol+0x9a>
  8005fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800600:	0f b6 00             	movzbl (%eax),%eax
  800603:	3c 30                	cmp    $0x30,%al
  800605:	75 0c                	jne    800613 <strtol+0x9a>
        s ++, base = 8;
  800607:	ff 45 08             	incl   0x8(%ebp)
  80060a:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800611:	eb 0d                	jmp    800620 <strtol+0xa7>
    }
    else if (base == 0) {
  800613:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800617:	75 07                	jne    800620 <strtol+0xa7>
        base = 10;
  800619:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  800620:	8b 45 08             	mov    0x8(%ebp),%eax
  800623:	0f b6 00             	movzbl (%eax),%eax
  800626:	3c 2f                	cmp    $0x2f,%al
  800628:	7e 1b                	jle    800645 <strtol+0xcc>
  80062a:	8b 45 08             	mov    0x8(%ebp),%eax
  80062d:	0f b6 00             	movzbl (%eax),%eax
  800630:	3c 39                	cmp    $0x39,%al
  800632:	7f 11                	jg     800645 <strtol+0xcc>
            dig = *s - '0';
  800634:	8b 45 08             	mov    0x8(%ebp),%eax
  800637:	0f b6 00             	movzbl (%eax),%eax
  80063a:	0f be c0             	movsbl %al,%eax
  80063d:	83 e8 30             	sub    $0x30,%eax
  800640:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800643:	eb 48                	jmp    80068d <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
  800645:	8b 45 08             	mov    0x8(%ebp),%eax
  800648:	0f b6 00             	movzbl (%eax),%eax
  80064b:	3c 60                	cmp    $0x60,%al
  80064d:	7e 1b                	jle    80066a <strtol+0xf1>
  80064f:	8b 45 08             	mov    0x8(%ebp),%eax
  800652:	0f b6 00             	movzbl (%eax),%eax
  800655:	3c 7a                	cmp    $0x7a,%al
  800657:	7f 11                	jg     80066a <strtol+0xf1>
            dig = *s - 'a' + 10;
  800659:	8b 45 08             	mov    0x8(%ebp),%eax
  80065c:	0f b6 00             	movzbl (%eax),%eax
  80065f:	0f be c0             	movsbl %al,%eax
  800662:	83 e8 57             	sub    $0x57,%eax
  800665:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800668:	eb 23                	jmp    80068d <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  80066a:	8b 45 08             	mov    0x8(%ebp),%eax
  80066d:	0f b6 00             	movzbl (%eax),%eax
  800670:	3c 40                	cmp    $0x40,%al
  800672:	7e 3b                	jle    8006af <strtol+0x136>
  800674:	8b 45 08             	mov    0x8(%ebp),%eax
  800677:	0f b6 00             	movzbl (%eax),%eax
  80067a:	3c 5a                	cmp    $0x5a,%al
  80067c:	7f 31                	jg     8006af <strtol+0x136>
            dig = *s - 'A' + 10;
  80067e:	8b 45 08             	mov    0x8(%ebp),%eax
  800681:	0f b6 00             	movzbl (%eax),%eax
  800684:	0f be c0             	movsbl %al,%eax
  800687:	83 e8 37             	sub    $0x37,%eax
  80068a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  80068d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800690:	3b 45 10             	cmp    0x10(%ebp),%eax
  800693:	7d 19                	jge    8006ae <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
  800695:	ff 45 08             	incl   0x8(%ebp)
  800698:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80069b:	0f af 45 10          	imul   0x10(%ebp),%eax
  80069f:	89 c2                	mov    %eax,%edx
  8006a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006a4:	01 d0                	add    %edx,%eax
  8006a6:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
  8006a9:	e9 72 ff ff ff       	jmp    800620 <strtol+0xa7>
        }
        else {
            break;
        }
        if (dig >= base) {
            break;
  8006ae:	90                   	nop
        }
        s ++, val = (val * base) + dig;
        // we don't properly detect overflow!
    }

    if (endptr) {
  8006af:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006b3:	74 08                	je     8006bd <strtol+0x144>
        *endptr = (char *) s;
  8006b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8006bb:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  8006bd:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  8006c1:	74 07                	je     8006ca <strtol+0x151>
  8006c3:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8006c6:	f7 d8                	neg    %eax
  8006c8:	eb 03                	jmp    8006cd <strtol+0x154>
  8006ca:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8006cd:	c9                   	leave  
  8006ce:	c3                   	ret    

008006cf <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  8006cf:	55                   	push   %ebp
  8006d0:	89 e5                	mov    %esp,%ebp
  8006d2:	57                   	push   %edi
  8006d3:	83 ec 24             	sub    $0x24,%esp
  8006d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006d9:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  8006dc:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8006e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8006e3:	89 55 f8             	mov    %edx,-0x8(%ebp)
  8006e6:	88 45 f7             	mov    %al,-0x9(%ebp)
  8006e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8006ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  8006ef:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8006f2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8006f6:	8b 55 f8             	mov    -0x8(%ebp),%edx
  8006f9:	89 d7                	mov    %edx,%edi
  8006fb:	f3 aa                	rep stos %al,%es:(%edi)
  8006fd:	89 fa                	mov    %edi,%edx
  8006ff:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  800702:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  800705:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800708:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  800709:	83 c4 24             	add    $0x24,%esp
  80070c:	5f                   	pop    %edi
  80070d:	5d                   	pop    %ebp
  80070e:	c3                   	ret    

0080070f <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  80070f:	55                   	push   %ebp
  800710:	89 e5                	mov    %esp,%ebp
  800712:	57                   	push   %edi
  800713:	56                   	push   %esi
  800714:	53                   	push   %ebx
  800715:	83 ec 30             	sub    $0x30,%esp
  800718:	8b 45 08             	mov    0x8(%ebp),%eax
  80071b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80071e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800721:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800724:	8b 45 10             	mov    0x10(%ebp),%eax
  800727:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  80072a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80072d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800730:	73 42                	jae    800774 <memmove+0x65>
  800732:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800735:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800738:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80073b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80073e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800741:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  800744:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800747:	c1 e8 02             	shr    $0x2,%eax
  80074a:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  80074c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80074f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800752:	89 d7                	mov    %edx,%edi
  800754:	89 c6                	mov    %eax,%esi
  800756:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800758:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80075b:	83 e1 03             	and    $0x3,%ecx
  80075e:	74 02                	je     800762 <memmove+0x53>
  800760:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  800762:	89 f0                	mov    %esi,%eax
  800764:	89 fa                	mov    %edi,%edx
  800766:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800769:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80076c:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
  80076f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
  800772:	eb 36                	jmp    8007aa <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  800774:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800777:	8d 50 ff             	lea    -0x1(%eax),%edx
  80077a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80077d:	01 c2                	add    %eax,%edx
  80077f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800782:	8d 48 ff             	lea    -0x1(%eax),%ecx
  800785:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800788:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
  80078b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80078e:	89 c1                	mov    %eax,%ecx
  800790:	89 d8                	mov    %ebx,%eax
  800792:	89 d6                	mov    %edx,%esi
  800794:	89 c7                	mov    %eax,%edi
  800796:	fd                   	std    
  800797:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  800799:	fc                   	cld    
  80079a:	89 f8                	mov    %edi,%eax
  80079c:	89 f2                	mov    %esi,%edx
  80079e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8007a1:	89 55 c8             	mov    %edx,-0x38(%ebp)
  8007a4:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
  8007a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  8007aa:	83 c4 30             	add    $0x30,%esp
  8007ad:	5b                   	pop    %ebx
  8007ae:	5e                   	pop    %esi
  8007af:	5f                   	pop    %edi
  8007b0:	5d                   	pop    %ebp
  8007b1:	c3                   	ret    

008007b2 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	57                   	push   %edi
  8007b6:	56                   	push   %esi
  8007b7:	83 ec 20             	sub    $0x20,%esp
  8007ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8007c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007c6:	8b 45 10             	mov    0x10(%ebp),%eax
  8007c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  8007cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007cf:	c1 e8 02             	shr    $0x2,%eax
  8007d2:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  8007d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007da:	89 d7                	mov    %edx,%edi
  8007dc:	89 c6                	mov    %eax,%esi
  8007de:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8007e0:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  8007e3:	83 e1 03             	and    $0x3,%ecx
  8007e6:	74 02                	je     8007ea <memcpy+0x38>
  8007e8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  8007ea:	89 f0                	mov    %esi,%eax
  8007ec:	89 fa                	mov    %edi,%edx
  8007ee:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  8007f1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
  8007f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
  8007fa:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  8007fb:	83 c4 20             	add    $0x20,%esp
  8007fe:	5e                   	pop    %esi
  8007ff:	5f                   	pop    %edi
  800800:	5d                   	pop    %ebp
  800801:	c3                   	ret    

00800802 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  800808:	8b 45 08             	mov    0x8(%ebp),%eax
  80080b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  80080e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800811:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  800814:	eb 2e                	jmp    800844 <memcmp+0x42>
        if (*s1 != *s2) {
  800816:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800819:	0f b6 10             	movzbl (%eax),%edx
  80081c:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80081f:	0f b6 00             	movzbl (%eax),%eax
  800822:	38 c2                	cmp    %al,%dl
  800824:	74 18                	je     80083e <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  800826:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800829:	0f b6 00             	movzbl (%eax),%eax
  80082c:	0f b6 d0             	movzbl %al,%edx
  80082f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800832:	0f b6 00             	movzbl (%eax),%eax
  800835:	0f b6 c0             	movzbl %al,%eax
  800838:	29 c2                	sub    %eax,%edx
  80083a:	89 d0                	mov    %edx,%eax
  80083c:	eb 18                	jmp    800856 <memcmp+0x54>
        }
        s1 ++, s2 ++;
  80083e:	ff 45 fc             	incl   -0x4(%ebp)
  800841:	ff 45 f8             	incl   -0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
  800844:	8b 45 10             	mov    0x10(%ebp),%eax
  800847:	8d 50 ff             	lea    -0x1(%eax),%edx
  80084a:	89 55 10             	mov    %edx,0x10(%ebp)
  80084d:	85 c0                	test   %eax,%eax
  80084f:	75 c5                	jne    800816 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
  800851:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800856:	c9                   	leave  
  800857:	c3                   	ret    

00800858 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	83 ec 58             	sub    $0x58,%esp
  80085e:	8b 45 10             	mov    0x10(%ebp),%eax
  800861:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800864:	8b 45 14             	mov    0x14(%ebp),%eax
  800867:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  80086a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80086d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800870:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800873:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  800876:	8b 45 18             	mov    0x18(%ebp),%eax
  800879:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80087c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80087f:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800882:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800885:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800888:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80088b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80088e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800892:	74 1c                	je     8008b0 <printnum+0x58>
  800894:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800897:	ba 00 00 00 00       	mov    $0x0,%edx
  80089c:	f7 75 e4             	divl   -0x1c(%ebp)
  80089f:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8008a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8008aa:	f7 75 e4             	divl   -0x1c(%ebp)
  8008ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8008b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008b6:	f7 75 e4             	divl   -0x1c(%ebp)
  8008b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008bc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008c2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8008c5:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8008c8:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8008cb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8008ce:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  8008d1:	8b 45 18             	mov    0x18(%ebp),%eax
  8008d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8008d9:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  8008dc:	77 56                	ja     800934 <printnum+0xdc>
  8008de:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  8008e1:	72 05                	jb     8008e8 <printnum+0x90>
  8008e3:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  8008e6:	77 4c                	ja     800934 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
  8008e8:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8008eb:	8d 50 ff             	lea    -0x1(%eax),%edx
  8008ee:	8b 45 20             	mov    0x20(%ebp),%eax
  8008f1:	89 44 24 18          	mov    %eax,0x18(%esp)
  8008f5:	89 54 24 14          	mov    %edx,0x14(%esp)
  8008f9:	8b 45 18             	mov    0x18(%ebp),%eax
  8008fc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800900:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800903:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800906:	89 44 24 08          	mov    %eax,0x8(%esp)
  80090a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80090e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800911:	89 44 24 04          	mov    %eax,0x4(%esp)
  800915:	8b 45 08             	mov    0x8(%ebp),%eax
  800918:	89 04 24             	mov    %eax,(%esp)
  80091b:	e8 38 ff ff ff       	call   800858 <printnum>
  800920:	eb 1b                	jmp    80093d <printnum+0xe5>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  800922:	8b 45 0c             	mov    0xc(%ebp),%eax
  800925:	89 44 24 04          	mov    %eax,0x4(%esp)
  800929:	8b 45 20             	mov    0x20(%ebp),%eax
  80092c:	89 04 24             	mov    %eax,(%esp)
  80092f:	8b 45 08             	mov    0x8(%ebp),%eax
  800932:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800934:	ff 4d 1c             	decl   0x1c(%ebp)
  800937:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  80093b:	7f e5                	jg     800922 <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  80093d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800940:	05 04 12 80 00       	add    $0x801204,%eax
  800945:	0f b6 00             	movzbl (%eax),%eax
  800948:	0f be c0             	movsbl %al,%eax
  80094b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800952:	89 04 24             	mov    %eax,(%esp)
  800955:	8b 45 08             	mov    0x8(%ebp),%eax
  800958:	ff d0                	call   *%eax
}
  80095a:	90                   	nop
  80095b:	c9                   	leave  
  80095c:	c3                   	ret    

0080095d <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  800960:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800964:	7e 14                	jle    80097a <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  800966:	8b 45 08             	mov    0x8(%ebp),%eax
  800969:	8b 00                	mov    (%eax),%eax
  80096b:	8d 48 08             	lea    0x8(%eax),%ecx
  80096e:	8b 55 08             	mov    0x8(%ebp),%edx
  800971:	89 0a                	mov    %ecx,(%edx)
  800973:	8b 50 04             	mov    0x4(%eax),%edx
  800976:	8b 00                	mov    (%eax),%eax
  800978:	eb 30                	jmp    8009aa <getuint+0x4d>
    }
    else if (lflag) {
  80097a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80097e:	74 16                	je     800996 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  800980:	8b 45 08             	mov    0x8(%ebp),%eax
  800983:	8b 00                	mov    (%eax),%eax
  800985:	8d 48 04             	lea    0x4(%eax),%ecx
  800988:	8b 55 08             	mov    0x8(%ebp),%edx
  80098b:	89 0a                	mov    %ecx,(%edx)
  80098d:	8b 00                	mov    (%eax),%eax
  80098f:	ba 00 00 00 00       	mov    $0x0,%edx
  800994:	eb 14                	jmp    8009aa <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  800996:	8b 45 08             	mov    0x8(%ebp),%eax
  800999:	8b 00                	mov    (%eax),%eax
  80099b:	8d 48 04             	lea    0x4(%eax),%ecx
  80099e:	8b 55 08             	mov    0x8(%ebp),%edx
  8009a1:	89 0a                	mov    %ecx,(%edx)
  8009a3:	8b 00                	mov    (%eax),%eax
  8009a5:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  8009aa:	5d                   	pop    %ebp
  8009ab:	c3                   	ret    

008009ac <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  8009af:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8009b3:	7e 14                	jle    8009c9 <getint+0x1d>
        return va_arg(*ap, long long);
  8009b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b8:	8b 00                	mov    (%eax),%eax
  8009ba:	8d 48 08             	lea    0x8(%eax),%ecx
  8009bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8009c0:	89 0a                	mov    %ecx,(%edx)
  8009c2:	8b 50 04             	mov    0x4(%eax),%edx
  8009c5:	8b 00                	mov    (%eax),%eax
  8009c7:	eb 28                	jmp    8009f1 <getint+0x45>
    }
    else if (lflag) {
  8009c9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009cd:	74 12                	je     8009e1 <getint+0x35>
        return va_arg(*ap, long);
  8009cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d2:	8b 00                	mov    (%eax),%eax
  8009d4:	8d 48 04             	lea    0x4(%eax),%ecx
  8009d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8009da:	89 0a                	mov    %ecx,(%edx)
  8009dc:	8b 00                	mov    (%eax),%eax
  8009de:	99                   	cltd   
  8009df:	eb 10                	jmp    8009f1 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  8009e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e4:	8b 00                	mov    (%eax),%eax
  8009e6:	8d 48 04             	lea    0x4(%eax),%ecx
  8009e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8009ec:	89 0a                	mov    %ecx,(%edx)
  8009ee:	8b 00                	mov    (%eax),%eax
  8009f0:	99                   	cltd   
    }
}
  8009f1:	5d                   	pop    %ebp
  8009f2:	c3                   	ret    

008009f3 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  8009f9:	8d 45 14             	lea    0x14(%ebp),%eax
  8009fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  8009ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a02:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a06:	8b 45 10             	mov    0x10(%ebp),%eax
  800a09:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a10:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a14:	8b 45 08             	mov    0x8(%ebp),%eax
  800a17:	89 04 24             	mov    %eax,(%esp)
  800a1a:	e8 03 00 00 00       	call   800a22 <vprintfmt>
    va_end(ap);
}
  800a1f:	90                   	nop
  800a20:	c9                   	leave  
  800a21:	c3                   	ret    

00800a22 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	56                   	push   %esi
  800a26:	53                   	push   %ebx
  800a27:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800a2a:	eb 17                	jmp    800a43 <vprintfmt+0x21>
            if (ch == '\0') {
  800a2c:	85 db                	test   %ebx,%ebx
  800a2e:	0f 84 bf 03 00 00    	je     800df3 <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
  800a34:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a37:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a3b:	89 1c 24             	mov    %ebx,(%esp)
  800a3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a41:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800a43:	8b 45 10             	mov    0x10(%ebp),%eax
  800a46:	8d 50 01             	lea    0x1(%eax),%edx
  800a49:	89 55 10             	mov    %edx,0x10(%ebp)
  800a4c:	0f b6 00             	movzbl (%eax),%eax
  800a4f:	0f b6 d8             	movzbl %al,%ebx
  800a52:	83 fb 25             	cmp    $0x25,%ebx
  800a55:	75 d5                	jne    800a2c <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
  800a57:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  800a5b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800a62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a65:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  800a68:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800a6f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a72:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  800a75:	8b 45 10             	mov    0x10(%ebp),%eax
  800a78:	8d 50 01             	lea    0x1(%eax),%edx
  800a7b:	89 55 10             	mov    %edx,0x10(%ebp)
  800a7e:	0f b6 00             	movzbl (%eax),%eax
  800a81:	0f b6 d8             	movzbl %al,%ebx
  800a84:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800a87:	83 f8 55             	cmp    $0x55,%eax
  800a8a:	0f 87 37 03 00 00    	ja     800dc7 <vprintfmt+0x3a5>
  800a90:	8b 04 85 28 12 80 00 	mov    0x801228(,%eax,4),%eax
  800a97:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  800a99:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  800a9d:	eb d6                	jmp    800a75 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  800a9f:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  800aa3:	eb d0                	jmp    800a75 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  800aa5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  800aac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800aaf:	89 d0                	mov    %edx,%eax
  800ab1:	c1 e0 02             	shl    $0x2,%eax
  800ab4:	01 d0                	add    %edx,%eax
  800ab6:	01 c0                	add    %eax,%eax
  800ab8:	01 d8                	add    %ebx,%eax
  800aba:	83 e8 30             	sub    $0x30,%eax
  800abd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  800ac0:	8b 45 10             	mov    0x10(%ebp),%eax
  800ac3:	0f b6 00             	movzbl (%eax),%eax
  800ac6:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  800ac9:	83 fb 2f             	cmp    $0x2f,%ebx
  800acc:	7e 38                	jle    800b06 <vprintfmt+0xe4>
  800ace:	83 fb 39             	cmp    $0x39,%ebx
  800ad1:	7f 33                	jg     800b06 <vprintfmt+0xe4>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  800ad3:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
  800ad6:	eb d4                	jmp    800aac <vprintfmt+0x8a>
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  800ad8:	8b 45 14             	mov    0x14(%ebp),%eax
  800adb:	8d 50 04             	lea    0x4(%eax),%edx
  800ade:	89 55 14             	mov    %edx,0x14(%ebp)
  800ae1:	8b 00                	mov    (%eax),%eax
  800ae3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  800ae6:	eb 1f                	jmp    800b07 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
  800ae8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800aec:	79 87                	jns    800a75 <vprintfmt+0x53>
                width = 0;
  800aee:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  800af5:	e9 7b ff ff ff       	jmp    800a75 <vprintfmt+0x53>

        case '#':
            altflag = 1;
  800afa:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  800b01:	e9 6f ff ff ff       	jmp    800a75 <vprintfmt+0x53>
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
            goto process_precision;
  800b06:	90                   	nop
        case '#':
            altflag = 1;
            goto reswitch;

        process_precision:
            if (width < 0)
  800b07:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800b0b:	0f 89 64 ff ff ff    	jns    800a75 <vprintfmt+0x53>
                width = precision, precision = -1;
  800b11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800b14:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800b17:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  800b1e:	e9 52 ff ff ff       	jmp    800a75 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  800b23:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
  800b26:	e9 4a ff ff ff       	jmp    800a75 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  800b2b:	8b 45 14             	mov    0x14(%ebp),%eax
  800b2e:	8d 50 04             	lea    0x4(%eax),%edx
  800b31:	89 55 14             	mov    %edx,0x14(%ebp)
  800b34:	8b 00                	mov    (%eax),%eax
  800b36:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b39:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b3d:	89 04 24             	mov    %eax,(%esp)
  800b40:	8b 45 08             	mov    0x8(%ebp),%eax
  800b43:	ff d0                	call   *%eax
            break;
  800b45:	e9 a4 02 00 00       	jmp    800dee <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
  800b4a:	8b 45 14             	mov    0x14(%ebp),%eax
  800b4d:	8d 50 04             	lea    0x4(%eax),%edx
  800b50:	89 55 14             	mov    %edx,0x14(%ebp)
  800b53:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  800b55:	85 db                	test   %ebx,%ebx
  800b57:	79 02                	jns    800b5b <vprintfmt+0x139>
                err = -err;
  800b59:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800b5b:	83 fb 18             	cmp    $0x18,%ebx
  800b5e:	7f 0b                	jg     800b6b <vprintfmt+0x149>
  800b60:	8b 34 9d a0 11 80 00 	mov    0x8011a0(,%ebx,4),%esi
  800b67:	85 f6                	test   %esi,%esi
  800b69:	75 23                	jne    800b8e <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
  800b6b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800b6f:	c7 44 24 08 15 12 80 	movl   $0x801215,0x8(%esp)
  800b76:	00 
  800b77:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b7a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b81:	89 04 24             	mov    %eax,(%esp)
  800b84:	e8 6a fe ff ff       	call   8009f3 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  800b89:	e9 60 02 00 00       	jmp    800dee <vprintfmt+0x3cc>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
  800b8e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800b92:	c7 44 24 08 1e 12 80 	movl   $0x80121e,0x8(%esp)
  800b99:	00 
  800b9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ba1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba4:	89 04 24             	mov    %eax,(%esp)
  800ba7:	e8 47 fe ff ff       	call   8009f3 <printfmt>
            }
            break;
  800bac:	e9 3d 02 00 00       	jmp    800dee <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  800bb1:	8b 45 14             	mov    0x14(%ebp),%eax
  800bb4:	8d 50 04             	lea    0x4(%eax),%edx
  800bb7:	89 55 14             	mov    %edx,0x14(%ebp)
  800bba:	8b 30                	mov    (%eax),%esi
  800bbc:	85 f6                	test   %esi,%esi
  800bbe:	75 05                	jne    800bc5 <vprintfmt+0x1a3>
                p = "(null)";
  800bc0:	be 21 12 80 00       	mov    $0x801221,%esi
            }
            if (width > 0 && padc != '-') {
  800bc5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800bc9:	7e 76                	jle    800c41 <vprintfmt+0x21f>
  800bcb:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800bcf:	74 70                	je     800c41 <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800bd1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800bd4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bd8:	89 34 24             	mov    %esi,(%esp)
  800bdb:	e8 f6 f7 ff ff       	call   8003d6 <strnlen>
  800be0:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800be3:	29 c2                	sub    %eax,%edx
  800be5:	89 d0                	mov    %edx,%eax
  800be7:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800bea:	eb 16                	jmp    800c02 <vprintfmt+0x1e0>
                    putch(padc, putdat);
  800bec:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800bf0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bf3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bf7:	89 04 24             	mov    %eax,(%esp)
  800bfa:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfd:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
  800bff:	ff 4d e8             	decl   -0x18(%ebp)
  800c02:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800c06:	7f e4                	jg     800bec <vprintfmt+0x1ca>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800c08:	eb 37                	jmp    800c41 <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
  800c0a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800c0e:	74 1f                	je     800c2f <vprintfmt+0x20d>
  800c10:	83 fb 1f             	cmp    $0x1f,%ebx
  800c13:	7e 05                	jle    800c1a <vprintfmt+0x1f8>
  800c15:	83 fb 7e             	cmp    $0x7e,%ebx
  800c18:	7e 15                	jle    800c2f <vprintfmt+0x20d>
                    putch('?', putdat);
  800c1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c21:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800c28:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2b:	ff d0                	call   *%eax
  800c2d:	eb 0f                	jmp    800c3e <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
  800c2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c32:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c36:	89 1c 24             	mov    %ebx,(%esp)
  800c39:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3c:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800c3e:	ff 4d e8             	decl   -0x18(%ebp)
  800c41:	89 f0                	mov    %esi,%eax
  800c43:	8d 70 01             	lea    0x1(%eax),%esi
  800c46:	0f b6 00             	movzbl (%eax),%eax
  800c49:	0f be d8             	movsbl %al,%ebx
  800c4c:	85 db                	test   %ebx,%ebx
  800c4e:	74 27                	je     800c77 <vprintfmt+0x255>
  800c50:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c54:	78 b4                	js     800c0a <vprintfmt+0x1e8>
  800c56:	ff 4d e4             	decl   -0x1c(%ebp)
  800c59:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c5d:	79 ab                	jns    800c0a <vprintfmt+0x1e8>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  800c5f:	eb 16                	jmp    800c77 <vprintfmt+0x255>
                putch(' ', putdat);
  800c61:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c64:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c68:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800c6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c72:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  800c74:	ff 4d e8             	decl   -0x18(%ebp)
  800c77:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800c7b:	7f e4                	jg     800c61 <vprintfmt+0x23f>
                putch(' ', putdat);
            }
            break;
  800c7d:	e9 6c 01 00 00       	jmp    800dee <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  800c82:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800c85:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c89:	8d 45 14             	lea    0x14(%ebp),%eax
  800c8c:	89 04 24             	mov    %eax,(%esp)
  800c8f:	e8 18 fd ff ff       	call   8009ac <getint>
  800c94:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800c97:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  800c9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c9d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ca0:	85 d2                	test   %edx,%edx
  800ca2:	79 26                	jns    800cca <vprintfmt+0x2a8>
                putch('-', putdat);
  800ca4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ca7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cab:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800cb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb5:	ff d0                	call   *%eax
                num = -(long long)num;
  800cb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800cbd:	f7 d8                	neg    %eax
  800cbf:	83 d2 00             	adc    $0x0,%edx
  800cc2:	f7 da                	neg    %edx
  800cc4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800cc7:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  800cca:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  800cd1:	e9 a8 00 00 00       	jmp    800d7e <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  800cd6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800cd9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cdd:	8d 45 14             	lea    0x14(%ebp),%eax
  800ce0:	89 04 24             	mov    %eax,(%esp)
  800ce3:	e8 75 fc ff ff       	call   80095d <getuint>
  800ce8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800ceb:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  800cee:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  800cf5:	e9 84 00 00 00       	jmp    800d7e <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  800cfa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800cfd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d01:	8d 45 14             	lea    0x14(%ebp),%eax
  800d04:	89 04 24             	mov    %eax,(%esp)
  800d07:	e8 51 fc ff ff       	call   80095d <getuint>
  800d0c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800d0f:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  800d12:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  800d19:	eb 63                	jmp    800d7e <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
  800d1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d22:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800d29:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2c:	ff d0                	call   *%eax
            putch('x', putdat);
  800d2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d31:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d35:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800d3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3f:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800d41:	8b 45 14             	mov    0x14(%ebp),%eax
  800d44:	8d 50 04             	lea    0x4(%eax),%edx
  800d47:	89 55 14             	mov    %edx,0x14(%ebp)
  800d4a:	8b 00                	mov    (%eax),%eax
  800d4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800d4f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  800d56:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  800d5d:	eb 1f                	jmp    800d7e <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  800d5f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d62:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d66:	8d 45 14             	lea    0x14(%ebp),%eax
  800d69:	89 04 24             	mov    %eax,(%esp)
  800d6c:	e8 ec fb ff ff       	call   80095d <getuint>
  800d71:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800d74:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  800d77:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  800d7e:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800d82:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d85:	89 54 24 18          	mov    %edx,0x18(%esp)
  800d89:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800d8c:	89 54 24 14          	mov    %edx,0x14(%esp)
  800d90:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d94:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d97:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d9a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d9e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800da2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800da5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800da9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dac:	89 04 24             	mov    %eax,(%esp)
  800daf:	e8 a4 fa ff ff       	call   800858 <printnum>
            break;
  800db4:	eb 38                	jmp    800dee <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  800db6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800db9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dbd:	89 1c 24             	mov    %ebx,(%esp)
  800dc0:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc3:	ff d0                	call   *%eax
            break;
  800dc5:	eb 27                	jmp    800dee <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  800dc7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dca:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dce:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800dd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd8:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  800dda:	ff 4d 10             	decl   0x10(%ebp)
  800ddd:	eb 03                	jmp    800de2 <vprintfmt+0x3c0>
  800ddf:	ff 4d 10             	decl   0x10(%ebp)
  800de2:	8b 45 10             	mov    0x10(%ebp),%eax
  800de5:	48                   	dec    %eax
  800de6:	0f b6 00             	movzbl (%eax),%eax
  800de9:	3c 25                	cmp    $0x25,%al
  800deb:	75 f2                	jne    800ddf <vprintfmt+0x3bd>
                /* do nothing */;
            break;
  800ded:	90                   	nop
        }
    }
  800dee:	e9 37 fc ff ff       	jmp    800a2a <vprintfmt+0x8>
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
            if (ch == '\0') {
                return;
  800df3:	90                   	nop
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800df4:	83 c4 40             	add    $0x40,%esp
  800df7:	5b                   	pop    %ebx
  800df8:	5e                   	pop    %esi
  800df9:	5d                   	pop    %ebp
  800dfa:	c3                   	ret    

00800dfb <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  800dfe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e01:	8b 40 08             	mov    0x8(%eax),%eax
  800e04:	8d 50 01             	lea    0x1(%eax),%edx
  800e07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e0a:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  800e0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e10:	8b 10                	mov    (%eax),%edx
  800e12:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e15:	8b 40 04             	mov    0x4(%eax),%eax
  800e18:	39 c2                	cmp    %eax,%edx
  800e1a:	73 12                	jae    800e2e <sprintputch+0x33>
        *b->buf ++ = ch;
  800e1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e1f:	8b 00                	mov    (%eax),%eax
  800e21:	8d 48 01             	lea    0x1(%eax),%ecx
  800e24:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e27:	89 0a                	mov    %ecx,(%edx)
  800e29:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2c:	88 10                	mov    %dl,(%eax)
    }
}
  800e2e:	90                   	nop
  800e2f:	5d                   	pop    %ebp
  800e30:	c3                   	ret    

00800e31 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  800e31:	55                   	push   %ebp
  800e32:	89 e5                	mov    %esp,%ebp
  800e34:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  800e37:	8d 45 14             	lea    0x14(%ebp),%eax
  800e3a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  800e3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e40:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e44:	8b 45 10             	mov    0x10(%ebp),%eax
  800e47:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e52:	8b 45 08             	mov    0x8(%ebp),%eax
  800e55:	89 04 24             	mov    %eax,(%esp)
  800e58:	e8 08 00 00 00       	call   800e65 <vsnprintf>
  800e5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  800e60:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800e63:	c9                   	leave  
  800e64:	c3                   	ret    

00800e65 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  800e65:	55                   	push   %ebp
  800e66:	89 e5                	mov    %esp,%ebp
  800e68:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  800e6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e71:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e74:	8d 50 ff             	lea    -0x1(%eax),%edx
  800e77:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7a:	01 d0                	add    %edx,%eax
  800e7c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800e7f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  800e86:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800e8a:	74 0a                	je     800e96 <vsnprintf+0x31>
  800e8c:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800e8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e92:	39 c2                	cmp    %eax,%edx
  800e94:	76 07                	jbe    800e9d <vsnprintf+0x38>
        return -E_INVAL;
  800e96:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e9b:	eb 2a                	jmp    800ec7 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  800e9d:	8b 45 14             	mov    0x14(%ebp),%eax
  800ea0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ea4:	8b 45 10             	mov    0x10(%ebp),%eax
  800ea7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800eab:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800eae:	89 44 24 04          	mov    %eax,0x4(%esp)
  800eb2:	c7 04 24 fb 0d 80 00 	movl   $0x800dfb,(%esp)
  800eb9:	e8 64 fb ff ff       	call   800a22 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  800ebe:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ec1:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  800ec4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800ec7:	c9                   	leave  
  800ec8:	c3                   	ret    

00800ec9 <hash32>:
 * @bits:   the number of bits in a return value
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
  800ec9:	55                   	push   %ebp
  800eca:	89 e5                	mov    %esp,%ebp
  800ecc:	83 ec 10             	sub    $0x10,%esp
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
  800ecf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed2:	69 c0 01 00 37 9e    	imul   $0x9e370001,%eax,%eax
  800ed8:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (hash >> (32 - bits));
  800edb:	b8 20 00 00 00       	mov    $0x20,%eax
  800ee0:	2b 45 0c             	sub    0xc(%ebp),%eax
  800ee3:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800ee6:	88 c1                	mov    %al,%cl
  800ee8:	d3 ea                	shr    %cl,%edx
  800eea:	89 d0                	mov    %edx,%eax
}
  800eec:	c9                   	leave  
  800eed:	c3                   	ret    

00800eee <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
  800eee:	55                   	push   %ebp
  800eef:	89 e5                	mov    %esp,%ebp
  800ef1:	57                   	push   %edi
  800ef2:	56                   	push   %esi
  800ef3:	53                   	push   %ebx
  800ef4:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
  800ef7:	a1 00 20 80 00       	mov    0x802000,%eax
  800efc:	8b 15 04 20 80 00    	mov    0x802004,%edx
  800f02:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
  800f08:	6b f0 05             	imul   $0x5,%eax,%esi
  800f0b:	01 fe                	add    %edi,%esi
  800f0d:	bf 6d e6 ec de       	mov    $0xdeece66d,%edi
  800f12:	f7 e7                	mul    %edi
  800f14:	01 d6                	add    %edx,%esi
  800f16:	89 f2                	mov    %esi,%edx
  800f18:	83 c0 0b             	add    $0xb,%eax
  800f1b:	83 d2 00             	adc    $0x0,%edx
  800f1e:	89 c7                	mov    %eax,%edi
  800f20:	83 e7 ff             	and    $0xffffffff,%edi
  800f23:	89 f9                	mov    %edi,%ecx
  800f25:	0f b7 da             	movzwl %dx,%ebx
  800f28:	89 0d 00 20 80 00    	mov    %ecx,0x802000
  800f2e:	89 1d 04 20 80 00    	mov    %ebx,0x802004
    unsigned long long result = (next >> 12);
  800f34:	a1 00 20 80 00       	mov    0x802000,%eax
  800f39:	8b 15 04 20 80 00    	mov    0x802004,%edx
  800f3f:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  800f43:	c1 ea 0c             	shr    $0xc,%edx
  800f46:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f49:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
  800f4c:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
  800f53:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f56:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f59:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f5c:	89 55 e8             	mov    %edx,-0x18(%ebp)
  800f5f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800f62:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800f65:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800f69:	74 1c                	je     800f87 <rand+0x99>
  800f6b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800f6e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f73:	f7 75 dc             	divl   -0x24(%ebp)
  800f76:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800f79:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800f7c:	ba 00 00 00 00       	mov    $0x0,%edx
  800f81:	f7 75 dc             	divl   -0x24(%ebp)
  800f84:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800f87:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800f8a:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800f8d:	f7 75 dc             	divl   -0x24(%ebp)
  800f90:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f93:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800f96:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800f99:	8b 55 e8             	mov    -0x18(%ebp),%edx
  800f9c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f9f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800fa2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
  800fa5:	83 c4 24             	add    $0x24,%esp
  800fa8:	5b                   	pop    %ebx
  800fa9:	5e                   	pop    %esi
  800faa:	5f                   	pop    %edi
  800fab:	5d                   	pop    %ebp
  800fac:	c3                   	ret    

00800fad <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
  800fad:	55                   	push   %ebp
  800fae:	89 e5                	mov    %esp,%ebp
    next = seed;
  800fb0:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb3:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb8:	a3 00 20 80 00       	mov    %eax,0x802000
  800fbd:	89 15 04 20 80 00    	mov    %edx,0x802004
}
  800fc3:	90                   	nop
  800fc4:	5d                   	pop    %ebp
  800fc5:	c3                   	ret    

00800fc6 <forkchild>:
#define DEPTH 4

void forktree(const char *cur);

void
forkchild(const char *cur, char branch) {
  800fc6:	55                   	push   %ebp
  800fc7:	89 e5                	mov    %esp,%ebp
  800fc9:	83 ec 48             	sub    $0x48,%esp
  800fcc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fcf:	88 45 e4             	mov    %al,-0x1c(%ebp)
    char nxt[DEPTH + 1];

    if (strlen(cur) >= DEPTH)
  800fd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd5:	89 04 24             	mov    %eax,(%esp)
  800fd8:	e8 d2 f3 ff ff       	call   8003af <strlen>
  800fdd:	83 f8 03             	cmp    $0x3,%eax
  800fe0:	77 4f                	ja     801031 <forkchild+0x6b>
        return;

    snprintf(nxt, DEPTH + 1, "%s%c", cur, branch);
  800fe2:	0f be 45 e4          	movsbl -0x1c(%ebp),%eax
  800fe6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fea:	8b 45 08             	mov    0x8(%ebp),%eax
  800fed:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ff1:	c7 44 24 08 80 13 80 	movl   $0x801380,0x8(%esp)
  800ff8:	00 
  800ff9:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  801000:	00 
  801001:	8d 45 f3             	lea    -0xd(%ebp),%eax
  801004:	89 04 24             	mov    %eax,(%esp)
  801007:	e8 25 fe ff ff       	call   800e31 <snprintf>
    if (fork() == 0) {
  80100c:	e8 0d f2 ff ff       	call   80021e <fork>
  801011:	85 c0                	test   %eax,%eax
  801013:	75 1d                	jne    801032 <forkchild+0x6c>
        forktree(nxt);
  801015:	8d 45 f3             	lea    -0xd(%ebp),%eax
  801018:	89 04 24             	mov    %eax,(%esp)
  80101b:	e8 14 00 00 00       	call   801034 <forktree>
        yield();
  801020:	e8 3c f2 ff ff       	call   800261 <yield>
        exit(0);
  801025:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80102c:	e8 ce f1 ff ff       	call   8001ff <exit>
void
forkchild(const char *cur, char branch) {
    char nxt[DEPTH + 1];

    if (strlen(cur) >= DEPTH)
        return;
  801031:	90                   	nop
    if (fork() == 0) {
        forktree(nxt);
        yield();
        exit(0);
    }
}
  801032:	c9                   	leave  
  801033:	c3                   	ret    

00801034 <forktree>:

void
forktree(const char *cur) {
  801034:	55                   	push   %ebp
  801035:	89 e5                	mov    %esp,%ebp
  801037:	83 ec 18             	sub    $0x18,%esp
    cprintf("%04x: I am '%s'\n", getpid(), cur);
  80103a:	e8 43 f2 ff ff       	call   800282 <getpid>
  80103f:	8b 55 08             	mov    0x8(%ebp),%edx
  801042:	89 54 24 08          	mov    %edx,0x8(%esp)
  801046:	89 44 24 04          	mov    %eax,0x4(%esp)
  80104a:	c7 04 24 85 13 80 00 	movl   $0x801385,(%esp)
  801051:	e8 cb f2 ff ff       	call   800321 <cprintf>

    forkchild(cur, '0');
  801056:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  80105d:	00 
  80105e:	8b 45 08             	mov    0x8(%ebp),%eax
  801061:	89 04 24             	mov    %eax,(%esp)
  801064:	e8 5d ff ff ff       	call   800fc6 <forkchild>
    forkchild(cur, '1');
  801069:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  801070:	00 
  801071:	8b 45 08             	mov    0x8(%ebp),%eax
  801074:	89 04 24             	mov    %eax,(%esp)
  801077:	e8 4a ff ff ff       	call   800fc6 <forkchild>
}
  80107c:	90                   	nop
  80107d:	c9                   	leave  
  80107e:	c3                   	ret    

0080107f <main>:

int
main(void) {
  80107f:	55                   	push   %ebp
  801080:	89 e5                	mov    %esp,%ebp
  801082:	83 e4 f0             	and    $0xfffffff0,%esp
  801085:	83 ec 10             	sub    $0x10,%esp
    forktree("");
  801088:	c7 04 24 96 13 80 00 	movl   $0x801396,(%esp)
  80108f:	e8 a0 ff ff ff       	call   801034 <forktree>
    return 0;
  801094:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801099:	c9                   	leave  
  80109a:	c3                   	ret    
