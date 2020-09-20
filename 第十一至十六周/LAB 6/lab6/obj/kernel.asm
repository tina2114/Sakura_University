
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 e0 1a 00       	mov    $0x1ae000,%eax
    movl %eax, %cr3
c0100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
c0100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
c010000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
c0100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
c0100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
c0100016:	8d 05 1e 00 10 c0    	lea    0xc010001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
c010001c:	ff e0                	jmp    *%eax

c010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
c010001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
c0100020:	a3 00 e0 1a c0       	mov    %eax,0xc01ae000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 c0 12 c0       	mov    $0xc012c000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
c010002f:	e8 02 00 00 00       	call   c0100036 <kern_init>

c0100034 <spin>:

# should never get here
spin:
    jmp spin
c0100034:	eb fe                	jmp    c0100034 <spin>

c0100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
c0100036:	55                   	push   %ebp
c0100037:	89 e5                	mov    %esp,%ebp
c0100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c010003c:	ba 6c 31 1b c0       	mov    $0xc01b316c,%edx
c0100041:	b8 00 00 1b c0       	mov    $0xc01b0000,%eax
c0100046:	29 c2                	sub    %eax,%edx
c0100048:	89 d0                	mov    %edx,%eax
c010004a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100055:	00 
c0100056:	c7 04 24 00 00 1b c0 	movl   $0xc01b0000,(%esp)
c010005d:	e8 24 b9 00 00       	call   c010b986 <memset>

    cons_init();                // init the console
c0100062:	e8 f0 1e 00 00       	call   c0101f57 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 80 c2 10 c0 	movl   $0xc010c280,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 9c c2 10 c0 	movl   $0xc010c29c,(%esp)
c010007c:	e8 2d 02 00 00       	call   c01002ae <cprintf>

    print_kerninfo();
c0100081:	e8 c6 09 00 00       	call   c0100a4c <print_kerninfo>

    grade_backtrace();
c0100086:	e8 a5 00 00 00       	call   c0100130 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 c7 7a 00 00       	call   c0107b57 <pmm_init>

    pic_init();                 // init interrupt controller
c0100090:	e8 26 20 00 00       	call   c01020bb <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100095:	e8 7f 21 00 00       	call   c0102219 <idt_init>

    vmm_init();                 // init virtual memory management
c010009a:	e8 54 3c 00 00       	call   c0103cf3 <vmm_init>
    sched_init();               // init scheduler
c010009f:	e8 e6 af 00 00       	call   c010b08a <sched_init>
    proc_init();                // init process table
c01000a4:	e8 fe ac 00 00       	call   c010ada7 <proc_init>
    
    ide_init();                 // init ide devices
c01000a9:	e8 4d 0e 00 00       	call   c0100efb <ide_init>
    swap_init();                // init swap
c01000ae:	e8 1f 47 00 00       	call   c01047d2 <swap_init>

    clock_init();               // init clock interrupt
c01000b3:	e8 52 16 00 00       	call   c010170a <clock_init>
    intr_enable();              // enable irq interrupt
c01000b8:	e8 31 21 00 00       	call   c01021ee <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();
    
    cpu_idle();                 // run idle process
c01000bd:	e8 a2 ae 00 00       	call   c010af64 <cpu_idle>

c01000c2 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000c2:	55                   	push   %ebp
c01000c3:	89 e5                	mov    %esp,%ebp
c01000c5:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000c8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000cf:	00 
c01000d0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000d7:	00 
c01000d8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000df:	e8 ac 0d 00 00       	call   c0100e90 <mon_backtrace>
}
c01000e4:	90                   	nop
c01000e5:	c9                   	leave  
c01000e6:	c3                   	ret    

c01000e7 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000e7:	55                   	push   %ebp
c01000e8:	89 e5                	mov    %esp,%ebp
c01000ea:	53                   	push   %ebx
c01000eb:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000ee:	8d 4d 0c             	lea    0xc(%ebp),%ecx
c01000f1:	8b 55 0c             	mov    0xc(%ebp),%edx
c01000f4:	8d 5d 08             	lea    0x8(%ebp),%ebx
c01000f7:	8b 45 08             	mov    0x8(%ebp),%eax
c01000fa:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01000fe:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100102:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0100106:	89 04 24             	mov    %eax,(%esp)
c0100109:	e8 b4 ff ff ff       	call   c01000c2 <grade_backtrace2>
}
c010010e:	90                   	nop
c010010f:	83 c4 14             	add    $0x14,%esp
c0100112:	5b                   	pop    %ebx
c0100113:	5d                   	pop    %ebp
c0100114:	c3                   	ret    

c0100115 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c0100115:	55                   	push   %ebp
c0100116:	89 e5                	mov    %esp,%ebp
c0100118:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c010011b:	8b 45 10             	mov    0x10(%ebp),%eax
c010011e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100122:	8b 45 08             	mov    0x8(%ebp),%eax
c0100125:	89 04 24             	mov    %eax,(%esp)
c0100128:	e8 ba ff ff ff       	call   c01000e7 <grade_backtrace1>
}
c010012d:	90                   	nop
c010012e:	c9                   	leave  
c010012f:	c3                   	ret    

c0100130 <grade_backtrace>:

void
grade_backtrace(void) {
c0100130:	55                   	push   %ebp
c0100131:	89 e5                	mov    %esp,%ebp
c0100133:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c0100136:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c010013b:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c0100142:	ff 
c0100143:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100147:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010014e:	e8 c2 ff ff ff       	call   c0100115 <grade_backtrace0>
}
c0100153:	90                   	nop
c0100154:	c9                   	leave  
c0100155:	c3                   	ret    

c0100156 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c0100156:	55                   	push   %ebp
c0100157:	89 e5                	mov    %esp,%ebp
c0100159:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c010015c:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c010015f:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c0100162:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100165:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c0100168:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010016c:	83 e0 03             	and    $0x3,%eax
c010016f:	89 c2                	mov    %eax,%edx
c0100171:	a1 00 00 1b c0       	mov    0xc01b0000,%eax
c0100176:	89 54 24 08          	mov    %edx,0x8(%esp)
c010017a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010017e:	c7 04 24 a1 c2 10 c0 	movl   $0xc010c2a1,(%esp)
c0100185:	e8 24 01 00 00       	call   c01002ae <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c010018a:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010018e:	89 c2                	mov    %eax,%edx
c0100190:	a1 00 00 1b c0       	mov    0xc01b0000,%eax
c0100195:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100199:	89 44 24 04          	mov    %eax,0x4(%esp)
c010019d:	c7 04 24 af c2 10 c0 	movl   $0xc010c2af,(%esp)
c01001a4:	e8 05 01 00 00       	call   c01002ae <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c01001a9:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c01001ad:	89 c2                	mov    %eax,%edx
c01001af:	a1 00 00 1b c0       	mov    0xc01b0000,%eax
c01001b4:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001b8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001bc:	c7 04 24 bd c2 10 c0 	movl   $0xc010c2bd,(%esp)
c01001c3:	e8 e6 00 00 00       	call   c01002ae <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001c8:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001cc:	89 c2                	mov    %eax,%edx
c01001ce:	a1 00 00 1b c0       	mov    0xc01b0000,%eax
c01001d3:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001d7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001db:	c7 04 24 cb c2 10 c0 	movl   $0xc010c2cb,(%esp)
c01001e2:	e8 c7 00 00 00       	call   c01002ae <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001e7:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001eb:	89 c2                	mov    %eax,%edx
c01001ed:	a1 00 00 1b c0       	mov    0xc01b0000,%eax
c01001f2:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001f6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001fa:	c7 04 24 d9 c2 10 c0 	movl   $0xc010c2d9,(%esp)
c0100201:	e8 a8 00 00 00       	call   c01002ae <cprintf>
    round ++;
c0100206:	a1 00 00 1b c0       	mov    0xc01b0000,%eax
c010020b:	40                   	inc    %eax
c010020c:	a3 00 00 1b c0       	mov    %eax,0xc01b0000
}
c0100211:	90                   	nop
c0100212:	c9                   	leave  
c0100213:	c3                   	ret    

c0100214 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c0100214:	55                   	push   %ebp
c0100215:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c0100217:	90                   	nop
c0100218:	5d                   	pop    %ebp
c0100219:	c3                   	ret    

c010021a <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c010021a:	55                   	push   %ebp
c010021b:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c010021d:	90                   	nop
c010021e:	5d                   	pop    %ebp
c010021f:	c3                   	ret    

c0100220 <lab1_switch_test>:

static void
lab1_switch_test(void) {
c0100220:	55                   	push   %ebp
c0100221:	89 e5                	mov    %esp,%ebp
c0100223:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c0100226:	e8 2b ff ff ff       	call   c0100156 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c010022b:	c7 04 24 e8 c2 10 c0 	movl   $0xc010c2e8,(%esp)
c0100232:	e8 77 00 00 00       	call   c01002ae <cprintf>
    lab1_switch_to_user();
c0100237:	e8 d8 ff ff ff       	call   c0100214 <lab1_switch_to_user>
    lab1_print_cur_status();
c010023c:	e8 15 ff ff ff       	call   c0100156 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100241:	c7 04 24 08 c3 10 c0 	movl   $0xc010c308,(%esp)
c0100248:	e8 61 00 00 00       	call   c01002ae <cprintf>
    lab1_switch_to_kernel();
c010024d:	e8 c8 ff ff ff       	call   c010021a <lab1_switch_to_kernel>
    lab1_print_cur_status();
c0100252:	e8 ff fe ff ff       	call   c0100156 <lab1_print_cur_status>
}
c0100257:	90                   	nop
c0100258:	c9                   	leave  
c0100259:	c3                   	ret    

c010025a <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c010025a:	55                   	push   %ebp
c010025b:	89 e5                	mov    %esp,%ebp
c010025d:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100260:	8b 45 08             	mov    0x8(%ebp),%eax
c0100263:	89 04 24             	mov    %eax,(%esp)
c0100266:	e8 19 1d 00 00       	call   c0101f84 <cons_putc>
    (*cnt) ++;
c010026b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010026e:	8b 00                	mov    (%eax),%eax
c0100270:	8d 50 01             	lea    0x1(%eax),%edx
c0100273:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100276:	89 10                	mov    %edx,(%eax)
}
c0100278:	90                   	nop
c0100279:	c9                   	leave  
c010027a:	c3                   	ret    

c010027b <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c010027b:	55                   	push   %ebp
c010027c:	89 e5                	mov    %esp,%ebp
c010027e:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100281:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c0100288:	8b 45 0c             	mov    0xc(%ebp),%eax
c010028b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010028f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100292:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100296:	8d 45 f4             	lea    -0xc(%ebp),%eax
c0100299:	89 44 24 04          	mov    %eax,0x4(%esp)
c010029d:	c7 04 24 5a 02 10 c0 	movl   $0xc010025a,(%esp)
c01002a4:	e8 30 ba 00 00       	call   c010bcd9 <vprintfmt>
    return cnt;
c01002a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01002ac:	c9                   	leave  
c01002ad:	c3                   	ret    

c01002ae <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c01002ae:	55                   	push   %ebp
c01002af:	89 e5                	mov    %esp,%ebp
c01002b1:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c01002b4:	8d 45 0c             	lea    0xc(%ebp),%eax
c01002b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c01002ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002bd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01002c1:	8b 45 08             	mov    0x8(%ebp),%eax
c01002c4:	89 04 24             	mov    %eax,(%esp)
c01002c7:	e8 af ff ff ff       	call   c010027b <vcprintf>
c01002cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c01002cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01002d2:	c9                   	leave  
c01002d3:	c3                   	ret    

c01002d4 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c01002d4:	55                   	push   %ebp
c01002d5:	89 e5                	mov    %esp,%ebp
c01002d7:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c01002da:	8b 45 08             	mov    0x8(%ebp),%eax
c01002dd:	89 04 24             	mov    %eax,(%esp)
c01002e0:	e8 9f 1c 00 00       	call   c0101f84 <cons_putc>
}
c01002e5:	90                   	nop
c01002e6:	c9                   	leave  
c01002e7:	c3                   	ret    

c01002e8 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c01002e8:	55                   	push   %ebp
c01002e9:	89 e5                	mov    %esp,%ebp
c01002eb:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c01002ee:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c01002f5:	eb 13                	jmp    c010030a <cputs+0x22>
        cputch(c, &cnt);
c01002f7:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01002fb:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01002fe:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100302:	89 04 24             	mov    %eax,(%esp)
c0100305:	e8 50 ff ff ff       	call   c010025a <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
c010030a:	8b 45 08             	mov    0x8(%ebp),%eax
c010030d:	8d 50 01             	lea    0x1(%eax),%edx
c0100310:	89 55 08             	mov    %edx,0x8(%ebp)
c0100313:	0f b6 00             	movzbl (%eax),%eax
c0100316:	88 45 f7             	mov    %al,-0x9(%ebp)
c0100319:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c010031d:	75 d8                	jne    c01002f7 <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
c010031f:	8d 45 f0             	lea    -0x10(%ebp),%eax
c0100322:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100326:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c010032d:	e8 28 ff ff ff       	call   c010025a <cputch>
    return cnt;
c0100332:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0100335:	c9                   	leave  
c0100336:	c3                   	ret    

c0100337 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c0100337:	55                   	push   %ebp
c0100338:	89 e5                	mov    %esp,%ebp
c010033a:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c010033d:	e8 7f 1c 00 00       	call   c0101fc1 <cons_getc>
c0100342:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100345:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100349:	74 f2                	je     c010033d <getchar+0x6>
        /* do nothing */;
    return c;
c010034b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010034e:	c9                   	leave  
c010034f:	c3                   	ret    

c0100350 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c0100350:	55                   	push   %ebp
c0100351:	89 e5                	mov    %esp,%ebp
c0100353:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c0100356:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010035a:	74 13                	je     c010036f <readline+0x1f>
        cprintf("%s", prompt);
c010035c:	8b 45 08             	mov    0x8(%ebp),%eax
c010035f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100363:	c7 04 24 27 c3 10 c0 	movl   $0xc010c327,(%esp)
c010036a:	e8 3f ff ff ff       	call   c01002ae <cprintf>
    }
    int i = 0, c;
c010036f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c0100376:	e8 bc ff ff ff       	call   c0100337 <getchar>
c010037b:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c010037e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100382:	79 07                	jns    c010038b <readline+0x3b>
            return NULL;
c0100384:	b8 00 00 00 00       	mov    $0x0,%eax
c0100389:	eb 78                	jmp    c0100403 <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c010038b:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c010038f:	7e 28                	jle    c01003b9 <readline+0x69>
c0100391:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c0100398:	7f 1f                	jg     c01003b9 <readline+0x69>
            cputchar(c);
c010039a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010039d:	89 04 24             	mov    %eax,(%esp)
c01003a0:	e8 2f ff ff ff       	call   c01002d4 <cputchar>
            buf[i ++] = c;
c01003a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01003a8:	8d 50 01             	lea    0x1(%eax),%edx
c01003ab:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01003ae:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01003b1:	88 90 20 00 1b c0    	mov    %dl,-0x3fe4ffe0(%eax)
c01003b7:	eb 45                	jmp    c01003fe <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
c01003b9:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01003bd:	75 16                	jne    c01003d5 <readline+0x85>
c01003bf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003c3:	7e 10                	jle    c01003d5 <readline+0x85>
            cputchar(c);
c01003c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003c8:	89 04 24             	mov    %eax,(%esp)
c01003cb:	e8 04 ff ff ff       	call   c01002d4 <cputchar>
            i --;
c01003d0:	ff 4d f4             	decl   -0xc(%ebp)
c01003d3:	eb 29                	jmp    c01003fe <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
c01003d5:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01003d9:	74 06                	je     c01003e1 <readline+0x91>
c01003db:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01003df:	75 95                	jne    c0100376 <readline+0x26>
            cputchar(c);
c01003e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003e4:	89 04 24             	mov    %eax,(%esp)
c01003e7:	e8 e8 fe ff ff       	call   c01002d4 <cputchar>
            buf[i] = '\0';
c01003ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01003ef:	05 20 00 1b c0       	add    $0xc01b0020,%eax
c01003f4:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01003f7:	b8 20 00 1b c0       	mov    $0xc01b0020,%eax
c01003fc:	eb 05                	jmp    c0100403 <readline+0xb3>
        }
    }
c01003fe:	e9 73 ff ff ff       	jmp    c0100376 <readline+0x26>
}
c0100403:	c9                   	leave  
c0100404:	c3                   	ret    

c0100405 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100405:	55                   	push   %ebp
c0100406:	89 e5                	mov    %esp,%ebp
c0100408:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c010040b:	a1 20 04 1b c0       	mov    0xc01b0420,%eax
c0100410:	85 c0                	test   %eax,%eax
c0100412:	75 5b                	jne    c010046f <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
c0100414:	c7 05 20 04 1b c0 01 	movl   $0x1,0xc01b0420
c010041b:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c010041e:	8d 45 14             	lea    0x14(%ebp),%eax
c0100421:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100424:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100427:	89 44 24 08          	mov    %eax,0x8(%esp)
c010042b:	8b 45 08             	mov    0x8(%ebp),%eax
c010042e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100432:	c7 04 24 2a c3 10 c0 	movl   $0xc010c32a,(%esp)
c0100439:	e8 70 fe ff ff       	call   c01002ae <cprintf>
    vcprintf(fmt, ap);
c010043e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100441:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100445:	8b 45 10             	mov    0x10(%ebp),%eax
c0100448:	89 04 24             	mov    %eax,(%esp)
c010044b:	e8 2b fe ff ff       	call   c010027b <vcprintf>
    cprintf("\n");
c0100450:	c7 04 24 46 c3 10 c0 	movl   $0xc010c346,(%esp)
c0100457:	e8 52 fe ff ff       	call   c01002ae <cprintf>
    
    cprintf("stack trackback:\n");
c010045c:	c7 04 24 48 c3 10 c0 	movl   $0xc010c348,(%esp)
c0100463:	e8 46 fe ff ff       	call   c01002ae <cprintf>
    print_stackframe();
c0100468:	e8 2a 07 00 00       	call   c0100b97 <print_stackframe>
c010046d:	eb 01                	jmp    c0100470 <__panic+0x6b>
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
        goto panic_dead;
c010046f:	90                   	nop
    print_stackframe();
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100470:	e8 80 1d 00 00       	call   c01021f5 <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100475:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010047c:	e8 42 09 00 00       	call   c0100dc3 <kmonitor>
    }
c0100481:	eb f2                	jmp    c0100475 <__panic+0x70>

c0100483 <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100483:	55                   	push   %ebp
c0100484:	89 e5                	mov    %esp,%ebp
c0100486:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c0100489:	8d 45 14             	lea    0x14(%ebp),%eax
c010048c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c010048f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100492:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100496:	8b 45 08             	mov    0x8(%ebp),%eax
c0100499:	89 44 24 04          	mov    %eax,0x4(%esp)
c010049d:	c7 04 24 5a c3 10 c0 	movl   $0xc010c35a,(%esp)
c01004a4:	e8 05 fe ff ff       	call   c01002ae <cprintf>
    vcprintf(fmt, ap);
c01004a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01004ac:	89 44 24 04          	mov    %eax,0x4(%esp)
c01004b0:	8b 45 10             	mov    0x10(%ebp),%eax
c01004b3:	89 04 24             	mov    %eax,(%esp)
c01004b6:	e8 c0 fd ff ff       	call   c010027b <vcprintf>
    cprintf("\n");
c01004bb:	c7 04 24 46 c3 10 c0 	movl   $0xc010c346,(%esp)
c01004c2:	e8 e7 fd ff ff       	call   c01002ae <cprintf>
    va_end(ap);
}
c01004c7:	90                   	nop
c01004c8:	c9                   	leave  
c01004c9:	c3                   	ret    

c01004ca <is_kernel_panic>:

bool
is_kernel_panic(void) {
c01004ca:	55                   	push   %ebp
c01004cb:	89 e5                	mov    %esp,%ebp
    return is_panic;
c01004cd:	a1 20 04 1b c0       	mov    0xc01b0420,%eax
}
c01004d2:	5d                   	pop    %ebp
c01004d3:	c3                   	ret    

c01004d4 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c01004d4:	55                   	push   %ebp
c01004d5:	89 e5                	mov    %esp,%ebp
c01004d7:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c01004da:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004dd:	8b 00                	mov    (%eax),%eax
c01004df:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004e2:	8b 45 10             	mov    0x10(%ebp),%eax
c01004e5:	8b 00                	mov    (%eax),%eax
c01004e7:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c01004f1:	e9 ca 00 00 00       	jmp    c01005c0 <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
c01004f6:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01004f9:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01004fc:	01 d0                	add    %edx,%eax
c01004fe:	89 c2                	mov    %eax,%edx
c0100500:	c1 ea 1f             	shr    $0x1f,%edx
c0100503:	01 d0                	add    %edx,%eax
c0100505:	d1 f8                	sar    %eax
c0100507:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010050a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010050d:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0100510:	eb 03                	jmp    c0100515 <stab_binsearch+0x41>
            m --;
c0100512:	ff 4d f0             	decl   -0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0100515:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100518:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010051b:	7c 1f                	jl     c010053c <stab_binsearch+0x68>
c010051d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100520:	89 d0                	mov    %edx,%eax
c0100522:	01 c0                	add    %eax,%eax
c0100524:	01 d0                	add    %edx,%eax
c0100526:	c1 e0 02             	shl    $0x2,%eax
c0100529:	89 c2                	mov    %eax,%edx
c010052b:	8b 45 08             	mov    0x8(%ebp),%eax
c010052e:	01 d0                	add    %edx,%eax
c0100530:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100534:	0f b6 c0             	movzbl %al,%eax
c0100537:	3b 45 14             	cmp    0x14(%ebp),%eax
c010053a:	75 d6                	jne    c0100512 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
c010053c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010053f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100542:	7d 09                	jge    c010054d <stab_binsearch+0x79>
            l = true_m + 1;
c0100544:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100547:	40                   	inc    %eax
c0100548:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c010054b:	eb 73                	jmp    c01005c0 <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
c010054d:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c0100554:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100557:	89 d0                	mov    %edx,%eax
c0100559:	01 c0                	add    %eax,%eax
c010055b:	01 d0                	add    %edx,%eax
c010055d:	c1 e0 02             	shl    $0x2,%eax
c0100560:	89 c2                	mov    %eax,%edx
c0100562:	8b 45 08             	mov    0x8(%ebp),%eax
c0100565:	01 d0                	add    %edx,%eax
c0100567:	8b 40 08             	mov    0x8(%eax),%eax
c010056a:	3b 45 18             	cmp    0x18(%ebp),%eax
c010056d:	73 11                	jae    c0100580 <stab_binsearch+0xac>
            *region_left = m;
c010056f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100572:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100575:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c0100577:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010057a:	40                   	inc    %eax
c010057b:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010057e:	eb 40                	jmp    c01005c0 <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
c0100580:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100583:	89 d0                	mov    %edx,%eax
c0100585:	01 c0                	add    %eax,%eax
c0100587:	01 d0                	add    %edx,%eax
c0100589:	c1 e0 02             	shl    $0x2,%eax
c010058c:	89 c2                	mov    %eax,%edx
c010058e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100591:	01 d0                	add    %edx,%eax
c0100593:	8b 40 08             	mov    0x8(%eax),%eax
c0100596:	3b 45 18             	cmp    0x18(%ebp),%eax
c0100599:	76 14                	jbe    c01005af <stab_binsearch+0xdb>
            *region_right = m - 1;
c010059b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010059e:	8d 50 ff             	lea    -0x1(%eax),%edx
c01005a1:	8b 45 10             	mov    0x10(%ebp),%eax
c01005a4:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c01005a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005a9:	48                   	dec    %eax
c01005aa:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01005ad:	eb 11                	jmp    c01005c0 <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01005af:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005b2:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005b5:	89 10                	mov    %edx,(%eax)
            l = m;
c01005b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005ba:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01005bd:	ff 45 18             	incl   0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
c01005c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01005c3:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01005c6:	0f 8e 2a ff ff ff    	jle    c01004f6 <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
c01005cc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01005d0:	75 0f                	jne    c01005e1 <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
c01005d2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005d5:	8b 00                	mov    (%eax),%eax
c01005d7:	8d 50 ff             	lea    -0x1(%eax),%edx
c01005da:	8b 45 10             	mov    0x10(%ebp),%eax
c01005dd:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
c01005df:	eb 3e                	jmp    c010061f <stab_binsearch+0x14b>
    if (!any_matches) {
        *region_right = *region_left - 1;
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
c01005e1:	8b 45 10             	mov    0x10(%ebp),%eax
c01005e4:	8b 00                	mov    (%eax),%eax
c01005e6:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c01005e9:	eb 03                	jmp    c01005ee <stab_binsearch+0x11a>
c01005eb:	ff 4d fc             	decl   -0x4(%ebp)
c01005ee:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005f1:	8b 00                	mov    (%eax),%eax
c01005f3:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01005f6:	7d 1f                	jge    c0100617 <stab_binsearch+0x143>
c01005f8:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01005fb:	89 d0                	mov    %edx,%eax
c01005fd:	01 c0                	add    %eax,%eax
c01005ff:	01 d0                	add    %edx,%eax
c0100601:	c1 e0 02             	shl    $0x2,%eax
c0100604:	89 c2                	mov    %eax,%edx
c0100606:	8b 45 08             	mov    0x8(%ebp),%eax
c0100609:	01 d0                	add    %edx,%eax
c010060b:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010060f:	0f b6 c0             	movzbl %al,%eax
c0100612:	3b 45 14             	cmp    0x14(%ebp),%eax
c0100615:	75 d4                	jne    c01005eb <stab_binsearch+0x117>
            /* do nothing */;
        *region_left = l;
c0100617:	8b 45 0c             	mov    0xc(%ebp),%eax
c010061a:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010061d:	89 10                	mov    %edx,(%eax)
    }
}
c010061f:	90                   	nop
c0100620:	c9                   	leave  
c0100621:	c3                   	ret    

c0100622 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c0100622:	55                   	push   %ebp
c0100623:	89 e5                	mov    %esp,%ebp
c0100625:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c0100628:	8b 45 0c             	mov    0xc(%ebp),%eax
c010062b:	c7 00 78 c3 10 c0    	movl   $0xc010c378,(%eax)
    info->eip_line = 0;
c0100631:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100634:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c010063b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010063e:	c7 40 08 78 c3 10 c0 	movl   $0xc010c378,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100645:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100648:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c010064f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100652:	8b 55 08             	mov    0x8(%ebp),%edx
c0100655:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c0100658:	8b 45 0c             	mov    0xc(%ebp),%eax
c010065b:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    // find the relevant set of stabs
    if (addr >= KERNBASE) {
c0100662:	81 7d 08 ff ff ff bf 	cmpl   $0xbfffffff,0x8(%ebp)
c0100669:	76 21                	jbe    c010068c <debuginfo_eip+0x6a>
        stabs = __STAB_BEGIN__;
c010066b:	c7 45 f4 40 eb 10 c0 	movl   $0xc010eb40,-0xc(%ebp)
        stab_end = __STAB_END__;
c0100672:	c7 45 f0 14 3d 12 c0 	movl   $0xc0123d14,-0x10(%ebp)
        stabstr = __STABSTR_BEGIN__;
c0100679:	c7 45 ec 15 3d 12 c0 	movl   $0xc0123d15,-0x14(%ebp)
        stabstr_end = __STABSTR_END__;
c0100680:	c7 45 e8 9c 9d 12 c0 	movl   $0xc0129d9c,-0x18(%ebp)
c0100687:	e9 ea 00 00 00       	jmp    c0100776 <debuginfo_eip+0x154>
    }
    else {
        // user-program linker script, tools/user.ld puts the information about the
        // program's stabs (included __STAB_BEGIN__, __STAB_END__, __STABSTR_BEGIN__,
        // and __STABSTR_END__) in a structure located at virtual address USTAB.
        const struct userstabdata *usd = (struct userstabdata *)USTAB;
c010068c:	c7 45 e4 00 00 20 00 	movl   $0x200000,-0x1c(%ebp)

        // make sure that debugger (current process) can access this memory
        struct mm_struct *mm;
        if (current == NULL || (mm = current->mm) == NULL) {
c0100693:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c0100698:	85 c0                	test   %eax,%eax
c010069a:	74 11                	je     c01006ad <debuginfo_eip+0x8b>
c010069c:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c01006a1:	8b 40 18             	mov    0x18(%eax),%eax
c01006a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01006a7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01006ab:	75 0a                	jne    c01006b7 <debuginfo_eip+0x95>
            return -1;
c01006ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006b2:	e9 93 03 00 00       	jmp    c0100a4a <debuginfo_eip+0x428>
        }
        if (!user_mem_check(mm, (uintptr_t)usd, sizeof(struct userstabdata), 0)) {
c01006b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006ba:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01006c1:	00 
c01006c2:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c01006c9:	00 
c01006ca:	89 44 24 04          	mov    %eax,0x4(%esp)
c01006ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006d1:	89 04 24             	mov    %eax,(%esp)
c01006d4:	e8 3a 3f 00 00       	call   c0104613 <user_mem_check>
c01006d9:	85 c0                	test   %eax,%eax
c01006db:	75 0a                	jne    c01006e7 <debuginfo_eip+0xc5>
            return -1;
c01006dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006e2:	e9 63 03 00 00       	jmp    c0100a4a <debuginfo_eip+0x428>
        }

        stabs = usd->stabs;
c01006e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006ea:	8b 00                	mov    (%eax),%eax
c01006ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
        stab_end = usd->stab_end;
c01006ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006f2:	8b 40 04             	mov    0x4(%eax),%eax
c01006f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
        stabstr = usd->stabstr;
c01006f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006fb:	8b 40 08             	mov    0x8(%eax),%eax
c01006fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
        stabstr_end = usd->stabstr_end;
c0100701:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100704:	8b 40 0c             	mov    0xc(%eax),%eax
c0100707:	89 45 e8             	mov    %eax,-0x18(%ebp)

        // make sure the STABS and string table memory is valid
        if (!user_mem_check(mm, (uintptr_t)stabs, (uintptr_t)stab_end - (uintptr_t)stabs, 0)) {
c010070a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010070d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100710:	29 c2                	sub    %eax,%edx
c0100712:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100715:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010071c:	00 
c010071d:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100721:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100725:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100728:	89 04 24             	mov    %eax,(%esp)
c010072b:	e8 e3 3e 00 00       	call   c0104613 <user_mem_check>
c0100730:	85 c0                	test   %eax,%eax
c0100732:	75 0a                	jne    c010073e <debuginfo_eip+0x11c>
            return -1;
c0100734:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100739:	e9 0c 03 00 00       	jmp    c0100a4a <debuginfo_eip+0x428>
        }
        if (!user_mem_check(mm, (uintptr_t)stabstr, stabstr_end - stabstr, 0)) {
c010073e:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0100741:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100744:	29 c2                	sub    %eax,%edx
c0100746:	89 d0                	mov    %edx,%eax
c0100748:	89 c2                	mov    %eax,%edx
c010074a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010074d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0100754:	00 
c0100755:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100759:	89 44 24 04          	mov    %eax,0x4(%esp)
c010075d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100760:	89 04 24             	mov    %eax,(%esp)
c0100763:	e8 ab 3e 00 00       	call   c0104613 <user_mem_check>
c0100768:	85 c0                	test   %eax,%eax
c010076a:	75 0a                	jne    c0100776 <debuginfo_eip+0x154>
            return -1;
c010076c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100771:	e9 d4 02 00 00       	jmp    c0100a4a <debuginfo_eip+0x428>
        }
    }

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c0100776:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100779:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010077c:	76 0b                	jbe    c0100789 <debuginfo_eip+0x167>
c010077e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100781:	48                   	dec    %eax
c0100782:	0f b6 00             	movzbl (%eax),%eax
c0100785:	84 c0                	test   %al,%al
c0100787:	74 0a                	je     c0100793 <debuginfo_eip+0x171>
        return -1;
c0100789:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010078e:	e9 b7 02 00 00       	jmp    c0100a4a <debuginfo_eip+0x428>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c0100793:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010079a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010079d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007a0:	29 c2                	sub    %eax,%edx
c01007a2:	89 d0                	mov    %edx,%eax
c01007a4:	c1 f8 02             	sar    $0x2,%eax
c01007a7:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01007ad:	48                   	dec    %eax
c01007ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01007b1:	8b 45 08             	mov    0x8(%ebp),%eax
c01007b4:	89 44 24 10          	mov    %eax,0x10(%esp)
c01007b8:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c01007bf:	00 
c01007c0:	8d 45 d8             	lea    -0x28(%ebp),%eax
c01007c3:	89 44 24 08          	mov    %eax,0x8(%esp)
c01007c7:	8d 45 dc             	lea    -0x24(%ebp),%eax
c01007ca:	89 44 24 04          	mov    %eax,0x4(%esp)
c01007ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007d1:	89 04 24             	mov    %eax,(%esp)
c01007d4:	e8 fb fc ff ff       	call   c01004d4 <stab_binsearch>
    if (lfile == 0)
c01007d9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01007dc:	85 c0                	test   %eax,%eax
c01007de:	75 0a                	jne    c01007ea <debuginfo_eip+0x1c8>
        return -1;
c01007e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01007e5:	e9 60 02 00 00       	jmp    c0100a4a <debuginfo_eip+0x428>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c01007ea:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01007ed:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c01007f0:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01007f3:	89 45 d0             	mov    %eax,-0x30(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c01007f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01007f9:	89 44 24 10          	mov    %eax,0x10(%esp)
c01007fd:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c0100804:	00 
c0100805:	8d 45 d0             	lea    -0x30(%ebp),%eax
c0100808:	89 44 24 08          	mov    %eax,0x8(%esp)
c010080c:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c010080f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100813:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100816:	89 04 24             	mov    %eax,(%esp)
c0100819:	e8 b6 fc ff ff       	call   c01004d4 <stab_binsearch>

    if (lfun <= rfun) {
c010081e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100821:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100824:	39 c2                	cmp    %eax,%edx
c0100826:	7f 7c                	jg     c01008a4 <debuginfo_eip+0x282>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c0100828:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010082b:	89 c2                	mov    %eax,%edx
c010082d:	89 d0                	mov    %edx,%eax
c010082f:	01 c0                	add    %eax,%eax
c0100831:	01 d0                	add    %edx,%eax
c0100833:	c1 e0 02             	shl    $0x2,%eax
c0100836:	89 c2                	mov    %eax,%edx
c0100838:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010083b:	01 d0                	add    %edx,%eax
c010083d:	8b 00                	mov    (%eax),%eax
c010083f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c0100842:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0100845:	29 d1                	sub    %edx,%ecx
c0100847:	89 ca                	mov    %ecx,%edx
c0100849:	39 d0                	cmp    %edx,%eax
c010084b:	73 22                	jae    c010086f <debuginfo_eip+0x24d>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c010084d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100850:	89 c2                	mov    %eax,%edx
c0100852:	89 d0                	mov    %edx,%eax
c0100854:	01 c0                	add    %eax,%eax
c0100856:	01 d0                	add    %edx,%eax
c0100858:	c1 e0 02             	shl    $0x2,%eax
c010085b:	89 c2                	mov    %eax,%edx
c010085d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100860:	01 d0                	add    %edx,%eax
c0100862:	8b 10                	mov    (%eax),%edx
c0100864:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100867:	01 c2                	add    %eax,%edx
c0100869:	8b 45 0c             	mov    0xc(%ebp),%eax
c010086c:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c010086f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100872:	89 c2                	mov    %eax,%edx
c0100874:	89 d0                	mov    %edx,%eax
c0100876:	01 c0                	add    %eax,%eax
c0100878:	01 d0                	add    %edx,%eax
c010087a:	c1 e0 02             	shl    $0x2,%eax
c010087d:	89 c2                	mov    %eax,%edx
c010087f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100882:	01 d0                	add    %edx,%eax
c0100884:	8b 50 08             	mov    0x8(%eax),%edx
c0100887:	8b 45 0c             	mov    0xc(%ebp),%eax
c010088a:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c010088d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100890:	8b 40 10             	mov    0x10(%eax),%eax
c0100893:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c0100896:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100899:	89 45 cc             	mov    %eax,-0x34(%ebp)
        rline = rfun;
c010089c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010089f:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01008a2:	eb 15                	jmp    c01008b9 <debuginfo_eip+0x297>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01008a4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008a7:	8b 55 08             	mov    0x8(%ebp),%edx
c01008aa:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01008ad:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01008b0:	89 45 cc             	mov    %eax,-0x34(%ebp)
        rline = rfile;
c01008b3:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01008b6:	89 45 c8             	mov    %eax,-0x38(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01008b9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008bc:	8b 40 08             	mov    0x8(%eax),%eax
c01008bf:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c01008c6:	00 
c01008c7:	89 04 24             	mov    %eax,(%esp)
c01008ca:	e8 33 af 00 00       	call   c010b802 <strfind>
c01008cf:	89 c2                	mov    %eax,%edx
c01008d1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008d4:	8b 40 08             	mov    0x8(%eax),%eax
c01008d7:	29 c2                	sub    %eax,%edx
c01008d9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008dc:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c01008df:	8b 45 08             	mov    0x8(%ebp),%eax
c01008e2:	89 44 24 10          	mov    %eax,0x10(%esp)
c01008e6:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c01008ed:	00 
c01008ee:	8d 45 c8             	lea    -0x38(%ebp),%eax
c01008f1:	89 44 24 08          	mov    %eax,0x8(%esp)
c01008f5:	8d 45 cc             	lea    -0x34(%ebp),%eax
c01008f8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01008fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008ff:	89 04 24             	mov    %eax,(%esp)
c0100902:	e8 cd fb ff ff       	call   c01004d4 <stab_binsearch>
    if (lline <= rline) {
c0100907:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010090a:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010090d:	39 c2                	cmp    %eax,%edx
c010090f:	7f 23                	jg     c0100934 <debuginfo_eip+0x312>
        info->eip_line = stabs[rline].n_desc;
c0100911:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0100914:	89 c2                	mov    %eax,%edx
c0100916:	89 d0                	mov    %edx,%eax
c0100918:	01 c0                	add    %eax,%eax
c010091a:	01 d0                	add    %edx,%eax
c010091c:	c1 e0 02             	shl    $0x2,%eax
c010091f:	89 c2                	mov    %eax,%edx
c0100921:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100924:	01 d0                	add    %edx,%eax
c0100926:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c010092a:	89 c2                	mov    %eax,%edx
c010092c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010092f:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100932:	eb 11                	jmp    c0100945 <debuginfo_eip+0x323>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
c0100934:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100939:	e9 0c 01 00 00       	jmp    c0100a4a <debuginfo_eip+0x428>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c010093e:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0100941:	48                   	dec    %eax
c0100942:	89 45 cc             	mov    %eax,-0x34(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100945:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0100948:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010094b:	39 c2                	cmp    %eax,%edx
c010094d:	7c 56                	jl     c01009a5 <debuginfo_eip+0x383>
           && stabs[lline].n_type != N_SOL
c010094f:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0100952:	89 c2                	mov    %eax,%edx
c0100954:	89 d0                	mov    %edx,%eax
c0100956:	01 c0                	add    %eax,%eax
c0100958:	01 d0                	add    %edx,%eax
c010095a:	c1 e0 02             	shl    $0x2,%eax
c010095d:	89 c2                	mov    %eax,%edx
c010095f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100962:	01 d0                	add    %edx,%eax
c0100964:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100968:	3c 84                	cmp    $0x84,%al
c010096a:	74 39                	je     c01009a5 <debuginfo_eip+0x383>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c010096c:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010096f:	89 c2                	mov    %eax,%edx
c0100971:	89 d0                	mov    %edx,%eax
c0100973:	01 c0                	add    %eax,%eax
c0100975:	01 d0                	add    %edx,%eax
c0100977:	c1 e0 02             	shl    $0x2,%eax
c010097a:	89 c2                	mov    %eax,%edx
c010097c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010097f:	01 d0                	add    %edx,%eax
c0100981:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100985:	3c 64                	cmp    $0x64,%al
c0100987:	75 b5                	jne    c010093e <debuginfo_eip+0x31c>
c0100989:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010098c:	89 c2                	mov    %eax,%edx
c010098e:	89 d0                	mov    %edx,%eax
c0100990:	01 c0                	add    %eax,%eax
c0100992:	01 d0                	add    %edx,%eax
c0100994:	c1 e0 02             	shl    $0x2,%eax
c0100997:	89 c2                	mov    %eax,%edx
c0100999:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010099c:	01 d0                	add    %edx,%eax
c010099e:	8b 40 08             	mov    0x8(%eax),%eax
c01009a1:	85 c0                	test   %eax,%eax
c01009a3:	74 99                	je     c010093e <debuginfo_eip+0x31c>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01009a5:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01009a8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01009ab:	39 c2                	cmp    %eax,%edx
c01009ad:	7c 46                	jl     c01009f5 <debuginfo_eip+0x3d3>
c01009af:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01009b2:	89 c2                	mov    %eax,%edx
c01009b4:	89 d0                	mov    %edx,%eax
c01009b6:	01 c0                	add    %eax,%eax
c01009b8:	01 d0                	add    %edx,%eax
c01009ba:	c1 e0 02             	shl    $0x2,%eax
c01009bd:	89 c2                	mov    %eax,%edx
c01009bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009c2:	01 d0                	add    %edx,%eax
c01009c4:	8b 00                	mov    (%eax),%eax
c01009c6:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c01009c9:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01009cc:	29 d1                	sub    %edx,%ecx
c01009ce:	89 ca                	mov    %ecx,%edx
c01009d0:	39 d0                	cmp    %edx,%eax
c01009d2:	73 21                	jae    c01009f5 <debuginfo_eip+0x3d3>
        info->eip_file = stabstr + stabs[lline].n_strx;
c01009d4:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01009d7:	89 c2                	mov    %eax,%edx
c01009d9:	89 d0                	mov    %edx,%eax
c01009db:	01 c0                	add    %eax,%eax
c01009dd:	01 d0                	add    %edx,%eax
c01009df:	c1 e0 02             	shl    $0x2,%eax
c01009e2:	89 c2                	mov    %eax,%edx
c01009e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009e7:	01 d0                	add    %edx,%eax
c01009e9:	8b 10                	mov    (%eax),%edx
c01009eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01009ee:	01 c2                	add    %eax,%edx
c01009f0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01009f3:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c01009f5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01009f8:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01009fb:	39 c2                	cmp    %eax,%edx
c01009fd:	7d 46                	jge    c0100a45 <debuginfo_eip+0x423>
        for (lline = lfun + 1;
c01009ff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100a02:	40                   	inc    %eax
c0100a03:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0100a06:	eb 16                	jmp    c0100a1e <debuginfo_eip+0x3fc>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0100a08:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100a0b:	8b 40 14             	mov    0x14(%eax),%eax
c0100a0e:	8d 50 01             	lea    0x1(%eax),%edx
c0100a11:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100a14:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
c0100a17:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0100a1a:	40                   	inc    %eax
c0100a1b:	89 45 cc             	mov    %eax,-0x34(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100a1e:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0100a21:	8b 45 d0             	mov    -0x30(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
c0100a24:	39 c2                	cmp    %eax,%edx
c0100a26:	7d 1d                	jge    c0100a45 <debuginfo_eip+0x423>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100a28:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0100a2b:	89 c2                	mov    %eax,%edx
c0100a2d:	89 d0                	mov    %edx,%eax
c0100a2f:	01 c0                	add    %eax,%eax
c0100a31:	01 d0                	add    %edx,%eax
c0100a33:	c1 e0 02             	shl    $0x2,%eax
c0100a36:	89 c2                	mov    %eax,%edx
c0100a38:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a3b:	01 d0                	add    %edx,%eax
c0100a3d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100a41:	3c a0                	cmp    $0xa0,%al
c0100a43:	74 c3                	je     c0100a08 <debuginfo_eip+0x3e6>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
c0100a45:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100a4a:	c9                   	leave  
c0100a4b:	c3                   	ret    

c0100a4c <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c0100a4c:	55                   	push   %ebp
c0100a4d:	89 e5                	mov    %esp,%ebp
c0100a4f:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0100a52:	c7 04 24 82 c3 10 c0 	movl   $0xc010c382,(%esp)
c0100a59:	e8 50 f8 ff ff       	call   c01002ae <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c0100a5e:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c0100a65:	c0 
c0100a66:	c7 04 24 9b c3 10 c0 	movl   $0xc010c39b,(%esp)
c0100a6d:	e8 3c f8 ff ff       	call   c01002ae <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c0100a72:	c7 44 24 04 7d c2 10 	movl   $0xc010c27d,0x4(%esp)
c0100a79:	c0 
c0100a7a:	c7 04 24 b3 c3 10 c0 	movl   $0xc010c3b3,(%esp)
c0100a81:	e8 28 f8 ff ff       	call   c01002ae <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c0100a86:	c7 44 24 04 00 00 1b 	movl   $0xc01b0000,0x4(%esp)
c0100a8d:	c0 
c0100a8e:	c7 04 24 cb c3 10 c0 	movl   $0xc010c3cb,(%esp)
c0100a95:	e8 14 f8 ff ff       	call   c01002ae <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c0100a9a:	c7 44 24 04 6c 31 1b 	movl   $0xc01b316c,0x4(%esp)
c0100aa1:	c0 
c0100aa2:	c7 04 24 e3 c3 10 c0 	movl   $0xc010c3e3,(%esp)
c0100aa9:	e8 00 f8 ff ff       	call   c01002ae <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c0100aae:	b8 6c 31 1b c0       	mov    $0xc01b316c,%eax
c0100ab3:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c0100ab9:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c0100abe:	29 c2                	sub    %eax,%edx
c0100ac0:	89 d0                	mov    %edx,%eax
c0100ac2:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c0100ac8:	85 c0                	test   %eax,%eax
c0100aca:	0f 48 c2             	cmovs  %edx,%eax
c0100acd:	c1 f8 0a             	sar    $0xa,%eax
c0100ad0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ad4:	c7 04 24 fc c3 10 c0 	movl   $0xc010c3fc,(%esp)
c0100adb:	e8 ce f7 ff ff       	call   c01002ae <cprintf>
}
c0100ae0:	90                   	nop
c0100ae1:	c9                   	leave  
c0100ae2:	c3                   	ret    

c0100ae3 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c0100ae3:	55                   	push   %ebp
c0100ae4:	89 e5                	mov    %esp,%ebp
c0100ae6:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c0100aec:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100aef:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100af3:	8b 45 08             	mov    0x8(%ebp),%eax
c0100af6:	89 04 24             	mov    %eax,(%esp)
c0100af9:	e8 24 fb ff ff       	call   c0100622 <debuginfo_eip>
c0100afe:	85 c0                	test   %eax,%eax
c0100b00:	74 15                	je     c0100b17 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c0100b02:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b05:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b09:	c7 04 24 26 c4 10 c0 	movl   $0xc010c426,(%esp)
c0100b10:	e8 99 f7 ff ff       	call   c01002ae <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
c0100b15:	eb 6c                	jmp    c0100b83 <print_debuginfo+0xa0>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100b17:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100b1e:	eb 1b                	jmp    c0100b3b <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
c0100b20:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100b23:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b26:	01 d0                	add    %edx,%eax
c0100b28:	0f b6 00             	movzbl (%eax),%eax
c0100b2b:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100b31:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100b34:	01 ca                	add    %ecx,%edx
c0100b36:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100b38:	ff 45 f4             	incl   -0xc(%ebp)
c0100b3b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100b3e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100b41:	7f dd                	jg     c0100b20 <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
c0100b43:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b4c:	01 d0                	add    %edx,%eax
c0100b4e:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
c0100b51:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100b54:	8b 55 08             	mov    0x8(%ebp),%edx
c0100b57:	89 d1                	mov    %edx,%ecx
c0100b59:	29 c1                	sub    %eax,%ecx
c0100b5b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100b5e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100b61:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0100b65:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100b6b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100b6f:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100b73:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b77:	c7 04 24 42 c4 10 c0 	movl   $0xc010c442,(%esp)
c0100b7e:	e8 2b f7 ff ff       	call   c01002ae <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
c0100b83:	90                   	nop
c0100b84:	c9                   	leave  
c0100b85:	c3                   	ret    

c0100b86 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c0100b86:	55                   	push   %ebp
c0100b87:	89 e5                	mov    %esp,%ebp
c0100b89:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c0100b8c:	8b 45 04             	mov    0x4(%ebp),%eax
c0100b8f:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0100b92:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0100b95:	c9                   	leave  
c0100b96:	c3                   	ret    

c0100b97 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0100b97:	55                   	push   %ebp
c0100b98:	89 e5                	mov    %esp,%ebp
c0100b9a:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0100b9d:	89 e8                	mov    %ebp,%eax
c0100b9f:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c0100ba2:	8b 45 e0             	mov    -0x20(%ebp),%eax
    uint32_t ebp = read_ebp(), eip = read_eip();
c0100ba5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100ba8:	e8 d9 ff ff ff       	call   c0100b86 <read_eip>
c0100bad:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i++) {
c0100bb0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100bb7:	e9 84 00 00 00       	jmp    c0100c40 <print_stackframe+0xa9>
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
c0100bbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100bbf:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100bc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bc6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bca:	c7 04 24 54 c4 10 c0 	movl   $0xc010c454,(%esp)
c0100bd1:	e8 d8 f6 ff ff       	call   c01002ae <cprintf>
        uint32_t * args = (uint32_t * )
        ebp + 2; //参数首地址
c0100bd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bd9:	83 c0 08             	add    $0x8,%eax
print_stackframe(void) {
    uint32_t ebp = read_ebp(), eip = read_eip();
    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i++) {
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
        uint32_t * args = (uint32_t * )
c0100bdc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ebp + 2; //参数首地址
        for (j = 0; j < 4; j++) {
c0100bdf:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0100be6:	eb 24                	jmp    c0100c0c <print_stackframe+0x75>
            cprintf("0x%08x", args[j]); //打印四个参数
c0100be8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100beb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100bf2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100bf5:	01 d0                	add    %edx,%eax
c0100bf7:	8b 00                	mov    (%eax),%eax
c0100bf9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bfd:	c7 04 24 70 c4 10 c0 	movl   $0xc010c470,(%esp)
c0100c04:	e8 a5 f6 ff ff       	call   c01002ae <cprintf>
    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i++) {
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
        uint32_t * args = (uint32_t * )
        ebp + 2; //参数首地址
        for (j = 0; j < 4; j++) {
c0100c09:	ff 45 e8             	incl   -0x18(%ebp)
c0100c0c:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100c10:	7e d6                	jle    c0100be8 <print_stackframe+0x51>
            cprintf("0x%08x", args[j]); //打印四个参数
        }
        cprintf("\n");
c0100c12:	c7 04 24 77 c4 10 c0 	movl   $0xc010c477,(%esp)
c0100c19:	e8 90 f6 ff ff       	call   c01002ae <cprintf>
        print_debuginfo(eip - 1); // 打印函数信息
c0100c1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100c21:	48                   	dec    %eax
c0100c22:	89 04 24             	mov    %eax,(%esp)
c0100c25:	e8 b9 fe ff ff       	call   c0100ae3 <print_debuginfo>
        eip = ((uint32_t * )
        ebp)[1];
c0100c2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c2d:	83 c0 04             	add    $0x4,%eax
        for (j = 0; j < 4; j++) {
            cprintf("0x%08x", args[j]); //打印四个参数
        }
        cprintf("\n");
        print_debuginfo(eip - 1); // 打印函数信息
        eip = ((uint32_t * )
c0100c30:	8b 00                	mov    (%eax),%eax
c0100c32:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp)[1];
        ebp = ((uint32_t * )
        ebp)[0];
c0100c35:	8b 45 f4             	mov    -0xc(%ebp),%eax
        }
        cprintf("\n");
        print_debuginfo(eip - 1); // 打印函数信息
        eip = ((uint32_t * )
        ebp)[1];
        ebp = ((uint32_t * )
c0100c38:	8b 00                	mov    (%eax),%eax
c0100c3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 * */
void
print_stackframe(void) {
    uint32_t ebp = read_ebp(), eip = read_eip();
    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i++) {
c0100c3d:	ff 45 ec             	incl   -0x14(%ebp)
c0100c40:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100c44:	74 0a                	je     c0100c50 <print_stackframe+0xb9>
c0100c46:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100c4a:	0f 8e 6c ff ff ff    	jle    c0100bbc <print_stackframe+0x25>
        eip = ((uint32_t * )
        ebp)[1];
        ebp = ((uint32_t * )
        ebp)[0];
    }
}
c0100c50:	90                   	nop
c0100c51:	c9                   	leave  
c0100c52:	c3                   	ret    

c0100c53 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100c53:	55                   	push   %ebp
c0100c54:	89 e5                	mov    %esp,%ebp
c0100c56:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100c59:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100c60:	eb 0c                	jmp    c0100c6e <parse+0x1b>
            *buf ++ = '\0';
c0100c62:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c65:	8d 50 01             	lea    0x1(%eax),%edx
c0100c68:	89 55 08             	mov    %edx,0x8(%ebp)
c0100c6b:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100c6e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c71:	0f b6 00             	movzbl (%eax),%eax
c0100c74:	84 c0                	test   %al,%al
c0100c76:	74 1d                	je     c0100c95 <parse+0x42>
c0100c78:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c7b:	0f b6 00             	movzbl (%eax),%eax
c0100c7e:	0f be c0             	movsbl %al,%eax
c0100c81:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c85:	c7 04 24 fc c4 10 c0 	movl   $0xc010c4fc,(%esp)
c0100c8c:	e8 3f ab 00 00       	call   c010b7d0 <strchr>
c0100c91:	85 c0                	test   %eax,%eax
c0100c93:	75 cd                	jne    c0100c62 <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
c0100c95:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c98:	0f b6 00             	movzbl (%eax),%eax
c0100c9b:	84 c0                	test   %al,%al
c0100c9d:	74 69                	je     c0100d08 <parse+0xb5>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100c9f:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100ca3:	75 14                	jne    c0100cb9 <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100ca5:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100cac:	00 
c0100cad:	c7 04 24 01 c5 10 c0 	movl   $0xc010c501,(%esp)
c0100cb4:	e8 f5 f5 ff ff       	call   c01002ae <cprintf>
        }
        argv[argc ++] = buf;
c0100cb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100cbc:	8d 50 01             	lea    0x1(%eax),%edx
c0100cbf:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100cc2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100cc9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100ccc:	01 c2                	add    %eax,%edx
c0100cce:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cd1:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100cd3:	eb 03                	jmp    c0100cd8 <parse+0x85>
            buf ++;
c0100cd5:	ff 45 08             	incl   0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100cd8:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cdb:	0f b6 00             	movzbl (%eax),%eax
c0100cde:	84 c0                	test   %al,%al
c0100ce0:	0f 84 7a ff ff ff    	je     c0100c60 <parse+0xd>
c0100ce6:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ce9:	0f b6 00             	movzbl (%eax),%eax
c0100cec:	0f be c0             	movsbl %al,%eax
c0100cef:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100cf3:	c7 04 24 fc c4 10 c0 	movl   $0xc010c4fc,(%esp)
c0100cfa:	e8 d1 aa 00 00       	call   c010b7d0 <strchr>
c0100cff:	85 c0                	test   %eax,%eax
c0100d01:	74 d2                	je     c0100cd5 <parse+0x82>
            buf ++;
        }
    }
c0100d03:	e9 58 ff ff ff       	jmp    c0100c60 <parse+0xd>
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
            break;
c0100d08:	90                   	nop
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
c0100d09:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100d0c:	c9                   	leave  
c0100d0d:	c3                   	ret    

c0100d0e <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100d0e:	55                   	push   %ebp
c0100d0f:	89 e5                	mov    %esp,%ebp
c0100d11:	53                   	push   %ebx
c0100d12:	83 ec 64             	sub    $0x64,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100d15:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100d18:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d1c:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d1f:	89 04 24             	mov    %eax,(%esp)
c0100d22:	e8 2c ff ff ff       	call   c0100c53 <parse>
c0100d27:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100d2a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100d2e:	75 0a                	jne    c0100d3a <runcmd+0x2c>
        return 0;
c0100d30:	b8 00 00 00 00       	mov    $0x0,%eax
c0100d35:	e9 83 00 00 00       	jmp    c0100dbd <runcmd+0xaf>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d3a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100d41:	eb 5a                	jmp    c0100d9d <runcmd+0x8f>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100d43:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100d46:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d49:	89 d0                	mov    %edx,%eax
c0100d4b:	01 c0                	add    %eax,%eax
c0100d4d:	01 d0                	add    %edx,%eax
c0100d4f:	c1 e0 02             	shl    $0x2,%eax
c0100d52:	05 00 c0 12 c0       	add    $0xc012c000,%eax
c0100d57:	8b 00                	mov    (%eax),%eax
c0100d59:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100d5d:	89 04 24             	mov    %eax,(%esp)
c0100d60:	e8 ce a9 00 00       	call   c010b733 <strcmp>
c0100d65:	85 c0                	test   %eax,%eax
c0100d67:	75 31                	jne    c0100d9a <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100d69:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d6c:	89 d0                	mov    %edx,%eax
c0100d6e:	01 c0                	add    %eax,%eax
c0100d70:	01 d0                	add    %edx,%eax
c0100d72:	c1 e0 02             	shl    $0x2,%eax
c0100d75:	05 08 c0 12 c0       	add    $0xc012c008,%eax
c0100d7a:	8b 10                	mov    (%eax),%edx
c0100d7c:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100d7f:	83 c0 04             	add    $0x4,%eax
c0100d82:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100d85:	8d 59 ff             	lea    -0x1(%ecx),%ebx
c0100d88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c0100d8b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100d8f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d93:	89 1c 24             	mov    %ebx,(%esp)
c0100d96:	ff d2                	call   *%edx
c0100d98:	eb 23                	jmp    c0100dbd <runcmd+0xaf>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d9a:	ff 45 f4             	incl   -0xc(%ebp)
c0100d9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100da0:	83 f8 02             	cmp    $0x2,%eax
c0100da3:	76 9e                	jbe    c0100d43 <runcmd+0x35>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100da5:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100da8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100dac:	c7 04 24 1f c5 10 c0 	movl   $0xc010c51f,(%esp)
c0100db3:	e8 f6 f4 ff ff       	call   c01002ae <cprintf>
    return 0;
c0100db8:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100dbd:	83 c4 64             	add    $0x64,%esp
c0100dc0:	5b                   	pop    %ebx
c0100dc1:	5d                   	pop    %ebp
c0100dc2:	c3                   	ret    

c0100dc3 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100dc3:	55                   	push   %ebp
c0100dc4:	89 e5                	mov    %esp,%ebp
c0100dc6:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100dc9:	c7 04 24 38 c5 10 c0 	movl   $0xc010c538,(%esp)
c0100dd0:	e8 d9 f4 ff ff       	call   c01002ae <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100dd5:	c7 04 24 60 c5 10 c0 	movl   $0xc010c560,(%esp)
c0100ddc:	e8 cd f4 ff ff       	call   c01002ae <cprintf>

    if (tf != NULL) {
c0100de1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100de5:	74 0b                	je     c0100df2 <kmonitor+0x2f>
        print_trapframe(tf);
c0100de7:	8b 45 08             	mov    0x8(%ebp),%eax
c0100dea:	89 04 24             	mov    %eax,(%esp)
c0100ded:	e8 dd 15 00 00       	call   c01023cf <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100df2:	c7 04 24 85 c5 10 c0 	movl   $0xc010c585,(%esp)
c0100df9:	e8 52 f5 ff ff       	call   c0100350 <readline>
c0100dfe:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100e01:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100e05:	74 eb                	je     c0100df2 <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
c0100e07:	8b 45 08             	mov    0x8(%ebp),%eax
c0100e0a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100e0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100e11:	89 04 24             	mov    %eax,(%esp)
c0100e14:	e8 f5 fe ff ff       	call   c0100d0e <runcmd>
c0100e19:	85 c0                	test   %eax,%eax
c0100e1b:	78 02                	js     c0100e1f <kmonitor+0x5c>
                break;
            }
        }
    }
c0100e1d:	eb d3                	jmp    c0100df2 <kmonitor+0x2f>

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
            if (runcmd(buf, tf) < 0) {
                break;
c0100e1f:	90                   	nop
            }
        }
    }
}
c0100e20:	90                   	nop
c0100e21:	c9                   	leave  
c0100e22:	c3                   	ret    

c0100e23 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100e23:	55                   	push   %ebp
c0100e24:	89 e5                	mov    %esp,%ebp
c0100e26:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100e29:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100e30:	eb 3d                	jmp    c0100e6f <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100e32:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100e35:	89 d0                	mov    %edx,%eax
c0100e37:	01 c0                	add    %eax,%eax
c0100e39:	01 d0                	add    %edx,%eax
c0100e3b:	c1 e0 02             	shl    $0x2,%eax
c0100e3e:	05 04 c0 12 c0       	add    $0xc012c004,%eax
c0100e43:	8b 08                	mov    (%eax),%ecx
c0100e45:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100e48:	89 d0                	mov    %edx,%eax
c0100e4a:	01 c0                	add    %eax,%eax
c0100e4c:	01 d0                	add    %edx,%eax
c0100e4e:	c1 e0 02             	shl    $0x2,%eax
c0100e51:	05 00 c0 12 c0       	add    $0xc012c000,%eax
c0100e56:	8b 00                	mov    (%eax),%eax
c0100e58:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100e5c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100e60:	c7 04 24 89 c5 10 c0 	movl   $0xc010c589,(%esp)
c0100e67:	e8 42 f4 ff ff       	call   c01002ae <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100e6c:	ff 45 f4             	incl   -0xc(%ebp)
c0100e6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100e72:	83 f8 02             	cmp    $0x2,%eax
c0100e75:	76 bb                	jbe    c0100e32 <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
c0100e77:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e7c:	c9                   	leave  
c0100e7d:	c3                   	ret    

c0100e7e <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100e7e:	55                   	push   %ebp
c0100e7f:	89 e5                	mov    %esp,%ebp
c0100e81:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100e84:	e8 c3 fb ff ff       	call   c0100a4c <print_kerninfo>
    return 0;
c0100e89:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e8e:	c9                   	leave  
c0100e8f:	c3                   	ret    

c0100e90 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100e90:	55                   	push   %ebp
c0100e91:	89 e5                	mov    %esp,%ebp
c0100e93:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100e96:	e8 fc fc ff ff       	call   c0100b97 <print_stackframe>
    return 0;
c0100e9b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100ea0:	c9                   	leave  
c0100ea1:	c3                   	ret    

c0100ea2 <ide_wait_ready>:
    unsigned int size;          // Size in Sectors
    unsigned char model[41];    // Model in String
} ide_devices[MAX_IDE];

static int
ide_wait_ready(unsigned short iobase, bool check_error) {
c0100ea2:	55                   	push   %ebp
c0100ea3:	89 e5                	mov    %esp,%ebp
c0100ea5:	83 ec 14             	sub    $0x14,%esp
c0100ea8:	8b 45 08             	mov    0x8(%ebp),%eax
c0100eab:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    int r;
    while ((r = inb(iobase + ISA_STATUS)) & IDE_BSY)
c0100eaf:	90                   	nop
c0100eb0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100eb3:	83 c0 07             	add    $0x7,%eax
c0100eb6:	0f b7 c0             	movzwl %ax,%eax
c0100eb9:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100ebd:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100ec1:	89 c2                	mov    %eax,%edx
c0100ec3:	ec                   	in     (%dx),%al
c0100ec4:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0100ec7:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0100ecb:	0f b6 c0             	movzbl %al,%eax
c0100ece:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100ed1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ed4:	25 80 00 00 00       	and    $0x80,%eax
c0100ed9:	85 c0                	test   %eax,%eax
c0100edb:	75 d3                	jne    c0100eb0 <ide_wait_ready+0xe>
        /* nothing */;
    if (check_error && (r & (IDE_DF | IDE_ERR)) != 0) {
c0100edd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0100ee1:	74 11                	je     c0100ef4 <ide_wait_ready+0x52>
c0100ee3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ee6:	83 e0 21             	and    $0x21,%eax
c0100ee9:	85 c0                	test   %eax,%eax
c0100eeb:	74 07                	je     c0100ef4 <ide_wait_ready+0x52>
        return -1;
c0100eed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100ef2:	eb 05                	jmp    c0100ef9 <ide_wait_ready+0x57>
    }
    return 0;
c0100ef4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100ef9:	c9                   	leave  
c0100efa:	c3                   	ret    

c0100efb <ide_init>:

void
ide_init(void) {
c0100efb:	55                   	push   %ebp
c0100efc:	89 e5                	mov    %esp,%ebp
c0100efe:	57                   	push   %edi
c0100eff:	53                   	push   %ebx
c0100f00:	81 ec 50 02 00 00    	sub    $0x250,%esp
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0100f06:	66 c7 45 f6 00 00    	movw   $0x0,-0xa(%ebp)
c0100f0c:	e9 d4 02 00 00       	jmp    c01011e5 <ide_init+0x2ea>
        /* assume that no device here */
        ide_devices[ideno].valid = 0;
c0100f11:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100f15:	c1 e0 03             	shl    $0x3,%eax
c0100f18:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0100f1f:	29 c2                	sub    %eax,%edx
c0100f21:	89 d0                	mov    %edx,%eax
c0100f23:	05 40 04 1b c0       	add    $0xc01b0440,%eax
c0100f28:	c6 00 00             	movb   $0x0,(%eax)

        iobase = IO_BASE(ideno);
c0100f2b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100f2f:	d1 e8                	shr    %eax
c0100f31:	0f b7 c0             	movzwl %ax,%eax
c0100f34:	8b 04 85 94 c5 10 c0 	mov    -0x3fef3a6c(,%eax,4),%eax
c0100f3b:	66 89 45 ea          	mov    %ax,-0x16(%ebp)

        /* wait device ready */
        ide_wait_ready(iobase, 0);
c0100f3f:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100f43:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100f4a:	00 
c0100f4b:	89 04 24             	mov    %eax,(%esp)
c0100f4e:	e8 4f ff ff ff       	call   c0100ea2 <ide_wait_ready>

        /* step1: select drive */
        outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4));
c0100f53:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100f57:	83 e0 01             	and    $0x1,%eax
c0100f5a:	c1 e0 04             	shl    $0x4,%eax
c0100f5d:	0c e0                	or     $0xe0,%al
c0100f5f:	0f b6 c0             	movzbl %al,%eax
c0100f62:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100f66:	83 c2 06             	add    $0x6,%edx
c0100f69:	0f b7 d2             	movzwl %dx,%edx
c0100f6c:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0100f70:	88 45 c7             	mov    %al,-0x39(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f73:	0f b6 45 c7          	movzbl -0x39(%ebp),%eax
c0100f77:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0100f7b:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c0100f7c:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100f80:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100f87:	00 
c0100f88:	89 04 24             	mov    %eax,(%esp)
c0100f8b:	e8 12 ff ff ff       	call   c0100ea2 <ide_wait_ready>

        /* step2: send ATA identify command */
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
c0100f90:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100f94:	83 c0 07             	add    $0x7,%eax
c0100f97:	0f b7 c0             	movzwl %ax,%eax
c0100f9a:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
c0100f9e:	c6 45 c8 ec          	movb   $0xec,-0x38(%ebp)
c0100fa2:	0f b6 45 c8          	movzbl -0x38(%ebp),%eax
c0100fa6:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100fa9:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c0100faa:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100fae:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100fb5:	00 
c0100fb6:	89 04 24             	mov    %eax,(%esp)
c0100fb9:	e8 e4 fe ff ff       	call   c0100ea2 <ide_wait_ready>

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
c0100fbe:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100fc2:	83 c0 07             	add    $0x7,%eax
c0100fc5:	0f b7 c0             	movzwl %ax,%eax
c0100fc8:	66 89 45 ca          	mov    %ax,-0x36(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100fcc:	0f b7 45 ca          	movzwl -0x36(%ebp),%eax
c0100fd0:	89 c2                	mov    %eax,%edx
c0100fd2:	ec                   	in     (%dx),%al
c0100fd3:	88 45 c9             	mov    %al,-0x37(%ebp)
    return data;
c0100fd6:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0100fda:	84 c0                	test   %al,%al
c0100fdc:	0f 84 f9 01 00 00    	je     c01011db <ide_init+0x2e0>
c0100fe2:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100fe6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0100fed:	00 
c0100fee:	89 04 24             	mov    %eax,(%esp)
c0100ff1:	e8 ac fe ff ff       	call   c0100ea2 <ide_wait_ready>
c0100ff6:	85 c0                	test   %eax,%eax
c0100ff8:	0f 85 dd 01 00 00    	jne    c01011db <ide_init+0x2e0>
            continue ;
        }

        /* device is ok */
        ide_devices[ideno].valid = 1;
c0100ffe:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101002:	c1 e0 03             	shl    $0x3,%eax
c0101005:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c010100c:	29 c2                	sub    %eax,%edx
c010100e:	89 d0                	mov    %edx,%eax
c0101010:	05 40 04 1b c0       	add    $0xc01b0440,%eax
c0101015:	c6 00 01             	movb   $0x1,(%eax)

        /* read identification space of the device */
        unsigned int buffer[128];
        insl(iobase + ISA_DATA, buffer, sizeof(buffer) / sizeof(unsigned int));
c0101018:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c010101c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010101f:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0101025:	89 45 c0             	mov    %eax,-0x40(%ebp)
c0101028:	c7 45 bc 80 00 00 00 	movl   $0x80,-0x44(%ebp)
}

static inline void
insl(uint32_t port, void *addr, int cnt) {
    asm volatile (
c010102f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0101032:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c0101035:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0101038:	89 cb                	mov    %ecx,%ebx
c010103a:	89 df                	mov    %ebx,%edi
c010103c:	89 c1                	mov    %eax,%ecx
c010103e:	fc                   	cld    
c010103f:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0101041:	89 c8                	mov    %ecx,%eax
c0101043:	89 fb                	mov    %edi,%ebx
c0101045:	89 5d c0             	mov    %ebx,-0x40(%ebp)
c0101048:	89 45 bc             	mov    %eax,-0x44(%ebp)

        unsigned char *ident = (unsigned char *)buffer;
c010104b:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0101051:	89 45 dc             	mov    %eax,-0x24(%ebp)
        unsigned int sectors;
        unsigned int cmdsets = *(unsigned int *)(ident + IDE_IDENT_CMDSETS);
c0101054:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101057:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
c010105d:	89 45 d8             	mov    %eax,-0x28(%ebp)
        /* device use 48-bits or 28-bits addressing */
        if (cmdsets & (1 << 26)) {
c0101060:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0101063:	25 00 00 00 04       	and    $0x4000000,%eax
c0101068:	85 c0                	test   %eax,%eax
c010106a:	74 0e                	je     c010107a <ide_init+0x17f>
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA_EXT);
c010106c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010106f:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
c0101075:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0101078:	eb 09                	jmp    c0101083 <ide_init+0x188>
        }
        else {
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA);
c010107a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010107d:	8b 40 78             	mov    0x78(%eax),%eax
c0101080:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        ide_devices[ideno].sets = cmdsets;
c0101083:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101087:	c1 e0 03             	shl    $0x3,%eax
c010108a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101091:	29 c2                	sub    %eax,%edx
c0101093:	89 d0                	mov    %edx,%eax
c0101095:	8d 90 44 04 1b c0    	lea    -0x3fe4fbbc(%eax),%edx
c010109b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010109e:	89 02                	mov    %eax,(%edx)
        ide_devices[ideno].size = sectors;
c01010a0:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01010a4:	c1 e0 03             	shl    $0x3,%eax
c01010a7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01010ae:	29 c2                	sub    %eax,%edx
c01010b0:	89 d0                	mov    %edx,%eax
c01010b2:	8d 90 48 04 1b c0    	lea    -0x3fe4fbb8(%eax),%edx
c01010b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01010bb:	89 02                	mov    %eax,(%edx)

        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c01010bd:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01010c0:	83 c0 62             	add    $0x62,%eax
c01010c3:	0f b7 00             	movzwl (%eax),%eax
c01010c6:	25 00 02 00 00       	and    $0x200,%eax
c01010cb:	85 c0                	test   %eax,%eax
c01010cd:	75 24                	jne    c01010f3 <ide_init+0x1f8>
c01010cf:	c7 44 24 0c 9c c5 10 	movl   $0xc010c59c,0xc(%esp)
c01010d6:	c0 
c01010d7:	c7 44 24 08 df c5 10 	movl   $0xc010c5df,0x8(%esp)
c01010de:	c0 
c01010df:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c01010e6:	00 
c01010e7:	c7 04 24 f4 c5 10 c0 	movl   $0xc010c5f4,(%esp)
c01010ee:	e8 12 f3 ff ff       	call   c0100405 <__panic>

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
c01010f3:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01010f7:	c1 e0 03             	shl    $0x3,%eax
c01010fa:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101101:	29 c2                	sub    %eax,%edx
c0101103:	8d 82 40 04 1b c0    	lea    -0x3fe4fbc0(%edx),%eax
c0101109:	83 c0 0c             	add    $0xc,%eax
c010110c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c010110f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101112:	83 c0 36             	add    $0x36,%eax
c0101115:	89 45 d0             	mov    %eax,-0x30(%ebp)
        unsigned int i, length = 40;
c0101118:	c7 45 cc 28 00 00 00 	movl   $0x28,-0x34(%ebp)
        for (i = 0; i < length; i += 2) {
c010111f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0101126:	eb 34                	jmp    c010115c <ide_init+0x261>
            model[i] = data[i + 1], model[i + 1] = data[i];
c0101128:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010112b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010112e:	01 c2                	add    %eax,%edx
c0101130:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101133:	8d 48 01             	lea    0x1(%eax),%ecx
c0101136:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0101139:	01 c8                	add    %ecx,%eax
c010113b:	0f b6 00             	movzbl (%eax),%eax
c010113e:	88 02                	mov    %al,(%edx)
c0101140:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101143:	8d 50 01             	lea    0x1(%eax),%edx
c0101146:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101149:	01 c2                	add    %eax,%edx
c010114b:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c010114e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101151:	01 c8                	add    %ecx,%eax
c0101153:	0f b6 00             	movzbl (%eax),%eax
c0101156:	88 02                	mov    %al,(%edx)
        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
        unsigned int i, length = 40;
        for (i = 0; i < length; i += 2) {
c0101158:	83 45 ec 02          	addl   $0x2,-0x14(%ebp)
c010115c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010115f:	3b 45 cc             	cmp    -0x34(%ebp),%eax
c0101162:	72 c4                	jb     c0101128 <ide_init+0x22d>
            model[i] = data[i + 1], model[i + 1] = data[i];
        }
        do {
            model[i] = '\0';
c0101164:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0101167:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010116a:	01 d0                	add    %edx,%eax
c010116c:	c6 00 00             	movb   $0x0,(%eax)
        } while (i -- > 0 && model[i] == ' ');
c010116f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101172:	8d 50 ff             	lea    -0x1(%eax),%edx
c0101175:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0101178:	85 c0                	test   %eax,%eax
c010117a:	74 0f                	je     c010118b <ide_init+0x290>
c010117c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010117f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101182:	01 d0                	add    %edx,%eax
c0101184:	0f b6 00             	movzbl (%eax),%eax
c0101187:	3c 20                	cmp    $0x20,%al
c0101189:	74 d9                	je     c0101164 <ide_init+0x269>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
c010118b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010118f:	c1 e0 03             	shl    $0x3,%eax
c0101192:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101199:	29 c2                	sub    %eax,%edx
c010119b:	8d 82 40 04 1b c0    	lea    -0x3fe4fbc0(%edx),%eax
c01011a1:	8d 48 0c             	lea    0xc(%eax),%ecx
c01011a4:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01011a8:	c1 e0 03             	shl    $0x3,%eax
c01011ab:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01011b2:	29 c2                	sub    %eax,%edx
c01011b4:	89 d0                	mov    %edx,%eax
c01011b6:	05 48 04 1b c0       	add    $0xc01b0448,%eax
c01011bb:	8b 10                	mov    (%eax),%edx
c01011bd:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01011c1:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01011c5:	89 54 24 08          	mov    %edx,0x8(%esp)
c01011c9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01011cd:	c7 04 24 06 c6 10 c0 	movl   $0xc010c606,(%esp)
c01011d4:	e8 d5 f0 ff ff       	call   c01002ae <cprintf>
c01011d9:	eb 01                	jmp    c01011dc <ide_init+0x2e1>
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
        ide_wait_ready(iobase, 0);

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
            continue ;
c01011db:	90                   	nop

void
ide_init(void) {
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c01011dc:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01011e0:	40                   	inc    %eax
c01011e1:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
c01011e5:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01011e9:	83 f8 03             	cmp    $0x3,%eax
c01011ec:	0f 86 1f fd ff ff    	jbe    c0100f11 <ide_init+0x16>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
    }

    // enable ide interrupt
    pic_enable(IRQ_IDE1);
c01011f2:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
c01011f9:	e8 8a 0e 00 00       	call   c0102088 <pic_enable>
    pic_enable(IRQ_IDE2);
c01011fe:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
c0101205:	e8 7e 0e 00 00       	call   c0102088 <pic_enable>
}
c010120a:	90                   	nop
c010120b:	81 c4 50 02 00 00    	add    $0x250,%esp
c0101211:	5b                   	pop    %ebx
c0101212:	5f                   	pop    %edi
c0101213:	5d                   	pop    %ebp
c0101214:	c3                   	ret    

c0101215 <ide_device_valid>:

bool
ide_device_valid(unsigned short ideno) {
c0101215:	55                   	push   %ebp
c0101216:	89 e5                	mov    %esp,%ebp
c0101218:	83 ec 04             	sub    $0x4,%esp
c010121b:	8b 45 08             	mov    0x8(%ebp),%eax
c010121e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    return VALID_IDE(ideno);
c0101222:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101226:	83 f8 03             	cmp    $0x3,%eax
c0101229:	77 25                	ja     c0101250 <ide_device_valid+0x3b>
c010122b:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c010122f:	c1 e0 03             	shl    $0x3,%eax
c0101232:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101239:	29 c2                	sub    %eax,%edx
c010123b:	89 d0                	mov    %edx,%eax
c010123d:	05 40 04 1b c0       	add    $0xc01b0440,%eax
c0101242:	0f b6 00             	movzbl (%eax),%eax
c0101245:	84 c0                	test   %al,%al
c0101247:	74 07                	je     c0101250 <ide_device_valid+0x3b>
c0101249:	b8 01 00 00 00       	mov    $0x1,%eax
c010124e:	eb 05                	jmp    c0101255 <ide_device_valid+0x40>
c0101250:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101255:	c9                   	leave  
c0101256:	c3                   	ret    

c0101257 <ide_device_size>:

size_t
ide_device_size(unsigned short ideno) {
c0101257:	55                   	push   %ebp
c0101258:	89 e5                	mov    %esp,%ebp
c010125a:	83 ec 08             	sub    $0x8,%esp
c010125d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101260:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    if (ide_device_valid(ideno)) {
c0101264:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101268:	89 04 24             	mov    %eax,(%esp)
c010126b:	e8 a5 ff ff ff       	call   c0101215 <ide_device_valid>
c0101270:	85 c0                	test   %eax,%eax
c0101272:	74 1b                	je     c010128f <ide_device_size+0x38>
        return ide_devices[ideno].size;
c0101274:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101278:	c1 e0 03             	shl    $0x3,%eax
c010127b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101282:	29 c2                	sub    %eax,%edx
c0101284:	89 d0                	mov    %edx,%eax
c0101286:	05 48 04 1b c0       	add    $0xc01b0448,%eax
c010128b:	8b 00                	mov    (%eax),%eax
c010128d:	eb 05                	jmp    c0101294 <ide_device_size+0x3d>
    }
    return 0;
c010128f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101294:	c9                   	leave  
c0101295:	c3                   	ret    

c0101296 <ide_read_secs>:

int
ide_read_secs(unsigned short ideno, uint32_t secno, void *dst, size_t nsecs) {
c0101296:	55                   	push   %ebp
c0101297:	89 e5                	mov    %esp,%ebp
c0101299:	57                   	push   %edi
c010129a:	53                   	push   %ebx
c010129b:	83 ec 50             	sub    $0x50,%esp
c010129e:	8b 45 08             	mov    0x8(%ebp),%eax
c01012a1:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c01012a5:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c01012ac:	77 27                	ja     c01012d5 <ide_read_secs+0x3f>
c01012ae:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01012b2:	83 f8 03             	cmp    $0x3,%eax
c01012b5:	77 1e                	ja     c01012d5 <ide_read_secs+0x3f>
c01012b7:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01012bb:	c1 e0 03             	shl    $0x3,%eax
c01012be:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01012c5:	29 c2                	sub    %eax,%edx
c01012c7:	89 d0                	mov    %edx,%eax
c01012c9:	05 40 04 1b c0       	add    $0xc01b0440,%eax
c01012ce:	0f b6 00             	movzbl (%eax),%eax
c01012d1:	84 c0                	test   %al,%al
c01012d3:	75 24                	jne    c01012f9 <ide_read_secs+0x63>
c01012d5:	c7 44 24 0c 24 c6 10 	movl   $0xc010c624,0xc(%esp)
c01012dc:	c0 
c01012dd:	c7 44 24 08 df c5 10 	movl   $0xc010c5df,0x8(%esp)
c01012e4:	c0 
c01012e5:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
c01012ec:	00 
c01012ed:	c7 04 24 f4 c5 10 c0 	movl   $0xc010c5f4,(%esp)
c01012f4:	e8 0c f1 ff ff       	call   c0100405 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c01012f9:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101300:	77 0f                	ja     c0101311 <ide_read_secs+0x7b>
c0101302:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101305:	8b 45 14             	mov    0x14(%ebp),%eax
c0101308:	01 d0                	add    %edx,%eax
c010130a:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c010130f:	76 24                	jbe    c0101335 <ide_read_secs+0x9f>
c0101311:	c7 44 24 0c 4c c6 10 	movl   $0xc010c64c,0xc(%esp)
c0101318:	c0 
c0101319:	c7 44 24 08 df c5 10 	movl   $0xc010c5df,0x8(%esp)
c0101320:	c0 
c0101321:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c0101328:	00 
c0101329:	c7 04 24 f4 c5 10 c0 	movl   $0xc010c5f4,(%esp)
c0101330:	e8 d0 f0 ff ff       	call   c0100405 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101335:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101339:	d1 e8                	shr    %eax
c010133b:	0f b7 c0             	movzwl %ax,%eax
c010133e:	8b 04 85 94 c5 10 c0 	mov    -0x3fef3a6c(,%eax,4),%eax
c0101345:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101349:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c010134d:	d1 e8                	shr    %eax
c010134f:	0f b7 c0             	movzwl %ax,%eax
c0101352:	0f b7 04 85 96 c5 10 	movzwl -0x3fef3a6a(,%eax,4),%eax
c0101359:	c0 
c010135a:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c010135e:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101362:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101369:	00 
c010136a:	89 04 24             	mov    %eax,(%esp)
c010136d:	e8 30 fb ff ff       	call   c0100ea2 <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0101372:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101375:	83 c0 02             	add    $0x2,%eax
c0101378:	0f b7 c0             	movzwl %ax,%eax
c010137b:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c010137f:	c6 45 d7 00          	movb   $0x0,-0x29(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101383:	0f b6 45 d7          	movzbl -0x29(%ebp),%eax
c0101387:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010138b:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c010138c:	8b 45 14             	mov    0x14(%ebp),%eax
c010138f:	0f b6 c0             	movzbl %al,%eax
c0101392:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101396:	83 c2 02             	add    $0x2,%edx
c0101399:	0f b7 d2             	movzwl %dx,%edx
c010139c:	66 89 55 e8          	mov    %dx,-0x18(%ebp)
c01013a0:	88 45 d8             	mov    %al,-0x28(%ebp)
c01013a3:	0f b6 45 d8          	movzbl -0x28(%ebp),%eax
c01013a7:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01013aa:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c01013ab:	8b 45 0c             	mov    0xc(%ebp),%eax
c01013ae:	0f b6 c0             	movzbl %al,%eax
c01013b1:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01013b5:	83 c2 03             	add    $0x3,%edx
c01013b8:	0f b7 d2             	movzwl %dx,%edx
c01013bb:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01013bf:	88 45 d9             	mov    %al,-0x27(%ebp)
c01013c2:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01013c6:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01013ca:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c01013cb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01013ce:	c1 e8 08             	shr    $0x8,%eax
c01013d1:	0f b6 c0             	movzbl %al,%eax
c01013d4:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01013d8:	83 c2 04             	add    $0x4,%edx
c01013db:	0f b7 d2             	movzwl %dx,%edx
c01013de:	66 89 55 e4          	mov    %dx,-0x1c(%ebp)
c01013e2:	88 45 da             	mov    %al,-0x26(%ebp)
c01013e5:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
c01013e9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01013ec:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c01013ed:	8b 45 0c             	mov    0xc(%ebp),%eax
c01013f0:	c1 e8 10             	shr    $0x10,%eax
c01013f3:	0f b6 c0             	movzbl %al,%eax
c01013f6:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01013fa:	83 c2 05             	add    $0x5,%edx
c01013fd:	0f b7 d2             	movzwl %dx,%edx
c0101400:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101404:	88 45 db             	mov    %al,-0x25(%ebp)
c0101407:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
c010140b:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c010140f:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101410:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0101413:	24 01                	and    $0x1,%al
c0101415:	c0 e0 04             	shl    $0x4,%al
c0101418:	88 c2                	mov    %al,%dl
c010141a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010141d:	c1 e8 18             	shr    $0x18,%eax
c0101420:	24 0f                	and    $0xf,%al
c0101422:	08 d0                	or     %dl,%al
c0101424:	0c e0                	or     $0xe0,%al
c0101426:	0f b6 c0             	movzbl %al,%eax
c0101429:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010142d:	83 c2 06             	add    $0x6,%edx
c0101430:	0f b7 d2             	movzwl %dx,%edx
c0101433:	66 89 55 e0          	mov    %dx,-0x20(%ebp)
c0101437:	88 45 dc             	mov    %al,-0x24(%ebp)
c010143a:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
c010143e:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0101441:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);
c0101442:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101446:	83 c0 07             	add    $0x7,%eax
c0101449:	0f b7 c0             	movzwl %ax,%eax
c010144c:	66 89 45 de          	mov    %ax,-0x22(%ebp)
c0101450:	c6 45 dd 20          	movb   $0x20,-0x23(%ebp)
c0101454:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101458:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c010145c:	ee                   	out    %al,(%dx)

    int ret = 0;
c010145d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101464:	eb 57                	jmp    c01014bd <ide_read_secs+0x227>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101466:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010146a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101471:	00 
c0101472:	89 04 24             	mov    %eax,(%esp)
c0101475:	e8 28 fa ff ff       	call   c0100ea2 <ide_wait_ready>
c010147a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010147d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101481:	75 42                	jne    c01014c5 <ide_read_secs+0x22f>
            goto out;
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
c0101483:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101487:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010148a:	8b 45 10             	mov    0x10(%ebp),%eax
c010148d:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0101490:	c7 45 cc 80 00 00 00 	movl   $0x80,-0x34(%ebp)
    return data;
}

static inline void
insl(uint32_t port, void *addr, int cnt) {
    asm volatile (
c0101497:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010149a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c010149d:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01014a0:	89 cb                	mov    %ecx,%ebx
c01014a2:	89 df                	mov    %ebx,%edi
c01014a4:	89 c1                	mov    %eax,%ecx
c01014a6:	fc                   	cld    
c01014a7:	f2 6d                	repnz insl (%dx),%es:(%edi)
c01014a9:	89 c8                	mov    %ecx,%eax
c01014ab:	89 fb                	mov    %edi,%ebx
c01014ad:	89 5d d0             	mov    %ebx,-0x30(%ebp)
c01014b0:	89 45 cc             	mov    %eax,-0x34(%ebp)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);

    int ret = 0;
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c01014b3:	ff 4d 14             	decl   0x14(%ebp)
c01014b6:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c01014bd:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c01014c1:	75 a3                	jne    c0101466 <ide_read_secs+0x1d0>
c01014c3:	eb 01                	jmp    c01014c6 <ide_read_secs+0x230>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
            goto out;
c01014c5:	90                   	nop
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
    }

out:
    return ret;
c01014c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01014c9:	83 c4 50             	add    $0x50,%esp
c01014cc:	5b                   	pop    %ebx
c01014cd:	5f                   	pop    %edi
c01014ce:	5d                   	pop    %ebp
c01014cf:	c3                   	ret    

c01014d0 <ide_write_secs>:

int
ide_write_secs(unsigned short ideno, uint32_t secno, const void *src, size_t nsecs) {
c01014d0:	55                   	push   %ebp
c01014d1:	89 e5                	mov    %esp,%ebp
c01014d3:	56                   	push   %esi
c01014d4:	53                   	push   %ebx
c01014d5:	83 ec 50             	sub    $0x50,%esp
c01014d8:	8b 45 08             	mov    0x8(%ebp),%eax
c01014db:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c01014df:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c01014e6:	77 27                	ja     c010150f <ide_write_secs+0x3f>
c01014e8:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01014ec:	83 f8 03             	cmp    $0x3,%eax
c01014ef:	77 1e                	ja     c010150f <ide_write_secs+0x3f>
c01014f1:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01014f5:	c1 e0 03             	shl    $0x3,%eax
c01014f8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01014ff:	29 c2                	sub    %eax,%edx
c0101501:	89 d0                	mov    %edx,%eax
c0101503:	05 40 04 1b c0       	add    $0xc01b0440,%eax
c0101508:	0f b6 00             	movzbl (%eax),%eax
c010150b:	84 c0                	test   %al,%al
c010150d:	75 24                	jne    c0101533 <ide_write_secs+0x63>
c010150f:	c7 44 24 0c 24 c6 10 	movl   $0xc010c624,0xc(%esp)
c0101516:	c0 
c0101517:	c7 44 24 08 df c5 10 	movl   $0xc010c5df,0x8(%esp)
c010151e:	c0 
c010151f:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c0101526:	00 
c0101527:	c7 04 24 f4 c5 10 c0 	movl   $0xc010c5f4,(%esp)
c010152e:	e8 d2 ee ff ff       	call   c0100405 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101533:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c010153a:	77 0f                	ja     c010154b <ide_write_secs+0x7b>
c010153c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010153f:	8b 45 14             	mov    0x14(%ebp),%eax
c0101542:	01 d0                	add    %edx,%eax
c0101544:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101549:	76 24                	jbe    c010156f <ide_write_secs+0x9f>
c010154b:	c7 44 24 0c 4c c6 10 	movl   $0xc010c64c,0xc(%esp)
c0101552:	c0 
c0101553:	c7 44 24 08 df c5 10 	movl   $0xc010c5df,0x8(%esp)
c010155a:	c0 
c010155b:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
c0101562:	00 
c0101563:	c7 04 24 f4 c5 10 c0 	movl   $0xc010c5f4,(%esp)
c010156a:	e8 96 ee ff ff       	call   c0100405 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c010156f:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101573:	d1 e8                	shr    %eax
c0101575:	0f b7 c0             	movzwl %ax,%eax
c0101578:	8b 04 85 94 c5 10 c0 	mov    -0x3fef3a6c(,%eax,4),%eax
c010157f:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101583:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101587:	d1 e8                	shr    %eax
c0101589:	0f b7 c0             	movzwl %ax,%eax
c010158c:	0f b7 04 85 96 c5 10 	movzwl -0x3fef3a6a(,%eax,4),%eax
c0101593:	c0 
c0101594:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101598:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010159c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01015a3:	00 
c01015a4:	89 04 24             	mov    %eax,(%esp)
c01015a7:	e8 f6 f8 ff ff       	call   c0100ea2 <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c01015ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01015af:	83 c0 02             	add    $0x2,%eax
c01015b2:	0f b7 c0             	movzwl %ax,%eax
c01015b5:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c01015b9:	c6 45 d7 00          	movb   $0x0,-0x29(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01015bd:	0f b6 45 d7          	movzbl -0x29(%ebp),%eax
c01015c1:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01015c5:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c01015c6:	8b 45 14             	mov    0x14(%ebp),%eax
c01015c9:	0f b6 c0             	movzbl %al,%eax
c01015cc:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01015d0:	83 c2 02             	add    $0x2,%edx
c01015d3:	0f b7 d2             	movzwl %dx,%edx
c01015d6:	66 89 55 e8          	mov    %dx,-0x18(%ebp)
c01015da:	88 45 d8             	mov    %al,-0x28(%ebp)
c01015dd:	0f b6 45 d8          	movzbl -0x28(%ebp),%eax
c01015e1:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01015e4:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c01015e5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01015e8:	0f b6 c0             	movzbl %al,%eax
c01015eb:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01015ef:	83 c2 03             	add    $0x3,%edx
c01015f2:	0f b7 d2             	movzwl %dx,%edx
c01015f5:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01015f9:	88 45 d9             	mov    %al,-0x27(%ebp)
c01015fc:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101600:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101604:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101605:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101608:	c1 e8 08             	shr    $0x8,%eax
c010160b:	0f b6 c0             	movzbl %al,%eax
c010160e:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101612:	83 c2 04             	add    $0x4,%edx
c0101615:	0f b7 d2             	movzwl %dx,%edx
c0101618:	66 89 55 e4          	mov    %dx,-0x1c(%ebp)
c010161c:	88 45 da             	mov    %al,-0x26(%ebp)
c010161f:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
c0101623:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0101626:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101627:	8b 45 0c             	mov    0xc(%ebp),%eax
c010162a:	c1 e8 10             	shr    $0x10,%eax
c010162d:	0f b6 c0             	movzbl %al,%eax
c0101630:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101634:	83 c2 05             	add    $0x5,%edx
c0101637:	0f b7 d2             	movzwl %dx,%edx
c010163a:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c010163e:	88 45 db             	mov    %al,-0x25(%ebp)
c0101641:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
c0101645:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101649:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c010164a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010164d:	24 01                	and    $0x1,%al
c010164f:	c0 e0 04             	shl    $0x4,%al
c0101652:	88 c2                	mov    %al,%dl
c0101654:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101657:	c1 e8 18             	shr    $0x18,%eax
c010165a:	24 0f                	and    $0xf,%al
c010165c:	08 d0                	or     %dl,%al
c010165e:	0c e0                	or     $0xe0,%al
c0101660:	0f b6 c0             	movzbl %al,%eax
c0101663:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101667:	83 c2 06             	add    $0x6,%edx
c010166a:	0f b7 d2             	movzwl %dx,%edx
c010166d:	66 89 55 e0          	mov    %dx,-0x20(%ebp)
c0101671:	88 45 dc             	mov    %al,-0x24(%ebp)
c0101674:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
c0101678:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010167b:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);
c010167c:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101680:	83 c0 07             	add    $0x7,%eax
c0101683:	0f b7 c0             	movzwl %ax,%eax
c0101686:	66 89 45 de          	mov    %ax,-0x22(%ebp)
c010168a:	c6 45 dd 30          	movb   $0x30,-0x23(%ebp)
c010168e:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101692:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101696:	ee                   	out    %al,(%dx)

    int ret = 0;
c0101697:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c010169e:	eb 57                	jmp    c01016f7 <ide_write_secs+0x227>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c01016a0:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01016a4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01016ab:	00 
c01016ac:	89 04 24             	mov    %eax,(%esp)
c01016af:	e8 ee f7 ff ff       	call   c0100ea2 <ide_wait_ready>
c01016b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01016b7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01016bb:	75 42                	jne    c01016ff <ide_write_secs+0x22f>
            goto out;
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
c01016bd:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01016c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01016c4:	8b 45 10             	mov    0x10(%ebp),%eax
c01016c7:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01016ca:	c7 45 cc 80 00 00 00 	movl   $0x80,-0x34(%ebp)
    asm volatile ("outw %0, %1" :: "a" (data), "d" (port) : "memory");
}

static inline void
outsl(uint32_t port, const void *addr, int cnt) {
    asm volatile (
c01016d1:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01016d4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c01016d7:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01016da:	89 cb                	mov    %ecx,%ebx
c01016dc:	89 de                	mov    %ebx,%esi
c01016de:	89 c1                	mov    %eax,%ecx
c01016e0:	fc                   	cld    
c01016e1:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
c01016e3:	89 c8                	mov    %ecx,%eax
c01016e5:	89 f3                	mov    %esi,%ebx
c01016e7:	89 5d d0             	mov    %ebx,-0x30(%ebp)
c01016ea:	89 45 cc             	mov    %eax,-0x34(%ebp)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);

    int ret = 0;
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c01016ed:	ff 4d 14             	decl   0x14(%ebp)
c01016f0:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c01016f7:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c01016fb:	75 a3                	jne    c01016a0 <ide_write_secs+0x1d0>
c01016fd:	eb 01                	jmp    c0101700 <ide_write_secs+0x230>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
            goto out;
c01016ff:	90                   	nop
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
    }

out:
    return ret;
c0101700:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101703:	83 c4 50             	add    $0x50,%esp
c0101706:	5b                   	pop    %ebx
c0101707:	5e                   	pop    %esi
c0101708:	5d                   	pop    %ebp
c0101709:	c3                   	ret    

c010170a <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c010170a:	55                   	push   %ebp
c010170b:	89 e5                	mov    %esp,%ebp
c010170d:	83 ec 28             	sub    $0x28,%esp
c0101710:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
c0101716:	c6 45 ef 34          	movb   $0x34,-0x11(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010171a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
c010171e:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101722:	ee                   	out    %al,(%dx)
c0101723:	66 c7 45 f4 40 00    	movw   $0x40,-0xc(%ebp)
c0101729:	c6 45 f0 9c          	movb   $0x9c,-0x10(%ebp)
c010172d:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
c0101731:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101734:	ee                   	out    %al,(%dx)
c0101735:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c010173b:	c6 45 f1 2e          	movb   $0x2e,-0xf(%ebp)
c010173f:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101743:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101747:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0101748:	c7 05 78 30 1b c0 00 	movl   $0x0,0xc01b3078
c010174f:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0101752:	c7 04 24 86 c6 10 c0 	movl   $0xc010c686,(%esp)
c0101759:	e8 50 eb ff ff       	call   c01002ae <cprintf>
    pic_enable(IRQ_TIMER);
c010175e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0101765:	e8 1e 09 00 00       	call   c0102088 <pic_enable>
}
c010176a:	90                   	nop
c010176b:	c9                   	leave  
c010176c:	c3                   	ret    

c010176d <__intr_save>:
#include <assert.h>
#include <atomic.h>
#include <sched.h>

static inline bool
__intr_save(void) {
c010176d:	55                   	push   %ebp
c010176e:	89 e5                	mov    %esp,%ebp
c0101770:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0101773:	9c                   	pushf  
c0101774:	58                   	pop    %eax
c0101775:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0101778:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c010177b:	25 00 02 00 00       	and    $0x200,%eax
c0101780:	85 c0                	test   %eax,%eax
c0101782:	74 0c                	je     c0101790 <__intr_save+0x23>
        intr_disable();
c0101784:	e8 6c 0a 00 00       	call   c01021f5 <intr_disable>
        return 1;
c0101789:	b8 01 00 00 00       	mov    $0x1,%eax
c010178e:	eb 05                	jmp    c0101795 <__intr_save+0x28>
    }
    return 0;
c0101790:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101795:	c9                   	leave  
c0101796:	c3                   	ret    

c0101797 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0101797:	55                   	push   %ebp
c0101798:	89 e5                	mov    %esp,%ebp
c010179a:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c010179d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01017a1:	74 05                	je     c01017a8 <__intr_restore+0x11>
        intr_enable();
c01017a3:	e8 46 0a 00 00       	call   c01021ee <intr_enable>
    }
}
c01017a8:	90                   	nop
c01017a9:	c9                   	leave  
c01017aa:	c3                   	ret    

c01017ab <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c01017ab:	55                   	push   %ebp
c01017ac:	89 e5                	mov    %esp,%ebp
c01017ae:	83 ec 10             	sub    $0x10,%esp
c01017b1:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01017b7:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c01017bb:	89 c2                	mov    %eax,%edx
c01017bd:	ec                   	in     (%dx),%al
c01017be:	88 45 f4             	mov    %al,-0xc(%ebp)
c01017c1:	66 c7 45 fc 84 00    	movw   $0x84,-0x4(%ebp)
c01017c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01017ca:	89 c2                	mov    %eax,%edx
c01017cc:	ec                   	in     (%dx),%al
c01017cd:	88 45 f5             	mov    %al,-0xb(%ebp)
c01017d0:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c01017d6:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01017da:	89 c2                	mov    %eax,%edx
c01017dc:	ec                   	in     (%dx),%al
c01017dd:	88 45 f6             	mov    %al,-0xa(%ebp)
c01017e0:	66 c7 45 f8 84 00    	movw   $0x84,-0x8(%ebp)
c01017e6:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01017e9:	89 c2                	mov    %eax,%edx
c01017eb:	ec                   	in     (%dx),%al
c01017ec:	88 45 f7             	mov    %al,-0x9(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c01017ef:	90                   	nop
c01017f0:	c9                   	leave  
c01017f1:	c3                   	ret    

c01017f2 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c01017f2:	55                   	push   %ebp
c01017f3:	89 e5                	mov    %esp,%ebp
c01017f5:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c01017f8:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c01017ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101802:	0f b7 00             	movzwl (%eax),%eax
c0101805:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0101809:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010180c:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0101811:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101814:	0f b7 00             	movzwl (%eax),%eax
c0101817:	0f b7 c0             	movzwl %ax,%eax
c010181a:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
c010181f:	74 12                	je     c0101833 <cga_init+0x41>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0101821:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0101828:	66 c7 05 26 05 1b c0 	movw   $0x3b4,0xc01b0526
c010182f:	b4 03 
c0101831:	eb 13                	jmp    c0101846 <cga_init+0x54>
    } else {
        *cp = was;
c0101833:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101836:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c010183a:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c010183d:	66 c7 05 26 05 1b c0 	movw   $0x3d4,0xc01b0526
c0101844:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0101846:	0f b7 05 26 05 1b c0 	movzwl 0xc01b0526,%eax
c010184d:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
c0101851:	c6 45 ea 0e          	movb   $0xe,-0x16(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101855:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
c0101859:	8b 55 f8             	mov    -0x8(%ebp),%edx
c010185c:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c010185d:	0f b7 05 26 05 1b c0 	movzwl 0xc01b0526,%eax
c0101864:	40                   	inc    %eax
c0101865:	0f b7 c0             	movzwl %ax,%eax
c0101868:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010186c:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101870:	89 c2                	mov    %eax,%edx
c0101872:	ec                   	in     (%dx),%al
c0101873:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0101876:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
c010187a:	0f b6 c0             	movzbl %al,%eax
c010187d:	c1 e0 08             	shl    $0x8,%eax
c0101880:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0101883:	0f b7 05 26 05 1b c0 	movzwl 0xc01b0526,%eax
c010188a:	66 89 45 f0          	mov    %ax,-0x10(%ebp)
c010188e:	c6 45 ec 0f          	movb   $0xf,-0x14(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101892:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
c0101896:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0101899:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c010189a:	0f b7 05 26 05 1b c0 	movzwl 0xc01b0526,%eax
c01018a1:	40                   	inc    %eax
c01018a2:	0f b7 c0             	movzwl %ax,%eax
c01018a5:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01018a9:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c01018ad:	89 c2                	mov    %eax,%edx
c01018af:	ec                   	in     (%dx),%al
c01018b0:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c01018b3:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01018b7:	0f b6 c0             	movzbl %al,%eax
c01018ba:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c01018bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018c0:	a3 20 05 1b c0       	mov    %eax,0xc01b0520
    crt_pos = pos;
c01018c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01018c8:	0f b7 c0             	movzwl %ax,%eax
c01018cb:	66 a3 24 05 1b c0    	mov    %ax,0xc01b0524
}
c01018d1:	90                   	nop
c01018d2:	c9                   	leave  
c01018d3:	c3                   	ret    

c01018d4 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c01018d4:	55                   	push   %ebp
c01018d5:	89 e5                	mov    %esp,%ebp
c01018d7:	83 ec 38             	sub    $0x38,%esp
c01018da:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
c01018e0:	c6 45 da 00          	movb   $0x0,-0x26(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018e4:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
c01018e8:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01018ec:	ee                   	out    %al,(%dx)
c01018ed:	66 c7 45 f4 fb 03    	movw   $0x3fb,-0xc(%ebp)
c01018f3:	c6 45 db 80          	movb   $0x80,-0x25(%ebp)
c01018f7:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
c01018fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01018fe:	ee                   	out    %al,(%dx)
c01018ff:	66 c7 45 f2 f8 03    	movw   $0x3f8,-0xe(%ebp)
c0101905:	c6 45 dc 0c          	movb   $0xc,-0x24(%ebp)
c0101909:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
c010190d:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101911:	ee                   	out    %al,(%dx)
c0101912:	66 c7 45 f0 f9 03    	movw   $0x3f9,-0x10(%ebp)
c0101918:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
c010191c:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101920:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0101923:	ee                   	out    %al,(%dx)
c0101924:	66 c7 45 ee fb 03    	movw   $0x3fb,-0x12(%ebp)
c010192a:	c6 45 de 03          	movb   $0x3,-0x22(%ebp)
c010192e:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
c0101932:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101936:	ee                   	out    %al,(%dx)
c0101937:	66 c7 45 ec fc 03    	movw   $0x3fc,-0x14(%ebp)
c010193d:	c6 45 df 00          	movb   $0x0,-0x21(%ebp)
c0101941:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
c0101945:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0101948:	ee                   	out    %al,(%dx)
c0101949:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c010194f:	c6 45 e0 01          	movb   $0x1,-0x20(%ebp)
c0101953:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
c0101957:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010195b:	ee                   	out    %al,(%dx)
c010195c:	66 c7 45 e8 fd 03    	movw   $0x3fd,-0x18(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101962:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0101965:	89 c2                	mov    %eax,%edx
c0101967:	ec                   	in     (%dx),%al
c0101968:	88 45 e1             	mov    %al,-0x1f(%ebp)
    return data;
c010196b:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c010196f:	3c ff                	cmp    $0xff,%al
c0101971:	0f 95 c0             	setne  %al
c0101974:	0f b6 c0             	movzbl %al,%eax
c0101977:	a3 28 05 1b c0       	mov    %eax,0xc01b0528
c010197c:	66 c7 45 e6 fa 03    	movw   $0x3fa,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101982:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c0101986:	89 c2                	mov    %eax,%edx
c0101988:	ec                   	in     (%dx),%al
c0101989:	88 45 e2             	mov    %al,-0x1e(%ebp)
c010198c:	66 c7 45 e4 f8 03    	movw   $0x3f8,-0x1c(%ebp)
c0101992:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101995:	89 c2                	mov    %eax,%edx
c0101997:	ec                   	in     (%dx),%al
c0101998:	88 45 e3             	mov    %al,-0x1d(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c010199b:	a1 28 05 1b c0       	mov    0xc01b0528,%eax
c01019a0:	85 c0                	test   %eax,%eax
c01019a2:	74 0c                	je     c01019b0 <serial_init+0xdc>
        pic_enable(IRQ_COM1);
c01019a4:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c01019ab:	e8 d8 06 00 00       	call   c0102088 <pic_enable>
    }
}
c01019b0:	90                   	nop
c01019b1:	c9                   	leave  
c01019b2:	c3                   	ret    

c01019b3 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c01019b3:	55                   	push   %ebp
c01019b4:	89 e5                	mov    %esp,%ebp
c01019b6:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01019b9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01019c0:	eb 08                	jmp    c01019ca <lpt_putc_sub+0x17>
        delay();
c01019c2:	e8 e4 fd ff ff       	call   c01017ab <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01019c7:	ff 45 fc             	incl   -0x4(%ebp)
c01019ca:	66 c7 45 f4 79 03    	movw   $0x379,-0xc(%ebp)
c01019d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01019d3:	89 c2                	mov    %eax,%edx
c01019d5:	ec                   	in     (%dx),%al
c01019d6:	88 45 f3             	mov    %al,-0xd(%ebp)
    return data;
c01019d9:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01019dd:	84 c0                	test   %al,%al
c01019df:	78 09                	js     c01019ea <lpt_putc_sub+0x37>
c01019e1:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c01019e8:	7e d8                	jle    c01019c2 <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
c01019ea:	8b 45 08             	mov    0x8(%ebp),%eax
c01019ed:	0f b6 c0             	movzbl %al,%eax
c01019f0:	66 c7 45 f8 78 03    	movw   $0x378,-0x8(%ebp)
c01019f6:	88 45 f0             	mov    %al,-0x10(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01019f9:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
c01019fd:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0101a00:	ee                   	out    %al,(%dx)
c0101a01:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
c0101a07:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c0101a0b:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101a0f:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101a13:	ee                   	out    %al,(%dx)
c0101a14:	66 c7 45 fa 7a 03    	movw   $0x37a,-0x6(%ebp)
c0101a1a:	c6 45 f2 08          	movb   $0x8,-0xe(%ebp)
c0101a1e:	0f b6 45 f2          	movzbl -0xe(%ebp),%eax
c0101a22:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101a26:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c0101a27:	90                   	nop
c0101a28:	c9                   	leave  
c0101a29:	c3                   	ret    

c0101a2a <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c0101a2a:	55                   	push   %ebp
c0101a2b:	89 e5                	mov    %esp,%ebp
c0101a2d:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101a30:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101a34:	74 0d                	je     c0101a43 <lpt_putc+0x19>
        lpt_putc_sub(c);
c0101a36:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a39:	89 04 24             	mov    %eax,(%esp)
c0101a3c:	e8 72 ff ff ff       	call   c01019b3 <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
c0101a41:	eb 24                	jmp    c0101a67 <lpt_putc+0x3d>
lpt_putc(int c) {
    if (c != '\b') {
        lpt_putc_sub(c);
    }
    else {
        lpt_putc_sub('\b');
c0101a43:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101a4a:	e8 64 ff ff ff       	call   c01019b3 <lpt_putc_sub>
        lpt_putc_sub(' ');
c0101a4f:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101a56:	e8 58 ff ff ff       	call   c01019b3 <lpt_putc_sub>
        lpt_putc_sub('\b');
c0101a5b:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101a62:	e8 4c ff ff ff       	call   c01019b3 <lpt_putc_sub>
    }
}
c0101a67:	90                   	nop
c0101a68:	c9                   	leave  
c0101a69:	c3                   	ret    

c0101a6a <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c0101a6a:	55                   	push   %ebp
c0101a6b:	89 e5                	mov    %esp,%ebp
c0101a6d:	53                   	push   %ebx
c0101a6e:	83 ec 24             	sub    $0x24,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c0101a71:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a74:	25 00 ff ff ff       	and    $0xffffff00,%eax
c0101a79:	85 c0                	test   %eax,%eax
c0101a7b:	75 07                	jne    c0101a84 <cga_putc+0x1a>
        c |= 0x0700;
c0101a7d:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c0101a84:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a87:	0f b6 c0             	movzbl %al,%eax
c0101a8a:	83 f8 0a             	cmp    $0xa,%eax
c0101a8d:	74 54                	je     c0101ae3 <cga_putc+0x79>
c0101a8f:	83 f8 0d             	cmp    $0xd,%eax
c0101a92:	74 62                	je     c0101af6 <cga_putc+0x8c>
c0101a94:	83 f8 08             	cmp    $0x8,%eax
c0101a97:	0f 85 93 00 00 00    	jne    c0101b30 <cga_putc+0xc6>
    case '\b':
        if (crt_pos > 0) {
c0101a9d:	0f b7 05 24 05 1b c0 	movzwl 0xc01b0524,%eax
c0101aa4:	85 c0                	test   %eax,%eax
c0101aa6:	0f 84 ae 00 00 00    	je     c0101b5a <cga_putc+0xf0>
            crt_pos --;
c0101aac:	0f b7 05 24 05 1b c0 	movzwl 0xc01b0524,%eax
c0101ab3:	48                   	dec    %eax
c0101ab4:	0f b7 c0             	movzwl %ax,%eax
c0101ab7:	66 a3 24 05 1b c0    	mov    %ax,0xc01b0524
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c0101abd:	a1 20 05 1b c0       	mov    0xc01b0520,%eax
c0101ac2:	0f b7 15 24 05 1b c0 	movzwl 0xc01b0524,%edx
c0101ac9:	01 d2                	add    %edx,%edx
c0101acb:	01 c2                	add    %eax,%edx
c0101acd:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ad0:	98                   	cwtl   
c0101ad1:	25 00 ff ff ff       	and    $0xffffff00,%eax
c0101ad6:	98                   	cwtl   
c0101ad7:	83 c8 20             	or     $0x20,%eax
c0101ada:	98                   	cwtl   
c0101adb:	0f b7 c0             	movzwl %ax,%eax
c0101ade:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c0101ae1:	eb 77                	jmp    c0101b5a <cga_putc+0xf0>
    case '\n':
        crt_pos += CRT_COLS;
c0101ae3:	0f b7 05 24 05 1b c0 	movzwl 0xc01b0524,%eax
c0101aea:	83 c0 50             	add    $0x50,%eax
c0101aed:	0f b7 c0             	movzwl %ax,%eax
c0101af0:	66 a3 24 05 1b c0    	mov    %ax,0xc01b0524
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c0101af6:	0f b7 1d 24 05 1b c0 	movzwl 0xc01b0524,%ebx
c0101afd:	0f b7 0d 24 05 1b c0 	movzwl 0xc01b0524,%ecx
c0101b04:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
c0101b09:	89 c8                	mov    %ecx,%eax
c0101b0b:	f7 e2                	mul    %edx
c0101b0d:	c1 ea 06             	shr    $0x6,%edx
c0101b10:	89 d0                	mov    %edx,%eax
c0101b12:	c1 e0 02             	shl    $0x2,%eax
c0101b15:	01 d0                	add    %edx,%eax
c0101b17:	c1 e0 04             	shl    $0x4,%eax
c0101b1a:	29 c1                	sub    %eax,%ecx
c0101b1c:	89 c8                	mov    %ecx,%eax
c0101b1e:	0f b7 c0             	movzwl %ax,%eax
c0101b21:	29 c3                	sub    %eax,%ebx
c0101b23:	89 d8                	mov    %ebx,%eax
c0101b25:	0f b7 c0             	movzwl %ax,%eax
c0101b28:	66 a3 24 05 1b c0    	mov    %ax,0xc01b0524
        break;
c0101b2e:	eb 2b                	jmp    c0101b5b <cga_putc+0xf1>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c0101b30:	8b 0d 20 05 1b c0    	mov    0xc01b0520,%ecx
c0101b36:	0f b7 05 24 05 1b c0 	movzwl 0xc01b0524,%eax
c0101b3d:	8d 50 01             	lea    0x1(%eax),%edx
c0101b40:	0f b7 d2             	movzwl %dx,%edx
c0101b43:	66 89 15 24 05 1b c0 	mov    %dx,0xc01b0524
c0101b4a:	01 c0                	add    %eax,%eax
c0101b4c:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c0101b4f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b52:	0f b7 c0             	movzwl %ax,%eax
c0101b55:	66 89 02             	mov    %ax,(%edx)
        break;
c0101b58:	eb 01                	jmp    c0101b5b <cga_putc+0xf1>
    case '\b':
        if (crt_pos > 0) {
            crt_pos --;
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
        }
        break;
c0101b5a:	90                   	nop
        crt_buf[crt_pos ++] = c;     // write the character
        break;
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c0101b5b:	0f b7 05 24 05 1b c0 	movzwl 0xc01b0524,%eax
c0101b62:	3d cf 07 00 00       	cmp    $0x7cf,%eax
c0101b67:	76 5d                	jbe    c0101bc6 <cga_putc+0x15c>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c0101b69:	a1 20 05 1b c0       	mov    0xc01b0520,%eax
c0101b6e:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c0101b74:	a1 20 05 1b c0       	mov    0xc01b0520,%eax
c0101b79:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c0101b80:	00 
c0101b81:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101b85:	89 04 24             	mov    %eax,(%esp)
c0101b88:	e8 39 9e 00 00       	call   c010b9c6 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101b8d:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c0101b94:	eb 14                	jmp    c0101baa <cga_putc+0x140>
            crt_buf[i] = 0x0700 | ' ';
c0101b96:	a1 20 05 1b c0       	mov    0xc01b0520,%eax
c0101b9b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101b9e:	01 d2                	add    %edx,%edx
c0101ba0:	01 d0                	add    %edx,%eax
c0101ba2:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101ba7:	ff 45 f4             	incl   -0xc(%ebp)
c0101baa:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c0101bb1:	7e e3                	jle    c0101b96 <cga_putc+0x12c>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
c0101bb3:	0f b7 05 24 05 1b c0 	movzwl 0xc01b0524,%eax
c0101bba:	83 e8 50             	sub    $0x50,%eax
c0101bbd:	0f b7 c0             	movzwl %ax,%eax
c0101bc0:	66 a3 24 05 1b c0    	mov    %ax,0xc01b0524
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c0101bc6:	0f b7 05 26 05 1b c0 	movzwl 0xc01b0526,%eax
c0101bcd:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101bd1:	c6 45 e8 0e          	movb   $0xe,-0x18(%ebp)
c0101bd5:	0f b6 45 e8          	movzbl -0x18(%ebp),%eax
c0101bd9:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101bdd:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c0101bde:	0f b7 05 24 05 1b c0 	movzwl 0xc01b0524,%eax
c0101be5:	c1 e8 08             	shr    $0x8,%eax
c0101be8:	0f b7 c0             	movzwl %ax,%eax
c0101beb:	0f b6 c0             	movzbl %al,%eax
c0101bee:	0f b7 15 26 05 1b c0 	movzwl 0xc01b0526,%edx
c0101bf5:	42                   	inc    %edx
c0101bf6:	0f b7 d2             	movzwl %dx,%edx
c0101bf9:	66 89 55 f0          	mov    %dx,-0x10(%ebp)
c0101bfd:	88 45 e9             	mov    %al,-0x17(%ebp)
c0101c00:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101c04:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0101c07:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c0101c08:	0f b7 05 26 05 1b c0 	movzwl 0xc01b0526,%eax
c0101c0f:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101c13:	c6 45 ea 0f          	movb   $0xf,-0x16(%ebp)
c0101c17:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
c0101c1b:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101c1f:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c0101c20:	0f b7 05 24 05 1b c0 	movzwl 0xc01b0524,%eax
c0101c27:	0f b6 c0             	movzbl %al,%eax
c0101c2a:	0f b7 15 26 05 1b c0 	movzwl 0xc01b0526,%edx
c0101c31:	42                   	inc    %edx
c0101c32:	0f b7 d2             	movzwl %dx,%edx
c0101c35:	66 89 55 ec          	mov    %dx,-0x14(%ebp)
c0101c39:	88 45 eb             	mov    %al,-0x15(%ebp)
c0101c3c:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
c0101c40:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0101c43:	ee                   	out    %al,(%dx)
}
c0101c44:	90                   	nop
c0101c45:	83 c4 24             	add    $0x24,%esp
c0101c48:	5b                   	pop    %ebx
c0101c49:	5d                   	pop    %ebp
c0101c4a:	c3                   	ret    

c0101c4b <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c0101c4b:	55                   	push   %ebp
c0101c4c:	89 e5                	mov    %esp,%ebp
c0101c4e:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101c51:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101c58:	eb 08                	jmp    c0101c62 <serial_putc_sub+0x17>
        delay();
c0101c5a:	e8 4c fb ff ff       	call   c01017ab <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101c5f:	ff 45 fc             	incl   -0x4(%ebp)
c0101c62:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101c68:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0101c6b:	89 c2                	mov    %eax,%edx
c0101c6d:	ec                   	in     (%dx),%al
c0101c6e:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
c0101c71:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0101c75:	0f b6 c0             	movzbl %al,%eax
c0101c78:	83 e0 20             	and    $0x20,%eax
c0101c7b:	85 c0                	test   %eax,%eax
c0101c7d:	75 09                	jne    c0101c88 <serial_putc_sub+0x3d>
c0101c7f:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101c86:	7e d2                	jle    c0101c5a <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
c0101c88:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c8b:	0f b6 c0             	movzbl %al,%eax
c0101c8e:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
c0101c94:	88 45 f6             	mov    %al,-0xa(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101c97:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
c0101c9b:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101c9f:	ee                   	out    %al,(%dx)
}
c0101ca0:	90                   	nop
c0101ca1:	c9                   	leave  
c0101ca2:	c3                   	ret    

c0101ca3 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0101ca3:	55                   	push   %ebp
c0101ca4:	89 e5                	mov    %esp,%ebp
c0101ca6:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101ca9:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101cad:	74 0d                	je     c0101cbc <serial_putc+0x19>
        serial_putc_sub(c);
c0101caf:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cb2:	89 04 24             	mov    %eax,(%esp)
c0101cb5:	e8 91 ff ff ff       	call   c0101c4b <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
c0101cba:	eb 24                	jmp    c0101ce0 <serial_putc+0x3d>
serial_putc(int c) {
    if (c != '\b') {
        serial_putc_sub(c);
    }
    else {
        serial_putc_sub('\b');
c0101cbc:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101cc3:	e8 83 ff ff ff       	call   c0101c4b <serial_putc_sub>
        serial_putc_sub(' ');
c0101cc8:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101ccf:	e8 77 ff ff ff       	call   c0101c4b <serial_putc_sub>
        serial_putc_sub('\b');
c0101cd4:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101cdb:	e8 6b ff ff ff       	call   c0101c4b <serial_putc_sub>
    }
}
c0101ce0:	90                   	nop
c0101ce1:	c9                   	leave  
c0101ce2:	c3                   	ret    

c0101ce3 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0101ce3:	55                   	push   %ebp
c0101ce4:	89 e5                	mov    %esp,%ebp
c0101ce6:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c0101ce9:	eb 33                	jmp    c0101d1e <cons_intr+0x3b>
        if (c != 0) {
c0101ceb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101cef:	74 2d                	je     c0101d1e <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c0101cf1:	a1 44 07 1b c0       	mov    0xc01b0744,%eax
c0101cf6:	8d 50 01             	lea    0x1(%eax),%edx
c0101cf9:	89 15 44 07 1b c0    	mov    %edx,0xc01b0744
c0101cff:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101d02:	88 90 40 05 1b c0    	mov    %dl,-0x3fe4fac0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0101d08:	a1 44 07 1b c0       	mov    0xc01b0744,%eax
c0101d0d:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101d12:	75 0a                	jne    c0101d1e <cons_intr+0x3b>
                cons.wpos = 0;
c0101d14:	c7 05 44 07 1b c0 00 	movl   $0x0,0xc01b0744
c0101d1b:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
c0101d1e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d21:	ff d0                	call   *%eax
c0101d23:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101d26:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c0101d2a:	75 bf                	jne    c0101ceb <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
c0101d2c:	90                   	nop
c0101d2d:	c9                   	leave  
c0101d2e:	c3                   	ret    

c0101d2f <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c0101d2f:	55                   	push   %ebp
c0101d30:	89 e5                	mov    %esp,%ebp
c0101d32:	83 ec 10             	sub    $0x10,%esp
c0101d35:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101d3b:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0101d3e:	89 c2                	mov    %eax,%edx
c0101d40:	ec                   	in     (%dx),%al
c0101d41:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
c0101d44:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c0101d48:	0f b6 c0             	movzbl %al,%eax
c0101d4b:	83 e0 01             	and    $0x1,%eax
c0101d4e:	85 c0                	test   %eax,%eax
c0101d50:	75 07                	jne    c0101d59 <serial_proc_data+0x2a>
        return -1;
c0101d52:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101d57:	eb 2a                	jmp    c0101d83 <serial_proc_data+0x54>
c0101d59:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101d5f:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101d63:	89 c2                	mov    %eax,%edx
c0101d65:	ec                   	in     (%dx),%al
c0101d66:	88 45 f6             	mov    %al,-0xa(%ebp)
    return data;
c0101d69:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c0101d6d:	0f b6 c0             	movzbl %al,%eax
c0101d70:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c0101d73:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0101d77:	75 07                	jne    c0101d80 <serial_proc_data+0x51>
        c = '\b';
c0101d79:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0101d80:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101d83:	c9                   	leave  
c0101d84:	c3                   	ret    

c0101d85 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0101d85:	55                   	push   %ebp
c0101d86:	89 e5                	mov    %esp,%ebp
c0101d88:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c0101d8b:	a1 28 05 1b c0       	mov    0xc01b0528,%eax
c0101d90:	85 c0                	test   %eax,%eax
c0101d92:	74 0c                	je     c0101da0 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c0101d94:	c7 04 24 2f 1d 10 c0 	movl   $0xc0101d2f,(%esp)
c0101d9b:	e8 43 ff ff ff       	call   c0101ce3 <cons_intr>
    }
}
c0101da0:	90                   	nop
c0101da1:	c9                   	leave  
c0101da2:	c3                   	ret    

c0101da3 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101da3:	55                   	push   %ebp
c0101da4:	89 e5                	mov    %esp,%ebp
c0101da6:	83 ec 28             	sub    $0x28,%esp
c0101da9:	66 c7 45 ec 64 00    	movw   $0x64,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101daf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101db2:	89 c2                	mov    %eax,%edx
c0101db4:	ec                   	in     (%dx),%al
c0101db5:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0101db8:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c0101dbc:	0f b6 c0             	movzbl %al,%eax
c0101dbf:	83 e0 01             	and    $0x1,%eax
c0101dc2:	85 c0                	test   %eax,%eax
c0101dc4:	75 0a                	jne    c0101dd0 <kbd_proc_data+0x2d>
        return -1;
c0101dc6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101dcb:	e9 56 01 00 00       	jmp    c0101f26 <kbd_proc_data+0x183>
c0101dd0:	66 c7 45 f0 60 00    	movw   $0x60,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101dd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101dd9:	89 c2                	mov    %eax,%edx
c0101ddb:	ec                   	in     (%dx),%al
c0101ddc:	88 45 ea             	mov    %al,-0x16(%ebp)
    return data;
c0101ddf:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
    }

    data = inb(KBDATAP);
c0101de3:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0101de6:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c0101dea:	75 17                	jne    c0101e03 <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
c0101dec:	a1 48 07 1b c0       	mov    0xc01b0748,%eax
c0101df1:	83 c8 40             	or     $0x40,%eax
c0101df4:	a3 48 07 1b c0       	mov    %eax,0xc01b0748
        return 0;
c0101df9:	b8 00 00 00 00       	mov    $0x0,%eax
c0101dfe:	e9 23 01 00 00       	jmp    c0101f26 <kbd_proc_data+0x183>
    } else if (data & 0x80) {
c0101e03:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101e07:	84 c0                	test   %al,%al
c0101e09:	79 45                	jns    c0101e50 <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c0101e0b:	a1 48 07 1b c0       	mov    0xc01b0748,%eax
c0101e10:	83 e0 40             	and    $0x40,%eax
c0101e13:	85 c0                	test   %eax,%eax
c0101e15:	75 08                	jne    c0101e1f <kbd_proc_data+0x7c>
c0101e17:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101e1b:	24 7f                	and    $0x7f,%al
c0101e1d:	eb 04                	jmp    c0101e23 <kbd_proc_data+0x80>
c0101e1f:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101e23:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c0101e26:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101e2a:	0f b6 80 40 c0 12 c0 	movzbl -0x3fed3fc0(%eax),%eax
c0101e31:	0c 40                	or     $0x40,%al
c0101e33:	0f b6 c0             	movzbl %al,%eax
c0101e36:	f7 d0                	not    %eax
c0101e38:	89 c2                	mov    %eax,%edx
c0101e3a:	a1 48 07 1b c0       	mov    0xc01b0748,%eax
c0101e3f:	21 d0                	and    %edx,%eax
c0101e41:	a3 48 07 1b c0       	mov    %eax,0xc01b0748
        return 0;
c0101e46:	b8 00 00 00 00       	mov    $0x0,%eax
c0101e4b:	e9 d6 00 00 00       	jmp    c0101f26 <kbd_proc_data+0x183>
    } else if (shift & E0ESC) {
c0101e50:	a1 48 07 1b c0       	mov    0xc01b0748,%eax
c0101e55:	83 e0 40             	and    $0x40,%eax
c0101e58:	85 c0                	test   %eax,%eax
c0101e5a:	74 11                	je     c0101e6d <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c0101e5c:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c0101e60:	a1 48 07 1b c0       	mov    0xc01b0748,%eax
c0101e65:	83 e0 bf             	and    $0xffffffbf,%eax
c0101e68:	a3 48 07 1b c0       	mov    %eax,0xc01b0748
    }

    shift |= shiftcode[data];
c0101e6d:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101e71:	0f b6 80 40 c0 12 c0 	movzbl -0x3fed3fc0(%eax),%eax
c0101e78:	0f b6 d0             	movzbl %al,%edx
c0101e7b:	a1 48 07 1b c0       	mov    0xc01b0748,%eax
c0101e80:	09 d0                	or     %edx,%eax
c0101e82:	a3 48 07 1b c0       	mov    %eax,0xc01b0748
    shift ^= togglecode[data];
c0101e87:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101e8b:	0f b6 80 40 c1 12 c0 	movzbl -0x3fed3ec0(%eax),%eax
c0101e92:	0f b6 d0             	movzbl %al,%edx
c0101e95:	a1 48 07 1b c0       	mov    0xc01b0748,%eax
c0101e9a:	31 d0                	xor    %edx,%eax
c0101e9c:	a3 48 07 1b c0       	mov    %eax,0xc01b0748

    c = charcode[shift & (CTL | SHIFT)][data];
c0101ea1:	a1 48 07 1b c0       	mov    0xc01b0748,%eax
c0101ea6:	83 e0 03             	and    $0x3,%eax
c0101ea9:	8b 14 85 40 c5 12 c0 	mov    -0x3fed3ac0(,%eax,4),%edx
c0101eb0:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101eb4:	01 d0                	add    %edx,%eax
c0101eb6:	0f b6 00             	movzbl (%eax),%eax
c0101eb9:	0f b6 c0             	movzbl %al,%eax
c0101ebc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101ebf:	a1 48 07 1b c0       	mov    0xc01b0748,%eax
c0101ec4:	83 e0 08             	and    $0x8,%eax
c0101ec7:	85 c0                	test   %eax,%eax
c0101ec9:	74 22                	je     c0101eed <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
c0101ecb:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0101ecf:	7e 0c                	jle    c0101edd <kbd_proc_data+0x13a>
c0101ed1:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101ed5:	7f 06                	jg     c0101edd <kbd_proc_data+0x13a>
            c += 'A' - 'a';
c0101ed7:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c0101edb:	eb 10                	jmp    c0101eed <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
c0101edd:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101ee1:	7e 0a                	jle    c0101eed <kbd_proc_data+0x14a>
c0101ee3:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c0101ee7:	7f 04                	jg     c0101eed <kbd_proc_data+0x14a>
            c += 'a' - 'A';
c0101ee9:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c0101eed:	a1 48 07 1b c0       	mov    0xc01b0748,%eax
c0101ef2:	f7 d0                	not    %eax
c0101ef4:	83 e0 06             	and    $0x6,%eax
c0101ef7:	85 c0                	test   %eax,%eax
c0101ef9:	75 28                	jne    c0101f23 <kbd_proc_data+0x180>
c0101efb:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0101f02:	75 1f                	jne    c0101f23 <kbd_proc_data+0x180>
        cprintf("Rebooting!\n");
c0101f04:	c7 04 24 a1 c6 10 c0 	movl   $0xc010c6a1,(%esp)
c0101f0b:	e8 9e e3 ff ff       	call   c01002ae <cprintf>
c0101f10:	66 c7 45 ee 92 00    	movw   $0x92,-0x12(%ebp)
c0101f16:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101f1a:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101f1e:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101f22:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c0101f23:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101f26:	c9                   	leave  
c0101f27:	c3                   	ret    

c0101f28 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c0101f28:	55                   	push   %ebp
c0101f29:	89 e5                	mov    %esp,%ebp
c0101f2b:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c0101f2e:	c7 04 24 a3 1d 10 c0 	movl   $0xc0101da3,(%esp)
c0101f35:	e8 a9 fd ff ff       	call   c0101ce3 <cons_intr>
}
c0101f3a:	90                   	nop
c0101f3b:	c9                   	leave  
c0101f3c:	c3                   	ret    

c0101f3d <kbd_init>:

static void
kbd_init(void) {
c0101f3d:	55                   	push   %ebp
c0101f3e:	89 e5                	mov    %esp,%ebp
c0101f40:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c0101f43:	e8 e0 ff ff ff       	call   c0101f28 <kbd_intr>
    pic_enable(IRQ_KBD);
c0101f48:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0101f4f:	e8 34 01 00 00       	call   c0102088 <pic_enable>
}
c0101f54:	90                   	nop
c0101f55:	c9                   	leave  
c0101f56:	c3                   	ret    

c0101f57 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c0101f57:	55                   	push   %ebp
c0101f58:	89 e5                	mov    %esp,%ebp
c0101f5a:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c0101f5d:	e8 90 f8 ff ff       	call   c01017f2 <cga_init>
    serial_init();
c0101f62:	e8 6d f9 ff ff       	call   c01018d4 <serial_init>
    kbd_init();
c0101f67:	e8 d1 ff ff ff       	call   c0101f3d <kbd_init>
    if (!serial_exists) {
c0101f6c:	a1 28 05 1b c0       	mov    0xc01b0528,%eax
c0101f71:	85 c0                	test   %eax,%eax
c0101f73:	75 0c                	jne    c0101f81 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c0101f75:	c7 04 24 ad c6 10 c0 	movl   $0xc010c6ad,(%esp)
c0101f7c:	e8 2d e3 ff ff       	call   c01002ae <cprintf>
    }
}
c0101f81:	90                   	nop
c0101f82:	c9                   	leave  
c0101f83:	c3                   	ret    

c0101f84 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c0101f84:	55                   	push   %ebp
c0101f85:	89 e5                	mov    %esp,%ebp
c0101f87:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0101f8a:	e8 de f7 ff ff       	call   c010176d <__intr_save>
c0101f8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0101f92:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f95:	89 04 24             	mov    %eax,(%esp)
c0101f98:	e8 8d fa ff ff       	call   c0101a2a <lpt_putc>
        cga_putc(c);
c0101f9d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101fa0:	89 04 24             	mov    %eax,(%esp)
c0101fa3:	e8 c2 fa ff ff       	call   c0101a6a <cga_putc>
        serial_putc(c);
c0101fa8:	8b 45 08             	mov    0x8(%ebp),%eax
c0101fab:	89 04 24             	mov    %eax,(%esp)
c0101fae:	e8 f0 fc ff ff       	call   c0101ca3 <serial_putc>
    }
    local_intr_restore(intr_flag);
c0101fb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101fb6:	89 04 24             	mov    %eax,(%esp)
c0101fb9:	e8 d9 f7 ff ff       	call   c0101797 <__intr_restore>
}
c0101fbe:	90                   	nop
c0101fbf:	c9                   	leave  
c0101fc0:	c3                   	ret    

c0101fc1 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c0101fc1:	55                   	push   %ebp
c0101fc2:	89 e5                	mov    %esp,%ebp
c0101fc4:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c0101fc7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0101fce:	e8 9a f7 ff ff       	call   c010176d <__intr_save>
c0101fd3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0101fd6:	e8 aa fd ff ff       	call   c0101d85 <serial_intr>
        kbd_intr();
c0101fdb:	e8 48 ff ff ff       	call   c0101f28 <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c0101fe0:	8b 15 40 07 1b c0    	mov    0xc01b0740,%edx
c0101fe6:	a1 44 07 1b c0       	mov    0xc01b0744,%eax
c0101feb:	39 c2                	cmp    %eax,%edx
c0101fed:	74 31                	je     c0102020 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c0101fef:	a1 40 07 1b c0       	mov    0xc01b0740,%eax
c0101ff4:	8d 50 01             	lea    0x1(%eax),%edx
c0101ff7:	89 15 40 07 1b c0    	mov    %edx,0xc01b0740
c0101ffd:	0f b6 80 40 05 1b c0 	movzbl -0x3fe4fac0(%eax),%eax
c0102004:	0f b6 c0             	movzbl %al,%eax
c0102007:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c010200a:	a1 40 07 1b c0       	mov    0xc01b0740,%eax
c010200f:	3d 00 02 00 00       	cmp    $0x200,%eax
c0102014:	75 0a                	jne    c0102020 <cons_getc+0x5f>
                cons.rpos = 0;
c0102016:	c7 05 40 07 1b c0 00 	movl   $0x0,0xc01b0740
c010201d:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c0102020:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102023:	89 04 24             	mov    %eax,(%esp)
c0102026:	e8 6c f7 ff ff       	call   c0101797 <__intr_restore>
    return c;
c010202b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010202e:	c9                   	leave  
c010202f:	c3                   	ret    

c0102030 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c0102030:	55                   	push   %ebp
c0102031:	89 e5                	mov    %esp,%ebp
c0102033:	83 ec 14             	sub    $0x14,%esp
c0102036:	8b 45 08             	mov    0x8(%ebp),%eax
c0102039:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c010203d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102040:	66 a3 50 c5 12 c0    	mov    %ax,0xc012c550
    if (did_init) {
c0102046:	a1 4c 07 1b c0       	mov    0xc01b074c,%eax
c010204b:	85 c0                	test   %eax,%eax
c010204d:	74 36                	je     c0102085 <pic_setmask+0x55>
        outb(IO_PIC1 + 1, mask);
c010204f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102052:	0f b6 c0             	movzbl %al,%eax
c0102055:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c010205b:	88 45 fa             	mov    %al,-0x6(%ebp)
c010205e:	0f b6 45 fa          	movzbl -0x6(%ebp),%eax
c0102062:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0102066:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c0102067:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c010206b:	c1 e8 08             	shr    $0x8,%eax
c010206e:	0f b7 c0             	movzwl %ax,%eax
c0102071:	0f b6 c0             	movzbl %al,%eax
c0102074:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
c010207a:	88 45 fb             	mov    %al,-0x5(%ebp)
c010207d:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
c0102081:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0102084:	ee                   	out    %al,(%dx)
    }
}
c0102085:	90                   	nop
c0102086:	c9                   	leave  
c0102087:	c3                   	ret    

c0102088 <pic_enable>:

void
pic_enable(unsigned int irq) {
c0102088:	55                   	push   %ebp
c0102089:	89 e5                	mov    %esp,%ebp
c010208b:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c010208e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102091:	ba 01 00 00 00       	mov    $0x1,%edx
c0102096:	88 c1                	mov    %al,%cl
c0102098:	d3 e2                	shl    %cl,%edx
c010209a:	89 d0                	mov    %edx,%eax
c010209c:	98                   	cwtl   
c010209d:	f7 d0                	not    %eax
c010209f:	0f bf d0             	movswl %ax,%edx
c01020a2:	0f b7 05 50 c5 12 c0 	movzwl 0xc012c550,%eax
c01020a9:	98                   	cwtl   
c01020aa:	21 d0                	and    %edx,%eax
c01020ac:	98                   	cwtl   
c01020ad:	0f b7 c0             	movzwl %ax,%eax
c01020b0:	89 04 24             	mov    %eax,(%esp)
c01020b3:	e8 78 ff ff ff       	call   c0102030 <pic_setmask>
}
c01020b8:	90                   	nop
c01020b9:	c9                   	leave  
c01020ba:	c3                   	ret    

c01020bb <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c01020bb:	55                   	push   %ebp
c01020bc:	89 e5                	mov    %esp,%ebp
c01020be:	83 ec 34             	sub    $0x34,%esp
    did_init = 1;
c01020c1:	c7 05 4c 07 1b c0 01 	movl   $0x1,0xc01b074c
c01020c8:	00 00 00 
c01020cb:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c01020d1:	c6 45 d6 ff          	movb   $0xff,-0x2a(%ebp)
c01020d5:	0f b6 45 d6          	movzbl -0x2a(%ebp),%eax
c01020d9:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c01020dd:	ee                   	out    %al,(%dx)
c01020de:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
c01020e4:	c6 45 d7 ff          	movb   $0xff,-0x29(%ebp)
c01020e8:	0f b6 45 d7          	movzbl -0x29(%ebp),%eax
c01020ec:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01020ef:	ee                   	out    %al,(%dx)
c01020f0:	66 c7 45 fa 20 00    	movw   $0x20,-0x6(%ebp)
c01020f6:	c6 45 d8 11          	movb   $0x11,-0x28(%ebp)
c01020fa:	0f b6 45 d8          	movzbl -0x28(%ebp),%eax
c01020fe:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0102102:	ee                   	out    %al,(%dx)
c0102103:	66 c7 45 f8 21 00    	movw   $0x21,-0x8(%ebp)
c0102109:	c6 45 d9 20          	movb   $0x20,-0x27(%ebp)
c010210d:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0102111:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0102114:	ee                   	out    %al,(%dx)
c0102115:	66 c7 45 f6 21 00    	movw   $0x21,-0xa(%ebp)
c010211b:	c6 45 da 04          	movb   $0x4,-0x26(%ebp)
c010211f:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
c0102123:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0102127:	ee                   	out    %al,(%dx)
c0102128:	66 c7 45 f4 21 00    	movw   $0x21,-0xc(%ebp)
c010212e:	c6 45 db 03          	movb   $0x3,-0x25(%ebp)
c0102132:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
c0102136:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102139:	ee                   	out    %al,(%dx)
c010213a:	66 c7 45 f2 a0 00    	movw   $0xa0,-0xe(%ebp)
c0102140:	c6 45 dc 11          	movb   $0x11,-0x24(%ebp)
c0102144:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
c0102148:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010214c:	ee                   	out    %al,(%dx)
c010214d:	66 c7 45 f0 a1 00    	movw   $0xa1,-0x10(%ebp)
c0102153:	c6 45 dd 28          	movb   $0x28,-0x23(%ebp)
c0102157:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c010215b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010215e:	ee                   	out    %al,(%dx)
c010215f:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
c0102165:	c6 45 de 02          	movb   $0x2,-0x22(%ebp)
c0102169:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
c010216d:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0102171:	ee                   	out    %al,(%dx)
c0102172:	66 c7 45 ec a1 00    	movw   $0xa1,-0x14(%ebp)
c0102178:	c6 45 df 03          	movb   $0x3,-0x21(%ebp)
c010217c:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
c0102180:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0102183:	ee                   	out    %al,(%dx)
c0102184:	66 c7 45 ea 20 00    	movw   $0x20,-0x16(%ebp)
c010218a:	c6 45 e0 68          	movb   $0x68,-0x20(%ebp)
c010218e:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
c0102192:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0102196:	ee                   	out    %al,(%dx)
c0102197:	66 c7 45 e8 20 00    	movw   $0x20,-0x18(%ebp)
c010219d:	c6 45 e1 0a          	movb   $0xa,-0x1f(%ebp)
c01021a1:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01021a5:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01021a8:	ee                   	out    %al,(%dx)
c01021a9:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
c01021af:	c6 45 e2 68          	movb   $0x68,-0x1e(%ebp)
c01021b3:	0f b6 45 e2          	movzbl -0x1e(%ebp),%eax
c01021b7:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01021bb:	ee                   	out    %al,(%dx)
c01021bc:	66 c7 45 e4 a0 00    	movw   $0xa0,-0x1c(%ebp)
c01021c2:	c6 45 e3 0a          	movb   $0xa,-0x1d(%ebp)
c01021c6:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
c01021ca:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01021cd:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c01021ce:	0f b7 05 50 c5 12 c0 	movzwl 0xc012c550,%eax
c01021d5:	3d ff ff 00 00       	cmp    $0xffff,%eax
c01021da:	74 0f                	je     c01021eb <pic_init+0x130>
        pic_setmask(irq_mask);
c01021dc:	0f b7 05 50 c5 12 c0 	movzwl 0xc012c550,%eax
c01021e3:	89 04 24             	mov    %eax,(%esp)
c01021e6:	e8 45 fe ff ff       	call   c0102030 <pic_setmask>
    }
}
c01021eb:	90                   	nop
c01021ec:	c9                   	leave  
c01021ed:	c3                   	ret    

c01021ee <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c01021ee:	55                   	push   %ebp
c01021ef:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
c01021f1:	fb                   	sti    
    sti();
}
c01021f2:	90                   	nop
c01021f3:	5d                   	pop    %ebp
c01021f4:	c3                   	ret    

c01021f5 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c01021f5:	55                   	push   %ebp
c01021f6:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
c01021f8:	fa                   	cli    
    cli();
}
c01021f9:	90                   	nop
c01021fa:	5d                   	pop    %ebp
c01021fb:	c3                   	ret    

c01021fc <print_ticks>:
#include <sync.h>
#include <proc.h>

#define TICK_NUM 100

static void print_ticks() {
c01021fc:	55                   	push   %ebp
c01021fd:	89 e5                	mov    %esp,%ebp
c01021ff:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c0102202:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0102209:	00 
c010220a:	c7 04 24 e0 c6 10 c0 	movl   $0xc010c6e0,(%esp)
c0102211:	e8 98 e0 ff ff       	call   c01002ae <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
c0102216:	90                   	nop
c0102217:	c9                   	leave  
c0102218:	c3                   	ret    

c0102219 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c0102219:	55                   	push   %ebp
c010221a:	89 e5                	mov    %esp,%ebp
c010221c:	83 ec 10             	sub    $0x10,%esp
     /* LAB5 YOUR CODE */ 
     //you should update your lab1 code (just add ONE or TWO lines of code), let user app to use syscall to get the service of ucore
     //so you should setup the syscall interrupt gate in here
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c010221f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0102226:	e9 c4 00 00 00       	jmp    c01022ef <idt_init+0xd6>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c010222b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010222e:	8b 04 85 e0 c5 12 c0 	mov    -0x3fed3a20(,%eax,4),%eax
c0102235:	0f b7 d0             	movzwl %ax,%edx
c0102238:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010223b:	66 89 14 c5 60 07 1b 	mov    %dx,-0x3fe4f8a0(,%eax,8)
c0102242:	c0 
c0102243:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102246:	66 c7 04 c5 62 07 1b 	movw   $0x8,-0x3fe4f89e(,%eax,8)
c010224d:	c0 08 00 
c0102250:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102253:	0f b6 14 c5 64 07 1b 	movzbl -0x3fe4f89c(,%eax,8),%edx
c010225a:	c0 
c010225b:	80 e2 e0             	and    $0xe0,%dl
c010225e:	88 14 c5 64 07 1b c0 	mov    %dl,-0x3fe4f89c(,%eax,8)
c0102265:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102268:	0f b6 14 c5 64 07 1b 	movzbl -0x3fe4f89c(,%eax,8),%edx
c010226f:	c0 
c0102270:	80 e2 1f             	and    $0x1f,%dl
c0102273:	88 14 c5 64 07 1b c0 	mov    %dl,-0x3fe4f89c(,%eax,8)
c010227a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010227d:	0f b6 14 c5 65 07 1b 	movzbl -0x3fe4f89b(,%eax,8),%edx
c0102284:	c0 
c0102285:	80 e2 f0             	and    $0xf0,%dl
c0102288:	80 ca 0e             	or     $0xe,%dl
c010228b:	88 14 c5 65 07 1b c0 	mov    %dl,-0x3fe4f89b(,%eax,8)
c0102292:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102295:	0f b6 14 c5 65 07 1b 	movzbl -0x3fe4f89b(,%eax,8),%edx
c010229c:	c0 
c010229d:	80 e2 ef             	and    $0xef,%dl
c01022a0:	88 14 c5 65 07 1b c0 	mov    %dl,-0x3fe4f89b(,%eax,8)
c01022a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022aa:	0f b6 14 c5 65 07 1b 	movzbl -0x3fe4f89b(,%eax,8),%edx
c01022b1:	c0 
c01022b2:	80 e2 9f             	and    $0x9f,%dl
c01022b5:	88 14 c5 65 07 1b c0 	mov    %dl,-0x3fe4f89b(,%eax,8)
c01022bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022bf:	0f b6 14 c5 65 07 1b 	movzbl -0x3fe4f89b(,%eax,8),%edx
c01022c6:	c0 
c01022c7:	80 ca 80             	or     $0x80,%dl
c01022ca:	88 14 c5 65 07 1b c0 	mov    %dl,-0x3fe4f89b(,%eax,8)
c01022d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022d4:	8b 04 85 e0 c5 12 c0 	mov    -0x3fed3a20(,%eax,4),%eax
c01022db:	c1 e8 10             	shr    $0x10,%eax
c01022de:	0f b7 d0             	movzwl %ax,%edx
c01022e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022e4:	66 89 14 c5 66 07 1b 	mov    %dx,-0x3fe4f89a(,%eax,8)
c01022eb:	c0 
     /* LAB5 YOUR CODE */ 
     //you should update your lab1 code (just add ONE or TWO lines of code), let user app to use syscall to get the service of ucore
     //so you should setup the syscall interrupt gate in here
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c01022ec:	ff 45 fc             	incl   -0x4(%ebp)
c01022ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01022f2:	3d ff 00 00 00       	cmp    $0xff,%eax
c01022f7:	0f 86 2e ff ff ff    	jbe    c010222b <idt_init+0x12>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
    }
    SETGATE(idt[T_SYSCALL], 1, GD_KTEXT, __vectors[T_SYSCALL], DPL_USER);
c01022fd:	a1 e0 c7 12 c0       	mov    0xc012c7e0,%eax
c0102302:	0f b7 c0             	movzwl %ax,%eax
c0102305:	66 a3 60 0b 1b c0    	mov    %ax,0xc01b0b60
c010230b:	66 c7 05 62 0b 1b c0 	movw   $0x8,0xc01b0b62
c0102312:	08 00 
c0102314:	0f b6 05 64 0b 1b c0 	movzbl 0xc01b0b64,%eax
c010231b:	24 e0                	and    $0xe0,%al
c010231d:	a2 64 0b 1b c0       	mov    %al,0xc01b0b64
c0102322:	0f b6 05 64 0b 1b c0 	movzbl 0xc01b0b64,%eax
c0102329:	24 1f                	and    $0x1f,%al
c010232b:	a2 64 0b 1b c0       	mov    %al,0xc01b0b64
c0102330:	0f b6 05 65 0b 1b c0 	movzbl 0xc01b0b65,%eax
c0102337:	0c 0f                	or     $0xf,%al
c0102339:	a2 65 0b 1b c0       	mov    %al,0xc01b0b65
c010233e:	0f b6 05 65 0b 1b c0 	movzbl 0xc01b0b65,%eax
c0102345:	24 ef                	and    $0xef,%al
c0102347:	a2 65 0b 1b c0       	mov    %al,0xc01b0b65
c010234c:	0f b6 05 65 0b 1b c0 	movzbl 0xc01b0b65,%eax
c0102353:	0c 60                	or     $0x60,%al
c0102355:	a2 65 0b 1b c0       	mov    %al,0xc01b0b65
c010235a:	0f b6 05 65 0b 1b c0 	movzbl 0xc01b0b65,%eax
c0102361:	0c 80                	or     $0x80,%al
c0102363:	a2 65 0b 1b c0       	mov    %al,0xc01b0b65
c0102368:	a1 e0 c7 12 c0       	mov    0xc012c7e0,%eax
c010236d:	c1 e8 10             	shr    $0x10,%eax
c0102370:	0f b7 c0             	movzwl %ax,%eax
c0102373:	66 a3 66 0b 1b c0    	mov    %ax,0xc01b0b66
c0102379:	c7 45 f8 60 c5 12 c0 	movl   $0xc012c560,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c0102380:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0102383:	0f 01 18             	lidtl  (%eax)
    lidt(&idt_pd);
}
c0102386:	90                   	nop
c0102387:	c9                   	leave  
c0102388:	c3                   	ret    

c0102389 <trapname>:

static const char *
trapname(int trapno) {
c0102389:	55                   	push   %ebp
c010238a:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c010238c:	8b 45 08             	mov    0x8(%ebp),%eax
c010238f:	83 f8 13             	cmp    $0x13,%eax
c0102392:	77 0c                	ja     c01023a0 <trapname+0x17>
        return excnames[trapno];
c0102394:	8b 45 08             	mov    0x8(%ebp),%eax
c0102397:	8b 04 85 80 cb 10 c0 	mov    -0x3fef3480(,%eax,4),%eax
c010239e:	eb 18                	jmp    c01023b8 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c01023a0:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c01023a4:	7e 0d                	jle    c01023b3 <trapname+0x2a>
c01023a6:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c01023aa:	7f 07                	jg     c01023b3 <trapname+0x2a>
        return "Hardware Interrupt";
c01023ac:	b8 ea c6 10 c0       	mov    $0xc010c6ea,%eax
c01023b1:	eb 05                	jmp    c01023b8 <trapname+0x2f>
    }
    return "(unknown trap)";
c01023b3:	b8 fd c6 10 c0       	mov    $0xc010c6fd,%eax
}
c01023b8:	5d                   	pop    %ebp
c01023b9:	c3                   	ret    

c01023ba <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c01023ba:	55                   	push   %ebp
c01023bb:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c01023bd:	8b 45 08             	mov    0x8(%ebp),%eax
c01023c0:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01023c4:	83 f8 08             	cmp    $0x8,%eax
c01023c7:	0f 94 c0             	sete   %al
c01023ca:	0f b6 c0             	movzbl %al,%eax
}
c01023cd:	5d                   	pop    %ebp
c01023ce:	c3                   	ret    

c01023cf <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c01023cf:	55                   	push   %ebp
c01023d0:	89 e5                	mov    %esp,%ebp
c01023d2:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c01023d5:	8b 45 08             	mov    0x8(%ebp),%eax
c01023d8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023dc:	c7 04 24 3e c7 10 c0 	movl   $0xc010c73e,(%esp)
c01023e3:	e8 c6 de ff ff       	call   c01002ae <cprintf>
    print_regs(&tf->tf_regs);
c01023e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01023eb:	89 04 24             	mov    %eax,(%esp)
c01023ee:	e8 91 01 00 00       	call   c0102584 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c01023f3:	8b 45 08             	mov    0x8(%ebp),%eax
c01023f6:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c01023fa:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023fe:	c7 04 24 4f c7 10 c0 	movl   $0xc010c74f,(%esp)
c0102405:	e8 a4 de ff ff       	call   c01002ae <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c010240a:	8b 45 08             	mov    0x8(%ebp),%eax
c010240d:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0102411:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102415:	c7 04 24 62 c7 10 c0 	movl   $0xc010c762,(%esp)
c010241c:	e8 8d de ff ff       	call   c01002ae <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0102421:	8b 45 08             	mov    0x8(%ebp),%eax
c0102424:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0102428:	89 44 24 04          	mov    %eax,0x4(%esp)
c010242c:	c7 04 24 75 c7 10 c0 	movl   $0xc010c775,(%esp)
c0102433:	e8 76 de ff ff       	call   c01002ae <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0102438:	8b 45 08             	mov    0x8(%ebp),%eax
c010243b:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c010243f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102443:	c7 04 24 88 c7 10 c0 	movl   $0xc010c788,(%esp)
c010244a:	e8 5f de ff ff       	call   c01002ae <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c010244f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102452:	8b 40 30             	mov    0x30(%eax),%eax
c0102455:	89 04 24             	mov    %eax,(%esp)
c0102458:	e8 2c ff ff ff       	call   c0102389 <trapname>
c010245d:	89 c2                	mov    %eax,%edx
c010245f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102462:	8b 40 30             	mov    0x30(%eax),%eax
c0102465:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102469:	89 44 24 04          	mov    %eax,0x4(%esp)
c010246d:	c7 04 24 9b c7 10 c0 	movl   $0xc010c79b,(%esp)
c0102474:	e8 35 de ff ff       	call   c01002ae <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0102479:	8b 45 08             	mov    0x8(%ebp),%eax
c010247c:	8b 40 34             	mov    0x34(%eax),%eax
c010247f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102483:	c7 04 24 ad c7 10 c0 	movl   $0xc010c7ad,(%esp)
c010248a:	e8 1f de ff ff       	call   c01002ae <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c010248f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102492:	8b 40 38             	mov    0x38(%eax),%eax
c0102495:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102499:	c7 04 24 bc c7 10 c0 	movl   $0xc010c7bc,(%esp)
c01024a0:	e8 09 de ff ff       	call   c01002ae <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c01024a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01024a8:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01024ac:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024b0:	c7 04 24 cb c7 10 c0 	movl   $0xc010c7cb,(%esp)
c01024b7:	e8 f2 dd ff ff       	call   c01002ae <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c01024bc:	8b 45 08             	mov    0x8(%ebp),%eax
c01024bf:	8b 40 40             	mov    0x40(%eax),%eax
c01024c2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024c6:	c7 04 24 de c7 10 c0 	movl   $0xc010c7de,(%esp)
c01024cd:	e8 dc dd ff ff       	call   c01002ae <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c01024d2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01024d9:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c01024e0:	eb 3d                	jmp    c010251f <print_trapframe+0x150>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c01024e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01024e5:	8b 50 40             	mov    0x40(%eax),%edx
c01024e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01024eb:	21 d0                	and    %edx,%eax
c01024ed:	85 c0                	test   %eax,%eax
c01024ef:	74 28                	je     c0102519 <print_trapframe+0x14a>
c01024f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01024f4:	8b 04 85 80 c5 12 c0 	mov    -0x3fed3a80(,%eax,4),%eax
c01024fb:	85 c0                	test   %eax,%eax
c01024fd:	74 1a                	je     c0102519 <print_trapframe+0x14a>
            cprintf("%s,", IA32flags[i]);
c01024ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102502:	8b 04 85 80 c5 12 c0 	mov    -0x3fed3a80(,%eax,4),%eax
c0102509:	89 44 24 04          	mov    %eax,0x4(%esp)
c010250d:	c7 04 24 ed c7 10 c0 	movl   $0xc010c7ed,(%esp)
c0102514:	e8 95 dd ff ff       	call   c01002ae <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0102519:	ff 45 f4             	incl   -0xc(%ebp)
c010251c:	d1 65 f0             	shll   -0x10(%ebp)
c010251f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102522:	83 f8 17             	cmp    $0x17,%eax
c0102525:	76 bb                	jbe    c01024e2 <print_trapframe+0x113>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0102527:	8b 45 08             	mov    0x8(%ebp),%eax
c010252a:	8b 40 40             	mov    0x40(%eax),%eax
c010252d:	25 00 30 00 00       	and    $0x3000,%eax
c0102532:	c1 e8 0c             	shr    $0xc,%eax
c0102535:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102539:	c7 04 24 f1 c7 10 c0 	movl   $0xc010c7f1,(%esp)
c0102540:	e8 69 dd ff ff       	call   c01002ae <cprintf>

    if (!trap_in_kernel(tf)) {
c0102545:	8b 45 08             	mov    0x8(%ebp),%eax
c0102548:	89 04 24             	mov    %eax,(%esp)
c010254b:	e8 6a fe ff ff       	call   c01023ba <trap_in_kernel>
c0102550:	85 c0                	test   %eax,%eax
c0102552:	75 2d                	jne    c0102581 <print_trapframe+0x1b2>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0102554:	8b 45 08             	mov    0x8(%ebp),%eax
c0102557:	8b 40 44             	mov    0x44(%eax),%eax
c010255a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010255e:	c7 04 24 fa c7 10 c0 	movl   $0xc010c7fa,(%esp)
c0102565:	e8 44 dd ff ff       	call   c01002ae <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c010256a:	8b 45 08             	mov    0x8(%ebp),%eax
c010256d:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0102571:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102575:	c7 04 24 09 c8 10 c0 	movl   $0xc010c809,(%esp)
c010257c:	e8 2d dd ff ff       	call   c01002ae <cprintf>
    }
}
c0102581:	90                   	nop
c0102582:	c9                   	leave  
c0102583:	c3                   	ret    

c0102584 <print_regs>:

void
print_regs(struct pushregs *regs) {
c0102584:	55                   	push   %ebp
c0102585:	89 e5                	mov    %esp,%ebp
c0102587:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c010258a:	8b 45 08             	mov    0x8(%ebp),%eax
c010258d:	8b 00                	mov    (%eax),%eax
c010258f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102593:	c7 04 24 1c c8 10 c0 	movl   $0xc010c81c,(%esp)
c010259a:	e8 0f dd ff ff       	call   c01002ae <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c010259f:	8b 45 08             	mov    0x8(%ebp),%eax
c01025a2:	8b 40 04             	mov    0x4(%eax),%eax
c01025a5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025a9:	c7 04 24 2b c8 10 c0 	movl   $0xc010c82b,(%esp)
c01025b0:	e8 f9 dc ff ff       	call   c01002ae <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c01025b5:	8b 45 08             	mov    0x8(%ebp),%eax
c01025b8:	8b 40 08             	mov    0x8(%eax),%eax
c01025bb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025bf:	c7 04 24 3a c8 10 c0 	movl   $0xc010c83a,(%esp)
c01025c6:	e8 e3 dc ff ff       	call   c01002ae <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c01025cb:	8b 45 08             	mov    0x8(%ebp),%eax
c01025ce:	8b 40 0c             	mov    0xc(%eax),%eax
c01025d1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025d5:	c7 04 24 49 c8 10 c0 	movl   $0xc010c849,(%esp)
c01025dc:	e8 cd dc ff ff       	call   c01002ae <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c01025e1:	8b 45 08             	mov    0x8(%ebp),%eax
c01025e4:	8b 40 10             	mov    0x10(%eax),%eax
c01025e7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01025eb:	c7 04 24 58 c8 10 c0 	movl   $0xc010c858,(%esp)
c01025f2:	e8 b7 dc ff ff       	call   c01002ae <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c01025f7:	8b 45 08             	mov    0x8(%ebp),%eax
c01025fa:	8b 40 14             	mov    0x14(%eax),%eax
c01025fd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102601:	c7 04 24 67 c8 10 c0 	movl   $0xc010c867,(%esp)
c0102608:	e8 a1 dc ff ff       	call   c01002ae <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c010260d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102610:	8b 40 18             	mov    0x18(%eax),%eax
c0102613:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102617:	c7 04 24 76 c8 10 c0 	movl   $0xc010c876,(%esp)
c010261e:	e8 8b dc ff ff       	call   c01002ae <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0102623:	8b 45 08             	mov    0x8(%ebp),%eax
c0102626:	8b 40 1c             	mov    0x1c(%eax),%eax
c0102629:	89 44 24 04          	mov    %eax,0x4(%esp)
c010262d:	c7 04 24 85 c8 10 c0 	movl   $0xc010c885,(%esp)
c0102634:	e8 75 dc ff ff       	call   c01002ae <cprintf>
}
c0102639:	90                   	nop
c010263a:	c9                   	leave  
c010263b:	c3                   	ret    

c010263c <print_pgfault>:

static inline void
print_pgfault(struct trapframe *tf) {
c010263c:	55                   	push   %ebp
c010263d:	89 e5                	mov    %esp,%ebp
c010263f:	53                   	push   %ebx
c0102640:	83 ec 34             	sub    $0x34,%esp
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
c0102643:	8b 45 08             	mov    0x8(%ebp),%eax
c0102646:	8b 40 34             	mov    0x34(%eax),%eax
c0102649:	83 e0 01             	and    $0x1,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c010264c:	85 c0                	test   %eax,%eax
c010264e:	74 07                	je     c0102657 <print_pgfault+0x1b>
c0102650:	bb 94 c8 10 c0       	mov    $0xc010c894,%ebx
c0102655:	eb 05                	jmp    c010265c <print_pgfault+0x20>
c0102657:	bb a5 c8 10 c0       	mov    $0xc010c8a5,%ebx
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
c010265c:	8b 45 08             	mov    0x8(%ebp),%eax
c010265f:	8b 40 34             	mov    0x34(%eax),%eax
c0102662:	83 e0 02             	and    $0x2,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0102665:	85 c0                	test   %eax,%eax
c0102667:	74 07                	je     c0102670 <print_pgfault+0x34>
c0102669:	b9 57 00 00 00       	mov    $0x57,%ecx
c010266e:	eb 05                	jmp    c0102675 <print_pgfault+0x39>
c0102670:	b9 52 00 00 00       	mov    $0x52,%ecx
            (tf->tf_err & 4) ? 'U' : 'K',
c0102675:	8b 45 08             	mov    0x8(%ebp),%eax
c0102678:	8b 40 34             	mov    0x34(%eax),%eax
c010267b:	83 e0 04             	and    $0x4,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c010267e:	85 c0                	test   %eax,%eax
c0102680:	74 07                	je     c0102689 <print_pgfault+0x4d>
c0102682:	ba 55 00 00 00       	mov    $0x55,%edx
c0102687:	eb 05                	jmp    c010268e <print_pgfault+0x52>
c0102689:	ba 4b 00 00 00       	mov    $0x4b,%edx
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c010268e:	0f 20 d0             	mov    %cr2,%eax
c0102691:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c0102694:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102697:	89 5c 24 10          	mov    %ebx,0x10(%esp)
c010269b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c010269f:	89 54 24 08          	mov    %edx,0x8(%esp)
c01026a3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01026a7:	c7 04 24 b4 c8 10 c0 	movl   $0xc010c8b4,(%esp)
c01026ae:	e8 fb db ff ff       	call   c01002ae <cprintf>
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
}
c01026b3:	90                   	nop
c01026b4:	83 c4 34             	add    $0x34,%esp
c01026b7:	5b                   	pop    %ebx
c01026b8:	5d                   	pop    %ebp
c01026b9:	c3                   	ret    

c01026ba <pgfault_handler>:

static int
pgfault_handler(struct trapframe *tf) {
c01026ba:	55                   	push   %ebp
c01026bb:	89 e5                	mov    %esp,%ebp
c01026bd:	83 ec 28             	sub    $0x28,%esp
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
c01026c0:	a1 7c 30 1b c0       	mov    0xc01b307c,%eax
c01026c5:	85 c0                	test   %eax,%eax
c01026c7:	74 0b                	je     c01026d4 <pgfault_handler+0x1a>
            print_pgfault(tf);
c01026c9:	8b 45 08             	mov    0x8(%ebp),%eax
c01026cc:	89 04 24             	mov    %eax,(%esp)
c01026cf:	e8 68 ff ff ff       	call   c010263c <print_pgfault>
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
c01026d4:	a1 7c 30 1b c0       	mov    0xc01b307c,%eax
c01026d9:	85 c0                	test   %eax,%eax
c01026db:	74 3d                	je     c010271a <pgfault_handler+0x60>
        assert(current == idleproc);
c01026dd:	8b 15 28 10 1b c0    	mov    0xc01b1028,%edx
c01026e3:	a1 20 10 1b c0       	mov    0xc01b1020,%eax
c01026e8:	39 c2                	cmp    %eax,%edx
c01026ea:	74 24                	je     c0102710 <pgfault_handler+0x56>
c01026ec:	c7 44 24 0c d7 c8 10 	movl   $0xc010c8d7,0xc(%esp)
c01026f3:	c0 
c01026f4:	c7 44 24 08 eb c8 10 	movl   $0xc010c8eb,0x8(%esp)
c01026fb:	c0 
c01026fc:	c7 44 24 04 b0 00 00 	movl   $0xb0,0x4(%esp)
c0102703:	00 
c0102704:	c7 04 24 00 c9 10 c0 	movl   $0xc010c900,(%esp)
c010270b:	e8 f5 dc ff ff       	call   c0100405 <__panic>
        mm = check_mm_struct;
c0102710:	a1 7c 30 1b c0       	mov    0xc01b307c,%eax
c0102715:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102718:	eb 46                	jmp    c0102760 <pgfault_handler+0xa6>
    }
    else {
        if (current == NULL) {
c010271a:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010271f:	85 c0                	test   %eax,%eax
c0102721:	75 32                	jne    c0102755 <pgfault_handler+0x9b>
            print_trapframe(tf);
c0102723:	8b 45 08             	mov    0x8(%ebp),%eax
c0102726:	89 04 24             	mov    %eax,(%esp)
c0102729:	e8 a1 fc ff ff       	call   c01023cf <print_trapframe>
            print_pgfault(tf);
c010272e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102731:	89 04 24             	mov    %eax,(%esp)
c0102734:	e8 03 ff ff ff       	call   c010263c <print_pgfault>
            panic("unhandled page fault.\n");
c0102739:	c7 44 24 08 11 c9 10 	movl   $0xc010c911,0x8(%esp)
c0102740:	c0 
c0102741:	c7 44 24 04 b7 00 00 	movl   $0xb7,0x4(%esp)
c0102748:	00 
c0102749:	c7 04 24 00 c9 10 c0 	movl   $0xc010c900,(%esp)
c0102750:	e8 b0 dc ff ff       	call   c0100405 <__panic>
        }
        mm = current->mm;
c0102755:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010275a:	8b 40 18             	mov    0x18(%eax),%eax
c010275d:	89 45 f4             	mov    %eax,-0xc(%ebp)
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c0102760:	0f 20 d0             	mov    %cr2,%eax
c0102763:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr2;
c0102766:	8b 55 f0             	mov    -0x10(%ebp),%edx
    }
    return do_pgfault(mm, tf->tf_err, rcr2());
c0102769:	8b 45 08             	mov    0x8(%ebp),%eax
c010276c:	8b 40 34             	mov    0x34(%eax),%eax
c010276f:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102773:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102777:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010277a:	89 04 24             	mov    %eax,(%esp)
c010277d:	e8 7c 1c 00 00       	call   c01043fe <do_pgfault>
}
c0102782:	c9                   	leave  
c0102783:	c3                   	ret    

c0102784 <trap_dispatch>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

static void
trap_dispatch(struct trapframe *tf) {
c0102784:	55                   	push   %ebp
c0102785:	89 e5                	mov    %esp,%ebp
c0102787:	83 ec 28             	sub    $0x28,%esp
    char c;

    int ret=0;
c010278a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    switch (tf->tf_trapno) {
c0102791:	8b 45 08             	mov    0x8(%ebp),%eax
c0102794:	8b 40 30             	mov    0x30(%eax),%eax
c0102797:	83 f8 2f             	cmp    $0x2f,%eax
c010279a:	77 38                	ja     c01027d4 <trap_dispatch+0x50>
c010279c:	83 f8 2e             	cmp    $0x2e,%eax
c010279f:	0f 83 08 02 00 00    	jae    c01029ad <trap_dispatch+0x229>
c01027a5:	83 f8 20             	cmp    $0x20,%eax
c01027a8:	0f 84 02 01 00 00    	je     c01028b0 <trap_dispatch+0x12c>
c01027ae:	83 f8 20             	cmp    $0x20,%eax
c01027b1:	77 0a                	ja     c01027bd <trap_dispatch+0x39>
c01027b3:	83 f8 0e             	cmp    $0xe,%eax
c01027b6:	74 3e                	je     c01027f6 <trap_dispatch+0x72>
c01027b8:	e9 a8 01 00 00       	jmp    c0102965 <trap_dispatch+0x1e1>
c01027bd:	83 f8 21             	cmp    $0x21,%eax
c01027c0:	0f 84 5d 01 00 00    	je     c0102923 <trap_dispatch+0x19f>
c01027c6:	83 f8 24             	cmp    $0x24,%eax
c01027c9:	0f 84 2b 01 00 00    	je     c01028fa <trap_dispatch+0x176>
c01027cf:	e9 91 01 00 00       	jmp    c0102965 <trap_dispatch+0x1e1>
c01027d4:	83 f8 78             	cmp    $0x78,%eax
c01027d7:	0f 82 88 01 00 00    	jb     c0102965 <trap_dispatch+0x1e1>
c01027dd:	83 f8 79             	cmp    $0x79,%eax
c01027e0:	0f 86 63 01 00 00    	jbe    c0102949 <trap_dispatch+0x1c5>
c01027e6:	3d 80 00 00 00       	cmp    $0x80,%eax
c01027eb:	0f 84 b5 00 00 00    	je     c01028a6 <trap_dispatch+0x122>
c01027f1:	e9 6f 01 00 00       	jmp    c0102965 <trap_dispatch+0x1e1>
    case T_PGFLT:  //page fault
        if ((ret = pgfault_handler(tf)) != 0) {
c01027f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01027f9:	89 04 24             	mov    %eax,(%esp)
c01027fc:	e8 b9 fe ff ff       	call   c01026ba <pgfault_handler>
c0102801:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102804:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102808:	0f 84 a2 01 00 00    	je     c01029b0 <trap_dispatch+0x22c>
            print_trapframe(tf);
c010280e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102811:	89 04 24             	mov    %eax,(%esp)
c0102814:	e8 b6 fb ff ff       	call   c01023cf <print_trapframe>
            if (current == NULL) {
c0102819:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010281e:	85 c0                	test   %eax,%eax
c0102820:	75 23                	jne    c0102845 <trap_dispatch+0xc1>
                panic("handle pgfault failed. ret=%d\n", ret);
c0102822:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102825:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102829:	c7 44 24 08 28 c9 10 	movl   $0xc010c928,0x8(%esp)
c0102830:	c0 
c0102831:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
c0102838:	00 
c0102839:	c7 04 24 00 c9 10 c0 	movl   $0xc010c900,(%esp)
c0102840:	e8 c0 db ff ff       	call   c0100405 <__panic>
            }
            else {
                if (trap_in_kernel(tf)) {
c0102845:	8b 45 08             	mov    0x8(%ebp),%eax
c0102848:	89 04 24             	mov    %eax,(%esp)
c010284b:	e8 6a fb ff ff       	call   c01023ba <trap_in_kernel>
c0102850:	85 c0                	test   %eax,%eax
c0102852:	74 23                	je     c0102877 <trap_dispatch+0xf3>
                    panic("handle pgfault failed in kernel mode. ret=%d\n", ret);
c0102854:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102857:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010285b:	c7 44 24 08 48 c9 10 	movl   $0xc010c948,0x8(%esp)
c0102862:	c0 
c0102863:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
c010286a:	00 
c010286b:	c7 04 24 00 c9 10 c0 	movl   $0xc010c900,(%esp)
c0102872:	e8 8e db ff ff       	call   c0100405 <__panic>
                }
                cprintf("killed by kernel.\n");
c0102877:	c7 04 24 76 c9 10 c0 	movl   $0xc010c976,(%esp)
c010287e:	e8 2b da ff ff       	call   c01002ae <cprintf>
                panic("handle user mode pgfault failed. ret=%d\n", ret); 
c0102883:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102886:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010288a:	c7 44 24 08 8c c9 10 	movl   $0xc010c98c,0x8(%esp)
c0102891:	c0 
c0102892:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c0102899:	00 
c010289a:	c7 04 24 00 c9 10 c0 	movl   $0xc010c900,(%esp)
c01028a1:	e8 5f db ff ff       	call   c0100405 <__panic>
                do_exit(-E_KILLED);
            }
        }
        break;
    case T_SYSCALL:
        syscall();
c01028a6:	e8 f3 8c 00 00       	call   c010b59e <syscall>
        break;
c01028ab:	e9 01 01 00 00       	jmp    c01029b1 <trap_dispatch+0x22d>
         */
        /* LAB5 YOUR CODE */
        /* you should upate you lab1 code (just add ONE or TWO lines of code):
         *    Every TICK_NUM cycle, you should set current process's current->need_resched = 1
         */
        ticks ++;
c01028b0:	a1 78 30 1b c0       	mov    0xc01b3078,%eax
c01028b5:	40                   	inc    %eax
c01028b6:	a3 78 30 1b c0       	mov    %eax,0xc01b3078
        assert(current != NULL);
c01028bb:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c01028c0:	85 c0                	test   %eax,%eax
c01028c2:	75 24                	jne    c01028e8 <trap_dispatch+0x164>
c01028c4:	c7 44 24 0c b5 c9 10 	movl   $0xc010c9b5,0xc(%esp)
c01028cb:	c0 
c01028cc:	c7 44 24 08 eb c8 10 	movl   $0xc010c8eb,0x8(%esp)
c01028d3:	c0 
c01028d4:	c7 44 24 04 eb 00 00 	movl   $0xeb,0x4(%esp)
c01028db:	00 
c01028dc:	c7 04 24 00 c9 10 c0 	movl   $0xc010c900,(%esp)
c01028e3:	e8 1d db ff ff       	call   c0100405 <__panic>
        sched_class_proc_tick(current);
c01028e8:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c01028ed:	89 04 24             	mov    %eax,(%esp)
c01028f0:	e8 5c 87 00 00       	call   c010b051 <sched_class_proc_tick>
        break;
c01028f5:	e9 b7 00 00 00       	jmp    c01029b1 <trap_dispatch+0x22d>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c01028fa:	e8 c2 f6 ff ff       	call   c0101fc1 <cons_getc>
c01028ff:	88 45 f3             	mov    %al,-0xd(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0102902:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c0102906:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c010290a:	89 54 24 08          	mov    %edx,0x8(%esp)
c010290e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102912:	c7 04 24 c5 c9 10 c0 	movl   $0xc010c9c5,(%esp)
c0102919:	e8 90 d9 ff ff       	call   c01002ae <cprintf>
        break;
c010291e:	e9 8e 00 00 00       	jmp    c01029b1 <trap_dispatch+0x22d>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0102923:	e8 99 f6 ff ff       	call   c0101fc1 <cons_getc>
c0102928:	88 45 f3             	mov    %al,-0xd(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c010292b:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c010292f:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c0102933:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102937:	89 44 24 04          	mov    %eax,0x4(%esp)
c010293b:	c7 04 24 d7 c9 10 c0 	movl   $0xc010c9d7,(%esp)
c0102942:	e8 67 d9 ff ff       	call   c01002ae <cprintf>
        break;
c0102947:	eb 68                	jmp    c01029b1 <trap_dispatch+0x22d>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c0102949:	c7 44 24 08 e6 c9 10 	movl   $0xc010c9e6,0x8(%esp)
c0102950:	c0 
c0102951:	c7 44 24 04 f9 00 00 	movl   $0xf9,0x4(%esp)
c0102958:	00 
c0102959:	c7 04 24 00 c9 10 c0 	movl   $0xc010c900,(%esp)
c0102960:	e8 a0 da ff ff       	call   c0100405 <__panic>
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        print_trapframe(tf);
c0102965:	8b 45 08             	mov    0x8(%ebp),%eax
c0102968:	89 04 24             	mov    %eax,(%esp)
c010296b:	e8 5f fa ff ff       	call   c01023cf <print_trapframe>
        if (current != NULL) {
c0102970:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c0102975:	85 c0                	test   %eax,%eax
c0102977:	74 18                	je     c0102991 <trap_dispatch+0x20d>
            cprintf("unhandled trap.\n");
c0102979:	c7 04 24 f6 c9 10 c0 	movl   $0xc010c9f6,(%esp)
c0102980:	e8 29 d9 ff ff       	call   c01002ae <cprintf>
            do_exit(-E_KILLED);
c0102985:	c7 04 24 f7 ff ff ff 	movl   $0xfffffff7,(%esp)
c010298c:	e8 8c 76 00 00       	call   c010a01d <do_exit>
        }
        // in kernel, it must be a mistake
        panic("unexpected trap in kernel.\n");
c0102991:	c7 44 24 08 07 ca 10 	movl   $0xc010ca07,0x8(%esp)
c0102998:	c0 
c0102999:	c7 44 24 04 06 01 00 	movl   $0x106,0x4(%esp)
c01029a0:	00 
c01029a1:	c7 04 24 00 c9 10 c0 	movl   $0xc010c900,(%esp)
c01029a8:	e8 58 da ff ff       	call   c0100405 <__panic>
        panic("T_SWITCH_** ??\n");
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
c01029ad:	90                   	nop
c01029ae:	eb 01                	jmp    c01029b1 <trap_dispatch+0x22d>
                cprintf("killed by kernel.\n");
                panic("handle user mode pgfault failed. ret=%d\n", ret); 
                do_exit(-E_KILLED);
            }
        }
        break;
c01029b0:	90                   	nop
        }
        // in kernel, it must be a mistake
        panic("unexpected trap in kernel.\n");

    }
}
c01029b1:	90                   	nop
c01029b2:	c9                   	leave  
c01029b3:	c3                   	ret    

c01029b4 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c01029b4:	55                   	push   %ebp
c01029b5:	89 e5                	mov    %esp,%ebp
c01029b7:	83 ec 28             	sub    $0x28,%esp
    // dispatch based on what type of trap occurred
    // used for previous projects
    if (current == NULL) {
c01029ba:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c01029bf:	85 c0                	test   %eax,%eax
c01029c1:	75 0d                	jne    c01029d0 <trap+0x1c>
        trap_dispatch(tf);
c01029c3:	8b 45 08             	mov    0x8(%ebp),%eax
c01029c6:	89 04 24             	mov    %eax,(%esp)
c01029c9:	e8 b6 fd ff ff       	call   c0102784 <trap_dispatch>
            if (current->need_resched) {
                schedule();
            }
        }
    }
}
c01029ce:	eb 6c                	jmp    c0102a3c <trap+0x88>
    if (current == NULL) {
        trap_dispatch(tf);
    }
    else {
        // keep a trapframe chain in stack
        struct trapframe *otf = current->tf;
c01029d0:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c01029d5:	8b 40 3c             	mov    0x3c(%eax),%eax
c01029d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
        current->tf = tf;
c01029db:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c01029e0:	8b 55 08             	mov    0x8(%ebp),%edx
c01029e3:	89 50 3c             	mov    %edx,0x3c(%eax)
    
        bool in_kernel = trap_in_kernel(tf);
c01029e6:	8b 45 08             	mov    0x8(%ebp),%eax
c01029e9:	89 04 24             	mov    %eax,(%esp)
c01029ec:	e8 c9 f9 ff ff       	call   c01023ba <trap_in_kernel>
c01029f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    
        trap_dispatch(tf);
c01029f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01029f7:	89 04 24             	mov    %eax,(%esp)
c01029fa:	e8 85 fd ff ff       	call   c0102784 <trap_dispatch>
    
        current->tf = otf;
c01029ff:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c0102a04:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102a07:	89 50 3c             	mov    %edx,0x3c(%eax)
        if (!in_kernel) {
c0102a0a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0102a0e:	75 2c                	jne    c0102a3c <trap+0x88>
            if (current->flags & PF_EXITING) {
c0102a10:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c0102a15:	8b 40 44             	mov    0x44(%eax),%eax
c0102a18:	83 e0 01             	and    $0x1,%eax
c0102a1b:	85 c0                	test   %eax,%eax
c0102a1d:	74 0c                	je     c0102a2b <trap+0x77>
                do_exit(-E_KILLED);
c0102a1f:	c7 04 24 f7 ff ff ff 	movl   $0xfffffff7,(%esp)
c0102a26:	e8 f2 75 00 00       	call   c010a01d <do_exit>
            }
            if (current->need_resched) {
c0102a2b:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c0102a30:	8b 40 10             	mov    0x10(%eax),%eax
c0102a33:	85 c0                	test   %eax,%eax
c0102a35:	74 05                	je     c0102a3c <trap+0x88>
                schedule();
c0102a37:	e8 56 87 00 00       	call   c010b192 <schedule>
            }
        }
    }
}
c0102a3c:	90                   	nop
c0102a3d:	c9                   	leave  
c0102a3e:	c3                   	ret    

c0102a3f <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0102a3f:	6a 00                	push   $0x0
  pushl $0
c0102a41:	6a 00                	push   $0x0
  jmp __alltraps
c0102a43:	e9 69 0a 00 00       	jmp    c01034b1 <__alltraps>

c0102a48 <vector1>:
.globl vector1
vector1:
  pushl $0
c0102a48:	6a 00                	push   $0x0
  pushl $1
c0102a4a:	6a 01                	push   $0x1
  jmp __alltraps
c0102a4c:	e9 60 0a 00 00       	jmp    c01034b1 <__alltraps>

c0102a51 <vector2>:
.globl vector2
vector2:
  pushl $0
c0102a51:	6a 00                	push   $0x0
  pushl $2
c0102a53:	6a 02                	push   $0x2
  jmp __alltraps
c0102a55:	e9 57 0a 00 00       	jmp    c01034b1 <__alltraps>

c0102a5a <vector3>:
.globl vector3
vector3:
  pushl $0
c0102a5a:	6a 00                	push   $0x0
  pushl $3
c0102a5c:	6a 03                	push   $0x3
  jmp __alltraps
c0102a5e:	e9 4e 0a 00 00       	jmp    c01034b1 <__alltraps>

c0102a63 <vector4>:
.globl vector4
vector4:
  pushl $0
c0102a63:	6a 00                	push   $0x0
  pushl $4
c0102a65:	6a 04                	push   $0x4
  jmp __alltraps
c0102a67:	e9 45 0a 00 00       	jmp    c01034b1 <__alltraps>

c0102a6c <vector5>:
.globl vector5
vector5:
  pushl $0
c0102a6c:	6a 00                	push   $0x0
  pushl $5
c0102a6e:	6a 05                	push   $0x5
  jmp __alltraps
c0102a70:	e9 3c 0a 00 00       	jmp    c01034b1 <__alltraps>

c0102a75 <vector6>:
.globl vector6
vector6:
  pushl $0
c0102a75:	6a 00                	push   $0x0
  pushl $6
c0102a77:	6a 06                	push   $0x6
  jmp __alltraps
c0102a79:	e9 33 0a 00 00       	jmp    c01034b1 <__alltraps>

c0102a7e <vector7>:
.globl vector7
vector7:
  pushl $0
c0102a7e:	6a 00                	push   $0x0
  pushl $7
c0102a80:	6a 07                	push   $0x7
  jmp __alltraps
c0102a82:	e9 2a 0a 00 00       	jmp    c01034b1 <__alltraps>

c0102a87 <vector8>:
.globl vector8
vector8:
  pushl $8
c0102a87:	6a 08                	push   $0x8
  jmp __alltraps
c0102a89:	e9 23 0a 00 00       	jmp    c01034b1 <__alltraps>

c0102a8e <vector9>:
.globl vector9
vector9:
  pushl $0
c0102a8e:	6a 00                	push   $0x0
  pushl $9
c0102a90:	6a 09                	push   $0x9
  jmp __alltraps
c0102a92:	e9 1a 0a 00 00       	jmp    c01034b1 <__alltraps>

c0102a97 <vector10>:
.globl vector10
vector10:
  pushl $10
c0102a97:	6a 0a                	push   $0xa
  jmp __alltraps
c0102a99:	e9 13 0a 00 00       	jmp    c01034b1 <__alltraps>

c0102a9e <vector11>:
.globl vector11
vector11:
  pushl $11
c0102a9e:	6a 0b                	push   $0xb
  jmp __alltraps
c0102aa0:	e9 0c 0a 00 00       	jmp    c01034b1 <__alltraps>

c0102aa5 <vector12>:
.globl vector12
vector12:
  pushl $12
c0102aa5:	6a 0c                	push   $0xc
  jmp __alltraps
c0102aa7:	e9 05 0a 00 00       	jmp    c01034b1 <__alltraps>

c0102aac <vector13>:
.globl vector13
vector13:
  pushl $13
c0102aac:	6a 0d                	push   $0xd
  jmp __alltraps
c0102aae:	e9 fe 09 00 00       	jmp    c01034b1 <__alltraps>

c0102ab3 <vector14>:
.globl vector14
vector14:
  pushl $14
c0102ab3:	6a 0e                	push   $0xe
  jmp __alltraps
c0102ab5:	e9 f7 09 00 00       	jmp    c01034b1 <__alltraps>

c0102aba <vector15>:
.globl vector15
vector15:
  pushl $0
c0102aba:	6a 00                	push   $0x0
  pushl $15
c0102abc:	6a 0f                	push   $0xf
  jmp __alltraps
c0102abe:	e9 ee 09 00 00       	jmp    c01034b1 <__alltraps>

c0102ac3 <vector16>:
.globl vector16
vector16:
  pushl $0
c0102ac3:	6a 00                	push   $0x0
  pushl $16
c0102ac5:	6a 10                	push   $0x10
  jmp __alltraps
c0102ac7:	e9 e5 09 00 00       	jmp    c01034b1 <__alltraps>

c0102acc <vector17>:
.globl vector17
vector17:
  pushl $17
c0102acc:	6a 11                	push   $0x11
  jmp __alltraps
c0102ace:	e9 de 09 00 00       	jmp    c01034b1 <__alltraps>

c0102ad3 <vector18>:
.globl vector18
vector18:
  pushl $0
c0102ad3:	6a 00                	push   $0x0
  pushl $18
c0102ad5:	6a 12                	push   $0x12
  jmp __alltraps
c0102ad7:	e9 d5 09 00 00       	jmp    c01034b1 <__alltraps>

c0102adc <vector19>:
.globl vector19
vector19:
  pushl $0
c0102adc:	6a 00                	push   $0x0
  pushl $19
c0102ade:	6a 13                	push   $0x13
  jmp __alltraps
c0102ae0:	e9 cc 09 00 00       	jmp    c01034b1 <__alltraps>

c0102ae5 <vector20>:
.globl vector20
vector20:
  pushl $0
c0102ae5:	6a 00                	push   $0x0
  pushl $20
c0102ae7:	6a 14                	push   $0x14
  jmp __alltraps
c0102ae9:	e9 c3 09 00 00       	jmp    c01034b1 <__alltraps>

c0102aee <vector21>:
.globl vector21
vector21:
  pushl $0
c0102aee:	6a 00                	push   $0x0
  pushl $21
c0102af0:	6a 15                	push   $0x15
  jmp __alltraps
c0102af2:	e9 ba 09 00 00       	jmp    c01034b1 <__alltraps>

c0102af7 <vector22>:
.globl vector22
vector22:
  pushl $0
c0102af7:	6a 00                	push   $0x0
  pushl $22
c0102af9:	6a 16                	push   $0x16
  jmp __alltraps
c0102afb:	e9 b1 09 00 00       	jmp    c01034b1 <__alltraps>

c0102b00 <vector23>:
.globl vector23
vector23:
  pushl $0
c0102b00:	6a 00                	push   $0x0
  pushl $23
c0102b02:	6a 17                	push   $0x17
  jmp __alltraps
c0102b04:	e9 a8 09 00 00       	jmp    c01034b1 <__alltraps>

c0102b09 <vector24>:
.globl vector24
vector24:
  pushl $0
c0102b09:	6a 00                	push   $0x0
  pushl $24
c0102b0b:	6a 18                	push   $0x18
  jmp __alltraps
c0102b0d:	e9 9f 09 00 00       	jmp    c01034b1 <__alltraps>

c0102b12 <vector25>:
.globl vector25
vector25:
  pushl $0
c0102b12:	6a 00                	push   $0x0
  pushl $25
c0102b14:	6a 19                	push   $0x19
  jmp __alltraps
c0102b16:	e9 96 09 00 00       	jmp    c01034b1 <__alltraps>

c0102b1b <vector26>:
.globl vector26
vector26:
  pushl $0
c0102b1b:	6a 00                	push   $0x0
  pushl $26
c0102b1d:	6a 1a                	push   $0x1a
  jmp __alltraps
c0102b1f:	e9 8d 09 00 00       	jmp    c01034b1 <__alltraps>

c0102b24 <vector27>:
.globl vector27
vector27:
  pushl $0
c0102b24:	6a 00                	push   $0x0
  pushl $27
c0102b26:	6a 1b                	push   $0x1b
  jmp __alltraps
c0102b28:	e9 84 09 00 00       	jmp    c01034b1 <__alltraps>

c0102b2d <vector28>:
.globl vector28
vector28:
  pushl $0
c0102b2d:	6a 00                	push   $0x0
  pushl $28
c0102b2f:	6a 1c                	push   $0x1c
  jmp __alltraps
c0102b31:	e9 7b 09 00 00       	jmp    c01034b1 <__alltraps>

c0102b36 <vector29>:
.globl vector29
vector29:
  pushl $0
c0102b36:	6a 00                	push   $0x0
  pushl $29
c0102b38:	6a 1d                	push   $0x1d
  jmp __alltraps
c0102b3a:	e9 72 09 00 00       	jmp    c01034b1 <__alltraps>

c0102b3f <vector30>:
.globl vector30
vector30:
  pushl $0
c0102b3f:	6a 00                	push   $0x0
  pushl $30
c0102b41:	6a 1e                	push   $0x1e
  jmp __alltraps
c0102b43:	e9 69 09 00 00       	jmp    c01034b1 <__alltraps>

c0102b48 <vector31>:
.globl vector31
vector31:
  pushl $0
c0102b48:	6a 00                	push   $0x0
  pushl $31
c0102b4a:	6a 1f                	push   $0x1f
  jmp __alltraps
c0102b4c:	e9 60 09 00 00       	jmp    c01034b1 <__alltraps>

c0102b51 <vector32>:
.globl vector32
vector32:
  pushl $0
c0102b51:	6a 00                	push   $0x0
  pushl $32
c0102b53:	6a 20                	push   $0x20
  jmp __alltraps
c0102b55:	e9 57 09 00 00       	jmp    c01034b1 <__alltraps>

c0102b5a <vector33>:
.globl vector33
vector33:
  pushl $0
c0102b5a:	6a 00                	push   $0x0
  pushl $33
c0102b5c:	6a 21                	push   $0x21
  jmp __alltraps
c0102b5e:	e9 4e 09 00 00       	jmp    c01034b1 <__alltraps>

c0102b63 <vector34>:
.globl vector34
vector34:
  pushl $0
c0102b63:	6a 00                	push   $0x0
  pushl $34
c0102b65:	6a 22                	push   $0x22
  jmp __alltraps
c0102b67:	e9 45 09 00 00       	jmp    c01034b1 <__alltraps>

c0102b6c <vector35>:
.globl vector35
vector35:
  pushl $0
c0102b6c:	6a 00                	push   $0x0
  pushl $35
c0102b6e:	6a 23                	push   $0x23
  jmp __alltraps
c0102b70:	e9 3c 09 00 00       	jmp    c01034b1 <__alltraps>

c0102b75 <vector36>:
.globl vector36
vector36:
  pushl $0
c0102b75:	6a 00                	push   $0x0
  pushl $36
c0102b77:	6a 24                	push   $0x24
  jmp __alltraps
c0102b79:	e9 33 09 00 00       	jmp    c01034b1 <__alltraps>

c0102b7e <vector37>:
.globl vector37
vector37:
  pushl $0
c0102b7e:	6a 00                	push   $0x0
  pushl $37
c0102b80:	6a 25                	push   $0x25
  jmp __alltraps
c0102b82:	e9 2a 09 00 00       	jmp    c01034b1 <__alltraps>

c0102b87 <vector38>:
.globl vector38
vector38:
  pushl $0
c0102b87:	6a 00                	push   $0x0
  pushl $38
c0102b89:	6a 26                	push   $0x26
  jmp __alltraps
c0102b8b:	e9 21 09 00 00       	jmp    c01034b1 <__alltraps>

c0102b90 <vector39>:
.globl vector39
vector39:
  pushl $0
c0102b90:	6a 00                	push   $0x0
  pushl $39
c0102b92:	6a 27                	push   $0x27
  jmp __alltraps
c0102b94:	e9 18 09 00 00       	jmp    c01034b1 <__alltraps>

c0102b99 <vector40>:
.globl vector40
vector40:
  pushl $0
c0102b99:	6a 00                	push   $0x0
  pushl $40
c0102b9b:	6a 28                	push   $0x28
  jmp __alltraps
c0102b9d:	e9 0f 09 00 00       	jmp    c01034b1 <__alltraps>

c0102ba2 <vector41>:
.globl vector41
vector41:
  pushl $0
c0102ba2:	6a 00                	push   $0x0
  pushl $41
c0102ba4:	6a 29                	push   $0x29
  jmp __alltraps
c0102ba6:	e9 06 09 00 00       	jmp    c01034b1 <__alltraps>

c0102bab <vector42>:
.globl vector42
vector42:
  pushl $0
c0102bab:	6a 00                	push   $0x0
  pushl $42
c0102bad:	6a 2a                	push   $0x2a
  jmp __alltraps
c0102baf:	e9 fd 08 00 00       	jmp    c01034b1 <__alltraps>

c0102bb4 <vector43>:
.globl vector43
vector43:
  pushl $0
c0102bb4:	6a 00                	push   $0x0
  pushl $43
c0102bb6:	6a 2b                	push   $0x2b
  jmp __alltraps
c0102bb8:	e9 f4 08 00 00       	jmp    c01034b1 <__alltraps>

c0102bbd <vector44>:
.globl vector44
vector44:
  pushl $0
c0102bbd:	6a 00                	push   $0x0
  pushl $44
c0102bbf:	6a 2c                	push   $0x2c
  jmp __alltraps
c0102bc1:	e9 eb 08 00 00       	jmp    c01034b1 <__alltraps>

c0102bc6 <vector45>:
.globl vector45
vector45:
  pushl $0
c0102bc6:	6a 00                	push   $0x0
  pushl $45
c0102bc8:	6a 2d                	push   $0x2d
  jmp __alltraps
c0102bca:	e9 e2 08 00 00       	jmp    c01034b1 <__alltraps>

c0102bcf <vector46>:
.globl vector46
vector46:
  pushl $0
c0102bcf:	6a 00                	push   $0x0
  pushl $46
c0102bd1:	6a 2e                	push   $0x2e
  jmp __alltraps
c0102bd3:	e9 d9 08 00 00       	jmp    c01034b1 <__alltraps>

c0102bd8 <vector47>:
.globl vector47
vector47:
  pushl $0
c0102bd8:	6a 00                	push   $0x0
  pushl $47
c0102bda:	6a 2f                	push   $0x2f
  jmp __alltraps
c0102bdc:	e9 d0 08 00 00       	jmp    c01034b1 <__alltraps>

c0102be1 <vector48>:
.globl vector48
vector48:
  pushl $0
c0102be1:	6a 00                	push   $0x0
  pushl $48
c0102be3:	6a 30                	push   $0x30
  jmp __alltraps
c0102be5:	e9 c7 08 00 00       	jmp    c01034b1 <__alltraps>

c0102bea <vector49>:
.globl vector49
vector49:
  pushl $0
c0102bea:	6a 00                	push   $0x0
  pushl $49
c0102bec:	6a 31                	push   $0x31
  jmp __alltraps
c0102bee:	e9 be 08 00 00       	jmp    c01034b1 <__alltraps>

c0102bf3 <vector50>:
.globl vector50
vector50:
  pushl $0
c0102bf3:	6a 00                	push   $0x0
  pushl $50
c0102bf5:	6a 32                	push   $0x32
  jmp __alltraps
c0102bf7:	e9 b5 08 00 00       	jmp    c01034b1 <__alltraps>

c0102bfc <vector51>:
.globl vector51
vector51:
  pushl $0
c0102bfc:	6a 00                	push   $0x0
  pushl $51
c0102bfe:	6a 33                	push   $0x33
  jmp __alltraps
c0102c00:	e9 ac 08 00 00       	jmp    c01034b1 <__alltraps>

c0102c05 <vector52>:
.globl vector52
vector52:
  pushl $0
c0102c05:	6a 00                	push   $0x0
  pushl $52
c0102c07:	6a 34                	push   $0x34
  jmp __alltraps
c0102c09:	e9 a3 08 00 00       	jmp    c01034b1 <__alltraps>

c0102c0e <vector53>:
.globl vector53
vector53:
  pushl $0
c0102c0e:	6a 00                	push   $0x0
  pushl $53
c0102c10:	6a 35                	push   $0x35
  jmp __alltraps
c0102c12:	e9 9a 08 00 00       	jmp    c01034b1 <__alltraps>

c0102c17 <vector54>:
.globl vector54
vector54:
  pushl $0
c0102c17:	6a 00                	push   $0x0
  pushl $54
c0102c19:	6a 36                	push   $0x36
  jmp __alltraps
c0102c1b:	e9 91 08 00 00       	jmp    c01034b1 <__alltraps>

c0102c20 <vector55>:
.globl vector55
vector55:
  pushl $0
c0102c20:	6a 00                	push   $0x0
  pushl $55
c0102c22:	6a 37                	push   $0x37
  jmp __alltraps
c0102c24:	e9 88 08 00 00       	jmp    c01034b1 <__alltraps>

c0102c29 <vector56>:
.globl vector56
vector56:
  pushl $0
c0102c29:	6a 00                	push   $0x0
  pushl $56
c0102c2b:	6a 38                	push   $0x38
  jmp __alltraps
c0102c2d:	e9 7f 08 00 00       	jmp    c01034b1 <__alltraps>

c0102c32 <vector57>:
.globl vector57
vector57:
  pushl $0
c0102c32:	6a 00                	push   $0x0
  pushl $57
c0102c34:	6a 39                	push   $0x39
  jmp __alltraps
c0102c36:	e9 76 08 00 00       	jmp    c01034b1 <__alltraps>

c0102c3b <vector58>:
.globl vector58
vector58:
  pushl $0
c0102c3b:	6a 00                	push   $0x0
  pushl $58
c0102c3d:	6a 3a                	push   $0x3a
  jmp __alltraps
c0102c3f:	e9 6d 08 00 00       	jmp    c01034b1 <__alltraps>

c0102c44 <vector59>:
.globl vector59
vector59:
  pushl $0
c0102c44:	6a 00                	push   $0x0
  pushl $59
c0102c46:	6a 3b                	push   $0x3b
  jmp __alltraps
c0102c48:	e9 64 08 00 00       	jmp    c01034b1 <__alltraps>

c0102c4d <vector60>:
.globl vector60
vector60:
  pushl $0
c0102c4d:	6a 00                	push   $0x0
  pushl $60
c0102c4f:	6a 3c                	push   $0x3c
  jmp __alltraps
c0102c51:	e9 5b 08 00 00       	jmp    c01034b1 <__alltraps>

c0102c56 <vector61>:
.globl vector61
vector61:
  pushl $0
c0102c56:	6a 00                	push   $0x0
  pushl $61
c0102c58:	6a 3d                	push   $0x3d
  jmp __alltraps
c0102c5a:	e9 52 08 00 00       	jmp    c01034b1 <__alltraps>

c0102c5f <vector62>:
.globl vector62
vector62:
  pushl $0
c0102c5f:	6a 00                	push   $0x0
  pushl $62
c0102c61:	6a 3e                	push   $0x3e
  jmp __alltraps
c0102c63:	e9 49 08 00 00       	jmp    c01034b1 <__alltraps>

c0102c68 <vector63>:
.globl vector63
vector63:
  pushl $0
c0102c68:	6a 00                	push   $0x0
  pushl $63
c0102c6a:	6a 3f                	push   $0x3f
  jmp __alltraps
c0102c6c:	e9 40 08 00 00       	jmp    c01034b1 <__alltraps>

c0102c71 <vector64>:
.globl vector64
vector64:
  pushl $0
c0102c71:	6a 00                	push   $0x0
  pushl $64
c0102c73:	6a 40                	push   $0x40
  jmp __alltraps
c0102c75:	e9 37 08 00 00       	jmp    c01034b1 <__alltraps>

c0102c7a <vector65>:
.globl vector65
vector65:
  pushl $0
c0102c7a:	6a 00                	push   $0x0
  pushl $65
c0102c7c:	6a 41                	push   $0x41
  jmp __alltraps
c0102c7e:	e9 2e 08 00 00       	jmp    c01034b1 <__alltraps>

c0102c83 <vector66>:
.globl vector66
vector66:
  pushl $0
c0102c83:	6a 00                	push   $0x0
  pushl $66
c0102c85:	6a 42                	push   $0x42
  jmp __alltraps
c0102c87:	e9 25 08 00 00       	jmp    c01034b1 <__alltraps>

c0102c8c <vector67>:
.globl vector67
vector67:
  pushl $0
c0102c8c:	6a 00                	push   $0x0
  pushl $67
c0102c8e:	6a 43                	push   $0x43
  jmp __alltraps
c0102c90:	e9 1c 08 00 00       	jmp    c01034b1 <__alltraps>

c0102c95 <vector68>:
.globl vector68
vector68:
  pushl $0
c0102c95:	6a 00                	push   $0x0
  pushl $68
c0102c97:	6a 44                	push   $0x44
  jmp __alltraps
c0102c99:	e9 13 08 00 00       	jmp    c01034b1 <__alltraps>

c0102c9e <vector69>:
.globl vector69
vector69:
  pushl $0
c0102c9e:	6a 00                	push   $0x0
  pushl $69
c0102ca0:	6a 45                	push   $0x45
  jmp __alltraps
c0102ca2:	e9 0a 08 00 00       	jmp    c01034b1 <__alltraps>

c0102ca7 <vector70>:
.globl vector70
vector70:
  pushl $0
c0102ca7:	6a 00                	push   $0x0
  pushl $70
c0102ca9:	6a 46                	push   $0x46
  jmp __alltraps
c0102cab:	e9 01 08 00 00       	jmp    c01034b1 <__alltraps>

c0102cb0 <vector71>:
.globl vector71
vector71:
  pushl $0
c0102cb0:	6a 00                	push   $0x0
  pushl $71
c0102cb2:	6a 47                	push   $0x47
  jmp __alltraps
c0102cb4:	e9 f8 07 00 00       	jmp    c01034b1 <__alltraps>

c0102cb9 <vector72>:
.globl vector72
vector72:
  pushl $0
c0102cb9:	6a 00                	push   $0x0
  pushl $72
c0102cbb:	6a 48                	push   $0x48
  jmp __alltraps
c0102cbd:	e9 ef 07 00 00       	jmp    c01034b1 <__alltraps>

c0102cc2 <vector73>:
.globl vector73
vector73:
  pushl $0
c0102cc2:	6a 00                	push   $0x0
  pushl $73
c0102cc4:	6a 49                	push   $0x49
  jmp __alltraps
c0102cc6:	e9 e6 07 00 00       	jmp    c01034b1 <__alltraps>

c0102ccb <vector74>:
.globl vector74
vector74:
  pushl $0
c0102ccb:	6a 00                	push   $0x0
  pushl $74
c0102ccd:	6a 4a                	push   $0x4a
  jmp __alltraps
c0102ccf:	e9 dd 07 00 00       	jmp    c01034b1 <__alltraps>

c0102cd4 <vector75>:
.globl vector75
vector75:
  pushl $0
c0102cd4:	6a 00                	push   $0x0
  pushl $75
c0102cd6:	6a 4b                	push   $0x4b
  jmp __alltraps
c0102cd8:	e9 d4 07 00 00       	jmp    c01034b1 <__alltraps>

c0102cdd <vector76>:
.globl vector76
vector76:
  pushl $0
c0102cdd:	6a 00                	push   $0x0
  pushl $76
c0102cdf:	6a 4c                	push   $0x4c
  jmp __alltraps
c0102ce1:	e9 cb 07 00 00       	jmp    c01034b1 <__alltraps>

c0102ce6 <vector77>:
.globl vector77
vector77:
  pushl $0
c0102ce6:	6a 00                	push   $0x0
  pushl $77
c0102ce8:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102cea:	e9 c2 07 00 00       	jmp    c01034b1 <__alltraps>

c0102cef <vector78>:
.globl vector78
vector78:
  pushl $0
c0102cef:	6a 00                	push   $0x0
  pushl $78
c0102cf1:	6a 4e                	push   $0x4e
  jmp __alltraps
c0102cf3:	e9 b9 07 00 00       	jmp    c01034b1 <__alltraps>

c0102cf8 <vector79>:
.globl vector79
vector79:
  pushl $0
c0102cf8:	6a 00                	push   $0x0
  pushl $79
c0102cfa:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102cfc:	e9 b0 07 00 00       	jmp    c01034b1 <__alltraps>

c0102d01 <vector80>:
.globl vector80
vector80:
  pushl $0
c0102d01:	6a 00                	push   $0x0
  pushl $80
c0102d03:	6a 50                	push   $0x50
  jmp __alltraps
c0102d05:	e9 a7 07 00 00       	jmp    c01034b1 <__alltraps>

c0102d0a <vector81>:
.globl vector81
vector81:
  pushl $0
c0102d0a:	6a 00                	push   $0x0
  pushl $81
c0102d0c:	6a 51                	push   $0x51
  jmp __alltraps
c0102d0e:	e9 9e 07 00 00       	jmp    c01034b1 <__alltraps>

c0102d13 <vector82>:
.globl vector82
vector82:
  pushl $0
c0102d13:	6a 00                	push   $0x0
  pushl $82
c0102d15:	6a 52                	push   $0x52
  jmp __alltraps
c0102d17:	e9 95 07 00 00       	jmp    c01034b1 <__alltraps>

c0102d1c <vector83>:
.globl vector83
vector83:
  pushl $0
c0102d1c:	6a 00                	push   $0x0
  pushl $83
c0102d1e:	6a 53                	push   $0x53
  jmp __alltraps
c0102d20:	e9 8c 07 00 00       	jmp    c01034b1 <__alltraps>

c0102d25 <vector84>:
.globl vector84
vector84:
  pushl $0
c0102d25:	6a 00                	push   $0x0
  pushl $84
c0102d27:	6a 54                	push   $0x54
  jmp __alltraps
c0102d29:	e9 83 07 00 00       	jmp    c01034b1 <__alltraps>

c0102d2e <vector85>:
.globl vector85
vector85:
  pushl $0
c0102d2e:	6a 00                	push   $0x0
  pushl $85
c0102d30:	6a 55                	push   $0x55
  jmp __alltraps
c0102d32:	e9 7a 07 00 00       	jmp    c01034b1 <__alltraps>

c0102d37 <vector86>:
.globl vector86
vector86:
  pushl $0
c0102d37:	6a 00                	push   $0x0
  pushl $86
c0102d39:	6a 56                	push   $0x56
  jmp __alltraps
c0102d3b:	e9 71 07 00 00       	jmp    c01034b1 <__alltraps>

c0102d40 <vector87>:
.globl vector87
vector87:
  pushl $0
c0102d40:	6a 00                	push   $0x0
  pushl $87
c0102d42:	6a 57                	push   $0x57
  jmp __alltraps
c0102d44:	e9 68 07 00 00       	jmp    c01034b1 <__alltraps>

c0102d49 <vector88>:
.globl vector88
vector88:
  pushl $0
c0102d49:	6a 00                	push   $0x0
  pushl $88
c0102d4b:	6a 58                	push   $0x58
  jmp __alltraps
c0102d4d:	e9 5f 07 00 00       	jmp    c01034b1 <__alltraps>

c0102d52 <vector89>:
.globl vector89
vector89:
  pushl $0
c0102d52:	6a 00                	push   $0x0
  pushl $89
c0102d54:	6a 59                	push   $0x59
  jmp __alltraps
c0102d56:	e9 56 07 00 00       	jmp    c01034b1 <__alltraps>

c0102d5b <vector90>:
.globl vector90
vector90:
  pushl $0
c0102d5b:	6a 00                	push   $0x0
  pushl $90
c0102d5d:	6a 5a                	push   $0x5a
  jmp __alltraps
c0102d5f:	e9 4d 07 00 00       	jmp    c01034b1 <__alltraps>

c0102d64 <vector91>:
.globl vector91
vector91:
  pushl $0
c0102d64:	6a 00                	push   $0x0
  pushl $91
c0102d66:	6a 5b                	push   $0x5b
  jmp __alltraps
c0102d68:	e9 44 07 00 00       	jmp    c01034b1 <__alltraps>

c0102d6d <vector92>:
.globl vector92
vector92:
  pushl $0
c0102d6d:	6a 00                	push   $0x0
  pushl $92
c0102d6f:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102d71:	e9 3b 07 00 00       	jmp    c01034b1 <__alltraps>

c0102d76 <vector93>:
.globl vector93
vector93:
  pushl $0
c0102d76:	6a 00                	push   $0x0
  pushl $93
c0102d78:	6a 5d                	push   $0x5d
  jmp __alltraps
c0102d7a:	e9 32 07 00 00       	jmp    c01034b1 <__alltraps>

c0102d7f <vector94>:
.globl vector94
vector94:
  pushl $0
c0102d7f:	6a 00                	push   $0x0
  pushl $94
c0102d81:	6a 5e                	push   $0x5e
  jmp __alltraps
c0102d83:	e9 29 07 00 00       	jmp    c01034b1 <__alltraps>

c0102d88 <vector95>:
.globl vector95
vector95:
  pushl $0
c0102d88:	6a 00                	push   $0x0
  pushl $95
c0102d8a:	6a 5f                	push   $0x5f
  jmp __alltraps
c0102d8c:	e9 20 07 00 00       	jmp    c01034b1 <__alltraps>

c0102d91 <vector96>:
.globl vector96
vector96:
  pushl $0
c0102d91:	6a 00                	push   $0x0
  pushl $96
c0102d93:	6a 60                	push   $0x60
  jmp __alltraps
c0102d95:	e9 17 07 00 00       	jmp    c01034b1 <__alltraps>

c0102d9a <vector97>:
.globl vector97
vector97:
  pushl $0
c0102d9a:	6a 00                	push   $0x0
  pushl $97
c0102d9c:	6a 61                	push   $0x61
  jmp __alltraps
c0102d9e:	e9 0e 07 00 00       	jmp    c01034b1 <__alltraps>

c0102da3 <vector98>:
.globl vector98
vector98:
  pushl $0
c0102da3:	6a 00                	push   $0x0
  pushl $98
c0102da5:	6a 62                	push   $0x62
  jmp __alltraps
c0102da7:	e9 05 07 00 00       	jmp    c01034b1 <__alltraps>

c0102dac <vector99>:
.globl vector99
vector99:
  pushl $0
c0102dac:	6a 00                	push   $0x0
  pushl $99
c0102dae:	6a 63                	push   $0x63
  jmp __alltraps
c0102db0:	e9 fc 06 00 00       	jmp    c01034b1 <__alltraps>

c0102db5 <vector100>:
.globl vector100
vector100:
  pushl $0
c0102db5:	6a 00                	push   $0x0
  pushl $100
c0102db7:	6a 64                	push   $0x64
  jmp __alltraps
c0102db9:	e9 f3 06 00 00       	jmp    c01034b1 <__alltraps>

c0102dbe <vector101>:
.globl vector101
vector101:
  pushl $0
c0102dbe:	6a 00                	push   $0x0
  pushl $101
c0102dc0:	6a 65                	push   $0x65
  jmp __alltraps
c0102dc2:	e9 ea 06 00 00       	jmp    c01034b1 <__alltraps>

c0102dc7 <vector102>:
.globl vector102
vector102:
  pushl $0
c0102dc7:	6a 00                	push   $0x0
  pushl $102
c0102dc9:	6a 66                	push   $0x66
  jmp __alltraps
c0102dcb:	e9 e1 06 00 00       	jmp    c01034b1 <__alltraps>

c0102dd0 <vector103>:
.globl vector103
vector103:
  pushl $0
c0102dd0:	6a 00                	push   $0x0
  pushl $103
c0102dd2:	6a 67                	push   $0x67
  jmp __alltraps
c0102dd4:	e9 d8 06 00 00       	jmp    c01034b1 <__alltraps>

c0102dd9 <vector104>:
.globl vector104
vector104:
  pushl $0
c0102dd9:	6a 00                	push   $0x0
  pushl $104
c0102ddb:	6a 68                	push   $0x68
  jmp __alltraps
c0102ddd:	e9 cf 06 00 00       	jmp    c01034b1 <__alltraps>

c0102de2 <vector105>:
.globl vector105
vector105:
  pushl $0
c0102de2:	6a 00                	push   $0x0
  pushl $105
c0102de4:	6a 69                	push   $0x69
  jmp __alltraps
c0102de6:	e9 c6 06 00 00       	jmp    c01034b1 <__alltraps>

c0102deb <vector106>:
.globl vector106
vector106:
  pushl $0
c0102deb:	6a 00                	push   $0x0
  pushl $106
c0102ded:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102def:	e9 bd 06 00 00       	jmp    c01034b1 <__alltraps>

c0102df4 <vector107>:
.globl vector107
vector107:
  pushl $0
c0102df4:	6a 00                	push   $0x0
  pushl $107
c0102df6:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102df8:	e9 b4 06 00 00       	jmp    c01034b1 <__alltraps>

c0102dfd <vector108>:
.globl vector108
vector108:
  pushl $0
c0102dfd:	6a 00                	push   $0x0
  pushl $108
c0102dff:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102e01:	e9 ab 06 00 00       	jmp    c01034b1 <__alltraps>

c0102e06 <vector109>:
.globl vector109
vector109:
  pushl $0
c0102e06:	6a 00                	push   $0x0
  pushl $109
c0102e08:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102e0a:	e9 a2 06 00 00       	jmp    c01034b1 <__alltraps>

c0102e0f <vector110>:
.globl vector110
vector110:
  pushl $0
c0102e0f:	6a 00                	push   $0x0
  pushl $110
c0102e11:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102e13:	e9 99 06 00 00       	jmp    c01034b1 <__alltraps>

c0102e18 <vector111>:
.globl vector111
vector111:
  pushl $0
c0102e18:	6a 00                	push   $0x0
  pushl $111
c0102e1a:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102e1c:	e9 90 06 00 00       	jmp    c01034b1 <__alltraps>

c0102e21 <vector112>:
.globl vector112
vector112:
  pushl $0
c0102e21:	6a 00                	push   $0x0
  pushl $112
c0102e23:	6a 70                	push   $0x70
  jmp __alltraps
c0102e25:	e9 87 06 00 00       	jmp    c01034b1 <__alltraps>

c0102e2a <vector113>:
.globl vector113
vector113:
  pushl $0
c0102e2a:	6a 00                	push   $0x0
  pushl $113
c0102e2c:	6a 71                	push   $0x71
  jmp __alltraps
c0102e2e:	e9 7e 06 00 00       	jmp    c01034b1 <__alltraps>

c0102e33 <vector114>:
.globl vector114
vector114:
  pushl $0
c0102e33:	6a 00                	push   $0x0
  pushl $114
c0102e35:	6a 72                	push   $0x72
  jmp __alltraps
c0102e37:	e9 75 06 00 00       	jmp    c01034b1 <__alltraps>

c0102e3c <vector115>:
.globl vector115
vector115:
  pushl $0
c0102e3c:	6a 00                	push   $0x0
  pushl $115
c0102e3e:	6a 73                	push   $0x73
  jmp __alltraps
c0102e40:	e9 6c 06 00 00       	jmp    c01034b1 <__alltraps>

c0102e45 <vector116>:
.globl vector116
vector116:
  pushl $0
c0102e45:	6a 00                	push   $0x0
  pushl $116
c0102e47:	6a 74                	push   $0x74
  jmp __alltraps
c0102e49:	e9 63 06 00 00       	jmp    c01034b1 <__alltraps>

c0102e4e <vector117>:
.globl vector117
vector117:
  pushl $0
c0102e4e:	6a 00                	push   $0x0
  pushl $117
c0102e50:	6a 75                	push   $0x75
  jmp __alltraps
c0102e52:	e9 5a 06 00 00       	jmp    c01034b1 <__alltraps>

c0102e57 <vector118>:
.globl vector118
vector118:
  pushl $0
c0102e57:	6a 00                	push   $0x0
  pushl $118
c0102e59:	6a 76                	push   $0x76
  jmp __alltraps
c0102e5b:	e9 51 06 00 00       	jmp    c01034b1 <__alltraps>

c0102e60 <vector119>:
.globl vector119
vector119:
  pushl $0
c0102e60:	6a 00                	push   $0x0
  pushl $119
c0102e62:	6a 77                	push   $0x77
  jmp __alltraps
c0102e64:	e9 48 06 00 00       	jmp    c01034b1 <__alltraps>

c0102e69 <vector120>:
.globl vector120
vector120:
  pushl $0
c0102e69:	6a 00                	push   $0x0
  pushl $120
c0102e6b:	6a 78                	push   $0x78
  jmp __alltraps
c0102e6d:	e9 3f 06 00 00       	jmp    c01034b1 <__alltraps>

c0102e72 <vector121>:
.globl vector121
vector121:
  pushl $0
c0102e72:	6a 00                	push   $0x0
  pushl $121
c0102e74:	6a 79                	push   $0x79
  jmp __alltraps
c0102e76:	e9 36 06 00 00       	jmp    c01034b1 <__alltraps>

c0102e7b <vector122>:
.globl vector122
vector122:
  pushl $0
c0102e7b:	6a 00                	push   $0x0
  pushl $122
c0102e7d:	6a 7a                	push   $0x7a
  jmp __alltraps
c0102e7f:	e9 2d 06 00 00       	jmp    c01034b1 <__alltraps>

c0102e84 <vector123>:
.globl vector123
vector123:
  pushl $0
c0102e84:	6a 00                	push   $0x0
  pushl $123
c0102e86:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102e88:	e9 24 06 00 00       	jmp    c01034b1 <__alltraps>

c0102e8d <vector124>:
.globl vector124
vector124:
  pushl $0
c0102e8d:	6a 00                	push   $0x0
  pushl $124
c0102e8f:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102e91:	e9 1b 06 00 00       	jmp    c01034b1 <__alltraps>

c0102e96 <vector125>:
.globl vector125
vector125:
  pushl $0
c0102e96:	6a 00                	push   $0x0
  pushl $125
c0102e98:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102e9a:	e9 12 06 00 00       	jmp    c01034b1 <__alltraps>

c0102e9f <vector126>:
.globl vector126
vector126:
  pushl $0
c0102e9f:	6a 00                	push   $0x0
  pushl $126
c0102ea1:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102ea3:	e9 09 06 00 00       	jmp    c01034b1 <__alltraps>

c0102ea8 <vector127>:
.globl vector127
vector127:
  pushl $0
c0102ea8:	6a 00                	push   $0x0
  pushl $127
c0102eaa:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102eac:	e9 00 06 00 00       	jmp    c01034b1 <__alltraps>

c0102eb1 <vector128>:
.globl vector128
vector128:
  pushl $0
c0102eb1:	6a 00                	push   $0x0
  pushl $128
c0102eb3:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102eb8:	e9 f4 05 00 00       	jmp    c01034b1 <__alltraps>

c0102ebd <vector129>:
.globl vector129
vector129:
  pushl $0
c0102ebd:	6a 00                	push   $0x0
  pushl $129
c0102ebf:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102ec4:	e9 e8 05 00 00       	jmp    c01034b1 <__alltraps>

c0102ec9 <vector130>:
.globl vector130
vector130:
  pushl $0
c0102ec9:	6a 00                	push   $0x0
  pushl $130
c0102ecb:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0102ed0:	e9 dc 05 00 00       	jmp    c01034b1 <__alltraps>

c0102ed5 <vector131>:
.globl vector131
vector131:
  pushl $0
c0102ed5:	6a 00                	push   $0x0
  pushl $131
c0102ed7:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102edc:	e9 d0 05 00 00       	jmp    c01034b1 <__alltraps>

c0102ee1 <vector132>:
.globl vector132
vector132:
  pushl $0
c0102ee1:	6a 00                	push   $0x0
  pushl $132
c0102ee3:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0102ee8:	e9 c4 05 00 00       	jmp    c01034b1 <__alltraps>

c0102eed <vector133>:
.globl vector133
vector133:
  pushl $0
c0102eed:	6a 00                	push   $0x0
  pushl $133
c0102eef:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0102ef4:	e9 b8 05 00 00       	jmp    c01034b1 <__alltraps>

c0102ef9 <vector134>:
.globl vector134
vector134:
  pushl $0
c0102ef9:	6a 00                	push   $0x0
  pushl $134
c0102efb:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0102f00:	e9 ac 05 00 00       	jmp    c01034b1 <__alltraps>

c0102f05 <vector135>:
.globl vector135
vector135:
  pushl $0
c0102f05:	6a 00                	push   $0x0
  pushl $135
c0102f07:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102f0c:	e9 a0 05 00 00       	jmp    c01034b1 <__alltraps>

c0102f11 <vector136>:
.globl vector136
vector136:
  pushl $0
c0102f11:	6a 00                	push   $0x0
  pushl $136
c0102f13:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0102f18:	e9 94 05 00 00       	jmp    c01034b1 <__alltraps>

c0102f1d <vector137>:
.globl vector137
vector137:
  pushl $0
c0102f1d:	6a 00                	push   $0x0
  pushl $137
c0102f1f:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0102f24:	e9 88 05 00 00       	jmp    c01034b1 <__alltraps>

c0102f29 <vector138>:
.globl vector138
vector138:
  pushl $0
c0102f29:	6a 00                	push   $0x0
  pushl $138
c0102f2b:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0102f30:	e9 7c 05 00 00       	jmp    c01034b1 <__alltraps>

c0102f35 <vector139>:
.globl vector139
vector139:
  pushl $0
c0102f35:	6a 00                	push   $0x0
  pushl $139
c0102f37:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0102f3c:	e9 70 05 00 00       	jmp    c01034b1 <__alltraps>

c0102f41 <vector140>:
.globl vector140
vector140:
  pushl $0
c0102f41:	6a 00                	push   $0x0
  pushl $140
c0102f43:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0102f48:	e9 64 05 00 00       	jmp    c01034b1 <__alltraps>

c0102f4d <vector141>:
.globl vector141
vector141:
  pushl $0
c0102f4d:	6a 00                	push   $0x0
  pushl $141
c0102f4f:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0102f54:	e9 58 05 00 00       	jmp    c01034b1 <__alltraps>

c0102f59 <vector142>:
.globl vector142
vector142:
  pushl $0
c0102f59:	6a 00                	push   $0x0
  pushl $142
c0102f5b:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0102f60:	e9 4c 05 00 00       	jmp    c01034b1 <__alltraps>

c0102f65 <vector143>:
.globl vector143
vector143:
  pushl $0
c0102f65:	6a 00                	push   $0x0
  pushl $143
c0102f67:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0102f6c:	e9 40 05 00 00       	jmp    c01034b1 <__alltraps>

c0102f71 <vector144>:
.globl vector144
vector144:
  pushl $0
c0102f71:	6a 00                	push   $0x0
  pushl $144
c0102f73:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0102f78:	e9 34 05 00 00       	jmp    c01034b1 <__alltraps>

c0102f7d <vector145>:
.globl vector145
vector145:
  pushl $0
c0102f7d:	6a 00                	push   $0x0
  pushl $145
c0102f7f:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0102f84:	e9 28 05 00 00       	jmp    c01034b1 <__alltraps>

c0102f89 <vector146>:
.globl vector146
vector146:
  pushl $0
c0102f89:	6a 00                	push   $0x0
  pushl $146
c0102f8b:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0102f90:	e9 1c 05 00 00       	jmp    c01034b1 <__alltraps>

c0102f95 <vector147>:
.globl vector147
vector147:
  pushl $0
c0102f95:	6a 00                	push   $0x0
  pushl $147
c0102f97:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0102f9c:	e9 10 05 00 00       	jmp    c01034b1 <__alltraps>

c0102fa1 <vector148>:
.globl vector148
vector148:
  pushl $0
c0102fa1:	6a 00                	push   $0x0
  pushl $148
c0102fa3:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0102fa8:	e9 04 05 00 00       	jmp    c01034b1 <__alltraps>

c0102fad <vector149>:
.globl vector149
vector149:
  pushl $0
c0102fad:	6a 00                	push   $0x0
  pushl $149
c0102faf:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0102fb4:	e9 f8 04 00 00       	jmp    c01034b1 <__alltraps>

c0102fb9 <vector150>:
.globl vector150
vector150:
  pushl $0
c0102fb9:	6a 00                	push   $0x0
  pushl $150
c0102fbb:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0102fc0:	e9 ec 04 00 00       	jmp    c01034b1 <__alltraps>

c0102fc5 <vector151>:
.globl vector151
vector151:
  pushl $0
c0102fc5:	6a 00                	push   $0x0
  pushl $151
c0102fc7:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0102fcc:	e9 e0 04 00 00       	jmp    c01034b1 <__alltraps>

c0102fd1 <vector152>:
.globl vector152
vector152:
  pushl $0
c0102fd1:	6a 00                	push   $0x0
  pushl $152
c0102fd3:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0102fd8:	e9 d4 04 00 00       	jmp    c01034b1 <__alltraps>

c0102fdd <vector153>:
.globl vector153
vector153:
  pushl $0
c0102fdd:	6a 00                	push   $0x0
  pushl $153
c0102fdf:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0102fe4:	e9 c8 04 00 00       	jmp    c01034b1 <__alltraps>

c0102fe9 <vector154>:
.globl vector154
vector154:
  pushl $0
c0102fe9:	6a 00                	push   $0x0
  pushl $154
c0102feb:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0102ff0:	e9 bc 04 00 00       	jmp    c01034b1 <__alltraps>

c0102ff5 <vector155>:
.globl vector155
vector155:
  pushl $0
c0102ff5:	6a 00                	push   $0x0
  pushl $155
c0102ff7:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0102ffc:	e9 b0 04 00 00       	jmp    c01034b1 <__alltraps>

c0103001 <vector156>:
.globl vector156
vector156:
  pushl $0
c0103001:	6a 00                	push   $0x0
  pushl $156
c0103003:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0103008:	e9 a4 04 00 00       	jmp    c01034b1 <__alltraps>

c010300d <vector157>:
.globl vector157
vector157:
  pushl $0
c010300d:	6a 00                	push   $0x0
  pushl $157
c010300f:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0103014:	e9 98 04 00 00       	jmp    c01034b1 <__alltraps>

c0103019 <vector158>:
.globl vector158
vector158:
  pushl $0
c0103019:	6a 00                	push   $0x0
  pushl $158
c010301b:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0103020:	e9 8c 04 00 00       	jmp    c01034b1 <__alltraps>

c0103025 <vector159>:
.globl vector159
vector159:
  pushl $0
c0103025:	6a 00                	push   $0x0
  pushl $159
c0103027:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c010302c:	e9 80 04 00 00       	jmp    c01034b1 <__alltraps>

c0103031 <vector160>:
.globl vector160
vector160:
  pushl $0
c0103031:	6a 00                	push   $0x0
  pushl $160
c0103033:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c0103038:	e9 74 04 00 00       	jmp    c01034b1 <__alltraps>

c010303d <vector161>:
.globl vector161
vector161:
  pushl $0
c010303d:	6a 00                	push   $0x0
  pushl $161
c010303f:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0103044:	e9 68 04 00 00       	jmp    c01034b1 <__alltraps>

c0103049 <vector162>:
.globl vector162
vector162:
  pushl $0
c0103049:	6a 00                	push   $0x0
  pushl $162
c010304b:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c0103050:	e9 5c 04 00 00       	jmp    c01034b1 <__alltraps>

c0103055 <vector163>:
.globl vector163
vector163:
  pushl $0
c0103055:	6a 00                	push   $0x0
  pushl $163
c0103057:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c010305c:	e9 50 04 00 00       	jmp    c01034b1 <__alltraps>

c0103061 <vector164>:
.globl vector164
vector164:
  pushl $0
c0103061:	6a 00                	push   $0x0
  pushl $164
c0103063:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c0103068:	e9 44 04 00 00       	jmp    c01034b1 <__alltraps>

c010306d <vector165>:
.globl vector165
vector165:
  pushl $0
c010306d:	6a 00                	push   $0x0
  pushl $165
c010306f:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c0103074:	e9 38 04 00 00       	jmp    c01034b1 <__alltraps>

c0103079 <vector166>:
.globl vector166
vector166:
  pushl $0
c0103079:	6a 00                	push   $0x0
  pushl $166
c010307b:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c0103080:	e9 2c 04 00 00       	jmp    c01034b1 <__alltraps>

c0103085 <vector167>:
.globl vector167
vector167:
  pushl $0
c0103085:	6a 00                	push   $0x0
  pushl $167
c0103087:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c010308c:	e9 20 04 00 00       	jmp    c01034b1 <__alltraps>

c0103091 <vector168>:
.globl vector168
vector168:
  pushl $0
c0103091:	6a 00                	push   $0x0
  pushl $168
c0103093:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c0103098:	e9 14 04 00 00       	jmp    c01034b1 <__alltraps>

c010309d <vector169>:
.globl vector169
vector169:
  pushl $0
c010309d:	6a 00                	push   $0x0
  pushl $169
c010309f:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c01030a4:	e9 08 04 00 00       	jmp    c01034b1 <__alltraps>

c01030a9 <vector170>:
.globl vector170
vector170:
  pushl $0
c01030a9:	6a 00                	push   $0x0
  pushl $170
c01030ab:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c01030b0:	e9 fc 03 00 00       	jmp    c01034b1 <__alltraps>

c01030b5 <vector171>:
.globl vector171
vector171:
  pushl $0
c01030b5:	6a 00                	push   $0x0
  pushl $171
c01030b7:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c01030bc:	e9 f0 03 00 00       	jmp    c01034b1 <__alltraps>

c01030c1 <vector172>:
.globl vector172
vector172:
  pushl $0
c01030c1:	6a 00                	push   $0x0
  pushl $172
c01030c3:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c01030c8:	e9 e4 03 00 00       	jmp    c01034b1 <__alltraps>

c01030cd <vector173>:
.globl vector173
vector173:
  pushl $0
c01030cd:	6a 00                	push   $0x0
  pushl $173
c01030cf:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c01030d4:	e9 d8 03 00 00       	jmp    c01034b1 <__alltraps>

c01030d9 <vector174>:
.globl vector174
vector174:
  pushl $0
c01030d9:	6a 00                	push   $0x0
  pushl $174
c01030db:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c01030e0:	e9 cc 03 00 00       	jmp    c01034b1 <__alltraps>

c01030e5 <vector175>:
.globl vector175
vector175:
  pushl $0
c01030e5:	6a 00                	push   $0x0
  pushl $175
c01030e7:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c01030ec:	e9 c0 03 00 00       	jmp    c01034b1 <__alltraps>

c01030f1 <vector176>:
.globl vector176
vector176:
  pushl $0
c01030f1:	6a 00                	push   $0x0
  pushl $176
c01030f3:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c01030f8:	e9 b4 03 00 00       	jmp    c01034b1 <__alltraps>

c01030fd <vector177>:
.globl vector177
vector177:
  pushl $0
c01030fd:	6a 00                	push   $0x0
  pushl $177
c01030ff:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0103104:	e9 a8 03 00 00       	jmp    c01034b1 <__alltraps>

c0103109 <vector178>:
.globl vector178
vector178:
  pushl $0
c0103109:	6a 00                	push   $0x0
  pushl $178
c010310b:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0103110:	e9 9c 03 00 00       	jmp    c01034b1 <__alltraps>

c0103115 <vector179>:
.globl vector179
vector179:
  pushl $0
c0103115:	6a 00                	push   $0x0
  pushl $179
c0103117:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c010311c:	e9 90 03 00 00       	jmp    c01034b1 <__alltraps>

c0103121 <vector180>:
.globl vector180
vector180:
  pushl $0
c0103121:	6a 00                	push   $0x0
  pushl $180
c0103123:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c0103128:	e9 84 03 00 00       	jmp    c01034b1 <__alltraps>

c010312d <vector181>:
.globl vector181
vector181:
  pushl $0
c010312d:	6a 00                	push   $0x0
  pushl $181
c010312f:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c0103134:	e9 78 03 00 00       	jmp    c01034b1 <__alltraps>

c0103139 <vector182>:
.globl vector182
vector182:
  pushl $0
c0103139:	6a 00                	push   $0x0
  pushl $182
c010313b:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0103140:	e9 6c 03 00 00       	jmp    c01034b1 <__alltraps>

c0103145 <vector183>:
.globl vector183
vector183:
  pushl $0
c0103145:	6a 00                	push   $0x0
  pushl $183
c0103147:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c010314c:	e9 60 03 00 00       	jmp    c01034b1 <__alltraps>

c0103151 <vector184>:
.globl vector184
vector184:
  pushl $0
c0103151:	6a 00                	push   $0x0
  pushl $184
c0103153:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c0103158:	e9 54 03 00 00       	jmp    c01034b1 <__alltraps>

c010315d <vector185>:
.globl vector185
vector185:
  pushl $0
c010315d:	6a 00                	push   $0x0
  pushl $185
c010315f:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c0103164:	e9 48 03 00 00       	jmp    c01034b1 <__alltraps>

c0103169 <vector186>:
.globl vector186
vector186:
  pushl $0
c0103169:	6a 00                	push   $0x0
  pushl $186
c010316b:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c0103170:	e9 3c 03 00 00       	jmp    c01034b1 <__alltraps>

c0103175 <vector187>:
.globl vector187
vector187:
  pushl $0
c0103175:	6a 00                	push   $0x0
  pushl $187
c0103177:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c010317c:	e9 30 03 00 00       	jmp    c01034b1 <__alltraps>

c0103181 <vector188>:
.globl vector188
vector188:
  pushl $0
c0103181:	6a 00                	push   $0x0
  pushl $188
c0103183:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c0103188:	e9 24 03 00 00       	jmp    c01034b1 <__alltraps>

c010318d <vector189>:
.globl vector189
vector189:
  pushl $0
c010318d:	6a 00                	push   $0x0
  pushl $189
c010318f:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c0103194:	e9 18 03 00 00       	jmp    c01034b1 <__alltraps>

c0103199 <vector190>:
.globl vector190
vector190:
  pushl $0
c0103199:	6a 00                	push   $0x0
  pushl $190
c010319b:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c01031a0:	e9 0c 03 00 00       	jmp    c01034b1 <__alltraps>

c01031a5 <vector191>:
.globl vector191
vector191:
  pushl $0
c01031a5:	6a 00                	push   $0x0
  pushl $191
c01031a7:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c01031ac:	e9 00 03 00 00       	jmp    c01034b1 <__alltraps>

c01031b1 <vector192>:
.globl vector192
vector192:
  pushl $0
c01031b1:	6a 00                	push   $0x0
  pushl $192
c01031b3:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c01031b8:	e9 f4 02 00 00       	jmp    c01034b1 <__alltraps>

c01031bd <vector193>:
.globl vector193
vector193:
  pushl $0
c01031bd:	6a 00                	push   $0x0
  pushl $193
c01031bf:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c01031c4:	e9 e8 02 00 00       	jmp    c01034b1 <__alltraps>

c01031c9 <vector194>:
.globl vector194
vector194:
  pushl $0
c01031c9:	6a 00                	push   $0x0
  pushl $194
c01031cb:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c01031d0:	e9 dc 02 00 00       	jmp    c01034b1 <__alltraps>

c01031d5 <vector195>:
.globl vector195
vector195:
  pushl $0
c01031d5:	6a 00                	push   $0x0
  pushl $195
c01031d7:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c01031dc:	e9 d0 02 00 00       	jmp    c01034b1 <__alltraps>

c01031e1 <vector196>:
.globl vector196
vector196:
  pushl $0
c01031e1:	6a 00                	push   $0x0
  pushl $196
c01031e3:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c01031e8:	e9 c4 02 00 00       	jmp    c01034b1 <__alltraps>

c01031ed <vector197>:
.globl vector197
vector197:
  pushl $0
c01031ed:	6a 00                	push   $0x0
  pushl $197
c01031ef:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c01031f4:	e9 b8 02 00 00       	jmp    c01034b1 <__alltraps>

c01031f9 <vector198>:
.globl vector198
vector198:
  pushl $0
c01031f9:	6a 00                	push   $0x0
  pushl $198
c01031fb:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c0103200:	e9 ac 02 00 00       	jmp    c01034b1 <__alltraps>

c0103205 <vector199>:
.globl vector199
vector199:
  pushl $0
c0103205:	6a 00                	push   $0x0
  pushl $199
c0103207:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c010320c:	e9 a0 02 00 00       	jmp    c01034b1 <__alltraps>

c0103211 <vector200>:
.globl vector200
vector200:
  pushl $0
c0103211:	6a 00                	push   $0x0
  pushl $200
c0103213:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c0103218:	e9 94 02 00 00       	jmp    c01034b1 <__alltraps>

c010321d <vector201>:
.globl vector201
vector201:
  pushl $0
c010321d:	6a 00                	push   $0x0
  pushl $201
c010321f:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0103224:	e9 88 02 00 00       	jmp    c01034b1 <__alltraps>

c0103229 <vector202>:
.globl vector202
vector202:
  pushl $0
c0103229:	6a 00                	push   $0x0
  pushl $202
c010322b:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c0103230:	e9 7c 02 00 00       	jmp    c01034b1 <__alltraps>

c0103235 <vector203>:
.globl vector203
vector203:
  pushl $0
c0103235:	6a 00                	push   $0x0
  pushl $203
c0103237:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c010323c:	e9 70 02 00 00       	jmp    c01034b1 <__alltraps>

c0103241 <vector204>:
.globl vector204
vector204:
  pushl $0
c0103241:	6a 00                	push   $0x0
  pushl $204
c0103243:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c0103248:	e9 64 02 00 00       	jmp    c01034b1 <__alltraps>

c010324d <vector205>:
.globl vector205
vector205:
  pushl $0
c010324d:	6a 00                	push   $0x0
  pushl $205
c010324f:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c0103254:	e9 58 02 00 00       	jmp    c01034b1 <__alltraps>

c0103259 <vector206>:
.globl vector206
vector206:
  pushl $0
c0103259:	6a 00                	push   $0x0
  pushl $206
c010325b:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c0103260:	e9 4c 02 00 00       	jmp    c01034b1 <__alltraps>

c0103265 <vector207>:
.globl vector207
vector207:
  pushl $0
c0103265:	6a 00                	push   $0x0
  pushl $207
c0103267:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c010326c:	e9 40 02 00 00       	jmp    c01034b1 <__alltraps>

c0103271 <vector208>:
.globl vector208
vector208:
  pushl $0
c0103271:	6a 00                	push   $0x0
  pushl $208
c0103273:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c0103278:	e9 34 02 00 00       	jmp    c01034b1 <__alltraps>

c010327d <vector209>:
.globl vector209
vector209:
  pushl $0
c010327d:	6a 00                	push   $0x0
  pushl $209
c010327f:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c0103284:	e9 28 02 00 00       	jmp    c01034b1 <__alltraps>

c0103289 <vector210>:
.globl vector210
vector210:
  pushl $0
c0103289:	6a 00                	push   $0x0
  pushl $210
c010328b:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c0103290:	e9 1c 02 00 00       	jmp    c01034b1 <__alltraps>

c0103295 <vector211>:
.globl vector211
vector211:
  pushl $0
c0103295:	6a 00                	push   $0x0
  pushl $211
c0103297:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c010329c:	e9 10 02 00 00       	jmp    c01034b1 <__alltraps>

c01032a1 <vector212>:
.globl vector212
vector212:
  pushl $0
c01032a1:	6a 00                	push   $0x0
  pushl $212
c01032a3:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c01032a8:	e9 04 02 00 00       	jmp    c01034b1 <__alltraps>

c01032ad <vector213>:
.globl vector213
vector213:
  pushl $0
c01032ad:	6a 00                	push   $0x0
  pushl $213
c01032af:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c01032b4:	e9 f8 01 00 00       	jmp    c01034b1 <__alltraps>

c01032b9 <vector214>:
.globl vector214
vector214:
  pushl $0
c01032b9:	6a 00                	push   $0x0
  pushl $214
c01032bb:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c01032c0:	e9 ec 01 00 00       	jmp    c01034b1 <__alltraps>

c01032c5 <vector215>:
.globl vector215
vector215:
  pushl $0
c01032c5:	6a 00                	push   $0x0
  pushl $215
c01032c7:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c01032cc:	e9 e0 01 00 00       	jmp    c01034b1 <__alltraps>

c01032d1 <vector216>:
.globl vector216
vector216:
  pushl $0
c01032d1:	6a 00                	push   $0x0
  pushl $216
c01032d3:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c01032d8:	e9 d4 01 00 00       	jmp    c01034b1 <__alltraps>

c01032dd <vector217>:
.globl vector217
vector217:
  pushl $0
c01032dd:	6a 00                	push   $0x0
  pushl $217
c01032df:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c01032e4:	e9 c8 01 00 00       	jmp    c01034b1 <__alltraps>

c01032e9 <vector218>:
.globl vector218
vector218:
  pushl $0
c01032e9:	6a 00                	push   $0x0
  pushl $218
c01032eb:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c01032f0:	e9 bc 01 00 00       	jmp    c01034b1 <__alltraps>

c01032f5 <vector219>:
.globl vector219
vector219:
  pushl $0
c01032f5:	6a 00                	push   $0x0
  pushl $219
c01032f7:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c01032fc:	e9 b0 01 00 00       	jmp    c01034b1 <__alltraps>

c0103301 <vector220>:
.globl vector220
vector220:
  pushl $0
c0103301:	6a 00                	push   $0x0
  pushl $220
c0103303:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c0103308:	e9 a4 01 00 00       	jmp    c01034b1 <__alltraps>

c010330d <vector221>:
.globl vector221
vector221:
  pushl $0
c010330d:	6a 00                	push   $0x0
  pushl $221
c010330f:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c0103314:	e9 98 01 00 00       	jmp    c01034b1 <__alltraps>

c0103319 <vector222>:
.globl vector222
vector222:
  pushl $0
c0103319:	6a 00                	push   $0x0
  pushl $222
c010331b:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0103320:	e9 8c 01 00 00       	jmp    c01034b1 <__alltraps>

c0103325 <vector223>:
.globl vector223
vector223:
  pushl $0
c0103325:	6a 00                	push   $0x0
  pushl $223
c0103327:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c010332c:	e9 80 01 00 00       	jmp    c01034b1 <__alltraps>

c0103331 <vector224>:
.globl vector224
vector224:
  pushl $0
c0103331:	6a 00                	push   $0x0
  pushl $224
c0103333:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c0103338:	e9 74 01 00 00       	jmp    c01034b1 <__alltraps>

c010333d <vector225>:
.globl vector225
vector225:
  pushl $0
c010333d:	6a 00                	push   $0x0
  pushl $225
c010333f:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c0103344:	e9 68 01 00 00       	jmp    c01034b1 <__alltraps>

c0103349 <vector226>:
.globl vector226
vector226:
  pushl $0
c0103349:	6a 00                	push   $0x0
  pushl $226
c010334b:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c0103350:	e9 5c 01 00 00       	jmp    c01034b1 <__alltraps>

c0103355 <vector227>:
.globl vector227
vector227:
  pushl $0
c0103355:	6a 00                	push   $0x0
  pushl $227
c0103357:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c010335c:	e9 50 01 00 00       	jmp    c01034b1 <__alltraps>

c0103361 <vector228>:
.globl vector228
vector228:
  pushl $0
c0103361:	6a 00                	push   $0x0
  pushl $228
c0103363:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c0103368:	e9 44 01 00 00       	jmp    c01034b1 <__alltraps>

c010336d <vector229>:
.globl vector229
vector229:
  pushl $0
c010336d:	6a 00                	push   $0x0
  pushl $229
c010336f:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c0103374:	e9 38 01 00 00       	jmp    c01034b1 <__alltraps>

c0103379 <vector230>:
.globl vector230
vector230:
  pushl $0
c0103379:	6a 00                	push   $0x0
  pushl $230
c010337b:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c0103380:	e9 2c 01 00 00       	jmp    c01034b1 <__alltraps>

c0103385 <vector231>:
.globl vector231
vector231:
  pushl $0
c0103385:	6a 00                	push   $0x0
  pushl $231
c0103387:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c010338c:	e9 20 01 00 00       	jmp    c01034b1 <__alltraps>

c0103391 <vector232>:
.globl vector232
vector232:
  pushl $0
c0103391:	6a 00                	push   $0x0
  pushl $232
c0103393:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c0103398:	e9 14 01 00 00       	jmp    c01034b1 <__alltraps>

c010339d <vector233>:
.globl vector233
vector233:
  pushl $0
c010339d:	6a 00                	push   $0x0
  pushl $233
c010339f:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c01033a4:	e9 08 01 00 00       	jmp    c01034b1 <__alltraps>

c01033a9 <vector234>:
.globl vector234
vector234:
  pushl $0
c01033a9:	6a 00                	push   $0x0
  pushl $234
c01033ab:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c01033b0:	e9 fc 00 00 00       	jmp    c01034b1 <__alltraps>

c01033b5 <vector235>:
.globl vector235
vector235:
  pushl $0
c01033b5:	6a 00                	push   $0x0
  pushl $235
c01033b7:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c01033bc:	e9 f0 00 00 00       	jmp    c01034b1 <__alltraps>

c01033c1 <vector236>:
.globl vector236
vector236:
  pushl $0
c01033c1:	6a 00                	push   $0x0
  pushl $236
c01033c3:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c01033c8:	e9 e4 00 00 00       	jmp    c01034b1 <__alltraps>

c01033cd <vector237>:
.globl vector237
vector237:
  pushl $0
c01033cd:	6a 00                	push   $0x0
  pushl $237
c01033cf:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c01033d4:	e9 d8 00 00 00       	jmp    c01034b1 <__alltraps>

c01033d9 <vector238>:
.globl vector238
vector238:
  pushl $0
c01033d9:	6a 00                	push   $0x0
  pushl $238
c01033db:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c01033e0:	e9 cc 00 00 00       	jmp    c01034b1 <__alltraps>

c01033e5 <vector239>:
.globl vector239
vector239:
  pushl $0
c01033e5:	6a 00                	push   $0x0
  pushl $239
c01033e7:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c01033ec:	e9 c0 00 00 00       	jmp    c01034b1 <__alltraps>

c01033f1 <vector240>:
.globl vector240
vector240:
  pushl $0
c01033f1:	6a 00                	push   $0x0
  pushl $240
c01033f3:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c01033f8:	e9 b4 00 00 00       	jmp    c01034b1 <__alltraps>

c01033fd <vector241>:
.globl vector241
vector241:
  pushl $0
c01033fd:	6a 00                	push   $0x0
  pushl $241
c01033ff:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c0103404:	e9 a8 00 00 00       	jmp    c01034b1 <__alltraps>

c0103409 <vector242>:
.globl vector242
vector242:
  pushl $0
c0103409:	6a 00                	push   $0x0
  pushl $242
c010340b:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c0103410:	e9 9c 00 00 00       	jmp    c01034b1 <__alltraps>

c0103415 <vector243>:
.globl vector243
vector243:
  pushl $0
c0103415:	6a 00                	push   $0x0
  pushl $243
c0103417:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c010341c:	e9 90 00 00 00       	jmp    c01034b1 <__alltraps>

c0103421 <vector244>:
.globl vector244
vector244:
  pushl $0
c0103421:	6a 00                	push   $0x0
  pushl $244
c0103423:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c0103428:	e9 84 00 00 00       	jmp    c01034b1 <__alltraps>

c010342d <vector245>:
.globl vector245
vector245:
  pushl $0
c010342d:	6a 00                	push   $0x0
  pushl $245
c010342f:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c0103434:	e9 78 00 00 00       	jmp    c01034b1 <__alltraps>

c0103439 <vector246>:
.globl vector246
vector246:
  pushl $0
c0103439:	6a 00                	push   $0x0
  pushl $246
c010343b:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c0103440:	e9 6c 00 00 00       	jmp    c01034b1 <__alltraps>

c0103445 <vector247>:
.globl vector247
vector247:
  pushl $0
c0103445:	6a 00                	push   $0x0
  pushl $247
c0103447:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c010344c:	e9 60 00 00 00       	jmp    c01034b1 <__alltraps>

c0103451 <vector248>:
.globl vector248
vector248:
  pushl $0
c0103451:	6a 00                	push   $0x0
  pushl $248
c0103453:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c0103458:	e9 54 00 00 00       	jmp    c01034b1 <__alltraps>

c010345d <vector249>:
.globl vector249
vector249:
  pushl $0
c010345d:	6a 00                	push   $0x0
  pushl $249
c010345f:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c0103464:	e9 48 00 00 00       	jmp    c01034b1 <__alltraps>

c0103469 <vector250>:
.globl vector250
vector250:
  pushl $0
c0103469:	6a 00                	push   $0x0
  pushl $250
c010346b:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c0103470:	e9 3c 00 00 00       	jmp    c01034b1 <__alltraps>

c0103475 <vector251>:
.globl vector251
vector251:
  pushl $0
c0103475:	6a 00                	push   $0x0
  pushl $251
c0103477:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c010347c:	e9 30 00 00 00       	jmp    c01034b1 <__alltraps>

c0103481 <vector252>:
.globl vector252
vector252:
  pushl $0
c0103481:	6a 00                	push   $0x0
  pushl $252
c0103483:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c0103488:	e9 24 00 00 00       	jmp    c01034b1 <__alltraps>

c010348d <vector253>:
.globl vector253
vector253:
  pushl $0
c010348d:	6a 00                	push   $0x0
  pushl $253
c010348f:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c0103494:	e9 18 00 00 00       	jmp    c01034b1 <__alltraps>

c0103499 <vector254>:
.globl vector254
vector254:
  pushl $0
c0103499:	6a 00                	push   $0x0
  pushl $254
c010349b:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c01034a0:	e9 0c 00 00 00       	jmp    c01034b1 <__alltraps>

c01034a5 <vector255>:
.globl vector255
vector255:
  pushl $0
c01034a5:	6a 00                	push   $0x0
  pushl $255
c01034a7:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c01034ac:	e9 00 00 00 00       	jmp    c01034b1 <__alltraps>

c01034b1 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c01034b1:	1e                   	push   %ds
    pushl %es
c01034b2:	06                   	push   %es
    pushl %fs
c01034b3:	0f a0                	push   %fs
    pushl %gs
c01034b5:	0f a8                	push   %gs
    pushal
c01034b7:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c01034b8:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c01034bd:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c01034bf:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c01034c1:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c01034c2:	e8 ed f4 ff ff       	call   c01029b4 <trap>

    # pop the pushed stack pointer
    popl %esp
c01034c7:	5c                   	pop    %esp

c01034c8 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c01034c8:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c01034c9:	0f a9                	pop    %gs
    popl %fs
c01034cb:	0f a1                	pop    %fs
    popl %es
c01034cd:	07                   	pop    %es
    popl %ds
c01034ce:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c01034cf:	83 c4 08             	add    $0x8,%esp
    iret
c01034d2:	cf                   	iret   

c01034d3 <forkrets>:

.globl forkrets
forkrets:
    # set stack to this new process's trapframe
    movl 4(%esp), %esp
c01034d3:	8b 64 24 04          	mov    0x4(%esp),%esp
    jmp __trapret
c01034d7:	eb ef                	jmp    c01034c8 <__trapret>

c01034d9 <lock_init>:
#define local_intr_restore(x)   __intr_restore(x);

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
c01034d9:	55                   	push   %ebp
c01034da:	89 e5                	mov    %esp,%ebp
    *lock = 0;
c01034dc:	8b 45 08             	mov    0x8(%ebp),%eax
c01034df:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
c01034e5:	90                   	nop
c01034e6:	5d                   	pop    %ebp
c01034e7:	c3                   	ret    

c01034e8 <mm_count>:
bool user_mem_check(struct mm_struct *mm, uintptr_t start, size_t len, bool write);
bool copy_from_user(struct mm_struct *mm, void *dst, const void *src, size_t len, bool writable);
bool copy_to_user(struct mm_struct *mm, void *dst, const void *src, size_t len);

static inline int
mm_count(struct mm_struct *mm) {
c01034e8:	55                   	push   %ebp
c01034e9:	89 e5                	mov    %esp,%ebp
    return mm->mm_count;
c01034eb:	8b 45 08             	mov    0x8(%ebp),%eax
c01034ee:	8b 40 18             	mov    0x18(%eax),%eax
}
c01034f1:	5d                   	pop    %ebp
c01034f2:	c3                   	ret    

c01034f3 <set_mm_count>:

static inline void
set_mm_count(struct mm_struct *mm, int val) {
c01034f3:	55                   	push   %ebp
c01034f4:	89 e5                	mov    %esp,%ebp
    mm->mm_count = val;
c01034f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01034f9:	8b 55 0c             	mov    0xc(%ebp),%edx
c01034fc:	89 50 18             	mov    %edx,0x18(%eax)
}
c01034ff:	90                   	nop
c0103500:	5d                   	pop    %ebp
c0103501:	c3                   	ret    

c0103502 <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c0103502:	55                   	push   %ebp
c0103503:	89 e5                	mov    %esp,%ebp
c0103505:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0103508:	8b 45 08             	mov    0x8(%ebp),%eax
c010350b:	c1 e8 0c             	shr    $0xc,%eax
c010350e:	89 c2                	mov    %eax,%edx
c0103510:	a1 80 0f 1b c0       	mov    0xc01b0f80,%eax
c0103515:	39 c2                	cmp    %eax,%edx
c0103517:	72 1c                	jb     c0103535 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0103519:	c7 44 24 08 d0 cb 10 	movl   $0xc010cbd0,0x8(%esp)
c0103520:	c0 
c0103521:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0103528:	00 
c0103529:	c7 04 24 ef cb 10 c0 	movl   $0xc010cbef,(%esp)
c0103530:	e8 d0 ce ff ff       	call   c0100405 <__panic>
    }
    return &pages[PPN(pa)];
c0103535:	a1 60 31 1b c0       	mov    0xc01b3160,%eax
c010353a:	8b 55 08             	mov    0x8(%ebp),%edx
c010353d:	c1 ea 0c             	shr    $0xc,%edx
c0103540:	c1 e2 05             	shl    $0x5,%edx
c0103543:	01 d0                	add    %edx,%eax
}
c0103545:	c9                   	leave  
c0103546:	c3                   	ret    

c0103547 <pde2page>:
    }
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *
pde2page(pde_t pde) {
c0103547:	55                   	push   %ebp
c0103548:	89 e5                	mov    %esp,%ebp
c010354a:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c010354d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103550:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103555:	89 04 24             	mov    %eax,(%esp)
c0103558:	e8 a5 ff ff ff       	call   c0103502 <pa2page>
}
c010355d:	c9                   	leave  
c010355e:	c3                   	ret    

c010355f <mm_create>:
static void check_vma_struct(void);
static void check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
struct mm_struct *
mm_create(void) {
c010355f:	55                   	push   %ebp
c0103560:	89 e5                	mov    %esp,%ebp
c0103562:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
c0103565:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010356c:	e8 26 24 00 00       	call   c0105997 <kmalloc>
c0103571:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (mm != NULL) {
c0103574:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103578:	74 79                	je     c01035f3 <mm_create+0x94>
        list_init(&(mm->mmap_list));
c010357a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010357d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0103580:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103583:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0103586:	89 50 04             	mov    %edx,0x4(%eax)
c0103589:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010358c:	8b 50 04             	mov    0x4(%eax),%edx
c010358f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103592:	89 10                	mov    %edx,(%eax)
        mm->mmap_cache = NULL;
c0103594:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103597:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        mm->pgdir = NULL;
c010359e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035a1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        mm->map_count = 0;
c01035a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035ab:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)

        if (swap_init_ok) swap_init_mm(mm);
c01035b2:	a1 68 0f 1b c0       	mov    0xc01b0f68,%eax
c01035b7:	85 c0                	test   %eax,%eax
c01035b9:	74 0d                	je     c01035c8 <mm_create+0x69>
c01035bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035be:	89 04 24             	mov    %eax,(%esp)
c01035c1:	e8 9c 12 00 00       	call   c0104862 <swap_init_mm>
c01035c6:	eb 0a                	jmp    c01035d2 <mm_create+0x73>
        else mm->sm_priv = NULL;
c01035c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035cb:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        
        set_mm_count(mm, 0);
c01035d2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01035d9:	00 
c01035da:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035dd:	89 04 24             	mov    %eax,(%esp)
c01035e0:	e8 0e ff ff ff       	call   c01034f3 <set_mm_count>
        lock_init(&(mm->mm_lock));
c01035e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035e8:	83 c0 1c             	add    $0x1c,%eax
c01035eb:	89 04 24             	mov    %eax,(%esp)
c01035ee:	e8 e6 fe ff ff       	call   c01034d9 <lock_init>
    }    
    return mm;
c01035f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01035f6:	c9                   	leave  
c01035f7:	c3                   	ret    

c01035f8 <vma_create>:

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
c01035f8:	55                   	push   %ebp
c01035f9:	89 e5                	mov    %esp,%ebp
c01035fb:	83 ec 28             	sub    $0x28,%esp
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
c01035fe:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c0103605:	e8 8d 23 00 00       	call   c0105997 <kmalloc>
c010360a:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (vma != NULL) {
c010360d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103611:	74 1b                	je     c010362e <vma_create+0x36>
        vma->vm_start = vm_start;
c0103613:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103616:	8b 55 08             	mov    0x8(%ebp),%edx
c0103619:	89 50 04             	mov    %edx,0x4(%eax)
        vma->vm_end = vm_end;
c010361c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010361f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103622:	89 50 08             	mov    %edx,0x8(%eax)
        vma->vm_flags = vm_flags;
c0103625:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103628:	8b 55 10             	mov    0x10(%ebp),%edx
c010362b:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    return vma;
c010362e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103631:	c9                   	leave  
c0103632:	c3                   	ret    

c0103633 <find_vma>:


// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr) {
c0103633:	55                   	push   %ebp
c0103634:	89 e5                	mov    %esp,%ebp
c0103636:	83 ec 20             	sub    $0x20,%esp
    struct vma_struct *vma = NULL;
c0103639:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    if (mm != NULL) {
c0103640:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0103644:	0f 84 95 00 00 00    	je     c01036df <find_vma+0xac>
        vma = mm->mmap_cache;
c010364a:	8b 45 08             	mov    0x8(%ebp),%eax
c010364d:	8b 40 08             	mov    0x8(%eax),%eax
c0103650:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
c0103653:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0103657:	74 16                	je     c010366f <find_vma+0x3c>
c0103659:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010365c:	8b 40 04             	mov    0x4(%eax),%eax
c010365f:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103662:	77 0b                	ja     c010366f <find_vma+0x3c>
c0103664:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103667:	8b 40 08             	mov    0x8(%eax),%eax
c010366a:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010366d:	77 61                	ja     c01036d0 <find_vma+0x9d>
                bool found = 0;
c010366f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
                list_entry_t *list = &(mm->mmap_list), *le = list;
c0103676:	8b 45 08             	mov    0x8(%ebp),%eax
c0103679:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010367c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010367f:	89 45 f4             	mov    %eax,-0xc(%ebp)
                while ((le = list_next(le)) != list) {
c0103682:	eb 28                	jmp    c01036ac <find_vma+0x79>
                    vma = le2vma(le, list_link);
c0103684:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103687:	83 e8 10             	sub    $0x10,%eax
c010368a:	89 45 fc             	mov    %eax,-0x4(%ebp)
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
c010368d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103690:	8b 40 04             	mov    0x4(%eax),%eax
c0103693:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103696:	77 14                	ja     c01036ac <find_vma+0x79>
c0103698:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010369b:	8b 40 08             	mov    0x8(%eax),%eax
c010369e:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01036a1:	76 09                	jbe    c01036ac <find_vma+0x79>
                        found = 1;
c01036a3:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%ebp)
                        break;
c01036aa:	eb 17                	jmp    c01036c3 <find_vma+0x90>
c01036ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036af:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01036b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01036b5:	8b 40 04             	mov    0x4(%eax),%eax
    if (mm != NULL) {
        vma = mm->mmap_cache;
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
                bool found = 0;
                list_entry_t *list = &(mm->mmap_list), *le = list;
                while ((le = list_next(le)) != list) {
c01036b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01036bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036be:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01036c1:	75 c1                	jne    c0103684 <find_vma+0x51>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
                        found = 1;
                        break;
                    }
                }
                if (!found) {
c01036c3:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
c01036c7:	75 07                	jne    c01036d0 <find_vma+0x9d>
                    vma = NULL;
c01036c9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
                }
        }
        if (vma != NULL) {
c01036d0:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01036d4:	74 09                	je     c01036df <find_vma+0xac>
            mm->mmap_cache = vma;
c01036d6:	8b 45 08             	mov    0x8(%ebp),%eax
c01036d9:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01036dc:	89 50 08             	mov    %edx,0x8(%eax)
        }
    }
    return vma;
c01036df:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01036e2:	c9                   	leave  
c01036e3:	c3                   	ret    

c01036e4 <check_vma_overlap>:


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
c01036e4:	55                   	push   %ebp
c01036e5:	89 e5                	mov    %esp,%ebp
c01036e7:	83 ec 18             	sub    $0x18,%esp
    assert(prev->vm_start < prev->vm_end);
c01036ea:	8b 45 08             	mov    0x8(%ebp),%eax
c01036ed:	8b 50 04             	mov    0x4(%eax),%edx
c01036f0:	8b 45 08             	mov    0x8(%ebp),%eax
c01036f3:	8b 40 08             	mov    0x8(%eax),%eax
c01036f6:	39 c2                	cmp    %eax,%edx
c01036f8:	72 24                	jb     c010371e <check_vma_overlap+0x3a>
c01036fa:	c7 44 24 0c fd cb 10 	movl   $0xc010cbfd,0xc(%esp)
c0103701:	c0 
c0103702:	c7 44 24 08 1b cc 10 	movl   $0xc010cc1b,0x8(%esp)
c0103709:	c0 
c010370a:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
c0103711:	00 
c0103712:	c7 04 24 30 cc 10 c0 	movl   $0xc010cc30,(%esp)
c0103719:	e8 e7 cc ff ff       	call   c0100405 <__panic>
    assert(prev->vm_end <= next->vm_start);
c010371e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103721:	8b 50 08             	mov    0x8(%eax),%edx
c0103724:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103727:	8b 40 04             	mov    0x4(%eax),%eax
c010372a:	39 c2                	cmp    %eax,%edx
c010372c:	76 24                	jbe    c0103752 <check_vma_overlap+0x6e>
c010372e:	c7 44 24 0c 40 cc 10 	movl   $0xc010cc40,0xc(%esp)
c0103735:	c0 
c0103736:	c7 44 24 08 1b cc 10 	movl   $0xc010cc1b,0x8(%esp)
c010373d:	c0 
c010373e:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c0103745:	00 
c0103746:	c7 04 24 30 cc 10 c0 	movl   $0xc010cc30,(%esp)
c010374d:	e8 b3 cc ff ff       	call   c0100405 <__panic>
    assert(next->vm_start < next->vm_end);
c0103752:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103755:	8b 50 04             	mov    0x4(%eax),%edx
c0103758:	8b 45 0c             	mov    0xc(%ebp),%eax
c010375b:	8b 40 08             	mov    0x8(%eax),%eax
c010375e:	39 c2                	cmp    %eax,%edx
c0103760:	72 24                	jb     c0103786 <check_vma_overlap+0xa2>
c0103762:	c7 44 24 0c 5f cc 10 	movl   $0xc010cc5f,0xc(%esp)
c0103769:	c0 
c010376a:	c7 44 24 08 1b cc 10 	movl   $0xc010cc1b,0x8(%esp)
c0103771:	c0 
c0103772:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0103779:	00 
c010377a:	c7 04 24 30 cc 10 c0 	movl   $0xc010cc30,(%esp)
c0103781:	e8 7f cc ff ff       	call   c0100405 <__panic>
}
c0103786:	90                   	nop
c0103787:	c9                   	leave  
c0103788:	c3                   	ret    

c0103789 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
c0103789:	55                   	push   %ebp
c010378a:	89 e5                	mov    %esp,%ebp
c010378c:	83 ec 48             	sub    $0x48,%esp
    assert(vma->vm_start < vma->vm_end);
c010378f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103792:	8b 50 04             	mov    0x4(%eax),%edx
c0103795:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103798:	8b 40 08             	mov    0x8(%eax),%eax
c010379b:	39 c2                	cmp    %eax,%edx
c010379d:	72 24                	jb     c01037c3 <insert_vma_struct+0x3a>
c010379f:	c7 44 24 0c 7d cc 10 	movl   $0xc010cc7d,0xc(%esp)
c01037a6:	c0 
c01037a7:	c7 44 24 08 1b cc 10 	movl   $0xc010cc1b,0x8(%esp)
c01037ae:	c0 
c01037af:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
c01037b6:	00 
c01037b7:	c7 04 24 30 cc 10 c0 	movl   $0xc010cc30,(%esp)
c01037be:	e8 42 cc ff ff       	call   c0100405 <__panic>
    list_entry_t *list = &(mm->mmap_list);
c01037c3:	8b 45 08             	mov    0x8(%ebp),%eax
c01037c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    list_entry_t *le_prev = list, *le_next;
c01037c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01037cc:	89 45 f4             	mov    %eax,-0xc(%ebp)

        list_entry_t *le = list;
c01037cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01037d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while ((le = list_next(le)) != list) {
c01037d5:	eb 1f                	jmp    c01037f6 <insert_vma_struct+0x6d>
            struct vma_struct *mmap_prev = le2vma(le, list_link);
c01037d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01037da:	83 e8 10             	sub    $0x10,%eax
c01037dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            if (mmap_prev->vm_start > vma->vm_start) {
c01037e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01037e3:	8b 50 04             	mov    0x4(%eax),%edx
c01037e6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01037e9:	8b 40 04             	mov    0x4(%eax),%eax
c01037ec:	39 c2                	cmp    %eax,%edx
c01037ee:	77 1f                	ja     c010380f <insert_vma_struct+0x86>
                break;
            }
            le_prev = le;
c01037f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01037f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01037f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01037f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01037fc:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01037ff:	8b 40 04             	mov    0x4(%eax),%eax
    assert(vma->vm_start < vma->vm_end);
    list_entry_t *list = &(mm->mmap_list);
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
c0103802:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103805:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103808:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010380b:	75 ca                	jne    c01037d7 <insert_vma_struct+0x4e>
c010380d:	eb 01                	jmp    c0103810 <insert_vma_struct+0x87>
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
                break;
c010380f:	90                   	nop
c0103810:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103813:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103816:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103819:	8b 40 04             	mov    0x4(%eax),%eax
            }
            le_prev = le;
        }

    le_next = list_next(le_prev);
c010381c:	89 45 dc             	mov    %eax,-0x24(%ebp)

    /* check overlap */
    if (le_prev != list) {
c010381f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103822:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103825:	74 15                	je     c010383c <insert_vma_struct+0xb3>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
c0103827:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010382a:	8d 50 f0             	lea    -0x10(%eax),%edx
c010382d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103830:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103834:	89 14 24             	mov    %edx,(%esp)
c0103837:	e8 a8 fe ff ff       	call   c01036e4 <check_vma_overlap>
    }
    if (le_next != list) {
c010383c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010383f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103842:	74 15                	je     c0103859 <insert_vma_struct+0xd0>
        check_vma_overlap(vma, le2vma(le_next, list_link));
c0103844:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103847:	83 e8 10             	sub    $0x10,%eax
c010384a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010384e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103851:	89 04 24             	mov    %eax,(%esp)
c0103854:	e8 8b fe ff ff       	call   c01036e4 <check_vma_overlap>
    }

    vma->vm_mm = mm;
c0103859:	8b 45 0c             	mov    0xc(%ebp),%eax
c010385c:	8b 55 08             	mov    0x8(%ebp),%edx
c010385f:	89 10                	mov    %edx,(%eax)
    list_add_after(le_prev, &(vma->list_link));
c0103861:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103864:	8d 50 10             	lea    0x10(%eax),%edx
c0103867:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010386a:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010386d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0103870:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103873:	8b 40 04             	mov    0x4(%eax),%eax
c0103876:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103879:	89 55 d0             	mov    %edx,-0x30(%ebp)
c010387c:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010387f:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0103882:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0103885:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103888:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010388b:	89 10                	mov    %edx,(%eax)
c010388d:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103890:	8b 10                	mov    (%eax),%edx
c0103892:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103895:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0103898:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010389b:	8b 55 c8             	mov    -0x38(%ebp),%edx
c010389e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01038a1:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01038a4:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01038a7:	89 10                	mov    %edx,(%eax)

    mm->map_count ++;
c01038a9:	8b 45 08             	mov    0x8(%ebp),%eax
c01038ac:	8b 40 10             	mov    0x10(%eax),%eax
c01038af:	8d 50 01             	lea    0x1(%eax),%edx
c01038b2:	8b 45 08             	mov    0x8(%ebp),%eax
c01038b5:	89 50 10             	mov    %edx,0x10(%eax)
}
c01038b8:	90                   	nop
c01038b9:	c9                   	leave  
c01038ba:	c3                   	ret    

c01038bb <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
c01038bb:	55                   	push   %ebp
c01038bc:	89 e5                	mov    %esp,%ebp
c01038be:	83 ec 38             	sub    $0x38,%esp
    assert(mm_count(mm) == 0);
c01038c1:	8b 45 08             	mov    0x8(%ebp),%eax
c01038c4:	89 04 24             	mov    %eax,(%esp)
c01038c7:	e8 1c fc ff ff       	call   c01034e8 <mm_count>
c01038cc:	85 c0                	test   %eax,%eax
c01038ce:	74 24                	je     c01038f4 <mm_destroy+0x39>
c01038d0:	c7 44 24 0c 99 cc 10 	movl   $0xc010cc99,0xc(%esp)
c01038d7:	c0 
c01038d8:	c7 44 24 08 1b cc 10 	movl   $0xc010cc1b,0x8(%esp)
c01038df:	c0 
c01038e0:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
c01038e7:	00 
c01038e8:	c7 04 24 30 cc 10 c0 	movl   $0xc010cc30,(%esp)
c01038ef:	e8 11 cb ff ff       	call   c0100405 <__panic>

    list_entry_t *list = &(mm->mmap_list), *le;
c01038f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01038f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(list)) != list) {
c01038fa:	eb 36                	jmp    c0103932 <mm_destroy+0x77>
c01038fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01038ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0103902:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103905:	8b 40 04             	mov    0x4(%eax),%eax
c0103908:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010390b:	8b 12                	mov    (%edx),%edx
c010390d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0103910:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0103913:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103916:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103919:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010391c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010391f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103922:	89 10                	mov    %edx,(%eax)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
c0103924:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103927:	83 e8 10             	sub    $0x10,%eax
c010392a:	89 04 24             	mov    %eax,(%esp)
c010392d:	e8 80 20 00 00       	call   c01059b2 <kfree>
c0103932:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103935:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0103938:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010393b:	8b 40 04             	mov    0x4(%eax),%eax
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
c010393e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103941:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103944:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103947:	75 b3                	jne    c01038fc <mm_destroy+0x41>
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
    }
    kfree(mm); //kfree mm
c0103949:	8b 45 08             	mov    0x8(%ebp),%eax
c010394c:	89 04 24             	mov    %eax,(%esp)
c010394f:	e8 5e 20 00 00       	call   c01059b2 <kfree>
    mm=NULL;
c0103954:	c7 45 08 00 00 00 00 	movl   $0x0,0x8(%ebp)
}
c010395b:	90                   	nop
c010395c:	c9                   	leave  
c010395d:	c3                   	ret    

c010395e <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
c010395e:	55                   	push   %ebp
c010395f:	89 e5                	mov    %esp,%ebp
c0103961:	83 ec 38             	sub    $0x38,%esp
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
c0103964:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103967:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010396a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010396d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103972:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103975:	c7 45 e8 00 10 00 00 	movl   $0x1000,-0x18(%ebp)
c010397c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010397f:	8b 45 10             	mov    0x10(%ebp),%eax
c0103982:	01 c2                	add    %eax,%edx
c0103984:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103987:	01 d0                	add    %edx,%eax
c0103989:	48                   	dec    %eax
c010398a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010398d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103990:	ba 00 00 00 00       	mov    $0x0,%edx
c0103995:	f7 75 e8             	divl   -0x18(%ebp)
c0103998:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010399b:	29 d0                	sub    %edx,%eax
c010399d:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if (!USER_ACCESS(start, end)) {
c01039a0:	81 7d ec ff ff 1f 00 	cmpl   $0x1fffff,-0x14(%ebp)
c01039a7:	76 11                	jbe    c01039ba <mm_map+0x5c>
c01039a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01039ac:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01039af:	73 09                	jae    c01039ba <mm_map+0x5c>
c01039b1:	81 7d e0 00 00 00 b0 	cmpl   $0xb0000000,-0x20(%ebp)
c01039b8:	76 0a                	jbe    c01039c4 <mm_map+0x66>
        return -E_INVAL;
c01039ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c01039bf:	e9 b0 00 00 00       	jmp    c0103a74 <mm_map+0x116>
    }

    assert(mm != NULL);
c01039c4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01039c8:	75 24                	jne    c01039ee <mm_map+0x90>
c01039ca:	c7 44 24 0c ab cc 10 	movl   $0xc010ccab,0xc(%esp)
c01039d1:	c0 
c01039d2:	c7 44 24 08 1b cc 10 	movl   $0xc010cc1b,0x8(%esp)
c01039d9:	c0 
c01039da:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
c01039e1:	00 
c01039e2:	c7 04 24 30 cc 10 c0 	movl   $0xc010cc30,(%esp)
c01039e9:	e8 17 ca ff ff       	call   c0100405 <__panic>

    int ret = -E_INVAL;
c01039ee:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
c01039f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01039f8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01039fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01039ff:	89 04 24             	mov    %eax,(%esp)
c0103a02:	e8 2c fc ff ff       	call   c0103633 <find_vma>
c0103a07:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0103a0a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0103a0e:	74 0b                	je     c0103a1b <mm_map+0xbd>
c0103a10:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103a13:	8b 40 04             	mov    0x4(%eax),%eax
c0103a16:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0103a19:	72 52                	jb     c0103a6d <mm_map+0x10f>
        goto out;
    }
    ret = -E_NO_MEM;
c0103a1b:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
c0103a22:	8b 45 14             	mov    0x14(%ebp),%eax
c0103a25:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103a29:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103a2c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103a30:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103a33:	89 04 24             	mov    %eax,(%esp)
c0103a36:	e8 bd fb ff ff       	call   c01035f8 <vma_create>
c0103a3b:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0103a3e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0103a42:	74 2c                	je     c0103a70 <mm_map+0x112>
        goto out;
    }
    insert_vma_struct(mm, vma);
c0103a44:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103a47:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103a4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a4e:	89 04 24             	mov    %eax,(%esp)
c0103a51:	e8 33 fd ff ff       	call   c0103789 <insert_vma_struct>
    if (vma_store != NULL) {
c0103a56:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0103a5a:	74 08                	je     c0103a64 <mm_map+0x106>
        *vma_store = vma;
c0103a5c:	8b 45 18             	mov    0x18(%ebp),%eax
c0103a5f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103a62:	89 10                	mov    %edx,(%eax)
    }
    ret = 0;
c0103a64:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103a6b:	eb 04                	jmp    c0103a71 <mm_map+0x113>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
        goto out;
c0103a6d:	90                   	nop
c0103a6e:	eb 01                	jmp    c0103a71 <mm_map+0x113>
    }
    ret = -E_NO_MEM;

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
c0103a70:	90                   	nop
        *vma_store = vma;
    }
    ret = 0;

out:
    return ret;
c0103a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103a74:	c9                   	leave  
c0103a75:	c3                   	ret    

c0103a76 <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
c0103a76:	55                   	push   %ebp
c0103a77:	89 e5                	mov    %esp,%ebp
c0103a79:	56                   	push   %esi
c0103a7a:	53                   	push   %ebx
c0103a7b:	83 ec 40             	sub    $0x40,%esp
    assert(to != NULL && from != NULL);
c0103a7e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0103a82:	74 06                	je     c0103a8a <dup_mmap+0x14>
c0103a84:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0103a88:	75 24                	jne    c0103aae <dup_mmap+0x38>
c0103a8a:	c7 44 24 0c b6 cc 10 	movl   $0xc010ccb6,0xc(%esp)
c0103a91:	c0 
c0103a92:	c7 44 24 08 1b cc 10 	movl   $0xc010cc1b,0x8(%esp)
c0103a99:	c0 
c0103a9a:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
c0103aa1:	00 
c0103aa2:	c7 04 24 30 cc 10 c0 	movl   $0xc010cc30,(%esp)
c0103aa9:	e8 57 c9 ff ff       	call   c0100405 <__panic>
    list_entry_t *list = &(from->mmap_list), *le = list;
c0103aae:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103ab1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103ab4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103ab7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_prev(le)) != list) {
c0103aba:	e9 92 00 00 00       	jmp    c0103b51 <dup_mmap+0xdb>
        struct vma_struct *vma, *nvma;
        vma = le2vma(le, list_link);
c0103abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ac2:	83 e8 10             	sub    $0x10,%eax
c0103ac5:	89 45 ec             	mov    %eax,-0x14(%ebp)
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
c0103ac8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103acb:	8b 48 0c             	mov    0xc(%eax),%ecx
c0103ace:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103ad1:	8b 50 08             	mov    0x8(%eax),%edx
c0103ad4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103ad7:	8b 40 04             	mov    0x4(%eax),%eax
c0103ada:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0103ade:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103ae2:	89 04 24             	mov    %eax,(%esp)
c0103ae5:	e8 0e fb ff ff       	call   c01035f8 <vma_create>
c0103aea:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if (nvma == NULL) {
c0103aed:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0103af1:	75 07                	jne    c0103afa <dup_mmap+0x84>
            return -E_NO_MEM;
c0103af3:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0103af8:	eb 76                	jmp    c0103b70 <dup_mmap+0xfa>
        }

        insert_vma_struct(to, nvma);
c0103afa:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103afd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103b01:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b04:	89 04 24             	mov    %eax,(%esp)
c0103b07:	e8 7d fc ff ff       	call   c0103789 <insert_vma_struct>

        bool share = 0;
c0103b0c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
c0103b13:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103b16:	8b 58 08             	mov    0x8(%eax),%ebx
c0103b19:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103b1c:	8b 48 04             	mov    0x4(%eax),%ecx
c0103b1f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103b22:	8b 50 0c             	mov    0xc(%eax),%edx
c0103b25:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b28:	8b 40 0c             	mov    0xc(%eax),%eax
c0103b2b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
c0103b2e:	89 74 24 10          	mov    %esi,0x10(%esp)
c0103b32:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0103b36:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0103b3a:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103b3e:	89 04 24             	mov    %eax,(%esp)
c0103b41:	e8 ed 44 00 00       	call   c0108033 <copy_range>
c0103b46:	85 c0                	test   %eax,%eax
c0103b48:	74 07                	je     c0103b51 <dup_mmap+0xdb>
            return -E_NO_MEM;
c0103b4a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0103b4f:	eb 1f                	jmp    c0103b70 <dup_mmap+0xfa>
c0103b51:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b54:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
c0103b57:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103b5a:	8b 00                	mov    (%eax),%eax

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
    assert(to != NULL && from != NULL);
    list_entry_t *list = &(from->mmap_list), *le = list;
    while ((le = list_prev(le)) != list) {
c0103b5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103b5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b62:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103b65:	0f 85 54 ff ff ff    	jne    c0103abf <dup_mmap+0x49>
        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
            return -E_NO_MEM;
        }
    }
    return 0;
c0103b6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103b70:	83 c4 40             	add    $0x40,%esp
c0103b73:	5b                   	pop    %ebx
c0103b74:	5e                   	pop    %esi
c0103b75:	5d                   	pop    %ebp
c0103b76:	c3                   	ret    

c0103b77 <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
c0103b77:	55                   	push   %ebp
c0103b78:	89 e5                	mov    %esp,%ebp
c0103b7a:	83 ec 38             	sub    $0x38,%esp
    assert(mm != NULL && mm_count(mm) == 0);
c0103b7d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0103b81:	74 0f                	je     c0103b92 <exit_mmap+0x1b>
c0103b83:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b86:	89 04 24             	mov    %eax,(%esp)
c0103b89:	e8 5a f9 ff ff       	call   c01034e8 <mm_count>
c0103b8e:	85 c0                	test   %eax,%eax
c0103b90:	74 24                	je     c0103bb6 <exit_mmap+0x3f>
c0103b92:	c7 44 24 0c d4 cc 10 	movl   $0xc010ccd4,0xc(%esp)
c0103b99:	c0 
c0103b9a:	c7 44 24 08 1b cc 10 	movl   $0xc010cc1b,0x8(%esp)
c0103ba1:	c0 
c0103ba2:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c0103ba9:	00 
c0103baa:	c7 04 24 30 cc 10 c0 	movl   $0xc010cc30,(%esp)
c0103bb1:	e8 4f c8 ff ff       	call   c0100405 <__panic>
    pde_t *pgdir = mm->pgdir;
c0103bb6:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bb9:	8b 40 0c             	mov    0xc(%eax),%eax
c0103bbc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    list_entry_t *list = &(mm->mmap_list), *le = list;
c0103bbf:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bc2:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103bc5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103bc8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(le)) != list) {
c0103bcb:	eb 28                	jmp    c0103bf5 <exit_mmap+0x7e>
        struct vma_struct *vma = le2vma(le, list_link);
c0103bcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103bd0:	83 e8 10             	sub    $0x10,%eax
c0103bd3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
c0103bd6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103bd9:	8b 50 08             	mov    0x8(%eax),%edx
c0103bdc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103bdf:	8b 40 04             	mov    0x4(%eax),%eax
c0103be2:	89 54 24 08          	mov    %edx,0x8(%esp)
c0103be6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103bea:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103bed:	89 04 24             	mov    %eax,(%esp)
c0103bf0:	e8 41 42 00 00       	call   c0107e36 <unmap_range>
c0103bf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103bf8:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0103bfb:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103bfe:	8b 40 04             	mov    0x4(%eax),%eax
void
exit_mmap(struct mm_struct *mm) {
    assert(mm != NULL && mm_count(mm) == 0);
    pde_t *pgdir = mm->pgdir;
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
c0103c01:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103c04:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c07:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103c0a:	75 c1                	jne    c0103bcd <exit_mmap+0x56>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
    }
    while ((le = list_next(le)) != list) {
c0103c0c:	eb 28                	jmp    c0103c36 <exit_mmap+0xbf>
        struct vma_struct *vma = le2vma(le, list_link);
c0103c0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c11:	83 e8 10             	sub    $0x10,%eax
c0103c14:	89 45 e0             	mov    %eax,-0x20(%ebp)
        exit_range(pgdir, vma->vm_start, vma->vm_end);
c0103c17:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103c1a:	8b 50 08             	mov    0x8(%eax),%edx
c0103c1d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103c20:	8b 40 04             	mov    0x4(%eax),%eax
c0103c23:	89 54 24 08          	mov    %edx,0x8(%esp)
c0103c27:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103c2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c2e:	89 04 24             	mov    %eax,(%esp)
c0103c31:	e8 f5 42 00 00       	call   c0107f2b <exit_range>
c0103c36:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c39:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103c3c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103c3f:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
    }
    while ((le = list_next(le)) != list) {
c0103c42:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c48:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103c4b:	75 c1                	jne    c0103c0e <exit_mmap+0x97>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
    }
}
c0103c4d:	90                   	nop
c0103c4e:	c9                   	leave  
c0103c4f:	c3                   	ret    

c0103c50 <copy_from_user>:

bool
copy_from_user(struct mm_struct *mm, void *dst, const void *src, size_t len, bool writable) {
c0103c50:	55                   	push   %ebp
c0103c51:	89 e5                	mov    %esp,%ebp
c0103c53:	83 ec 18             	sub    $0x18,%esp
    if (!user_mem_check(mm, (uintptr_t)src, len, writable)) {
c0103c56:	8b 45 10             	mov    0x10(%ebp),%eax
c0103c59:	8b 55 18             	mov    0x18(%ebp),%edx
c0103c5c:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0103c60:	8b 55 14             	mov    0x14(%ebp),%edx
c0103c63:	89 54 24 08          	mov    %edx,0x8(%esp)
c0103c67:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103c6b:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c6e:	89 04 24             	mov    %eax,(%esp)
c0103c71:	e8 9d 09 00 00       	call   c0104613 <user_mem_check>
c0103c76:	85 c0                	test   %eax,%eax
c0103c78:	75 07                	jne    c0103c81 <copy_from_user+0x31>
        return 0;
c0103c7a:	b8 00 00 00 00       	mov    $0x0,%eax
c0103c7f:	eb 1e                	jmp    c0103c9f <copy_from_user+0x4f>
    }
    memcpy(dst, src, len);
c0103c81:	8b 45 14             	mov    0x14(%ebp),%eax
c0103c84:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103c88:	8b 45 10             	mov    0x10(%ebp),%eax
c0103c8b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103c8f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103c92:	89 04 24             	mov    %eax,(%esp)
c0103c95:	e8 cf 7d 00 00       	call   c010ba69 <memcpy>
    return 1;
c0103c9a:	b8 01 00 00 00       	mov    $0x1,%eax
}
c0103c9f:	c9                   	leave  
c0103ca0:	c3                   	ret    

c0103ca1 <copy_to_user>:

bool
copy_to_user(struct mm_struct *mm, void *dst, const void *src, size_t len) {
c0103ca1:	55                   	push   %ebp
c0103ca2:	89 e5                	mov    %esp,%ebp
c0103ca4:	83 ec 18             	sub    $0x18,%esp
    if (!user_mem_check(mm, (uintptr_t)dst, len, 1)) {
c0103ca7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103caa:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c0103cb1:	00 
c0103cb2:	8b 55 14             	mov    0x14(%ebp),%edx
c0103cb5:	89 54 24 08          	mov    %edx,0x8(%esp)
c0103cb9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103cbd:	8b 45 08             	mov    0x8(%ebp),%eax
c0103cc0:	89 04 24             	mov    %eax,(%esp)
c0103cc3:	e8 4b 09 00 00       	call   c0104613 <user_mem_check>
c0103cc8:	85 c0                	test   %eax,%eax
c0103cca:	75 07                	jne    c0103cd3 <copy_to_user+0x32>
        return 0;
c0103ccc:	b8 00 00 00 00       	mov    $0x0,%eax
c0103cd1:	eb 1e                	jmp    c0103cf1 <copy_to_user+0x50>
    }
    memcpy(dst, src, len);
c0103cd3:	8b 45 14             	mov    0x14(%ebp),%eax
c0103cd6:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103cda:	8b 45 10             	mov    0x10(%ebp),%eax
c0103cdd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103ce1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103ce4:	89 04 24             	mov    %eax,(%esp)
c0103ce7:	e8 7d 7d 00 00       	call   c010ba69 <memcpy>
    return 1;
c0103cec:	b8 01 00 00 00       	mov    $0x1,%eax
}
c0103cf1:	c9                   	leave  
c0103cf2:	c3                   	ret    

c0103cf3 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
c0103cf3:	55                   	push   %ebp
c0103cf4:	89 e5                	mov    %esp,%ebp
c0103cf6:	83 ec 08             	sub    $0x8,%esp
    check_vmm();
c0103cf9:	e8 03 00 00 00       	call   c0103d01 <check_vmm>
}
c0103cfe:	90                   	nop
c0103cff:	c9                   	leave  
c0103d00:	c3                   	ret    

c0103d01 <check_vmm>:

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
c0103d01:	55                   	push   %ebp
c0103d02:	89 e5                	mov    %esp,%ebp
c0103d04:	83 ec 28             	sub    $0x28,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0103d07:	e8 02 39 00 00       	call   c010760e <nr_free_pages>
c0103d0c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    
    check_vma_struct();
c0103d0f:	e8 14 00 00 00       	call   c0103d28 <check_vma_struct>
    check_pgfault();
c0103d14:	e8 a1 04 00 00       	call   c01041ba <check_pgfault>

    cprintf("check_vmm() succeeded.\n");
c0103d19:	c7 04 24 f4 cc 10 c0 	movl   $0xc010ccf4,(%esp)
c0103d20:	e8 89 c5 ff ff       	call   c01002ae <cprintf>
}
c0103d25:	90                   	nop
c0103d26:	c9                   	leave  
c0103d27:	c3                   	ret    

c0103d28 <check_vma_struct>:

static void
check_vma_struct(void) {
c0103d28:	55                   	push   %ebp
c0103d29:	89 e5                	mov    %esp,%ebp
c0103d2b:	83 ec 68             	sub    $0x68,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0103d2e:	e8 db 38 00 00       	call   c010760e <nr_free_pages>
c0103d33:	89 45 ec             	mov    %eax,-0x14(%ebp)

    struct mm_struct *mm = mm_create();
c0103d36:	e8 24 f8 ff ff       	call   c010355f <mm_create>
c0103d3b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(mm != NULL);
c0103d3e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0103d42:	75 24                	jne    c0103d68 <check_vma_struct+0x40>
c0103d44:	c7 44 24 0c ab cc 10 	movl   $0xc010ccab,0xc(%esp)
c0103d4b:	c0 
c0103d4c:	c7 44 24 08 1b cc 10 	movl   $0xc010cc1b,0x8(%esp)
c0103d53:	c0 
c0103d54:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c0103d5b:	00 
c0103d5c:	c7 04 24 30 cc 10 c0 	movl   $0xc010cc30,(%esp)
c0103d63:	e8 9d c6 ff ff       	call   c0100405 <__panic>

    int step1 = 10, step2 = step1 * 10;
c0103d68:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
c0103d6f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103d72:	89 d0                	mov    %edx,%eax
c0103d74:	c1 e0 02             	shl    $0x2,%eax
c0103d77:	01 d0                	add    %edx,%eax
c0103d79:	01 c0                	add    %eax,%eax
c0103d7b:	89 45 e0             	mov    %eax,-0x20(%ebp)

    int i;
    for (i = step1; i >= 1; i --) {
c0103d7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103d81:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103d84:	eb 6f                	jmp    c0103df5 <check_vma_struct+0xcd>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0103d86:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103d89:	89 d0                	mov    %edx,%eax
c0103d8b:	c1 e0 02             	shl    $0x2,%eax
c0103d8e:	01 d0                	add    %edx,%eax
c0103d90:	83 c0 02             	add    $0x2,%eax
c0103d93:	89 c1                	mov    %eax,%ecx
c0103d95:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103d98:	89 d0                	mov    %edx,%eax
c0103d9a:	c1 e0 02             	shl    $0x2,%eax
c0103d9d:	01 d0                	add    %edx,%eax
c0103d9f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103da6:	00 
c0103da7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0103dab:	89 04 24             	mov    %eax,(%esp)
c0103dae:	e8 45 f8 ff ff       	call   c01035f8 <vma_create>
c0103db3:	89 45 dc             	mov    %eax,-0x24(%ebp)
        assert(vma != NULL);
c0103db6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0103dba:	75 24                	jne    c0103de0 <check_vma_struct+0xb8>
c0103dbc:	c7 44 24 0c 0c cd 10 	movl   $0xc010cd0c,0xc(%esp)
c0103dc3:	c0 
c0103dc4:	c7 44 24 08 1b cc 10 	movl   $0xc010cc1b,0x8(%esp)
c0103dcb:	c0 
c0103dcc:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
c0103dd3:	00 
c0103dd4:	c7 04 24 30 cc 10 c0 	movl   $0xc010cc30,(%esp)
c0103ddb:	e8 25 c6 ff ff       	call   c0100405 <__panic>
        insert_vma_struct(mm, vma);
c0103de0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103de3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103de7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103dea:	89 04 24             	mov    %eax,(%esp)
c0103ded:	e8 97 f9 ff ff       	call   c0103789 <insert_vma_struct>
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
c0103df2:	ff 4d f4             	decl   -0xc(%ebp)
c0103df5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103df9:	7f 8b                	jg     c0103d86 <check_vma_struct+0x5e>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    for (i = step1 + 1; i <= step2; i ++) {
c0103dfb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103dfe:	40                   	inc    %eax
c0103dff:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103e02:	eb 6f                	jmp    c0103e73 <check_vma_struct+0x14b>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0103e04:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103e07:	89 d0                	mov    %edx,%eax
c0103e09:	c1 e0 02             	shl    $0x2,%eax
c0103e0c:	01 d0                	add    %edx,%eax
c0103e0e:	83 c0 02             	add    $0x2,%eax
c0103e11:	89 c1                	mov    %eax,%ecx
c0103e13:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103e16:	89 d0                	mov    %edx,%eax
c0103e18:	c1 e0 02             	shl    $0x2,%eax
c0103e1b:	01 d0                	add    %edx,%eax
c0103e1d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103e24:	00 
c0103e25:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0103e29:	89 04 24             	mov    %eax,(%esp)
c0103e2c:	e8 c7 f7 ff ff       	call   c01035f8 <vma_create>
c0103e31:	89 45 d8             	mov    %eax,-0x28(%ebp)
        assert(vma != NULL);
c0103e34:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0103e38:	75 24                	jne    c0103e5e <check_vma_struct+0x136>
c0103e3a:	c7 44 24 0c 0c cd 10 	movl   $0xc010cd0c,0xc(%esp)
c0103e41:	c0 
c0103e42:	c7 44 24 08 1b cc 10 	movl   $0xc010cc1b,0x8(%esp)
c0103e49:	c0 
c0103e4a:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
c0103e51:	00 
c0103e52:	c7 04 24 30 cc 10 c0 	movl   $0xc010cc30,(%esp)
c0103e59:	e8 a7 c5 ff ff       	call   c0100405 <__panic>
        insert_vma_struct(mm, vma);
c0103e5e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103e61:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103e65:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103e68:	89 04 24             	mov    %eax,(%esp)
c0103e6b:	e8 19 f9 ff ff       	call   c0103789 <insert_vma_struct>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    for (i = step1 + 1; i <= step2; i ++) {
c0103e70:	ff 45 f4             	incl   -0xc(%ebp)
c0103e73:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103e76:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0103e79:	7e 89                	jle    c0103e04 <check_vma_struct+0xdc>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    list_entry_t *le = list_next(&(mm->mmap_list));
c0103e7b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103e7e:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c0103e81:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103e84:	8b 40 04             	mov    0x4(%eax),%eax
c0103e87:	89 45 f0             	mov    %eax,-0x10(%ebp)

    for (i = 1; i <= step2; i ++) {
c0103e8a:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
c0103e91:	e9 96 00 00 00       	jmp    c0103f2c <check_vma_struct+0x204>
        assert(le != &(mm->mmap_list));
c0103e96:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103e99:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103e9c:	75 24                	jne    c0103ec2 <check_vma_struct+0x19a>
c0103e9e:	c7 44 24 0c 18 cd 10 	movl   $0xc010cd18,0xc(%esp)
c0103ea5:	c0 
c0103ea6:	c7 44 24 08 1b cc 10 	movl   $0xc010cc1b,0x8(%esp)
c0103ead:	c0 
c0103eae:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
c0103eb5:	00 
c0103eb6:	c7 04 24 30 cc 10 c0 	movl   $0xc010cc30,(%esp)
c0103ebd:	e8 43 c5 ff ff       	call   c0100405 <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
c0103ec2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103ec5:	83 e8 10             	sub    $0x10,%eax
c0103ec8:	89 45 d0             	mov    %eax,-0x30(%ebp)
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
c0103ecb:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103ece:	8b 48 04             	mov    0x4(%eax),%ecx
c0103ed1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103ed4:	89 d0                	mov    %edx,%eax
c0103ed6:	c1 e0 02             	shl    $0x2,%eax
c0103ed9:	01 d0                	add    %edx,%eax
c0103edb:	39 c1                	cmp    %eax,%ecx
c0103edd:	75 17                	jne    c0103ef6 <check_vma_struct+0x1ce>
c0103edf:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103ee2:	8b 48 08             	mov    0x8(%eax),%ecx
c0103ee5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103ee8:	89 d0                	mov    %edx,%eax
c0103eea:	c1 e0 02             	shl    $0x2,%eax
c0103eed:	01 d0                	add    %edx,%eax
c0103eef:	83 c0 02             	add    $0x2,%eax
c0103ef2:	39 c1                	cmp    %eax,%ecx
c0103ef4:	74 24                	je     c0103f1a <check_vma_struct+0x1f2>
c0103ef6:	c7 44 24 0c 30 cd 10 	movl   $0xc010cd30,0xc(%esp)
c0103efd:	c0 
c0103efe:	c7 44 24 08 1b cc 10 	movl   $0xc010cc1b,0x8(%esp)
c0103f05:	c0 
c0103f06:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
c0103f0d:	00 
c0103f0e:	c7 04 24 30 cc 10 c0 	movl   $0xc010cc30,(%esp)
c0103f15:	e8 eb c4 ff ff       	call   c0100405 <__panic>
c0103f1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103f1d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0103f20:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103f23:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0103f26:	89 45 f0             	mov    %eax,-0x10(%ebp)
        insert_vma_struct(mm, vma);
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
c0103f29:	ff 45 f4             	incl   -0xc(%ebp)
c0103f2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103f2f:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0103f32:	0f 8e 5e ff ff ff    	jle    c0103e96 <check_vma_struct+0x16e>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c0103f38:	c7 45 f4 05 00 00 00 	movl   $0x5,-0xc(%ebp)
c0103f3f:	e9 cb 01 00 00       	jmp    c010410f <check_vma_struct+0x3e7>
        struct vma_struct *vma1 = find_vma(mm, i);
c0103f44:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103f47:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103f4b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103f4e:	89 04 24             	mov    %eax,(%esp)
c0103f51:	e8 dd f6 ff ff       	call   c0103633 <find_vma>
c0103f56:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(vma1 != NULL);
c0103f59:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0103f5d:	75 24                	jne    c0103f83 <check_vma_struct+0x25b>
c0103f5f:	c7 44 24 0c 65 cd 10 	movl   $0xc010cd65,0xc(%esp)
c0103f66:	c0 
c0103f67:	c7 44 24 08 1b cc 10 	movl   $0xc010cc1b,0x8(%esp)
c0103f6e:	c0 
c0103f6f:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
c0103f76:	00 
c0103f77:	c7 04 24 30 cc 10 c0 	movl   $0xc010cc30,(%esp)
c0103f7e:	e8 82 c4 ff ff       	call   c0100405 <__panic>
        struct vma_struct *vma2 = find_vma(mm, i+1);
c0103f83:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103f86:	40                   	inc    %eax
c0103f87:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103f8b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103f8e:	89 04 24             	mov    %eax,(%esp)
c0103f91:	e8 9d f6 ff ff       	call   c0103633 <find_vma>
c0103f96:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(vma2 != NULL);
c0103f99:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0103f9d:	75 24                	jne    c0103fc3 <check_vma_struct+0x29b>
c0103f9f:	c7 44 24 0c 72 cd 10 	movl   $0xc010cd72,0xc(%esp)
c0103fa6:	c0 
c0103fa7:	c7 44 24 08 1b cc 10 	movl   $0xc010cc1b,0x8(%esp)
c0103fae:	c0 
c0103faf:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
c0103fb6:	00 
c0103fb7:	c7 04 24 30 cc 10 c0 	movl   $0xc010cc30,(%esp)
c0103fbe:	e8 42 c4 ff ff       	call   c0100405 <__panic>
        struct vma_struct *vma3 = find_vma(mm, i+2);
c0103fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103fc6:	83 c0 02             	add    $0x2,%eax
c0103fc9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103fcd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103fd0:	89 04 24             	mov    %eax,(%esp)
c0103fd3:	e8 5b f6 ff ff       	call   c0103633 <find_vma>
c0103fd8:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        assert(vma3 == NULL);
c0103fdb:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
c0103fdf:	74 24                	je     c0104005 <check_vma_struct+0x2dd>
c0103fe1:	c7 44 24 0c 7f cd 10 	movl   $0xc010cd7f,0xc(%esp)
c0103fe8:	c0 
c0103fe9:	c7 44 24 08 1b cc 10 	movl   $0xc010cc1b,0x8(%esp)
c0103ff0:	c0 
c0103ff1:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
c0103ff8:	00 
c0103ff9:	c7 04 24 30 cc 10 c0 	movl   $0xc010cc30,(%esp)
c0104000:	e8 00 c4 ff ff       	call   c0100405 <__panic>
        struct vma_struct *vma4 = find_vma(mm, i+3);
c0104005:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104008:	83 c0 03             	add    $0x3,%eax
c010400b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010400f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104012:	89 04 24             	mov    %eax,(%esp)
c0104015:	e8 19 f6 ff ff       	call   c0103633 <find_vma>
c010401a:	89 45 c0             	mov    %eax,-0x40(%ebp)
        assert(vma4 == NULL);
c010401d:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c0104021:	74 24                	je     c0104047 <check_vma_struct+0x31f>
c0104023:	c7 44 24 0c 8c cd 10 	movl   $0xc010cd8c,0xc(%esp)
c010402a:	c0 
c010402b:	c7 44 24 08 1b cc 10 	movl   $0xc010cc1b,0x8(%esp)
c0104032:	c0 
c0104033:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
c010403a:	00 
c010403b:	c7 04 24 30 cc 10 c0 	movl   $0xc010cc30,(%esp)
c0104042:	e8 be c3 ff ff       	call   c0100405 <__panic>
        struct vma_struct *vma5 = find_vma(mm, i+4);
c0104047:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010404a:	83 c0 04             	add    $0x4,%eax
c010404d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104051:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104054:	89 04 24             	mov    %eax,(%esp)
c0104057:	e8 d7 f5 ff ff       	call   c0103633 <find_vma>
c010405c:	89 45 bc             	mov    %eax,-0x44(%ebp)
        assert(vma5 == NULL);
c010405f:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0104063:	74 24                	je     c0104089 <check_vma_struct+0x361>
c0104065:	c7 44 24 0c 99 cd 10 	movl   $0xc010cd99,0xc(%esp)
c010406c:	c0 
c010406d:	c7 44 24 08 1b cc 10 	movl   $0xc010cc1b,0x8(%esp)
c0104074:	c0 
c0104075:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
c010407c:	00 
c010407d:	c7 04 24 30 cc 10 c0 	movl   $0xc010cc30,(%esp)
c0104084:	e8 7c c3 ff ff       	call   c0100405 <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
c0104089:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010408c:	8b 50 04             	mov    0x4(%eax),%edx
c010408f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104092:	39 c2                	cmp    %eax,%edx
c0104094:	75 10                	jne    c01040a6 <check_vma_struct+0x37e>
c0104096:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104099:	8b 40 08             	mov    0x8(%eax),%eax
c010409c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010409f:	83 c2 02             	add    $0x2,%edx
c01040a2:	39 d0                	cmp    %edx,%eax
c01040a4:	74 24                	je     c01040ca <check_vma_struct+0x3a2>
c01040a6:	c7 44 24 0c a8 cd 10 	movl   $0xc010cda8,0xc(%esp)
c01040ad:	c0 
c01040ae:	c7 44 24 08 1b cc 10 	movl   $0xc010cc1b,0x8(%esp)
c01040b5:	c0 
c01040b6:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
c01040bd:	00 
c01040be:	c7 04 24 30 cc 10 c0 	movl   $0xc010cc30,(%esp)
c01040c5:	e8 3b c3 ff ff       	call   c0100405 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
c01040ca:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01040cd:	8b 50 04             	mov    0x4(%eax),%edx
c01040d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01040d3:	39 c2                	cmp    %eax,%edx
c01040d5:	75 10                	jne    c01040e7 <check_vma_struct+0x3bf>
c01040d7:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01040da:	8b 40 08             	mov    0x8(%eax),%eax
c01040dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01040e0:	83 c2 02             	add    $0x2,%edx
c01040e3:	39 d0                	cmp    %edx,%eax
c01040e5:	74 24                	je     c010410b <check_vma_struct+0x3e3>
c01040e7:	c7 44 24 0c d8 cd 10 	movl   $0xc010cdd8,0xc(%esp)
c01040ee:	c0 
c01040ef:	c7 44 24 08 1b cc 10 	movl   $0xc010cc1b,0x8(%esp)
c01040f6:	c0 
c01040f7:	c7 44 24 04 33 01 00 	movl   $0x133,0x4(%esp)
c01040fe:	00 
c01040ff:	c7 04 24 30 cc 10 c0 	movl   $0xc010cc30,(%esp)
c0104106:	e8 fa c2 ff ff       	call   c0100405 <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c010410b:	83 45 f4 05          	addl   $0x5,-0xc(%ebp)
c010410f:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104112:	89 d0                	mov    %edx,%eax
c0104114:	c1 e0 02             	shl    $0x2,%eax
c0104117:	01 d0                	add    %edx,%eax
c0104119:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010411c:	0f 8d 22 fe ff ff    	jge    c0103f44 <check_vma_struct+0x21c>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
    }

    for (i =4; i>=0; i--) {
c0104122:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%ebp)
c0104129:	eb 6f                	jmp    c010419a <check_vma_struct+0x472>
        struct vma_struct *vma_below_5= find_vma(mm,i);
c010412b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010412e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104132:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104135:	89 04 24             	mov    %eax,(%esp)
c0104138:	e8 f6 f4 ff ff       	call   c0103633 <find_vma>
c010413d:	89 45 b8             	mov    %eax,-0x48(%ebp)
        if (vma_below_5 != NULL ) {
c0104140:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0104144:	74 27                	je     c010416d <check_vma_struct+0x445>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
c0104146:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0104149:	8b 50 08             	mov    0x8(%eax),%edx
c010414c:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010414f:	8b 40 04             	mov    0x4(%eax),%eax
c0104152:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0104156:	89 44 24 08          	mov    %eax,0x8(%esp)
c010415a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010415d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104161:	c7 04 24 08 ce 10 c0 	movl   $0xc010ce08,(%esp)
c0104168:	e8 41 c1 ff ff       	call   c01002ae <cprintf>
        }
        assert(vma_below_5 == NULL);
c010416d:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0104171:	74 24                	je     c0104197 <check_vma_struct+0x46f>
c0104173:	c7 44 24 0c 2d ce 10 	movl   $0xc010ce2d,0xc(%esp)
c010417a:	c0 
c010417b:	c7 44 24 08 1b cc 10 	movl   $0xc010cc1b,0x8(%esp)
c0104182:	c0 
c0104183:	c7 44 24 04 3b 01 00 	movl   $0x13b,0x4(%esp)
c010418a:	00 
c010418b:	c7 04 24 30 cc 10 c0 	movl   $0xc010cc30,(%esp)
c0104192:	e8 6e c2 ff ff       	call   c0100405 <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
    }

    for (i =4; i>=0; i--) {
c0104197:	ff 4d f4             	decl   -0xc(%ebp)
c010419a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010419e:	79 8b                	jns    c010412b <check_vma_struct+0x403>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
        }
        assert(vma_below_5 == NULL);
    }

    mm_destroy(mm);
c01041a0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01041a3:	89 04 24             	mov    %eax,(%esp)
c01041a6:	e8 10 f7 ff ff       	call   c01038bb <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
c01041ab:	c7 04 24 44 ce 10 c0 	movl   $0xc010ce44,(%esp)
c01041b2:	e8 f7 c0 ff ff       	call   c01002ae <cprintf>
}
c01041b7:	90                   	nop
c01041b8:	c9                   	leave  
c01041b9:	c3                   	ret    

c01041ba <check_pgfault>:

struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
c01041ba:	55                   	push   %ebp
c01041bb:	89 e5                	mov    %esp,%ebp
c01041bd:	83 ec 38             	sub    $0x38,%esp
    size_t nr_free_pages_store = nr_free_pages();
c01041c0:	e8 49 34 00 00       	call   c010760e <nr_free_pages>
c01041c5:	89 45 ec             	mov    %eax,-0x14(%ebp)

    check_mm_struct = mm_create();
c01041c8:	e8 92 f3 ff ff       	call   c010355f <mm_create>
c01041cd:	a3 7c 30 1b c0       	mov    %eax,0xc01b307c
    assert(check_mm_struct != NULL);
c01041d2:	a1 7c 30 1b c0       	mov    0xc01b307c,%eax
c01041d7:	85 c0                	test   %eax,%eax
c01041d9:	75 24                	jne    c01041ff <check_pgfault+0x45>
c01041db:	c7 44 24 0c 63 ce 10 	movl   $0xc010ce63,0xc(%esp)
c01041e2:	c0 
c01041e3:	c7 44 24 08 1b cc 10 	movl   $0xc010cc1b,0x8(%esp)
c01041ea:	c0 
c01041eb:	c7 44 24 04 4b 01 00 	movl   $0x14b,0x4(%esp)
c01041f2:	00 
c01041f3:	c7 04 24 30 cc 10 c0 	movl   $0xc010cc30,(%esp)
c01041fa:	e8 06 c2 ff ff       	call   c0100405 <__panic>

    struct mm_struct *mm = check_mm_struct;
c01041ff:	a1 7c 30 1b c0       	mov    0xc01b307c,%eax
c0104204:	89 45 e8             	mov    %eax,-0x18(%ebp)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
c0104207:	8b 15 20 ca 12 c0    	mov    0xc012ca20,%edx
c010420d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104210:	89 50 0c             	mov    %edx,0xc(%eax)
c0104213:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104216:	8b 40 0c             	mov    0xc(%eax),%eax
c0104219:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(pgdir[0] == 0);
c010421c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010421f:	8b 00                	mov    (%eax),%eax
c0104221:	85 c0                	test   %eax,%eax
c0104223:	74 24                	je     c0104249 <check_pgfault+0x8f>
c0104225:	c7 44 24 0c 7b ce 10 	movl   $0xc010ce7b,0xc(%esp)
c010422c:	c0 
c010422d:	c7 44 24 08 1b cc 10 	movl   $0xc010cc1b,0x8(%esp)
c0104234:	c0 
c0104235:	c7 44 24 04 4f 01 00 	movl   $0x14f,0x4(%esp)
c010423c:	00 
c010423d:	c7 04 24 30 cc 10 c0 	movl   $0xc010cc30,(%esp)
c0104244:	e8 bc c1 ff ff       	call   c0100405 <__panic>

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
c0104249:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
c0104250:	00 
c0104251:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
c0104258:	00 
c0104259:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0104260:	e8 93 f3 ff ff       	call   c01035f8 <vma_create>
c0104265:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(vma != NULL);
c0104268:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c010426c:	75 24                	jne    c0104292 <check_pgfault+0xd8>
c010426e:	c7 44 24 0c 0c cd 10 	movl   $0xc010cd0c,0xc(%esp)
c0104275:	c0 
c0104276:	c7 44 24 08 1b cc 10 	movl   $0xc010cc1b,0x8(%esp)
c010427d:	c0 
c010427e:	c7 44 24 04 52 01 00 	movl   $0x152,0x4(%esp)
c0104285:	00 
c0104286:	c7 04 24 30 cc 10 c0 	movl   $0xc010cc30,(%esp)
c010428d:	e8 73 c1 ff ff       	call   c0100405 <__panic>

    insert_vma_struct(mm, vma);
c0104292:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104295:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104299:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010429c:	89 04 24             	mov    %eax,(%esp)
c010429f:	e8 e5 f4 ff ff       	call   c0103789 <insert_vma_struct>

    uintptr_t addr = 0x100;
c01042a4:	c7 45 dc 00 01 00 00 	movl   $0x100,-0x24(%ebp)
    assert(find_vma(mm, addr) == vma);
c01042ab:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01042ae:	89 44 24 04          	mov    %eax,0x4(%esp)
c01042b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01042b5:	89 04 24             	mov    %eax,(%esp)
c01042b8:	e8 76 f3 ff ff       	call   c0103633 <find_vma>
c01042bd:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01042c0:	74 24                	je     c01042e6 <check_pgfault+0x12c>
c01042c2:	c7 44 24 0c 89 ce 10 	movl   $0xc010ce89,0xc(%esp)
c01042c9:	c0 
c01042ca:	c7 44 24 08 1b cc 10 	movl   $0xc010cc1b,0x8(%esp)
c01042d1:	c0 
c01042d2:	c7 44 24 04 57 01 00 	movl   $0x157,0x4(%esp)
c01042d9:	00 
c01042da:	c7 04 24 30 cc 10 c0 	movl   $0xc010cc30,(%esp)
c01042e1:	e8 1f c1 ff ff       	call   c0100405 <__panic>

    int i, sum = 0;
c01042e6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c01042ed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01042f4:	eb 16                	jmp    c010430c <check_pgfault+0x152>
        *(char *)(addr + i) = i;
c01042f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01042f9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01042fc:	01 d0                	add    %edx,%eax
c01042fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104301:	88 10                	mov    %dl,(%eax)
        sum += i;
c0104303:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104306:	01 45 f0             	add    %eax,-0x10(%ebp)

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
c0104309:	ff 45 f4             	incl   -0xc(%ebp)
c010430c:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0104310:	7e e4                	jle    c01042f6 <check_pgfault+0x13c>
        *(char *)(addr + i) = i;
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
c0104312:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104319:	eb 14                	jmp    c010432f <check_pgfault+0x175>
        sum -= *(char *)(addr + i);
c010431b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010431e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104321:	01 d0                	add    %edx,%eax
c0104323:	0f b6 00             	movzbl (%eax),%eax
c0104326:	0f be c0             	movsbl %al,%eax
c0104329:	29 45 f0             	sub    %eax,-0x10(%ebp)
    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
        *(char *)(addr + i) = i;
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
c010432c:	ff 45 f4             	incl   -0xc(%ebp)
c010432f:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0104333:	7e e6                	jle    c010431b <check_pgfault+0x161>
        sum -= *(char *)(addr + i);
    }
    assert(sum == 0);
c0104335:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104339:	74 24                	je     c010435f <check_pgfault+0x1a5>
c010433b:	c7 44 24 0c a3 ce 10 	movl   $0xc010cea3,0xc(%esp)
c0104342:	c0 
c0104343:	c7 44 24 08 1b cc 10 	movl   $0xc010cc1b,0x8(%esp)
c010434a:	c0 
c010434b:	c7 44 24 04 61 01 00 	movl   $0x161,0x4(%esp)
c0104352:	00 
c0104353:	c7 04 24 30 cc 10 c0 	movl   $0xc010cc30,(%esp)
c010435a:	e8 a6 c0 ff ff       	call   c0100405 <__panic>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
c010435f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104362:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0104365:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104368:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010436d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104371:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104374:	89 04 24             	mov    %eax,(%esp)
c0104377:	e8 da 3e 00 00       	call   c0108256 <page_remove>
    free_page(pde2page(pgdir[0]));
c010437c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010437f:	8b 00                	mov    (%eax),%eax
c0104381:	89 04 24             	mov    %eax,(%esp)
c0104384:	e8 be f1 ff ff       	call   c0103547 <pde2page>
c0104389:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104390:	00 
c0104391:	89 04 24             	mov    %eax,(%esp)
c0104394:	e8 42 32 00 00       	call   c01075db <free_pages>
    pgdir[0] = 0;
c0104399:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010439c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    mm->pgdir = NULL;
c01043a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01043a5:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    mm_destroy(mm);
c01043ac:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01043af:	89 04 24             	mov    %eax,(%esp)
c01043b2:	e8 04 f5 ff ff       	call   c01038bb <mm_destroy>
    check_mm_struct = NULL;
c01043b7:	c7 05 7c 30 1b c0 00 	movl   $0x0,0xc01b307c
c01043be:	00 00 00 

    assert(nr_free_pages_store == nr_free_pages());
c01043c1:	e8 48 32 00 00       	call   c010760e <nr_free_pages>
c01043c6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01043c9:	74 24                	je     c01043ef <check_pgfault+0x235>
c01043cb:	c7 44 24 0c ac ce 10 	movl   $0xc010ceac,0xc(%esp)
c01043d2:	c0 
c01043d3:	c7 44 24 08 1b cc 10 	movl   $0xc010cc1b,0x8(%esp)
c01043da:	c0 
c01043db:	c7 44 24 04 6b 01 00 	movl   $0x16b,0x4(%esp)
c01043e2:	00 
c01043e3:	c7 04 24 30 cc 10 c0 	movl   $0xc010cc30,(%esp)
c01043ea:	e8 16 c0 ff ff       	call   c0100405 <__panic>

    cprintf("check_pgfault() succeeded!\n");
c01043ef:	c7 04 24 d3 ce 10 c0 	movl   $0xc010ced3,(%esp)
c01043f6:	e8 b3 be ff ff       	call   c01002ae <cprintf>
}
c01043fb:	90                   	nop
c01043fc:	c9                   	leave  
c01043fd:	c3                   	ret    

c01043fe <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
c01043fe:	55                   	push   %ebp
c01043ff:	89 e5                	mov    %esp,%ebp
c0104401:	83 ec 38             	sub    $0x38,%esp
    int ret = -E_INVAL;
c0104404:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
c010440b:	8b 45 10             	mov    0x10(%ebp),%eax
c010440e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104412:	8b 45 08             	mov    0x8(%ebp),%eax
c0104415:	89 04 24             	mov    %eax,(%esp)
c0104418:	e8 16 f2 ff ff       	call   c0103633 <find_vma>
c010441d:	89 45 ec             	mov    %eax,-0x14(%ebp)

    pgfault_num++;
c0104420:	a1 64 0f 1b c0       	mov    0xc01b0f64,%eax
c0104425:	40                   	inc    %eax
c0104426:	a3 64 0f 1b c0       	mov    %eax,0xc01b0f64
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
c010442b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010442f:	74 0b                	je     c010443c <do_pgfault+0x3e>
c0104431:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104434:	8b 40 04             	mov    0x4(%eax),%eax
c0104437:	3b 45 10             	cmp    0x10(%ebp),%eax
c010443a:	76 18                	jbe    c0104454 <do_pgfault+0x56>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
c010443c:	8b 45 10             	mov    0x10(%ebp),%eax
c010443f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104443:	c7 04 24 f0 ce 10 c0 	movl   $0xc010cef0,(%esp)
c010444a:	e8 5f be ff ff       	call   c01002ae <cprintf>
        goto failed;
c010444f:	e9 ba 01 00 00       	jmp    c010460e <do_pgfault+0x210>
    }
    //check the error_code
    switch (error_code & 3) {
c0104454:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104457:	83 e0 03             	and    $0x3,%eax
c010445a:	85 c0                	test   %eax,%eax
c010445c:	74 34                	je     c0104492 <do_pgfault+0x94>
c010445e:	83 f8 01             	cmp    $0x1,%eax
c0104461:	74 1e                	je     c0104481 <do_pgfault+0x83>
    default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE)) {
c0104463:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104466:	8b 40 0c             	mov    0xc(%eax),%eax
c0104469:	83 e0 02             	and    $0x2,%eax
c010446c:	85 c0                	test   %eax,%eax
c010446e:	75 40                	jne    c01044b0 <do_pgfault+0xb2>
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
c0104470:	c7 04 24 20 cf 10 c0 	movl   $0xc010cf20,(%esp)
c0104477:	e8 32 be ff ff       	call   c01002ae <cprintf>
            goto failed;
c010447c:	e9 8d 01 00 00       	jmp    c010460e <do_pgfault+0x210>
        }
        break;
    case 1: /* error code flag : (W/R=0, P=1): read, present */
        cprintf("do_pgfault failed: error code flag = read AND present\n");
c0104481:	c7 04 24 80 cf 10 c0 	movl   $0xc010cf80,(%esp)
c0104488:	e8 21 be ff ff       	call   c01002ae <cprintf>
        goto failed;
c010448d:	e9 7c 01 00 00       	jmp    c010460e <do_pgfault+0x210>
    case 0: /* error code flag : (W/R=0, P=0): read, not present */
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
c0104492:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104495:	8b 40 0c             	mov    0xc(%eax),%eax
c0104498:	83 e0 05             	and    $0x5,%eax
c010449b:	85 c0                	test   %eax,%eax
c010449d:	75 12                	jne    c01044b1 <do_pgfault+0xb3>
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
c010449f:	c7 04 24 b8 cf 10 c0 	movl   $0xc010cfb8,(%esp)
c01044a6:	e8 03 be ff ff       	call   c01002ae <cprintf>
            goto failed;
c01044ab:	e9 5e 01 00 00       	jmp    c010460e <do_pgfault+0x210>
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE)) {
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
            goto failed;
        }
        break;
c01044b0:	90                   	nop
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
c01044b1:	c7 45 f0 04 00 00 00 	movl   $0x4,-0x10(%ebp)
    if (vma->vm_flags & VM_WRITE) {
c01044b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01044bb:	8b 40 0c             	mov    0xc(%eax),%eax
c01044be:	83 e0 02             	and    $0x2,%eax
c01044c1:	85 c0                	test   %eax,%eax
c01044c3:	74 04                	je     c01044c9 <do_pgfault+0xcb>
        perm |= PTE_W;
c01044c5:	83 4d f0 02          	orl    $0x2,-0x10(%ebp)
    }
    addr = ROUNDDOWN(addr, PGSIZE);
c01044c9:	8b 45 10             	mov    0x10(%ebp),%eax
c01044cc:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01044cf:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01044d2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01044d7:	89 45 10             	mov    %eax,0x10(%ebp)

    ret = -E_NO_MEM;
c01044da:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    pte_t *ptep=NULL;
c01044e1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    // 获取页表项，但找不到虚拟地址所对应的页表项
    if ((ptep = get_pte(mm->pgdir,addr,1)) == NULL){
c01044e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01044eb:	8b 40 0c             	mov    0xc(%eax),%eax
c01044ee:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01044f5:	00 
c01044f6:	8b 55 10             	mov    0x10(%ebp),%edx
c01044f9:	89 54 24 04          	mov    %edx,0x4(%esp)
c01044fd:	89 04 24             	mov    %eax,(%esp)
c0104500:	e8 3d 37 00 00       	call   c0107c42 <get_pte>
c0104505:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104508:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010450c:	75 11                	jne    c010451f <do_pgfault+0x121>
        cprintf("get_pte in do_pgfault failed\n");
c010450e:	c7 04 24 1b d0 10 c0 	movl   $0xc010d01b,(%esp)
c0104515:	e8 94 bd ff ff       	call   c01002ae <cprintf>
        goto failed;
c010451a:	e9 ef 00 00 00       	jmp    c010460e <do_pgfault+0x210>
    }

    // 页表项为0，不存在映射关系，则要建立虚拟地址和物理地址的映射关系
    if (*ptep == 0){
c010451f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104522:	8b 00                	mov    (%eax),%eax
c0104524:	85 c0                	test   %eax,%eax
c0104526:	75 35                	jne    c010455d <do_pgfault+0x15f>
        // 权限不够,失败
        // Present为1,但低权限访问高权限内存空间 OR 程序试图写属性只读的页
        if (pgdir_alloc_page(mm->pgdir,addr,perm) == NULL){
c0104528:	8b 45 08             	mov    0x8(%ebp),%eax
c010452b:	8b 40 0c             	mov    0xc(%eax),%eax
c010452e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104531:	89 54 24 08          	mov    %edx,0x8(%esp)
c0104535:	8b 55 10             	mov    0x10(%ebp),%edx
c0104538:	89 54 24 04          	mov    %edx,0x4(%esp)
c010453c:	89 04 24             	mov    %eax,(%esp)
c010453f:	e8 6c 3e 00 00       	call   c01083b0 <pgdir_alloc_page>
c0104544:	85 c0                	test   %eax,%eax
c0104546:	0f 85 bb 00 00 00    	jne    c0104607 <do_pgfault+0x209>
            cprintf("pgdir_alloc_page in do_pgfault failed");
c010454c:	c7 04 24 3c d0 10 c0 	movl   $0xc010d03c,(%esp)
c0104553:	e8 56 bd ff ff       	call   c01002ae <cprintf>
            goto failed;
c0104558:	e9 b1 00 00 00       	jmp    c010460e <do_pgfault+0x210>
        }
    }
    else {
        // 页表项非空，尝试换入页面
        if (swap_init_ok){
c010455d:	a1 68 0f 1b c0       	mov    0xc01b0f68,%eax
c0104562:	85 c0                	test   %eax,%eax
c0104564:	0f 84 86 00 00 00    	je     c01045f0 <do_pgfault+0x1f2>
            struct Page *page = NULL; // 根据mm结构和addr地址，尝试将硬盘中的内容换入至page中
c010456a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
            if ((ret = swap_in(mm,addr,&page)) != 0){
c0104571:	8d 45 e0             	lea    -0x20(%ebp),%eax
c0104574:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104578:	8b 45 10             	mov    0x10(%ebp),%eax
c010457b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010457f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104582:	89 04 24             	mov    %eax,(%esp)
c0104585:	e8 ca 04 00 00       	call   c0104a54 <swap_in>
c010458a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010458d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104591:	74 0e                	je     c01045a1 <do_pgfault+0x1a3>
                cprintf("swap_in in do_pgfault failed\n");
c0104593:	c7 04 24 62 d0 10 c0 	movl   $0xc010d062,(%esp)
c010459a:	e8 0f bd ff ff       	call   c01002ae <cprintf>
c010459f:	eb 6d                	jmp    c010460e <do_pgfault+0x210>
                goto failed;
            }
            page_insert(mm->pgdir,page,addr,perm); //建立虚拟地址和物理地址之间的对应关系
c01045a1:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01045a4:	8b 45 08             	mov    0x8(%ebp),%eax
c01045a7:	8b 40 0c             	mov    0xc(%eax),%eax
c01045aa:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c01045ad:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01045b1:	8b 4d 10             	mov    0x10(%ebp),%ecx
c01045b4:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01045b8:	89 54 24 04          	mov    %edx,0x4(%esp)
c01045bc:	89 04 24             	mov    %eax,(%esp)
c01045bf:	e8 d7 3c 00 00       	call   c010829b <page_insert>
            swap_map_swappable(mm,addr,page,1); //将此页面设置为可交换的
c01045c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01045c7:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c01045ce:	00 
c01045cf:	89 44 24 08          	mov    %eax,0x8(%esp)
c01045d3:	8b 45 10             	mov    0x10(%ebp),%eax
c01045d6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01045da:	8b 45 08             	mov    0x8(%ebp),%eax
c01045dd:	89 04 24             	mov    %eax,(%esp)
c01045e0:	e8 ad 02 00 00       	call   c0104892 <swap_map_swappable>
            page->pra_vaddr = addr;
c01045e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01045e8:	8b 55 10             	mov    0x10(%ebp),%edx
c01045eb:	89 50 1c             	mov    %edx,0x1c(%eax)
c01045ee:	eb 17                	jmp    c0104607 <do_pgfault+0x209>
        }
        else{
            cprintf("no swap_init_ok but ptep is %x,failed\n",*ptep);
c01045f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01045f3:	8b 00                	mov    (%eax),%eax
c01045f5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01045f9:	c7 04 24 80 d0 10 c0 	movl   $0xc010d080,(%esp)
c0104600:	e8 a9 bc ff ff       	call   c01002ae <cprintf>
            goto failed;
c0104605:	eb 07                	jmp    c010460e <do_pgfault+0x210>
        }
    }
    ret = 0;
c0104607:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    failed:
    return ret;
c010460e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104611:	c9                   	leave  
c0104612:	c3                   	ret    

c0104613 <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
c0104613:	55                   	push   %ebp
c0104614:	89 e5                	mov    %esp,%ebp
c0104616:	83 ec 18             	sub    $0x18,%esp
    if (mm != NULL) {
c0104619:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010461d:	0f 84 e0 00 00 00    	je     c0104703 <user_mem_check+0xf0>
        if (!USER_ACCESS(addr, addr + len)) {
c0104623:	81 7d 0c ff ff 1f 00 	cmpl   $0x1fffff,0xc(%ebp)
c010462a:	76 1c                	jbe    c0104648 <user_mem_check+0x35>
c010462c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010462f:	8b 45 10             	mov    0x10(%ebp),%eax
c0104632:	01 d0                	add    %edx,%eax
c0104634:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104637:	76 0f                	jbe    c0104648 <user_mem_check+0x35>
c0104639:	8b 55 0c             	mov    0xc(%ebp),%edx
c010463c:	8b 45 10             	mov    0x10(%ebp),%eax
c010463f:	01 d0                	add    %edx,%eax
c0104641:	3d 00 00 00 b0       	cmp    $0xb0000000,%eax
c0104646:	76 0a                	jbe    c0104652 <user_mem_check+0x3f>
            return 0;
c0104648:	b8 00 00 00 00       	mov    $0x0,%eax
c010464d:	e9 e3 00 00 00       	jmp    c0104735 <user_mem_check+0x122>
        }
        struct vma_struct *vma;
        uintptr_t start = addr, end = addr + len;
c0104652:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104655:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0104658:	8b 55 0c             	mov    0xc(%ebp),%edx
c010465b:	8b 45 10             	mov    0x10(%ebp),%eax
c010465e:	01 d0                	add    %edx,%eax
c0104660:	89 45 f8             	mov    %eax,-0x8(%ebp)
        while (start < end) {
c0104663:	e9 88 00 00 00       	jmp    c01046f0 <user_mem_check+0xdd>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
c0104668:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010466b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010466f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104672:	89 04 24             	mov    %eax,(%esp)
c0104675:	e8 b9 ef ff ff       	call   c0103633 <find_vma>
c010467a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010467d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104681:	74 0b                	je     c010468e <user_mem_check+0x7b>
c0104683:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104686:	8b 40 04             	mov    0x4(%eax),%eax
c0104689:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010468c:	76 0a                	jbe    c0104698 <user_mem_check+0x85>
                return 0;
c010468e:	b8 00 00 00 00       	mov    $0x0,%eax
c0104693:	e9 9d 00 00 00       	jmp    c0104735 <user_mem_check+0x122>
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
c0104698:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010469b:	8b 50 0c             	mov    0xc(%eax),%edx
c010469e:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c01046a2:	74 07                	je     c01046ab <user_mem_check+0x98>
c01046a4:	b8 02 00 00 00       	mov    $0x2,%eax
c01046a9:	eb 05                	jmp    c01046b0 <user_mem_check+0x9d>
c01046ab:	b8 01 00 00 00       	mov    $0x1,%eax
c01046b0:	21 d0                	and    %edx,%eax
c01046b2:	85 c0                	test   %eax,%eax
c01046b4:	75 07                	jne    c01046bd <user_mem_check+0xaa>
                return 0;
c01046b6:	b8 00 00 00 00       	mov    $0x0,%eax
c01046bb:	eb 78                	jmp    c0104735 <user_mem_check+0x122>
            }
            if (write && (vma->vm_flags & VM_STACK)) {
c01046bd:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c01046c1:	74 24                	je     c01046e7 <user_mem_check+0xd4>
c01046c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046c6:	8b 40 0c             	mov    0xc(%eax),%eax
c01046c9:	83 e0 08             	and    $0x8,%eax
c01046cc:	85 c0                	test   %eax,%eax
c01046ce:	74 17                	je     c01046e7 <user_mem_check+0xd4>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
c01046d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046d3:	8b 40 04             	mov    0x4(%eax),%eax
c01046d6:	05 00 10 00 00       	add    $0x1000,%eax
c01046db:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01046de:	76 07                	jbe    c01046e7 <user_mem_check+0xd4>
                    return 0;
c01046e0:	b8 00 00 00 00       	mov    $0x0,%eax
c01046e5:	eb 4e                	jmp    c0104735 <user_mem_check+0x122>
                }
            }
            start = vma->vm_end;
c01046e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046ea:	8b 40 08             	mov    0x8(%eax),%eax
c01046ed:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!USER_ACCESS(addr, addr + len)) {
            return 0;
        }
        struct vma_struct *vma;
        uintptr_t start = addr, end = addr + len;
        while (start < end) {
c01046f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01046f3:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01046f6:	0f 82 6c ff ff ff    	jb     c0104668 <user_mem_check+0x55>
                    return 0;
                }
            }
            start = vma->vm_end;
        }
        return 1;
c01046fc:	b8 01 00 00 00       	mov    $0x1,%eax
c0104701:	eb 32                	jmp    c0104735 <user_mem_check+0x122>
    }
    return KERN_ACCESS(addr, addr + len);
c0104703:	81 7d 0c ff ff ff bf 	cmpl   $0xbfffffff,0xc(%ebp)
c010470a:	76 23                	jbe    c010472f <user_mem_check+0x11c>
c010470c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010470f:	8b 45 10             	mov    0x10(%ebp),%eax
c0104712:	01 d0                	add    %edx,%eax
c0104714:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104717:	76 16                	jbe    c010472f <user_mem_check+0x11c>
c0104719:	8b 55 0c             	mov    0xc(%ebp),%edx
c010471c:	8b 45 10             	mov    0x10(%ebp),%eax
c010471f:	01 d0                	add    %edx,%eax
c0104721:	3d 00 00 00 f8       	cmp    $0xf8000000,%eax
c0104726:	77 07                	ja     c010472f <user_mem_check+0x11c>
c0104728:	b8 01 00 00 00       	mov    $0x1,%eax
c010472d:	eb 05                	jmp    c0104734 <user_mem_check+0x121>
c010472f:	b8 00 00 00 00       	mov    $0x0,%eax
c0104734:	90                   	nop
}
c0104735:	c9                   	leave  
c0104736:	c3                   	ret    

c0104737 <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c0104737:	55                   	push   %ebp
c0104738:	89 e5                	mov    %esp,%ebp
c010473a:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c010473d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104740:	c1 e8 0c             	shr    $0xc,%eax
c0104743:	89 c2                	mov    %eax,%edx
c0104745:	a1 80 0f 1b c0       	mov    0xc01b0f80,%eax
c010474a:	39 c2                	cmp    %eax,%edx
c010474c:	72 1c                	jb     c010476a <pa2page+0x33>
        panic("pa2page called with invalid pa");
c010474e:	c7 44 24 08 a8 d0 10 	movl   $0xc010d0a8,0x8(%esp)
c0104755:	c0 
c0104756:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c010475d:	00 
c010475e:	c7 04 24 c7 d0 10 c0 	movl   $0xc010d0c7,(%esp)
c0104765:	e8 9b bc ff ff       	call   c0100405 <__panic>
    }
    return &pages[PPN(pa)];
c010476a:	a1 60 31 1b c0       	mov    0xc01b3160,%eax
c010476f:	8b 55 08             	mov    0x8(%ebp),%edx
c0104772:	c1 ea 0c             	shr    $0xc,%edx
c0104775:	c1 e2 05             	shl    $0x5,%edx
c0104778:	01 d0                	add    %edx,%eax
}
c010477a:	c9                   	leave  
c010477b:	c3                   	ret    

c010477c <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c010477c:	55                   	push   %ebp
c010477d:	89 e5                	mov    %esp,%ebp
c010477f:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0104782:	8b 45 08             	mov    0x8(%ebp),%eax
c0104785:	83 e0 01             	and    $0x1,%eax
c0104788:	85 c0                	test   %eax,%eax
c010478a:	75 1c                	jne    c01047a8 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c010478c:	c7 44 24 08 d8 d0 10 	movl   $0xc010d0d8,0x8(%esp)
c0104793:	c0 
c0104794:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c010479b:	00 
c010479c:	c7 04 24 c7 d0 10 c0 	movl   $0xc010d0c7,(%esp)
c01047a3:	e8 5d bc ff ff       	call   c0100405 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c01047a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01047ab:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01047b0:	89 04 24             	mov    %eax,(%esp)
c01047b3:	e8 7f ff ff ff       	call   c0104737 <pa2page>
}
c01047b8:	c9                   	leave  
c01047b9:	c3                   	ret    

c01047ba <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c01047ba:	55                   	push   %ebp
c01047bb:	89 e5                	mov    %esp,%ebp
c01047bd:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c01047c0:	8b 45 08             	mov    0x8(%ebp),%eax
c01047c3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01047c8:	89 04 24             	mov    %eax,(%esp)
c01047cb:	e8 67 ff ff ff       	call   c0104737 <pa2page>
}
c01047d0:	c9                   	leave  
c01047d1:	c3                   	ret    

c01047d2 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
c01047d2:	55                   	push   %ebp
c01047d3:	89 e5                	mov    %esp,%ebp
c01047d5:	83 ec 28             	sub    $0x28,%esp
     swapfs_init();
c01047d8:	e8 cc 49 00 00       	call   c01091a9 <swapfs_init>

     if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
c01047dd:	a1 1c 31 1b c0       	mov    0xc01b311c,%eax
c01047e2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
c01047e7:	76 0c                	jbe    c01047f5 <swap_init+0x23>
c01047e9:	a1 1c 31 1b c0       	mov    0xc01b311c,%eax
c01047ee:	3d ff ff ff 00       	cmp    $0xffffff,%eax
c01047f3:	76 25                	jbe    c010481a <swap_init+0x48>
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
c01047f5:	a1 1c 31 1b c0       	mov    0xc01b311c,%eax
c01047fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01047fe:	c7 44 24 08 f9 d0 10 	movl   $0xc010d0f9,0x8(%esp)
c0104805:	c0 
c0104806:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
c010480d:	00 
c010480e:	c7 04 24 14 d1 10 c0 	movl   $0xc010d114,(%esp)
c0104815:	e8 eb bb ff ff       	call   c0100405 <__panic>
     }
     

     sm = &swap_manager_fifo;
c010481a:	c7 05 70 0f 1b c0 00 	movl   $0xc012ca00,0xc01b0f70
c0104821:	ca 12 c0 
     int r = sm->init();
c0104824:	a1 70 0f 1b c0       	mov    0xc01b0f70,%eax
c0104829:	8b 40 04             	mov    0x4(%eax),%eax
c010482c:	ff d0                	call   *%eax
c010482e:	89 45 f4             	mov    %eax,-0xc(%ebp)
     
     if (r == 0)
c0104831:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104835:	75 26                	jne    c010485d <swap_init+0x8b>
     {
          swap_init_ok = 1;
c0104837:	c7 05 68 0f 1b c0 01 	movl   $0x1,0xc01b0f68
c010483e:	00 00 00 
          cprintf("SWAP: manager = %s\n", sm->name);
c0104841:	a1 70 0f 1b c0       	mov    0xc01b0f70,%eax
c0104846:	8b 00                	mov    (%eax),%eax
c0104848:	89 44 24 04          	mov    %eax,0x4(%esp)
c010484c:	c7 04 24 23 d1 10 c0 	movl   $0xc010d123,(%esp)
c0104853:	e8 56 ba ff ff       	call   c01002ae <cprintf>
          check_swap();
c0104858:	e8 9e 04 00 00       	call   c0104cfb <check_swap>
     }

     return r;
c010485d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104860:	c9                   	leave  
c0104861:	c3                   	ret    

c0104862 <swap_init_mm>:

int
swap_init_mm(struct mm_struct *mm)
{
c0104862:	55                   	push   %ebp
c0104863:	89 e5                	mov    %esp,%ebp
c0104865:	83 ec 18             	sub    $0x18,%esp
     return sm->init_mm(mm);
c0104868:	a1 70 0f 1b c0       	mov    0xc01b0f70,%eax
c010486d:	8b 40 08             	mov    0x8(%eax),%eax
c0104870:	8b 55 08             	mov    0x8(%ebp),%edx
c0104873:	89 14 24             	mov    %edx,(%esp)
c0104876:	ff d0                	call   *%eax
}
c0104878:	c9                   	leave  
c0104879:	c3                   	ret    

c010487a <swap_tick_event>:

int
swap_tick_event(struct mm_struct *mm)
{
c010487a:	55                   	push   %ebp
c010487b:	89 e5                	mov    %esp,%ebp
c010487d:	83 ec 18             	sub    $0x18,%esp
     return sm->tick_event(mm);
c0104880:	a1 70 0f 1b c0       	mov    0xc01b0f70,%eax
c0104885:	8b 40 0c             	mov    0xc(%eax),%eax
c0104888:	8b 55 08             	mov    0x8(%ebp),%edx
c010488b:	89 14 24             	mov    %edx,(%esp)
c010488e:	ff d0                	call   *%eax
}
c0104890:	c9                   	leave  
c0104891:	c3                   	ret    

c0104892 <swap_map_swappable>:

int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0104892:	55                   	push   %ebp
c0104893:	89 e5                	mov    %esp,%ebp
c0104895:	83 ec 18             	sub    $0x18,%esp
     return sm->map_swappable(mm, addr, page, swap_in);
c0104898:	a1 70 0f 1b c0       	mov    0xc01b0f70,%eax
c010489d:	8b 40 10             	mov    0x10(%eax),%eax
c01048a0:	8b 55 14             	mov    0x14(%ebp),%edx
c01048a3:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01048a7:	8b 55 10             	mov    0x10(%ebp),%edx
c01048aa:	89 54 24 08          	mov    %edx,0x8(%esp)
c01048ae:	8b 55 0c             	mov    0xc(%ebp),%edx
c01048b1:	89 54 24 04          	mov    %edx,0x4(%esp)
c01048b5:	8b 55 08             	mov    0x8(%ebp),%edx
c01048b8:	89 14 24             	mov    %edx,(%esp)
c01048bb:	ff d0                	call   *%eax
}
c01048bd:	c9                   	leave  
c01048be:	c3                   	ret    

c01048bf <swap_set_unswappable>:

int
swap_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c01048bf:	55                   	push   %ebp
c01048c0:	89 e5                	mov    %esp,%ebp
c01048c2:	83 ec 18             	sub    $0x18,%esp
     return sm->set_unswappable(mm, addr);
c01048c5:	a1 70 0f 1b c0       	mov    0xc01b0f70,%eax
c01048ca:	8b 40 14             	mov    0x14(%eax),%eax
c01048cd:	8b 55 0c             	mov    0xc(%ebp),%edx
c01048d0:	89 54 24 04          	mov    %edx,0x4(%esp)
c01048d4:	8b 55 08             	mov    0x8(%ebp),%edx
c01048d7:	89 14 24             	mov    %edx,(%esp)
c01048da:	ff d0                	call   *%eax
}
c01048dc:	c9                   	leave  
c01048dd:	c3                   	ret    

c01048de <swap_out>:

volatile unsigned int swap_out_num=0;

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
c01048de:	55                   	push   %ebp
c01048df:	89 e5                	mov    %esp,%ebp
c01048e1:	83 ec 38             	sub    $0x38,%esp
     int i;
     for (i = 0; i != n; ++ i)
c01048e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01048eb:	e9 53 01 00 00       	jmp    c0104a43 <swap_out+0x165>
     {
          uintptr_t v;
          //struct Page **ptr_page=NULL;
          struct Page *page;
          // cprintf("i %d, SWAP: call swap_out_victim\n",i);
          int r = sm->swap_out_victim(mm, &page, in_tick);
c01048f0:	a1 70 0f 1b c0       	mov    0xc01b0f70,%eax
c01048f5:	8b 40 18             	mov    0x18(%eax),%eax
c01048f8:	8b 55 10             	mov    0x10(%ebp),%edx
c01048fb:	89 54 24 08          	mov    %edx,0x8(%esp)
c01048ff:	8d 55 e4             	lea    -0x1c(%ebp),%edx
c0104902:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104906:	8b 55 08             	mov    0x8(%ebp),%edx
c0104909:	89 14 24             	mov    %edx,(%esp)
c010490c:	ff d0                	call   *%eax
c010490e:	89 45 f0             	mov    %eax,-0x10(%ebp)
          if (r != 0) {
c0104911:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104915:	74 18                	je     c010492f <swap_out+0x51>
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
c0104917:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010491a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010491e:	c7 04 24 38 d1 10 c0 	movl   $0xc010d138,(%esp)
c0104925:	e8 84 b9 ff ff       	call   c01002ae <cprintf>
c010492a:	e9 20 01 00 00       	jmp    c0104a4f <swap_out+0x171>
          }          
          //assert(!PageReserved(page));

          //cprintf("SWAP: choose victim page 0x%08x\n", page);
          
          v=page->pra_vaddr; 
c010492f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104932:	8b 40 1c             	mov    0x1c(%eax),%eax
c0104935:	89 45 ec             	mov    %eax,-0x14(%ebp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
c0104938:	8b 45 08             	mov    0x8(%ebp),%eax
c010493b:	8b 40 0c             	mov    0xc(%eax),%eax
c010493e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104945:	00 
c0104946:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104949:	89 54 24 04          	mov    %edx,0x4(%esp)
c010494d:	89 04 24             	mov    %eax,(%esp)
c0104950:	e8 ed 32 00 00       	call   c0107c42 <get_pte>
c0104955:	89 45 e8             	mov    %eax,-0x18(%ebp)
          assert((*ptep & PTE_P) != 0);
c0104958:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010495b:	8b 00                	mov    (%eax),%eax
c010495d:	83 e0 01             	and    $0x1,%eax
c0104960:	85 c0                	test   %eax,%eax
c0104962:	75 24                	jne    c0104988 <swap_out+0xaa>
c0104964:	c7 44 24 0c 65 d1 10 	movl   $0xc010d165,0xc(%esp)
c010496b:	c0 
c010496c:	c7 44 24 08 7a d1 10 	movl   $0xc010d17a,0x8(%esp)
c0104973:	c0 
c0104974:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c010497b:	00 
c010497c:	c7 04 24 14 d1 10 c0 	movl   $0xc010d114,(%esp)
c0104983:	e8 7d ba ff ff       	call   c0100405 <__panic>

          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
c0104988:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010498b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010498e:	8b 52 1c             	mov    0x1c(%edx),%edx
c0104991:	c1 ea 0c             	shr    $0xc,%edx
c0104994:	42                   	inc    %edx
c0104995:	c1 e2 08             	shl    $0x8,%edx
c0104998:	89 44 24 04          	mov    %eax,0x4(%esp)
c010499c:	89 14 24             	mov    %edx,(%esp)
c010499f:	e8 c0 48 00 00       	call   c0109264 <swapfs_write>
c01049a4:	85 c0                	test   %eax,%eax
c01049a6:	74 34                	je     c01049dc <swap_out+0xfe>
                    cprintf("SWAP: failed to save\n");
c01049a8:	c7 04 24 8f d1 10 c0 	movl   $0xc010d18f,(%esp)
c01049af:	e8 fa b8 ff ff       	call   c01002ae <cprintf>
                    sm->map_swappable(mm, v, page, 0);
c01049b4:	a1 70 0f 1b c0       	mov    0xc01b0f70,%eax
c01049b9:	8b 40 10             	mov    0x10(%eax),%eax
c01049bc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01049bf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01049c6:	00 
c01049c7:	89 54 24 08          	mov    %edx,0x8(%esp)
c01049cb:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01049ce:	89 54 24 04          	mov    %edx,0x4(%esp)
c01049d2:	8b 55 08             	mov    0x8(%ebp),%edx
c01049d5:	89 14 24             	mov    %edx,(%esp)
c01049d8:	ff d0                	call   *%eax
c01049da:	eb 64                	jmp    c0104a40 <swap_out+0x162>
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
c01049dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01049df:	8b 40 1c             	mov    0x1c(%eax),%eax
c01049e2:	c1 e8 0c             	shr    $0xc,%eax
c01049e5:	40                   	inc    %eax
c01049e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01049ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01049ed:	89 44 24 08          	mov    %eax,0x8(%esp)
c01049f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049f4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01049f8:	c7 04 24 a8 d1 10 c0 	movl   $0xc010d1a8,(%esp)
c01049ff:	e8 aa b8 ff ff       	call   c01002ae <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
c0104a04:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104a07:	8b 40 1c             	mov    0x1c(%eax),%eax
c0104a0a:	c1 e8 0c             	shr    $0xc,%eax
c0104a0d:	40                   	inc    %eax
c0104a0e:	c1 e0 08             	shl    $0x8,%eax
c0104a11:	89 c2                	mov    %eax,%edx
c0104a13:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104a16:	89 10                	mov    %edx,(%eax)
                    free_page(page);
c0104a18:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104a1b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104a22:	00 
c0104a23:	89 04 24             	mov    %eax,(%esp)
c0104a26:	e8 b0 2b 00 00       	call   c01075db <free_pages>
          }
          
          tlb_invalidate(mm->pgdir, v);
c0104a2b:	8b 45 08             	mov    0x8(%ebp),%eax
c0104a2e:	8b 40 0c             	mov    0xc(%eax),%eax
c0104a31:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104a34:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104a38:	89 04 24             	mov    %eax,(%esp)
c0104a3b:	e8 14 39 00 00       	call   c0108354 <tlb_invalidate>

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
     int i;
     for (i = 0; i != n; ++ i)
c0104a40:	ff 45 f4             	incl   -0xc(%ebp)
c0104a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a46:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104a49:	0f 85 a1 fe ff ff    	jne    c01048f0 <swap_out+0x12>
                    free_page(page);
          }
          
          tlb_invalidate(mm->pgdir, v);
     }
     return i;
c0104a4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104a52:	c9                   	leave  
c0104a53:	c3                   	ret    

c0104a54 <swap_in>:

int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
c0104a54:	55                   	push   %ebp
c0104a55:	89 e5                	mov    %esp,%ebp
c0104a57:	83 ec 28             	sub    $0x28,%esp
     struct Page *result = alloc_page();
c0104a5a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104a61:	e8 0a 2b 00 00       	call   c0107570 <alloc_pages>
c0104a66:	89 45 f4             	mov    %eax,-0xc(%ebp)
     assert(result!=NULL);
c0104a69:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104a6d:	75 24                	jne    c0104a93 <swap_in+0x3f>
c0104a6f:	c7 44 24 0c e8 d1 10 	movl   $0xc010d1e8,0xc(%esp)
c0104a76:	c0 
c0104a77:	c7 44 24 08 7a d1 10 	movl   $0xc010d17a,0x8(%esp)
c0104a7e:	c0 
c0104a7f:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c0104a86:	00 
c0104a87:	c7 04 24 14 d1 10 c0 	movl   $0xc010d114,(%esp)
c0104a8e:	e8 72 b9 ff ff       	call   c0100405 <__panic>

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
c0104a93:	8b 45 08             	mov    0x8(%ebp),%eax
c0104a96:	8b 40 0c             	mov    0xc(%eax),%eax
c0104a99:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104aa0:	00 
c0104aa1:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104aa4:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104aa8:	89 04 24             	mov    %eax,(%esp)
c0104aab:	e8 92 31 00 00       	call   c0107c42 <get_pte>
c0104ab0:	89 45 f0             	mov    %eax,-0x10(%ebp)
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
c0104ab3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ab6:	8b 00                	mov    (%eax),%eax
c0104ab8:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104abb:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104abf:	89 04 24             	mov    %eax,(%esp)
c0104ac2:	e8 2b 47 00 00       	call   c01091f2 <swapfs_read>
c0104ac7:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104aca:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104ace:	74 2a                	je     c0104afa <swap_in+0xa6>
     {
        assert(r!=0);
c0104ad0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104ad4:	75 24                	jne    c0104afa <swap_in+0xa6>
c0104ad6:	c7 44 24 0c f5 d1 10 	movl   $0xc010d1f5,0xc(%esp)
c0104add:	c0 
c0104ade:	c7 44 24 08 7a d1 10 	movl   $0xc010d17a,0x8(%esp)
c0104ae5:	c0 
c0104ae6:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
c0104aed:	00 
c0104aee:	c7 04 24 14 d1 10 c0 	movl   $0xc010d114,(%esp)
c0104af5:	e8 0b b9 ff ff       	call   c0100405 <__panic>
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
c0104afa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104afd:	8b 00                	mov    (%eax),%eax
c0104aff:	c1 e8 08             	shr    $0x8,%eax
c0104b02:	89 c2                	mov    %eax,%edx
c0104b04:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104b07:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104b0b:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104b0f:	c7 04 24 fc d1 10 c0 	movl   $0xc010d1fc,(%esp)
c0104b16:	e8 93 b7 ff ff       	call   c01002ae <cprintf>
     *ptr_result=result;
c0104b1b:	8b 45 10             	mov    0x10(%ebp),%eax
c0104b1e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104b21:	89 10                	mov    %edx,(%eax)
     return 0;
c0104b23:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104b28:	c9                   	leave  
c0104b29:	c3                   	ret    

c0104b2a <check_content_set>:



static inline void
check_content_set(void)
{
c0104b2a:	55                   	push   %ebp
c0104b2b:	89 e5                	mov    %esp,%ebp
c0104b2d:	83 ec 18             	sub    $0x18,%esp
     *(unsigned char *)0x1000 = 0x0a;
c0104b30:	b8 00 10 00 00       	mov    $0x1000,%eax
c0104b35:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0104b38:	a1 64 0f 1b c0       	mov    0xc01b0f64,%eax
c0104b3d:	83 f8 01             	cmp    $0x1,%eax
c0104b40:	74 24                	je     c0104b66 <check_content_set+0x3c>
c0104b42:	c7 44 24 0c 3a d2 10 	movl   $0xc010d23a,0xc(%esp)
c0104b49:	c0 
c0104b4a:	c7 44 24 08 7a d1 10 	movl   $0xc010d17a,0x8(%esp)
c0104b51:	c0 
c0104b52:	c7 44 24 04 92 00 00 	movl   $0x92,0x4(%esp)
c0104b59:	00 
c0104b5a:	c7 04 24 14 d1 10 c0 	movl   $0xc010d114,(%esp)
c0104b61:	e8 9f b8 ff ff       	call   c0100405 <__panic>
     *(unsigned char *)0x1010 = 0x0a;
c0104b66:	b8 10 10 00 00       	mov    $0x1010,%eax
c0104b6b:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0104b6e:	a1 64 0f 1b c0       	mov    0xc01b0f64,%eax
c0104b73:	83 f8 01             	cmp    $0x1,%eax
c0104b76:	74 24                	je     c0104b9c <check_content_set+0x72>
c0104b78:	c7 44 24 0c 3a d2 10 	movl   $0xc010d23a,0xc(%esp)
c0104b7f:	c0 
c0104b80:	c7 44 24 08 7a d1 10 	movl   $0xc010d17a,0x8(%esp)
c0104b87:	c0 
c0104b88:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
c0104b8f:	00 
c0104b90:	c7 04 24 14 d1 10 c0 	movl   $0xc010d114,(%esp)
c0104b97:	e8 69 b8 ff ff       	call   c0100405 <__panic>
     *(unsigned char *)0x2000 = 0x0b;
c0104b9c:	b8 00 20 00 00       	mov    $0x2000,%eax
c0104ba1:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0104ba4:	a1 64 0f 1b c0       	mov    0xc01b0f64,%eax
c0104ba9:	83 f8 02             	cmp    $0x2,%eax
c0104bac:	74 24                	je     c0104bd2 <check_content_set+0xa8>
c0104bae:	c7 44 24 0c 49 d2 10 	movl   $0xc010d249,0xc(%esp)
c0104bb5:	c0 
c0104bb6:	c7 44 24 08 7a d1 10 	movl   $0xc010d17a,0x8(%esp)
c0104bbd:	c0 
c0104bbe:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
c0104bc5:	00 
c0104bc6:	c7 04 24 14 d1 10 c0 	movl   $0xc010d114,(%esp)
c0104bcd:	e8 33 b8 ff ff       	call   c0100405 <__panic>
     *(unsigned char *)0x2010 = 0x0b;
c0104bd2:	b8 10 20 00 00       	mov    $0x2010,%eax
c0104bd7:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0104bda:	a1 64 0f 1b c0       	mov    0xc01b0f64,%eax
c0104bdf:	83 f8 02             	cmp    $0x2,%eax
c0104be2:	74 24                	je     c0104c08 <check_content_set+0xde>
c0104be4:	c7 44 24 0c 49 d2 10 	movl   $0xc010d249,0xc(%esp)
c0104beb:	c0 
c0104bec:	c7 44 24 08 7a d1 10 	movl   $0xc010d17a,0x8(%esp)
c0104bf3:	c0 
c0104bf4:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
c0104bfb:	00 
c0104bfc:	c7 04 24 14 d1 10 c0 	movl   $0xc010d114,(%esp)
c0104c03:	e8 fd b7 ff ff       	call   c0100405 <__panic>
     *(unsigned char *)0x3000 = 0x0c;
c0104c08:	b8 00 30 00 00       	mov    $0x3000,%eax
c0104c0d:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0104c10:	a1 64 0f 1b c0       	mov    0xc01b0f64,%eax
c0104c15:	83 f8 03             	cmp    $0x3,%eax
c0104c18:	74 24                	je     c0104c3e <check_content_set+0x114>
c0104c1a:	c7 44 24 0c 58 d2 10 	movl   $0xc010d258,0xc(%esp)
c0104c21:	c0 
c0104c22:	c7 44 24 08 7a d1 10 	movl   $0xc010d17a,0x8(%esp)
c0104c29:	c0 
c0104c2a:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
c0104c31:	00 
c0104c32:	c7 04 24 14 d1 10 c0 	movl   $0xc010d114,(%esp)
c0104c39:	e8 c7 b7 ff ff       	call   c0100405 <__panic>
     *(unsigned char *)0x3010 = 0x0c;
c0104c3e:	b8 10 30 00 00       	mov    $0x3010,%eax
c0104c43:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0104c46:	a1 64 0f 1b c0       	mov    0xc01b0f64,%eax
c0104c4b:	83 f8 03             	cmp    $0x3,%eax
c0104c4e:	74 24                	je     c0104c74 <check_content_set+0x14a>
c0104c50:	c7 44 24 0c 58 d2 10 	movl   $0xc010d258,0xc(%esp)
c0104c57:	c0 
c0104c58:	c7 44 24 08 7a d1 10 	movl   $0xc010d17a,0x8(%esp)
c0104c5f:	c0 
c0104c60:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c0104c67:	00 
c0104c68:	c7 04 24 14 d1 10 c0 	movl   $0xc010d114,(%esp)
c0104c6f:	e8 91 b7 ff ff       	call   c0100405 <__panic>
     *(unsigned char *)0x4000 = 0x0d;
c0104c74:	b8 00 40 00 00       	mov    $0x4000,%eax
c0104c79:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0104c7c:	a1 64 0f 1b c0       	mov    0xc01b0f64,%eax
c0104c81:	83 f8 04             	cmp    $0x4,%eax
c0104c84:	74 24                	je     c0104caa <check_content_set+0x180>
c0104c86:	c7 44 24 0c 67 d2 10 	movl   $0xc010d267,0xc(%esp)
c0104c8d:	c0 
c0104c8e:	c7 44 24 08 7a d1 10 	movl   $0xc010d17a,0x8(%esp)
c0104c95:	c0 
c0104c96:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
c0104c9d:	00 
c0104c9e:	c7 04 24 14 d1 10 c0 	movl   $0xc010d114,(%esp)
c0104ca5:	e8 5b b7 ff ff       	call   c0100405 <__panic>
     *(unsigned char *)0x4010 = 0x0d;
c0104caa:	b8 10 40 00 00       	mov    $0x4010,%eax
c0104caf:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0104cb2:	a1 64 0f 1b c0       	mov    0xc01b0f64,%eax
c0104cb7:	83 f8 04             	cmp    $0x4,%eax
c0104cba:	74 24                	je     c0104ce0 <check_content_set+0x1b6>
c0104cbc:	c7 44 24 0c 67 d2 10 	movl   $0xc010d267,0xc(%esp)
c0104cc3:	c0 
c0104cc4:	c7 44 24 08 7a d1 10 	movl   $0xc010d17a,0x8(%esp)
c0104ccb:	c0 
c0104ccc:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c0104cd3:	00 
c0104cd4:	c7 04 24 14 d1 10 c0 	movl   $0xc010d114,(%esp)
c0104cdb:	e8 25 b7 ff ff       	call   c0100405 <__panic>
}
c0104ce0:	90                   	nop
c0104ce1:	c9                   	leave  
c0104ce2:	c3                   	ret    

c0104ce3 <check_content_access>:

static inline int
check_content_access(void)
{
c0104ce3:	55                   	push   %ebp
c0104ce4:	89 e5                	mov    %esp,%ebp
c0104ce6:	83 ec 18             	sub    $0x18,%esp
    int ret = sm->check_swap();
c0104ce9:	a1 70 0f 1b c0       	mov    0xc01b0f70,%eax
c0104cee:	8b 40 1c             	mov    0x1c(%eax),%eax
c0104cf1:	ff d0                	call   *%eax
c0104cf3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ret;
c0104cf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104cf9:	c9                   	leave  
c0104cfa:	c3                   	ret    

c0104cfb <check_swap>:
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
check_swap(void)
{
c0104cfb:	55                   	push   %ebp
c0104cfc:	89 e5                	mov    %esp,%ebp
c0104cfe:	83 ec 78             	sub    $0x78,%esp
    //backup mem env
     int ret, count = 0, total = 0, i;
c0104d01:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104d08:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     list_entry_t *le = &free_list;
c0104d0f:	c7 45 e8 4c 31 1b c0 	movl   $0xc01b314c,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0104d16:	eb 6a                	jmp    c0104d82 <check_swap+0x87>
        struct Page *p = le2page(le, page_link);
c0104d18:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104d1b:	83 e8 0c             	sub    $0xc,%eax
c0104d1e:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(PageProperty(p));
c0104d21:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104d24:	83 c0 04             	add    $0x4,%eax
c0104d27:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
c0104d2e:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104d31:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0104d34:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0104d37:	0f a3 10             	bt     %edx,(%eax)
c0104d3a:	19 c0                	sbb    %eax,%eax
c0104d3c:	89 45 a8             	mov    %eax,-0x58(%ebp)
    return oldbit != 0;
c0104d3f:	83 7d a8 00          	cmpl   $0x0,-0x58(%ebp)
c0104d43:	0f 95 c0             	setne  %al
c0104d46:	0f b6 c0             	movzbl %al,%eax
c0104d49:	85 c0                	test   %eax,%eax
c0104d4b:	75 24                	jne    c0104d71 <check_swap+0x76>
c0104d4d:	c7 44 24 0c 76 d2 10 	movl   $0xc010d276,0xc(%esp)
c0104d54:	c0 
c0104d55:	c7 44 24 08 7a d1 10 	movl   $0xc010d17a,0x8(%esp)
c0104d5c:	c0 
c0104d5d:	c7 44 24 04 bb 00 00 	movl   $0xbb,0x4(%esp)
c0104d64:	00 
c0104d65:	c7 04 24 14 d1 10 c0 	movl   $0xc010d114,(%esp)
c0104d6c:	e8 94 b6 ff ff       	call   c0100405 <__panic>
        count ++, total += p->property;
c0104d71:	ff 45 f4             	incl   -0xc(%ebp)
c0104d74:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104d77:	8b 50 08             	mov    0x8(%eax),%edx
c0104d7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d7d:	01 d0                	add    %edx,%eax
c0104d7f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104d82:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104d85:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0104d88:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104d8b:	8b 40 04             	mov    0x4(%eax),%eax
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
c0104d8e:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104d91:	81 7d e8 4c 31 1b c0 	cmpl   $0xc01b314c,-0x18(%ebp)
c0104d98:	0f 85 7a ff ff ff    	jne    c0104d18 <check_swap+0x1d>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
     }
     assert(total == nr_free_pages());
c0104d9e:	e8 6b 28 00 00       	call   c010760e <nr_free_pages>
c0104da3:	89 c2                	mov    %eax,%edx
c0104da5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104da8:	39 c2                	cmp    %eax,%edx
c0104daa:	74 24                	je     c0104dd0 <check_swap+0xd5>
c0104dac:	c7 44 24 0c 86 d2 10 	movl   $0xc010d286,0xc(%esp)
c0104db3:	c0 
c0104db4:	c7 44 24 08 7a d1 10 	movl   $0xc010d17a,0x8(%esp)
c0104dbb:	c0 
c0104dbc:	c7 44 24 04 be 00 00 	movl   $0xbe,0x4(%esp)
c0104dc3:	00 
c0104dc4:	c7 04 24 14 d1 10 c0 	movl   $0xc010d114,(%esp)
c0104dcb:	e8 35 b6 ff ff       	call   c0100405 <__panic>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
c0104dd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104dd3:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104dd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104dda:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104dde:	c7 04 24 a0 d2 10 c0 	movl   $0xc010d2a0,(%esp)
c0104de5:	e8 c4 b4 ff ff       	call   c01002ae <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
c0104dea:	e8 70 e7 ff ff       	call   c010355f <mm_create>
c0104def:	89 45 d8             	mov    %eax,-0x28(%ebp)
     assert(mm != NULL);
c0104df2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0104df6:	75 24                	jne    c0104e1c <check_swap+0x121>
c0104df8:	c7 44 24 0c c6 d2 10 	movl   $0xc010d2c6,0xc(%esp)
c0104dff:	c0 
c0104e00:	c7 44 24 08 7a d1 10 	movl   $0xc010d17a,0x8(%esp)
c0104e07:	c0 
c0104e08:	c7 44 24 04 c3 00 00 	movl   $0xc3,0x4(%esp)
c0104e0f:	00 
c0104e10:	c7 04 24 14 d1 10 c0 	movl   $0xc010d114,(%esp)
c0104e17:	e8 e9 b5 ff ff       	call   c0100405 <__panic>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
c0104e1c:	a1 7c 30 1b c0       	mov    0xc01b307c,%eax
c0104e21:	85 c0                	test   %eax,%eax
c0104e23:	74 24                	je     c0104e49 <check_swap+0x14e>
c0104e25:	c7 44 24 0c d1 d2 10 	movl   $0xc010d2d1,0xc(%esp)
c0104e2c:	c0 
c0104e2d:	c7 44 24 08 7a d1 10 	movl   $0xc010d17a,0x8(%esp)
c0104e34:	c0 
c0104e35:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
c0104e3c:	00 
c0104e3d:	c7 04 24 14 d1 10 c0 	movl   $0xc010d114,(%esp)
c0104e44:	e8 bc b5 ff ff       	call   c0100405 <__panic>

     check_mm_struct = mm;
c0104e49:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104e4c:	a3 7c 30 1b c0       	mov    %eax,0xc01b307c

     pde_t *pgdir = mm->pgdir = boot_pgdir;
c0104e51:	8b 15 20 ca 12 c0    	mov    0xc012ca20,%edx
c0104e57:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104e5a:	89 50 0c             	mov    %edx,0xc(%eax)
c0104e5d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104e60:	8b 40 0c             	mov    0xc(%eax),%eax
c0104e63:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     assert(pgdir[0] == 0);
c0104e66:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104e69:	8b 00                	mov    (%eax),%eax
c0104e6b:	85 c0                	test   %eax,%eax
c0104e6d:	74 24                	je     c0104e93 <check_swap+0x198>
c0104e6f:	c7 44 24 0c e9 d2 10 	movl   $0xc010d2e9,0xc(%esp)
c0104e76:	c0 
c0104e77:	c7 44 24 08 7a d1 10 	movl   $0xc010d17a,0x8(%esp)
c0104e7e:	c0 
c0104e7f:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c0104e86:	00 
c0104e87:	c7 04 24 14 d1 10 c0 	movl   $0xc010d114,(%esp)
c0104e8e:	e8 72 b5 ff ff       	call   c0100405 <__panic>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
c0104e93:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
c0104e9a:	00 
c0104e9b:	c7 44 24 04 00 60 00 	movl   $0x6000,0x4(%esp)
c0104ea2:	00 
c0104ea3:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
c0104eaa:	e8 49 e7 ff ff       	call   c01035f8 <vma_create>
c0104eaf:	89 45 d0             	mov    %eax,-0x30(%ebp)
     assert(vma != NULL);
c0104eb2:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c0104eb6:	75 24                	jne    c0104edc <check_swap+0x1e1>
c0104eb8:	c7 44 24 0c f7 d2 10 	movl   $0xc010d2f7,0xc(%esp)
c0104ebf:	c0 
c0104ec0:	c7 44 24 08 7a d1 10 	movl   $0xc010d17a,0x8(%esp)
c0104ec7:	c0 
c0104ec8:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c0104ecf:	00 
c0104ed0:	c7 04 24 14 d1 10 c0 	movl   $0xc010d114,(%esp)
c0104ed7:	e8 29 b5 ff ff       	call   c0100405 <__panic>

     insert_vma_struct(mm, vma);
c0104edc:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104edf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104ee3:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104ee6:	89 04 24             	mov    %eax,(%esp)
c0104ee9:	e8 9b e8 ff ff       	call   c0103789 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
c0104eee:	c7 04 24 04 d3 10 c0 	movl   $0xc010d304,(%esp)
c0104ef5:	e8 b4 b3 ff ff       	call   c01002ae <cprintf>
     pte_t *temp_ptep=NULL;
c0104efa:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
c0104f01:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104f04:	8b 40 0c             	mov    0xc(%eax),%eax
c0104f07:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0104f0e:	00 
c0104f0f:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104f16:	00 
c0104f17:	89 04 24             	mov    %eax,(%esp)
c0104f1a:	e8 23 2d 00 00       	call   c0107c42 <get_pte>
c0104f1f:	89 45 cc             	mov    %eax,-0x34(%ebp)
     assert(temp_ptep!= NULL);
c0104f22:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0104f26:	75 24                	jne    c0104f4c <check_swap+0x251>
c0104f28:	c7 44 24 0c 38 d3 10 	movl   $0xc010d338,0xc(%esp)
c0104f2f:	c0 
c0104f30:	c7 44 24 08 7a d1 10 	movl   $0xc010d17a,0x8(%esp)
c0104f37:	c0 
c0104f38:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c0104f3f:	00 
c0104f40:	c7 04 24 14 d1 10 c0 	movl   $0xc010d114,(%esp)
c0104f47:	e8 b9 b4 ff ff       	call   c0100405 <__panic>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
c0104f4c:	c7 04 24 4c d3 10 c0 	movl   $0xc010d34c,(%esp)
c0104f53:	e8 56 b3 ff ff       	call   c01002ae <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0104f58:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0104f5f:	e9 a4 00 00 00       	jmp    c0105008 <check_swap+0x30d>
          check_rp[i] = alloc_page();
c0104f64:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104f6b:	e8 00 26 00 00       	call   c0107570 <alloc_pages>
c0104f70:	89 c2                	mov    %eax,%edx
c0104f72:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104f75:	89 14 85 80 30 1b c0 	mov    %edx,-0x3fe4cf80(,%eax,4)
          assert(check_rp[i] != NULL );
c0104f7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104f7f:	8b 04 85 80 30 1b c0 	mov    -0x3fe4cf80(,%eax,4),%eax
c0104f86:	85 c0                	test   %eax,%eax
c0104f88:	75 24                	jne    c0104fae <check_swap+0x2b3>
c0104f8a:	c7 44 24 0c 70 d3 10 	movl   $0xc010d370,0xc(%esp)
c0104f91:	c0 
c0104f92:	c7 44 24 08 7a d1 10 	movl   $0xc010d17a,0x8(%esp)
c0104f99:	c0 
c0104f9a:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c0104fa1:	00 
c0104fa2:	c7 04 24 14 d1 10 c0 	movl   $0xc010d114,(%esp)
c0104fa9:	e8 57 b4 ff ff       	call   c0100405 <__panic>
          assert(!PageProperty(check_rp[i]));
c0104fae:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104fb1:	8b 04 85 80 30 1b c0 	mov    -0x3fe4cf80(,%eax,4),%eax
c0104fb8:	83 c0 04             	add    $0x4,%eax
c0104fbb:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c0104fc2:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104fc5:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0104fc8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104fcb:	0f a3 10             	bt     %edx,(%eax)
c0104fce:	19 c0                	sbb    %eax,%eax
c0104fd0:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return oldbit != 0;
c0104fd3:	83 7d a0 00          	cmpl   $0x0,-0x60(%ebp)
c0104fd7:	0f 95 c0             	setne  %al
c0104fda:	0f b6 c0             	movzbl %al,%eax
c0104fdd:	85 c0                	test   %eax,%eax
c0104fdf:	74 24                	je     c0105005 <check_swap+0x30a>
c0104fe1:	c7 44 24 0c 84 d3 10 	movl   $0xc010d384,0xc(%esp)
c0104fe8:	c0 
c0104fe9:	c7 44 24 08 7a d1 10 	movl   $0xc010d17a,0x8(%esp)
c0104ff0:	c0 
c0104ff1:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c0104ff8:	00 
c0104ff9:	c7 04 24 14 d1 10 c0 	movl   $0xc010d114,(%esp)
c0105000:	e8 00 b4 ff ff       	call   c0100405 <__panic>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
     assert(temp_ptep!= NULL);
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105005:	ff 45 ec             	incl   -0x14(%ebp)
c0105008:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c010500c:	0f 8e 52 ff ff ff    	jle    c0104f64 <check_swap+0x269>
          check_rp[i] = alloc_page();
          assert(check_rp[i] != NULL );
          assert(!PageProperty(check_rp[i]));
     }
     list_entry_t free_list_store = free_list;
c0105012:	a1 4c 31 1b c0       	mov    0xc01b314c,%eax
c0105017:	8b 15 50 31 1b c0    	mov    0xc01b3150,%edx
c010501d:	89 45 98             	mov    %eax,-0x68(%ebp)
c0105020:	89 55 9c             	mov    %edx,-0x64(%ebp)
c0105023:	c7 45 c0 4c 31 1b c0 	movl   $0xc01b314c,-0x40(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010502a:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010502d:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0105030:	89 50 04             	mov    %edx,0x4(%eax)
c0105033:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0105036:	8b 50 04             	mov    0x4(%eax),%edx
c0105039:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010503c:	89 10                	mov    %edx,(%eax)
c010503e:	c7 45 c8 4c 31 1b c0 	movl   $0xc01b314c,-0x38(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0105045:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0105048:	8b 40 04             	mov    0x4(%eax),%eax
c010504b:	39 45 c8             	cmp    %eax,-0x38(%ebp)
c010504e:	0f 94 c0             	sete   %al
c0105051:	0f b6 c0             	movzbl %al,%eax
     list_init(&free_list);
     assert(list_empty(&free_list));
c0105054:	85 c0                	test   %eax,%eax
c0105056:	75 24                	jne    c010507c <check_swap+0x381>
c0105058:	c7 44 24 0c 9f d3 10 	movl   $0xc010d39f,0xc(%esp)
c010505f:	c0 
c0105060:	c7 44 24 08 7a d1 10 	movl   $0xc010d17a,0x8(%esp)
c0105067:	c0 
c0105068:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
c010506f:	00 
c0105070:	c7 04 24 14 d1 10 c0 	movl   $0xc010d114,(%esp)
c0105077:	e8 89 b3 ff ff       	call   c0100405 <__panic>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
c010507c:	a1 54 31 1b c0       	mov    0xc01b3154,%eax
c0105081:	89 45 bc             	mov    %eax,-0x44(%ebp)
     nr_free = 0;
c0105084:	c7 05 54 31 1b c0 00 	movl   $0x0,0xc01b3154
c010508b:	00 00 00 
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c010508e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0105095:	eb 1d                	jmp    c01050b4 <check_swap+0x3b9>
        free_pages(check_rp[i],1);
c0105097:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010509a:	8b 04 85 80 30 1b c0 	mov    -0x3fe4cf80(,%eax,4),%eax
c01050a1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01050a8:	00 
c01050a9:	89 04 24             	mov    %eax,(%esp)
c01050ac:	e8 2a 25 00 00       	call   c01075db <free_pages>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01050b1:	ff 45 ec             	incl   -0x14(%ebp)
c01050b4:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c01050b8:	7e dd                	jle    c0105097 <check_swap+0x39c>
        free_pages(check_rp[i],1);
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
c01050ba:	a1 54 31 1b c0       	mov    0xc01b3154,%eax
c01050bf:	83 f8 04             	cmp    $0x4,%eax
c01050c2:	74 24                	je     c01050e8 <check_swap+0x3ed>
c01050c4:	c7 44 24 0c b8 d3 10 	movl   $0xc010d3b8,0xc(%esp)
c01050cb:	c0 
c01050cc:	c7 44 24 08 7a d1 10 	movl   $0xc010d17a,0x8(%esp)
c01050d3:	c0 
c01050d4:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c01050db:	00 
c01050dc:	c7 04 24 14 d1 10 c0 	movl   $0xc010d114,(%esp)
c01050e3:	e8 1d b3 ff ff       	call   c0100405 <__panic>
     
     cprintf("set up init env for check_swap begin!\n");
c01050e8:	c7 04 24 dc d3 10 c0 	movl   $0xc010d3dc,(%esp)
c01050ef:	e8 ba b1 ff ff       	call   c01002ae <cprintf>
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
c01050f4:	c7 05 64 0f 1b c0 00 	movl   $0x0,0xc01b0f64
c01050fb:	00 00 00 
     
     check_content_set();
c01050fe:	e8 27 fa ff ff       	call   c0104b2a <check_content_set>
     assert( nr_free == 0);         
c0105103:	a1 54 31 1b c0       	mov    0xc01b3154,%eax
c0105108:	85 c0                	test   %eax,%eax
c010510a:	74 24                	je     c0105130 <check_swap+0x435>
c010510c:	c7 44 24 0c 03 d4 10 	movl   $0xc010d403,0xc(%esp)
c0105113:	c0 
c0105114:	c7 44 24 08 7a d1 10 	movl   $0xc010d17a,0x8(%esp)
c010511b:	c0 
c010511c:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
c0105123:	00 
c0105124:	c7 04 24 14 d1 10 c0 	movl   $0xc010d114,(%esp)
c010512b:	e8 d5 b2 ff ff       	call   c0100405 <__panic>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c0105130:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0105137:	eb 25                	jmp    c010515e <check_swap+0x463>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
c0105139:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010513c:	c7 04 85 a0 30 1b c0 	movl   $0xffffffff,-0x3fe4cf60(,%eax,4)
c0105143:	ff ff ff ff 
c0105147:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010514a:	8b 14 85 a0 30 1b c0 	mov    -0x3fe4cf60(,%eax,4),%edx
c0105151:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105154:	89 14 85 e0 30 1b c0 	mov    %edx,-0x3fe4cf20(,%eax,4)
     
     pgfault_num=0;
     
     check_content_set();
     assert( nr_free == 0);         
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c010515b:	ff 45 ec             	incl   -0x14(%ebp)
c010515e:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
c0105162:	7e d5                	jle    c0105139 <check_swap+0x43e>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105164:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c010516b:	e9 ec 00 00 00       	jmp    c010525c <check_swap+0x561>
         check_ptep[i]=0;
c0105170:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105173:	c7 04 85 34 31 1b c0 	movl   $0x0,-0x3fe4cecc(,%eax,4)
c010517a:	00 00 00 00 
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
c010517e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105181:	40                   	inc    %eax
c0105182:	c1 e0 0c             	shl    $0xc,%eax
c0105185:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010518c:	00 
c010518d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105191:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105194:	89 04 24             	mov    %eax,(%esp)
c0105197:	e8 a6 2a 00 00       	call   c0107c42 <get_pte>
c010519c:	89 c2                	mov    %eax,%edx
c010519e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01051a1:	89 14 85 34 31 1b c0 	mov    %edx,-0x3fe4cecc(,%eax,4)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
c01051a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01051ab:	8b 04 85 34 31 1b c0 	mov    -0x3fe4cecc(,%eax,4),%eax
c01051b2:	85 c0                	test   %eax,%eax
c01051b4:	75 24                	jne    c01051da <check_swap+0x4df>
c01051b6:	c7 44 24 0c 10 d4 10 	movl   $0xc010d410,0xc(%esp)
c01051bd:	c0 
c01051be:	c7 44 24 08 7a d1 10 	movl   $0xc010d17a,0x8(%esp)
c01051c5:	c0 
c01051c6:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c01051cd:	00 
c01051ce:	c7 04 24 14 d1 10 c0 	movl   $0xc010d114,(%esp)
c01051d5:	e8 2b b2 ff ff       	call   c0100405 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
c01051da:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01051dd:	8b 04 85 34 31 1b c0 	mov    -0x3fe4cecc(,%eax,4),%eax
c01051e4:	8b 00                	mov    (%eax),%eax
c01051e6:	89 04 24             	mov    %eax,(%esp)
c01051e9:	e8 8e f5 ff ff       	call   c010477c <pte2page>
c01051ee:	89 c2                	mov    %eax,%edx
c01051f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01051f3:	8b 04 85 80 30 1b c0 	mov    -0x3fe4cf80(,%eax,4),%eax
c01051fa:	39 c2                	cmp    %eax,%edx
c01051fc:	74 24                	je     c0105222 <check_swap+0x527>
c01051fe:	c7 44 24 0c 28 d4 10 	movl   $0xc010d428,0xc(%esp)
c0105205:	c0 
c0105206:	c7 44 24 08 7a d1 10 	movl   $0xc010d17a,0x8(%esp)
c010520d:	c0 
c010520e:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
c0105215:	00 
c0105216:	c7 04 24 14 d1 10 c0 	movl   $0xc010d114,(%esp)
c010521d:	e8 e3 b1 ff ff       	call   c0100405 <__panic>
         assert((*check_ptep[i] & PTE_P));          
c0105222:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105225:	8b 04 85 34 31 1b c0 	mov    -0x3fe4cecc(,%eax,4),%eax
c010522c:	8b 00                	mov    (%eax),%eax
c010522e:	83 e0 01             	and    $0x1,%eax
c0105231:	85 c0                	test   %eax,%eax
c0105233:	75 24                	jne    c0105259 <check_swap+0x55e>
c0105235:	c7 44 24 0c 50 d4 10 	movl   $0xc010d450,0xc(%esp)
c010523c:	c0 
c010523d:	c7 44 24 08 7a d1 10 	movl   $0xc010d17a,0x8(%esp)
c0105244:	c0 
c0105245:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
c010524c:	00 
c010524d:	c7 04 24 14 d1 10 c0 	movl   $0xc010d114,(%esp)
c0105254:	e8 ac b1 ff ff       	call   c0100405 <__panic>
     check_content_set();
     assert( nr_free == 0);         
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105259:	ff 45 ec             	incl   -0x14(%ebp)
c010525c:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0105260:	0f 8e 0a ff ff ff    	jle    c0105170 <check_swap+0x475>
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
         assert((*check_ptep[i] & PTE_P));          
     }
     cprintf("set up init env for check_swap over!\n");
c0105266:	c7 04 24 6c d4 10 c0 	movl   $0xc010d46c,(%esp)
c010526d:	e8 3c b0 ff ff       	call   c01002ae <cprintf>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
c0105272:	e8 6c fa ff ff       	call   c0104ce3 <check_content_access>
c0105277:	89 45 b8             	mov    %eax,-0x48(%ebp)
     assert(ret==0);
c010527a:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c010527e:	74 24                	je     c01052a4 <check_swap+0x5a9>
c0105280:	c7 44 24 0c 92 d4 10 	movl   $0xc010d492,0xc(%esp)
c0105287:	c0 
c0105288:	c7 44 24 08 7a d1 10 	movl   $0xc010d17a,0x8(%esp)
c010528f:	c0 
c0105290:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
c0105297:	00 
c0105298:	c7 04 24 14 d1 10 c0 	movl   $0xc010d114,(%esp)
c010529f:	e8 61 b1 ff ff       	call   c0100405 <__panic>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01052a4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01052ab:	eb 1d                	jmp    c01052ca <check_swap+0x5cf>
         free_pages(check_rp[i],1);
c01052ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01052b0:	8b 04 85 80 30 1b c0 	mov    -0x3fe4cf80(,%eax,4),%eax
c01052b7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01052be:	00 
c01052bf:	89 04 24             	mov    %eax,(%esp)
c01052c2:	e8 14 23 00 00       	call   c01075db <free_pages>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01052c7:	ff 45 ec             	incl   -0x14(%ebp)
c01052ca:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c01052ce:	7e dd                	jle    c01052ad <check_swap+0x5b2>
         free_pages(check_rp[i],1);
     } 

     //free_page(pte2page(*temp_ptep));
    free_page(pde2page(pgdir[0]));
c01052d0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01052d3:	8b 00                	mov    (%eax),%eax
c01052d5:	89 04 24             	mov    %eax,(%esp)
c01052d8:	e8 dd f4 ff ff       	call   c01047ba <pde2page>
c01052dd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01052e4:	00 
c01052e5:	89 04 24             	mov    %eax,(%esp)
c01052e8:	e8 ee 22 00 00       	call   c01075db <free_pages>
     pgdir[0] = 0;
c01052ed:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01052f0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
     mm->pgdir = NULL;
c01052f6:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01052f9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
     mm_destroy(mm);
c0105300:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105303:	89 04 24             	mov    %eax,(%esp)
c0105306:	e8 b0 e5 ff ff       	call   c01038bb <mm_destroy>
     check_mm_struct = NULL;
c010530b:	c7 05 7c 30 1b c0 00 	movl   $0x0,0xc01b307c
c0105312:	00 00 00 
     
     nr_free = nr_free_store;
c0105315:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0105318:	a3 54 31 1b c0       	mov    %eax,0xc01b3154
     free_list = free_list_store;
c010531d:	8b 45 98             	mov    -0x68(%ebp),%eax
c0105320:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0105323:	a3 4c 31 1b c0       	mov    %eax,0xc01b314c
c0105328:	89 15 50 31 1b c0    	mov    %edx,0xc01b3150

     
     le = &free_list;
c010532e:	c7 45 e8 4c 31 1b c0 	movl   $0xc01b314c,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0105335:	eb 1c                	jmp    c0105353 <check_swap+0x658>
         struct Page *p = le2page(le, page_link);
c0105337:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010533a:	83 e8 0c             	sub    $0xc,%eax
c010533d:	89 45 b4             	mov    %eax,-0x4c(%ebp)
         count --, total -= p->property;
c0105340:	ff 4d f4             	decl   -0xc(%ebp)
c0105343:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105346:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0105349:	8b 40 08             	mov    0x8(%eax),%eax
c010534c:	29 c2                	sub    %eax,%edx
c010534e:	89 d0                	mov    %edx,%eax
c0105350:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105353:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105356:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0105359:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010535c:	8b 40 04             	mov    0x4(%eax),%eax
     nr_free = nr_free_store;
     free_list = free_list_store;

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
c010535f:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105362:	81 7d e8 4c 31 1b c0 	cmpl   $0xc01b314c,-0x18(%ebp)
c0105369:	75 cc                	jne    c0105337 <check_swap+0x63c>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
     }
     cprintf("count is %d, total is %d\n",count,total);
c010536b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010536e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105372:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105375:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105379:	c7 04 24 99 d4 10 c0 	movl   $0xc010d499,(%esp)
c0105380:	e8 29 af ff ff       	call   c01002ae <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
c0105385:	c7 04 24 b3 d4 10 c0 	movl   $0xc010d4b3,(%esp)
c010538c:	e8 1d af ff ff       	call   c01002ae <cprintf>
}
c0105391:	90                   	nop
c0105392:	c9                   	leave  
c0105393:	c3                   	ret    

c0105394 <__intr_save>:
#include <assert.h>
#include <atomic.h>
#include <sched.h>

static inline bool
__intr_save(void) {
c0105394:	55                   	push   %ebp
c0105395:	89 e5                	mov    %esp,%ebp
c0105397:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010539a:	9c                   	pushf  
c010539b:	58                   	pop    %eax
c010539c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c010539f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01053a2:	25 00 02 00 00       	and    $0x200,%eax
c01053a7:	85 c0                	test   %eax,%eax
c01053a9:	74 0c                	je     c01053b7 <__intr_save+0x23>
        intr_disable();
c01053ab:	e8 45 ce ff ff       	call   c01021f5 <intr_disable>
        return 1;
c01053b0:	b8 01 00 00 00       	mov    $0x1,%eax
c01053b5:	eb 05                	jmp    c01053bc <__intr_save+0x28>
    }
    return 0;
c01053b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01053bc:	c9                   	leave  
c01053bd:	c3                   	ret    

c01053be <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c01053be:	55                   	push   %ebp
c01053bf:	89 e5                	mov    %esp,%ebp
c01053c1:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01053c4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01053c8:	74 05                	je     c01053cf <__intr_restore+0x11>
        intr_enable();
c01053ca:	e8 1f ce ff ff       	call   c01021ee <intr_enable>
    }
}
c01053cf:	90                   	nop
c01053d0:	c9                   	leave  
c01053d1:	c3                   	ret    

c01053d2 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c01053d2:	55                   	push   %ebp
c01053d3:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01053d5:	8b 45 08             	mov    0x8(%ebp),%eax
c01053d8:	8b 15 60 31 1b c0    	mov    0xc01b3160,%edx
c01053de:	29 d0                	sub    %edx,%eax
c01053e0:	c1 f8 05             	sar    $0x5,%eax
}
c01053e3:	5d                   	pop    %ebp
c01053e4:	c3                   	ret    

c01053e5 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c01053e5:	55                   	push   %ebp
c01053e6:	89 e5                	mov    %esp,%ebp
c01053e8:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01053eb:	8b 45 08             	mov    0x8(%ebp),%eax
c01053ee:	89 04 24             	mov    %eax,(%esp)
c01053f1:	e8 dc ff ff ff       	call   c01053d2 <page2ppn>
c01053f6:	c1 e0 0c             	shl    $0xc,%eax
}
c01053f9:	c9                   	leave  
c01053fa:	c3                   	ret    

c01053fb <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c01053fb:	55                   	push   %ebp
c01053fc:	89 e5                	mov    %esp,%ebp
c01053fe:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0105401:	8b 45 08             	mov    0x8(%ebp),%eax
c0105404:	c1 e8 0c             	shr    $0xc,%eax
c0105407:	89 c2                	mov    %eax,%edx
c0105409:	a1 80 0f 1b c0       	mov    0xc01b0f80,%eax
c010540e:	39 c2                	cmp    %eax,%edx
c0105410:	72 1c                	jb     c010542e <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0105412:	c7 44 24 08 cc d4 10 	movl   $0xc010d4cc,0x8(%esp)
c0105419:	c0 
c010541a:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0105421:	00 
c0105422:	c7 04 24 eb d4 10 c0 	movl   $0xc010d4eb,(%esp)
c0105429:	e8 d7 af ff ff       	call   c0100405 <__panic>
    }
    return &pages[PPN(pa)];
c010542e:	a1 60 31 1b c0       	mov    0xc01b3160,%eax
c0105433:	8b 55 08             	mov    0x8(%ebp),%edx
c0105436:	c1 ea 0c             	shr    $0xc,%edx
c0105439:	c1 e2 05             	shl    $0x5,%edx
c010543c:	01 d0                	add    %edx,%eax
}
c010543e:	c9                   	leave  
c010543f:	c3                   	ret    

c0105440 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0105440:	55                   	push   %ebp
c0105441:	89 e5                	mov    %esp,%ebp
c0105443:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0105446:	8b 45 08             	mov    0x8(%ebp),%eax
c0105449:	89 04 24             	mov    %eax,(%esp)
c010544c:	e8 94 ff ff ff       	call   c01053e5 <page2pa>
c0105451:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105454:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105457:	c1 e8 0c             	shr    $0xc,%eax
c010545a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010545d:	a1 80 0f 1b c0       	mov    0xc01b0f80,%eax
c0105462:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0105465:	72 23                	jb     c010548a <page2kva+0x4a>
c0105467:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010546a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010546e:	c7 44 24 08 fc d4 10 	movl   $0xc010d4fc,0x8(%esp)
c0105475:	c0 
c0105476:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c010547d:	00 
c010547e:	c7 04 24 eb d4 10 c0 	movl   $0xc010d4eb,(%esp)
c0105485:	e8 7b af ff ff       	call   c0100405 <__panic>
c010548a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010548d:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0105492:	c9                   	leave  
c0105493:	c3                   	ret    

c0105494 <kva2page>:

static inline struct Page *
kva2page(void *kva) {
c0105494:	55                   	push   %ebp
c0105495:	89 e5                	mov    %esp,%ebp
c0105497:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c010549a:	8b 45 08             	mov    0x8(%ebp),%eax
c010549d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01054a0:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01054a7:	77 23                	ja     c01054cc <kva2page+0x38>
c01054a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01054ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01054b0:	c7 44 24 08 20 d5 10 	movl   $0xc010d520,0x8(%esp)
c01054b7:	c0 
c01054b8:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
c01054bf:	00 
c01054c0:	c7 04 24 eb d4 10 c0 	movl   $0xc010d4eb,(%esp)
c01054c7:	e8 39 af ff ff       	call   c0100405 <__panic>
c01054cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01054cf:	05 00 00 00 40       	add    $0x40000000,%eax
c01054d4:	89 04 24             	mov    %eax,(%esp)
c01054d7:	e8 1f ff ff ff       	call   c01053fb <pa2page>
}
c01054dc:	c9                   	leave  
c01054dd:	c3                   	ret    

c01054de <__slob_get_free_pages>:
static slob_t *slobfree = &arena;
static bigblock_t *bigblocks;


static void* __slob_get_free_pages(gfp_t gfp, int order)
{
c01054de:	55                   	push   %ebp
c01054df:	89 e5                	mov    %esp,%ebp
c01054e1:	83 ec 28             	sub    $0x28,%esp
  struct Page * page = alloc_pages(1 << order);
c01054e4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01054e7:	ba 01 00 00 00       	mov    $0x1,%edx
c01054ec:	88 c1                	mov    %al,%cl
c01054ee:	d3 e2                	shl    %cl,%edx
c01054f0:	89 d0                	mov    %edx,%eax
c01054f2:	89 04 24             	mov    %eax,(%esp)
c01054f5:	e8 76 20 00 00       	call   c0107570 <alloc_pages>
c01054fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!page)
c01054fd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105501:	75 07                	jne    c010550a <__slob_get_free_pages+0x2c>
    return NULL;
c0105503:	b8 00 00 00 00       	mov    $0x0,%eax
c0105508:	eb 0b                	jmp    c0105515 <__slob_get_free_pages+0x37>
  return page2kva(page);
c010550a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010550d:	89 04 24             	mov    %eax,(%esp)
c0105510:	e8 2b ff ff ff       	call   c0105440 <page2kva>
}
c0105515:	c9                   	leave  
c0105516:	c3                   	ret    

c0105517 <__slob_free_pages>:

#define __slob_get_free_page(gfp) __slob_get_free_pages(gfp, 0)

static inline void __slob_free_pages(unsigned long kva, int order)
{
c0105517:	55                   	push   %ebp
c0105518:	89 e5                	mov    %esp,%ebp
c010551a:	53                   	push   %ebx
c010551b:	83 ec 14             	sub    $0x14,%esp
  free_pages(kva2page(kva), 1 << order);
c010551e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105521:	ba 01 00 00 00       	mov    $0x1,%edx
c0105526:	88 c1                	mov    %al,%cl
c0105528:	d3 e2                	shl    %cl,%edx
c010552a:	89 d0                	mov    %edx,%eax
c010552c:	89 c3                	mov    %eax,%ebx
c010552e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105531:	89 04 24             	mov    %eax,(%esp)
c0105534:	e8 5b ff ff ff       	call   c0105494 <kva2page>
c0105539:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c010553d:	89 04 24             	mov    %eax,(%esp)
c0105540:	e8 96 20 00 00       	call   c01075db <free_pages>
}
c0105545:	90                   	nop
c0105546:	83 c4 14             	add    $0x14,%esp
c0105549:	5b                   	pop    %ebx
c010554a:	5d                   	pop    %ebp
c010554b:	c3                   	ret    

c010554c <slob_alloc>:

static void slob_free(void *b, int size);

static void *slob_alloc(size_t size, gfp_t gfp, int align)
{
c010554c:	55                   	push   %ebp
c010554d:	89 e5                	mov    %esp,%ebp
c010554f:	83 ec 38             	sub    $0x38,%esp
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
c0105552:	8b 45 08             	mov    0x8(%ebp),%eax
c0105555:	83 c0 08             	add    $0x8,%eax
c0105558:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c010555d:	76 24                	jbe    c0105583 <slob_alloc+0x37>
c010555f:	c7 44 24 0c 44 d5 10 	movl   $0xc010d544,0xc(%esp)
c0105566:	c0 
c0105567:	c7 44 24 08 63 d5 10 	movl   $0xc010d563,0x8(%esp)
c010556e:	c0 
c010556f:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0105576:	00 
c0105577:	c7 04 24 78 d5 10 c0 	movl   $0xc010d578,(%esp)
c010557e:	e8 82 ae ff ff       	call   c0100405 <__panic>

	slob_t *prev, *cur, *aligned = 0;
c0105583:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	int delta = 0, units = SLOB_UNITS(size);
c010558a:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0105591:	8b 45 08             	mov    0x8(%ebp),%eax
c0105594:	83 c0 07             	add    $0x7,%eax
c0105597:	c1 e8 03             	shr    $0x3,%eax
c010559a:	89 45 e0             	mov    %eax,-0x20(%ebp)
	unsigned long flags;

	spin_lock_irqsave(&slob_lock, flags);
c010559d:	e8 f2 fd ff ff       	call   c0105394 <__intr_save>
c01055a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	prev = slobfree;
c01055a5:	a1 e8 c9 12 c0       	mov    0xc012c9e8,%eax
c01055aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c01055ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01055b0:	8b 40 04             	mov    0x4(%eax),%eax
c01055b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (align) {
c01055b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01055ba:	74 25                	je     c01055e1 <slob_alloc+0x95>
			aligned = (slob_t *)ALIGN((unsigned long)cur, align);
c01055bc:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01055bf:	8b 45 10             	mov    0x10(%ebp),%eax
c01055c2:	01 d0                	add    %edx,%eax
c01055c4:	8d 50 ff             	lea    -0x1(%eax),%edx
c01055c7:	8b 45 10             	mov    0x10(%ebp),%eax
c01055ca:	f7 d8                	neg    %eax
c01055cc:	21 d0                	and    %edx,%eax
c01055ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
			delta = aligned - cur;
c01055d1:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01055d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01055d7:	29 c2                	sub    %eax,%edx
c01055d9:	89 d0                	mov    %edx,%eax
c01055db:	c1 f8 03             	sar    $0x3,%eax
c01055de:	89 45 e8             	mov    %eax,-0x18(%ebp)
		}
		if (cur->units >= units + delta) { /* room enough? */
c01055e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01055e4:	8b 00                	mov    (%eax),%eax
c01055e6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c01055e9:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01055ec:	01 ca                	add    %ecx,%edx
c01055ee:	39 d0                	cmp    %edx,%eax
c01055f0:	0f 8c aa 00 00 00    	jl     c01056a0 <slob_alloc+0x154>
			if (delta) { /* need to fragment head to align? */
c01055f6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01055fa:	74 38                	je     c0105634 <slob_alloc+0xe8>
				aligned->units = cur->units - delta;
c01055fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01055ff:	8b 00                	mov    (%eax),%eax
c0105601:	2b 45 e8             	sub    -0x18(%ebp),%eax
c0105604:	89 c2                	mov    %eax,%edx
c0105606:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105609:	89 10                	mov    %edx,(%eax)
				aligned->next = cur->next;
c010560b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010560e:	8b 50 04             	mov    0x4(%eax),%edx
c0105611:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105614:	89 50 04             	mov    %edx,0x4(%eax)
				cur->next = aligned;
c0105617:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010561a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010561d:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = delta;
c0105620:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105623:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0105626:	89 10                	mov    %edx,(%eax)
				prev = cur;
c0105628:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010562b:	89 45 f4             	mov    %eax,-0xc(%ebp)
				cur = aligned;
c010562e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105631:	89 45 f0             	mov    %eax,-0x10(%ebp)
			}

			if (cur->units == units) /* exact fit? */
c0105634:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105637:	8b 00                	mov    (%eax),%eax
c0105639:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c010563c:	75 0e                	jne    c010564c <slob_alloc+0x100>
				prev->next = cur->next; /* unlink */
c010563e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105641:	8b 50 04             	mov    0x4(%eax),%edx
c0105644:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105647:	89 50 04             	mov    %edx,0x4(%eax)
c010564a:	eb 3c                	jmp    c0105688 <slob_alloc+0x13c>
			else { /* fragment */
				prev->next = cur + units;
c010564c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010564f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0105656:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105659:	01 c2                	add    %eax,%edx
c010565b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010565e:	89 50 04             	mov    %edx,0x4(%eax)
				prev->next->units = cur->units - units;
c0105661:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105664:	8b 40 04             	mov    0x4(%eax),%eax
c0105667:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010566a:	8b 12                	mov    (%edx),%edx
c010566c:	2b 55 e0             	sub    -0x20(%ebp),%edx
c010566f:	89 10                	mov    %edx,(%eax)
				prev->next->next = cur->next;
c0105671:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105674:	8b 40 04             	mov    0x4(%eax),%eax
c0105677:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010567a:	8b 52 04             	mov    0x4(%edx),%edx
c010567d:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = units;
c0105680:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105683:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105686:	89 10                	mov    %edx,(%eax)
			}

			slobfree = prev;
c0105688:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010568b:	a3 e8 c9 12 c0       	mov    %eax,0xc012c9e8
			spin_unlock_irqrestore(&slob_lock, flags);
c0105690:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105693:	89 04 24             	mov    %eax,(%esp)
c0105696:	e8 23 fd ff ff       	call   c01053be <__intr_restore>
			return cur;
c010569b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010569e:	eb 7f                	jmp    c010571f <slob_alloc+0x1d3>
		}
		if (cur == slobfree) {
c01056a0:	a1 e8 c9 12 c0       	mov    0xc012c9e8,%eax
c01056a5:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01056a8:	75 61                	jne    c010570b <slob_alloc+0x1bf>
			spin_unlock_irqrestore(&slob_lock, flags);
c01056aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01056ad:	89 04 24             	mov    %eax,(%esp)
c01056b0:	e8 09 fd ff ff       	call   c01053be <__intr_restore>

			if (size == PAGE_SIZE) /* trying to shrink arena? */
c01056b5:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c01056bc:	75 07                	jne    c01056c5 <slob_alloc+0x179>
				return 0;
c01056be:	b8 00 00 00 00       	mov    $0x0,%eax
c01056c3:	eb 5a                	jmp    c010571f <slob_alloc+0x1d3>

			cur = (slob_t *)__slob_get_free_page(gfp);
c01056c5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01056cc:	00 
c01056cd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01056d0:	89 04 24             	mov    %eax,(%esp)
c01056d3:	e8 06 fe ff ff       	call   c01054de <__slob_get_free_pages>
c01056d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
			if (!cur)
c01056db:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01056df:	75 07                	jne    c01056e8 <slob_alloc+0x19c>
				return 0;
c01056e1:	b8 00 00 00 00       	mov    $0x0,%eax
c01056e6:	eb 37                	jmp    c010571f <slob_alloc+0x1d3>

			slob_free(cur, PAGE_SIZE);
c01056e8:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01056ef:	00 
c01056f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01056f3:	89 04 24             	mov    %eax,(%esp)
c01056f6:	e8 26 00 00 00       	call   c0105721 <slob_free>
			spin_lock_irqsave(&slob_lock, flags);
c01056fb:	e8 94 fc ff ff       	call   c0105394 <__intr_save>
c0105700:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			cur = slobfree;
c0105703:	a1 e8 c9 12 c0       	mov    0xc012c9e8,%eax
c0105708:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int delta = 0, units = SLOB_UNITS(size);
	unsigned long flags;

	spin_lock_irqsave(&slob_lock, flags);
	prev = slobfree;
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c010570b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010570e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105711:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105714:	8b 40 04             	mov    0x4(%eax),%eax
c0105717:	89 45 f0             	mov    %eax,-0x10(%ebp)

			slob_free(cur, PAGE_SIZE);
			spin_lock_irqsave(&slob_lock, flags);
			cur = slobfree;
		}
	}
c010571a:	e9 97 fe ff ff       	jmp    c01055b6 <slob_alloc+0x6a>
}
c010571f:	c9                   	leave  
c0105720:	c3                   	ret    

c0105721 <slob_free>:

static void slob_free(void *block, int size)
{
c0105721:	55                   	push   %ebp
c0105722:	89 e5                	mov    %esp,%ebp
c0105724:	83 ec 28             	sub    $0x28,%esp
	slob_t *cur, *b = (slob_t *)block;
c0105727:	8b 45 08             	mov    0x8(%ebp),%eax
c010572a:	89 45 f0             	mov    %eax,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c010572d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105731:	0f 84 01 01 00 00    	je     c0105838 <slob_free+0x117>
		return;

	if (size)
c0105737:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010573b:	74 10                	je     c010574d <slob_free+0x2c>
		b->units = SLOB_UNITS(size);
c010573d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105740:	83 c0 07             	add    $0x7,%eax
c0105743:	c1 e8 03             	shr    $0x3,%eax
c0105746:	89 c2                	mov    %eax,%edx
c0105748:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010574b:	89 10                	mov    %edx,(%eax)

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
c010574d:	e8 42 fc ff ff       	call   c0105394 <__intr_save>
c0105752:	89 45 ec             	mov    %eax,-0x14(%ebp)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c0105755:	a1 e8 c9 12 c0       	mov    0xc012c9e8,%eax
c010575a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010575d:	eb 27                	jmp    c0105786 <slob_free+0x65>
		if (cur >= cur->next && (b > cur || b < cur->next))
c010575f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105762:	8b 40 04             	mov    0x4(%eax),%eax
c0105765:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0105768:	77 13                	ja     c010577d <slob_free+0x5c>
c010576a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010576d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0105770:	77 27                	ja     c0105799 <slob_free+0x78>
c0105772:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105775:	8b 40 04             	mov    0x4(%eax),%eax
c0105778:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010577b:	77 1c                	ja     c0105799 <slob_free+0x78>
	if (size)
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c010577d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105780:	8b 40 04             	mov    0x4(%eax),%eax
c0105783:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105786:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105789:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010578c:	76 d1                	jbe    c010575f <slob_free+0x3e>
c010578e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105791:	8b 40 04             	mov    0x4(%eax),%eax
c0105794:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0105797:	76 c6                	jbe    c010575f <slob_free+0x3e>
		if (cur >= cur->next && (b > cur || b < cur->next))
			break;

	if (b + b->units == cur->next) {
c0105799:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010579c:	8b 00                	mov    (%eax),%eax
c010579e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01057a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01057a8:	01 c2                	add    %eax,%edx
c01057aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01057ad:	8b 40 04             	mov    0x4(%eax),%eax
c01057b0:	39 c2                	cmp    %eax,%edx
c01057b2:	75 25                	jne    c01057d9 <slob_free+0xb8>
		b->units += cur->next->units;
c01057b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01057b7:	8b 10                	mov    (%eax),%edx
c01057b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01057bc:	8b 40 04             	mov    0x4(%eax),%eax
c01057bf:	8b 00                	mov    (%eax),%eax
c01057c1:	01 c2                	add    %eax,%edx
c01057c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01057c6:	89 10                	mov    %edx,(%eax)
		b->next = cur->next->next;
c01057c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01057cb:	8b 40 04             	mov    0x4(%eax),%eax
c01057ce:	8b 50 04             	mov    0x4(%eax),%edx
c01057d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01057d4:	89 50 04             	mov    %edx,0x4(%eax)
c01057d7:	eb 0c                	jmp    c01057e5 <slob_free+0xc4>
	} else
		b->next = cur->next;
c01057d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01057dc:	8b 50 04             	mov    0x4(%eax),%edx
c01057df:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01057e2:	89 50 04             	mov    %edx,0x4(%eax)

	if (cur + cur->units == b) {
c01057e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01057e8:	8b 00                	mov    (%eax),%eax
c01057ea:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01057f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01057f4:	01 d0                	add    %edx,%eax
c01057f6:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01057f9:	75 1f                	jne    c010581a <slob_free+0xf9>
		cur->units += b->units;
c01057fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01057fe:	8b 10                	mov    (%eax),%edx
c0105800:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105803:	8b 00                	mov    (%eax),%eax
c0105805:	01 c2                	add    %eax,%edx
c0105807:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010580a:	89 10                	mov    %edx,(%eax)
		cur->next = b->next;
c010580c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010580f:	8b 50 04             	mov    0x4(%eax),%edx
c0105812:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105815:	89 50 04             	mov    %edx,0x4(%eax)
c0105818:	eb 09                	jmp    c0105823 <slob_free+0x102>
	} else
		cur->next = b;
c010581a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010581d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105820:	89 50 04             	mov    %edx,0x4(%eax)

	slobfree = cur;
c0105823:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105826:	a3 e8 c9 12 c0       	mov    %eax,0xc012c9e8

	spin_unlock_irqrestore(&slob_lock, flags);
c010582b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010582e:	89 04 24             	mov    %eax,(%esp)
c0105831:	e8 88 fb ff ff       	call   c01053be <__intr_restore>
c0105836:	eb 01                	jmp    c0105839 <slob_free+0x118>
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
		return;
c0105838:	90                   	nop
		cur->next = b;

	slobfree = cur;

	spin_unlock_irqrestore(&slob_lock, flags);
}
c0105839:	c9                   	leave  
c010583a:	c3                   	ret    

c010583b <slob_init>:



void
slob_init(void) {
c010583b:	55                   	push   %ebp
c010583c:	89 e5                	mov    %esp,%ebp
c010583e:	83 ec 18             	sub    $0x18,%esp
  cprintf("use SLOB allocator\n");
c0105841:	c7 04 24 8a d5 10 c0 	movl   $0xc010d58a,(%esp)
c0105848:	e8 61 aa ff ff       	call   c01002ae <cprintf>
}
c010584d:	90                   	nop
c010584e:	c9                   	leave  
c010584f:	c3                   	ret    

c0105850 <kmalloc_init>:

inline void 
kmalloc_init(void) {
c0105850:	55                   	push   %ebp
c0105851:	89 e5                	mov    %esp,%ebp
c0105853:	83 ec 18             	sub    $0x18,%esp
    slob_init();
c0105856:	e8 e0 ff ff ff       	call   c010583b <slob_init>
    cprintf("kmalloc_init() succeeded!\n");
c010585b:	c7 04 24 9e d5 10 c0 	movl   $0xc010d59e,(%esp)
c0105862:	e8 47 aa ff ff       	call   c01002ae <cprintf>
}
c0105867:	90                   	nop
c0105868:	c9                   	leave  
c0105869:	c3                   	ret    

c010586a <slob_allocated>:

size_t
slob_allocated(void) {
c010586a:	55                   	push   %ebp
c010586b:	89 e5                	mov    %esp,%ebp
  return 0;
c010586d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105872:	5d                   	pop    %ebp
c0105873:	c3                   	ret    

c0105874 <kallocated>:

size_t
kallocated(void) {
c0105874:	55                   	push   %ebp
c0105875:	89 e5                	mov    %esp,%ebp
   return slob_allocated();
c0105877:	e8 ee ff ff ff       	call   c010586a <slob_allocated>
}
c010587c:	5d                   	pop    %ebp
c010587d:	c3                   	ret    

c010587e <find_order>:

static int find_order(int size)
{
c010587e:	55                   	push   %ebp
c010587f:	89 e5                	mov    %esp,%ebp
c0105881:	83 ec 10             	sub    $0x10,%esp
	int order = 0;
c0105884:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	for ( ; size > 4096 ; size >>=1)
c010588b:	eb 06                	jmp    c0105893 <find_order+0x15>
		order++;
c010588d:	ff 45 fc             	incl   -0x4(%ebp)
}

static int find_order(int size)
{
	int order = 0;
	for ( ; size > 4096 ; size >>=1)
c0105890:	d1 7d 08             	sarl   0x8(%ebp)
c0105893:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c010589a:	7f f1                	jg     c010588d <find_order+0xf>
		order++;
	return order;
c010589c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010589f:	c9                   	leave  
c01058a0:	c3                   	ret    

c01058a1 <__kmalloc>:

static void *__kmalloc(size_t size, gfp_t gfp)
{
c01058a1:	55                   	push   %ebp
c01058a2:	89 e5                	mov    %esp,%ebp
c01058a4:	83 ec 28             	sub    $0x28,%esp
	slob_t *m;
	bigblock_t *bb;
	unsigned long flags;

	if (size < PAGE_SIZE - SLOB_UNIT) {
c01058a7:	81 7d 08 f7 0f 00 00 	cmpl   $0xff7,0x8(%ebp)
c01058ae:	77 3b                	ja     c01058eb <__kmalloc+0x4a>
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
c01058b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01058b3:	8d 50 08             	lea    0x8(%eax),%edx
c01058b6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01058bd:	00 
c01058be:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058c1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01058c5:	89 14 24             	mov    %edx,(%esp)
c01058c8:	e8 7f fc ff ff       	call   c010554c <slob_alloc>
c01058cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
		return m ? (void *)(m + 1) : 0;
c01058d0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01058d4:	74 0b                	je     c01058e1 <__kmalloc+0x40>
c01058d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01058d9:	83 c0 08             	add    $0x8,%eax
c01058dc:	e9 b4 00 00 00       	jmp    c0105995 <__kmalloc+0xf4>
c01058e1:	b8 00 00 00 00       	mov    $0x0,%eax
c01058e6:	e9 aa 00 00 00       	jmp    c0105995 <__kmalloc+0xf4>
	}

	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
c01058eb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01058f2:	00 
c01058f3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058f6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01058fa:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
c0105901:	e8 46 fc ff ff       	call   c010554c <slob_alloc>
c0105906:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (!bb)
c0105909:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010590d:	75 07                	jne    c0105916 <__kmalloc+0x75>
		return 0;
c010590f:	b8 00 00 00 00       	mov    $0x0,%eax
c0105914:	eb 7f                	jmp    c0105995 <__kmalloc+0xf4>

	bb->order = find_order(size);
c0105916:	8b 45 08             	mov    0x8(%ebp),%eax
c0105919:	89 04 24             	mov    %eax,(%esp)
c010591c:	e8 5d ff ff ff       	call   c010587e <find_order>
c0105921:	89 c2                	mov    %eax,%edx
c0105923:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105926:	89 10                	mov    %edx,(%eax)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
c0105928:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010592b:	8b 00                	mov    (%eax),%eax
c010592d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105931:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105934:	89 04 24             	mov    %eax,(%esp)
c0105937:	e8 a2 fb ff ff       	call   c01054de <__slob_get_free_pages>
c010593c:	89 c2                	mov    %eax,%edx
c010593e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105941:	89 50 04             	mov    %edx,0x4(%eax)

	if (bb->pages) {
c0105944:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105947:	8b 40 04             	mov    0x4(%eax),%eax
c010594a:	85 c0                	test   %eax,%eax
c010594c:	74 2f                	je     c010597d <__kmalloc+0xdc>
		spin_lock_irqsave(&block_lock, flags);
c010594e:	e8 41 fa ff ff       	call   c0105394 <__intr_save>
c0105953:	89 45 ec             	mov    %eax,-0x14(%ebp)
		bb->next = bigblocks;
c0105956:	8b 15 74 0f 1b c0    	mov    0xc01b0f74,%edx
c010595c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010595f:	89 50 08             	mov    %edx,0x8(%eax)
		bigblocks = bb;
c0105962:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105965:	a3 74 0f 1b c0       	mov    %eax,0xc01b0f74
		spin_unlock_irqrestore(&block_lock, flags);
c010596a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010596d:	89 04 24             	mov    %eax,(%esp)
c0105970:	e8 49 fa ff ff       	call   c01053be <__intr_restore>
		return bb->pages;
c0105975:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105978:	8b 40 04             	mov    0x4(%eax),%eax
c010597b:	eb 18                	jmp    c0105995 <__kmalloc+0xf4>
	}

	slob_free(bb, sizeof(bigblock_t));
c010597d:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
c0105984:	00 
c0105985:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105988:	89 04 24             	mov    %eax,(%esp)
c010598b:	e8 91 fd ff ff       	call   c0105721 <slob_free>
	return 0;
c0105990:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105995:	c9                   	leave  
c0105996:	c3                   	ret    

c0105997 <kmalloc>:

void *
kmalloc(size_t size)
{
c0105997:	55                   	push   %ebp
c0105998:	89 e5                	mov    %esp,%ebp
c010599a:	83 ec 18             	sub    $0x18,%esp
  return __kmalloc(size, 0);
c010599d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01059a4:	00 
c01059a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01059a8:	89 04 24             	mov    %eax,(%esp)
c01059ab:	e8 f1 fe ff ff       	call   c01058a1 <__kmalloc>
}
c01059b0:	c9                   	leave  
c01059b1:	c3                   	ret    

c01059b2 <kfree>:


void kfree(void *block)
{
c01059b2:	55                   	push   %ebp
c01059b3:	89 e5                	mov    %esp,%ebp
c01059b5:	83 ec 28             	sub    $0x28,%esp
	bigblock_t *bb, **last = &bigblocks;
c01059b8:	c7 45 f0 74 0f 1b c0 	movl   $0xc01b0f74,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c01059bf:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01059c3:	0f 84 a4 00 00 00    	je     c0105a6d <kfree+0xbb>
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c01059c9:	8b 45 08             	mov    0x8(%ebp),%eax
c01059cc:	25 ff 0f 00 00       	and    $0xfff,%eax
c01059d1:	85 c0                	test   %eax,%eax
c01059d3:	75 7f                	jne    c0105a54 <kfree+0xa2>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
c01059d5:	e8 ba f9 ff ff       	call   c0105394 <__intr_save>
c01059da:	89 45 ec             	mov    %eax,-0x14(%ebp)
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c01059dd:	a1 74 0f 1b c0       	mov    0xc01b0f74,%eax
c01059e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01059e5:	eb 5c                	jmp    c0105a43 <kfree+0x91>
			if (bb->pages == block) {
c01059e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059ea:	8b 40 04             	mov    0x4(%eax),%eax
c01059ed:	3b 45 08             	cmp    0x8(%ebp),%eax
c01059f0:	75 3f                	jne    c0105a31 <kfree+0x7f>
				*last = bb->next;
c01059f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059f5:	8b 50 08             	mov    0x8(%eax),%edx
c01059f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01059fb:	89 10                	mov    %edx,(%eax)
				spin_unlock_irqrestore(&block_lock, flags);
c01059fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a00:	89 04 24             	mov    %eax,(%esp)
c0105a03:	e8 b6 f9 ff ff       	call   c01053be <__intr_restore>
				__slob_free_pages((unsigned long)block, bb->order);
c0105a08:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a0b:	8b 10                	mov    (%eax),%edx
c0105a0d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a10:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105a14:	89 04 24             	mov    %eax,(%esp)
c0105a17:	e8 fb fa ff ff       	call   c0105517 <__slob_free_pages>
				slob_free(bb, sizeof(bigblock_t));
c0105a1c:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
c0105a23:	00 
c0105a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a27:	89 04 24             	mov    %eax,(%esp)
c0105a2a:	e8 f2 fc ff ff       	call   c0105721 <slob_free>
				return;
c0105a2f:	eb 3d                	jmp    c0105a6e <kfree+0xbc>
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c0105a31:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a34:	83 c0 08             	add    $0x8,%eax
c0105a37:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a3d:	8b 40 08             	mov    0x8(%eax),%eax
c0105a40:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105a43:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105a47:	75 9e                	jne    c01059e7 <kfree+0x35>
				__slob_free_pages((unsigned long)block, bb->order);
				slob_free(bb, sizeof(bigblock_t));
				return;
			}
		}
		spin_unlock_irqrestore(&block_lock, flags);
c0105a49:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a4c:	89 04 24             	mov    %eax,(%esp)
c0105a4f:	e8 6a f9 ff ff       	call   c01053be <__intr_restore>
	}

	slob_free((slob_t *)block - 1, 0);
c0105a54:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a57:	83 e8 08             	sub    $0x8,%eax
c0105a5a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105a61:	00 
c0105a62:	89 04 24             	mov    %eax,(%esp)
c0105a65:	e8 b7 fc ff ff       	call   c0105721 <slob_free>
	return;
c0105a6a:	90                   	nop
c0105a6b:	eb 01                	jmp    c0105a6e <kfree+0xbc>
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
		return;
c0105a6d:	90                   	nop
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
c0105a6e:	c9                   	leave  
c0105a6f:	c3                   	ret    

c0105a70 <ksize>:


unsigned int ksize(const void *block)
{
c0105a70:	55                   	push   %ebp
c0105a71:	89 e5                	mov    %esp,%ebp
c0105a73:	83 ec 28             	sub    $0x28,%esp
	bigblock_t *bb;
	unsigned long flags;

	if (!block)
c0105a76:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105a7a:	75 07                	jne    c0105a83 <ksize+0x13>
		return 0;
c0105a7c:	b8 00 00 00 00       	mov    $0x0,%eax
c0105a81:	eb 6b                	jmp    c0105aee <ksize+0x7e>

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c0105a83:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a86:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105a8b:	85 c0                	test   %eax,%eax
c0105a8d:	75 54                	jne    c0105ae3 <ksize+0x73>
		spin_lock_irqsave(&block_lock, flags);
c0105a8f:	e8 00 f9 ff ff       	call   c0105394 <__intr_save>
c0105a94:	89 45 f0             	mov    %eax,-0x10(%ebp)
		for (bb = bigblocks; bb; bb = bb->next)
c0105a97:	a1 74 0f 1b c0       	mov    0xc01b0f74,%eax
c0105a9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105a9f:	eb 31                	jmp    c0105ad2 <ksize+0x62>
			if (bb->pages == block) {
c0105aa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105aa4:	8b 40 04             	mov    0x4(%eax),%eax
c0105aa7:	3b 45 08             	cmp    0x8(%ebp),%eax
c0105aaa:	75 1d                	jne    c0105ac9 <ksize+0x59>
				spin_unlock_irqrestore(&slob_lock, flags);
c0105aac:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105aaf:	89 04 24             	mov    %eax,(%esp)
c0105ab2:	e8 07 f9 ff ff       	call   c01053be <__intr_restore>
				return PAGE_SIZE << bb->order;
c0105ab7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105aba:	8b 00                	mov    (%eax),%eax
c0105abc:	ba 00 10 00 00       	mov    $0x1000,%edx
c0105ac1:	88 c1                	mov    %al,%cl
c0105ac3:	d3 e2                	shl    %cl,%edx
c0105ac5:	89 d0                	mov    %edx,%eax
c0105ac7:	eb 25                	jmp    c0105aee <ksize+0x7e>
	if (!block)
		return 0;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; bb = bb->next)
c0105ac9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105acc:	8b 40 08             	mov    0x8(%eax),%eax
c0105acf:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105ad2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105ad6:	75 c9                	jne    c0105aa1 <ksize+0x31>
			if (bb->pages == block) {
				spin_unlock_irqrestore(&slob_lock, flags);
				return PAGE_SIZE << bb->order;
			}
		spin_unlock_irqrestore(&block_lock, flags);
c0105ad8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105adb:	89 04 24             	mov    %eax,(%esp)
c0105ade:	e8 db f8 ff ff       	call   c01053be <__intr_restore>
	}

	return ((slob_t *)block - 1)->units * SLOB_UNIT;
c0105ae3:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ae6:	83 e8 08             	sub    $0x8,%eax
c0105ae9:	8b 00                	mov    (%eax),%eax
c0105aeb:	c1 e0 03             	shl    $0x3,%eax
}
c0105aee:	c9                   	leave  
c0105aef:	c3                   	ret    

c0105af0 <_fifo_init_mm>:
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
c0105af0:	55                   	push   %ebp
c0105af1:	89 e5                	mov    %esp,%ebp
c0105af3:	83 ec 10             	sub    $0x10,%esp
c0105af6:	c7 45 fc 44 31 1b c0 	movl   $0xc01b3144,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0105afd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105b00:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0105b03:	89 50 04             	mov    %edx,0x4(%eax)
c0105b06:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105b09:	8b 50 04             	mov    0x4(%eax),%edx
c0105b0c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105b0f:	89 10                	mov    %edx,(%eax)
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
c0105b11:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b14:	c7 40 14 44 31 1b c0 	movl   $0xc01b3144,0x14(%eax)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
c0105b1b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105b20:	c9                   	leave  
c0105b21:	c3                   	ret    

c0105b22 <_fifo_map_swappable>:
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0105b22:	55                   	push   %ebp
c0105b23:	89 e5                	mov    %esp,%ebp
c0105b25:	83 ec 48             	sub    $0x48,%esp
    list_entry_t *head=(list_entry_t*) mm->sm_priv;//获取页访问情况的链表头
c0105b28:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b2b:	8b 40 14             	mov    0x14(%eax),%eax
c0105b2e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *entry=&(page->pra_page_link);//获取最近被使用到的页面
c0105b31:	8b 45 10             	mov    0x10(%ebp),%eax
c0105b34:	83 c0 14             	add    $0x14,%eax
c0105b37:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(entry != NULL && head != NULL);
c0105b3a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105b3e:	74 06                	je     c0105b46 <_fifo_map_swappable+0x24>
c0105b40:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105b44:	75 24                	jne    c0105b6a <_fifo_map_swappable+0x48>
c0105b46:	c7 44 24 0c bc d5 10 	movl   $0xc010d5bc,0xc(%esp)
c0105b4d:	c0 
c0105b4e:	c7 44 24 08 da d5 10 	movl   $0xc010d5da,0x8(%esp)
c0105b55:	c0 
c0105b56:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
c0105b5d:	00 
c0105b5e:	c7 04 24 ef d5 10 c0 	movl   $0xc010d5ef,(%esp)
c0105b65:	e8 9b a8 ff ff       	call   c0100405 <__panic>
c0105b6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105b6d:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105b70:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105b73:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105b76:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105b79:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105b7c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105b7f:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0105b82:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105b85:	8b 40 04             	mov    0x4(%eax),%eax
c0105b88:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105b8b:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0105b8e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105b91:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0105b94:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0105b97:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105b9a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105b9d:	89 10                	mov    %edx,(%eax)
c0105b9f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105ba2:	8b 10                	mov    (%eax),%edx
c0105ba4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105ba7:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0105baa:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105bad:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105bb0:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0105bb3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105bb6:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105bb9:	89 10                	mov    %edx,(%eax)
    list_add(head, entry);//头插，将最近被用到的页面添加到记录页访问情况的链表
    return 0;
c0105bbb:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105bc0:	c9                   	leave  
c0105bc1:	c3                   	ret    

c0105bc2 <_fifo_swap_out_victim>:
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then assign the value of *ptr_page to the addr of this page.
 */
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
c0105bc2:	55                   	push   %ebp
c0105bc3:	89 e5                	mov    %esp,%ebp
c0105bc5:	83 ec 38             	sub    $0x38,%esp
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0105bc8:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bcb:	8b 40 14             	mov    0x14(%eax),%eax
c0105bce:	89 45 f4             	mov    %eax,-0xc(%ebp)
         assert(head != NULL);
c0105bd1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105bd5:	75 24                	jne    c0105bfb <_fifo_swap_out_victim+0x39>
c0105bd7:	c7 44 24 0c 03 d6 10 	movl   $0xc010d603,0xc(%esp)
c0105bde:	c0 
c0105bdf:	c7 44 24 08 da d5 10 	movl   $0xc010d5da,0x8(%esp)
c0105be6:	c0 
c0105be7:	c7 44 24 04 3d 00 00 	movl   $0x3d,0x4(%esp)
c0105bee:	00 
c0105bef:	c7 04 24 ef d5 10 c0 	movl   $0xc010d5ef,(%esp)
c0105bf6:	e8 0a a8 ff ff       	call   c0100405 <__panic>
     assert(in_tick==0);
c0105bfb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105bff:	74 24                	je     c0105c25 <_fifo_swap_out_victim+0x63>
c0105c01:	c7 44 24 0c 10 d6 10 	movl   $0xc010d610,0xc(%esp)
c0105c08:	c0 
c0105c09:	c7 44 24 08 da d5 10 	movl   $0xc010d5da,0x8(%esp)
c0105c10:	c0 
c0105c11:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
c0105c18:	00 
c0105c19:	c7 04 24 ef d5 10 c0 	movl   $0xc010d5ef,(%esp)
c0105c20:	e8 e0 a7 ff ff       	call   c0100405 <__panic>
    list_entry_t *le = head->prev; //找到要被换出的页（即链表尾，找的是第一次访问时间最远的页）
c0105c25:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c28:	8b 00                	mov    (%eax),%eax
c0105c2a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(head != le);
c0105c2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c30:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0105c33:	75 24                	jne    c0105c59 <_fifo_swap_out_victim+0x97>
c0105c35:	c7 44 24 0c 1b d6 10 	movl   $0xc010d61b,0xc(%esp)
c0105c3c:	c0 
c0105c3d:	c7 44 24 08 da d5 10 	movl   $0xc010d5da,0x8(%esp)
c0105c44:	c0 
c0105c45:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
c0105c4c:	00 
c0105c4d:	c7 04 24 ef d5 10 c0 	movl   $0xc010d5ef,(%esp)
c0105c54:	e8 ac a7 ff ff       	call   c0100405 <__panic>
    struct Page *p = le2page(le,pra_page_link); //找到page结构的head
c0105c59:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c5c:	83 e8 14             	sub    $0x14,%eax
c0105c5f:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105c62:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c65:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0105c68:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105c6b:	8b 40 04             	mov    0x4(%eax),%eax
c0105c6e:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0105c71:	8b 12                	mov    (%edx),%edx
c0105c73:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0105c76:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0105c79:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105c7c:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105c7f:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0105c82:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105c85:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105c88:	89 10                	mov    %edx,(%eax)
    list_del(le); //将进来最早的页面从队列中删除
    assert (p != NULL);
c0105c8a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0105c8e:	75 24                	jne    c0105cb4 <_fifo_swap_out_victim+0xf2>
c0105c90:	c7 44 24 0c 26 d6 10 	movl   $0xc010d626,0xc(%esp)
c0105c97:	c0 
c0105c98:	c7 44 24 08 da d5 10 	movl   $0xc010d5da,0x8(%esp)
c0105c9f:	c0 
c0105ca0:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
c0105ca7:	00 
c0105ca8:	c7 04 24 ef d5 10 c0 	movl   $0xc010d5ef,(%esp)
c0105caf:	e8 51 a7 ff ff       	call   c0100405 <__panic>
    *ptr_page = p;
c0105cb4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105cb7:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105cba:	89 10                	mov    %edx,(%eax)

    return 0;
c0105cbc:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105cc1:	c9                   	leave  
c0105cc2:	c3                   	ret    

c0105cc3 <_fifo_check_swap>:

static int
_fifo_check_swap(void) {
c0105cc3:	55                   	push   %ebp
c0105cc4:	89 e5                	mov    %esp,%ebp
c0105cc6:	83 ec 18             	sub    $0x18,%esp
    cprintf("write Virt Page c in fifo_check_swap\n");
c0105cc9:	c7 04 24 30 d6 10 c0 	movl   $0xc010d630,(%esp)
c0105cd0:	e8 d9 a5 ff ff       	call   c01002ae <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c0105cd5:	b8 00 30 00 00       	mov    $0x3000,%eax
c0105cda:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==4);
c0105cdd:	a1 64 0f 1b c0       	mov    0xc01b0f64,%eax
c0105ce2:	83 f8 04             	cmp    $0x4,%eax
c0105ce5:	74 24                	je     c0105d0b <_fifo_check_swap+0x48>
c0105ce7:	c7 44 24 0c 56 d6 10 	movl   $0xc010d656,0xc(%esp)
c0105cee:	c0 
c0105cef:	c7 44 24 08 da d5 10 	movl   $0xc010d5da,0x8(%esp)
c0105cf6:	c0 
c0105cf7:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
c0105cfe:	00 
c0105cff:	c7 04 24 ef d5 10 c0 	movl   $0xc010d5ef,(%esp)
c0105d06:	e8 fa a6 ff ff       	call   c0100405 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0105d0b:	c7 04 24 68 d6 10 c0 	movl   $0xc010d668,(%esp)
c0105d12:	e8 97 a5 ff ff       	call   c01002ae <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c0105d17:	b8 00 10 00 00       	mov    $0x1000,%eax
c0105d1c:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==4);
c0105d1f:	a1 64 0f 1b c0       	mov    0xc01b0f64,%eax
c0105d24:	83 f8 04             	cmp    $0x4,%eax
c0105d27:	74 24                	je     c0105d4d <_fifo_check_swap+0x8a>
c0105d29:	c7 44 24 0c 56 d6 10 	movl   $0xc010d656,0xc(%esp)
c0105d30:	c0 
c0105d31:	c7 44 24 08 da d5 10 	movl   $0xc010d5da,0x8(%esp)
c0105d38:	c0 
c0105d39:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
c0105d40:	00 
c0105d41:	c7 04 24 ef d5 10 c0 	movl   $0xc010d5ef,(%esp)
c0105d48:	e8 b8 a6 ff ff       	call   c0100405 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0105d4d:	c7 04 24 90 d6 10 c0 	movl   $0xc010d690,(%esp)
c0105d54:	e8 55 a5 ff ff       	call   c01002ae <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0105d59:	b8 00 40 00 00       	mov    $0x4000,%eax
c0105d5e:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==4);
c0105d61:	a1 64 0f 1b c0       	mov    0xc01b0f64,%eax
c0105d66:	83 f8 04             	cmp    $0x4,%eax
c0105d69:	74 24                	je     c0105d8f <_fifo_check_swap+0xcc>
c0105d6b:	c7 44 24 0c 56 d6 10 	movl   $0xc010d656,0xc(%esp)
c0105d72:	c0 
c0105d73:	c7 44 24 08 da d5 10 	movl   $0xc010d5da,0x8(%esp)
c0105d7a:	c0 
c0105d7b:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
c0105d82:	00 
c0105d83:	c7 04 24 ef d5 10 c0 	movl   $0xc010d5ef,(%esp)
c0105d8a:	e8 76 a6 ff ff       	call   c0100405 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0105d8f:	c7 04 24 b8 d6 10 c0 	movl   $0xc010d6b8,(%esp)
c0105d96:	e8 13 a5 ff ff       	call   c01002ae <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0105d9b:	b8 00 20 00 00       	mov    $0x2000,%eax
c0105da0:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==4);
c0105da3:	a1 64 0f 1b c0       	mov    0xc01b0f64,%eax
c0105da8:	83 f8 04             	cmp    $0x4,%eax
c0105dab:	74 24                	je     c0105dd1 <_fifo_check_swap+0x10e>
c0105dad:	c7 44 24 0c 56 d6 10 	movl   $0xc010d656,0xc(%esp)
c0105db4:	c0 
c0105db5:	c7 44 24 08 da d5 10 	movl   $0xc010d5da,0x8(%esp)
c0105dbc:	c0 
c0105dbd:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
c0105dc4:	00 
c0105dc5:	c7 04 24 ef d5 10 c0 	movl   $0xc010d5ef,(%esp)
c0105dcc:	e8 34 a6 ff ff       	call   c0100405 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0105dd1:	c7 04 24 e0 d6 10 c0 	movl   $0xc010d6e0,(%esp)
c0105dd8:	e8 d1 a4 ff ff       	call   c01002ae <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0105ddd:	b8 00 50 00 00       	mov    $0x5000,%eax
c0105de2:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==5);
c0105de5:	a1 64 0f 1b c0       	mov    0xc01b0f64,%eax
c0105dea:	83 f8 05             	cmp    $0x5,%eax
c0105ded:	74 24                	je     c0105e13 <_fifo_check_swap+0x150>
c0105def:	c7 44 24 0c 06 d7 10 	movl   $0xc010d706,0xc(%esp)
c0105df6:	c0 
c0105df7:	c7 44 24 08 da d5 10 	movl   $0xc010d5da,0x8(%esp)
c0105dfe:	c0 
c0105dff:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
c0105e06:	00 
c0105e07:	c7 04 24 ef d5 10 c0 	movl   $0xc010d5ef,(%esp)
c0105e0e:	e8 f2 a5 ff ff       	call   c0100405 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0105e13:	c7 04 24 b8 d6 10 c0 	movl   $0xc010d6b8,(%esp)
c0105e1a:	e8 8f a4 ff ff       	call   c01002ae <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0105e1f:	b8 00 20 00 00       	mov    $0x2000,%eax
c0105e24:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==5);
c0105e27:	a1 64 0f 1b c0       	mov    0xc01b0f64,%eax
c0105e2c:	83 f8 05             	cmp    $0x5,%eax
c0105e2f:	74 24                	je     c0105e55 <_fifo_check_swap+0x192>
c0105e31:	c7 44 24 0c 06 d7 10 	movl   $0xc010d706,0xc(%esp)
c0105e38:	c0 
c0105e39:	c7 44 24 08 da d5 10 	movl   $0xc010d5da,0x8(%esp)
c0105e40:	c0 
c0105e41:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
c0105e48:	00 
c0105e49:	c7 04 24 ef d5 10 c0 	movl   $0xc010d5ef,(%esp)
c0105e50:	e8 b0 a5 ff ff       	call   c0100405 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0105e55:	c7 04 24 68 d6 10 c0 	movl   $0xc010d668,(%esp)
c0105e5c:	e8 4d a4 ff ff       	call   c01002ae <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c0105e61:	b8 00 10 00 00       	mov    $0x1000,%eax
c0105e66:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==6);
c0105e69:	a1 64 0f 1b c0       	mov    0xc01b0f64,%eax
c0105e6e:	83 f8 06             	cmp    $0x6,%eax
c0105e71:	74 24                	je     c0105e97 <_fifo_check_swap+0x1d4>
c0105e73:	c7 44 24 0c 15 d7 10 	movl   $0xc010d715,0xc(%esp)
c0105e7a:	c0 
c0105e7b:	c7 44 24 08 da d5 10 	movl   $0xc010d5da,0x8(%esp)
c0105e82:	c0 
c0105e83:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c0105e8a:	00 
c0105e8b:	c7 04 24 ef d5 10 c0 	movl   $0xc010d5ef,(%esp)
c0105e92:	e8 6e a5 ff ff       	call   c0100405 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0105e97:	c7 04 24 b8 d6 10 c0 	movl   $0xc010d6b8,(%esp)
c0105e9e:	e8 0b a4 ff ff       	call   c01002ae <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0105ea3:	b8 00 20 00 00       	mov    $0x2000,%eax
c0105ea8:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==7);
c0105eab:	a1 64 0f 1b c0       	mov    0xc01b0f64,%eax
c0105eb0:	83 f8 07             	cmp    $0x7,%eax
c0105eb3:	74 24                	je     c0105ed9 <_fifo_check_swap+0x216>
c0105eb5:	c7 44 24 0c 24 d7 10 	movl   $0xc010d724,0xc(%esp)
c0105ebc:	c0 
c0105ebd:	c7 44 24 08 da d5 10 	movl   $0xc010d5da,0x8(%esp)
c0105ec4:	c0 
c0105ec5:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
c0105ecc:	00 
c0105ecd:	c7 04 24 ef d5 10 c0 	movl   $0xc010d5ef,(%esp)
c0105ed4:	e8 2c a5 ff ff       	call   c0100405 <__panic>
    cprintf("write Virt Page c in fifo_check_swap\n");
c0105ed9:	c7 04 24 30 d6 10 c0 	movl   $0xc010d630,(%esp)
c0105ee0:	e8 c9 a3 ff ff       	call   c01002ae <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c0105ee5:	b8 00 30 00 00       	mov    $0x3000,%eax
c0105eea:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==8);
c0105eed:	a1 64 0f 1b c0       	mov    0xc01b0f64,%eax
c0105ef2:	83 f8 08             	cmp    $0x8,%eax
c0105ef5:	74 24                	je     c0105f1b <_fifo_check_swap+0x258>
c0105ef7:	c7 44 24 0c 33 d7 10 	movl   $0xc010d733,0xc(%esp)
c0105efe:	c0 
c0105eff:	c7 44 24 08 da d5 10 	movl   $0xc010d5da,0x8(%esp)
c0105f06:	c0 
c0105f07:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c0105f0e:	00 
c0105f0f:	c7 04 24 ef d5 10 c0 	movl   $0xc010d5ef,(%esp)
c0105f16:	e8 ea a4 ff ff       	call   c0100405 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0105f1b:	c7 04 24 90 d6 10 c0 	movl   $0xc010d690,(%esp)
c0105f22:	e8 87 a3 ff ff       	call   c01002ae <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0105f27:	b8 00 40 00 00       	mov    $0x4000,%eax
c0105f2c:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==9);
c0105f2f:	a1 64 0f 1b c0       	mov    0xc01b0f64,%eax
c0105f34:	83 f8 09             	cmp    $0x9,%eax
c0105f37:	74 24                	je     c0105f5d <_fifo_check_swap+0x29a>
c0105f39:	c7 44 24 0c 42 d7 10 	movl   $0xc010d742,0xc(%esp)
c0105f40:	c0 
c0105f41:	c7 44 24 08 da d5 10 	movl   $0xc010d5da,0x8(%esp)
c0105f48:	c0 
c0105f49:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
c0105f50:	00 
c0105f51:	c7 04 24 ef d5 10 c0 	movl   $0xc010d5ef,(%esp)
c0105f58:	e8 a8 a4 ff ff       	call   c0100405 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0105f5d:	c7 04 24 e0 d6 10 c0 	movl   $0xc010d6e0,(%esp)
c0105f64:	e8 45 a3 ff ff       	call   c01002ae <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0105f69:	b8 00 50 00 00       	mov    $0x5000,%eax
c0105f6e:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==10);
c0105f71:	a1 64 0f 1b c0       	mov    0xc01b0f64,%eax
c0105f76:	83 f8 0a             	cmp    $0xa,%eax
c0105f79:	74 24                	je     c0105f9f <_fifo_check_swap+0x2dc>
c0105f7b:	c7 44 24 0c 51 d7 10 	movl   $0xc010d751,0xc(%esp)
c0105f82:	c0 
c0105f83:	c7 44 24 08 da d5 10 	movl   $0xc010d5da,0x8(%esp)
c0105f8a:	c0 
c0105f8b:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
c0105f92:	00 
c0105f93:	c7 04 24 ef d5 10 c0 	movl   $0xc010d5ef,(%esp)
c0105f9a:	e8 66 a4 ff ff       	call   c0100405 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0105f9f:	c7 04 24 68 d6 10 c0 	movl   $0xc010d668,(%esp)
c0105fa6:	e8 03 a3 ff ff       	call   c01002ae <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
c0105fab:	b8 00 10 00 00       	mov    $0x1000,%eax
c0105fb0:	0f b6 00             	movzbl (%eax),%eax
c0105fb3:	3c 0a                	cmp    $0xa,%al
c0105fb5:	74 24                	je     c0105fdb <_fifo_check_swap+0x318>
c0105fb7:	c7 44 24 0c 64 d7 10 	movl   $0xc010d764,0xc(%esp)
c0105fbe:	c0 
c0105fbf:	c7 44 24 08 da d5 10 	movl   $0xc010d5da,0x8(%esp)
c0105fc6:	c0 
c0105fc7:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0105fce:	00 
c0105fcf:	c7 04 24 ef d5 10 c0 	movl   $0xc010d5ef,(%esp)
c0105fd6:	e8 2a a4 ff ff       	call   c0100405 <__panic>
    *(unsigned char *)0x1000 = 0x0a;
c0105fdb:	b8 00 10 00 00       	mov    $0x1000,%eax
c0105fe0:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==11);
c0105fe3:	a1 64 0f 1b c0       	mov    0xc01b0f64,%eax
c0105fe8:	83 f8 0b             	cmp    $0xb,%eax
c0105feb:	74 24                	je     c0106011 <_fifo_check_swap+0x34e>
c0105fed:	c7 44 24 0c 85 d7 10 	movl   $0xc010d785,0xc(%esp)
c0105ff4:	c0 
c0105ff5:	c7 44 24 08 da d5 10 	movl   $0xc010d5da,0x8(%esp)
c0105ffc:	c0 
c0105ffd:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
c0106004:	00 
c0106005:	c7 04 24 ef d5 10 c0 	movl   $0xc010d5ef,(%esp)
c010600c:	e8 f4 a3 ff ff       	call   c0100405 <__panic>
    return 0;
c0106011:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106016:	c9                   	leave  
c0106017:	c3                   	ret    

c0106018 <_fifo_init>:


static int
_fifo_init(void)
{
c0106018:	55                   	push   %ebp
c0106019:	89 e5                	mov    %esp,%ebp
    return 0;
c010601b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106020:	5d                   	pop    %ebp
c0106021:	c3                   	ret    

c0106022 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c0106022:	55                   	push   %ebp
c0106023:	89 e5                	mov    %esp,%ebp
    return 0;
c0106025:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010602a:	5d                   	pop    %ebp
c010602b:	c3                   	ret    

c010602c <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
c010602c:	55                   	push   %ebp
c010602d:	89 e5                	mov    %esp,%ebp
c010602f:	b8 00 00 00 00       	mov    $0x0,%eax
c0106034:	5d                   	pop    %ebp
c0106035:	c3                   	ret    

c0106036 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0106036:	55                   	push   %ebp
c0106037:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0106039:	8b 45 08             	mov    0x8(%ebp),%eax
c010603c:	8b 15 60 31 1b c0    	mov    0xc01b3160,%edx
c0106042:	29 d0                	sub    %edx,%eax
c0106044:	c1 f8 05             	sar    $0x5,%eax
}
c0106047:	5d                   	pop    %ebp
c0106048:	c3                   	ret    

c0106049 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0106049:	55                   	push   %ebp
c010604a:	89 e5                	mov    %esp,%ebp
c010604c:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c010604f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106052:	89 04 24             	mov    %eax,(%esp)
c0106055:	e8 dc ff ff ff       	call   c0106036 <page2ppn>
c010605a:	c1 e0 0c             	shl    $0xc,%eax
}
c010605d:	c9                   	leave  
c010605e:	c3                   	ret    

c010605f <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c010605f:	55                   	push   %ebp
c0106060:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0106062:	8b 45 08             	mov    0x8(%ebp),%eax
c0106065:	8b 00                	mov    (%eax),%eax
}
c0106067:	5d                   	pop    %ebp
c0106068:	c3                   	ret    

c0106069 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0106069:	55                   	push   %ebp
c010606a:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c010606c:	8b 45 08             	mov    0x8(%ebp),%eax
c010606f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106072:	89 10                	mov    %edx,(%eax)
}
c0106074:	90                   	nop
c0106075:	5d                   	pop    %ebp
c0106076:	c3                   	ret    

c0106077 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c0106077:	55                   	push   %ebp
c0106078:	89 e5                	mov    %esp,%ebp
c010607a:	83 ec 10             	sub    $0x10,%esp
c010607d:	c7 45 fc 4c 31 1b c0 	movl   $0xc01b314c,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0106084:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106087:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010608a:	89 50 04             	mov    %edx,0x4(%eax)
c010608d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106090:	8b 50 04             	mov    0x4(%eax),%edx
c0106093:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106096:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c0106098:	c7 05 54 31 1b c0 00 	movl   $0x0,0xc01b3154
c010609f:	00 00 00 
}
c01060a2:	90                   	nop
c01060a3:	c9                   	leave  
c01060a4:	c3                   	ret    

c01060a5 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c01060a5:	55                   	push   %ebp
c01060a6:	89 e5                	mov    %esp,%ebp
c01060a8:	83 ec 58             	sub    $0x58,%esp
    // 传进来的第一个参数是某个连续地址的空闲块的起始页
    // 第二个参数是页个数
    assert(n > 0);
c01060ab:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01060af:	75 24                	jne    c01060d5 <default_init_memmap+0x30>
c01060b1:	c7 44 24 0c a8 d7 10 	movl   $0xc010d7a8,0xc(%esp)
c01060b8:	c0 
c01060b9:	c7 44 24 08 ae d7 10 	movl   $0xc010d7ae,0x8(%esp)
c01060c0:	c0 
c01060c1:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
c01060c8:	00 
c01060c9:	c7 04 24 c3 d7 10 c0 	movl   $0xc010d7c3,(%esp)
c01060d0:	e8 30 a3 ff ff       	call   c0100405 <__panic>
    struct Page *p = base;
c01060d5:	8b 45 08             	mov    0x8(%ebp),%eax
c01060d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c01060db:	eb 7d                	jmp    c010615a <default_init_memmap+0xb5>
        assert(PageReserved(p)); // 判断此页是否为保留页
c01060dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01060e0:	83 c0 04             	add    $0x4,%eax
c01060e3:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c01060ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01060ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01060f0:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01060f3:	0f a3 10             	bt     %edx,(%eax)
c01060f6:	19 c0                	sbb    %eax,%eax
c01060f8:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return oldbit != 0;
c01060fb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01060ff:	0f 95 c0             	setne  %al
c0106102:	0f b6 c0             	movzbl %al,%eax
c0106105:	85 c0                	test   %eax,%eax
c0106107:	75 24                	jne    c010612d <default_init_memmap+0x88>
c0106109:	c7 44 24 0c d9 d7 10 	movl   $0xc010d7d9,0xc(%esp)
c0106110:	c0 
c0106111:	c7 44 24 08 ae d7 10 	movl   $0xc010d7ae,0x8(%esp)
c0106118:	c0 
c0106119:	c7 44 24 04 72 00 00 	movl   $0x72,0x4(%esp)
c0106120:	00 
c0106121:	c7 04 24 c3 d7 10 c0 	movl   $0xc010d7c3,(%esp)
c0106128:	e8 d8 a2 ff ff       	call   c0100405 <__panic>
        p->flags = p->property = 0; // flag位与块内空闲页个数初始化
c010612d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106130:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c0106137:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010613a:	8b 50 08             	mov    0x8(%eax),%edx
c010613d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106140:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0); // page->ref = val;
c0106143:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010614a:	00 
c010614b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010614e:	89 04 24             	mov    %eax,(%esp)
c0106151:	e8 13 ff ff ff       	call   c0106069 <set_page_ref>
default_init_memmap(struct Page *base, size_t n) {
    // 传进来的第一个参数是某个连续地址的空闲块的起始页
    // 第二个参数是页个数
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c0106156:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c010615a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010615d:	c1 e0 05             	shl    $0x5,%eax
c0106160:	89 c2                	mov    %eax,%edx
c0106162:	8b 45 08             	mov    0x8(%ebp),%eax
c0106165:	01 d0                	add    %edx,%eax
c0106167:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010616a:	0f 85 6d ff ff ff    	jne    c01060dd <default_init_memmap+0x38>
        assert(PageReserved(p)); // 判断此页是否为保留页
        p->flags = p->property = 0; // flag位与块内空闲页个数初始化
        set_page_ref(p, 0); // page->ref = val;
    }
    base->property = n;
c0106170:	8b 45 08             	mov    0x8(%ebp),%eax
c0106173:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106176:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base); // 将其标记为已占有的物理内存空间
c0106179:	8b 45 08             	mov    0x8(%ebp),%eax
c010617c:	83 c0 04             	add    $0x4,%eax
c010617f:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
c0106186:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0106189:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010618c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010618f:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
c0106192:	8b 15 54 31 1b c0    	mov    0xc01b3154,%edx
c0106198:	8b 45 0c             	mov    0xc(%ebp),%eax
c010619b:	01 d0                	add    %edx,%eax
c010619d:	a3 54 31 1b c0       	mov    %eax,0xc01b3154
    list_add(&free_list, &(base->page_link)); // 运用头插法将空闲块插入链表
c01061a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01061a5:	83 c0 0c             	add    $0xc,%eax
c01061a8:	c7 45 f0 4c 31 1b c0 	movl   $0xc01b314c,-0x10(%ebp)
c01061af:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01061b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01061b5:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01061b8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01061bb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c01061be:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01061c1:	8b 40 04             	mov    0x4(%eax),%eax
c01061c4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01061c7:	89 55 d0             	mov    %edx,-0x30(%ebp)
c01061ca:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01061cd:	89 55 cc             	mov    %edx,-0x34(%ebp)
c01061d0:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01061d3:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01061d6:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01061d9:	89 10                	mov    %edx,(%eax)
c01061db:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01061de:	8b 10                	mov    (%eax),%edx
c01061e0:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01061e3:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01061e6:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01061e9:	8b 55 c8             	mov    -0x38(%ebp),%edx
c01061ec:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01061ef:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01061f2:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01061f5:	89 10                	mov    %edx,(%eax)
}
c01061f7:	90                   	nop
c01061f8:	c9                   	leave  
c01061f9:	c3                   	ret    

c01061fa <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c01061fa:	55                   	push   %ebp
c01061fb:	89 e5                	mov    %esp,%ebp
c01061fd:	83 ec 78             	sub    $0x78,%esp
    // 边界情况检查
    assert(n > 0);
c0106200:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0106204:	75 24                	jne    c010622a <default_alloc_pages+0x30>
c0106206:	c7 44 24 0c a8 d7 10 	movl   $0xc010d7a8,0xc(%esp)
c010620d:	c0 
c010620e:	c7 44 24 08 ae d7 10 	movl   $0xc010d7ae,0x8(%esp)
c0106215:	c0 
c0106216:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
c010621d:	00 
c010621e:	c7 04 24 c3 d7 10 c0 	movl   $0xc010d7c3,(%esp)
c0106225:	e8 db a1 ff ff       	call   c0100405 <__panic>
    if (n > nr_free) {
c010622a:	a1 54 31 1b c0       	mov    0xc01b3154,%eax
c010622f:	3b 45 08             	cmp    0x8(%ebp),%eax
c0106232:	73 0a                	jae    c010623e <default_alloc_pages+0x44>
        return NULL;
c0106234:	b8 00 00 00 00       	mov    $0x0,%eax
c0106239:	e9 6d 01 00 00       	jmp    c01063ab <default_alloc_pages+0x1b1>
    }
    struct Page *page = NULL;
c010623e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c0106245:	c7 45 f0 4c 31 1b c0 	movl   $0xc01b314c,-0x10(%ebp)
    // 若list_next == &free_list代表该循环双向链表被查询完毕
    while ((le = list_next(le)) != &free_list) {
c010624c:	eb 1c                	jmp    c010626a <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link); // 由list_entry_t结构转换为Page结构，找到该page结构的头地址
c010624e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106251:	83 e8 0c             	sub    $0xc,%eax
c0106254:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if (p->property >= n) {
c0106257:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010625a:	8b 40 08             	mov    0x8(%eax),%eax
c010625d:	3b 45 08             	cmp    0x8(%ebp),%eax
c0106260:	72 08                	jb     c010626a <default_alloc_pages+0x70>
            page = p; // 如果该空闲块里面的空闲页个数满足要求，就找到了
c0106262:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106265:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c0106268:	eb 18                	jmp    c0106282 <default_alloc_pages+0x88>
c010626a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010626d:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0106270:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106273:	8b 40 04             	mov    0x4(%eax),%eax
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    // 若list_next == &free_list代表该循环双向链表被查询完毕
    while ((le = list_next(le)) != &free_list) {
c0106276:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106279:	81 7d f0 4c 31 1b c0 	cmpl   $0xc01b314c,-0x10(%ebp)
c0106280:	75 cc                	jne    c010624e <default_alloc_pages+0x54>
            page = p; // 如果该空闲块里面的空闲页个数满足要求，就找到了
            break;
        }
    }
    // 匹配空闲块成功后的处理
    if (page != NULL) {
c0106282:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106286:	0f 84 1c 01 00 00    	je     c01063a8 <default_alloc_pages+0x1ae>
        list_del(&(page->page_link)); //将此块取出
c010628c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010628f:	83 c0 0c             	add    $0xc,%eax
c0106292:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0106295:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106298:	8b 40 04             	mov    0x4(%eax),%eax
c010629b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010629e:	8b 12                	mov    (%edx),%edx
c01062a0:	89 55 cc             	mov    %edx,-0x34(%ebp)
c01062a3:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01062a6:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01062a9:	8b 55 c8             	mov    -0x38(%ebp),%edx
c01062ac:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01062af:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01062b2:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01062b5:	89 10                	mov    %edx,(%eax)
        // 如果空闲页个数比要求的多
        if (page->property > n) {
c01062b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01062ba:	8b 40 08             	mov    0x8(%eax),%eax
c01062bd:	3b 45 08             	cmp    0x8(%ebp),%eax
c01062c0:	0f 86 91 00 00 00    	jbe    c0106357 <default_alloc_pages+0x15d>
            struct Page *p = page + n;
c01062c6:	8b 45 08             	mov    0x8(%ebp),%eax
c01062c9:	c1 e0 05             	shl    $0x5,%eax
c01062cc:	89 c2                	mov    %eax,%edx
c01062ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01062d1:	01 d0                	add    %edx,%eax
c01062d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
            p->property = page->property - n;
c01062d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01062d9:	8b 40 08             	mov    0x8(%eax),%eax
c01062dc:	2b 45 08             	sub    0x8(%ebp),%eax
c01062df:	89 c2                	mov    %eax,%edx
c01062e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01062e4:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p); // 标为已使用块
c01062e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01062ea:	83 c0 04             	add    $0x4,%eax
c01062ed:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
c01062f4:	89 45 ac             	mov    %eax,-0x54(%ebp)
c01062f7:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01062fa:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01062fd:	0f ab 10             	bts    %edx,(%eax)
            list_add(&(page->page_link), &(p->page_link));
c0106300:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106303:	83 c0 0c             	add    $0xc,%eax
c0106306:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106309:	83 c2 0c             	add    $0xc,%edx
c010630c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010630f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c0106312:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106315:	89 45 c0             	mov    %eax,-0x40(%ebp)
c0106318:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010631b:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c010631e:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0106321:	8b 40 04             	mov    0x4(%eax),%eax
c0106324:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0106327:	89 55 b8             	mov    %edx,-0x48(%ebp)
c010632a:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010632d:	89 55 b4             	mov    %edx,-0x4c(%ebp)
c0106330:	89 45 b0             	mov    %eax,-0x50(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0106333:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0106336:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0106339:	89 10                	mov    %edx,(%eax)
c010633b:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010633e:	8b 10                	mov    (%eax),%edx
c0106340:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0106343:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0106346:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0106349:	8b 55 b0             	mov    -0x50(%ebp),%edx
c010634c:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010634f:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0106352:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0106355:	89 10                	mov    %edx,(%eax)
        }
        list_del(&(page->page_link)); //从链表中删除
c0106357:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010635a:	83 c0 0c             	add    $0xc,%eax
c010635d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0106360:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106363:	8b 40 04             	mov    0x4(%eax),%eax
c0106366:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106369:	8b 12                	mov    (%edx),%edx
c010636b:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c010636e:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0106371:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0106374:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0106377:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010637a:	8b 45 a0             	mov    -0x60(%ebp),%eax
c010637d:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0106380:	89 10                	mov    %edx,(%eax)
        nr_free -= n;
c0106382:	a1 54 31 1b c0       	mov    0xc01b3154,%eax
c0106387:	2b 45 08             	sub    0x8(%ebp),%eax
c010638a:	a3 54 31 1b c0       	mov    %eax,0xc01b3154
        ClearPageProperty(page);
c010638f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106392:	83 c0 04             	add    $0x4,%eax
c0106395:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
c010639c:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010639f:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01063a2:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01063a5:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
c01063a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01063ab:	c9                   	leave  
c01063ac:	c3                   	ret    

c01063ad <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c01063ad:	55                   	push   %ebp
c01063ae:	89 e5                	mov    %esp,%ebp
c01063b0:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c01063b6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01063ba:	75 24                	jne    c01063e0 <default_free_pages+0x33>
c01063bc:	c7 44 24 0c a8 d7 10 	movl   $0xc010d7a8,0xc(%esp)
c01063c3:	c0 
c01063c4:	c7 44 24 08 ae d7 10 	movl   $0xc010d7ae,0x8(%esp)
c01063cb:	c0 
c01063cc:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c01063d3:	00 
c01063d4:	c7 04 24 c3 d7 10 c0 	movl   $0xc010d7c3,(%esp)
c01063db:	e8 25 a0 ff ff       	call   c0100405 <__panic>
    struct Page *p = base;
c01063e0:	8b 45 08             	mov    0x8(%ebp),%eax
c01063e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c01063e6:	e9 9d 00 00 00       	jmp    c0106488 <default_free_pages+0xdb>
        // 检测flag的bit 0是否是0，bit 1是否是0。即是否被保留，是否被free
        assert(!PageReserved(p) && !PageProperty(p));
c01063eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01063ee:	83 c0 04             	add    $0x4,%eax
c01063f1:	c7 45 c0 00 00 00 00 	movl   $0x0,-0x40(%ebp)
c01063f8:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01063fb:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01063fe:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0106401:	0f a3 10             	bt     %edx,(%eax)
c0106404:	19 c0                	sbb    %eax,%eax
c0106406:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0106409:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c010640d:	0f 95 c0             	setne  %al
c0106410:	0f b6 c0             	movzbl %al,%eax
c0106413:	85 c0                	test   %eax,%eax
c0106415:	75 2c                	jne    c0106443 <default_free_pages+0x96>
c0106417:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010641a:	83 c0 04             	add    $0x4,%eax
c010641d:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
c0106424:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106427:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010642a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010642d:	0f a3 10             	bt     %edx,(%eax)
c0106430:	19 c0                	sbb    %eax,%eax
c0106432:	89 45 b0             	mov    %eax,-0x50(%ebp)
    return oldbit != 0;
c0106435:	83 7d b0 00          	cmpl   $0x0,-0x50(%ebp)
c0106439:	0f 95 c0             	setne  %al
c010643c:	0f b6 c0             	movzbl %al,%eax
c010643f:	85 c0                	test   %eax,%eax
c0106441:	74 24                	je     c0106467 <default_free_pages+0xba>
c0106443:	c7 44 24 0c ec d7 10 	movl   $0xc010d7ec,0xc(%esp)
c010644a:	c0 
c010644b:	c7 44 24 08 ae d7 10 	movl   $0xc010d7ae,0x8(%esp)
c0106452:	c0 
c0106453:	c7 44 24 04 a4 00 00 	movl   $0xa4,0x4(%esp)
c010645a:	00 
c010645b:	c7 04 24 c3 d7 10 c0 	movl   $0xc010d7c3,(%esp)
c0106462:	e8 9e 9f ff ff       	call   c0100405 <__panic>
        p->flags = 0;
c0106467:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010646a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0); // 此页被引用次数清零
c0106471:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0106478:	00 
c0106479:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010647c:	89 04 24             	mov    %eax,(%esp)
c010647f:	e8 e5 fb ff ff       	call   c0106069 <set_page_ref>

static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c0106484:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c0106488:	8b 45 0c             	mov    0xc(%ebp),%eax
c010648b:	c1 e0 05             	shl    $0x5,%eax
c010648e:	89 c2                	mov    %eax,%edx
c0106490:	8b 45 08             	mov    0x8(%ebp),%eax
c0106493:	01 d0                	add    %edx,%eax
c0106495:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0106498:	0f 85 4d ff ff ff    	jne    c01063eb <default_free_pages+0x3e>
        // 检测flag的bit 0是否是0，bit 1是否是0。即是否被保留，是否被free
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0); // 此页被引用次数清零
    }
    base->property = n;
c010649e:	8b 45 08             	mov    0x8(%ebp),%eax
c01064a1:	8b 55 0c             	mov    0xc(%ebp),%edx
c01064a4:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base); // 设置为保留页
c01064a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01064aa:	83 c0 04             	add    $0x4,%eax
c01064ad:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c01064b4:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01064b7:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01064ba:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01064bd:	0f ab 10             	bts    %edx,(%eax)
c01064c0:	c7 45 e8 4c 31 1b c0 	movl   $0xc01b314c,-0x18(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01064c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01064ca:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c01064cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    // 找到要free的页，将其合并
    while (le != &free_list) {
c01064d0:	e9 fa 00 00 00       	jmp    c01065cf <default_free_pages+0x222>
        p = le2page(le, page_link);
c01064d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01064d8:	83 e8 0c             	sub    $0xc,%eax
c01064db:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01064de:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01064e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01064e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01064e7:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c01064ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
        // 这里是两种情况，看下图
        if (base + base->property == p) {
c01064ed:	8b 45 08             	mov    0x8(%ebp),%eax
c01064f0:	8b 40 08             	mov    0x8(%eax),%eax
c01064f3:	c1 e0 05             	shl    $0x5,%eax
c01064f6:	89 c2                	mov    %eax,%edx
c01064f8:	8b 45 08             	mov    0x8(%ebp),%eax
c01064fb:	01 d0                	add    %edx,%eax
c01064fd:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0106500:	75 5a                	jne    c010655c <default_free_pages+0x1af>
            base->property += p->property;
c0106502:	8b 45 08             	mov    0x8(%ebp),%eax
c0106505:	8b 50 08             	mov    0x8(%eax),%edx
c0106508:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010650b:	8b 40 08             	mov    0x8(%eax),%eax
c010650e:	01 c2                	add    %eax,%edx
c0106510:	8b 45 08             	mov    0x8(%ebp),%eax
c0106513:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c0106516:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106519:	83 c0 04             	add    $0x4,%eax
c010651c:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c0106523:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0106526:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0106529:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010652c:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
c010652f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106532:	83 c0 0c             	add    $0xc,%eax
c0106535:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0106538:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010653b:	8b 40 04             	mov    0x4(%eax),%eax
c010653e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106541:	8b 12                	mov    (%edx),%edx
c0106543:	89 55 a8             	mov    %edx,-0x58(%ebp)
c0106546:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0106549:	8b 45 a8             	mov    -0x58(%ebp),%eax
c010654c:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c010654f:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0106552:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0106555:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0106558:	89 10                	mov    %edx,(%eax)
c010655a:	eb 73                	jmp    c01065cf <default_free_pages+0x222>
        }
        else if (p + p->property == base) {
c010655c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010655f:	8b 40 08             	mov    0x8(%eax),%eax
c0106562:	c1 e0 05             	shl    $0x5,%eax
c0106565:	89 c2                	mov    %eax,%edx
c0106567:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010656a:	01 d0                	add    %edx,%eax
c010656c:	3b 45 08             	cmp    0x8(%ebp),%eax
c010656f:	75 5e                	jne    c01065cf <default_free_pages+0x222>
            p->property += base->property;
c0106571:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106574:	8b 50 08             	mov    0x8(%eax),%edx
c0106577:	8b 45 08             	mov    0x8(%ebp),%eax
c010657a:	8b 40 08             	mov    0x8(%eax),%eax
c010657d:	01 c2                	add    %eax,%edx
c010657f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106582:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c0106585:	8b 45 08             	mov    0x8(%ebp),%eax
c0106588:	83 c0 04             	add    $0x4,%eax
c010658b:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
c0106592:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0106595:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0106598:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010659b:	0f b3 10             	btr    %edx,(%eax)
            base = p;
c010659e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01065a1:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c01065a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01065a7:	83 c0 0c             	add    $0xc,%eax
c01065aa:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c01065ad:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01065b0:	8b 40 04             	mov    0x4(%eax),%eax
c01065b3:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01065b6:	8b 12                	mov    (%edx),%edx
c01065b8:	89 55 9c             	mov    %edx,-0x64(%ebp)
c01065bb:	89 45 98             	mov    %eax,-0x68(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01065be:	8b 45 9c             	mov    -0x64(%ebp),%eax
c01065c1:	8b 55 98             	mov    -0x68(%ebp),%edx
c01065c4:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01065c7:	8b 45 98             	mov    -0x68(%ebp),%eax
c01065ca:	8b 55 9c             	mov    -0x64(%ebp),%edx
c01065cd:	89 10                	mov    %edx,(%eax)
    }
    base->property = n;
    SetPageProperty(base); // 设置为保留页
    list_entry_t *le = list_next(&free_list);
    // 找到要free的页，将其合并
    while (le != &free_list) {
c01065cf:	81 7d f0 4c 31 1b c0 	cmpl   $0xc01b314c,-0x10(%ebp)
c01065d6:	0f 85 f9 fe ff ff    	jne    c01064d5 <default_free_pages+0x128>
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
c01065dc:	8b 15 54 31 1b c0    	mov    0xc01b3154,%edx
c01065e2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01065e5:	01 d0                	add    %edx,%eax
c01065e7:	a3 54 31 1b c0       	mov    %eax,0xc01b3154
c01065ec:	c7 45 d0 4c 31 1b c0 	movl   $0xc01b314c,-0x30(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01065f3:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01065f6:	8b 40 04             	mov    0x4(%eax),%eax
    le = list_next(&free_list);
c01065f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) //检测需释放的这段内存页 是否与head page相邻，详情见图三
c01065fc:	eb 66                	jmp    c0106664 <default_free_pages+0x2b7>
    {
        p = le2page(le, page_link);
c01065fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106601:	83 e8 0c             	sub    $0xc,%eax
c0106604:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property <= p)
c0106607:	8b 45 08             	mov    0x8(%ebp),%eax
c010660a:	8b 40 08             	mov    0x8(%eax),%eax
c010660d:	c1 e0 05             	shl    $0x5,%eax
c0106610:	89 c2                	mov    %eax,%edx
c0106612:	8b 45 08             	mov    0x8(%ebp),%eax
c0106615:	01 d0                	add    %edx,%eax
c0106617:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010661a:	77 39                	ja     c0106655 <default_free_pages+0x2a8>
        {
            assert(base + base->property != p);
c010661c:	8b 45 08             	mov    0x8(%ebp),%eax
c010661f:	8b 40 08             	mov    0x8(%eax),%eax
c0106622:	c1 e0 05             	shl    $0x5,%eax
c0106625:	89 c2                	mov    %eax,%edx
c0106627:	8b 45 08             	mov    0x8(%ebp),%eax
c010662a:	01 d0                	add    %edx,%eax
c010662c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010662f:	75 3e                	jne    c010666f <default_free_pages+0x2c2>
c0106631:	c7 44 24 0c 11 d8 10 	movl   $0xc010d811,0xc(%esp)
c0106638:	c0 
c0106639:	c7 44 24 08 ae d7 10 	movl   $0xc010d7ae,0x8(%esp)
c0106640:	c0 
c0106641:	c7 44 24 04 c3 00 00 	movl   $0xc3,0x4(%esp)
c0106648:	00 
c0106649:	c7 04 24 c3 d7 10 c0 	movl   $0xc010d7c3,(%esp)
c0106650:	e8 b0 9d ff ff       	call   c0100405 <__panic>
c0106655:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106658:	89 45 c8             	mov    %eax,-0x38(%ebp)
c010665b:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010665e:	8b 40 04             	mov    0x4(%eax),%eax
            break;
        }
        le = list_next(le);
c0106661:	89 45 f0             	mov    %eax,-0x10(%ebp)
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
    le = list_next(&free_list);
    while (le != &free_list) //检测需释放的这段内存页 是否与head page相邻，详情见图三
c0106664:	81 7d f0 4c 31 1b c0 	cmpl   $0xc01b314c,-0x10(%ebp)
c010666b:	75 91                	jne    c01065fe <default_free_pages+0x251>
c010666d:	eb 01                	jmp    c0106670 <default_free_pages+0x2c3>
    {
        p = le2page(le, page_link);
        if (base + base->property <= p)
        {
            assert(base + base->property != p);
            break;
c010666f:	90                   	nop
        }
        le = list_next(le);
    }
    list_add_before(&free_list, &(base->page_link)); //尾插，存疑，为何可行
c0106670:	8b 45 08             	mov    0x8(%ebp),%eax
c0106673:	83 c0 0c             	add    $0xc,%eax
c0106676:	c7 45 c4 4c 31 1b c0 	movl   $0xc01b314c,-0x3c(%ebp)
c010667d:	89 45 90             	mov    %eax,-0x70(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0106680:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0106683:	8b 00                	mov    (%eax),%eax
c0106685:	8b 55 90             	mov    -0x70(%ebp),%edx
c0106688:	89 55 8c             	mov    %edx,-0x74(%ebp)
c010668b:	89 45 88             	mov    %eax,-0x78(%ebp)
c010668e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0106691:	89 45 84             	mov    %eax,-0x7c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0106694:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0106697:	8b 55 8c             	mov    -0x74(%ebp),%edx
c010669a:	89 10                	mov    %edx,(%eax)
c010669c:	8b 45 84             	mov    -0x7c(%ebp),%eax
c010669f:	8b 10                	mov    (%eax),%edx
c01066a1:	8b 45 88             	mov    -0x78(%ebp),%eax
c01066a4:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01066a7:	8b 45 8c             	mov    -0x74(%ebp),%eax
c01066aa:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01066ad:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01066b0:	8b 45 8c             	mov    -0x74(%ebp),%eax
c01066b3:	8b 55 88             	mov    -0x78(%ebp),%edx
c01066b6:	89 10                	mov    %edx,(%eax)
}
c01066b8:	90                   	nop
c01066b9:	c9                   	leave  
c01066ba:	c3                   	ret    

c01066bb <default_nr_free_pages>:
static size_t
default_nr_free_pages(void) {
c01066bb:	55                   	push   %ebp
c01066bc:	89 e5                	mov    %esp,%ebp
    return nr_free;
c01066be:	a1 54 31 1b c0       	mov    0xc01b3154,%eax
}
c01066c3:	5d                   	pop    %ebp
c01066c4:	c3                   	ret    

c01066c5 <basic_check>:

static void
basic_check(void) {
c01066c5:	55                   	push   %ebp
c01066c6:	89 e5                	mov    %esp,%ebp
c01066c8:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c01066cb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01066d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01066d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01066d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01066db:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c01066de:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01066e5:	e8 86 0e 00 00       	call   c0107570 <alloc_pages>
c01066ea:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01066ed:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01066f1:	75 24                	jne    c0106717 <basic_check+0x52>
c01066f3:	c7 44 24 0c 2c d8 10 	movl   $0xc010d82c,0xc(%esp)
c01066fa:	c0 
c01066fb:	c7 44 24 08 ae d7 10 	movl   $0xc010d7ae,0x8(%esp)
c0106702:	c0 
c0106703:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c010670a:	00 
c010670b:	c7 04 24 c3 d7 10 c0 	movl   $0xc010d7c3,(%esp)
c0106712:	e8 ee 9c ff ff       	call   c0100405 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0106717:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010671e:	e8 4d 0e 00 00       	call   c0107570 <alloc_pages>
c0106723:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106726:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010672a:	75 24                	jne    c0106750 <basic_check+0x8b>
c010672c:	c7 44 24 0c 48 d8 10 	movl   $0xc010d848,0xc(%esp)
c0106733:	c0 
c0106734:	c7 44 24 08 ae d7 10 	movl   $0xc010d7ae,0x8(%esp)
c010673b:	c0 
c010673c:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
c0106743:	00 
c0106744:	c7 04 24 c3 d7 10 c0 	movl   $0xc010d7c3,(%esp)
c010674b:	e8 b5 9c ff ff       	call   c0100405 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0106750:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106757:	e8 14 0e 00 00       	call   c0107570 <alloc_pages>
c010675c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010675f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106763:	75 24                	jne    c0106789 <basic_check+0xc4>
c0106765:	c7 44 24 0c 64 d8 10 	movl   $0xc010d864,0xc(%esp)
c010676c:	c0 
c010676d:	c7 44 24 08 ae d7 10 	movl   $0xc010d7ae,0x8(%esp)
c0106774:	c0 
c0106775:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
c010677c:	00 
c010677d:	c7 04 24 c3 d7 10 c0 	movl   $0xc010d7c3,(%esp)
c0106784:	e8 7c 9c ff ff       	call   c0100405 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0106789:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010678c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010678f:	74 10                	je     c01067a1 <basic_check+0xdc>
c0106791:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106794:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0106797:	74 08                	je     c01067a1 <basic_check+0xdc>
c0106799:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010679c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010679f:	75 24                	jne    c01067c5 <basic_check+0x100>
c01067a1:	c7 44 24 0c 80 d8 10 	movl   $0xc010d880,0xc(%esp)
c01067a8:	c0 
c01067a9:	c7 44 24 08 ae d7 10 	movl   $0xc010d7ae,0x8(%esp)
c01067b0:	c0 
c01067b1:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
c01067b8:	00 
c01067b9:	c7 04 24 c3 d7 10 c0 	movl   $0xc010d7c3,(%esp)
c01067c0:	e8 40 9c ff ff       	call   c0100405 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c01067c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01067c8:	89 04 24             	mov    %eax,(%esp)
c01067cb:	e8 8f f8 ff ff       	call   c010605f <page_ref>
c01067d0:	85 c0                	test   %eax,%eax
c01067d2:	75 1e                	jne    c01067f2 <basic_check+0x12d>
c01067d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01067d7:	89 04 24             	mov    %eax,(%esp)
c01067da:	e8 80 f8 ff ff       	call   c010605f <page_ref>
c01067df:	85 c0                	test   %eax,%eax
c01067e1:	75 0f                	jne    c01067f2 <basic_check+0x12d>
c01067e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01067e6:	89 04 24             	mov    %eax,(%esp)
c01067e9:	e8 71 f8 ff ff       	call   c010605f <page_ref>
c01067ee:	85 c0                	test   %eax,%eax
c01067f0:	74 24                	je     c0106816 <basic_check+0x151>
c01067f2:	c7 44 24 0c a4 d8 10 	movl   $0xc010d8a4,0xc(%esp)
c01067f9:	c0 
c01067fa:	c7 44 24 08 ae d7 10 	movl   $0xc010d7ae,0x8(%esp)
c0106801:	c0 
c0106802:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
c0106809:	00 
c010680a:	c7 04 24 c3 d7 10 c0 	movl   $0xc010d7c3,(%esp)
c0106811:	e8 ef 9b ff ff       	call   c0100405 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0106816:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106819:	89 04 24             	mov    %eax,(%esp)
c010681c:	e8 28 f8 ff ff       	call   c0106049 <page2pa>
c0106821:	8b 15 80 0f 1b c0    	mov    0xc01b0f80,%edx
c0106827:	c1 e2 0c             	shl    $0xc,%edx
c010682a:	39 d0                	cmp    %edx,%eax
c010682c:	72 24                	jb     c0106852 <basic_check+0x18d>
c010682e:	c7 44 24 0c e0 d8 10 	movl   $0xc010d8e0,0xc(%esp)
c0106835:	c0 
c0106836:	c7 44 24 08 ae d7 10 	movl   $0xc010d7ae,0x8(%esp)
c010683d:	c0 
c010683e:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c0106845:	00 
c0106846:	c7 04 24 c3 d7 10 c0 	movl   $0xc010d7c3,(%esp)
c010684d:	e8 b3 9b ff ff       	call   c0100405 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0106852:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106855:	89 04 24             	mov    %eax,(%esp)
c0106858:	e8 ec f7 ff ff       	call   c0106049 <page2pa>
c010685d:	8b 15 80 0f 1b c0    	mov    0xc01b0f80,%edx
c0106863:	c1 e2 0c             	shl    $0xc,%edx
c0106866:	39 d0                	cmp    %edx,%eax
c0106868:	72 24                	jb     c010688e <basic_check+0x1c9>
c010686a:	c7 44 24 0c fd d8 10 	movl   $0xc010d8fd,0xc(%esp)
c0106871:	c0 
c0106872:	c7 44 24 08 ae d7 10 	movl   $0xc010d7ae,0x8(%esp)
c0106879:	c0 
c010687a:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c0106881:	00 
c0106882:	c7 04 24 c3 d7 10 c0 	movl   $0xc010d7c3,(%esp)
c0106889:	e8 77 9b ff ff       	call   c0100405 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c010688e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106891:	89 04 24             	mov    %eax,(%esp)
c0106894:	e8 b0 f7 ff ff       	call   c0106049 <page2pa>
c0106899:	8b 15 80 0f 1b c0    	mov    0xc01b0f80,%edx
c010689f:	c1 e2 0c             	shl    $0xc,%edx
c01068a2:	39 d0                	cmp    %edx,%eax
c01068a4:	72 24                	jb     c01068ca <basic_check+0x205>
c01068a6:	c7 44 24 0c 1a d9 10 	movl   $0xc010d91a,0xc(%esp)
c01068ad:	c0 
c01068ae:	c7 44 24 08 ae d7 10 	movl   $0xc010d7ae,0x8(%esp)
c01068b5:	c0 
c01068b6:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c01068bd:	00 
c01068be:	c7 04 24 c3 d7 10 c0 	movl   $0xc010d7c3,(%esp)
c01068c5:	e8 3b 9b ff ff       	call   c0100405 <__panic>

    list_entry_t free_list_store = free_list;
c01068ca:	a1 4c 31 1b c0       	mov    0xc01b314c,%eax
c01068cf:	8b 15 50 31 1b c0    	mov    0xc01b3150,%edx
c01068d5:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01068d8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01068db:	c7 45 e4 4c 31 1b c0 	movl   $0xc01b314c,-0x1c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01068e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01068e5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01068e8:	89 50 04             	mov    %edx,0x4(%eax)
c01068eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01068ee:	8b 50 04             	mov    0x4(%eax),%edx
c01068f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01068f4:	89 10                	mov    %edx,(%eax)
c01068f6:	c7 45 d8 4c 31 1b c0 	movl   $0xc01b314c,-0x28(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c01068fd:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0106900:	8b 40 04             	mov    0x4(%eax),%eax
c0106903:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0106906:	0f 94 c0             	sete   %al
c0106909:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c010690c:	85 c0                	test   %eax,%eax
c010690e:	75 24                	jne    c0106934 <basic_check+0x26f>
c0106910:	c7 44 24 0c 37 d9 10 	movl   $0xc010d937,0xc(%esp)
c0106917:	c0 
c0106918:	c7 44 24 08 ae d7 10 	movl   $0xc010d7ae,0x8(%esp)
c010691f:	c0 
c0106920:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
c0106927:	00 
c0106928:	c7 04 24 c3 d7 10 c0 	movl   $0xc010d7c3,(%esp)
c010692f:	e8 d1 9a ff ff       	call   c0100405 <__panic>

    unsigned int nr_free_store = nr_free;
c0106934:	a1 54 31 1b c0       	mov    0xc01b3154,%eax
c0106939:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
c010693c:	c7 05 54 31 1b c0 00 	movl   $0x0,0xc01b3154
c0106943:	00 00 00 

    assert(alloc_page() == NULL);
c0106946:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010694d:	e8 1e 0c 00 00       	call   c0107570 <alloc_pages>
c0106952:	85 c0                	test   %eax,%eax
c0106954:	74 24                	je     c010697a <basic_check+0x2b5>
c0106956:	c7 44 24 0c 4e d9 10 	movl   $0xc010d94e,0xc(%esp)
c010695d:	c0 
c010695e:	c7 44 24 08 ae d7 10 	movl   $0xc010d7ae,0x8(%esp)
c0106965:	c0 
c0106966:	c7 44 24 04 e5 00 00 	movl   $0xe5,0x4(%esp)
c010696d:	00 
c010696e:	c7 04 24 c3 d7 10 c0 	movl   $0xc010d7c3,(%esp)
c0106975:	e8 8b 9a ff ff       	call   c0100405 <__panic>

    free_page(p0);
c010697a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106981:	00 
c0106982:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106985:	89 04 24             	mov    %eax,(%esp)
c0106988:	e8 4e 0c 00 00       	call   c01075db <free_pages>
    free_page(p1);
c010698d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106994:	00 
c0106995:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106998:	89 04 24             	mov    %eax,(%esp)
c010699b:	e8 3b 0c 00 00       	call   c01075db <free_pages>
    free_page(p2);
c01069a0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01069a7:	00 
c01069a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01069ab:	89 04 24             	mov    %eax,(%esp)
c01069ae:	e8 28 0c 00 00       	call   c01075db <free_pages>
    assert(nr_free == 3);
c01069b3:	a1 54 31 1b c0       	mov    0xc01b3154,%eax
c01069b8:	83 f8 03             	cmp    $0x3,%eax
c01069bb:	74 24                	je     c01069e1 <basic_check+0x31c>
c01069bd:	c7 44 24 0c 63 d9 10 	movl   $0xc010d963,0xc(%esp)
c01069c4:	c0 
c01069c5:	c7 44 24 08 ae d7 10 	movl   $0xc010d7ae,0x8(%esp)
c01069cc:	c0 
c01069cd:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
c01069d4:	00 
c01069d5:	c7 04 24 c3 d7 10 c0 	movl   $0xc010d7c3,(%esp)
c01069dc:	e8 24 9a ff ff       	call   c0100405 <__panic>

    assert((p0 = alloc_page()) != NULL);
c01069e1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01069e8:	e8 83 0b 00 00       	call   c0107570 <alloc_pages>
c01069ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01069f0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01069f4:	75 24                	jne    c0106a1a <basic_check+0x355>
c01069f6:	c7 44 24 0c 2c d8 10 	movl   $0xc010d82c,0xc(%esp)
c01069fd:	c0 
c01069fe:	c7 44 24 08 ae d7 10 	movl   $0xc010d7ae,0x8(%esp)
c0106a05:	c0 
c0106a06:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
c0106a0d:	00 
c0106a0e:	c7 04 24 c3 d7 10 c0 	movl   $0xc010d7c3,(%esp)
c0106a15:	e8 eb 99 ff ff       	call   c0100405 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0106a1a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106a21:	e8 4a 0b 00 00       	call   c0107570 <alloc_pages>
c0106a26:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106a29:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106a2d:	75 24                	jne    c0106a53 <basic_check+0x38e>
c0106a2f:	c7 44 24 0c 48 d8 10 	movl   $0xc010d848,0xc(%esp)
c0106a36:	c0 
c0106a37:	c7 44 24 08 ae d7 10 	movl   $0xc010d7ae,0x8(%esp)
c0106a3e:	c0 
c0106a3f:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
c0106a46:	00 
c0106a47:	c7 04 24 c3 d7 10 c0 	movl   $0xc010d7c3,(%esp)
c0106a4e:	e8 b2 99 ff ff       	call   c0100405 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0106a53:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106a5a:	e8 11 0b 00 00       	call   c0107570 <alloc_pages>
c0106a5f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106a62:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106a66:	75 24                	jne    c0106a8c <basic_check+0x3c7>
c0106a68:	c7 44 24 0c 64 d8 10 	movl   $0xc010d864,0xc(%esp)
c0106a6f:	c0 
c0106a70:	c7 44 24 08 ae d7 10 	movl   $0xc010d7ae,0x8(%esp)
c0106a77:	c0 
c0106a78:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
c0106a7f:	00 
c0106a80:	c7 04 24 c3 d7 10 c0 	movl   $0xc010d7c3,(%esp)
c0106a87:	e8 79 99 ff ff       	call   c0100405 <__panic>

    assert(alloc_page() == NULL);
c0106a8c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106a93:	e8 d8 0a 00 00       	call   c0107570 <alloc_pages>
c0106a98:	85 c0                	test   %eax,%eax
c0106a9a:	74 24                	je     c0106ac0 <basic_check+0x3fb>
c0106a9c:	c7 44 24 0c 4e d9 10 	movl   $0xc010d94e,0xc(%esp)
c0106aa3:	c0 
c0106aa4:	c7 44 24 08 ae d7 10 	movl   $0xc010d7ae,0x8(%esp)
c0106aab:	c0 
c0106aac:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
c0106ab3:	00 
c0106ab4:	c7 04 24 c3 d7 10 c0 	movl   $0xc010d7c3,(%esp)
c0106abb:	e8 45 99 ff ff       	call   c0100405 <__panic>

    free_page(p0);
c0106ac0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106ac7:	00 
c0106ac8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106acb:	89 04 24             	mov    %eax,(%esp)
c0106ace:	e8 08 0b 00 00       	call   c01075db <free_pages>
c0106ad3:	c7 45 e8 4c 31 1b c0 	movl   $0xc01b314c,-0x18(%ebp)
c0106ada:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106add:	8b 40 04             	mov    0x4(%eax),%eax
c0106ae0:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0106ae3:	0f 94 c0             	sete   %al
c0106ae6:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0106ae9:	85 c0                	test   %eax,%eax
c0106aeb:	74 24                	je     c0106b11 <basic_check+0x44c>
c0106aed:	c7 44 24 0c 70 d9 10 	movl   $0xc010d970,0xc(%esp)
c0106af4:	c0 
c0106af5:	c7 44 24 08 ae d7 10 	movl   $0xc010d7ae,0x8(%esp)
c0106afc:	c0 
c0106afd:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
c0106b04:	00 
c0106b05:	c7 04 24 c3 d7 10 c0 	movl   $0xc010d7c3,(%esp)
c0106b0c:	e8 f4 98 ff ff       	call   c0100405 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0106b11:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106b18:	e8 53 0a 00 00       	call   c0107570 <alloc_pages>
c0106b1d:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0106b20:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106b23:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0106b26:	74 24                	je     c0106b4c <basic_check+0x487>
c0106b28:	c7 44 24 0c 88 d9 10 	movl   $0xc010d988,0xc(%esp)
c0106b2f:	c0 
c0106b30:	c7 44 24 08 ae d7 10 	movl   $0xc010d7ae,0x8(%esp)
c0106b37:	c0 
c0106b38:	c7 44 24 04 f6 00 00 	movl   $0xf6,0x4(%esp)
c0106b3f:	00 
c0106b40:	c7 04 24 c3 d7 10 c0 	movl   $0xc010d7c3,(%esp)
c0106b47:	e8 b9 98 ff ff       	call   c0100405 <__panic>
    assert(alloc_page() == NULL);
c0106b4c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106b53:	e8 18 0a 00 00       	call   c0107570 <alloc_pages>
c0106b58:	85 c0                	test   %eax,%eax
c0106b5a:	74 24                	je     c0106b80 <basic_check+0x4bb>
c0106b5c:	c7 44 24 0c 4e d9 10 	movl   $0xc010d94e,0xc(%esp)
c0106b63:	c0 
c0106b64:	c7 44 24 08 ae d7 10 	movl   $0xc010d7ae,0x8(%esp)
c0106b6b:	c0 
c0106b6c:	c7 44 24 04 f7 00 00 	movl   $0xf7,0x4(%esp)
c0106b73:	00 
c0106b74:	c7 04 24 c3 d7 10 c0 	movl   $0xc010d7c3,(%esp)
c0106b7b:	e8 85 98 ff ff       	call   c0100405 <__panic>

    assert(nr_free == 0);
c0106b80:	a1 54 31 1b c0       	mov    0xc01b3154,%eax
c0106b85:	85 c0                	test   %eax,%eax
c0106b87:	74 24                	je     c0106bad <basic_check+0x4e8>
c0106b89:	c7 44 24 0c a1 d9 10 	movl   $0xc010d9a1,0xc(%esp)
c0106b90:	c0 
c0106b91:	c7 44 24 08 ae d7 10 	movl   $0xc010d7ae,0x8(%esp)
c0106b98:	c0 
c0106b99:	c7 44 24 04 f9 00 00 	movl   $0xf9,0x4(%esp)
c0106ba0:	00 
c0106ba1:	c7 04 24 c3 d7 10 c0 	movl   $0xc010d7c3,(%esp)
c0106ba8:	e8 58 98 ff ff       	call   c0100405 <__panic>
    free_list = free_list_store;
c0106bad:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106bb0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106bb3:	a3 4c 31 1b c0       	mov    %eax,0xc01b314c
c0106bb8:	89 15 50 31 1b c0    	mov    %edx,0xc01b3150
    nr_free = nr_free_store;
c0106bbe:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106bc1:	a3 54 31 1b c0       	mov    %eax,0xc01b3154

    free_page(p);
c0106bc6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106bcd:	00 
c0106bce:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106bd1:	89 04 24             	mov    %eax,(%esp)
c0106bd4:	e8 02 0a 00 00       	call   c01075db <free_pages>
    free_page(p1);
c0106bd9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106be0:	00 
c0106be1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106be4:	89 04 24             	mov    %eax,(%esp)
c0106be7:	e8 ef 09 00 00       	call   c01075db <free_pages>
    free_page(p2);
c0106bec:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106bf3:	00 
c0106bf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106bf7:	89 04 24             	mov    %eax,(%esp)
c0106bfa:	e8 dc 09 00 00       	call   c01075db <free_pages>
}
c0106bff:	90                   	nop
c0106c00:	c9                   	leave  
c0106c01:	c3                   	ret    

c0106c02 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0106c02:	55                   	push   %ebp
c0106c03:	89 e5                	mov    %esp,%ebp
c0106c05:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
c0106c0b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0106c12:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0106c19:	c7 45 ec 4c 31 1b c0 	movl   $0xc01b314c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0106c20:	eb 6a                	jmp    c0106c8c <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
c0106c22:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106c25:	83 e8 0c             	sub    $0xc,%eax
c0106c28:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        assert(PageProperty(p));
c0106c2b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106c2e:	83 c0 04             	add    $0x4,%eax
c0106c31:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
c0106c38:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106c3b:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0106c3e:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0106c41:	0f a3 10             	bt     %edx,(%eax)
c0106c44:	19 c0                	sbb    %eax,%eax
c0106c46:	89 45 a8             	mov    %eax,-0x58(%ebp)
    return oldbit != 0;
c0106c49:	83 7d a8 00          	cmpl   $0x0,-0x58(%ebp)
c0106c4d:	0f 95 c0             	setne  %al
c0106c50:	0f b6 c0             	movzbl %al,%eax
c0106c53:	85 c0                	test   %eax,%eax
c0106c55:	75 24                	jne    c0106c7b <default_check+0x79>
c0106c57:	c7 44 24 0c ae d9 10 	movl   $0xc010d9ae,0xc(%esp)
c0106c5e:	c0 
c0106c5f:	c7 44 24 08 ae d7 10 	movl   $0xc010d7ae,0x8(%esp)
c0106c66:	c0 
c0106c67:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
c0106c6e:	00 
c0106c6f:	c7 04 24 c3 d7 10 c0 	movl   $0xc010d7c3,(%esp)
c0106c76:	e8 8a 97 ff ff       	call   c0100405 <__panic>
        count ++, total += p->property;
c0106c7b:	ff 45 f4             	incl   -0xc(%ebp)
c0106c7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106c81:	8b 50 08             	mov    0x8(%eax),%edx
c0106c84:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106c87:	01 d0                	add    %edx,%eax
c0106c89:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106c8c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106c8f:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0106c92:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106c95:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0106c98:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106c9b:	81 7d ec 4c 31 1b c0 	cmpl   $0xc01b314c,-0x14(%ebp)
c0106ca2:	0f 85 7a ff ff ff    	jne    c0106c22 <default_check+0x20>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
c0106ca8:	e8 61 09 00 00       	call   c010760e <nr_free_pages>
c0106cad:	89 c2                	mov    %eax,%edx
c0106caf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106cb2:	39 c2                	cmp    %eax,%edx
c0106cb4:	74 24                	je     c0106cda <default_check+0xd8>
c0106cb6:	c7 44 24 0c be d9 10 	movl   $0xc010d9be,0xc(%esp)
c0106cbd:	c0 
c0106cbe:	c7 44 24 08 ae d7 10 	movl   $0xc010d7ae,0x8(%esp)
c0106cc5:	c0 
c0106cc6:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
c0106ccd:	00 
c0106cce:	c7 04 24 c3 d7 10 c0 	movl   $0xc010d7c3,(%esp)
c0106cd5:	e8 2b 97 ff ff       	call   c0100405 <__panic>

    basic_check();
c0106cda:	e8 e6 f9 ff ff       	call   c01066c5 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0106cdf:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0106ce6:	e8 85 08 00 00       	call   c0107570 <alloc_pages>
c0106ceb:	89 45 dc             	mov    %eax,-0x24(%ebp)
    assert(p0 != NULL);
c0106cee:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0106cf2:	75 24                	jne    c0106d18 <default_check+0x116>
c0106cf4:	c7 44 24 0c d7 d9 10 	movl   $0xc010d9d7,0xc(%esp)
c0106cfb:	c0 
c0106cfc:	c7 44 24 08 ae d7 10 	movl   $0xc010d7ae,0x8(%esp)
c0106d03:	c0 
c0106d04:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
c0106d0b:	00 
c0106d0c:	c7 04 24 c3 d7 10 c0 	movl   $0xc010d7c3,(%esp)
c0106d13:	e8 ed 96 ff ff       	call   c0100405 <__panic>
    assert(!PageProperty(p0));
c0106d18:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106d1b:	83 c0 04             	add    $0x4,%eax
c0106d1e:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
c0106d25:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106d28:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0106d2b:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0106d2e:	0f a3 10             	bt     %edx,(%eax)
c0106d31:	19 c0                	sbb    %eax,%eax
c0106d33:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return oldbit != 0;
c0106d36:	83 7d a0 00          	cmpl   $0x0,-0x60(%ebp)
c0106d3a:	0f 95 c0             	setne  %al
c0106d3d:	0f b6 c0             	movzbl %al,%eax
c0106d40:	85 c0                	test   %eax,%eax
c0106d42:	74 24                	je     c0106d68 <default_check+0x166>
c0106d44:	c7 44 24 0c e2 d9 10 	movl   $0xc010d9e2,0xc(%esp)
c0106d4b:	c0 
c0106d4c:	c7 44 24 08 ae d7 10 	movl   $0xc010d7ae,0x8(%esp)
c0106d53:	c0 
c0106d54:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
c0106d5b:	00 
c0106d5c:	c7 04 24 c3 d7 10 c0 	movl   $0xc010d7c3,(%esp)
c0106d63:	e8 9d 96 ff ff       	call   c0100405 <__panic>

    list_entry_t free_list_store = free_list;
c0106d68:	a1 4c 31 1b c0       	mov    0xc01b314c,%eax
c0106d6d:	8b 15 50 31 1b c0    	mov    0xc01b3150,%edx
c0106d73:	89 45 80             	mov    %eax,-0x80(%ebp)
c0106d76:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0106d79:	c7 45 d0 4c 31 1b c0 	movl   $0xc01b314c,-0x30(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0106d80:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106d83:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0106d86:	89 50 04             	mov    %edx,0x4(%eax)
c0106d89:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106d8c:	8b 50 04             	mov    0x4(%eax),%edx
c0106d8f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106d92:	89 10                	mov    %edx,(%eax)
c0106d94:	c7 45 d8 4c 31 1b c0 	movl   $0xc01b314c,-0x28(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0106d9b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0106d9e:	8b 40 04             	mov    0x4(%eax),%eax
c0106da1:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0106da4:	0f 94 c0             	sete   %al
c0106da7:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0106daa:	85 c0                	test   %eax,%eax
c0106dac:	75 24                	jne    c0106dd2 <default_check+0x1d0>
c0106dae:	c7 44 24 0c 37 d9 10 	movl   $0xc010d937,0xc(%esp)
c0106db5:	c0 
c0106db6:	c7 44 24 08 ae d7 10 	movl   $0xc010d7ae,0x8(%esp)
c0106dbd:	c0 
c0106dbe:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
c0106dc5:	00 
c0106dc6:	c7 04 24 c3 d7 10 c0 	movl   $0xc010d7c3,(%esp)
c0106dcd:	e8 33 96 ff ff       	call   c0100405 <__panic>
    assert(alloc_page() == NULL);
c0106dd2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106dd9:	e8 92 07 00 00       	call   c0107570 <alloc_pages>
c0106dde:	85 c0                	test   %eax,%eax
c0106de0:	74 24                	je     c0106e06 <default_check+0x204>
c0106de2:	c7 44 24 0c 4e d9 10 	movl   $0xc010d94e,0xc(%esp)
c0106de9:	c0 
c0106dea:	c7 44 24 08 ae d7 10 	movl   $0xc010d7ae,0x8(%esp)
c0106df1:	c0 
c0106df2:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
c0106df9:	00 
c0106dfa:	c7 04 24 c3 d7 10 c0 	movl   $0xc010d7c3,(%esp)
c0106e01:	e8 ff 95 ff ff       	call   c0100405 <__panic>

    unsigned int nr_free_store = nr_free;
c0106e06:	a1 54 31 1b c0       	mov    0xc01b3154,%eax
c0106e0b:	89 45 cc             	mov    %eax,-0x34(%ebp)
    nr_free = 0;
c0106e0e:	c7 05 54 31 1b c0 00 	movl   $0x0,0xc01b3154
c0106e15:	00 00 00 

    free_pages(p0 + 2, 3);
c0106e18:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106e1b:	83 c0 40             	add    $0x40,%eax
c0106e1e:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0106e25:	00 
c0106e26:	89 04 24             	mov    %eax,(%esp)
c0106e29:	e8 ad 07 00 00       	call   c01075db <free_pages>
    assert(alloc_pages(4) == NULL);
c0106e2e:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0106e35:	e8 36 07 00 00       	call   c0107570 <alloc_pages>
c0106e3a:	85 c0                	test   %eax,%eax
c0106e3c:	74 24                	je     c0106e62 <default_check+0x260>
c0106e3e:	c7 44 24 0c f4 d9 10 	movl   $0xc010d9f4,0xc(%esp)
c0106e45:	c0 
c0106e46:	c7 44 24 08 ae d7 10 	movl   $0xc010d7ae,0x8(%esp)
c0106e4d:	c0 
c0106e4e:	c7 44 24 04 1e 01 00 	movl   $0x11e,0x4(%esp)
c0106e55:	00 
c0106e56:	c7 04 24 c3 d7 10 c0 	movl   $0xc010d7c3,(%esp)
c0106e5d:	e8 a3 95 ff ff       	call   c0100405 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c0106e62:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106e65:	83 c0 40             	add    $0x40,%eax
c0106e68:	83 c0 04             	add    $0x4,%eax
c0106e6b:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c0106e72:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106e75:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0106e78:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106e7b:	0f a3 10             	bt     %edx,(%eax)
c0106e7e:	19 c0                	sbb    %eax,%eax
c0106e80:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0106e83:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0106e87:	0f 95 c0             	setne  %al
c0106e8a:	0f b6 c0             	movzbl %al,%eax
c0106e8d:	85 c0                	test   %eax,%eax
c0106e8f:	74 0e                	je     c0106e9f <default_check+0x29d>
c0106e91:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106e94:	83 c0 40             	add    $0x40,%eax
c0106e97:	8b 40 08             	mov    0x8(%eax),%eax
c0106e9a:	83 f8 03             	cmp    $0x3,%eax
c0106e9d:	74 24                	je     c0106ec3 <default_check+0x2c1>
c0106e9f:	c7 44 24 0c 0c da 10 	movl   $0xc010da0c,0xc(%esp)
c0106ea6:	c0 
c0106ea7:	c7 44 24 08 ae d7 10 	movl   $0xc010d7ae,0x8(%esp)
c0106eae:	c0 
c0106eaf:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
c0106eb6:	00 
c0106eb7:	c7 04 24 c3 d7 10 c0 	movl   $0xc010d7c3,(%esp)
c0106ebe:	e8 42 95 ff ff       	call   c0100405 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c0106ec3:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c0106eca:	e8 a1 06 00 00       	call   c0107570 <alloc_pages>
c0106ecf:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c0106ed2:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
c0106ed6:	75 24                	jne    c0106efc <default_check+0x2fa>
c0106ed8:	c7 44 24 0c 38 da 10 	movl   $0xc010da38,0xc(%esp)
c0106edf:	c0 
c0106ee0:	c7 44 24 08 ae d7 10 	movl   $0xc010d7ae,0x8(%esp)
c0106ee7:	c0 
c0106ee8:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
c0106eef:	00 
c0106ef0:	c7 04 24 c3 d7 10 c0 	movl   $0xc010d7c3,(%esp)
c0106ef7:	e8 09 95 ff ff       	call   c0100405 <__panic>
    assert(alloc_page() == NULL);
c0106efc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106f03:	e8 68 06 00 00       	call   c0107570 <alloc_pages>
c0106f08:	85 c0                	test   %eax,%eax
c0106f0a:	74 24                	je     c0106f30 <default_check+0x32e>
c0106f0c:	c7 44 24 0c 4e d9 10 	movl   $0xc010d94e,0xc(%esp)
c0106f13:	c0 
c0106f14:	c7 44 24 08 ae d7 10 	movl   $0xc010d7ae,0x8(%esp)
c0106f1b:	c0 
c0106f1c:	c7 44 24 04 21 01 00 	movl   $0x121,0x4(%esp)
c0106f23:	00 
c0106f24:	c7 04 24 c3 d7 10 c0 	movl   $0xc010d7c3,(%esp)
c0106f2b:	e8 d5 94 ff ff       	call   c0100405 <__panic>
    assert(p0 + 2 == p1);
c0106f30:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106f33:	83 c0 40             	add    $0x40,%eax
c0106f36:	3b 45 c4             	cmp    -0x3c(%ebp),%eax
c0106f39:	74 24                	je     c0106f5f <default_check+0x35d>
c0106f3b:	c7 44 24 0c 56 da 10 	movl   $0xc010da56,0xc(%esp)
c0106f42:	c0 
c0106f43:	c7 44 24 08 ae d7 10 	movl   $0xc010d7ae,0x8(%esp)
c0106f4a:	c0 
c0106f4b:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
c0106f52:	00 
c0106f53:	c7 04 24 c3 d7 10 c0 	movl   $0xc010d7c3,(%esp)
c0106f5a:	e8 a6 94 ff ff       	call   c0100405 <__panic>

    p2 = p0 + 1;
c0106f5f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106f62:	83 c0 20             	add    $0x20,%eax
c0106f65:	89 45 c0             	mov    %eax,-0x40(%ebp)
    free_page(p0);
c0106f68:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106f6f:	00 
c0106f70:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106f73:	89 04 24             	mov    %eax,(%esp)
c0106f76:	e8 60 06 00 00       	call   c01075db <free_pages>
    free_pages(p1, 3);
c0106f7b:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0106f82:	00 
c0106f83:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0106f86:	89 04 24             	mov    %eax,(%esp)
c0106f89:	e8 4d 06 00 00       	call   c01075db <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c0106f8e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106f91:	83 c0 04             	add    $0x4,%eax
c0106f94:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c0106f9b:	89 45 94             	mov    %eax,-0x6c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106f9e:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0106fa1:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0106fa4:	0f a3 10             	bt     %edx,(%eax)
c0106fa7:	19 c0                	sbb    %eax,%eax
c0106fa9:	89 45 90             	mov    %eax,-0x70(%ebp)
    return oldbit != 0;
c0106fac:	83 7d 90 00          	cmpl   $0x0,-0x70(%ebp)
c0106fb0:	0f 95 c0             	setne  %al
c0106fb3:	0f b6 c0             	movzbl %al,%eax
c0106fb6:	85 c0                	test   %eax,%eax
c0106fb8:	74 0b                	je     c0106fc5 <default_check+0x3c3>
c0106fba:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106fbd:	8b 40 08             	mov    0x8(%eax),%eax
c0106fc0:	83 f8 01             	cmp    $0x1,%eax
c0106fc3:	74 24                	je     c0106fe9 <default_check+0x3e7>
c0106fc5:	c7 44 24 0c 64 da 10 	movl   $0xc010da64,0xc(%esp)
c0106fcc:	c0 
c0106fcd:	c7 44 24 08 ae d7 10 	movl   $0xc010d7ae,0x8(%esp)
c0106fd4:	c0 
c0106fd5:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
c0106fdc:	00 
c0106fdd:	c7 04 24 c3 d7 10 c0 	movl   $0xc010d7c3,(%esp)
c0106fe4:	e8 1c 94 ff ff       	call   c0100405 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c0106fe9:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0106fec:	83 c0 04             	add    $0x4,%eax
c0106fef:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
c0106ff6:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106ff9:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0106ffc:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0106fff:	0f a3 10             	bt     %edx,(%eax)
c0107002:	19 c0                	sbb    %eax,%eax
c0107004:	89 45 88             	mov    %eax,-0x78(%ebp)
    return oldbit != 0;
c0107007:	83 7d 88 00          	cmpl   $0x0,-0x78(%ebp)
c010700b:	0f 95 c0             	setne  %al
c010700e:	0f b6 c0             	movzbl %al,%eax
c0107011:	85 c0                	test   %eax,%eax
c0107013:	74 0b                	je     c0107020 <default_check+0x41e>
c0107015:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0107018:	8b 40 08             	mov    0x8(%eax),%eax
c010701b:	83 f8 03             	cmp    $0x3,%eax
c010701e:	74 24                	je     c0107044 <default_check+0x442>
c0107020:	c7 44 24 0c 8c da 10 	movl   $0xc010da8c,0xc(%esp)
c0107027:	c0 
c0107028:	c7 44 24 08 ae d7 10 	movl   $0xc010d7ae,0x8(%esp)
c010702f:	c0 
c0107030:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
c0107037:	00 
c0107038:	c7 04 24 c3 d7 10 c0 	movl   $0xc010d7c3,(%esp)
c010703f:	e8 c1 93 ff ff       	call   c0100405 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c0107044:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010704b:	e8 20 05 00 00       	call   c0107570 <alloc_pages>
c0107050:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0107053:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0107056:	83 e8 20             	sub    $0x20,%eax
c0107059:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c010705c:	74 24                	je     c0107082 <default_check+0x480>
c010705e:	c7 44 24 0c b2 da 10 	movl   $0xc010dab2,0xc(%esp)
c0107065:	c0 
c0107066:	c7 44 24 08 ae d7 10 	movl   $0xc010d7ae,0x8(%esp)
c010706d:	c0 
c010706e:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
c0107075:	00 
c0107076:	c7 04 24 c3 d7 10 c0 	movl   $0xc010d7c3,(%esp)
c010707d:	e8 83 93 ff ff       	call   c0100405 <__panic>
    free_page(p0);
c0107082:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107089:	00 
c010708a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010708d:	89 04 24             	mov    %eax,(%esp)
c0107090:	e8 46 05 00 00       	call   c01075db <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c0107095:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c010709c:	e8 cf 04 00 00       	call   c0107570 <alloc_pages>
c01070a1:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01070a4:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01070a7:	83 c0 20             	add    $0x20,%eax
c01070aa:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c01070ad:	74 24                	je     c01070d3 <default_check+0x4d1>
c01070af:	c7 44 24 0c d0 da 10 	movl   $0xc010dad0,0xc(%esp)
c01070b6:	c0 
c01070b7:	c7 44 24 08 ae d7 10 	movl   $0xc010d7ae,0x8(%esp)
c01070be:	c0 
c01070bf:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
c01070c6:	00 
c01070c7:	c7 04 24 c3 d7 10 c0 	movl   $0xc010d7c3,(%esp)
c01070ce:	e8 32 93 ff ff       	call   c0100405 <__panic>

    free_pages(p0, 2);
c01070d3:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c01070da:	00 
c01070db:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01070de:	89 04 24             	mov    %eax,(%esp)
c01070e1:	e8 f5 04 00 00       	call   c01075db <free_pages>
    free_page(p2);
c01070e6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01070ed:	00 
c01070ee:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01070f1:	89 04 24             	mov    %eax,(%esp)
c01070f4:	e8 e2 04 00 00       	call   c01075db <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c01070f9:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0107100:	e8 6b 04 00 00       	call   c0107570 <alloc_pages>
c0107105:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0107108:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010710c:	75 24                	jne    c0107132 <default_check+0x530>
c010710e:	c7 44 24 0c f0 da 10 	movl   $0xc010daf0,0xc(%esp)
c0107115:	c0 
c0107116:	c7 44 24 08 ae d7 10 	movl   $0xc010d7ae,0x8(%esp)
c010711d:	c0 
c010711e:	c7 44 24 04 31 01 00 	movl   $0x131,0x4(%esp)
c0107125:	00 
c0107126:	c7 04 24 c3 d7 10 c0 	movl   $0xc010d7c3,(%esp)
c010712d:	e8 d3 92 ff ff       	call   c0100405 <__panic>
    assert(alloc_page() == NULL);
c0107132:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107139:	e8 32 04 00 00       	call   c0107570 <alloc_pages>
c010713e:	85 c0                	test   %eax,%eax
c0107140:	74 24                	je     c0107166 <default_check+0x564>
c0107142:	c7 44 24 0c 4e d9 10 	movl   $0xc010d94e,0xc(%esp)
c0107149:	c0 
c010714a:	c7 44 24 08 ae d7 10 	movl   $0xc010d7ae,0x8(%esp)
c0107151:	c0 
c0107152:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
c0107159:	00 
c010715a:	c7 04 24 c3 d7 10 c0 	movl   $0xc010d7c3,(%esp)
c0107161:	e8 9f 92 ff ff       	call   c0100405 <__panic>

    assert(nr_free == 0);
c0107166:	a1 54 31 1b c0       	mov    0xc01b3154,%eax
c010716b:	85 c0                	test   %eax,%eax
c010716d:	74 24                	je     c0107193 <default_check+0x591>
c010716f:	c7 44 24 0c a1 d9 10 	movl   $0xc010d9a1,0xc(%esp)
c0107176:	c0 
c0107177:	c7 44 24 08 ae d7 10 	movl   $0xc010d7ae,0x8(%esp)
c010717e:	c0 
c010717f:	c7 44 24 04 34 01 00 	movl   $0x134,0x4(%esp)
c0107186:	00 
c0107187:	c7 04 24 c3 d7 10 c0 	movl   $0xc010d7c3,(%esp)
c010718e:	e8 72 92 ff ff       	call   c0100405 <__panic>
    nr_free = nr_free_store;
c0107193:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0107196:	a3 54 31 1b c0       	mov    %eax,0xc01b3154

    free_list = free_list_store;
c010719b:	8b 45 80             	mov    -0x80(%ebp),%eax
c010719e:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01071a1:	a3 4c 31 1b c0       	mov    %eax,0xc01b314c
c01071a6:	89 15 50 31 1b c0    	mov    %edx,0xc01b3150
    free_pages(p0, 5);
c01071ac:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c01071b3:	00 
c01071b4:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01071b7:	89 04 24             	mov    %eax,(%esp)
c01071ba:	e8 1c 04 00 00       	call   c01075db <free_pages>

    le = &free_list;
c01071bf:	c7 45 ec 4c 31 1b c0 	movl   $0xc01b314c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c01071c6:	eb 1c                	jmp    c01071e4 <default_check+0x5e2>
        struct Page *p = le2page(le, page_link);
c01071c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01071cb:	83 e8 0c             	sub    $0xc,%eax
c01071ce:	89 45 b4             	mov    %eax,-0x4c(%ebp)
        count --, total -= p->property;
c01071d1:	ff 4d f4             	decl   -0xc(%ebp)
c01071d4:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01071d7:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01071da:	8b 40 08             	mov    0x8(%eax),%eax
c01071dd:	29 c2                	sub    %eax,%edx
c01071df:	89 d0                	mov    %edx,%eax
c01071e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01071e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01071e7:	89 45 b8             	mov    %eax,-0x48(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01071ea:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01071ed:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c01071f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01071f3:	81 7d ec 4c 31 1b c0 	cmpl   $0xc01b314c,-0x14(%ebp)
c01071fa:	75 cc                	jne    c01071c8 <default_check+0x5c6>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
c01071fc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107200:	74 24                	je     c0107226 <default_check+0x624>
c0107202:	c7 44 24 0c 0e db 10 	movl   $0xc010db0e,0xc(%esp)
c0107209:	c0 
c010720a:	c7 44 24 08 ae d7 10 	movl   $0xc010d7ae,0x8(%esp)
c0107211:	c0 
c0107212:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
c0107219:	00 
c010721a:	c7 04 24 c3 d7 10 c0 	movl   $0xc010d7c3,(%esp)
c0107221:	e8 df 91 ff ff       	call   c0100405 <__panic>
    assert(total == 0);
c0107226:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010722a:	74 24                	je     c0107250 <default_check+0x64e>
c010722c:	c7 44 24 0c 19 db 10 	movl   $0xc010db19,0xc(%esp)
c0107233:	c0 
c0107234:	c7 44 24 08 ae d7 10 	movl   $0xc010d7ae,0x8(%esp)
c010723b:	c0 
c010723c:	c7 44 24 04 40 01 00 	movl   $0x140,0x4(%esp)
c0107243:	00 
c0107244:	c7 04 24 c3 d7 10 c0 	movl   $0xc010d7c3,(%esp)
c010724b:	e8 b5 91 ff ff       	call   c0100405 <__panic>
}
c0107250:	90                   	nop
c0107251:	c9                   	leave  
c0107252:	c3                   	ret    

c0107253 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0107253:	55                   	push   %ebp
c0107254:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0107256:	8b 45 08             	mov    0x8(%ebp),%eax
c0107259:	8b 15 60 31 1b c0    	mov    0xc01b3160,%edx
c010725f:	29 d0                	sub    %edx,%eax
c0107261:	c1 f8 05             	sar    $0x5,%eax
}
c0107264:	5d                   	pop    %ebp
c0107265:	c3                   	ret    

c0107266 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0107266:	55                   	push   %ebp
c0107267:	89 e5                	mov    %esp,%ebp
c0107269:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c010726c:	8b 45 08             	mov    0x8(%ebp),%eax
c010726f:	89 04 24             	mov    %eax,(%esp)
c0107272:	e8 dc ff ff ff       	call   c0107253 <page2ppn>
c0107277:	c1 e0 0c             	shl    $0xc,%eax
}
c010727a:	c9                   	leave  
c010727b:	c3                   	ret    

c010727c <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c010727c:	55                   	push   %ebp
c010727d:	89 e5                	mov    %esp,%ebp
c010727f:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0107282:	8b 45 08             	mov    0x8(%ebp),%eax
c0107285:	c1 e8 0c             	shr    $0xc,%eax
c0107288:	89 c2                	mov    %eax,%edx
c010728a:	a1 80 0f 1b c0       	mov    0xc01b0f80,%eax
c010728f:	39 c2                	cmp    %eax,%edx
c0107291:	72 1c                	jb     c01072af <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0107293:	c7 44 24 08 54 db 10 	movl   $0xc010db54,0x8(%esp)
c010729a:	c0 
c010729b:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c01072a2:	00 
c01072a3:	c7 04 24 73 db 10 c0 	movl   $0xc010db73,(%esp)
c01072aa:	e8 56 91 ff ff       	call   c0100405 <__panic>
    }
    return &pages[PPN(pa)];
c01072af:	a1 60 31 1b c0       	mov    0xc01b3160,%eax
c01072b4:	8b 55 08             	mov    0x8(%ebp),%edx
c01072b7:	c1 ea 0c             	shr    $0xc,%edx
c01072ba:	c1 e2 05             	shl    $0x5,%edx
c01072bd:	01 d0                	add    %edx,%eax
}
c01072bf:	c9                   	leave  
c01072c0:	c3                   	ret    

c01072c1 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c01072c1:	55                   	push   %ebp
c01072c2:	89 e5                	mov    %esp,%ebp
c01072c4:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c01072c7:	8b 45 08             	mov    0x8(%ebp),%eax
c01072ca:	89 04 24             	mov    %eax,(%esp)
c01072cd:	e8 94 ff ff ff       	call   c0107266 <page2pa>
c01072d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01072d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01072d8:	c1 e8 0c             	shr    $0xc,%eax
c01072db:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01072de:	a1 80 0f 1b c0       	mov    0xc01b0f80,%eax
c01072e3:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01072e6:	72 23                	jb     c010730b <page2kva+0x4a>
c01072e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01072eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01072ef:	c7 44 24 08 84 db 10 	movl   $0xc010db84,0x8(%esp)
c01072f6:	c0 
c01072f7:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c01072fe:	00 
c01072ff:	c7 04 24 73 db 10 c0 	movl   $0xc010db73,(%esp)
c0107306:	e8 fa 90 ff ff       	call   c0100405 <__panic>
c010730b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010730e:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0107313:	c9                   	leave  
c0107314:	c3                   	ret    

c0107315 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c0107315:	55                   	push   %ebp
c0107316:	89 e5                	mov    %esp,%ebp
c0107318:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c010731b:	8b 45 08             	mov    0x8(%ebp),%eax
c010731e:	83 e0 01             	and    $0x1,%eax
c0107321:	85 c0                	test   %eax,%eax
c0107323:	75 1c                	jne    c0107341 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0107325:	c7 44 24 08 a8 db 10 	movl   $0xc010dba8,0x8(%esp)
c010732c:	c0 
c010732d:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0107334:	00 
c0107335:	c7 04 24 73 db 10 c0 	movl   $0xc010db73,(%esp)
c010733c:	e8 c4 90 ff ff       	call   c0100405 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0107341:	8b 45 08             	mov    0x8(%ebp),%eax
c0107344:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107349:	89 04 24             	mov    %eax,(%esp)
c010734c:	e8 2b ff ff ff       	call   c010727c <pa2page>
}
c0107351:	c9                   	leave  
c0107352:	c3                   	ret    

c0107353 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c0107353:	55                   	push   %ebp
c0107354:	89 e5                	mov    %esp,%ebp
c0107356:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0107359:	8b 45 08             	mov    0x8(%ebp),%eax
c010735c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107361:	89 04 24             	mov    %eax,(%esp)
c0107364:	e8 13 ff ff ff       	call   c010727c <pa2page>
}
c0107369:	c9                   	leave  
c010736a:	c3                   	ret    

c010736b <page_ref>:

static inline int
page_ref(struct Page *page) {
c010736b:	55                   	push   %ebp
c010736c:	89 e5                	mov    %esp,%ebp
    return page->ref;
c010736e:	8b 45 08             	mov    0x8(%ebp),%eax
c0107371:	8b 00                	mov    (%eax),%eax
}
c0107373:	5d                   	pop    %ebp
c0107374:	c3                   	ret    

c0107375 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0107375:	55                   	push   %ebp
c0107376:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0107378:	8b 45 08             	mov    0x8(%ebp),%eax
c010737b:	8b 55 0c             	mov    0xc(%ebp),%edx
c010737e:	89 10                	mov    %edx,(%eax)
}
c0107380:	90                   	nop
c0107381:	5d                   	pop    %ebp
c0107382:	c3                   	ret    

c0107383 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0107383:	55                   	push   %ebp
c0107384:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0107386:	8b 45 08             	mov    0x8(%ebp),%eax
c0107389:	8b 00                	mov    (%eax),%eax
c010738b:	8d 50 01             	lea    0x1(%eax),%edx
c010738e:	8b 45 08             	mov    0x8(%ebp),%eax
c0107391:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0107393:	8b 45 08             	mov    0x8(%ebp),%eax
c0107396:	8b 00                	mov    (%eax),%eax
}
c0107398:	5d                   	pop    %ebp
c0107399:	c3                   	ret    

c010739a <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c010739a:	55                   	push   %ebp
c010739b:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c010739d:	8b 45 08             	mov    0x8(%ebp),%eax
c01073a0:	8b 00                	mov    (%eax),%eax
c01073a2:	8d 50 ff             	lea    -0x1(%eax),%edx
c01073a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01073a8:	89 10                	mov    %edx,(%eax)
    return page->ref;
c01073aa:	8b 45 08             	mov    0x8(%ebp),%eax
c01073ad:	8b 00                	mov    (%eax),%eax
}
c01073af:	5d                   	pop    %ebp
c01073b0:	c3                   	ret    

c01073b1 <__intr_save>:
#include <assert.h>
#include <atomic.h>
#include <sched.h>

static inline bool
__intr_save(void) {
c01073b1:	55                   	push   %ebp
c01073b2:	89 e5                	mov    %esp,%ebp
c01073b4:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c01073b7:	9c                   	pushf  
c01073b8:	58                   	pop    %eax
c01073b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01073bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01073bf:	25 00 02 00 00       	and    $0x200,%eax
c01073c4:	85 c0                	test   %eax,%eax
c01073c6:	74 0c                	je     c01073d4 <__intr_save+0x23>
        intr_disable();
c01073c8:	e8 28 ae ff ff       	call   c01021f5 <intr_disable>
        return 1;
c01073cd:	b8 01 00 00 00       	mov    $0x1,%eax
c01073d2:	eb 05                	jmp    c01073d9 <__intr_save+0x28>
    }
    return 0;
c01073d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01073d9:	c9                   	leave  
c01073da:	c3                   	ret    

c01073db <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c01073db:	55                   	push   %ebp
c01073dc:	89 e5                	mov    %esp,%ebp
c01073de:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01073e1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01073e5:	74 05                	je     c01073ec <__intr_restore+0x11>
        intr_enable();
c01073e7:	e8 02 ae ff ff       	call   c01021ee <intr_enable>
    }
}
c01073ec:	90                   	nop
c01073ed:	c9                   	leave  
c01073ee:	c3                   	ret    

c01073ef <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c01073ef:	55                   	push   %ebp
c01073f0:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c01073f2:	8b 45 08             	mov    0x8(%ebp),%eax
c01073f5:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c01073f8:	b8 23 00 00 00       	mov    $0x23,%eax
c01073fd:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c01073ff:	b8 23 00 00 00       	mov    $0x23,%eax
c0107404:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0107406:	b8 10 00 00 00       	mov    $0x10,%eax
c010740b:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c010740d:	b8 10 00 00 00       	mov    $0x10,%eax
c0107412:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0107414:	b8 10 00 00 00       	mov    $0x10,%eax
c0107419:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c010741b:	ea 22 74 10 c0 08 00 	ljmp   $0x8,$0xc0107422
}
c0107422:	90                   	nop
c0107423:	5d                   	pop    %ebp
c0107424:	c3                   	ret    

c0107425 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0107425:	55                   	push   %ebp
c0107426:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0107428:	8b 45 08             	mov    0x8(%ebp),%eax
c010742b:	a3 a4 0f 1b c0       	mov    %eax,0xc01b0fa4
}
c0107430:	90                   	nop
c0107431:	5d                   	pop    %ebp
c0107432:	c3                   	ret    

c0107433 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0107433:	55                   	push   %ebp
c0107434:	89 e5                	mov    %esp,%ebp
c0107436:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0107439:	b8 00 c0 12 c0       	mov    $0xc012c000,%eax
c010743e:	89 04 24             	mov    %eax,(%esp)
c0107441:	e8 df ff ff ff       	call   c0107425 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0107446:	66 c7 05 a8 0f 1b c0 	movw   $0x10,0xc01b0fa8
c010744d:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c010744f:	66 c7 05 68 ca 12 c0 	movw   $0x68,0xc012ca68
c0107456:	68 00 
c0107458:	b8 a0 0f 1b c0       	mov    $0xc01b0fa0,%eax
c010745d:	0f b7 c0             	movzwl %ax,%eax
c0107460:	66 a3 6a ca 12 c0    	mov    %ax,0xc012ca6a
c0107466:	b8 a0 0f 1b c0       	mov    $0xc01b0fa0,%eax
c010746b:	c1 e8 10             	shr    $0x10,%eax
c010746e:	a2 6c ca 12 c0       	mov    %al,0xc012ca6c
c0107473:	0f b6 05 6d ca 12 c0 	movzbl 0xc012ca6d,%eax
c010747a:	24 f0                	and    $0xf0,%al
c010747c:	0c 09                	or     $0x9,%al
c010747e:	a2 6d ca 12 c0       	mov    %al,0xc012ca6d
c0107483:	0f b6 05 6d ca 12 c0 	movzbl 0xc012ca6d,%eax
c010748a:	24 ef                	and    $0xef,%al
c010748c:	a2 6d ca 12 c0       	mov    %al,0xc012ca6d
c0107491:	0f b6 05 6d ca 12 c0 	movzbl 0xc012ca6d,%eax
c0107498:	24 9f                	and    $0x9f,%al
c010749a:	a2 6d ca 12 c0       	mov    %al,0xc012ca6d
c010749f:	0f b6 05 6d ca 12 c0 	movzbl 0xc012ca6d,%eax
c01074a6:	0c 80                	or     $0x80,%al
c01074a8:	a2 6d ca 12 c0       	mov    %al,0xc012ca6d
c01074ad:	0f b6 05 6e ca 12 c0 	movzbl 0xc012ca6e,%eax
c01074b4:	24 f0                	and    $0xf0,%al
c01074b6:	a2 6e ca 12 c0       	mov    %al,0xc012ca6e
c01074bb:	0f b6 05 6e ca 12 c0 	movzbl 0xc012ca6e,%eax
c01074c2:	24 ef                	and    $0xef,%al
c01074c4:	a2 6e ca 12 c0       	mov    %al,0xc012ca6e
c01074c9:	0f b6 05 6e ca 12 c0 	movzbl 0xc012ca6e,%eax
c01074d0:	24 df                	and    $0xdf,%al
c01074d2:	a2 6e ca 12 c0       	mov    %al,0xc012ca6e
c01074d7:	0f b6 05 6e ca 12 c0 	movzbl 0xc012ca6e,%eax
c01074de:	0c 40                	or     $0x40,%al
c01074e0:	a2 6e ca 12 c0       	mov    %al,0xc012ca6e
c01074e5:	0f b6 05 6e ca 12 c0 	movzbl 0xc012ca6e,%eax
c01074ec:	24 7f                	and    $0x7f,%al
c01074ee:	a2 6e ca 12 c0       	mov    %al,0xc012ca6e
c01074f3:	b8 a0 0f 1b c0       	mov    $0xc01b0fa0,%eax
c01074f8:	c1 e8 18             	shr    $0x18,%eax
c01074fb:	a2 6f ca 12 c0       	mov    %al,0xc012ca6f

    // reload all segment registers
    lgdt(&gdt_pd);
c0107500:	c7 04 24 70 ca 12 c0 	movl   $0xc012ca70,(%esp)
c0107507:	e8 e3 fe ff ff       	call   c01073ef <lgdt>
c010750c:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0107512:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0107516:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c0107519:	90                   	nop
c010751a:	c9                   	leave  
c010751b:	c3                   	ret    

c010751c <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c010751c:	55                   	push   %ebp
c010751d:	89 e5                	mov    %esp,%ebp
c010751f:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0107522:	c7 05 58 31 1b c0 38 	movl   $0xc010db38,0xc01b3158
c0107529:	db 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c010752c:	a1 58 31 1b c0       	mov    0xc01b3158,%eax
c0107531:	8b 00                	mov    (%eax),%eax
c0107533:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107537:	c7 04 24 d4 db 10 c0 	movl   $0xc010dbd4,(%esp)
c010753e:	e8 6b 8d ff ff       	call   c01002ae <cprintf>
    pmm_manager->init();
c0107543:	a1 58 31 1b c0       	mov    0xc01b3158,%eax
c0107548:	8b 40 04             	mov    0x4(%eax),%eax
c010754b:	ff d0                	call   *%eax
}
c010754d:	90                   	nop
c010754e:	c9                   	leave  
c010754f:	c3                   	ret    

c0107550 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0107550:	55                   	push   %ebp
c0107551:	89 e5                	mov    %esp,%ebp
c0107553:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0107556:	a1 58 31 1b c0       	mov    0xc01b3158,%eax
c010755b:	8b 40 08             	mov    0x8(%eax),%eax
c010755e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0107561:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107565:	8b 55 08             	mov    0x8(%ebp),%edx
c0107568:	89 14 24             	mov    %edx,(%esp)
c010756b:	ff d0                	call   *%eax
}
c010756d:	90                   	nop
c010756e:	c9                   	leave  
c010756f:	c3                   	ret    

c0107570 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0107570:	55                   	push   %ebp
c0107571:	89 e5                	mov    %esp,%ebp
c0107573:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0107576:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    
    while (1)
    {
         local_intr_save(intr_flag);
c010757d:	e8 2f fe ff ff       	call   c01073b1 <__intr_save>
c0107582:	89 45 f0             	mov    %eax,-0x10(%ebp)
         {
              page = pmm_manager->alloc_pages(n);
c0107585:	a1 58 31 1b c0       	mov    0xc01b3158,%eax
c010758a:	8b 40 0c             	mov    0xc(%eax),%eax
c010758d:	8b 55 08             	mov    0x8(%ebp),%edx
c0107590:	89 14 24             	mov    %edx,(%esp)
c0107593:	ff d0                	call   *%eax
c0107595:	89 45 f4             	mov    %eax,-0xc(%ebp)
         }
         local_intr_restore(intr_flag);
c0107598:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010759b:	89 04 24             	mov    %eax,(%esp)
c010759e:	e8 38 fe ff ff       	call   c01073db <__intr_restore>

         if (page != NULL || n > 1 || swap_init_ok == 0) break;
c01075a3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01075a7:	75 2d                	jne    c01075d6 <alloc_pages+0x66>
c01075a9:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
c01075ad:	77 27                	ja     c01075d6 <alloc_pages+0x66>
c01075af:	a1 68 0f 1b c0       	mov    0xc01b0f68,%eax
c01075b4:	85 c0                	test   %eax,%eax
c01075b6:	74 1e                	je     c01075d6 <alloc_pages+0x66>
         
         extern struct mm_struct *check_mm_struct;
         //cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
         swap_out(check_mm_struct, n, 0);
c01075b8:	8b 55 08             	mov    0x8(%ebp),%edx
c01075bb:	a1 7c 30 1b c0       	mov    0xc01b307c,%eax
c01075c0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01075c7:	00 
c01075c8:	89 54 24 04          	mov    %edx,0x4(%esp)
c01075cc:	89 04 24             	mov    %eax,(%esp)
c01075cf:	e8 0a d3 ff ff       	call   c01048de <swap_out>
    }
c01075d4:	eb a7                	jmp    c010757d <alloc_pages+0xd>
    //cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
c01075d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01075d9:	c9                   	leave  
c01075da:	c3                   	ret    

c01075db <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c01075db:	55                   	push   %ebp
c01075dc:	89 e5                	mov    %esp,%ebp
c01075de:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c01075e1:	e8 cb fd ff ff       	call   c01073b1 <__intr_save>
c01075e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c01075e9:	a1 58 31 1b c0       	mov    0xc01b3158,%eax
c01075ee:	8b 40 10             	mov    0x10(%eax),%eax
c01075f1:	8b 55 0c             	mov    0xc(%ebp),%edx
c01075f4:	89 54 24 04          	mov    %edx,0x4(%esp)
c01075f8:	8b 55 08             	mov    0x8(%ebp),%edx
c01075fb:	89 14 24             	mov    %edx,(%esp)
c01075fe:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0107600:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107603:	89 04 24             	mov    %eax,(%esp)
c0107606:	e8 d0 fd ff ff       	call   c01073db <__intr_restore>
}
c010760b:	90                   	nop
c010760c:	c9                   	leave  
c010760d:	c3                   	ret    

c010760e <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c010760e:	55                   	push   %ebp
c010760f:	89 e5                	mov    %esp,%ebp
c0107611:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0107614:	e8 98 fd ff ff       	call   c01073b1 <__intr_save>
c0107619:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c010761c:	a1 58 31 1b c0       	mov    0xc01b3158,%eax
c0107621:	8b 40 14             	mov    0x14(%eax),%eax
c0107624:	ff d0                	call   *%eax
c0107626:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0107629:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010762c:	89 04 24             	mov    %eax,(%esp)
c010762f:	e8 a7 fd ff ff       	call   c01073db <__intr_restore>
    return ret;
c0107634:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0107637:	c9                   	leave  
c0107638:	c3                   	ret    

c0107639 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0107639:	55                   	push   %ebp
c010763a:	89 e5                	mov    %esp,%ebp
c010763c:	57                   	push   %edi
c010763d:	56                   	push   %esi
c010763e:	53                   	push   %ebx
c010763f:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0107645:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c010764c:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0107653:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c010765a:	c7 04 24 eb db 10 c0 	movl   $0xc010dbeb,(%esp)
c0107661:	e8 48 8c ff ff       	call   c01002ae <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0107666:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010766d:	e9 22 01 00 00       	jmp    c0107794 <page_init+0x15b>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0107672:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0107675:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107678:	89 d0                	mov    %edx,%eax
c010767a:	c1 e0 02             	shl    $0x2,%eax
c010767d:	01 d0                	add    %edx,%eax
c010767f:	c1 e0 02             	shl    $0x2,%eax
c0107682:	01 c8                	add    %ecx,%eax
c0107684:	8b 50 08             	mov    0x8(%eax),%edx
c0107687:	8b 40 04             	mov    0x4(%eax),%eax
c010768a:	89 45 b8             	mov    %eax,-0x48(%ebp)
c010768d:	89 55 bc             	mov    %edx,-0x44(%ebp)
c0107690:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0107693:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107696:	89 d0                	mov    %edx,%eax
c0107698:	c1 e0 02             	shl    $0x2,%eax
c010769b:	01 d0                	add    %edx,%eax
c010769d:	c1 e0 02             	shl    $0x2,%eax
c01076a0:	01 c8                	add    %ecx,%eax
c01076a2:	8b 48 0c             	mov    0xc(%eax),%ecx
c01076a5:	8b 58 10             	mov    0x10(%eax),%ebx
c01076a8:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01076ab:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01076ae:	01 c8                	add    %ecx,%eax
c01076b0:	11 da                	adc    %ebx,%edx
c01076b2:	89 45 b0             	mov    %eax,-0x50(%ebp)
c01076b5:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c01076b8:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01076bb:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01076be:	89 d0                	mov    %edx,%eax
c01076c0:	c1 e0 02             	shl    $0x2,%eax
c01076c3:	01 d0                	add    %edx,%eax
c01076c5:	c1 e0 02             	shl    $0x2,%eax
c01076c8:	01 c8                	add    %ecx,%eax
c01076ca:	83 c0 14             	add    $0x14,%eax
c01076cd:	8b 00                	mov    (%eax),%eax
c01076cf:	89 45 84             	mov    %eax,-0x7c(%ebp)
c01076d2:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01076d5:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01076d8:	83 c0 ff             	add    $0xffffffff,%eax
c01076db:	83 d2 ff             	adc    $0xffffffff,%edx
c01076de:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
c01076e4:	89 95 7c ff ff ff    	mov    %edx,-0x84(%ebp)
c01076ea:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01076ed:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01076f0:	89 d0                	mov    %edx,%eax
c01076f2:	c1 e0 02             	shl    $0x2,%eax
c01076f5:	01 d0                	add    %edx,%eax
c01076f7:	c1 e0 02             	shl    $0x2,%eax
c01076fa:	01 c8                	add    %ecx,%eax
c01076fc:	8b 48 0c             	mov    0xc(%eax),%ecx
c01076ff:	8b 58 10             	mov    0x10(%eax),%ebx
c0107702:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0107705:	89 54 24 1c          	mov    %edx,0x1c(%esp)
c0107709:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
c010770f:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
c0107715:	89 44 24 14          	mov    %eax,0x14(%esp)
c0107719:	89 54 24 18          	mov    %edx,0x18(%esp)
c010771d:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0107720:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0107723:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107727:	89 54 24 10          	mov    %edx,0x10(%esp)
c010772b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c010772f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0107733:	c7 04 24 f8 db 10 c0 	movl   $0xc010dbf8,(%esp)
c010773a:	e8 6f 8b ff ff       	call   c01002ae <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c010773f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0107742:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107745:	89 d0                	mov    %edx,%eax
c0107747:	c1 e0 02             	shl    $0x2,%eax
c010774a:	01 d0                	add    %edx,%eax
c010774c:	c1 e0 02             	shl    $0x2,%eax
c010774f:	01 c8                	add    %ecx,%eax
c0107751:	83 c0 14             	add    $0x14,%eax
c0107754:	8b 00                	mov    (%eax),%eax
c0107756:	83 f8 01             	cmp    $0x1,%eax
c0107759:	75 36                	jne    c0107791 <page_init+0x158>
            if (maxpa < end && begin < KMEMSIZE) {
c010775b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010775e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107761:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0107764:	77 2b                	ja     c0107791 <page_init+0x158>
c0107766:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0107769:	72 05                	jb     c0107770 <page_init+0x137>
c010776b:	3b 45 b0             	cmp    -0x50(%ebp),%eax
c010776e:	73 21                	jae    c0107791 <page_init+0x158>
c0107770:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0107774:	77 1b                	ja     c0107791 <page_init+0x158>
c0107776:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c010777a:	72 09                	jb     c0107785 <page_init+0x14c>
c010777c:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
c0107783:	77 0c                	ja     c0107791 <page_init+0x158>
                maxpa = end;
c0107785:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0107788:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c010778b:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010778e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0107791:	ff 45 dc             	incl   -0x24(%ebp)
c0107794:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0107797:	8b 00                	mov    (%eax),%eax
c0107799:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c010779c:	0f 8f d0 fe ff ff    	jg     c0107672 <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c01077a2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01077a6:	72 1d                	jb     c01077c5 <page_init+0x18c>
c01077a8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01077ac:	77 09                	ja     c01077b7 <page_init+0x17e>
c01077ae:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c01077b5:	76 0e                	jbe    c01077c5 <page_init+0x18c>
        maxpa = KMEMSIZE;
c01077b7:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c01077be:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c01077c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01077c8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01077cb:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c01077cf:	c1 ea 0c             	shr    $0xc,%edx
c01077d2:	a3 80 0f 1b c0       	mov    %eax,0xc01b0f80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c01077d7:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
c01077de:	b8 6c 31 1b c0       	mov    $0xc01b316c,%eax
c01077e3:	8d 50 ff             	lea    -0x1(%eax),%edx
c01077e6:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01077e9:	01 d0                	add    %edx,%eax
c01077eb:	89 45 a8             	mov    %eax,-0x58(%ebp)
c01077ee:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01077f1:	ba 00 00 00 00       	mov    $0x0,%edx
c01077f6:	f7 75 ac             	divl   -0x54(%ebp)
c01077f9:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01077fc:	29 d0                	sub    %edx,%eax
c01077fe:	a3 60 31 1b c0       	mov    %eax,0xc01b3160

    for (i = 0; i < npage; i ++) {
c0107803:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010780a:	eb 26                	jmp    c0107832 <page_init+0x1f9>
        SetPageReserved(pages + i);
c010780c:	a1 60 31 1b c0       	mov    0xc01b3160,%eax
c0107811:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107814:	c1 e2 05             	shl    $0x5,%edx
c0107817:	01 d0                	add    %edx,%eax
c0107819:	83 c0 04             	add    $0x4,%eax
c010781c:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
c0107823:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0107826:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0107829:	8b 55 90             	mov    -0x70(%ebp),%edx
c010782c:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
c010782f:	ff 45 dc             	incl   -0x24(%ebp)
c0107832:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107835:	a1 80 0f 1b c0       	mov    0xc01b0f80,%eax
c010783a:	39 c2                	cmp    %eax,%edx
c010783c:	72 ce                	jb     c010780c <page_init+0x1d3>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c010783e:	a1 80 0f 1b c0       	mov    0xc01b0f80,%eax
c0107843:	c1 e0 05             	shl    $0x5,%eax
c0107846:	89 c2                	mov    %eax,%edx
c0107848:	a1 60 31 1b c0       	mov    0xc01b3160,%eax
c010784d:	01 d0                	add    %edx,%eax
c010784f:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c0107852:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
c0107859:	77 23                	ja     c010787e <page_init+0x245>
c010785b:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c010785e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107862:	c7 44 24 08 28 dc 10 	movl   $0xc010dc28,0x8(%esp)
c0107869:	c0 
c010786a:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
c0107871:	00 
c0107872:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c0107879:	e8 87 8b ff ff       	call   c0100405 <__panic>
c010787e:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0107881:	05 00 00 00 40       	add    $0x40000000,%eax
c0107886:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0107889:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0107890:	e9 61 01 00 00       	jmp    c01079f6 <page_init+0x3bd>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0107895:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0107898:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010789b:	89 d0                	mov    %edx,%eax
c010789d:	c1 e0 02             	shl    $0x2,%eax
c01078a0:	01 d0                	add    %edx,%eax
c01078a2:	c1 e0 02             	shl    $0x2,%eax
c01078a5:	01 c8                	add    %ecx,%eax
c01078a7:	8b 50 08             	mov    0x8(%eax),%edx
c01078aa:	8b 40 04             	mov    0x4(%eax),%eax
c01078ad:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01078b0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01078b3:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01078b6:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01078b9:	89 d0                	mov    %edx,%eax
c01078bb:	c1 e0 02             	shl    $0x2,%eax
c01078be:	01 d0                	add    %edx,%eax
c01078c0:	c1 e0 02             	shl    $0x2,%eax
c01078c3:	01 c8                	add    %ecx,%eax
c01078c5:	8b 48 0c             	mov    0xc(%eax),%ecx
c01078c8:	8b 58 10             	mov    0x10(%eax),%ebx
c01078cb:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01078ce:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01078d1:	01 c8                	add    %ecx,%eax
c01078d3:	11 da                	adc    %ebx,%edx
c01078d5:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01078d8:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c01078db:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01078de:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01078e1:	89 d0                	mov    %edx,%eax
c01078e3:	c1 e0 02             	shl    $0x2,%eax
c01078e6:	01 d0                	add    %edx,%eax
c01078e8:	c1 e0 02             	shl    $0x2,%eax
c01078eb:	01 c8                	add    %ecx,%eax
c01078ed:	83 c0 14             	add    $0x14,%eax
c01078f0:	8b 00                	mov    (%eax),%eax
c01078f2:	83 f8 01             	cmp    $0x1,%eax
c01078f5:	0f 85 f8 00 00 00    	jne    c01079f3 <page_init+0x3ba>
            if (begin < freemem) {
c01078fb:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01078fe:	ba 00 00 00 00       	mov    $0x0,%edx
c0107903:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0107906:	72 17                	jb     c010791f <page_init+0x2e6>
c0107908:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010790b:	77 05                	ja     c0107912 <page_init+0x2d9>
c010790d:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0107910:	76 0d                	jbe    c010791f <page_init+0x2e6>
                begin = freemem;
c0107912:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0107915:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0107918:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c010791f:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0107923:	72 1d                	jb     c0107942 <page_init+0x309>
c0107925:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0107929:	77 09                	ja     c0107934 <page_init+0x2fb>
c010792b:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c0107932:	76 0e                	jbe    c0107942 <page_init+0x309>
                end = KMEMSIZE;
c0107934:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c010793b:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0107942:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107945:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107948:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c010794b:	0f 87 a2 00 00 00    	ja     c01079f3 <page_init+0x3ba>
c0107951:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0107954:	72 09                	jb     c010795f <page_init+0x326>
c0107956:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0107959:	0f 83 94 00 00 00    	jae    c01079f3 <page_init+0x3ba>
                begin = ROUNDUP(begin, PGSIZE);
c010795f:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
c0107966:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0107969:	8b 45 9c             	mov    -0x64(%ebp),%eax
c010796c:	01 d0                	add    %edx,%eax
c010796e:	48                   	dec    %eax
c010796f:	89 45 98             	mov    %eax,-0x68(%ebp)
c0107972:	8b 45 98             	mov    -0x68(%ebp),%eax
c0107975:	ba 00 00 00 00       	mov    $0x0,%edx
c010797a:	f7 75 9c             	divl   -0x64(%ebp)
c010797d:	8b 45 98             	mov    -0x68(%ebp),%eax
c0107980:	29 d0                	sub    %edx,%eax
c0107982:	ba 00 00 00 00       	mov    $0x0,%edx
c0107987:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010798a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c010798d:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0107990:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0107993:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0107996:	ba 00 00 00 00       	mov    $0x0,%edx
c010799b:	89 c3                	mov    %eax,%ebx
c010799d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
c01079a3:	89 de                	mov    %ebx,%esi
c01079a5:	89 d0                	mov    %edx,%eax
c01079a7:	83 e0 00             	and    $0x0,%eax
c01079aa:	89 c7                	mov    %eax,%edi
c01079ac:	89 75 c8             	mov    %esi,-0x38(%ebp)
c01079af:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
c01079b2:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01079b5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01079b8:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c01079bb:	77 36                	ja     c01079f3 <page_init+0x3ba>
c01079bd:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c01079c0:	72 05                	jb     c01079c7 <page_init+0x38e>
c01079c2:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c01079c5:	73 2c                	jae    c01079f3 <page_init+0x3ba>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c01079c7:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01079ca:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01079cd:	2b 45 d0             	sub    -0x30(%ebp),%eax
c01079d0:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c01079d3:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c01079d7:	c1 ea 0c             	shr    $0xc,%edx
c01079da:	89 c3                	mov    %eax,%ebx
c01079dc:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01079df:	89 04 24             	mov    %eax,(%esp)
c01079e2:	e8 95 f8 ff ff       	call   c010727c <pa2page>
c01079e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01079eb:	89 04 24             	mov    %eax,(%esp)
c01079ee:	e8 5d fb ff ff       	call   c0107550 <init_memmap>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
c01079f3:	ff 45 dc             	incl   -0x24(%ebp)
c01079f6:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01079f9:	8b 00                	mov    (%eax),%eax
c01079fb:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c01079fe:	0f 8f 91 fe ff ff    	jg     c0107895 <page_init+0x25c>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
c0107a04:	90                   	nop
c0107a05:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c0107a0b:	5b                   	pop    %ebx
c0107a0c:	5e                   	pop    %esi
c0107a0d:	5f                   	pop    %edi
c0107a0e:	5d                   	pop    %ebp
c0107a0f:	c3                   	ret    

c0107a10 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c0107a10:	55                   	push   %ebp
c0107a11:	89 e5                	mov    %esp,%ebp
c0107a13:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0107a16:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107a19:	33 45 14             	xor    0x14(%ebp),%eax
c0107a1c:	25 ff 0f 00 00       	and    $0xfff,%eax
c0107a21:	85 c0                	test   %eax,%eax
c0107a23:	74 24                	je     c0107a49 <boot_map_segment+0x39>
c0107a25:	c7 44 24 0c 5a dc 10 	movl   $0xc010dc5a,0xc(%esp)
c0107a2c:	c0 
c0107a2d:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c0107a34:	c0 
c0107a35:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
c0107a3c:	00 
c0107a3d:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c0107a44:	e8 bc 89 ff ff       	call   c0100405 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c0107a49:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c0107a50:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107a53:	25 ff 0f 00 00       	and    $0xfff,%eax
c0107a58:	89 c2                	mov    %eax,%edx
c0107a5a:	8b 45 10             	mov    0x10(%ebp),%eax
c0107a5d:	01 c2                	add    %eax,%edx
c0107a5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107a62:	01 d0                	add    %edx,%eax
c0107a64:	48                   	dec    %eax
c0107a65:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107a68:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107a6b:	ba 00 00 00 00       	mov    $0x0,%edx
c0107a70:	f7 75 f0             	divl   -0x10(%ebp)
c0107a73:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107a76:	29 d0                	sub    %edx,%eax
c0107a78:	c1 e8 0c             	shr    $0xc,%eax
c0107a7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c0107a7e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107a81:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107a84:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107a87:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107a8c:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c0107a8f:	8b 45 14             	mov    0x14(%ebp),%eax
c0107a92:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107a95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107a98:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107a9d:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0107aa0:	eb 68                	jmp    c0107b0a <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
c0107aa2:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0107aa9:	00 
c0107aaa:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107aad:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107ab1:	8b 45 08             	mov    0x8(%ebp),%eax
c0107ab4:	89 04 24             	mov    %eax,(%esp)
c0107ab7:	e8 86 01 00 00       	call   c0107c42 <get_pte>
c0107abc:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c0107abf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0107ac3:	75 24                	jne    c0107ae9 <boot_map_segment+0xd9>
c0107ac5:	c7 44 24 0c 86 dc 10 	movl   $0xc010dc86,0xc(%esp)
c0107acc:	c0 
c0107acd:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c0107ad4:	c0 
c0107ad5:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
c0107adc:	00 
c0107add:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c0107ae4:	e8 1c 89 ff ff       	call   c0100405 <__panic>
        *ptep = pa | PTE_P | perm;
c0107ae9:	8b 45 14             	mov    0x14(%ebp),%eax
c0107aec:	0b 45 18             	or     0x18(%ebp),%eax
c0107aef:	83 c8 01             	or     $0x1,%eax
c0107af2:	89 c2                	mov    %eax,%edx
c0107af4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107af7:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0107af9:	ff 4d f4             	decl   -0xc(%ebp)
c0107afc:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c0107b03:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0107b0a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107b0e:	75 92                	jne    c0107aa2 <boot_map_segment+0x92>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
c0107b10:	90                   	nop
c0107b11:	c9                   	leave  
c0107b12:	c3                   	ret    

c0107b13 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c0107b13:	55                   	push   %ebp
c0107b14:	89 e5                	mov    %esp,%ebp
c0107b16:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c0107b19:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107b20:	e8 4b fa ff ff       	call   c0107570 <alloc_pages>
c0107b25:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c0107b28:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107b2c:	75 1c                	jne    c0107b4a <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c0107b2e:	c7 44 24 08 93 dc 10 	movl   $0xc010dc93,0x8(%esp)
c0107b35:	c0 
c0107b36:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c0107b3d:	00 
c0107b3e:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c0107b45:	e8 bb 88 ff ff       	call   c0100405 <__panic>
    }
    return page2kva(p);
c0107b4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107b4d:	89 04 24             	mov    %eax,(%esp)
c0107b50:	e8 6c f7 ff ff       	call   c01072c1 <page2kva>
}
c0107b55:	c9                   	leave  
c0107b56:	c3                   	ret    

c0107b57 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c0107b57:	55                   	push   %ebp
c0107b58:	89 e5                	mov    %esp,%ebp
c0107b5a:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c0107b5d:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c0107b62:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107b65:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0107b6c:	77 23                	ja     c0107b91 <pmm_init+0x3a>
c0107b6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107b71:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107b75:	c7 44 24 08 28 dc 10 	movl   $0xc010dc28,0x8(%esp)
c0107b7c:	c0 
c0107b7d:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
c0107b84:	00 
c0107b85:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c0107b8c:	e8 74 88 ff ff       	call   c0100405 <__panic>
c0107b91:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107b94:	05 00 00 00 40       	add    $0x40000000,%eax
c0107b99:	a3 5c 31 1b c0       	mov    %eax,0xc01b315c
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c0107b9e:	e8 79 f9 ff ff       	call   c010751c <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c0107ba3:	e8 91 fa ff ff       	call   c0107639 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0107ba8:	e8 d7 08 00 00       	call   c0108484 <check_alloc_page>

    check_pgdir();
c0107bad:	e8 f1 08 00 00       	call   c01084a3 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c0107bb2:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c0107bb7:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c0107bbd:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c0107bc2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107bc5:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0107bcc:	77 23                	ja     c0107bf1 <pmm_init+0x9a>
c0107bce:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107bd1:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107bd5:	c7 44 24 08 28 dc 10 	movl   $0xc010dc28,0x8(%esp)
c0107bdc:	c0 
c0107bdd:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
c0107be4:	00 
c0107be5:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c0107bec:	e8 14 88 ff ff       	call   c0100405 <__panic>
c0107bf1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107bf4:	05 00 00 00 40       	add    $0x40000000,%eax
c0107bf9:	83 c8 03             	or     $0x3,%eax
c0107bfc:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0107bfe:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c0107c03:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c0107c0a:	00 
c0107c0b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0107c12:	00 
c0107c13:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c0107c1a:	38 
c0107c1b:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c0107c22:	c0 
c0107c23:	89 04 24             	mov    %eax,(%esp)
c0107c26:	e8 e5 fd ff ff       	call   c0107a10 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c0107c2b:	e8 03 f8 ff ff       	call   c0107433 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c0107c30:	e8 0a 0f 00 00       	call   c0108b3f <check_boot_pgdir>

    print_pgdir();
c0107c35:	e8 83 13 00 00       	call   c0108fbd <print_pgdir>
    
    kmalloc_init();
c0107c3a:	e8 11 dc ff ff       	call   c0105850 <kmalloc_init>

}
c0107c3f:	90                   	nop
c0107c40:	c9                   	leave  
c0107c41:	c3                   	ret    

c0107c42 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c0107c42:	55                   	push   %ebp
c0107c43:	89 e5                	mov    %esp,%ebp
c0107c45:	83 ec 38             	sub    $0x38,%esp
    pde_t *pdep = &pgdir[PDX(la)];  //尝试获得页表
c0107c48:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107c4b:	c1 e8 16             	shr    $0x16,%eax
c0107c4e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0107c55:	8b 45 08             	mov    0x8(%ebp),%eax
c0107c58:	01 d0                	add    %edx,%eax
c0107c5a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) { //如果获取不成功
c0107c5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107c60:	8b 00                	mov    (%eax),%eax
c0107c62:	83 e0 01             	and    $0x1,%eax
c0107c65:	85 c0                	test   %eax,%eax
c0107c67:	0f 85 af 00 00 00    	jne    c0107d1c <get_pte+0xda>
        struct Page *page;
        //假如不需要分配或是分配失败
        if (!create || (page = alloc_page()) == NULL) {
c0107c6d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0107c71:	74 15                	je     c0107c88 <get_pte+0x46>
c0107c73:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107c7a:	e8 f1 f8 ff ff       	call   c0107570 <alloc_pages>
c0107c7f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107c82:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107c86:	75 0a                	jne    c0107c92 <get_pte+0x50>
            return NULL;
c0107c88:	b8 00 00 00 00       	mov    $0x0,%eax
c0107c8d:	e9 e7 00 00 00       	jmp    c0107d79 <get_pte+0x137>
        }
        set_page_ref(page, 1); //引用次数加一
c0107c92:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107c99:	00 
c0107c9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107c9d:	89 04 24             	mov    %eax,(%esp)
c0107ca0:	e8 d0 f6 ff ff       	call   c0107375 <set_page_ref>
        uintptr_t pa = page2pa(page);  //得到该页物理地址
c0107ca5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107ca8:	89 04 24             	mov    %eax,(%esp)
c0107cab:	e8 b6 f5 ff ff       	call   c0107266 <page2pa>
c0107cb0:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE); //物理地址转虚拟地址，并初始化
c0107cb3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107cb6:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107cb9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107cbc:	c1 e8 0c             	shr    $0xc,%eax
c0107cbf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107cc2:	a1 80 0f 1b c0       	mov    0xc01b0f80,%eax
c0107cc7:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0107cca:	72 23                	jb     c0107cef <get_pte+0xad>
c0107ccc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107ccf:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107cd3:	c7 44 24 08 84 db 10 	movl   $0xc010db84,0x8(%esp)
c0107cda:	c0 
c0107cdb:	c7 44 24 04 62 01 00 	movl   $0x162,0x4(%esp)
c0107ce2:	00 
c0107ce3:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c0107cea:	e8 16 87 ff ff       	call   c0100405 <__panic>
c0107cef:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107cf2:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0107cf7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0107cfe:	00 
c0107cff:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0107d06:	00 
c0107d07:	89 04 24             	mov    %eax,(%esp)
c0107d0a:	e8 77 3c 00 00       	call   c010b986 <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P; //设置控制位
c0107d0f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107d12:	83 c8 07             	or     $0x7,%eax
c0107d15:	89 c2                	mov    %eax,%edx
c0107d17:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107d1a:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c0107d1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107d1f:	8b 00                	mov    (%eax),%eax
c0107d21:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107d26:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0107d29:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107d2c:	c1 e8 0c             	shr    $0xc,%eax
c0107d2f:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0107d32:	a1 80 0f 1b c0       	mov    0xc01b0f80,%eax
c0107d37:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0107d3a:	72 23                	jb     c0107d5f <get_pte+0x11d>
c0107d3c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107d3f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107d43:	c7 44 24 08 84 db 10 	movl   $0xc010db84,0x8(%esp)
c0107d4a:	c0 
c0107d4b:	c7 44 24 04 65 01 00 	movl   $0x165,0x4(%esp)
c0107d52:	00 
c0107d53:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c0107d5a:	e8 a6 86 ff ff       	call   c0100405 <__panic>
c0107d5f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107d62:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0107d67:	89 c2                	mov    %eax,%edx
c0107d69:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107d6c:	c1 e8 0c             	shr    $0xc,%eax
c0107d6f:	25 ff 03 00 00       	and    $0x3ff,%eax
c0107d74:	c1 e0 02             	shl    $0x2,%eax
c0107d77:	01 d0                	add    %edx,%eax
    //KADDR(PDE_ADDR(*pdep)):这部分是由页目录项地址得到关联的页表物理地址， 再转成虚拟地址
    //PTX(la)：返回虚拟地址la的页表项索引
    //最后返回的是虚拟地址la对应的页表项入口地址
}
c0107d79:	c9                   	leave  
c0107d7a:	c3                   	ret    

c0107d7b <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c0107d7b:	55                   	push   %ebp
c0107d7c:	89 e5                	mov    %esp,%ebp
c0107d7e:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0107d81:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107d88:	00 
c0107d89:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107d8c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107d90:	8b 45 08             	mov    0x8(%ebp),%eax
c0107d93:	89 04 24             	mov    %eax,(%esp)
c0107d96:	e8 a7 fe ff ff       	call   c0107c42 <get_pte>
c0107d9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c0107d9e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0107da2:	74 08                	je     c0107dac <get_page+0x31>
        *ptep_store = ptep;
c0107da4:	8b 45 10             	mov    0x10(%ebp),%eax
c0107da7:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107daa:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c0107dac:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107db0:	74 1b                	je     c0107dcd <get_page+0x52>
c0107db2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107db5:	8b 00                	mov    (%eax),%eax
c0107db7:	83 e0 01             	and    $0x1,%eax
c0107dba:	85 c0                	test   %eax,%eax
c0107dbc:	74 0f                	je     c0107dcd <get_page+0x52>
        return pte2page(*ptep);
c0107dbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107dc1:	8b 00                	mov    (%eax),%eax
c0107dc3:	89 04 24             	mov    %eax,(%esp)
c0107dc6:	e8 4a f5 ff ff       	call   c0107315 <pte2page>
c0107dcb:	eb 05                	jmp    c0107dd2 <get_page+0x57>
    }
    return NULL;
c0107dcd:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107dd2:	c9                   	leave  
c0107dd3:	c3                   	ret    

c0107dd4 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0107dd4:	55                   	push   %ebp
c0107dd5:	89 e5                	mov    %esp,%ebp
c0107dd7:	83 ec 28             	sub    $0x28,%esp
    if (*ptep & PTE_P) { // 二级页表项存在
c0107dda:	8b 45 10             	mov    0x10(%ebp),%eax
c0107ddd:	8b 00                	mov    (%eax),%eax
c0107ddf:	83 e0 01             	and    $0x1,%eax
c0107de2:	85 c0                	test   %eax,%eax
c0107de4:	74 4d                	je     c0107e33 <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep); //找到页表项
c0107de6:	8b 45 10             	mov    0x10(%ebp),%eax
c0107de9:	8b 00                	mov    (%eax),%eax
c0107deb:	89 04 24             	mov    %eax,(%esp)
c0107dee:	e8 22 f5 ff ff       	call   c0107315 <pte2page>
c0107df3:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) { // 此页的被引用数为0，即无其他进程对此页进行引用
c0107df6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107df9:	89 04 24             	mov    %eax,(%esp)
c0107dfc:	e8 99 f5 ff ff       	call   c010739a <page_ref_dec>
c0107e01:	85 c0                	test   %eax,%eax
c0107e03:	75 13                	jne    c0107e18 <page_remove_pte+0x44>
            free_page(page);
c0107e05:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107e0c:	00 
c0107e0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107e10:	89 04 24             	mov    %eax,(%esp)
c0107e13:	e8 c3 f7 ff ff       	call   c01075db <free_pages>
        }
        *ptep = 0; // 该页目录项清零
c0107e18:	8b 45 10             	mov    0x10(%ebp),%eax
c0107e1b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la); //当修改的页表是进程正在使用的那些页表，使之无效。
c0107e21:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107e24:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107e28:	8b 45 08             	mov    0x8(%ebp),%eax
c0107e2b:	89 04 24             	mov    %eax,(%esp)
c0107e2e:	e8 21 05 00 00       	call   c0108354 <tlb_invalidate>
    }
}
c0107e33:	90                   	nop
c0107e34:	c9                   	leave  
c0107e35:	c3                   	ret    

c0107e36 <unmap_range>:

void
unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
c0107e36:	55                   	push   %ebp
c0107e37:	89 e5                	mov    %esp,%ebp
c0107e39:	83 ec 28             	sub    $0x28,%esp
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
c0107e3c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107e3f:	25 ff 0f 00 00       	and    $0xfff,%eax
c0107e44:	85 c0                	test   %eax,%eax
c0107e46:	75 0c                	jne    c0107e54 <unmap_range+0x1e>
c0107e48:	8b 45 10             	mov    0x10(%ebp),%eax
c0107e4b:	25 ff 0f 00 00       	and    $0xfff,%eax
c0107e50:	85 c0                	test   %eax,%eax
c0107e52:	74 24                	je     c0107e78 <unmap_range+0x42>
c0107e54:	c7 44 24 0c ac dc 10 	movl   $0xc010dcac,0xc(%esp)
c0107e5b:	c0 
c0107e5c:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c0107e63:	c0 
c0107e64:	c7 44 24 04 89 01 00 	movl   $0x189,0x4(%esp)
c0107e6b:	00 
c0107e6c:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c0107e73:	e8 8d 85 ff ff       	call   c0100405 <__panic>
    assert(USER_ACCESS(start, end));
c0107e78:	81 7d 0c ff ff 1f 00 	cmpl   $0x1fffff,0xc(%ebp)
c0107e7f:	76 11                	jbe    c0107e92 <unmap_range+0x5c>
c0107e81:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107e84:	3b 45 10             	cmp    0x10(%ebp),%eax
c0107e87:	73 09                	jae    c0107e92 <unmap_range+0x5c>
c0107e89:	81 7d 10 00 00 00 b0 	cmpl   $0xb0000000,0x10(%ebp)
c0107e90:	76 24                	jbe    c0107eb6 <unmap_range+0x80>
c0107e92:	c7 44 24 0c d5 dc 10 	movl   $0xc010dcd5,0xc(%esp)
c0107e99:	c0 
c0107e9a:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c0107ea1:	c0 
c0107ea2:	c7 44 24 04 8a 01 00 	movl   $0x18a,0x4(%esp)
c0107ea9:	00 
c0107eaa:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c0107eb1:	e8 4f 85 ff ff       	call   c0100405 <__panic>

    do {
        pte_t *ptep = get_pte(pgdir, start, 0);
c0107eb6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107ebd:	00 
c0107ebe:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107ec1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107ec5:	8b 45 08             	mov    0x8(%ebp),%eax
c0107ec8:	89 04 24             	mov    %eax,(%esp)
c0107ecb:	e8 72 fd ff ff       	call   c0107c42 <get_pte>
c0107ed0:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (ptep == NULL) {
c0107ed3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107ed7:	75 18                	jne    c0107ef1 <unmap_range+0xbb>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
c0107ed9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107edc:	05 00 00 40 00       	add    $0x400000,%eax
c0107ee1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107ee4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107ee7:	25 00 00 c0 ff       	and    $0xffc00000,%eax
c0107eec:	89 45 0c             	mov    %eax,0xc(%ebp)
            continue ;
c0107eef:	eb 29                	jmp    c0107f1a <unmap_range+0xe4>
        }
        if (*ptep != 0) {
c0107ef1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107ef4:	8b 00                	mov    (%eax),%eax
c0107ef6:	85 c0                	test   %eax,%eax
c0107ef8:	74 19                	je     c0107f13 <unmap_range+0xdd>
            page_remove_pte(pgdir, start, ptep);
c0107efa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107efd:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107f01:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107f04:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107f08:	8b 45 08             	mov    0x8(%ebp),%eax
c0107f0b:	89 04 24             	mov    %eax,(%esp)
c0107f0e:	e8 c1 fe ff ff       	call   c0107dd4 <page_remove_pte>
        }
        start += PGSIZE;
c0107f13:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
    } while (start != 0 && start < end);
c0107f1a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0107f1e:	74 08                	je     c0107f28 <unmap_range+0xf2>
c0107f20:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107f23:	3b 45 10             	cmp    0x10(%ebp),%eax
c0107f26:	72 8e                	jb     c0107eb6 <unmap_range+0x80>
}
c0107f28:	90                   	nop
c0107f29:	c9                   	leave  
c0107f2a:	c3                   	ret    

c0107f2b <exit_range>:

void
exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
c0107f2b:	55                   	push   %ebp
c0107f2c:	89 e5                	mov    %esp,%ebp
c0107f2e:	83 ec 28             	sub    $0x28,%esp
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
c0107f31:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107f34:	25 ff 0f 00 00       	and    $0xfff,%eax
c0107f39:	85 c0                	test   %eax,%eax
c0107f3b:	75 0c                	jne    c0107f49 <exit_range+0x1e>
c0107f3d:	8b 45 10             	mov    0x10(%ebp),%eax
c0107f40:	25 ff 0f 00 00       	and    $0xfff,%eax
c0107f45:	85 c0                	test   %eax,%eax
c0107f47:	74 24                	je     c0107f6d <exit_range+0x42>
c0107f49:	c7 44 24 0c ac dc 10 	movl   $0xc010dcac,0xc(%esp)
c0107f50:	c0 
c0107f51:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c0107f58:	c0 
c0107f59:	c7 44 24 04 9b 01 00 	movl   $0x19b,0x4(%esp)
c0107f60:	00 
c0107f61:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c0107f68:	e8 98 84 ff ff       	call   c0100405 <__panic>
    assert(USER_ACCESS(start, end));
c0107f6d:	81 7d 0c ff ff 1f 00 	cmpl   $0x1fffff,0xc(%ebp)
c0107f74:	76 11                	jbe    c0107f87 <exit_range+0x5c>
c0107f76:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107f79:	3b 45 10             	cmp    0x10(%ebp),%eax
c0107f7c:	73 09                	jae    c0107f87 <exit_range+0x5c>
c0107f7e:	81 7d 10 00 00 00 b0 	cmpl   $0xb0000000,0x10(%ebp)
c0107f85:	76 24                	jbe    c0107fab <exit_range+0x80>
c0107f87:	c7 44 24 0c d5 dc 10 	movl   $0xc010dcd5,0xc(%esp)
c0107f8e:	c0 
c0107f8f:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c0107f96:	c0 
c0107f97:	c7 44 24 04 9c 01 00 	movl   $0x19c,0x4(%esp)
c0107f9e:	00 
c0107f9f:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c0107fa6:	e8 5a 84 ff ff       	call   c0100405 <__panic>

    start = ROUNDDOWN(start, PTSIZE);
c0107fab:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107fae:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107fb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107fb4:	25 00 00 c0 ff       	and    $0xffc00000,%eax
c0107fb9:	89 45 0c             	mov    %eax,0xc(%ebp)
    do {
        int pde_idx = PDX(start);
c0107fbc:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107fbf:	c1 e8 16             	shr    $0x16,%eax
c0107fc2:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (pgdir[pde_idx] & PTE_P) {
c0107fc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107fc8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0107fcf:	8b 45 08             	mov    0x8(%ebp),%eax
c0107fd2:	01 d0                	add    %edx,%eax
c0107fd4:	8b 00                	mov    (%eax),%eax
c0107fd6:	83 e0 01             	and    $0x1,%eax
c0107fd9:	85 c0                	test   %eax,%eax
c0107fdb:	74 3e                	je     c010801b <exit_range+0xf0>
            free_page(pde2page(pgdir[pde_idx]));
c0107fdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107fe0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0107fe7:	8b 45 08             	mov    0x8(%ebp),%eax
c0107fea:	01 d0                	add    %edx,%eax
c0107fec:	8b 00                	mov    (%eax),%eax
c0107fee:	89 04 24             	mov    %eax,(%esp)
c0107ff1:	e8 5d f3 ff ff       	call   c0107353 <pde2page>
c0107ff6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107ffd:	00 
c0107ffe:	89 04 24             	mov    %eax,(%esp)
c0108001:	e8 d5 f5 ff ff       	call   c01075db <free_pages>
            pgdir[pde_idx] = 0;
c0108006:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108009:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0108010:	8b 45 08             	mov    0x8(%ebp),%eax
c0108013:	01 d0                	add    %edx,%eax
c0108015:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        }
        start += PTSIZE;
c010801b:	81 45 0c 00 00 40 00 	addl   $0x400000,0xc(%ebp)
    } while (start != 0 && start < end);
c0108022:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0108026:	74 08                	je     c0108030 <exit_range+0x105>
c0108028:	8b 45 0c             	mov    0xc(%ebp),%eax
c010802b:	3b 45 10             	cmp    0x10(%ebp),%eax
c010802e:	72 8c                	jb     c0107fbc <exit_range+0x91>
}
c0108030:	90                   	nop
c0108031:	c9                   	leave  
c0108032:	c3                   	ret    

c0108033 <copy_range>:
 * @share: flags to indicate to dup OR share. We just use dup method, so it didn't be used.
 *
 * CALL GRAPH: copy_mm-->dup_mmap-->copy_range
 */
int
copy_range(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end, bool share) {
c0108033:	55                   	push   %ebp
c0108034:	89 e5                	mov    %esp,%ebp
c0108036:	83 ec 48             	sub    $0x48,%esp
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
c0108039:	8b 45 10             	mov    0x10(%ebp),%eax
c010803c:	25 ff 0f 00 00       	and    $0xfff,%eax
c0108041:	85 c0                	test   %eax,%eax
c0108043:	75 0c                	jne    c0108051 <copy_range+0x1e>
c0108045:	8b 45 14             	mov    0x14(%ebp),%eax
c0108048:	25 ff 0f 00 00       	and    $0xfff,%eax
c010804d:	85 c0                	test   %eax,%eax
c010804f:	74 24                	je     c0108075 <copy_range+0x42>
c0108051:	c7 44 24 0c ac dc 10 	movl   $0xc010dcac,0xc(%esp)
c0108058:	c0 
c0108059:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c0108060:	c0 
c0108061:	c7 44 24 04 b1 01 00 	movl   $0x1b1,0x4(%esp)
c0108068:	00 
c0108069:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c0108070:	e8 90 83 ff ff       	call   c0100405 <__panic>
    assert(USER_ACCESS(start, end));
c0108075:	81 7d 10 ff ff 1f 00 	cmpl   $0x1fffff,0x10(%ebp)
c010807c:	76 11                	jbe    c010808f <copy_range+0x5c>
c010807e:	8b 45 10             	mov    0x10(%ebp),%eax
c0108081:	3b 45 14             	cmp    0x14(%ebp),%eax
c0108084:	73 09                	jae    c010808f <copy_range+0x5c>
c0108086:	81 7d 14 00 00 00 b0 	cmpl   $0xb0000000,0x14(%ebp)
c010808d:	76 24                	jbe    c01080b3 <copy_range+0x80>
c010808f:	c7 44 24 0c d5 dc 10 	movl   $0xc010dcd5,0xc(%esp)
c0108096:	c0 
c0108097:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c010809e:	c0 
c010809f:	c7 44 24 04 b2 01 00 	movl   $0x1b2,0x4(%esp)
c01080a6:	00 
c01080a7:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c01080ae:	e8 52 83 ff ff       	call   c0100405 <__panic>
    // copy content by page unit.
    do {
        //call get_pte to find process A's pte according to the addr start
        pte_t *ptep = get_pte(from, start, 0), *nptep;
c01080b3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01080ba:	00 
c01080bb:	8b 45 10             	mov    0x10(%ebp),%eax
c01080be:	89 44 24 04          	mov    %eax,0x4(%esp)
c01080c2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01080c5:	89 04 24             	mov    %eax,(%esp)
c01080c8:	e8 75 fb ff ff       	call   c0107c42 <get_pte>
c01080cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (ptep == NULL) {
c01080d0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01080d4:	75 1b                	jne    c01080f1 <copy_range+0xbe>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
c01080d6:	8b 45 10             	mov    0x10(%ebp),%eax
c01080d9:	05 00 00 40 00       	add    $0x400000,%eax
c01080de:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01080e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01080e4:	25 00 00 c0 ff       	and    $0xffc00000,%eax
c01080e9:	89 45 10             	mov    %eax,0x10(%ebp)
            continue ;
c01080ec:	e9 4c 01 00 00       	jmp    c010823d <copy_range+0x20a>
        }
        //call get_pte to find process B's pte according to the addr start. If pte is NULL, just alloc a PT
        if (*ptep & PTE_P) {
c01080f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01080f4:	8b 00                	mov    (%eax),%eax
c01080f6:	83 e0 01             	and    $0x1,%eax
c01080f9:	85 c0                	test   %eax,%eax
c01080fb:	0f 84 35 01 00 00    	je     c0108236 <copy_range+0x203>
            if ((nptep = get_pte(to, start, 1)) == NULL) {
c0108101:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0108108:	00 
c0108109:	8b 45 10             	mov    0x10(%ebp),%eax
c010810c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108110:	8b 45 08             	mov    0x8(%ebp),%eax
c0108113:	89 04 24             	mov    %eax,(%esp)
c0108116:	e8 27 fb ff ff       	call   c0107c42 <get_pte>
c010811b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010811e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0108122:	75 0a                	jne    c010812e <copy_range+0xfb>
                return -E_NO_MEM;
c0108124:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0108129:	e9 26 01 00 00       	jmp    c0108254 <copy_range+0x221>
            }
        uint32_t perm = (*ptep & PTE_USER);
c010812e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108131:	8b 00                	mov    (%eax),%eax
c0108133:	83 e0 07             	and    $0x7,%eax
c0108136:	89 45 e8             	mov    %eax,-0x18(%ebp)
        //get page from ptep
        struct Page *page = pte2page(*ptep);
c0108139:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010813c:	8b 00                	mov    (%eax),%eax
c010813e:	89 04 24             	mov    %eax,(%esp)
c0108141:	e8 cf f1 ff ff       	call   c0107315 <pte2page>
c0108146:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        // alloc a page for process B
        struct Page *npage=alloc_page();
c0108149:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108150:	e8 1b f4 ff ff       	call   c0107570 <alloc_pages>
c0108155:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(page!=NULL);
c0108158:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010815c:	75 24                	jne    c0108182 <copy_range+0x14f>
c010815e:	c7 44 24 0c ed dc 10 	movl   $0xc010dced,0xc(%esp)
c0108165:	c0 
c0108166:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c010816d:	c0 
c010816e:	c7 44 24 04 c5 01 00 	movl   $0x1c5,0x4(%esp)
c0108175:	00 
c0108176:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c010817d:	e8 83 82 ff ff       	call   c0100405 <__panic>
        assert(npage!=NULL);
c0108182:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0108186:	75 24                	jne    c01081ac <copy_range+0x179>
c0108188:	c7 44 24 0c f8 dc 10 	movl   $0xc010dcf8,0xc(%esp)
c010818f:	c0 
c0108190:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c0108197:	c0 
c0108198:	c7 44 24 04 c6 01 00 	movl   $0x1c6,0x4(%esp)
c010819f:	00 
c01081a0:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c01081a7:	e8 59 82 ff ff       	call   c0100405 <__panic>
        int ret=0;
c01081ac:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
        // 返回父进程的内核虚拟页地址
            char *kva_src = page2kva(page);
c01081b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01081b6:	89 04 24             	mov    %eax,(%esp)
c01081b9:	e8 03 f1 ff ff       	call   c01072c1 <page2kva>
c01081be:	89 45 d8             	mov    %eax,-0x28(%ebp)
            // 返回子进程的内核虚拟页地址
            char *kva_dst = page2kva(npage);
c01081c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01081c4:	89 04 24             	mov    %eax,(%esp)
c01081c7:	e8 f5 f0 ff ff       	call   c01072c1 <page2kva>
c01081cc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
            // 复制父进程到子进程
            memcpy(kva_dst, kva_src, PGSIZE);
c01081cf:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01081d6:	00 
c01081d7:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01081da:	89 44 24 04          	mov    %eax,0x4(%esp)
c01081de:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01081e1:	89 04 24             	mov    %eax,(%esp)
c01081e4:	e8 80 38 00 00       	call   c010ba69 <memcpy>
            // 建立子进程页起始地址与物理地址的映射关系
            ret = page_insert(to, npage, start, perm);
c01081e9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01081ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01081f0:	8b 45 10             	mov    0x10(%ebp),%eax
c01081f3:	89 44 24 08          	mov    %eax,0x8(%esp)
c01081f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01081fa:	89 44 24 04          	mov    %eax,0x4(%esp)
c01081fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0108201:	89 04 24             	mov    %eax,(%esp)
c0108204:	e8 92 00 00 00       	call   c010829b <page_insert>
c0108209:	89 45 dc             	mov    %eax,-0x24(%ebp)

            assert(ret == 0);
c010820c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0108210:	74 24                	je     c0108236 <copy_range+0x203>
c0108212:	c7 44 24 0c 04 dd 10 	movl   $0xc010dd04,0xc(%esp)
c0108219:	c0 
c010821a:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c0108221:	c0 
c0108222:	c7 44 24 04 d1 01 00 	movl   $0x1d1,0x4(%esp)
c0108229:	00 
c010822a:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c0108231:	e8 cf 81 ff ff       	call   c0100405 <__panic>
        }
        start += PGSIZE;
c0108236:	81 45 10 00 10 00 00 	addl   $0x1000,0x10(%ebp)
    } while (start != 0 && start < end);
c010823d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108241:	74 0c                	je     c010824f <copy_range+0x21c>
c0108243:	8b 45 10             	mov    0x10(%ebp),%eax
c0108246:	3b 45 14             	cmp    0x14(%ebp),%eax
c0108249:	0f 82 64 fe ff ff    	jb     c01080b3 <copy_range+0x80>
    return 0;
c010824f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108254:	c9                   	leave  
c0108255:	c3                   	ret    

c0108256 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c0108256:	55                   	push   %ebp
c0108257:	89 e5                	mov    %esp,%ebp
c0108259:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c010825c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0108263:	00 
c0108264:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108267:	89 44 24 04          	mov    %eax,0x4(%esp)
c010826b:	8b 45 08             	mov    0x8(%ebp),%eax
c010826e:	89 04 24             	mov    %eax,(%esp)
c0108271:	e8 cc f9 ff ff       	call   c0107c42 <get_pte>
c0108276:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c0108279:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010827d:	74 19                	je     c0108298 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c010827f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108282:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108286:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108289:	89 44 24 04          	mov    %eax,0x4(%esp)
c010828d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108290:	89 04 24             	mov    %eax,(%esp)
c0108293:	e8 3c fb ff ff       	call   c0107dd4 <page_remove_pte>
    }
}
c0108298:	90                   	nop
c0108299:	c9                   	leave  
c010829a:	c3                   	ret    

c010829b <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c010829b:	55                   	push   %ebp
c010829c:	89 e5                	mov    %esp,%ebp
c010829e:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c01082a1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01082a8:	00 
c01082a9:	8b 45 10             	mov    0x10(%ebp),%eax
c01082ac:	89 44 24 04          	mov    %eax,0x4(%esp)
c01082b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01082b3:	89 04 24             	mov    %eax,(%esp)
c01082b6:	e8 87 f9 ff ff       	call   c0107c42 <get_pte>
c01082bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c01082be:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01082c2:	75 0a                	jne    c01082ce <page_insert+0x33>
        return -E_NO_MEM;
c01082c4:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c01082c9:	e9 84 00 00 00       	jmp    c0108352 <page_insert+0xb7>
    }
    page_ref_inc(page);
c01082ce:	8b 45 0c             	mov    0xc(%ebp),%eax
c01082d1:	89 04 24             	mov    %eax,(%esp)
c01082d4:	e8 aa f0 ff ff       	call   c0107383 <page_ref_inc>
    if (*ptep & PTE_P) {
c01082d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01082dc:	8b 00                	mov    (%eax),%eax
c01082de:	83 e0 01             	and    $0x1,%eax
c01082e1:	85 c0                	test   %eax,%eax
c01082e3:	74 3e                	je     c0108323 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c01082e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01082e8:	8b 00                	mov    (%eax),%eax
c01082ea:	89 04 24             	mov    %eax,(%esp)
c01082ed:	e8 23 f0 ff ff       	call   c0107315 <pte2page>
c01082f2:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c01082f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01082f8:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01082fb:	75 0d                	jne    c010830a <page_insert+0x6f>
            page_ref_dec(page);
c01082fd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108300:	89 04 24             	mov    %eax,(%esp)
c0108303:	e8 92 f0 ff ff       	call   c010739a <page_ref_dec>
c0108308:	eb 19                	jmp    c0108323 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c010830a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010830d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108311:	8b 45 10             	mov    0x10(%ebp),%eax
c0108314:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108318:	8b 45 08             	mov    0x8(%ebp),%eax
c010831b:	89 04 24             	mov    %eax,(%esp)
c010831e:	e8 b1 fa ff ff       	call   c0107dd4 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0108323:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108326:	89 04 24             	mov    %eax,(%esp)
c0108329:	e8 38 ef ff ff       	call   c0107266 <page2pa>
c010832e:	0b 45 14             	or     0x14(%ebp),%eax
c0108331:	83 c8 01             	or     $0x1,%eax
c0108334:	89 c2                	mov    %eax,%edx
c0108336:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108339:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c010833b:	8b 45 10             	mov    0x10(%ebp),%eax
c010833e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108342:	8b 45 08             	mov    0x8(%ebp),%eax
c0108345:	89 04 24             	mov    %eax,(%esp)
c0108348:	e8 07 00 00 00       	call   c0108354 <tlb_invalidate>
    return 0;
c010834d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108352:	c9                   	leave  
c0108353:	c3                   	ret    

c0108354 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c0108354:	55                   	push   %ebp
c0108355:	89 e5                	mov    %esp,%ebp
c0108357:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c010835a:	0f 20 d8             	mov    %cr3,%eax
c010835d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    return cr3;
c0108360:	8b 55 ec             	mov    -0x14(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
c0108363:	8b 45 08             	mov    0x8(%ebp),%eax
c0108366:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108369:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0108370:	77 23                	ja     c0108395 <tlb_invalidate+0x41>
c0108372:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108375:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108379:	c7 44 24 08 28 dc 10 	movl   $0xc010dc28,0x8(%esp)
c0108380:	c0 
c0108381:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
c0108388:	00 
c0108389:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c0108390:	e8 70 80 ff ff       	call   c0100405 <__panic>
c0108395:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108398:	05 00 00 00 40       	add    $0x40000000,%eax
c010839d:	39 c2                	cmp    %eax,%edx
c010839f:	75 0c                	jne    c01083ad <tlb_invalidate+0x59>
        invlpg((void *)la);
c01083a1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01083a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c01083a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01083aa:	0f 01 38             	invlpg (%eax)
    }
}
c01083ad:	90                   	nop
c01083ae:	c9                   	leave  
c01083af:	c3                   	ret    

c01083b0 <pgdir_alloc_page>:

// pgdir_alloc_page - call alloc_page & page_insert functions to 
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
struct Page *
pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
c01083b0:	55                   	push   %ebp
c01083b1:	89 e5                	mov    %esp,%ebp
c01083b3:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_page();
c01083b6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01083bd:	e8 ae f1 ff ff       	call   c0107570 <alloc_pages>
c01083c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c01083c5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01083c9:	0f 84 b0 00 00 00    	je     c010847f <pgdir_alloc_page+0xcf>
        if (page_insert(pgdir, page, la, perm) != 0) {
c01083cf:	8b 45 10             	mov    0x10(%ebp),%eax
c01083d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01083d6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01083d9:	89 44 24 08          	mov    %eax,0x8(%esp)
c01083dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01083e0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01083e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01083e7:	89 04 24             	mov    %eax,(%esp)
c01083ea:	e8 ac fe ff ff       	call   c010829b <page_insert>
c01083ef:	85 c0                	test   %eax,%eax
c01083f1:	74 1a                	je     c010840d <pgdir_alloc_page+0x5d>
            free_page(page);
c01083f3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01083fa:	00 
c01083fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01083fe:	89 04 24             	mov    %eax,(%esp)
c0108401:	e8 d5 f1 ff ff       	call   c01075db <free_pages>
            return NULL;
c0108406:	b8 00 00 00 00       	mov    $0x0,%eax
c010840b:	eb 75                	jmp    c0108482 <pgdir_alloc_page+0xd2>
        }
        if (swap_init_ok){
c010840d:	a1 68 0f 1b c0       	mov    0xc01b0f68,%eax
c0108412:	85 c0                	test   %eax,%eax
c0108414:	74 69                	je     c010847f <pgdir_alloc_page+0xcf>
            if(check_mm_struct!=NULL) {
c0108416:	a1 7c 30 1b c0       	mov    0xc01b307c,%eax
c010841b:	85 c0                	test   %eax,%eax
c010841d:	74 60                	je     c010847f <pgdir_alloc_page+0xcf>
                swap_map_swappable(check_mm_struct, la, page, 0);
c010841f:	a1 7c 30 1b c0       	mov    0xc01b307c,%eax
c0108424:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010842b:	00 
c010842c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010842f:	89 54 24 08          	mov    %edx,0x8(%esp)
c0108433:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108436:	89 54 24 04          	mov    %edx,0x4(%esp)
c010843a:	89 04 24             	mov    %eax,(%esp)
c010843d:	e8 50 c4 ff ff       	call   c0104892 <swap_map_swappable>
                page->pra_vaddr=la;
c0108442:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108445:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108448:	89 50 1c             	mov    %edx,0x1c(%eax)
                assert(page_ref(page) == 1);
c010844b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010844e:	89 04 24             	mov    %eax,(%esp)
c0108451:	e8 15 ef ff ff       	call   c010736b <page_ref>
c0108456:	83 f8 01             	cmp    $0x1,%eax
c0108459:	74 24                	je     c010847f <pgdir_alloc_page+0xcf>
c010845b:	c7 44 24 0c 0d dd 10 	movl   $0xc010dd0d,0xc(%esp)
c0108462:	c0 
c0108463:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c010846a:	c0 
c010846b:	c7 44 24 04 16 02 00 	movl   $0x216,0x4(%esp)
c0108472:	00 
c0108473:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c010847a:	e8 86 7f ff ff       	call   c0100405 <__panic>
            }
        }

    }

    return page;
c010847f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0108482:	c9                   	leave  
c0108483:	c3                   	ret    

c0108484 <check_alloc_page>:

static void
check_alloc_page(void) {
c0108484:	55                   	push   %ebp
c0108485:	89 e5                	mov    %esp,%ebp
c0108487:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c010848a:	a1 58 31 1b c0       	mov    0xc01b3158,%eax
c010848f:	8b 40 18             	mov    0x18(%eax),%eax
c0108492:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c0108494:	c7 04 24 24 dd 10 c0 	movl   $0xc010dd24,(%esp)
c010849b:	e8 0e 7e ff ff       	call   c01002ae <cprintf>
}
c01084a0:	90                   	nop
c01084a1:	c9                   	leave  
c01084a2:	c3                   	ret    

c01084a3 <check_pgdir>:

static void
check_pgdir(void) {
c01084a3:	55                   	push   %ebp
c01084a4:	89 e5                	mov    %esp,%ebp
c01084a6:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c01084a9:	a1 80 0f 1b c0       	mov    0xc01b0f80,%eax
c01084ae:	3d 00 80 03 00       	cmp    $0x38000,%eax
c01084b3:	76 24                	jbe    c01084d9 <check_pgdir+0x36>
c01084b5:	c7 44 24 0c 43 dd 10 	movl   $0xc010dd43,0xc(%esp)
c01084bc:	c0 
c01084bd:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c01084c4:	c0 
c01084c5:	c7 44 24 04 2e 02 00 	movl   $0x22e,0x4(%esp)
c01084cc:	00 
c01084cd:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c01084d4:	e8 2c 7f ff ff       	call   c0100405 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c01084d9:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c01084de:	85 c0                	test   %eax,%eax
c01084e0:	74 0e                	je     c01084f0 <check_pgdir+0x4d>
c01084e2:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c01084e7:	25 ff 0f 00 00       	and    $0xfff,%eax
c01084ec:	85 c0                	test   %eax,%eax
c01084ee:	74 24                	je     c0108514 <check_pgdir+0x71>
c01084f0:	c7 44 24 0c 60 dd 10 	movl   $0xc010dd60,0xc(%esp)
c01084f7:	c0 
c01084f8:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c01084ff:	c0 
c0108500:	c7 44 24 04 2f 02 00 	movl   $0x22f,0x4(%esp)
c0108507:	00 
c0108508:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c010850f:	e8 f1 7e ff ff       	call   c0100405 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c0108514:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c0108519:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0108520:	00 
c0108521:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0108528:	00 
c0108529:	89 04 24             	mov    %eax,(%esp)
c010852c:	e8 4a f8 ff ff       	call   c0107d7b <get_page>
c0108531:	85 c0                	test   %eax,%eax
c0108533:	74 24                	je     c0108559 <check_pgdir+0xb6>
c0108535:	c7 44 24 0c 98 dd 10 	movl   $0xc010dd98,0xc(%esp)
c010853c:	c0 
c010853d:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c0108544:	c0 
c0108545:	c7 44 24 04 30 02 00 	movl   $0x230,0x4(%esp)
c010854c:	00 
c010854d:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c0108554:	e8 ac 7e ff ff       	call   c0100405 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c0108559:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108560:	e8 0b f0 ff ff       	call   c0107570 <alloc_pages>
c0108565:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c0108568:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c010856d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0108574:	00 
c0108575:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010857c:	00 
c010857d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108580:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108584:	89 04 24             	mov    %eax,(%esp)
c0108587:	e8 0f fd ff ff       	call   c010829b <page_insert>
c010858c:	85 c0                	test   %eax,%eax
c010858e:	74 24                	je     c01085b4 <check_pgdir+0x111>
c0108590:	c7 44 24 0c c0 dd 10 	movl   $0xc010ddc0,0xc(%esp)
c0108597:	c0 
c0108598:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c010859f:	c0 
c01085a0:	c7 44 24 04 34 02 00 	movl   $0x234,0x4(%esp)
c01085a7:	00 
c01085a8:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c01085af:	e8 51 7e ff ff       	call   c0100405 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c01085b4:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c01085b9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01085c0:	00 
c01085c1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01085c8:	00 
c01085c9:	89 04 24             	mov    %eax,(%esp)
c01085cc:	e8 71 f6 ff ff       	call   c0107c42 <get_pte>
c01085d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01085d4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01085d8:	75 24                	jne    c01085fe <check_pgdir+0x15b>
c01085da:	c7 44 24 0c ec dd 10 	movl   $0xc010ddec,0xc(%esp)
c01085e1:	c0 
c01085e2:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c01085e9:	c0 
c01085ea:	c7 44 24 04 37 02 00 	movl   $0x237,0x4(%esp)
c01085f1:	00 
c01085f2:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c01085f9:	e8 07 7e ff ff       	call   c0100405 <__panic>
    assert(pte2page(*ptep) == p1);
c01085fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108601:	8b 00                	mov    (%eax),%eax
c0108603:	89 04 24             	mov    %eax,(%esp)
c0108606:	e8 0a ed ff ff       	call   c0107315 <pte2page>
c010860b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010860e:	74 24                	je     c0108634 <check_pgdir+0x191>
c0108610:	c7 44 24 0c 19 de 10 	movl   $0xc010de19,0xc(%esp)
c0108617:	c0 
c0108618:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c010861f:	c0 
c0108620:	c7 44 24 04 38 02 00 	movl   $0x238,0x4(%esp)
c0108627:	00 
c0108628:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c010862f:	e8 d1 7d ff ff       	call   c0100405 <__panic>
    assert(page_ref(p1) == 1);
c0108634:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108637:	89 04 24             	mov    %eax,(%esp)
c010863a:	e8 2c ed ff ff       	call   c010736b <page_ref>
c010863f:	83 f8 01             	cmp    $0x1,%eax
c0108642:	74 24                	je     c0108668 <check_pgdir+0x1c5>
c0108644:	c7 44 24 0c 2f de 10 	movl   $0xc010de2f,0xc(%esp)
c010864b:	c0 
c010864c:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c0108653:	c0 
c0108654:	c7 44 24 04 39 02 00 	movl   $0x239,0x4(%esp)
c010865b:	00 
c010865c:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c0108663:	e8 9d 7d ff ff       	call   c0100405 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c0108668:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c010866d:	8b 00                	mov    (%eax),%eax
c010866f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0108674:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108677:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010867a:	c1 e8 0c             	shr    $0xc,%eax
c010867d:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108680:	a1 80 0f 1b c0       	mov    0xc01b0f80,%eax
c0108685:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0108688:	72 23                	jb     c01086ad <check_pgdir+0x20a>
c010868a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010868d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108691:	c7 44 24 08 84 db 10 	movl   $0xc010db84,0x8(%esp)
c0108698:	c0 
c0108699:	c7 44 24 04 3b 02 00 	movl   $0x23b,0x4(%esp)
c01086a0:	00 
c01086a1:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c01086a8:	e8 58 7d ff ff       	call   c0100405 <__panic>
c01086ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01086b0:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01086b5:	83 c0 04             	add    $0x4,%eax
c01086b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c01086bb:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c01086c0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01086c7:	00 
c01086c8:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01086cf:	00 
c01086d0:	89 04 24             	mov    %eax,(%esp)
c01086d3:	e8 6a f5 ff ff       	call   c0107c42 <get_pte>
c01086d8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01086db:	74 24                	je     c0108701 <check_pgdir+0x25e>
c01086dd:	c7 44 24 0c 44 de 10 	movl   $0xc010de44,0xc(%esp)
c01086e4:	c0 
c01086e5:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c01086ec:	c0 
c01086ed:	c7 44 24 04 3c 02 00 	movl   $0x23c,0x4(%esp)
c01086f4:	00 
c01086f5:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c01086fc:	e8 04 7d ff ff       	call   c0100405 <__panic>

    p2 = alloc_page();
c0108701:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108708:	e8 63 ee ff ff       	call   c0107570 <alloc_pages>
c010870d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0108710:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c0108715:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c010871c:	00 
c010871d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0108724:	00 
c0108725:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108728:	89 54 24 04          	mov    %edx,0x4(%esp)
c010872c:	89 04 24             	mov    %eax,(%esp)
c010872f:	e8 67 fb ff ff       	call   c010829b <page_insert>
c0108734:	85 c0                	test   %eax,%eax
c0108736:	74 24                	je     c010875c <check_pgdir+0x2b9>
c0108738:	c7 44 24 0c 6c de 10 	movl   $0xc010de6c,0xc(%esp)
c010873f:	c0 
c0108740:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c0108747:	c0 
c0108748:	c7 44 24 04 3f 02 00 	movl   $0x23f,0x4(%esp)
c010874f:	00 
c0108750:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c0108757:	e8 a9 7c ff ff       	call   c0100405 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c010875c:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c0108761:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0108768:	00 
c0108769:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0108770:	00 
c0108771:	89 04 24             	mov    %eax,(%esp)
c0108774:	e8 c9 f4 ff ff       	call   c0107c42 <get_pte>
c0108779:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010877c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0108780:	75 24                	jne    c01087a6 <check_pgdir+0x303>
c0108782:	c7 44 24 0c a4 de 10 	movl   $0xc010dea4,0xc(%esp)
c0108789:	c0 
c010878a:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c0108791:	c0 
c0108792:	c7 44 24 04 40 02 00 	movl   $0x240,0x4(%esp)
c0108799:	00 
c010879a:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c01087a1:	e8 5f 7c ff ff       	call   c0100405 <__panic>
    assert(*ptep & PTE_U);
c01087a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01087a9:	8b 00                	mov    (%eax),%eax
c01087ab:	83 e0 04             	and    $0x4,%eax
c01087ae:	85 c0                	test   %eax,%eax
c01087b0:	75 24                	jne    c01087d6 <check_pgdir+0x333>
c01087b2:	c7 44 24 0c d4 de 10 	movl   $0xc010ded4,0xc(%esp)
c01087b9:	c0 
c01087ba:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c01087c1:	c0 
c01087c2:	c7 44 24 04 41 02 00 	movl   $0x241,0x4(%esp)
c01087c9:	00 
c01087ca:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c01087d1:	e8 2f 7c ff ff       	call   c0100405 <__panic>
    assert(*ptep & PTE_W);
c01087d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01087d9:	8b 00                	mov    (%eax),%eax
c01087db:	83 e0 02             	and    $0x2,%eax
c01087de:	85 c0                	test   %eax,%eax
c01087e0:	75 24                	jne    c0108806 <check_pgdir+0x363>
c01087e2:	c7 44 24 0c e2 de 10 	movl   $0xc010dee2,0xc(%esp)
c01087e9:	c0 
c01087ea:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c01087f1:	c0 
c01087f2:	c7 44 24 04 42 02 00 	movl   $0x242,0x4(%esp)
c01087f9:	00 
c01087fa:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c0108801:	e8 ff 7b ff ff       	call   c0100405 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0108806:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c010880b:	8b 00                	mov    (%eax),%eax
c010880d:	83 e0 04             	and    $0x4,%eax
c0108810:	85 c0                	test   %eax,%eax
c0108812:	75 24                	jne    c0108838 <check_pgdir+0x395>
c0108814:	c7 44 24 0c f0 de 10 	movl   $0xc010def0,0xc(%esp)
c010881b:	c0 
c010881c:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c0108823:	c0 
c0108824:	c7 44 24 04 43 02 00 	movl   $0x243,0x4(%esp)
c010882b:	00 
c010882c:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c0108833:	e8 cd 7b ff ff       	call   c0100405 <__panic>
    assert(page_ref(p2) == 1);
c0108838:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010883b:	89 04 24             	mov    %eax,(%esp)
c010883e:	e8 28 eb ff ff       	call   c010736b <page_ref>
c0108843:	83 f8 01             	cmp    $0x1,%eax
c0108846:	74 24                	je     c010886c <check_pgdir+0x3c9>
c0108848:	c7 44 24 0c 06 df 10 	movl   $0xc010df06,0xc(%esp)
c010884f:	c0 
c0108850:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c0108857:	c0 
c0108858:	c7 44 24 04 44 02 00 	movl   $0x244,0x4(%esp)
c010885f:	00 
c0108860:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c0108867:	e8 99 7b ff ff       	call   c0100405 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c010886c:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c0108871:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0108878:	00 
c0108879:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0108880:	00 
c0108881:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108884:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108888:	89 04 24             	mov    %eax,(%esp)
c010888b:	e8 0b fa ff ff       	call   c010829b <page_insert>
c0108890:	85 c0                	test   %eax,%eax
c0108892:	74 24                	je     c01088b8 <check_pgdir+0x415>
c0108894:	c7 44 24 0c 18 df 10 	movl   $0xc010df18,0xc(%esp)
c010889b:	c0 
c010889c:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c01088a3:	c0 
c01088a4:	c7 44 24 04 46 02 00 	movl   $0x246,0x4(%esp)
c01088ab:	00 
c01088ac:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c01088b3:	e8 4d 7b ff ff       	call   c0100405 <__panic>
    assert(page_ref(p1) == 2);
c01088b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01088bb:	89 04 24             	mov    %eax,(%esp)
c01088be:	e8 a8 ea ff ff       	call   c010736b <page_ref>
c01088c3:	83 f8 02             	cmp    $0x2,%eax
c01088c6:	74 24                	je     c01088ec <check_pgdir+0x449>
c01088c8:	c7 44 24 0c 44 df 10 	movl   $0xc010df44,0xc(%esp)
c01088cf:	c0 
c01088d0:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c01088d7:	c0 
c01088d8:	c7 44 24 04 47 02 00 	movl   $0x247,0x4(%esp)
c01088df:	00 
c01088e0:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c01088e7:	e8 19 7b ff ff       	call   c0100405 <__panic>
    assert(page_ref(p2) == 0);
c01088ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01088ef:	89 04 24             	mov    %eax,(%esp)
c01088f2:	e8 74 ea ff ff       	call   c010736b <page_ref>
c01088f7:	85 c0                	test   %eax,%eax
c01088f9:	74 24                	je     c010891f <check_pgdir+0x47c>
c01088fb:	c7 44 24 0c 56 df 10 	movl   $0xc010df56,0xc(%esp)
c0108902:	c0 
c0108903:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c010890a:	c0 
c010890b:	c7 44 24 04 48 02 00 	movl   $0x248,0x4(%esp)
c0108912:	00 
c0108913:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c010891a:	e8 e6 7a ff ff       	call   c0100405 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c010891f:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c0108924:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010892b:	00 
c010892c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0108933:	00 
c0108934:	89 04 24             	mov    %eax,(%esp)
c0108937:	e8 06 f3 ff ff       	call   c0107c42 <get_pte>
c010893c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010893f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0108943:	75 24                	jne    c0108969 <check_pgdir+0x4c6>
c0108945:	c7 44 24 0c a4 de 10 	movl   $0xc010dea4,0xc(%esp)
c010894c:	c0 
c010894d:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c0108954:	c0 
c0108955:	c7 44 24 04 49 02 00 	movl   $0x249,0x4(%esp)
c010895c:	00 
c010895d:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c0108964:	e8 9c 7a ff ff       	call   c0100405 <__panic>
    assert(pte2page(*ptep) == p1);
c0108969:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010896c:	8b 00                	mov    (%eax),%eax
c010896e:	89 04 24             	mov    %eax,(%esp)
c0108971:	e8 9f e9 ff ff       	call   c0107315 <pte2page>
c0108976:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0108979:	74 24                	je     c010899f <check_pgdir+0x4fc>
c010897b:	c7 44 24 0c 19 de 10 	movl   $0xc010de19,0xc(%esp)
c0108982:	c0 
c0108983:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c010898a:	c0 
c010898b:	c7 44 24 04 4a 02 00 	movl   $0x24a,0x4(%esp)
c0108992:	00 
c0108993:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c010899a:	e8 66 7a ff ff       	call   c0100405 <__panic>
    assert((*ptep & PTE_U) == 0);
c010899f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01089a2:	8b 00                	mov    (%eax),%eax
c01089a4:	83 e0 04             	and    $0x4,%eax
c01089a7:	85 c0                	test   %eax,%eax
c01089a9:	74 24                	je     c01089cf <check_pgdir+0x52c>
c01089ab:	c7 44 24 0c 68 df 10 	movl   $0xc010df68,0xc(%esp)
c01089b2:	c0 
c01089b3:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c01089ba:	c0 
c01089bb:	c7 44 24 04 4b 02 00 	movl   $0x24b,0x4(%esp)
c01089c2:	00 
c01089c3:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c01089ca:	e8 36 7a ff ff       	call   c0100405 <__panic>

    page_remove(boot_pgdir, 0x0);
c01089cf:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c01089d4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01089db:	00 
c01089dc:	89 04 24             	mov    %eax,(%esp)
c01089df:	e8 72 f8 ff ff       	call   c0108256 <page_remove>
    assert(page_ref(p1) == 1);
c01089e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01089e7:	89 04 24             	mov    %eax,(%esp)
c01089ea:	e8 7c e9 ff ff       	call   c010736b <page_ref>
c01089ef:	83 f8 01             	cmp    $0x1,%eax
c01089f2:	74 24                	je     c0108a18 <check_pgdir+0x575>
c01089f4:	c7 44 24 0c 2f de 10 	movl   $0xc010de2f,0xc(%esp)
c01089fb:	c0 
c01089fc:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c0108a03:	c0 
c0108a04:	c7 44 24 04 4e 02 00 	movl   $0x24e,0x4(%esp)
c0108a0b:	00 
c0108a0c:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c0108a13:	e8 ed 79 ff ff       	call   c0100405 <__panic>
    assert(page_ref(p2) == 0);
c0108a18:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108a1b:	89 04 24             	mov    %eax,(%esp)
c0108a1e:	e8 48 e9 ff ff       	call   c010736b <page_ref>
c0108a23:	85 c0                	test   %eax,%eax
c0108a25:	74 24                	je     c0108a4b <check_pgdir+0x5a8>
c0108a27:	c7 44 24 0c 56 df 10 	movl   $0xc010df56,0xc(%esp)
c0108a2e:	c0 
c0108a2f:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c0108a36:	c0 
c0108a37:	c7 44 24 04 4f 02 00 	movl   $0x24f,0x4(%esp)
c0108a3e:	00 
c0108a3f:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c0108a46:	e8 ba 79 ff ff       	call   c0100405 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0108a4b:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c0108a50:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0108a57:	00 
c0108a58:	89 04 24             	mov    %eax,(%esp)
c0108a5b:	e8 f6 f7 ff ff       	call   c0108256 <page_remove>
    assert(page_ref(p1) == 0);
c0108a60:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108a63:	89 04 24             	mov    %eax,(%esp)
c0108a66:	e8 00 e9 ff ff       	call   c010736b <page_ref>
c0108a6b:	85 c0                	test   %eax,%eax
c0108a6d:	74 24                	je     c0108a93 <check_pgdir+0x5f0>
c0108a6f:	c7 44 24 0c 7d df 10 	movl   $0xc010df7d,0xc(%esp)
c0108a76:	c0 
c0108a77:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c0108a7e:	c0 
c0108a7f:	c7 44 24 04 52 02 00 	movl   $0x252,0x4(%esp)
c0108a86:	00 
c0108a87:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c0108a8e:	e8 72 79 ff ff       	call   c0100405 <__panic>
    assert(page_ref(p2) == 0);
c0108a93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108a96:	89 04 24             	mov    %eax,(%esp)
c0108a99:	e8 cd e8 ff ff       	call   c010736b <page_ref>
c0108a9e:	85 c0                	test   %eax,%eax
c0108aa0:	74 24                	je     c0108ac6 <check_pgdir+0x623>
c0108aa2:	c7 44 24 0c 56 df 10 	movl   $0xc010df56,0xc(%esp)
c0108aa9:	c0 
c0108aaa:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c0108ab1:	c0 
c0108ab2:	c7 44 24 04 53 02 00 	movl   $0x253,0x4(%esp)
c0108ab9:	00 
c0108aba:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c0108ac1:	e8 3f 79 ff ff       	call   c0100405 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0108ac6:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c0108acb:	8b 00                	mov    (%eax),%eax
c0108acd:	89 04 24             	mov    %eax,(%esp)
c0108ad0:	e8 7e e8 ff ff       	call   c0107353 <pde2page>
c0108ad5:	89 04 24             	mov    %eax,(%esp)
c0108ad8:	e8 8e e8 ff ff       	call   c010736b <page_ref>
c0108add:	83 f8 01             	cmp    $0x1,%eax
c0108ae0:	74 24                	je     c0108b06 <check_pgdir+0x663>
c0108ae2:	c7 44 24 0c 90 df 10 	movl   $0xc010df90,0xc(%esp)
c0108ae9:	c0 
c0108aea:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c0108af1:	c0 
c0108af2:	c7 44 24 04 55 02 00 	movl   $0x255,0x4(%esp)
c0108af9:	00 
c0108afa:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c0108b01:	e8 ff 78 ff ff       	call   c0100405 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0108b06:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c0108b0b:	8b 00                	mov    (%eax),%eax
c0108b0d:	89 04 24             	mov    %eax,(%esp)
c0108b10:	e8 3e e8 ff ff       	call   c0107353 <pde2page>
c0108b15:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0108b1c:	00 
c0108b1d:	89 04 24             	mov    %eax,(%esp)
c0108b20:	e8 b6 ea ff ff       	call   c01075db <free_pages>
    boot_pgdir[0] = 0;
c0108b25:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c0108b2a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0108b30:	c7 04 24 b7 df 10 c0 	movl   $0xc010dfb7,(%esp)
c0108b37:	e8 72 77 ff ff       	call   c01002ae <cprintf>
}
c0108b3c:	90                   	nop
c0108b3d:	c9                   	leave  
c0108b3e:	c3                   	ret    

c0108b3f <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0108b3f:	55                   	push   %ebp
c0108b40:	89 e5                	mov    %esp,%ebp
c0108b42:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0108b45:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0108b4c:	e9 ca 00 00 00       	jmp    c0108c1b <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0108b51:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108b54:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108b57:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108b5a:	c1 e8 0c             	shr    $0xc,%eax
c0108b5d:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108b60:	a1 80 0f 1b c0       	mov    0xc01b0f80,%eax
c0108b65:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0108b68:	72 23                	jb     c0108b8d <check_boot_pgdir+0x4e>
c0108b6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108b6d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108b71:	c7 44 24 08 84 db 10 	movl   $0xc010db84,0x8(%esp)
c0108b78:	c0 
c0108b79:	c7 44 24 04 61 02 00 	movl   $0x261,0x4(%esp)
c0108b80:	00 
c0108b81:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c0108b88:	e8 78 78 ff ff       	call   c0100405 <__panic>
c0108b8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108b90:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0108b95:	89 c2                	mov    %eax,%edx
c0108b97:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c0108b9c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0108ba3:	00 
c0108ba4:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108ba8:	89 04 24             	mov    %eax,(%esp)
c0108bab:	e8 92 f0 ff ff       	call   c0107c42 <get_pte>
c0108bb0:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108bb3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108bb7:	75 24                	jne    c0108bdd <check_boot_pgdir+0x9e>
c0108bb9:	c7 44 24 0c d4 df 10 	movl   $0xc010dfd4,0xc(%esp)
c0108bc0:	c0 
c0108bc1:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c0108bc8:	c0 
c0108bc9:	c7 44 24 04 61 02 00 	movl   $0x261,0x4(%esp)
c0108bd0:	00 
c0108bd1:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c0108bd8:	e8 28 78 ff ff       	call   c0100405 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0108bdd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108be0:	8b 00                	mov    (%eax),%eax
c0108be2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0108be7:	89 c2                	mov    %eax,%edx
c0108be9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108bec:	39 c2                	cmp    %eax,%edx
c0108bee:	74 24                	je     c0108c14 <check_boot_pgdir+0xd5>
c0108bf0:	c7 44 24 0c 11 e0 10 	movl   $0xc010e011,0xc(%esp)
c0108bf7:	c0 
c0108bf8:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c0108bff:	c0 
c0108c00:	c7 44 24 04 62 02 00 	movl   $0x262,0x4(%esp)
c0108c07:	00 
c0108c08:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c0108c0f:	e8 f1 77 ff ff       	call   c0100405 <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0108c14:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0108c1b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108c1e:	a1 80 0f 1b c0       	mov    0xc01b0f80,%eax
c0108c23:	39 c2                	cmp    %eax,%edx
c0108c25:	0f 82 26 ff ff ff    	jb     c0108b51 <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0108c2b:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c0108c30:	05 ac 0f 00 00       	add    $0xfac,%eax
c0108c35:	8b 00                	mov    (%eax),%eax
c0108c37:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0108c3c:	89 c2                	mov    %eax,%edx
c0108c3e:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c0108c43:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0108c46:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
c0108c4d:	77 23                	ja     c0108c72 <check_boot_pgdir+0x133>
c0108c4f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108c52:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108c56:	c7 44 24 08 28 dc 10 	movl   $0xc010dc28,0x8(%esp)
c0108c5d:	c0 
c0108c5e:	c7 44 24 04 65 02 00 	movl   $0x265,0x4(%esp)
c0108c65:	00 
c0108c66:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c0108c6d:	e8 93 77 ff ff       	call   c0100405 <__panic>
c0108c72:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108c75:	05 00 00 00 40       	add    $0x40000000,%eax
c0108c7a:	39 c2                	cmp    %eax,%edx
c0108c7c:	74 24                	je     c0108ca2 <check_boot_pgdir+0x163>
c0108c7e:	c7 44 24 0c 28 e0 10 	movl   $0xc010e028,0xc(%esp)
c0108c85:	c0 
c0108c86:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c0108c8d:	c0 
c0108c8e:	c7 44 24 04 65 02 00 	movl   $0x265,0x4(%esp)
c0108c95:	00 
c0108c96:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c0108c9d:	e8 63 77 ff ff       	call   c0100405 <__panic>

    assert(boot_pgdir[0] == 0);
c0108ca2:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c0108ca7:	8b 00                	mov    (%eax),%eax
c0108ca9:	85 c0                	test   %eax,%eax
c0108cab:	74 24                	je     c0108cd1 <check_boot_pgdir+0x192>
c0108cad:	c7 44 24 0c 5c e0 10 	movl   $0xc010e05c,0xc(%esp)
c0108cb4:	c0 
c0108cb5:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c0108cbc:	c0 
c0108cbd:	c7 44 24 04 67 02 00 	movl   $0x267,0x4(%esp)
c0108cc4:	00 
c0108cc5:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c0108ccc:	e8 34 77 ff ff       	call   c0100405 <__panic>

    struct Page *p;
    p = alloc_page();
c0108cd1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108cd8:	e8 93 e8 ff ff       	call   c0107570 <alloc_pages>
c0108cdd:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0108ce0:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c0108ce5:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0108cec:	00 
c0108ced:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0108cf4:	00 
c0108cf5:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108cf8:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108cfc:	89 04 24             	mov    %eax,(%esp)
c0108cff:	e8 97 f5 ff ff       	call   c010829b <page_insert>
c0108d04:	85 c0                	test   %eax,%eax
c0108d06:	74 24                	je     c0108d2c <check_boot_pgdir+0x1ed>
c0108d08:	c7 44 24 0c 70 e0 10 	movl   $0xc010e070,0xc(%esp)
c0108d0f:	c0 
c0108d10:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c0108d17:	c0 
c0108d18:	c7 44 24 04 6b 02 00 	movl   $0x26b,0x4(%esp)
c0108d1f:	00 
c0108d20:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c0108d27:	e8 d9 76 ff ff       	call   c0100405 <__panic>
    assert(page_ref(p) == 1);
c0108d2c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108d2f:	89 04 24             	mov    %eax,(%esp)
c0108d32:	e8 34 e6 ff ff       	call   c010736b <page_ref>
c0108d37:	83 f8 01             	cmp    $0x1,%eax
c0108d3a:	74 24                	je     c0108d60 <check_boot_pgdir+0x221>
c0108d3c:	c7 44 24 0c 9e e0 10 	movl   $0xc010e09e,0xc(%esp)
c0108d43:	c0 
c0108d44:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c0108d4b:	c0 
c0108d4c:	c7 44 24 04 6c 02 00 	movl   $0x26c,0x4(%esp)
c0108d53:	00 
c0108d54:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c0108d5b:	e8 a5 76 ff ff       	call   c0100405 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0108d60:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c0108d65:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0108d6c:	00 
c0108d6d:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0108d74:	00 
c0108d75:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108d78:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108d7c:	89 04 24             	mov    %eax,(%esp)
c0108d7f:	e8 17 f5 ff ff       	call   c010829b <page_insert>
c0108d84:	85 c0                	test   %eax,%eax
c0108d86:	74 24                	je     c0108dac <check_boot_pgdir+0x26d>
c0108d88:	c7 44 24 0c b0 e0 10 	movl   $0xc010e0b0,0xc(%esp)
c0108d8f:	c0 
c0108d90:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c0108d97:	c0 
c0108d98:	c7 44 24 04 6d 02 00 	movl   $0x26d,0x4(%esp)
c0108d9f:	00 
c0108da0:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c0108da7:	e8 59 76 ff ff       	call   c0100405 <__panic>
    assert(page_ref(p) == 2);
c0108dac:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108daf:	89 04 24             	mov    %eax,(%esp)
c0108db2:	e8 b4 e5 ff ff       	call   c010736b <page_ref>
c0108db7:	83 f8 02             	cmp    $0x2,%eax
c0108dba:	74 24                	je     c0108de0 <check_boot_pgdir+0x2a1>
c0108dbc:	c7 44 24 0c e7 e0 10 	movl   $0xc010e0e7,0xc(%esp)
c0108dc3:	c0 
c0108dc4:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c0108dcb:	c0 
c0108dcc:	c7 44 24 04 6e 02 00 	movl   $0x26e,0x4(%esp)
c0108dd3:	00 
c0108dd4:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c0108ddb:	e8 25 76 ff ff       	call   c0100405 <__panic>

    const char *str = "ucore: Hello world!!";
c0108de0:	c7 45 dc f8 e0 10 c0 	movl   $0xc010e0f8,-0x24(%ebp)
    strcpy((void *)0x100, str);
c0108de7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108dea:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108dee:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0108df5:	e8 c2 28 00 00       	call   c010b6bc <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0108dfa:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c0108e01:	00 
c0108e02:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0108e09:	e8 25 29 00 00       	call   c010b733 <strcmp>
c0108e0e:	85 c0                	test   %eax,%eax
c0108e10:	74 24                	je     c0108e36 <check_boot_pgdir+0x2f7>
c0108e12:	c7 44 24 0c 10 e1 10 	movl   $0xc010e110,0xc(%esp)
c0108e19:	c0 
c0108e1a:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c0108e21:	c0 
c0108e22:	c7 44 24 04 72 02 00 	movl   $0x272,0x4(%esp)
c0108e29:	00 
c0108e2a:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c0108e31:	e8 cf 75 ff ff       	call   c0100405 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0108e36:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108e39:	89 04 24             	mov    %eax,(%esp)
c0108e3c:	e8 80 e4 ff ff       	call   c01072c1 <page2kva>
c0108e41:	05 00 01 00 00       	add    $0x100,%eax
c0108e46:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0108e49:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0108e50:	e8 11 28 00 00       	call   c010b666 <strlen>
c0108e55:	85 c0                	test   %eax,%eax
c0108e57:	74 24                	je     c0108e7d <check_boot_pgdir+0x33e>
c0108e59:	c7 44 24 0c 48 e1 10 	movl   $0xc010e148,0xc(%esp)
c0108e60:	c0 
c0108e61:	c7 44 24 08 71 dc 10 	movl   $0xc010dc71,0x8(%esp)
c0108e68:	c0 
c0108e69:	c7 44 24 04 75 02 00 	movl   $0x275,0x4(%esp)
c0108e70:	00 
c0108e71:	c7 04 24 4c dc 10 c0 	movl   $0xc010dc4c,(%esp)
c0108e78:	e8 88 75 ff ff       	call   c0100405 <__panic>

    free_page(p);
c0108e7d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0108e84:	00 
c0108e85:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108e88:	89 04 24             	mov    %eax,(%esp)
c0108e8b:	e8 4b e7 ff ff       	call   c01075db <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c0108e90:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c0108e95:	8b 00                	mov    (%eax),%eax
c0108e97:	89 04 24             	mov    %eax,(%esp)
c0108e9a:	e8 b4 e4 ff ff       	call   c0107353 <pde2page>
c0108e9f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0108ea6:	00 
c0108ea7:	89 04 24             	mov    %eax,(%esp)
c0108eaa:	e8 2c e7 ff ff       	call   c01075db <free_pages>
    boot_pgdir[0] = 0;
c0108eaf:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c0108eb4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0108eba:	c7 04 24 6c e1 10 c0 	movl   $0xc010e16c,(%esp)
c0108ec1:	e8 e8 73 ff ff       	call   c01002ae <cprintf>
}
c0108ec6:	90                   	nop
c0108ec7:	c9                   	leave  
c0108ec8:	c3                   	ret    

c0108ec9 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0108ec9:	55                   	push   %ebp
c0108eca:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0108ecc:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ecf:	83 e0 04             	and    $0x4,%eax
c0108ed2:	85 c0                	test   %eax,%eax
c0108ed4:	74 04                	je     c0108eda <perm2str+0x11>
c0108ed6:	b0 75                	mov    $0x75,%al
c0108ed8:	eb 02                	jmp    c0108edc <perm2str+0x13>
c0108eda:	b0 2d                	mov    $0x2d,%al
c0108edc:	a2 08 10 1b c0       	mov    %al,0xc01b1008
    str[1] = 'r';
c0108ee1:	c6 05 09 10 1b c0 72 	movb   $0x72,0xc01b1009
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0108ee8:	8b 45 08             	mov    0x8(%ebp),%eax
c0108eeb:	83 e0 02             	and    $0x2,%eax
c0108eee:	85 c0                	test   %eax,%eax
c0108ef0:	74 04                	je     c0108ef6 <perm2str+0x2d>
c0108ef2:	b0 77                	mov    $0x77,%al
c0108ef4:	eb 02                	jmp    c0108ef8 <perm2str+0x2f>
c0108ef6:	b0 2d                	mov    $0x2d,%al
c0108ef8:	a2 0a 10 1b c0       	mov    %al,0xc01b100a
    str[3] = '\0';
c0108efd:	c6 05 0b 10 1b c0 00 	movb   $0x0,0xc01b100b
    return str;
c0108f04:	b8 08 10 1b c0       	mov    $0xc01b1008,%eax
}
c0108f09:	5d                   	pop    %ebp
c0108f0a:	c3                   	ret    

c0108f0b <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0108f0b:	55                   	push   %ebp
c0108f0c:	89 e5                	mov    %esp,%ebp
c0108f0e:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c0108f11:	8b 45 10             	mov    0x10(%ebp),%eax
c0108f14:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108f17:	72 0d                	jb     c0108f26 <get_pgtable_items+0x1b>
        return 0;
c0108f19:	b8 00 00 00 00       	mov    $0x0,%eax
c0108f1e:	e9 98 00 00 00       	jmp    c0108fbb <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
c0108f23:	ff 45 10             	incl   0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
c0108f26:	8b 45 10             	mov    0x10(%ebp),%eax
c0108f29:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108f2c:	73 18                	jae    c0108f46 <get_pgtable_items+0x3b>
c0108f2e:	8b 45 10             	mov    0x10(%ebp),%eax
c0108f31:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0108f38:	8b 45 14             	mov    0x14(%ebp),%eax
c0108f3b:	01 d0                	add    %edx,%eax
c0108f3d:	8b 00                	mov    (%eax),%eax
c0108f3f:	83 e0 01             	and    $0x1,%eax
c0108f42:	85 c0                	test   %eax,%eax
c0108f44:	74 dd                	je     c0108f23 <get_pgtable_items+0x18>
        start ++;
    }
    if (start < right) {
c0108f46:	8b 45 10             	mov    0x10(%ebp),%eax
c0108f49:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108f4c:	73 68                	jae    c0108fb6 <get_pgtable_items+0xab>
        if (left_store != NULL) {
c0108f4e:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0108f52:	74 08                	je     c0108f5c <get_pgtable_items+0x51>
            *left_store = start;
c0108f54:	8b 45 18             	mov    0x18(%ebp),%eax
c0108f57:	8b 55 10             	mov    0x10(%ebp),%edx
c0108f5a:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c0108f5c:	8b 45 10             	mov    0x10(%ebp),%eax
c0108f5f:	8d 50 01             	lea    0x1(%eax),%edx
c0108f62:	89 55 10             	mov    %edx,0x10(%ebp)
c0108f65:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0108f6c:	8b 45 14             	mov    0x14(%ebp),%eax
c0108f6f:	01 d0                	add    %edx,%eax
c0108f71:	8b 00                	mov    (%eax),%eax
c0108f73:	83 e0 07             	and    $0x7,%eax
c0108f76:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0108f79:	eb 03                	jmp    c0108f7e <get_pgtable_items+0x73>
            start ++;
c0108f7b:	ff 45 10             	incl   0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
c0108f7e:	8b 45 10             	mov    0x10(%ebp),%eax
c0108f81:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108f84:	73 1d                	jae    c0108fa3 <get_pgtable_items+0x98>
c0108f86:	8b 45 10             	mov    0x10(%ebp),%eax
c0108f89:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0108f90:	8b 45 14             	mov    0x14(%ebp),%eax
c0108f93:	01 d0                	add    %edx,%eax
c0108f95:	8b 00                	mov    (%eax),%eax
c0108f97:	83 e0 07             	and    $0x7,%eax
c0108f9a:	89 c2                	mov    %eax,%edx
c0108f9c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108f9f:	39 c2                	cmp    %eax,%edx
c0108fa1:	74 d8                	je     c0108f7b <get_pgtable_items+0x70>
            start ++;
        }
        if (right_store != NULL) {
c0108fa3:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0108fa7:	74 08                	je     c0108fb1 <get_pgtable_items+0xa6>
            *right_store = start;
c0108fa9:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0108fac:	8b 55 10             	mov    0x10(%ebp),%edx
c0108faf:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0108fb1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108fb4:	eb 05                	jmp    c0108fbb <get_pgtable_items+0xb0>
    }
    return 0;
c0108fb6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108fbb:	c9                   	leave  
c0108fbc:	c3                   	ret    

c0108fbd <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0108fbd:	55                   	push   %ebp
c0108fbe:	89 e5                	mov    %esp,%ebp
c0108fc0:	57                   	push   %edi
c0108fc1:	56                   	push   %esi
c0108fc2:	53                   	push   %ebx
c0108fc3:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0108fc6:	c7 04 24 8c e1 10 c0 	movl   $0xc010e18c,(%esp)
c0108fcd:	e8 dc 72 ff ff       	call   c01002ae <cprintf>
    size_t left, right = 0, perm;
c0108fd2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0108fd9:	e9 fa 00 00 00       	jmp    c01090d8 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0108fde:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108fe1:	89 04 24             	mov    %eax,(%esp)
c0108fe4:	e8 e0 fe ff ff       	call   c0108ec9 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0108fe9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0108fec:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0108fef:	29 d1                	sub    %edx,%ecx
c0108ff1:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0108ff3:	89 d6                	mov    %edx,%esi
c0108ff5:	c1 e6 16             	shl    $0x16,%esi
c0108ff8:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0108ffb:	89 d3                	mov    %edx,%ebx
c0108ffd:	c1 e3 16             	shl    $0x16,%ebx
c0109000:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0109003:	89 d1                	mov    %edx,%ecx
c0109005:	c1 e1 16             	shl    $0x16,%ecx
c0109008:	8b 7d dc             	mov    -0x24(%ebp),%edi
c010900b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010900e:	29 d7                	sub    %edx,%edi
c0109010:	89 fa                	mov    %edi,%edx
c0109012:	89 44 24 14          	mov    %eax,0x14(%esp)
c0109016:	89 74 24 10          	mov    %esi,0x10(%esp)
c010901a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c010901e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0109022:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109026:	c7 04 24 bd e1 10 c0 	movl   $0xc010e1bd,(%esp)
c010902d:	e8 7c 72 ff ff       	call   c01002ae <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
c0109032:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109035:	c1 e0 0a             	shl    $0xa,%eax
c0109038:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c010903b:	eb 54                	jmp    c0109091 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c010903d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109040:	89 04 24             	mov    %eax,(%esp)
c0109043:	e8 81 fe ff ff       	call   c0108ec9 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0109048:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c010904b:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010904e:	29 d1                	sub    %edx,%ecx
c0109050:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0109052:	89 d6                	mov    %edx,%esi
c0109054:	c1 e6 0c             	shl    $0xc,%esi
c0109057:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010905a:	89 d3                	mov    %edx,%ebx
c010905c:	c1 e3 0c             	shl    $0xc,%ebx
c010905f:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0109062:	89 d1                	mov    %edx,%ecx
c0109064:	c1 e1 0c             	shl    $0xc,%ecx
c0109067:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c010906a:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010906d:	29 d7                	sub    %edx,%edi
c010906f:	89 fa                	mov    %edi,%edx
c0109071:	89 44 24 14          	mov    %eax,0x14(%esp)
c0109075:	89 74 24 10          	mov    %esi,0x10(%esp)
c0109079:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c010907d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0109081:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109085:	c7 04 24 dc e1 10 c0 	movl   $0xc010e1dc,(%esp)
c010908c:	e8 1d 72 ff ff       	call   c01002ae <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0109091:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c0109096:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0109099:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010909c:	89 d3                	mov    %edx,%ebx
c010909e:	c1 e3 0a             	shl    $0xa,%ebx
c01090a1:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01090a4:	89 d1                	mov    %edx,%ecx
c01090a6:	c1 e1 0a             	shl    $0xa,%ecx
c01090a9:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c01090ac:	89 54 24 14          	mov    %edx,0x14(%esp)
c01090b0:	8d 55 d8             	lea    -0x28(%ebp),%edx
c01090b3:	89 54 24 10          	mov    %edx,0x10(%esp)
c01090b7:	89 74 24 0c          	mov    %esi,0xc(%esp)
c01090bb:	89 44 24 08          	mov    %eax,0x8(%esp)
c01090bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01090c3:	89 0c 24             	mov    %ecx,(%esp)
c01090c6:	e8 40 fe ff ff       	call   c0108f0b <get_pgtable_items>
c01090cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01090ce:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01090d2:	0f 85 65 ff ff ff    	jne    c010903d <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c01090d8:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c01090dd:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01090e0:	8d 55 dc             	lea    -0x24(%ebp),%edx
c01090e3:	89 54 24 14          	mov    %edx,0x14(%esp)
c01090e7:	8d 55 e0             	lea    -0x20(%ebp),%edx
c01090ea:	89 54 24 10          	mov    %edx,0x10(%esp)
c01090ee:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01090f2:	89 44 24 08          	mov    %eax,0x8(%esp)
c01090f6:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c01090fd:	00 
c01090fe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0109105:	e8 01 fe ff ff       	call   c0108f0b <get_pgtable_items>
c010910a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010910d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0109111:	0f 85 c7 fe ff ff    	jne    c0108fde <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0109117:	c7 04 24 00 e2 10 c0 	movl   $0xc010e200,(%esp)
c010911e:	e8 8b 71 ff ff       	call   c01002ae <cprintf>
}
c0109123:	90                   	nop
c0109124:	83 c4 4c             	add    $0x4c,%esp
c0109127:	5b                   	pop    %ebx
c0109128:	5e                   	pop    %esi
c0109129:	5f                   	pop    %edi
c010912a:	5d                   	pop    %ebp
c010912b:	c3                   	ret    

c010912c <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c010912c:	55                   	push   %ebp
c010912d:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010912f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109132:	8b 15 60 31 1b c0    	mov    0xc01b3160,%edx
c0109138:	29 d0                	sub    %edx,%eax
c010913a:	c1 f8 05             	sar    $0x5,%eax
}
c010913d:	5d                   	pop    %ebp
c010913e:	c3                   	ret    

c010913f <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c010913f:	55                   	push   %ebp
c0109140:	89 e5                	mov    %esp,%ebp
c0109142:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0109145:	8b 45 08             	mov    0x8(%ebp),%eax
c0109148:	89 04 24             	mov    %eax,(%esp)
c010914b:	e8 dc ff ff ff       	call   c010912c <page2ppn>
c0109150:	c1 e0 0c             	shl    $0xc,%eax
}
c0109153:	c9                   	leave  
c0109154:	c3                   	ret    

c0109155 <page2kva>:
    }
    return &pages[PPN(pa)];
}

static inline void *
page2kva(struct Page *page) {
c0109155:	55                   	push   %ebp
c0109156:	89 e5                	mov    %esp,%ebp
c0109158:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c010915b:	8b 45 08             	mov    0x8(%ebp),%eax
c010915e:	89 04 24             	mov    %eax,(%esp)
c0109161:	e8 d9 ff ff ff       	call   c010913f <page2pa>
c0109166:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109169:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010916c:	c1 e8 0c             	shr    $0xc,%eax
c010916f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109172:	a1 80 0f 1b c0       	mov    0xc01b0f80,%eax
c0109177:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010917a:	72 23                	jb     c010919f <page2kva+0x4a>
c010917c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010917f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109183:	c7 44 24 08 34 e2 10 	movl   $0xc010e234,0x8(%esp)
c010918a:	c0 
c010918b:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c0109192:	00 
c0109193:	c7 04 24 57 e2 10 c0 	movl   $0xc010e257,(%esp)
c010919a:	e8 66 72 ff ff       	call   c0100405 <__panic>
c010919f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01091a2:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01091a7:	c9                   	leave  
c01091a8:	c3                   	ret    

c01091a9 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
c01091a9:	55                   	push   %ebp
c01091aa:	89 e5                	mov    %esp,%ebp
c01091ac:	83 ec 18             	sub    $0x18,%esp
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
c01091af:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01091b6:	e8 5a 80 ff ff       	call   c0101215 <ide_device_valid>
c01091bb:	85 c0                	test   %eax,%eax
c01091bd:	75 1c                	jne    c01091db <swapfs_init+0x32>
        panic("swap fs isn't available.\n");
c01091bf:	c7 44 24 08 65 e2 10 	movl   $0xc010e265,0x8(%esp)
c01091c6:	c0 
c01091c7:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
c01091ce:	00 
c01091cf:	c7 04 24 7f e2 10 c0 	movl   $0xc010e27f,(%esp)
c01091d6:	e8 2a 72 ff ff       	call   c0100405 <__panic>
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
c01091db:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01091e2:	e8 70 80 ff ff       	call   c0101257 <ide_device_size>
c01091e7:	c1 e8 03             	shr    $0x3,%eax
c01091ea:	a3 1c 31 1b c0       	mov    %eax,0xc01b311c
}
c01091ef:	90                   	nop
c01091f0:	c9                   	leave  
c01091f1:	c3                   	ret    

c01091f2 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
c01091f2:	55                   	push   %ebp
c01091f3:	89 e5                	mov    %esp,%ebp
c01091f5:	83 ec 28             	sub    $0x28,%esp
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c01091f8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01091fb:	89 04 24             	mov    %eax,(%esp)
c01091fe:	e8 52 ff ff ff       	call   c0109155 <page2kva>
c0109203:	8b 55 08             	mov    0x8(%ebp),%edx
c0109206:	c1 ea 08             	shr    $0x8,%edx
c0109209:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010920c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109210:	74 0b                	je     c010921d <swapfs_read+0x2b>
c0109212:	8b 15 1c 31 1b c0    	mov    0xc01b311c,%edx
c0109218:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c010921b:	72 23                	jb     c0109240 <swapfs_read+0x4e>
c010921d:	8b 45 08             	mov    0x8(%ebp),%eax
c0109220:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109224:	c7 44 24 08 90 e2 10 	movl   $0xc010e290,0x8(%esp)
c010922b:	c0 
c010922c:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
c0109233:	00 
c0109234:	c7 04 24 7f e2 10 c0 	movl   $0xc010e27f,(%esp)
c010923b:	e8 c5 71 ff ff       	call   c0100405 <__panic>
c0109240:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109243:	c1 e2 03             	shl    $0x3,%edx
c0109246:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c010924d:	00 
c010924e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109252:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109256:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010925d:	e8 34 80 ff ff       	call   c0101296 <ide_read_secs>
}
c0109262:	c9                   	leave  
c0109263:	c3                   	ret    

c0109264 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
c0109264:	55                   	push   %ebp
c0109265:	89 e5                	mov    %esp,%ebp
c0109267:	83 ec 28             	sub    $0x28,%esp
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c010926a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010926d:	89 04 24             	mov    %eax,(%esp)
c0109270:	e8 e0 fe ff ff       	call   c0109155 <page2kva>
c0109275:	8b 55 08             	mov    0x8(%ebp),%edx
c0109278:	c1 ea 08             	shr    $0x8,%edx
c010927b:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010927e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109282:	74 0b                	je     c010928f <swapfs_write+0x2b>
c0109284:	8b 15 1c 31 1b c0    	mov    0xc01b311c,%edx
c010928a:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c010928d:	72 23                	jb     c01092b2 <swapfs_write+0x4e>
c010928f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109292:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109296:	c7 44 24 08 90 e2 10 	movl   $0xc010e290,0x8(%esp)
c010929d:	c0 
c010929e:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
c01092a5:	00 
c01092a6:	c7 04 24 7f e2 10 c0 	movl   $0xc010e27f,(%esp)
c01092ad:	e8 53 71 ff ff       	call   c0100405 <__panic>
c01092b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01092b5:	c1 e2 03             	shl    $0x3,%edx
c01092b8:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c01092bf:	00 
c01092c0:	89 44 24 08          	mov    %eax,0x8(%esp)
c01092c4:	89 54 24 04          	mov    %edx,0x4(%esp)
c01092c8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01092cf:	e8 fc 81 ff ff       	call   c01014d0 <ide_write_secs>
}
c01092d4:	c9                   	leave  
c01092d5:	c3                   	ret    

c01092d6 <switch_to>:
.text
.globl switch_to
switch_to:                      # switch_to(from, to)

    # save from's registers
    movl 4(%esp), %eax          # eax points to from
c01092d6:	8b 44 24 04          	mov    0x4(%esp),%eax
    popl 0(%eax)                # save eip !popl
c01092da:	8f 00                	popl   (%eax)
    movl %esp, 4(%eax)
c01092dc:	89 60 04             	mov    %esp,0x4(%eax)
    movl %ebx, 8(%eax)
c01092df:	89 58 08             	mov    %ebx,0x8(%eax)
    movl %ecx, 12(%eax)
c01092e2:	89 48 0c             	mov    %ecx,0xc(%eax)
    movl %edx, 16(%eax)
c01092e5:	89 50 10             	mov    %edx,0x10(%eax)
    movl %esi, 20(%eax)
c01092e8:	89 70 14             	mov    %esi,0x14(%eax)
    movl %edi, 24(%eax)
c01092eb:	89 78 18             	mov    %edi,0x18(%eax)
    movl %ebp, 28(%eax)
c01092ee:	89 68 1c             	mov    %ebp,0x1c(%eax)

    # restore to's registers
    movl 4(%esp), %eax          # not 8(%esp): popped return address already
c01092f1:	8b 44 24 04          	mov    0x4(%esp),%eax
                                # eax now points to to
    movl 28(%eax), %ebp
c01092f5:	8b 68 1c             	mov    0x1c(%eax),%ebp
    movl 24(%eax), %edi
c01092f8:	8b 78 18             	mov    0x18(%eax),%edi
    movl 20(%eax), %esi
c01092fb:	8b 70 14             	mov    0x14(%eax),%esi
    movl 16(%eax), %edx
c01092fe:	8b 50 10             	mov    0x10(%eax),%edx
    movl 12(%eax), %ecx
c0109301:	8b 48 0c             	mov    0xc(%eax),%ecx
    movl 8(%eax), %ebx
c0109304:	8b 58 08             	mov    0x8(%eax),%ebx
    movl 4(%eax), %esp
c0109307:	8b 60 04             	mov    0x4(%eax),%esp

    pushl 0(%eax)               # push eip
c010930a:	ff 30                	pushl  (%eax)

    ret
c010930c:	c3                   	ret    

c010930d <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)

    pushl %edx              # push arg
c010930d:	52                   	push   %edx
    call *%ebx              # call fn
c010930e:	ff d3                	call   *%ebx

    pushl %eax              # save the return value of fn(arg)
c0109310:	50                   	push   %eax
    call do_exit            # call do_exit to terminate current thread
c0109311:	e8 07 0d 00 00       	call   c010a01d <do_exit>

c0109316 <test_and_set_bit>:
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool
test_and_set_bit(int nr, volatile void *addr) {
c0109316:	55                   	push   %ebp
c0109317:	89 e5                	mov    %esp,%ebp
c0109319:	83 ec 10             	sub    $0x10,%esp
    int oldbit;
    asm volatile ("btsl %2, %1; sbbl %0, %0" : "=r" (oldbit), "=m" (*(volatile long *)addr) : "Ir" (nr) : "memory");
c010931c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010931f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109322:	0f ab 02             	bts    %eax,(%edx)
c0109325:	19 c0                	sbb    %eax,%eax
c0109327:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return oldbit != 0;
c010932a:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010932e:	0f 95 c0             	setne  %al
c0109331:	0f b6 c0             	movzbl %al,%eax
}
c0109334:	c9                   	leave  
c0109335:	c3                   	ret    

c0109336 <test_and_clear_bit>:
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool
test_and_clear_bit(int nr, volatile void *addr) {
c0109336:	55                   	push   %ebp
c0109337:	89 e5                	mov    %esp,%ebp
c0109339:	83 ec 10             	sub    $0x10,%esp
    int oldbit;
    asm volatile ("btrl %2, %1; sbbl %0, %0" : "=r" (oldbit), "=m" (*(volatile long *)addr) : "Ir" (nr) : "memory");
c010933c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010933f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109342:	0f b3 02             	btr    %eax,(%edx)
c0109345:	19 c0                	sbb    %eax,%eax
c0109347:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return oldbit != 0;
c010934a:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010934e:	0f 95 c0             	setne  %al
c0109351:	0f b6 c0             	movzbl %al,%eax
}
c0109354:	c9                   	leave  
c0109355:	c3                   	ret    

c0109356 <__intr_save>:
#include <assert.h>
#include <atomic.h>
#include <sched.h>

static inline bool
__intr_save(void) {
c0109356:	55                   	push   %ebp
c0109357:	89 e5                	mov    %esp,%ebp
c0109359:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010935c:	9c                   	pushf  
c010935d:	58                   	pop    %eax
c010935e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0109361:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0109364:	25 00 02 00 00       	and    $0x200,%eax
c0109369:	85 c0                	test   %eax,%eax
c010936b:	74 0c                	je     c0109379 <__intr_save+0x23>
        intr_disable();
c010936d:	e8 83 8e ff ff       	call   c01021f5 <intr_disable>
        return 1;
c0109372:	b8 01 00 00 00       	mov    $0x1,%eax
c0109377:	eb 05                	jmp    c010937e <__intr_save+0x28>
    }
    return 0;
c0109379:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010937e:	c9                   	leave  
c010937f:	c3                   	ret    

c0109380 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0109380:	55                   	push   %ebp
c0109381:	89 e5                	mov    %esp,%ebp
c0109383:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0109386:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010938a:	74 05                	je     c0109391 <__intr_restore+0x11>
        intr_enable();
c010938c:	e8 5d 8e ff ff       	call   c01021ee <intr_enable>
    }
}
c0109391:	90                   	nop
c0109392:	c9                   	leave  
c0109393:	c3                   	ret    

c0109394 <try_lock>:
lock_init(lock_t *lock) {
    *lock = 0;
}

static inline bool
try_lock(lock_t *lock) {
c0109394:	55                   	push   %ebp
c0109395:	89 e5                	mov    %esp,%ebp
c0109397:	83 ec 08             	sub    $0x8,%esp
    return !test_and_set_bit(0, lock);
c010939a:	8b 45 08             	mov    0x8(%ebp),%eax
c010939d:	89 44 24 04          	mov    %eax,0x4(%esp)
c01093a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01093a8:	e8 69 ff ff ff       	call   c0109316 <test_and_set_bit>
c01093ad:	85 c0                	test   %eax,%eax
c01093af:	0f 94 c0             	sete   %al
c01093b2:	0f b6 c0             	movzbl %al,%eax
}
c01093b5:	c9                   	leave  
c01093b6:	c3                   	ret    

c01093b7 <lock>:

static inline void
lock(lock_t *lock) {
c01093b7:	55                   	push   %ebp
c01093b8:	89 e5                	mov    %esp,%ebp
c01093ba:	83 ec 18             	sub    $0x18,%esp
    while (!try_lock(lock)) {
c01093bd:	eb 05                	jmp    c01093c4 <lock+0xd>
        schedule();
c01093bf:	e8 ce 1d 00 00       	call   c010b192 <schedule>
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
c01093c4:	8b 45 08             	mov    0x8(%ebp),%eax
c01093c7:	89 04 24             	mov    %eax,(%esp)
c01093ca:	e8 c5 ff ff ff       	call   c0109394 <try_lock>
c01093cf:	85 c0                	test   %eax,%eax
c01093d1:	74 ec                	je     c01093bf <lock+0x8>
        schedule();
    }
}
c01093d3:	90                   	nop
c01093d4:	c9                   	leave  
c01093d5:	c3                   	ret    

c01093d6 <unlock>:

static inline void
unlock(lock_t *lock) {
c01093d6:	55                   	push   %ebp
c01093d7:	89 e5                	mov    %esp,%ebp
c01093d9:	83 ec 18             	sub    $0x18,%esp
    if (!test_and_clear_bit(0, lock)) {
c01093dc:	8b 45 08             	mov    0x8(%ebp),%eax
c01093df:	89 44 24 04          	mov    %eax,0x4(%esp)
c01093e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01093ea:	e8 47 ff ff ff       	call   c0109336 <test_and_clear_bit>
c01093ef:	85 c0                	test   %eax,%eax
c01093f1:	75 1c                	jne    c010940f <unlock+0x39>
        panic("Unlock failed.\n");
c01093f3:	c7 44 24 08 b0 e2 10 	movl   $0xc010e2b0,0x8(%esp)
c01093fa:	c0 
c01093fb:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
c0109402:	00 
c0109403:	c7 04 24 c0 e2 10 c0 	movl   $0xc010e2c0,(%esp)
c010940a:	e8 f6 6f ff ff       	call   c0100405 <__panic>
    }
}
c010940f:	90                   	nop
c0109410:	c9                   	leave  
c0109411:	c3                   	ret    

c0109412 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0109412:	55                   	push   %ebp
c0109413:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0109415:	8b 45 08             	mov    0x8(%ebp),%eax
c0109418:	8b 15 60 31 1b c0    	mov    0xc01b3160,%edx
c010941e:	29 d0                	sub    %edx,%eax
c0109420:	c1 f8 05             	sar    $0x5,%eax
}
c0109423:	5d                   	pop    %ebp
c0109424:	c3                   	ret    

c0109425 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0109425:	55                   	push   %ebp
c0109426:	89 e5                	mov    %esp,%ebp
c0109428:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c010942b:	8b 45 08             	mov    0x8(%ebp),%eax
c010942e:	89 04 24             	mov    %eax,(%esp)
c0109431:	e8 dc ff ff ff       	call   c0109412 <page2ppn>
c0109436:	c1 e0 0c             	shl    $0xc,%eax
}
c0109439:	c9                   	leave  
c010943a:	c3                   	ret    

c010943b <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c010943b:	55                   	push   %ebp
c010943c:	89 e5                	mov    %esp,%ebp
c010943e:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0109441:	8b 45 08             	mov    0x8(%ebp),%eax
c0109444:	c1 e8 0c             	shr    $0xc,%eax
c0109447:	89 c2                	mov    %eax,%edx
c0109449:	a1 80 0f 1b c0       	mov    0xc01b0f80,%eax
c010944e:	39 c2                	cmp    %eax,%edx
c0109450:	72 1c                	jb     c010946e <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0109452:	c7 44 24 08 d4 e2 10 	movl   $0xc010e2d4,0x8(%esp)
c0109459:	c0 
c010945a:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0109461:	00 
c0109462:	c7 04 24 f3 e2 10 c0 	movl   $0xc010e2f3,(%esp)
c0109469:	e8 97 6f ff ff       	call   c0100405 <__panic>
    }
    return &pages[PPN(pa)];
c010946e:	a1 60 31 1b c0       	mov    0xc01b3160,%eax
c0109473:	8b 55 08             	mov    0x8(%ebp),%edx
c0109476:	c1 ea 0c             	shr    $0xc,%edx
c0109479:	c1 e2 05             	shl    $0x5,%edx
c010947c:	01 d0                	add    %edx,%eax
}
c010947e:	c9                   	leave  
c010947f:	c3                   	ret    

c0109480 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0109480:	55                   	push   %ebp
c0109481:	89 e5                	mov    %esp,%ebp
c0109483:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0109486:	8b 45 08             	mov    0x8(%ebp),%eax
c0109489:	89 04 24             	mov    %eax,(%esp)
c010948c:	e8 94 ff ff ff       	call   c0109425 <page2pa>
c0109491:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109494:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109497:	c1 e8 0c             	shr    $0xc,%eax
c010949a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010949d:	a1 80 0f 1b c0       	mov    0xc01b0f80,%eax
c01094a2:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01094a5:	72 23                	jb     c01094ca <page2kva+0x4a>
c01094a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01094aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01094ae:	c7 44 24 08 04 e3 10 	movl   $0xc010e304,0x8(%esp)
c01094b5:	c0 
c01094b6:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c01094bd:	00 
c01094be:	c7 04 24 f3 e2 10 c0 	movl   $0xc010e2f3,(%esp)
c01094c5:	e8 3b 6f ff ff       	call   c0100405 <__panic>
c01094ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01094cd:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01094d2:	c9                   	leave  
c01094d3:	c3                   	ret    

c01094d4 <kva2page>:

static inline struct Page *
kva2page(void *kva) {
c01094d4:	55                   	push   %ebp
c01094d5:	89 e5                	mov    %esp,%ebp
c01094d7:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c01094da:	8b 45 08             	mov    0x8(%ebp),%eax
c01094dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01094e0:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01094e7:	77 23                	ja     c010950c <kva2page+0x38>
c01094e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01094ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01094f0:	c7 44 24 08 28 e3 10 	movl   $0xc010e328,0x8(%esp)
c01094f7:	c0 
c01094f8:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
c01094ff:	00 
c0109500:	c7 04 24 f3 e2 10 c0 	movl   $0xc010e2f3,(%esp)
c0109507:	e8 f9 6e ff ff       	call   c0100405 <__panic>
c010950c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010950f:	05 00 00 00 40       	add    $0x40000000,%eax
c0109514:	89 04 24             	mov    %eax,(%esp)
c0109517:	e8 1f ff ff ff       	call   c010943b <pa2page>
}
c010951c:	c9                   	leave  
c010951d:	c3                   	ret    

c010951e <mm_count_inc>:

static inline int
mm_count_inc(struct mm_struct *mm) {
c010951e:	55                   	push   %ebp
c010951f:	89 e5                	mov    %esp,%ebp
    mm->mm_count += 1;
c0109521:	8b 45 08             	mov    0x8(%ebp),%eax
c0109524:	8b 40 18             	mov    0x18(%eax),%eax
c0109527:	8d 50 01             	lea    0x1(%eax),%edx
c010952a:	8b 45 08             	mov    0x8(%ebp),%eax
c010952d:	89 50 18             	mov    %edx,0x18(%eax)
    return mm->mm_count;
c0109530:	8b 45 08             	mov    0x8(%ebp),%eax
c0109533:	8b 40 18             	mov    0x18(%eax),%eax
}
c0109536:	5d                   	pop    %ebp
c0109537:	c3                   	ret    

c0109538 <mm_count_dec>:

static inline int
mm_count_dec(struct mm_struct *mm) {
c0109538:	55                   	push   %ebp
c0109539:	89 e5                	mov    %esp,%ebp
    mm->mm_count -= 1;
c010953b:	8b 45 08             	mov    0x8(%ebp),%eax
c010953e:	8b 40 18             	mov    0x18(%eax),%eax
c0109541:	8d 50 ff             	lea    -0x1(%eax),%edx
c0109544:	8b 45 08             	mov    0x8(%ebp),%eax
c0109547:	89 50 18             	mov    %edx,0x18(%eax)
    return mm->mm_count;
c010954a:	8b 45 08             	mov    0x8(%ebp),%eax
c010954d:	8b 40 18             	mov    0x18(%eax),%eax
}
c0109550:	5d                   	pop    %ebp
c0109551:	c3                   	ret    

c0109552 <lock_mm>:

static inline void
lock_mm(struct mm_struct *mm) {
c0109552:	55                   	push   %ebp
c0109553:	89 e5                	mov    %esp,%ebp
c0109555:	83 ec 18             	sub    $0x18,%esp
    if (mm != NULL) {
c0109558:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010955c:	74 0e                	je     c010956c <lock_mm+0x1a>
        lock(&(mm->mm_lock));
c010955e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109561:	83 c0 1c             	add    $0x1c,%eax
c0109564:	89 04 24             	mov    %eax,(%esp)
c0109567:	e8 4b fe ff ff       	call   c01093b7 <lock>
    }
}
c010956c:	90                   	nop
c010956d:	c9                   	leave  
c010956e:	c3                   	ret    

c010956f <unlock_mm>:

static inline void
unlock_mm(struct mm_struct *mm) {
c010956f:	55                   	push   %ebp
c0109570:	89 e5                	mov    %esp,%ebp
c0109572:	83 ec 18             	sub    $0x18,%esp
    if (mm != NULL) {
c0109575:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109579:	74 0e                	je     c0109589 <unlock_mm+0x1a>
        unlock(&(mm->mm_lock));
c010957b:	8b 45 08             	mov    0x8(%ebp),%eax
c010957e:	83 c0 1c             	add    $0x1c,%eax
c0109581:	89 04 24             	mov    %eax,(%esp)
c0109584:	e8 4d fe ff ff       	call   c01093d6 <unlock>
    }
}
c0109589:	90                   	nop
c010958a:	c9                   	leave  
c010958b:	c3                   	ret    

c010958c <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
c010958c:	55                   	push   %ebp
c010958d:	89 e5                	mov    %esp,%ebp
c010958f:	83 ec 28             	sub    $0x28,%esp
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
c0109592:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
c0109599:	e8 f9 c3 ff ff       	call   c0105997 <kmalloc>
c010959e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (proc != NULL) {
c01095a1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01095a5:	0f 84 4c 01 00 00    	je     c01096f7 <alloc_proc+0x16b>
	proc->state = PROC_UNINIT; // 设置进程为“初始”态
c01095ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095ae:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        proc->pid = -1;            // 设置进程pid未初始化的值
c01095b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095b7:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
        proc->runs = 0;            // 初始化运行时间
c01095be:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095c1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        proc->kstack = 0;          // 初始化内核栈地址
c01095c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095cb:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        proc->need_resched = 0;    // 初始化，不需要调度
c01095d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095d5:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        proc->parent = NULL;       // 父进程为空
c01095dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095df:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        proc->mm = NULL;           // 虚拟内存为空
c01095e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095e9:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
        memset(&(proc->context),0, sizeof(struct context)); // 初始化上下文
c01095f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095f3:	83 c0 1c             	add    $0x1c,%eax
c01095f6:	c7 44 24 08 20 00 00 	movl   $0x20,0x8(%esp)
c01095fd:	00 
c01095fe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109605:	00 
c0109606:	89 04 24             	mov    %eax,(%esp)
c0109609:	e8 78 23 00 00       	call   c010b986 <memset>
        proc->tf = NULL;           // 中断帧指针为空
c010960e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109611:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
        proc->cr3 = boot_cr3;       // 使用内核页目录表的基址
c0109618:	8b 15 5c 31 1b c0    	mov    0xc01b315c,%edx
c010961e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109621:	89 50 40             	mov    %edx,0x40(%eax)
        proc->flags = 0;            // flag为0
c0109624:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109627:	c7 40 44 00 00 00 00 	movl   $0x0,0x44(%eax)
        memset(proc->name,0,PROC_NAME_LEN); // 进程名为0
c010962e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109631:	83 c0 48             	add    $0x48,%eax
c0109634:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c010963b:	00 
c010963c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109643:	00 
c0109644:	89 04 24             	mov    %eax,(%esp)
c0109647:	e8 3a 23 00 00       	call   c010b986 <memset>
        proc->wait_state = 0; //初始化进程等待状态
c010964c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010964f:	c7 40 6c 00 00 00 00 	movl   $0x0,0x6c(%eax)
        proc->cptr = proc->optr = proc->yptr = NULL; //设置指针
c0109656:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109659:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
c0109660:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109663:	8b 50 74             	mov    0x74(%eax),%edx
c0109666:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109669:	89 50 78             	mov    %edx,0x78(%eax)
c010966c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010966f:	8b 50 78             	mov    0x78(%eax),%edx
c0109672:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109675:	89 50 70             	mov    %edx,0x70(%eax)
        proc->rq = NULL; // 初始化运行队列
c0109678:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010967b:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
        list_init(&(proc->run_link));
c0109682:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109685:	83 e8 80             	sub    $0xffffff80,%eax
c0109688:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010968b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010968e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0109691:	89 50 04             	mov    %edx,0x4(%eax)
c0109694:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109697:	8b 50 04             	mov    0x4(%eax),%edx
c010969a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010969d:	89 10                	mov    %edx,(%eax)
        proc->time_slice = 0; // 初始化时间片
c010969f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01096a2:	c7 80 88 00 00 00 00 	movl   $0x0,0x88(%eax)
c01096a9:	00 00 00 
        proc->lab6_run_pool.left = proc->lab6_run_pool.right = proc->lab6_run_pool.parent = NULL;
c01096ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01096af:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
c01096b6:	00 00 00 
c01096b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01096bc:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
c01096c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01096c5:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
c01096cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01096ce:	8b 90 94 00 00 00    	mov    0x94(%eax),%edx
c01096d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01096d7:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)
        proc->lab6_stride = 0; // 设置步长为0
c01096dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01096e0:	c7 80 98 00 00 00 00 	movl   $0x0,0x98(%eax)
c01096e7:	00 00 00 
        proc->lab6_priority = 0; // 设置优先级为0
c01096ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01096ed:	c7 80 9c 00 00 00 00 	movl   $0x0,0x9c(%eax)
c01096f4:	00 00 00 
    }
    return proc;
c01096f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01096fa:	c9                   	leave  
c01096fb:	c3                   	ret    

c01096fc <set_proc_name>:

// set_proc_name - set the name of proc
char *
set_proc_name(struct proc_struct *proc, const char *name) {
c01096fc:	55                   	push   %ebp
c01096fd:	89 e5                	mov    %esp,%ebp
c01096ff:	83 ec 18             	sub    $0x18,%esp
    memset(proc->name, 0, sizeof(proc->name));
c0109702:	8b 45 08             	mov    0x8(%ebp),%eax
c0109705:	83 c0 48             	add    $0x48,%eax
c0109708:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c010970f:	00 
c0109710:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109717:	00 
c0109718:	89 04 24             	mov    %eax,(%esp)
c010971b:	e8 66 22 00 00       	call   c010b986 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
c0109720:	8b 45 08             	mov    0x8(%ebp),%eax
c0109723:	8d 50 48             	lea    0x48(%eax),%edx
c0109726:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c010972d:	00 
c010972e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109731:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109735:	89 14 24             	mov    %edx,(%esp)
c0109738:	e8 2c 23 00 00       	call   c010ba69 <memcpy>
}
c010973d:	c9                   	leave  
c010973e:	c3                   	ret    

c010973f <get_proc_name>:

// get_proc_name - get the name of proc
char *
get_proc_name(struct proc_struct *proc) {
c010973f:	55                   	push   %ebp
c0109740:	89 e5                	mov    %esp,%ebp
c0109742:	83 ec 18             	sub    $0x18,%esp
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
c0109745:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c010974c:	00 
c010974d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109754:	00 
c0109755:	c7 04 24 44 30 1b c0 	movl   $0xc01b3044,(%esp)
c010975c:	e8 25 22 00 00       	call   c010b986 <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
c0109761:	8b 45 08             	mov    0x8(%ebp),%eax
c0109764:	83 c0 48             	add    $0x48,%eax
c0109767:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c010976e:	00 
c010976f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109773:	c7 04 24 44 30 1b c0 	movl   $0xc01b3044,(%esp)
c010977a:	e8 ea 22 00 00       	call   c010ba69 <memcpy>
}
c010977f:	c9                   	leave  
c0109780:	c3                   	ret    

c0109781 <set_links>:

// set_links - set the relation links of process
static void
set_links(struct proc_struct *proc) {
c0109781:	55                   	push   %ebp
c0109782:	89 e5                	mov    %esp,%ebp
c0109784:	83 ec 20             	sub    $0x20,%esp
    list_add(&proc_list, &(proc->list_link));
c0109787:	8b 45 08             	mov    0x8(%ebp),%eax
c010978a:	83 c0 58             	add    $0x58,%eax
c010978d:	c7 45 fc 64 31 1b c0 	movl   $0xc01b3164,-0x4(%ebp)
c0109794:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0109797:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010979a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010979d:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01097a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c01097a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01097a6:	8b 40 04             	mov    0x4(%eax),%eax
c01097a9:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01097ac:	89 55 ec             	mov    %edx,-0x14(%ebp)
c01097af:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01097b2:	89 55 e8             	mov    %edx,-0x18(%ebp)
c01097b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01097b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01097bb:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01097be:	89 10                	mov    %edx,(%eax)
c01097c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01097c3:	8b 10                	mov    (%eax),%edx
c01097c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01097c8:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01097cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01097ce:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01097d1:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01097d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01097d7:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01097da:	89 10                	mov    %edx,(%eax)
    proc->yptr = NULL;
c01097dc:	8b 45 08             	mov    0x8(%ebp),%eax
c01097df:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
    if ((proc->optr = proc->parent->cptr) != NULL) {
c01097e6:	8b 45 08             	mov    0x8(%ebp),%eax
c01097e9:	8b 40 14             	mov    0x14(%eax),%eax
c01097ec:	8b 50 70             	mov    0x70(%eax),%edx
c01097ef:	8b 45 08             	mov    0x8(%ebp),%eax
c01097f2:	89 50 78             	mov    %edx,0x78(%eax)
c01097f5:	8b 45 08             	mov    0x8(%ebp),%eax
c01097f8:	8b 40 78             	mov    0x78(%eax),%eax
c01097fb:	85 c0                	test   %eax,%eax
c01097fd:	74 0c                	je     c010980b <set_links+0x8a>
        proc->optr->yptr = proc;
c01097ff:	8b 45 08             	mov    0x8(%ebp),%eax
c0109802:	8b 40 78             	mov    0x78(%eax),%eax
c0109805:	8b 55 08             	mov    0x8(%ebp),%edx
c0109808:	89 50 74             	mov    %edx,0x74(%eax)
    }
    proc->parent->cptr = proc;
c010980b:	8b 45 08             	mov    0x8(%ebp),%eax
c010980e:	8b 40 14             	mov    0x14(%eax),%eax
c0109811:	8b 55 08             	mov    0x8(%ebp),%edx
c0109814:	89 50 70             	mov    %edx,0x70(%eax)
    nr_process ++;
c0109817:	a1 40 30 1b c0       	mov    0xc01b3040,%eax
c010981c:	40                   	inc    %eax
c010981d:	a3 40 30 1b c0       	mov    %eax,0xc01b3040
}
c0109822:	90                   	nop
c0109823:	c9                   	leave  
c0109824:	c3                   	ret    

c0109825 <remove_links>:

// remove_links - clean the relation links of process
static void
remove_links(struct proc_struct *proc) {
c0109825:	55                   	push   %ebp
c0109826:	89 e5                	mov    %esp,%ebp
c0109828:	83 ec 10             	sub    $0x10,%esp
    list_del(&(proc->list_link));
c010982b:	8b 45 08             	mov    0x8(%ebp),%eax
c010982e:	83 c0 58             	add    $0x58,%eax
c0109831:	89 45 fc             	mov    %eax,-0x4(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0109834:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109837:	8b 40 04             	mov    0x4(%eax),%eax
c010983a:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010983d:	8b 12                	mov    (%edx),%edx
c010983f:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0109842:	89 45 f4             	mov    %eax,-0xc(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0109845:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109848:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010984b:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010984e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109851:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0109854:	89 10                	mov    %edx,(%eax)
    if (proc->optr != NULL) {
c0109856:	8b 45 08             	mov    0x8(%ebp),%eax
c0109859:	8b 40 78             	mov    0x78(%eax),%eax
c010985c:	85 c0                	test   %eax,%eax
c010985e:	74 0f                	je     c010986f <remove_links+0x4a>
        proc->optr->yptr = proc->yptr;
c0109860:	8b 45 08             	mov    0x8(%ebp),%eax
c0109863:	8b 40 78             	mov    0x78(%eax),%eax
c0109866:	8b 55 08             	mov    0x8(%ebp),%edx
c0109869:	8b 52 74             	mov    0x74(%edx),%edx
c010986c:	89 50 74             	mov    %edx,0x74(%eax)
    }
    if (proc->yptr != NULL) {
c010986f:	8b 45 08             	mov    0x8(%ebp),%eax
c0109872:	8b 40 74             	mov    0x74(%eax),%eax
c0109875:	85 c0                	test   %eax,%eax
c0109877:	74 11                	je     c010988a <remove_links+0x65>
        proc->yptr->optr = proc->optr;
c0109879:	8b 45 08             	mov    0x8(%ebp),%eax
c010987c:	8b 40 74             	mov    0x74(%eax),%eax
c010987f:	8b 55 08             	mov    0x8(%ebp),%edx
c0109882:	8b 52 78             	mov    0x78(%edx),%edx
c0109885:	89 50 78             	mov    %edx,0x78(%eax)
c0109888:	eb 0f                	jmp    c0109899 <remove_links+0x74>
    }
    else {
       proc->parent->cptr = proc->optr;
c010988a:	8b 45 08             	mov    0x8(%ebp),%eax
c010988d:	8b 40 14             	mov    0x14(%eax),%eax
c0109890:	8b 55 08             	mov    0x8(%ebp),%edx
c0109893:	8b 52 78             	mov    0x78(%edx),%edx
c0109896:	89 50 70             	mov    %edx,0x70(%eax)
    }
    nr_process --;
c0109899:	a1 40 30 1b c0       	mov    0xc01b3040,%eax
c010989e:	48                   	dec    %eax
c010989f:	a3 40 30 1b c0       	mov    %eax,0xc01b3040
}
c01098a4:	90                   	nop
c01098a5:	c9                   	leave  
c01098a6:	c3                   	ret    

c01098a7 <get_pid>:

// get_pid - alloc a unique pid for process
static int
get_pid(void) {
c01098a7:	55                   	push   %ebp
c01098a8:	89 e5                	mov    %esp,%ebp
c01098aa:	83 ec 10             	sub    $0x10,%esp
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
c01098ad:	c7 45 f8 64 31 1b c0 	movl   $0xc01b3164,-0x8(%ebp)
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++ last_pid >= MAX_PID) {
c01098b4:	a1 78 ca 12 c0       	mov    0xc012ca78,%eax
c01098b9:	40                   	inc    %eax
c01098ba:	a3 78 ca 12 c0       	mov    %eax,0xc012ca78
c01098bf:	a1 78 ca 12 c0       	mov    0xc012ca78,%eax
c01098c4:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c01098c9:	7e 0c                	jle    c01098d7 <get_pid+0x30>
        last_pid = 1;
c01098cb:	c7 05 78 ca 12 c0 01 	movl   $0x1,0xc012ca78
c01098d2:	00 00 00 
        goto inside;
c01098d5:	eb 13                	jmp    c01098ea <get_pid+0x43>
    }
    if (last_pid >= next_safe) {
c01098d7:	8b 15 78 ca 12 c0    	mov    0xc012ca78,%edx
c01098dd:	a1 7c ca 12 c0       	mov    0xc012ca7c,%eax
c01098e2:	39 c2                	cmp    %eax,%edx
c01098e4:	0f 8c aa 00 00 00    	jl     c0109994 <get_pid+0xed>
    inside:
        next_safe = MAX_PID;
c01098ea:	c7 05 7c ca 12 c0 00 	movl   $0x2000,0xc012ca7c
c01098f1:	20 00 00 
    repeat:
        le = list;
c01098f4:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01098f7:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while ((le = list_next(le)) != list) {
c01098fa:	eb 7d                	jmp    c0109979 <get_pid+0xd2>
            proc = le2proc(le, list_link);
c01098fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01098ff:	83 e8 58             	sub    $0x58,%eax
c0109902:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (proc->pid == last_pid) {
c0109905:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109908:	8b 50 04             	mov    0x4(%eax),%edx
c010990b:	a1 78 ca 12 c0       	mov    0xc012ca78,%eax
c0109910:	39 c2                	cmp    %eax,%edx
c0109912:	75 3c                	jne    c0109950 <get_pid+0xa9>
                if (++ last_pid >= next_safe) {
c0109914:	a1 78 ca 12 c0       	mov    0xc012ca78,%eax
c0109919:	40                   	inc    %eax
c010991a:	a3 78 ca 12 c0       	mov    %eax,0xc012ca78
c010991f:	8b 15 78 ca 12 c0    	mov    0xc012ca78,%edx
c0109925:	a1 7c ca 12 c0       	mov    0xc012ca7c,%eax
c010992a:	39 c2                	cmp    %eax,%edx
c010992c:	7c 4b                	jl     c0109979 <get_pid+0xd2>
                    if (last_pid >= MAX_PID) {
c010992e:	a1 78 ca 12 c0       	mov    0xc012ca78,%eax
c0109933:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c0109938:	7e 0a                	jle    c0109944 <get_pid+0x9d>
                        last_pid = 1;
c010993a:	c7 05 78 ca 12 c0 01 	movl   $0x1,0xc012ca78
c0109941:	00 00 00 
                    }
                    next_safe = MAX_PID;
c0109944:	c7 05 7c ca 12 c0 00 	movl   $0x2000,0xc012ca7c
c010994b:	20 00 00 
                    goto repeat;
c010994e:	eb a4                	jmp    c01098f4 <get_pid+0x4d>
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid) {
c0109950:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109953:	8b 50 04             	mov    0x4(%eax),%edx
c0109956:	a1 78 ca 12 c0       	mov    0xc012ca78,%eax
c010995b:	39 c2                	cmp    %eax,%edx
c010995d:	7e 1a                	jle    c0109979 <get_pid+0xd2>
c010995f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109962:	8b 50 04             	mov    0x4(%eax),%edx
c0109965:	a1 7c ca 12 c0       	mov    0xc012ca7c,%eax
c010996a:	39 c2                	cmp    %eax,%edx
c010996c:	7d 0b                	jge    c0109979 <get_pid+0xd2>
                next_safe = proc->pid;
c010996e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109971:	8b 40 04             	mov    0x4(%eax),%eax
c0109974:	a3 7c ca 12 c0       	mov    %eax,0xc012ca7c
c0109979:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010997c:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010997f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109982:	8b 40 04             	mov    0x4(%eax),%eax
    if (last_pid >= next_safe) {
    inside:
        next_safe = MAX_PID;
    repeat:
        le = list;
        while ((le = list_next(le)) != list) {
c0109985:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0109988:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010998b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c010998e:	0f 85 68 ff ff ff    	jne    c01098fc <get_pid+0x55>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
                next_safe = proc->pid;
            }
        }
    }
    return last_pid;
c0109994:	a1 78 ca 12 c0       	mov    0xc012ca78,%eax
}
c0109999:	c9                   	leave  
c010999a:	c3                   	ret    

c010999b <proc_run>:

// proc_run - make process "proc" running on cpu
// NOTE: before call switch_to, should load  base addr of "proc"'s new PDT
void
proc_run(struct proc_struct *proc) {
c010999b:	55                   	push   %ebp
c010999c:	89 e5                	mov    %esp,%ebp
c010999e:	83 ec 28             	sub    $0x28,%esp
    if (proc != current) {
c01099a1:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c01099a6:	39 45 08             	cmp    %eax,0x8(%ebp)
c01099a9:	74 63                	je     c0109a0e <proc_run+0x73>
        bool intr_flag;
        struct proc_struct *prev = current, *next = proc;
c01099ab:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c01099b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01099b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01099b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
        local_intr_save(intr_flag);
c01099b9:	e8 98 f9 ff ff       	call   c0109356 <__intr_save>
c01099be:	89 45 ec             	mov    %eax,-0x14(%ebp)
        {
            current = proc;
c01099c1:	8b 45 08             	mov    0x8(%ebp),%eax
c01099c4:	a3 28 10 1b c0       	mov    %eax,0xc01b1028
            load_esp0(next->kstack + KSTACKSIZE);
c01099c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01099cc:	8b 40 0c             	mov    0xc(%eax),%eax
c01099cf:	05 00 20 00 00       	add    $0x2000,%eax
c01099d4:	89 04 24             	mov    %eax,(%esp)
c01099d7:	e8 49 da ff ff       	call   c0107425 <load_esp0>
            lcr3(next->cr3);
c01099dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01099df:	8b 40 40             	mov    0x40(%eax),%eax
c01099e2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("mov %0, %%cr0" :: "r" (cr0) : "memory");
}

static inline void
lcr3(uintptr_t cr3) {
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c01099e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01099e8:	0f 22 d8             	mov    %eax,%cr3
            switch_to(&(prev->context), &(next->context));
c01099eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01099ee:	8d 50 1c             	lea    0x1c(%eax),%edx
c01099f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01099f4:	83 c0 1c             	add    $0x1c,%eax
c01099f7:	89 54 24 04          	mov    %edx,0x4(%esp)
c01099fb:	89 04 24             	mov    %eax,(%esp)
c01099fe:	e8 d3 f8 ff ff       	call   c01092d6 <switch_to>
        }
        local_intr_restore(intr_flag);
c0109a03:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109a06:	89 04 24             	mov    %eax,(%esp)
c0109a09:	e8 72 f9 ff ff       	call   c0109380 <__intr_restore>
    }
}
c0109a0e:	90                   	nop
c0109a0f:	c9                   	leave  
c0109a10:	c3                   	ret    

c0109a11 <forkret>:

// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
c0109a11:	55                   	push   %ebp
c0109a12:	89 e5                	mov    %esp,%ebp
c0109a14:	83 ec 18             	sub    $0x18,%esp
    forkrets(current->tf);
c0109a17:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c0109a1c:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109a1f:	89 04 24             	mov    %eax,(%esp)
c0109a22:	e8 ac 9a ff ff       	call   c01034d3 <forkrets>
}
c0109a27:	90                   	nop
c0109a28:	c9                   	leave  
c0109a29:	c3                   	ret    

c0109a2a <hash_proc>:

// hash_proc - add proc into proc hash_list
static void
hash_proc(struct proc_struct *proc) {
c0109a2a:	55                   	push   %ebp
c0109a2b:	89 e5                	mov    %esp,%ebp
c0109a2d:	53                   	push   %ebx
c0109a2e:	83 ec 34             	sub    $0x34,%esp
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
c0109a31:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a34:	8d 58 60             	lea    0x60(%eax),%ebx
c0109a37:	8b 45 08             	mov    0x8(%ebp),%eax
c0109a3a:	8b 40 04             	mov    0x4(%eax),%eax
c0109a3d:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
c0109a44:	00 
c0109a45:	89 04 24             	mov    %eax,(%esp)
c0109a48:	e8 33 27 00 00       	call   c010c180 <hash32>
c0109a4d:	c1 e0 03             	shl    $0x3,%eax
c0109a50:	05 40 10 1b c0       	add    $0xc01b1040,%eax
c0109a55:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109a58:	89 5d f0             	mov    %ebx,-0x10(%ebp)
c0109a5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109a5e:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109a61:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109a64:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0109a67:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109a6a:	8b 40 04             	mov    0x4(%eax),%eax
c0109a6d:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0109a70:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0109a73:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109a76:	89 55 e0             	mov    %edx,-0x20(%ebp)
c0109a79:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0109a7c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109a7f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0109a82:	89 10                	mov    %edx,(%eax)
c0109a84:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109a87:	8b 10                	mov    (%eax),%edx
c0109a89:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109a8c:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0109a8f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109a92:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0109a95:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0109a98:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109a9b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0109a9e:	89 10                	mov    %edx,(%eax)
}
c0109aa0:	90                   	nop
c0109aa1:	83 c4 34             	add    $0x34,%esp
c0109aa4:	5b                   	pop    %ebx
c0109aa5:	5d                   	pop    %ebp
c0109aa6:	c3                   	ret    

c0109aa7 <unhash_proc>:

// unhash_proc - delete proc from proc hash_list
static void
unhash_proc(struct proc_struct *proc) {
c0109aa7:	55                   	push   %ebp
c0109aa8:	89 e5                	mov    %esp,%ebp
c0109aaa:	83 ec 10             	sub    $0x10,%esp
    list_del(&(proc->hash_link));
c0109aad:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ab0:	83 c0 60             	add    $0x60,%eax
c0109ab3:	89 45 fc             	mov    %eax,-0x4(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0109ab6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109ab9:	8b 40 04             	mov    0x4(%eax),%eax
c0109abc:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0109abf:	8b 12                	mov    (%edx),%edx
c0109ac1:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0109ac4:	89 45 f4             	mov    %eax,-0xc(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0109ac7:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109aca:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109acd:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0109ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109ad3:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0109ad6:	89 10                	mov    %edx,(%eax)
}
c0109ad8:	90                   	nop
c0109ad9:	c9                   	leave  
c0109ada:	c3                   	ret    

c0109adb <find_proc>:

// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid) {
c0109adb:	55                   	push   %ebp
c0109adc:	89 e5                	mov    %esp,%ebp
c0109ade:	83 ec 28             	sub    $0x28,%esp
    if (0 < pid && pid < MAX_PID) {
c0109ae1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109ae5:	7e 5f                	jle    c0109b46 <find_proc+0x6b>
c0109ae7:	81 7d 08 ff 1f 00 00 	cmpl   $0x1fff,0x8(%ebp)
c0109aee:	7f 56                	jg     c0109b46 <find_proc+0x6b>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
c0109af0:	8b 45 08             	mov    0x8(%ebp),%eax
c0109af3:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
c0109afa:	00 
c0109afb:	89 04 24             	mov    %eax,(%esp)
c0109afe:	e8 7d 26 00 00       	call   c010c180 <hash32>
c0109b03:	c1 e0 03             	shl    $0x3,%eax
c0109b06:	05 40 10 1b c0       	add    $0xc01b1040,%eax
c0109b0b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109b0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109b11:	89 45 f4             	mov    %eax,-0xc(%ebp)
        while ((le = list_next(le)) != list) {
c0109b14:	eb 19                	jmp    c0109b2f <find_proc+0x54>
            struct proc_struct *proc = le2proc(le, hash_link);
c0109b16:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109b19:	83 e8 60             	sub    $0x60,%eax
c0109b1c:	89 45 ec             	mov    %eax,-0x14(%ebp)
            if (proc->pid == pid) {
c0109b1f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109b22:	8b 40 04             	mov    0x4(%eax),%eax
c0109b25:	3b 45 08             	cmp    0x8(%ebp),%eax
c0109b28:	75 05                	jne    c0109b2f <find_proc+0x54>
                return proc;
c0109b2a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109b2d:	eb 1c                	jmp    c0109b4b <find_proc+0x70>
c0109b2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109b32:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0109b35:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109b38:	8b 40 04             	mov    0x4(%eax),%eax
// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid) {
    if (0 < pid && pid < MAX_PID) {
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
        while ((le = list_next(le)) != list) {
c0109b3b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109b3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109b41:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0109b44:	75 d0                	jne    c0109b16 <find_proc+0x3b>
            if (proc->pid == pid) {
                return proc;
            }
        }
    }
    return NULL;
c0109b46:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109b4b:	c9                   	leave  
c0109b4c:	c3                   	ret    

c0109b4d <kernel_thread>:

// kernel_thread - create a kernel thread using "fn" function
// NOTE: the contents of temp trapframe tf will be copied to 
//       proc->tf in do_fork-->copy_thread function
int
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
c0109b4d:	55                   	push   %ebp
c0109b4e:	89 e5                	mov    %esp,%ebp
c0109b50:	83 ec 68             	sub    $0x68,%esp
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));
c0109b53:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
c0109b5a:	00 
c0109b5b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109b62:	00 
c0109b63:	8d 45 ac             	lea    -0x54(%ebp),%eax
c0109b66:	89 04 24             	mov    %eax,(%esp)
c0109b69:	e8 18 1e 00 00       	call   c010b986 <memset>
    tf.tf_cs = KERNEL_CS;
c0109b6e:	66 c7 45 e8 08 00    	movw   $0x8,-0x18(%ebp)
    tf.tf_ds = tf.tf_es = tf.tf_ss = KERNEL_DS;
c0109b74:	66 c7 45 f4 10 00    	movw   $0x10,-0xc(%ebp)
c0109b7a:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0109b7e:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
c0109b82:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
c0109b86:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
    tf.tf_regs.reg_ebx = (uint32_t)fn;
c0109b8a:	8b 45 08             	mov    0x8(%ebp),%eax
c0109b8d:	89 45 bc             	mov    %eax,-0x44(%ebp)
    tf.tf_regs.reg_edx = (uint32_t)arg;
c0109b90:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109b93:	89 45 c0             	mov    %eax,-0x40(%ebp)
    tf.tf_eip = (uint32_t)kernel_thread_entry;
c0109b96:	b8 0d 93 10 c0       	mov    $0xc010930d,%eax
c0109b9b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
c0109b9e:	8b 45 10             	mov    0x10(%ebp),%eax
c0109ba1:	0d 00 01 00 00       	or     $0x100,%eax
c0109ba6:	89 c2                	mov    %eax,%edx
c0109ba8:	8d 45 ac             	lea    -0x54(%ebp),%eax
c0109bab:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109baf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109bb6:	00 
c0109bb7:	89 14 24             	mov    %edx,(%esp)
c0109bba:	e8 37 03 00 00       	call   c0109ef6 <do_fork>
}
c0109bbf:	c9                   	leave  
c0109bc0:	c3                   	ret    

c0109bc1 <setup_kstack>:

// setup_kstack - alloc pages with size KSTACKPAGE as process kernel stack
static int
setup_kstack(struct proc_struct *proc) {
c0109bc1:	55                   	push   %ebp
c0109bc2:	89 e5                	mov    %esp,%ebp
c0109bc4:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_pages(KSTACKPAGE);
c0109bc7:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0109bce:	e8 9d d9 ff ff       	call   c0107570 <alloc_pages>
c0109bd3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c0109bd6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109bda:	74 1a                	je     c0109bf6 <setup_kstack+0x35>
        proc->kstack = (uintptr_t)page2kva(page);
c0109bdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109bdf:	89 04 24             	mov    %eax,(%esp)
c0109be2:	e8 99 f8 ff ff       	call   c0109480 <page2kva>
c0109be7:	89 c2                	mov    %eax,%edx
c0109be9:	8b 45 08             	mov    0x8(%ebp),%eax
c0109bec:	89 50 0c             	mov    %edx,0xc(%eax)
        return 0;
c0109bef:	b8 00 00 00 00       	mov    $0x0,%eax
c0109bf4:	eb 05                	jmp    c0109bfb <setup_kstack+0x3a>
    }
    return -E_NO_MEM;
c0109bf6:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
c0109bfb:	c9                   	leave  
c0109bfc:	c3                   	ret    

c0109bfd <put_kstack>:

// put_kstack - free the memory space of process kernel stack
static void
put_kstack(struct proc_struct *proc) {
c0109bfd:	55                   	push   %ebp
c0109bfe:	89 e5                	mov    %esp,%ebp
c0109c00:	83 ec 18             	sub    $0x18,%esp
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
c0109c03:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c06:	8b 40 0c             	mov    0xc(%eax),%eax
c0109c09:	89 04 24             	mov    %eax,(%esp)
c0109c0c:	e8 c3 f8 ff ff       	call   c01094d4 <kva2page>
c0109c11:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0109c18:	00 
c0109c19:	89 04 24             	mov    %eax,(%esp)
c0109c1c:	e8 ba d9 ff ff       	call   c01075db <free_pages>
}
c0109c21:	90                   	nop
c0109c22:	c9                   	leave  
c0109c23:	c3                   	ret    

c0109c24 <setup_pgdir>:

// setup_pgdir - alloc one page as PDT
static int
setup_pgdir(struct mm_struct *mm) {
c0109c24:	55                   	push   %ebp
c0109c25:	89 e5                	mov    %esp,%ebp
c0109c27:	83 ec 28             	sub    $0x28,%esp
    struct Page *page;
    if ((page = alloc_page()) == NULL) {
c0109c2a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0109c31:	e8 3a d9 ff ff       	call   c0107570 <alloc_pages>
c0109c36:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109c39:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109c3d:	75 0a                	jne    c0109c49 <setup_pgdir+0x25>
        return -E_NO_MEM;
c0109c3f:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0109c44:	e9 80 00 00 00       	jmp    c0109cc9 <setup_pgdir+0xa5>
    }
    pde_t *pgdir = page2kva(page);
c0109c49:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109c4c:	89 04 24             	mov    %eax,(%esp)
c0109c4f:	e8 2c f8 ff ff       	call   c0109480 <page2kva>
c0109c54:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memcpy(pgdir, boot_pgdir, PGSIZE);
c0109c57:	a1 20 ca 12 c0       	mov    0xc012ca20,%eax
c0109c5c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0109c63:	00 
c0109c64:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109c68:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109c6b:	89 04 24             	mov    %eax,(%esp)
c0109c6e:	e8 f6 1d 00 00       	call   c010ba69 <memcpy>
    pgdir[PDX(VPT)] = PADDR(pgdir) | PTE_P | PTE_W;
c0109c73:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109c76:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c0109c7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109c7f:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109c82:	81 7d ec ff ff ff bf 	cmpl   $0xbfffffff,-0x14(%ebp)
c0109c89:	77 23                	ja     c0109cae <setup_pgdir+0x8a>
c0109c8b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109c8e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109c92:	c7 44 24 08 28 e3 10 	movl   $0xc010e328,0x8(%esp)
c0109c99:	c0 
c0109c9a:	c7 44 24 04 1e 01 00 	movl   $0x11e,0x4(%esp)
c0109ca1:	00 
c0109ca2:	c7 04 24 4c e3 10 c0 	movl   $0xc010e34c,(%esp)
c0109ca9:	e8 57 67 ff ff       	call   c0100405 <__panic>
c0109cae:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109cb1:	05 00 00 00 40       	add    $0x40000000,%eax
c0109cb6:	83 c8 03             	or     $0x3,%eax
c0109cb9:	89 02                	mov    %eax,(%edx)
    mm->pgdir = pgdir;
c0109cbb:	8b 45 08             	mov    0x8(%ebp),%eax
c0109cbe:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0109cc1:	89 50 0c             	mov    %edx,0xc(%eax)
    return 0;
c0109cc4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109cc9:	c9                   	leave  
c0109cca:	c3                   	ret    

c0109ccb <put_pgdir>:

// put_pgdir - free the memory space of PDT
static void
put_pgdir(struct mm_struct *mm) {
c0109ccb:	55                   	push   %ebp
c0109ccc:	89 e5                	mov    %esp,%ebp
c0109cce:	83 ec 18             	sub    $0x18,%esp
    free_page(kva2page(mm->pgdir));
c0109cd1:	8b 45 08             	mov    0x8(%ebp),%eax
c0109cd4:	8b 40 0c             	mov    0xc(%eax),%eax
c0109cd7:	89 04 24             	mov    %eax,(%esp)
c0109cda:	e8 f5 f7 ff ff       	call   c01094d4 <kva2page>
c0109cdf:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0109ce6:	00 
c0109ce7:	89 04 24             	mov    %eax,(%esp)
c0109cea:	e8 ec d8 ff ff       	call   c01075db <free_pages>
}
c0109cef:	90                   	nop
c0109cf0:	c9                   	leave  
c0109cf1:	c3                   	ret    

c0109cf2 <copy_mm>:

// copy_mm - process "proc" duplicate OR share process "current"'s mm according clone_flags
//         - if clone_flags & CLONE_VM, then "share" ; else "duplicate"
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc) {
c0109cf2:	55                   	push   %ebp
c0109cf3:	89 e5                	mov    %esp,%ebp
c0109cf5:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm, *oldmm = current->mm;
c0109cf8:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c0109cfd:	8b 40 18             	mov    0x18(%eax),%eax
c0109d00:	89 45 ec             	mov    %eax,-0x14(%ebp)

    /* current is a kernel thread */
    if (oldmm == NULL) {
c0109d03:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0109d07:	75 0a                	jne    c0109d13 <copy_mm+0x21>
        return 0;
c0109d09:	b8 00 00 00 00       	mov    $0x0,%eax
c0109d0e:	e9 fb 00 00 00       	jmp    c0109e0e <copy_mm+0x11c>
    }
    if (clone_flags & CLONE_VM) {
c0109d13:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d16:	25 00 01 00 00       	and    $0x100,%eax
c0109d1b:	85 c0                	test   %eax,%eax
c0109d1d:	74 08                	je     c0109d27 <copy_mm+0x35>
        mm = oldmm;
c0109d1f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109d22:	89 45 f4             	mov    %eax,-0xc(%ebp)
        goto good_mm;
c0109d25:	eb 5d                	jmp    c0109d84 <copy_mm+0x92>
    }

    int ret = -E_NO_MEM;
c0109d27:	c7 45 f0 fc ff ff ff 	movl   $0xfffffffc,-0x10(%ebp)
    if ((mm = mm_create()) == NULL) {
c0109d2e:	e8 2c 98 ff ff       	call   c010355f <mm_create>
c0109d33:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109d36:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109d3a:	0f 84 ca 00 00 00    	je     c0109e0a <copy_mm+0x118>
        goto bad_mm;
    }
    if (setup_pgdir(mm) != 0) {
c0109d40:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109d43:	89 04 24             	mov    %eax,(%esp)
c0109d46:	e8 d9 fe ff ff       	call   c0109c24 <setup_pgdir>
c0109d4b:	85 c0                	test   %eax,%eax
c0109d4d:	0f 85 a9 00 00 00    	jne    c0109dfc <copy_mm+0x10a>
        goto bad_pgdir_cleanup_mm;
    }

    lock_mm(oldmm);
c0109d53:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109d56:	89 04 24             	mov    %eax,(%esp)
c0109d59:	e8 f4 f7 ff ff       	call   c0109552 <lock_mm>
    {
        ret = dup_mmap(mm, oldmm);
c0109d5e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109d61:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109d65:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109d68:	89 04 24             	mov    %eax,(%esp)
c0109d6b:	e8 06 9d ff ff       	call   c0103a76 <dup_mmap>
c0109d70:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    unlock_mm(oldmm);
c0109d73:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109d76:	89 04 24             	mov    %eax,(%esp)
c0109d79:	e8 f1 f7 ff ff       	call   c010956f <unlock_mm>

    if (ret != 0) {
c0109d7e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0109d82:	75 5f                	jne    c0109de3 <copy_mm+0xf1>
        goto bad_dup_cleanup_mmap;
    }

good_mm:
    mm_count_inc(mm);
c0109d84:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109d87:	89 04 24             	mov    %eax,(%esp)
c0109d8a:	e8 8f f7 ff ff       	call   c010951e <mm_count_inc>
    proc->mm = mm;
c0109d8f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109d92:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109d95:	89 50 18             	mov    %edx,0x18(%eax)
    proc->cr3 = PADDR(mm->pgdir);
c0109d98:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109d9b:	8b 40 0c             	mov    0xc(%eax),%eax
c0109d9e:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0109da1:	81 7d e8 ff ff ff bf 	cmpl   $0xbfffffff,-0x18(%ebp)
c0109da8:	77 23                	ja     c0109dcd <copy_mm+0xdb>
c0109daa:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109dad:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109db1:	c7 44 24 08 28 e3 10 	movl   $0xc010e328,0x8(%esp)
c0109db8:	c0 
c0109db9:	c7 44 24 04 4d 01 00 	movl   $0x14d,0x4(%esp)
c0109dc0:	00 
c0109dc1:	c7 04 24 4c e3 10 c0 	movl   $0xc010e34c,(%esp)
c0109dc8:	e8 38 66 ff ff       	call   c0100405 <__panic>
c0109dcd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109dd0:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c0109dd6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109dd9:	89 50 40             	mov    %edx,0x40(%eax)
    return 0;
c0109ddc:	b8 00 00 00 00       	mov    $0x0,%eax
c0109de1:	eb 2b                	jmp    c0109e0e <copy_mm+0x11c>
        ret = dup_mmap(mm, oldmm);
    }
    unlock_mm(oldmm);

    if (ret != 0) {
        goto bad_dup_cleanup_mmap;
c0109de3:	90                   	nop
    mm_count_inc(mm);
    proc->mm = mm;
    proc->cr3 = PADDR(mm->pgdir);
    return 0;
bad_dup_cleanup_mmap:
    exit_mmap(mm);
c0109de4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109de7:	89 04 24             	mov    %eax,(%esp)
c0109dea:	e8 88 9d ff ff       	call   c0103b77 <exit_mmap>
    put_pgdir(mm);
c0109def:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109df2:	89 04 24             	mov    %eax,(%esp)
c0109df5:	e8 d1 fe ff ff       	call   c0109ccb <put_pgdir>
c0109dfa:	eb 01                	jmp    c0109dfd <copy_mm+0x10b>
    int ret = -E_NO_MEM;
    if ((mm = mm_create()) == NULL) {
        goto bad_mm;
    }
    if (setup_pgdir(mm) != 0) {
        goto bad_pgdir_cleanup_mm;
c0109dfc:	90                   	nop
    return 0;
bad_dup_cleanup_mmap:
    exit_mmap(mm);
    put_pgdir(mm);
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
c0109dfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109e00:	89 04 24             	mov    %eax,(%esp)
c0109e03:	e8 b3 9a ff ff       	call   c01038bb <mm_destroy>
c0109e08:	eb 01                	jmp    c0109e0b <copy_mm+0x119>
        goto good_mm;
    }

    int ret = -E_NO_MEM;
    if ((mm = mm_create()) == NULL) {
        goto bad_mm;
c0109e0a:	90                   	nop
    exit_mmap(mm);
    put_pgdir(mm);
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
bad_mm:
    return ret;
c0109e0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0109e0e:	c9                   	leave  
c0109e0f:	c3                   	ret    

c0109e10 <copy_thread>:

// copy_thread - setup the trapframe on the  process's kernel stack top and
//             - setup the kernel entry point and stack of process
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf) {
c0109e10:	55                   	push   %ebp
c0109e11:	89 e5                	mov    %esp,%ebp
c0109e13:	57                   	push   %edi
c0109e14:	56                   	push   %esi
c0109e15:	53                   	push   %ebx
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
c0109e16:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e19:	8b 40 0c             	mov    0xc(%eax),%eax
c0109e1c:	05 b4 1f 00 00       	add    $0x1fb4,%eax
c0109e21:	89 c2                	mov    %eax,%edx
c0109e23:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e26:	89 50 3c             	mov    %edx,0x3c(%eax)
    *(proc->tf) = *tf;
c0109e29:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e2c:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109e2f:	8b 55 10             	mov    0x10(%ebp),%edx
c0109e32:	bb 4c 00 00 00       	mov    $0x4c,%ebx
c0109e37:	89 c1                	mov    %eax,%ecx
c0109e39:	83 e1 01             	and    $0x1,%ecx
c0109e3c:	85 c9                	test   %ecx,%ecx
c0109e3e:	74 0c                	je     c0109e4c <copy_thread+0x3c>
c0109e40:	0f b6 0a             	movzbl (%edx),%ecx
c0109e43:	88 08                	mov    %cl,(%eax)
c0109e45:	8d 40 01             	lea    0x1(%eax),%eax
c0109e48:	8d 52 01             	lea    0x1(%edx),%edx
c0109e4b:	4b                   	dec    %ebx
c0109e4c:	89 c1                	mov    %eax,%ecx
c0109e4e:	83 e1 02             	and    $0x2,%ecx
c0109e51:	85 c9                	test   %ecx,%ecx
c0109e53:	74 0f                	je     c0109e64 <copy_thread+0x54>
c0109e55:	0f b7 0a             	movzwl (%edx),%ecx
c0109e58:	66 89 08             	mov    %cx,(%eax)
c0109e5b:	8d 40 02             	lea    0x2(%eax),%eax
c0109e5e:	8d 52 02             	lea    0x2(%edx),%edx
c0109e61:	83 eb 02             	sub    $0x2,%ebx
c0109e64:	89 df                	mov    %ebx,%edi
c0109e66:	83 e7 fc             	and    $0xfffffffc,%edi
c0109e69:	b9 00 00 00 00       	mov    $0x0,%ecx
c0109e6e:	8b 34 0a             	mov    (%edx,%ecx,1),%esi
c0109e71:	89 34 08             	mov    %esi,(%eax,%ecx,1)
c0109e74:	83 c1 04             	add    $0x4,%ecx
c0109e77:	39 f9                	cmp    %edi,%ecx
c0109e79:	72 f3                	jb     c0109e6e <copy_thread+0x5e>
c0109e7b:	01 c8                	add    %ecx,%eax
c0109e7d:	01 ca                	add    %ecx,%edx
c0109e7f:	b9 00 00 00 00       	mov    $0x0,%ecx
c0109e84:	89 de                	mov    %ebx,%esi
c0109e86:	83 e6 02             	and    $0x2,%esi
c0109e89:	85 f6                	test   %esi,%esi
c0109e8b:	74 0b                	je     c0109e98 <copy_thread+0x88>
c0109e8d:	0f b7 34 0a          	movzwl (%edx,%ecx,1),%esi
c0109e91:	66 89 34 08          	mov    %si,(%eax,%ecx,1)
c0109e95:	83 c1 02             	add    $0x2,%ecx
c0109e98:	83 e3 01             	and    $0x1,%ebx
c0109e9b:	85 db                	test   %ebx,%ebx
c0109e9d:	74 07                	je     c0109ea6 <copy_thread+0x96>
c0109e9f:	0f b6 14 0a          	movzbl (%edx,%ecx,1),%edx
c0109ea3:	88 14 08             	mov    %dl,(%eax,%ecx,1)
    proc->tf->tf_regs.reg_eax = 0;
c0109ea6:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ea9:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109eac:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    proc->tf->tf_esp = esp;
c0109eb3:	8b 45 08             	mov    0x8(%ebp),%eax
c0109eb6:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109eb9:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109ebc:	89 50 44             	mov    %edx,0x44(%eax)
    proc->tf->tf_eflags |= FL_IF;
c0109ebf:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ec2:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109ec5:	8b 55 08             	mov    0x8(%ebp),%edx
c0109ec8:	8b 52 3c             	mov    0x3c(%edx),%edx
c0109ecb:	8b 52 40             	mov    0x40(%edx),%edx
c0109ece:	81 ca 00 02 00 00    	or     $0x200,%edx
c0109ed4:	89 50 40             	mov    %edx,0x40(%eax)

    proc->context.eip = (uintptr_t)forkret;
c0109ed7:	ba 11 9a 10 c0       	mov    $0xc0109a11,%edx
c0109edc:	8b 45 08             	mov    0x8(%ebp),%eax
c0109edf:	89 50 1c             	mov    %edx,0x1c(%eax)
    proc->context.esp = (uintptr_t)(proc->tf);
c0109ee2:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ee5:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109ee8:	89 c2                	mov    %eax,%edx
c0109eea:	8b 45 08             	mov    0x8(%ebp),%eax
c0109eed:	89 50 20             	mov    %edx,0x20(%eax)
}
c0109ef0:	90                   	nop
c0109ef1:	5b                   	pop    %ebx
c0109ef2:	5e                   	pop    %esi
c0109ef3:	5f                   	pop    %edi
c0109ef4:	5d                   	pop    %ebp
c0109ef5:	c3                   	ret    

c0109ef6 <do_fork>:
 * @clone_flags: used to guide how to clone the child process
 * @stack:       the parent's user stack pointer. if stack==0, It means to fork a kernel thread.
 * @tf:          the trapframe info, which will be copied to child process's proc->tf
 */
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
c0109ef6:	55                   	push   %ebp
c0109ef7:	89 e5                	mov    %esp,%ebp
c0109ef9:	83 ec 28             	sub    $0x28,%esp
    int ret = -E_NO_FREE_PROC;
c0109efc:	c7 45 f4 fb ff ff ff 	movl   $0xfffffffb,-0xc(%ebp)
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
c0109f03:	a1 40 30 1b c0       	mov    0xc01b3040,%eax
c0109f08:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c0109f0d:	0f 8f e3 00 00 00    	jg     c0109ff6 <do_fork+0x100>
        goto fork_out;
    }
    ret = -E_NO_MEM;
c0109f13:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)
    //调用alloc_proc，首先获得一块用户信息块。
    if((proc = alloc_proc()) == NULL){
c0109f1a:	e8 6d f6 ff ff       	call   c010958c <alloc_proc>
c0109f1f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109f22:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0109f26:	0f 84 cd 00 00 00    	je     c0109ff9 <do_fork+0x103>
        goto fork_out; //返回
    }
    proc->parent = current; // 设置父进程名字
c0109f2c:	8b 15 28 10 1b c0    	mov    0xc01b1028,%edx
c0109f32:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109f35:	89 50 14             	mov    %edx,0x14(%eax)
    assert(current->wait_state == 0); // 确保进程在等待
c0109f38:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c0109f3d:	8b 40 6c             	mov    0x6c(%eax),%eax
c0109f40:	85 c0                	test   %eax,%eax
c0109f42:	74 24                	je     c0109f68 <do_fork+0x72>
c0109f44:	c7 44 24 0c 60 e3 10 	movl   $0xc010e360,0xc(%esp)
c0109f4b:	c0 
c0109f4c:	c7 44 24 08 79 e3 10 	movl   $0xc010e379,0x8(%esp)
c0109f53:	c0 
c0109f54:	c7 44 24 04 78 01 00 	movl   $0x178,0x4(%esp)
c0109f5b:	00 
c0109f5c:	c7 04 24 4c e3 10 c0 	movl   $0xc010e34c,(%esp)
c0109f63:	e8 9d 64 ff ff       	call   c0100405 <__panic>
    // 为进程分配一个内核栈。
    if (setup_kstack(proc) !=0){ //申请一块2*PGSZIE内存用于进程堆栈
c0109f68:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109f6b:	89 04 24             	mov    %eax,(%esp)
c0109f6e:	e8 4e fc ff ff       	call   c0109bc1 <setup_kstack>
c0109f73:	85 c0                	test   %eax,%eax
c0109f75:	0f 85 92 00 00 00    	jne    c010a00d <do_fork+0x117>
        goto bad_fork_cleanup_proc; // 返回
    }
    // 复制父进程的内存管理信息到子进程（但内核线程不必做此事）
    if (copy_mm(clone_flags,proc) != 0){
c0109f7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109f7e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109f82:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f85:	89 04 24             	mov    %eax,(%esp)
c0109f88:	e8 65 fd ff ff       	call   c0109cf2 <copy_mm>
c0109f8d:	85 c0                	test   %eax,%eax
c0109f8f:	75 6e                	jne    c0109fff <do_fork+0x109>
        goto bad_fork_cleanup_kstack; // 返回
    }
    // 复制中断帧和原进程上下文到新进程
    copy_thread(proc,stack,tf);
c0109f91:	8b 45 10             	mov    0x10(%ebp),%eax
c0109f94:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109f98:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109f9b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109f9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109fa2:	89 04 24             	mov    %eax,(%esp)
c0109fa5:	e8 66 fe ff ff       	call   c0109e10 <copy_thread>
    bool intr_flag;
    local_intr_save(intr_flag); // 禁止中断，intr_flag置为1
c0109faa:	e8 a7 f3 ff ff       	call   c0109356 <__intr_save>
c0109faf:	89 45 ec             	mov    %eax,-0x14(%ebp)
    // 将新进程添加到进程列表

    proc->pid = get_pid();
c0109fb2:	e8 f0 f8 ff ff       	call   c01098a7 <get_pid>
c0109fb7:	89 c2                	mov    %eax,%edx
c0109fb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109fbc:	89 50 04             	mov    %edx,0x4(%eax)
    hash_proc(proc);
c0109fbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109fc2:	89 04 24             	mov    %eax,(%esp)
c0109fc5:	e8 60 fa ff ff       	call   c0109a2a <hash_proc>
    set_links(proc); //设置进程链接
c0109fca:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109fcd:	89 04 24             	mov    %eax,(%esp)
c0109fd0:	e8 ac f7 ff ff       	call   c0109781 <set_links>

    local_intr_restore(intr_flag); // 恢复中断
c0109fd5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109fd8:	89 04 24             	mov    %eax,(%esp)
c0109fdb:	e8 a0 f3 ff ff       	call   c0109380 <__intr_restore>
    // 唤醒新进程
    wakeup_proc(proc);
c0109fe0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109fe3:	89 04 24             	mov    %eax,(%esp)
c0109fe6:	e8 0d 11 00 00       	call   c010b0f8 <wakeup_proc>

    ret = proc->pid;
c0109feb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109fee:	8b 40 04             	mov    0x4(%eax),%eax
c0109ff1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109ff4:	eb 04                	jmp    c0109ffa <do_fork+0x104>
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
    int ret = -E_NO_FREE_PROC;
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
        goto fork_out;
c0109ff6:	90                   	nop
c0109ff7:	eb 01                	jmp    c0109ffa <do_fork+0x104>
    }
    ret = -E_NO_MEM;
    //调用alloc_proc，首先获得一块用户信息块。
    if((proc = alloc_proc()) == NULL){
        goto fork_out; //返回
c0109ff9:	90                   	nop
    wakeup_proc(proc);

    ret = proc->pid;

    fork_out:
    return ret;
c0109ffa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109ffd:	eb 1c                	jmp    c010a01b <do_fork+0x125>
    if (setup_kstack(proc) !=0){ //申请一块2*PGSZIE内存用于进程堆栈
        goto bad_fork_cleanup_proc; // 返回
    }
    // 复制父进程的内存管理信息到子进程（但内核线程不必做此事）
    if (copy_mm(clone_flags,proc) != 0){
        goto bad_fork_cleanup_kstack; // 返回
c0109fff:	90                   	nop

    fork_out:
    return ret;

    bad_fork_cleanup_kstack:
    put_kstack(proc);
c010a000:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a003:	89 04 24             	mov    %eax,(%esp)
c010a006:	e8 f2 fb ff ff       	call   c0109bfd <put_kstack>
c010a00b:	eb 01                	jmp    c010a00e <do_fork+0x118>
    }
    proc->parent = current; // 设置父进程名字
    assert(current->wait_state == 0); // 确保进程在等待
    // 为进程分配一个内核栈。
    if (setup_kstack(proc) !=0){ //申请一块2*PGSZIE内存用于进程堆栈
        goto bad_fork_cleanup_proc; // 返回
c010a00d:	90                   	nop
    return ret;

    bad_fork_cleanup_kstack:
    put_kstack(proc);
    bad_fork_cleanup_proc:
    kfree(proc);
c010a00e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a011:	89 04 24             	mov    %eax,(%esp)
c010a014:	e8 99 b9 ff ff       	call   c01059b2 <kfree>
    goto fork_out;
c010a019:	eb df                	jmp    c0109ffa <do_fork+0x104>
}
c010a01b:	c9                   	leave  
c010a01c:	c3                   	ret    

c010a01d <do_exit>:
// do_exit - called by sys_exit
//   1. call exit_mmap & put_pgdir & mm_destroy to free the almost all memory space of process
//   2. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
//   3. call scheduler to switch to other process
int
do_exit(int error_code) {
c010a01d:	55                   	push   %ebp
c010a01e:	89 e5                	mov    %esp,%ebp
c010a020:	83 ec 28             	sub    $0x28,%esp
    if (current == idleproc) {
c010a023:	8b 15 28 10 1b c0    	mov    0xc01b1028,%edx
c010a029:	a1 20 10 1b c0       	mov    0xc01b1020,%eax
c010a02e:	39 c2                	cmp    %eax,%edx
c010a030:	75 1c                	jne    c010a04e <do_exit+0x31>
        panic("idleproc exit.\n");
c010a032:	c7 44 24 08 8e e3 10 	movl   $0xc010e38e,0x8(%esp)
c010a039:	c0 
c010a03a:	c7 44 24 04 a2 01 00 	movl   $0x1a2,0x4(%esp)
c010a041:	00 
c010a042:	c7 04 24 4c e3 10 c0 	movl   $0xc010e34c,(%esp)
c010a049:	e8 b7 63 ff ff       	call   c0100405 <__panic>
    }
    if (current == initproc) {
c010a04e:	8b 15 28 10 1b c0    	mov    0xc01b1028,%edx
c010a054:	a1 24 10 1b c0       	mov    0xc01b1024,%eax
c010a059:	39 c2                	cmp    %eax,%edx
c010a05b:	75 1c                	jne    c010a079 <do_exit+0x5c>
        panic("initproc exit.\n");
c010a05d:	c7 44 24 08 9e e3 10 	movl   $0xc010e39e,0x8(%esp)
c010a064:	c0 
c010a065:	c7 44 24 04 a5 01 00 	movl   $0x1a5,0x4(%esp)
c010a06c:	00 
c010a06d:	c7 04 24 4c e3 10 c0 	movl   $0xc010e34c,(%esp)
c010a074:	e8 8c 63 ff ff       	call   c0100405 <__panic>
    }
    
    struct mm_struct *mm = current->mm;
c010a079:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010a07e:	8b 40 18             	mov    0x18(%eax),%eax
c010a081:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (mm != NULL) {
c010a084:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a088:	74 4a                	je     c010a0d4 <do_exit+0xb7>
        lcr3(boot_cr3);
c010a08a:	a1 5c 31 1b c0       	mov    0xc01b315c,%eax
c010a08f:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010a092:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a095:	0f 22 d8             	mov    %eax,%cr3
        if (mm_count_dec(mm) == 0) {
c010a098:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a09b:	89 04 24             	mov    %eax,(%esp)
c010a09e:	e8 95 f4 ff ff       	call   c0109538 <mm_count_dec>
c010a0a3:	85 c0                	test   %eax,%eax
c010a0a5:	75 21                	jne    c010a0c8 <do_exit+0xab>
            exit_mmap(mm);
c010a0a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a0aa:	89 04 24             	mov    %eax,(%esp)
c010a0ad:	e8 c5 9a ff ff       	call   c0103b77 <exit_mmap>
            put_pgdir(mm);
c010a0b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a0b5:	89 04 24             	mov    %eax,(%esp)
c010a0b8:	e8 0e fc ff ff       	call   c0109ccb <put_pgdir>
            mm_destroy(mm);
c010a0bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a0c0:	89 04 24             	mov    %eax,(%esp)
c010a0c3:	e8 f3 97 ff ff       	call   c01038bb <mm_destroy>
        }
        current->mm = NULL;
c010a0c8:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010a0cd:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
    }
    current->state = PROC_ZOMBIE;
c010a0d4:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010a0d9:	c7 00 03 00 00 00    	movl   $0x3,(%eax)
    current->exit_code = error_code;
c010a0df:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010a0e4:	8b 55 08             	mov    0x8(%ebp),%edx
c010a0e7:	89 50 68             	mov    %edx,0x68(%eax)
    
    bool intr_flag;
    struct proc_struct *proc;
    local_intr_save(intr_flag);
c010a0ea:	e8 67 f2 ff ff       	call   c0109356 <__intr_save>
c010a0ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        proc = current->parent;
c010a0f2:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010a0f7:	8b 40 14             	mov    0x14(%eax),%eax
c010a0fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (proc->wait_state == WT_CHILD) {
c010a0fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a100:	8b 40 6c             	mov    0x6c(%eax),%eax
c010a103:	3d 01 00 00 80       	cmp    $0x80000001,%eax
c010a108:	0f 85 96 00 00 00    	jne    c010a1a4 <do_exit+0x187>
            wakeup_proc(proc);
c010a10e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a111:	89 04 24             	mov    %eax,(%esp)
c010a114:	e8 df 0f 00 00       	call   c010b0f8 <wakeup_proc>
        }
        while (current->cptr != NULL) {
c010a119:	e9 86 00 00 00       	jmp    c010a1a4 <do_exit+0x187>
            proc = current->cptr;
c010a11e:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010a123:	8b 40 70             	mov    0x70(%eax),%eax
c010a126:	89 45 ec             	mov    %eax,-0x14(%ebp)
            current->cptr = proc->optr;
c010a129:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010a12e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a131:	8b 52 78             	mov    0x78(%edx),%edx
c010a134:	89 50 70             	mov    %edx,0x70(%eax)
    
            proc->yptr = NULL;
c010a137:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a13a:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
            if ((proc->optr = initproc->cptr) != NULL) {
c010a141:	a1 24 10 1b c0       	mov    0xc01b1024,%eax
c010a146:	8b 50 70             	mov    0x70(%eax),%edx
c010a149:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a14c:	89 50 78             	mov    %edx,0x78(%eax)
c010a14f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a152:	8b 40 78             	mov    0x78(%eax),%eax
c010a155:	85 c0                	test   %eax,%eax
c010a157:	74 0e                	je     c010a167 <do_exit+0x14a>
                initproc->cptr->yptr = proc;
c010a159:	a1 24 10 1b c0       	mov    0xc01b1024,%eax
c010a15e:	8b 40 70             	mov    0x70(%eax),%eax
c010a161:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a164:	89 50 74             	mov    %edx,0x74(%eax)
            }
            proc->parent = initproc;
c010a167:	8b 15 24 10 1b c0    	mov    0xc01b1024,%edx
c010a16d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a170:	89 50 14             	mov    %edx,0x14(%eax)
            initproc->cptr = proc;
c010a173:	a1 24 10 1b c0       	mov    0xc01b1024,%eax
c010a178:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a17b:	89 50 70             	mov    %edx,0x70(%eax)
            if (proc->state == PROC_ZOMBIE) {
c010a17e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a181:	8b 00                	mov    (%eax),%eax
c010a183:	83 f8 03             	cmp    $0x3,%eax
c010a186:	75 1c                	jne    c010a1a4 <do_exit+0x187>
                if (initproc->wait_state == WT_CHILD) {
c010a188:	a1 24 10 1b c0       	mov    0xc01b1024,%eax
c010a18d:	8b 40 6c             	mov    0x6c(%eax),%eax
c010a190:	3d 01 00 00 80       	cmp    $0x80000001,%eax
c010a195:	75 0d                	jne    c010a1a4 <do_exit+0x187>
                    wakeup_proc(initproc);
c010a197:	a1 24 10 1b c0       	mov    0xc01b1024,%eax
c010a19c:	89 04 24             	mov    %eax,(%esp)
c010a19f:	e8 54 0f 00 00       	call   c010b0f8 <wakeup_proc>
    {
        proc = current->parent;
        if (proc->wait_state == WT_CHILD) {
            wakeup_proc(proc);
        }
        while (current->cptr != NULL) {
c010a1a4:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010a1a9:	8b 40 70             	mov    0x70(%eax),%eax
c010a1ac:	85 c0                	test   %eax,%eax
c010a1ae:	0f 85 6a ff ff ff    	jne    c010a11e <do_exit+0x101>
                    wakeup_proc(initproc);
                }
            }
        }
    }
    local_intr_restore(intr_flag);
c010a1b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a1b7:	89 04 24             	mov    %eax,(%esp)
c010a1ba:	e8 c1 f1 ff ff       	call   c0109380 <__intr_restore>
    
    schedule();
c010a1bf:	e8 ce 0f 00 00       	call   c010b192 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
c010a1c4:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010a1c9:	8b 40 04             	mov    0x4(%eax),%eax
c010a1cc:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a1d0:	c7 44 24 08 b0 e3 10 	movl   $0xc010e3b0,0x8(%esp)
c010a1d7:	c0 
c010a1d8:	c7 44 24 04 d1 01 00 	movl   $0x1d1,0x4(%esp)
c010a1df:	00 
c010a1e0:	c7 04 24 4c e3 10 c0 	movl   $0xc010e34c,(%esp)
c010a1e7:	e8 19 62 ff ff       	call   c0100405 <__panic>

c010a1ec <load_icode>:
/* load_icode - load the content of binary program(ELF format) as the new content of current process
 * @binary:  the memory addr of the content of binary program
 * @size:  the size of the content of binary program
 */
static int
load_icode(unsigned char *binary, size_t size) {
c010a1ec:	55                   	push   %ebp
c010a1ed:	89 e5                	mov    %esp,%ebp
c010a1ef:	83 ec 78             	sub    $0x78,%esp
    if (current->mm != NULL) {
c010a1f2:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010a1f7:	8b 40 18             	mov    0x18(%eax),%eax
c010a1fa:	85 c0                	test   %eax,%eax
c010a1fc:	74 1c                	je     c010a21a <load_icode+0x2e>
        panic("load_icode: current->mm must be empty.\n");
c010a1fe:	c7 44 24 08 d0 e3 10 	movl   $0xc010e3d0,0x8(%esp)
c010a205:	c0 
c010a206:	c7 44 24 04 db 01 00 	movl   $0x1db,0x4(%esp)
c010a20d:	00 
c010a20e:	c7 04 24 4c e3 10 c0 	movl   $0xc010e34c,(%esp)
c010a215:	e8 eb 61 ff ff       	call   c0100405 <__panic>
    }

    int ret = -E_NO_MEM;
c010a21a:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)
    struct mm_struct *mm;
    //(1) create a new mm for current process
    if ((mm = mm_create()) == NULL) {
c010a221:	e8 39 93 ff ff       	call   c010355f <mm_create>
c010a226:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010a229:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c010a22d:	0f 84 13 06 00 00    	je     c010a846 <load_icode+0x65a>
        goto bad_mm;
    }
    //(2) create a new PDT, and mm->pgdir= kernel virtual addr of PDT
    if (setup_pgdir(mm) != 0) {
c010a233:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a236:	89 04 24             	mov    %eax,(%esp)
c010a239:	e8 e6 f9 ff ff       	call   c0109c24 <setup_pgdir>
c010a23e:	85 c0                	test   %eax,%eax
c010a240:	0f 85 f2 05 00 00    	jne    c010a838 <load_icode+0x64c>
        goto bad_pgdir_cleanup_mm;
    }
    //(3) copy TEXT/DATA section, build BSS parts in binary to memory space of process
    struct Page *page;
    //(3.1) get the file header of the bianry program (ELF format)
    struct elfhdr *elf = (struct elfhdr *)binary;
c010a246:	8b 45 08             	mov    0x8(%ebp),%eax
c010a249:	89 45 cc             	mov    %eax,-0x34(%ebp)
    //(3.2) get the entry of the program section headers of the bianry program (ELF format)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
c010a24c:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010a24f:	8b 50 1c             	mov    0x1c(%eax),%edx
c010a252:	8b 45 08             	mov    0x8(%ebp),%eax
c010a255:	01 d0                	add    %edx,%eax
c010a257:	89 45 ec             	mov    %eax,-0x14(%ebp)
    //(3.3) This program is valid?
    if (elf->e_magic != ELF_MAGIC) {
c010a25a:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010a25d:	8b 00                	mov    (%eax),%eax
c010a25f:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
c010a264:	74 0c                	je     c010a272 <load_icode+0x86>
        ret = -E_INVAL_ELF;
c010a266:	c7 45 f4 f8 ff ff ff 	movl   $0xfffffff8,-0xc(%ebp)
        goto bad_elf_cleanup_pgdir;
c010a26d:	e9 b9 05 00 00       	jmp    c010a82b <load_icode+0x63f>
    }

    uint32_t vm_flags, perm;
    struct proghdr *ph_end = ph + elf->e_phnum;
c010a272:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010a275:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c010a279:	c1 e0 05             	shl    $0x5,%eax
c010a27c:	89 c2                	mov    %eax,%edx
c010a27e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a281:	01 d0                	add    %edx,%eax
c010a283:	89 45 c8             	mov    %eax,-0x38(%ebp)
    for (; ph < ph_end; ph ++) {
c010a286:	e9 07 03 00 00       	jmp    c010a592 <load_icode+0x3a6>
    //(3.4) find every program section headers
        if (ph->p_type != ELF_PT_LOAD) {
c010a28b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a28e:	8b 00                	mov    (%eax),%eax
c010a290:	83 f8 01             	cmp    $0x1,%eax
c010a293:	0f 85 ee 02 00 00    	jne    c010a587 <load_icode+0x39b>
            continue ;
        }
        if (ph->p_filesz > ph->p_memsz) {
c010a299:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a29c:	8b 50 10             	mov    0x10(%eax),%edx
c010a29f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a2a2:	8b 40 14             	mov    0x14(%eax),%eax
c010a2a5:	39 c2                	cmp    %eax,%edx
c010a2a7:	76 0c                	jbe    c010a2b5 <load_icode+0xc9>
            ret = -E_INVAL_ELF;
c010a2a9:	c7 45 f4 f8 ff ff ff 	movl   $0xfffffff8,-0xc(%ebp)
            goto bad_cleanup_mmap;
c010a2b0:	e9 6b 05 00 00       	jmp    c010a820 <load_icode+0x634>
        }
        if (ph->p_filesz == 0) {
c010a2b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a2b8:	8b 40 10             	mov    0x10(%eax),%eax
c010a2bb:	85 c0                	test   %eax,%eax
c010a2bd:	0f 84 c7 02 00 00    	je     c010a58a <load_icode+0x39e>
            continue ;
        }
    //(3.5) call mm_map fun to setup the new vma ( ph->p_va, ph->p_memsz)
        vm_flags = 0, perm = PTE_U;
c010a2c3:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c010a2ca:	c7 45 e4 04 00 00 00 	movl   $0x4,-0x1c(%ebp)
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
c010a2d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a2d4:	8b 40 18             	mov    0x18(%eax),%eax
c010a2d7:	83 e0 01             	and    $0x1,%eax
c010a2da:	85 c0                	test   %eax,%eax
c010a2dc:	74 04                	je     c010a2e2 <load_icode+0xf6>
c010a2de:	83 4d e8 04          	orl    $0x4,-0x18(%ebp)
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
c010a2e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a2e5:	8b 40 18             	mov    0x18(%eax),%eax
c010a2e8:	83 e0 02             	and    $0x2,%eax
c010a2eb:	85 c0                	test   %eax,%eax
c010a2ed:	74 04                	je     c010a2f3 <load_icode+0x107>
c010a2ef:	83 4d e8 02          	orl    $0x2,-0x18(%ebp)
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
c010a2f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a2f6:	8b 40 18             	mov    0x18(%eax),%eax
c010a2f9:	83 e0 04             	and    $0x4,%eax
c010a2fc:	85 c0                	test   %eax,%eax
c010a2fe:	74 04                	je     c010a304 <load_icode+0x118>
c010a300:	83 4d e8 01          	orl    $0x1,-0x18(%ebp)
        if (vm_flags & VM_WRITE) perm |= PTE_W;
c010a304:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a307:	83 e0 02             	and    $0x2,%eax
c010a30a:	85 c0                	test   %eax,%eax
c010a30c:	74 04                	je     c010a312 <load_icode+0x126>
c010a30e:	83 4d e4 02          	orl    $0x2,-0x1c(%ebp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
c010a312:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a315:	8b 50 14             	mov    0x14(%eax),%edx
c010a318:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a31b:	8b 40 08             	mov    0x8(%eax),%eax
c010a31e:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
c010a325:	00 
c010a326:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010a329:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c010a32d:	89 54 24 08          	mov    %edx,0x8(%esp)
c010a331:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a335:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a338:	89 04 24             	mov    %eax,(%esp)
c010a33b:	e8 1e 96 ff ff       	call   c010395e <mm_map>
c010a340:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a343:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a347:	0f 85 c9 04 00 00    	jne    c010a816 <load_icode+0x62a>
            goto bad_cleanup_mmap;
        }
        unsigned char *from = binary + ph->p_offset;
c010a34d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a350:	8b 50 04             	mov    0x4(%eax),%edx
c010a353:	8b 45 08             	mov    0x8(%ebp),%eax
c010a356:	01 d0                	add    %edx,%eax
c010a358:	89 45 e0             	mov    %eax,-0x20(%ebp)
        size_t off, size;
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
c010a35b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a35e:	8b 40 08             	mov    0x8(%eax),%eax
c010a361:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010a364:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a367:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c010a36a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010a36d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010a372:	89 45 d4             	mov    %eax,-0x2c(%ebp)

        ret = -E_NO_MEM;
c010a375:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

     //(3.6) alloc memory, and  copy the contents of every program section (from, from+end) to process's memory (la, la+end)
        end = ph->p_va + ph->p_filesz;
c010a37c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a37f:	8b 50 08             	mov    0x8(%eax),%edx
c010a382:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a385:	8b 40 10             	mov    0x10(%eax),%eax
c010a388:	01 d0                	add    %edx,%eax
c010a38a:	89 45 c0             	mov    %eax,-0x40(%ebp)
     //(3.6.1) copy TEXT/DATA section of bianry program
        while (start < end) {
c010a38d:	e9 89 00 00 00       	jmp    c010a41b <load_icode+0x22f>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
c010a392:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a395:	8b 40 0c             	mov    0xc(%eax),%eax
c010a398:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010a39b:	89 54 24 08          	mov    %edx,0x8(%esp)
c010a39f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010a3a2:	89 54 24 04          	mov    %edx,0x4(%esp)
c010a3a6:	89 04 24             	mov    %eax,(%esp)
c010a3a9:	e8 02 e0 ff ff       	call   c01083b0 <pgdir_alloc_page>
c010a3ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a3b1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a3b5:	0f 84 5e 04 00 00    	je     c010a819 <load_icode+0x62d>
                goto bad_cleanup_mmap;
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
c010a3bb:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a3be:	2b 45 d4             	sub    -0x2c(%ebp),%eax
c010a3c1:	89 45 bc             	mov    %eax,-0x44(%ebp)
c010a3c4:	b8 00 10 00 00       	mov    $0x1000,%eax
c010a3c9:	2b 45 bc             	sub    -0x44(%ebp),%eax
c010a3cc:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010a3cf:	81 45 d4 00 10 00 00 	addl   $0x1000,-0x2c(%ebp)
            if (end < la) {
c010a3d6:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a3d9:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a3dc:	73 09                	jae    c010a3e7 <load_icode+0x1fb>
                size -= la - end;
c010a3de:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a3e1:	2b 45 d4             	sub    -0x2c(%ebp),%eax
c010a3e4:	01 45 dc             	add    %eax,-0x24(%ebp)
            }
            memcpy(page2kva(page) + off, from, size);
c010a3e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a3ea:	89 04 24             	mov    %eax,(%esp)
c010a3ed:	e8 8e f0 ff ff       	call   c0109480 <page2kva>
c010a3f2:	89 c2                	mov    %eax,%edx
c010a3f4:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010a3f7:	01 c2                	add    %eax,%edx
c010a3f9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a3fc:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a400:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010a403:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a407:	89 14 24             	mov    %edx,(%esp)
c010a40a:	e8 5a 16 00 00       	call   c010ba69 <memcpy>
            start += size, from += size;
c010a40f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a412:	01 45 d8             	add    %eax,-0x28(%ebp)
c010a415:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a418:	01 45 e0             	add    %eax,-0x20(%ebp)
        ret = -E_NO_MEM;

     //(3.6) alloc memory, and  copy the contents of every program section (from, from+end) to process's memory (la, la+end)
        end = ph->p_va + ph->p_filesz;
     //(3.6.1) copy TEXT/DATA section of bianry program
        while (start < end) {
c010a41b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a41e:	3b 45 c0             	cmp    -0x40(%ebp),%eax
c010a421:	0f 82 6b ff ff ff    	jb     c010a392 <load_icode+0x1a6>
            memcpy(page2kva(page) + off, from, size);
            start += size, from += size;
        }

      //(3.6.2) build BSS section of binary program
        end = ph->p_va + ph->p_memsz;
c010a427:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a42a:	8b 50 08             	mov    0x8(%eax),%edx
c010a42d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a430:	8b 40 14             	mov    0x14(%eax),%eax
c010a433:	01 d0                	add    %edx,%eax
c010a435:	89 45 c0             	mov    %eax,-0x40(%ebp)
        if (start < la) {
c010a438:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a43b:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a43e:	0f 83 35 01 00 00    	jae    c010a579 <load_icode+0x38d>
            /* ph->p_memsz == ph->p_filesz */
            if (start == end) {
c010a444:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a447:	3b 45 c0             	cmp    -0x40(%ebp),%eax
c010a44a:	0f 84 3d 01 00 00    	je     c010a58d <load_icode+0x3a1>
                continue ;
            }
            off = start + PGSIZE - la, size = PGSIZE - off;
c010a450:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a453:	2b 45 d4             	sub    -0x2c(%ebp),%eax
c010a456:	05 00 10 00 00       	add    $0x1000,%eax
c010a45b:	89 45 bc             	mov    %eax,-0x44(%ebp)
c010a45e:	b8 00 10 00 00       	mov    $0x1000,%eax
c010a463:	2b 45 bc             	sub    -0x44(%ebp),%eax
c010a466:	89 45 dc             	mov    %eax,-0x24(%ebp)
            if (end < la) {
c010a469:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a46c:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a46f:	73 09                	jae    c010a47a <load_icode+0x28e>
                size -= la - end;
c010a471:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a474:	2b 45 d4             	sub    -0x2c(%ebp),%eax
c010a477:	01 45 dc             	add    %eax,-0x24(%ebp)
            }
            memset(page2kva(page) + off, 0, size);
c010a47a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a47d:	89 04 24             	mov    %eax,(%esp)
c010a480:	e8 fb ef ff ff       	call   c0109480 <page2kva>
c010a485:	89 c2                	mov    %eax,%edx
c010a487:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010a48a:	01 c2                	add    %eax,%edx
c010a48c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a48f:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a493:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010a49a:	00 
c010a49b:	89 14 24             	mov    %edx,(%esp)
c010a49e:	e8 e3 14 00 00       	call   c010b986 <memset>
            start += size;
c010a4a3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a4a6:	01 45 d8             	add    %eax,-0x28(%ebp)
            assert((end < la && start == end) || (end >= la && start == la));
c010a4a9:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a4ac:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a4af:	73 0c                	jae    c010a4bd <load_icode+0x2d1>
c010a4b1:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a4b4:	3b 45 c0             	cmp    -0x40(%ebp),%eax
c010a4b7:	0f 84 bc 00 00 00    	je     c010a579 <load_icode+0x38d>
c010a4bd:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a4c0:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a4c3:	72 0c                	jb     c010a4d1 <load_icode+0x2e5>
c010a4c5:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a4c8:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a4cb:	0f 84 a8 00 00 00    	je     c010a579 <load_icode+0x38d>
c010a4d1:	c7 44 24 0c f8 e3 10 	movl   $0xc010e3f8,0xc(%esp)
c010a4d8:	c0 
c010a4d9:	c7 44 24 08 79 e3 10 	movl   $0xc010e379,0x8(%esp)
c010a4e0:	c0 
c010a4e1:	c7 44 24 04 2d 02 00 	movl   $0x22d,0x4(%esp)
c010a4e8:	00 
c010a4e9:	c7 04 24 4c e3 10 c0 	movl   $0xc010e34c,(%esp)
c010a4f0:	e8 10 5f ff ff       	call   c0100405 <__panic>
        }
        while (start < end) {
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
c010a4f5:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a4f8:	8b 40 0c             	mov    0xc(%eax),%eax
c010a4fb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010a4fe:	89 54 24 08          	mov    %edx,0x8(%esp)
c010a502:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010a505:	89 54 24 04          	mov    %edx,0x4(%esp)
c010a509:	89 04 24             	mov    %eax,(%esp)
c010a50c:	e8 9f de ff ff       	call   c01083b0 <pgdir_alloc_page>
c010a511:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a514:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a518:	0f 84 fe 02 00 00    	je     c010a81c <load_icode+0x630>
                goto bad_cleanup_mmap;
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
c010a51e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a521:	2b 45 d4             	sub    -0x2c(%ebp),%eax
c010a524:	89 45 bc             	mov    %eax,-0x44(%ebp)
c010a527:	b8 00 10 00 00       	mov    $0x1000,%eax
c010a52c:	2b 45 bc             	sub    -0x44(%ebp),%eax
c010a52f:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010a532:	81 45 d4 00 10 00 00 	addl   $0x1000,-0x2c(%ebp)
            if (end < la) {
c010a539:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a53c:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c010a53f:	73 09                	jae    c010a54a <load_icode+0x35e>
                size -= la - end;
c010a541:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010a544:	2b 45 d4             	sub    -0x2c(%ebp),%eax
c010a547:	01 45 dc             	add    %eax,-0x24(%ebp)
            }
            memset(page2kva(page) + off, 0, size);
c010a54a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a54d:	89 04 24             	mov    %eax,(%esp)
c010a550:	e8 2b ef ff ff       	call   c0109480 <page2kva>
c010a555:	89 c2                	mov    %eax,%edx
c010a557:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010a55a:	01 c2                	add    %eax,%edx
c010a55c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a55f:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a563:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010a56a:	00 
c010a56b:	89 14 24             	mov    %edx,(%esp)
c010a56e:	e8 13 14 00 00       	call   c010b986 <memset>
            start += size;
c010a573:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a576:	01 45 d8             	add    %eax,-0x28(%ebp)
            }
            memset(page2kva(page) + off, 0, size);
            start += size;
            assert((end < la && start == end) || (end >= la && start == la));
        }
        while (start < end) {
c010a579:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a57c:	3b 45 c0             	cmp    -0x40(%ebp),%eax
c010a57f:	0f 82 70 ff ff ff    	jb     c010a4f5 <load_icode+0x309>
c010a585:	eb 07                	jmp    c010a58e <load_icode+0x3a2>
    uint32_t vm_flags, perm;
    struct proghdr *ph_end = ph + elf->e_phnum;
    for (; ph < ph_end; ph ++) {
    //(3.4) find every program section headers
        if (ph->p_type != ELF_PT_LOAD) {
            continue ;
c010a587:	90                   	nop
c010a588:	eb 04                	jmp    c010a58e <load_icode+0x3a2>
        if (ph->p_filesz > ph->p_memsz) {
            ret = -E_INVAL_ELF;
            goto bad_cleanup_mmap;
        }
        if (ph->p_filesz == 0) {
            continue ;
c010a58a:	90                   	nop
c010a58b:	eb 01                	jmp    c010a58e <load_icode+0x3a2>
      //(3.6.2) build BSS section of binary program
        end = ph->p_va + ph->p_memsz;
        if (start < la) {
            /* ph->p_memsz == ph->p_filesz */
            if (start == end) {
                continue ;
c010a58d:	90                   	nop
        goto bad_elf_cleanup_pgdir;
    }

    uint32_t vm_flags, perm;
    struct proghdr *ph_end = ph + elf->e_phnum;
    for (; ph < ph_end; ph ++) {
c010a58e:	83 45 ec 20          	addl   $0x20,-0x14(%ebp)
c010a592:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a595:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c010a598:	0f 82 ed fc ff ff    	jb     c010a28b <load_icode+0x9f>
            memset(page2kva(page) + off, 0, size);
            start += size;
        }
    }
    //(4) build user stack memory
    vm_flags = VM_READ | VM_WRITE | VM_STACK;
c010a59e:	c7 45 e8 0b 00 00 00 	movl   $0xb,-0x18(%ebp)
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
c010a5a5:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
c010a5ac:	00 
c010a5ad:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a5b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a5b4:	c7 44 24 08 00 00 10 	movl   $0x100000,0x8(%esp)
c010a5bb:	00 
c010a5bc:	c7 44 24 04 00 00 f0 	movl   $0xaff00000,0x4(%esp)
c010a5c3:	af 
c010a5c4:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a5c7:	89 04 24             	mov    %eax,(%esp)
c010a5ca:	e8 8f 93 ff ff       	call   c010395e <mm_map>
c010a5cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a5d2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a5d6:	0f 85 43 02 00 00    	jne    c010a81f <load_icode+0x633>
        goto bad_cleanup_mmap;
    }
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
c010a5dc:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a5df:	8b 40 0c             	mov    0xc(%eax),%eax
c010a5e2:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a5e9:	00 
c010a5ea:	c7 44 24 04 00 f0 ff 	movl   $0xaffff000,0x4(%esp)
c010a5f1:	af 
c010a5f2:	89 04 24             	mov    %eax,(%esp)
c010a5f5:	e8 b6 dd ff ff       	call   c01083b0 <pgdir_alloc_page>
c010a5fa:	85 c0                	test   %eax,%eax
c010a5fc:	75 24                	jne    c010a622 <load_icode+0x436>
c010a5fe:	c7 44 24 0c 34 e4 10 	movl   $0xc010e434,0xc(%esp)
c010a605:	c0 
c010a606:	c7 44 24 08 79 e3 10 	movl   $0xc010e379,0x8(%esp)
c010a60d:	c0 
c010a60e:	c7 44 24 04 40 02 00 	movl   $0x240,0x4(%esp)
c010a615:	00 
c010a616:	c7 04 24 4c e3 10 c0 	movl   $0xc010e34c,(%esp)
c010a61d:	e8 e3 5d ff ff       	call   c0100405 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
c010a622:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a625:	8b 40 0c             	mov    0xc(%eax),%eax
c010a628:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a62f:	00 
c010a630:	c7 44 24 04 00 e0 ff 	movl   $0xafffe000,0x4(%esp)
c010a637:	af 
c010a638:	89 04 24             	mov    %eax,(%esp)
c010a63b:	e8 70 dd ff ff       	call   c01083b0 <pgdir_alloc_page>
c010a640:	85 c0                	test   %eax,%eax
c010a642:	75 24                	jne    c010a668 <load_icode+0x47c>
c010a644:	c7 44 24 0c 78 e4 10 	movl   $0xc010e478,0xc(%esp)
c010a64b:	c0 
c010a64c:	c7 44 24 08 79 e3 10 	movl   $0xc010e379,0x8(%esp)
c010a653:	c0 
c010a654:	c7 44 24 04 41 02 00 	movl   $0x241,0x4(%esp)
c010a65b:	00 
c010a65c:	c7 04 24 4c e3 10 c0 	movl   $0xc010e34c,(%esp)
c010a663:	e8 9d 5d ff ff       	call   c0100405 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
c010a668:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a66b:	8b 40 0c             	mov    0xc(%eax),%eax
c010a66e:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a675:	00 
c010a676:	c7 44 24 04 00 d0 ff 	movl   $0xafffd000,0x4(%esp)
c010a67d:	af 
c010a67e:	89 04 24             	mov    %eax,(%esp)
c010a681:	e8 2a dd ff ff       	call   c01083b0 <pgdir_alloc_page>
c010a686:	85 c0                	test   %eax,%eax
c010a688:	75 24                	jne    c010a6ae <load_icode+0x4c2>
c010a68a:	c7 44 24 0c bc e4 10 	movl   $0xc010e4bc,0xc(%esp)
c010a691:	c0 
c010a692:	c7 44 24 08 79 e3 10 	movl   $0xc010e379,0x8(%esp)
c010a699:	c0 
c010a69a:	c7 44 24 04 42 02 00 	movl   $0x242,0x4(%esp)
c010a6a1:	00 
c010a6a2:	c7 04 24 4c e3 10 c0 	movl   $0xc010e34c,(%esp)
c010a6a9:	e8 57 5d ff ff       	call   c0100405 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
c010a6ae:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a6b1:	8b 40 0c             	mov    0xc(%eax),%eax
c010a6b4:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
c010a6bb:	00 
c010a6bc:	c7 44 24 04 00 c0 ff 	movl   $0xafffc000,0x4(%esp)
c010a6c3:	af 
c010a6c4:	89 04 24             	mov    %eax,(%esp)
c010a6c7:	e8 e4 dc ff ff       	call   c01083b0 <pgdir_alloc_page>
c010a6cc:	85 c0                	test   %eax,%eax
c010a6ce:	75 24                	jne    c010a6f4 <load_icode+0x508>
c010a6d0:	c7 44 24 0c 00 e5 10 	movl   $0xc010e500,0xc(%esp)
c010a6d7:	c0 
c010a6d8:	c7 44 24 08 79 e3 10 	movl   $0xc010e379,0x8(%esp)
c010a6df:	c0 
c010a6e0:	c7 44 24 04 43 02 00 	movl   $0x243,0x4(%esp)
c010a6e7:	00 
c010a6e8:	c7 04 24 4c e3 10 c0 	movl   $0xc010e34c,(%esp)
c010a6ef:	e8 11 5d ff ff       	call   c0100405 <__panic>
    
    //(5) set current process's mm, sr3, and set CR3 reg = physical addr of Page Directory
    mm_count_inc(mm);
c010a6f4:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a6f7:	89 04 24             	mov    %eax,(%esp)
c010a6fa:	e8 1f ee ff ff       	call   c010951e <mm_count_inc>
    current->mm = mm;
c010a6ff:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010a704:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010a707:	89 50 18             	mov    %edx,0x18(%eax)
    current->cr3 = PADDR(mm->pgdir);
c010a70a:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010a70f:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010a712:	8b 52 0c             	mov    0xc(%edx),%edx
c010a715:	89 55 b8             	mov    %edx,-0x48(%ebp)
c010a718:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
c010a71f:	77 23                	ja     c010a744 <load_icode+0x558>
c010a721:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010a724:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a728:	c7 44 24 08 28 e3 10 	movl   $0xc010e328,0x8(%esp)
c010a72f:	c0 
c010a730:	c7 44 24 04 48 02 00 	movl   $0x248,0x4(%esp)
c010a737:	00 
c010a738:	c7 04 24 4c e3 10 c0 	movl   $0xc010e34c,(%esp)
c010a73f:	e8 c1 5c ff ff       	call   c0100405 <__panic>
c010a744:	8b 55 b8             	mov    -0x48(%ebp),%edx
c010a747:	81 c2 00 00 00 40    	add    $0x40000000,%edx
c010a74d:	89 50 40             	mov    %edx,0x40(%eax)
    lcr3(PADDR(mm->pgdir));
c010a750:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a753:	8b 40 0c             	mov    0xc(%eax),%eax
c010a756:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c010a759:	81 7d b4 ff ff ff bf 	cmpl   $0xbfffffff,-0x4c(%ebp)
c010a760:	77 23                	ja     c010a785 <load_icode+0x599>
c010a762:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a765:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a769:	c7 44 24 08 28 e3 10 	movl   $0xc010e328,0x8(%esp)
c010a770:	c0 
c010a771:	c7 44 24 04 49 02 00 	movl   $0x249,0x4(%esp)
c010a778:	00 
c010a779:	c7 04 24 4c e3 10 c0 	movl   $0xc010e34c,(%esp)
c010a780:	e8 80 5c ff ff       	call   c0100405 <__panic>
c010a785:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010a788:	05 00 00 00 40       	add    $0x40000000,%eax
c010a78d:	89 45 ac             	mov    %eax,-0x54(%ebp)
c010a790:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010a793:	0f 22 d8             	mov    %eax,%cr3

    //(6) setup trapframe for user environment
    struct trapframe *tf = current->tf;
c010a796:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010a79b:	8b 40 3c             	mov    0x3c(%eax),%eax
c010a79e:	89 45 b0             	mov    %eax,-0x50(%ebp)
    memset(tf, 0, sizeof(struct trapframe));
c010a7a1:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
c010a7a8:	00 
c010a7a9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010a7b0:	00 
c010a7b1:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a7b4:	89 04 24             	mov    %eax,(%esp)
c010a7b7:	e8 ca 11 00 00       	call   c010b986 <memset>
    tf->tf_cs = USER_CS;
c010a7bc:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a7bf:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
    tf->tf_ds = tf->tf_es = tf->tf_ss = USER_DS;
c010a7c5:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a7c8:	66 c7 40 48 23 00    	movw   $0x23,0x48(%eax)
c010a7ce:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a7d1:	0f b7 50 48          	movzwl 0x48(%eax),%edx
c010a7d5:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a7d8:	66 89 50 28          	mov    %dx,0x28(%eax)
c010a7dc:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a7df:	0f b7 50 28          	movzwl 0x28(%eax),%edx
c010a7e3:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a7e6:	66 89 50 2c          	mov    %dx,0x2c(%eax)
    tf->tf_esp = USTACKTOP;
c010a7ea:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a7ed:	c7 40 44 00 00 00 b0 	movl   $0xb0000000,0x44(%eax)
    tf->tf_eip = elf->e_entry;
c010a7f4:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010a7f7:	8b 50 18             	mov    0x18(%eax),%edx
c010a7fa:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a7fd:	89 50 38             	mov    %edx,0x38(%eax)
    tf->tf_eflags = FL_IF;
c010a800:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010a803:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
    ret = 0;
c010a80a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
out:
    return ret;
c010a811:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a814:	eb 33                	jmp    c010a849 <load_icode+0x65d>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
        if (vm_flags & VM_WRITE) perm |= PTE_W;
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
            goto bad_cleanup_mmap;
c010a816:	90                   	nop
c010a817:	eb 07                	jmp    c010a820 <load_icode+0x634>
     //(3.6) alloc memory, and  copy the contents of every program section (from, from+end) to process's memory (la, la+end)
        end = ph->p_va + ph->p_filesz;
     //(3.6.1) copy TEXT/DATA section of bianry program
        while (start < end) {
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
                goto bad_cleanup_mmap;
c010a819:	90                   	nop
c010a81a:	eb 04                	jmp    c010a820 <load_icode+0x634>
            start += size;
            assert((end < la && start == end) || (end >= la && start == la));
        }
        while (start < end) {
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
                goto bad_cleanup_mmap;
c010a81c:	90                   	nop
c010a81d:	eb 01                	jmp    c010a820 <load_icode+0x634>
        }
    }
    //(4) build user stack memory
    vm_flags = VM_READ | VM_WRITE | VM_STACK;
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
        goto bad_cleanup_mmap;
c010a81f:	90                   	nop
    tf->tf_eflags = FL_IF;
    ret = 0;
out:
    return ret;
bad_cleanup_mmap:
    exit_mmap(mm);
c010a820:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a823:	89 04 24             	mov    %eax,(%esp)
c010a826:	e8 4c 93 ff ff       	call   c0103b77 <exit_mmap>
bad_elf_cleanup_pgdir:
    put_pgdir(mm);
c010a82b:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a82e:	89 04 24             	mov    %eax,(%esp)
c010a831:	e8 95 f4 ff ff       	call   c0109ccb <put_pgdir>
c010a836:	eb 01                	jmp    c010a839 <load_icode+0x64d>
    if ((mm = mm_create()) == NULL) {
        goto bad_mm;
    }
    //(2) create a new PDT, and mm->pgdir= kernel virtual addr of PDT
    if (setup_pgdir(mm) != 0) {
        goto bad_pgdir_cleanup_mm;
c010a838:	90                   	nop
bad_cleanup_mmap:
    exit_mmap(mm);
bad_elf_cleanup_pgdir:
    put_pgdir(mm);
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
c010a839:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a83c:	89 04 24             	mov    %eax,(%esp)
c010a83f:	e8 77 90 ff ff       	call   c01038bb <mm_destroy>
bad_mm:
    goto out;
c010a844:	eb cb                	jmp    c010a811 <load_icode+0x625>

    int ret = -E_NO_MEM;
    struct mm_struct *mm;
    //(1) create a new mm for current process
    if ((mm = mm_create()) == NULL) {
        goto bad_mm;
c010a846:	90                   	nop
bad_elf_cleanup_pgdir:
    put_pgdir(mm);
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
bad_mm:
    goto out;
c010a847:	eb c8                	jmp    c010a811 <load_icode+0x625>
}
c010a849:	c9                   	leave  
c010a84a:	c3                   	ret    

c010a84b <do_execve>:

// do_execve - call exit_mmap(mm)&put_pgdir(mm) to reclaim memory space of current process
//           - call load_icode to setup new memory space accroding binary prog.
int
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
c010a84b:	55                   	push   %ebp
c010a84c:	89 e5                	mov    %esp,%ebp
c010a84e:	83 ec 38             	sub    $0x38,%esp
    struct mm_struct *mm = current->mm;
c010a851:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010a856:	8b 40 18             	mov    0x18(%eax),%eax
c010a859:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
c010a85c:	8b 45 08             	mov    0x8(%ebp),%eax
c010a85f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010a866:	00 
c010a867:	8b 55 0c             	mov    0xc(%ebp),%edx
c010a86a:	89 54 24 08          	mov    %edx,0x8(%esp)
c010a86e:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a872:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a875:	89 04 24             	mov    %eax,(%esp)
c010a878:	e8 96 9d ff ff       	call   c0104613 <user_mem_check>
c010a87d:	85 c0                	test   %eax,%eax
c010a87f:	75 0a                	jne    c010a88b <do_execve+0x40>
        return -E_INVAL;
c010a881:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010a886:	e9 f6 00 00 00       	jmp    c010a981 <do_execve+0x136>
    }
    if (len > PROC_NAME_LEN) {
c010a88b:	83 7d 0c 0f          	cmpl   $0xf,0xc(%ebp)
c010a88f:	76 07                	jbe    c010a898 <do_execve+0x4d>
        len = PROC_NAME_LEN;
c010a891:	c7 45 0c 0f 00 00 00 	movl   $0xf,0xc(%ebp)
    }

    char local_name[PROC_NAME_LEN + 1];
    memset(local_name, 0, sizeof(local_name));
c010a898:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c010a89f:	00 
c010a8a0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010a8a7:	00 
c010a8a8:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010a8ab:	89 04 24             	mov    %eax,(%esp)
c010a8ae:	e8 d3 10 00 00       	call   c010b986 <memset>
    memcpy(local_name, name, len);
c010a8b3:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a8b6:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a8ba:	8b 45 08             	mov    0x8(%ebp),%eax
c010a8bd:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a8c1:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010a8c4:	89 04 24             	mov    %eax,(%esp)
c010a8c7:	e8 9d 11 00 00       	call   c010ba69 <memcpy>

    if (mm != NULL) {
c010a8cc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a8d0:	74 4a                	je     c010a91c <do_execve+0xd1>
        lcr3(boot_cr3);
c010a8d2:	a1 5c 31 1b c0       	mov    0xc01b315c,%eax
c010a8d7:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010a8da:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a8dd:	0f 22 d8             	mov    %eax,%cr3
        if (mm_count_dec(mm) == 0) {
c010a8e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a8e3:	89 04 24             	mov    %eax,(%esp)
c010a8e6:	e8 4d ec ff ff       	call   c0109538 <mm_count_dec>
c010a8eb:	85 c0                	test   %eax,%eax
c010a8ed:	75 21                	jne    c010a910 <do_execve+0xc5>
            exit_mmap(mm);
c010a8ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a8f2:	89 04 24             	mov    %eax,(%esp)
c010a8f5:	e8 7d 92 ff ff       	call   c0103b77 <exit_mmap>
            put_pgdir(mm);
c010a8fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a8fd:	89 04 24             	mov    %eax,(%esp)
c010a900:	e8 c6 f3 ff ff       	call   c0109ccb <put_pgdir>
            mm_destroy(mm);
c010a905:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a908:	89 04 24             	mov    %eax,(%esp)
c010a90b:	e8 ab 8f ff ff       	call   c01038bb <mm_destroy>
        }
        current->mm = NULL;
c010a910:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010a915:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
    }
    int ret;
    if ((ret = load_icode(binary, size)) != 0) {
c010a91c:	8b 45 14             	mov    0x14(%ebp),%eax
c010a91f:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a923:	8b 45 10             	mov    0x10(%ebp),%eax
c010a926:	89 04 24             	mov    %eax,(%esp)
c010a929:	e8 be f8 ff ff       	call   c010a1ec <load_icode>
c010a92e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a931:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a935:	75 1b                	jne    c010a952 <do_execve+0x107>
        goto execve_exit;
    }
    set_proc_name(current, local_name);
c010a937:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010a93c:	8d 55 dc             	lea    -0x24(%ebp),%edx
c010a93f:	89 54 24 04          	mov    %edx,0x4(%esp)
c010a943:	89 04 24             	mov    %eax,(%esp)
c010a946:	e8 b1 ed ff ff       	call   c01096fc <set_proc_name>
    return 0;
c010a94b:	b8 00 00 00 00       	mov    $0x0,%eax
c010a950:	eb 2f                	jmp    c010a981 <do_execve+0x136>
        }
        current->mm = NULL;
    }
    int ret;
    if ((ret = load_icode(binary, size)) != 0) {
        goto execve_exit;
c010a952:	90                   	nop
    }
    set_proc_name(current, local_name);
    return 0;

execve_exit:
    do_exit(ret);
c010a953:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a956:	89 04 24             	mov    %eax,(%esp)
c010a959:	e8 bf f6 ff ff       	call   c010a01d <do_exit>
    panic("already exit: %e.\n", ret);
c010a95e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a961:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a965:	c7 44 24 08 43 e5 10 	movl   $0xc010e543,0x8(%esp)
c010a96c:	c0 
c010a96d:	c7 44 24 04 82 02 00 	movl   $0x282,0x4(%esp)
c010a974:	00 
c010a975:	c7 04 24 4c e3 10 c0 	movl   $0xc010e34c,(%esp)
c010a97c:	e8 84 5a ff ff       	call   c0100405 <__panic>
}
c010a981:	c9                   	leave  
c010a982:	c3                   	ret    

c010a983 <do_yield>:

// do_yield - ask the scheduler to reschedule
int
do_yield(void) {
c010a983:	55                   	push   %ebp
c010a984:	89 e5                	mov    %esp,%ebp
    current->need_resched = 1;
c010a986:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010a98b:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    return 0;
c010a992:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010a997:	5d                   	pop    %ebp
c010a998:	c3                   	ret    

c010a999 <do_wait>:

// do_wait - wait one OR any children with PROC_ZOMBIE state, and free memory space of kernel stack
//         - proc struct of this child.
// NOTE: only after do_wait function, all resources of the child proces are free.
int
do_wait(int pid, int *code_store) {
c010a999:	55                   	push   %ebp
c010a99a:	89 e5                	mov    %esp,%ebp
c010a99c:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = current->mm;
c010a99f:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010a9a4:	8b 40 18             	mov    0x18(%eax),%eax
c010a9a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (code_store != NULL) {
c010a9aa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010a9ae:	74 30                	je     c010a9e0 <do_wait+0x47>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
c010a9b0:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a9b3:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c010a9ba:	00 
c010a9bb:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
c010a9c2:	00 
c010a9c3:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a9c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a9ca:	89 04 24             	mov    %eax,(%esp)
c010a9cd:	e8 41 9c ff ff       	call   c0104613 <user_mem_check>
c010a9d2:	85 c0                	test   %eax,%eax
c010a9d4:	75 0a                	jne    c010a9e0 <do_wait+0x47>
            return -E_INVAL;
c010a9d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010a9db:	e9 46 01 00 00       	jmp    c010ab26 <do_wait+0x18d>
    }

    struct proc_struct *proc;
    bool intr_flag, haskid;
repeat:
    haskid = 0;
c010a9e0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    if (pid != 0) {
c010a9e7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010a9eb:	74 36                	je     c010aa23 <do_wait+0x8a>
        proc = find_proc(pid);
c010a9ed:	8b 45 08             	mov    0x8(%ebp),%eax
c010a9f0:	89 04 24             	mov    %eax,(%esp)
c010a9f3:	e8 e3 f0 ff ff       	call   c0109adb <find_proc>
c010a9f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (proc != NULL && proc->parent == current) {
c010a9fb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a9ff:	74 4f                	je     c010aa50 <do_wait+0xb7>
c010aa01:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aa04:	8b 50 14             	mov    0x14(%eax),%edx
c010aa07:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010aa0c:	39 c2                	cmp    %eax,%edx
c010aa0e:	75 40                	jne    c010aa50 <do_wait+0xb7>
            haskid = 1;
c010aa10:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
            if (proc->state == PROC_ZOMBIE) {
c010aa17:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aa1a:	8b 00                	mov    (%eax),%eax
c010aa1c:	83 f8 03             	cmp    $0x3,%eax
c010aa1f:	75 2f                	jne    c010aa50 <do_wait+0xb7>
                goto found;
c010aa21:	eb 7e                	jmp    c010aaa1 <do_wait+0x108>
            }
        }
    }
    else {
        proc = current->cptr;
c010aa23:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010aa28:	8b 40 70             	mov    0x70(%eax),%eax
c010aa2b:	89 45 f4             	mov    %eax,-0xc(%ebp)
        for (; proc != NULL; proc = proc->optr) {
c010aa2e:	eb 1a                	jmp    c010aa4a <do_wait+0xb1>
            haskid = 1;
c010aa30:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
            if (proc->state == PROC_ZOMBIE) {
c010aa37:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aa3a:	8b 00                	mov    (%eax),%eax
c010aa3c:	83 f8 03             	cmp    $0x3,%eax
c010aa3f:	74 5f                	je     c010aaa0 <do_wait+0x107>
            }
        }
    }
    else {
        proc = current->cptr;
        for (; proc != NULL; proc = proc->optr) {
c010aa41:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aa44:	8b 40 78             	mov    0x78(%eax),%eax
c010aa47:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010aa4a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010aa4e:	75 e0                	jne    c010aa30 <do_wait+0x97>
            if (proc->state == PROC_ZOMBIE) {
                goto found;
            }
        }
    }
    if (haskid) {
c010aa50:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010aa54:	74 40                	je     c010aa96 <do_wait+0xfd>
        current->state = PROC_SLEEPING;
c010aa56:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010aa5b:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
        current->wait_state = WT_CHILD;
c010aa61:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010aa66:	c7 40 6c 01 00 00 80 	movl   $0x80000001,0x6c(%eax)
        schedule();
c010aa6d:	e8 20 07 00 00       	call   c010b192 <schedule>
        if (current->flags & PF_EXITING) {
c010aa72:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010aa77:	8b 40 44             	mov    0x44(%eax),%eax
c010aa7a:	83 e0 01             	and    $0x1,%eax
c010aa7d:	85 c0                	test   %eax,%eax
c010aa7f:	0f 84 5b ff ff ff    	je     c010a9e0 <do_wait+0x47>
            do_exit(-E_KILLED);
c010aa85:	c7 04 24 f7 ff ff ff 	movl   $0xfffffff7,(%esp)
c010aa8c:	e8 8c f5 ff ff       	call   c010a01d <do_exit>
        }
        goto repeat;
c010aa91:	e9 4a ff ff ff       	jmp    c010a9e0 <do_wait+0x47>
    }
    return -E_BAD_PROC;
c010aa96:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
c010aa9b:	e9 86 00 00 00       	jmp    c010ab26 <do_wait+0x18d>
    else {
        proc = current->cptr;
        for (; proc != NULL; proc = proc->optr) {
            haskid = 1;
            if (proc->state == PROC_ZOMBIE) {
                goto found;
c010aaa0:	90                   	nop
        goto repeat;
    }
    return -E_BAD_PROC;

found:
    if (proc == idleproc || proc == initproc) {
c010aaa1:	a1 20 10 1b c0       	mov    0xc01b1020,%eax
c010aaa6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010aaa9:	74 0a                	je     c010aab5 <do_wait+0x11c>
c010aaab:	a1 24 10 1b c0       	mov    0xc01b1024,%eax
c010aab0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010aab3:	75 1c                	jne    c010aad1 <do_wait+0x138>
        panic("wait idleproc or initproc.\n");
c010aab5:	c7 44 24 08 56 e5 10 	movl   $0xc010e556,0x8(%esp)
c010aabc:	c0 
c010aabd:	c7 44 24 04 bb 02 00 	movl   $0x2bb,0x4(%esp)
c010aac4:	00 
c010aac5:	c7 04 24 4c e3 10 c0 	movl   $0xc010e34c,(%esp)
c010aacc:	e8 34 59 ff ff       	call   c0100405 <__panic>
    }
    if (code_store != NULL) {
c010aad1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010aad5:	74 0b                	je     c010aae2 <do_wait+0x149>
        *code_store = proc->exit_code;
c010aad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aada:	8b 50 68             	mov    0x68(%eax),%edx
c010aadd:	8b 45 0c             	mov    0xc(%ebp),%eax
c010aae0:	89 10                	mov    %edx,(%eax)
    }
    local_intr_save(intr_flag);
c010aae2:	e8 6f e8 ff ff       	call   c0109356 <__intr_save>
c010aae7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    {
        unhash_proc(proc);
c010aaea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aaed:	89 04 24             	mov    %eax,(%esp)
c010aaf0:	e8 b2 ef ff ff       	call   c0109aa7 <unhash_proc>
        remove_links(proc);
c010aaf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010aaf8:	89 04 24             	mov    %eax,(%esp)
c010aafb:	e8 25 ed ff ff       	call   c0109825 <remove_links>
    }
    local_intr_restore(intr_flag);
c010ab00:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010ab03:	89 04 24             	mov    %eax,(%esp)
c010ab06:	e8 75 e8 ff ff       	call   c0109380 <__intr_restore>
    put_kstack(proc);
c010ab0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ab0e:	89 04 24             	mov    %eax,(%esp)
c010ab11:	e8 e7 f0 ff ff       	call   c0109bfd <put_kstack>
    kfree(proc);
c010ab16:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ab19:	89 04 24             	mov    %eax,(%esp)
c010ab1c:	e8 91 ae ff ff       	call   c01059b2 <kfree>
    return 0;
c010ab21:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010ab26:	c9                   	leave  
c010ab27:	c3                   	ret    

c010ab28 <do_kill>:

// do_kill - kill process with pid by set this process's flags with PF_EXITING
int
do_kill(int pid) {
c010ab28:	55                   	push   %ebp
c010ab29:	89 e5                	mov    %esp,%ebp
c010ab2b:	83 ec 28             	sub    $0x28,%esp
    struct proc_struct *proc;
    if ((proc = find_proc(pid)) != NULL) {
c010ab2e:	8b 45 08             	mov    0x8(%ebp),%eax
c010ab31:	89 04 24             	mov    %eax,(%esp)
c010ab34:	e8 a2 ef ff ff       	call   c0109adb <find_proc>
c010ab39:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010ab3c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010ab40:	74 41                	je     c010ab83 <do_kill+0x5b>
        if (!(proc->flags & PF_EXITING)) {
c010ab42:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ab45:	8b 40 44             	mov    0x44(%eax),%eax
c010ab48:	83 e0 01             	and    $0x1,%eax
c010ab4b:	85 c0                	test   %eax,%eax
c010ab4d:	75 2d                	jne    c010ab7c <do_kill+0x54>
            proc->flags |= PF_EXITING;
c010ab4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ab52:	8b 40 44             	mov    0x44(%eax),%eax
c010ab55:	83 c8 01             	or     $0x1,%eax
c010ab58:	89 c2                	mov    %eax,%edx
c010ab5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ab5d:	89 50 44             	mov    %edx,0x44(%eax)
            if (proc->wait_state & WT_INTERRUPTED) {
c010ab60:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ab63:	8b 40 6c             	mov    0x6c(%eax),%eax
c010ab66:	85 c0                	test   %eax,%eax
c010ab68:	79 0b                	jns    c010ab75 <do_kill+0x4d>
                wakeup_proc(proc);
c010ab6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010ab6d:	89 04 24             	mov    %eax,(%esp)
c010ab70:	e8 83 05 00 00       	call   c010b0f8 <wakeup_proc>
            }
            return 0;
c010ab75:	b8 00 00 00 00       	mov    $0x0,%eax
c010ab7a:	eb 0c                	jmp    c010ab88 <do_kill+0x60>
        }
        return -E_KILLED;
c010ab7c:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
c010ab81:	eb 05                	jmp    c010ab88 <do_kill+0x60>
    }
    return -E_INVAL;
c010ab83:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
c010ab88:	c9                   	leave  
c010ab89:	c3                   	ret    

c010ab8a <kernel_execve>:

// kernel_execve - do SYS_exec syscall to exec a user program called by user_main kernel_thread
static int
kernel_execve(const char *name, unsigned char *binary, size_t size) {
c010ab8a:	55                   	push   %ebp
c010ab8b:	89 e5                	mov    %esp,%ebp
c010ab8d:	57                   	push   %edi
c010ab8e:	56                   	push   %esi
c010ab8f:	53                   	push   %ebx
c010ab90:	83 ec 2c             	sub    $0x2c,%esp
    int ret, len = strlen(name);
c010ab93:	8b 45 08             	mov    0x8(%ebp),%eax
c010ab96:	89 04 24             	mov    %eax,(%esp)
c010ab99:	e8 c8 0a 00 00       	call   c010b666 <strlen>
c010ab9e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    asm volatile (
c010aba1:	b8 04 00 00 00       	mov    $0x4,%eax
c010aba6:	8b 55 08             	mov    0x8(%ebp),%edx
c010aba9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
c010abac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
c010abaf:	8b 75 10             	mov    0x10(%ebp),%esi
c010abb2:	89 f7                	mov    %esi,%edi
c010abb4:	cd 80                	int    $0x80
c010abb6:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "int %1;"
        : "=a" (ret)
        : "i" (T_SYSCALL), "0" (SYS_exec), "d" (name), "c" (len), "b" (binary), "D" (size)
        : "memory");
    return ret;
c010abb9:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
c010abbc:	83 c4 2c             	add    $0x2c,%esp
c010abbf:	5b                   	pop    %ebx
c010abc0:	5e                   	pop    %esi
c010abc1:	5f                   	pop    %edi
c010abc2:	5d                   	pop    %ebp
c010abc3:	c3                   	ret    

c010abc4 <user_main>:

#define KERNEL_EXECVE2(x, xstart, xsize)        __KERNEL_EXECVE2(x, xstart, xsize)

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
c010abc4:	55                   	push   %ebp
c010abc5:	89 e5                	mov    %esp,%ebp
c010abc7:	83 ec 18             	sub    $0x18,%esp
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
#else
    KERNEL_EXECVE(exit);
c010abca:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010abcf:	8b 40 04             	mov    0x4(%eax),%eax
c010abd2:	c7 44 24 08 72 e5 10 	movl   $0xc010e572,0x8(%esp)
c010abd9:	c0 
c010abda:	89 44 24 04          	mov    %eax,0x4(%esp)
c010abde:	c7 04 24 78 e5 10 c0 	movl   $0xc010e578,(%esp)
c010abe5:	e8 c4 56 ff ff       	call   c01002ae <cprintf>
c010abea:	b8 dc 78 00 00       	mov    $0x78dc,%eax
c010abef:	89 44 24 08          	mov    %eax,0x8(%esp)
c010abf3:	c7 44 24 04 d0 a3 15 	movl   $0xc015a3d0,0x4(%esp)
c010abfa:	c0 
c010abfb:	c7 04 24 72 e5 10 c0 	movl   $0xc010e572,(%esp)
c010ac02:	e8 83 ff ff ff       	call   c010ab8a <kernel_execve>
#endif
    panic("user_main execve failed.\n");
c010ac07:	c7 44 24 08 9f e5 10 	movl   $0xc010e59f,0x8(%esp)
c010ac0e:	c0 
c010ac0f:	c7 44 24 04 04 03 00 	movl   $0x304,0x4(%esp)
c010ac16:	00 
c010ac17:	c7 04 24 4c e3 10 c0 	movl   $0xc010e34c,(%esp)
c010ac1e:	e8 e2 57 ff ff       	call   c0100405 <__panic>

c010ac23 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
c010ac23:	55                   	push   %ebp
c010ac24:	89 e5                	mov    %esp,%ebp
c010ac26:	83 ec 38             	sub    $0x38,%esp
    size_t nr_free_pages_store = nr_free_pages();
c010ac29:	e8 e0 c9 ff ff       	call   c010760e <nr_free_pages>
c010ac2e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    size_t kernel_allocated_store = kallocated();
c010ac31:	e8 3e ac ff ff       	call   c0105874 <kallocated>
c010ac36:	89 45 f0             	mov    %eax,-0x10(%ebp)

    int pid = kernel_thread(user_main, NULL, 0);
c010ac39:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010ac40:	00 
c010ac41:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010ac48:	00 
c010ac49:	c7 04 24 c4 ab 10 c0 	movl   $0xc010abc4,(%esp)
c010ac50:	e8 f8 ee ff ff       	call   c0109b4d <kernel_thread>
c010ac55:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (pid <= 0) {
c010ac58:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010ac5c:	7f 21                	jg     c010ac7f <init_main+0x5c>
        panic("create user_main failed.\n");
c010ac5e:	c7 44 24 08 b9 e5 10 	movl   $0xc010e5b9,0x8(%esp)
c010ac65:	c0 
c010ac66:	c7 44 24 04 0f 03 00 	movl   $0x30f,0x4(%esp)
c010ac6d:	00 
c010ac6e:	c7 04 24 4c e3 10 c0 	movl   $0xc010e34c,(%esp)
c010ac75:	e8 8b 57 ff ff       	call   c0100405 <__panic>
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
c010ac7a:	e8 13 05 00 00       	call   c010b192 <schedule>
    int pid = kernel_thread(user_main, NULL, 0);
    if (pid <= 0) {
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
c010ac7f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010ac86:	00 
c010ac87:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010ac8e:	e8 06 fd ff ff       	call   c010a999 <do_wait>
c010ac93:	85 c0                	test   %eax,%eax
c010ac95:	74 e3                	je     c010ac7a <init_main+0x57>
        schedule();
    }

    cprintf("all user-mode processes have quit.\n");
c010ac97:	c7 04 24 d4 e5 10 c0 	movl   $0xc010e5d4,(%esp)
c010ac9e:	e8 0b 56 ff ff       	call   c01002ae <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
c010aca3:	a1 24 10 1b c0       	mov    0xc01b1024,%eax
c010aca8:	8b 40 70             	mov    0x70(%eax),%eax
c010acab:	85 c0                	test   %eax,%eax
c010acad:	75 18                	jne    c010acc7 <init_main+0xa4>
c010acaf:	a1 24 10 1b c0       	mov    0xc01b1024,%eax
c010acb4:	8b 40 74             	mov    0x74(%eax),%eax
c010acb7:	85 c0                	test   %eax,%eax
c010acb9:	75 0c                	jne    c010acc7 <init_main+0xa4>
c010acbb:	a1 24 10 1b c0       	mov    0xc01b1024,%eax
c010acc0:	8b 40 78             	mov    0x78(%eax),%eax
c010acc3:	85 c0                	test   %eax,%eax
c010acc5:	74 24                	je     c010aceb <init_main+0xc8>
c010acc7:	c7 44 24 0c f8 e5 10 	movl   $0xc010e5f8,0xc(%esp)
c010acce:	c0 
c010accf:	c7 44 24 08 79 e3 10 	movl   $0xc010e379,0x8(%esp)
c010acd6:	c0 
c010acd7:	c7 44 24 04 17 03 00 	movl   $0x317,0x4(%esp)
c010acde:	00 
c010acdf:	c7 04 24 4c e3 10 c0 	movl   $0xc010e34c,(%esp)
c010ace6:	e8 1a 57 ff ff       	call   c0100405 <__panic>
    assert(nr_process == 2);
c010aceb:	a1 40 30 1b c0       	mov    0xc01b3040,%eax
c010acf0:	83 f8 02             	cmp    $0x2,%eax
c010acf3:	74 24                	je     c010ad19 <init_main+0xf6>
c010acf5:	c7 44 24 0c 43 e6 10 	movl   $0xc010e643,0xc(%esp)
c010acfc:	c0 
c010acfd:	c7 44 24 08 79 e3 10 	movl   $0xc010e379,0x8(%esp)
c010ad04:	c0 
c010ad05:	c7 44 24 04 18 03 00 	movl   $0x318,0x4(%esp)
c010ad0c:	00 
c010ad0d:	c7 04 24 4c e3 10 c0 	movl   $0xc010e34c,(%esp)
c010ad14:	e8 ec 56 ff ff       	call   c0100405 <__panic>
c010ad19:	c7 45 e4 64 31 1b c0 	movl   $0xc01b3164,-0x1c(%ebp)
c010ad20:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010ad23:	8b 40 04             	mov    0x4(%eax),%eax
    assert(list_next(&proc_list) == &(initproc->list_link));
c010ad26:	8b 15 24 10 1b c0    	mov    0xc01b1024,%edx
c010ad2c:	83 c2 58             	add    $0x58,%edx
c010ad2f:	39 d0                	cmp    %edx,%eax
c010ad31:	74 24                	je     c010ad57 <init_main+0x134>
c010ad33:	c7 44 24 0c 54 e6 10 	movl   $0xc010e654,0xc(%esp)
c010ad3a:	c0 
c010ad3b:	c7 44 24 08 79 e3 10 	movl   $0xc010e379,0x8(%esp)
c010ad42:	c0 
c010ad43:	c7 44 24 04 19 03 00 	movl   $0x319,0x4(%esp)
c010ad4a:	00 
c010ad4b:	c7 04 24 4c e3 10 c0 	movl   $0xc010e34c,(%esp)
c010ad52:	e8 ae 56 ff ff       	call   c0100405 <__panic>
c010ad57:	c7 45 e8 64 31 1b c0 	movl   $0xc01b3164,-0x18(%ebp)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
c010ad5e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010ad61:	8b 00                	mov    (%eax),%eax
    assert(list_prev(&proc_list) == &(initproc->list_link));
c010ad63:	8b 15 24 10 1b c0    	mov    0xc01b1024,%edx
c010ad69:	83 c2 58             	add    $0x58,%edx
c010ad6c:	39 d0                	cmp    %edx,%eax
c010ad6e:	74 24                	je     c010ad94 <init_main+0x171>
c010ad70:	c7 44 24 0c 84 e6 10 	movl   $0xc010e684,0xc(%esp)
c010ad77:	c0 
c010ad78:	c7 44 24 08 79 e3 10 	movl   $0xc010e379,0x8(%esp)
c010ad7f:	c0 
c010ad80:	c7 44 24 04 1a 03 00 	movl   $0x31a,0x4(%esp)
c010ad87:	00 
c010ad88:	c7 04 24 4c e3 10 c0 	movl   $0xc010e34c,(%esp)
c010ad8f:	e8 71 56 ff ff       	call   c0100405 <__panic>

    cprintf("init check memory pass.\n");
c010ad94:	c7 04 24 b4 e6 10 c0 	movl   $0xc010e6b4,(%esp)
c010ad9b:	e8 0e 55 ff ff       	call   c01002ae <cprintf>
    return 0;
c010ada0:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010ada5:	c9                   	leave  
c010ada6:	c3                   	ret    

c010ada7 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
c010ada7:	55                   	push   %ebp
c010ada8:	89 e5                	mov    %esp,%ebp
c010adaa:	83 ec 28             	sub    $0x28,%esp
c010adad:	c7 45 e8 64 31 1b c0 	movl   $0xc01b3164,-0x18(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010adb4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010adb7:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010adba:	89 50 04             	mov    %edx,0x4(%eax)
c010adbd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010adc0:	8b 50 04             	mov    0x4(%eax),%edx
c010adc3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010adc6:	89 10                	mov    %edx,(%eax)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c010adc8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010adcf:	eb 25                	jmp    c010adf6 <proc_init+0x4f>
        list_init(hash_list + i);
c010add1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010add4:	c1 e0 03             	shl    $0x3,%eax
c010add7:	05 40 10 1b c0       	add    $0xc01b1040,%eax
c010addc:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010addf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010ade2:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010ade5:	89 50 04             	mov    %edx,0x4(%eax)
c010ade8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010adeb:	8b 50 04             	mov    0x4(%eax),%edx
c010adee:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010adf1:	89 10                	mov    %edx,(%eax)
void
proc_init(void) {
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c010adf3:	ff 45 f4             	incl   -0xc(%ebp)
c010adf6:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
c010adfd:	7e d2                	jle    c010add1 <proc_init+0x2a>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
c010adff:	e8 88 e7 ff ff       	call   c010958c <alloc_proc>
c010ae04:	a3 20 10 1b c0       	mov    %eax,0xc01b1020
c010ae09:	a1 20 10 1b c0       	mov    0xc01b1020,%eax
c010ae0e:	85 c0                	test   %eax,%eax
c010ae10:	75 1c                	jne    c010ae2e <proc_init+0x87>
        panic("cannot alloc idleproc.\n");
c010ae12:	c7 44 24 08 cd e6 10 	movl   $0xc010e6cd,0x8(%esp)
c010ae19:	c0 
c010ae1a:	c7 44 24 04 2c 03 00 	movl   $0x32c,0x4(%esp)
c010ae21:	00 
c010ae22:	c7 04 24 4c e3 10 c0 	movl   $0xc010e34c,(%esp)
c010ae29:	e8 d7 55 ff ff       	call   c0100405 <__panic>
    }

    idleproc->pid = 0;
c010ae2e:	a1 20 10 1b c0       	mov    0xc01b1020,%eax
c010ae33:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    idleproc->state = PROC_RUNNABLE;
c010ae3a:	a1 20 10 1b c0       	mov    0xc01b1020,%eax
c010ae3f:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
    idleproc->kstack = (uintptr_t)bootstack;
c010ae45:	a1 20 10 1b c0       	mov    0xc01b1020,%eax
c010ae4a:	ba 00 a0 12 c0       	mov    $0xc012a000,%edx
c010ae4f:	89 50 0c             	mov    %edx,0xc(%eax)
    idleproc->need_resched = 1;
c010ae52:	a1 20 10 1b c0       	mov    0xc01b1020,%eax
c010ae57:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    set_proc_name(idleproc, "idle");
c010ae5e:	a1 20 10 1b c0       	mov    0xc01b1020,%eax
c010ae63:	c7 44 24 04 e5 e6 10 	movl   $0xc010e6e5,0x4(%esp)
c010ae6a:	c0 
c010ae6b:	89 04 24             	mov    %eax,(%esp)
c010ae6e:	e8 89 e8 ff ff       	call   c01096fc <set_proc_name>
    nr_process ++;
c010ae73:	a1 40 30 1b c0       	mov    0xc01b3040,%eax
c010ae78:	40                   	inc    %eax
c010ae79:	a3 40 30 1b c0       	mov    %eax,0xc01b3040

    current = idleproc;
c010ae7e:	a1 20 10 1b c0       	mov    0xc01b1020,%eax
c010ae83:	a3 28 10 1b c0       	mov    %eax,0xc01b1028

    int pid = kernel_thread(init_main, NULL, 0);
c010ae88:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010ae8f:	00 
c010ae90:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010ae97:	00 
c010ae98:	c7 04 24 23 ac 10 c0 	movl   $0xc010ac23,(%esp)
c010ae9f:	e8 a9 ec ff ff       	call   c0109b4d <kernel_thread>
c010aea4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (pid <= 0) {
c010aea7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010aeab:	7f 1c                	jg     c010aec9 <proc_init+0x122>
        panic("create init_main failed.\n");
c010aead:	c7 44 24 08 ea e6 10 	movl   $0xc010e6ea,0x8(%esp)
c010aeb4:	c0 
c010aeb5:	c7 44 24 04 3a 03 00 	movl   $0x33a,0x4(%esp)
c010aebc:	00 
c010aebd:	c7 04 24 4c e3 10 c0 	movl   $0xc010e34c,(%esp)
c010aec4:	e8 3c 55 ff ff       	call   c0100405 <__panic>
    }

    initproc = find_proc(pid);
c010aec9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010aecc:	89 04 24             	mov    %eax,(%esp)
c010aecf:	e8 07 ec ff ff       	call   c0109adb <find_proc>
c010aed4:	a3 24 10 1b c0       	mov    %eax,0xc01b1024
    set_proc_name(initproc, "init");
c010aed9:	a1 24 10 1b c0       	mov    0xc01b1024,%eax
c010aede:	c7 44 24 04 04 e7 10 	movl   $0xc010e704,0x4(%esp)
c010aee5:	c0 
c010aee6:	89 04 24             	mov    %eax,(%esp)
c010aee9:	e8 0e e8 ff ff       	call   c01096fc <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
c010aeee:	a1 20 10 1b c0       	mov    0xc01b1020,%eax
c010aef3:	85 c0                	test   %eax,%eax
c010aef5:	74 0c                	je     c010af03 <proc_init+0x15c>
c010aef7:	a1 20 10 1b c0       	mov    0xc01b1020,%eax
c010aefc:	8b 40 04             	mov    0x4(%eax),%eax
c010aeff:	85 c0                	test   %eax,%eax
c010af01:	74 24                	je     c010af27 <proc_init+0x180>
c010af03:	c7 44 24 0c 0c e7 10 	movl   $0xc010e70c,0xc(%esp)
c010af0a:	c0 
c010af0b:	c7 44 24 08 79 e3 10 	movl   $0xc010e379,0x8(%esp)
c010af12:	c0 
c010af13:	c7 44 24 04 40 03 00 	movl   $0x340,0x4(%esp)
c010af1a:	00 
c010af1b:	c7 04 24 4c e3 10 c0 	movl   $0xc010e34c,(%esp)
c010af22:	e8 de 54 ff ff       	call   c0100405 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
c010af27:	a1 24 10 1b c0       	mov    0xc01b1024,%eax
c010af2c:	85 c0                	test   %eax,%eax
c010af2e:	74 0d                	je     c010af3d <proc_init+0x196>
c010af30:	a1 24 10 1b c0       	mov    0xc01b1024,%eax
c010af35:	8b 40 04             	mov    0x4(%eax),%eax
c010af38:	83 f8 01             	cmp    $0x1,%eax
c010af3b:	74 24                	je     c010af61 <proc_init+0x1ba>
c010af3d:	c7 44 24 0c 34 e7 10 	movl   $0xc010e734,0xc(%esp)
c010af44:	c0 
c010af45:	c7 44 24 08 79 e3 10 	movl   $0xc010e379,0x8(%esp)
c010af4c:	c0 
c010af4d:	c7 44 24 04 41 03 00 	movl   $0x341,0x4(%esp)
c010af54:	00 
c010af55:	c7 04 24 4c e3 10 c0 	movl   $0xc010e34c,(%esp)
c010af5c:	e8 a4 54 ff ff       	call   c0100405 <__panic>
}
c010af61:	90                   	nop
c010af62:	c9                   	leave  
c010af63:	c3                   	ret    

c010af64 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
c010af64:	55                   	push   %ebp
c010af65:	89 e5                	mov    %esp,%ebp
c010af67:	83 ec 08             	sub    $0x8,%esp
    while (1) {
        if (current->need_resched) {
c010af6a:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010af6f:	8b 40 10             	mov    0x10(%eax),%eax
c010af72:	85 c0                	test   %eax,%eax
c010af74:	74 f4                	je     c010af6a <cpu_idle+0x6>
            schedule();
c010af76:	e8 17 02 00 00       	call   c010b192 <schedule>
        }
    }
c010af7b:	eb ed                	jmp    c010af6a <cpu_idle+0x6>

c010af7d <lab6_set_priority>:
}

//FOR LAB6, set the process's priority (bigger value will get more CPU time) 
void
lab6_set_priority(uint32_t priority)
{
c010af7d:	55                   	push   %ebp
c010af7e:	89 e5                	mov    %esp,%ebp
    if (priority == 0)
c010af80:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010af84:	75 11                	jne    c010af97 <lab6_set_priority+0x1a>
        current->lab6_priority = 1;
c010af86:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010af8b:	c7 80 9c 00 00 00 01 	movl   $0x1,0x9c(%eax)
c010af92:	00 00 00 
    else current->lab6_priority = priority;
}
c010af95:	eb 0e                	jmp    c010afa5 <lab6_set_priority+0x28>
void
lab6_set_priority(uint32_t priority)
{
    if (priority == 0)
        current->lab6_priority = 1;
    else current->lab6_priority = priority;
c010af97:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010af9c:	8b 55 08             	mov    0x8(%ebp),%edx
c010af9f:	89 90 9c 00 00 00    	mov    %edx,0x9c(%eax)
}
c010afa5:	90                   	nop
c010afa6:	5d                   	pop    %ebp
c010afa7:	c3                   	ret    

c010afa8 <__intr_save>:
#include <assert.h>
#include <atomic.h>
#include <sched.h>

static inline bool
__intr_save(void) {
c010afa8:	55                   	push   %ebp
c010afa9:	89 e5                	mov    %esp,%ebp
c010afab:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010afae:	9c                   	pushf  
c010afaf:	58                   	pop    %eax
c010afb0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c010afb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c010afb6:	25 00 02 00 00       	and    $0x200,%eax
c010afbb:	85 c0                	test   %eax,%eax
c010afbd:	74 0c                	je     c010afcb <__intr_save+0x23>
        intr_disable();
c010afbf:	e8 31 72 ff ff       	call   c01021f5 <intr_disable>
        return 1;
c010afc4:	b8 01 00 00 00       	mov    $0x1,%eax
c010afc9:	eb 05                	jmp    c010afd0 <__intr_save+0x28>
    }
    return 0;
c010afcb:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010afd0:	c9                   	leave  
c010afd1:	c3                   	ret    

c010afd2 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c010afd2:	55                   	push   %ebp
c010afd3:	89 e5                	mov    %esp,%ebp
c010afd5:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c010afd8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010afdc:	74 05                	je     c010afe3 <__intr_restore+0x11>
        intr_enable();
c010afde:	e8 0b 72 ff ff       	call   c01021ee <intr_enable>
    }
}
c010afe3:	90                   	nop
c010afe4:	c9                   	leave  
c010afe5:	c3                   	ret    

c010afe6 <sched_class_enqueue>:
static struct sched_class *sched_class;

static struct run_queue *rq;

static inline void
sched_class_enqueue(struct proc_struct *proc) {
c010afe6:	55                   	push   %ebp
c010afe7:	89 e5                	mov    %esp,%ebp
c010afe9:	83 ec 18             	sub    $0x18,%esp
    if (proc != idleproc) {
c010afec:	a1 20 10 1b c0       	mov    0xc01b1020,%eax
c010aff1:	39 45 08             	cmp    %eax,0x8(%ebp)
c010aff4:	74 1a                	je     c010b010 <sched_class_enqueue+0x2a>
        sched_class->enqueue(rq, proc);
c010aff6:	a1 5c 30 1b c0       	mov    0xc01b305c,%eax
c010affb:	8b 40 08             	mov    0x8(%eax),%eax
c010affe:	8b 15 60 30 1b c0    	mov    0xc01b3060,%edx
c010b004:	8b 4d 08             	mov    0x8(%ebp),%ecx
c010b007:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c010b00b:	89 14 24             	mov    %edx,(%esp)
c010b00e:	ff d0                	call   *%eax
    }
}
c010b010:	90                   	nop
c010b011:	c9                   	leave  
c010b012:	c3                   	ret    

c010b013 <sched_class_dequeue>:

static inline void
sched_class_dequeue(struct proc_struct *proc) {
c010b013:	55                   	push   %ebp
c010b014:	89 e5                	mov    %esp,%ebp
c010b016:	83 ec 18             	sub    $0x18,%esp
    sched_class->dequeue(rq, proc);
c010b019:	a1 5c 30 1b c0       	mov    0xc01b305c,%eax
c010b01e:	8b 40 0c             	mov    0xc(%eax),%eax
c010b021:	8b 15 60 30 1b c0    	mov    0xc01b3060,%edx
c010b027:	8b 4d 08             	mov    0x8(%ebp),%ecx
c010b02a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c010b02e:	89 14 24             	mov    %edx,(%esp)
c010b031:	ff d0                	call   *%eax
}
c010b033:	90                   	nop
c010b034:	c9                   	leave  
c010b035:	c3                   	ret    

c010b036 <sched_class_pick_next>:

static inline struct proc_struct *
sched_class_pick_next(void) {
c010b036:	55                   	push   %ebp
c010b037:	89 e5                	mov    %esp,%ebp
c010b039:	83 ec 18             	sub    $0x18,%esp
    return sched_class->pick_next(rq);
c010b03c:	a1 5c 30 1b c0       	mov    0xc01b305c,%eax
c010b041:	8b 40 10             	mov    0x10(%eax),%eax
c010b044:	8b 15 60 30 1b c0    	mov    0xc01b3060,%edx
c010b04a:	89 14 24             	mov    %edx,(%esp)
c010b04d:	ff d0                	call   *%eax
}
c010b04f:	c9                   	leave  
c010b050:	c3                   	ret    

c010b051 <sched_class_proc_tick>:

void
sched_class_proc_tick(struct proc_struct *proc) {
c010b051:	55                   	push   %ebp
c010b052:	89 e5                	mov    %esp,%ebp
c010b054:	83 ec 18             	sub    $0x18,%esp
    if (proc != idleproc) {
c010b057:	a1 20 10 1b c0       	mov    0xc01b1020,%eax
c010b05c:	39 45 08             	cmp    %eax,0x8(%ebp)
c010b05f:	74 1c                	je     c010b07d <sched_class_proc_tick+0x2c>
        sched_class->proc_tick(rq, proc);
c010b061:	a1 5c 30 1b c0       	mov    0xc01b305c,%eax
c010b066:	8b 40 14             	mov    0x14(%eax),%eax
c010b069:	8b 15 60 30 1b c0    	mov    0xc01b3060,%edx
c010b06f:	8b 4d 08             	mov    0x8(%ebp),%ecx
c010b072:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c010b076:	89 14 24             	mov    %edx,(%esp)
c010b079:	ff d0                	call   *%eax
    }
    else {
        proc->need_resched = 1;
    }
}
c010b07b:	eb 0a                	jmp    c010b087 <sched_class_proc_tick+0x36>
sched_class_proc_tick(struct proc_struct *proc) {
    if (proc != idleproc) {
        sched_class->proc_tick(rq, proc);
    }
    else {
        proc->need_resched = 1;
c010b07d:	8b 45 08             	mov    0x8(%ebp),%eax
c010b080:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    }
}
c010b087:	90                   	nop
c010b088:	c9                   	leave  
c010b089:	c3                   	ret    

c010b08a <sched_init>:

static struct run_queue __rq;

void
sched_init(void) {
c010b08a:	55                   	push   %ebp
c010b08b:	89 e5                	mov    %esp,%ebp
c010b08d:	83 ec 28             	sub    $0x28,%esp
c010b090:	c7 45 f4 54 30 1b c0 	movl   $0xc01b3054,-0xc(%ebp)
c010b097:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b09a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010b09d:	89 50 04             	mov    %edx,0x4(%eax)
c010b0a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b0a3:	8b 50 04             	mov    0x4(%eax),%edx
c010b0a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b0a9:	89 10                	mov    %edx,(%eax)
    list_init(&timer_list);

    sched_class = &default_sched_class;
c010b0ab:	c7 05 5c 30 1b c0 80 	movl   $0xc012ca80,0xc01b305c
c010b0b2:	ca 12 c0 

    rq = &__rq;
c010b0b5:	c7 05 60 30 1b c0 64 	movl   $0xc01b3064,0xc01b3060
c010b0bc:	30 1b c0 
    rq->max_time_slice = MAX_TIME_SLICE;
c010b0bf:	a1 60 30 1b c0       	mov    0xc01b3060,%eax
c010b0c4:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
    sched_class->init(rq);
c010b0cb:	a1 5c 30 1b c0       	mov    0xc01b305c,%eax
c010b0d0:	8b 40 04             	mov    0x4(%eax),%eax
c010b0d3:	8b 15 60 30 1b c0    	mov    0xc01b3060,%edx
c010b0d9:	89 14 24             	mov    %edx,(%esp)
c010b0dc:	ff d0                	call   *%eax

    cprintf("sched class: %s\n", sched_class->name);
c010b0de:	a1 5c 30 1b c0       	mov    0xc01b305c,%eax
c010b0e3:	8b 00                	mov    (%eax),%eax
c010b0e5:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b0e9:	c7 04 24 5b e7 10 c0 	movl   $0xc010e75b,(%esp)
c010b0f0:	e8 b9 51 ff ff       	call   c01002ae <cprintf>
}
c010b0f5:	90                   	nop
c010b0f6:	c9                   	leave  
c010b0f7:	c3                   	ret    

c010b0f8 <wakeup_proc>:

void
wakeup_proc(struct proc_struct *proc) {
c010b0f8:	55                   	push   %ebp
c010b0f9:	89 e5                	mov    %esp,%ebp
c010b0fb:	83 ec 28             	sub    $0x28,%esp
    assert(proc->state != PROC_ZOMBIE);
c010b0fe:	8b 45 08             	mov    0x8(%ebp),%eax
c010b101:	8b 00                	mov    (%eax),%eax
c010b103:	83 f8 03             	cmp    $0x3,%eax
c010b106:	75 24                	jne    c010b12c <wakeup_proc+0x34>
c010b108:	c7 44 24 0c 6c e7 10 	movl   $0xc010e76c,0xc(%esp)
c010b10f:	c0 
c010b110:	c7 44 24 08 87 e7 10 	movl   $0xc010e787,0x8(%esp)
c010b117:	c0 
c010b118:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
c010b11f:	00 
c010b120:	c7 04 24 9c e7 10 c0 	movl   $0xc010e79c,(%esp)
c010b127:	e8 d9 52 ff ff       	call   c0100405 <__panic>
    bool intr_flag;
    local_intr_save(intr_flag);
c010b12c:	e8 77 fe ff ff       	call   c010afa8 <__intr_save>
c010b131:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        if (proc->state != PROC_RUNNABLE) {
c010b134:	8b 45 08             	mov    0x8(%ebp),%eax
c010b137:	8b 00                	mov    (%eax),%eax
c010b139:	83 f8 02             	cmp    $0x2,%eax
c010b13c:	74 2a                	je     c010b168 <wakeup_proc+0x70>
            proc->state = PROC_RUNNABLE;
c010b13e:	8b 45 08             	mov    0x8(%ebp),%eax
c010b141:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
            proc->wait_state = 0;
c010b147:	8b 45 08             	mov    0x8(%ebp),%eax
c010b14a:	c7 40 6c 00 00 00 00 	movl   $0x0,0x6c(%eax)
            if (proc != current) {
c010b151:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010b156:	39 45 08             	cmp    %eax,0x8(%ebp)
c010b159:	74 29                	je     c010b184 <wakeup_proc+0x8c>
                sched_class_enqueue(proc);
c010b15b:	8b 45 08             	mov    0x8(%ebp),%eax
c010b15e:	89 04 24             	mov    %eax,(%esp)
c010b161:	e8 80 fe ff ff       	call   c010afe6 <sched_class_enqueue>
c010b166:	eb 1c                	jmp    c010b184 <wakeup_proc+0x8c>
            }
        }
        else {
            warn("wakeup runnable process.\n");
c010b168:	c7 44 24 08 b2 e7 10 	movl   $0xc010e7b2,0x8(%esp)
c010b16f:	c0 
c010b170:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
c010b177:	00 
c010b178:	c7 04 24 9c e7 10 c0 	movl   $0xc010e79c,(%esp)
c010b17f:	e8 ff 52 ff ff       	call   c0100483 <__warn>
        }
    }
    local_intr_restore(intr_flag);
c010b184:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b187:	89 04 24             	mov    %eax,(%esp)
c010b18a:	e8 43 fe ff ff       	call   c010afd2 <__intr_restore>
}
c010b18f:	90                   	nop
c010b190:	c9                   	leave  
c010b191:	c3                   	ret    

c010b192 <schedule>:

void
schedule(void) {
c010b192:	55                   	push   %ebp
c010b193:	89 e5                	mov    %esp,%ebp
c010b195:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    struct proc_struct *next;
    local_intr_save(intr_flag);
c010b198:	e8 0b fe ff ff       	call   c010afa8 <__intr_save>
c010b19d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        current->need_resched = 0;
c010b1a0:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010b1a5:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        if (current->state == PROC_RUNNABLE) {
c010b1ac:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010b1b1:	8b 00                	mov    (%eax),%eax
c010b1b3:	83 f8 02             	cmp    $0x2,%eax
c010b1b6:	75 0d                	jne    c010b1c5 <schedule+0x33>
            sched_class_enqueue(current);
c010b1b8:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010b1bd:	89 04 24             	mov    %eax,(%esp)
c010b1c0:	e8 21 fe ff ff       	call   c010afe6 <sched_class_enqueue>
        }
        if ((next = sched_class_pick_next()) != NULL) {
c010b1c5:	e8 6c fe ff ff       	call   c010b036 <sched_class_pick_next>
c010b1ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b1cd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010b1d1:	74 0b                	je     c010b1de <schedule+0x4c>
            sched_class_dequeue(next);
c010b1d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b1d6:	89 04 24             	mov    %eax,(%esp)
c010b1d9:	e8 35 fe ff ff       	call   c010b013 <sched_class_dequeue>
        }
        if (next == NULL) {
c010b1de:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010b1e2:	75 08                	jne    c010b1ec <schedule+0x5a>
            next = idleproc;
c010b1e4:	a1 20 10 1b c0       	mov    0xc01b1020,%eax
c010b1e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        next->runs ++;
c010b1ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b1ef:	8b 40 08             	mov    0x8(%eax),%eax
c010b1f2:	8d 50 01             	lea    0x1(%eax),%edx
c010b1f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b1f8:	89 50 08             	mov    %edx,0x8(%eax)
        if (next != current) {
c010b1fb:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010b200:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010b203:	74 0b                	je     c010b210 <schedule+0x7e>
            proc_run(next);
c010b205:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b208:	89 04 24             	mov    %eax,(%esp)
c010b20b:	e8 8b e7 ff ff       	call   c010999b <proc_run>
        }
    }
    local_intr_restore(intr_flag);
c010b210:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b213:	89 04 24             	mov    %eax,(%esp)
c010b216:	e8 b7 fd ff ff       	call   c010afd2 <__intr_restore>
}
c010b21b:	90                   	nop
c010b21c:	c9                   	leave  
c010b21d:	c3                   	ret    

c010b21e <RR_init>:
#include <proc.h>
#include <assert.h>
#include <default_sched.h>

static void
RR_init(struct run_queue *rq) {
c010b21e:	55                   	push   %ebp
c010b21f:	89 e5                	mov    %esp,%ebp
c010b221:	83 ec 10             	sub    $0x10,%esp
    list_init(&(rq->run_list));
c010b224:	8b 45 08             	mov    0x8(%ebp),%eax
c010b227:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010b22a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b22d:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010b230:	89 50 04             	mov    %edx,0x4(%eax)
c010b233:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b236:	8b 50 04             	mov    0x4(%eax),%edx
c010b239:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b23c:	89 10                	mov    %edx,(%eax)
    rq->proc_num = 0;
c010b23e:	8b 45 08             	mov    0x8(%ebp),%eax
c010b241:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
c010b248:	90                   	nop
c010b249:	c9                   	leave  
c010b24a:	c3                   	ret    

c010b24b <RR_enqueue>:

static void
RR_enqueue(struct run_queue *rq, struct proc_struct *proc) {
c010b24b:	55                   	push   %ebp
c010b24c:	89 e5                	mov    %esp,%ebp
c010b24e:	83 ec 38             	sub    $0x38,%esp
    assert(list_empty(&(proc->run_link)));
c010b251:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b254:	83 e8 80             	sub    $0xffffff80,%eax
c010b257:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c010b25a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b25d:	8b 40 04             	mov    0x4(%eax),%eax
c010b260:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010b263:	0f 94 c0             	sete   %al
c010b266:	0f b6 c0             	movzbl %al,%eax
c010b269:	85 c0                	test   %eax,%eax
c010b26b:	75 24                	jne    c010b291 <RR_enqueue+0x46>
c010b26d:	c7 44 24 0c cc e7 10 	movl   $0xc010e7cc,0xc(%esp)
c010b274:	c0 
c010b275:	c7 44 24 08 ea e7 10 	movl   $0xc010e7ea,0x8(%esp)
c010b27c:	c0 
c010b27d:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
c010b284:	00 
c010b285:	c7 04 24 ff e7 10 c0 	movl   $0xc010e7ff,(%esp)
c010b28c:	e8 74 51 ff ff       	call   c0100405 <__panic>
    list_add_before(&(rq->run_list), &(proc->run_link));
c010b291:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b294:	8d 90 80 00 00 00    	lea    0x80(%eax),%edx
c010b29a:	8b 45 08             	mov    0x8(%ebp),%eax
c010b29d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b2a0:	89 55 ec             	mov    %edx,-0x14(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c010b2a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b2a6:	8b 00                	mov    (%eax),%eax
c010b2a8:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010b2ab:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010b2ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010b2b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b2b4:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c010b2b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b2ba:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010b2bd:	89 10                	mov    %edx,(%eax)
c010b2bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b2c2:	8b 10                	mov    (%eax),%edx
c010b2c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010b2c7:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010b2ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b2cd:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010b2d0:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010b2d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b2d6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010b2d9:	89 10                	mov    %edx,(%eax)
    if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
c010b2db:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b2de:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
c010b2e4:	85 c0                	test   %eax,%eax
c010b2e6:	74 13                	je     c010b2fb <RR_enqueue+0xb0>
c010b2e8:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b2eb:	8b 90 88 00 00 00    	mov    0x88(%eax),%edx
c010b2f1:	8b 45 08             	mov    0x8(%ebp),%eax
c010b2f4:	8b 40 0c             	mov    0xc(%eax),%eax
c010b2f7:	39 c2                	cmp    %eax,%edx
c010b2f9:	7e 0f                	jle    c010b30a <RR_enqueue+0xbf>
        proc->time_slice = rq->max_time_slice;
c010b2fb:	8b 45 08             	mov    0x8(%ebp),%eax
c010b2fe:	8b 50 0c             	mov    0xc(%eax),%edx
c010b301:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b304:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
    }
    proc->rq = rq;
c010b30a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b30d:	8b 55 08             	mov    0x8(%ebp),%edx
c010b310:	89 50 7c             	mov    %edx,0x7c(%eax)
    rq->proc_num ++;
c010b313:	8b 45 08             	mov    0x8(%ebp),%eax
c010b316:	8b 40 08             	mov    0x8(%eax),%eax
c010b319:	8d 50 01             	lea    0x1(%eax),%edx
c010b31c:	8b 45 08             	mov    0x8(%ebp),%eax
c010b31f:	89 50 08             	mov    %edx,0x8(%eax)
}
c010b322:	90                   	nop
c010b323:	c9                   	leave  
c010b324:	c3                   	ret    

c010b325 <RR_dequeue>:

static void
RR_dequeue(struct run_queue *rq, struct proc_struct *proc) {
c010b325:	55                   	push   %ebp
c010b326:	89 e5                	mov    %esp,%ebp
c010b328:	83 ec 38             	sub    $0x38,%esp
    assert(!list_empty(&(proc->run_link)) && proc->rq == rq);
c010b32b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b32e:	83 e8 80             	sub    $0xffffff80,%eax
c010b331:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c010b334:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b337:	8b 40 04             	mov    0x4(%eax),%eax
c010b33a:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010b33d:	0f 94 c0             	sete   %al
c010b340:	0f b6 c0             	movzbl %al,%eax
c010b343:	85 c0                	test   %eax,%eax
c010b345:	75 0b                	jne    c010b352 <RR_dequeue+0x2d>
c010b347:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b34a:	8b 40 7c             	mov    0x7c(%eax),%eax
c010b34d:	3b 45 08             	cmp    0x8(%ebp),%eax
c010b350:	74 24                	je     c010b376 <RR_dequeue+0x51>
c010b352:	c7 44 24 0c 20 e8 10 	movl   $0xc010e820,0xc(%esp)
c010b359:	c0 
c010b35a:	c7 44 24 08 ea e7 10 	movl   $0xc010e7ea,0x8(%esp)
c010b361:	c0 
c010b362:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
c010b369:	00 
c010b36a:	c7 04 24 ff e7 10 c0 	movl   $0xc010e7ff,(%esp)
c010b371:	e8 8f 50 ff ff       	call   c0100405 <__panic>
    list_del_init(&(proc->run_link));
c010b376:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b379:	83 e8 80             	sub    $0xffffff80,%eax
c010b37c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b37f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b382:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c010b385:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b388:	8b 40 04             	mov    0x4(%eax),%eax
c010b38b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010b38e:	8b 12                	mov    (%edx),%edx
c010b390:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010b393:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c010b396:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b399:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010b39c:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010b39f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010b3a2:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010b3a5:	89 10                	mov    %edx,(%eax)
c010b3a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b3aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010b3ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b3b0:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010b3b3:	89 50 04             	mov    %edx,0x4(%eax)
c010b3b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b3b9:	8b 50 04             	mov    0x4(%eax),%edx
c010b3bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b3bf:	89 10                	mov    %edx,(%eax)
    rq->proc_num --;
c010b3c1:	8b 45 08             	mov    0x8(%ebp),%eax
c010b3c4:	8b 40 08             	mov    0x8(%eax),%eax
c010b3c7:	8d 50 ff             	lea    -0x1(%eax),%edx
c010b3ca:	8b 45 08             	mov    0x8(%ebp),%eax
c010b3cd:	89 50 08             	mov    %edx,0x8(%eax)
}
c010b3d0:	90                   	nop
c010b3d1:	c9                   	leave  
c010b3d2:	c3                   	ret    

c010b3d3 <RR_pick_next>:

static struct proc_struct *
RR_pick_next(struct run_queue *rq) {
c010b3d3:	55                   	push   %ebp
c010b3d4:	89 e5                	mov    %esp,%ebp
c010b3d6:	83 ec 10             	sub    $0x10,%esp
    list_entry_t *le = list_next(&(rq->run_list));
c010b3d9:	8b 45 08             	mov    0x8(%ebp),%eax
c010b3dc:	89 45 f8             	mov    %eax,-0x8(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010b3df:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b3e2:	8b 40 04             	mov    0x4(%eax),%eax
c010b3e5:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (le != &(rq->run_list)) {
c010b3e8:	8b 45 08             	mov    0x8(%ebp),%eax
c010b3eb:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010b3ee:	74 08                	je     c010b3f8 <RR_pick_next+0x25>
        return le2proc(le, run_link);
c010b3f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b3f3:	83 c0 80             	add    $0xffffff80,%eax
c010b3f6:	eb 05                	jmp    c010b3fd <RR_pick_next+0x2a>
    }
    return NULL;
c010b3f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b3fd:	c9                   	leave  
c010b3fe:	c3                   	ret    

c010b3ff <RR_proc_tick>:

static void
RR_proc_tick(struct run_queue *rq, struct proc_struct *proc) {
c010b3ff:	55                   	push   %ebp
c010b400:	89 e5                	mov    %esp,%ebp
    if (proc->time_slice > 0) {
c010b402:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b405:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
c010b40b:	85 c0                	test   %eax,%eax
c010b40d:	7e 15                	jle    c010b424 <RR_proc_tick+0x25>
        proc->time_slice --;
c010b40f:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b412:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
c010b418:	8d 50 ff             	lea    -0x1(%eax),%edx
c010b41b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b41e:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
    }
    if (proc->time_slice == 0) {
c010b424:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b427:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
c010b42d:	85 c0                	test   %eax,%eax
c010b42f:	75 0a                	jne    c010b43b <RR_proc_tick+0x3c>
        proc->need_resched = 1;
c010b431:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b434:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    }
}
c010b43b:	90                   	nop
c010b43c:	5d                   	pop    %ebp
c010b43d:	c3                   	ret    

c010b43e <sys_exit>:
#include <pmm.h>
#include <assert.h>
#include <clock.h>

static int
sys_exit(uint32_t arg[]) {
c010b43e:	55                   	push   %ebp
c010b43f:	89 e5                	mov    %esp,%ebp
c010b441:	83 ec 28             	sub    $0x28,%esp
    int error_code = (int)arg[0];
c010b444:	8b 45 08             	mov    0x8(%ebp),%eax
c010b447:	8b 00                	mov    (%eax),%eax
c010b449:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return do_exit(error_code);
c010b44c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b44f:	89 04 24             	mov    %eax,(%esp)
c010b452:	e8 c6 eb ff ff       	call   c010a01d <do_exit>
}
c010b457:	c9                   	leave  
c010b458:	c3                   	ret    

c010b459 <sys_fork>:

static int
sys_fork(uint32_t arg[]) {
c010b459:	55                   	push   %ebp
c010b45a:	89 e5                	mov    %esp,%ebp
c010b45c:	83 ec 28             	sub    $0x28,%esp
    struct trapframe *tf = current->tf;
c010b45f:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010b464:	8b 40 3c             	mov    0x3c(%eax),%eax
c010b467:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uintptr_t stack = tf->tf_esp;
c010b46a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b46d:	8b 40 44             	mov    0x44(%eax),%eax
c010b470:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return do_fork(0, stack, tf);
c010b473:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b476:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b47a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b47d:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b481:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010b488:	e8 69 ea ff ff       	call   c0109ef6 <do_fork>
}
c010b48d:	c9                   	leave  
c010b48e:	c3                   	ret    

c010b48f <sys_wait>:

static int
sys_wait(uint32_t arg[]) {
c010b48f:	55                   	push   %ebp
c010b490:	89 e5                	mov    %esp,%ebp
c010b492:	83 ec 28             	sub    $0x28,%esp
    int pid = (int)arg[0];
c010b495:	8b 45 08             	mov    0x8(%ebp),%eax
c010b498:	8b 00                	mov    (%eax),%eax
c010b49a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int *store = (int *)arg[1];
c010b49d:	8b 45 08             	mov    0x8(%ebp),%eax
c010b4a0:	83 c0 04             	add    $0x4,%eax
c010b4a3:	8b 00                	mov    (%eax),%eax
c010b4a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return do_wait(pid, store);
c010b4a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b4ab:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b4af:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b4b2:	89 04 24             	mov    %eax,(%esp)
c010b4b5:	e8 df f4 ff ff       	call   c010a999 <do_wait>
}
c010b4ba:	c9                   	leave  
c010b4bb:	c3                   	ret    

c010b4bc <sys_exec>:

static int
sys_exec(uint32_t arg[]) {
c010b4bc:	55                   	push   %ebp
c010b4bd:	89 e5                	mov    %esp,%ebp
c010b4bf:	83 ec 28             	sub    $0x28,%esp
    const char *name = (const char *)arg[0];
c010b4c2:	8b 45 08             	mov    0x8(%ebp),%eax
c010b4c5:	8b 00                	mov    (%eax),%eax
c010b4c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    size_t len = (size_t)arg[1];
c010b4ca:	8b 45 08             	mov    0x8(%ebp),%eax
c010b4cd:	83 c0 04             	add    $0x4,%eax
c010b4d0:	8b 00                	mov    (%eax),%eax
c010b4d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    unsigned char *binary = (unsigned char *)arg[2];
c010b4d5:	8b 45 08             	mov    0x8(%ebp),%eax
c010b4d8:	83 c0 08             	add    $0x8,%eax
c010b4db:	8b 00                	mov    (%eax),%eax
c010b4dd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    size_t size = (size_t)arg[3];
c010b4e0:	8b 45 08             	mov    0x8(%ebp),%eax
c010b4e3:	83 c0 0c             	add    $0xc,%eax
c010b4e6:	8b 00                	mov    (%eax),%eax
c010b4e8:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return do_execve(name, len, binary, size);
c010b4eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b4ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010b4f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b4f5:	89 44 24 08          	mov    %eax,0x8(%esp)
c010b4f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b4fc:	89 44 24 04          	mov    %eax,0x4(%esp)
c010b500:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b503:	89 04 24             	mov    %eax,(%esp)
c010b506:	e8 40 f3 ff ff       	call   c010a84b <do_execve>
}
c010b50b:	c9                   	leave  
c010b50c:	c3                   	ret    

c010b50d <sys_yield>:

static int
sys_yield(uint32_t arg[]) {
c010b50d:	55                   	push   %ebp
c010b50e:	89 e5                	mov    %esp,%ebp
c010b510:	83 ec 08             	sub    $0x8,%esp
    return do_yield();
c010b513:	e8 6b f4 ff ff       	call   c010a983 <do_yield>
}
c010b518:	c9                   	leave  
c010b519:	c3                   	ret    

c010b51a <sys_kill>:

static int
sys_kill(uint32_t arg[]) {
c010b51a:	55                   	push   %ebp
c010b51b:	89 e5                	mov    %esp,%ebp
c010b51d:	83 ec 28             	sub    $0x28,%esp
    int pid = (int)arg[0];
c010b520:	8b 45 08             	mov    0x8(%ebp),%eax
c010b523:	8b 00                	mov    (%eax),%eax
c010b525:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return do_kill(pid);
c010b528:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b52b:	89 04 24             	mov    %eax,(%esp)
c010b52e:	e8 f5 f5 ff ff       	call   c010ab28 <do_kill>
}
c010b533:	c9                   	leave  
c010b534:	c3                   	ret    

c010b535 <sys_getpid>:

static int
sys_getpid(uint32_t arg[]) {
c010b535:	55                   	push   %ebp
c010b536:	89 e5                	mov    %esp,%ebp
    return current->pid;
c010b538:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010b53d:	8b 40 04             	mov    0x4(%eax),%eax
}
c010b540:	5d                   	pop    %ebp
c010b541:	c3                   	ret    

c010b542 <sys_putc>:

static int
sys_putc(uint32_t arg[]) {
c010b542:	55                   	push   %ebp
c010b543:	89 e5                	mov    %esp,%ebp
c010b545:	83 ec 28             	sub    $0x28,%esp
    int c = (int)arg[0];
c010b548:	8b 45 08             	mov    0x8(%ebp),%eax
c010b54b:	8b 00                	mov    (%eax),%eax
c010b54d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cputchar(c);
c010b550:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b553:	89 04 24             	mov    %eax,(%esp)
c010b556:	e8 79 4d ff ff       	call   c01002d4 <cputchar>
    return 0;
c010b55b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b560:	c9                   	leave  
c010b561:	c3                   	ret    

c010b562 <sys_pgdir>:

static int
sys_pgdir(uint32_t arg[]) {
c010b562:	55                   	push   %ebp
c010b563:	89 e5                	mov    %esp,%ebp
c010b565:	83 ec 08             	sub    $0x8,%esp
    print_pgdir();
c010b568:	e8 50 da ff ff       	call   c0108fbd <print_pgdir>
    return 0;
c010b56d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b572:	c9                   	leave  
c010b573:	c3                   	ret    

c010b574 <sys_gettime>:

static int
sys_gettime(uint32_t arg[]) {
c010b574:	55                   	push   %ebp
c010b575:	89 e5                	mov    %esp,%ebp
    return (int)ticks;
c010b577:	a1 78 30 1b c0       	mov    0xc01b3078,%eax
}
c010b57c:	5d                   	pop    %ebp
c010b57d:	c3                   	ret    

c010b57e <sys_lab6_set_priority>:
static int
sys_lab6_set_priority(uint32_t arg[])
{
c010b57e:	55                   	push   %ebp
c010b57f:	89 e5                	mov    %esp,%ebp
c010b581:	83 ec 28             	sub    $0x28,%esp
    uint32_t priority = (uint32_t)arg[0];
c010b584:	8b 45 08             	mov    0x8(%ebp),%eax
c010b587:	8b 00                	mov    (%eax),%eax
c010b589:	89 45 f4             	mov    %eax,-0xc(%ebp)
    lab6_set_priority(priority);
c010b58c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b58f:	89 04 24             	mov    %eax,(%esp)
c010b592:	e8 e6 f9 ff ff       	call   c010af7d <lab6_set_priority>
    return 0;
c010b597:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b59c:	c9                   	leave  
c010b59d:	c3                   	ret    

c010b59e <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
c010b59e:	55                   	push   %ebp
c010b59f:	89 e5                	mov    %esp,%ebp
c010b5a1:	83 ec 48             	sub    $0x48,%esp
    struct trapframe *tf = current->tf;
c010b5a4:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010b5a9:	8b 40 3c             	mov    0x3c(%eax),%eax
c010b5ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uint32_t arg[5];
    int num = tf->tf_regs.reg_eax;
c010b5af:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b5b2:	8b 40 1c             	mov    0x1c(%eax),%eax
c010b5b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (num >= 0 && num < NUM_SYSCALLS) {
c010b5b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010b5bc:	78 60                	js     c010b61e <syscall+0x80>
c010b5be:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b5c1:	3d ff 00 00 00       	cmp    $0xff,%eax
c010b5c6:	77 56                	ja     c010b61e <syscall+0x80>
        if (syscalls[num] != NULL) {
c010b5c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b5cb:	8b 04 85 a0 ca 12 c0 	mov    -0x3fed3560(,%eax,4),%eax
c010b5d2:	85 c0                	test   %eax,%eax
c010b5d4:	74 48                	je     c010b61e <syscall+0x80>
            arg[0] = tf->tf_regs.reg_edx;
c010b5d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b5d9:	8b 40 14             	mov    0x14(%eax),%eax
c010b5dc:	89 45 dc             	mov    %eax,-0x24(%ebp)
            arg[1] = tf->tf_regs.reg_ecx;
c010b5df:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b5e2:	8b 40 18             	mov    0x18(%eax),%eax
c010b5e5:	89 45 e0             	mov    %eax,-0x20(%ebp)
            arg[2] = tf->tf_regs.reg_ebx;
c010b5e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b5eb:	8b 40 10             	mov    0x10(%eax),%eax
c010b5ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            arg[3] = tf->tf_regs.reg_edi;
c010b5f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b5f4:	8b 00                	mov    (%eax),%eax
c010b5f6:	89 45 e8             	mov    %eax,-0x18(%ebp)
            arg[4] = tf->tf_regs.reg_esi;
c010b5f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b5fc:	8b 40 04             	mov    0x4(%eax),%eax
c010b5ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
            tf->tf_regs.reg_eax = syscalls[num](arg);
c010b602:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b605:	8b 04 85 a0 ca 12 c0 	mov    -0x3fed3560(,%eax,4),%eax
c010b60c:	8d 55 dc             	lea    -0x24(%ebp),%edx
c010b60f:	89 14 24             	mov    %edx,(%esp)
c010b612:	ff d0                	call   *%eax
c010b614:	89 c2                	mov    %eax,%edx
c010b616:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b619:	89 50 1c             	mov    %edx,0x1c(%eax)
            return ;
c010b61c:	eb 46                	jmp    c010b664 <syscall+0xc6>
        }
    }
    print_trapframe(tf);
c010b61e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b621:	89 04 24             	mov    %eax,(%esp)
c010b624:	e8 a6 6d ff ff       	call   c01023cf <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
c010b629:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010b62e:	8d 50 48             	lea    0x48(%eax),%edx
c010b631:	a1 28 10 1b c0       	mov    0xc01b1028,%eax
c010b636:	8b 40 04             	mov    0x4(%eax),%eax
c010b639:	89 54 24 14          	mov    %edx,0x14(%esp)
c010b63d:	89 44 24 10          	mov    %eax,0x10(%esp)
c010b641:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b644:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010b648:	c7 44 24 08 60 e8 10 	movl   $0xc010e860,0x8(%esp)
c010b64f:	c0 
c010b650:	c7 44 24 04 72 00 00 	movl   $0x72,0x4(%esp)
c010b657:	00 
c010b658:	c7 04 24 8c e8 10 c0 	movl   $0xc010e88c,(%esp)
c010b65f:	e8 a1 4d ff ff       	call   c0100405 <__panic>
            num, current->pid, current->name);
}
c010b664:	c9                   	leave  
c010b665:	c3                   	ret    

c010b666 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c010b666:	55                   	push   %ebp
c010b667:	89 e5                	mov    %esp,%ebp
c010b669:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c010b66c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c010b673:	eb 03                	jmp    c010b678 <strlen+0x12>
        cnt ++;
c010b675:	ff 45 fc             	incl   -0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
c010b678:	8b 45 08             	mov    0x8(%ebp),%eax
c010b67b:	8d 50 01             	lea    0x1(%eax),%edx
c010b67e:	89 55 08             	mov    %edx,0x8(%ebp)
c010b681:	0f b6 00             	movzbl (%eax),%eax
c010b684:	84 c0                	test   %al,%al
c010b686:	75 ed                	jne    c010b675 <strlen+0xf>
        cnt ++;
    }
    return cnt;
c010b688:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010b68b:	c9                   	leave  
c010b68c:	c3                   	ret    

c010b68d <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c010b68d:	55                   	push   %ebp
c010b68e:	89 e5                	mov    %esp,%ebp
c010b690:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c010b693:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c010b69a:	eb 03                	jmp    c010b69f <strnlen+0x12>
        cnt ++;
c010b69c:	ff 45 fc             	incl   -0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
c010b69f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b6a2:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010b6a5:	73 10                	jae    c010b6b7 <strnlen+0x2a>
c010b6a7:	8b 45 08             	mov    0x8(%ebp),%eax
c010b6aa:	8d 50 01             	lea    0x1(%eax),%edx
c010b6ad:	89 55 08             	mov    %edx,0x8(%ebp)
c010b6b0:	0f b6 00             	movzbl (%eax),%eax
c010b6b3:	84 c0                	test   %al,%al
c010b6b5:	75 e5                	jne    c010b69c <strnlen+0xf>
        cnt ++;
    }
    return cnt;
c010b6b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010b6ba:	c9                   	leave  
c010b6bb:	c3                   	ret    

c010b6bc <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c010b6bc:	55                   	push   %ebp
c010b6bd:	89 e5                	mov    %esp,%ebp
c010b6bf:	57                   	push   %edi
c010b6c0:	56                   	push   %esi
c010b6c1:	83 ec 20             	sub    $0x20,%esp
c010b6c4:	8b 45 08             	mov    0x8(%ebp),%eax
c010b6c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b6ca:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b6cd:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c010b6d0:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010b6d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b6d6:	89 d1                	mov    %edx,%ecx
c010b6d8:	89 c2                	mov    %eax,%edx
c010b6da:	89 ce                	mov    %ecx,%esi
c010b6dc:	89 d7                	mov    %edx,%edi
c010b6de:	ac                   	lods   %ds:(%esi),%al
c010b6df:	aa                   	stos   %al,%es:(%edi)
c010b6e0:	84 c0                	test   %al,%al
c010b6e2:	75 fa                	jne    c010b6de <strcpy+0x22>
c010b6e4:	89 fa                	mov    %edi,%edx
c010b6e6:	89 f1                	mov    %esi,%ecx
c010b6e8:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010b6eb:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010b6ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c010b6f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
c010b6f4:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c010b6f5:	83 c4 20             	add    $0x20,%esp
c010b6f8:	5e                   	pop    %esi
c010b6f9:	5f                   	pop    %edi
c010b6fa:	5d                   	pop    %ebp
c010b6fb:	c3                   	ret    

c010b6fc <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c010b6fc:	55                   	push   %ebp
c010b6fd:	89 e5                	mov    %esp,%ebp
c010b6ff:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c010b702:	8b 45 08             	mov    0x8(%ebp),%eax
c010b705:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c010b708:	eb 1e                	jmp    c010b728 <strncpy+0x2c>
        if ((*p = *src) != '\0') {
c010b70a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b70d:	0f b6 10             	movzbl (%eax),%edx
c010b710:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b713:	88 10                	mov    %dl,(%eax)
c010b715:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b718:	0f b6 00             	movzbl (%eax),%eax
c010b71b:	84 c0                	test   %al,%al
c010b71d:	74 03                	je     c010b722 <strncpy+0x26>
            src ++;
c010b71f:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
c010b722:	ff 45 fc             	incl   -0x4(%ebp)
c010b725:	ff 4d 10             	decl   0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
c010b728:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b72c:	75 dc                	jne    c010b70a <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
c010b72e:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010b731:	c9                   	leave  
c010b732:	c3                   	ret    

c010b733 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c010b733:	55                   	push   %ebp
c010b734:	89 e5                	mov    %esp,%ebp
c010b736:	57                   	push   %edi
c010b737:	56                   	push   %esi
c010b738:	83 ec 20             	sub    $0x20,%esp
c010b73b:	8b 45 08             	mov    0x8(%ebp),%eax
c010b73e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b741:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b744:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
c010b747:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010b74a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b74d:	89 d1                	mov    %edx,%ecx
c010b74f:	89 c2                	mov    %eax,%edx
c010b751:	89 ce                	mov    %ecx,%esi
c010b753:	89 d7                	mov    %edx,%edi
c010b755:	ac                   	lods   %ds:(%esi),%al
c010b756:	ae                   	scas   %es:(%edi),%al
c010b757:	75 08                	jne    c010b761 <strcmp+0x2e>
c010b759:	84 c0                	test   %al,%al
c010b75b:	75 f8                	jne    c010b755 <strcmp+0x22>
c010b75d:	31 c0                	xor    %eax,%eax
c010b75f:	eb 04                	jmp    c010b765 <strcmp+0x32>
c010b761:	19 c0                	sbb    %eax,%eax
c010b763:	0c 01                	or     $0x1,%al
c010b765:	89 fa                	mov    %edi,%edx
c010b767:	89 f1                	mov    %esi,%ecx
c010b769:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010b76c:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010b76f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
c010b772:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
c010b775:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c010b776:	83 c4 20             	add    $0x20,%esp
c010b779:	5e                   	pop    %esi
c010b77a:	5f                   	pop    %edi
c010b77b:	5d                   	pop    %ebp
c010b77c:	c3                   	ret    

c010b77d <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c010b77d:	55                   	push   %ebp
c010b77e:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010b780:	eb 09                	jmp    c010b78b <strncmp+0xe>
        n --, s1 ++, s2 ++;
c010b782:	ff 4d 10             	decl   0x10(%ebp)
c010b785:	ff 45 08             	incl   0x8(%ebp)
c010b788:	ff 45 0c             	incl   0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010b78b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b78f:	74 1a                	je     c010b7ab <strncmp+0x2e>
c010b791:	8b 45 08             	mov    0x8(%ebp),%eax
c010b794:	0f b6 00             	movzbl (%eax),%eax
c010b797:	84 c0                	test   %al,%al
c010b799:	74 10                	je     c010b7ab <strncmp+0x2e>
c010b79b:	8b 45 08             	mov    0x8(%ebp),%eax
c010b79e:	0f b6 10             	movzbl (%eax),%edx
c010b7a1:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b7a4:	0f b6 00             	movzbl (%eax),%eax
c010b7a7:	38 c2                	cmp    %al,%dl
c010b7a9:	74 d7                	je     c010b782 <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c010b7ab:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b7af:	74 18                	je     c010b7c9 <strncmp+0x4c>
c010b7b1:	8b 45 08             	mov    0x8(%ebp),%eax
c010b7b4:	0f b6 00             	movzbl (%eax),%eax
c010b7b7:	0f b6 d0             	movzbl %al,%edx
c010b7ba:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b7bd:	0f b6 00             	movzbl (%eax),%eax
c010b7c0:	0f b6 c0             	movzbl %al,%eax
c010b7c3:	29 c2                	sub    %eax,%edx
c010b7c5:	89 d0                	mov    %edx,%eax
c010b7c7:	eb 05                	jmp    c010b7ce <strncmp+0x51>
c010b7c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b7ce:	5d                   	pop    %ebp
c010b7cf:	c3                   	ret    

c010b7d0 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c010b7d0:	55                   	push   %ebp
c010b7d1:	89 e5                	mov    %esp,%ebp
c010b7d3:	83 ec 04             	sub    $0x4,%esp
c010b7d6:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b7d9:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010b7dc:	eb 13                	jmp    c010b7f1 <strchr+0x21>
        if (*s == c) {
c010b7de:	8b 45 08             	mov    0x8(%ebp),%eax
c010b7e1:	0f b6 00             	movzbl (%eax),%eax
c010b7e4:	3a 45 fc             	cmp    -0x4(%ebp),%al
c010b7e7:	75 05                	jne    c010b7ee <strchr+0x1e>
            return (char *)s;
c010b7e9:	8b 45 08             	mov    0x8(%ebp),%eax
c010b7ec:	eb 12                	jmp    c010b800 <strchr+0x30>
        }
        s ++;
c010b7ee:	ff 45 08             	incl   0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
c010b7f1:	8b 45 08             	mov    0x8(%ebp),%eax
c010b7f4:	0f b6 00             	movzbl (%eax),%eax
c010b7f7:	84 c0                	test   %al,%al
c010b7f9:	75 e3                	jne    c010b7de <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
c010b7fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b800:	c9                   	leave  
c010b801:	c3                   	ret    

c010b802 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c010b802:	55                   	push   %ebp
c010b803:	89 e5                	mov    %esp,%ebp
c010b805:	83 ec 04             	sub    $0x4,%esp
c010b808:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b80b:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010b80e:	eb 0e                	jmp    c010b81e <strfind+0x1c>
        if (*s == c) {
c010b810:	8b 45 08             	mov    0x8(%ebp),%eax
c010b813:	0f b6 00             	movzbl (%eax),%eax
c010b816:	3a 45 fc             	cmp    -0x4(%ebp),%al
c010b819:	74 0f                	je     c010b82a <strfind+0x28>
            break;
        }
        s ++;
c010b81b:	ff 45 08             	incl   0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
c010b81e:	8b 45 08             	mov    0x8(%ebp),%eax
c010b821:	0f b6 00             	movzbl (%eax),%eax
c010b824:	84 c0                	test   %al,%al
c010b826:	75 e8                	jne    c010b810 <strfind+0xe>
c010b828:	eb 01                	jmp    c010b82b <strfind+0x29>
        if (*s == c) {
            break;
c010b82a:	90                   	nop
        }
        s ++;
    }
    return (char *)s;
c010b82b:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010b82e:	c9                   	leave  
c010b82f:	c3                   	ret    

c010b830 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c010b830:	55                   	push   %ebp
c010b831:	89 e5                	mov    %esp,%ebp
c010b833:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c010b836:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c010b83d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c010b844:	eb 03                	jmp    c010b849 <strtol+0x19>
        s ++;
c010b846:	ff 45 08             	incl   0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c010b849:	8b 45 08             	mov    0x8(%ebp),%eax
c010b84c:	0f b6 00             	movzbl (%eax),%eax
c010b84f:	3c 20                	cmp    $0x20,%al
c010b851:	74 f3                	je     c010b846 <strtol+0x16>
c010b853:	8b 45 08             	mov    0x8(%ebp),%eax
c010b856:	0f b6 00             	movzbl (%eax),%eax
c010b859:	3c 09                	cmp    $0x9,%al
c010b85b:	74 e9                	je     c010b846 <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
c010b85d:	8b 45 08             	mov    0x8(%ebp),%eax
c010b860:	0f b6 00             	movzbl (%eax),%eax
c010b863:	3c 2b                	cmp    $0x2b,%al
c010b865:	75 05                	jne    c010b86c <strtol+0x3c>
        s ++;
c010b867:	ff 45 08             	incl   0x8(%ebp)
c010b86a:	eb 14                	jmp    c010b880 <strtol+0x50>
    }
    else if (*s == '-') {
c010b86c:	8b 45 08             	mov    0x8(%ebp),%eax
c010b86f:	0f b6 00             	movzbl (%eax),%eax
c010b872:	3c 2d                	cmp    $0x2d,%al
c010b874:	75 0a                	jne    c010b880 <strtol+0x50>
        s ++, neg = 1;
c010b876:	ff 45 08             	incl   0x8(%ebp)
c010b879:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c010b880:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b884:	74 06                	je     c010b88c <strtol+0x5c>
c010b886:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c010b88a:	75 22                	jne    c010b8ae <strtol+0x7e>
c010b88c:	8b 45 08             	mov    0x8(%ebp),%eax
c010b88f:	0f b6 00             	movzbl (%eax),%eax
c010b892:	3c 30                	cmp    $0x30,%al
c010b894:	75 18                	jne    c010b8ae <strtol+0x7e>
c010b896:	8b 45 08             	mov    0x8(%ebp),%eax
c010b899:	40                   	inc    %eax
c010b89a:	0f b6 00             	movzbl (%eax),%eax
c010b89d:	3c 78                	cmp    $0x78,%al
c010b89f:	75 0d                	jne    c010b8ae <strtol+0x7e>
        s += 2, base = 16;
c010b8a1:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c010b8a5:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c010b8ac:	eb 29                	jmp    c010b8d7 <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
c010b8ae:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b8b2:	75 16                	jne    c010b8ca <strtol+0x9a>
c010b8b4:	8b 45 08             	mov    0x8(%ebp),%eax
c010b8b7:	0f b6 00             	movzbl (%eax),%eax
c010b8ba:	3c 30                	cmp    $0x30,%al
c010b8bc:	75 0c                	jne    c010b8ca <strtol+0x9a>
        s ++, base = 8;
c010b8be:	ff 45 08             	incl   0x8(%ebp)
c010b8c1:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c010b8c8:	eb 0d                	jmp    c010b8d7 <strtol+0xa7>
    }
    else if (base == 0) {
c010b8ca:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b8ce:	75 07                	jne    c010b8d7 <strtol+0xa7>
        base = 10;
c010b8d0:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c010b8d7:	8b 45 08             	mov    0x8(%ebp),%eax
c010b8da:	0f b6 00             	movzbl (%eax),%eax
c010b8dd:	3c 2f                	cmp    $0x2f,%al
c010b8df:	7e 1b                	jle    c010b8fc <strtol+0xcc>
c010b8e1:	8b 45 08             	mov    0x8(%ebp),%eax
c010b8e4:	0f b6 00             	movzbl (%eax),%eax
c010b8e7:	3c 39                	cmp    $0x39,%al
c010b8e9:	7f 11                	jg     c010b8fc <strtol+0xcc>
            dig = *s - '0';
c010b8eb:	8b 45 08             	mov    0x8(%ebp),%eax
c010b8ee:	0f b6 00             	movzbl (%eax),%eax
c010b8f1:	0f be c0             	movsbl %al,%eax
c010b8f4:	83 e8 30             	sub    $0x30,%eax
c010b8f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b8fa:	eb 48                	jmp    c010b944 <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
c010b8fc:	8b 45 08             	mov    0x8(%ebp),%eax
c010b8ff:	0f b6 00             	movzbl (%eax),%eax
c010b902:	3c 60                	cmp    $0x60,%al
c010b904:	7e 1b                	jle    c010b921 <strtol+0xf1>
c010b906:	8b 45 08             	mov    0x8(%ebp),%eax
c010b909:	0f b6 00             	movzbl (%eax),%eax
c010b90c:	3c 7a                	cmp    $0x7a,%al
c010b90e:	7f 11                	jg     c010b921 <strtol+0xf1>
            dig = *s - 'a' + 10;
c010b910:	8b 45 08             	mov    0x8(%ebp),%eax
c010b913:	0f b6 00             	movzbl (%eax),%eax
c010b916:	0f be c0             	movsbl %al,%eax
c010b919:	83 e8 57             	sub    $0x57,%eax
c010b91c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b91f:	eb 23                	jmp    c010b944 <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c010b921:	8b 45 08             	mov    0x8(%ebp),%eax
c010b924:	0f b6 00             	movzbl (%eax),%eax
c010b927:	3c 40                	cmp    $0x40,%al
c010b929:	7e 3b                	jle    c010b966 <strtol+0x136>
c010b92b:	8b 45 08             	mov    0x8(%ebp),%eax
c010b92e:	0f b6 00             	movzbl (%eax),%eax
c010b931:	3c 5a                	cmp    $0x5a,%al
c010b933:	7f 31                	jg     c010b966 <strtol+0x136>
            dig = *s - 'A' + 10;
c010b935:	8b 45 08             	mov    0x8(%ebp),%eax
c010b938:	0f b6 00             	movzbl (%eax),%eax
c010b93b:	0f be c0             	movsbl %al,%eax
c010b93e:	83 e8 37             	sub    $0x37,%eax
c010b941:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c010b944:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b947:	3b 45 10             	cmp    0x10(%ebp),%eax
c010b94a:	7d 19                	jge    c010b965 <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
c010b94c:	ff 45 08             	incl   0x8(%ebp)
c010b94f:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b952:	0f af 45 10          	imul   0x10(%ebp),%eax
c010b956:	89 c2                	mov    %eax,%edx
c010b958:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b95b:	01 d0                	add    %edx,%eax
c010b95d:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
c010b960:	e9 72 ff ff ff       	jmp    c010b8d7 <strtol+0xa7>
        }
        else {
            break;
        }
        if (dig >= base) {
            break;
c010b965:	90                   	nop
        }
        s ++, val = (val * base) + dig;
        // we don't properly detect overflow!
    }

    if (endptr) {
c010b966:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010b96a:	74 08                	je     c010b974 <strtol+0x144>
        *endptr = (char *) s;
c010b96c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b96f:	8b 55 08             	mov    0x8(%ebp),%edx
c010b972:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c010b974:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010b978:	74 07                	je     c010b981 <strtol+0x151>
c010b97a:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b97d:	f7 d8                	neg    %eax
c010b97f:	eb 03                	jmp    c010b984 <strtol+0x154>
c010b981:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c010b984:	c9                   	leave  
c010b985:	c3                   	ret    

c010b986 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c010b986:	55                   	push   %ebp
c010b987:	89 e5                	mov    %esp,%ebp
c010b989:	57                   	push   %edi
c010b98a:	83 ec 24             	sub    $0x24,%esp
c010b98d:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b990:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c010b993:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c010b997:	8b 55 08             	mov    0x8(%ebp),%edx
c010b99a:	89 55 f8             	mov    %edx,-0x8(%ebp)
c010b99d:	88 45 f7             	mov    %al,-0x9(%ebp)
c010b9a0:	8b 45 10             	mov    0x10(%ebp),%eax
c010b9a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c010b9a6:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c010b9a9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c010b9ad:	8b 55 f8             	mov    -0x8(%ebp),%edx
c010b9b0:	89 d7                	mov    %edx,%edi
c010b9b2:	f3 aa                	rep stos %al,%es:(%edi)
c010b9b4:	89 fa                	mov    %edi,%edx
c010b9b6:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010b9b9:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c010b9bc:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b9bf:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c010b9c0:	83 c4 24             	add    $0x24,%esp
c010b9c3:	5f                   	pop    %edi
c010b9c4:	5d                   	pop    %ebp
c010b9c5:	c3                   	ret    

c010b9c6 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c010b9c6:	55                   	push   %ebp
c010b9c7:	89 e5                	mov    %esp,%ebp
c010b9c9:	57                   	push   %edi
c010b9ca:	56                   	push   %esi
c010b9cb:	53                   	push   %ebx
c010b9cc:	83 ec 30             	sub    $0x30,%esp
c010b9cf:	8b 45 08             	mov    0x8(%ebp),%eax
c010b9d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b9d5:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b9d8:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010b9db:	8b 45 10             	mov    0x10(%ebp),%eax
c010b9de:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c010b9e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b9e4:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010b9e7:	73 42                	jae    c010ba2b <memmove+0x65>
c010b9e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b9ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010b9ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b9f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010b9f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b9f8:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010b9fb:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010b9fe:	c1 e8 02             	shr    $0x2,%eax
c010ba01:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c010ba03:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010ba06:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010ba09:	89 d7                	mov    %edx,%edi
c010ba0b:	89 c6                	mov    %eax,%esi
c010ba0d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010ba0f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c010ba12:	83 e1 03             	and    $0x3,%ecx
c010ba15:	74 02                	je     c010ba19 <memmove+0x53>
c010ba17:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010ba19:	89 f0                	mov    %esi,%eax
c010ba1b:	89 fa                	mov    %edi,%edx
c010ba1d:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c010ba20:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010ba23:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c010ba26:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
c010ba29:	eb 36                	jmp    c010ba61 <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c010ba2b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010ba2e:	8d 50 ff             	lea    -0x1(%eax),%edx
c010ba31:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010ba34:	01 c2                	add    %eax,%edx
c010ba36:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010ba39:	8d 48 ff             	lea    -0x1(%eax),%ecx
c010ba3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010ba3f:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
c010ba42:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010ba45:	89 c1                	mov    %eax,%ecx
c010ba47:	89 d8                	mov    %ebx,%eax
c010ba49:	89 d6                	mov    %edx,%esi
c010ba4b:	89 c7                	mov    %eax,%edi
c010ba4d:	fd                   	std    
c010ba4e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010ba50:	fc                   	cld    
c010ba51:	89 f8                	mov    %edi,%eax
c010ba53:	89 f2                	mov    %esi,%edx
c010ba55:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c010ba58:	89 55 c8             	mov    %edx,-0x38(%ebp)
c010ba5b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
c010ba5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c010ba61:	83 c4 30             	add    $0x30,%esp
c010ba64:	5b                   	pop    %ebx
c010ba65:	5e                   	pop    %esi
c010ba66:	5f                   	pop    %edi
c010ba67:	5d                   	pop    %ebp
c010ba68:	c3                   	ret    

c010ba69 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c010ba69:	55                   	push   %ebp
c010ba6a:	89 e5                	mov    %esp,%ebp
c010ba6c:	57                   	push   %edi
c010ba6d:	56                   	push   %esi
c010ba6e:	83 ec 20             	sub    $0x20,%esp
c010ba71:	8b 45 08             	mov    0x8(%ebp),%eax
c010ba74:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010ba77:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ba7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010ba7d:	8b 45 10             	mov    0x10(%ebp),%eax
c010ba80:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010ba83:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010ba86:	c1 e8 02             	shr    $0x2,%eax
c010ba89:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c010ba8b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010ba8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010ba91:	89 d7                	mov    %edx,%edi
c010ba93:	89 c6                	mov    %eax,%esi
c010ba95:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010ba97:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c010ba9a:	83 e1 03             	and    $0x3,%ecx
c010ba9d:	74 02                	je     c010baa1 <memcpy+0x38>
c010ba9f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010baa1:	89 f0                	mov    %esi,%eax
c010baa3:	89 fa                	mov    %edi,%edx
c010baa5:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010baa8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010baab:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c010baae:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
c010bab1:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c010bab2:	83 c4 20             	add    $0x20,%esp
c010bab5:	5e                   	pop    %esi
c010bab6:	5f                   	pop    %edi
c010bab7:	5d                   	pop    %ebp
c010bab8:	c3                   	ret    

c010bab9 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c010bab9:	55                   	push   %ebp
c010baba:	89 e5                	mov    %esp,%ebp
c010babc:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c010babf:	8b 45 08             	mov    0x8(%ebp),%eax
c010bac2:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c010bac5:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bac8:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c010bacb:	eb 2e                	jmp    c010bafb <memcmp+0x42>
        if (*s1 != *s2) {
c010bacd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010bad0:	0f b6 10             	movzbl (%eax),%edx
c010bad3:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010bad6:	0f b6 00             	movzbl (%eax),%eax
c010bad9:	38 c2                	cmp    %al,%dl
c010badb:	74 18                	je     c010baf5 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c010badd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010bae0:	0f b6 00             	movzbl (%eax),%eax
c010bae3:	0f b6 d0             	movzbl %al,%edx
c010bae6:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010bae9:	0f b6 00             	movzbl (%eax),%eax
c010baec:	0f b6 c0             	movzbl %al,%eax
c010baef:	29 c2                	sub    %eax,%edx
c010baf1:	89 d0                	mov    %edx,%eax
c010baf3:	eb 18                	jmp    c010bb0d <memcmp+0x54>
        }
        s1 ++, s2 ++;
c010baf5:	ff 45 fc             	incl   -0x4(%ebp)
c010baf8:	ff 45 f8             	incl   -0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
c010bafb:	8b 45 10             	mov    0x10(%ebp),%eax
c010bafe:	8d 50 ff             	lea    -0x1(%eax),%edx
c010bb01:	89 55 10             	mov    %edx,0x10(%ebp)
c010bb04:	85 c0                	test   %eax,%eax
c010bb06:	75 c5                	jne    c010bacd <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
c010bb08:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010bb0d:	c9                   	leave  
c010bb0e:	c3                   	ret    

c010bb0f <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c010bb0f:	55                   	push   %ebp
c010bb10:	89 e5                	mov    %esp,%ebp
c010bb12:	83 ec 58             	sub    $0x58,%esp
c010bb15:	8b 45 10             	mov    0x10(%ebp),%eax
c010bb18:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010bb1b:	8b 45 14             	mov    0x14(%ebp),%eax
c010bb1e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c010bb21:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010bb24:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010bb27:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010bb2a:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c010bb2d:	8b 45 18             	mov    0x18(%ebp),%eax
c010bb30:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010bb33:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010bb36:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010bb39:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010bb3c:	89 55 f0             	mov    %edx,-0x10(%ebp)
c010bb3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bb42:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010bb45:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010bb49:	74 1c                	je     c010bb67 <printnum+0x58>
c010bb4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bb4e:	ba 00 00 00 00       	mov    $0x0,%edx
c010bb53:	f7 75 e4             	divl   -0x1c(%ebp)
c010bb56:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010bb59:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bb5c:	ba 00 00 00 00       	mov    $0x0,%edx
c010bb61:	f7 75 e4             	divl   -0x1c(%ebp)
c010bb64:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bb67:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010bb6a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010bb6d:	f7 75 e4             	divl   -0x1c(%ebp)
c010bb70:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010bb73:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010bb76:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010bb79:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010bb7c:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010bb7f:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010bb82:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010bb85:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c010bb88:	8b 45 18             	mov    0x18(%ebp),%eax
c010bb8b:	ba 00 00 00 00       	mov    $0x0,%edx
c010bb90:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010bb93:	77 56                	ja     c010bbeb <printnum+0xdc>
c010bb95:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010bb98:	72 05                	jb     c010bb9f <printnum+0x90>
c010bb9a:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c010bb9d:	77 4c                	ja     c010bbeb <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c010bb9f:	8b 45 1c             	mov    0x1c(%ebp),%eax
c010bba2:	8d 50 ff             	lea    -0x1(%eax),%edx
c010bba5:	8b 45 20             	mov    0x20(%ebp),%eax
c010bba8:	89 44 24 18          	mov    %eax,0x18(%esp)
c010bbac:	89 54 24 14          	mov    %edx,0x14(%esp)
c010bbb0:	8b 45 18             	mov    0x18(%ebp),%eax
c010bbb3:	89 44 24 10          	mov    %eax,0x10(%esp)
c010bbb7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010bbba:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010bbbd:	89 44 24 08          	mov    %eax,0x8(%esp)
c010bbc1:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010bbc5:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bbc8:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bbcc:	8b 45 08             	mov    0x8(%ebp),%eax
c010bbcf:	89 04 24             	mov    %eax,(%esp)
c010bbd2:	e8 38 ff ff ff       	call   c010bb0f <printnum>
c010bbd7:	eb 1b                	jmp    c010bbf4 <printnum+0xe5>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c010bbd9:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bbdc:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bbe0:	8b 45 20             	mov    0x20(%ebp),%eax
c010bbe3:	89 04 24             	mov    %eax,(%esp)
c010bbe6:	8b 45 08             	mov    0x8(%ebp),%eax
c010bbe9:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
c010bbeb:	ff 4d 1c             	decl   0x1c(%ebp)
c010bbee:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c010bbf2:	7f e5                	jg     c010bbd9 <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c010bbf4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010bbf7:	05 c4 e9 10 c0       	add    $0xc010e9c4,%eax
c010bbfc:	0f b6 00             	movzbl (%eax),%eax
c010bbff:	0f be c0             	movsbl %al,%eax
c010bc02:	8b 55 0c             	mov    0xc(%ebp),%edx
c010bc05:	89 54 24 04          	mov    %edx,0x4(%esp)
c010bc09:	89 04 24             	mov    %eax,(%esp)
c010bc0c:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc0f:	ff d0                	call   *%eax
}
c010bc11:	90                   	nop
c010bc12:	c9                   	leave  
c010bc13:	c3                   	ret    

c010bc14 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c010bc14:	55                   	push   %ebp
c010bc15:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010bc17:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010bc1b:	7e 14                	jle    c010bc31 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c010bc1d:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc20:	8b 00                	mov    (%eax),%eax
c010bc22:	8d 48 08             	lea    0x8(%eax),%ecx
c010bc25:	8b 55 08             	mov    0x8(%ebp),%edx
c010bc28:	89 0a                	mov    %ecx,(%edx)
c010bc2a:	8b 50 04             	mov    0x4(%eax),%edx
c010bc2d:	8b 00                	mov    (%eax),%eax
c010bc2f:	eb 30                	jmp    c010bc61 <getuint+0x4d>
    }
    else if (lflag) {
c010bc31:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010bc35:	74 16                	je     c010bc4d <getuint+0x39>
        return va_arg(*ap, unsigned long);
c010bc37:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc3a:	8b 00                	mov    (%eax),%eax
c010bc3c:	8d 48 04             	lea    0x4(%eax),%ecx
c010bc3f:	8b 55 08             	mov    0x8(%ebp),%edx
c010bc42:	89 0a                	mov    %ecx,(%edx)
c010bc44:	8b 00                	mov    (%eax),%eax
c010bc46:	ba 00 00 00 00       	mov    $0x0,%edx
c010bc4b:	eb 14                	jmp    c010bc61 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c010bc4d:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc50:	8b 00                	mov    (%eax),%eax
c010bc52:	8d 48 04             	lea    0x4(%eax),%ecx
c010bc55:	8b 55 08             	mov    0x8(%ebp),%edx
c010bc58:	89 0a                	mov    %ecx,(%edx)
c010bc5a:	8b 00                	mov    (%eax),%eax
c010bc5c:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c010bc61:	5d                   	pop    %ebp
c010bc62:	c3                   	ret    

c010bc63 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c010bc63:	55                   	push   %ebp
c010bc64:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010bc66:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010bc6a:	7e 14                	jle    c010bc80 <getint+0x1d>
        return va_arg(*ap, long long);
c010bc6c:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc6f:	8b 00                	mov    (%eax),%eax
c010bc71:	8d 48 08             	lea    0x8(%eax),%ecx
c010bc74:	8b 55 08             	mov    0x8(%ebp),%edx
c010bc77:	89 0a                	mov    %ecx,(%edx)
c010bc79:	8b 50 04             	mov    0x4(%eax),%edx
c010bc7c:	8b 00                	mov    (%eax),%eax
c010bc7e:	eb 28                	jmp    c010bca8 <getint+0x45>
    }
    else if (lflag) {
c010bc80:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010bc84:	74 12                	je     c010bc98 <getint+0x35>
        return va_arg(*ap, long);
c010bc86:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc89:	8b 00                	mov    (%eax),%eax
c010bc8b:	8d 48 04             	lea    0x4(%eax),%ecx
c010bc8e:	8b 55 08             	mov    0x8(%ebp),%edx
c010bc91:	89 0a                	mov    %ecx,(%edx)
c010bc93:	8b 00                	mov    (%eax),%eax
c010bc95:	99                   	cltd   
c010bc96:	eb 10                	jmp    c010bca8 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c010bc98:	8b 45 08             	mov    0x8(%ebp),%eax
c010bc9b:	8b 00                	mov    (%eax),%eax
c010bc9d:	8d 48 04             	lea    0x4(%eax),%ecx
c010bca0:	8b 55 08             	mov    0x8(%ebp),%edx
c010bca3:	89 0a                	mov    %ecx,(%edx)
c010bca5:	8b 00                	mov    (%eax),%eax
c010bca7:	99                   	cltd   
    }
}
c010bca8:	5d                   	pop    %ebp
c010bca9:	c3                   	ret    

c010bcaa <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c010bcaa:	55                   	push   %ebp
c010bcab:	89 e5                	mov    %esp,%ebp
c010bcad:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c010bcb0:	8d 45 14             	lea    0x14(%ebp),%eax
c010bcb3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c010bcb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010bcb9:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010bcbd:	8b 45 10             	mov    0x10(%ebp),%eax
c010bcc0:	89 44 24 08          	mov    %eax,0x8(%esp)
c010bcc4:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bcc7:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bccb:	8b 45 08             	mov    0x8(%ebp),%eax
c010bcce:	89 04 24             	mov    %eax,(%esp)
c010bcd1:	e8 03 00 00 00       	call   c010bcd9 <vprintfmt>
    va_end(ap);
}
c010bcd6:	90                   	nop
c010bcd7:	c9                   	leave  
c010bcd8:	c3                   	ret    

c010bcd9 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c010bcd9:	55                   	push   %ebp
c010bcda:	89 e5                	mov    %esp,%ebp
c010bcdc:	56                   	push   %esi
c010bcdd:	53                   	push   %ebx
c010bcde:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010bce1:	eb 17                	jmp    c010bcfa <vprintfmt+0x21>
            if (ch == '\0') {
c010bce3:	85 db                	test   %ebx,%ebx
c010bce5:	0f 84 bf 03 00 00    	je     c010c0aa <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
c010bceb:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bcee:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bcf2:	89 1c 24             	mov    %ebx,(%esp)
c010bcf5:	8b 45 08             	mov    0x8(%ebp),%eax
c010bcf8:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010bcfa:	8b 45 10             	mov    0x10(%ebp),%eax
c010bcfd:	8d 50 01             	lea    0x1(%eax),%edx
c010bd00:	89 55 10             	mov    %edx,0x10(%ebp)
c010bd03:	0f b6 00             	movzbl (%eax),%eax
c010bd06:	0f b6 d8             	movzbl %al,%ebx
c010bd09:	83 fb 25             	cmp    $0x25,%ebx
c010bd0c:	75 d5                	jne    c010bce3 <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
c010bd0e:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c010bd12:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c010bd19:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010bd1c:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c010bd1f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010bd26:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010bd29:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c010bd2c:	8b 45 10             	mov    0x10(%ebp),%eax
c010bd2f:	8d 50 01             	lea    0x1(%eax),%edx
c010bd32:	89 55 10             	mov    %edx,0x10(%ebp)
c010bd35:	0f b6 00             	movzbl (%eax),%eax
c010bd38:	0f b6 d8             	movzbl %al,%ebx
c010bd3b:	8d 43 dd             	lea    -0x23(%ebx),%eax
c010bd3e:	83 f8 55             	cmp    $0x55,%eax
c010bd41:	0f 87 37 03 00 00    	ja     c010c07e <vprintfmt+0x3a5>
c010bd47:	8b 04 85 e8 e9 10 c0 	mov    -0x3fef1618(,%eax,4),%eax
c010bd4e:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c010bd50:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c010bd54:	eb d6                	jmp    c010bd2c <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c010bd56:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c010bd5a:	eb d0                	jmp    c010bd2c <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c010bd5c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c010bd63:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010bd66:	89 d0                	mov    %edx,%eax
c010bd68:	c1 e0 02             	shl    $0x2,%eax
c010bd6b:	01 d0                	add    %edx,%eax
c010bd6d:	01 c0                	add    %eax,%eax
c010bd6f:	01 d8                	add    %ebx,%eax
c010bd71:	83 e8 30             	sub    $0x30,%eax
c010bd74:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c010bd77:	8b 45 10             	mov    0x10(%ebp),%eax
c010bd7a:	0f b6 00             	movzbl (%eax),%eax
c010bd7d:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c010bd80:	83 fb 2f             	cmp    $0x2f,%ebx
c010bd83:	7e 38                	jle    c010bdbd <vprintfmt+0xe4>
c010bd85:	83 fb 39             	cmp    $0x39,%ebx
c010bd88:	7f 33                	jg     c010bdbd <vprintfmt+0xe4>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c010bd8a:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
c010bd8d:	eb d4                	jmp    c010bd63 <vprintfmt+0x8a>
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c010bd8f:	8b 45 14             	mov    0x14(%ebp),%eax
c010bd92:	8d 50 04             	lea    0x4(%eax),%edx
c010bd95:	89 55 14             	mov    %edx,0x14(%ebp)
c010bd98:	8b 00                	mov    (%eax),%eax
c010bd9a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c010bd9d:	eb 1f                	jmp    c010bdbe <vprintfmt+0xe5>

        case '.':
            if (width < 0)
c010bd9f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010bda3:	79 87                	jns    c010bd2c <vprintfmt+0x53>
                width = 0;
c010bda5:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c010bdac:	e9 7b ff ff ff       	jmp    c010bd2c <vprintfmt+0x53>

        case '#':
            altflag = 1;
c010bdb1:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c010bdb8:	e9 6f ff ff ff       	jmp    c010bd2c <vprintfmt+0x53>
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
            goto process_precision;
c010bdbd:	90                   	nop
        case '#':
            altflag = 1;
            goto reswitch;

        process_precision:
            if (width < 0)
c010bdbe:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010bdc2:	0f 89 64 ff ff ff    	jns    c010bd2c <vprintfmt+0x53>
                width = precision, precision = -1;
c010bdc8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010bdcb:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010bdce:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c010bdd5:	e9 52 ff ff ff       	jmp    c010bd2c <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c010bdda:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
c010bddd:	e9 4a ff ff ff       	jmp    c010bd2c <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c010bde2:	8b 45 14             	mov    0x14(%ebp),%eax
c010bde5:	8d 50 04             	lea    0x4(%eax),%edx
c010bde8:	89 55 14             	mov    %edx,0x14(%ebp)
c010bdeb:	8b 00                	mov    (%eax),%eax
c010bded:	8b 55 0c             	mov    0xc(%ebp),%edx
c010bdf0:	89 54 24 04          	mov    %edx,0x4(%esp)
c010bdf4:	89 04 24             	mov    %eax,(%esp)
c010bdf7:	8b 45 08             	mov    0x8(%ebp),%eax
c010bdfa:	ff d0                	call   *%eax
            break;
c010bdfc:	e9 a4 02 00 00       	jmp    c010c0a5 <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
c010be01:	8b 45 14             	mov    0x14(%ebp),%eax
c010be04:	8d 50 04             	lea    0x4(%eax),%edx
c010be07:	89 55 14             	mov    %edx,0x14(%ebp)
c010be0a:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c010be0c:	85 db                	test   %ebx,%ebx
c010be0e:	79 02                	jns    c010be12 <vprintfmt+0x139>
                err = -err;
c010be10:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c010be12:	83 fb 18             	cmp    $0x18,%ebx
c010be15:	7f 0b                	jg     c010be22 <vprintfmt+0x149>
c010be17:	8b 34 9d 60 e9 10 c0 	mov    -0x3fef16a0(,%ebx,4),%esi
c010be1e:	85 f6                	test   %esi,%esi
c010be20:	75 23                	jne    c010be45 <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
c010be22:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c010be26:	c7 44 24 08 d5 e9 10 	movl   $0xc010e9d5,0x8(%esp)
c010be2d:	c0 
c010be2e:	8b 45 0c             	mov    0xc(%ebp),%eax
c010be31:	89 44 24 04          	mov    %eax,0x4(%esp)
c010be35:	8b 45 08             	mov    0x8(%ebp),%eax
c010be38:	89 04 24             	mov    %eax,(%esp)
c010be3b:	e8 6a fe ff ff       	call   c010bcaa <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c010be40:	e9 60 02 00 00       	jmp    c010c0a5 <vprintfmt+0x3cc>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
c010be45:	89 74 24 0c          	mov    %esi,0xc(%esp)
c010be49:	c7 44 24 08 de e9 10 	movl   $0xc010e9de,0x8(%esp)
c010be50:	c0 
c010be51:	8b 45 0c             	mov    0xc(%ebp),%eax
c010be54:	89 44 24 04          	mov    %eax,0x4(%esp)
c010be58:	8b 45 08             	mov    0x8(%ebp),%eax
c010be5b:	89 04 24             	mov    %eax,(%esp)
c010be5e:	e8 47 fe ff ff       	call   c010bcaa <printfmt>
            }
            break;
c010be63:	e9 3d 02 00 00       	jmp    c010c0a5 <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c010be68:	8b 45 14             	mov    0x14(%ebp),%eax
c010be6b:	8d 50 04             	lea    0x4(%eax),%edx
c010be6e:	89 55 14             	mov    %edx,0x14(%ebp)
c010be71:	8b 30                	mov    (%eax),%esi
c010be73:	85 f6                	test   %esi,%esi
c010be75:	75 05                	jne    c010be7c <vprintfmt+0x1a3>
                p = "(null)";
c010be77:	be e1 e9 10 c0       	mov    $0xc010e9e1,%esi
            }
            if (width > 0 && padc != '-') {
c010be7c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010be80:	7e 76                	jle    c010bef8 <vprintfmt+0x21f>
c010be82:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c010be86:	74 70                	je     c010bef8 <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
c010be88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010be8b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010be8f:	89 34 24             	mov    %esi,(%esp)
c010be92:	e8 f6 f7 ff ff       	call   c010b68d <strnlen>
c010be97:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010be9a:	29 c2                	sub    %eax,%edx
c010be9c:	89 d0                	mov    %edx,%eax
c010be9e:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010bea1:	eb 16                	jmp    c010beb9 <vprintfmt+0x1e0>
                    putch(padc, putdat);
c010bea3:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c010bea7:	8b 55 0c             	mov    0xc(%ebp),%edx
c010beaa:	89 54 24 04          	mov    %edx,0x4(%esp)
c010beae:	89 04 24             	mov    %eax,(%esp)
c010beb1:	8b 45 08             	mov    0x8(%ebp),%eax
c010beb4:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
c010beb6:	ff 4d e8             	decl   -0x18(%ebp)
c010beb9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010bebd:	7f e4                	jg     c010bea3 <vprintfmt+0x1ca>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010bebf:	eb 37                	jmp    c010bef8 <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
c010bec1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010bec5:	74 1f                	je     c010bee6 <vprintfmt+0x20d>
c010bec7:	83 fb 1f             	cmp    $0x1f,%ebx
c010beca:	7e 05                	jle    c010bed1 <vprintfmt+0x1f8>
c010becc:	83 fb 7e             	cmp    $0x7e,%ebx
c010becf:	7e 15                	jle    c010bee6 <vprintfmt+0x20d>
                    putch('?', putdat);
c010bed1:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bed4:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bed8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c010bedf:	8b 45 08             	mov    0x8(%ebp),%eax
c010bee2:	ff d0                	call   *%eax
c010bee4:	eb 0f                	jmp    c010bef5 <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
c010bee6:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bee9:	89 44 24 04          	mov    %eax,0x4(%esp)
c010beed:	89 1c 24             	mov    %ebx,(%esp)
c010bef0:	8b 45 08             	mov    0x8(%ebp),%eax
c010bef3:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010bef5:	ff 4d e8             	decl   -0x18(%ebp)
c010bef8:	89 f0                	mov    %esi,%eax
c010befa:	8d 70 01             	lea    0x1(%eax),%esi
c010befd:	0f b6 00             	movzbl (%eax),%eax
c010bf00:	0f be d8             	movsbl %al,%ebx
c010bf03:	85 db                	test   %ebx,%ebx
c010bf05:	74 27                	je     c010bf2e <vprintfmt+0x255>
c010bf07:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010bf0b:	78 b4                	js     c010bec1 <vprintfmt+0x1e8>
c010bf0d:	ff 4d e4             	decl   -0x1c(%ebp)
c010bf10:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010bf14:	79 ab                	jns    c010bec1 <vprintfmt+0x1e8>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c010bf16:	eb 16                	jmp    c010bf2e <vprintfmt+0x255>
                putch(' ', putdat);
c010bf18:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bf1b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bf1f:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010bf26:	8b 45 08             	mov    0x8(%ebp),%eax
c010bf29:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c010bf2b:	ff 4d e8             	decl   -0x18(%ebp)
c010bf2e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010bf32:	7f e4                	jg     c010bf18 <vprintfmt+0x23f>
                putch(' ', putdat);
            }
            break;
c010bf34:	e9 6c 01 00 00       	jmp    c010c0a5 <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c010bf39:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010bf3c:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bf40:	8d 45 14             	lea    0x14(%ebp),%eax
c010bf43:	89 04 24             	mov    %eax,(%esp)
c010bf46:	e8 18 fd ff ff       	call   c010bc63 <getint>
c010bf4b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bf4e:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c010bf51:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bf54:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010bf57:	85 d2                	test   %edx,%edx
c010bf59:	79 26                	jns    c010bf81 <vprintfmt+0x2a8>
                putch('-', putdat);
c010bf5b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bf5e:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bf62:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c010bf69:	8b 45 08             	mov    0x8(%ebp),%eax
c010bf6c:	ff d0                	call   *%eax
                num = -(long long)num;
c010bf6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010bf71:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010bf74:	f7 d8                	neg    %eax
c010bf76:	83 d2 00             	adc    $0x0,%edx
c010bf79:	f7 da                	neg    %edx
c010bf7b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bf7e:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c010bf81:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010bf88:	e9 a8 00 00 00       	jmp    c010c035 <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c010bf8d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010bf90:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bf94:	8d 45 14             	lea    0x14(%ebp),%eax
c010bf97:	89 04 24             	mov    %eax,(%esp)
c010bf9a:	e8 75 fc ff ff       	call   c010bc14 <getuint>
c010bf9f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bfa2:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c010bfa5:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010bfac:	e9 84 00 00 00       	jmp    c010c035 <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c010bfb1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010bfb4:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bfb8:	8d 45 14             	lea    0x14(%ebp),%eax
c010bfbb:	89 04 24             	mov    %eax,(%esp)
c010bfbe:	e8 51 fc ff ff       	call   c010bc14 <getuint>
c010bfc3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010bfc6:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c010bfc9:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c010bfd0:	eb 63                	jmp    c010c035 <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
c010bfd2:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bfd5:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bfd9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c010bfe0:	8b 45 08             	mov    0x8(%ebp),%eax
c010bfe3:	ff d0                	call   *%eax
            putch('x', putdat);
c010bfe5:	8b 45 0c             	mov    0xc(%ebp),%eax
c010bfe8:	89 44 24 04          	mov    %eax,0x4(%esp)
c010bfec:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c010bff3:	8b 45 08             	mov    0x8(%ebp),%eax
c010bff6:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c010bff8:	8b 45 14             	mov    0x14(%ebp),%eax
c010bffb:	8d 50 04             	lea    0x4(%eax),%edx
c010bffe:	89 55 14             	mov    %edx,0x14(%ebp)
c010c001:	8b 00                	mov    (%eax),%eax
c010c003:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010c006:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c010c00d:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c010c014:	eb 1f                	jmp    c010c035 <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c010c016:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010c019:	89 44 24 04          	mov    %eax,0x4(%esp)
c010c01d:	8d 45 14             	lea    0x14(%ebp),%eax
c010c020:	89 04 24             	mov    %eax,(%esp)
c010c023:	e8 ec fb ff ff       	call   c010bc14 <getuint>
c010c028:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010c02b:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c010c02e:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c010c035:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c010c039:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010c03c:	89 54 24 18          	mov    %edx,0x18(%esp)
c010c040:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010c043:	89 54 24 14          	mov    %edx,0x14(%esp)
c010c047:	89 44 24 10          	mov    %eax,0x10(%esp)
c010c04b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010c04e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010c051:	89 44 24 08          	mov    %eax,0x8(%esp)
c010c055:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010c059:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c05c:	89 44 24 04          	mov    %eax,0x4(%esp)
c010c060:	8b 45 08             	mov    0x8(%ebp),%eax
c010c063:	89 04 24             	mov    %eax,(%esp)
c010c066:	e8 a4 fa ff ff       	call   c010bb0f <printnum>
            break;
c010c06b:	eb 38                	jmp    c010c0a5 <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c010c06d:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c070:	89 44 24 04          	mov    %eax,0x4(%esp)
c010c074:	89 1c 24             	mov    %ebx,(%esp)
c010c077:	8b 45 08             	mov    0x8(%ebp),%eax
c010c07a:	ff d0                	call   *%eax
            break;
c010c07c:	eb 27                	jmp    c010c0a5 <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c010c07e:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c081:	89 44 24 04          	mov    %eax,0x4(%esp)
c010c085:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c010c08c:	8b 45 08             	mov    0x8(%ebp),%eax
c010c08f:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c010c091:	ff 4d 10             	decl   0x10(%ebp)
c010c094:	eb 03                	jmp    c010c099 <vprintfmt+0x3c0>
c010c096:	ff 4d 10             	decl   0x10(%ebp)
c010c099:	8b 45 10             	mov    0x10(%ebp),%eax
c010c09c:	48                   	dec    %eax
c010c09d:	0f b6 00             	movzbl (%eax),%eax
c010c0a0:	3c 25                	cmp    $0x25,%al
c010c0a2:	75 f2                	jne    c010c096 <vprintfmt+0x3bd>
                /* do nothing */;
            break;
c010c0a4:	90                   	nop
        }
    }
c010c0a5:	e9 37 fc ff ff       	jmp    c010bce1 <vprintfmt+0x8>
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
            if (ch == '\0') {
                return;
c010c0aa:	90                   	nop
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
c010c0ab:	83 c4 40             	add    $0x40,%esp
c010c0ae:	5b                   	pop    %ebx
c010c0af:	5e                   	pop    %esi
c010c0b0:	5d                   	pop    %ebp
c010c0b1:	c3                   	ret    

c010c0b2 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c010c0b2:	55                   	push   %ebp
c010c0b3:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c010c0b5:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c0b8:	8b 40 08             	mov    0x8(%eax),%eax
c010c0bb:	8d 50 01             	lea    0x1(%eax),%edx
c010c0be:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c0c1:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c010c0c4:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c0c7:	8b 10                	mov    (%eax),%edx
c010c0c9:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c0cc:	8b 40 04             	mov    0x4(%eax),%eax
c010c0cf:	39 c2                	cmp    %eax,%edx
c010c0d1:	73 12                	jae    c010c0e5 <sprintputch+0x33>
        *b->buf ++ = ch;
c010c0d3:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c0d6:	8b 00                	mov    (%eax),%eax
c010c0d8:	8d 48 01             	lea    0x1(%eax),%ecx
c010c0db:	8b 55 0c             	mov    0xc(%ebp),%edx
c010c0de:	89 0a                	mov    %ecx,(%edx)
c010c0e0:	8b 55 08             	mov    0x8(%ebp),%edx
c010c0e3:	88 10                	mov    %dl,(%eax)
    }
}
c010c0e5:	90                   	nop
c010c0e6:	5d                   	pop    %ebp
c010c0e7:	c3                   	ret    

c010c0e8 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c010c0e8:	55                   	push   %ebp
c010c0e9:	89 e5                	mov    %esp,%ebp
c010c0eb:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010c0ee:	8d 45 14             	lea    0x14(%ebp),%eax
c010c0f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c010c0f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010c0f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010c0fb:	8b 45 10             	mov    0x10(%ebp),%eax
c010c0fe:	89 44 24 08          	mov    %eax,0x8(%esp)
c010c102:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c105:	89 44 24 04          	mov    %eax,0x4(%esp)
c010c109:	8b 45 08             	mov    0x8(%ebp),%eax
c010c10c:	89 04 24             	mov    %eax,(%esp)
c010c10f:	e8 08 00 00 00       	call   c010c11c <vsnprintf>
c010c114:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c010c117:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010c11a:	c9                   	leave  
c010c11b:	c3                   	ret    

c010c11c <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c010c11c:	55                   	push   %ebp
c010c11d:	89 e5                	mov    %esp,%ebp
c010c11f:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c010c122:	8b 45 08             	mov    0x8(%ebp),%eax
c010c125:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010c128:	8b 45 0c             	mov    0xc(%ebp),%eax
c010c12b:	8d 50 ff             	lea    -0x1(%eax),%edx
c010c12e:	8b 45 08             	mov    0x8(%ebp),%eax
c010c131:	01 d0                	add    %edx,%eax
c010c133:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010c136:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c010c13d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010c141:	74 0a                	je     c010c14d <vsnprintf+0x31>
c010c143:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010c146:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010c149:	39 c2                	cmp    %eax,%edx
c010c14b:	76 07                	jbe    c010c154 <vsnprintf+0x38>
        return -E_INVAL;
c010c14d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010c152:	eb 2a                	jmp    c010c17e <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c010c154:	8b 45 14             	mov    0x14(%ebp),%eax
c010c157:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010c15b:	8b 45 10             	mov    0x10(%ebp),%eax
c010c15e:	89 44 24 08          	mov    %eax,0x8(%esp)
c010c162:	8d 45 ec             	lea    -0x14(%ebp),%eax
c010c165:	89 44 24 04          	mov    %eax,0x4(%esp)
c010c169:	c7 04 24 b2 c0 10 c0 	movl   $0xc010c0b2,(%esp)
c010c170:	e8 64 fb ff ff       	call   c010bcd9 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c010c175:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010c178:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c010c17b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010c17e:	c9                   	leave  
c010c17f:	c3                   	ret    

c010c180 <hash32>:
 * @bits:   the number of bits in a return value
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
c010c180:	55                   	push   %ebp
c010c181:	89 e5                	mov    %esp,%ebp
c010c183:	83 ec 10             	sub    $0x10,%esp
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
c010c186:	8b 45 08             	mov    0x8(%ebp),%eax
c010c189:	69 c0 01 00 37 9e    	imul   $0x9e370001,%eax,%eax
c010c18f:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (hash >> (32 - bits));
c010c192:	b8 20 00 00 00       	mov    $0x20,%eax
c010c197:	2b 45 0c             	sub    0xc(%ebp),%eax
c010c19a:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010c19d:	88 c1                	mov    %al,%cl
c010c19f:	d3 ea                	shr    %cl,%edx
c010c1a1:	89 d0                	mov    %edx,%eax
}
c010c1a3:	c9                   	leave  
c010c1a4:	c3                   	ret    

c010c1a5 <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
c010c1a5:	55                   	push   %ebp
c010c1a6:	89 e5                	mov    %esp,%ebp
c010c1a8:	57                   	push   %edi
c010c1a9:	56                   	push   %esi
c010c1aa:	53                   	push   %ebx
c010c1ab:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
c010c1ae:	a1 a0 ce 12 c0       	mov    0xc012cea0,%eax
c010c1b3:	8b 15 a4 ce 12 c0    	mov    0xc012cea4,%edx
c010c1b9:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
c010c1bf:	6b f0 05             	imul   $0x5,%eax,%esi
c010c1c2:	01 fe                	add    %edi,%esi
c010c1c4:	bf 6d e6 ec de       	mov    $0xdeece66d,%edi
c010c1c9:	f7 e7                	mul    %edi
c010c1cb:	01 d6                	add    %edx,%esi
c010c1cd:	89 f2                	mov    %esi,%edx
c010c1cf:	83 c0 0b             	add    $0xb,%eax
c010c1d2:	83 d2 00             	adc    $0x0,%edx
c010c1d5:	89 c7                	mov    %eax,%edi
c010c1d7:	83 e7 ff             	and    $0xffffffff,%edi
c010c1da:	89 f9                	mov    %edi,%ecx
c010c1dc:	0f b7 da             	movzwl %dx,%ebx
c010c1df:	89 0d a0 ce 12 c0    	mov    %ecx,0xc012cea0
c010c1e5:	89 1d a4 ce 12 c0    	mov    %ebx,0xc012cea4
    unsigned long long result = (next >> 12);
c010c1eb:	a1 a0 ce 12 c0       	mov    0xc012cea0,%eax
c010c1f0:	8b 15 a4 ce 12 c0    	mov    0xc012cea4,%edx
c010c1f6:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c010c1fa:	c1 ea 0c             	shr    $0xc,%edx
c010c1fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010c200:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
c010c203:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
c010c20a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010c20d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010c210:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010c213:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010c216:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010c219:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010c21c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010c220:	74 1c                	je     c010c23e <rand+0x99>
c010c222:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010c225:	ba 00 00 00 00       	mov    $0x0,%edx
c010c22a:	f7 75 dc             	divl   -0x24(%ebp)
c010c22d:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010c230:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010c233:	ba 00 00 00 00       	mov    $0x0,%edx
c010c238:	f7 75 dc             	divl   -0x24(%ebp)
c010c23b:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010c23e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010c241:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010c244:	f7 75 dc             	divl   -0x24(%ebp)
c010c247:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010c24a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010c24d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010c250:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010c253:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010c256:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010c259:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
c010c25c:	83 c4 24             	add    $0x24,%esp
c010c25f:	5b                   	pop    %ebx
c010c260:	5e                   	pop    %esi
c010c261:	5f                   	pop    %edi
c010c262:	5d                   	pop    %ebp
c010c263:	c3                   	ret    

c010c264 <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
c010c264:	55                   	push   %ebp
c010c265:	89 e5                	mov    %esp,%ebp
    next = seed;
c010c267:	8b 45 08             	mov    0x8(%ebp),%eax
c010c26a:	ba 00 00 00 00       	mov    $0x0,%edx
c010c26f:	a3 a0 ce 12 c0       	mov    %eax,0xc012cea0
c010c274:	89 15 a4 ce 12 c0    	mov    %edx,0xc012cea4
}
c010c27a:	90                   	nop
c010c27b:	5d                   	pop    %ebp
c010c27c:	c3                   	ret    
