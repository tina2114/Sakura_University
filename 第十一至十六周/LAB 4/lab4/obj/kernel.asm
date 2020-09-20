
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:
.text
.globl kern_entry
kern_entry:
    # reload temperate gdt (second time) to remap all physical memory
    # virtual_addr 0~4G=linear_addr&physical_addr -KERNBASE~4G-KERNBASE 
    lgdt REALLOC(__gdtdesc)
c0100000:	0f 01 15 18 70 12 00 	lgdtl  0x127018
    movl $KERNEL_DS, %eax
c0100007:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c010000c:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c010000e:	8e c0                	mov    %eax,%es
    movw %ax, %ss
c0100010:	8e d0                	mov    %eax,%ss

    ljmp $KERNEL_CS, $relocated
c0100012:	ea 19 00 10 c0 08 00 	ljmp   $0x8,$0xc0100019

c0100019 <relocated>:

relocated:

    # set ebp, esp
    movl $0x0, %ebp
c0100019:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010001e:	bc 00 70 12 c0       	mov    $0xc0127000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
c0100023:	e8 02 00 00 00       	call   c010002a <kern_init>

c0100028 <spin>:

# should never get here
spin:
    jmp spin
c0100028:	eb fe                	jmp    c0100028 <spin>

c010002a <kern_init>:
int kern_init(void) __attribute__((noreturn));

static void lab1_switch_test(void);

int
kern_init(void) {
c010002a:	55                   	push   %ebp
c010002b:	89 e5                	mov    %esp,%ebp
c010002d:	83 ec 18             	sub    $0x18,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c0100030:	ba ec ab 12 c0       	mov    $0xc012abec,%edx
c0100035:	b8 88 7a 12 c0       	mov    $0xc0127a88,%eax
c010003a:	29 c2                	sub    %eax,%edx
c010003c:	89 d0                	mov    %edx,%eax
c010003e:	83 ec 04             	sub    $0x4,%esp
c0100041:	50                   	push   %eax
c0100042:	6a 00                	push   $0x0
c0100044:	68 88 7a 12 c0       	push   $0xc0127a88
c0100049:	e8 0a a1 00 00       	call   c010a158 <memset>
c010004e:	83 c4 10             	add    $0x10,%esp

    cons_init();                // init the console
c0100051:	e8 1c 31 00 00       	call   c0103172 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100056:	c7 45 f4 00 aa 10 c0 	movl   $0xc010aa00,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010005d:	83 ec 08             	sub    $0x8,%esp
c0100060:	ff 75 f4             	pushl  -0xc(%ebp)
c0100063:	68 1c aa 10 c0       	push   $0xc010aa1c
c0100068:	e8 11 02 00 00       	call   c010027e <cprintf>
c010006d:	83 c4 10             	add    $0x10,%esp

    print_kerninfo();
c0100070:	e8 0b 1c 00 00       	call   c0101c80 <print_kerninfo>

    grade_backtrace();
c0100075:	e8 8b 00 00 00       	call   c0100105 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010007a:	e8 17 81 00 00       	call   c0108196 <pmm_init>

    pic_init();                 // init interrupt controller
c010007f:	e8 60 32 00 00       	call   c01032e4 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100084:	e8 c1 33 00 00       	call   c010344a <idt_init>

    vmm_init();                 // init virtual memory management
c0100089:	e8 61 48 00 00       	call   c01048ef <vmm_init>
    proc_init();                // init process table
c010008e:	e8 93 9a 00 00       	call   c0109b26 <proc_init>
    
    ide_init();                 // init ide devices
c0100093:	e8 a9 20 00 00       	call   c0102141 <ide_init>
    swap_init();                // init swap
c0100098:	e8 11 51 00 00       	call   c01051ae <swap_init>

    clock_init();               // init clock interrupt
c010009d:	e8 77 28 00 00       	call   c0102919 <clock_init>
    intr_enable();              // enable irq interrupt
c01000a2:	e8 7a 33 00 00       	call   c0103421 <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();
    
    cpu_idle();                 // run idle process
c01000a7:	e8 1a 9c 00 00       	call   c0109cc6 <cpu_idle>

c01000ac <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000ac:	55                   	push   %ebp
c01000ad:	89 e5                	mov    %esp,%ebp
c01000af:	83 ec 08             	sub    $0x8,%esp
    mon_backtrace(0, NULL, NULL);
c01000b2:	83 ec 04             	sub    $0x4,%esp
c01000b5:	6a 00                	push   $0x0
c01000b7:	6a 00                	push   $0x0
c01000b9:	6a 00                	push   $0x0
c01000bb:	e8 15 20 00 00       	call   c01020d5 <mon_backtrace>
c01000c0:	83 c4 10             	add    $0x10,%esp
}
c01000c3:	90                   	nop
c01000c4:	c9                   	leave  
c01000c5:	c3                   	ret    

c01000c6 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000c6:	55                   	push   %ebp
c01000c7:	89 e5                	mov    %esp,%ebp
c01000c9:	53                   	push   %ebx
c01000ca:	83 ec 04             	sub    $0x4,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000cd:	8d 4d 0c             	lea    0xc(%ebp),%ecx
c01000d0:	8b 55 0c             	mov    0xc(%ebp),%edx
c01000d3:	8d 5d 08             	lea    0x8(%ebp),%ebx
c01000d6:	8b 45 08             	mov    0x8(%ebp),%eax
c01000d9:	51                   	push   %ecx
c01000da:	52                   	push   %edx
c01000db:	53                   	push   %ebx
c01000dc:	50                   	push   %eax
c01000dd:	e8 ca ff ff ff       	call   c01000ac <grade_backtrace2>
c01000e2:	83 c4 10             	add    $0x10,%esp
}
c01000e5:	90                   	nop
c01000e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01000e9:	c9                   	leave  
c01000ea:	c3                   	ret    

c01000eb <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c01000eb:	55                   	push   %ebp
c01000ec:	89 e5                	mov    %esp,%ebp
c01000ee:	83 ec 08             	sub    $0x8,%esp
    grade_backtrace1(arg0, arg2);
c01000f1:	83 ec 08             	sub    $0x8,%esp
c01000f4:	ff 75 10             	pushl  0x10(%ebp)
c01000f7:	ff 75 08             	pushl  0x8(%ebp)
c01000fa:	e8 c7 ff ff ff       	call   c01000c6 <grade_backtrace1>
c01000ff:	83 c4 10             	add    $0x10,%esp
}
c0100102:	90                   	nop
c0100103:	c9                   	leave  
c0100104:	c3                   	ret    

c0100105 <grade_backtrace>:

void
grade_backtrace(void) {
c0100105:	55                   	push   %ebp
c0100106:	89 e5                	mov    %esp,%ebp
c0100108:	83 ec 08             	sub    $0x8,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c010010b:	b8 2a 00 10 c0       	mov    $0xc010002a,%eax
c0100110:	83 ec 04             	sub    $0x4,%esp
c0100113:	68 00 00 ff ff       	push   $0xffff0000
c0100118:	50                   	push   %eax
c0100119:	6a 00                	push   $0x0
c010011b:	e8 cb ff ff ff       	call   c01000eb <grade_backtrace0>
c0100120:	83 c4 10             	add    $0x10,%esp
}
c0100123:	90                   	nop
c0100124:	c9                   	leave  
c0100125:	c3                   	ret    

c0100126 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c0100126:	55                   	push   %ebp
c0100127:	89 e5                	mov    %esp,%ebp
c0100129:	83 ec 18             	sub    $0x18,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c010012c:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c010012f:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c0100132:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100135:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c0100138:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010013c:	0f b7 c0             	movzwl %ax,%eax
c010013f:	83 e0 03             	and    $0x3,%eax
c0100142:	89 c2                	mov    %eax,%edx
c0100144:	a1 a0 7a 12 c0       	mov    0xc0127aa0,%eax
c0100149:	83 ec 04             	sub    $0x4,%esp
c010014c:	52                   	push   %edx
c010014d:	50                   	push   %eax
c010014e:	68 21 aa 10 c0       	push   $0xc010aa21
c0100153:	e8 26 01 00 00       	call   c010027e <cprintf>
c0100158:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  cs = %x\n", round, reg1);
c010015b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010015f:	0f b7 d0             	movzwl %ax,%edx
c0100162:	a1 a0 7a 12 c0       	mov    0xc0127aa0,%eax
c0100167:	83 ec 04             	sub    $0x4,%esp
c010016a:	52                   	push   %edx
c010016b:	50                   	push   %eax
c010016c:	68 2f aa 10 c0       	push   $0xc010aa2f
c0100171:	e8 08 01 00 00       	call   c010027e <cprintf>
c0100176:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  ds = %x\n", round, reg2);
c0100179:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c010017d:	0f b7 d0             	movzwl %ax,%edx
c0100180:	a1 a0 7a 12 c0       	mov    0xc0127aa0,%eax
c0100185:	83 ec 04             	sub    $0x4,%esp
c0100188:	52                   	push   %edx
c0100189:	50                   	push   %eax
c010018a:	68 3d aa 10 c0       	push   $0xc010aa3d
c010018f:	e8 ea 00 00 00       	call   c010027e <cprintf>
c0100194:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  es = %x\n", round, reg3);
c0100197:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010019b:	0f b7 d0             	movzwl %ax,%edx
c010019e:	a1 a0 7a 12 c0       	mov    0xc0127aa0,%eax
c01001a3:	83 ec 04             	sub    $0x4,%esp
c01001a6:	52                   	push   %edx
c01001a7:	50                   	push   %eax
c01001a8:	68 4b aa 10 c0       	push   $0xc010aa4b
c01001ad:	e8 cc 00 00 00       	call   c010027e <cprintf>
c01001b2:	83 c4 10             	add    $0x10,%esp
    cprintf("%d:  ss = %x\n", round, reg4);
c01001b5:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001b9:	0f b7 d0             	movzwl %ax,%edx
c01001bc:	a1 a0 7a 12 c0       	mov    0xc0127aa0,%eax
c01001c1:	83 ec 04             	sub    $0x4,%esp
c01001c4:	52                   	push   %edx
c01001c5:	50                   	push   %eax
c01001c6:	68 59 aa 10 c0       	push   $0xc010aa59
c01001cb:	e8 ae 00 00 00       	call   c010027e <cprintf>
c01001d0:	83 c4 10             	add    $0x10,%esp
    round ++;
c01001d3:	a1 a0 7a 12 c0       	mov    0xc0127aa0,%eax
c01001d8:	83 c0 01             	add    $0x1,%eax
c01001db:	a3 a0 7a 12 c0       	mov    %eax,0xc0127aa0
}
c01001e0:	90                   	nop
c01001e1:	c9                   	leave  
c01001e2:	c3                   	ret    

c01001e3 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c01001e3:	55                   	push   %ebp
c01001e4:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c01001e6:	90                   	nop
c01001e7:	5d                   	pop    %ebp
c01001e8:	c3                   	ret    

c01001e9 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c01001e9:	55                   	push   %ebp
c01001ea:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c01001ec:	90                   	nop
c01001ed:	5d                   	pop    %ebp
c01001ee:	c3                   	ret    

c01001ef <lab1_switch_test>:

static void
lab1_switch_test(void) {
c01001ef:	55                   	push   %ebp
c01001f0:	89 e5                	mov    %esp,%ebp
c01001f2:	83 ec 08             	sub    $0x8,%esp
    lab1_print_cur_status();
c01001f5:	e8 2c ff ff ff       	call   c0100126 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c01001fa:	83 ec 0c             	sub    $0xc,%esp
c01001fd:	68 68 aa 10 c0       	push   $0xc010aa68
c0100202:	e8 77 00 00 00       	call   c010027e <cprintf>
c0100207:	83 c4 10             	add    $0x10,%esp
    lab1_switch_to_user();
c010020a:	e8 d4 ff ff ff       	call   c01001e3 <lab1_switch_to_user>
    lab1_print_cur_status();
c010020f:	e8 12 ff ff ff       	call   c0100126 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100214:	83 ec 0c             	sub    $0xc,%esp
c0100217:	68 88 aa 10 c0       	push   $0xc010aa88
c010021c:	e8 5d 00 00 00       	call   c010027e <cprintf>
c0100221:	83 c4 10             	add    $0x10,%esp
    lab1_switch_to_kernel();
c0100224:	e8 c0 ff ff ff       	call   c01001e9 <lab1_switch_to_kernel>
    lab1_print_cur_status();
c0100229:	e8 f8 fe ff ff       	call   c0100126 <lab1_print_cur_status>
}
c010022e:	90                   	nop
c010022f:	c9                   	leave  
c0100230:	c3                   	ret    

c0100231 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c0100231:	55                   	push   %ebp
c0100232:	89 e5                	mov    %esp,%ebp
c0100234:	83 ec 08             	sub    $0x8,%esp
    cons_putc(c);
c0100237:	83 ec 0c             	sub    $0xc,%esp
c010023a:	ff 75 08             	pushl  0x8(%ebp)
c010023d:	e8 61 2f 00 00       	call   c01031a3 <cons_putc>
c0100242:	83 c4 10             	add    $0x10,%esp
    (*cnt) ++;
c0100245:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100248:	8b 00                	mov    (%eax),%eax
c010024a:	8d 50 01             	lea    0x1(%eax),%edx
c010024d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100250:	89 10                	mov    %edx,(%eax)
}
c0100252:	90                   	nop
c0100253:	c9                   	leave  
c0100254:	c3                   	ret    

c0100255 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c0100255:	55                   	push   %ebp
c0100256:	89 e5                	mov    %esp,%ebp
c0100258:	83 ec 18             	sub    $0x18,%esp
    int cnt = 0;
c010025b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c0100262:	ff 75 0c             	pushl  0xc(%ebp)
c0100265:	ff 75 08             	pushl  0x8(%ebp)
c0100268:	8d 45 f4             	lea    -0xc(%ebp),%eax
c010026b:	50                   	push   %eax
c010026c:	68 31 02 10 c0       	push   $0xc0100231
c0100271:	e8 18 a2 00 00       	call   c010a48e <vprintfmt>
c0100276:	83 c4 10             	add    $0x10,%esp
    return cnt;
c0100279:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010027c:	c9                   	leave  
c010027d:	c3                   	ret    

c010027e <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c010027e:	55                   	push   %ebp
c010027f:	89 e5                	mov    %esp,%ebp
c0100281:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0100284:	8d 45 0c             	lea    0xc(%ebp),%eax
c0100287:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c010028a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010028d:	83 ec 08             	sub    $0x8,%esp
c0100290:	50                   	push   %eax
c0100291:	ff 75 08             	pushl  0x8(%ebp)
c0100294:	e8 bc ff ff ff       	call   c0100255 <vcprintf>
c0100299:	83 c4 10             	add    $0x10,%esp
c010029c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c010029f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01002a2:	c9                   	leave  
c01002a3:	c3                   	ret    

c01002a4 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c01002a4:	55                   	push   %ebp
c01002a5:	89 e5                	mov    %esp,%ebp
c01002a7:	83 ec 08             	sub    $0x8,%esp
    cons_putc(c);
c01002aa:	83 ec 0c             	sub    $0xc,%esp
c01002ad:	ff 75 08             	pushl  0x8(%ebp)
c01002b0:	e8 ee 2e 00 00       	call   c01031a3 <cons_putc>
c01002b5:	83 c4 10             	add    $0x10,%esp
}
c01002b8:	90                   	nop
c01002b9:	c9                   	leave  
c01002ba:	c3                   	ret    

c01002bb <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c01002bb:	55                   	push   %ebp
c01002bc:	89 e5                	mov    %esp,%ebp
c01002be:	83 ec 18             	sub    $0x18,%esp
    int cnt = 0;
c01002c1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c01002c8:	eb 14                	jmp    c01002de <cputs+0x23>
        cputch(c, &cnt);
c01002ca:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01002ce:	83 ec 08             	sub    $0x8,%esp
c01002d1:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01002d4:	52                   	push   %edx
c01002d5:	50                   	push   %eax
c01002d6:	e8 56 ff ff ff       	call   c0100231 <cputch>
c01002db:	83 c4 10             	add    $0x10,%esp
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
c01002de:	8b 45 08             	mov    0x8(%ebp),%eax
c01002e1:	8d 50 01             	lea    0x1(%eax),%edx
c01002e4:	89 55 08             	mov    %edx,0x8(%ebp)
c01002e7:	0f b6 00             	movzbl (%eax),%eax
c01002ea:	88 45 f7             	mov    %al,-0x9(%ebp)
c01002ed:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c01002f1:	75 d7                	jne    c01002ca <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
c01002f3:	83 ec 08             	sub    $0x8,%esp
c01002f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
c01002f9:	50                   	push   %eax
c01002fa:	6a 0a                	push   $0xa
c01002fc:	e8 30 ff ff ff       	call   c0100231 <cputch>
c0100301:	83 c4 10             	add    $0x10,%esp
    return cnt;
c0100304:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0100307:	c9                   	leave  
c0100308:	c3                   	ret    

c0100309 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c0100309:	55                   	push   %ebp
c010030a:	89 e5                	mov    %esp,%ebp
c010030c:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c010030f:	e8 d8 2e 00 00       	call   c01031ec <cons_getc>
c0100314:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100317:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010031b:	74 f2                	je     c010030f <getchar+0x6>
        /* do nothing */;
    return c;
c010031d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100320:	c9                   	leave  
c0100321:	c3                   	ret    

c0100322 <rb_node_create>:
#include <rb_tree.h>
#include <assert.h>

/* rb_node_create - create a new rb_node */
static inline rb_node *
rb_node_create(void) {
c0100322:	55                   	push   %ebp
c0100323:	89 e5                	mov    %esp,%ebp
c0100325:	83 ec 08             	sub    $0x8,%esp
    return kmalloc(sizeof(rb_node));
c0100328:	83 ec 0c             	sub    $0xc,%esp
c010032b:	6a 10                	push   $0x10
c010032d:	e8 bb 5e 00 00       	call   c01061ed <kmalloc>
c0100332:	83 c4 10             	add    $0x10,%esp
}
c0100335:	c9                   	leave  
c0100336:	c3                   	ret    

c0100337 <rb_tree_empty>:

/* rb_tree_empty - tests if tree is empty */
static inline bool
rb_tree_empty(rb_tree *tree) {
c0100337:	55                   	push   %ebp
c0100338:	89 e5                	mov    %esp,%ebp
c010033a:	83 ec 10             	sub    $0x10,%esp
    rb_node *nil = tree->nil, *root = tree->root;
c010033d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100340:	8b 40 04             	mov    0x4(%eax),%eax
c0100343:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100346:	8b 45 08             	mov    0x8(%ebp),%eax
c0100349:	8b 40 08             	mov    0x8(%eax),%eax
c010034c:	89 45 f8             	mov    %eax,-0x8(%ebp)
    return root->left == nil;
c010034f:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100352:	8b 40 08             	mov    0x8(%eax),%eax
c0100355:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100358:	0f 94 c0             	sete   %al
c010035b:	0f b6 c0             	movzbl %al,%eax
}
c010035e:	c9                   	leave  
c010035f:	c3                   	ret    

c0100360 <rb_tree_create>:
 * Note that, root->left should always point to the node that is the root
 * of the tree. And nil points to a 'NULL' node which should always be
 * black and may have arbitrary children and parent node.
 * */
rb_tree *
rb_tree_create(int (*compare)(rb_node *node1, rb_node *node2)) {
c0100360:	55                   	push   %ebp
c0100361:	89 e5                	mov    %esp,%ebp
c0100363:	83 ec 18             	sub    $0x18,%esp
    assert(compare != NULL);
c0100366:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010036a:	75 16                	jne    c0100382 <rb_tree_create+0x22>
c010036c:	68 a8 aa 10 c0       	push   $0xc010aaa8
c0100371:	68 b8 aa 10 c0       	push   $0xc010aab8
c0100376:	6a 1f                	push   $0x1f
c0100378:	68 cd aa 10 c0       	push   $0xc010aacd
c010037d:	e8 da 13 00 00       	call   c010175c <__panic>

    rb_tree *tree;
    rb_node *nil, *root;

    if ((tree = kmalloc(sizeof(rb_tree))) == NULL) {
c0100382:	83 ec 0c             	sub    $0xc,%esp
c0100385:	6a 0c                	push   $0xc
c0100387:	e8 61 5e 00 00       	call   c01061ed <kmalloc>
c010038c:	83 c4 10             	add    $0x10,%esp
c010038f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100392:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100396:	0f 84 b5 00 00 00    	je     c0100451 <rb_tree_create+0xf1>
        goto bad_tree;
    }

    tree->compare = compare;
c010039c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010039f:	8b 55 08             	mov    0x8(%ebp),%edx
c01003a2:	89 10                	mov    %edx,(%eax)

    if ((nil = rb_node_create()) == NULL) {
c01003a4:	e8 79 ff ff ff       	call   c0100322 <rb_node_create>
c01003a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01003ac:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01003b0:	0f 84 8a 00 00 00    	je     c0100440 <rb_tree_create+0xe0>
        goto bad_node_cleanup_tree;
    }

    nil->parent = nil->left = nil->right = nil;
c01003b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003b9:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01003bc:	89 50 0c             	mov    %edx,0xc(%eax)
c01003bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003c2:	8b 50 0c             	mov    0xc(%eax),%edx
c01003c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003c8:	89 50 08             	mov    %edx,0x8(%eax)
c01003cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003ce:	8b 50 08             	mov    0x8(%eax),%edx
c01003d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003d4:	89 50 04             	mov    %edx,0x4(%eax)
    nil->red = 0;
c01003d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003da:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    tree->nil = nil;
c01003e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01003e3:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01003e6:	89 50 04             	mov    %edx,0x4(%eax)

    if ((root = rb_node_create()) == NULL) {
c01003e9:	e8 34 ff ff ff       	call   c0100322 <rb_node_create>
c01003ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01003f1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01003f5:	74 38                	je     c010042f <rb_tree_create+0xcf>
        goto bad_node_cleanup_nil;
    }

    root->parent = root->left = root->right = nil;
c01003f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01003fa:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01003fd:	89 50 0c             	mov    %edx,0xc(%eax)
c0100400:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100403:	8b 50 0c             	mov    0xc(%eax),%edx
c0100406:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100409:	89 50 08             	mov    %edx,0x8(%eax)
c010040c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010040f:	8b 50 08             	mov    0x8(%eax),%edx
c0100412:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100415:	89 50 04             	mov    %edx,0x4(%eax)
    root->red = 0;
c0100418:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010041b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    tree->root = root;
c0100421:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100424:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0100427:	89 50 08             	mov    %edx,0x8(%eax)
    return tree;
c010042a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010042d:	eb 28                	jmp    c0100457 <rb_tree_create+0xf7>
    nil->parent = nil->left = nil->right = nil;
    nil->red = 0;
    tree->nil = nil;

    if ((root = rb_node_create()) == NULL) {
        goto bad_node_cleanup_nil;
c010042f:	90                   	nop
    root->red = 0;
    tree->root = root;
    return tree;

bad_node_cleanup_nil:
    kfree(nil);
c0100430:	83 ec 0c             	sub    $0xc,%esp
c0100433:	ff 75 f0             	pushl  -0x10(%ebp)
c0100436:	e8 ca 5d 00 00       	call   c0106205 <kfree>
c010043b:	83 c4 10             	add    $0x10,%esp
c010043e:	eb 01                	jmp    c0100441 <rb_tree_create+0xe1>
    }

    tree->compare = compare;

    if ((nil = rb_node_create()) == NULL) {
        goto bad_node_cleanup_tree;
c0100440:	90                   	nop
    return tree;

bad_node_cleanup_nil:
    kfree(nil);
bad_node_cleanup_tree:
    kfree(tree);
c0100441:	83 ec 0c             	sub    $0xc,%esp
c0100444:	ff 75 f4             	pushl  -0xc(%ebp)
c0100447:	e8 b9 5d 00 00       	call   c0106205 <kfree>
c010044c:	83 c4 10             	add    $0x10,%esp
c010044f:	eb 01                	jmp    c0100452 <rb_tree_create+0xf2>

    rb_tree *tree;
    rb_node *nil, *root;

    if ((tree = kmalloc(sizeof(rb_tree))) == NULL) {
        goto bad_tree;
c0100451:	90                   	nop
bad_node_cleanup_nil:
    kfree(nil);
bad_node_cleanup_tree:
    kfree(tree);
bad_tree:
    return NULL;
c0100452:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100457:	c9                   	leave  
c0100458:	c3                   	ret    

c0100459 <rb_left_rotate>:
    y->_left = x;                                               \
    x->parent = y;                                              \
    assert(!(nil->red));                                        \
}

FUNC_ROTATE(rb_left_rotate, left, right);
c0100459:	55                   	push   %ebp
c010045a:	89 e5                	mov    %esp,%ebp
c010045c:	83 ec 18             	sub    $0x18,%esp
c010045f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100462:	8b 40 04             	mov    0x4(%eax),%eax
c0100465:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100468:	8b 45 0c             	mov    0xc(%ebp),%eax
c010046b:	8b 40 0c             	mov    0xc(%eax),%eax
c010046e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100471:	8b 45 08             	mov    0x8(%ebp),%eax
c0100474:	8b 40 08             	mov    0x8(%eax),%eax
c0100477:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010047a:	74 10                	je     c010048c <rb_left_rotate+0x33>
c010047c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010047f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100482:	74 08                	je     c010048c <rb_left_rotate+0x33>
c0100484:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100487:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010048a:	75 16                	jne    c01004a2 <rb_left_rotate+0x49>
c010048c:	68 e4 aa 10 c0       	push   $0xc010aae4
c0100491:	68 b8 aa 10 c0       	push   $0xc010aab8
c0100496:	6a 64                	push   $0x64
c0100498:	68 cd aa 10 c0       	push   $0xc010aacd
c010049d:	e8 ba 12 00 00       	call   c010175c <__panic>
c01004a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004a5:	8b 50 08             	mov    0x8(%eax),%edx
c01004a8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004ab:	89 50 0c             	mov    %edx,0xc(%eax)
c01004ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004b1:	8b 40 08             	mov    0x8(%eax),%eax
c01004b4:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01004b7:	74 0c                	je     c01004c5 <rb_left_rotate+0x6c>
c01004b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004bc:	8b 40 08             	mov    0x8(%eax),%eax
c01004bf:	8b 55 0c             	mov    0xc(%ebp),%edx
c01004c2:	89 50 04             	mov    %edx,0x4(%eax)
c01004c5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004c8:	8b 50 04             	mov    0x4(%eax),%edx
c01004cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004ce:	89 50 04             	mov    %edx,0x4(%eax)
c01004d1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004d4:	8b 40 04             	mov    0x4(%eax),%eax
c01004d7:	8b 40 08             	mov    0x8(%eax),%eax
c01004da:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01004dd:	75 0e                	jne    c01004ed <rb_left_rotate+0x94>
c01004df:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004e2:	8b 40 04             	mov    0x4(%eax),%eax
c01004e5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004e8:	89 50 08             	mov    %edx,0x8(%eax)
c01004eb:	eb 0c                	jmp    c01004f9 <rb_left_rotate+0xa0>
c01004ed:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004f0:	8b 40 04             	mov    0x4(%eax),%eax
c01004f3:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004f6:	89 50 0c             	mov    %edx,0xc(%eax)
c01004f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004fc:	8b 55 0c             	mov    0xc(%ebp),%edx
c01004ff:	89 50 08             	mov    %edx,0x8(%eax)
c0100502:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100505:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100508:	89 50 04             	mov    %edx,0x4(%eax)
c010050b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010050e:	8b 00                	mov    (%eax),%eax
c0100510:	85 c0                	test   %eax,%eax
c0100512:	74 16                	je     c010052a <rb_left_rotate+0xd1>
c0100514:	68 0c ab 10 c0       	push   $0xc010ab0c
c0100519:	68 b8 aa 10 c0       	push   $0xc010aab8
c010051e:	6a 64                	push   $0x64
c0100520:	68 cd aa 10 c0       	push   $0xc010aacd
c0100525:	e8 32 12 00 00       	call   c010175c <__panic>
c010052a:	90                   	nop
c010052b:	c9                   	leave  
c010052c:	c3                   	ret    

c010052d <rb_right_rotate>:
FUNC_ROTATE(rb_right_rotate, right, left);
c010052d:	55                   	push   %ebp
c010052e:	89 e5                	mov    %esp,%ebp
c0100530:	83 ec 18             	sub    $0x18,%esp
c0100533:	8b 45 08             	mov    0x8(%ebp),%eax
c0100536:	8b 40 04             	mov    0x4(%eax),%eax
c0100539:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010053c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010053f:	8b 40 08             	mov    0x8(%eax),%eax
c0100542:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100545:	8b 45 08             	mov    0x8(%ebp),%eax
c0100548:	8b 40 08             	mov    0x8(%eax),%eax
c010054b:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010054e:	74 10                	je     c0100560 <rb_right_rotate+0x33>
c0100550:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100553:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100556:	74 08                	je     c0100560 <rb_right_rotate+0x33>
c0100558:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010055b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010055e:	75 16                	jne    c0100576 <rb_right_rotate+0x49>
c0100560:	68 e4 aa 10 c0       	push   $0xc010aae4
c0100565:	68 b8 aa 10 c0       	push   $0xc010aab8
c010056a:	6a 65                	push   $0x65
c010056c:	68 cd aa 10 c0       	push   $0xc010aacd
c0100571:	e8 e6 11 00 00       	call   c010175c <__panic>
c0100576:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100579:	8b 50 0c             	mov    0xc(%eax),%edx
c010057c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010057f:	89 50 08             	mov    %edx,0x8(%eax)
c0100582:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100585:	8b 40 0c             	mov    0xc(%eax),%eax
c0100588:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010058b:	74 0c                	je     c0100599 <rb_right_rotate+0x6c>
c010058d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100590:	8b 40 0c             	mov    0xc(%eax),%eax
c0100593:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100596:	89 50 04             	mov    %edx,0x4(%eax)
c0100599:	8b 45 0c             	mov    0xc(%ebp),%eax
c010059c:	8b 50 04             	mov    0x4(%eax),%edx
c010059f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005a2:	89 50 04             	mov    %edx,0x4(%eax)
c01005a5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005a8:	8b 40 04             	mov    0x4(%eax),%eax
c01005ab:	8b 40 0c             	mov    0xc(%eax),%eax
c01005ae:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01005b1:	75 0e                	jne    c01005c1 <rb_right_rotate+0x94>
c01005b3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005b6:	8b 40 04             	mov    0x4(%eax),%eax
c01005b9:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005bc:	89 50 0c             	mov    %edx,0xc(%eax)
c01005bf:	eb 0c                	jmp    c01005cd <rb_right_rotate+0xa0>
c01005c1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005c4:	8b 40 04             	mov    0x4(%eax),%eax
c01005c7:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005ca:	89 50 08             	mov    %edx,0x8(%eax)
c01005cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005d0:	8b 55 0c             	mov    0xc(%ebp),%edx
c01005d3:	89 50 0c             	mov    %edx,0xc(%eax)
c01005d6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005d9:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005dc:	89 50 04             	mov    %edx,0x4(%eax)
c01005df:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01005e2:	8b 00                	mov    (%eax),%eax
c01005e4:	85 c0                	test   %eax,%eax
c01005e6:	74 16                	je     c01005fe <rb_right_rotate+0xd1>
c01005e8:	68 0c ab 10 c0       	push   $0xc010ab0c
c01005ed:	68 b8 aa 10 c0       	push   $0xc010aab8
c01005f2:	6a 65                	push   $0x65
c01005f4:	68 cd aa 10 c0       	push   $0xc010aacd
c01005f9:	e8 5e 11 00 00       	call   c010175c <__panic>
c01005fe:	90                   	nop
c01005ff:	c9                   	leave  
c0100600:	c3                   	ret    

c0100601 <rb_insert_binary>:
 * rb_insert_binary - insert @node to red-black @tree as if it were
 * a regular binary tree. This function is only intended to be called
 * by function rb_insert.
 * */
static inline void
rb_insert_binary(rb_tree *tree, rb_node *node) {
c0100601:	55                   	push   %ebp
c0100602:	89 e5                	mov    %esp,%ebp
c0100604:	83 ec 28             	sub    $0x28,%esp
    rb_node *x, *y, *z = node, *nil = tree->nil, *root = tree->root;
c0100607:	8b 45 0c             	mov    0xc(%ebp),%eax
c010060a:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010060d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100610:	8b 40 04             	mov    0x4(%eax),%eax
c0100613:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0100616:	8b 45 08             	mov    0x8(%ebp),%eax
c0100619:	8b 40 08             	mov    0x8(%eax),%eax
c010061c:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    z->left = z->right = nil;
c010061f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100622:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0100625:	89 50 0c             	mov    %edx,0xc(%eax)
c0100628:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010062b:	8b 50 0c             	mov    0xc(%eax),%edx
c010062e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100631:	89 50 08             	mov    %edx,0x8(%eax)
    y = root, x = y->left;
c0100634:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100637:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010063a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010063d:	8b 40 08             	mov    0x8(%eax),%eax
c0100640:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while (x != nil) {
c0100643:	eb 2e                	jmp    c0100673 <rb_insert_binary+0x72>
        y = x;
c0100645:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100648:	89 45 f0             	mov    %eax,-0x10(%ebp)
        x = (COMPARE(tree, x, node) > 0) ? x->left : x->right;
c010064b:	8b 45 08             	mov    0x8(%ebp),%eax
c010064e:	8b 00                	mov    (%eax),%eax
c0100650:	83 ec 08             	sub    $0x8,%esp
c0100653:	ff 75 0c             	pushl  0xc(%ebp)
c0100656:	ff 75 f4             	pushl  -0xc(%ebp)
c0100659:	ff d0                	call   *%eax
c010065b:	83 c4 10             	add    $0x10,%esp
c010065e:	85 c0                	test   %eax,%eax
c0100660:	7e 08                	jle    c010066a <rb_insert_binary+0x69>
c0100662:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100665:	8b 40 08             	mov    0x8(%eax),%eax
c0100668:	eb 06                	jmp    c0100670 <rb_insert_binary+0x6f>
c010066a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010066d:	8b 40 0c             	mov    0xc(%eax),%eax
c0100670:	89 45 f4             	mov    %eax,-0xc(%ebp)
rb_insert_binary(rb_tree *tree, rb_node *node) {
    rb_node *x, *y, *z = node, *nil = tree->nil, *root = tree->root;

    z->left = z->right = nil;
    y = root, x = y->left;
    while (x != nil) {
c0100673:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100676:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c0100679:	75 ca                	jne    c0100645 <rb_insert_binary+0x44>
        y = x;
        x = (COMPARE(tree, x, node) > 0) ? x->left : x->right;
    }
    z->parent = y;
c010067b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010067e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100681:	89 50 04             	mov    %edx,0x4(%eax)
    if (y == root || COMPARE(tree, y, z) > 0) {
c0100684:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100687:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
c010068a:	74 17                	je     c01006a3 <rb_insert_binary+0xa2>
c010068c:	8b 45 08             	mov    0x8(%ebp),%eax
c010068f:	8b 00                	mov    (%eax),%eax
c0100691:	83 ec 08             	sub    $0x8,%esp
c0100694:	ff 75 ec             	pushl  -0x14(%ebp)
c0100697:	ff 75 f0             	pushl  -0x10(%ebp)
c010069a:	ff d0                	call   *%eax
c010069c:	83 c4 10             	add    $0x10,%esp
c010069f:	85 c0                	test   %eax,%eax
c01006a1:	7e 0b                	jle    c01006ae <rb_insert_binary+0xad>
        y->left = z;
c01006a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01006a6:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01006a9:	89 50 08             	mov    %edx,0x8(%eax)
c01006ac:	eb 09                	jmp    c01006b7 <rb_insert_binary+0xb6>
    }
    else {
        y->right = z;
c01006ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01006b1:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01006b4:	89 50 0c             	mov    %edx,0xc(%eax)
    }
}
c01006b7:	90                   	nop
c01006b8:	c9                   	leave  
c01006b9:	c3                   	ret    

c01006ba <rb_insert>:

/* rb_insert - insert a node to red-black tree */
void
rb_insert(rb_tree *tree, rb_node *node) {
c01006ba:	55                   	push   %ebp
c01006bb:	89 e5                	mov    %esp,%ebp
c01006bd:	83 ec 18             	sub    $0x18,%esp
    rb_insert_binary(tree, node);
c01006c0:	83 ec 08             	sub    $0x8,%esp
c01006c3:	ff 75 0c             	pushl  0xc(%ebp)
c01006c6:	ff 75 08             	pushl  0x8(%ebp)
c01006c9:	e8 33 ff ff ff       	call   c0100601 <rb_insert_binary>
c01006ce:	83 c4 10             	add    $0x10,%esp
    node->red = 1;
c01006d1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006d4:	c7 00 01 00 00 00    	movl   $0x1,(%eax)

    rb_node *x = node, *y;
c01006da:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
            x->parent->parent->red = 1;                         \
            rb_##_right##_rotate(tree, x->parent->parent);      \
        }                                                       \
    } while (0)

    while (x->parent->red) {
c01006e0:	e9 6c 01 00 00       	jmp    c0100851 <rb_insert+0x197>
        if (x->parent == x->parent->parent->left) {
c01006e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006e8:	8b 50 04             	mov    0x4(%eax),%edx
c01006eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006ee:	8b 40 04             	mov    0x4(%eax),%eax
c01006f1:	8b 40 04             	mov    0x4(%eax),%eax
c01006f4:	8b 40 08             	mov    0x8(%eax),%eax
c01006f7:	39 c2                	cmp    %eax,%edx
c01006f9:	0f 85 ad 00 00 00    	jne    c01007ac <rb_insert+0xf2>
            RB_INSERT_SUB(left, right);
c01006ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100702:	8b 40 04             	mov    0x4(%eax),%eax
c0100705:	8b 40 04             	mov    0x4(%eax),%eax
c0100708:	8b 40 0c             	mov    0xc(%eax),%eax
c010070b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010070e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100711:	8b 00                	mov    (%eax),%eax
c0100713:	85 c0                	test   %eax,%eax
c0100715:	74 35                	je     c010074c <rb_insert+0x92>
c0100717:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010071a:	8b 40 04             	mov    0x4(%eax),%eax
c010071d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100723:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100726:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c010072c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010072f:	8b 40 04             	mov    0x4(%eax),%eax
c0100732:	8b 40 04             	mov    0x4(%eax),%eax
c0100735:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c010073b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010073e:	8b 40 04             	mov    0x4(%eax),%eax
c0100741:	8b 40 04             	mov    0x4(%eax),%eax
c0100744:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100747:	e9 05 01 00 00       	jmp    c0100851 <rb_insert+0x197>
c010074c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010074f:	8b 40 04             	mov    0x4(%eax),%eax
c0100752:	8b 40 0c             	mov    0xc(%eax),%eax
c0100755:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100758:	75 1a                	jne    c0100774 <rb_insert+0xba>
c010075a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010075d:	8b 40 04             	mov    0x4(%eax),%eax
c0100760:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100763:	83 ec 08             	sub    $0x8,%esp
c0100766:	ff 75 f4             	pushl  -0xc(%ebp)
c0100769:	ff 75 08             	pushl  0x8(%ebp)
c010076c:	e8 e8 fc ff ff       	call   c0100459 <rb_left_rotate>
c0100771:	83 c4 10             	add    $0x10,%esp
c0100774:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100777:	8b 40 04             	mov    0x4(%eax),%eax
c010077a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100780:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100783:	8b 40 04             	mov    0x4(%eax),%eax
c0100786:	8b 40 04             	mov    0x4(%eax),%eax
c0100789:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c010078f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100792:	8b 40 04             	mov    0x4(%eax),%eax
c0100795:	8b 40 04             	mov    0x4(%eax),%eax
c0100798:	83 ec 08             	sub    $0x8,%esp
c010079b:	50                   	push   %eax
c010079c:	ff 75 08             	pushl  0x8(%ebp)
c010079f:	e8 89 fd ff ff       	call   c010052d <rb_right_rotate>
c01007a4:	83 c4 10             	add    $0x10,%esp
c01007a7:	e9 a5 00 00 00       	jmp    c0100851 <rb_insert+0x197>
        }
        else {
            RB_INSERT_SUB(right, left);
c01007ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007af:	8b 40 04             	mov    0x4(%eax),%eax
c01007b2:	8b 40 04             	mov    0x4(%eax),%eax
c01007b5:	8b 40 08             	mov    0x8(%eax),%eax
c01007b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01007bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01007be:	8b 00                	mov    (%eax),%eax
c01007c0:	85 c0                	test   %eax,%eax
c01007c2:	74 32                	je     c01007f6 <rb_insert+0x13c>
c01007c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007c7:	8b 40 04             	mov    0x4(%eax),%eax
c01007ca:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c01007d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01007d3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c01007d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007dc:	8b 40 04             	mov    0x4(%eax),%eax
c01007df:	8b 40 04             	mov    0x4(%eax),%eax
c01007e2:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c01007e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007eb:	8b 40 04             	mov    0x4(%eax),%eax
c01007ee:	8b 40 04             	mov    0x4(%eax),%eax
c01007f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01007f4:	eb 5b                	jmp    c0100851 <rb_insert+0x197>
c01007f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007f9:	8b 40 04             	mov    0x4(%eax),%eax
c01007fc:	8b 40 08             	mov    0x8(%eax),%eax
c01007ff:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100802:	75 1a                	jne    c010081e <rb_insert+0x164>
c0100804:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100807:	8b 40 04             	mov    0x4(%eax),%eax
c010080a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010080d:	83 ec 08             	sub    $0x8,%esp
c0100810:	ff 75 f4             	pushl  -0xc(%ebp)
c0100813:	ff 75 08             	pushl  0x8(%ebp)
c0100816:	e8 12 fd ff ff       	call   c010052d <rb_right_rotate>
c010081b:	83 c4 10             	add    $0x10,%esp
c010081e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100821:	8b 40 04             	mov    0x4(%eax),%eax
c0100824:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c010082a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010082d:	8b 40 04             	mov    0x4(%eax),%eax
c0100830:	8b 40 04             	mov    0x4(%eax),%eax
c0100833:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c0100839:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010083c:	8b 40 04             	mov    0x4(%eax),%eax
c010083f:	8b 40 04             	mov    0x4(%eax),%eax
c0100842:	83 ec 08             	sub    $0x8,%esp
c0100845:	50                   	push   %eax
c0100846:	ff 75 08             	pushl  0x8(%ebp)
c0100849:	e8 0b fc ff ff       	call   c0100459 <rb_left_rotate>
c010084e:	83 c4 10             	add    $0x10,%esp
            x->parent->parent->red = 1;                         \
            rb_##_right##_rotate(tree, x->parent->parent);      \
        }                                                       \
    } while (0)

    while (x->parent->red) {
c0100851:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100854:	8b 40 04             	mov    0x4(%eax),%eax
c0100857:	8b 00                	mov    (%eax),%eax
c0100859:	85 c0                	test   %eax,%eax
c010085b:	0f 85 84 fe ff ff    	jne    c01006e5 <rb_insert+0x2b>
        }
        else {
            RB_INSERT_SUB(right, left);
        }
    }
    tree->root->left->red = 0;
c0100861:	8b 45 08             	mov    0x8(%ebp),%eax
c0100864:	8b 40 08             	mov    0x8(%eax),%eax
c0100867:	8b 40 08             	mov    0x8(%eax),%eax
c010086a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    assert(!(tree->nil->red) && !(tree->root->red));
c0100870:	8b 45 08             	mov    0x8(%ebp),%eax
c0100873:	8b 40 04             	mov    0x4(%eax),%eax
c0100876:	8b 00                	mov    (%eax),%eax
c0100878:	85 c0                	test   %eax,%eax
c010087a:	75 0c                	jne    c0100888 <rb_insert+0x1ce>
c010087c:	8b 45 08             	mov    0x8(%ebp),%eax
c010087f:	8b 40 08             	mov    0x8(%eax),%eax
c0100882:	8b 00                	mov    (%eax),%eax
c0100884:	85 c0                	test   %eax,%eax
c0100886:	74 19                	je     c01008a1 <rb_insert+0x1e7>
c0100888:	68 18 ab 10 c0       	push   $0xc010ab18
c010088d:	68 b8 aa 10 c0       	push   $0xc010aab8
c0100892:	68 a9 00 00 00       	push   $0xa9
c0100897:	68 cd aa 10 c0       	push   $0xc010aacd
c010089c:	e8 bb 0e 00 00       	call   c010175c <__panic>

#undef RB_INSERT_SUB
}
c01008a1:	90                   	nop
c01008a2:	c9                   	leave  
c01008a3:	c3                   	ret    

c01008a4 <rb_tree_successor>:
 * rb_tree_successor - returns the successor of @node, or nil
 * if no successor exists. Make sure that @node must belong to @tree,
 * and this function should only be called by rb_node_prev.
 * */
static inline rb_node *
rb_tree_successor(rb_tree *tree, rb_node *node) {
c01008a4:	55                   	push   %ebp
c01008a5:	89 e5                	mov    %esp,%ebp
c01008a7:	83 ec 10             	sub    $0x10,%esp
    rb_node *x = node, *y, *nil = tree->nil;
c01008aa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008ad:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01008b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01008b3:	8b 40 04             	mov    0x4(%eax),%eax
c01008b6:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if ((y = x->right) != nil) {
c01008b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01008bc:	8b 40 0c             	mov    0xc(%eax),%eax
c01008bf:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01008c2:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01008c5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01008c8:	74 1b                	je     c01008e5 <rb_tree_successor+0x41>
        while (y->left != nil) {
c01008ca:	eb 09                	jmp    c01008d5 <rb_tree_successor+0x31>
            y = y->left;
c01008cc:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01008cf:	8b 40 08             	mov    0x8(%eax),%eax
c01008d2:	89 45 f8             	mov    %eax,-0x8(%ebp)
static inline rb_node *
rb_tree_successor(rb_tree *tree, rb_node *node) {
    rb_node *x = node, *y, *nil = tree->nil;

    if ((y = x->right) != nil) {
        while (y->left != nil) {
c01008d5:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01008d8:	8b 40 08             	mov    0x8(%eax),%eax
c01008db:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01008de:	75 ec                	jne    c01008cc <rb_tree_successor+0x28>
            y = y->left;
        }
        return y;
c01008e0:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01008e3:	eb 38                	jmp    c010091d <rb_tree_successor+0x79>
    }
    else {
        y = x->parent;
c01008e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01008e8:	8b 40 04             	mov    0x4(%eax),%eax
c01008eb:	89 45 f8             	mov    %eax,-0x8(%ebp)
        while (x == y->right) {
c01008ee:	eb 0f                	jmp    c01008ff <rb_tree_successor+0x5b>
            x = y, y = y->parent;
c01008f0:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01008f3:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01008f6:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01008f9:	8b 40 04             	mov    0x4(%eax),%eax
c01008fc:	89 45 f8             	mov    %eax,-0x8(%ebp)
        }
        return y;
    }
    else {
        y = x->parent;
        while (x == y->right) {
c01008ff:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100902:	8b 40 0c             	mov    0xc(%eax),%eax
c0100905:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100908:	74 e6                	je     c01008f0 <rb_tree_successor+0x4c>
            x = y, y = y->parent;
        }
        if (y == tree->root) {
c010090a:	8b 45 08             	mov    0x8(%ebp),%eax
c010090d:	8b 40 08             	mov    0x8(%eax),%eax
c0100910:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0100913:	75 05                	jne    c010091a <rb_tree_successor+0x76>
            return nil;
c0100915:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100918:	eb 03                	jmp    c010091d <rb_tree_successor+0x79>
        }
        return y;
c010091a:	8b 45 f8             	mov    -0x8(%ebp),%eax
    }
}
c010091d:	c9                   	leave  
c010091e:	c3                   	ret    

c010091f <rb_tree_predecessor>:
/* *
 * rb_tree_predecessor - returns the predecessor of @node, or nil
 * if no predecessor exists, likes rb_tree_successor.
 * */
static inline rb_node *
rb_tree_predecessor(rb_tree *tree, rb_node *node) {
c010091f:	55                   	push   %ebp
c0100920:	89 e5                	mov    %esp,%ebp
c0100922:	83 ec 10             	sub    $0x10,%esp
    rb_node *x = node, *y, *nil = tree->nil;
c0100925:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100928:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010092b:	8b 45 08             	mov    0x8(%ebp),%eax
c010092e:	8b 40 04             	mov    0x4(%eax),%eax
c0100931:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if ((y = x->left) != nil) {
c0100934:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100937:	8b 40 08             	mov    0x8(%eax),%eax
c010093a:	89 45 f8             	mov    %eax,-0x8(%ebp)
c010093d:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100940:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100943:	74 1b                	je     c0100960 <rb_tree_predecessor+0x41>
        while (y->right != nil) {
c0100945:	eb 09                	jmp    c0100950 <rb_tree_predecessor+0x31>
            y = y->right;
c0100947:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010094a:	8b 40 0c             	mov    0xc(%eax),%eax
c010094d:	89 45 f8             	mov    %eax,-0x8(%ebp)
static inline rb_node *
rb_tree_predecessor(rb_tree *tree, rb_node *node) {
    rb_node *x = node, *y, *nil = tree->nil;

    if ((y = x->left) != nil) {
        while (y->right != nil) {
c0100950:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100953:	8b 40 0c             	mov    0xc(%eax),%eax
c0100956:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100959:	75 ec                	jne    c0100947 <rb_tree_predecessor+0x28>
            y = y->right;
        }
        return y;
c010095b:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010095e:	eb 38                	jmp    c0100998 <rb_tree_predecessor+0x79>
    }
    else {
        y = x->parent;
c0100960:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100963:	8b 40 04             	mov    0x4(%eax),%eax
c0100966:	89 45 f8             	mov    %eax,-0x8(%ebp)
        while (x == y->left) {
c0100969:	eb 1f                	jmp    c010098a <rb_tree_predecessor+0x6b>
            if (y == tree->root) {
c010096b:	8b 45 08             	mov    0x8(%ebp),%eax
c010096e:	8b 40 08             	mov    0x8(%eax),%eax
c0100971:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0100974:	75 05                	jne    c010097b <rb_tree_predecessor+0x5c>
                return nil;
c0100976:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100979:	eb 1d                	jmp    c0100998 <rb_tree_predecessor+0x79>
            }
            x = y, y = y->parent;
c010097b:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010097e:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100981:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100984:	8b 40 04             	mov    0x4(%eax),%eax
c0100987:	89 45 f8             	mov    %eax,-0x8(%ebp)
        }
        return y;
    }
    else {
        y = x->parent;
        while (x == y->left) {
c010098a:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010098d:	8b 40 08             	mov    0x8(%eax),%eax
c0100990:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100993:	74 d6                	je     c010096b <rb_tree_predecessor+0x4c>
            if (y == tree->root) {
                return nil;
            }
            x = y, y = y->parent;
        }
        return y;
c0100995:	8b 45 f8             	mov    -0x8(%ebp),%eax
    }
}
c0100998:	c9                   	leave  
c0100999:	c3                   	ret    

c010099a <rb_search>:
 * rb_search - returns a node with value 'equal' to @key (according to
 * function @compare). If there're multiple nodes with value 'equal' to @key,
 * the functions returns the one highest in the tree.
 * */
rb_node *
rb_search(rb_tree *tree, int (*compare)(rb_node *node, void *key), void *key) {
c010099a:	55                   	push   %ebp
c010099b:	89 e5                	mov    %esp,%ebp
c010099d:	83 ec 18             	sub    $0x18,%esp
    rb_node *nil = tree->nil, *node = tree->root->left;
c01009a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01009a3:	8b 40 04             	mov    0x4(%eax),%eax
c01009a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01009a9:	8b 45 08             	mov    0x8(%ebp),%eax
c01009ac:	8b 40 08             	mov    0x8(%eax),%eax
c01009af:	8b 40 08             	mov    0x8(%eax),%eax
c01009b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int r;
    while (node != nil && (r = compare(node, key)) != 0) {
c01009b5:	eb 17                	jmp    c01009ce <rb_search+0x34>
        node = (r > 0) ? node->left : node->right;
c01009b7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01009bb:	7e 08                	jle    c01009c5 <rb_search+0x2b>
c01009bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009c0:	8b 40 08             	mov    0x8(%eax),%eax
c01009c3:	eb 06                	jmp    c01009cb <rb_search+0x31>
c01009c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009c8:	8b 40 0c             	mov    0xc(%eax),%eax
c01009cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
 * */
rb_node *
rb_search(rb_tree *tree, int (*compare)(rb_node *node, void *key), void *key) {
    rb_node *nil = tree->nil, *node = tree->root->left;
    int r;
    while (node != nil && (r = compare(node, key)) != 0) {
c01009ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009d1:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01009d4:	74 1a                	je     c01009f0 <rb_search+0x56>
c01009d6:	83 ec 08             	sub    $0x8,%esp
c01009d9:	ff 75 10             	pushl  0x10(%ebp)
c01009dc:	ff 75 f4             	pushl  -0xc(%ebp)
c01009df:	8b 45 0c             	mov    0xc(%ebp),%eax
c01009e2:	ff d0                	call   *%eax
c01009e4:	83 c4 10             	add    $0x10,%esp
c01009e7:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01009ea:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01009ee:	75 c7                	jne    c01009b7 <rb_search+0x1d>
        node = (r > 0) ? node->left : node->right;
    }
    return (node != nil) ? node : NULL;
c01009f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009f3:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01009f6:	74 05                	je     c01009fd <rb_search+0x63>
c01009f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009fb:	eb 05                	jmp    c0100a02 <rb_search+0x68>
c01009fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100a02:	c9                   	leave  
c0100a03:	c3                   	ret    

c0100a04 <rb_delete_fixup>:
/* *
 * rb_delete_fixup - performs rotations and changes colors to restore
 * red-black properties after a node is deleted.
 * */
static void
rb_delete_fixup(rb_tree *tree, rb_node *node) {
c0100a04:	55                   	push   %ebp
c0100a05:	89 e5                	mov    %esp,%ebp
c0100a07:	83 ec 18             	sub    $0x18,%esp
    rb_node *x = node, *w, *root = tree->root->left;
c0100a0a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100a0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100a10:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a13:	8b 40 08             	mov    0x8(%eax),%eax
c0100a16:	8b 40 08             	mov    0x8(%eax),%eax
c0100a19:	89 45 ec             	mov    %eax,-0x14(%ebp)
            rb_##_left##_rotate(tree, x->parent);               \
            x = root;                                           \
        }                                                       \
    } while (0)

    while (x != root && !x->red) {
c0100a1c:	e9 04 02 00 00       	jmp    c0100c25 <rb_delete_fixup+0x221>
        if (x == x->parent->left) {
c0100a21:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a24:	8b 40 04             	mov    0x4(%eax),%eax
c0100a27:	8b 40 08             	mov    0x8(%eax),%eax
c0100a2a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100a2d:	0f 85 fd 00 00 00    	jne    c0100b30 <rb_delete_fixup+0x12c>
            RB_DELETE_FIXUP_SUB(left, right);
c0100a33:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a36:	8b 40 04             	mov    0x4(%eax),%eax
c0100a39:	8b 40 0c             	mov    0xc(%eax),%eax
c0100a3c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100a3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a42:	8b 00                	mov    (%eax),%eax
c0100a44:	85 c0                	test   %eax,%eax
c0100a46:	74 36                	je     c0100a7e <rb_delete_fixup+0x7a>
c0100a48:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a4b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100a51:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a54:	8b 40 04             	mov    0x4(%eax),%eax
c0100a57:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c0100a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a60:	8b 40 04             	mov    0x4(%eax),%eax
c0100a63:	83 ec 08             	sub    $0x8,%esp
c0100a66:	50                   	push   %eax
c0100a67:	ff 75 08             	pushl  0x8(%ebp)
c0100a6a:	e8 ea f9 ff ff       	call   c0100459 <rb_left_rotate>
c0100a6f:	83 c4 10             	add    $0x10,%esp
c0100a72:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a75:	8b 40 04             	mov    0x4(%eax),%eax
c0100a78:	8b 40 0c             	mov    0xc(%eax),%eax
c0100a7b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100a7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a81:	8b 40 08             	mov    0x8(%eax),%eax
c0100a84:	8b 00                	mov    (%eax),%eax
c0100a86:	85 c0                	test   %eax,%eax
c0100a88:	75 23                	jne    c0100aad <rb_delete_fixup+0xa9>
c0100a8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a8d:	8b 40 0c             	mov    0xc(%eax),%eax
c0100a90:	8b 00                	mov    (%eax),%eax
c0100a92:	85 c0                	test   %eax,%eax
c0100a94:	75 17                	jne    c0100aad <rb_delete_fixup+0xa9>
c0100a96:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a99:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c0100a9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100aa2:	8b 40 04             	mov    0x4(%eax),%eax
c0100aa5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100aa8:	e9 78 01 00 00       	jmp    c0100c25 <rb_delete_fixup+0x221>
c0100aad:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100ab0:	8b 40 0c             	mov    0xc(%eax),%eax
c0100ab3:	8b 00                	mov    (%eax),%eax
c0100ab5:	85 c0                	test   %eax,%eax
c0100ab7:	75 32                	jne    c0100aeb <rb_delete_fixup+0xe7>
c0100ab9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100abc:	8b 40 08             	mov    0x8(%eax),%eax
c0100abf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100ac5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100ac8:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c0100ace:	83 ec 08             	sub    $0x8,%esp
c0100ad1:	ff 75 f0             	pushl  -0x10(%ebp)
c0100ad4:	ff 75 08             	pushl  0x8(%ebp)
c0100ad7:	e8 51 fa ff ff       	call   c010052d <rb_right_rotate>
c0100adc:	83 c4 10             	add    $0x10,%esp
c0100adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ae2:	8b 40 04             	mov    0x4(%eax),%eax
c0100ae5:	8b 40 0c             	mov    0xc(%eax),%eax
c0100ae8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100aeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100aee:	8b 40 04             	mov    0x4(%eax),%eax
c0100af1:	8b 10                	mov    (%eax),%edx
c0100af3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100af6:	89 10                	mov    %edx,(%eax)
c0100af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100afb:	8b 40 04             	mov    0x4(%eax),%eax
c0100afe:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100b04:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b07:	8b 40 0c             	mov    0xc(%eax),%eax
c0100b0a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100b10:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b13:	8b 40 04             	mov    0x4(%eax),%eax
c0100b16:	83 ec 08             	sub    $0x8,%esp
c0100b19:	50                   	push   %eax
c0100b1a:	ff 75 08             	pushl  0x8(%ebp)
c0100b1d:	e8 37 f9 ff ff       	call   c0100459 <rb_left_rotate>
c0100b22:	83 c4 10             	add    $0x10,%esp
c0100b25:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100b28:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100b2b:	e9 f5 00 00 00       	jmp    c0100c25 <rb_delete_fixup+0x221>
        }
        else {
            RB_DELETE_FIXUP_SUB(right, left);
c0100b30:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b33:	8b 40 04             	mov    0x4(%eax),%eax
c0100b36:	8b 40 08             	mov    0x8(%eax),%eax
c0100b39:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100b3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b3f:	8b 00                	mov    (%eax),%eax
c0100b41:	85 c0                	test   %eax,%eax
c0100b43:	74 36                	je     c0100b7b <rb_delete_fixup+0x177>
c0100b45:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b48:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100b4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b51:	8b 40 04             	mov    0x4(%eax),%eax
c0100b54:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c0100b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b5d:	8b 40 04             	mov    0x4(%eax),%eax
c0100b60:	83 ec 08             	sub    $0x8,%esp
c0100b63:	50                   	push   %eax
c0100b64:	ff 75 08             	pushl  0x8(%ebp)
c0100b67:	e8 c1 f9 ff ff       	call   c010052d <rb_right_rotate>
c0100b6c:	83 c4 10             	add    $0x10,%esp
c0100b6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b72:	8b 40 04             	mov    0x4(%eax),%eax
c0100b75:	8b 40 08             	mov    0x8(%eax),%eax
c0100b78:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100b7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b7e:	8b 40 0c             	mov    0xc(%eax),%eax
c0100b81:	8b 00                	mov    (%eax),%eax
c0100b83:	85 c0                	test   %eax,%eax
c0100b85:	75 20                	jne    c0100ba7 <rb_delete_fixup+0x1a3>
c0100b87:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b8a:	8b 40 08             	mov    0x8(%eax),%eax
c0100b8d:	8b 00                	mov    (%eax),%eax
c0100b8f:	85 c0                	test   %eax,%eax
c0100b91:	75 14                	jne    c0100ba7 <rb_delete_fixup+0x1a3>
c0100b93:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b96:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c0100b9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b9f:	8b 40 04             	mov    0x4(%eax),%eax
c0100ba2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100ba5:	eb 7e                	jmp    c0100c25 <rb_delete_fixup+0x221>
c0100ba7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100baa:	8b 40 08             	mov    0x8(%eax),%eax
c0100bad:	8b 00                	mov    (%eax),%eax
c0100baf:	85 c0                	test   %eax,%eax
c0100bb1:	75 32                	jne    c0100be5 <rb_delete_fixup+0x1e1>
c0100bb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100bb6:	8b 40 0c             	mov    0xc(%eax),%eax
c0100bb9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100bbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100bc2:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c0100bc8:	83 ec 08             	sub    $0x8,%esp
c0100bcb:	ff 75 f0             	pushl  -0x10(%ebp)
c0100bce:	ff 75 08             	pushl  0x8(%ebp)
c0100bd1:	e8 83 f8 ff ff       	call   c0100459 <rb_left_rotate>
c0100bd6:	83 c4 10             	add    $0x10,%esp
c0100bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bdc:	8b 40 04             	mov    0x4(%eax),%eax
c0100bdf:	8b 40 08             	mov    0x8(%eax),%eax
c0100be2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100be5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100be8:	8b 40 04             	mov    0x4(%eax),%eax
c0100beb:	8b 10                	mov    (%eax),%edx
c0100bed:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100bf0:	89 10                	mov    %edx,(%eax)
c0100bf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bf5:	8b 40 04             	mov    0x4(%eax),%eax
c0100bf8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100bfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100c01:	8b 40 08             	mov    0x8(%eax),%eax
c0100c04:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100c0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c0d:	8b 40 04             	mov    0x4(%eax),%eax
c0100c10:	83 ec 08             	sub    $0x8,%esp
c0100c13:	50                   	push   %eax
c0100c14:	ff 75 08             	pushl  0x8(%ebp)
c0100c17:	e8 11 f9 ff ff       	call   c010052d <rb_right_rotate>
c0100c1c:	83 c4 10             	add    $0x10,%esp
c0100c1f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100c22:	89 45 f4             	mov    %eax,-0xc(%ebp)
            rb_##_left##_rotate(tree, x->parent);               \
            x = root;                                           \
        }                                                       \
    } while (0)

    while (x != root && !x->red) {
c0100c25:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c28:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0100c2b:	74 0d                	je     c0100c3a <rb_delete_fixup+0x236>
c0100c2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c30:	8b 00                	mov    (%eax),%eax
c0100c32:	85 c0                	test   %eax,%eax
c0100c34:	0f 84 e7 fd ff ff    	je     c0100a21 <rb_delete_fixup+0x1d>
        }
        else {
            RB_DELETE_FIXUP_SUB(right, left);
        }
    }
    x->red = 0;
c0100c3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c3d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

#undef RB_DELETE_FIXUP_SUB
}
c0100c43:	90                   	nop
c0100c44:	c9                   	leave  
c0100c45:	c3                   	ret    

c0100c46 <rb_delete>:
/* *
 * rb_delete - deletes @node from @tree, and calls rb_delete_fixup to
 * restore red-black properties.
 * */
void
rb_delete(rb_tree *tree, rb_node *node) {
c0100c46:	55                   	push   %ebp
c0100c47:	89 e5                	mov    %esp,%ebp
c0100c49:	83 ec 28             	sub    $0x28,%esp
    rb_node *x, *y, *z = node;
c0100c4c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100c4f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    rb_node *nil = tree->nil, *root = tree->root;
c0100c52:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c55:	8b 40 04             	mov    0x4(%eax),%eax
c0100c58:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100c5b:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c5e:	8b 40 08             	mov    0x8(%eax),%eax
c0100c61:	89 45 ec             	mov    %eax,-0x14(%ebp)

    y = (z->left == nil || z->right == nil) ? z : rb_tree_successor(tree, z);
c0100c64:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c67:	8b 40 08             	mov    0x8(%eax),%eax
c0100c6a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0100c6d:	74 1b                	je     c0100c8a <rb_delete+0x44>
c0100c6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c72:	8b 40 0c             	mov    0xc(%eax),%eax
c0100c75:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0100c78:	74 10                	je     c0100c8a <rb_delete+0x44>
c0100c7a:	ff 75 f4             	pushl  -0xc(%ebp)
c0100c7d:	ff 75 08             	pushl  0x8(%ebp)
c0100c80:	e8 1f fc ff ff       	call   c01008a4 <rb_tree_successor>
c0100c85:	83 c4 08             	add    $0x8,%esp
c0100c88:	eb 03                	jmp    c0100c8d <rb_delete+0x47>
c0100c8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c8d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    x = (y->left != nil) ? y->left : y->right;
c0100c90:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100c93:	8b 40 08             	mov    0x8(%eax),%eax
c0100c96:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0100c99:	74 08                	je     c0100ca3 <rb_delete+0x5d>
c0100c9b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100c9e:	8b 40 08             	mov    0x8(%eax),%eax
c0100ca1:	eb 06                	jmp    c0100ca9 <rb_delete+0x63>
c0100ca3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100ca6:	8b 40 0c             	mov    0xc(%eax),%eax
c0100ca9:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    assert(y != root && y != nil);
c0100cac:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100caf:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0100cb2:	74 08                	je     c0100cbc <rb_delete+0x76>
c0100cb4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100cb7:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0100cba:	75 19                	jne    c0100cd5 <rb_delete+0x8f>
c0100cbc:	68 40 ab 10 c0       	push   $0xc010ab40
c0100cc1:	68 b8 aa 10 c0       	push   $0xc010aab8
c0100cc6:	68 2f 01 00 00       	push   $0x12f
c0100ccb:	68 cd aa 10 c0       	push   $0xc010aacd
c0100cd0:	e8 87 0a 00 00       	call   c010175c <__panic>

    x->parent = y->parent;
c0100cd5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100cd8:	8b 50 04             	mov    0x4(%eax),%edx
c0100cdb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100cde:	89 50 04             	mov    %edx,0x4(%eax)
    if (y == y->parent->left) {
c0100ce1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100ce4:	8b 40 04             	mov    0x4(%eax),%eax
c0100ce7:	8b 40 08             	mov    0x8(%eax),%eax
c0100cea:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c0100ced:	75 0e                	jne    c0100cfd <rb_delete+0xb7>
        y->parent->left = x;
c0100cef:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100cf2:	8b 40 04             	mov    0x4(%eax),%eax
c0100cf5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100cf8:	89 50 08             	mov    %edx,0x8(%eax)
c0100cfb:	eb 0c                	jmp    c0100d09 <rb_delete+0xc3>
    }
    else {
        y->parent->right = x;
c0100cfd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100d00:	8b 40 04             	mov    0x4(%eax),%eax
c0100d03:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100d06:	89 50 0c             	mov    %edx,0xc(%eax)
    }

    bool need_fixup = !(y->red);
c0100d09:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100d0c:	8b 00                	mov    (%eax),%eax
c0100d0e:	85 c0                	test   %eax,%eax
c0100d10:	0f 94 c0             	sete   %al
c0100d13:	0f b6 c0             	movzbl %al,%eax
c0100d16:	89 45 e0             	mov    %eax,-0x20(%ebp)

    if (y != z) {
c0100d19:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100d1c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100d1f:	74 5c                	je     c0100d7d <rb_delete+0x137>
        if (z == z->parent->left) {
c0100d21:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d24:	8b 40 04             	mov    0x4(%eax),%eax
c0100d27:	8b 40 08             	mov    0x8(%eax),%eax
c0100d2a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100d2d:	75 0e                	jne    c0100d3d <rb_delete+0xf7>
            z->parent->left = y;
c0100d2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d32:	8b 40 04             	mov    0x4(%eax),%eax
c0100d35:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0100d38:	89 50 08             	mov    %edx,0x8(%eax)
c0100d3b:	eb 0c                	jmp    c0100d49 <rb_delete+0x103>
        }
        else {
            z->parent->right = y;
c0100d3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d40:	8b 40 04             	mov    0x4(%eax),%eax
c0100d43:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0100d46:	89 50 0c             	mov    %edx,0xc(%eax)
        }
        z->left->parent = z->right->parent = y;
c0100d49:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d4c:	8b 50 08             	mov    0x8(%eax),%edx
c0100d4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d52:	8b 40 0c             	mov    0xc(%eax),%eax
c0100d55:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c0100d58:	89 48 04             	mov    %ecx,0x4(%eax)
c0100d5b:	8b 40 04             	mov    0x4(%eax),%eax
c0100d5e:	89 42 04             	mov    %eax,0x4(%edx)
        *y = *z;
c0100d61:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100d64:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d67:	8b 0a                	mov    (%edx),%ecx
c0100d69:	89 08                	mov    %ecx,(%eax)
c0100d6b:	8b 4a 04             	mov    0x4(%edx),%ecx
c0100d6e:	89 48 04             	mov    %ecx,0x4(%eax)
c0100d71:	8b 4a 08             	mov    0x8(%edx),%ecx
c0100d74:	89 48 08             	mov    %ecx,0x8(%eax)
c0100d77:	8b 52 0c             	mov    0xc(%edx),%edx
c0100d7a:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    if (need_fixup) {
c0100d7d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0100d81:	74 11                	je     c0100d94 <rb_delete+0x14e>
        rb_delete_fixup(tree, x);
c0100d83:	83 ec 08             	sub    $0x8,%esp
c0100d86:	ff 75 e4             	pushl  -0x1c(%ebp)
c0100d89:	ff 75 08             	pushl  0x8(%ebp)
c0100d8c:	e8 73 fc ff ff       	call   c0100a04 <rb_delete_fixup>
c0100d91:	83 c4 10             	add    $0x10,%esp
    }
}
c0100d94:	90                   	nop
c0100d95:	c9                   	leave  
c0100d96:	c3                   	ret    

c0100d97 <rb_tree_destroy>:

/* rb_tree_destroy - destroy a tree and free memory */
void
rb_tree_destroy(rb_tree *tree) {
c0100d97:	55                   	push   %ebp
c0100d98:	89 e5                	mov    %esp,%ebp
c0100d9a:	83 ec 08             	sub    $0x8,%esp
    kfree(tree->root);
c0100d9d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100da0:	8b 40 08             	mov    0x8(%eax),%eax
c0100da3:	83 ec 0c             	sub    $0xc,%esp
c0100da6:	50                   	push   %eax
c0100da7:	e8 59 54 00 00       	call   c0106205 <kfree>
c0100dac:	83 c4 10             	add    $0x10,%esp
    kfree(tree->nil);
c0100daf:	8b 45 08             	mov    0x8(%ebp),%eax
c0100db2:	8b 40 04             	mov    0x4(%eax),%eax
c0100db5:	83 ec 0c             	sub    $0xc,%esp
c0100db8:	50                   	push   %eax
c0100db9:	e8 47 54 00 00       	call   c0106205 <kfree>
c0100dbe:	83 c4 10             	add    $0x10,%esp
    kfree(tree);
c0100dc1:	83 ec 0c             	sub    $0xc,%esp
c0100dc4:	ff 75 08             	pushl  0x8(%ebp)
c0100dc7:	e8 39 54 00 00       	call   c0106205 <kfree>
c0100dcc:	83 c4 10             	add    $0x10,%esp
}
c0100dcf:	90                   	nop
c0100dd0:	c9                   	leave  
c0100dd1:	c3                   	ret    

c0100dd2 <rb_node_prev>:
/* *
 * rb_node_prev - returns the predecessor node of @node in @tree,
 * or 'NULL' if no predecessor exists.
 * */
rb_node *
rb_node_prev(rb_tree *tree, rb_node *node) {
c0100dd2:	55                   	push   %ebp
c0100dd3:	89 e5                	mov    %esp,%ebp
c0100dd5:	83 ec 10             	sub    $0x10,%esp
    rb_node *prev = rb_tree_predecessor(tree, node);
c0100dd8:	ff 75 0c             	pushl  0xc(%ebp)
c0100ddb:	ff 75 08             	pushl  0x8(%ebp)
c0100dde:	e8 3c fb ff ff       	call   c010091f <rb_tree_predecessor>
c0100de3:	83 c4 08             	add    $0x8,%esp
c0100de6:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (prev != tree->nil) ? prev : NULL;
c0100de9:	8b 45 08             	mov    0x8(%ebp),%eax
c0100dec:	8b 40 04             	mov    0x4(%eax),%eax
c0100def:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100df2:	74 05                	je     c0100df9 <rb_node_prev+0x27>
c0100df4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100df7:	eb 05                	jmp    c0100dfe <rb_node_prev+0x2c>
c0100df9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100dfe:	c9                   	leave  
c0100dff:	c3                   	ret    

c0100e00 <rb_node_next>:
/* *
 * rb_node_next - returns the successor node of @node in @tree,
 * or 'NULL' if no successor exists.
 * */
rb_node *
rb_node_next(rb_tree *tree, rb_node *node) {
c0100e00:	55                   	push   %ebp
c0100e01:	89 e5                	mov    %esp,%ebp
c0100e03:	83 ec 10             	sub    $0x10,%esp
    rb_node *next = rb_tree_successor(tree, node);
c0100e06:	ff 75 0c             	pushl  0xc(%ebp)
c0100e09:	ff 75 08             	pushl  0x8(%ebp)
c0100e0c:	e8 93 fa ff ff       	call   c01008a4 <rb_tree_successor>
c0100e11:	83 c4 08             	add    $0x8,%esp
c0100e14:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (next != tree->nil) ? next : NULL;
c0100e17:	8b 45 08             	mov    0x8(%ebp),%eax
c0100e1a:	8b 40 04             	mov    0x4(%eax),%eax
c0100e1d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100e20:	74 05                	je     c0100e27 <rb_node_next+0x27>
c0100e22:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e25:	eb 05                	jmp    c0100e2c <rb_node_next+0x2c>
c0100e27:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e2c:	c9                   	leave  
c0100e2d:	c3                   	ret    

c0100e2e <rb_node_root>:

/* rb_node_root - returns the root node of a @tree, or 'NULL' if tree is empty */
rb_node *
rb_node_root(rb_tree *tree) {
c0100e2e:	55                   	push   %ebp
c0100e2f:	89 e5                	mov    %esp,%ebp
c0100e31:	83 ec 10             	sub    $0x10,%esp
    rb_node *node = tree->root->left;
c0100e34:	8b 45 08             	mov    0x8(%ebp),%eax
c0100e37:	8b 40 08             	mov    0x8(%eax),%eax
c0100e3a:	8b 40 08             	mov    0x8(%eax),%eax
c0100e3d:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (node != tree->nil) ? node : NULL;
c0100e40:	8b 45 08             	mov    0x8(%ebp),%eax
c0100e43:	8b 40 04             	mov    0x4(%eax),%eax
c0100e46:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100e49:	74 05                	je     c0100e50 <rb_node_root+0x22>
c0100e4b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e4e:	eb 05                	jmp    c0100e55 <rb_node_root+0x27>
c0100e50:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e55:	c9                   	leave  
c0100e56:	c3                   	ret    

c0100e57 <rb_node_left>:

/* rb_node_left - gets the left child of @node, or 'NULL' if no such node */
rb_node *
rb_node_left(rb_tree *tree, rb_node *node) {
c0100e57:	55                   	push   %ebp
c0100e58:	89 e5                	mov    %esp,%ebp
c0100e5a:	83 ec 10             	sub    $0x10,%esp
    rb_node *left = node->left;
c0100e5d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100e60:	8b 40 08             	mov    0x8(%eax),%eax
c0100e63:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (left != tree->nil) ? left : NULL;
c0100e66:	8b 45 08             	mov    0x8(%ebp),%eax
c0100e69:	8b 40 04             	mov    0x4(%eax),%eax
c0100e6c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100e6f:	74 05                	je     c0100e76 <rb_node_left+0x1f>
c0100e71:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e74:	eb 05                	jmp    c0100e7b <rb_node_left+0x24>
c0100e76:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e7b:	c9                   	leave  
c0100e7c:	c3                   	ret    

c0100e7d <rb_node_right>:

/* rb_node_right - gets the right child of @node, or 'NULL' if no such node */
rb_node *
rb_node_right(rb_tree *tree, rb_node *node) {
c0100e7d:	55                   	push   %ebp
c0100e7e:	89 e5                	mov    %esp,%ebp
c0100e80:	83 ec 10             	sub    $0x10,%esp
    rb_node *right = node->right;
c0100e83:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100e86:	8b 40 0c             	mov    0xc(%eax),%eax
c0100e89:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (right != tree->nil) ? right : NULL;
c0100e8c:	8b 45 08             	mov    0x8(%ebp),%eax
c0100e8f:	8b 40 04             	mov    0x4(%eax),%eax
c0100e92:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100e95:	74 05                	je     c0100e9c <rb_node_right+0x1f>
c0100e97:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e9a:	eb 05                	jmp    c0100ea1 <rb_node_right+0x24>
c0100e9c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100ea1:	c9                   	leave  
c0100ea2:	c3                   	ret    

c0100ea3 <check_tree>:

int
check_tree(rb_tree *tree, rb_node *node) {
c0100ea3:	55                   	push   %ebp
c0100ea4:	89 e5                	mov    %esp,%ebp
c0100ea6:	83 ec 18             	sub    $0x18,%esp
    rb_node *nil = tree->nil;
c0100ea9:	8b 45 08             	mov    0x8(%ebp),%eax
c0100eac:	8b 40 04             	mov    0x4(%eax),%eax
c0100eaf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (node == nil) {
c0100eb2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100eb5:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0100eb8:	75 2c                	jne    c0100ee6 <check_tree+0x43>
        assert(!node->red);
c0100eba:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100ebd:	8b 00                	mov    (%eax),%eax
c0100ebf:	85 c0                	test   %eax,%eax
c0100ec1:	74 19                	je     c0100edc <check_tree+0x39>
c0100ec3:	68 56 ab 10 c0       	push   $0xc010ab56
c0100ec8:	68 b8 aa 10 c0       	push   $0xc010aab8
c0100ecd:	68 7f 01 00 00       	push   $0x17f
c0100ed2:	68 cd aa 10 c0       	push   $0xc010aacd
c0100ed7:	e8 80 08 00 00       	call   c010175c <__panic>
        return 1;
c0100edc:	b8 01 00 00 00       	mov    $0x1,%eax
c0100ee1:	e9 6d 01 00 00       	jmp    c0101053 <check_tree+0x1b0>
    }
    if (node->left != nil) {
c0100ee6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100ee9:	8b 40 08             	mov    0x8(%eax),%eax
c0100eec:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0100eef:	74 5b                	je     c0100f4c <check_tree+0xa9>
        assert(COMPARE(tree, node, node->left) >= 0);
c0100ef1:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ef4:	8b 00                	mov    (%eax),%eax
c0100ef6:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100ef9:	8b 52 08             	mov    0x8(%edx),%edx
c0100efc:	83 ec 08             	sub    $0x8,%esp
c0100eff:	52                   	push   %edx
c0100f00:	ff 75 0c             	pushl  0xc(%ebp)
c0100f03:	ff d0                	call   *%eax
c0100f05:	83 c4 10             	add    $0x10,%esp
c0100f08:	85 c0                	test   %eax,%eax
c0100f0a:	79 19                	jns    c0100f25 <check_tree+0x82>
c0100f0c:	68 64 ab 10 c0       	push   $0xc010ab64
c0100f11:	68 b8 aa 10 c0       	push   $0xc010aab8
c0100f16:	68 83 01 00 00       	push   $0x183
c0100f1b:	68 cd aa 10 c0       	push   $0xc010aacd
c0100f20:	e8 37 08 00 00       	call   c010175c <__panic>
        assert(node->left->parent == node);
c0100f25:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100f28:	8b 40 08             	mov    0x8(%eax),%eax
c0100f2b:	8b 40 04             	mov    0x4(%eax),%eax
c0100f2e:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0100f31:	74 19                	je     c0100f4c <check_tree+0xa9>
c0100f33:	68 89 ab 10 c0       	push   $0xc010ab89
c0100f38:	68 b8 aa 10 c0       	push   $0xc010aab8
c0100f3d:	68 84 01 00 00       	push   $0x184
c0100f42:	68 cd aa 10 c0       	push   $0xc010aacd
c0100f47:	e8 10 08 00 00       	call   c010175c <__panic>
    }
    if (node->right != nil) {
c0100f4c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100f4f:	8b 40 0c             	mov    0xc(%eax),%eax
c0100f52:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0100f55:	74 5b                	je     c0100fb2 <check_tree+0x10f>
        assert(COMPARE(tree, node, node->right) <= 0);
c0100f57:	8b 45 08             	mov    0x8(%ebp),%eax
c0100f5a:	8b 00                	mov    (%eax),%eax
c0100f5c:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100f5f:	8b 52 0c             	mov    0xc(%edx),%edx
c0100f62:	83 ec 08             	sub    $0x8,%esp
c0100f65:	52                   	push   %edx
c0100f66:	ff 75 0c             	pushl  0xc(%ebp)
c0100f69:	ff d0                	call   *%eax
c0100f6b:	83 c4 10             	add    $0x10,%esp
c0100f6e:	85 c0                	test   %eax,%eax
c0100f70:	7e 19                	jle    c0100f8b <check_tree+0xe8>
c0100f72:	68 a4 ab 10 c0       	push   $0xc010aba4
c0100f77:	68 b8 aa 10 c0       	push   $0xc010aab8
c0100f7c:	68 87 01 00 00       	push   $0x187
c0100f81:	68 cd aa 10 c0       	push   $0xc010aacd
c0100f86:	e8 d1 07 00 00       	call   c010175c <__panic>
        assert(node->right->parent == node);
c0100f8b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100f8e:	8b 40 0c             	mov    0xc(%eax),%eax
c0100f91:	8b 40 04             	mov    0x4(%eax),%eax
c0100f94:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0100f97:	74 19                	je     c0100fb2 <check_tree+0x10f>
c0100f99:	68 ca ab 10 c0       	push   $0xc010abca
c0100f9e:	68 b8 aa 10 c0       	push   $0xc010aab8
c0100fa3:	68 88 01 00 00       	push   $0x188
c0100fa8:	68 cd aa 10 c0       	push   $0xc010aacd
c0100fad:	e8 aa 07 00 00       	call   c010175c <__panic>
    }
    if (node->red) {
c0100fb2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100fb5:	8b 00                	mov    (%eax),%eax
c0100fb7:	85 c0                	test   %eax,%eax
c0100fb9:	74 31                	je     c0100fec <check_tree+0x149>
        assert(!node->left->red && !node->right->red);
c0100fbb:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100fbe:	8b 40 08             	mov    0x8(%eax),%eax
c0100fc1:	8b 00                	mov    (%eax),%eax
c0100fc3:	85 c0                	test   %eax,%eax
c0100fc5:	75 0c                	jne    c0100fd3 <check_tree+0x130>
c0100fc7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100fca:	8b 40 0c             	mov    0xc(%eax),%eax
c0100fcd:	8b 00                	mov    (%eax),%eax
c0100fcf:	85 c0                	test   %eax,%eax
c0100fd1:	74 19                	je     c0100fec <check_tree+0x149>
c0100fd3:	68 e8 ab 10 c0       	push   $0xc010abe8
c0100fd8:	68 b8 aa 10 c0       	push   $0xc010aab8
c0100fdd:	68 8b 01 00 00       	push   $0x18b
c0100fe2:	68 cd aa 10 c0       	push   $0xc010aacd
c0100fe7:	e8 70 07 00 00       	call   c010175c <__panic>
    }
    int hb_left = check_tree(tree, node->left);
c0100fec:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100fef:	8b 40 08             	mov    0x8(%eax),%eax
c0100ff2:	83 ec 08             	sub    $0x8,%esp
c0100ff5:	50                   	push   %eax
c0100ff6:	ff 75 08             	pushl  0x8(%ebp)
c0100ff9:	e8 a5 fe ff ff       	call   c0100ea3 <check_tree>
c0100ffe:	83 c4 10             	add    $0x10,%esp
c0101001:	89 45 ec             	mov    %eax,-0x14(%ebp)
    int hb_right = check_tree(tree, node->right);
c0101004:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101007:	8b 40 0c             	mov    0xc(%eax),%eax
c010100a:	83 ec 08             	sub    $0x8,%esp
c010100d:	50                   	push   %eax
c010100e:	ff 75 08             	pushl  0x8(%ebp)
c0101011:	e8 8d fe ff ff       	call   c0100ea3 <check_tree>
c0101016:	83 c4 10             	add    $0x10,%esp
c0101019:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(hb_left == hb_right);
c010101c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010101f:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c0101022:	74 19                	je     c010103d <check_tree+0x19a>
c0101024:	68 0e ac 10 c0       	push   $0xc010ac0e
c0101029:	68 b8 aa 10 c0       	push   $0xc010aab8
c010102e:	68 8f 01 00 00       	push   $0x18f
c0101033:	68 cd aa 10 c0       	push   $0xc010aacd
c0101038:	e8 1f 07 00 00       	call   c010175c <__panic>
    int hb = hb_left;
c010103d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101040:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!node->red) {
c0101043:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101046:	8b 00                	mov    (%eax),%eax
c0101048:	85 c0                	test   %eax,%eax
c010104a:	75 04                	jne    c0101050 <check_tree+0x1ad>
        hb ++;
c010104c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    }
    return hb;
c0101050:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101053:	c9                   	leave  
c0101054:	c3                   	ret    

c0101055 <check_safe_kmalloc>:

static void *
check_safe_kmalloc(size_t size) {
c0101055:	55                   	push   %ebp
c0101056:	89 e5                	mov    %esp,%ebp
c0101058:	83 ec 18             	sub    $0x18,%esp
    void *ret = kmalloc(size);
c010105b:	83 ec 0c             	sub    $0xc,%esp
c010105e:	ff 75 08             	pushl  0x8(%ebp)
c0101061:	e8 87 51 00 00       	call   c01061ed <kmalloc>
c0101066:	83 c4 10             	add    $0x10,%esp
c0101069:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(ret != NULL);
c010106c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101070:	75 19                	jne    c010108b <check_safe_kmalloc+0x36>
c0101072:	68 22 ac 10 c0       	push   $0xc010ac22
c0101077:	68 b8 aa 10 c0       	push   $0xc010aab8
c010107c:	68 9a 01 00 00       	push   $0x19a
c0101081:	68 cd aa 10 c0       	push   $0xc010aacd
c0101086:	e8 d1 06 00 00       	call   c010175c <__panic>
    return ret;
c010108b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010108e:	c9                   	leave  
c010108f:	c3                   	ret    

c0101090 <check_compare1>:

#define rbn2data(node)              \
    (to_struct(node, struct check_data, rb_link))

static inline int
check_compare1(rb_node *node1, rb_node *node2) {
c0101090:	55                   	push   %ebp
c0101091:	89 e5                	mov    %esp,%ebp
    return rbn2data(node1)->data - rbn2data(node2)->data;
c0101093:	8b 45 08             	mov    0x8(%ebp),%eax
c0101096:	83 e8 04             	sub    $0x4,%eax
c0101099:	8b 10                	mov    (%eax),%edx
c010109b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010109e:	83 e8 04             	sub    $0x4,%eax
c01010a1:	8b 00                	mov    (%eax),%eax
c01010a3:	29 c2                	sub    %eax,%edx
c01010a5:	89 d0                	mov    %edx,%eax
}
c01010a7:	5d                   	pop    %ebp
c01010a8:	c3                   	ret    

c01010a9 <check_compare2>:

static inline int
check_compare2(rb_node *node, void *key) {
c01010a9:	55                   	push   %ebp
c01010aa:	89 e5                	mov    %esp,%ebp
    return rbn2data(node)->data - (long)key;
c01010ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01010af:	83 e8 04             	sub    $0x4,%eax
c01010b2:	8b 10                	mov    (%eax),%edx
c01010b4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01010b7:	29 c2                	sub    %eax,%edx
c01010b9:	89 d0                	mov    %edx,%eax
}
c01010bb:	5d                   	pop    %ebp
c01010bc:	c3                   	ret    

c01010bd <check_rb_tree>:

void
check_rb_tree(void) {
c01010bd:	55                   	push   %ebp
c01010be:	89 e5                	mov    %esp,%ebp
c01010c0:	53                   	push   %ebx
c01010c1:	83 ec 34             	sub    $0x34,%esp
    rb_tree *tree = rb_tree_create(check_compare1);
c01010c4:	83 ec 0c             	sub    $0xc,%esp
c01010c7:	68 90 10 10 c0       	push   $0xc0101090
c01010cc:	e8 8f f2 ff ff       	call   c0100360 <rb_tree_create>
c01010d1:	83 c4 10             	add    $0x10,%esp
c01010d4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(tree != NULL);
c01010d7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01010db:	75 19                	jne    c01010f6 <check_rb_tree+0x39>
c01010dd:	68 2e ac 10 c0       	push   $0xc010ac2e
c01010e2:	68 b8 aa 10 c0       	push   $0xc010aab8
c01010e7:	68 b3 01 00 00       	push   $0x1b3
c01010ec:	68 cd aa 10 c0       	push   $0xc010aacd
c01010f1:	e8 66 06 00 00       	call   c010175c <__panic>

    rb_node *nil = tree->nil, *root = tree->root;
c01010f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01010f9:	8b 40 04             	mov    0x4(%eax),%eax
c01010fc:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01010ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101102:	8b 40 08             	mov    0x8(%eax),%eax
c0101105:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(!nil->red && root->left == nil);
c0101108:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010110b:	8b 00                	mov    (%eax),%eax
c010110d:	85 c0                	test   %eax,%eax
c010110f:	75 0b                	jne    c010111c <check_rb_tree+0x5f>
c0101111:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101114:	8b 40 08             	mov    0x8(%eax),%eax
c0101117:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c010111a:	74 19                	je     c0101135 <check_rb_tree+0x78>
c010111c:	68 3c ac 10 c0       	push   $0xc010ac3c
c0101121:	68 b8 aa 10 c0       	push   $0xc010aab8
c0101126:	68 b6 01 00 00       	push   $0x1b6
c010112b:	68 cd aa 10 c0       	push   $0xc010aacd
c0101130:	e8 27 06 00 00       	call   c010175c <__panic>

    int total = 1000;
c0101135:	c7 45 e0 e8 03 00 00 	movl   $0x3e8,-0x20(%ebp)
    struct check_data **all = check_safe_kmalloc(sizeof(struct check_data *) * total);
c010113c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010113f:	c1 e0 02             	shl    $0x2,%eax
c0101142:	83 ec 0c             	sub    $0xc,%esp
c0101145:	50                   	push   %eax
c0101146:	e8 0a ff ff ff       	call   c0101055 <check_safe_kmalloc>
c010114b:	83 c4 10             	add    $0x10,%esp
c010114e:	89 45 dc             	mov    %eax,-0x24(%ebp)

    long i;
    for (i = 0; i < total; i ++) {
c0101151:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101158:	eb 39                	jmp    c0101193 <check_rb_tree+0xd6>
        all[i] = check_safe_kmalloc(sizeof(struct check_data));
c010115a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010115d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101164:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101167:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
c010116a:	83 ec 0c             	sub    $0xc,%esp
c010116d:	6a 14                	push   $0x14
c010116f:	e8 e1 fe ff ff       	call   c0101055 <check_safe_kmalloc>
c0101174:	83 c4 10             	add    $0x10,%esp
c0101177:	89 03                	mov    %eax,(%ebx)
        all[i]->data = i;
c0101179:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010117c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101183:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101186:	01 d0                	add    %edx,%eax
c0101188:	8b 00                	mov    (%eax),%eax
c010118a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010118d:	89 10                	mov    %edx,(%eax)

    int total = 1000;
    struct check_data **all = check_safe_kmalloc(sizeof(struct check_data *) * total);

    long i;
    for (i = 0; i < total; i ++) {
c010118f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101193:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101196:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0101199:	7c bf                	jl     c010115a <check_rb_tree+0x9d>
        all[i] = check_safe_kmalloc(sizeof(struct check_data));
        all[i]->data = i;
    }

    int *mark = check_safe_kmalloc(sizeof(int) * total);
c010119b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010119e:	c1 e0 02             	shl    $0x2,%eax
c01011a1:	83 ec 0c             	sub    $0xc,%esp
c01011a4:	50                   	push   %eax
c01011a5:	e8 ab fe ff ff       	call   c0101055 <check_safe_kmalloc>
c01011aa:	83 c4 10             	add    $0x10,%esp
c01011ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
    memset(mark, 0, sizeof(int) * total);
c01011b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01011b3:	c1 e0 02             	shl    $0x2,%eax
c01011b6:	83 ec 04             	sub    $0x4,%esp
c01011b9:	50                   	push   %eax
c01011ba:	6a 00                	push   $0x0
c01011bc:	ff 75 d8             	pushl  -0x28(%ebp)
c01011bf:	e8 94 8f 00 00       	call   c010a158 <memset>
c01011c4:	83 c4 10             	add    $0x10,%esp

    for (i = 0; i < total; i ++) {
c01011c7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01011ce:	eb 29                	jmp    c01011f9 <check_rb_tree+0x13c>
        mark[all[i]->data] = 1;
c01011d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01011d3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01011da:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01011dd:	01 d0                	add    %edx,%eax
c01011df:	8b 00                	mov    (%eax),%eax
c01011e1:	8b 00                	mov    (%eax),%eax
c01011e3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01011ea:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01011ed:	01 d0                	add    %edx,%eax
c01011ef:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
    }

    int *mark = check_safe_kmalloc(sizeof(int) * total);
    memset(mark, 0, sizeof(int) * total);

    for (i = 0; i < total; i ++) {
c01011f5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01011f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01011fc:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01011ff:	7c cf                	jl     c01011d0 <check_rb_tree+0x113>
        mark[all[i]->data] = 1;
    }
    for (i = 0; i < total; i ++) {
c0101201:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101208:	eb 33                	jmp    c010123d <check_rb_tree+0x180>
        assert(mark[i] == 1);
c010120a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010120d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101214:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0101217:	01 d0                	add    %edx,%eax
c0101219:	8b 00                	mov    (%eax),%eax
c010121b:	83 f8 01             	cmp    $0x1,%eax
c010121e:	74 19                	je     c0101239 <check_rb_tree+0x17c>
c0101220:	68 5b ac 10 c0       	push   $0xc010ac5b
c0101225:	68 b8 aa 10 c0       	push   $0xc010aab8
c010122a:	68 c8 01 00 00       	push   $0x1c8
c010122f:	68 cd aa 10 c0       	push   $0xc010aacd
c0101234:	e8 23 05 00 00       	call   c010175c <__panic>
    memset(mark, 0, sizeof(int) * total);

    for (i = 0; i < total; i ++) {
        mark[all[i]->data] = 1;
    }
    for (i = 0; i < total; i ++) {
c0101239:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010123d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101240:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0101243:	7c c5                	jl     c010120a <check_rb_tree+0x14d>
        assert(mark[i] == 1);
    }

    for (i = 0; i < total; i ++) {
c0101245:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010124c:	eb 6a                	jmp    c01012b8 <check_rb_tree+0x1fb>
        int j = (rand() % (total - i)) + i;
c010124e:	e8 c1 96 00 00       	call   c010a914 <rand>
c0101253:	89 c2                	mov    %eax,%edx
c0101255:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101258:	2b 45 f4             	sub    -0xc(%ebp),%eax
c010125b:	89 c1                	mov    %eax,%ecx
c010125d:	89 d0                	mov    %edx,%eax
c010125f:	99                   	cltd   
c0101260:	f7 f9                	idiv   %ecx
c0101262:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101265:	01 d0                	add    %edx,%eax
c0101267:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        struct check_data *z = all[i];
c010126a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010126d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101274:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101277:	01 d0                	add    %edx,%eax
c0101279:	8b 00                	mov    (%eax),%eax
c010127b:	89 45 d0             	mov    %eax,-0x30(%ebp)
        all[i] = all[j];
c010127e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101281:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101288:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010128b:	01 c2                	add    %eax,%edx
c010128d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101290:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
c0101297:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010129a:	01 c8                	add    %ecx,%eax
c010129c:	8b 00                	mov    (%eax),%eax
c010129e:	89 02                	mov    %eax,(%edx)
        all[j] = z;
c01012a0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01012a3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01012aa:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01012ad:	01 c2                	add    %eax,%edx
c01012af:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01012b2:	89 02                	mov    %eax,(%edx)
    }
    for (i = 0; i < total; i ++) {
        assert(mark[i] == 1);
    }

    for (i = 0; i < total; i ++) {
c01012b4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01012b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01012bb:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01012be:	7c 8e                	jl     c010124e <check_rb_tree+0x191>
        struct check_data *z = all[i];
        all[i] = all[j];
        all[j] = z;
    }

    memset(mark, 0, sizeof(int) * total);
c01012c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01012c3:	c1 e0 02             	shl    $0x2,%eax
c01012c6:	83 ec 04             	sub    $0x4,%esp
c01012c9:	50                   	push   %eax
c01012ca:	6a 00                	push   $0x0
c01012cc:	ff 75 d8             	pushl  -0x28(%ebp)
c01012cf:	e8 84 8e 00 00       	call   c010a158 <memset>
c01012d4:	83 c4 10             	add    $0x10,%esp
    for (i = 0; i < total; i ++) {
c01012d7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01012de:	eb 29                	jmp    c0101309 <check_rb_tree+0x24c>
        mark[all[i]->data] = 1;
c01012e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01012e3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01012ea:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01012ed:	01 d0                	add    %edx,%eax
c01012ef:	8b 00                	mov    (%eax),%eax
c01012f1:	8b 00                	mov    (%eax),%eax
c01012f3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01012fa:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01012fd:	01 d0                	add    %edx,%eax
c01012ff:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
        all[i] = all[j];
        all[j] = z;
    }

    memset(mark, 0, sizeof(int) * total);
    for (i = 0; i < total; i ++) {
c0101305:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101309:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010130c:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c010130f:	7c cf                	jl     c01012e0 <check_rb_tree+0x223>
        mark[all[i]->data] = 1;
    }
    for (i = 0; i < total; i ++) {
c0101311:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101318:	eb 33                	jmp    c010134d <check_rb_tree+0x290>
        assert(mark[i] == 1);
c010131a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010131d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101324:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0101327:	01 d0                	add    %edx,%eax
c0101329:	8b 00                	mov    (%eax),%eax
c010132b:	83 f8 01             	cmp    $0x1,%eax
c010132e:	74 19                	je     c0101349 <check_rb_tree+0x28c>
c0101330:	68 5b ac 10 c0       	push   $0xc010ac5b
c0101335:	68 b8 aa 10 c0       	push   $0xc010aab8
c010133a:	68 d7 01 00 00       	push   $0x1d7
c010133f:	68 cd aa 10 c0       	push   $0xc010aacd
c0101344:	e8 13 04 00 00       	call   c010175c <__panic>

    memset(mark, 0, sizeof(int) * total);
    for (i = 0; i < total; i ++) {
        mark[all[i]->data] = 1;
    }
    for (i = 0; i < total; i ++) {
c0101349:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010134d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101350:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0101353:	7c c5                	jl     c010131a <check_rb_tree+0x25d>
        assert(mark[i] == 1);
    }

    for (i = 0; i < total; i ++) {
c0101355:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010135c:	eb 3c                	jmp    c010139a <check_rb_tree+0x2dd>
        rb_insert(tree, &(all[i]->rb_link));
c010135e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101361:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101368:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010136b:	01 d0                	add    %edx,%eax
c010136d:	8b 00                	mov    (%eax),%eax
c010136f:	83 c0 04             	add    $0x4,%eax
c0101372:	83 ec 08             	sub    $0x8,%esp
c0101375:	50                   	push   %eax
c0101376:	ff 75 ec             	pushl  -0x14(%ebp)
c0101379:	e8 3c f3 ff ff       	call   c01006ba <rb_insert>
c010137e:	83 c4 10             	add    $0x10,%esp
        check_tree(tree, root->left);
c0101381:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101384:	8b 40 08             	mov    0x8(%eax),%eax
c0101387:	83 ec 08             	sub    $0x8,%esp
c010138a:	50                   	push   %eax
c010138b:	ff 75 ec             	pushl  -0x14(%ebp)
c010138e:	e8 10 fb ff ff       	call   c0100ea3 <check_tree>
c0101393:	83 c4 10             	add    $0x10,%esp
    }
    for (i = 0; i < total; i ++) {
        assert(mark[i] == 1);
    }

    for (i = 0; i < total; i ++) {
c0101396:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010139a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010139d:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01013a0:	7c bc                	jl     c010135e <check_rb_tree+0x2a1>
        rb_insert(tree, &(all[i]->rb_link));
        check_tree(tree, root->left);
    }

    rb_node *node;
    for (i = 0; i < total; i ++) {
c01013a2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01013a9:	eb 66                	jmp    c0101411 <check_rb_tree+0x354>
        node = rb_search(tree, check_compare2, (void *)(all[i]->data));
c01013ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01013ae:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01013b5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01013b8:	01 d0                	add    %edx,%eax
c01013ba:	8b 00                	mov    (%eax),%eax
c01013bc:	8b 00                	mov    (%eax),%eax
c01013be:	83 ec 04             	sub    $0x4,%esp
c01013c1:	50                   	push   %eax
c01013c2:	68 a9 10 10 c0       	push   $0xc01010a9
c01013c7:	ff 75 ec             	pushl  -0x14(%ebp)
c01013ca:	e8 cb f5 ff ff       	call   c010099a <rb_search>
c01013cf:	83 c4 10             	add    $0x10,%esp
c01013d2:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(node != NULL && node == &(all[i]->rb_link));
c01013d5:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01013d9:	74 19                	je     c01013f4 <check_rb_tree+0x337>
c01013db:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01013de:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01013e5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01013e8:	01 d0                	add    %edx,%eax
c01013ea:	8b 00                	mov    (%eax),%eax
c01013ec:	83 c0 04             	add    $0x4,%eax
c01013ef:	3b 45 cc             	cmp    -0x34(%ebp),%eax
c01013f2:	74 19                	je     c010140d <check_rb_tree+0x350>
c01013f4:	68 68 ac 10 c0       	push   $0xc010ac68
c01013f9:	68 b8 aa 10 c0       	push   $0xc010aab8
c01013fe:	68 e2 01 00 00       	push   $0x1e2
c0101403:	68 cd aa 10 c0       	push   $0xc010aacd
c0101408:	e8 4f 03 00 00       	call   c010175c <__panic>
        rb_insert(tree, &(all[i]->rb_link));
        check_tree(tree, root->left);
    }

    rb_node *node;
    for (i = 0; i < total; i ++) {
c010140d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101411:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101414:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0101417:	7c 92                	jl     c01013ab <check_rb_tree+0x2ee>
        node = rb_search(tree, check_compare2, (void *)(all[i]->data));
        assert(node != NULL && node == &(all[i]->rb_link));
    }

    for (i = 0; i < total; i ++) {
c0101419:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101420:	eb 70                	jmp    c0101492 <check_rb_tree+0x3d5>
        node = rb_search(tree, check_compare2, (void *)i);
c0101422:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101425:	83 ec 04             	sub    $0x4,%esp
c0101428:	50                   	push   %eax
c0101429:	68 a9 10 10 c0       	push   $0xc01010a9
c010142e:	ff 75 ec             	pushl  -0x14(%ebp)
c0101431:	e8 64 f5 ff ff       	call   c010099a <rb_search>
c0101436:	83 c4 10             	add    $0x10,%esp
c0101439:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(node != NULL && rbn2data(node)->data == i);
c010143c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0101440:	74 0d                	je     c010144f <check_rb_tree+0x392>
c0101442:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0101445:	83 e8 04             	sub    $0x4,%eax
c0101448:	8b 00                	mov    (%eax),%eax
c010144a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010144d:	74 19                	je     c0101468 <check_rb_tree+0x3ab>
c010144f:	68 94 ac 10 c0       	push   $0xc010ac94
c0101454:	68 b8 aa 10 c0       	push   $0xc010aab8
c0101459:	68 e7 01 00 00       	push   $0x1e7
c010145e:	68 cd aa 10 c0       	push   $0xc010aacd
c0101463:	e8 f4 02 00 00       	call   c010175c <__panic>
        rb_delete(tree, node);
c0101468:	83 ec 08             	sub    $0x8,%esp
c010146b:	ff 75 cc             	pushl  -0x34(%ebp)
c010146e:	ff 75 ec             	pushl  -0x14(%ebp)
c0101471:	e8 d0 f7 ff ff       	call   c0100c46 <rb_delete>
c0101476:	83 c4 10             	add    $0x10,%esp
        check_tree(tree, root->left);
c0101479:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010147c:	8b 40 08             	mov    0x8(%eax),%eax
c010147f:	83 ec 08             	sub    $0x8,%esp
c0101482:	50                   	push   %eax
c0101483:	ff 75 ec             	pushl  -0x14(%ebp)
c0101486:	e8 18 fa ff ff       	call   c0100ea3 <check_tree>
c010148b:	83 c4 10             	add    $0x10,%esp
    for (i = 0; i < total; i ++) {
        node = rb_search(tree, check_compare2, (void *)(all[i]->data));
        assert(node != NULL && node == &(all[i]->rb_link));
    }

    for (i = 0; i < total; i ++) {
c010148e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101492:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101495:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0101498:	7c 88                	jl     c0101422 <check_rb_tree+0x365>
        assert(node != NULL && rbn2data(node)->data == i);
        rb_delete(tree, node);
        check_tree(tree, root->left);
    }

    assert(!nil->red && root->left == nil);
c010149a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010149d:	8b 00                	mov    (%eax),%eax
c010149f:	85 c0                	test   %eax,%eax
c01014a1:	75 0b                	jne    c01014ae <check_rb_tree+0x3f1>
c01014a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01014a6:	8b 40 08             	mov    0x8(%eax),%eax
c01014a9:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c01014ac:	74 19                	je     c01014c7 <check_rb_tree+0x40a>
c01014ae:	68 3c ac 10 c0       	push   $0xc010ac3c
c01014b3:	68 b8 aa 10 c0       	push   $0xc010aab8
c01014b8:	68 ec 01 00 00       	push   $0x1ec
c01014bd:	68 cd aa 10 c0       	push   $0xc010aacd
c01014c2:	e8 95 02 00 00       	call   c010175c <__panic>

    long max = 32;
c01014c7:	c7 45 f0 20 00 00 00 	movl   $0x20,-0x10(%ebp)
    if (max > total) {
c01014ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01014d1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01014d4:	7e 06                	jle    c01014dc <check_rb_tree+0x41f>
        max = total;
c01014d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01014d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }

    for (i = 0; i < max; i ++) {
c01014dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01014e3:	eb 52                	jmp    c0101537 <check_rb_tree+0x47a>
        all[i]->data = max;
c01014e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01014e8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01014ef:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01014f2:	01 d0                	add    %edx,%eax
c01014f4:	8b 00                	mov    (%eax),%eax
c01014f6:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01014f9:	89 10                	mov    %edx,(%eax)
        rb_insert(tree, &(all[i]->rb_link));
c01014fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01014fe:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101505:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101508:	01 d0                	add    %edx,%eax
c010150a:	8b 00                	mov    (%eax),%eax
c010150c:	83 c0 04             	add    $0x4,%eax
c010150f:	83 ec 08             	sub    $0x8,%esp
c0101512:	50                   	push   %eax
c0101513:	ff 75 ec             	pushl  -0x14(%ebp)
c0101516:	e8 9f f1 ff ff       	call   c01006ba <rb_insert>
c010151b:	83 c4 10             	add    $0x10,%esp
        check_tree(tree, root->left);
c010151e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101521:	8b 40 08             	mov    0x8(%eax),%eax
c0101524:	83 ec 08             	sub    $0x8,%esp
c0101527:	50                   	push   %eax
c0101528:	ff 75 ec             	pushl  -0x14(%ebp)
c010152b:	e8 73 f9 ff ff       	call   c0100ea3 <check_tree>
c0101530:	83 c4 10             	add    $0x10,%esp
    long max = 32;
    if (max > total) {
        max = total;
    }

    for (i = 0; i < max; i ++) {
c0101533:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101537:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010153a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010153d:	7c a6                	jl     c01014e5 <check_rb_tree+0x428>
        all[i]->data = max;
        rb_insert(tree, &(all[i]->rb_link));
        check_tree(tree, root->left);
    }

    for (i = 0; i < max; i ++) {
c010153f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101546:	eb 70                	jmp    c01015b8 <check_rb_tree+0x4fb>
        node = rb_search(tree, check_compare2, (void *)max);
c0101548:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010154b:	83 ec 04             	sub    $0x4,%esp
c010154e:	50                   	push   %eax
c010154f:	68 a9 10 10 c0       	push   $0xc01010a9
c0101554:	ff 75 ec             	pushl  -0x14(%ebp)
c0101557:	e8 3e f4 ff ff       	call   c010099a <rb_search>
c010155c:	83 c4 10             	add    $0x10,%esp
c010155f:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(node != NULL && rbn2data(node)->data == max);
c0101562:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0101566:	74 0d                	je     c0101575 <check_rb_tree+0x4b8>
c0101568:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010156b:	83 e8 04             	sub    $0x4,%eax
c010156e:	8b 00                	mov    (%eax),%eax
c0101570:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0101573:	74 19                	je     c010158e <check_rb_tree+0x4d1>
c0101575:	68 c0 ac 10 c0       	push   $0xc010acc0
c010157a:	68 b8 aa 10 c0       	push   $0xc010aab8
c010157f:	68 fb 01 00 00       	push   $0x1fb
c0101584:	68 cd aa 10 c0       	push   $0xc010aacd
c0101589:	e8 ce 01 00 00       	call   c010175c <__panic>
        rb_delete(tree, node);
c010158e:	83 ec 08             	sub    $0x8,%esp
c0101591:	ff 75 cc             	pushl  -0x34(%ebp)
c0101594:	ff 75 ec             	pushl  -0x14(%ebp)
c0101597:	e8 aa f6 ff ff       	call   c0100c46 <rb_delete>
c010159c:	83 c4 10             	add    $0x10,%esp
        check_tree(tree, root->left);
c010159f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01015a2:	8b 40 08             	mov    0x8(%eax),%eax
c01015a5:	83 ec 08             	sub    $0x8,%esp
c01015a8:	50                   	push   %eax
c01015a9:	ff 75 ec             	pushl  -0x14(%ebp)
c01015ac:	e8 f2 f8 ff ff       	call   c0100ea3 <check_tree>
c01015b1:	83 c4 10             	add    $0x10,%esp
        all[i]->data = max;
        rb_insert(tree, &(all[i]->rb_link));
        check_tree(tree, root->left);
    }

    for (i = 0; i < max; i ++) {
c01015b4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01015b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01015bb:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01015be:	7c 88                	jl     c0101548 <check_rb_tree+0x48b>
        assert(node != NULL && rbn2data(node)->data == max);
        rb_delete(tree, node);
        check_tree(tree, root->left);
    }

    assert(rb_tree_empty(tree));
c01015c0:	83 ec 0c             	sub    $0xc,%esp
c01015c3:	ff 75 ec             	pushl  -0x14(%ebp)
c01015c6:	e8 6c ed ff ff       	call   c0100337 <rb_tree_empty>
c01015cb:	83 c4 10             	add    $0x10,%esp
c01015ce:	85 c0                	test   %eax,%eax
c01015d0:	75 19                	jne    c01015eb <check_rb_tree+0x52e>
c01015d2:	68 ec ac 10 c0       	push   $0xc010acec
c01015d7:	68 b8 aa 10 c0       	push   $0xc010aab8
c01015dc:	68 00 02 00 00       	push   $0x200
c01015e1:	68 cd aa 10 c0       	push   $0xc010aacd
c01015e6:	e8 71 01 00 00       	call   c010175c <__panic>

    for (i = 0; i < total; i ++) {
c01015eb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01015f2:	eb 3c                	jmp    c0101630 <check_rb_tree+0x573>
        rb_insert(tree, &(all[i]->rb_link));
c01015f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01015f7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01015fe:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101601:	01 d0                	add    %edx,%eax
c0101603:	8b 00                	mov    (%eax),%eax
c0101605:	83 c0 04             	add    $0x4,%eax
c0101608:	83 ec 08             	sub    $0x8,%esp
c010160b:	50                   	push   %eax
c010160c:	ff 75 ec             	pushl  -0x14(%ebp)
c010160f:	e8 a6 f0 ff ff       	call   c01006ba <rb_insert>
c0101614:	83 c4 10             	add    $0x10,%esp
        check_tree(tree, root->left);
c0101617:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010161a:	8b 40 08             	mov    0x8(%eax),%eax
c010161d:	83 ec 08             	sub    $0x8,%esp
c0101620:	50                   	push   %eax
c0101621:	ff 75 ec             	pushl  -0x14(%ebp)
c0101624:	e8 7a f8 ff ff       	call   c0100ea3 <check_tree>
c0101629:	83 c4 10             	add    $0x10,%esp
        check_tree(tree, root->left);
    }

    assert(rb_tree_empty(tree));

    for (i = 0; i < total; i ++) {
c010162c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101630:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101633:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0101636:	7c bc                	jl     c01015f4 <check_rb_tree+0x537>
        rb_insert(tree, &(all[i]->rb_link));
        check_tree(tree, root->left);
    }

    rb_tree_destroy(tree);
c0101638:	83 ec 0c             	sub    $0xc,%esp
c010163b:	ff 75 ec             	pushl  -0x14(%ebp)
c010163e:	e8 54 f7 ff ff       	call   c0100d97 <rb_tree_destroy>
c0101643:	83 c4 10             	add    $0x10,%esp

    for (i = 0; i < total; i ++) {
c0101646:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010164d:	eb 21                	jmp    c0101670 <check_rb_tree+0x5b3>
        kfree(all[i]);
c010164f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101652:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101659:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010165c:	01 d0                	add    %edx,%eax
c010165e:	8b 00                	mov    (%eax),%eax
c0101660:	83 ec 0c             	sub    $0xc,%esp
c0101663:	50                   	push   %eax
c0101664:	e8 9c 4b 00 00       	call   c0106205 <kfree>
c0101669:	83 c4 10             	add    $0x10,%esp
        check_tree(tree, root->left);
    }

    rb_tree_destroy(tree);

    for (i = 0; i < total; i ++) {
c010166c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101670:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101673:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0101676:	7c d7                	jl     c010164f <check_rb_tree+0x592>
        kfree(all[i]);
    }

    kfree(mark);
c0101678:	83 ec 0c             	sub    $0xc,%esp
c010167b:	ff 75 d8             	pushl  -0x28(%ebp)
c010167e:	e8 82 4b 00 00       	call   c0106205 <kfree>
c0101683:	83 c4 10             	add    $0x10,%esp
    kfree(all);
c0101686:	83 ec 0c             	sub    $0xc,%esp
c0101689:	ff 75 dc             	pushl  -0x24(%ebp)
c010168c:	e8 74 4b 00 00       	call   c0106205 <kfree>
c0101691:	83 c4 10             	add    $0x10,%esp
}
c0101694:	90                   	nop
c0101695:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0101698:	c9                   	leave  
c0101699:	c3                   	ret    

c010169a <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c010169a:	55                   	push   %ebp
c010169b:	89 e5                	mov    %esp,%ebp
c010169d:	83 ec 18             	sub    $0x18,%esp
    if (prompt != NULL) {
c01016a0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01016a4:	74 13                	je     c01016b9 <readline+0x1f>
        cprintf("%s", prompt);
c01016a6:	83 ec 08             	sub    $0x8,%esp
c01016a9:	ff 75 08             	pushl  0x8(%ebp)
c01016ac:	68 00 ad 10 c0       	push   $0xc010ad00
c01016b1:	e8 c8 eb ff ff       	call   c010027e <cprintf>
c01016b6:	83 c4 10             	add    $0x10,%esp
    }
    int i = 0, c;
c01016b9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c01016c0:	e8 44 ec ff ff       	call   c0100309 <getchar>
c01016c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c01016c8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01016cc:	79 0a                	jns    c01016d8 <readline+0x3e>
            return NULL;
c01016ce:	b8 00 00 00 00       	mov    $0x0,%eax
c01016d3:	e9 82 00 00 00       	jmp    c010175a <readline+0xc0>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c01016d8:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c01016dc:	7e 2b                	jle    c0101709 <readline+0x6f>
c01016de:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c01016e5:	7f 22                	jg     c0101709 <readline+0x6f>
            cputchar(c);
c01016e7:	83 ec 0c             	sub    $0xc,%esp
c01016ea:	ff 75 f0             	pushl  -0x10(%ebp)
c01016ed:	e8 b2 eb ff ff       	call   c01002a4 <cputchar>
c01016f2:	83 c4 10             	add    $0x10,%esp
            buf[i ++] = c;
c01016f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01016f8:	8d 50 01             	lea    0x1(%eax),%edx
c01016fb:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01016fe:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0101701:	88 90 c0 7a 12 c0    	mov    %dl,-0x3fed8540(%eax)
c0101707:	eb 4c                	jmp    c0101755 <readline+0xbb>
        }
        else if (c == '\b' && i > 0) {
c0101709:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c010170d:	75 1a                	jne    c0101729 <readline+0x8f>
c010170f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101713:	7e 14                	jle    c0101729 <readline+0x8f>
            cputchar(c);
c0101715:	83 ec 0c             	sub    $0xc,%esp
c0101718:	ff 75 f0             	pushl  -0x10(%ebp)
c010171b:	e8 84 eb ff ff       	call   c01002a4 <cputchar>
c0101720:	83 c4 10             	add    $0x10,%esp
            i --;
c0101723:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0101727:	eb 2c                	jmp    c0101755 <readline+0xbb>
        }
        else if (c == '\n' || c == '\r') {
c0101729:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c010172d:	74 06                	je     c0101735 <readline+0x9b>
c010172f:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c0101733:	75 8b                	jne    c01016c0 <readline+0x26>
            cputchar(c);
c0101735:	83 ec 0c             	sub    $0xc,%esp
c0101738:	ff 75 f0             	pushl  -0x10(%ebp)
c010173b:	e8 64 eb ff ff       	call   c01002a4 <cputchar>
c0101740:	83 c4 10             	add    $0x10,%esp
            buf[i] = '\0';
c0101743:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101746:	05 c0 7a 12 c0       	add    $0xc0127ac0,%eax
c010174b:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c010174e:	b8 c0 7a 12 c0       	mov    $0xc0127ac0,%eax
c0101753:	eb 05                	jmp    c010175a <readline+0xc0>
        }
    }
c0101755:	e9 66 ff ff ff       	jmp    c01016c0 <readline+0x26>
}
c010175a:	c9                   	leave  
c010175b:	c3                   	ret    

c010175c <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c010175c:	55                   	push   %ebp
c010175d:	89 e5                	mov    %esp,%ebp
c010175f:	83 ec 18             	sub    $0x18,%esp
    if (is_panic) {
c0101762:	a1 c0 7e 12 c0       	mov    0xc0127ec0,%eax
c0101767:	85 c0                	test   %eax,%eax
c0101769:	75 4a                	jne    c01017b5 <__panic+0x59>
        goto panic_dead;
    }
    is_panic = 1;
c010176b:	c7 05 c0 7e 12 c0 01 	movl   $0x1,0xc0127ec0
c0101772:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0101775:	8d 45 14             	lea    0x14(%ebp),%eax
c0101778:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c010177b:	83 ec 04             	sub    $0x4,%esp
c010177e:	ff 75 0c             	pushl  0xc(%ebp)
c0101781:	ff 75 08             	pushl  0x8(%ebp)
c0101784:	68 03 ad 10 c0       	push   $0xc010ad03
c0101789:	e8 f0 ea ff ff       	call   c010027e <cprintf>
c010178e:	83 c4 10             	add    $0x10,%esp
    vcprintf(fmt, ap);
c0101791:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101794:	83 ec 08             	sub    $0x8,%esp
c0101797:	50                   	push   %eax
c0101798:	ff 75 10             	pushl  0x10(%ebp)
c010179b:	e8 b5 ea ff ff       	call   c0100255 <vcprintf>
c01017a0:	83 c4 10             	add    $0x10,%esp
    cprintf("\n");
c01017a3:	83 ec 0c             	sub    $0xc,%esp
c01017a6:	68 1f ad 10 c0       	push   $0xc010ad1f
c01017ab:	e8 ce ea ff ff       	call   c010027e <cprintf>
c01017b0:	83 c4 10             	add    $0x10,%esp
c01017b3:	eb 01                	jmp    c01017b6 <__panic+0x5a>
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
        goto panic_dead;
c01017b5:	90                   	nop
    vcprintf(fmt, ap);
    cprintf("\n");
    va_end(ap);

panic_dead:
    intr_disable();
c01017b6:	e8 6d 1c 00 00       	call   c0103428 <intr_disable>
    while (1) {
        kmonitor(NULL);
c01017bb:	83 ec 0c             	sub    $0xc,%esp
c01017be:	6a 00                	push   $0x0
c01017c0:	e8 36 08 00 00       	call   c0101ffb <kmonitor>
c01017c5:	83 c4 10             	add    $0x10,%esp
    }
c01017c8:	eb f1                	jmp    c01017bb <__panic+0x5f>

c01017ca <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c01017ca:	55                   	push   %ebp
c01017cb:	89 e5                	mov    %esp,%ebp
c01017cd:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    va_start(ap, fmt);
c01017d0:	8d 45 14             	lea    0x14(%ebp),%eax
c01017d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c01017d6:	83 ec 04             	sub    $0x4,%esp
c01017d9:	ff 75 0c             	pushl  0xc(%ebp)
c01017dc:	ff 75 08             	pushl  0x8(%ebp)
c01017df:	68 21 ad 10 c0       	push   $0xc010ad21
c01017e4:	e8 95 ea ff ff       	call   c010027e <cprintf>
c01017e9:	83 c4 10             	add    $0x10,%esp
    vcprintf(fmt, ap);
c01017ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01017ef:	83 ec 08             	sub    $0x8,%esp
c01017f2:	50                   	push   %eax
c01017f3:	ff 75 10             	pushl  0x10(%ebp)
c01017f6:	e8 5a ea ff ff       	call   c0100255 <vcprintf>
c01017fb:	83 c4 10             	add    $0x10,%esp
    cprintf("\n");
c01017fe:	83 ec 0c             	sub    $0xc,%esp
c0101801:	68 1f ad 10 c0       	push   $0xc010ad1f
c0101806:	e8 73 ea ff ff       	call   c010027e <cprintf>
c010180b:	83 c4 10             	add    $0x10,%esp
    va_end(ap);
}
c010180e:	90                   	nop
c010180f:	c9                   	leave  
c0101810:	c3                   	ret    

c0101811 <is_kernel_panic>:

bool
is_kernel_panic(void) {
c0101811:	55                   	push   %ebp
c0101812:	89 e5                	mov    %esp,%ebp
    return is_panic;
c0101814:	a1 c0 7e 12 c0       	mov    0xc0127ec0,%eax
}
c0101819:	5d                   	pop    %ebp
c010181a:	c3                   	ret    

c010181b <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c010181b:	55                   	push   %ebp
c010181c:	89 e5                	mov    %esp,%ebp
c010181e:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c0101821:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101824:	8b 00                	mov    (%eax),%eax
c0101826:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0101829:	8b 45 10             	mov    0x10(%ebp),%eax
c010182c:	8b 00                	mov    (%eax),%eax
c010182e:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0101831:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c0101838:	e9 d2 00 00 00       	jmp    c010190f <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
c010183d:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0101840:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0101843:	01 d0                	add    %edx,%eax
c0101845:	89 c2                	mov    %eax,%edx
c0101847:	c1 ea 1f             	shr    $0x1f,%edx
c010184a:	01 d0                	add    %edx,%eax
c010184c:	d1 f8                	sar    %eax
c010184e:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0101851:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101854:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0101857:	eb 04                	jmp    c010185d <stab_binsearch+0x42>
            m --;
c0101859:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c010185d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101860:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0101863:	7c 1f                	jl     c0101884 <stab_binsearch+0x69>
c0101865:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0101868:	89 d0                	mov    %edx,%eax
c010186a:	01 c0                	add    %eax,%eax
c010186c:	01 d0                	add    %edx,%eax
c010186e:	c1 e0 02             	shl    $0x2,%eax
c0101871:	89 c2                	mov    %eax,%edx
c0101873:	8b 45 08             	mov    0x8(%ebp),%eax
c0101876:	01 d0                	add    %edx,%eax
c0101878:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010187c:	0f b6 c0             	movzbl %al,%eax
c010187f:	3b 45 14             	cmp    0x14(%ebp),%eax
c0101882:	75 d5                	jne    c0101859 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
c0101884:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101887:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010188a:	7d 0b                	jge    c0101897 <stab_binsearch+0x7c>
            l = true_m + 1;
c010188c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010188f:	83 c0 01             	add    $0x1,%eax
c0101892:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c0101895:	eb 78                	jmp    c010190f <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
c0101897:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c010189e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01018a1:	89 d0                	mov    %edx,%eax
c01018a3:	01 c0                	add    %eax,%eax
c01018a5:	01 d0                	add    %edx,%eax
c01018a7:	c1 e0 02             	shl    $0x2,%eax
c01018aa:	89 c2                	mov    %eax,%edx
c01018ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01018af:	01 d0                	add    %edx,%eax
c01018b1:	8b 40 08             	mov    0x8(%eax),%eax
c01018b4:	3b 45 18             	cmp    0x18(%ebp),%eax
c01018b7:	73 13                	jae    c01018cc <stab_binsearch+0xb1>
            *region_left = m;
c01018b9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01018bc:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01018bf:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c01018c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01018c4:	83 c0 01             	add    $0x1,%eax
c01018c7:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01018ca:	eb 43                	jmp    c010190f <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
c01018cc:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01018cf:	89 d0                	mov    %edx,%eax
c01018d1:	01 c0                	add    %eax,%eax
c01018d3:	01 d0                	add    %edx,%eax
c01018d5:	c1 e0 02             	shl    $0x2,%eax
c01018d8:	89 c2                	mov    %eax,%edx
c01018da:	8b 45 08             	mov    0x8(%ebp),%eax
c01018dd:	01 d0                	add    %edx,%eax
c01018df:	8b 40 08             	mov    0x8(%eax),%eax
c01018e2:	3b 45 18             	cmp    0x18(%ebp),%eax
c01018e5:	76 16                	jbe    c01018fd <stab_binsearch+0xe2>
            *region_right = m - 1;
c01018e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01018ea:	8d 50 ff             	lea    -0x1(%eax),%edx
c01018ed:	8b 45 10             	mov    0x10(%ebp),%eax
c01018f0:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c01018f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01018f5:	83 e8 01             	sub    $0x1,%eax
c01018f8:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01018fb:	eb 12                	jmp    c010190f <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01018fd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101900:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0101903:	89 10                	mov    %edx,(%eax)
            l = m;
c0101905:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101908:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c010190b:	83 45 18 01          	addl   $0x1,0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
c010190f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101912:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0101915:	0f 8e 22 ff ff ff    	jle    c010183d <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
c010191b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010191f:	75 0f                	jne    c0101930 <stab_binsearch+0x115>
        *region_right = *region_left - 1;
c0101921:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101924:	8b 00                	mov    (%eax),%eax
c0101926:	8d 50 ff             	lea    -0x1(%eax),%edx
c0101929:	8b 45 10             	mov    0x10(%ebp),%eax
c010192c:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
c010192e:	eb 3f                	jmp    c010196f <stab_binsearch+0x154>
    if (!any_matches) {
        *region_right = *region_left - 1;
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
c0101930:	8b 45 10             	mov    0x10(%ebp),%eax
c0101933:	8b 00                	mov    (%eax),%eax
c0101935:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c0101938:	eb 04                	jmp    c010193e <stab_binsearch+0x123>
c010193a:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
c010193e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101941:	8b 00                	mov    (%eax),%eax
c0101943:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0101946:	7d 1f                	jge    c0101967 <stab_binsearch+0x14c>
c0101948:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010194b:	89 d0                	mov    %edx,%eax
c010194d:	01 c0                	add    %eax,%eax
c010194f:	01 d0                	add    %edx,%eax
c0101951:	c1 e0 02             	shl    $0x2,%eax
c0101954:	89 c2                	mov    %eax,%edx
c0101956:	8b 45 08             	mov    0x8(%ebp),%eax
c0101959:	01 d0                	add    %edx,%eax
c010195b:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010195f:	0f b6 c0             	movzbl %al,%eax
c0101962:	3b 45 14             	cmp    0x14(%ebp),%eax
c0101965:	75 d3                	jne    c010193a <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
c0101967:	8b 45 0c             	mov    0xc(%ebp),%eax
c010196a:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010196d:	89 10                	mov    %edx,(%eax)
    }
}
c010196f:	90                   	nop
c0101970:	c9                   	leave  
c0101971:	c3                   	ret    

c0101972 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c0101972:	55                   	push   %ebp
c0101973:	89 e5                	mov    %esp,%ebp
c0101975:	83 ec 38             	sub    $0x38,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c0101978:	8b 45 0c             	mov    0xc(%ebp),%eax
c010197b:	c7 00 40 ad 10 c0    	movl   $0xc010ad40,(%eax)
    info->eip_line = 0;
c0101981:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101984:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c010198b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010198e:	c7 40 08 40 ad 10 c0 	movl   $0xc010ad40,0x8(%eax)
    info->eip_fn_namelen = 9;
c0101995:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101998:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c010199f:	8b 45 0c             	mov    0xc(%ebp),%eax
c01019a2:	8b 55 08             	mov    0x8(%ebp),%edx
c01019a5:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c01019a8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01019ab:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c01019b2:	c7 45 f4 10 cf 10 c0 	movl   $0xc010cf10,-0xc(%ebp)
    stab_end = __STAB_END__;
c01019b9:	c7 45 f0 7c 01 12 c0 	movl   $0xc012017c,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c01019c0:	c7 45 ec 7d 01 12 c0 	movl   $0xc012017d,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c01019c7:	c7 45 e8 f9 4e 12 c0 	movl   $0xc0124ef9,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c01019ce:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01019d1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01019d4:	76 0d                	jbe    c01019e3 <debuginfo_eip+0x71>
c01019d6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01019d9:	83 e8 01             	sub    $0x1,%eax
c01019dc:	0f b6 00             	movzbl (%eax),%eax
c01019df:	84 c0                	test   %al,%al
c01019e1:	74 0a                	je     c01019ed <debuginfo_eip+0x7b>
        return -1;
c01019e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01019e8:	e9 91 02 00 00       	jmp    c0101c7e <debuginfo_eip+0x30c>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c01019ed:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c01019f4:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01019f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01019fa:	29 c2                	sub    %eax,%edx
c01019fc:	89 d0                	mov    %edx,%eax
c01019fe:	c1 f8 02             	sar    $0x2,%eax
c0101a01:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c0101a07:	83 e8 01             	sub    $0x1,%eax
c0101a0a:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c0101a0d:	ff 75 08             	pushl  0x8(%ebp)
c0101a10:	6a 64                	push   $0x64
c0101a12:	8d 45 e0             	lea    -0x20(%ebp),%eax
c0101a15:	50                   	push   %eax
c0101a16:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c0101a19:	50                   	push   %eax
c0101a1a:	ff 75 f4             	pushl  -0xc(%ebp)
c0101a1d:	e8 f9 fd ff ff       	call   c010181b <stab_binsearch>
c0101a22:	83 c4 14             	add    $0x14,%esp
    if (lfile == 0)
c0101a25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101a28:	85 c0                	test   %eax,%eax
c0101a2a:	75 0a                	jne    c0101a36 <debuginfo_eip+0xc4>
        return -1;
c0101a2c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101a31:	e9 48 02 00 00       	jmp    c0101c7e <debuginfo_eip+0x30c>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c0101a36:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101a39:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0101a3c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101a3f:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c0101a42:	ff 75 08             	pushl  0x8(%ebp)
c0101a45:	6a 24                	push   $0x24
c0101a47:	8d 45 d8             	lea    -0x28(%ebp),%eax
c0101a4a:	50                   	push   %eax
c0101a4b:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0101a4e:	50                   	push   %eax
c0101a4f:	ff 75 f4             	pushl  -0xc(%ebp)
c0101a52:	e8 c4 fd ff ff       	call   c010181b <stab_binsearch>
c0101a57:	83 c4 14             	add    $0x14,%esp

    if (lfun <= rfun) {
c0101a5a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101a5d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0101a60:	39 c2                	cmp    %eax,%edx
c0101a62:	7f 7c                	jg     c0101ae0 <debuginfo_eip+0x16e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c0101a64:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101a67:	89 c2                	mov    %eax,%edx
c0101a69:	89 d0                	mov    %edx,%eax
c0101a6b:	01 c0                	add    %eax,%eax
c0101a6d:	01 d0                	add    %edx,%eax
c0101a6f:	c1 e0 02             	shl    $0x2,%eax
c0101a72:	89 c2                	mov    %eax,%edx
c0101a74:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101a77:	01 d0                	add    %edx,%eax
c0101a79:	8b 00                	mov    (%eax),%eax
c0101a7b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c0101a7e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0101a81:	29 d1                	sub    %edx,%ecx
c0101a83:	89 ca                	mov    %ecx,%edx
c0101a85:	39 d0                	cmp    %edx,%eax
c0101a87:	73 22                	jae    c0101aab <debuginfo_eip+0x139>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0101a89:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101a8c:	89 c2                	mov    %eax,%edx
c0101a8e:	89 d0                	mov    %edx,%eax
c0101a90:	01 c0                	add    %eax,%eax
c0101a92:	01 d0                	add    %edx,%eax
c0101a94:	c1 e0 02             	shl    $0x2,%eax
c0101a97:	89 c2                	mov    %eax,%edx
c0101a99:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101a9c:	01 d0                	add    %edx,%eax
c0101a9e:	8b 10                	mov    (%eax),%edx
c0101aa0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101aa3:	01 c2                	add    %eax,%edx
c0101aa5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101aa8:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c0101aab:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101aae:	89 c2                	mov    %eax,%edx
c0101ab0:	89 d0                	mov    %edx,%eax
c0101ab2:	01 c0                	add    %eax,%eax
c0101ab4:	01 d0                	add    %edx,%eax
c0101ab6:	c1 e0 02             	shl    $0x2,%eax
c0101ab9:	89 c2                	mov    %eax,%edx
c0101abb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101abe:	01 d0                	add    %edx,%eax
c0101ac0:	8b 50 08             	mov    0x8(%eax),%edx
c0101ac3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101ac6:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c0101ac9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101acc:	8b 40 10             	mov    0x10(%eax),%eax
c0101acf:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c0101ad2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101ad5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c0101ad8:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0101adb:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0101ade:	eb 15                	jmp    c0101af5 <debuginfo_eip+0x183>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c0101ae0:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101ae3:	8b 55 08             	mov    0x8(%ebp),%edx
c0101ae6:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c0101ae9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101aec:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c0101aef:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101af2:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c0101af5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101af8:	8b 40 08             	mov    0x8(%eax),%eax
c0101afb:	83 ec 08             	sub    $0x8,%esp
c0101afe:	6a 3a                	push   $0x3a
c0101b00:	50                   	push   %eax
c0101b01:	e8 c6 84 00 00       	call   c0109fcc <strfind>
c0101b06:	83 c4 10             	add    $0x10,%esp
c0101b09:	89 c2                	mov    %eax,%edx
c0101b0b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101b0e:	8b 40 08             	mov    0x8(%eax),%eax
c0101b11:	29 c2                	sub    %eax,%edx
c0101b13:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101b16:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c0101b19:	83 ec 0c             	sub    $0xc,%esp
c0101b1c:	ff 75 08             	pushl  0x8(%ebp)
c0101b1f:	6a 44                	push   $0x44
c0101b21:	8d 45 d0             	lea    -0x30(%ebp),%eax
c0101b24:	50                   	push   %eax
c0101b25:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c0101b28:	50                   	push   %eax
c0101b29:	ff 75 f4             	pushl  -0xc(%ebp)
c0101b2c:	e8 ea fc ff ff       	call   c010181b <stab_binsearch>
c0101b31:	83 c4 20             	add    $0x20,%esp
    if (lline <= rline) {
c0101b34:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0101b37:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0101b3a:	39 c2                	cmp    %eax,%edx
c0101b3c:	7f 24                	jg     c0101b62 <debuginfo_eip+0x1f0>
        info->eip_line = stabs[rline].n_desc;
c0101b3e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0101b41:	89 c2                	mov    %eax,%edx
c0101b43:	89 d0                	mov    %edx,%eax
c0101b45:	01 c0                	add    %eax,%eax
c0101b47:	01 d0                	add    %edx,%eax
c0101b49:	c1 e0 02             	shl    $0x2,%eax
c0101b4c:	89 c2                	mov    %eax,%edx
c0101b4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b51:	01 d0                	add    %edx,%eax
c0101b53:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0101b57:	0f b7 d0             	movzwl %ax,%edx
c0101b5a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101b5d:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0101b60:	eb 13                	jmp    c0101b75 <debuginfo_eip+0x203>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
c0101b62:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101b67:	e9 12 01 00 00       	jmp    c0101c7e <debuginfo_eip+0x30c>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c0101b6c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101b6f:	83 e8 01             	sub    $0x1,%eax
c0101b72:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0101b75:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0101b78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101b7b:	39 c2                	cmp    %eax,%edx
c0101b7d:	7c 56                	jl     c0101bd5 <debuginfo_eip+0x263>
           && stabs[lline].n_type != N_SOL
c0101b7f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101b82:	89 c2                	mov    %eax,%edx
c0101b84:	89 d0                	mov    %edx,%eax
c0101b86:	01 c0                	add    %eax,%eax
c0101b88:	01 d0                	add    %edx,%eax
c0101b8a:	c1 e0 02             	shl    $0x2,%eax
c0101b8d:	89 c2                	mov    %eax,%edx
c0101b8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b92:	01 d0                	add    %edx,%eax
c0101b94:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0101b98:	3c 84                	cmp    $0x84,%al
c0101b9a:	74 39                	je     c0101bd5 <debuginfo_eip+0x263>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c0101b9c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101b9f:	89 c2                	mov    %eax,%edx
c0101ba1:	89 d0                	mov    %edx,%eax
c0101ba3:	01 c0                	add    %eax,%eax
c0101ba5:	01 d0                	add    %edx,%eax
c0101ba7:	c1 e0 02             	shl    $0x2,%eax
c0101baa:	89 c2                	mov    %eax,%edx
c0101bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101baf:	01 d0                	add    %edx,%eax
c0101bb1:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0101bb5:	3c 64                	cmp    $0x64,%al
c0101bb7:	75 b3                	jne    c0101b6c <debuginfo_eip+0x1fa>
c0101bb9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101bbc:	89 c2                	mov    %eax,%edx
c0101bbe:	89 d0                	mov    %edx,%eax
c0101bc0:	01 c0                	add    %eax,%eax
c0101bc2:	01 d0                	add    %edx,%eax
c0101bc4:	c1 e0 02             	shl    $0x2,%eax
c0101bc7:	89 c2                	mov    %eax,%edx
c0101bc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101bcc:	01 d0                	add    %edx,%eax
c0101bce:	8b 40 08             	mov    0x8(%eax),%eax
c0101bd1:	85 c0                	test   %eax,%eax
c0101bd3:	74 97                	je     c0101b6c <debuginfo_eip+0x1fa>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c0101bd5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0101bd8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101bdb:	39 c2                	cmp    %eax,%edx
c0101bdd:	7c 46                	jl     c0101c25 <debuginfo_eip+0x2b3>
c0101bdf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101be2:	89 c2                	mov    %eax,%edx
c0101be4:	89 d0                	mov    %edx,%eax
c0101be6:	01 c0                	add    %eax,%eax
c0101be8:	01 d0                	add    %edx,%eax
c0101bea:	c1 e0 02             	shl    $0x2,%eax
c0101bed:	89 c2                	mov    %eax,%edx
c0101bef:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101bf2:	01 d0                	add    %edx,%eax
c0101bf4:	8b 00                	mov    (%eax),%eax
c0101bf6:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c0101bf9:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0101bfc:	29 d1                	sub    %edx,%ecx
c0101bfe:	89 ca                	mov    %ecx,%edx
c0101c00:	39 d0                	cmp    %edx,%eax
c0101c02:	73 21                	jae    c0101c25 <debuginfo_eip+0x2b3>
        info->eip_file = stabstr + stabs[lline].n_strx;
c0101c04:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101c07:	89 c2                	mov    %eax,%edx
c0101c09:	89 d0                	mov    %edx,%eax
c0101c0b:	01 c0                	add    %eax,%eax
c0101c0d:	01 d0                	add    %edx,%eax
c0101c0f:	c1 e0 02             	shl    $0x2,%eax
c0101c12:	89 c2                	mov    %eax,%edx
c0101c14:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101c17:	01 d0                	add    %edx,%eax
c0101c19:	8b 10                	mov    (%eax),%edx
c0101c1b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101c1e:	01 c2                	add    %eax,%edx
c0101c20:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101c23:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c0101c25:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101c28:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0101c2b:	39 c2                	cmp    %eax,%edx
c0101c2d:	7d 4a                	jge    c0101c79 <debuginfo_eip+0x307>
        for (lline = lfun + 1;
c0101c2f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101c32:	83 c0 01             	add    $0x1,%eax
c0101c35:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0101c38:	eb 18                	jmp    c0101c52 <debuginfo_eip+0x2e0>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0101c3a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101c3d:	8b 40 14             	mov    0x14(%eax),%eax
c0101c40:	8d 50 01             	lea    0x1(%eax),%edx
c0101c43:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101c46:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
c0101c49:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101c4c:	83 c0 01             	add    $0x1,%eax
c0101c4f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0101c52:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0101c55:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
c0101c58:	39 c2                	cmp    %eax,%edx
c0101c5a:	7d 1d                	jge    c0101c79 <debuginfo_eip+0x307>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0101c5c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101c5f:	89 c2                	mov    %eax,%edx
c0101c61:	89 d0                	mov    %edx,%eax
c0101c63:	01 c0                	add    %eax,%eax
c0101c65:	01 d0                	add    %edx,%eax
c0101c67:	c1 e0 02             	shl    $0x2,%eax
c0101c6a:	89 c2                	mov    %eax,%edx
c0101c6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101c6f:	01 d0                	add    %edx,%eax
c0101c71:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0101c75:	3c a0                	cmp    $0xa0,%al
c0101c77:	74 c1                	je     c0101c3a <debuginfo_eip+0x2c8>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
c0101c79:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101c7e:	c9                   	leave  
c0101c7f:	c3                   	ret    

c0101c80 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c0101c80:	55                   	push   %ebp
c0101c81:	89 e5                	mov    %esp,%ebp
c0101c83:	83 ec 08             	sub    $0x8,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0101c86:	83 ec 0c             	sub    $0xc,%esp
c0101c89:	68 4a ad 10 c0       	push   $0xc010ad4a
c0101c8e:	e8 eb e5 ff ff       	call   c010027e <cprintf>
c0101c93:	83 c4 10             	add    $0x10,%esp
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c0101c96:	83 ec 08             	sub    $0x8,%esp
c0101c99:	68 2a 00 10 c0       	push   $0xc010002a
c0101c9e:	68 63 ad 10 c0       	push   $0xc010ad63
c0101ca3:	e8 d6 e5 ff ff       	call   c010027e <cprintf>
c0101ca8:	83 c4 10             	add    $0x10,%esp
    cprintf("  etext  0x%08x (phys)\n", etext);
c0101cab:	83 ec 08             	sub    $0x8,%esp
c0101cae:	68 ec a9 10 c0       	push   $0xc010a9ec
c0101cb3:	68 7b ad 10 c0       	push   $0xc010ad7b
c0101cb8:	e8 c1 e5 ff ff       	call   c010027e <cprintf>
c0101cbd:	83 c4 10             	add    $0x10,%esp
    cprintf("  edata  0x%08x (phys)\n", edata);
c0101cc0:	83 ec 08             	sub    $0x8,%esp
c0101cc3:	68 88 7a 12 c0       	push   $0xc0127a88
c0101cc8:	68 93 ad 10 c0       	push   $0xc010ad93
c0101ccd:	e8 ac e5 ff ff       	call   c010027e <cprintf>
c0101cd2:	83 c4 10             	add    $0x10,%esp
    cprintf("  end    0x%08x (phys)\n", end);
c0101cd5:	83 ec 08             	sub    $0x8,%esp
c0101cd8:	68 ec ab 12 c0       	push   $0xc012abec
c0101cdd:	68 ab ad 10 c0       	push   $0xc010adab
c0101ce2:	e8 97 e5 ff ff       	call   c010027e <cprintf>
c0101ce7:	83 c4 10             	add    $0x10,%esp
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c0101cea:	b8 ec ab 12 c0       	mov    $0xc012abec,%eax
c0101cef:	05 ff 03 00 00       	add    $0x3ff,%eax
c0101cf4:	ba 2a 00 10 c0       	mov    $0xc010002a,%edx
c0101cf9:	29 d0                	sub    %edx,%eax
c0101cfb:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c0101d01:	85 c0                	test   %eax,%eax
c0101d03:	0f 48 c2             	cmovs  %edx,%eax
c0101d06:	c1 f8 0a             	sar    $0xa,%eax
c0101d09:	83 ec 08             	sub    $0x8,%esp
c0101d0c:	50                   	push   %eax
c0101d0d:	68 c4 ad 10 c0       	push   $0xc010adc4
c0101d12:	e8 67 e5 ff ff       	call   c010027e <cprintf>
c0101d17:	83 c4 10             	add    $0x10,%esp
}
c0101d1a:	90                   	nop
c0101d1b:	c9                   	leave  
c0101d1c:	c3                   	ret    

c0101d1d <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c0101d1d:	55                   	push   %ebp
c0101d1e:	89 e5                	mov    %esp,%ebp
c0101d20:	81 ec 28 01 00 00    	sub    $0x128,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c0101d26:	83 ec 08             	sub    $0x8,%esp
c0101d29:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0101d2c:	50                   	push   %eax
c0101d2d:	ff 75 08             	pushl  0x8(%ebp)
c0101d30:	e8 3d fc ff ff       	call   c0101972 <debuginfo_eip>
c0101d35:	83 c4 10             	add    $0x10,%esp
c0101d38:	85 c0                	test   %eax,%eax
c0101d3a:	74 15                	je     c0101d51 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c0101d3c:	83 ec 08             	sub    $0x8,%esp
c0101d3f:	ff 75 08             	pushl  0x8(%ebp)
c0101d42:	68 ee ad 10 c0       	push   $0xc010adee
c0101d47:	e8 32 e5 ff ff       	call   c010027e <cprintf>
c0101d4c:	83 c4 10             	add    $0x10,%esp
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
c0101d4f:	eb 65                	jmp    c0101db6 <print_debuginfo+0x99>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0101d51:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101d58:	eb 1c                	jmp    c0101d76 <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
c0101d5a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0101d5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101d60:	01 d0                	add    %edx,%eax
c0101d62:	0f b6 00             	movzbl (%eax),%eax
c0101d65:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0101d6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101d6e:	01 ca                	add    %ecx,%edx
c0101d70:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0101d72:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101d76:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0101d79:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0101d7c:	7f dc                	jg     c0101d5a <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
c0101d7e:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0101d84:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101d87:	01 d0                	add    %edx,%eax
c0101d89:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
c0101d8c:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0101d8f:	8b 55 08             	mov    0x8(%ebp),%edx
c0101d92:	89 d1                	mov    %edx,%ecx
c0101d94:	29 c1                	sub    %eax,%ecx
c0101d96:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0101d99:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101d9c:	83 ec 0c             	sub    $0xc,%esp
c0101d9f:	51                   	push   %ecx
c0101da0:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0101da6:	51                   	push   %ecx
c0101da7:	52                   	push   %edx
c0101da8:	50                   	push   %eax
c0101da9:	68 0a ae 10 c0       	push   $0xc010ae0a
c0101dae:	e8 cb e4 ff ff       	call   c010027e <cprintf>
c0101db3:	83 c4 20             	add    $0x20,%esp
                fnname, eip - info.eip_fn_addr);
    }
}
c0101db6:	90                   	nop
c0101db7:	c9                   	leave  
c0101db8:	c3                   	ret    

c0101db9 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c0101db9:	55                   	push   %ebp
c0101dba:	89 e5                	mov    %esp,%ebp
c0101dbc:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c0101dbf:	8b 45 04             	mov    0x4(%ebp),%eax
c0101dc2:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0101dc5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101dc8:	c9                   	leave  
c0101dc9:	c3                   	ret    

c0101dca <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0101dca:	55                   	push   %ebp
c0101dcb:	89 e5                	mov    %esp,%ebp
c0101dcd:	83 ec 28             	sub    $0x28,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0101dd0:	89 e8                	mov    %ebp,%eax
c0101dd2:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c0101dd5:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();
c0101dd8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101ddb:	e8 d9 ff ff ff       	call   c0101db9 <read_eip>
c0101de0:	89 45 f0             	mov    %eax,-0x10(%ebp)

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
c0101de3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0101dea:	e9 8d 00 00 00       	jmp    c0101e7c <print_stackframe+0xb2>
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
c0101def:	83 ec 04             	sub    $0x4,%esp
c0101df2:	ff 75 f0             	pushl  -0x10(%ebp)
c0101df5:	ff 75 f4             	pushl  -0xc(%ebp)
c0101df8:	68 1c ae 10 c0       	push   $0xc010ae1c
c0101dfd:	e8 7c e4 ff ff       	call   c010027e <cprintf>
c0101e02:	83 c4 10             	add    $0x10,%esp
        uint32_t *args = (uint32_t *)ebp + 2;
c0101e05:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101e08:	83 c0 08             	add    $0x8,%eax
c0101e0b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (j = 0; j < 4; j ++) {
c0101e0e:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0101e15:	eb 26                	jmp    c0101e3d <print_stackframe+0x73>
            cprintf("0x%08x ", args[j]);
c0101e17:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0101e1a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101e21:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101e24:	01 d0                	add    %edx,%eax
c0101e26:	8b 00                	mov    (%eax),%eax
c0101e28:	83 ec 08             	sub    $0x8,%esp
c0101e2b:	50                   	push   %eax
c0101e2c:	68 38 ae 10 c0       	push   $0xc010ae38
c0101e31:	e8 48 e4 ff ff       	call   c010027e <cprintf>
c0101e36:	83 c4 10             	add    $0x10,%esp

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
        uint32_t *args = (uint32_t *)ebp + 2;
        for (j = 0; j < 4; j ++) {
c0101e39:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
c0101e3d:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0101e41:	7e d4                	jle    c0101e17 <print_stackframe+0x4d>
            cprintf("0x%08x ", args[j]);
        }
        cprintf("\n");
c0101e43:	83 ec 0c             	sub    $0xc,%esp
c0101e46:	68 40 ae 10 c0       	push   $0xc010ae40
c0101e4b:	e8 2e e4 ff ff       	call   c010027e <cprintf>
c0101e50:	83 c4 10             	add    $0x10,%esp
        print_debuginfo(eip - 1);
c0101e53:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101e56:	83 e8 01             	sub    $0x1,%eax
c0101e59:	83 ec 0c             	sub    $0xc,%esp
c0101e5c:	50                   	push   %eax
c0101e5d:	e8 bb fe ff ff       	call   c0101d1d <print_debuginfo>
c0101e62:	83 c4 10             	add    $0x10,%esp
        eip = ((uint32_t *)ebp)[1];
c0101e65:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101e68:	83 c0 04             	add    $0x4,%eax
c0101e6b:	8b 00                	mov    (%eax),%eax
c0101e6d:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t *)ebp)[0];
c0101e70:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101e73:	8b 00                	mov    (%eax),%eax
c0101e75:	89 45 f4             	mov    %eax,-0xc(%ebp)
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
c0101e78:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0101e7c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101e80:	74 0a                	je     c0101e8c <print_stackframe+0xc2>
c0101e82:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0101e86:	0f 8e 63 ff ff ff    	jle    c0101def <print_stackframe+0x25>
        cprintf("\n");
        print_debuginfo(eip - 1);
        eip = ((uint32_t *)ebp)[1];
        ebp = ((uint32_t *)ebp)[0];
    }
}
c0101e8c:	90                   	nop
c0101e8d:	c9                   	leave  
c0101e8e:	c3                   	ret    

c0101e8f <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0101e8f:	55                   	push   %ebp
c0101e90:	89 e5                	mov    %esp,%ebp
c0101e92:	83 ec 18             	sub    $0x18,%esp
    int argc = 0;
c0101e95:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0101e9c:	eb 0c                	jmp    c0101eaa <parse+0x1b>
            *buf ++ = '\0';
c0101e9e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ea1:	8d 50 01             	lea    0x1(%eax),%edx
c0101ea4:	89 55 08             	mov    %edx,0x8(%ebp)
c0101ea7:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0101eaa:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ead:	0f b6 00             	movzbl (%eax),%eax
c0101eb0:	84 c0                	test   %al,%al
c0101eb2:	74 1e                	je     c0101ed2 <parse+0x43>
c0101eb4:	8b 45 08             	mov    0x8(%ebp),%eax
c0101eb7:	0f b6 00             	movzbl (%eax),%eax
c0101eba:	0f be c0             	movsbl %al,%eax
c0101ebd:	83 ec 08             	sub    $0x8,%esp
c0101ec0:	50                   	push   %eax
c0101ec1:	68 c4 ae 10 c0       	push   $0xc010aec4
c0101ec6:	e8 ce 80 00 00       	call   c0109f99 <strchr>
c0101ecb:	83 c4 10             	add    $0x10,%esp
c0101ece:	85 c0                	test   %eax,%eax
c0101ed0:	75 cc                	jne    c0101e9e <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
c0101ed2:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ed5:	0f b6 00             	movzbl (%eax),%eax
c0101ed8:	84 c0                	test   %al,%al
c0101eda:	74 69                	je     c0101f45 <parse+0xb6>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0101edc:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0101ee0:	75 12                	jne    c0101ef4 <parse+0x65>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0101ee2:	83 ec 08             	sub    $0x8,%esp
c0101ee5:	6a 10                	push   $0x10
c0101ee7:	68 c9 ae 10 c0       	push   $0xc010aec9
c0101eec:	e8 8d e3 ff ff       	call   c010027e <cprintf>
c0101ef1:	83 c4 10             	add    $0x10,%esp
        }
        argv[argc ++] = buf;
c0101ef4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101ef7:	8d 50 01             	lea    0x1(%eax),%edx
c0101efa:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0101efd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101f04:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101f07:	01 c2                	add    %eax,%edx
c0101f09:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f0c:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0101f0e:	eb 04                	jmp    c0101f14 <parse+0x85>
            buf ++;
c0101f10:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0101f14:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f17:	0f b6 00             	movzbl (%eax),%eax
c0101f1a:	84 c0                	test   %al,%al
c0101f1c:	0f 84 7a ff ff ff    	je     c0101e9c <parse+0xd>
c0101f22:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f25:	0f b6 00             	movzbl (%eax),%eax
c0101f28:	0f be c0             	movsbl %al,%eax
c0101f2b:	83 ec 08             	sub    $0x8,%esp
c0101f2e:	50                   	push   %eax
c0101f2f:	68 c4 ae 10 c0       	push   $0xc010aec4
c0101f34:	e8 60 80 00 00       	call   c0109f99 <strchr>
c0101f39:	83 c4 10             	add    $0x10,%esp
c0101f3c:	85 c0                	test   %eax,%eax
c0101f3e:	74 d0                	je     c0101f10 <parse+0x81>
            buf ++;
        }
    }
c0101f40:	e9 57 ff ff ff       	jmp    c0101e9c <parse+0xd>
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
            break;
c0101f45:	90                   	nop
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
c0101f46:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101f49:	c9                   	leave  
c0101f4a:	c3                   	ret    

c0101f4b <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0101f4b:	55                   	push   %ebp
c0101f4c:	89 e5                	mov    %esp,%ebp
c0101f4e:	83 ec 58             	sub    $0x58,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0101f51:	83 ec 08             	sub    $0x8,%esp
c0101f54:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0101f57:	50                   	push   %eax
c0101f58:	ff 75 08             	pushl  0x8(%ebp)
c0101f5b:	e8 2f ff ff ff       	call   c0101e8f <parse>
c0101f60:	83 c4 10             	add    $0x10,%esp
c0101f63:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0101f66:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0101f6a:	75 0a                	jne    c0101f76 <runcmd+0x2b>
        return 0;
c0101f6c:	b8 00 00 00 00       	mov    $0x0,%eax
c0101f71:	e9 83 00 00 00       	jmp    c0101ff9 <runcmd+0xae>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0101f76:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101f7d:	eb 59                	jmp    c0101fd8 <runcmd+0x8d>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0101f7f:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0101f82:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101f85:	89 d0                	mov    %edx,%eax
c0101f87:	01 c0                	add    %eax,%eax
c0101f89:	01 d0                	add    %edx,%eax
c0101f8b:	c1 e0 02             	shl    $0x2,%eax
c0101f8e:	05 20 70 12 c0       	add    $0xc0127020,%eax
c0101f93:	8b 00                	mov    (%eax),%eax
c0101f95:	83 ec 08             	sub    $0x8,%esp
c0101f98:	51                   	push   %ecx
c0101f99:	50                   	push   %eax
c0101f9a:	e8 5a 7f 00 00       	call   c0109ef9 <strcmp>
c0101f9f:	83 c4 10             	add    $0x10,%esp
c0101fa2:	85 c0                	test   %eax,%eax
c0101fa4:	75 2e                	jne    c0101fd4 <runcmd+0x89>
            return commands[i].func(argc - 1, argv + 1, tf);
c0101fa6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101fa9:	89 d0                	mov    %edx,%eax
c0101fab:	01 c0                	add    %eax,%eax
c0101fad:	01 d0                	add    %edx,%eax
c0101faf:	c1 e0 02             	shl    $0x2,%eax
c0101fb2:	05 28 70 12 c0       	add    $0xc0127028,%eax
c0101fb7:	8b 10                	mov    (%eax),%edx
c0101fb9:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0101fbc:	83 c0 04             	add    $0x4,%eax
c0101fbf:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0101fc2:	83 e9 01             	sub    $0x1,%ecx
c0101fc5:	83 ec 04             	sub    $0x4,%esp
c0101fc8:	ff 75 0c             	pushl  0xc(%ebp)
c0101fcb:	50                   	push   %eax
c0101fcc:	51                   	push   %ecx
c0101fcd:	ff d2                	call   *%edx
c0101fcf:	83 c4 10             	add    $0x10,%esp
c0101fd2:	eb 25                	jmp    c0101ff9 <runcmd+0xae>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0101fd4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101fd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101fdb:	83 f8 02             	cmp    $0x2,%eax
c0101fde:	76 9f                	jbe    c0101f7f <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0101fe0:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0101fe3:	83 ec 08             	sub    $0x8,%esp
c0101fe6:	50                   	push   %eax
c0101fe7:	68 e7 ae 10 c0       	push   $0xc010aee7
c0101fec:	e8 8d e2 ff ff       	call   c010027e <cprintf>
c0101ff1:	83 c4 10             	add    $0x10,%esp
    return 0;
c0101ff4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101ff9:	c9                   	leave  
c0101ffa:	c3                   	ret    

c0101ffb <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0101ffb:	55                   	push   %ebp
c0101ffc:	89 e5                	mov    %esp,%ebp
c0101ffe:	83 ec 18             	sub    $0x18,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0102001:	83 ec 0c             	sub    $0xc,%esp
c0102004:	68 00 af 10 c0       	push   $0xc010af00
c0102009:	e8 70 e2 ff ff       	call   c010027e <cprintf>
c010200e:	83 c4 10             	add    $0x10,%esp
    cprintf("Type 'help' for a list of commands.\n");
c0102011:	83 ec 0c             	sub    $0xc,%esp
c0102014:	68 28 af 10 c0       	push   $0xc010af28
c0102019:	e8 60 e2 ff ff       	call   c010027e <cprintf>
c010201e:	83 c4 10             	add    $0x10,%esp

    if (tf != NULL) {
c0102021:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0102025:	74 0e                	je     c0102035 <kmonitor+0x3a>
        print_trapframe(tf);
c0102027:	83 ec 0c             	sub    $0xc,%esp
c010202a:	ff 75 08             	pushl  0x8(%ebp)
c010202d:	e8 52 15 00 00       	call   c0103584 <print_trapframe>
c0102032:	83 c4 10             	add    $0x10,%esp
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0102035:	83 ec 0c             	sub    $0xc,%esp
c0102038:	68 4d af 10 c0       	push   $0xc010af4d
c010203d:	e8 58 f6 ff ff       	call   c010169a <readline>
c0102042:	83 c4 10             	add    $0x10,%esp
c0102045:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102048:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010204c:	74 e7                	je     c0102035 <kmonitor+0x3a>
            if (runcmd(buf, tf) < 0) {
c010204e:	83 ec 08             	sub    $0x8,%esp
c0102051:	ff 75 08             	pushl  0x8(%ebp)
c0102054:	ff 75 f4             	pushl  -0xc(%ebp)
c0102057:	e8 ef fe ff ff       	call   c0101f4b <runcmd>
c010205c:	83 c4 10             	add    $0x10,%esp
c010205f:	85 c0                	test   %eax,%eax
c0102061:	78 02                	js     c0102065 <kmonitor+0x6a>
                break;
            }
        }
    }
c0102063:	eb d0                	jmp    c0102035 <kmonitor+0x3a>

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
            if (runcmd(buf, tf) < 0) {
                break;
c0102065:	90                   	nop
            }
        }
    }
}
c0102066:	90                   	nop
c0102067:	c9                   	leave  
c0102068:	c3                   	ret    

c0102069 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0102069:	55                   	push   %ebp
c010206a:	89 e5                	mov    %esp,%ebp
c010206c:	83 ec 18             	sub    $0x18,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c010206f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0102076:	eb 3c                	jmp    c01020b4 <mon_help+0x4b>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0102078:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010207b:	89 d0                	mov    %edx,%eax
c010207d:	01 c0                	add    %eax,%eax
c010207f:	01 d0                	add    %edx,%eax
c0102081:	c1 e0 02             	shl    $0x2,%eax
c0102084:	05 24 70 12 c0       	add    $0xc0127024,%eax
c0102089:	8b 08                	mov    (%eax),%ecx
c010208b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010208e:	89 d0                	mov    %edx,%eax
c0102090:	01 c0                	add    %eax,%eax
c0102092:	01 d0                	add    %edx,%eax
c0102094:	c1 e0 02             	shl    $0x2,%eax
c0102097:	05 20 70 12 c0       	add    $0xc0127020,%eax
c010209c:	8b 00                	mov    (%eax),%eax
c010209e:	83 ec 04             	sub    $0x4,%esp
c01020a1:	51                   	push   %ecx
c01020a2:	50                   	push   %eax
c01020a3:	68 51 af 10 c0       	push   $0xc010af51
c01020a8:	e8 d1 e1 ff ff       	call   c010027e <cprintf>
c01020ad:	83 c4 10             	add    $0x10,%esp

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c01020b0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01020b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01020b7:	83 f8 02             	cmp    $0x2,%eax
c01020ba:	76 bc                	jbe    c0102078 <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
c01020bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01020c1:	c9                   	leave  
c01020c2:	c3                   	ret    

c01020c3 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c01020c3:	55                   	push   %ebp
c01020c4:	89 e5                	mov    %esp,%ebp
c01020c6:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c01020c9:	e8 b2 fb ff ff       	call   c0101c80 <print_kerninfo>
    return 0;
c01020ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01020d3:	c9                   	leave  
c01020d4:	c3                   	ret    

c01020d5 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c01020d5:	55                   	push   %ebp
c01020d6:	89 e5                	mov    %esp,%ebp
c01020d8:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c01020db:	e8 ea fc ff ff       	call   c0101dca <print_stackframe>
    return 0;
c01020e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01020e5:	c9                   	leave  
c01020e6:	c3                   	ret    

c01020e7 <ide_wait_ready>:
    unsigned int size;          // Size in Sectors
    unsigned char model[41];    // Model in String
} ide_devices[MAX_IDE];

static int
ide_wait_ready(unsigned short iobase, bool check_error) {
c01020e7:	55                   	push   %ebp
c01020e8:	89 e5                	mov    %esp,%ebp
c01020ea:	83 ec 14             	sub    $0x14,%esp
c01020ed:	8b 45 08             	mov    0x8(%ebp),%eax
c01020f0:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    int r;
    while ((r = inb(iobase + ISA_STATUS)) & IDE_BSY)
c01020f4:	90                   	nop
c01020f5:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01020f9:	83 c0 07             	add    $0x7,%eax
c01020fc:	0f b7 c0             	movzwl %ax,%eax
c01020ff:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0102103:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0102107:	89 c2                	mov    %eax,%edx
c0102109:	ec                   	in     (%dx),%al
c010210a:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c010210d:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0102111:	0f b6 c0             	movzbl %al,%eax
c0102114:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0102117:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010211a:	25 80 00 00 00       	and    $0x80,%eax
c010211f:	85 c0                	test   %eax,%eax
c0102121:	75 d2                	jne    c01020f5 <ide_wait_ready+0xe>
        /* nothing */;
    if (check_error && (r & (IDE_DF | IDE_ERR)) != 0) {
c0102123:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0102127:	74 11                	je     c010213a <ide_wait_ready+0x53>
c0102129:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010212c:	83 e0 21             	and    $0x21,%eax
c010212f:	85 c0                	test   %eax,%eax
c0102131:	74 07                	je     c010213a <ide_wait_ready+0x53>
        return -1;
c0102133:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0102138:	eb 05                	jmp    c010213f <ide_wait_ready+0x58>
    }
    return 0;
c010213a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010213f:	c9                   	leave  
c0102140:	c3                   	ret    

c0102141 <ide_init>:

void
ide_init(void) {
c0102141:	55                   	push   %ebp
c0102142:	89 e5                	mov    %esp,%ebp
c0102144:	57                   	push   %edi
c0102145:	53                   	push   %ebx
c0102146:	81 ec 40 02 00 00    	sub    $0x240,%esp
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c010214c:	66 c7 45 f6 00 00    	movw   $0x0,-0xa(%ebp)
c0102152:	e9 c1 02 00 00       	jmp    c0102418 <ide_init+0x2d7>
        /* assume that no device here */
        ide_devices[ideno].valid = 0;
c0102157:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010215b:	c1 e0 03             	shl    $0x3,%eax
c010215e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0102165:	29 c2                	sub    %eax,%edx
c0102167:	89 d0                	mov    %edx,%eax
c0102169:	05 e0 7e 12 c0       	add    $0xc0127ee0,%eax
c010216e:	c6 00 00             	movb   $0x0,(%eax)

        iobase = IO_BASE(ideno);
c0102171:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0102175:	66 d1 e8             	shr    %ax
c0102178:	0f b7 c0             	movzwl %ax,%eax
c010217b:	0f b7 04 85 5c af 10 	movzwl -0x3fef50a4(,%eax,4),%eax
c0102182:	c0 
c0102183:	66 89 45 ea          	mov    %ax,-0x16(%ebp)

        /* wait device ready */
        ide_wait_ready(iobase, 0);
c0102187:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c010218b:	6a 00                	push   $0x0
c010218d:	50                   	push   %eax
c010218e:	e8 54 ff ff ff       	call   c01020e7 <ide_wait_ready>
c0102193:	83 c4 08             	add    $0x8,%esp

        /* step1: select drive */
        outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4));
c0102196:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010219a:	83 e0 01             	and    $0x1,%eax
c010219d:	c1 e0 04             	shl    $0x4,%eax
c01021a0:	83 c8 e0             	or     $0xffffffe0,%eax
c01021a3:	0f b6 c0             	movzbl %al,%eax
c01021a6:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01021aa:	83 c2 06             	add    $0x6,%edx
c01021ad:	0f b7 d2             	movzwl %dx,%edx
c01021b0:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c01021b4:	88 45 c7             	mov    %al,-0x39(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01021b7:	0f b6 45 c7          	movzbl -0x39(%ebp),%eax
c01021bb:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c01021bf:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c01021c0:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01021c4:	6a 00                	push   $0x0
c01021c6:	50                   	push   %eax
c01021c7:	e8 1b ff ff ff       	call   c01020e7 <ide_wait_ready>
c01021cc:	83 c4 08             	add    $0x8,%esp

        /* step2: send ATA identify command */
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
c01021cf:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01021d3:	83 c0 07             	add    $0x7,%eax
c01021d6:	0f b7 c0             	movzwl %ax,%eax
c01021d9:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
c01021dd:	c6 45 c8 ec          	movb   $0xec,-0x38(%ebp)
c01021e1:	0f b6 45 c8          	movzbl -0x38(%ebp),%eax
c01021e5:	0f b7 55 e0          	movzwl -0x20(%ebp),%edx
c01021e9:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c01021ea:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01021ee:	6a 00                	push   $0x0
c01021f0:	50                   	push   %eax
c01021f1:	e8 f1 fe ff ff       	call   c01020e7 <ide_wait_ready>
c01021f6:	83 c4 08             	add    $0x8,%esp

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
c01021f9:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01021fd:	83 c0 07             	add    $0x7,%eax
c0102200:	0f b7 c0             	movzwl %ax,%eax
c0102203:	66 89 45 ca          	mov    %ax,-0x36(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0102207:	0f b7 45 ca          	movzwl -0x36(%ebp),%eax
c010220b:	89 c2                	mov    %eax,%edx
c010220d:	ec                   	in     (%dx),%al
c010220e:	88 45 c9             	mov    %al,-0x37(%ebp)
    return data;
c0102211:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0102215:	84 c0                	test   %al,%al
c0102217:	0f 84 ef 01 00 00    	je     c010240c <ide_init+0x2cb>
c010221d:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0102221:	6a 01                	push   $0x1
c0102223:	50                   	push   %eax
c0102224:	e8 be fe ff ff       	call   c01020e7 <ide_wait_ready>
c0102229:	83 c4 08             	add    $0x8,%esp
c010222c:	85 c0                	test   %eax,%eax
c010222e:	0f 85 d8 01 00 00    	jne    c010240c <ide_init+0x2cb>
            continue ;
        }

        /* device is ok */
        ide_devices[ideno].valid = 1;
c0102234:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0102238:	c1 e0 03             	shl    $0x3,%eax
c010223b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0102242:	29 c2                	sub    %eax,%edx
c0102244:	89 d0                	mov    %edx,%eax
c0102246:	05 e0 7e 12 c0       	add    $0xc0127ee0,%eax
c010224b:	c6 00 01             	movb   $0x1,(%eax)

        /* read identification space of the device */
        unsigned int buffer[128];
        insl(iobase + ISA_DATA, buffer, sizeof(buffer) / sizeof(unsigned int));
c010224e:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0102252:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0102255:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c010225b:	89 45 c0             	mov    %eax,-0x40(%ebp)
c010225e:	c7 45 bc 80 00 00 00 	movl   $0x80,-0x44(%ebp)
}

static inline void
insl(uint32_t port, void *addr, int cnt) {
    asm volatile (
c0102265:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102268:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c010226b:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010226e:	89 cb                	mov    %ecx,%ebx
c0102270:	89 df                	mov    %ebx,%edi
c0102272:	89 c1                	mov    %eax,%ecx
c0102274:	fc                   	cld    
c0102275:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0102277:	89 c8                	mov    %ecx,%eax
c0102279:	89 fb                	mov    %edi,%ebx
c010227b:	89 5d c0             	mov    %ebx,-0x40(%ebp)
c010227e:	89 45 bc             	mov    %eax,-0x44(%ebp)

        unsigned char *ident = (unsigned char *)buffer;
c0102281:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0102287:	89 45 dc             	mov    %eax,-0x24(%ebp)
        unsigned int sectors;
        unsigned int cmdsets = *(unsigned int *)(ident + IDE_IDENT_CMDSETS);
c010228a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010228d:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
c0102293:	89 45 d8             	mov    %eax,-0x28(%ebp)
        /* device use 48-bits or 28-bits addressing */
        if (cmdsets & (1 << 26)) {
c0102296:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0102299:	25 00 00 00 04       	and    $0x4000000,%eax
c010229e:	85 c0                	test   %eax,%eax
c01022a0:	74 0e                	je     c01022b0 <ide_init+0x16f>
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA_EXT);
c01022a2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01022a5:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
c01022ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01022ae:	eb 09                	jmp    c01022b9 <ide_init+0x178>
        }
        else {
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA);
c01022b0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01022b3:	8b 40 78             	mov    0x78(%eax),%eax
c01022b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        ide_devices[ideno].sets = cmdsets;
c01022b9:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01022bd:	c1 e0 03             	shl    $0x3,%eax
c01022c0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01022c7:	29 c2                	sub    %eax,%edx
c01022c9:	89 d0                	mov    %edx,%eax
c01022cb:	8d 90 e4 7e 12 c0    	lea    -0x3fed811c(%eax),%edx
c01022d1:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01022d4:	89 02                	mov    %eax,(%edx)
        ide_devices[ideno].size = sectors;
c01022d6:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01022da:	c1 e0 03             	shl    $0x3,%eax
c01022dd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01022e4:	29 c2                	sub    %eax,%edx
c01022e6:	89 d0                	mov    %edx,%eax
c01022e8:	8d 90 e8 7e 12 c0    	lea    -0x3fed8118(%eax),%edx
c01022ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01022f1:	89 02                	mov    %eax,(%edx)

        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c01022f3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01022f6:	83 c0 62             	add    $0x62,%eax
c01022f9:	0f b7 00             	movzwl (%eax),%eax
c01022fc:	0f b7 c0             	movzwl %ax,%eax
c01022ff:	25 00 02 00 00       	and    $0x200,%eax
c0102304:	85 c0                	test   %eax,%eax
c0102306:	75 16                	jne    c010231e <ide_init+0x1dd>
c0102308:	68 64 af 10 c0       	push   $0xc010af64
c010230d:	68 a7 af 10 c0       	push   $0xc010afa7
c0102312:	6a 7d                	push   $0x7d
c0102314:	68 bc af 10 c0       	push   $0xc010afbc
c0102319:	e8 3e f4 ff ff       	call   c010175c <__panic>

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
c010231e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0102322:	89 c2                	mov    %eax,%edx
c0102324:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
c010232b:	89 c2                	mov    %eax,%edx
c010232d:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
c0102334:	29 d0                	sub    %edx,%eax
c0102336:	05 e0 7e 12 c0       	add    $0xc0127ee0,%eax
c010233b:	83 c0 0c             	add    $0xc,%eax
c010233e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0102341:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102344:	83 c0 36             	add    $0x36,%eax
c0102347:	89 45 d0             	mov    %eax,-0x30(%ebp)
        unsigned int i, length = 40;
c010234a:	c7 45 cc 28 00 00 00 	movl   $0x28,-0x34(%ebp)
        for (i = 0; i < length; i += 2) {
c0102351:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0102358:	eb 34                	jmp    c010238e <ide_init+0x24d>
            model[i] = data[i + 1], model[i + 1] = data[i];
c010235a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010235d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102360:	01 c2                	add    %eax,%edx
c0102362:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102365:	8d 48 01             	lea    0x1(%eax),%ecx
c0102368:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010236b:	01 c8                	add    %ecx,%eax
c010236d:	0f b6 00             	movzbl (%eax),%eax
c0102370:	88 02                	mov    %al,(%edx)
c0102372:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102375:	8d 50 01             	lea    0x1(%eax),%edx
c0102378:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010237b:	01 c2                	add    %eax,%edx
c010237d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c0102380:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102383:	01 c8                	add    %ecx,%eax
c0102385:	0f b6 00             	movzbl (%eax),%eax
c0102388:	88 02                	mov    %al,(%edx)
        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
        unsigned int i, length = 40;
        for (i = 0; i < length; i += 2) {
c010238a:	83 45 ec 02          	addl   $0x2,-0x14(%ebp)
c010238e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102391:	3b 45 cc             	cmp    -0x34(%ebp),%eax
c0102394:	72 c4                	jb     c010235a <ide_init+0x219>
            model[i] = data[i + 1], model[i + 1] = data[i];
        }
        do {
            model[i] = '\0';
c0102396:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102399:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010239c:	01 d0                	add    %edx,%eax
c010239e:	c6 00 00             	movb   $0x0,(%eax)
        } while (i -- > 0 && model[i] == ' ');
c01023a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01023a4:	8d 50 ff             	lea    -0x1(%eax),%edx
c01023a7:	89 55 ec             	mov    %edx,-0x14(%ebp)
c01023aa:	85 c0                	test   %eax,%eax
c01023ac:	74 0f                	je     c01023bd <ide_init+0x27c>
c01023ae:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01023b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01023b4:	01 d0                	add    %edx,%eax
c01023b6:	0f b6 00             	movzbl (%eax),%eax
c01023b9:	3c 20                	cmp    $0x20,%al
c01023bb:	74 d9                	je     c0102396 <ide_init+0x255>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
c01023bd:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01023c1:	89 c2                	mov    %eax,%edx
c01023c3:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
c01023ca:	89 c2                	mov    %eax,%edx
c01023cc:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
c01023d3:	29 d0                	sub    %edx,%eax
c01023d5:	05 e0 7e 12 c0       	add    $0xc0127ee0,%eax
c01023da:	8d 48 0c             	lea    0xc(%eax),%ecx
c01023dd:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01023e1:	c1 e0 03             	shl    $0x3,%eax
c01023e4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01023eb:	29 c2                	sub    %eax,%edx
c01023ed:	89 d0                	mov    %edx,%eax
c01023ef:	05 e8 7e 12 c0       	add    $0xc0127ee8,%eax
c01023f4:	8b 10                	mov    (%eax),%edx
c01023f6:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01023fa:	51                   	push   %ecx
c01023fb:	52                   	push   %edx
c01023fc:	50                   	push   %eax
c01023fd:	68 ce af 10 c0       	push   $0xc010afce
c0102402:	e8 77 de ff ff       	call   c010027e <cprintf>
c0102407:	83 c4 10             	add    $0x10,%esp
c010240a:	eb 01                	jmp    c010240d <ide_init+0x2cc>
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
        ide_wait_ready(iobase, 0);

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
            continue ;
c010240c:	90                   	nop

void
ide_init(void) {
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c010240d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0102411:	83 c0 01             	add    $0x1,%eax
c0102414:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
c0102418:	66 83 7d f6 03       	cmpw   $0x3,-0xa(%ebp)
c010241d:	0f 86 34 fd ff ff    	jbe    c0102157 <ide_init+0x16>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
    }

    // enable ide interrupt
    pic_enable(IRQ_IDE1);
c0102423:	83 ec 0c             	sub    $0xc,%esp
c0102426:	6a 0e                	push   $0xe
c0102428:	e8 8a 0e 00 00       	call   c01032b7 <pic_enable>
c010242d:	83 c4 10             	add    $0x10,%esp
    pic_enable(IRQ_IDE2);
c0102430:	83 ec 0c             	sub    $0xc,%esp
c0102433:	6a 0f                	push   $0xf
c0102435:	e8 7d 0e 00 00       	call   c01032b7 <pic_enable>
c010243a:	83 c4 10             	add    $0x10,%esp
}
c010243d:	90                   	nop
c010243e:	8d 65 f8             	lea    -0x8(%ebp),%esp
c0102441:	5b                   	pop    %ebx
c0102442:	5f                   	pop    %edi
c0102443:	5d                   	pop    %ebp
c0102444:	c3                   	ret    

c0102445 <ide_device_valid>:

bool
ide_device_valid(unsigned short ideno) {
c0102445:	55                   	push   %ebp
c0102446:	89 e5                	mov    %esp,%ebp
c0102448:	83 ec 04             	sub    $0x4,%esp
c010244b:	8b 45 08             	mov    0x8(%ebp),%eax
c010244e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    return VALID_IDE(ideno);
c0102452:	66 83 7d fc 03       	cmpw   $0x3,-0x4(%ebp)
c0102457:	77 25                	ja     c010247e <ide_device_valid+0x39>
c0102459:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c010245d:	c1 e0 03             	shl    $0x3,%eax
c0102460:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0102467:	29 c2                	sub    %eax,%edx
c0102469:	89 d0                	mov    %edx,%eax
c010246b:	05 e0 7e 12 c0       	add    $0xc0127ee0,%eax
c0102470:	0f b6 00             	movzbl (%eax),%eax
c0102473:	84 c0                	test   %al,%al
c0102475:	74 07                	je     c010247e <ide_device_valid+0x39>
c0102477:	b8 01 00 00 00       	mov    $0x1,%eax
c010247c:	eb 05                	jmp    c0102483 <ide_device_valid+0x3e>
c010247e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0102483:	c9                   	leave  
c0102484:	c3                   	ret    

c0102485 <ide_device_size>:

size_t
ide_device_size(unsigned short ideno) {
c0102485:	55                   	push   %ebp
c0102486:	89 e5                	mov    %esp,%ebp
c0102488:	83 ec 04             	sub    $0x4,%esp
c010248b:	8b 45 08             	mov    0x8(%ebp),%eax
c010248e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    if (ide_device_valid(ideno)) {
c0102492:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0102496:	50                   	push   %eax
c0102497:	e8 a9 ff ff ff       	call   c0102445 <ide_device_valid>
c010249c:	83 c4 04             	add    $0x4,%esp
c010249f:	85 c0                	test   %eax,%eax
c01024a1:	74 1b                	je     c01024be <ide_device_size+0x39>
        return ide_devices[ideno].size;
c01024a3:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c01024a7:	c1 e0 03             	shl    $0x3,%eax
c01024aa:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01024b1:	29 c2                	sub    %eax,%edx
c01024b3:	89 d0                	mov    %edx,%eax
c01024b5:	05 e8 7e 12 c0       	add    $0xc0127ee8,%eax
c01024ba:	8b 00                	mov    (%eax),%eax
c01024bc:	eb 05                	jmp    c01024c3 <ide_device_size+0x3e>
    }
    return 0;
c01024be:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01024c3:	c9                   	leave  
c01024c4:	c3                   	ret    

c01024c5 <ide_read_secs>:

int
ide_read_secs(unsigned short ideno, uint32_t secno, void *dst, size_t nsecs) {
c01024c5:	55                   	push   %ebp
c01024c6:	89 e5                	mov    %esp,%ebp
c01024c8:	57                   	push   %edi
c01024c9:	53                   	push   %ebx
c01024ca:	83 ec 40             	sub    $0x40,%esp
c01024cd:	8b 45 08             	mov    0x8(%ebp),%eax
c01024d0:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c01024d4:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c01024db:	77 25                	ja     c0102502 <ide_read_secs+0x3d>
c01024dd:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c01024e2:	77 1e                	ja     c0102502 <ide_read_secs+0x3d>
c01024e4:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01024e8:	c1 e0 03             	shl    $0x3,%eax
c01024eb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01024f2:	29 c2                	sub    %eax,%edx
c01024f4:	89 d0                	mov    %edx,%eax
c01024f6:	05 e0 7e 12 c0       	add    $0xc0127ee0,%eax
c01024fb:	0f b6 00             	movzbl (%eax),%eax
c01024fe:	84 c0                	test   %al,%al
c0102500:	75 19                	jne    c010251b <ide_read_secs+0x56>
c0102502:	68 ec af 10 c0       	push   $0xc010afec
c0102507:	68 a7 af 10 c0       	push   $0xc010afa7
c010250c:	68 9f 00 00 00       	push   $0x9f
c0102511:	68 bc af 10 c0       	push   $0xc010afbc
c0102516:	e8 41 f2 ff ff       	call   c010175c <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c010251b:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0102522:	77 0f                	ja     c0102533 <ide_read_secs+0x6e>
c0102524:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102527:	8b 45 14             	mov    0x14(%ebp),%eax
c010252a:	01 d0                	add    %edx,%eax
c010252c:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0102531:	76 19                	jbe    c010254c <ide_read_secs+0x87>
c0102533:	68 14 b0 10 c0       	push   $0xc010b014
c0102538:	68 a7 af 10 c0       	push   $0xc010afa7
c010253d:	68 a0 00 00 00       	push   $0xa0
c0102542:	68 bc af 10 c0       	push   $0xc010afbc
c0102547:	e8 10 f2 ff ff       	call   c010175c <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c010254c:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0102550:	66 d1 e8             	shr    %ax
c0102553:	0f b7 c0             	movzwl %ax,%eax
c0102556:	0f b7 04 85 5c af 10 	movzwl -0x3fef50a4(,%eax,4),%eax
c010255d:	c0 
c010255e:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0102562:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0102566:	66 d1 e8             	shr    %ax
c0102569:	0f b7 c0             	movzwl %ax,%eax
c010256c:	0f b7 04 85 5e af 10 	movzwl -0x3fef50a2(,%eax,4),%eax
c0102573:	c0 
c0102574:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0102578:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010257c:	83 ec 08             	sub    $0x8,%esp
c010257f:	6a 00                	push   $0x0
c0102581:	50                   	push   %eax
c0102582:	e8 60 fb ff ff       	call   c01020e7 <ide_wait_ready>
c0102587:	83 c4 10             	add    $0x10,%esp

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c010258a:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c010258e:	83 c0 02             	add    $0x2,%eax
c0102591:	0f b7 c0             	movzwl %ax,%eax
c0102594:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c0102598:	c6 45 d7 00          	movb   $0x0,-0x29(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010259c:	0f b6 45 d7          	movzbl -0x29(%ebp),%eax
c01025a0:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01025a4:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c01025a5:	8b 45 14             	mov    0x14(%ebp),%eax
c01025a8:	0f b6 c0             	movzbl %al,%eax
c01025ab:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01025af:	83 c2 02             	add    $0x2,%edx
c01025b2:	0f b7 d2             	movzwl %dx,%edx
c01025b5:	66 89 55 e8          	mov    %dx,-0x18(%ebp)
c01025b9:	88 45 d8             	mov    %al,-0x28(%ebp)
c01025bc:	0f b6 45 d8          	movzbl -0x28(%ebp),%eax
c01025c0:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c01025c4:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c01025c5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01025c8:	0f b6 c0             	movzbl %al,%eax
c01025cb:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01025cf:	83 c2 03             	add    $0x3,%edx
c01025d2:	0f b7 d2             	movzwl %dx,%edx
c01025d5:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01025d9:	88 45 d9             	mov    %al,-0x27(%ebp)
c01025dc:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01025e0:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01025e4:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c01025e5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01025e8:	c1 e8 08             	shr    $0x8,%eax
c01025eb:	0f b6 c0             	movzbl %al,%eax
c01025ee:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01025f2:	83 c2 04             	add    $0x4,%edx
c01025f5:	0f b7 d2             	movzwl %dx,%edx
c01025f8:	66 89 55 e4          	mov    %dx,-0x1c(%ebp)
c01025fc:	88 45 da             	mov    %al,-0x26(%ebp)
c01025ff:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
c0102603:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
c0102607:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0102608:	8b 45 0c             	mov    0xc(%ebp),%eax
c010260b:	c1 e8 10             	shr    $0x10,%eax
c010260e:	0f b6 c0             	movzbl %al,%eax
c0102611:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102615:	83 c2 05             	add    $0x5,%edx
c0102618:	0f b7 d2             	movzwl %dx,%edx
c010261b:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c010261f:	88 45 db             	mov    %al,-0x25(%ebp)
c0102622:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
c0102626:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c010262a:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c010262b:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c010262f:	83 e0 01             	and    $0x1,%eax
c0102632:	c1 e0 04             	shl    $0x4,%eax
c0102635:	89 c2                	mov    %eax,%edx
c0102637:	8b 45 0c             	mov    0xc(%ebp),%eax
c010263a:	c1 e8 18             	shr    $0x18,%eax
c010263d:	83 e0 0f             	and    $0xf,%eax
c0102640:	09 d0                	or     %edx,%eax
c0102642:	83 c8 e0             	or     $0xffffffe0,%eax
c0102645:	0f b6 c0             	movzbl %al,%eax
c0102648:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010264c:	83 c2 06             	add    $0x6,%edx
c010264f:	0f b7 d2             	movzwl %dx,%edx
c0102652:	66 89 55 e0          	mov    %dx,-0x20(%ebp)
c0102656:	88 45 dc             	mov    %al,-0x24(%ebp)
c0102659:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
c010265d:	0f b7 55 e0          	movzwl -0x20(%ebp),%edx
c0102661:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);
c0102662:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0102666:	83 c0 07             	add    $0x7,%eax
c0102669:	0f b7 c0             	movzwl %ax,%eax
c010266c:	66 89 45 de          	mov    %ax,-0x22(%ebp)
c0102670:	c6 45 dd 20          	movb   $0x20,-0x23(%ebp)
c0102674:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0102678:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c010267c:	ee                   	out    %al,(%dx)

    int ret = 0;
c010267d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0102684:	eb 56                	jmp    c01026dc <ide_read_secs+0x217>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0102686:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010268a:	83 ec 08             	sub    $0x8,%esp
c010268d:	6a 01                	push   $0x1
c010268f:	50                   	push   %eax
c0102690:	e8 52 fa ff ff       	call   c01020e7 <ide_wait_ready>
c0102695:	83 c4 10             	add    $0x10,%esp
c0102698:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010269b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010269f:	75 43                	jne    c01026e4 <ide_read_secs+0x21f>
            goto out;
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
c01026a1:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01026a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01026a8:	8b 45 10             	mov    0x10(%ebp),%eax
c01026ab:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01026ae:	c7 45 cc 80 00 00 00 	movl   $0x80,-0x34(%ebp)
    return data;
}

static inline void
insl(uint32_t port, void *addr, int cnt) {
    asm volatile (
c01026b5:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01026b8:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c01026bb:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01026be:	89 cb                	mov    %ecx,%ebx
c01026c0:	89 df                	mov    %ebx,%edi
c01026c2:	89 c1                	mov    %eax,%ecx
c01026c4:	fc                   	cld    
c01026c5:	f2 6d                	repnz insl (%dx),%es:(%edi)
c01026c7:	89 c8                	mov    %ecx,%eax
c01026c9:	89 fb                	mov    %edi,%ebx
c01026cb:	89 5d d0             	mov    %ebx,-0x30(%ebp)
c01026ce:	89 45 cc             	mov    %eax,-0x34(%ebp)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);

    int ret = 0;
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c01026d1:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c01026d5:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c01026dc:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c01026e0:	75 a4                	jne    c0102686 <ide_read_secs+0x1c1>
c01026e2:	eb 01                	jmp    c01026e5 <ide_read_secs+0x220>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
            goto out;
c01026e4:	90                   	nop
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
    }

out:
    return ret;
c01026e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01026e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
c01026eb:	5b                   	pop    %ebx
c01026ec:	5f                   	pop    %edi
c01026ed:	5d                   	pop    %ebp
c01026ee:	c3                   	ret    

c01026ef <ide_write_secs>:

int
ide_write_secs(unsigned short ideno, uint32_t secno, const void *src, size_t nsecs) {
c01026ef:	55                   	push   %ebp
c01026f0:	89 e5                	mov    %esp,%ebp
c01026f2:	56                   	push   %esi
c01026f3:	53                   	push   %ebx
c01026f4:	83 ec 40             	sub    $0x40,%esp
c01026f7:	8b 45 08             	mov    0x8(%ebp),%eax
c01026fa:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c01026fe:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0102705:	77 25                	ja     c010272c <ide_write_secs+0x3d>
c0102707:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c010270c:	77 1e                	ja     c010272c <ide_write_secs+0x3d>
c010270e:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0102712:	c1 e0 03             	shl    $0x3,%eax
c0102715:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c010271c:	29 c2                	sub    %eax,%edx
c010271e:	89 d0                	mov    %edx,%eax
c0102720:	05 e0 7e 12 c0       	add    $0xc0127ee0,%eax
c0102725:	0f b6 00             	movzbl (%eax),%eax
c0102728:	84 c0                	test   %al,%al
c010272a:	75 19                	jne    c0102745 <ide_write_secs+0x56>
c010272c:	68 ec af 10 c0       	push   $0xc010afec
c0102731:	68 a7 af 10 c0       	push   $0xc010afa7
c0102736:	68 bc 00 00 00       	push   $0xbc
c010273b:	68 bc af 10 c0       	push   $0xc010afbc
c0102740:	e8 17 f0 ff ff       	call   c010175c <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0102745:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c010274c:	77 0f                	ja     c010275d <ide_write_secs+0x6e>
c010274e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102751:	8b 45 14             	mov    0x14(%ebp),%eax
c0102754:	01 d0                	add    %edx,%eax
c0102756:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c010275b:	76 19                	jbe    c0102776 <ide_write_secs+0x87>
c010275d:	68 14 b0 10 c0       	push   $0xc010b014
c0102762:	68 a7 af 10 c0       	push   $0xc010afa7
c0102767:	68 bd 00 00 00       	push   $0xbd
c010276c:	68 bc af 10 c0       	push   $0xc010afbc
c0102771:	e8 e6 ef ff ff       	call   c010175c <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0102776:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c010277a:	66 d1 e8             	shr    %ax
c010277d:	0f b7 c0             	movzwl %ax,%eax
c0102780:	0f b7 04 85 5c af 10 	movzwl -0x3fef50a4(,%eax,4),%eax
c0102787:	c0 
c0102788:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c010278c:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0102790:	66 d1 e8             	shr    %ax
c0102793:	0f b7 c0             	movzwl %ax,%eax
c0102796:	0f b7 04 85 5e af 10 	movzwl -0x3fef50a2(,%eax,4),%eax
c010279d:	c0 
c010279e:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c01027a2:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01027a6:	83 ec 08             	sub    $0x8,%esp
c01027a9:	6a 00                	push   $0x0
c01027ab:	50                   	push   %eax
c01027ac:	e8 36 f9 ff ff       	call   c01020e7 <ide_wait_ready>
c01027b1:	83 c4 10             	add    $0x10,%esp

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c01027b4:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01027b8:	83 c0 02             	add    $0x2,%eax
c01027bb:	0f b7 c0             	movzwl %ax,%eax
c01027be:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c01027c2:	c6 45 d7 00          	movb   $0x0,-0x29(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01027c6:	0f b6 45 d7          	movzbl -0x29(%ebp),%eax
c01027ca:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01027ce:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c01027cf:	8b 45 14             	mov    0x14(%ebp),%eax
c01027d2:	0f b6 c0             	movzbl %al,%eax
c01027d5:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01027d9:	83 c2 02             	add    $0x2,%edx
c01027dc:	0f b7 d2             	movzwl %dx,%edx
c01027df:	66 89 55 e8          	mov    %dx,-0x18(%ebp)
c01027e3:	88 45 d8             	mov    %al,-0x28(%ebp)
c01027e6:	0f b6 45 d8          	movzbl -0x28(%ebp),%eax
c01027ea:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c01027ee:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c01027ef:	8b 45 0c             	mov    0xc(%ebp),%eax
c01027f2:	0f b6 c0             	movzbl %al,%eax
c01027f5:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01027f9:	83 c2 03             	add    $0x3,%edx
c01027fc:	0f b7 d2             	movzwl %dx,%edx
c01027ff:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0102803:	88 45 d9             	mov    %al,-0x27(%ebp)
c0102806:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c010280a:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010280e:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c010280f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102812:	c1 e8 08             	shr    $0x8,%eax
c0102815:	0f b6 c0             	movzbl %al,%eax
c0102818:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010281c:	83 c2 04             	add    $0x4,%edx
c010281f:	0f b7 d2             	movzwl %dx,%edx
c0102822:	66 89 55 e4          	mov    %dx,-0x1c(%ebp)
c0102826:	88 45 da             	mov    %al,-0x26(%ebp)
c0102829:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
c010282d:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
c0102831:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0102832:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102835:	c1 e8 10             	shr    $0x10,%eax
c0102838:	0f b6 c0             	movzbl %al,%eax
c010283b:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010283f:	83 c2 05             	add    $0x5,%edx
c0102842:	0f b7 d2             	movzwl %dx,%edx
c0102845:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0102849:	88 45 db             	mov    %al,-0x25(%ebp)
c010284c:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
c0102850:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0102854:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0102855:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0102859:	83 e0 01             	and    $0x1,%eax
c010285c:	c1 e0 04             	shl    $0x4,%eax
c010285f:	89 c2                	mov    %eax,%edx
c0102861:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102864:	c1 e8 18             	shr    $0x18,%eax
c0102867:	83 e0 0f             	and    $0xf,%eax
c010286a:	09 d0                	or     %edx,%eax
c010286c:	83 c8 e0             	or     $0xffffffe0,%eax
c010286f:	0f b6 c0             	movzbl %al,%eax
c0102872:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102876:	83 c2 06             	add    $0x6,%edx
c0102879:	0f b7 d2             	movzwl %dx,%edx
c010287c:	66 89 55 e0          	mov    %dx,-0x20(%ebp)
c0102880:	88 45 dc             	mov    %al,-0x24(%ebp)
c0102883:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
c0102887:	0f b7 55 e0          	movzwl -0x20(%ebp),%edx
c010288b:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);
c010288c:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0102890:	83 c0 07             	add    $0x7,%eax
c0102893:	0f b7 c0             	movzwl %ax,%eax
c0102896:	66 89 45 de          	mov    %ax,-0x22(%ebp)
c010289a:	c6 45 dd 30          	movb   $0x30,-0x23(%ebp)
c010289e:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01028a2:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c01028a6:	ee                   	out    %al,(%dx)

    int ret = 0;
c01028a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c01028ae:	eb 56                	jmp    c0102906 <ide_write_secs+0x217>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c01028b0:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01028b4:	83 ec 08             	sub    $0x8,%esp
c01028b7:	6a 01                	push   $0x1
c01028b9:	50                   	push   %eax
c01028ba:	e8 28 f8 ff ff       	call   c01020e7 <ide_wait_ready>
c01028bf:	83 c4 10             	add    $0x10,%esp
c01028c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01028c5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01028c9:	75 43                	jne    c010290e <ide_write_secs+0x21f>
            goto out;
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
c01028cb:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01028cf:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01028d2:	8b 45 10             	mov    0x10(%ebp),%eax
c01028d5:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01028d8:	c7 45 cc 80 00 00 00 	movl   $0x80,-0x34(%ebp)
    asm volatile ("outw %0, %1" :: "a" (data), "d" (port) : "memory");
}

static inline void
outsl(uint32_t port, const void *addr, int cnt) {
    asm volatile (
c01028df:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01028e2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c01028e5:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01028e8:	89 cb                	mov    %ecx,%ebx
c01028ea:	89 de                	mov    %ebx,%esi
c01028ec:	89 c1                	mov    %eax,%ecx
c01028ee:	fc                   	cld    
c01028ef:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
c01028f1:	89 c8                	mov    %ecx,%eax
c01028f3:	89 f3                	mov    %esi,%ebx
c01028f5:	89 5d d0             	mov    %ebx,-0x30(%ebp)
c01028f8:	89 45 cc             	mov    %eax,-0x34(%ebp)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);

    int ret = 0;
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c01028fb:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c01028ff:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0102906:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c010290a:	75 a4                	jne    c01028b0 <ide_write_secs+0x1c1>
c010290c:	eb 01                	jmp    c010290f <ide_write_secs+0x220>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
            goto out;
c010290e:	90                   	nop
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
    }

out:
    return ret;
c010290f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102912:	8d 65 f8             	lea    -0x8(%ebp),%esp
c0102915:	5b                   	pop    %ebx
c0102916:	5e                   	pop    %esi
c0102917:	5d                   	pop    %ebp
c0102918:	c3                   	ret    

c0102919 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0102919:	55                   	push   %ebp
c010291a:	89 e5                	mov    %esp,%ebp
c010291c:	83 ec 18             	sub    $0x18,%esp
c010291f:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
c0102925:	c6 45 ef 34          	movb   $0x34,-0x11(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102929:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
c010292d:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0102931:	ee                   	out    %al,(%dx)
c0102932:	66 c7 45 f4 40 00    	movw   $0x40,-0xc(%ebp)
c0102938:	c6 45 f0 9c          	movb   $0x9c,-0x10(%ebp)
c010293c:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
c0102940:	0f b7 55 f4          	movzwl -0xc(%ebp),%edx
c0102944:	ee                   	out    %al,(%dx)
c0102945:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c010294b:	c6 45 f1 2e          	movb   $0x2e,-0xf(%ebp)
c010294f:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0102953:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102957:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0102958:	c7 05 f4 aa 12 c0 00 	movl   $0x0,0xc012aaf4
c010295f:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0102962:	83 ec 0c             	sub    $0xc,%esp
c0102965:	68 4e b0 10 c0       	push   $0xc010b04e
c010296a:	e8 0f d9 ff ff       	call   c010027e <cprintf>
c010296f:	83 c4 10             	add    $0x10,%esp
    pic_enable(IRQ_TIMER);
c0102972:	83 ec 0c             	sub    $0xc,%esp
c0102975:	6a 00                	push   $0x0
c0102977:	e8 3b 09 00 00       	call   c01032b7 <pic_enable>
c010297c:	83 c4 10             	add    $0x10,%esp
}
c010297f:	90                   	nop
c0102980:	c9                   	leave  
c0102981:	c3                   	ret    

c0102982 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0102982:	55                   	push   %ebp
c0102983:	89 e5                	mov    %esp,%ebp
c0102985:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0102988:	9c                   	pushf  
c0102989:	58                   	pop    %eax
c010298a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c010298d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0102990:	25 00 02 00 00       	and    $0x200,%eax
c0102995:	85 c0                	test   %eax,%eax
c0102997:	74 0c                	je     c01029a5 <__intr_save+0x23>
        intr_disable();
c0102999:	e8 8a 0a 00 00       	call   c0103428 <intr_disable>
        return 1;
c010299e:	b8 01 00 00 00       	mov    $0x1,%eax
c01029a3:	eb 05                	jmp    c01029aa <__intr_save+0x28>
    }
    return 0;
c01029a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01029aa:	c9                   	leave  
c01029ab:	c3                   	ret    

c01029ac <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c01029ac:	55                   	push   %ebp
c01029ad:	89 e5                	mov    %esp,%ebp
c01029af:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01029b2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01029b6:	74 05                	je     c01029bd <__intr_restore+0x11>
        intr_enable();
c01029b8:	e8 64 0a 00 00       	call   c0103421 <intr_enable>
    }
}
c01029bd:	90                   	nop
c01029be:	c9                   	leave  
c01029bf:	c3                   	ret    

c01029c0 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c01029c0:	55                   	push   %ebp
c01029c1:	89 e5                	mov    %esp,%ebp
c01029c3:	83 ec 10             	sub    $0x10,%esp
c01029c6:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01029cc:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c01029d0:	89 c2                	mov    %eax,%edx
c01029d2:	ec                   	in     (%dx),%al
c01029d3:	88 45 f4             	mov    %al,-0xc(%ebp)
c01029d6:	66 c7 45 fc 84 00    	movw   $0x84,-0x4(%ebp)
c01029dc:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c01029e0:	89 c2                	mov    %eax,%edx
c01029e2:	ec                   	in     (%dx),%al
c01029e3:	88 45 f5             	mov    %al,-0xb(%ebp)
c01029e6:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c01029ec:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01029f0:	89 c2                	mov    %eax,%edx
c01029f2:	ec                   	in     (%dx),%al
c01029f3:	88 45 f6             	mov    %al,-0xa(%ebp)
c01029f6:	66 c7 45 f8 84 00    	movw   $0x84,-0x8(%ebp)
c01029fc:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
c0102a00:	89 c2                	mov    %eax,%edx
c0102a02:	ec                   	in     (%dx),%al
c0102a03:	88 45 f7             	mov    %al,-0x9(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0102a06:	90                   	nop
c0102a07:	c9                   	leave  
c0102a08:	c3                   	ret    

c0102a09 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0102a09:	55                   	push   %ebp
c0102a0a:	89 e5                	mov    %esp,%ebp
c0102a0c:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0102a0f:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0102a16:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102a19:	0f b7 00             	movzwl (%eax),%eax
c0102a1c:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0102a20:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102a23:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0102a28:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102a2b:	0f b7 00             	movzwl (%eax),%eax
c0102a2e:	66 3d 5a a5          	cmp    $0xa55a,%ax
c0102a32:	74 12                	je     c0102a46 <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0102a34:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0102a3b:	66 c7 05 c6 7f 12 c0 	movw   $0x3b4,0xc0127fc6
c0102a42:	b4 03 
c0102a44:	eb 13                	jmp    c0102a59 <cga_init+0x50>
    } else {
        *cp = was;
c0102a46:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102a49:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0102a4d:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0102a50:	66 c7 05 c6 7f 12 c0 	movw   $0x3d4,0xc0127fc6
c0102a57:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0102a59:	0f b7 05 c6 7f 12 c0 	movzwl 0xc0127fc6,%eax
c0102a60:	0f b7 c0             	movzwl %ax,%eax
c0102a63:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
c0102a67:	c6 45 ea 0e          	movb   $0xe,-0x16(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102a6b:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
c0102a6f:	0f b7 55 f8          	movzwl -0x8(%ebp),%edx
c0102a73:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0102a74:	0f b7 05 c6 7f 12 c0 	movzwl 0xc0127fc6,%eax
c0102a7b:	83 c0 01             	add    $0x1,%eax
c0102a7e:	0f b7 c0             	movzwl %ax,%eax
c0102a81:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0102a85:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0102a89:	89 c2                	mov    %eax,%edx
c0102a8b:	ec                   	in     (%dx),%al
c0102a8c:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0102a8f:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
c0102a93:	0f b6 c0             	movzbl %al,%eax
c0102a96:	c1 e0 08             	shl    $0x8,%eax
c0102a99:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0102a9c:	0f b7 05 c6 7f 12 c0 	movzwl 0xc0127fc6,%eax
c0102aa3:	0f b7 c0             	movzwl %ax,%eax
c0102aa6:	66 89 45 f0          	mov    %ax,-0x10(%ebp)
c0102aaa:	c6 45 ec 0f          	movb   $0xf,-0x14(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102aae:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
c0102ab2:	0f b7 55 f0          	movzwl -0x10(%ebp),%edx
c0102ab6:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c0102ab7:	0f b7 05 c6 7f 12 c0 	movzwl 0xc0127fc6,%eax
c0102abe:	83 c0 01             	add    $0x1,%eax
c0102ac1:	0f b7 c0             	movzwl %ax,%eax
c0102ac4:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0102ac8:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0102acc:	89 c2                	mov    %eax,%edx
c0102ace:	ec                   	in     (%dx),%al
c0102acf:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0102ad2:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0102ad6:	0f b6 c0             	movzbl %al,%eax
c0102ad9:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0102adc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102adf:	a3 c0 7f 12 c0       	mov    %eax,0xc0127fc0
    crt_pos = pos;
c0102ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102ae7:	66 a3 c4 7f 12 c0    	mov    %ax,0xc0127fc4
}
c0102aed:	90                   	nop
c0102aee:	c9                   	leave  
c0102aef:	c3                   	ret    

c0102af0 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0102af0:	55                   	push   %ebp
c0102af1:	89 e5                	mov    %esp,%ebp
c0102af3:	83 ec 28             	sub    $0x28,%esp
c0102af6:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
c0102afc:	c6 45 da 00          	movb   $0x0,-0x26(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102b00:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
c0102b04:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0102b08:	ee                   	out    %al,(%dx)
c0102b09:	66 c7 45 f4 fb 03    	movw   $0x3fb,-0xc(%ebp)
c0102b0f:	c6 45 db 80          	movb   $0x80,-0x25(%ebp)
c0102b13:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
c0102b17:	0f b7 55 f4          	movzwl -0xc(%ebp),%edx
c0102b1b:	ee                   	out    %al,(%dx)
c0102b1c:	66 c7 45 f2 f8 03    	movw   $0x3f8,-0xe(%ebp)
c0102b22:	c6 45 dc 0c          	movb   $0xc,-0x24(%ebp)
c0102b26:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
c0102b2a:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102b2e:	ee                   	out    %al,(%dx)
c0102b2f:	66 c7 45 f0 f9 03    	movw   $0x3f9,-0x10(%ebp)
c0102b35:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
c0102b39:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0102b3d:	0f b7 55 f0          	movzwl -0x10(%ebp),%edx
c0102b41:	ee                   	out    %al,(%dx)
c0102b42:	66 c7 45 ee fb 03    	movw   $0x3fb,-0x12(%ebp)
c0102b48:	c6 45 de 03          	movb   $0x3,-0x22(%ebp)
c0102b4c:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
c0102b50:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0102b54:	ee                   	out    %al,(%dx)
c0102b55:	66 c7 45 ec fc 03    	movw   $0x3fc,-0x14(%ebp)
c0102b5b:	c6 45 df 00          	movb   $0x0,-0x21(%ebp)
c0102b5f:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
c0102b63:	0f b7 55 ec          	movzwl -0x14(%ebp),%edx
c0102b67:	ee                   	out    %al,(%dx)
c0102b68:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0102b6e:	c6 45 e0 01          	movb   $0x1,-0x20(%ebp)
c0102b72:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
c0102b76:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0102b7a:	ee                   	out    %al,(%dx)
c0102b7b:	66 c7 45 e8 fd 03    	movw   $0x3fd,-0x18(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0102b81:	0f b7 45 e8          	movzwl -0x18(%ebp),%eax
c0102b85:	89 c2                	mov    %eax,%edx
c0102b87:	ec                   	in     (%dx),%al
c0102b88:	88 45 e1             	mov    %al,-0x1f(%ebp)
    return data;
c0102b8b:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0102b8f:	3c ff                	cmp    $0xff,%al
c0102b91:	0f 95 c0             	setne  %al
c0102b94:	0f b6 c0             	movzbl %al,%eax
c0102b97:	a3 c8 7f 12 c0       	mov    %eax,0xc0127fc8
c0102b9c:	66 c7 45 e6 fa 03    	movw   $0x3fa,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0102ba2:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c0102ba6:	89 c2                	mov    %eax,%edx
c0102ba8:	ec                   	in     (%dx),%al
c0102ba9:	88 45 e2             	mov    %al,-0x1e(%ebp)
c0102bac:	66 c7 45 e4 f8 03    	movw   $0x3f8,-0x1c(%ebp)
c0102bb2:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
c0102bb6:	89 c2                	mov    %eax,%edx
c0102bb8:	ec                   	in     (%dx),%al
c0102bb9:	88 45 e3             	mov    %al,-0x1d(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c0102bbc:	a1 c8 7f 12 c0       	mov    0xc0127fc8,%eax
c0102bc1:	85 c0                	test   %eax,%eax
c0102bc3:	74 0d                	je     c0102bd2 <serial_init+0xe2>
        pic_enable(IRQ_COM1);
c0102bc5:	83 ec 0c             	sub    $0xc,%esp
c0102bc8:	6a 04                	push   $0x4
c0102bca:	e8 e8 06 00 00       	call   c01032b7 <pic_enable>
c0102bcf:	83 c4 10             	add    $0x10,%esp
    }
}
c0102bd2:	90                   	nop
c0102bd3:	c9                   	leave  
c0102bd4:	c3                   	ret    

c0102bd5 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c0102bd5:	55                   	push   %ebp
c0102bd6:	89 e5                	mov    %esp,%ebp
c0102bd8:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0102bdb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0102be2:	eb 09                	jmp    c0102bed <lpt_putc_sub+0x18>
        delay();
c0102be4:	e8 d7 fd ff ff       	call   c01029c0 <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0102be9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0102bed:	66 c7 45 f4 79 03    	movw   $0x379,-0xc(%ebp)
c0102bf3:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0102bf7:	89 c2                	mov    %eax,%edx
c0102bf9:	ec                   	in     (%dx),%al
c0102bfa:	88 45 f3             	mov    %al,-0xd(%ebp)
    return data;
c0102bfd:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0102c01:	84 c0                	test   %al,%al
c0102c03:	78 09                	js     c0102c0e <lpt_putc_sub+0x39>
c0102c05:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0102c0c:	7e d6                	jle    c0102be4 <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
c0102c0e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c11:	0f b6 c0             	movzbl %al,%eax
c0102c14:	66 c7 45 f8 78 03    	movw   $0x378,-0x8(%ebp)
c0102c1a:	88 45 f0             	mov    %al,-0x10(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102c1d:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
c0102c21:	0f b7 55 f8          	movzwl -0x8(%ebp),%edx
c0102c25:	ee                   	out    %al,(%dx)
c0102c26:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
c0102c2c:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c0102c30:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0102c34:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0102c38:	ee                   	out    %al,(%dx)
c0102c39:	66 c7 45 fa 7a 03    	movw   $0x37a,-0x6(%ebp)
c0102c3f:	c6 45 f2 08          	movb   $0x8,-0xe(%ebp)
c0102c43:	0f b6 45 f2          	movzbl -0xe(%ebp),%eax
c0102c47:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0102c4b:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c0102c4c:	90                   	nop
c0102c4d:	c9                   	leave  
c0102c4e:	c3                   	ret    

c0102c4f <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c0102c4f:	55                   	push   %ebp
c0102c50:	89 e5                	mov    %esp,%ebp
    if (c != '\b') {
c0102c52:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0102c56:	74 0d                	je     c0102c65 <lpt_putc+0x16>
        lpt_putc_sub(c);
c0102c58:	ff 75 08             	pushl  0x8(%ebp)
c0102c5b:	e8 75 ff ff ff       	call   c0102bd5 <lpt_putc_sub>
c0102c60:	83 c4 04             	add    $0x4,%esp
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
c0102c63:	eb 1e                	jmp    c0102c83 <lpt_putc+0x34>
lpt_putc(int c) {
    if (c != '\b') {
        lpt_putc_sub(c);
    }
    else {
        lpt_putc_sub('\b');
c0102c65:	6a 08                	push   $0x8
c0102c67:	e8 69 ff ff ff       	call   c0102bd5 <lpt_putc_sub>
c0102c6c:	83 c4 04             	add    $0x4,%esp
        lpt_putc_sub(' ');
c0102c6f:	6a 20                	push   $0x20
c0102c71:	e8 5f ff ff ff       	call   c0102bd5 <lpt_putc_sub>
c0102c76:	83 c4 04             	add    $0x4,%esp
        lpt_putc_sub('\b');
c0102c79:	6a 08                	push   $0x8
c0102c7b:	e8 55 ff ff ff       	call   c0102bd5 <lpt_putc_sub>
c0102c80:	83 c4 04             	add    $0x4,%esp
    }
}
c0102c83:	90                   	nop
c0102c84:	c9                   	leave  
c0102c85:	c3                   	ret    

c0102c86 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c0102c86:	55                   	push   %ebp
c0102c87:	89 e5                	mov    %esp,%ebp
c0102c89:	53                   	push   %ebx
c0102c8a:	83 ec 14             	sub    $0x14,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c0102c8d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c90:	b0 00                	mov    $0x0,%al
c0102c92:	85 c0                	test   %eax,%eax
c0102c94:	75 07                	jne    c0102c9d <cga_putc+0x17>
        c |= 0x0700;
c0102c96:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c0102c9d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ca0:	0f b6 c0             	movzbl %al,%eax
c0102ca3:	83 f8 0a             	cmp    $0xa,%eax
c0102ca6:	74 4e                	je     c0102cf6 <cga_putc+0x70>
c0102ca8:	83 f8 0d             	cmp    $0xd,%eax
c0102cab:	74 59                	je     c0102d06 <cga_putc+0x80>
c0102cad:	83 f8 08             	cmp    $0x8,%eax
c0102cb0:	0f 85 8a 00 00 00    	jne    c0102d40 <cga_putc+0xba>
    case '\b':
        if (crt_pos > 0) {
c0102cb6:	0f b7 05 c4 7f 12 c0 	movzwl 0xc0127fc4,%eax
c0102cbd:	66 85 c0             	test   %ax,%ax
c0102cc0:	0f 84 a0 00 00 00    	je     c0102d66 <cga_putc+0xe0>
            crt_pos --;
c0102cc6:	0f b7 05 c4 7f 12 c0 	movzwl 0xc0127fc4,%eax
c0102ccd:	83 e8 01             	sub    $0x1,%eax
c0102cd0:	66 a3 c4 7f 12 c0    	mov    %ax,0xc0127fc4
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c0102cd6:	a1 c0 7f 12 c0       	mov    0xc0127fc0,%eax
c0102cdb:	0f b7 15 c4 7f 12 c0 	movzwl 0xc0127fc4,%edx
c0102ce2:	0f b7 d2             	movzwl %dx,%edx
c0102ce5:	01 d2                	add    %edx,%edx
c0102ce7:	01 d0                	add    %edx,%eax
c0102ce9:	8b 55 08             	mov    0x8(%ebp),%edx
c0102cec:	b2 00                	mov    $0x0,%dl
c0102cee:	83 ca 20             	or     $0x20,%edx
c0102cf1:	66 89 10             	mov    %dx,(%eax)
        }
        break;
c0102cf4:	eb 70                	jmp    c0102d66 <cga_putc+0xe0>
    case '\n':
        crt_pos += CRT_COLS;
c0102cf6:	0f b7 05 c4 7f 12 c0 	movzwl 0xc0127fc4,%eax
c0102cfd:	83 c0 50             	add    $0x50,%eax
c0102d00:	66 a3 c4 7f 12 c0    	mov    %ax,0xc0127fc4
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c0102d06:	0f b7 1d c4 7f 12 c0 	movzwl 0xc0127fc4,%ebx
c0102d0d:	0f b7 0d c4 7f 12 c0 	movzwl 0xc0127fc4,%ecx
c0102d14:	0f b7 c1             	movzwl %cx,%eax
c0102d17:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
c0102d1d:	c1 e8 10             	shr    $0x10,%eax
c0102d20:	89 c2                	mov    %eax,%edx
c0102d22:	66 c1 ea 06          	shr    $0x6,%dx
c0102d26:	89 d0                	mov    %edx,%eax
c0102d28:	c1 e0 02             	shl    $0x2,%eax
c0102d2b:	01 d0                	add    %edx,%eax
c0102d2d:	c1 e0 04             	shl    $0x4,%eax
c0102d30:	29 c1                	sub    %eax,%ecx
c0102d32:	89 ca                	mov    %ecx,%edx
c0102d34:	89 d8                	mov    %ebx,%eax
c0102d36:	29 d0                	sub    %edx,%eax
c0102d38:	66 a3 c4 7f 12 c0    	mov    %ax,0xc0127fc4
        break;
c0102d3e:	eb 27                	jmp    c0102d67 <cga_putc+0xe1>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c0102d40:	8b 0d c0 7f 12 c0    	mov    0xc0127fc0,%ecx
c0102d46:	0f b7 05 c4 7f 12 c0 	movzwl 0xc0127fc4,%eax
c0102d4d:	8d 50 01             	lea    0x1(%eax),%edx
c0102d50:	66 89 15 c4 7f 12 c0 	mov    %dx,0xc0127fc4
c0102d57:	0f b7 c0             	movzwl %ax,%eax
c0102d5a:	01 c0                	add    %eax,%eax
c0102d5c:	01 c8                	add    %ecx,%eax
c0102d5e:	8b 55 08             	mov    0x8(%ebp),%edx
c0102d61:	66 89 10             	mov    %dx,(%eax)
        break;
c0102d64:	eb 01                	jmp    c0102d67 <cga_putc+0xe1>
    case '\b':
        if (crt_pos > 0) {
            crt_pos --;
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
        }
        break;
c0102d66:	90                   	nop
        crt_buf[crt_pos ++] = c;     // write the character
        break;
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c0102d67:	0f b7 05 c4 7f 12 c0 	movzwl 0xc0127fc4,%eax
c0102d6e:	66 3d cf 07          	cmp    $0x7cf,%ax
c0102d72:	76 59                	jbe    c0102dcd <cga_putc+0x147>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c0102d74:	a1 c0 7f 12 c0       	mov    0xc0127fc0,%eax
c0102d79:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c0102d7f:	a1 c0 7f 12 c0       	mov    0xc0127fc0,%eax
c0102d84:	83 ec 04             	sub    $0x4,%esp
c0102d87:	68 00 0f 00 00       	push   $0xf00
c0102d8c:	52                   	push   %edx
c0102d8d:	50                   	push   %eax
c0102d8e:	e8 05 74 00 00       	call   c010a198 <memmove>
c0102d93:	83 c4 10             	add    $0x10,%esp
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0102d96:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c0102d9d:	eb 15                	jmp    c0102db4 <cga_putc+0x12e>
            crt_buf[i] = 0x0700 | ' ';
c0102d9f:	a1 c0 7f 12 c0       	mov    0xc0127fc0,%eax
c0102da4:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102da7:	01 d2                	add    %edx,%edx
c0102da9:	01 d0                	add    %edx,%eax
c0102dab:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0102db0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0102db4:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c0102dbb:	7e e2                	jle    c0102d9f <cga_putc+0x119>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
c0102dbd:	0f b7 05 c4 7f 12 c0 	movzwl 0xc0127fc4,%eax
c0102dc4:	83 e8 50             	sub    $0x50,%eax
c0102dc7:	66 a3 c4 7f 12 c0    	mov    %ax,0xc0127fc4
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c0102dcd:	0f b7 05 c6 7f 12 c0 	movzwl 0xc0127fc6,%eax
c0102dd4:	0f b7 c0             	movzwl %ax,%eax
c0102dd7:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0102ddb:	c6 45 e8 0e          	movb   $0xe,-0x18(%ebp)
c0102ddf:	0f b6 45 e8          	movzbl -0x18(%ebp),%eax
c0102de3:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102de7:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c0102de8:	0f b7 05 c4 7f 12 c0 	movzwl 0xc0127fc4,%eax
c0102def:	66 c1 e8 08          	shr    $0x8,%ax
c0102df3:	0f b6 c0             	movzbl %al,%eax
c0102df6:	0f b7 15 c6 7f 12 c0 	movzwl 0xc0127fc6,%edx
c0102dfd:	83 c2 01             	add    $0x1,%edx
c0102e00:	0f b7 d2             	movzwl %dx,%edx
c0102e03:	66 89 55 f0          	mov    %dx,-0x10(%ebp)
c0102e07:	88 45 e9             	mov    %al,-0x17(%ebp)
c0102e0a:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0102e0e:	0f b7 55 f0          	movzwl -0x10(%ebp),%edx
c0102e12:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c0102e13:	0f b7 05 c6 7f 12 c0 	movzwl 0xc0127fc6,%eax
c0102e1a:	0f b7 c0             	movzwl %ax,%eax
c0102e1d:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0102e21:	c6 45 ea 0f          	movb   $0xf,-0x16(%ebp)
c0102e25:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
c0102e29:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0102e2d:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c0102e2e:	0f b7 05 c4 7f 12 c0 	movzwl 0xc0127fc4,%eax
c0102e35:	0f b6 c0             	movzbl %al,%eax
c0102e38:	0f b7 15 c6 7f 12 c0 	movzwl 0xc0127fc6,%edx
c0102e3f:	83 c2 01             	add    $0x1,%edx
c0102e42:	0f b7 d2             	movzwl %dx,%edx
c0102e45:	66 89 55 ec          	mov    %dx,-0x14(%ebp)
c0102e49:	88 45 eb             	mov    %al,-0x15(%ebp)
c0102e4c:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
c0102e50:	0f b7 55 ec          	movzwl -0x14(%ebp),%edx
c0102e54:	ee                   	out    %al,(%dx)
}
c0102e55:	90                   	nop
c0102e56:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0102e59:	c9                   	leave  
c0102e5a:	c3                   	ret    

c0102e5b <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c0102e5b:	55                   	push   %ebp
c0102e5c:	89 e5                	mov    %esp,%ebp
c0102e5e:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0102e61:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0102e68:	eb 09                	jmp    c0102e73 <serial_putc_sub+0x18>
        delay();
c0102e6a:	e8 51 fb ff ff       	call   c01029c0 <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0102e6f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0102e73:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0102e79:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
c0102e7d:	89 c2                	mov    %eax,%edx
c0102e7f:	ec                   	in     (%dx),%al
c0102e80:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
c0102e83:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0102e87:	0f b6 c0             	movzbl %al,%eax
c0102e8a:	83 e0 20             	and    $0x20,%eax
c0102e8d:	85 c0                	test   %eax,%eax
c0102e8f:	75 09                	jne    c0102e9a <serial_putc_sub+0x3f>
c0102e91:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0102e98:	7e d0                	jle    c0102e6a <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
c0102e9a:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e9d:	0f b6 c0             	movzbl %al,%eax
c0102ea0:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
c0102ea6:	88 45 f6             	mov    %al,-0xa(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102ea9:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
c0102ead:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0102eb1:	ee                   	out    %al,(%dx)
}
c0102eb2:	90                   	nop
c0102eb3:	c9                   	leave  
c0102eb4:	c3                   	ret    

c0102eb5 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0102eb5:	55                   	push   %ebp
c0102eb6:	89 e5                	mov    %esp,%ebp
    if (c != '\b') {
c0102eb8:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0102ebc:	74 0d                	je     c0102ecb <serial_putc+0x16>
        serial_putc_sub(c);
c0102ebe:	ff 75 08             	pushl  0x8(%ebp)
c0102ec1:	e8 95 ff ff ff       	call   c0102e5b <serial_putc_sub>
c0102ec6:	83 c4 04             	add    $0x4,%esp
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
c0102ec9:	eb 1e                	jmp    c0102ee9 <serial_putc+0x34>
serial_putc(int c) {
    if (c != '\b') {
        serial_putc_sub(c);
    }
    else {
        serial_putc_sub('\b');
c0102ecb:	6a 08                	push   $0x8
c0102ecd:	e8 89 ff ff ff       	call   c0102e5b <serial_putc_sub>
c0102ed2:	83 c4 04             	add    $0x4,%esp
        serial_putc_sub(' ');
c0102ed5:	6a 20                	push   $0x20
c0102ed7:	e8 7f ff ff ff       	call   c0102e5b <serial_putc_sub>
c0102edc:	83 c4 04             	add    $0x4,%esp
        serial_putc_sub('\b');
c0102edf:	6a 08                	push   $0x8
c0102ee1:	e8 75 ff ff ff       	call   c0102e5b <serial_putc_sub>
c0102ee6:	83 c4 04             	add    $0x4,%esp
    }
}
c0102ee9:	90                   	nop
c0102eea:	c9                   	leave  
c0102eeb:	c3                   	ret    

c0102eec <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0102eec:	55                   	push   %ebp
c0102eed:	89 e5                	mov    %esp,%ebp
c0102eef:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c0102ef2:	eb 33                	jmp    c0102f27 <cons_intr+0x3b>
        if (c != 0) {
c0102ef4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102ef8:	74 2d                	je     c0102f27 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c0102efa:	a1 e4 81 12 c0       	mov    0xc01281e4,%eax
c0102eff:	8d 50 01             	lea    0x1(%eax),%edx
c0102f02:	89 15 e4 81 12 c0    	mov    %edx,0xc01281e4
c0102f08:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102f0b:	88 90 e0 7f 12 c0    	mov    %dl,-0x3fed8020(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0102f11:	a1 e4 81 12 c0       	mov    0xc01281e4,%eax
c0102f16:	3d 00 02 00 00       	cmp    $0x200,%eax
c0102f1b:	75 0a                	jne    c0102f27 <cons_intr+0x3b>
                cons.wpos = 0;
c0102f1d:	c7 05 e4 81 12 c0 00 	movl   $0x0,0xc01281e4
c0102f24:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
c0102f27:	8b 45 08             	mov    0x8(%ebp),%eax
c0102f2a:	ff d0                	call   *%eax
c0102f2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102f2f:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c0102f33:	75 bf                	jne    c0102ef4 <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
c0102f35:	90                   	nop
c0102f36:	c9                   	leave  
c0102f37:	c3                   	ret    

c0102f38 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c0102f38:	55                   	push   %ebp
c0102f39:	89 e5                	mov    %esp,%ebp
c0102f3b:	83 ec 10             	sub    $0x10,%esp
c0102f3e:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0102f44:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
c0102f48:	89 c2                	mov    %eax,%edx
c0102f4a:	ec                   	in     (%dx),%al
c0102f4b:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
c0102f4e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c0102f52:	0f b6 c0             	movzbl %al,%eax
c0102f55:	83 e0 01             	and    $0x1,%eax
c0102f58:	85 c0                	test   %eax,%eax
c0102f5a:	75 07                	jne    c0102f63 <serial_proc_data+0x2b>
        return -1;
c0102f5c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0102f61:	eb 2a                	jmp    c0102f8d <serial_proc_data+0x55>
c0102f63:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0102f69:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0102f6d:	89 c2                	mov    %eax,%edx
c0102f6f:	ec                   	in     (%dx),%al
c0102f70:	88 45 f6             	mov    %al,-0xa(%ebp)
    return data;
c0102f73:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c0102f77:	0f b6 c0             	movzbl %al,%eax
c0102f7a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c0102f7d:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0102f81:	75 07                	jne    c0102f8a <serial_proc_data+0x52>
        c = '\b';
c0102f83:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0102f8a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0102f8d:	c9                   	leave  
c0102f8e:	c3                   	ret    

c0102f8f <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0102f8f:	55                   	push   %ebp
c0102f90:	89 e5                	mov    %esp,%ebp
c0102f92:	83 ec 08             	sub    $0x8,%esp
    if (serial_exists) {
c0102f95:	a1 c8 7f 12 c0       	mov    0xc0127fc8,%eax
c0102f9a:	85 c0                	test   %eax,%eax
c0102f9c:	74 10                	je     c0102fae <serial_intr+0x1f>
        cons_intr(serial_proc_data);
c0102f9e:	83 ec 0c             	sub    $0xc,%esp
c0102fa1:	68 38 2f 10 c0       	push   $0xc0102f38
c0102fa6:	e8 41 ff ff ff       	call   c0102eec <cons_intr>
c0102fab:	83 c4 10             	add    $0x10,%esp
    }
}
c0102fae:	90                   	nop
c0102faf:	c9                   	leave  
c0102fb0:	c3                   	ret    

c0102fb1 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0102fb1:	55                   	push   %ebp
c0102fb2:	89 e5                	mov    %esp,%ebp
c0102fb4:	83 ec 18             	sub    $0x18,%esp
c0102fb7:	66 c7 45 ec 64 00    	movw   $0x64,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0102fbd:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0102fc1:	89 c2                	mov    %eax,%edx
c0102fc3:	ec                   	in     (%dx),%al
c0102fc4:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0102fc7:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c0102fcb:	0f b6 c0             	movzbl %al,%eax
c0102fce:	83 e0 01             	and    $0x1,%eax
c0102fd1:	85 c0                	test   %eax,%eax
c0102fd3:	75 0a                	jne    c0102fdf <kbd_proc_data+0x2e>
        return -1;
c0102fd5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0102fda:	e9 5d 01 00 00       	jmp    c010313c <kbd_proc_data+0x18b>
c0102fdf:	66 c7 45 f0 60 00    	movw   $0x60,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0102fe5:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0102fe9:	89 c2                	mov    %eax,%edx
c0102feb:	ec                   	in     (%dx),%al
c0102fec:	88 45 ea             	mov    %al,-0x16(%ebp)
    return data;
c0102fef:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
    }

    data = inb(KBDATAP);
c0102ff3:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0102ff6:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c0102ffa:	75 17                	jne    c0103013 <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
c0102ffc:	a1 e8 81 12 c0       	mov    0xc01281e8,%eax
c0103001:	83 c8 40             	or     $0x40,%eax
c0103004:	a3 e8 81 12 c0       	mov    %eax,0xc01281e8
        return 0;
c0103009:	b8 00 00 00 00       	mov    $0x0,%eax
c010300e:	e9 29 01 00 00       	jmp    c010313c <kbd_proc_data+0x18b>
    } else if (data & 0x80) {
c0103013:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0103017:	84 c0                	test   %al,%al
c0103019:	79 47                	jns    c0103062 <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c010301b:	a1 e8 81 12 c0       	mov    0xc01281e8,%eax
c0103020:	83 e0 40             	and    $0x40,%eax
c0103023:	85 c0                	test   %eax,%eax
c0103025:	75 09                	jne    c0103030 <kbd_proc_data+0x7f>
c0103027:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010302b:	83 e0 7f             	and    $0x7f,%eax
c010302e:	eb 04                	jmp    c0103034 <kbd_proc_data+0x83>
c0103030:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0103034:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c0103037:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010303b:	0f b6 80 60 70 12 c0 	movzbl -0x3fed8fa0(%eax),%eax
c0103042:	83 c8 40             	or     $0x40,%eax
c0103045:	0f b6 c0             	movzbl %al,%eax
c0103048:	f7 d0                	not    %eax
c010304a:	89 c2                	mov    %eax,%edx
c010304c:	a1 e8 81 12 c0       	mov    0xc01281e8,%eax
c0103051:	21 d0                	and    %edx,%eax
c0103053:	a3 e8 81 12 c0       	mov    %eax,0xc01281e8
        return 0;
c0103058:	b8 00 00 00 00       	mov    $0x0,%eax
c010305d:	e9 da 00 00 00       	jmp    c010313c <kbd_proc_data+0x18b>
    } else if (shift & E0ESC) {
c0103062:	a1 e8 81 12 c0       	mov    0xc01281e8,%eax
c0103067:	83 e0 40             	and    $0x40,%eax
c010306a:	85 c0                	test   %eax,%eax
c010306c:	74 11                	je     c010307f <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c010306e:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c0103072:	a1 e8 81 12 c0       	mov    0xc01281e8,%eax
c0103077:	83 e0 bf             	and    $0xffffffbf,%eax
c010307a:	a3 e8 81 12 c0       	mov    %eax,0xc01281e8
    }

    shift |= shiftcode[data];
c010307f:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0103083:	0f b6 80 60 70 12 c0 	movzbl -0x3fed8fa0(%eax),%eax
c010308a:	0f b6 d0             	movzbl %al,%edx
c010308d:	a1 e8 81 12 c0       	mov    0xc01281e8,%eax
c0103092:	09 d0                	or     %edx,%eax
c0103094:	a3 e8 81 12 c0       	mov    %eax,0xc01281e8
    shift ^= togglecode[data];
c0103099:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010309d:	0f b6 80 60 71 12 c0 	movzbl -0x3fed8ea0(%eax),%eax
c01030a4:	0f b6 d0             	movzbl %al,%edx
c01030a7:	a1 e8 81 12 c0       	mov    0xc01281e8,%eax
c01030ac:	31 d0                	xor    %edx,%eax
c01030ae:	a3 e8 81 12 c0       	mov    %eax,0xc01281e8

    c = charcode[shift & (CTL | SHIFT)][data];
c01030b3:	a1 e8 81 12 c0       	mov    0xc01281e8,%eax
c01030b8:	83 e0 03             	and    $0x3,%eax
c01030bb:	8b 14 85 60 75 12 c0 	mov    -0x3fed8aa0(,%eax,4),%edx
c01030c2:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01030c6:	01 d0                	add    %edx,%eax
c01030c8:	0f b6 00             	movzbl (%eax),%eax
c01030cb:	0f b6 c0             	movzbl %al,%eax
c01030ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c01030d1:	a1 e8 81 12 c0       	mov    0xc01281e8,%eax
c01030d6:	83 e0 08             	and    $0x8,%eax
c01030d9:	85 c0                	test   %eax,%eax
c01030db:	74 22                	je     c01030ff <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
c01030dd:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c01030e1:	7e 0c                	jle    c01030ef <kbd_proc_data+0x13e>
c01030e3:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c01030e7:	7f 06                	jg     c01030ef <kbd_proc_data+0x13e>
            c += 'A' - 'a';
c01030e9:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c01030ed:	eb 10                	jmp    c01030ff <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
c01030ef:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c01030f3:	7e 0a                	jle    c01030ff <kbd_proc_data+0x14e>
c01030f5:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c01030f9:	7f 04                	jg     c01030ff <kbd_proc_data+0x14e>
            c += 'a' - 'A';
c01030fb:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c01030ff:	a1 e8 81 12 c0       	mov    0xc01281e8,%eax
c0103104:	f7 d0                	not    %eax
c0103106:	83 e0 06             	and    $0x6,%eax
c0103109:	85 c0                	test   %eax,%eax
c010310b:	75 2c                	jne    c0103139 <kbd_proc_data+0x188>
c010310d:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0103114:	75 23                	jne    c0103139 <kbd_proc_data+0x188>
        cprintf("Rebooting!\n");
c0103116:	83 ec 0c             	sub    $0xc,%esp
c0103119:	68 69 b0 10 c0       	push   $0xc010b069
c010311e:	e8 5b d1 ff ff       	call   c010027e <cprintf>
c0103123:	83 c4 10             	add    $0x10,%esp
c0103126:	66 c7 45 ee 92 00    	movw   $0x92,-0x12(%ebp)
c010312c:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0103130:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0103134:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0103138:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c0103139:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010313c:	c9                   	leave  
c010313d:	c3                   	ret    

c010313e <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c010313e:	55                   	push   %ebp
c010313f:	89 e5                	mov    %esp,%ebp
c0103141:	83 ec 08             	sub    $0x8,%esp
    cons_intr(kbd_proc_data);
c0103144:	83 ec 0c             	sub    $0xc,%esp
c0103147:	68 b1 2f 10 c0       	push   $0xc0102fb1
c010314c:	e8 9b fd ff ff       	call   c0102eec <cons_intr>
c0103151:	83 c4 10             	add    $0x10,%esp
}
c0103154:	90                   	nop
c0103155:	c9                   	leave  
c0103156:	c3                   	ret    

c0103157 <kbd_init>:

static void
kbd_init(void) {
c0103157:	55                   	push   %ebp
c0103158:	89 e5                	mov    %esp,%ebp
c010315a:	83 ec 08             	sub    $0x8,%esp
    // drain the kbd buffer
    kbd_intr();
c010315d:	e8 dc ff ff ff       	call   c010313e <kbd_intr>
    pic_enable(IRQ_KBD);
c0103162:	83 ec 0c             	sub    $0xc,%esp
c0103165:	6a 01                	push   $0x1
c0103167:	e8 4b 01 00 00       	call   c01032b7 <pic_enable>
c010316c:	83 c4 10             	add    $0x10,%esp
}
c010316f:	90                   	nop
c0103170:	c9                   	leave  
c0103171:	c3                   	ret    

c0103172 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c0103172:	55                   	push   %ebp
c0103173:	89 e5                	mov    %esp,%ebp
c0103175:	83 ec 08             	sub    $0x8,%esp
    cga_init();
c0103178:	e8 8c f8 ff ff       	call   c0102a09 <cga_init>
    serial_init();
c010317d:	e8 6e f9 ff ff       	call   c0102af0 <serial_init>
    kbd_init();
c0103182:	e8 d0 ff ff ff       	call   c0103157 <kbd_init>
    if (!serial_exists) {
c0103187:	a1 c8 7f 12 c0       	mov    0xc0127fc8,%eax
c010318c:	85 c0                	test   %eax,%eax
c010318e:	75 10                	jne    c01031a0 <cons_init+0x2e>
        cprintf("serial port does not exist!!\n");
c0103190:	83 ec 0c             	sub    $0xc,%esp
c0103193:	68 75 b0 10 c0       	push   $0xc010b075
c0103198:	e8 e1 d0 ff ff       	call   c010027e <cprintf>
c010319d:	83 c4 10             	add    $0x10,%esp
    }
}
c01031a0:	90                   	nop
c01031a1:	c9                   	leave  
c01031a2:	c3                   	ret    

c01031a3 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c01031a3:	55                   	push   %ebp
c01031a4:	89 e5                	mov    %esp,%ebp
c01031a6:	83 ec 18             	sub    $0x18,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c01031a9:	e8 d4 f7 ff ff       	call   c0102982 <__intr_save>
c01031ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c01031b1:	83 ec 0c             	sub    $0xc,%esp
c01031b4:	ff 75 08             	pushl  0x8(%ebp)
c01031b7:	e8 93 fa ff ff       	call   c0102c4f <lpt_putc>
c01031bc:	83 c4 10             	add    $0x10,%esp
        cga_putc(c);
c01031bf:	83 ec 0c             	sub    $0xc,%esp
c01031c2:	ff 75 08             	pushl  0x8(%ebp)
c01031c5:	e8 bc fa ff ff       	call   c0102c86 <cga_putc>
c01031ca:	83 c4 10             	add    $0x10,%esp
        serial_putc(c);
c01031cd:	83 ec 0c             	sub    $0xc,%esp
c01031d0:	ff 75 08             	pushl  0x8(%ebp)
c01031d3:	e8 dd fc ff ff       	call   c0102eb5 <serial_putc>
c01031d8:	83 c4 10             	add    $0x10,%esp
    }
    local_intr_restore(intr_flag);
c01031db:	83 ec 0c             	sub    $0xc,%esp
c01031de:	ff 75 f4             	pushl  -0xc(%ebp)
c01031e1:	e8 c6 f7 ff ff       	call   c01029ac <__intr_restore>
c01031e6:	83 c4 10             	add    $0x10,%esp
}
c01031e9:	90                   	nop
c01031ea:	c9                   	leave  
c01031eb:	c3                   	ret    

c01031ec <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c01031ec:	55                   	push   %ebp
c01031ed:	89 e5                	mov    %esp,%ebp
c01031ef:	83 ec 18             	sub    $0x18,%esp
    int c = 0;
c01031f2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c01031f9:	e8 84 f7 ff ff       	call   c0102982 <__intr_save>
c01031fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0103201:	e8 89 fd ff ff       	call   c0102f8f <serial_intr>
        kbd_intr();
c0103206:	e8 33 ff ff ff       	call   c010313e <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c010320b:	8b 15 e0 81 12 c0    	mov    0xc01281e0,%edx
c0103211:	a1 e4 81 12 c0       	mov    0xc01281e4,%eax
c0103216:	39 c2                	cmp    %eax,%edx
c0103218:	74 31                	je     c010324b <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c010321a:	a1 e0 81 12 c0       	mov    0xc01281e0,%eax
c010321f:	8d 50 01             	lea    0x1(%eax),%edx
c0103222:	89 15 e0 81 12 c0    	mov    %edx,0xc01281e0
c0103228:	0f b6 80 e0 7f 12 c0 	movzbl -0x3fed8020(%eax),%eax
c010322f:	0f b6 c0             	movzbl %al,%eax
c0103232:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c0103235:	a1 e0 81 12 c0       	mov    0xc01281e0,%eax
c010323a:	3d 00 02 00 00       	cmp    $0x200,%eax
c010323f:	75 0a                	jne    c010324b <cons_getc+0x5f>
                cons.rpos = 0;
c0103241:	c7 05 e0 81 12 c0 00 	movl   $0x0,0xc01281e0
c0103248:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c010324b:	83 ec 0c             	sub    $0xc,%esp
c010324e:	ff 75 f0             	pushl  -0x10(%ebp)
c0103251:	e8 56 f7 ff ff       	call   c01029ac <__intr_restore>
c0103256:	83 c4 10             	add    $0x10,%esp
    return c;
c0103259:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010325c:	c9                   	leave  
c010325d:	c3                   	ret    

c010325e <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c010325e:	55                   	push   %ebp
c010325f:	89 e5                	mov    %esp,%ebp
c0103261:	83 ec 14             	sub    $0x14,%esp
c0103264:	8b 45 08             	mov    0x8(%ebp),%eax
c0103267:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c010326b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c010326f:	66 a3 70 75 12 c0    	mov    %ax,0xc0127570
    if (did_init) {
c0103275:	a1 ec 81 12 c0       	mov    0xc01281ec,%eax
c010327a:	85 c0                	test   %eax,%eax
c010327c:	74 36                	je     c01032b4 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
c010327e:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0103282:	0f b6 c0             	movzbl %al,%eax
c0103285:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c010328b:	88 45 fa             	mov    %al,-0x6(%ebp)
c010328e:	0f b6 45 fa          	movzbl -0x6(%ebp),%eax
c0103292:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0103296:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c0103297:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c010329b:	66 c1 e8 08          	shr    $0x8,%ax
c010329f:	0f b6 c0             	movzbl %al,%eax
c01032a2:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
c01032a8:	88 45 fb             	mov    %al,-0x5(%ebp)
c01032ab:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
c01032af:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
c01032b3:	ee                   	out    %al,(%dx)
    }
}
c01032b4:	90                   	nop
c01032b5:	c9                   	leave  
c01032b6:	c3                   	ret    

c01032b7 <pic_enable>:

void
pic_enable(unsigned int irq) {
c01032b7:	55                   	push   %ebp
c01032b8:	89 e5                	mov    %esp,%ebp
    pic_setmask(irq_mask & ~(1 << irq));
c01032ba:	8b 45 08             	mov    0x8(%ebp),%eax
c01032bd:	ba 01 00 00 00       	mov    $0x1,%edx
c01032c2:	89 c1                	mov    %eax,%ecx
c01032c4:	d3 e2                	shl    %cl,%edx
c01032c6:	89 d0                	mov    %edx,%eax
c01032c8:	f7 d0                	not    %eax
c01032ca:	89 c2                	mov    %eax,%edx
c01032cc:	0f b7 05 70 75 12 c0 	movzwl 0xc0127570,%eax
c01032d3:	21 d0                	and    %edx,%eax
c01032d5:	0f b7 c0             	movzwl %ax,%eax
c01032d8:	50                   	push   %eax
c01032d9:	e8 80 ff ff ff       	call   c010325e <pic_setmask>
c01032de:	83 c4 04             	add    $0x4,%esp
}
c01032e1:	90                   	nop
c01032e2:	c9                   	leave  
c01032e3:	c3                   	ret    

c01032e4 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c01032e4:	55                   	push   %ebp
c01032e5:	89 e5                	mov    %esp,%ebp
c01032e7:	83 ec 30             	sub    $0x30,%esp
    did_init = 1;
c01032ea:	c7 05 ec 81 12 c0 01 	movl   $0x1,0xc01281ec
c01032f1:	00 00 00 
c01032f4:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c01032fa:	c6 45 d6 ff          	movb   $0xff,-0x2a(%ebp)
c01032fe:	0f b6 45 d6          	movzbl -0x2a(%ebp),%eax
c0103302:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0103306:	ee                   	out    %al,(%dx)
c0103307:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
c010330d:	c6 45 d7 ff          	movb   $0xff,-0x29(%ebp)
c0103311:	0f b6 45 d7          	movzbl -0x29(%ebp),%eax
c0103315:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
c0103319:	ee                   	out    %al,(%dx)
c010331a:	66 c7 45 fa 20 00    	movw   $0x20,-0x6(%ebp)
c0103320:	c6 45 d8 11          	movb   $0x11,-0x28(%ebp)
c0103324:	0f b6 45 d8          	movzbl -0x28(%ebp),%eax
c0103328:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c010332c:	ee                   	out    %al,(%dx)
c010332d:	66 c7 45 f8 21 00    	movw   $0x21,-0x8(%ebp)
c0103333:	c6 45 d9 20          	movb   $0x20,-0x27(%ebp)
c0103337:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c010333b:	0f b7 55 f8          	movzwl -0x8(%ebp),%edx
c010333f:	ee                   	out    %al,(%dx)
c0103340:	66 c7 45 f6 21 00    	movw   $0x21,-0xa(%ebp)
c0103346:	c6 45 da 04          	movb   $0x4,-0x26(%ebp)
c010334a:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
c010334e:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0103352:	ee                   	out    %al,(%dx)
c0103353:	66 c7 45 f4 21 00    	movw   $0x21,-0xc(%ebp)
c0103359:	c6 45 db 03          	movb   $0x3,-0x25(%ebp)
c010335d:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
c0103361:	0f b7 55 f4          	movzwl -0xc(%ebp),%edx
c0103365:	ee                   	out    %al,(%dx)
c0103366:	66 c7 45 f2 a0 00    	movw   $0xa0,-0xe(%ebp)
c010336c:	c6 45 dc 11          	movb   $0x11,-0x24(%ebp)
c0103370:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
c0103374:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0103378:	ee                   	out    %al,(%dx)
c0103379:	66 c7 45 f0 a1 00    	movw   $0xa1,-0x10(%ebp)
c010337f:	c6 45 dd 28          	movb   $0x28,-0x23(%ebp)
c0103383:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0103387:	0f b7 55 f0          	movzwl -0x10(%ebp),%edx
c010338b:	ee                   	out    %al,(%dx)
c010338c:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
c0103392:	c6 45 de 02          	movb   $0x2,-0x22(%ebp)
c0103396:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
c010339a:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010339e:	ee                   	out    %al,(%dx)
c010339f:	66 c7 45 ec a1 00    	movw   $0xa1,-0x14(%ebp)
c01033a5:	c6 45 df 03          	movb   $0x3,-0x21(%ebp)
c01033a9:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
c01033ad:	0f b7 55 ec          	movzwl -0x14(%ebp),%edx
c01033b1:	ee                   	out    %al,(%dx)
c01033b2:	66 c7 45 ea 20 00    	movw   $0x20,-0x16(%ebp)
c01033b8:	c6 45 e0 68          	movb   $0x68,-0x20(%ebp)
c01033bc:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
c01033c0:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01033c4:	ee                   	out    %al,(%dx)
c01033c5:	66 c7 45 e8 20 00    	movw   $0x20,-0x18(%ebp)
c01033cb:	c6 45 e1 0a          	movb   $0xa,-0x1f(%ebp)
c01033cf:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01033d3:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c01033d7:	ee                   	out    %al,(%dx)
c01033d8:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
c01033de:	c6 45 e2 68          	movb   $0x68,-0x1e(%ebp)
c01033e2:	0f b6 45 e2          	movzbl -0x1e(%ebp),%eax
c01033e6:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01033ea:	ee                   	out    %al,(%dx)
c01033eb:	66 c7 45 e4 a0 00    	movw   $0xa0,-0x1c(%ebp)
c01033f1:	c6 45 e3 0a          	movb   $0xa,-0x1d(%ebp)
c01033f5:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
c01033f9:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
c01033fd:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c01033fe:	0f b7 05 70 75 12 c0 	movzwl 0xc0127570,%eax
c0103405:	66 83 f8 ff          	cmp    $0xffff,%ax
c0103409:	74 13                	je     c010341e <pic_init+0x13a>
        pic_setmask(irq_mask);
c010340b:	0f b7 05 70 75 12 c0 	movzwl 0xc0127570,%eax
c0103412:	0f b7 c0             	movzwl %ax,%eax
c0103415:	50                   	push   %eax
c0103416:	e8 43 fe ff ff       	call   c010325e <pic_setmask>
c010341b:	83 c4 04             	add    $0x4,%esp
    }
}
c010341e:	90                   	nop
c010341f:	c9                   	leave  
c0103420:	c3                   	ret    

c0103421 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c0103421:	55                   	push   %ebp
c0103422:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
c0103424:	fb                   	sti    
    sti();
}
c0103425:	90                   	nop
c0103426:	5d                   	pop    %ebp
c0103427:	c3                   	ret    

c0103428 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c0103428:	55                   	push   %ebp
c0103429:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
c010342b:	fa                   	cli    
    cli();
}
c010342c:	90                   	nop
c010342d:	5d                   	pop    %ebp
c010342e:	c3                   	ret    

c010342f <print_ticks>:
#include <swap.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c010342f:	55                   	push   %ebp
c0103430:	89 e5                	mov    %esp,%ebp
c0103432:	83 ec 08             	sub    $0x8,%esp
    cprintf("%d ticks\n",TICK_NUM);
c0103435:	83 ec 08             	sub    $0x8,%esp
c0103438:	6a 64                	push   $0x64
c010343a:	68 a0 b0 10 c0       	push   $0xc010b0a0
c010343f:	e8 3a ce ff ff       	call   c010027e <cprintf>
c0103444:	83 c4 10             	add    $0x10,%esp
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
c0103447:	90                   	nop
c0103448:	c9                   	leave  
c0103449:	c3                   	ret    

c010344a <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c010344a:	55                   	push   %ebp
c010344b:	89 e5                	mov    %esp,%ebp
c010344d:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c0103450:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0103457:	e9 c3 00 00 00       	jmp    c010351f <idt_init+0xd5>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c010345c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010345f:	8b 04 85 00 76 12 c0 	mov    -0x3fed8a00(,%eax,4),%eax
c0103466:	89 c2                	mov    %eax,%edx
c0103468:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010346b:	66 89 14 c5 00 82 12 	mov    %dx,-0x3fed7e00(,%eax,8)
c0103472:	c0 
c0103473:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103476:	66 c7 04 c5 02 82 12 	movw   $0x8,-0x3fed7dfe(,%eax,8)
c010347d:	c0 08 00 
c0103480:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103483:	0f b6 14 c5 04 82 12 	movzbl -0x3fed7dfc(,%eax,8),%edx
c010348a:	c0 
c010348b:	83 e2 e0             	and    $0xffffffe0,%edx
c010348e:	88 14 c5 04 82 12 c0 	mov    %dl,-0x3fed7dfc(,%eax,8)
c0103495:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103498:	0f b6 14 c5 04 82 12 	movzbl -0x3fed7dfc(,%eax,8),%edx
c010349f:	c0 
c01034a0:	83 e2 1f             	and    $0x1f,%edx
c01034a3:	88 14 c5 04 82 12 c0 	mov    %dl,-0x3fed7dfc(,%eax,8)
c01034aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01034ad:	0f b6 14 c5 05 82 12 	movzbl -0x3fed7dfb(,%eax,8),%edx
c01034b4:	c0 
c01034b5:	83 e2 f0             	and    $0xfffffff0,%edx
c01034b8:	83 ca 0e             	or     $0xe,%edx
c01034bb:	88 14 c5 05 82 12 c0 	mov    %dl,-0x3fed7dfb(,%eax,8)
c01034c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01034c5:	0f b6 14 c5 05 82 12 	movzbl -0x3fed7dfb(,%eax,8),%edx
c01034cc:	c0 
c01034cd:	83 e2 ef             	and    $0xffffffef,%edx
c01034d0:	88 14 c5 05 82 12 c0 	mov    %dl,-0x3fed7dfb(,%eax,8)
c01034d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01034da:	0f b6 14 c5 05 82 12 	movzbl -0x3fed7dfb(,%eax,8),%edx
c01034e1:	c0 
c01034e2:	83 e2 9f             	and    $0xffffff9f,%edx
c01034e5:	88 14 c5 05 82 12 c0 	mov    %dl,-0x3fed7dfb(,%eax,8)
c01034ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01034ef:	0f b6 14 c5 05 82 12 	movzbl -0x3fed7dfb(,%eax,8),%edx
c01034f6:	c0 
c01034f7:	83 ca 80             	or     $0xffffff80,%edx
c01034fa:	88 14 c5 05 82 12 c0 	mov    %dl,-0x3fed7dfb(,%eax,8)
c0103501:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103504:	8b 04 85 00 76 12 c0 	mov    -0x3fed8a00(,%eax,4),%eax
c010350b:	c1 e8 10             	shr    $0x10,%eax
c010350e:	89 c2                	mov    %eax,%edx
c0103510:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103513:	66 89 14 c5 06 82 12 	mov    %dx,-0x3fed7dfa(,%eax,8)
c010351a:	c0 
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c010351b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010351f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103522:	3d ff 00 00 00       	cmp    $0xff,%eax
c0103527:	0f 86 2f ff ff ff    	jbe    c010345c <idt_init+0x12>
c010352d:	c7 45 f8 80 75 12 c0 	movl   $0xc0127580,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c0103534:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0103537:	0f 01 18             	lidtl  (%eax)
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
    }
    lidt(&idt_pd);
}
c010353a:	90                   	nop
c010353b:	c9                   	leave  
c010353c:	c3                   	ret    

c010353d <trapname>:

static const char *
trapname(int trapno) {
c010353d:	55                   	push   %ebp
c010353e:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c0103540:	8b 45 08             	mov    0x8(%ebp),%eax
c0103543:	83 f8 13             	cmp    $0x13,%eax
c0103546:	77 0c                	ja     c0103554 <trapname+0x17>
        return excnames[trapno];
c0103548:	8b 45 08             	mov    0x8(%ebp),%eax
c010354b:	8b 04 85 80 b4 10 c0 	mov    -0x3fef4b80(,%eax,4),%eax
c0103552:	eb 18                	jmp    c010356c <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c0103554:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c0103558:	7e 0d                	jle    c0103567 <trapname+0x2a>
c010355a:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c010355e:	7f 07                	jg     c0103567 <trapname+0x2a>
        return "Hardware Interrupt";
c0103560:	b8 aa b0 10 c0       	mov    $0xc010b0aa,%eax
c0103565:	eb 05                	jmp    c010356c <trapname+0x2f>
    }
    return "(unknown trap)";
c0103567:	b8 bd b0 10 c0       	mov    $0xc010b0bd,%eax
}
c010356c:	5d                   	pop    %ebp
c010356d:	c3                   	ret    

c010356e <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c010356e:	55                   	push   %ebp
c010356f:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c0103571:	8b 45 08             	mov    0x8(%ebp),%eax
c0103574:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0103578:	66 83 f8 08          	cmp    $0x8,%ax
c010357c:	0f 94 c0             	sete   %al
c010357f:	0f b6 c0             	movzbl %al,%eax
}
c0103582:	5d                   	pop    %ebp
c0103583:	c3                   	ret    

c0103584 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c0103584:	55                   	push   %ebp
c0103585:	89 e5                	mov    %esp,%ebp
c0103587:	83 ec 18             	sub    $0x18,%esp
    cprintf("trapframe at %p\n", tf);
c010358a:	83 ec 08             	sub    $0x8,%esp
c010358d:	ff 75 08             	pushl  0x8(%ebp)
c0103590:	68 fe b0 10 c0       	push   $0xc010b0fe
c0103595:	e8 e4 cc ff ff       	call   c010027e <cprintf>
c010359a:	83 c4 10             	add    $0x10,%esp
    print_regs(&tf->tf_regs);
c010359d:	8b 45 08             	mov    0x8(%ebp),%eax
c01035a0:	83 ec 0c             	sub    $0xc,%esp
c01035a3:	50                   	push   %eax
c01035a4:	e8 b8 01 00 00       	call   c0103761 <print_regs>
c01035a9:	83 c4 10             	add    $0x10,%esp
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c01035ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01035af:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c01035b3:	0f b7 c0             	movzwl %ax,%eax
c01035b6:	83 ec 08             	sub    $0x8,%esp
c01035b9:	50                   	push   %eax
c01035ba:	68 0f b1 10 c0       	push   $0xc010b10f
c01035bf:	e8 ba cc ff ff       	call   c010027e <cprintf>
c01035c4:	83 c4 10             	add    $0x10,%esp
    cprintf("  es   0x----%04x\n", tf->tf_es);
c01035c7:	8b 45 08             	mov    0x8(%ebp),%eax
c01035ca:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c01035ce:	0f b7 c0             	movzwl %ax,%eax
c01035d1:	83 ec 08             	sub    $0x8,%esp
c01035d4:	50                   	push   %eax
c01035d5:	68 22 b1 10 c0       	push   $0xc010b122
c01035da:	e8 9f cc ff ff       	call   c010027e <cprintf>
c01035df:	83 c4 10             	add    $0x10,%esp
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c01035e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01035e5:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c01035e9:	0f b7 c0             	movzwl %ax,%eax
c01035ec:	83 ec 08             	sub    $0x8,%esp
c01035ef:	50                   	push   %eax
c01035f0:	68 35 b1 10 c0       	push   $0xc010b135
c01035f5:	e8 84 cc ff ff       	call   c010027e <cprintf>
c01035fa:	83 c4 10             	add    $0x10,%esp
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c01035fd:	8b 45 08             	mov    0x8(%ebp),%eax
c0103600:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0103604:	0f b7 c0             	movzwl %ax,%eax
c0103607:	83 ec 08             	sub    $0x8,%esp
c010360a:	50                   	push   %eax
c010360b:	68 48 b1 10 c0       	push   $0xc010b148
c0103610:	e8 69 cc ff ff       	call   c010027e <cprintf>
c0103615:	83 c4 10             	add    $0x10,%esp
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0103618:	8b 45 08             	mov    0x8(%ebp),%eax
c010361b:	8b 40 30             	mov    0x30(%eax),%eax
c010361e:	83 ec 0c             	sub    $0xc,%esp
c0103621:	50                   	push   %eax
c0103622:	e8 16 ff ff ff       	call   c010353d <trapname>
c0103627:	83 c4 10             	add    $0x10,%esp
c010362a:	89 c2                	mov    %eax,%edx
c010362c:	8b 45 08             	mov    0x8(%ebp),%eax
c010362f:	8b 40 30             	mov    0x30(%eax),%eax
c0103632:	83 ec 04             	sub    $0x4,%esp
c0103635:	52                   	push   %edx
c0103636:	50                   	push   %eax
c0103637:	68 5b b1 10 c0       	push   $0xc010b15b
c010363c:	e8 3d cc ff ff       	call   c010027e <cprintf>
c0103641:	83 c4 10             	add    $0x10,%esp
    cprintf("  err  0x%08x\n", tf->tf_err);
c0103644:	8b 45 08             	mov    0x8(%ebp),%eax
c0103647:	8b 40 34             	mov    0x34(%eax),%eax
c010364a:	83 ec 08             	sub    $0x8,%esp
c010364d:	50                   	push   %eax
c010364e:	68 6d b1 10 c0       	push   $0xc010b16d
c0103653:	e8 26 cc ff ff       	call   c010027e <cprintf>
c0103658:	83 c4 10             	add    $0x10,%esp
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c010365b:	8b 45 08             	mov    0x8(%ebp),%eax
c010365e:	8b 40 38             	mov    0x38(%eax),%eax
c0103661:	83 ec 08             	sub    $0x8,%esp
c0103664:	50                   	push   %eax
c0103665:	68 7c b1 10 c0       	push   $0xc010b17c
c010366a:	e8 0f cc ff ff       	call   c010027e <cprintf>
c010366f:	83 c4 10             	add    $0x10,%esp
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0103672:	8b 45 08             	mov    0x8(%ebp),%eax
c0103675:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0103679:	0f b7 c0             	movzwl %ax,%eax
c010367c:	83 ec 08             	sub    $0x8,%esp
c010367f:	50                   	push   %eax
c0103680:	68 8b b1 10 c0       	push   $0xc010b18b
c0103685:	e8 f4 cb ff ff       	call   c010027e <cprintf>
c010368a:	83 c4 10             	add    $0x10,%esp
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c010368d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103690:	8b 40 40             	mov    0x40(%eax),%eax
c0103693:	83 ec 08             	sub    $0x8,%esp
c0103696:	50                   	push   %eax
c0103697:	68 9e b1 10 c0       	push   $0xc010b19e
c010369c:	e8 dd cb ff ff       	call   c010027e <cprintf>
c01036a1:	83 c4 10             	add    $0x10,%esp

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c01036a4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01036ab:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c01036b2:	eb 3f                	jmp    c01036f3 <print_trapframe+0x16f>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c01036b4:	8b 45 08             	mov    0x8(%ebp),%eax
c01036b7:	8b 50 40             	mov    0x40(%eax),%edx
c01036ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01036bd:	21 d0                	and    %edx,%eax
c01036bf:	85 c0                	test   %eax,%eax
c01036c1:	74 29                	je     c01036ec <print_trapframe+0x168>
c01036c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036c6:	8b 04 85 a0 75 12 c0 	mov    -0x3fed8a60(,%eax,4),%eax
c01036cd:	85 c0                	test   %eax,%eax
c01036cf:	74 1b                	je     c01036ec <print_trapframe+0x168>
            cprintf("%s,", IA32flags[i]);
c01036d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036d4:	8b 04 85 a0 75 12 c0 	mov    -0x3fed8a60(,%eax,4),%eax
c01036db:	83 ec 08             	sub    $0x8,%esp
c01036de:	50                   	push   %eax
c01036df:	68 ad b1 10 c0       	push   $0xc010b1ad
c01036e4:	e8 95 cb ff ff       	call   c010027e <cprintf>
c01036e9:	83 c4 10             	add    $0x10,%esp
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c01036ec:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01036f0:	d1 65 f0             	shll   -0x10(%ebp)
c01036f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036f6:	83 f8 17             	cmp    $0x17,%eax
c01036f9:	76 b9                	jbe    c01036b4 <print_trapframe+0x130>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c01036fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01036fe:	8b 40 40             	mov    0x40(%eax),%eax
c0103701:	25 00 30 00 00       	and    $0x3000,%eax
c0103706:	c1 e8 0c             	shr    $0xc,%eax
c0103709:	83 ec 08             	sub    $0x8,%esp
c010370c:	50                   	push   %eax
c010370d:	68 b1 b1 10 c0       	push   $0xc010b1b1
c0103712:	e8 67 cb ff ff       	call   c010027e <cprintf>
c0103717:	83 c4 10             	add    $0x10,%esp

    if (!trap_in_kernel(tf)) {
c010371a:	83 ec 0c             	sub    $0xc,%esp
c010371d:	ff 75 08             	pushl  0x8(%ebp)
c0103720:	e8 49 fe ff ff       	call   c010356e <trap_in_kernel>
c0103725:	83 c4 10             	add    $0x10,%esp
c0103728:	85 c0                	test   %eax,%eax
c010372a:	75 32                	jne    c010375e <print_trapframe+0x1da>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c010372c:	8b 45 08             	mov    0x8(%ebp),%eax
c010372f:	8b 40 44             	mov    0x44(%eax),%eax
c0103732:	83 ec 08             	sub    $0x8,%esp
c0103735:	50                   	push   %eax
c0103736:	68 ba b1 10 c0       	push   $0xc010b1ba
c010373b:	e8 3e cb ff ff       	call   c010027e <cprintf>
c0103740:	83 c4 10             	add    $0x10,%esp
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0103743:	8b 45 08             	mov    0x8(%ebp),%eax
c0103746:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c010374a:	0f b7 c0             	movzwl %ax,%eax
c010374d:	83 ec 08             	sub    $0x8,%esp
c0103750:	50                   	push   %eax
c0103751:	68 c9 b1 10 c0       	push   $0xc010b1c9
c0103756:	e8 23 cb ff ff       	call   c010027e <cprintf>
c010375b:	83 c4 10             	add    $0x10,%esp
    }
}
c010375e:	90                   	nop
c010375f:	c9                   	leave  
c0103760:	c3                   	ret    

c0103761 <print_regs>:

void
print_regs(struct pushregs *regs) {
c0103761:	55                   	push   %ebp
c0103762:	89 e5                	mov    %esp,%ebp
c0103764:	83 ec 08             	sub    $0x8,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0103767:	8b 45 08             	mov    0x8(%ebp),%eax
c010376a:	8b 00                	mov    (%eax),%eax
c010376c:	83 ec 08             	sub    $0x8,%esp
c010376f:	50                   	push   %eax
c0103770:	68 dc b1 10 c0       	push   $0xc010b1dc
c0103775:	e8 04 cb ff ff       	call   c010027e <cprintf>
c010377a:	83 c4 10             	add    $0x10,%esp
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c010377d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103780:	8b 40 04             	mov    0x4(%eax),%eax
c0103783:	83 ec 08             	sub    $0x8,%esp
c0103786:	50                   	push   %eax
c0103787:	68 eb b1 10 c0       	push   $0xc010b1eb
c010378c:	e8 ed ca ff ff       	call   c010027e <cprintf>
c0103791:	83 c4 10             	add    $0x10,%esp
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0103794:	8b 45 08             	mov    0x8(%ebp),%eax
c0103797:	8b 40 08             	mov    0x8(%eax),%eax
c010379a:	83 ec 08             	sub    $0x8,%esp
c010379d:	50                   	push   %eax
c010379e:	68 fa b1 10 c0       	push   $0xc010b1fa
c01037a3:	e8 d6 ca ff ff       	call   c010027e <cprintf>
c01037a8:	83 c4 10             	add    $0x10,%esp
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c01037ab:	8b 45 08             	mov    0x8(%ebp),%eax
c01037ae:	8b 40 0c             	mov    0xc(%eax),%eax
c01037b1:	83 ec 08             	sub    $0x8,%esp
c01037b4:	50                   	push   %eax
c01037b5:	68 09 b2 10 c0       	push   $0xc010b209
c01037ba:	e8 bf ca ff ff       	call   c010027e <cprintf>
c01037bf:	83 c4 10             	add    $0x10,%esp
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c01037c2:	8b 45 08             	mov    0x8(%ebp),%eax
c01037c5:	8b 40 10             	mov    0x10(%eax),%eax
c01037c8:	83 ec 08             	sub    $0x8,%esp
c01037cb:	50                   	push   %eax
c01037cc:	68 18 b2 10 c0       	push   $0xc010b218
c01037d1:	e8 a8 ca ff ff       	call   c010027e <cprintf>
c01037d6:	83 c4 10             	add    $0x10,%esp
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c01037d9:	8b 45 08             	mov    0x8(%ebp),%eax
c01037dc:	8b 40 14             	mov    0x14(%eax),%eax
c01037df:	83 ec 08             	sub    $0x8,%esp
c01037e2:	50                   	push   %eax
c01037e3:	68 27 b2 10 c0       	push   $0xc010b227
c01037e8:	e8 91 ca ff ff       	call   c010027e <cprintf>
c01037ed:	83 c4 10             	add    $0x10,%esp
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c01037f0:	8b 45 08             	mov    0x8(%ebp),%eax
c01037f3:	8b 40 18             	mov    0x18(%eax),%eax
c01037f6:	83 ec 08             	sub    $0x8,%esp
c01037f9:	50                   	push   %eax
c01037fa:	68 36 b2 10 c0       	push   $0xc010b236
c01037ff:	e8 7a ca ff ff       	call   c010027e <cprintf>
c0103804:	83 c4 10             	add    $0x10,%esp
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0103807:	8b 45 08             	mov    0x8(%ebp),%eax
c010380a:	8b 40 1c             	mov    0x1c(%eax),%eax
c010380d:	83 ec 08             	sub    $0x8,%esp
c0103810:	50                   	push   %eax
c0103811:	68 45 b2 10 c0       	push   $0xc010b245
c0103816:	e8 63 ca ff ff       	call   c010027e <cprintf>
c010381b:	83 c4 10             	add    $0x10,%esp
}
c010381e:	90                   	nop
c010381f:	c9                   	leave  
c0103820:	c3                   	ret    

c0103821 <print_pgfault>:

static inline void
print_pgfault(struct trapframe *tf) {
c0103821:	55                   	push   %ebp
c0103822:	89 e5                	mov    %esp,%ebp
c0103824:	53                   	push   %ebx
c0103825:	83 ec 14             	sub    $0x14,%esp
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
c0103828:	8b 45 08             	mov    0x8(%ebp),%eax
c010382b:	8b 40 34             	mov    0x34(%eax),%eax
c010382e:	83 e0 01             	and    $0x1,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0103831:	85 c0                	test   %eax,%eax
c0103833:	74 07                	je     c010383c <print_pgfault+0x1b>
c0103835:	bb 54 b2 10 c0       	mov    $0xc010b254,%ebx
c010383a:	eb 05                	jmp    c0103841 <print_pgfault+0x20>
c010383c:	bb 65 b2 10 c0       	mov    $0xc010b265,%ebx
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
c0103841:	8b 45 08             	mov    0x8(%ebp),%eax
c0103844:	8b 40 34             	mov    0x34(%eax),%eax
c0103847:	83 e0 02             	and    $0x2,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c010384a:	85 c0                	test   %eax,%eax
c010384c:	74 07                	je     c0103855 <print_pgfault+0x34>
c010384e:	b9 57 00 00 00       	mov    $0x57,%ecx
c0103853:	eb 05                	jmp    c010385a <print_pgfault+0x39>
c0103855:	b9 52 00 00 00       	mov    $0x52,%ecx
            (tf->tf_err & 4) ? 'U' : 'K',
c010385a:	8b 45 08             	mov    0x8(%ebp),%eax
c010385d:	8b 40 34             	mov    0x34(%eax),%eax
c0103860:	83 e0 04             	and    $0x4,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0103863:	85 c0                	test   %eax,%eax
c0103865:	74 07                	je     c010386e <print_pgfault+0x4d>
c0103867:	ba 55 00 00 00       	mov    $0x55,%edx
c010386c:	eb 05                	jmp    c0103873 <print_pgfault+0x52>
c010386e:	ba 4b 00 00 00       	mov    $0x4b,%edx
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c0103873:	0f 20 d0             	mov    %cr2,%eax
c0103876:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c0103879:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010387c:	83 ec 0c             	sub    $0xc,%esp
c010387f:	53                   	push   %ebx
c0103880:	51                   	push   %ecx
c0103881:	52                   	push   %edx
c0103882:	50                   	push   %eax
c0103883:	68 74 b2 10 c0       	push   $0xc010b274
c0103888:	e8 f1 c9 ff ff       	call   c010027e <cprintf>
c010388d:	83 c4 20             	add    $0x20,%esp
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
}
c0103890:	90                   	nop
c0103891:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0103894:	c9                   	leave  
c0103895:	c3                   	ret    

c0103896 <pgfault_handler>:

static int
pgfault_handler(struct trapframe *tf) {
c0103896:	55                   	push   %ebp
c0103897:	89 e5                	mov    %esp,%ebp
c0103899:	83 ec 18             	sub    $0x18,%esp
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
c010389c:	83 ec 0c             	sub    $0xc,%esp
c010389f:	ff 75 08             	pushl  0x8(%ebp)
c01038a2:	e8 7a ff ff ff       	call   c0103821 <print_pgfault>
c01038a7:	83 c4 10             	add    $0x10,%esp
    if (check_mm_struct != NULL) {
c01038aa:	a1 f8 aa 12 c0       	mov    0xc012aaf8,%eax
c01038af:	85 c0                	test   %eax,%eax
c01038b1:	74 24                	je     c01038d7 <pgfault_handler+0x41>
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c01038b3:	0f 20 d0             	mov    %cr2,%eax
c01038b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c01038b9:	8b 4d f4             	mov    -0xc(%ebp),%ecx
        return do_pgfault(check_mm_struct, tf->tf_err, rcr2());
c01038bc:	8b 45 08             	mov    0x8(%ebp),%eax
c01038bf:	8b 50 34             	mov    0x34(%eax),%edx
c01038c2:	a1 f8 aa 12 c0       	mov    0xc012aaf8,%eax
c01038c7:	83 ec 04             	sub    $0x4,%esp
c01038ca:	51                   	push   %ecx
c01038cb:	52                   	push   %edx
c01038cc:	50                   	push   %eax
c01038cd:	e8 58 16 00 00       	call   c0104f2a <do_pgfault>
c01038d2:	83 c4 10             	add    $0x10,%esp
c01038d5:	eb 17                	jmp    c01038ee <pgfault_handler+0x58>
    }
    panic("unhandled page fault.\n");
c01038d7:	83 ec 04             	sub    $0x4,%esp
c01038da:	68 97 b2 10 c0       	push   $0xc010b297
c01038df:	68 a5 00 00 00       	push   $0xa5
c01038e4:	68 ae b2 10 c0       	push   $0xc010b2ae
c01038e9:	e8 6e de ff ff       	call   c010175c <__panic>
}
c01038ee:	c9                   	leave  
c01038ef:	c3                   	ret    

c01038f0 <trap_dispatch>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

static void
trap_dispatch(struct trapframe *tf) {
c01038f0:	55                   	push   %ebp
c01038f1:	89 e5                	mov    %esp,%ebp
c01038f3:	83 ec 18             	sub    $0x18,%esp
    char c;

    int ret;

    switch (tf->tf_trapno) {
c01038f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01038f9:	8b 40 30             	mov    0x30(%eax),%eax
c01038fc:	83 f8 24             	cmp    $0x24,%eax
c01038ff:	0f 84 ba 00 00 00    	je     c01039bf <trap_dispatch+0xcf>
c0103905:	83 f8 24             	cmp    $0x24,%eax
c0103908:	77 18                	ja     c0103922 <trap_dispatch+0x32>
c010390a:	83 f8 20             	cmp    $0x20,%eax
c010390d:	74 76                	je     c0103985 <trap_dispatch+0x95>
c010390f:	83 f8 21             	cmp    $0x21,%eax
c0103912:	0f 84 cb 00 00 00    	je     c01039e3 <trap_dispatch+0xf3>
c0103918:	83 f8 0e             	cmp    $0xe,%eax
c010391b:	74 28                	je     c0103945 <trap_dispatch+0x55>
c010391d:	e9 fc 00 00 00       	jmp    c0103a1e <trap_dispatch+0x12e>
c0103922:	83 f8 2e             	cmp    $0x2e,%eax
c0103925:	0f 82 f3 00 00 00    	jb     c0103a1e <trap_dispatch+0x12e>
c010392b:	83 f8 2f             	cmp    $0x2f,%eax
c010392e:	0f 86 20 01 00 00    	jbe    c0103a54 <trap_dispatch+0x164>
c0103934:	83 e8 78             	sub    $0x78,%eax
c0103937:	83 f8 01             	cmp    $0x1,%eax
c010393a:	0f 87 de 00 00 00    	ja     c0103a1e <trap_dispatch+0x12e>
c0103940:	e9 c2 00 00 00       	jmp    c0103a07 <trap_dispatch+0x117>
    case T_PGFLT:  //page fault
        if ((ret = pgfault_handler(tf)) != 0) {
c0103945:	83 ec 0c             	sub    $0xc,%esp
c0103948:	ff 75 08             	pushl  0x8(%ebp)
c010394b:	e8 46 ff ff ff       	call   c0103896 <pgfault_handler>
c0103950:	83 c4 10             	add    $0x10,%esp
c0103953:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103956:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010395a:	0f 84 f7 00 00 00    	je     c0103a57 <trap_dispatch+0x167>
            print_trapframe(tf);
c0103960:	83 ec 0c             	sub    $0xc,%esp
c0103963:	ff 75 08             	pushl  0x8(%ebp)
c0103966:	e8 19 fc ff ff       	call   c0103584 <print_trapframe>
c010396b:	83 c4 10             	add    $0x10,%esp
            panic("handle pgfault failed. %e\n", ret);
c010396e:	ff 75 f4             	pushl  -0xc(%ebp)
c0103971:	68 bf b2 10 c0       	push   $0xc010b2bf
c0103976:	68 b5 00 00 00       	push   $0xb5
c010397b:	68 ae b2 10 c0       	push   $0xc010b2ae
c0103980:	e8 d7 dd ff ff       	call   c010175c <__panic>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
c0103985:	a1 f4 aa 12 c0       	mov    0xc012aaf4,%eax
c010398a:	83 c0 01             	add    $0x1,%eax
c010398d:	a3 f4 aa 12 c0       	mov    %eax,0xc012aaf4
        if (ticks % TICK_NUM == 0) {
c0103992:	8b 0d f4 aa 12 c0    	mov    0xc012aaf4,%ecx
c0103998:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c010399d:	89 c8                	mov    %ecx,%eax
c010399f:	f7 e2                	mul    %edx
c01039a1:	89 d0                	mov    %edx,%eax
c01039a3:	c1 e8 05             	shr    $0x5,%eax
c01039a6:	6b c0 64             	imul   $0x64,%eax,%eax
c01039a9:	29 c1                	sub    %eax,%ecx
c01039ab:	89 c8                	mov    %ecx,%eax
c01039ad:	85 c0                	test   %eax,%eax
c01039af:	0f 85 a5 00 00 00    	jne    c0103a5a <trap_dispatch+0x16a>
            print_ticks();
c01039b5:	e8 75 fa ff ff       	call   c010342f <print_ticks>
        }
        break;
c01039ba:	e9 9b 00 00 00       	jmp    c0103a5a <trap_dispatch+0x16a>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c01039bf:	e8 28 f8 ff ff       	call   c01031ec <cons_getc>
c01039c4:	88 45 f3             	mov    %al,-0xd(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c01039c7:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c01039cb:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c01039cf:	83 ec 04             	sub    $0x4,%esp
c01039d2:	52                   	push   %edx
c01039d3:	50                   	push   %eax
c01039d4:	68 da b2 10 c0       	push   $0xc010b2da
c01039d9:	e8 a0 c8 ff ff       	call   c010027e <cprintf>
c01039de:	83 c4 10             	add    $0x10,%esp
        break;
c01039e1:	eb 78                	jmp    c0103a5b <trap_dispatch+0x16b>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c01039e3:	e8 04 f8 ff ff       	call   c01031ec <cons_getc>
c01039e8:	88 45 f3             	mov    %al,-0xd(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c01039eb:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c01039ef:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c01039f3:	83 ec 04             	sub    $0x4,%esp
c01039f6:	52                   	push   %edx
c01039f7:	50                   	push   %eax
c01039f8:	68 ec b2 10 c0       	push   $0xc010b2ec
c01039fd:	e8 7c c8 ff ff       	call   c010027e <cprintf>
c0103a02:	83 c4 10             	add    $0x10,%esp
        break;
c0103a05:	eb 54                	jmp    c0103a5b <trap_dispatch+0x16b>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c0103a07:	83 ec 04             	sub    $0x4,%esp
c0103a0a:	68 fb b2 10 c0       	push   $0xc010b2fb
c0103a0f:	68 d3 00 00 00       	push   $0xd3
c0103a14:	68 ae b2 10 c0       	push   $0xc010b2ae
c0103a19:	e8 3e dd ff ff       	call   c010175c <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0103a1e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a21:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0103a25:	0f b7 c0             	movzwl %ax,%eax
c0103a28:	83 e0 03             	and    $0x3,%eax
c0103a2b:	85 c0                	test   %eax,%eax
c0103a2d:	75 2c                	jne    c0103a5b <trap_dispatch+0x16b>
            print_trapframe(tf);
c0103a2f:	83 ec 0c             	sub    $0xc,%esp
c0103a32:	ff 75 08             	pushl  0x8(%ebp)
c0103a35:	e8 4a fb ff ff       	call   c0103584 <print_trapframe>
c0103a3a:	83 c4 10             	add    $0x10,%esp
            panic("unexpected trap in kernel.\n");
c0103a3d:	83 ec 04             	sub    $0x4,%esp
c0103a40:	68 0b b3 10 c0       	push   $0xc010b30b
c0103a45:	68 dd 00 00 00       	push   $0xdd
c0103a4a:	68 ae b2 10 c0       	push   $0xc010b2ae
c0103a4f:	e8 08 dd ff ff       	call   c010175c <__panic>
        panic("T_SWITCH_** ??\n");
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
c0103a54:	90                   	nop
c0103a55:	eb 04                	jmp    c0103a5b <trap_dispatch+0x16b>
    case T_PGFLT:  //page fault
        if ((ret = pgfault_handler(tf)) != 0) {
            print_trapframe(tf);
            panic("handle pgfault failed. %e\n", ret);
        }
        break;
c0103a57:	90                   	nop
c0103a58:	eb 01                	jmp    c0103a5b <trap_dispatch+0x16b>
         */
        ticks ++;
        if (ticks % TICK_NUM == 0) {
            print_ticks();
        }
        break;
c0103a5a:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
c0103a5b:	90                   	nop
c0103a5c:	c9                   	leave  
c0103a5d:	c3                   	ret    

c0103a5e <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0103a5e:	55                   	push   %ebp
c0103a5f:	89 e5                	mov    %esp,%ebp
c0103a61:	83 ec 08             	sub    $0x8,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c0103a64:	83 ec 0c             	sub    $0xc,%esp
c0103a67:	ff 75 08             	pushl  0x8(%ebp)
c0103a6a:	e8 81 fe ff ff       	call   c01038f0 <trap_dispatch>
c0103a6f:	83 c4 10             	add    $0x10,%esp
}
c0103a72:	90                   	nop
c0103a73:	c9                   	leave  
c0103a74:	c3                   	ret    

c0103a75 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0103a75:	6a 00                	push   $0x0
  pushl $0
c0103a77:	6a 00                	push   $0x0
  jmp __alltraps
c0103a79:	e9 67 0a 00 00       	jmp    c01044e5 <__alltraps>

c0103a7e <vector1>:
.globl vector1
vector1:
  pushl $0
c0103a7e:	6a 00                	push   $0x0
  pushl $1
c0103a80:	6a 01                	push   $0x1
  jmp __alltraps
c0103a82:	e9 5e 0a 00 00       	jmp    c01044e5 <__alltraps>

c0103a87 <vector2>:
.globl vector2
vector2:
  pushl $0
c0103a87:	6a 00                	push   $0x0
  pushl $2
c0103a89:	6a 02                	push   $0x2
  jmp __alltraps
c0103a8b:	e9 55 0a 00 00       	jmp    c01044e5 <__alltraps>

c0103a90 <vector3>:
.globl vector3
vector3:
  pushl $0
c0103a90:	6a 00                	push   $0x0
  pushl $3
c0103a92:	6a 03                	push   $0x3
  jmp __alltraps
c0103a94:	e9 4c 0a 00 00       	jmp    c01044e5 <__alltraps>

c0103a99 <vector4>:
.globl vector4
vector4:
  pushl $0
c0103a99:	6a 00                	push   $0x0
  pushl $4
c0103a9b:	6a 04                	push   $0x4
  jmp __alltraps
c0103a9d:	e9 43 0a 00 00       	jmp    c01044e5 <__alltraps>

c0103aa2 <vector5>:
.globl vector5
vector5:
  pushl $0
c0103aa2:	6a 00                	push   $0x0
  pushl $5
c0103aa4:	6a 05                	push   $0x5
  jmp __alltraps
c0103aa6:	e9 3a 0a 00 00       	jmp    c01044e5 <__alltraps>

c0103aab <vector6>:
.globl vector6
vector6:
  pushl $0
c0103aab:	6a 00                	push   $0x0
  pushl $6
c0103aad:	6a 06                	push   $0x6
  jmp __alltraps
c0103aaf:	e9 31 0a 00 00       	jmp    c01044e5 <__alltraps>

c0103ab4 <vector7>:
.globl vector7
vector7:
  pushl $0
c0103ab4:	6a 00                	push   $0x0
  pushl $7
c0103ab6:	6a 07                	push   $0x7
  jmp __alltraps
c0103ab8:	e9 28 0a 00 00       	jmp    c01044e5 <__alltraps>

c0103abd <vector8>:
.globl vector8
vector8:
  pushl $8
c0103abd:	6a 08                	push   $0x8
  jmp __alltraps
c0103abf:	e9 21 0a 00 00       	jmp    c01044e5 <__alltraps>

c0103ac4 <vector9>:
.globl vector9
vector9:
  pushl $9
c0103ac4:	6a 09                	push   $0x9
  jmp __alltraps
c0103ac6:	e9 1a 0a 00 00       	jmp    c01044e5 <__alltraps>

c0103acb <vector10>:
.globl vector10
vector10:
  pushl $10
c0103acb:	6a 0a                	push   $0xa
  jmp __alltraps
c0103acd:	e9 13 0a 00 00       	jmp    c01044e5 <__alltraps>

c0103ad2 <vector11>:
.globl vector11
vector11:
  pushl $11
c0103ad2:	6a 0b                	push   $0xb
  jmp __alltraps
c0103ad4:	e9 0c 0a 00 00       	jmp    c01044e5 <__alltraps>

c0103ad9 <vector12>:
.globl vector12
vector12:
  pushl $12
c0103ad9:	6a 0c                	push   $0xc
  jmp __alltraps
c0103adb:	e9 05 0a 00 00       	jmp    c01044e5 <__alltraps>

c0103ae0 <vector13>:
.globl vector13
vector13:
  pushl $13
c0103ae0:	6a 0d                	push   $0xd
  jmp __alltraps
c0103ae2:	e9 fe 09 00 00       	jmp    c01044e5 <__alltraps>

c0103ae7 <vector14>:
.globl vector14
vector14:
  pushl $14
c0103ae7:	6a 0e                	push   $0xe
  jmp __alltraps
c0103ae9:	e9 f7 09 00 00       	jmp    c01044e5 <__alltraps>

c0103aee <vector15>:
.globl vector15
vector15:
  pushl $0
c0103aee:	6a 00                	push   $0x0
  pushl $15
c0103af0:	6a 0f                	push   $0xf
  jmp __alltraps
c0103af2:	e9 ee 09 00 00       	jmp    c01044e5 <__alltraps>

c0103af7 <vector16>:
.globl vector16
vector16:
  pushl $0
c0103af7:	6a 00                	push   $0x0
  pushl $16
c0103af9:	6a 10                	push   $0x10
  jmp __alltraps
c0103afb:	e9 e5 09 00 00       	jmp    c01044e5 <__alltraps>

c0103b00 <vector17>:
.globl vector17
vector17:
  pushl $17
c0103b00:	6a 11                	push   $0x11
  jmp __alltraps
c0103b02:	e9 de 09 00 00       	jmp    c01044e5 <__alltraps>

c0103b07 <vector18>:
.globl vector18
vector18:
  pushl $0
c0103b07:	6a 00                	push   $0x0
  pushl $18
c0103b09:	6a 12                	push   $0x12
  jmp __alltraps
c0103b0b:	e9 d5 09 00 00       	jmp    c01044e5 <__alltraps>

c0103b10 <vector19>:
.globl vector19
vector19:
  pushl $0
c0103b10:	6a 00                	push   $0x0
  pushl $19
c0103b12:	6a 13                	push   $0x13
  jmp __alltraps
c0103b14:	e9 cc 09 00 00       	jmp    c01044e5 <__alltraps>

c0103b19 <vector20>:
.globl vector20
vector20:
  pushl $0
c0103b19:	6a 00                	push   $0x0
  pushl $20
c0103b1b:	6a 14                	push   $0x14
  jmp __alltraps
c0103b1d:	e9 c3 09 00 00       	jmp    c01044e5 <__alltraps>

c0103b22 <vector21>:
.globl vector21
vector21:
  pushl $0
c0103b22:	6a 00                	push   $0x0
  pushl $21
c0103b24:	6a 15                	push   $0x15
  jmp __alltraps
c0103b26:	e9 ba 09 00 00       	jmp    c01044e5 <__alltraps>

c0103b2b <vector22>:
.globl vector22
vector22:
  pushl $0
c0103b2b:	6a 00                	push   $0x0
  pushl $22
c0103b2d:	6a 16                	push   $0x16
  jmp __alltraps
c0103b2f:	e9 b1 09 00 00       	jmp    c01044e5 <__alltraps>

c0103b34 <vector23>:
.globl vector23
vector23:
  pushl $0
c0103b34:	6a 00                	push   $0x0
  pushl $23
c0103b36:	6a 17                	push   $0x17
  jmp __alltraps
c0103b38:	e9 a8 09 00 00       	jmp    c01044e5 <__alltraps>

c0103b3d <vector24>:
.globl vector24
vector24:
  pushl $0
c0103b3d:	6a 00                	push   $0x0
  pushl $24
c0103b3f:	6a 18                	push   $0x18
  jmp __alltraps
c0103b41:	e9 9f 09 00 00       	jmp    c01044e5 <__alltraps>

c0103b46 <vector25>:
.globl vector25
vector25:
  pushl $0
c0103b46:	6a 00                	push   $0x0
  pushl $25
c0103b48:	6a 19                	push   $0x19
  jmp __alltraps
c0103b4a:	e9 96 09 00 00       	jmp    c01044e5 <__alltraps>

c0103b4f <vector26>:
.globl vector26
vector26:
  pushl $0
c0103b4f:	6a 00                	push   $0x0
  pushl $26
c0103b51:	6a 1a                	push   $0x1a
  jmp __alltraps
c0103b53:	e9 8d 09 00 00       	jmp    c01044e5 <__alltraps>

c0103b58 <vector27>:
.globl vector27
vector27:
  pushl $0
c0103b58:	6a 00                	push   $0x0
  pushl $27
c0103b5a:	6a 1b                	push   $0x1b
  jmp __alltraps
c0103b5c:	e9 84 09 00 00       	jmp    c01044e5 <__alltraps>

c0103b61 <vector28>:
.globl vector28
vector28:
  pushl $0
c0103b61:	6a 00                	push   $0x0
  pushl $28
c0103b63:	6a 1c                	push   $0x1c
  jmp __alltraps
c0103b65:	e9 7b 09 00 00       	jmp    c01044e5 <__alltraps>

c0103b6a <vector29>:
.globl vector29
vector29:
  pushl $0
c0103b6a:	6a 00                	push   $0x0
  pushl $29
c0103b6c:	6a 1d                	push   $0x1d
  jmp __alltraps
c0103b6e:	e9 72 09 00 00       	jmp    c01044e5 <__alltraps>

c0103b73 <vector30>:
.globl vector30
vector30:
  pushl $0
c0103b73:	6a 00                	push   $0x0
  pushl $30
c0103b75:	6a 1e                	push   $0x1e
  jmp __alltraps
c0103b77:	e9 69 09 00 00       	jmp    c01044e5 <__alltraps>

c0103b7c <vector31>:
.globl vector31
vector31:
  pushl $0
c0103b7c:	6a 00                	push   $0x0
  pushl $31
c0103b7e:	6a 1f                	push   $0x1f
  jmp __alltraps
c0103b80:	e9 60 09 00 00       	jmp    c01044e5 <__alltraps>

c0103b85 <vector32>:
.globl vector32
vector32:
  pushl $0
c0103b85:	6a 00                	push   $0x0
  pushl $32
c0103b87:	6a 20                	push   $0x20
  jmp __alltraps
c0103b89:	e9 57 09 00 00       	jmp    c01044e5 <__alltraps>

c0103b8e <vector33>:
.globl vector33
vector33:
  pushl $0
c0103b8e:	6a 00                	push   $0x0
  pushl $33
c0103b90:	6a 21                	push   $0x21
  jmp __alltraps
c0103b92:	e9 4e 09 00 00       	jmp    c01044e5 <__alltraps>

c0103b97 <vector34>:
.globl vector34
vector34:
  pushl $0
c0103b97:	6a 00                	push   $0x0
  pushl $34
c0103b99:	6a 22                	push   $0x22
  jmp __alltraps
c0103b9b:	e9 45 09 00 00       	jmp    c01044e5 <__alltraps>

c0103ba0 <vector35>:
.globl vector35
vector35:
  pushl $0
c0103ba0:	6a 00                	push   $0x0
  pushl $35
c0103ba2:	6a 23                	push   $0x23
  jmp __alltraps
c0103ba4:	e9 3c 09 00 00       	jmp    c01044e5 <__alltraps>

c0103ba9 <vector36>:
.globl vector36
vector36:
  pushl $0
c0103ba9:	6a 00                	push   $0x0
  pushl $36
c0103bab:	6a 24                	push   $0x24
  jmp __alltraps
c0103bad:	e9 33 09 00 00       	jmp    c01044e5 <__alltraps>

c0103bb2 <vector37>:
.globl vector37
vector37:
  pushl $0
c0103bb2:	6a 00                	push   $0x0
  pushl $37
c0103bb4:	6a 25                	push   $0x25
  jmp __alltraps
c0103bb6:	e9 2a 09 00 00       	jmp    c01044e5 <__alltraps>

c0103bbb <vector38>:
.globl vector38
vector38:
  pushl $0
c0103bbb:	6a 00                	push   $0x0
  pushl $38
c0103bbd:	6a 26                	push   $0x26
  jmp __alltraps
c0103bbf:	e9 21 09 00 00       	jmp    c01044e5 <__alltraps>

c0103bc4 <vector39>:
.globl vector39
vector39:
  pushl $0
c0103bc4:	6a 00                	push   $0x0
  pushl $39
c0103bc6:	6a 27                	push   $0x27
  jmp __alltraps
c0103bc8:	e9 18 09 00 00       	jmp    c01044e5 <__alltraps>

c0103bcd <vector40>:
.globl vector40
vector40:
  pushl $0
c0103bcd:	6a 00                	push   $0x0
  pushl $40
c0103bcf:	6a 28                	push   $0x28
  jmp __alltraps
c0103bd1:	e9 0f 09 00 00       	jmp    c01044e5 <__alltraps>

c0103bd6 <vector41>:
.globl vector41
vector41:
  pushl $0
c0103bd6:	6a 00                	push   $0x0
  pushl $41
c0103bd8:	6a 29                	push   $0x29
  jmp __alltraps
c0103bda:	e9 06 09 00 00       	jmp    c01044e5 <__alltraps>

c0103bdf <vector42>:
.globl vector42
vector42:
  pushl $0
c0103bdf:	6a 00                	push   $0x0
  pushl $42
c0103be1:	6a 2a                	push   $0x2a
  jmp __alltraps
c0103be3:	e9 fd 08 00 00       	jmp    c01044e5 <__alltraps>

c0103be8 <vector43>:
.globl vector43
vector43:
  pushl $0
c0103be8:	6a 00                	push   $0x0
  pushl $43
c0103bea:	6a 2b                	push   $0x2b
  jmp __alltraps
c0103bec:	e9 f4 08 00 00       	jmp    c01044e5 <__alltraps>

c0103bf1 <vector44>:
.globl vector44
vector44:
  pushl $0
c0103bf1:	6a 00                	push   $0x0
  pushl $44
c0103bf3:	6a 2c                	push   $0x2c
  jmp __alltraps
c0103bf5:	e9 eb 08 00 00       	jmp    c01044e5 <__alltraps>

c0103bfa <vector45>:
.globl vector45
vector45:
  pushl $0
c0103bfa:	6a 00                	push   $0x0
  pushl $45
c0103bfc:	6a 2d                	push   $0x2d
  jmp __alltraps
c0103bfe:	e9 e2 08 00 00       	jmp    c01044e5 <__alltraps>

c0103c03 <vector46>:
.globl vector46
vector46:
  pushl $0
c0103c03:	6a 00                	push   $0x0
  pushl $46
c0103c05:	6a 2e                	push   $0x2e
  jmp __alltraps
c0103c07:	e9 d9 08 00 00       	jmp    c01044e5 <__alltraps>

c0103c0c <vector47>:
.globl vector47
vector47:
  pushl $0
c0103c0c:	6a 00                	push   $0x0
  pushl $47
c0103c0e:	6a 2f                	push   $0x2f
  jmp __alltraps
c0103c10:	e9 d0 08 00 00       	jmp    c01044e5 <__alltraps>

c0103c15 <vector48>:
.globl vector48
vector48:
  pushl $0
c0103c15:	6a 00                	push   $0x0
  pushl $48
c0103c17:	6a 30                	push   $0x30
  jmp __alltraps
c0103c19:	e9 c7 08 00 00       	jmp    c01044e5 <__alltraps>

c0103c1e <vector49>:
.globl vector49
vector49:
  pushl $0
c0103c1e:	6a 00                	push   $0x0
  pushl $49
c0103c20:	6a 31                	push   $0x31
  jmp __alltraps
c0103c22:	e9 be 08 00 00       	jmp    c01044e5 <__alltraps>

c0103c27 <vector50>:
.globl vector50
vector50:
  pushl $0
c0103c27:	6a 00                	push   $0x0
  pushl $50
c0103c29:	6a 32                	push   $0x32
  jmp __alltraps
c0103c2b:	e9 b5 08 00 00       	jmp    c01044e5 <__alltraps>

c0103c30 <vector51>:
.globl vector51
vector51:
  pushl $0
c0103c30:	6a 00                	push   $0x0
  pushl $51
c0103c32:	6a 33                	push   $0x33
  jmp __alltraps
c0103c34:	e9 ac 08 00 00       	jmp    c01044e5 <__alltraps>

c0103c39 <vector52>:
.globl vector52
vector52:
  pushl $0
c0103c39:	6a 00                	push   $0x0
  pushl $52
c0103c3b:	6a 34                	push   $0x34
  jmp __alltraps
c0103c3d:	e9 a3 08 00 00       	jmp    c01044e5 <__alltraps>

c0103c42 <vector53>:
.globl vector53
vector53:
  pushl $0
c0103c42:	6a 00                	push   $0x0
  pushl $53
c0103c44:	6a 35                	push   $0x35
  jmp __alltraps
c0103c46:	e9 9a 08 00 00       	jmp    c01044e5 <__alltraps>

c0103c4b <vector54>:
.globl vector54
vector54:
  pushl $0
c0103c4b:	6a 00                	push   $0x0
  pushl $54
c0103c4d:	6a 36                	push   $0x36
  jmp __alltraps
c0103c4f:	e9 91 08 00 00       	jmp    c01044e5 <__alltraps>

c0103c54 <vector55>:
.globl vector55
vector55:
  pushl $0
c0103c54:	6a 00                	push   $0x0
  pushl $55
c0103c56:	6a 37                	push   $0x37
  jmp __alltraps
c0103c58:	e9 88 08 00 00       	jmp    c01044e5 <__alltraps>

c0103c5d <vector56>:
.globl vector56
vector56:
  pushl $0
c0103c5d:	6a 00                	push   $0x0
  pushl $56
c0103c5f:	6a 38                	push   $0x38
  jmp __alltraps
c0103c61:	e9 7f 08 00 00       	jmp    c01044e5 <__alltraps>

c0103c66 <vector57>:
.globl vector57
vector57:
  pushl $0
c0103c66:	6a 00                	push   $0x0
  pushl $57
c0103c68:	6a 39                	push   $0x39
  jmp __alltraps
c0103c6a:	e9 76 08 00 00       	jmp    c01044e5 <__alltraps>

c0103c6f <vector58>:
.globl vector58
vector58:
  pushl $0
c0103c6f:	6a 00                	push   $0x0
  pushl $58
c0103c71:	6a 3a                	push   $0x3a
  jmp __alltraps
c0103c73:	e9 6d 08 00 00       	jmp    c01044e5 <__alltraps>

c0103c78 <vector59>:
.globl vector59
vector59:
  pushl $0
c0103c78:	6a 00                	push   $0x0
  pushl $59
c0103c7a:	6a 3b                	push   $0x3b
  jmp __alltraps
c0103c7c:	e9 64 08 00 00       	jmp    c01044e5 <__alltraps>

c0103c81 <vector60>:
.globl vector60
vector60:
  pushl $0
c0103c81:	6a 00                	push   $0x0
  pushl $60
c0103c83:	6a 3c                	push   $0x3c
  jmp __alltraps
c0103c85:	e9 5b 08 00 00       	jmp    c01044e5 <__alltraps>

c0103c8a <vector61>:
.globl vector61
vector61:
  pushl $0
c0103c8a:	6a 00                	push   $0x0
  pushl $61
c0103c8c:	6a 3d                	push   $0x3d
  jmp __alltraps
c0103c8e:	e9 52 08 00 00       	jmp    c01044e5 <__alltraps>

c0103c93 <vector62>:
.globl vector62
vector62:
  pushl $0
c0103c93:	6a 00                	push   $0x0
  pushl $62
c0103c95:	6a 3e                	push   $0x3e
  jmp __alltraps
c0103c97:	e9 49 08 00 00       	jmp    c01044e5 <__alltraps>

c0103c9c <vector63>:
.globl vector63
vector63:
  pushl $0
c0103c9c:	6a 00                	push   $0x0
  pushl $63
c0103c9e:	6a 3f                	push   $0x3f
  jmp __alltraps
c0103ca0:	e9 40 08 00 00       	jmp    c01044e5 <__alltraps>

c0103ca5 <vector64>:
.globl vector64
vector64:
  pushl $0
c0103ca5:	6a 00                	push   $0x0
  pushl $64
c0103ca7:	6a 40                	push   $0x40
  jmp __alltraps
c0103ca9:	e9 37 08 00 00       	jmp    c01044e5 <__alltraps>

c0103cae <vector65>:
.globl vector65
vector65:
  pushl $0
c0103cae:	6a 00                	push   $0x0
  pushl $65
c0103cb0:	6a 41                	push   $0x41
  jmp __alltraps
c0103cb2:	e9 2e 08 00 00       	jmp    c01044e5 <__alltraps>

c0103cb7 <vector66>:
.globl vector66
vector66:
  pushl $0
c0103cb7:	6a 00                	push   $0x0
  pushl $66
c0103cb9:	6a 42                	push   $0x42
  jmp __alltraps
c0103cbb:	e9 25 08 00 00       	jmp    c01044e5 <__alltraps>

c0103cc0 <vector67>:
.globl vector67
vector67:
  pushl $0
c0103cc0:	6a 00                	push   $0x0
  pushl $67
c0103cc2:	6a 43                	push   $0x43
  jmp __alltraps
c0103cc4:	e9 1c 08 00 00       	jmp    c01044e5 <__alltraps>

c0103cc9 <vector68>:
.globl vector68
vector68:
  pushl $0
c0103cc9:	6a 00                	push   $0x0
  pushl $68
c0103ccb:	6a 44                	push   $0x44
  jmp __alltraps
c0103ccd:	e9 13 08 00 00       	jmp    c01044e5 <__alltraps>

c0103cd2 <vector69>:
.globl vector69
vector69:
  pushl $0
c0103cd2:	6a 00                	push   $0x0
  pushl $69
c0103cd4:	6a 45                	push   $0x45
  jmp __alltraps
c0103cd6:	e9 0a 08 00 00       	jmp    c01044e5 <__alltraps>

c0103cdb <vector70>:
.globl vector70
vector70:
  pushl $0
c0103cdb:	6a 00                	push   $0x0
  pushl $70
c0103cdd:	6a 46                	push   $0x46
  jmp __alltraps
c0103cdf:	e9 01 08 00 00       	jmp    c01044e5 <__alltraps>

c0103ce4 <vector71>:
.globl vector71
vector71:
  pushl $0
c0103ce4:	6a 00                	push   $0x0
  pushl $71
c0103ce6:	6a 47                	push   $0x47
  jmp __alltraps
c0103ce8:	e9 f8 07 00 00       	jmp    c01044e5 <__alltraps>

c0103ced <vector72>:
.globl vector72
vector72:
  pushl $0
c0103ced:	6a 00                	push   $0x0
  pushl $72
c0103cef:	6a 48                	push   $0x48
  jmp __alltraps
c0103cf1:	e9 ef 07 00 00       	jmp    c01044e5 <__alltraps>

c0103cf6 <vector73>:
.globl vector73
vector73:
  pushl $0
c0103cf6:	6a 00                	push   $0x0
  pushl $73
c0103cf8:	6a 49                	push   $0x49
  jmp __alltraps
c0103cfa:	e9 e6 07 00 00       	jmp    c01044e5 <__alltraps>

c0103cff <vector74>:
.globl vector74
vector74:
  pushl $0
c0103cff:	6a 00                	push   $0x0
  pushl $74
c0103d01:	6a 4a                	push   $0x4a
  jmp __alltraps
c0103d03:	e9 dd 07 00 00       	jmp    c01044e5 <__alltraps>

c0103d08 <vector75>:
.globl vector75
vector75:
  pushl $0
c0103d08:	6a 00                	push   $0x0
  pushl $75
c0103d0a:	6a 4b                	push   $0x4b
  jmp __alltraps
c0103d0c:	e9 d4 07 00 00       	jmp    c01044e5 <__alltraps>

c0103d11 <vector76>:
.globl vector76
vector76:
  pushl $0
c0103d11:	6a 00                	push   $0x0
  pushl $76
c0103d13:	6a 4c                	push   $0x4c
  jmp __alltraps
c0103d15:	e9 cb 07 00 00       	jmp    c01044e5 <__alltraps>

c0103d1a <vector77>:
.globl vector77
vector77:
  pushl $0
c0103d1a:	6a 00                	push   $0x0
  pushl $77
c0103d1c:	6a 4d                	push   $0x4d
  jmp __alltraps
c0103d1e:	e9 c2 07 00 00       	jmp    c01044e5 <__alltraps>

c0103d23 <vector78>:
.globl vector78
vector78:
  pushl $0
c0103d23:	6a 00                	push   $0x0
  pushl $78
c0103d25:	6a 4e                	push   $0x4e
  jmp __alltraps
c0103d27:	e9 b9 07 00 00       	jmp    c01044e5 <__alltraps>

c0103d2c <vector79>:
.globl vector79
vector79:
  pushl $0
c0103d2c:	6a 00                	push   $0x0
  pushl $79
c0103d2e:	6a 4f                	push   $0x4f
  jmp __alltraps
c0103d30:	e9 b0 07 00 00       	jmp    c01044e5 <__alltraps>

c0103d35 <vector80>:
.globl vector80
vector80:
  pushl $0
c0103d35:	6a 00                	push   $0x0
  pushl $80
c0103d37:	6a 50                	push   $0x50
  jmp __alltraps
c0103d39:	e9 a7 07 00 00       	jmp    c01044e5 <__alltraps>

c0103d3e <vector81>:
.globl vector81
vector81:
  pushl $0
c0103d3e:	6a 00                	push   $0x0
  pushl $81
c0103d40:	6a 51                	push   $0x51
  jmp __alltraps
c0103d42:	e9 9e 07 00 00       	jmp    c01044e5 <__alltraps>

c0103d47 <vector82>:
.globl vector82
vector82:
  pushl $0
c0103d47:	6a 00                	push   $0x0
  pushl $82
c0103d49:	6a 52                	push   $0x52
  jmp __alltraps
c0103d4b:	e9 95 07 00 00       	jmp    c01044e5 <__alltraps>

c0103d50 <vector83>:
.globl vector83
vector83:
  pushl $0
c0103d50:	6a 00                	push   $0x0
  pushl $83
c0103d52:	6a 53                	push   $0x53
  jmp __alltraps
c0103d54:	e9 8c 07 00 00       	jmp    c01044e5 <__alltraps>

c0103d59 <vector84>:
.globl vector84
vector84:
  pushl $0
c0103d59:	6a 00                	push   $0x0
  pushl $84
c0103d5b:	6a 54                	push   $0x54
  jmp __alltraps
c0103d5d:	e9 83 07 00 00       	jmp    c01044e5 <__alltraps>

c0103d62 <vector85>:
.globl vector85
vector85:
  pushl $0
c0103d62:	6a 00                	push   $0x0
  pushl $85
c0103d64:	6a 55                	push   $0x55
  jmp __alltraps
c0103d66:	e9 7a 07 00 00       	jmp    c01044e5 <__alltraps>

c0103d6b <vector86>:
.globl vector86
vector86:
  pushl $0
c0103d6b:	6a 00                	push   $0x0
  pushl $86
c0103d6d:	6a 56                	push   $0x56
  jmp __alltraps
c0103d6f:	e9 71 07 00 00       	jmp    c01044e5 <__alltraps>

c0103d74 <vector87>:
.globl vector87
vector87:
  pushl $0
c0103d74:	6a 00                	push   $0x0
  pushl $87
c0103d76:	6a 57                	push   $0x57
  jmp __alltraps
c0103d78:	e9 68 07 00 00       	jmp    c01044e5 <__alltraps>

c0103d7d <vector88>:
.globl vector88
vector88:
  pushl $0
c0103d7d:	6a 00                	push   $0x0
  pushl $88
c0103d7f:	6a 58                	push   $0x58
  jmp __alltraps
c0103d81:	e9 5f 07 00 00       	jmp    c01044e5 <__alltraps>

c0103d86 <vector89>:
.globl vector89
vector89:
  pushl $0
c0103d86:	6a 00                	push   $0x0
  pushl $89
c0103d88:	6a 59                	push   $0x59
  jmp __alltraps
c0103d8a:	e9 56 07 00 00       	jmp    c01044e5 <__alltraps>

c0103d8f <vector90>:
.globl vector90
vector90:
  pushl $0
c0103d8f:	6a 00                	push   $0x0
  pushl $90
c0103d91:	6a 5a                	push   $0x5a
  jmp __alltraps
c0103d93:	e9 4d 07 00 00       	jmp    c01044e5 <__alltraps>

c0103d98 <vector91>:
.globl vector91
vector91:
  pushl $0
c0103d98:	6a 00                	push   $0x0
  pushl $91
c0103d9a:	6a 5b                	push   $0x5b
  jmp __alltraps
c0103d9c:	e9 44 07 00 00       	jmp    c01044e5 <__alltraps>

c0103da1 <vector92>:
.globl vector92
vector92:
  pushl $0
c0103da1:	6a 00                	push   $0x0
  pushl $92
c0103da3:	6a 5c                	push   $0x5c
  jmp __alltraps
c0103da5:	e9 3b 07 00 00       	jmp    c01044e5 <__alltraps>

c0103daa <vector93>:
.globl vector93
vector93:
  pushl $0
c0103daa:	6a 00                	push   $0x0
  pushl $93
c0103dac:	6a 5d                	push   $0x5d
  jmp __alltraps
c0103dae:	e9 32 07 00 00       	jmp    c01044e5 <__alltraps>

c0103db3 <vector94>:
.globl vector94
vector94:
  pushl $0
c0103db3:	6a 00                	push   $0x0
  pushl $94
c0103db5:	6a 5e                	push   $0x5e
  jmp __alltraps
c0103db7:	e9 29 07 00 00       	jmp    c01044e5 <__alltraps>

c0103dbc <vector95>:
.globl vector95
vector95:
  pushl $0
c0103dbc:	6a 00                	push   $0x0
  pushl $95
c0103dbe:	6a 5f                	push   $0x5f
  jmp __alltraps
c0103dc0:	e9 20 07 00 00       	jmp    c01044e5 <__alltraps>

c0103dc5 <vector96>:
.globl vector96
vector96:
  pushl $0
c0103dc5:	6a 00                	push   $0x0
  pushl $96
c0103dc7:	6a 60                	push   $0x60
  jmp __alltraps
c0103dc9:	e9 17 07 00 00       	jmp    c01044e5 <__alltraps>

c0103dce <vector97>:
.globl vector97
vector97:
  pushl $0
c0103dce:	6a 00                	push   $0x0
  pushl $97
c0103dd0:	6a 61                	push   $0x61
  jmp __alltraps
c0103dd2:	e9 0e 07 00 00       	jmp    c01044e5 <__alltraps>

c0103dd7 <vector98>:
.globl vector98
vector98:
  pushl $0
c0103dd7:	6a 00                	push   $0x0
  pushl $98
c0103dd9:	6a 62                	push   $0x62
  jmp __alltraps
c0103ddb:	e9 05 07 00 00       	jmp    c01044e5 <__alltraps>

c0103de0 <vector99>:
.globl vector99
vector99:
  pushl $0
c0103de0:	6a 00                	push   $0x0
  pushl $99
c0103de2:	6a 63                	push   $0x63
  jmp __alltraps
c0103de4:	e9 fc 06 00 00       	jmp    c01044e5 <__alltraps>

c0103de9 <vector100>:
.globl vector100
vector100:
  pushl $0
c0103de9:	6a 00                	push   $0x0
  pushl $100
c0103deb:	6a 64                	push   $0x64
  jmp __alltraps
c0103ded:	e9 f3 06 00 00       	jmp    c01044e5 <__alltraps>

c0103df2 <vector101>:
.globl vector101
vector101:
  pushl $0
c0103df2:	6a 00                	push   $0x0
  pushl $101
c0103df4:	6a 65                	push   $0x65
  jmp __alltraps
c0103df6:	e9 ea 06 00 00       	jmp    c01044e5 <__alltraps>

c0103dfb <vector102>:
.globl vector102
vector102:
  pushl $0
c0103dfb:	6a 00                	push   $0x0
  pushl $102
c0103dfd:	6a 66                	push   $0x66
  jmp __alltraps
c0103dff:	e9 e1 06 00 00       	jmp    c01044e5 <__alltraps>

c0103e04 <vector103>:
.globl vector103
vector103:
  pushl $0
c0103e04:	6a 00                	push   $0x0
  pushl $103
c0103e06:	6a 67                	push   $0x67
  jmp __alltraps
c0103e08:	e9 d8 06 00 00       	jmp    c01044e5 <__alltraps>

c0103e0d <vector104>:
.globl vector104
vector104:
  pushl $0
c0103e0d:	6a 00                	push   $0x0
  pushl $104
c0103e0f:	6a 68                	push   $0x68
  jmp __alltraps
c0103e11:	e9 cf 06 00 00       	jmp    c01044e5 <__alltraps>

c0103e16 <vector105>:
.globl vector105
vector105:
  pushl $0
c0103e16:	6a 00                	push   $0x0
  pushl $105
c0103e18:	6a 69                	push   $0x69
  jmp __alltraps
c0103e1a:	e9 c6 06 00 00       	jmp    c01044e5 <__alltraps>

c0103e1f <vector106>:
.globl vector106
vector106:
  pushl $0
c0103e1f:	6a 00                	push   $0x0
  pushl $106
c0103e21:	6a 6a                	push   $0x6a
  jmp __alltraps
c0103e23:	e9 bd 06 00 00       	jmp    c01044e5 <__alltraps>

c0103e28 <vector107>:
.globl vector107
vector107:
  pushl $0
c0103e28:	6a 00                	push   $0x0
  pushl $107
c0103e2a:	6a 6b                	push   $0x6b
  jmp __alltraps
c0103e2c:	e9 b4 06 00 00       	jmp    c01044e5 <__alltraps>

c0103e31 <vector108>:
.globl vector108
vector108:
  pushl $0
c0103e31:	6a 00                	push   $0x0
  pushl $108
c0103e33:	6a 6c                	push   $0x6c
  jmp __alltraps
c0103e35:	e9 ab 06 00 00       	jmp    c01044e5 <__alltraps>

c0103e3a <vector109>:
.globl vector109
vector109:
  pushl $0
c0103e3a:	6a 00                	push   $0x0
  pushl $109
c0103e3c:	6a 6d                	push   $0x6d
  jmp __alltraps
c0103e3e:	e9 a2 06 00 00       	jmp    c01044e5 <__alltraps>

c0103e43 <vector110>:
.globl vector110
vector110:
  pushl $0
c0103e43:	6a 00                	push   $0x0
  pushl $110
c0103e45:	6a 6e                	push   $0x6e
  jmp __alltraps
c0103e47:	e9 99 06 00 00       	jmp    c01044e5 <__alltraps>

c0103e4c <vector111>:
.globl vector111
vector111:
  pushl $0
c0103e4c:	6a 00                	push   $0x0
  pushl $111
c0103e4e:	6a 6f                	push   $0x6f
  jmp __alltraps
c0103e50:	e9 90 06 00 00       	jmp    c01044e5 <__alltraps>

c0103e55 <vector112>:
.globl vector112
vector112:
  pushl $0
c0103e55:	6a 00                	push   $0x0
  pushl $112
c0103e57:	6a 70                	push   $0x70
  jmp __alltraps
c0103e59:	e9 87 06 00 00       	jmp    c01044e5 <__alltraps>

c0103e5e <vector113>:
.globl vector113
vector113:
  pushl $0
c0103e5e:	6a 00                	push   $0x0
  pushl $113
c0103e60:	6a 71                	push   $0x71
  jmp __alltraps
c0103e62:	e9 7e 06 00 00       	jmp    c01044e5 <__alltraps>

c0103e67 <vector114>:
.globl vector114
vector114:
  pushl $0
c0103e67:	6a 00                	push   $0x0
  pushl $114
c0103e69:	6a 72                	push   $0x72
  jmp __alltraps
c0103e6b:	e9 75 06 00 00       	jmp    c01044e5 <__alltraps>

c0103e70 <vector115>:
.globl vector115
vector115:
  pushl $0
c0103e70:	6a 00                	push   $0x0
  pushl $115
c0103e72:	6a 73                	push   $0x73
  jmp __alltraps
c0103e74:	e9 6c 06 00 00       	jmp    c01044e5 <__alltraps>

c0103e79 <vector116>:
.globl vector116
vector116:
  pushl $0
c0103e79:	6a 00                	push   $0x0
  pushl $116
c0103e7b:	6a 74                	push   $0x74
  jmp __alltraps
c0103e7d:	e9 63 06 00 00       	jmp    c01044e5 <__alltraps>

c0103e82 <vector117>:
.globl vector117
vector117:
  pushl $0
c0103e82:	6a 00                	push   $0x0
  pushl $117
c0103e84:	6a 75                	push   $0x75
  jmp __alltraps
c0103e86:	e9 5a 06 00 00       	jmp    c01044e5 <__alltraps>

c0103e8b <vector118>:
.globl vector118
vector118:
  pushl $0
c0103e8b:	6a 00                	push   $0x0
  pushl $118
c0103e8d:	6a 76                	push   $0x76
  jmp __alltraps
c0103e8f:	e9 51 06 00 00       	jmp    c01044e5 <__alltraps>

c0103e94 <vector119>:
.globl vector119
vector119:
  pushl $0
c0103e94:	6a 00                	push   $0x0
  pushl $119
c0103e96:	6a 77                	push   $0x77
  jmp __alltraps
c0103e98:	e9 48 06 00 00       	jmp    c01044e5 <__alltraps>

c0103e9d <vector120>:
.globl vector120
vector120:
  pushl $0
c0103e9d:	6a 00                	push   $0x0
  pushl $120
c0103e9f:	6a 78                	push   $0x78
  jmp __alltraps
c0103ea1:	e9 3f 06 00 00       	jmp    c01044e5 <__alltraps>

c0103ea6 <vector121>:
.globl vector121
vector121:
  pushl $0
c0103ea6:	6a 00                	push   $0x0
  pushl $121
c0103ea8:	6a 79                	push   $0x79
  jmp __alltraps
c0103eaa:	e9 36 06 00 00       	jmp    c01044e5 <__alltraps>

c0103eaf <vector122>:
.globl vector122
vector122:
  pushl $0
c0103eaf:	6a 00                	push   $0x0
  pushl $122
c0103eb1:	6a 7a                	push   $0x7a
  jmp __alltraps
c0103eb3:	e9 2d 06 00 00       	jmp    c01044e5 <__alltraps>

c0103eb8 <vector123>:
.globl vector123
vector123:
  pushl $0
c0103eb8:	6a 00                	push   $0x0
  pushl $123
c0103eba:	6a 7b                	push   $0x7b
  jmp __alltraps
c0103ebc:	e9 24 06 00 00       	jmp    c01044e5 <__alltraps>

c0103ec1 <vector124>:
.globl vector124
vector124:
  pushl $0
c0103ec1:	6a 00                	push   $0x0
  pushl $124
c0103ec3:	6a 7c                	push   $0x7c
  jmp __alltraps
c0103ec5:	e9 1b 06 00 00       	jmp    c01044e5 <__alltraps>

c0103eca <vector125>:
.globl vector125
vector125:
  pushl $0
c0103eca:	6a 00                	push   $0x0
  pushl $125
c0103ecc:	6a 7d                	push   $0x7d
  jmp __alltraps
c0103ece:	e9 12 06 00 00       	jmp    c01044e5 <__alltraps>

c0103ed3 <vector126>:
.globl vector126
vector126:
  pushl $0
c0103ed3:	6a 00                	push   $0x0
  pushl $126
c0103ed5:	6a 7e                	push   $0x7e
  jmp __alltraps
c0103ed7:	e9 09 06 00 00       	jmp    c01044e5 <__alltraps>

c0103edc <vector127>:
.globl vector127
vector127:
  pushl $0
c0103edc:	6a 00                	push   $0x0
  pushl $127
c0103ede:	6a 7f                	push   $0x7f
  jmp __alltraps
c0103ee0:	e9 00 06 00 00       	jmp    c01044e5 <__alltraps>

c0103ee5 <vector128>:
.globl vector128
vector128:
  pushl $0
c0103ee5:	6a 00                	push   $0x0
  pushl $128
c0103ee7:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0103eec:	e9 f4 05 00 00       	jmp    c01044e5 <__alltraps>

c0103ef1 <vector129>:
.globl vector129
vector129:
  pushl $0
c0103ef1:	6a 00                	push   $0x0
  pushl $129
c0103ef3:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0103ef8:	e9 e8 05 00 00       	jmp    c01044e5 <__alltraps>

c0103efd <vector130>:
.globl vector130
vector130:
  pushl $0
c0103efd:	6a 00                	push   $0x0
  pushl $130
c0103eff:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0103f04:	e9 dc 05 00 00       	jmp    c01044e5 <__alltraps>

c0103f09 <vector131>:
.globl vector131
vector131:
  pushl $0
c0103f09:	6a 00                	push   $0x0
  pushl $131
c0103f0b:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0103f10:	e9 d0 05 00 00       	jmp    c01044e5 <__alltraps>

c0103f15 <vector132>:
.globl vector132
vector132:
  pushl $0
c0103f15:	6a 00                	push   $0x0
  pushl $132
c0103f17:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0103f1c:	e9 c4 05 00 00       	jmp    c01044e5 <__alltraps>

c0103f21 <vector133>:
.globl vector133
vector133:
  pushl $0
c0103f21:	6a 00                	push   $0x0
  pushl $133
c0103f23:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0103f28:	e9 b8 05 00 00       	jmp    c01044e5 <__alltraps>

c0103f2d <vector134>:
.globl vector134
vector134:
  pushl $0
c0103f2d:	6a 00                	push   $0x0
  pushl $134
c0103f2f:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0103f34:	e9 ac 05 00 00       	jmp    c01044e5 <__alltraps>

c0103f39 <vector135>:
.globl vector135
vector135:
  pushl $0
c0103f39:	6a 00                	push   $0x0
  pushl $135
c0103f3b:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0103f40:	e9 a0 05 00 00       	jmp    c01044e5 <__alltraps>

c0103f45 <vector136>:
.globl vector136
vector136:
  pushl $0
c0103f45:	6a 00                	push   $0x0
  pushl $136
c0103f47:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0103f4c:	e9 94 05 00 00       	jmp    c01044e5 <__alltraps>

c0103f51 <vector137>:
.globl vector137
vector137:
  pushl $0
c0103f51:	6a 00                	push   $0x0
  pushl $137
c0103f53:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0103f58:	e9 88 05 00 00       	jmp    c01044e5 <__alltraps>

c0103f5d <vector138>:
.globl vector138
vector138:
  pushl $0
c0103f5d:	6a 00                	push   $0x0
  pushl $138
c0103f5f:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0103f64:	e9 7c 05 00 00       	jmp    c01044e5 <__alltraps>

c0103f69 <vector139>:
.globl vector139
vector139:
  pushl $0
c0103f69:	6a 00                	push   $0x0
  pushl $139
c0103f6b:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0103f70:	e9 70 05 00 00       	jmp    c01044e5 <__alltraps>

c0103f75 <vector140>:
.globl vector140
vector140:
  pushl $0
c0103f75:	6a 00                	push   $0x0
  pushl $140
c0103f77:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0103f7c:	e9 64 05 00 00       	jmp    c01044e5 <__alltraps>

c0103f81 <vector141>:
.globl vector141
vector141:
  pushl $0
c0103f81:	6a 00                	push   $0x0
  pushl $141
c0103f83:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0103f88:	e9 58 05 00 00       	jmp    c01044e5 <__alltraps>

c0103f8d <vector142>:
.globl vector142
vector142:
  pushl $0
c0103f8d:	6a 00                	push   $0x0
  pushl $142
c0103f8f:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0103f94:	e9 4c 05 00 00       	jmp    c01044e5 <__alltraps>

c0103f99 <vector143>:
.globl vector143
vector143:
  pushl $0
c0103f99:	6a 00                	push   $0x0
  pushl $143
c0103f9b:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0103fa0:	e9 40 05 00 00       	jmp    c01044e5 <__alltraps>

c0103fa5 <vector144>:
.globl vector144
vector144:
  pushl $0
c0103fa5:	6a 00                	push   $0x0
  pushl $144
c0103fa7:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0103fac:	e9 34 05 00 00       	jmp    c01044e5 <__alltraps>

c0103fb1 <vector145>:
.globl vector145
vector145:
  pushl $0
c0103fb1:	6a 00                	push   $0x0
  pushl $145
c0103fb3:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0103fb8:	e9 28 05 00 00       	jmp    c01044e5 <__alltraps>

c0103fbd <vector146>:
.globl vector146
vector146:
  pushl $0
c0103fbd:	6a 00                	push   $0x0
  pushl $146
c0103fbf:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0103fc4:	e9 1c 05 00 00       	jmp    c01044e5 <__alltraps>

c0103fc9 <vector147>:
.globl vector147
vector147:
  pushl $0
c0103fc9:	6a 00                	push   $0x0
  pushl $147
c0103fcb:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0103fd0:	e9 10 05 00 00       	jmp    c01044e5 <__alltraps>

c0103fd5 <vector148>:
.globl vector148
vector148:
  pushl $0
c0103fd5:	6a 00                	push   $0x0
  pushl $148
c0103fd7:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0103fdc:	e9 04 05 00 00       	jmp    c01044e5 <__alltraps>

c0103fe1 <vector149>:
.globl vector149
vector149:
  pushl $0
c0103fe1:	6a 00                	push   $0x0
  pushl $149
c0103fe3:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0103fe8:	e9 f8 04 00 00       	jmp    c01044e5 <__alltraps>

c0103fed <vector150>:
.globl vector150
vector150:
  pushl $0
c0103fed:	6a 00                	push   $0x0
  pushl $150
c0103fef:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0103ff4:	e9 ec 04 00 00       	jmp    c01044e5 <__alltraps>

c0103ff9 <vector151>:
.globl vector151
vector151:
  pushl $0
c0103ff9:	6a 00                	push   $0x0
  pushl $151
c0103ffb:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0104000:	e9 e0 04 00 00       	jmp    c01044e5 <__alltraps>

c0104005 <vector152>:
.globl vector152
vector152:
  pushl $0
c0104005:	6a 00                	push   $0x0
  pushl $152
c0104007:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c010400c:	e9 d4 04 00 00       	jmp    c01044e5 <__alltraps>

c0104011 <vector153>:
.globl vector153
vector153:
  pushl $0
c0104011:	6a 00                	push   $0x0
  pushl $153
c0104013:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0104018:	e9 c8 04 00 00       	jmp    c01044e5 <__alltraps>

c010401d <vector154>:
.globl vector154
vector154:
  pushl $0
c010401d:	6a 00                	push   $0x0
  pushl $154
c010401f:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0104024:	e9 bc 04 00 00       	jmp    c01044e5 <__alltraps>

c0104029 <vector155>:
.globl vector155
vector155:
  pushl $0
c0104029:	6a 00                	push   $0x0
  pushl $155
c010402b:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0104030:	e9 b0 04 00 00       	jmp    c01044e5 <__alltraps>

c0104035 <vector156>:
.globl vector156
vector156:
  pushl $0
c0104035:	6a 00                	push   $0x0
  pushl $156
c0104037:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c010403c:	e9 a4 04 00 00       	jmp    c01044e5 <__alltraps>

c0104041 <vector157>:
.globl vector157
vector157:
  pushl $0
c0104041:	6a 00                	push   $0x0
  pushl $157
c0104043:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0104048:	e9 98 04 00 00       	jmp    c01044e5 <__alltraps>

c010404d <vector158>:
.globl vector158
vector158:
  pushl $0
c010404d:	6a 00                	push   $0x0
  pushl $158
c010404f:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0104054:	e9 8c 04 00 00       	jmp    c01044e5 <__alltraps>

c0104059 <vector159>:
.globl vector159
vector159:
  pushl $0
c0104059:	6a 00                	push   $0x0
  pushl $159
c010405b:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0104060:	e9 80 04 00 00       	jmp    c01044e5 <__alltraps>

c0104065 <vector160>:
.globl vector160
vector160:
  pushl $0
c0104065:	6a 00                	push   $0x0
  pushl $160
c0104067:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c010406c:	e9 74 04 00 00       	jmp    c01044e5 <__alltraps>

c0104071 <vector161>:
.globl vector161
vector161:
  pushl $0
c0104071:	6a 00                	push   $0x0
  pushl $161
c0104073:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0104078:	e9 68 04 00 00       	jmp    c01044e5 <__alltraps>

c010407d <vector162>:
.globl vector162
vector162:
  pushl $0
c010407d:	6a 00                	push   $0x0
  pushl $162
c010407f:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c0104084:	e9 5c 04 00 00       	jmp    c01044e5 <__alltraps>

c0104089 <vector163>:
.globl vector163
vector163:
  pushl $0
c0104089:	6a 00                	push   $0x0
  pushl $163
c010408b:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c0104090:	e9 50 04 00 00       	jmp    c01044e5 <__alltraps>

c0104095 <vector164>:
.globl vector164
vector164:
  pushl $0
c0104095:	6a 00                	push   $0x0
  pushl $164
c0104097:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c010409c:	e9 44 04 00 00       	jmp    c01044e5 <__alltraps>

c01040a1 <vector165>:
.globl vector165
vector165:
  pushl $0
c01040a1:	6a 00                	push   $0x0
  pushl $165
c01040a3:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c01040a8:	e9 38 04 00 00       	jmp    c01044e5 <__alltraps>

c01040ad <vector166>:
.globl vector166
vector166:
  pushl $0
c01040ad:	6a 00                	push   $0x0
  pushl $166
c01040af:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c01040b4:	e9 2c 04 00 00       	jmp    c01044e5 <__alltraps>

c01040b9 <vector167>:
.globl vector167
vector167:
  pushl $0
c01040b9:	6a 00                	push   $0x0
  pushl $167
c01040bb:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c01040c0:	e9 20 04 00 00       	jmp    c01044e5 <__alltraps>

c01040c5 <vector168>:
.globl vector168
vector168:
  pushl $0
c01040c5:	6a 00                	push   $0x0
  pushl $168
c01040c7:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c01040cc:	e9 14 04 00 00       	jmp    c01044e5 <__alltraps>

c01040d1 <vector169>:
.globl vector169
vector169:
  pushl $0
c01040d1:	6a 00                	push   $0x0
  pushl $169
c01040d3:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c01040d8:	e9 08 04 00 00       	jmp    c01044e5 <__alltraps>

c01040dd <vector170>:
.globl vector170
vector170:
  pushl $0
c01040dd:	6a 00                	push   $0x0
  pushl $170
c01040df:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c01040e4:	e9 fc 03 00 00       	jmp    c01044e5 <__alltraps>

c01040e9 <vector171>:
.globl vector171
vector171:
  pushl $0
c01040e9:	6a 00                	push   $0x0
  pushl $171
c01040eb:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c01040f0:	e9 f0 03 00 00       	jmp    c01044e5 <__alltraps>

c01040f5 <vector172>:
.globl vector172
vector172:
  pushl $0
c01040f5:	6a 00                	push   $0x0
  pushl $172
c01040f7:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c01040fc:	e9 e4 03 00 00       	jmp    c01044e5 <__alltraps>

c0104101 <vector173>:
.globl vector173
vector173:
  pushl $0
c0104101:	6a 00                	push   $0x0
  pushl $173
c0104103:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c0104108:	e9 d8 03 00 00       	jmp    c01044e5 <__alltraps>

c010410d <vector174>:
.globl vector174
vector174:
  pushl $0
c010410d:	6a 00                	push   $0x0
  pushl $174
c010410f:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0104114:	e9 cc 03 00 00       	jmp    c01044e5 <__alltraps>

c0104119 <vector175>:
.globl vector175
vector175:
  pushl $0
c0104119:	6a 00                	push   $0x0
  pushl $175
c010411b:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0104120:	e9 c0 03 00 00       	jmp    c01044e5 <__alltraps>

c0104125 <vector176>:
.globl vector176
vector176:
  pushl $0
c0104125:	6a 00                	push   $0x0
  pushl $176
c0104127:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c010412c:	e9 b4 03 00 00       	jmp    c01044e5 <__alltraps>

c0104131 <vector177>:
.globl vector177
vector177:
  pushl $0
c0104131:	6a 00                	push   $0x0
  pushl $177
c0104133:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0104138:	e9 a8 03 00 00       	jmp    c01044e5 <__alltraps>

c010413d <vector178>:
.globl vector178
vector178:
  pushl $0
c010413d:	6a 00                	push   $0x0
  pushl $178
c010413f:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0104144:	e9 9c 03 00 00       	jmp    c01044e5 <__alltraps>

c0104149 <vector179>:
.globl vector179
vector179:
  pushl $0
c0104149:	6a 00                	push   $0x0
  pushl $179
c010414b:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0104150:	e9 90 03 00 00       	jmp    c01044e5 <__alltraps>

c0104155 <vector180>:
.globl vector180
vector180:
  pushl $0
c0104155:	6a 00                	push   $0x0
  pushl $180
c0104157:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c010415c:	e9 84 03 00 00       	jmp    c01044e5 <__alltraps>

c0104161 <vector181>:
.globl vector181
vector181:
  pushl $0
c0104161:	6a 00                	push   $0x0
  pushl $181
c0104163:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c0104168:	e9 78 03 00 00       	jmp    c01044e5 <__alltraps>

c010416d <vector182>:
.globl vector182
vector182:
  pushl $0
c010416d:	6a 00                	push   $0x0
  pushl $182
c010416f:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0104174:	e9 6c 03 00 00       	jmp    c01044e5 <__alltraps>

c0104179 <vector183>:
.globl vector183
vector183:
  pushl $0
c0104179:	6a 00                	push   $0x0
  pushl $183
c010417b:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c0104180:	e9 60 03 00 00       	jmp    c01044e5 <__alltraps>

c0104185 <vector184>:
.globl vector184
vector184:
  pushl $0
c0104185:	6a 00                	push   $0x0
  pushl $184
c0104187:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c010418c:	e9 54 03 00 00       	jmp    c01044e5 <__alltraps>

c0104191 <vector185>:
.globl vector185
vector185:
  pushl $0
c0104191:	6a 00                	push   $0x0
  pushl $185
c0104193:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c0104198:	e9 48 03 00 00       	jmp    c01044e5 <__alltraps>

c010419d <vector186>:
.globl vector186
vector186:
  pushl $0
c010419d:	6a 00                	push   $0x0
  pushl $186
c010419f:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c01041a4:	e9 3c 03 00 00       	jmp    c01044e5 <__alltraps>

c01041a9 <vector187>:
.globl vector187
vector187:
  pushl $0
c01041a9:	6a 00                	push   $0x0
  pushl $187
c01041ab:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c01041b0:	e9 30 03 00 00       	jmp    c01044e5 <__alltraps>

c01041b5 <vector188>:
.globl vector188
vector188:
  pushl $0
c01041b5:	6a 00                	push   $0x0
  pushl $188
c01041b7:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c01041bc:	e9 24 03 00 00       	jmp    c01044e5 <__alltraps>

c01041c1 <vector189>:
.globl vector189
vector189:
  pushl $0
c01041c1:	6a 00                	push   $0x0
  pushl $189
c01041c3:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c01041c8:	e9 18 03 00 00       	jmp    c01044e5 <__alltraps>

c01041cd <vector190>:
.globl vector190
vector190:
  pushl $0
c01041cd:	6a 00                	push   $0x0
  pushl $190
c01041cf:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c01041d4:	e9 0c 03 00 00       	jmp    c01044e5 <__alltraps>

c01041d9 <vector191>:
.globl vector191
vector191:
  pushl $0
c01041d9:	6a 00                	push   $0x0
  pushl $191
c01041db:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c01041e0:	e9 00 03 00 00       	jmp    c01044e5 <__alltraps>

c01041e5 <vector192>:
.globl vector192
vector192:
  pushl $0
c01041e5:	6a 00                	push   $0x0
  pushl $192
c01041e7:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c01041ec:	e9 f4 02 00 00       	jmp    c01044e5 <__alltraps>

c01041f1 <vector193>:
.globl vector193
vector193:
  pushl $0
c01041f1:	6a 00                	push   $0x0
  pushl $193
c01041f3:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c01041f8:	e9 e8 02 00 00       	jmp    c01044e5 <__alltraps>

c01041fd <vector194>:
.globl vector194
vector194:
  pushl $0
c01041fd:	6a 00                	push   $0x0
  pushl $194
c01041ff:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c0104204:	e9 dc 02 00 00       	jmp    c01044e5 <__alltraps>

c0104209 <vector195>:
.globl vector195
vector195:
  pushl $0
c0104209:	6a 00                	push   $0x0
  pushl $195
c010420b:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0104210:	e9 d0 02 00 00       	jmp    c01044e5 <__alltraps>

c0104215 <vector196>:
.globl vector196
vector196:
  pushl $0
c0104215:	6a 00                	push   $0x0
  pushl $196
c0104217:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c010421c:	e9 c4 02 00 00       	jmp    c01044e5 <__alltraps>

c0104221 <vector197>:
.globl vector197
vector197:
  pushl $0
c0104221:	6a 00                	push   $0x0
  pushl $197
c0104223:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c0104228:	e9 b8 02 00 00       	jmp    c01044e5 <__alltraps>

c010422d <vector198>:
.globl vector198
vector198:
  pushl $0
c010422d:	6a 00                	push   $0x0
  pushl $198
c010422f:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c0104234:	e9 ac 02 00 00       	jmp    c01044e5 <__alltraps>

c0104239 <vector199>:
.globl vector199
vector199:
  pushl $0
c0104239:	6a 00                	push   $0x0
  pushl $199
c010423b:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0104240:	e9 a0 02 00 00       	jmp    c01044e5 <__alltraps>

c0104245 <vector200>:
.globl vector200
vector200:
  pushl $0
c0104245:	6a 00                	push   $0x0
  pushl $200
c0104247:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c010424c:	e9 94 02 00 00       	jmp    c01044e5 <__alltraps>

c0104251 <vector201>:
.globl vector201
vector201:
  pushl $0
c0104251:	6a 00                	push   $0x0
  pushl $201
c0104253:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0104258:	e9 88 02 00 00       	jmp    c01044e5 <__alltraps>

c010425d <vector202>:
.globl vector202
vector202:
  pushl $0
c010425d:	6a 00                	push   $0x0
  pushl $202
c010425f:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c0104264:	e9 7c 02 00 00       	jmp    c01044e5 <__alltraps>

c0104269 <vector203>:
.globl vector203
vector203:
  pushl $0
c0104269:	6a 00                	push   $0x0
  pushl $203
c010426b:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c0104270:	e9 70 02 00 00       	jmp    c01044e5 <__alltraps>

c0104275 <vector204>:
.globl vector204
vector204:
  pushl $0
c0104275:	6a 00                	push   $0x0
  pushl $204
c0104277:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c010427c:	e9 64 02 00 00       	jmp    c01044e5 <__alltraps>

c0104281 <vector205>:
.globl vector205
vector205:
  pushl $0
c0104281:	6a 00                	push   $0x0
  pushl $205
c0104283:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c0104288:	e9 58 02 00 00       	jmp    c01044e5 <__alltraps>

c010428d <vector206>:
.globl vector206
vector206:
  pushl $0
c010428d:	6a 00                	push   $0x0
  pushl $206
c010428f:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c0104294:	e9 4c 02 00 00       	jmp    c01044e5 <__alltraps>

c0104299 <vector207>:
.globl vector207
vector207:
  pushl $0
c0104299:	6a 00                	push   $0x0
  pushl $207
c010429b:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c01042a0:	e9 40 02 00 00       	jmp    c01044e5 <__alltraps>

c01042a5 <vector208>:
.globl vector208
vector208:
  pushl $0
c01042a5:	6a 00                	push   $0x0
  pushl $208
c01042a7:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c01042ac:	e9 34 02 00 00       	jmp    c01044e5 <__alltraps>

c01042b1 <vector209>:
.globl vector209
vector209:
  pushl $0
c01042b1:	6a 00                	push   $0x0
  pushl $209
c01042b3:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c01042b8:	e9 28 02 00 00       	jmp    c01044e5 <__alltraps>

c01042bd <vector210>:
.globl vector210
vector210:
  pushl $0
c01042bd:	6a 00                	push   $0x0
  pushl $210
c01042bf:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c01042c4:	e9 1c 02 00 00       	jmp    c01044e5 <__alltraps>

c01042c9 <vector211>:
.globl vector211
vector211:
  pushl $0
c01042c9:	6a 00                	push   $0x0
  pushl $211
c01042cb:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c01042d0:	e9 10 02 00 00       	jmp    c01044e5 <__alltraps>

c01042d5 <vector212>:
.globl vector212
vector212:
  pushl $0
c01042d5:	6a 00                	push   $0x0
  pushl $212
c01042d7:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c01042dc:	e9 04 02 00 00       	jmp    c01044e5 <__alltraps>

c01042e1 <vector213>:
.globl vector213
vector213:
  pushl $0
c01042e1:	6a 00                	push   $0x0
  pushl $213
c01042e3:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c01042e8:	e9 f8 01 00 00       	jmp    c01044e5 <__alltraps>

c01042ed <vector214>:
.globl vector214
vector214:
  pushl $0
c01042ed:	6a 00                	push   $0x0
  pushl $214
c01042ef:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c01042f4:	e9 ec 01 00 00       	jmp    c01044e5 <__alltraps>

c01042f9 <vector215>:
.globl vector215
vector215:
  pushl $0
c01042f9:	6a 00                	push   $0x0
  pushl $215
c01042fb:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c0104300:	e9 e0 01 00 00       	jmp    c01044e5 <__alltraps>

c0104305 <vector216>:
.globl vector216
vector216:
  pushl $0
c0104305:	6a 00                	push   $0x0
  pushl $216
c0104307:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c010430c:	e9 d4 01 00 00       	jmp    c01044e5 <__alltraps>

c0104311 <vector217>:
.globl vector217
vector217:
  pushl $0
c0104311:	6a 00                	push   $0x0
  pushl $217
c0104313:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0104318:	e9 c8 01 00 00       	jmp    c01044e5 <__alltraps>

c010431d <vector218>:
.globl vector218
vector218:
  pushl $0
c010431d:	6a 00                	push   $0x0
  pushl $218
c010431f:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c0104324:	e9 bc 01 00 00       	jmp    c01044e5 <__alltraps>

c0104329 <vector219>:
.globl vector219
vector219:
  pushl $0
c0104329:	6a 00                	push   $0x0
  pushl $219
c010432b:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0104330:	e9 b0 01 00 00       	jmp    c01044e5 <__alltraps>

c0104335 <vector220>:
.globl vector220
vector220:
  pushl $0
c0104335:	6a 00                	push   $0x0
  pushl $220
c0104337:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c010433c:	e9 a4 01 00 00       	jmp    c01044e5 <__alltraps>

c0104341 <vector221>:
.globl vector221
vector221:
  pushl $0
c0104341:	6a 00                	push   $0x0
  pushl $221
c0104343:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c0104348:	e9 98 01 00 00       	jmp    c01044e5 <__alltraps>

c010434d <vector222>:
.globl vector222
vector222:
  pushl $0
c010434d:	6a 00                	push   $0x0
  pushl $222
c010434f:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0104354:	e9 8c 01 00 00       	jmp    c01044e5 <__alltraps>

c0104359 <vector223>:
.globl vector223
vector223:
  pushl $0
c0104359:	6a 00                	push   $0x0
  pushl $223
c010435b:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c0104360:	e9 80 01 00 00       	jmp    c01044e5 <__alltraps>

c0104365 <vector224>:
.globl vector224
vector224:
  pushl $0
c0104365:	6a 00                	push   $0x0
  pushl $224
c0104367:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c010436c:	e9 74 01 00 00       	jmp    c01044e5 <__alltraps>

c0104371 <vector225>:
.globl vector225
vector225:
  pushl $0
c0104371:	6a 00                	push   $0x0
  pushl $225
c0104373:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c0104378:	e9 68 01 00 00       	jmp    c01044e5 <__alltraps>

c010437d <vector226>:
.globl vector226
vector226:
  pushl $0
c010437d:	6a 00                	push   $0x0
  pushl $226
c010437f:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c0104384:	e9 5c 01 00 00       	jmp    c01044e5 <__alltraps>

c0104389 <vector227>:
.globl vector227
vector227:
  pushl $0
c0104389:	6a 00                	push   $0x0
  pushl $227
c010438b:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c0104390:	e9 50 01 00 00       	jmp    c01044e5 <__alltraps>

c0104395 <vector228>:
.globl vector228
vector228:
  pushl $0
c0104395:	6a 00                	push   $0x0
  pushl $228
c0104397:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c010439c:	e9 44 01 00 00       	jmp    c01044e5 <__alltraps>

c01043a1 <vector229>:
.globl vector229
vector229:
  pushl $0
c01043a1:	6a 00                	push   $0x0
  pushl $229
c01043a3:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c01043a8:	e9 38 01 00 00       	jmp    c01044e5 <__alltraps>

c01043ad <vector230>:
.globl vector230
vector230:
  pushl $0
c01043ad:	6a 00                	push   $0x0
  pushl $230
c01043af:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c01043b4:	e9 2c 01 00 00       	jmp    c01044e5 <__alltraps>

c01043b9 <vector231>:
.globl vector231
vector231:
  pushl $0
c01043b9:	6a 00                	push   $0x0
  pushl $231
c01043bb:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c01043c0:	e9 20 01 00 00       	jmp    c01044e5 <__alltraps>

c01043c5 <vector232>:
.globl vector232
vector232:
  pushl $0
c01043c5:	6a 00                	push   $0x0
  pushl $232
c01043c7:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c01043cc:	e9 14 01 00 00       	jmp    c01044e5 <__alltraps>

c01043d1 <vector233>:
.globl vector233
vector233:
  pushl $0
c01043d1:	6a 00                	push   $0x0
  pushl $233
c01043d3:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c01043d8:	e9 08 01 00 00       	jmp    c01044e5 <__alltraps>

c01043dd <vector234>:
.globl vector234
vector234:
  pushl $0
c01043dd:	6a 00                	push   $0x0
  pushl $234
c01043df:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c01043e4:	e9 fc 00 00 00       	jmp    c01044e5 <__alltraps>

c01043e9 <vector235>:
.globl vector235
vector235:
  pushl $0
c01043e9:	6a 00                	push   $0x0
  pushl $235
c01043eb:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c01043f0:	e9 f0 00 00 00       	jmp    c01044e5 <__alltraps>

c01043f5 <vector236>:
.globl vector236
vector236:
  pushl $0
c01043f5:	6a 00                	push   $0x0
  pushl $236
c01043f7:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c01043fc:	e9 e4 00 00 00       	jmp    c01044e5 <__alltraps>

c0104401 <vector237>:
.globl vector237
vector237:
  pushl $0
c0104401:	6a 00                	push   $0x0
  pushl $237
c0104403:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c0104408:	e9 d8 00 00 00       	jmp    c01044e5 <__alltraps>

c010440d <vector238>:
.globl vector238
vector238:
  pushl $0
c010440d:	6a 00                	push   $0x0
  pushl $238
c010440f:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c0104414:	e9 cc 00 00 00       	jmp    c01044e5 <__alltraps>

c0104419 <vector239>:
.globl vector239
vector239:
  pushl $0
c0104419:	6a 00                	push   $0x0
  pushl $239
c010441b:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c0104420:	e9 c0 00 00 00       	jmp    c01044e5 <__alltraps>

c0104425 <vector240>:
.globl vector240
vector240:
  pushl $0
c0104425:	6a 00                	push   $0x0
  pushl $240
c0104427:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c010442c:	e9 b4 00 00 00       	jmp    c01044e5 <__alltraps>

c0104431 <vector241>:
.globl vector241
vector241:
  pushl $0
c0104431:	6a 00                	push   $0x0
  pushl $241
c0104433:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c0104438:	e9 a8 00 00 00       	jmp    c01044e5 <__alltraps>

c010443d <vector242>:
.globl vector242
vector242:
  pushl $0
c010443d:	6a 00                	push   $0x0
  pushl $242
c010443f:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c0104444:	e9 9c 00 00 00       	jmp    c01044e5 <__alltraps>

c0104449 <vector243>:
.globl vector243
vector243:
  pushl $0
c0104449:	6a 00                	push   $0x0
  pushl $243
c010444b:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c0104450:	e9 90 00 00 00       	jmp    c01044e5 <__alltraps>

c0104455 <vector244>:
.globl vector244
vector244:
  pushl $0
c0104455:	6a 00                	push   $0x0
  pushl $244
c0104457:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c010445c:	e9 84 00 00 00       	jmp    c01044e5 <__alltraps>

c0104461 <vector245>:
.globl vector245
vector245:
  pushl $0
c0104461:	6a 00                	push   $0x0
  pushl $245
c0104463:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c0104468:	e9 78 00 00 00       	jmp    c01044e5 <__alltraps>

c010446d <vector246>:
.globl vector246
vector246:
  pushl $0
c010446d:	6a 00                	push   $0x0
  pushl $246
c010446f:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c0104474:	e9 6c 00 00 00       	jmp    c01044e5 <__alltraps>

c0104479 <vector247>:
.globl vector247
vector247:
  pushl $0
c0104479:	6a 00                	push   $0x0
  pushl $247
c010447b:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c0104480:	e9 60 00 00 00       	jmp    c01044e5 <__alltraps>

c0104485 <vector248>:
.globl vector248
vector248:
  pushl $0
c0104485:	6a 00                	push   $0x0
  pushl $248
c0104487:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c010448c:	e9 54 00 00 00       	jmp    c01044e5 <__alltraps>

c0104491 <vector249>:
.globl vector249
vector249:
  pushl $0
c0104491:	6a 00                	push   $0x0
  pushl $249
c0104493:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c0104498:	e9 48 00 00 00       	jmp    c01044e5 <__alltraps>

c010449d <vector250>:
.globl vector250
vector250:
  pushl $0
c010449d:	6a 00                	push   $0x0
  pushl $250
c010449f:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c01044a4:	e9 3c 00 00 00       	jmp    c01044e5 <__alltraps>

c01044a9 <vector251>:
.globl vector251
vector251:
  pushl $0
c01044a9:	6a 00                	push   $0x0
  pushl $251
c01044ab:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c01044b0:	e9 30 00 00 00       	jmp    c01044e5 <__alltraps>

c01044b5 <vector252>:
.globl vector252
vector252:
  pushl $0
c01044b5:	6a 00                	push   $0x0
  pushl $252
c01044b7:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c01044bc:	e9 24 00 00 00       	jmp    c01044e5 <__alltraps>

c01044c1 <vector253>:
.globl vector253
vector253:
  pushl $0
c01044c1:	6a 00                	push   $0x0
  pushl $253
c01044c3:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c01044c8:	e9 18 00 00 00       	jmp    c01044e5 <__alltraps>

c01044cd <vector254>:
.globl vector254
vector254:
  pushl $0
c01044cd:	6a 00                	push   $0x0
  pushl $254
c01044cf:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c01044d4:	e9 0c 00 00 00       	jmp    c01044e5 <__alltraps>

c01044d9 <vector255>:
.globl vector255
vector255:
  pushl $0
c01044d9:	6a 00                	push   $0x0
  pushl $255
c01044db:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c01044e0:	e9 00 00 00 00       	jmp    c01044e5 <__alltraps>

c01044e5 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c01044e5:	1e                   	push   %ds
    pushl %es
c01044e6:	06                   	push   %es
    pushl %fs
c01044e7:	0f a0                	push   %fs
    pushl %gs
c01044e9:	0f a8                	push   %gs
    pushal
c01044eb:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c01044ec:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c01044f1:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c01044f3:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c01044f5:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c01044f6:	e8 63 f5 ff ff       	call   c0103a5e <trap>

    # pop the pushed stack pointer
    popl %esp
c01044fb:	5c                   	pop    %esp

c01044fc <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c01044fc:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c01044fd:	0f a9                	pop    %gs
    popl %fs
c01044ff:	0f a1                	pop    %fs
    popl %es
c0104501:	07                   	pop    %es
    popl %ds
c0104502:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0104503:	83 c4 08             	add    $0x8,%esp
    iret
c0104506:	cf                   	iret   

c0104507 <forkrets>:

.globl forkrets
forkrets:
    # set stack to this new process's trapframe
    movl 4(%esp), %esp
c0104507:	8b 64 24 04          	mov    0x4(%esp),%esp
    jmp __trapret
c010450b:	eb ef                	jmp    c01044fc <__trapret>

c010450d <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c010450d:	55                   	push   %ebp
c010450e:	89 e5                	mov    %esp,%ebp
c0104510:	83 ec 08             	sub    $0x8,%esp
    if (PPN(pa) >= npage) {
c0104513:	8b 45 08             	mov    0x8(%ebp),%eax
c0104516:	c1 e8 0c             	shr    $0xc,%eax
c0104519:	89 c2                	mov    %eax,%edx
c010451b:	a1 20 8a 12 c0       	mov    0xc0128a20,%eax
c0104520:	39 c2                	cmp    %eax,%edx
c0104522:	72 14                	jb     c0104538 <pa2page+0x2b>
        panic("pa2page called with invalid pa");
c0104524:	83 ec 04             	sub    $0x4,%esp
c0104527:	68 d0 b4 10 c0       	push   $0xc010b4d0
c010452c:	6a 5f                	push   $0x5f
c010452e:	68 ef b4 10 c0       	push   $0xc010b4ef
c0104533:	e8 24 d2 ff ff       	call   c010175c <__panic>
    }
    return &pages[PPN(pa)];
c0104538:	8b 0d e0 ab 12 c0    	mov    0xc012abe0,%ecx
c010453e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104541:	c1 e8 0c             	shr    $0xc,%eax
c0104544:	89 c2                	mov    %eax,%edx
c0104546:	89 d0                	mov    %edx,%eax
c0104548:	c1 e0 03             	shl    $0x3,%eax
c010454b:	01 d0                	add    %edx,%eax
c010454d:	c1 e0 02             	shl    $0x2,%eax
c0104550:	01 c8                	add    %ecx,%eax
}
c0104552:	c9                   	leave  
c0104553:	c3                   	ret    

c0104554 <pde2page>:
    }
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *
pde2page(pde_t pde) {
c0104554:	55                   	push   %ebp
c0104555:	89 e5                	mov    %esp,%ebp
c0104557:	83 ec 08             	sub    $0x8,%esp
    return pa2page(PDE_ADDR(pde));
c010455a:	8b 45 08             	mov    0x8(%ebp),%eax
c010455d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104562:	83 ec 0c             	sub    $0xc,%esp
c0104565:	50                   	push   %eax
c0104566:	e8 a2 ff ff ff       	call   c010450d <pa2page>
c010456b:	83 c4 10             	add    $0x10,%esp
}
c010456e:	c9                   	leave  
c010456f:	c3                   	ret    

c0104570 <mm_create>:
static void check_vma_struct(void);
static void check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
struct mm_struct *
mm_create(void) {
c0104570:	55                   	push   %ebp
c0104571:	89 e5                	mov    %esp,%ebp
c0104573:	83 ec 18             	sub    $0x18,%esp
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
c0104576:	83 ec 0c             	sub    $0xc,%esp
c0104579:	6a 18                	push   $0x18
c010457b:	e8 6d 1c 00 00       	call   c01061ed <kmalloc>
c0104580:	83 c4 10             	add    $0x10,%esp
c0104583:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (mm != NULL) {
c0104586:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010458a:	74 5b                	je     c01045e7 <mm_create+0x77>
        list_init(&(mm->mmap_list));
c010458c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010458f:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0104592:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104595:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104598:	89 50 04             	mov    %edx,0x4(%eax)
c010459b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010459e:	8b 50 04             	mov    0x4(%eax),%edx
c01045a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01045a4:	89 10                	mov    %edx,(%eax)
        mm->mmap_cache = NULL;
c01045a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045a9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        mm->pgdir = NULL;
c01045b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045b3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        mm->map_count = 0;
c01045ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045bd:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)

        if (swap_init_ok) swap_init_mm(mm);
c01045c4:	a1 08 8a 12 c0       	mov    0xc0128a08,%eax
c01045c9:	85 c0                	test   %eax,%eax
c01045cb:	74 10                	je     c01045dd <mm_create+0x6d>
c01045cd:	83 ec 0c             	sub    $0xc,%esp
c01045d0:	ff 75 f4             	pushl  -0xc(%ebp)
c01045d3:	e8 59 0c 00 00       	call   c0105231 <swap_init_mm>
c01045d8:	83 c4 10             	add    $0x10,%esp
c01045db:	eb 0a                	jmp    c01045e7 <mm_create+0x77>
        else mm->sm_priv = NULL;
c01045dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045e0:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
    }
    return mm;
c01045e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01045ea:	c9                   	leave  
c01045eb:	c3                   	ret    

c01045ec <vma_create>:

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
c01045ec:	55                   	push   %ebp
c01045ed:	89 e5                	mov    %esp,%ebp
c01045ef:	83 ec 18             	sub    $0x18,%esp
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
c01045f2:	83 ec 0c             	sub    $0xc,%esp
c01045f5:	6a 18                	push   $0x18
c01045f7:	e8 f1 1b 00 00       	call   c01061ed <kmalloc>
c01045fc:	83 c4 10             	add    $0x10,%esp
c01045ff:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (vma != NULL) {
c0104602:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104606:	74 1b                	je     c0104623 <vma_create+0x37>
        vma->vm_start = vm_start;
c0104608:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010460b:	8b 55 08             	mov    0x8(%ebp),%edx
c010460e:	89 50 04             	mov    %edx,0x4(%eax)
        vma->vm_end = vm_end;
c0104611:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104614:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104617:	89 50 08             	mov    %edx,0x8(%eax)
        vma->vm_flags = vm_flags;
c010461a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010461d:	8b 55 10             	mov    0x10(%ebp),%edx
c0104620:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    return vma;
c0104623:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104626:	c9                   	leave  
c0104627:	c3                   	ret    

c0104628 <find_vma>:


// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr) {
c0104628:	55                   	push   %ebp
c0104629:	89 e5                	mov    %esp,%ebp
c010462b:	83 ec 20             	sub    $0x20,%esp
    struct vma_struct *vma = NULL;
c010462e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    if (mm != NULL) {
c0104635:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104639:	0f 84 95 00 00 00    	je     c01046d4 <find_vma+0xac>
        vma = mm->mmap_cache;
c010463f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104642:	8b 40 08             	mov    0x8(%eax),%eax
c0104645:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
c0104648:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010464c:	74 16                	je     c0104664 <find_vma+0x3c>
c010464e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104651:	8b 40 04             	mov    0x4(%eax),%eax
c0104654:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104657:	77 0b                	ja     c0104664 <find_vma+0x3c>
c0104659:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010465c:	8b 40 08             	mov    0x8(%eax),%eax
c010465f:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104662:	77 61                	ja     c01046c5 <find_vma+0x9d>
                bool found = 0;
c0104664:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
                list_entry_t *list = &(mm->mmap_list), *le = list;
c010466b:	8b 45 08             	mov    0x8(%ebp),%eax
c010466e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104671:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104674:	89 45 f4             	mov    %eax,-0xc(%ebp)
                while ((le = list_next(le)) != list) {
c0104677:	eb 28                	jmp    c01046a1 <find_vma+0x79>
                    vma = le2vma(le, list_link);
c0104679:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010467c:	83 e8 10             	sub    $0x10,%eax
c010467f:	89 45 fc             	mov    %eax,-0x4(%ebp)
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
c0104682:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104685:	8b 40 04             	mov    0x4(%eax),%eax
c0104688:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010468b:	77 14                	ja     c01046a1 <find_vma+0x79>
c010468d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104690:	8b 40 08             	mov    0x8(%eax),%eax
c0104693:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104696:	76 09                	jbe    c01046a1 <find_vma+0x79>
                        found = 1;
c0104698:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%ebp)
                        break;
c010469f:	eb 17                	jmp    c01046b8 <find_vma+0x90>
c01046a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01046a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01046aa:	8b 40 04             	mov    0x4(%eax),%eax
    if (mm != NULL) {
        vma = mm->mmap_cache;
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
                bool found = 0;
                list_entry_t *list = &(mm->mmap_list), *le = list;
                while ((le = list_next(le)) != list) {
c01046ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01046b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046b3:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01046b6:	75 c1                	jne    c0104679 <find_vma+0x51>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
                        found = 1;
                        break;
                    }
                }
                if (!found) {
c01046b8:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
c01046bc:	75 07                	jne    c01046c5 <find_vma+0x9d>
                    vma = NULL;
c01046be:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
                }
        }
        if (vma != NULL) {
c01046c5:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01046c9:	74 09                	je     c01046d4 <find_vma+0xac>
            mm->mmap_cache = vma;
c01046cb:	8b 45 08             	mov    0x8(%ebp),%eax
c01046ce:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01046d1:	89 50 08             	mov    %edx,0x8(%eax)
        }
    }
    return vma;
c01046d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01046d7:	c9                   	leave  
c01046d8:	c3                   	ret    

c01046d9 <check_vma_overlap>:


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
c01046d9:	55                   	push   %ebp
c01046da:	89 e5                	mov    %esp,%ebp
c01046dc:	83 ec 08             	sub    $0x8,%esp
    assert(prev->vm_start < prev->vm_end);
c01046df:	8b 45 08             	mov    0x8(%ebp),%eax
c01046e2:	8b 50 04             	mov    0x4(%eax),%edx
c01046e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01046e8:	8b 40 08             	mov    0x8(%eax),%eax
c01046eb:	39 c2                	cmp    %eax,%edx
c01046ed:	72 16                	jb     c0104705 <check_vma_overlap+0x2c>
c01046ef:	68 fd b4 10 c0       	push   $0xc010b4fd
c01046f4:	68 1b b5 10 c0       	push   $0xc010b51b
c01046f9:	6a 68                	push   $0x68
c01046fb:	68 30 b5 10 c0       	push   $0xc010b530
c0104700:	e8 57 d0 ff ff       	call   c010175c <__panic>
    assert(prev->vm_end <= next->vm_start);
c0104705:	8b 45 08             	mov    0x8(%ebp),%eax
c0104708:	8b 50 08             	mov    0x8(%eax),%edx
c010470b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010470e:	8b 40 04             	mov    0x4(%eax),%eax
c0104711:	39 c2                	cmp    %eax,%edx
c0104713:	76 16                	jbe    c010472b <check_vma_overlap+0x52>
c0104715:	68 40 b5 10 c0       	push   $0xc010b540
c010471a:	68 1b b5 10 c0       	push   $0xc010b51b
c010471f:	6a 69                	push   $0x69
c0104721:	68 30 b5 10 c0       	push   $0xc010b530
c0104726:	e8 31 d0 ff ff       	call   c010175c <__panic>
    assert(next->vm_start < next->vm_end);
c010472b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010472e:	8b 50 04             	mov    0x4(%eax),%edx
c0104731:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104734:	8b 40 08             	mov    0x8(%eax),%eax
c0104737:	39 c2                	cmp    %eax,%edx
c0104739:	72 16                	jb     c0104751 <check_vma_overlap+0x78>
c010473b:	68 5f b5 10 c0       	push   $0xc010b55f
c0104740:	68 1b b5 10 c0       	push   $0xc010b51b
c0104745:	6a 6a                	push   $0x6a
c0104747:	68 30 b5 10 c0       	push   $0xc010b530
c010474c:	e8 0b d0 ff ff       	call   c010175c <__panic>
}
c0104751:	90                   	nop
c0104752:	c9                   	leave  
c0104753:	c3                   	ret    

c0104754 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
c0104754:	55                   	push   %ebp
c0104755:	89 e5                	mov    %esp,%ebp
c0104757:	83 ec 38             	sub    $0x38,%esp
    assert(vma->vm_start < vma->vm_end);
c010475a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010475d:	8b 50 04             	mov    0x4(%eax),%edx
c0104760:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104763:	8b 40 08             	mov    0x8(%eax),%eax
c0104766:	39 c2                	cmp    %eax,%edx
c0104768:	72 16                	jb     c0104780 <insert_vma_struct+0x2c>
c010476a:	68 7d b5 10 c0       	push   $0xc010b57d
c010476f:	68 1b b5 10 c0       	push   $0xc010b51b
c0104774:	6a 71                	push   $0x71
c0104776:	68 30 b5 10 c0       	push   $0xc010b530
c010477b:	e8 dc cf ff ff       	call   c010175c <__panic>
    list_entry_t *list = &(mm->mmap_list);
c0104780:	8b 45 08             	mov    0x8(%ebp),%eax
c0104783:	89 45 ec             	mov    %eax,-0x14(%ebp)
    list_entry_t *le_prev = list, *le_next;
c0104786:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104789:	89 45 f4             	mov    %eax,-0xc(%ebp)

        list_entry_t *le = list;
c010478c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010478f:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while ((le = list_next(le)) != list) {
c0104792:	eb 1f                	jmp    c01047b3 <insert_vma_struct+0x5f>
            struct vma_struct *mmap_prev = le2vma(le, list_link);
c0104794:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104797:	83 e8 10             	sub    $0x10,%eax
c010479a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            if (mmap_prev->vm_start > vma->vm_start) {
c010479d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01047a0:	8b 50 04             	mov    0x4(%eax),%edx
c01047a3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01047a6:	8b 40 04             	mov    0x4(%eax),%eax
c01047a9:	39 c2                	cmp    %eax,%edx
c01047ab:	77 1f                	ja     c01047cc <insert_vma_struct+0x78>
                break;
            }
            le_prev = le;
c01047ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01047b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01047b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01047b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01047b9:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01047bc:	8b 40 04             	mov    0x4(%eax),%eax
    assert(vma->vm_start < vma->vm_end);
    list_entry_t *list = &(mm->mmap_list);
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
c01047bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01047c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01047c5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01047c8:	75 ca                	jne    c0104794 <insert_vma_struct+0x40>
c01047ca:	eb 01                	jmp    c01047cd <insert_vma_struct+0x79>
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
                break;
c01047cc:	90                   	nop
c01047cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047d0:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01047d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01047d6:	8b 40 04             	mov    0x4(%eax),%eax
            }
            le_prev = le;
        }

    le_next = list_next(le_prev);
c01047d9:	89 45 dc             	mov    %eax,-0x24(%ebp)

    /* check overlap */
    if (le_prev != list) {
c01047dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047df:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01047e2:	74 15                	je     c01047f9 <insert_vma_struct+0xa5>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
c01047e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047e7:	83 e8 10             	sub    $0x10,%eax
c01047ea:	83 ec 08             	sub    $0x8,%esp
c01047ed:	ff 75 0c             	pushl  0xc(%ebp)
c01047f0:	50                   	push   %eax
c01047f1:	e8 e3 fe ff ff       	call   c01046d9 <check_vma_overlap>
c01047f6:	83 c4 10             	add    $0x10,%esp
    }
    if (le_next != list) {
c01047f9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01047fc:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01047ff:	74 15                	je     c0104816 <insert_vma_struct+0xc2>
        check_vma_overlap(vma, le2vma(le_next, list_link));
c0104801:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104804:	83 e8 10             	sub    $0x10,%eax
c0104807:	83 ec 08             	sub    $0x8,%esp
c010480a:	50                   	push   %eax
c010480b:	ff 75 0c             	pushl  0xc(%ebp)
c010480e:	e8 c6 fe ff ff       	call   c01046d9 <check_vma_overlap>
c0104813:	83 c4 10             	add    $0x10,%esp
    }

    vma->vm_mm = mm;
c0104816:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104819:	8b 55 08             	mov    0x8(%ebp),%edx
c010481c:	89 10                	mov    %edx,(%eax)
    list_add_after(le_prev, &(vma->list_link));
c010481e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104821:	8d 50 10             	lea    0x10(%eax),%edx
c0104824:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104827:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010482a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c010482d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104830:	8b 40 04             	mov    0x4(%eax),%eax
c0104833:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104836:	89 55 d0             	mov    %edx,-0x30(%ebp)
c0104839:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010483c:	89 55 cc             	mov    %edx,-0x34(%ebp)
c010483f:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0104842:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104845:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104848:	89 10                	mov    %edx,(%eax)
c010484a:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010484d:	8b 10                	mov    (%eax),%edx
c010484f:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104852:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0104855:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104858:	8b 55 c8             	mov    -0x38(%ebp),%edx
c010485b:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010485e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104861:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0104864:	89 10                	mov    %edx,(%eax)

    mm->map_count ++;
c0104866:	8b 45 08             	mov    0x8(%ebp),%eax
c0104869:	8b 40 10             	mov    0x10(%eax),%eax
c010486c:	8d 50 01             	lea    0x1(%eax),%edx
c010486f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104872:	89 50 10             	mov    %edx,0x10(%eax)
}
c0104875:	90                   	nop
c0104876:	c9                   	leave  
c0104877:	c3                   	ret    

c0104878 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
c0104878:	55                   	push   %ebp
c0104879:	89 e5                	mov    %esp,%ebp
c010487b:	83 ec 28             	sub    $0x28,%esp

    list_entry_t *list = &(mm->mmap_list), *le;
c010487e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104881:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(list)) != list) {
c0104884:	eb 3a                	jmp    c01048c0 <mm_destroy+0x48>
c0104886:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104889:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c010488c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010488f:	8b 40 04             	mov    0x4(%eax),%eax
c0104892:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0104895:	8b 12                	mov    (%edx),%edx
c0104897:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010489a:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c010489d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01048a0:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01048a3:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01048a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01048a9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01048ac:	89 10                	mov    %edx,(%eax)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
c01048ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01048b1:	83 e8 10             	sub    $0x10,%eax
c01048b4:	83 ec 0c             	sub    $0xc,%esp
c01048b7:	50                   	push   %eax
c01048b8:	e8 48 19 00 00       	call   c0106205 <kfree>
c01048bd:	83 c4 10             	add    $0x10,%esp
c01048c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01048c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01048c9:	8b 40 04             	mov    0x4(%eax),%eax
// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
c01048cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01048cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01048d2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01048d5:	75 af                	jne    c0104886 <mm_destroy+0xe>
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
    }
    kfree(mm); //kfree mm
c01048d7:	83 ec 0c             	sub    $0xc,%esp
c01048da:	ff 75 08             	pushl  0x8(%ebp)
c01048dd:	e8 23 19 00 00       	call   c0106205 <kfree>
c01048e2:	83 c4 10             	add    $0x10,%esp
    mm=NULL;
c01048e5:	c7 45 08 00 00 00 00 	movl   $0x0,0x8(%ebp)
}
c01048ec:	90                   	nop
c01048ed:	c9                   	leave  
c01048ee:	c3                   	ret    

c01048ef <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
c01048ef:	55                   	push   %ebp
c01048f0:	89 e5                	mov    %esp,%ebp
c01048f2:	83 ec 08             	sub    $0x8,%esp
    check_vmm();
c01048f5:	e8 03 00 00 00       	call   c01048fd <check_vmm>
}
c01048fa:	90                   	nop
c01048fb:	c9                   	leave  
c01048fc:	c3                   	ret    

c01048fd <check_vmm>:

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
c01048fd:	55                   	push   %ebp
c01048fe:	89 e5                	mov    %esp,%ebp
c0104900:	83 ec 18             	sub    $0x18,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0104903:	e8 3e 33 00 00       	call   c0107c46 <nr_free_pages>
c0104908:	89 45 f4             	mov    %eax,-0xc(%ebp)
    
    check_vma_struct();
c010490b:	e8 18 00 00 00       	call   c0104928 <check_vma_struct>
    check_pgfault();
c0104910:	e8 10 04 00 00       	call   c0104d25 <check_pgfault>

    cprintf("check_vmm() succeeded.\n");
c0104915:	83 ec 0c             	sub    $0xc,%esp
c0104918:	68 99 b5 10 c0       	push   $0xc010b599
c010491d:	e8 5c b9 ff ff       	call   c010027e <cprintf>
c0104922:	83 c4 10             	add    $0x10,%esp
}
c0104925:	90                   	nop
c0104926:	c9                   	leave  
c0104927:	c3                   	ret    

c0104928 <check_vma_struct>:

static void
check_vma_struct(void) {
c0104928:	55                   	push   %ebp
c0104929:	89 e5                	mov    %esp,%ebp
c010492b:	83 ec 58             	sub    $0x58,%esp
    size_t nr_free_pages_store = nr_free_pages();
c010492e:	e8 13 33 00 00       	call   c0107c46 <nr_free_pages>
c0104933:	89 45 ec             	mov    %eax,-0x14(%ebp)

    struct mm_struct *mm = mm_create();
c0104936:	e8 35 fc ff ff       	call   c0104570 <mm_create>
c010493b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(mm != NULL);
c010493e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104942:	75 19                	jne    c010495d <check_vma_struct+0x35>
c0104944:	68 b1 b5 10 c0       	push   $0xc010b5b1
c0104949:	68 1b b5 10 c0       	push   $0xc010b51b
c010494e:	68 b2 00 00 00       	push   $0xb2
c0104953:	68 30 b5 10 c0       	push   $0xc010b530
c0104958:	e8 ff cd ff ff       	call   c010175c <__panic>

    int step1 = 10, step2 = step1 * 10;
c010495d:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
c0104964:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104967:	89 d0                	mov    %edx,%eax
c0104969:	c1 e0 02             	shl    $0x2,%eax
c010496c:	01 d0                	add    %edx,%eax
c010496e:	01 c0                	add    %eax,%eax
c0104970:	89 45 e0             	mov    %eax,-0x20(%ebp)

    int i;
    for (i = step1; i >= 1; i --) {
c0104973:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104976:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104979:	eb 5f                	jmp    c01049da <check_vma_struct+0xb2>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c010497b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010497e:	89 d0                	mov    %edx,%eax
c0104980:	c1 e0 02             	shl    $0x2,%eax
c0104983:	01 d0                	add    %edx,%eax
c0104985:	83 c0 02             	add    $0x2,%eax
c0104988:	89 c1                	mov    %eax,%ecx
c010498a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010498d:	89 d0                	mov    %edx,%eax
c010498f:	c1 e0 02             	shl    $0x2,%eax
c0104992:	01 d0                	add    %edx,%eax
c0104994:	83 ec 04             	sub    $0x4,%esp
c0104997:	6a 00                	push   $0x0
c0104999:	51                   	push   %ecx
c010499a:	50                   	push   %eax
c010499b:	e8 4c fc ff ff       	call   c01045ec <vma_create>
c01049a0:	83 c4 10             	add    $0x10,%esp
c01049a3:	89 45 dc             	mov    %eax,-0x24(%ebp)
        assert(vma != NULL);
c01049a6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01049aa:	75 19                	jne    c01049c5 <check_vma_struct+0x9d>
c01049ac:	68 bc b5 10 c0       	push   $0xc010b5bc
c01049b1:	68 1b b5 10 c0       	push   $0xc010b51b
c01049b6:	68 b9 00 00 00       	push   $0xb9
c01049bb:	68 30 b5 10 c0       	push   $0xc010b530
c01049c0:	e8 97 cd ff ff       	call   c010175c <__panic>
        insert_vma_struct(mm, vma);
c01049c5:	83 ec 08             	sub    $0x8,%esp
c01049c8:	ff 75 dc             	pushl  -0x24(%ebp)
c01049cb:	ff 75 e8             	pushl  -0x18(%ebp)
c01049ce:	e8 81 fd ff ff       	call   c0104754 <insert_vma_struct>
c01049d3:	83 c4 10             	add    $0x10,%esp
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
c01049d6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01049da:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01049de:	7f 9b                	jg     c010497b <check_vma_struct+0x53>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    for (i = step1 + 1; i <= step2; i ++) {
c01049e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01049e3:	83 c0 01             	add    $0x1,%eax
c01049e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01049e9:	eb 5f                	jmp    c0104a4a <check_vma_struct+0x122>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c01049eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01049ee:	89 d0                	mov    %edx,%eax
c01049f0:	c1 e0 02             	shl    $0x2,%eax
c01049f3:	01 d0                	add    %edx,%eax
c01049f5:	83 c0 02             	add    $0x2,%eax
c01049f8:	89 c1                	mov    %eax,%ecx
c01049fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01049fd:	89 d0                	mov    %edx,%eax
c01049ff:	c1 e0 02             	shl    $0x2,%eax
c0104a02:	01 d0                	add    %edx,%eax
c0104a04:	83 ec 04             	sub    $0x4,%esp
c0104a07:	6a 00                	push   $0x0
c0104a09:	51                   	push   %ecx
c0104a0a:	50                   	push   %eax
c0104a0b:	e8 dc fb ff ff       	call   c01045ec <vma_create>
c0104a10:	83 c4 10             	add    $0x10,%esp
c0104a13:	89 45 d8             	mov    %eax,-0x28(%ebp)
        assert(vma != NULL);
c0104a16:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0104a1a:	75 19                	jne    c0104a35 <check_vma_struct+0x10d>
c0104a1c:	68 bc b5 10 c0       	push   $0xc010b5bc
c0104a21:	68 1b b5 10 c0       	push   $0xc010b51b
c0104a26:	68 bf 00 00 00       	push   $0xbf
c0104a2b:	68 30 b5 10 c0       	push   $0xc010b530
c0104a30:	e8 27 cd ff ff       	call   c010175c <__panic>
        insert_vma_struct(mm, vma);
c0104a35:	83 ec 08             	sub    $0x8,%esp
c0104a38:	ff 75 d8             	pushl  -0x28(%ebp)
c0104a3b:	ff 75 e8             	pushl  -0x18(%ebp)
c0104a3e:	e8 11 fd ff ff       	call   c0104754 <insert_vma_struct>
c0104a43:	83 c4 10             	add    $0x10,%esp
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    for (i = step1 + 1; i <= step2; i ++) {
c0104a46:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0104a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a4d:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0104a50:	7e 99                	jle    c01049eb <check_vma_struct+0xc3>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    list_entry_t *le = list_next(&(mm->mmap_list));
c0104a52:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104a55:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c0104a58:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104a5b:	8b 40 04             	mov    0x4(%eax),%eax
c0104a5e:	89 45 f0             	mov    %eax,-0x10(%ebp)

    for (i = 1; i <= step2; i ++) {
c0104a61:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
c0104a68:	e9 81 00 00 00       	jmp    c0104aee <check_vma_struct+0x1c6>
        assert(le != &(mm->mmap_list));
c0104a6d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104a70:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104a73:	75 19                	jne    c0104a8e <check_vma_struct+0x166>
c0104a75:	68 c8 b5 10 c0       	push   $0xc010b5c8
c0104a7a:	68 1b b5 10 c0       	push   $0xc010b51b
c0104a7f:	68 c6 00 00 00       	push   $0xc6
c0104a84:	68 30 b5 10 c0       	push   $0xc010b530
c0104a89:	e8 ce cc ff ff       	call   c010175c <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
c0104a8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a91:	83 e8 10             	sub    $0x10,%eax
c0104a94:	89 45 d0             	mov    %eax,-0x30(%ebp)
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
c0104a97:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104a9a:	8b 48 04             	mov    0x4(%eax),%ecx
c0104a9d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104aa0:	89 d0                	mov    %edx,%eax
c0104aa2:	c1 e0 02             	shl    $0x2,%eax
c0104aa5:	01 d0                	add    %edx,%eax
c0104aa7:	39 c1                	cmp    %eax,%ecx
c0104aa9:	75 17                	jne    c0104ac2 <check_vma_struct+0x19a>
c0104aab:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104aae:	8b 48 08             	mov    0x8(%eax),%ecx
c0104ab1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104ab4:	89 d0                	mov    %edx,%eax
c0104ab6:	c1 e0 02             	shl    $0x2,%eax
c0104ab9:	01 d0                	add    %edx,%eax
c0104abb:	83 c0 02             	add    $0x2,%eax
c0104abe:	39 c1                	cmp    %eax,%ecx
c0104ac0:	74 19                	je     c0104adb <check_vma_struct+0x1b3>
c0104ac2:	68 e0 b5 10 c0       	push   $0xc010b5e0
c0104ac7:	68 1b b5 10 c0       	push   $0xc010b51b
c0104acc:	68 c8 00 00 00       	push   $0xc8
c0104ad1:	68 30 b5 10 c0       	push   $0xc010b530
c0104ad6:	e8 81 cc ff ff       	call   c010175c <__panic>
c0104adb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ade:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0104ae1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104ae4:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0104ae7:	89 45 f0             	mov    %eax,-0x10(%ebp)
        insert_vma_struct(mm, vma);
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
c0104aea:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0104aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104af1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0104af4:	0f 8e 73 ff ff ff    	jle    c0104a6d <check_vma_struct+0x145>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c0104afa:	c7 45 f4 05 00 00 00 	movl   $0x5,-0xc(%ebp)
c0104b01:	e9 80 01 00 00       	jmp    c0104c86 <check_vma_struct+0x35e>
        struct vma_struct *vma1 = find_vma(mm, i);
c0104b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b09:	83 ec 08             	sub    $0x8,%esp
c0104b0c:	50                   	push   %eax
c0104b0d:	ff 75 e8             	pushl  -0x18(%ebp)
c0104b10:	e8 13 fb ff ff       	call   c0104628 <find_vma>
c0104b15:	83 c4 10             	add    $0x10,%esp
c0104b18:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(vma1 != NULL);
c0104b1b:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0104b1f:	75 19                	jne    c0104b3a <check_vma_struct+0x212>
c0104b21:	68 15 b6 10 c0       	push   $0xc010b615
c0104b26:	68 1b b5 10 c0       	push   $0xc010b51b
c0104b2b:	68 ce 00 00 00       	push   $0xce
c0104b30:	68 30 b5 10 c0       	push   $0xc010b530
c0104b35:	e8 22 cc ff ff       	call   c010175c <__panic>
        struct vma_struct *vma2 = find_vma(mm, i+1);
c0104b3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b3d:	83 c0 01             	add    $0x1,%eax
c0104b40:	83 ec 08             	sub    $0x8,%esp
c0104b43:	50                   	push   %eax
c0104b44:	ff 75 e8             	pushl  -0x18(%ebp)
c0104b47:	e8 dc fa ff ff       	call   c0104628 <find_vma>
c0104b4c:	83 c4 10             	add    $0x10,%esp
c0104b4f:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(vma2 != NULL);
c0104b52:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0104b56:	75 19                	jne    c0104b71 <check_vma_struct+0x249>
c0104b58:	68 22 b6 10 c0       	push   $0xc010b622
c0104b5d:	68 1b b5 10 c0       	push   $0xc010b51b
c0104b62:	68 d0 00 00 00       	push   $0xd0
c0104b67:	68 30 b5 10 c0       	push   $0xc010b530
c0104b6c:	e8 eb cb ff ff       	call   c010175c <__panic>
        struct vma_struct *vma3 = find_vma(mm, i+2);
c0104b71:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b74:	83 c0 02             	add    $0x2,%eax
c0104b77:	83 ec 08             	sub    $0x8,%esp
c0104b7a:	50                   	push   %eax
c0104b7b:	ff 75 e8             	pushl  -0x18(%ebp)
c0104b7e:	e8 a5 fa ff ff       	call   c0104628 <find_vma>
c0104b83:	83 c4 10             	add    $0x10,%esp
c0104b86:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        assert(vma3 == NULL);
c0104b89:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
c0104b8d:	74 19                	je     c0104ba8 <check_vma_struct+0x280>
c0104b8f:	68 2f b6 10 c0       	push   $0xc010b62f
c0104b94:	68 1b b5 10 c0       	push   $0xc010b51b
c0104b99:	68 d2 00 00 00       	push   $0xd2
c0104b9e:	68 30 b5 10 c0       	push   $0xc010b530
c0104ba3:	e8 b4 cb ff ff       	call   c010175c <__panic>
        struct vma_struct *vma4 = find_vma(mm, i+3);
c0104ba8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bab:	83 c0 03             	add    $0x3,%eax
c0104bae:	83 ec 08             	sub    $0x8,%esp
c0104bb1:	50                   	push   %eax
c0104bb2:	ff 75 e8             	pushl  -0x18(%ebp)
c0104bb5:	e8 6e fa ff ff       	call   c0104628 <find_vma>
c0104bba:	83 c4 10             	add    $0x10,%esp
c0104bbd:	89 45 c0             	mov    %eax,-0x40(%ebp)
        assert(vma4 == NULL);
c0104bc0:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c0104bc4:	74 19                	je     c0104bdf <check_vma_struct+0x2b7>
c0104bc6:	68 3c b6 10 c0       	push   $0xc010b63c
c0104bcb:	68 1b b5 10 c0       	push   $0xc010b51b
c0104bd0:	68 d4 00 00 00       	push   $0xd4
c0104bd5:	68 30 b5 10 c0       	push   $0xc010b530
c0104bda:	e8 7d cb ff ff       	call   c010175c <__panic>
        struct vma_struct *vma5 = find_vma(mm, i+4);
c0104bdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104be2:	83 c0 04             	add    $0x4,%eax
c0104be5:	83 ec 08             	sub    $0x8,%esp
c0104be8:	50                   	push   %eax
c0104be9:	ff 75 e8             	pushl  -0x18(%ebp)
c0104bec:	e8 37 fa ff ff       	call   c0104628 <find_vma>
c0104bf1:	83 c4 10             	add    $0x10,%esp
c0104bf4:	89 45 bc             	mov    %eax,-0x44(%ebp)
        assert(vma5 == NULL);
c0104bf7:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0104bfb:	74 19                	je     c0104c16 <check_vma_struct+0x2ee>
c0104bfd:	68 49 b6 10 c0       	push   $0xc010b649
c0104c02:	68 1b b5 10 c0       	push   $0xc010b51b
c0104c07:	68 d6 00 00 00       	push   $0xd6
c0104c0c:	68 30 b5 10 c0       	push   $0xc010b530
c0104c11:	e8 46 cb ff ff       	call   c010175c <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
c0104c16:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104c19:	8b 50 04             	mov    0x4(%eax),%edx
c0104c1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c1f:	39 c2                	cmp    %eax,%edx
c0104c21:	75 10                	jne    c0104c33 <check_vma_struct+0x30b>
c0104c23:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104c26:	8b 40 08             	mov    0x8(%eax),%eax
c0104c29:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104c2c:	83 c2 02             	add    $0x2,%edx
c0104c2f:	39 d0                	cmp    %edx,%eax
c0104c31:	74 19                	je     c0104c4c <check_vma_struct+0x324>
c0104c33:	68 58 b6 10 c0       	push   $0xc010b658
c0104c38:	68 1b b5 10 c0       	push   $0xc010b51b
c0104c3d:	68 d8 00 00 00       	push   $0xd8
c0104c42:	68 30 b5 10 c0       	push   $0xc010b530
c0104c47:	e8 10 cb ff ff       	call   c010175c <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
c0104c4c:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104c4f:	8b 50 04             	mov    0x4(%eax),%edx
c0104c52:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c55:	39 c2                	cmp    %eax,%edx
c0104c57:	75 10                	jne    c0104c69 <check_vma_struct+0x341>
c0104c59:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104c5c:	8b 40 08             	mov    0x8(%eax),%eax
c0104c5f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104c62:	83 c2 02             	add    $0x2,%edx
c0104c65:	39 d0                	cmp    %edx,%eax
c0104c67:	74 19                	je     c0104c82 <check_vma_struct+0x35a>
c0104c69:	68 88 b6 10 c0       	push   $0xc010b688
c0104c6e:	68 1b b5 10 c0       	push   $0xc010b51b
c0104c73:	68 d9 00 00 00       	push   $0xd9
c0104c78:	68 30 b5 10 c0       	push   $0xc010b530
c0104c7d:	e8 da ca ff ff       	call   c010175c <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c0104c82:	83 45 f4 05          	addl   $0x5,-0xc(%ebp)
c0104c86:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104c89:	89 d0                	mov    %edx,%eax
c0104c8b:	c1 e0 02             	shl    $0x2,%eax
c0104c8e:	01 d0                	add    %edx,%eax
c0104c90:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104c93:	0f 8d 6d fe ff ff    	jge    c0104b06 <check_vma_struct+0x1de>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
    }

    for (i =4; i>=0; i--) {
c0104c99:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%ebp)
c0104ca0:	eb 5c                	jmp    c0104cfe <check_vma_struct+0x3d6>
        struct vma_struct *vma_below_5= find_vma(mm,i);
c0104ca2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ca5:	83 ec 08             	sub    $0x8,%esp
c0104ca8:	50                   	push   %eax
c0104ca9:	ff 75 e8             	pushl  -0x18(%ebp)
c0104cac:	e8 77 f9 ff ff       	call   c0104628 <find_vma>
c0104cb1:	83 c4 10             	add    $0x10,%esp
c0104cb4:	89 45 b8             	mov    %eax,-0x48(%ebp)
        if (vma_below_5 != NULL ) {
c0104cb7:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0104cbb:	74 1e                	je     c0104cdb <check_vma_struct+0x3b3>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
c0104cbd:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0104cc0:	8b 50 08             	mov    0x8(%eax),%edx
c0104cc3:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0104cc6:	8b 40 04             	mov    0x4(%eax),%eax
c0104cc9:	52                   	push   %edx
c0104cca:	50                   	push   %eax
c0104ccb:	ff 75 f4             	pushl  -0xc(%ebp)
c0104cce:	68 b8 b6 10 c0       	push   $0xc010b6b8
c0104cd3:	e8 a6 b5 ff ff       	call   c010027e <cprintf>
c0104cd8:	83 c4 10             	add    $0x10,%esp
        }
        assert(vma_below_5 == NULL);
c0104cdb:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0104cdf:	74 19                	je     c0104cfa <check_vma_struct+0x3d2>
c0104ce1:	68 dd b6 10 c0       	push   $0xc010b6dd
c0104ce6:	68 1b b5 10 c0       	push   $0xc010b51b
c0104ceb:	68 e1 00 00 00       	push   $0xe1
c0104cf0:	68 30 b5 10 c0       	push   $0xc010b530
c0104cf5:	e8 62 ca ff ff       	call   c010175c <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
    }

    for (i =4; i>=0; i--) {
c0104cfa:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0104cfe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104d02:	79 9e                	jns    c0104ca2 <check_vma_struct+0x37a>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
        }
        assert(vma_below_5 == NULL);
    }

    mm_destroy(mm);
c0104d04:	83 ec 0c             	sub    $0xc,%esp
c0104d07:	ff 75 e8             	pushl  -0x18(%ebp)
c0104d0a:	e8 69 fb ff ff       	call   c0104878 <mm_destroy>
c0104d0f:	83 c4 10             	add    $0x10,%esp

    cprintf("check_vma_struct() succeeded!\n");
c0104d12:	83 ec 0c             	sub    $0xc,%esp
c0104d15:	68 f4 b6 10 c0       	push   $0xc010b6f4
c0104d1a:	e8 5f b5 ff ff       	call   c010027e <cprintf>
c0104d1f:	83 c4 10             	add    $0x10,%esp
}
c0104d22:	90                   	nop
c0104d23:	c9                   	leave  
c0104d24:	c3                   	ret    

c0104d25 <check_pgfault>:

struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
c0104d25:	55                   	push   %ebp
c0104d26:	89 e5                	mov    %esp,%ebp
c0104d28:	83 ec 28             	sub    $0x28,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0104d2b:	e8 16 2f 00 00       	call   c0107c46 <nr_free_pages>
c0104d30:	89 45 ec             	mov    %eax,-0x14(%ebp)

    check_mm_struct = mm_create();
c0104d33:	e8 38 f8 ff ff       	call   c0104570 <mm_create>
c0104d38:	a3 f8 aa 12 c0       	mov    %eax,0xc012aaf8
    assert(check_mm_struct != NULL);
c0104d3d:	a1 f8 aa 12 c0       	mov    0xc012aaf8,%eax
c0104d42:	85 c0                	test   %eax,%eax
c0104d44:	75 19                	jne    c0104d5f <check_pgfault+0x3a>
c0104d46:	68 13 b7 10 c0       	push   $0xc010b713
c0104d4b:	68 1b b5 10 c0       	push   $0xc010b51b
c0104d50:	68 f1 00 00 00       	push   $0xf1
c0104d55:	68 30 b5 10 c0       	push   $0xc010b530
c0104d5a:	e8 fd c9 ff ff       	call   c010175c <__panic>

    struct mm_struct *mm = check_mm_struct;
c0104d5f:	a1 f8 aa 12 c0       	mov    0xc012aaf8,%eax
c0104d64:	89 45 e8             	mov    %eax,-0x18(%ebp)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
c0104d67:	8b 15 24 8a 12 c0    	mov    0xc0128a24,%edx
c0104d6d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104d70:	89 50 0c             	mov    %edx,0xc(%eax)
c0104d73:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104d76:	8b 40 0c             	mov    0xc(%eax),%eax
c0104d79:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(pgdir[0] == 0);
c0104d7c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104d7f:	8b 00                	mov    (%eax),%eax
c0104d81:	85 c0                	test   %eax,%eax
c0104d83:	74 19                	je     c0104d9e <check_pgfault+0x79>
c0104d85:	68 2b b7 10 c0       	push   $0xc010b72b
c0104d8a:	68 1b b5 10 c0       	push   $0xc010b51b
c0104d8f:	68 f5 00 00 00       	push   $0xf5
c0104d94:	68 30 b5 10 c0       	push   $0xc010b530
c0104d99:	e8 be c9 ff ff       	call   c010175c <__panic>

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
c0104d9e:	83 ec 04             	sub    $0x4,%esp
c0104da1:	6a 02                	push   $0x2
c0104da3:	68 00 00 40 00       	push   $0x400000
c0104da8:	6a 00                	push   $0x0
c0104daa:	e8 3d f8 ff ff       	call   c01045ec <vma_create>
c0104daf:	83 c4 10             	add    $0x10,%esp
c0104db2:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(vma != NULL);
c0104db5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0104db9:	75 19                	jne    c0104dd4 <check_pgfault+0xaf>
c0104dbb:	68 bc b5 10 c0       	push   $0xc010b5bc
c0104dc0:	68 1b b5 10 c0       	push   $0xc010b51b
c0104dc5:	68 f8 00 00 00       	push   $0xf8
c0104dca:	68 30 b5 10 c0       	push   $0xc010b530
c0104dcf:	e8 88 c9 ff ff       	call   c010175c <__panic>

    insert_vma_struct(mm, vma);
c0104dd4:	83 ec 08             	sub    $0x8,%esp
c0104dd7:	ff 75 e0             	pushl  -0x20(%ebp)
c0104dda:	ff 75 e8             	pushl  -0x18(%ebp)
c0104ddd:	e8 72 f9 ff ff       	call   c0104754 <insert_vma_struct>
c0104de2:	83 c4 10             	add    $0x10,%esp

    uintptr_t addr = 0x100;
c0104de5:	c7 45 dc 00 01 00 00 	movl   $0x100,-0x24(%ebp)
    assert(find_vma(mm, addr) == vma);
c0104dec:	83 ec 08             	sub    $0x8,%esp
c0104def:	ff 75 dc             	pushl  -0x24(%ebp)
c0104df2:	ff 75 e8             	pushl  -0x18(%ebp)
c0104df5:	e8 2e f8 ff ff       	call   c0104628 <find_vma>
c0104dfa:	83 c4 10             	add    $0x10,%esp
c0104dfd:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0104e00:	74 19                	je     c0104e1b <check_pgfault+0xf6>
c0104e02:	68 39 b7 10 c0       	push   $0xc010b739
c0104e07:	68 1b b5 10 c0       	push   $0xc010b51b
c0104e0c:	68 fd 00 00 00       	push   $0xfd
c0104e11:	68 30 b5 10 c0       	push   $0xc010b530
c0104e16:	e8 41 c9 ff ff       	call   c010175c <__panic>

    int i, sum = 0;
c0104e1b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0104e22:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104e29:	eb 19                	jmp    c0104e44 <check_pgfault+0x11f>
        *(char *)(addr + i) = i;
c0104e2b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104e2e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104e31:	01 d0                	add    %edx,%eax
c0104e33:	89 c2                	mov    %eax,%edx
c0104e35:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e38:	88 02                	mov    %al,(%edx)
        sum += i;
c0104e3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e3d:	01 45 f0             	add    %eax,-0x10(%ebp)

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
c0104e40:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0104e44:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0104e48:	7e e1                	jle    c0104e2b <check_pgfault+0x106>
        *(char *)(addr + i) = i;
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
c0104e4a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104e51:	eb 15                	jmp    c0104e68 <check_pgfault+0x143>
        sum -= *(char *)(addr + i);
c0104e53:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104e56:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104e59:	01 d0                	add    %edx,%eax
c0104e5b:	0f b6 00             	movzbl (%eax),%eax
c0104e5e:	0f be c0             	movsbl %al,%eax
c0104e61:	29 45 f0             	sub    %eax,-0x10(%ebp)
    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
        *(char *)(addr + i) = i;
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
c0104e64:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0104e68:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0104e6c:	7e e5                	jle    c0104e53 <check_pgfault+0x12e>
        sum -= *(char *)(addr + i);
    }
    assert(sum == 0);
c0104e6e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104e72:	74 19                	je     c0104e8d <check_pgfault+0x168>
c0104e74:	68 53 b7 10 c0       	push   $0xc010b753
c0104e79:	68 1b b5 10 c0       	push   $0xc010b51b
c0104e7e:	68 07 01 00 00       	push   $0x107
c0104e83:	68 30 b5 10 c0       	push   $0xc010b530
c0104e88:	e8 cf c8 ff ff       	call   c010175c <__panic>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
c0104e8d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104e90:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0104e93:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104e96:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104e9b:	83 ec 08             	sub    $0x8,%esp
c0104e9e:	50                   	push   %eax
c0104e9f:	ff 75 e4             	pushl  -0x1c(%ebp)
c0104ea2:	e8 d1 35 00 00       	call   c0108478 <page_remove>
c0104ea7:	83 c4 10             	add    $0x10,%esp
    free_page(pde2page(pgdir[0]));
c0104eaa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104ead:	8b 00                	mov    (%eax),%eax
c0104eaf:	83 ec 0c             	sub    $0xc,%esp
c0104eb2:	50                   	push   %eax
c0104eb3:	e8 9c f6 ff ff       	call   c0104554 <pde2page>
c0104eb8:	83 c4 10             	add    $0x10,%esp
c0104ebb:	83 ec 08             	sub    $0x8,%esp
c0104ebe:	6a 01                	push   $0x1
c0104ec0:	50                   	push   %eax
c0104ec1:	e8 4b 2d 00 00       	call   c0107c11 <free_pages>
c0104ec6:	83 c4 10             	add    $0x10,%esp
    pgdir[0] = 0;
c0104ec9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104ecc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    mm->pgdir = NULL;
c0104ed2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104ed5:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    mm_destroy(mm);
c0104edc:	83 ec 0c             	sub    $0xc,%esp
c0104edf:	ff 75 e8             	pushl  -0x18(%ebp)
c0104ee2:	e8 91 f9 ff ff       	call   c0104878 <mm_destroy>
c0104ee7:	83 c4 10             	add    $0x10,%esp
    check_mm_struct = NULL;
c0104eea:	c7 05 f8 aa 12 c0 00 	movl   $0x0,0xc012aaf8
c0104ef1:	00 00 00 

    assert(nr_free_pages_store == nr_free_pages());
c0104ef4:	e8 4d 2d 00 00       	call   c0107c46 <nr_free_pages>
c0104ef9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0104efc:	74 19                	je     c0104f17 <check_pgfault+0x1f2>
c0104efe:	68 5c b7 10 c0       	push   $0xc010b75c
c0104f03:	68 1b b5 10 c0       	push   $0xc010b51b
c0104f08:	68 11 01 00 00       	push   $0x111
c0104f0d:	68 30 b5 10 c0       	push   $0xc010b530
c0104f12:	e8 45 c8 ff ff       	call   c010175c <__panic>

    cprintf("check_pgfault() succeeded!\n");
c0104f17:	83 ec 0c             	sub    $0xc,%esp
c0104f1a:	68 83 b7 10 c0       	push   $0xc010b783
c0104f1f:	e8 5a b3 ff ff       	call   c010027e <cprintf>
c0104f24:	83 c4 10             	add    $0x10,%esp
}
c0104f27:	90                   	nop
c0104f28:	c9                   	leave  
c0104f29:	c3                   	ret    

c0104f2a <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
c0104f2a:	55                   	push   %ebp
c0104f2b:	89 e5                	mov    %esp,%ebp
c0104f2d:	83 ec 28             	sub    $0x28,%esp
    int ret = -E_INVAL;
c0104f30:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
    struct vma_struct *vma = find_vma(mm, addr);// 查找在mm变量中的mmap_list链表中某个vma包含此addr
c0104f37:	ff 75 10             	pushl  0x10(%ebp)
c0104f3a:	ff 75 08             	pushl  0x8(%ebp)
c0104f3d:	e8 e6 f6 ff ff       	call   c0104628 <find_vma>
c0104f42:	83 c4 08             	add    $0x8,%esp
c0104f45:	89 45 ec             	mov    %eax,-0x14(%ebp)

    pgfault_num++; // 缺页次数++
c0104f48:	a1 04 8a 12 c0       	mov    0xc0128a04,%eax
c0104f4d:	83 c0 01             	add    $0x1,%eax
c0104f50:	a3 04 8a 12 c0       	mov    %eax,0xc0128a04
    //该虚地址不在某vma结构体描述的范围内,为非法访问.
    if (vma == NULL || vma->vm_start > addr) {
c0104f55:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104f59:	74 0b                	je     c0104f66 <do_pgfault+0x3c>
c0104f5b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104f5e:	8b 40 04             	mov    0x4(%eax),%eax
c0104f61:	3b 45 10             	cmp    0x10(%ebp),%eax
c0104f64:	76 18                	jbe    c0104f7e <do_pgfault+0x54>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
c0104f66:	83 ec 08             	sub    $0x8,%esp
c0104f69:	ff 75 10             	pushl  0x10(%ebp)
c0104f6c:	68 a0 b7 10 c0       	push   $0xc010b7a0
c0104f71:	e8 08 b3 ff ff       	call   c010027e <cprintf>
c0104f76:	83 c4 10             	add    $0x10,%esp
        goto failed;
c0104f79:	e9 aa 01 00 00       	jmp    c0105128 <do_pgfault+0x1fe>
    }
    //check the error_code
    switch (error_code & 3) {
c0104f7e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104f81:	83 e0 03             	and    $0x3,%eax
c0104f84:	85 c0                	test   %eax,%eax
c0104f86:	74 3c                	je     c0104fc4 <do_pgfault+0x9a>
c0104f88:	83 f8 01             	cmp    $0x1,%eax
c0104f8b:	74 22                	je     c0104faf <do_pgfault+0x85>
        default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
        case 2: /* error code flag : (W/R=1, P=0): write, not present */
            if (!(vma->vm_flags & VM_WRITE)) {
c0104f8d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104f90:	8b 40 0c             	mov    0xc(%eax),%eax
c0104f93:	83 e0 02             	and    $0x2,%eax
c0104f96:	85 c0                	test   %eax,%eax
c0104f98:	75 4c                	jne    c0104fe6 <do_pgfault+0xbc>
                // 如果vm_flags ！= 0x2，即vma地址无可写权限
                cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
c0104f9a:	83 ec 0c             	sub    $0xc,%esp
c0104f9d:	68 d0 b7 10 c0       	push   $0xc010b7d0
c0104fa2:	e8 d7 b2 ff ff       	call   c010027e <cprintf>
c0104fa7:	83 c4 10             	add    $0x10,%esp
                goto failed;
c0104faa:	e9 79 01 00 00       	jmp    c0105128 <do_pgfault+0x1fe>
            }
            break;
        case 1: /* error code flag : (W/R=0, P=1): read, present */
            // vma地址无可读权限
            cprintf("do_pgfault failed: error code flag = read AND present\n");
c0104faf:	83 ec 0c             	sub    $0xc,%esp
c0104fb2:	68 30 b8 10 c0       	push   $0xc010b830
c0104fb7:	e8 c2 b2 ff ff       	call   c010027e <cprintf>
c0104fbc:	83 c4 10             	add    $0x10,%esp
            goto failed;
c0104fbf:	e9 64 01 00 00       	jmp    c0105128 <do_pgfault+0x1fe>
        case 0: /* error code flag : (W/R=0, P=0): read, not present */
            if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
c0104fc4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104fc7:	8b 40 0c             	mov    0xc(%eax),%eax
c0104fca:	83 e0 05             	and    $0x5,%eax
c0104fcd:	85 c0                	test   %eax,%eax
c0104fcf:	75 16                	jne    c0104fe7 <do_pgfault+0xbd>
                // vma地址无可读或可执行权限
                cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
c0104fd1:	83 ec 0c             	sub    $0xc,%esp
c0104fd4:	68 68 b8 10 c0       	push   $0xc010b868
c0104fd9:	e8 a0 b2 ff ff       	call   c010027e <cprintf>
c0104fde:	83 c4 10             	add    $0x10,%esp
                goto failed;
c0104fe1:	e9 42 01 00 00       	jmp    c0105128 <do_pgfault+0x1fe>
            if (!(vma->vm_flags & VM_WRITE)) {
                // 如果vm_flags ！= 0x2，即vma地址无可写权限
                cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
                goto failed;
            }
            break;
c0104fe6:	90                   	nop
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
c0104fe7:	c7 45 f0 04 00 00 00 	movl   $0x4,-0x10(%ebp)
    if (vma->vm_flags & VM_WRITE) {
c0104fee:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104ff1:	8b 40 0c             	mov    0xc(%eax),%eax
c0104ff4:	83 e0 02             	and    $0x2,%eax
c0104ff7:	85 c0                	test   %eax,%eax
c0104ff9:	74 04                	je     c0104fff <do_pgfault+0xd5>
        perm |= PTE_W;
c0104ffb:	83 4d f0 02          	orl    $0x2,-0x10(%ebp)
    }
    addr = ROUNDDOWN(addr, PGSIZE);
c0104fff:	8b 45 10             	mov    0x10(%ebp),%eax
c0105002:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105005:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105008:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010500d:	89 45 10             	mov    %eax,0x10(%ebp)

    ret = -E_NO_MEM;
c0105010:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    pte_t *ptep=NULL;
c0105017:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    // 获取页表项，但找不到虚拟地址所对应的页表项
    if ((ptep = get_pte(mm->pgdir,addr,1)) == NULL){
c010501e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105021:	8b 40 0c             	mov    0xc(%eax),%eax
c0105024:	83 ec 04             	sub    $0x4,%esp
c0105027:	6a 01                	push   $0x1
c0105029:	ff 75 10             	pushl  0x10(%ebp)
c010502c:	50                   	push   %eax
c010502d:	e8 6e 32 00 00       	call   c01082a0 <get_pte>
c0105032:	83 c4 10             	add    $0x10,%esp
c0105035:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105038:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010503c:	75 15                	jne    c0105053 <do_pgfault+0x129>
        cprintf("get_pte in do_pgfault failed\n");
c010503e:	83 ec 0c             	sub    $0xc,%esp
c0105041:	68 cb b8 10 c0       	push   $0xc010b8cb
c0105046:	e8 33 b2 ff ff       	call   c010027e <cprintf>
c010504b:	83 c4 10             	add    $0x10,%esp
        goto failed;
c010504e:	e9 d5 00 00 00       	jmp    c0105128 <do_pgfault+0x1fe>
    }

    // 页表项为0，不存在映射关系，则要建立虚拟地址和物理地址的映射关系
    if (*ptep == 0){
c0105053:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105056:	8b 00                	mov    (%eax),%eax
c0105058:	85 c0                	test   %eax,%eax
c010505a:	75 35                	jne    c0105091 <do_pgfault+0x167>
        // 权限不够,失败
        // Present为1,但低权限访问高权限内存空间 OR 程序试图写属性只读的页
        if (pgdir_alloc_page(mm->pgdir,addr,perm) == NULL){
c010505c:	8b 45 08             	mov    0x8(%ebp),%eax
c010505f:	8b 40 0c             	mov    0xc(%eax),%eax
c0105062:	83 ec 04             	sub    $0x4,%esp
c0105065:	ff 75 f0             	pushl  -0x10(%ebp)
c0105068:	ff 75 10             	pushl  0x10(%ebp)
c010506b:	50                   	push   %eax
c010506c:	e8 49 35 00 00       	call   c01085ba <pgdir_alloc_page>
c0105071:	83 c4 10             	add    $0x10,%esp
c0105074:	85 c0                	test   %eax,%eax
c0105076:	0f 85 a5 00 00 00    	jne    c0105121 <do_pgfault+0x1f7>
            cprintf("pgdir_alloc_page in do_pgfault failed");
c010507c:	83 ec 0c             	sub    $0xc,%esp
c010507f:	68 ec b8 10 c0       	push   $0xc010b8ec
c0105084:	e8 f5 b1 ff ff       	call   c010027e <cprintf>
c0105089:	83 c4 10             	add    $0x10,%esp
            goto failed;
c010508c:	e9 97 00 00 00       	jmp    c0105128 <do_pgfault+0x1fe>
        }
    }
    else {
        // 页表项非空，尝试换入页面
        if (swap_init_ok){
c0105091:	a1 08 8a 12 c0       	mov    0xc0128a08,%eax
c0105096:	85 c0                	test   %eax,%eax
c0105098:	74 6f                	je     c0105109 <do_pgfault+0x1df>
            struct Page *page = NULL; // 根据mm结构和addr地址，尝试将硬盘中的内容换入至page中
c010509a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
            if ((ret = swap_in(mm,addr,&page)) != 0){
c01050a1:	83 ec 04             	sub    $0x4,%esp
c01050a4:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01050a7:	50                   	push   %eax
c01050a8:	ff 75 10             	pushl  0x10(%ebp)
c01050ab:	ff 75 08             	pushl  0x8(%ebp)
c01050ae:	e8 44 03 00 00       	call   c01053f7 <swap_in>
c01050b3:	83 c4 10             	add    $0x10,%esp
c01050b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01050b9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01050bd:	74 12                	je     c01050d1 <do_pgfault+0x1a7>
                cprintf("swap_in in do_pgfault failed\n");
c01050bf:	83 ec 0c             	sub    $0xc,%esp
c01050c2:	68 12 b9 10 c0       	push   $0xc010b912
c01050c7:	e8 b2 b1 ff ff       	call   c010027e <cprintf>
c01050cc:	83 c4 10             	add    $0x10,%esp
c01050cf:	eb 57                	jmp    c0105128 <do_pgfault+0x1fe>
                goto failed;
            }
            page_insert(mm->pgdir,page,addr,perm); //建立虚拟地址和物理地址之间的对应关系
c01050d1:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01050d4:	8b 45 08             	mov    0x8(%ebp),%eax
c01050d7:	8b 40 0c             	mov    0xc(%eax),%eax
c01050da:	ff 75 f0             	pushl  -0x10(%ebp)
c01050dd:	ff 75 10             	pushl  0x10(%ebp)
c01050e0:	52                   	push   %edx
c01050e1:	50                   	push   %eax
c01050e2:	e8 ca 33 00 00       	call   c01084b1 <page_insert>
c01050e7:	83 c4 10             	add    $0x10,%esp
            swap_map_swappable(mm,addr,page,1); //将此页面设置为可交换的
c01050ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01050ed:	6a 01                	push   $0x1
c01050ef:	50                   	push   %eax
c01050f0:	ff 75 10             	pushl  0x10(%ebp)
c01050f3:	ff 75 08             	pushl  0x8(%ebp)
c01050f6:	e8 6c 01 00 00       	call   c0105267 <swap_map_swappable>
c01050fb:	83 c4 10             	add    $0x10,%esp
            page->pra_vaddr = addr;
c01050fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105101:	8b 55 10             	mov    0x10(%ebp),%edx
c0105104:	89 50 20             	mov    %edx,0x20(%eax)
c0105107:	eb 18                	jmp    c0105121 <do_pgfault+0x1f7>
        }
        else{
            cprintf("no swap_init_ok but ptep is %x,failed\n",*ptep);
c0105109:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010510c:	8b 00                	mov    (%eax),%eax
c010510e:	83 ec 08             	sub    $0x8,%esp
c0105111:	50                   	push   %eax
c0105112:	68 30 b9 10 c0       	push   $0xc010b930
c0105117:	e8 62 b1 ff ff       	call   c010027e <cprintf>
c010511c:	83 c4 10             	add    $0x10,%esp
            goto failed;
c010511f:	eb 07                	jmp    c0105128 <do_pgfault+0x1fe>
        }
    }
    ret = 0;
c0105121:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    failed:
    return ret;
c0105128:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010512b:	c9                   	leave  
c010512c:	c3                   	ret    

c010512d <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c010512d:	55                   	push   %ebp
c010512e:	89 e5                	mov    %esp,%ebp
c0105130:	83 ec 08             	sub    $0x8,%esp
    if (PPN(pa) >= npage) {
c0105133:	8b 45 08             	mov    0x8(%ebp),%eax
c0105136:	c1 e8 0c             	shr    $0xc,%eax
c0105139:	89 c2                	mov    %eax,%edx
c010513b:	a1 20 8a 12 c0       	mov    0xc0128a20,%eax
c0105140:	39 c2                	cmp    %eax,%edx
c0105142:	72 14                	jb     c0105158 <pa2page+0x2b>
        panic("pa2page called with invalid pa");
c0105144:	83 ec 04             	sub    $0x4,%esp
c0105147:	68 58 b9 10 c0       	push   $0xc010b958
c010514c:	6a 5f                	push   $0x5f
c010514e:	68 77 b9 10 c0       	push   $0xc010b977
c0105153:	e8 04 c6 ff ff       	call   c010175c <__panic>
    }
    return &pages[PPN(pa)];
c0105158:	8b 0d e0 ab 12 c0    	mov    0xc012abe0,%ecx
c010515e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105161:	c1 e8 0c             	shr    $0xc,%eax
c0105164:	89 c2                	mov    %eax,%edx
c0105166:	89 d0                	mov    %edx,%eax
c0105168:	c1 e0 03             	shl    $0x3,%eax
c010516b:	01 d0                	add    %edx,%eax
c010516d:	c1 e0 02             	shl    $0x2,%eax
c0105170:	01 c8                	add    %ecx,%eax
}
c0105172:	c9                   	leave  
c0105173:	c3                   	ret    

c0105174 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c0105174:	55                   	push   %ebp
c0105175:	89 e5                	mov    %esp,%ebp
c0105177:	83 ec 08             	sub    $0x8,%esp
    if (!(pte & PTE_P)) {
c010517a:	8b 45 08             	mov    0x8(%ebp),%eax
c010517d:	83 e0 01             	and    $0x1,%eax
c0105180:	85 c0                	test   %eax,%eax
c0105182:	75 14                	jne    c0105198 <pte2page+0x24>
        panic("pte2page called with invalid pte");
c0105184:	83 ec 04             	sub    $0x4,%esp
c0105187:	68 88 b9 10 c0       	push   $0xc010b988
c010518c:	6a 71                	push   $0x71
c010518e:	68 77 b9 10 c0       	push   $0xc010b977
c0105193:	e8 c4 c5 ff ff       	call   c010175c <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0105198:	8b 45 08             	mov    0x8(%ebp),%eax
c010519b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01051a0:	83 ec 0c             	sub    $0xc,%esp
c01051a3:	50                   	push   %eax
c01051a4:	e8 84 ff ff ff       	call   c010512d <pa2page>
c01051a9:	83 c4 10             	add    $0x10,%esp
}
c01051ac:	c9                   	leave  
c01051ad:	c3                   	ret    

c01051ae <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
c01051ae:	55                   	push   %ebp
c01051af:	89 e5                	mov    %esp,%ebp
c01051b1:	83 ec 18             	sub    $0x18,%esp
     swapfs_init();
c01051b4:	e8 f2 3f 00 00       	call   c01091ab <swapfs_init>

     if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
c01051b9:	a1 9c ab 12 c0       	mov    0xc012ab9c,%eax
c01051be:	3d ff 03 00 00       	cmp    $0x3ff,%eax
c01051c3:	76 0c                	jbe    c01051d1 <swap_init+0x23>
c01051c5:	a1 9c ab 12 c0       	mov    0xc012ab9c,%eax
c01051ca:	3d ff ff ff 00       	cmp    $0xffffff,%eax
c01051cf:	76 17                	jbe    c01051e8 <swap_init+0x3a>
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
c01051d1:	a1 9c ab 12 c0       	mov    0xc012ab9c,%eax
c01051d6:	50                   	push   %eax
c01051d7:	68 a9 b9 10 c0       	push   $0xc010b9a9
c01051dc:	6a 25                	push   $0x25
c01051de:	68 c4 b9 10 c0       	push   $0xc010b9c4
c01051e3:	e8 74 c5 ff ff       	call   c010175c <__panic>
     }
     

     sm = &swap_manager_fifo;
c01051e8:	c7 05 10 8a 12 c0 20 	movl   $0xc0127a20,0xc0128a10
c01051ef:	7a 12 c0 
     int r = sm->init();
c01051f2:	a1 10 8a 12 c0       	mov    0xc0128a10,%eax
c01051f7:	8b 40 04             	mov    0x4(%eax),%eax
c01051fa:	ff d0                	call   *%eax
c01051fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
     
     if (r == 0)
c01051ff:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105203:	75 27                	jne    c010522c <swap_init+0x7e>
     {
          swap_init_ok = 1;
c0105205:	c7 05 08 8a 12 c0 01 	movl   $0x1,0xc0128a08
c010520c:	00 00 00 
          cprintf("SWAP: manager = %s\n", sm->name);
c010520f:	a1 10 8a 12 c0       	mov    0xc0128a10,%eax
c0105214:	8b 00                	mov    (%eax),%eax
c0105216:	83 ec 08             	sub    $0x8,%esp
c0105219:	50                   	push   %eax
c010521a:	68 d3 b9 10 c0       	push   $0xc010b9d3
c010521f:	e8 5a b0 ff ff       	call   c010027e <cprintf>
c0105224:	83 c4 10             	add    $0x10,%esp
          check_swap();
c0105227:	e8 f7 03 00 00       	call   c0105623 <check_swap>
     }

     return r;
c010522c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010522f:	c9                   	leave  
c0105230:	c3                   	ret    

c0105231 <swap_init_mm>:

int
swap_init_mm(struct mm_struct *mm)
{
c0105231:	55                   	push   %ebp
c0105232:	89 e5                	mov    %esp,%ebp
c0105234:	83 ec 08             	sub    $0x8,%esp
     return sm->init_mm(mm);
c0105237:	a1 10 8a 12 c0       	mov    0xc0128a10,%eax
c010523c:	8b 40 08             	mov    0x8(%eax),%eax
c010523f:	83 ec 0c             	sub    $0xc,%esp
c0105242:	ff 75 08             	pushl  0x8(%ebp)
c0105245:	ff d0                	call   *%eax
c0105247:	83 c4 10             	add    $0x10,%esp
}
c010524a:	c9                   	leave  
c010524b:	c3                   	ret    

c010524c <swap_tick_event>:

int
swap_tick_event(struct mm_struct *mm)
{
c010524c:	55                   	push   %ebp
c010524d:	89 e5                	mov    %esp,%ebp
c010524f:	83 ec 08             	sub    $0x8,%esp
     return sm->tick_event(mm);
c0105252:	a1 10 8a 12 c0       	mov    0xc0128a10,%eax
c0105257:	8b 40 0c             	mov    0xc(%eax),%eax
c010525a:	83 ec 0c             	sub    $0xc,%esp
c010525d:	ff 75 08             	pushl  0x8(%ebp)
c0105260:	ff d0                	call   *%eax
c0105262:	83 c4 10             	add    $0x10,%esp
}
c0105265:	c9                   	leave  
c0105266:	c3                   	ret    

c0105267 <swap_map_swappable>:

int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0105267:	55                   	push   %ebp
c0105268:	89 e5                	mov    %esp,%ebp
c010526a:	83 ec 08             	sub    $0x8,%esp
     return sm->map_swappable(mm, addr, page, swap_in);
c010526d:	a1 10 8a 12 c0       	mov    0xc0128a10,%eax
c0105272:	8b 40 10             	mov    0x10(%eax),%eax
c0105275:	ff 75 14             	pushl  0x14(%ebp)
c0105278:	ff 75 10             	pushl  0x10(%ebp)
c010527b:	ff 75 0c             	pushl  0xc(%ebp)
c010527e:	ff 75 08             	pushl  0x8(%ebp)
c0105281:	ff d0                	call   *%eax
c0105283:	83 c4 10             	add    $0x10,%esp
}
c0105286:	c9                   	leave  
c0105287:	c3                   	ret    

c0105288 <swap_set_unswappable>:

int
swap_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c0105288:	55                   	push   %ebp
c0105289:	89 e5                	mov    %esp,%ebp
c010528b:	83 ec 08             	sub    $0x8,%esp
     return sm->set_unswappable(mm, addr);
c010528e:	a1 10 8a 12 c0       	mov    0xc0128a10,%eax
c0105293:	8b 40 14             	mov    0x14(%eax),%eax
c0105296:	83 ec 08             	sub    $0x8,%esp
c0105299:	ff 75 0c             	pushl  0xc(%ebp)
c010529c:	ff 75 08             	pushl  0x8(%ebp)
c010529f:	ff d0                	call   *%eax
c01052a1:	83 c4 10             	add    $0x10,%esp
}
c01052a4:	c9                   	leave  
c01052a5:	c3                   	ret    

c01052a6 <swap_out>:

volatile unsigned int swap_out_num=0;

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
c01052a6:	55                   	push   %ebp
c01052a7:	89 e5                	mov    %esp,%ebp
c01052a9:	83 ec 28             	sub    $0x28,%esp
     int i;
     for (i = 0; i != n; ++ i)
c01052ac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01052b3:	e9 2e 01 00 00       	jmp    c01053e6 <swap_out+0x140>
     {
          uintptr_t v;
          //struct Page **ptr_page=NULL;
          struct Page *page;
          // cprintf("i %d, SWAP: call swap_out_victim\n",i);
          int r = sm->swap_out_victim(mm, &page, in_tick);
c01052b8:	a1 10 8a 12 c0       	mov    0xc0128a10,%eax
c01052bd:	8b 40 18             	mov    0x18(%eax),%eax
c01052c0:	83 ec 04             	sub    $0x4,%esp
c01052c3:	ff 75 10             	pushl  0x10(%ebp)
c01052c6:	8d 55 e4             	lea    -0x1c(%ebp),%edx
c01052c9:	52                   	push   %edx
c01052ca:	ff 75 08             	pushl  0x8(%ebp)
c01052cd:	ff d0                	call   *%eax
c01052cf:	83 c4 10             	add    $0x10,%esp
c01052d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
          if (r != 0) {
c01052d5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01052d9:	74 18                	je     c01052f3 <swap_out+0x4d>
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
c01052db:	83 ec 08             	sub    $0x8,%esp
c01052de:	ff 75 f4             	pushl  -0xc(%ebp)
c01052e1:	68 e8 b9 10 c0       	push   $0xc010b9e8
c01052e6:	e8 93 af ff ff       	call   c010027e <cprintf>
c01052eb:	83 c4 10             	add    $0x10,%esp
c01052ee:	e9 ff 00 00 00       	jmp    c01053f2 <swap_out+0x14c>
          }          
          //assert(!PageReserved(page));

          //cprintf("SWAP: choose victim page 0x%08x\n", page);
          
          v=page->pra_vaddr; 
c01052f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01052f6:	8b 40 20             	mov    0x20(%eax),%eax
c01052f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
c01052fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01052ff:	8b 40 0c             	mov    0xc(%eax),%eax
c0105302:	83 ec 04             	sub    $0x4,%esp
c0105305:	6a 00                	push   $0x0
c0105307:	ff 75 ec             	pushl  -0x14(%ebp)
c010530a:	50                   	push   %eax
c010530b:	e8 90 2f 00 00       	call   c01082a0 <get_pte>
c0105310:	83 c4 10             	add    $0x10,%esp
c0105313:	89 45 e8             	mov    %eax,-0x18(%ebp)
          assert((*ptep & PTE_P) != 0);
c0105316:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105319:	8b 00                	mov    (%eax),%eax
c010531b:	83 e0 01             	and    $0x1,%eax
c010531e:	85 c0                	test   %eax,%eax
c0105320:	75 16                	jne    c0105338 <swap_out+0x92>
c0105322:	68 15 ba 10 c0       	push   $0xc010ba15
c0105327:	68 2a ba 10 c0       	push   $0xc010ba2a
c010532c:	6a 65                	push   $0x65
c010532e:	68 c4 b9 10 c0       	push   $0xc010b9c4
c0105333:	e8 24 c4 ff ff       	call   c010175c <__panic>

          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
c0105338:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010533b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010533e:	8b 52 20             	mov    0x20(%edx),%edx
c0105341:	c1 ea 0c             	shr    $0xc,%edx
c0105344:	83 c2 01             	add    $0x1,%edx
c0105347:	c1 e2 08             	shl    $0x8,%edx
c010534a:	83 ec 08             	sub    $0x8,%esp
c010534d:	50                   	push   %eax
c010534e:	52                   	push   %edx
c010534f:	e8 f3 3e 00 00       	call   c0109247 <swapfs_write>
c0105354:	83 c4 10             	add    $0x10,%esp
c0105357:	85 c0                	test   %eax,%eax
c0105359:	74 2b                	je     c0105386 <swap_out+0xe0>
                    cprintf("SWAP: failed to save\n");
c010535b:	83 ec 0c             	sub    $0xc,%esp
c010535e:	68 3f ba 10 c0       	push   $0xc010ba3f
c0105363:	e8 16 af ff ff       	call   c010027e <cprintf>
c0105368:	83 c4 10             	add    $0x10,%esp
                    sm->map_swappable(mm, v, page, 0);
c010536b:	a1 10 8a 12 c0       	mov    0xc0128a10,%eax
c0105370:	8b 40 10             	mov    0x10(%eax),%eax
c0105373:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105376:	6a 00                	push   $0x0
c0105378:	52                   	push   %edx
c0105379:	ff 75 ec             	pushl  -0x14(%ebp)
c010537c:	ff 75 08             	pushl  0x8(%ebp)
c010537f:	ff d0                	call   *%eax
c0105381:	83 c4 10             	add    $0x10,%esp
c0105384:	eb 5c                	jmp    c01053e2 <swap_out+0x13c>
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
c0105386:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105389:	8b 40 20             	mov    0x20(%eax),%eax
c010538c:	c1 e8 0c             	shr    $0xc,%eax
c010538f:	83 c0 01             	add    $0x1,%eax
c0105392:	50                   	push   %eax
c0105393:	ff 75 ec             	pushl  -0x14(%ebp)
c0105396:	ff 75 f4             	pushl  -0xc(%ebp)
c0105399:	68 58 ba 10 c0       	push   $0xc010ba58
c010539e:	e8 db ae ff ff       	call   c010027e <cprintf>
c01053a3:	83 c4 10             	add    $0x10,%esp
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
c01053a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01053a9:	8b 40 20             	mov    0x20(%eax),%eax
c01053ac:	c1 e8 0c             	shr    $0xc,%eax
c01053af:	83 c0 01             	add    $0x1,%eax
c01053b2:	c1 e0 08             	shl    $0x8,%eax
c01053b5:	89 c2                	mov    %eax,%edx
c01053b7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01053ba:	89 10                	mov    %edx,(%eax)
                    free_page(page);
c01053bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01053bf:	83 ec 08             	sub    $0x8,%esp
c01053c2:	6a 01                	push   $0x1
c01053c4:	50                   	push   %eax
c01053c5:	e8 47 28 00 00       	call   c0107c11 <free_pages>
c01053ca:	83 c4 10             	add    $0x10,%esp
          }
          
          tlb_invalidate(mm->pgdir, v);
c01053cd:	8b 45 08             	mov    0x8(%ebp),%eax
c01053d0:	8b 40 0c             	mov    0xc(%eax),%eax
c01053d3:	83 ec 08             	sub    $0x8,%esp
c01053d6:	ff 75 ec             	pushl  -0x14(%ebp)
c01053d9:	50                   	push   %eax
c01053da:	e8 8b 31 00 00       	call   c010856a <tlb_invalidate>
c01053df:	83 c4 10             	add    $0x10,%esp

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
     int i;
     for (i = 0; i != n; ++ i)
c01053e2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01053e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01053e9:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01053ec:	0f 85 c6 fe ff ff    	jne    c01052b8 <swap_out+0x12>
                    free_page(page);
          }
          
          tlb_invalidate(mm->pgdir, v);
     }
     return i;
c01053f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01053f5:	c9                   	leave  
c01053f6:	c3                   	ret    

c01053f7 <swap_in>:

int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
c01053f7:	55                   	push   %ebp
c01053f8:	89 e5                	mov    %esp,%ebp
c01053fa:	83 ec 18             	sub    $0x18,%esp
     struct Page *result = alloc_page();
c01053fd:	83 ec 0c             	sub    $0xc,%esp
c0105400:	6a 01                	push   $0x1
c0105402:	e8 9e 27 00 00       	call   c0107ba5 <alloc_pages>
c0105407:	83 c4 10             	add    $0x10,%esp
c010540a:	89 45 f4             	mov    %eax,-0xc(%ebp)
     assert(result!=NULL);
c010540d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105411:	75 16                	jne    c0105429 <swap_in+0x32>
c0105413:	68 98 ba 10 c0       	push   $0xc010ba98
c0105418:	68 2a ba 10 c0       	push   $0xc010ba2a
c010541d:	6a 7b                	push   $0x7b
c010541f:	68 c4 b9 10 c0       	push   $0xc010b9c4
c0105424:	e8 33 c3 ff ff       	call   c010175c <__panic>

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
c0105429:	8b 45 08             	mov    0x8(%ebp),%eax
c010542c:	8b 40 0c             	mov    0xc(%eax),%eax
c010542f:	83 ec 04             	sub    $0x4,%esp
c0105432:	6a 00                	push   $0x0
c0105434:	ff 75 0c             	pushl  0xc(%ebp)
c0105437:	50                   	push   %eax
c0105438:	e8 63 2e 00 00       	call   c01082a0 <get_pte>
c010543d:	83 c4 10             	add    $0x10,%esp
c0105440:	89 45 f0             	mov    %eax,-0x10(%ebp)
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
c0105443:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105446:	8b 00                	mov    (%eax),%eax
c0105448:	83 ec 08             	sub    $0x8,%esp
c010544b:	ff 75 f4             	pushl  -0xc(%ebp)
c010544e:	50                   	push   %eax
c010544f:	e8 9a 3d 00 00       	call   c01091ee <swapfs_read>
c0105454:	83 c4 10             	add    $0x10,%esp
c0105457:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010545a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010545e:	74 1f                	je     c010547f <swap_in+0x88>
     {
        assert(r!=0);
c0105460:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0105464:	75 19                	jne    c010547f <swap_in+0x88>
c0105466:	68 a5 ba 10 c0       	push   $0xc010baa5
c010546b:	68 2a ba 10 c0       	push   $0xc010ba2a
c0105470:	68 83 00 00 00       	push   $0x83
c0105475:	68 c4 b9 10 c0       	push   $0xc010b9c4
c010547a:	e8 dd c2 ff ff       	call   c010175c <__panic>
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
c010547f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105482:	8b 00                	mov    (%eax),%eax
c0105484:	c1 e8 08             	shr    $0x8,%eax
c0105487:	83 ec 04             	sub    $0x4,%esp
c010548a:	ff 75 0c             	pushl  0xc(%ebp)
c010548d:	50                   	push   %eax
c010548e:	68 ac ba 10 c0       	push   $0xc010baac
c0105493:	e8 e6 ad ff ff       	call   c010027e <cprintf>
c0105498:	83 c4 10             	add    $0x10,%esp
     *ptr_result=result;
c010549b:	8b 45 10             	mov    0x10(%ebp),%eax
c010549e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01054a1:	89 10                	mov    %edx,(%eax)
     return 0;
c01054a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01054a8:	c9                   	leave  
c01054a9:	c3                   	ret    

c01054aa <check_content_set>:



static inline void
check_content_set(void)
{
c01054aa:	55                   	push   %ebp
c01054ab:	89 e5                	mov    %esp,%ebp
c01054ad:	83 ec 08             	sub    $0x8,%esp
     *(unsigned char *)0x1000 = 0x0a;
c01054b0:	b8 00 10 00 00       	mov    $0x1000,%eax
c01054b5:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c01054b8:	a1 04 8a 12 c0       	mov    0xc0128a04,%eax
c01054bd:	83 f8 01             	cmp    $0x1,%eax
c01054c0:	74 19                	je     c01054db <check_content_set+0x31>
c01054c2:	68 ea ba 10 c0       	push   $0xc010baea
c01054c7:	68 2a ba 10 c0       	push   $0xc010ba2a
c01054cc:	68 90 00 00 00       	push   $0x90
c01054d1:	68 c4 b9 10 c0       	push   $0xc010b9c4
c01054d6:	e8 81 c2 ff ff       	call   c010175c <__panic>
     *(unsigned char *)0x1010 = 0x0a;
c01054db:	b8 10 10 00 00       	mov    $0x1010,%eax
c01054e0:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c01054e3:	a1 04 8a 12 c0       	mov    0xc0128a04,%eax
c01054e8:	83 f8 01             	cmp    $0x1,%eax
c01054eb:	74 19                	je     c0105506 <check_content_set+0x5c>
c01054ed:	68 ea ba 10 c0       	push   $0xc010baea
c01054f2:	68 2a ba 10 c0       	push   $0xc010ba2a
c01054f7:	68 92 00 00 00       	push   $0x92
c01054fc:	68 c4 b9 10 c0       	push   $0xc010b9c4
c0105501:	e8 56 c2 ff ff       	call   c010175c <__panic>
     *(unsigned char *)0x2000 = 0x0b;
c0105506:	b8 00 20 00 00       	mov    $0x2000,%eax
c010550b:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c010550e:	a1 04 8a 12 c0       	mov    0xc0128a04,%eax
c0105513:	83 f8 02             	cmp    $0x2,%eax
c0105516:	74 19                	je     c0105531 <check_content_set+0x87>
c0105518:	68 f9 ba 10 c0       	push   $0xc010baf9
c010551d:	68 2a ba 10 c0       	push   $0xc010ba2a
c0105522:	68 94 00 00 00       	push   $0x94
c0105527:	68 c4 b9 10 c0       	push   $0xc010b9c4
c010552c:	e8 2b c2 ff ff       	call   c010175c <__panic>
     *(unsigned char *)0x2010 = 0x0b;
c0105531:	b8 10 20 00 00       	mov    $0x2010,%eax
c0105536:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0105539:	a1 04 8a 12 c0       	mov    0xc0128a04,%eax
c010553e:	83 f8 02             	cmp    $0x2,%eax
c0105541:	74 19                	je     c010555c <check_content_set+0xb2>
c0105543:	68 f9 ba 10 c0       	push   $0xc010baf9
c0105548:	68 2a ba 10 c0       	push   $0xc010ba2a
c010554d:	68 96 00 00 00       	push   $0x96
c0105552:	68 c4 b9 10 c0       	push   $0xc010b9c4
c0105557:	e8 00 c2 ff ff       	call   c010175c <__panic>
     *(unsigned char *)0x3000 = 0x0c;
c010555c:	b8 00 30 00 00       	mov    $0x3000,%eax
c0105561:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0105564:	a1 04 8a 12 c0       	mov    0xc0128a04,%eax
c0105569:	83 f8 03             	cmp    $0x3,%eax
c010556c:	74 19                	je     c0105587 <check_content_set+0xdd>
c010556e:	68 08 bb 10 c0       	push   $0xc010bb08
c0105573:	68 2a ba 10 c0       	push   $0xc010ba2a
c0105578:	68 98 00 00 00       	push   $0x98
c010557d:	68 c4 b9 10 c0       	push   $0xc010b9c4
c0105582:	e8 d5 c1 ff ff       	call   c010175c <__panic>
     *(unsigned char *)0x3010 = 0x0c;
c0105587:	b8 10 30 00 00       	mov    $0x3010,%eax
c010558c:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c010558f:	a1 04 8a 12 c0       	mov    0xc0128a04,%eax
c0105594:	83 f8 03             	cmp    $0x3,%eax
c0105597:	74 19                	je     c01055b2 <check_content_set+0x108>
c0105599:	68 08 bb 10 c0       	push   $0xc010bb08
c010559e:	68 2a ba 10 c0       	push   $0xc010ba2a
c01055a3:	68 9a 00 00 00       	push   $0x9a
c01055a8:	68 c4 b9 10 c0       	push   $0xc010b9c4
c01055ad:	e8 aa c1 ff ff       	call   c010175c <__panic>
     *(unsigned char *)0x4000 = 0x0d;
c01055b2:	b8 00 40 00 00       	mov    $0x4000,%eax
c01055b7:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c01055ba:	a1 04 8a 12 c0       	mov    0xc0128a04,%eax
c01055bf:	83 f8 04             	cmp    $0x4,%eax
c01055c2:	74 19                	je     c01055dd <check_content_set+0x133>
c01055c4:	68 17 bb 10 c0       	push   $0xc010bb17
c01055c9:	68 2a ba 10 c0       	push   $0xc010ba2a
c01055ce:	68 9c 00 00 00       	push   $0x9c
c01055d3:	68 c4 b9 10 c0       	push   $0xc010b9c4
c01055d8:	e8 7f c1 ff ff       	call   c010175c <__panic>
     *(unsigned char *)0x4010 = 0x0d;
c01055dd:	b8 10 40 00 00       	mov    $0x4010,%eax
c01055e2:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c01055e5:	a1 04 8a 12 c0       	mov    0xc0128a04,%eax
c01055ea:	83 f8 04             	cmp    $0x4,%eax
c01055ed:	74 19                	je     c0105608 <check_content_set+0x15e>
c01055ef:	68 17 bb 10 c0       	push   $0xc010bb17
c01055f4:	68 2a ba 10 c0       	push   $0xc010ba2a
c01055f9:	68 9e 00 00 00       	push   $0x9e
c01055fe:	68 c4 b9 10 c0       	push   $0xc010b9c4
c0105603:	e8 54 c1 ff ff       	call   c010175c <__panic>
}
c0105608:	90                   	nop
c0105609:	c9                   	leave  
c010560a:	c3                   	ret    

c010560b <check_content_access>:

static inline int
check_content_access(void)
{
c010560b:	55                   	push   %ebp
c010560c:	89 e5                	mov    %esp,%ebp
c010560e:	83 ec 18             	sub    $0x18,%esp
    int ret = sm->check_swap();
c0105611:	a1 10 8a 12 c0       	mov    0xc0128a10,%eax
c0105616:	8b 40 1c             	mov    0x1c(%eax),%eax
c0105619:	ff d0                	call   *%eax
c010561b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ret;
c010561e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105621:	c9                   	leave  
c0105622:	c3                   	ret    

c0105623 <check_swap>:
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
check_swap(void)
{
c0105623:	55                   	push   %ebp
c0105624:	89 e5                	mov    %esp,%ebp
c0105626:	83 ec 68             	sub    $0x68,%esp
    //backup mem env
     int ret, count = 0, total = 0, i;
c0105629:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105630:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     list_entry_t *le = &free_list;
c0105637:	c7 45 e8 cc ab 12 c0 	movl   $0xc012abcc,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c010563e:	eb 60                	jmp    c01056a0 <check_swap+0x7d>
        struct Page *p = le2page(le, page_link);
c0105640:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105643:	83 e8 10             	sub    $0x10,%eax
c0105646:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(PageProperty(p));
c0105649:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010564c:	83 c0 04             	add    $0x4,%eax
c010564f:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
c0105656:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105659:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010565c:	8b 55 b0             	mov    -0x50(%ebp),%edx
c010565f:	0f a3 10             	bt     %edx,(%eax)
c0105662:	19 c0                	sbb    %eax,%eax
c0105664:	89 45 a8             	mov    %eax,-0x58(%ebp)
    return oldbit != 0;
c0105667:	83 7d a8 00          	cmpl   $0x0,-0x58(%ebp)
c010566b:	0f 95 c0             	setne  %al
c010566e:	0f b6 c0             	movzbl %al,%eax
c0105671:	85 c0                	test   %eax,%eax
c0105673:	75 19                	jne    c010568e <check_swap+0x6b>
c0105675:	68 26 bb 10 c0       	push   $0xc010bb26
c010567a:	68 2a ba 10 c0       	push   $0xc010ba2a
c010567f:	68 b9 00 00 00       	push   $0xb9
c0105684:	68 c4 b9 10 c0       	push   $0xc010b9c4
c0105689:	e8 ce c0 ff ff       	call   c010175c <__panic>
        count ++, total += p->property;
c010568e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0105692:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105695:	8b 50 08             	mov    0x8(%eax),%edx
c0105698:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010569b:	01 d0                	add    %edx,%eax
c010569d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01056a0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01056a3:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01056a6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01056a9:	8b 40 04             	mov    0x4(%eax),%eax
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
c01056ac:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01056af:	81 7d e8 cc ab 12 c0 	cmpl   $0xc012abcc,-0x18(%ebp)
c01056b6:	75 88                	jne    c0105640 <check_swap+0x1d>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
     }
     assert(total == nr_free_pages());
c01056b8:	e8 89 25 00 00       	call   c0107c46 <nr_free_pages>
c01056bd:	89 c2                	mov    %eax,%edx
c01056bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01056c2:	39 c2                	cmp    %eax,%edx
c01056c4:	74 19                	je     c01056df <check_swap+0xbc>
c01056c6:	68 36 bb 10 c0       	push   $0xc010bb36
c01056cb:	68 2a ba 10 c0       	push   $0xc010ba2a
c01056d0:	68 bc 00 00 00       	push   $0xbc
c01056d5:	68 c4 b9 10 c0       	push   $0xc010b9c4
c01056da:	e8 7d c0 ff ff       	call   c010175c <__panic>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
c01056df:	83 ec 04             	sub    $0x4,%esp
c01056e2:	ff 75 f0             	pushl  -0x10(%ebp)
c01056e5:	ff 75 f4             	pushl  -0xc(%ebp)
c01056e8:	68 50 bb 10 c0       	push   $0xc010bb50
c01056ed:	e8 8c ab ff ff       	call   c010027e <cprintf>
c01056f2:	83 c4 10             	add    $0x10,%esp
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
c01056f5:	e8 76 ee ff ff       	call   c0104570 <mm_create>
c01056fa:	89 45 d8             	mov    %eax,-0x28(%ebp)
     assert(mm != NULL);
c01056fd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0105701:	75 19                	jne    c010571c <check_swap+0xf9>
c0105703:	68 76 bb 10 c0       	push   $0xc010bb76
c0105708:	68 2a ba 10 c0       	push   $0xc010ba2a
c010570d:	68 c1 00 00 00       	push   $0xc1
c0105712:	68 c4 b9 10 c0       	push   $0xc010b9c4
c0105717:	e8 40 c0 ff ff       	call   c010175c <__panic>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
c010571c:	a1 f8 aa 12 c0       	mov    0xc012aaf8,%eax
c0105721:	85 c0                	test   %eax,%eax
c0105723:	74 19                	je     c010573e <check_swap+0x11b>
c0105725:	68 81 bb 10 c0       	push   $0xc010bb81
c010572a:	68 2a ba 10 c0       	push   $0xc010ba2a
c010572f:	68 c4 00 00 00       	push   $0xc4
c0105734:	68 c4 b9 10 c0       	push   $0xc010b9c4
c0105739:	e8 1e c0 ff ff       	call   c010175c <__panic>

     check_mm_struct = mm;
c010573e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105741:	a3 f8 aa 12 c0       	mov    %eax,0xc012aaf8

     pde_t *pgdir = mm->pgdir = boot_pgdir;
c0105746:	8b 15 24 8a 12 c0    	mov    0xc0128a24,%edx
c010574c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010574f:	89 50 0c             	mov    %edx,0xc(%eax)
c0105752:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105755:	8b 40 0c             	mov    0xc(%eax),%eax
c0105758:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     assert(pgdir[0] == 0);
c010575b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010575e:	8b 00                	mov    (%eax),%eax
c0105760:	85 c0                	test   %eax,%eax
c0105762:	74 19                	je     c010577d <check_swap+0x15a>
c0105764:	68 99 bb 10 c0       	push   $0xc010bb99
c0105769:	68 2a ba 10 c0       	push   $0xc010ba2a
c010576e:	68 c9 00 00 00       	push   $0xc9
c0105773:	68 c4 b9 10 c0       	push   $0xc010b9c4
c0105778:	e8 df bf ff ff       	call   c010175c <__panic>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
c010577d:	83 ec 04             	sub    $0x4,%esp
c0105780:	6a 03                	push   $0x3
c0105782:	68 00 60 00 00       	push   $0x6000
c0105787:	68 00 10 00 00       	push   $0x1000
c010578c:	e8 5b ee ff ff       	call   c01045ec <vma_create>
c0105791:	83 c4 10             	add    $0x10,%esp
c0105794:	89 45 d0             	mov    %eax,-0x30(%ebp)
     assert(vma != NULL);
c0105797:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c010579b:	75 19                	jne    c01057b6 <check_swap+0x193>
c010579d:	68 a7 bb 10 c0       	push   $0xc010bba7
c01057a2:	68 2a ba 10 c0       	push   $0xc010ba2a
c01057a7:	68 cc 00 00 00       	push   $0xcc
c01057ac:	68 c4 b9 10 c0       	push   $0xc010b9c4
c01057b1:	e8 a6 bf ff ff       	call   c010175c <__panic>

     insert_vma_struct(mm, vma);
c01057b6:	83 ec 08             	sub    $0x8,%esp
c01057b9:	ff 75 d0             	pushl  -0x30(%ebp)
c01057bc:	ff 75 d8             	pushl  -0x28(%ebp)
c01057bf:	e8 90 ef ff ff       	call   c0104754 <insert_vma_struct>
c01057c4:	83 c4 10             	add    $0x10,%esp

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
c01057c7:	83 ec 0c             	sub    $0xc,%esp
c01057ca:	68 b4 bb 10 c0       	push   $0xc010bbb4
c01057cf:	e8 aa aa ff ff       	call   c010027e <cprintf>
c01057d4:	83 c4 10             	add    $0x10,%esp
     pte_t *temp_ptep=NULL;
c01057d7:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
c01057de:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01057e1:	8b 40 0c             	mov    0xc(%eax),%eax
c01057e4:	83 ec 04             	sub    $0x4,%esp
c01057e7:	6a 01                	push   $0x1
c01057e9:	68 00 10 00 00       	push   $0x1000
c01057ee:	50                   	push   %eax
c01057ef:	e8 ac 2a 00 00       	call   c01082a0 <get_pte>
c01057f4:	83 c4 10             	add    $0x10,%esp
c01057f7:	89 45 cc             	mov    %eax,-0x34(%ebp)
     assert(temp_ptep!= NULL);
c01057fa:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01057fe:	75 19                	jne    c0105819 <check_swap+0x1f6>
c0105800:	68 e8 bb 10 c0       	push   $0xc010bbe8
c0105805:	68 2a ba 10 c0       	push   $0xc010ba2a
c010580a:	68 d4 00 00 00       	push   $0xd4
c010580f:	68 c4 b9 10 c0       	push   $0xc010b9c4
c0105814:	e8 43 bf ff ff       	call   c010175c <__panic>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
c0105819:	83 ec 0c             	sub    $0xc,%esp
c010581c:	68 fc bb 10 c0       	push   $0xc010bbfc
c0105821:	e8 58 aa ff ff       	call   c010027e <cprintf>
c0105826:	83 c4 10             	add    $0x10,%esp
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105829:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0105830:	e9 90 00 00 00       	jmp    c01058c5 <check_swap+0x2a2>
          check_rp[i] = alloc_page();
c0105835:	83 ec 0c             	sub    $0xc,%esp
c0105838:	6a 01                	push   $0x1
c010583a:	e8 66 23 00 00       	call   c0107ba5 <alloc_pages>
c010583f:	83 c4 10             	add    $0x10,%esp
c0105842:	89 c2                	mov    %eax,%edx
c0105844:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105847:	89 14 85 00 ab 12 c0 	mov    %edx,-0x3fed5500(,%eax,4)
          assert(check_rp[i] != NULL );
c010584e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105851:	8b 04 85 00 ab 12 c0 	mov    -0x3fed5500(,%eax,4),%eax
c0105858:	85 c0                	test   %eax,%eax
c010585a:	75 19                	jne    c0105875 <check_swap+0x252>
c010585c:	68 20 bc 10 c0       	push   $0xc010bc20
c0105861:	68 2a ba 10 c0       	push   $0xc010ba2a
c0105866:	68 d9 00 00 00       	push   $0xd9
c010586b:	68 c4 b9 10 c0       	push   $0xc010b9c4
c0105870:	e8 e7 be ff ff       	call   c010175c <__panic>
          assert(!PageProperty(check_rp[i]));
c0105875:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105878:	8b 04 85 00 ab 12 c0 	mov    -0x3fed5500(,%eax,4),%eax
c010587f:	83 c0 04             	add    $0x4,%eax
c0105882:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c0105889:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010588c:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c010588f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105892:	0f a3 10             	bt     %edx,(%eax)
c0105895:	19 c0                	sbb    %eax,%eax
c0105897:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return oldbit != 0;
c010589a:	83 7d a0 00          	cmpl   $0x0,-0x60(%ebp)
c010589e:	0f 95 c0             	setne  %al
c01058a1:	0f b6 c0             	movzbl %al,%eax
c01058a4:	85 c0                	test   %eax,%eax
c01058a6:	74 19                	je     c01058c1 <check_swap+0x29e>
c01058a8:	68 34 bc 10 c0       	push   $0xc010bc34
c01058ad:	68 2a ba 10 c0       	push   $0xc010ba2a
c01058b2:	68 da 00 00 00       	push   $0xda
c01058b7:	68 c4 b9 10 c0       	push   $0xc010b9c4
c01058bc:	e8 9b be ff ff       	call   c010175c <__panic>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
     assert(temp_ptep!= NULL);
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01058c1:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c01058c5:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c01058c9:	0f 8e 66 ff ff ff    	jle    c0105835 <check_swap+0x212>
          check_rp[i] = alloc_page();
          assert(check_rp[i] != NULL );
          assert(!PageProperty(check_rp[i]));
     }
     list_entry_t free_list_store = free_list;
c01058cf:	a1 cc ab 12 c0       	mov    0xc012abcc,%eax
c01058d4:	8b 15 d0 ab 12 c0    	mov    0xc012abd0,%edx
c01058da:	89 45 98             	mov    %eax,-0x68(%ebp)
c01058dd:	89 55 9c             	mov    %edx,-0x64(%ebp)
c01058e0:	c7 45 c0 cc ab 12 c0 	movl   $0xc012abcc,-0x40(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01058e7:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01058ea:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01058ed:	89 50 04             	mov    %edx,0x4(%eax)
c01058f0:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01058f3:	8b 50 04             	mov    0x4(%eax),%edx
c01058f6:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01058f9:	89 10                	mov    %edx,(%eax)
c01058fb:	c7 45 c8 cc ab 12 c0 	movl   $0xc012abcc,-0x38(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0105902:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0105905:	8b 40 04             	mov    0x4(%eax),%eax
c0105908:	39 45 c8             	cmp    %eax,-0x38(%ebp)
c010590b:	0f 94 c0             	sete   %al
c010590e:	0f b6 c0             	movzbl %al,%eax
     list_init(&free_list);
     assert(list_empty(&free_list));
c0105911:	85 c0                	test   %eax,%eax
c0105913:	75 19                	jne    c010592e <check_swap+0x30b>
c0105915:	68 4f bc 10 c0       	push   $0xc010bc4f
c010591a:	68 2a ba 10 c0       	push   $0xc010ba2a
c010591f:	68 de 00 00 00       	push   $0xde
c0105924:	68 c4 b9 10 c0       	push   $0xc010b9c4
c0105929:	e8 2e be ff ff       	call   c010175c <__panic>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
c010592e:	a1 d4 ab 12 c0       	mov    0xc012abd4,%eax
c0105933:	89 45 bc             	mov    %eax,-0x44(%ebp)
     nr_free = 0;
c0105936:	c7 05 d4 ab 12 c0 00 	movl   $0x0,0xc012abd4
c010593d:	00 00 00 
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105940:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0105947:	eb 1c                	jmp    c0105965 <check_swap+0x342>
        free_pages(check_rp[i],1);
c0105949:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010594c:	8b 04 85 00 ab 12 c0 	mov    -0x3fed5500(,%eax,4),%eax
c0105953:	83 ec 08             	sub    $0x8,%esp
c0105956:	6a 01                	push   $0x1
c0105958:	50                   	push   %eax
c0105959:	e8 b3 22 00 00       	call   c0107c11 <free_pages>
c010595e:	83 c4 10             	add    $0x10,%esp
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105961:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0105965:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0105969:	7e de                	jle    c0105949 <check_swap+0x326>
        free_pages(check_rp[i],1);
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
c010596b:	a1 d4 ab 12 c0       	mov    0xc012abd4,%eax
c0105970:	83 f8 04             	cmp    $0x4,%eax
c0105973:	74 19                	je     c010598e <check_swap+0x36b>
c0105975:	68 68 bc 10 c0       	push   $0xc010bc68
c010597a:	68 2a ba 10 c0       	push   $0xc010ba2a
c010597f:	68 e7 00 00 00       	push   $0xe7
c0105984:	68 c4 b9 10 c0       	push   $0xc010b9c4
c0105989:	e8 ce bd ff ff       	call   c010175c <__panic>
     
     cprintf("set up init env for check_swap begin!\n");
c010598e:	83 ec 0c             	sub    $0xc,%esp
c0105991:	68 8c bc 10 c0       	push   $0xc010bc8c
c0105996:	e8 e3 a8 ff ff       	call   c010027e <cprintf>
c010599b:	83 c4 10             	add    $0x10,%esp
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
c010599e:	c7 05 04 8a 12 c0 00 	movl   $0x0,0xc0128a04
c01059a5:	00 00 00 
     
     check_content_set();
c01059a8:	e8 fd fa ff ff       	call   c01054aa <check_content_set>
     assert( nr_free == 0);         
c01059ad:	a1 d4 ab 12 c0       	mov    0xc012abd4,%eax
c01059b2:	85 c0                	test   %eax,%eax
c01059b4:	74 19                	je     c01059cf <check_swap+0x3ac>
c01059b6:	68 b3 bc 10 c0       	push   $0xc010bcb3
c01059bb:	68 2a ba 10 c0       	push   $0xc010ba2a
c01059c0:	68 f0 00 00 00       	push   $0xf0
c01059c5:	68 c4 b9 10 c0       	push   $0xc010b9c4
c01059ca:	e8 8d bd ff ff       	call   c010175c <__panic>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c01059cf:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01059d6:	eb 26                	jmp    c01059fe <check_swap+0x3db>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
c01059d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01059db:	c7 04 85 20 ab 12 c0 	movl   $0xffffffff,-0x3fed54e0(,%eax,4)
c01059e2:	ff ff ff ff 
c01059e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01059e9:	8b 14 85 20 ab 12 c0 	mov    -0x3fed54e0(,%eax,4),%edx
c01059f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01059f3:	89 14 85 60 ab 12 c0 	mov    %edx,-0x3fed54a0(,%eax,4)
     
     pgfault_num=0;
     
     check_content_set();
     assert( nr_free == 0);         
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c01059fa:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c01059fe:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
c0105a02:	7e d4                	jle    c01059d8 <check_swap+0x3b5>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105a04:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0105a0b:	e9 cc 00 00 00       	jmp    c0105adc <check_swap+0x4b9>
         check_ptep[i]=0;
c0105a10:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a13:	c7 04 85 b4 ab 12 c0 	movl   $0x0,-0x3fed544c(,%eax,4)
c0105a1a:	00 00 00 00 
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
c0105a1e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a21:	83 c0 01             	add    $0x1,%eax
c0105a24:	c1 e0 0c             	shl    $0xc,%eax
c0105a27:	83 ec 04             	sub    $0x4,%esp
c0105a2a:	6a 00                	push   $0x0
c0105a2c:	50                   	push   %eax
c0105a2d:	ff 75 d4             	pushl  -0x2c(%ebp)
c0105a30:	e8 6b 28 00 00       	call   c01082a0 <get_pte>
c0105a35:	83 c4 10             	add    $0x10,%esp
c0105a38:	89 c2                	mov    %eax,%edx
c0105a3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a3d:	89 14 85 b4 ab 12 c0 	mov    %edx,-0x3fed544c(,%eax,4)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
c0105a44:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a47:	8b 04 85 b4 ab 12 c0 	mov    -0x3fed544c(,%eax,4),%eax
c0105a4e:	85 c0                	test   %eax,%eax
c0105a50:	75 19                	jne    c0105a6b <check_swap+0x448>
c0105a52:	68 c0 bc 10 c0       	push   $0xc010bcc0
c0105a57:	68 2a ba 10 c0       	push   $0xc010ba2a
c0105a5c:	68 f8 00 00 00       	push   $0xf8
c0105a61:	68 c4 b9 10 c0       	push   $0xc010b9c4
c0105a66:	e8 f1 bc ff ff       	call   c010175c <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
c0105a6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a6e:	8b 04 85 b4 ab 12 c0 	mov    -0x3fed544c(,%eax,4),%eax
c0105a75:	8b 00                	mov    (%eax),%eax
c0105a77:	83 ec 0c             	sub    $0xc,%esp
c0105a7a:	50                   	push   %eax
c0105a7b:	e8 f4 f6 ff ff       	call   c0105174 <pte2page>
c0105a80:	83 c4 10             	add    $0x10,%esp
c0105a83:	89 c2                	mov    %eax,%edx
c0105a85:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a88:	8b 04 85 00 ab 12 c0 	mov    -0x3fed5500(,%eax,4),%eax
c0105a8f:	39 c2                	cmp    %eax,%edx
c0105a91:	74 19                	je     c0105aac <check_swap+0x489>
c0105a93:	68 d8 bc 10 c0       	push   $0xc010bcd8
c0105a98:	68 2a ba 10 c0       	push   $0xc010ba2a
c0105a9d:	68 f9 00 00 00       	push   $0xf9
c0105aa2:	68 c4 b9 10 c0       	push   $0xc010b9c4
c0105aa7:	e8 b0 bc ff ff       	call   c010175c <__panic>
         assert((*check_ptep[i] & PTE_P));          
c0105aac:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105aaf:	8b 04 85 b4 ab 12 c0 	mov    -0x3fed544c(,%eax,4),%eax
c0105ab6:	8b 00                	mov    (%eax),%eax
c0105ab8:	83 e0 01             	and    $0x1,%eax
c0105abb:	85 c0                	test   %eax,%eax
c0105abd:	75 19                	jne    c0105ad8 <check_swap+0x4b5>
c0105abf:	68 00 bd 10 c0       	push   $0xc010bd00
c0105ac4:	68 2a ba 10 c0       	push   $0xc010ba2a
c0105ac9:	68 fa 00 00 00       	push   $0xfa
c0105ace:	68 c4 b9 10 c0       	push   $0xc010b9c4
c0105ad3:	e8 84 bc ff ff       	call   c010175c <__panic>
     check_content_set();
     assert( nr_free == 0);         
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105ad8:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0105adc:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0105ae0:	0f 8e 2a ff ff ff    	jle    c0105a10 <check_swap+0x3ed>
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
         assert((*check_ptep[i] & PTE_P));          
     }
     cprintf("set up init env for check_swap over!\n");
c0105ae6:	83 ec 0c             	sub    $0xc,%esp
c0105ae9:	68 1c bd 10 c0       	push   $0xc010bd1c
c0105aee:	e8 8b a7 ff ff       	call   c010027e <cprintf>
c0105af3:	83 c4 10             	add    $0x10,%esp
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
c0105af6:	e8 10 fb ff ff       	call   c010560b <check_content_access>
c0105afb:	89 45 b8             	mov    %eax,-0x48(%ebp)
     assert(ret==0);
c0105afe:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0105b02:	74 19                	je     c0105b1d <check_swap+0x4fa>
c0105b04:	68 42 bd 10 c0       	push   $0xc010bd42
c0105b09:	68 2a ba 10 c0       	push   $0xc010ba2a
c0105b0e:	68 ff 00 00 00       	push   $0xff
c0105b13:	68 c4 b9 10 c0       	push   $0xc010b9c4
c0105b18:	e8 3f bc ff ff       	call   c010175c <__panic>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105b1d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0105b24:	eb 1c                	jmp    c0105b42 <check_swap+0x51f>
         free_pages(check_rp[i],1);
c0105b26:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105b29:	8b 04 85 00 ab 12 c0 	mov    -0x3fed5500(,%eax,4),%eax
c0105b30:	83 ec 08             	sub    $0x8,%esp
c0105b33:	6a 01                	push   $0x1
c0105b35:	50                   	push   %eax
c0105b36:	e8 d6 20 00 00       	call   c0107c11 <free_pages>
c0105b3b:	83 c4 10             	add    $0x10,%esp
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0105b3e:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0105b42:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0105b46:	7e de                	jle    c0105b26 <check_swap+0x503>
         free_pages(check_rp[i],1);
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
c0105b48:	83 ec 0c             	sub    $0xc,%esp
c0105b4b:	ff 75 d8             	pushl  -0x28(%ebp)
c0105b4e:	e8 25 ed ff ff       	call   c0104878 <mm_destroy>
c0105b53:	83 c4 10             	add    $0x10,%esp
         
     nr_free = nr_free_store;
c0105b56:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0105b59:	a3 d4 ab 12 c0       	mov    %eax,0xc012abd4
     free_list = free_list_store;
c0105b5e:	8b 45 98             	mov    -0x68(%ebp),%eax
c0105b61:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0105b64:	a3 cc ab 12 c0       	mov    %eax,0xc012abcc
c0105b69:	89 15 d0 ab 12 c0    	mov    %edx,0xc012abd0

     
     le = &free_list;
c0105b6f:	c7 45 e8 cc ab 12 c0 	movl   $0xc012abcc,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0105b76:	eb 1d                	jmp    c0105b95 <check_swap+0x572>
         struct Page *p = le2page(le, page_link);
c0105b78:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105b7b:	83 e8 10             	sub    $0x10,%eax
c0105b7e:	89 45 b4             	mov    %eax,-0x4c(%ebp)
         count --, total -= p->property;
c0105b81:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0105b85:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105b88:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0105b8b:	8b 40 08             	mov    0x8(%eax),%eax
c0105b8e:	29 c2                	sub    %eax,%edx
c0105b90:	89 d0                	mov    %edx,%eax
c0105b92:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105b95:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105b98:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0105b9b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105b9e:	8b 40 04             	mov    0x4(%eax),%eax
     nr_free = nr_free_store;
     free_list = free_list_store;

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
c0105ba1:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105ba4:	81 7d e8 cc ab 12 c0 	cmpl   $0xc012abcc,-0x18(%ebp)
c0105bab:	75 cb                	jne    c0105b78 <check_swap+0x555>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
     }
     cprintf("count is %d, total is %d\n",count,total);
c0105bad:	83 ec 04             	sub    $0x4,%esp
c0105bb0:	ff 75 f0             	pushl  -0x10(%ebp)
c0105bb3:	ff 75 f4             	pushl  -0xc(%ebp)
c0105bb6:	68 49 bd 10 c0       	push   $0xc010bd49
c0105bbb:	e8 be a6 ff ff       	call   c010027e <cprintf>
c0105bc0:	83 c4 10             	add    $0x10,%esp
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
c0105bc3:	83 ec 0c             	sub    $0xc,%esp
c0105bc6:	68 63 bd 10 c0       	push   $0xc010bd63
c0105bcb:	e8 ae a6 ff ff       	call   c010027e <cprintf>
c0105bd0:	83 c4 10             	add    $0x10,%esp
}
c0105bd3:	90                   	nop
c0105bd4:	c9                   	leave  
c0105bd5:	c3                   	ret    

c0105bd6 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0105bd6:	55                   	push   %ebp
c0105bd7:	89 e5                	mov    %esp,%ebp
c0105bd9:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0105bdc:	9c                   	pushf  
c0105bdd:	58                   	pop    %eax
c0105bde:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0105be1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0105be4:	25 00 02 00 00       	and    $0x200,%eax
c0105be9:	85 c0                	test   %eax,%eax
c0105beb:	74 0c                	je     c0105bf9 <__intr_save+0x23>
        intr_disable();
c0105bed:	e8 36 d8 ff ff       	call   c0103428 <intr_disable>
        return 1;
c0105bf2:	b8 01 00 00 00       	mov    $0x1,%eax
c0105bf7:	eb 05                	jmp    c0105bfe <__intr_save+0x28>
    }
    return 0;
c0105bf9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105bfe:	c9                   	leave  
c0105bff:	c3                   	ret    

c0105c00 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0105c00:	55                   	push   %ebp
c0105c01:	89 e5                	mov    %esp,%ebp
c0105c03:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0105c06:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105c0a:	74 05                	je     c0105c11 <__intr_restore+0x11>
        intr_enable();
c0105c0c:	e8 10 d8 ff ff       	call   c0103421 <intr_enable>
    }
}
c0105c11:	90                   	nop
c0105c12:	c9                   	leave  
c0105c13:	c3                   	ret    

c0105c14 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0105c14:	55                   	push   %ebp
c0105c15:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0105c17:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c1a:	8b 15 e0 ab 12 c0    	mov    0xc012abe0,%edx
c0105c20:	29 d0                	sub    %edx,%eax
c0105c22:	c1 f8 02             	sar    $0x2,%eax
c0105c25:	69 c0 39 8e e3 38    	imul   $0x38e38e39,%eax,%eax
}
c0105c2b:	5d                   	pop    %ebp
c0105c2c:	c3                   	ret    

c0105c2d <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0105c2d:	55                   	push   %ebp
c0105c2e:	89 e5                	mov    %esp,%ebp
    return page2ppn(page) << PGSHIFT;
c0105c30:	ff 75 08             	pushl  0x8(%ebp)
c0105c33:	e8 dc ff ff ff       	call   c0105c14 <page2ppn>
c0105c38:	83 c4 04             	add    $0x4,%esp
c0105c3b:	c1 e0 0c             	shl    $0xc,%eax
}
c0105c3e:	c9                   	leave  
c0105c3f:	c3                   	ret    

c0105c40 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0105c40:	55                   	push   %ebp
c0105c41:	89 e5                	mov    %esp,%ebp
c0105c43:	83 ec 08             	sub    $0x8,%esp
    if (PPN(pa) >= npage) {
c0105c46:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c49:	c1 e8 0c             	shr    $0xc,%eax
c0105c4c:	89 c2                	mov    %eax,%edx
c0105c4e:	a1 20 8a 12 c0       	mov    0xc0128a20,%eax
c0105c53:	39 c2                	cmp    %eax,%edx
c0105c55:	72 14                	jb     c0105c6b <pa2page+0x2b>
        panic("pa2page called with invalid pa");
c0105c57:	83 ec 04             	sub    $0x4,%esp
c0105c5a:	68 7c bd 10 c0       	push   $0xc010bd7c
c0105c5f:	6a 5f                	push   $0x5f
c0105c61:	68 9b bd 10 c0       	push   $0xc010bd9b
c0105c66:	e8 f1 ba ff ff       	call   c010175c <__panic>
    }
    return &pages[PPN(pa)];
c0105c6b:	8b 0d e0 ab 12 c0    	mov    0xc012abe0,%ecx
c0105c71:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c74:	c1 e8 0c             	shr    $0xc,%eax
c0105c77:	89 c2                	mov    %eax,%edx
c0105c79:	89 d0                	mov    %edx,%eax
c0105c7b:	c1 e0 03             	shl    $0x3,%eax
c0105c7e:	01 d0                	add    %edx,%eax
c0105c80:	c1 e0 02             	shl    $0x2,%eax
c0105c83:	01 c8                	add    %ecx,%eax
}
c0105c85:	c9                   	leave  
c0105c86:	c3                   	ret    

c0105c87 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0105c87:	55                   	push   %ebp
c0105c88:	89 e5                	mov    %esp,%ebp
c0105c8a:	83 ec 18             	sub    $0x18,%esp
    return KADDR(page2pa(page));
c0105c8d:	ff 75 08             	pushl  0x8(%ebp)
c0105c90:	e8 98 ff ff ff       	call   c0105c2d <page2pa>
c0105c95:	83 c4 04             	add    $0x4,%esp
c0105c98:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105c9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c9e:	c1 e8 0c             	shr    $0xc,%eax
c0105ca1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105ca4:	a1 20 8a 12 c0       	mov    0xc0128a20,%eax
c0105ca9:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0105cac:	72 14                	jb     c0105cc2 <page2kva+0x3b>
c0105cae:	ff 75 f4             	pushl  -0xc(%ebp)
c0105cb1:	68 ac bd 10 c0       	push   $0xc010bdac
c0105cb6:	6a 66                	push   $0x66
c0105cb8:	68 9b bd 10 c0       	push   $0xc010bd9b
c0105cbd:	e8 9a ba ff ff       	call   c010175c <__panic>
c0105cc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105cc5:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0105cca:	c9                   	leave  
c0105ccb:	c3                   	ret    

c0105ccc <kva2page>:

static inline struct Page *
kva2page(void *kva) {
c0105ccc:	55                   	push   %ebp
c0105ccd:	89 e5                	mov    %esp,%ebp
c0105ccf:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PADDR(kva));
c0105cd2:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cd5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105cd8:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0105cdf:	77 14                	ja     c0105cf5 <kva2page+0x29>
c0105ce1:	ff 75 f4             	pushl  -0xc(%ebp)
c0105ce4:	68 d0 bd 10 c0       	push   $0xc010bdd0
c0105ce9:	6a 6b                	push   $0x6b
c0105ceb:	68 9b bd 10 c0       	push   $0xc010bd9b
c0105cf0:	e8 67 ba ff ff       	call   c010175c <__panic>
c0105cf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105cf8:	05 00 00 00 40       	add    $0x40000000,%eax
c0105cfd:	83 ec 0c             	sub    $0xc,%esp
c0105d00:	50                   	push   %eax
c0105d01:	e8 3a ff ff ff       	call   c0105c40 <pa2page>
c0105d06:	83 c4 10             	add    $0x10,%esp
}
c0105d09:	c9                   	leave  
c0105d0a:	c3                   	ret    

c0105d0b <__slob_get_free_pages>:
static slob_t *slobfree = &arena;
static bigblock_t *bigblocks;


static void* __slob_get_free_pages(gfp_t gfp, int order)
{
c0105d0b:	55                   	push   %ebp
c0105d0c:	89 e5                	mov    %esp,%ebp
c0105d0e:	83 ec 18             	sub    $0x18,%esp
  struct Page * page = alloc_pages(1 << order);
c0105d11:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d14:	ba 01 00 00 00       	mov    $0x1,%edx
c0105d19:	89 c1                	mov    %eax,%ecx
c0105d1b:	d3 e2                	shl    %cl,%edx
c0105d1d:	89 d0                	mov    %edx,%eax
c0105d1f:	83 ec 0c             	sub    $0xc,%esp
c0105d22:	50                   	push   %eax
c0105d23:	e8 7d 1e 00 00       	call   c0107ba5 <alloc_pages>
c0105d28:	83 c4 10             	add    $0x10,%esp
c0105d2b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!page)
c0105d2e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105d32:	75 07                	jne    c0105d3b <__slob_get_free_pages+0x30>
    return NULL;
c0105d34:	b8 00 00 00 00       	mov    $0x0,%eax
c0105d39:	eb 0e                	jmp    c0105d49 <__slob_get_free_pages+0x3e>
  return page2kva(page);
c0105d3b:	83 ec 0c             	sub    $0xc,%esp
c0105d3e:	ff 75 f4             	pushl  -0xc(%ebp)
c0105d41:	e8 41 ff ff ff       	call   c0105c87 <page2kva>
c0105d46:	83 c4 10             	add    $0x10,%esp
}
c0105d49:	c9                   	leave  
c0105d4a:	c3                   	ret    

c0105d4b <__slob_free_pages>:

#define __slob_get_free_page(gfp) __slob_get_free_pages(gfp, 0)

static inline void __slob_free_pages(unsigned long kva, int order)
{
c0105d4b:	55                   	push   %ebp
c0105d4c:	89 e5                	mov    %esp,%ebp
c0105d4e:	53                   	push   %ebx
c0105d4f:	83 ec 04             	sub    $0x4,%esp
  free_pages(kva2page(kva), 1 << order);
c0105d52:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d55:	ba 01 00 00 00       	mov    $0x1,%edx
c0105d5a:	89 c1                	mov    %eax,%ecx
c0105d5c:	d3 e2                	shl    %cl,%edx
c0105d5e:	89 d0                	mov    %edx,%eax
c0105d60:	89 c3                	mov    %eax,%ebx
c0105d62:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d65:	83 ec 0c             	sub    $0xc,%esp
c0105d68:	50                   	push   %eax
c0105d69:	e8 5e ff ff ff       	call   c0105ccc <kva2page>
c0105d6e:	83 c4 10             	add    $0x10,%esp
c0105d71:	83 ec 08             	sub    $0x8,%esp
c0105d74:	53                   	push   %ebx
c0105d75:	50                   	push   %eax
c0105d76:	e8 96 1e 00 00       	call   c0107c11 <free_pages>
c0105d7b:	83 c4 10             	add    $0x10,%esp
}
c0105d7e:	90                   	nop
c0105d7f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0105d82:	c9                   	leave  
c0105d83:	c3                   	ret    

c0105d84 <slob_alloc>:

static void slob_free(void *b, int size);

static void *slob_alloc(size_t size, gfp_t gfp, int align)
{
c0105d84:	55                   	push   %ebp
c0105d85:	89 e5                	mov    %esp,%ebp
c0105d87:	83 ec 28             	sub    $0x28,%esp
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
c0105d8a:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d8d:	83 c0 08             	add    $0x8,%eax
c0105d90:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c0105d95:	76 16                	jbe    c0105dad <slob_alloc+0x29>
c0105d97:	68 f4 bd 10 c0       	push   $0xc010bdf4
c0105d9c:	68 13 be 10 c0       	push   $0xc010be13
c0105da1:	6a 64                	push   $0x64
c0105da3:	68 28 be 10 c0       	push   $0xc010be28
c0105da8:	e8 af b9 ff ff       	call   c010175c <__panic>

	slob_t *prev, *cur, *aligned = 0;
c0105dad:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	int delta = 0, units = SLOB_UNITS(size);
c0105db4:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0105dbb:	8b 45 08             	mov    0x8(%ebp),%eax
c0105dbe:	83 c0 07             	add    $0x7,%eax
c0105dc1:	c1 e8 03             	shr    $0x3,%eax
c0105dc4:	89 45 e0             	mov    %eax,-0x20(%ebp)
	unsigned long flags;

	spin_lock_irqsave(&slob_lock, flags);
c0105dc7:	e8 0a fe ff ff       	call   c0105bd6 <__intr_save>
c0105dcc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	prev = slobfree;
c0105dcf:	a1 08 7a 12 c0       	mov    0xc0127a08,%eax
c0105dd4:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c0105dd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105dda:	8b 40 04             	mov    0x4(%eax),%eax
c0105ddd:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (align) {
c0105de0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105de4:	74 25                	je     c0105e0b <slob_alloc+0x87>
			aligned = (slob_t *)ALIGN((unsigned long)cur, align);
c0105de6:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105de9:	8b 45 10             	mov    0x10(%ebp),%eax
c0105dec:	01 d0                	add    %edx,%eax
c0105dee:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105df1:	8b 45 10             	mov    0x10(%ebp),%eax
c0105df4:	f7 d8                	neg    %eax
c0105df6:	21 d0                	and    %edx,%eax
c0105df8:	89 45 ec             	mov    %eax,-0x14(%ebp)
			delta = aligned - cur;
c0105dfb:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105dfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e01:	29 c2                	sub    %eax,%edx
c0105e03:	89 d0                	mov    %edx,%eax
c0105e05:	c1 f8 03             	sar    $0x3,%eax
c0105e08:	89 45 e8             	mov    %eax,-0x18(%ebp)
		}
		if (cur->units >= units + delta) { /* room enough? */
c0105e0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e0e:	8b 00                	mov    (%eax),%eax
c0105e10:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0105e13:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0105e16:	01 ca                	add    %ecx,%edx
c0105e18:	39 d0                	cmp    %edx,%eax
c0105e1a:	0f 8c b1 00 00 00    	jl     c0105ed1 <slob_alloc+0x14d>
			if (delta) { /* need to fragment head to align? */
c0105e20:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105e24:	74 38                	je     c0105e5e <slob_alloc+0xda>
				aligned->units = cur->units - delta;
c0105e26:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e29:	8b 00                	mov    (%eax),%eax
c0105e2b:	2b 45 e8             	sub    -0x18(%ebp),%eax
c0105e2e:	89 c2                	mov    %eax,%edx
c0105e30:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105e33:	89 10                	mov    %edx,(%eax)
				aligned->next = cur->next;
c0105e35:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e38:	8b 50 04             	mov    0x4(%eax),%edx
c0105e3b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105e3e:	89 50 04             	mov    %edx,0x4(%eax)
				cur->next = aligned;
c0105e41:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e44:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105e47:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = delta;
c0105e4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e4d:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0105e50:	89 10                	mov    %edx,(%eax)
				prev = cur;
c0105e52:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e55:	89 45 f4             	mov    %eax,-0xc(%ebp)
				cur = aligned;
c0105e58:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105e5b:	89 45 f0             	mov    %eax,-0x10(%ebp)
			}

			if (cur->units == units) /* exact fit? */
c0105e5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e61:	8b 00                	mov    (%eax),%eax
c0105e63:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0105e66:	75 0e                	jne    c0105e76 <slob_alloc+0xf2>
				prev->next = cur->next; /* unlink */
c0105e68:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e6b:	8b 50 04             	mov    0x4(%eax),%edx
c0105e6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105e71:	89 50 04             	mov    %edx,0x4(%eax)
c0105e74:	eb 3c                	jmp    c0105eb2 <slob_alloc+0x12e>
			else { /* fragment */
				prev->next = cur + units;
c0105e76:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105e79:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0105e80:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e83:	01 c2                	add    %eax,%edx
c0105e85:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105e88:	89 50 04             	mov    %edx,0x4(%eax)
				prev->next->units = cur->units - units;
c0105e8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105e8e:	8b 40 04             	mov    0x4(%eax),%eax
c0105e91:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105e94:	8b 12                	mov    (%edx),%edx
c0105e96:	2b 55 e0             	sub    -0x20(%ebp),%edx
c0105e99:	89 10                	mov    %edx,(%eax)
				prev->next->next = cur->next;
c0105e9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105e9e:	8b 40 04             	mov    0x4(%eax),%eax
c0105ea1:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105ea4:	8b 52 04             	mov    0x4(%edx),%edx
c0105ea7:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = units;
c0105eaa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ead:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105eb0:	89 10                	mov    %edx,(%eax)
			}

			slobfree = prev;
c0105eb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105eb5:	a3 08 7a 12 c0       	mov    %eax,0xc0127a08
			spin_unlock_irqrestore(&slob_lock, flags);
c0105eba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105ebd:	83 ec 0c             	sub    $0xc,%esp
c0105ec0:	50                   	push   %eax
c0105ec1:	e8 3a fd ff ff       	call   c0105c00 <__intr_restore>
c0105ec6:	83 c4 10             	add    $0x10,%esp
			return cur;
c0105ec9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ecc:	e9 80 00 00 00       	jmp    c0105f51 <slob_alloc+0x1cd>
		}
		if (cur == slobfree) {
c0105ed1:	a1 08 7a 12 c0       	mov    0xc0127a08,%eax
c0105ed6:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0105ed9:	75 62                	jne    c0105f3d <slob_alloc+0x1b9>
			spin_unlock_irqrestore(&slob_lock, flags);
c0105edb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105ede:	83 ec 0c             	sub    $0xc,%esp
c0105ee1:	50                   	push   %eax
c0105ee2:	e8 19 fd ff ff       	call   c0105c00 <__intr_restore>
c0105ee7:	83 c4 10             	add    $0x10,%esp

			if (size == PAGE_SIZE) /* trying to shrink arena? */
c0105eea:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c0105ef1:	75 07                	jne    c0105efa <slob_alloc+0x176>
				return 0;
c0105ef3:	b8 00 00 00 00       	mov    $0x0,%eax
c0105ef8:	eb 57                	jmp    c0105f51 <slob_alloc+0x1cd>

			cur = (slob_t *)__slob_get_free_page(gfp);
c0105efa:	83 ec 08             	sub    $0x8,%esp
c0105efd:	6a 00                	push   $0x0
c0105eff:	ff 75 0c             	pushl  0xc(%ebp)
c0105f02:	e8 04 fe ff ff       	call   c0105d0b <__slob_get_free_pages>
c0105f07:	83 c4 10             	add    $0x10,%esp
c0105f0a:	89 45 f0             	mov    %eax,-0x10(%ebp)
			if (!cur)
c0105f0d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105f11:	75 07                	jne    c0105f1a <slob_alloc+0x196>
				return 0;
c0105f13:	b8 00 00 00 00       	mov    $0x0,%eax
c0105f18:	eb 37                	jmp    c0105f51 <slob_alloc+0x1cd>

			slob_free(cur, PAGE_SIZE);
c0105f1a:	83 ec 08             	sub    $0x8,%esp
c0105f1d:	68 00 10 00 00       	push   $0x1000
c0105f22:	ff 75 f0             	pushl  -0x10(%ebp)
c0105f25:	e8 29 00 00 00       	call   c0105f53 <slob_free>
c0105f2a:	83 c4 10             	add    $0x10,%esp
			spin_lock_irqsave(&slob_lock, flags);
c0105f2d:	e8 a4 fc ff ff       	call   c0105bd6 <__intr_save>
c0105f32:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			cur = slobfree;
c0105f35:	a1 08 7a 12 c0       	mov    0xc0127a08,%eax
c0105f3a:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int delta = 0, units = SLOB_UNITS(size);
	unsigned long flags;

	spin_lock_irqsave(&slob_lock, flags);
	prev = slobfree;
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c0105f3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105f40:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105f43:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105f46:	8b 40 04             	mov    0x4(%eax),%eax
c0105f49:	89 45 f0             	mov    %eax,-0x10(%ebp)

			slob_free(cur, PAGE_SIZE);
			spin_lock_irqsave(&slob_lock, flags);
			cur = slobfree;
		}
	}
c0105f4c:	e9 8f fe ff ff       	jmp    c0105de0 <slob_alloc+0x5c>
}
c0105f51:	c9                   	leave  
c0105f52:	c3                   	ret    

c0105f53 <slob_free>:

static void slob_free(void *block, int size)
{
c0105f53:	55                   	push   %ebp
c0105f54:	89 e5                	mov    %esp,%ebp
c0105f56:	83 ec 18             	sub    $0x18,%esp
	slob_t *cur, *b = (slob_t *)block;
c0105f59:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f5c:	89 45 f0             	mov    %eax,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c0105f5f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105f63:	0f 84 05 01 00 00    	je     c010606e <slob_free+0x11b>
		return;

	if (size)
c0105f69:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105f6d:	74 10                	je     c0105f7f <slob_free+0x2c>
		b->units = SLOB_UNITS(size);
c0105f6f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105f72:	83 c0 07             	add    $0x7,%eax
c0105f75:	c1 e8 03             	shr    $0x3,%eax
c0105f78:	89 c2                	mov    %eax,%edx
c0105f7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105f7d:	89 10                	mov    %edx,(%eax)

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
c0105f7f:	e8 52 fc ff ff       	call   c0105bd6 <__intr_save>
c0105f84:	89 45 ec             	mov    %eax,-0x14(%ebp)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c0105f87:	a1 08 7a 12 c0       	mov    0xc0127a08,%eax
c0105f8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105f8f:	eb 27                	jmp    c0105fb8 <slob_free+0x65>
		if (cur >= cur->next && (b > cur || b < cur->next))
c0105f91:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105f94:	8b 40 04             	mov    0x4(%eax),%eax
c0105f97:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0105f9a:	77 13                	ja     c0105faf <slob_free+0x5c>
c0105f9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105f9f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0105fa2:	77 27                	ja     c0105fcb <slob_free+0x78>
c0105fa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105fa7:	8b 40 04             	mov    0x4(%eax),%eax
c0105faa:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0105fad:	77 1c                	ja     c0105fcb <slob_free+0x78>
	if (size)
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c0105faf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105fb2:	8b 40 04             	mov    0x4(%eax),%eax
c0105fb5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105fb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105fbb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0105fbe:	76 d1                	jbe    c0105f91 <slob_free+0x3e>
c0105fc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105fc3:	8b 40 04             	mov    0x4(%eax),%eax
c0105fc6:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0105fc9:	76 c6                	jbe    c0105f91 <slob_free+0x3e>
		if (cur >= cur->next && (b > cur || b < cur->next))
			break;

	if (b + b->units == cur->next) {
c0105fcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105fce:	8b 00                	mov    (%eax),%eax
c0105fd0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0105fd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105fda:	01 c2                	add    %eax,%edx
c0105fdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105fdf:	8b 40 04             	mov    0x4(%eax),%eax
c0105fe2:	39 c2                	cmp    %eax,%edx
c0105fe4:	75 25                	jne    c010600b <slob_free+0xb8>
		b->units += cur->next->units;
c0105fe6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105fe9:	8b 10                	mov    (%eax),%edx
c0105feb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105fee:	8b 40 04             	mov    0x4(%eax),%eax
c0105ff1:	8b 00                	mov    (%eax),%eax
c0105ff3:	01 c2                	add    %eax,%edx
c0105ff5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ff8:	89 10                	mov    %edx,(%eax)
		b->next = cur->next->next;
c0105ffa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ffd:	8b 40 04             	mov    0x4(%eax),%eax
c0106000:	8b 50 04             	mov    0x4(%eax),%edx
c0106003:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106006:	89 50 04             	mov    %edx,0x4(%eax)
c0106009:	eb 0c                	jmp    c0106017 <slob_free+0xc4>
	} else
		b->next = cur->next;
c010600b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010600e:	8b 50 04             	mov    0x4(%eax),%edx
c0106011:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106014:	89 50 04             	mov    %edx,0x4(%eax)

	if (cur + cur->units == b) {
c0106017:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010601a:	8b 00                	mov    (%eax),%eax
c010601c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0106023:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106026:	01 d0                	add    %edx,%eax
c0106028:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010602b:	75 1f                	jne    c010604c <slob_free+0xf9>
		cur->units += b->units;
c010602d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106030:	8b 10                	mov    (%eax),%edx
c0106032:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106035:	8b 00                	mov    (%eax),%eax
c0106037:	01 c2                	add    %eax,%edx
c0106039:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010603c:	89 10                	mov    %edx,(%eax)
		cur->next = b->next;
c010603e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106041:	8b 50 04             	mov    0x4(%eax),%edx
c0106044:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106047:	89 50 04             	mov    %edx,0x4(%eax)
c010604a:	eb 09                	jmp    c0106055 <slob_free+0x102>
	} else
		cur->next = b;
c010604c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010604f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0106052:	89 50 04             	mov    %edx,0x4(%eax)

	slobfree = cur;
c0106055:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106058:	a3 08 7a 12 c0       	mov    %eax,0xc0127a08

	spin_unlock_irqrestore(&slob_lock, flags);
c010605d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106060:	83 ec 0c             	sub    $0xc,%esp
c0106063:	50                   	push   %eax
c0106064:	e8 97 fb ff ff       	call   c0105c00 <__intr_restore>
c0106069:	83 c4 10             	add    $0x10,%esp
c010606c:	eb 01                	jmp    c010606f <slob_free+0x11c>
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
		return;
c010606e:	90                   	nop
		cur->next = b;

	slobfree = cur;

	spin_unlock_irqrestore(&slob_lock, flags);
}
c010606f:	c9                   	leave  
c0106070:	c3                   	ret    

c0106071 <check_slab>:



void check_slab(void) {
c0106071:	55                   	push   %ebp
c0106072:	89 e5                	mov    %esp,%ebp
c0106074:	83 ec 08             	sub    $0x8,%esp
  cprintf("check_slab() success\n");
c0106077:	83 ec 0c             	sub    $0xc,%esp
c010607a:	68 3a be 10 c0       	push   $0xc010be3a
c010607f:	e8 fa a1 ff ff       	call   c010027e <cprintf>
c0106084:	83 c4 10             	add    $0x10,%esp
}
c0106087:	90                   	nop
c0106088:	c9                   	leave  
c0106089:	c3                   	ret    

c010608a <slab_init>:

void
slab_init(void) {
c010608a:	55                   	push   %ebp
c010608b:	89 e5                	mov    %esp,%ebp
c010608d:	83 ec 08             	sub    $0x8,%esp
  cprintf("use SLOB allocator\n");
c0106090:	83 ec 0c             	sub    $0xc,%esp
c0106093:	68 50 be 10 c0       	push   $0xc010be50
c0106098:	e8 e1 a1 ff ff       	call   c010027e <cprintf>
c010609d:	83 c4 10             	add    $0x10,%esp
  check_slab();
c01060a0:	e8 cc ff ff ff       	call   c0106071 <check_slab>
}
c01060a5:	90                   	nop
c01060a6:	c9                   	leave  
c01060a7:	c3                   	ret    

c01060a8 <kmalloc_init>:

inline void 
kmalloc_init(void) {
c01060a8:	55                   	push   %ebp
c01060a9:	89 e5                	mov    %esp,%ebp
c01060ab:	83 ec 08             	sub    $0x8,%esp
    slab_init();
c01060ae:	e8 d7 ff ff ff       	call   c010608a <slab_init>
    cprintf("kmalloc_init() succeeded!\n");
c01060b3:	83 ec 0c             	sub    $0xc,%esp
c01060b6:	68 64 be 10 c0       	push   $0xc010be64
c01060bb:	e8 be a1 ff ff       	call   c010027e <cprintf>
c01060c0:	83 c4 10             	add    $0x10,%esp
}
c01060c3:	90                   	nop
c01060c4:	c9                   	leave  
c01060c5:	c3                   	ret    

c01060c6 <slab_allocated>:

size_t
slab_allocated(void) {
c01060c6:	55                   	push   %ebp
c01060c7:	89 e5                	mov    %esp,%ebp
  return 0;
c01060c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01060ce:	5d                   	pop    %ebp
c01060cf:	c3                   	ret    

c01060d0 <kallocated>:

size_t
kallocated(void) {
c01060d0:	55                   	push   %ebp
c01060d1:	89 e5                	mov    %esp,%ebp
   return slab_allocated();
c01060d3:	e8 ee ff ff ff       	call   c01060c6 <slab_allocated>
}
c01060d8:	5d                   	pop    %ebp
c01060d9:	c3                   	ret    

c01060da <find_order>:

static int find_order(int size)
{
c01060da:	55                   	push   %ebp
c01060db:	89 e5                	mov    %esp,%ebp
c01060dd:	83 ec 10             	sub    $0x10,%esp
	int order = 0;
c01060e0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	for ( ; size > 4096 ; size >>=1)
c01060e7:	eb 07                	jmp    c01060f0 <find_order+0x16>
		order++;
c01060e9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
}

static int find_order(int size)
{
	int order = 0;
	for ( ; size > 4096 ; size >>=1)
c01060ed:	d1 7d 08             	sarl   0x8(%ebp)
c01060f0:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c01060f7:	7f f0                	jg     c01060e9 <find_order+0xf>
		order++;
	return order;
c01060f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01060fc:	c9                   	leave  
c01060fd:	c3                   	ret    

c01060fe <__kmalloc>:

static void *__kmalloc(size_t size, gfp_t gfp)
{
c01060fe:	55                   	push   %ebp
c01060ff:	89 e5                	mov    %esp,%ebp
c0106101:	83 ec 18             	sub    $0x18,%esp
	slob_t *m;
	bigblock_t *bb;
	unsigned long flags;

	if (size < PAGE_SIZE - SLOB_UNIT) {
c0106104:	81 7d 08 f7 0f 00 00 	cmpl   $0xff7,0x8(%ebp)
c010610b:	77 35                	ja     c0106142 <__kmalloc+0x44>
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
c010610d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106110:	83 c0 08             	add    $0x8,%eax
c0106113:	83 ec 04             	sub    $0x4,%esp
c0106116:	6a 00                	push   $0x0
c0106118:	ff 75 0c             	pushl  0xc(%ebp)
c010611b:	50                   	push   %eax
c010611c:	e8 63 fc ff ff       	call   c0105d84 <slob_alloc>
c0106121:	83 c4 10             	add    $0x10,%esp
c0106124:	89 45 f4             	mov    %eax,-0xc(%ebp)
		return m ? (void *)(m + 1) : 0;
c0106127:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010612b:	74 0b                	je     c0106138 <__kmalloc+0x3a>
c010612d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106130:	83 c0 08             	add    $0x8,%eax
c0106133:	e9 b3 00 00 00       	jmp    c01061eb <__kmalloc+0xed>
c0106138:	b8 00 00 00 00       	mov    $0x0,%eax
c010613d:	e9 a9 00 00 00       	jmp    c01061eb <__kmalloc+0xed>
	}

	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
c0106142:	83 ec 04             	sub    $0x4,%esp
c0106145:	6a 00                	push   $0x0
c0106147:	ff 75 0c             	pushl  0xc(%ebp)
c010614a:	6a 0c                	push   $0xc
c010614c:	e8 33 fc ff ff       	call   c0105d84 <slob_alloc>
c0106151:	83 c4 10             	add    $0x10,%esp
c0106154:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (!bb)
c0106157:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010615b:	75 0a                	jne    c0106167 <__kmalloc+0x69>
		return 0;
c010615d:	b8 00 00 00 00       	mov    $0x0,%eax
c0106162:	e9 84 00 00 00       	jmp    c01061eb <__kmalloc+0xed>

	bb->order = find_order(size);
c0106167:	8b 45 08             	mov    0x8(%ebp),%eax
c010616a:	83 ec 0c             	sub    $0xc,%esp
c010616d:	50                   	push   %eax
c010616e:	e8 67 ff ff ff       	call   c01060da <find_order>
c0106173:	83 c4 10             	add    $0x10,%esp
c0106176:	89 c2                	mov    %eax,%edx
c0106178:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010617b:	89 10                	mov    %edx,(%eax)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
c010617d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106180:	8b 00                	mov    (%eax),%eax
c0106182:	83 ec 08             	sub    $0x8,%esp
c0106185:	50                   	push   %eax
c0106186:	ff 75 0c             	pushl  0xc(%ebp)
c0106189:	e8 7d fb ff ff       	call   c0105d0b <__slob_get_free_pages>
c010618e:	83 c4 10             	add    $0x10,%esp
c0106191:	89 c2                	mov    %eax,%edx
c0106193:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106196:	89 50 04             	mov    %edx,0x4(%eax)

	if (bb->pages) {
c0106199:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010619c:	8b 40 04             	mov    0x4(%eax),%eax
c010619f:	85 c0                	test   %eax,%eax
c01061a1:	74 33                	je     c01061d6 <__kmalloc+0xd8>
		spin_lock_irqsave(&block_lock, flags);
c01061a3:	e8 2e fa ff ff       	call   c0105bd6 <__intr_save>
c01061a8:	89 45 ec             	mov    %eax,-0x14(%ebp)
		bb->next = bigblocks;
c01061ab:	8b 15 14 8a 12 c0    	mov    0xc0128a14,%edx
c01061b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01061b4:	89 50 08             	mov    %edx,0x8(%eax)
		bigblocks = bb;
c01061b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01061ba:	a3 14 8a 12 c0       	mov    %eax,0xc0128a14
		spin_unlock_irqrestore(&block_lock, flags);
c01061bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01061c2:	83 ec 0c             	sub    $0xc,%esp
c01061c5:	50                   	push   %eax
c01061c6:	e8 35 fa ff ff       	call   c0105c00 <__intr_restore>
c01061cb:	83 c4 10             	add    $0x10,%esp
		return bb->pages;
c01061ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01061d1:	8b 40 04             	mov    0x4(%eax),%eax
c01061d4:	eb 15                	jmp    c01061eb <__kmalloc+0xed>
	}

	slob_free(bb, sizeof(bigblock_t));
c01061d6:	83 ec 08             	sub    $0x8,%esp
c01061d9:	6a 0c                	push   $0xc
c01061db:	ff 75 f0             	pushl  -0x10(%ebp)
c01061de:	e8 70 fd ff ff       	call   c0105f53 <slob_free>
c01061e3:	83 c4 10             	add    $0x10,%esp
	return 0;
c01061e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01061eb:	c9                   	leave  
c01061ec:	c3                   	ret    

c01061ed <kmalloc>:

void *
kmalloc(size_t size)
{
c01061ed:	55                   	push   %ebp
c01061ee:	89 e5                	mov    %esp,%ebp
c01061f0:	83 ec 08             	sub    $0x8,%esp
  return __kmalloc(size, 0);
c01061f3:	83 ec 08             	sub    $0x8,%esp
c01061f6:	6a 00                	push   $0x0
c01061f8:	ff 75 08             	pushl  0x8(%ebp)
c01061fb:	e8 fe fe ff ff       	call   c01060fe <__kmalloc>
c0106200:	83 c4 10             	add    $0x10,%esp
}
c0106203:	c9                   	leave  
c0106204:	c3                   	ret    

c0106205 <kfree>:


void kfree(void *block)
{
c0106205:	55                   	push   %ebp
c0106206:	89 e5                	mov    %esp,%ebp
c0106208:	83 ec 18             	sub    $0x18,%esp
	bigblock_t *bb, **last = &bigblocks;
c010620b:	c7 45 f0 14 8a 12 c0 	movl   $0xc0128a14,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c0106212:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0106216:	0f 84 ac 00 00 00    	je     c01062c8 <kfree+0xc3>
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c010621c:	8b 45 08             	mov    0x8(%ebp),%eax
c010621f:	25 ff 0f 00 00       	and    $0xfff,%eax
c0106224:	85 c0                	test   %eax,%eax
c0106226:	0f 85 85 00 00 00    	jne    c01062b1 <kfree+0xac>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
c010622c:	e8 a5 f9 ff ff       	call   c0105bd6 <__intr_save>
c0106231:	89 45 ec             	mov    %eax,-0x14(%ebp)
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c0106234:	a1 14 8a 12 c0       	mov    0xc0128a14,%eax
c0106239:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010623c:	eb 5e                	jmp    c010629c <kfree+0x97>
			if (bb->pages == block) {
c010623e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106241:	8b 40 04             	mov    0x4(%eax),%eax
c0106244:	3b 45 08             	cmp    0x8(%ebp),%eax
c0106247:	75 41                	jne    c010628a <kfree+0x85>
				*last = bb->next;
c0106249:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010624c:	8b 50 08             	mov    0x8(%eax),%edx
c010624f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106252:	89 10                	mov    %edx,(%eax)
				spin_unlock_irqrestore(&block_lock, flags);
c0106254:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106257:	83 ec 0c             	sub    $0xc,%esp
c010625a:	50                   	push   %eax
c010625b:	e8 a0 f9 ff ff       	call   c0105c00 <__intr_restore>
c0106260:	83 c4 10             	add    $0x10,%esp
				__slob_free_pages((unsigned long)block, bb->order);
c0106263:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106266:	8b 10                	mov    (%eax),%edx
c0106268:	8b 45 08             	mov    0x8(%ebp),%eax
c010626b:	83 ec 08             	sub    $0x8,%esp
c010626e:	52                   	push   %edx
c010626f:	50                   	push   %eax
c0106270:	e8 d6 fa ff ff       	call   c0105d4b <__slob_free_pages>
c0106275:	83 c4 10             	add    $0x10,%esp
				slob_free(bb, sizeof(bigblock_t));
c0106278:	83 ec 08             	sub    $0x8,%esp
c010627b:	6a 0c                	push   $0xc
c010627d:	ff 75 f4             	pushl  -0xc(%ebp)
c0106280:	e8 ce fc ff ff       	call   c0105f53 <slob_free>
c0106285:	83 c4 10             	add    $0x10,%esp
				return;
c0106288:	eb 3f                	jmp    c01062c9 <kfree+0xc4>
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c010628a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010628d:	83 c0 08             	add    $0x8,%eax
c0106290:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106293:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106296:	8b 40 08             	mov    0x8(%eax),%eax
c0106299:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010629c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01062a0:	75 9c                	jne    c010623e <kfree+0x39>
				__slob_free_pages((unsigned long)block, bb->order);
				slob_free(bb, sizeof(bigblock_t));
				return;
			}
		}
		spin_unlock_irqrestore(&block_lock, flags);
c01062a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01062a5:	83 ec 0c             	sub    $0xc,%esp
c01062a8:	50                   	push   %eax
c01062a9:	e8 52 f9 ff ff       	call   c0105c00 <__intr_restore>
c01062ae:	83 c4 10             	add    $0x10,%esp
	}

	slob_free((slob_t *)block - 1, 0);
c01062b1:	8b 45 08             	mov    0x8(%ebp),%eax
c01062b4:	83 e8 08             	sub    $0x8,%eax
c01062b7:	83 ec 08             	sub    $0x8,%esp
c01062ba:	6a 00                	push   $0x0
c01062bc:	50                   	push   %eax
c01062bd:	e8 91 fc ff ff       	call   c0105f53 <slob_free>
c01062c2:	83 c4 10             	add    $0x10,%esp
	return;
c01062c5:	90                   	nop
c01062c6:	eb 01                	jmp    c01062c9 <kfree+0xc4>
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
		return;
c01062c8:	90                   	nop
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
c01062c9:	c9                   	leave  
c01062ca:	c3                   	ret    

c01062cb <ksize>:


unsigned int ksize(const void *block)
{
c01062cb:	55                   	push   %ebp
c01062cc:	89 e5                	mov    %esp,%ebp
c01062ce:	83 ec 18             	sub    $0x18,%esp
	bigblock_t *bb;
	unsigned long flags;

	if (!block)
c01062d1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01062d5:	75 07                	jne    c01062de <ksize+0x13>
		return 0;
c01062d7:	b8 00 00 00 00       	mov    $0x0,%eax
c01062dc:	eb 73                	jmp    c0106351 <ksize+0x86>

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c01062de:	8b 45 08             	mov    0x8(%ebp),%eax
c01062e1:	25 ff 0f 00 00       	and    $0xfff,%eax
c01062e6:	85 c0                	test   %eax,%eax
c01062e8:	75 5c                	jne    c0106346 <ksize+0x7b>
		spin_lock_irqsave(&block_lock, flags);
c01062ea:	e8 e7 f8 ff ff       	call   c0105bd6 <__intr_save>
c01062ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
		for (bb = bigblocks; bb; bb = bb->next)
c01062f2:	a1 14 8a 12 c0       	mov    0xc0128a14,%eax
c01062f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01062fa:	eb 35                	jmp    c0106331 <ksize+0x66>
			if (bb->pages == block) {
c01062fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01062ff:	8b 40 04             	mov    0x4(%eax),%eax
c0106302:	3b 45 08             	cmp    0x8(%ebp),%eax
c0106305:	75 21                	jne    c0106328 <ksize+0x5d>
				spin_unlock_irqrestore(&slob_lock, flags);
c0106307:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010630a:	83 ec 0c             	sub    $0xc,%esp
c010630d:	50                   	push   %eax
c010630e:	e8 ed f8 ff ff       	call   c0105c00 <__intr_restore>
c0106313:	83 c4 10             	add    $0x10,%esp
				return PAGE_SIZE << bb->order;
c0106316:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106319:	8b 00                	mov    (%eax),%eax
c010631b:	ba 00 10 00 00       	mov    $0x1000,%edx
c0106320:	89 c1                	mov    %eax,%ecx
c0106322:	d3 e2                	shl    %cl,%edx
c0106324:	89 d0                	mov    %edx,%eax
c0106326:	eb 29                	jmp    c0106351 <ksize+0x86>
	if (!block)
		return 0;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; bb = bb->next)
c0106328:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010632b:	8b 40 08             	mov    0x8(%eax),%eax
c010632e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106331:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106335:	75 c5                	jne    c01062fc <ksize+0x31>
			if (bb->pages == block) {
				spin_unlock_irqrestore(&slob_lock, flags);
				return PAGE_SIZE << bb->order;
			}
		spin_unlock_irqrestore(&block_lock, flags);
c0106337:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010633a:	83 ec 0c             	sub    $0xc,%esp
c010633d:	50                   	push   %eax
c010633e:	e8 bd f8 ff ff       	call   c0105c00 <__intr_restore>
c0106343:	83 c4 10             	add    $0x10,%esp
	}

	return ((slob_t *)block - 1)->units * SLOB_UNIT;
c0106346:	8b 45 08             	mov    0x8(%ebp),%eax
c0106349:	83 e8 08             	sub    $0x8,%eax
c010634c:	8b 00                	mov    (%eax),%eax
c010634e:	c1 e0 03             	shl    $0x3,%eax
}
c0106351:	c9                   	leave  
c0106352:	c3                   	ret    

c0106353 <_fifo_init_mm>:
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{
c0106353:	55                   	push   %ebp
c0106354:	89 e5                	mov    %esp,%ebp
c0106356:	83 ec 10             	sub    $0x10,%esp
c0106359:	c7 45 fc c4 ab 12 c0 	movl   $0xc012abc4,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0106360:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106363:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0106366:	89 50 04             	mov    %edx,0x4(%eax)
c0106369:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010636c:	8b 50 04             	mov    0x4(%eax),%edx
c010636f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106372:	89 10                	mov    %edx,(%eax)
    list_init(&pra_list_head);//先将按访问时间排序的链表进行初始化
    mm->sm_priv = &pra_list_head;//把mm变量指向用来链接记录页访问情况的属性指向该链表
c0106374:	8b 45 08             	mov    0x8(%ebp),%eax
c0106377:	c7 40 14 c4 ab 12 c0 	movl   $0xc012abc4,0x14(%eax)
    //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
    return 0;
c010637e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106383:	c9                   	leave  
c0106384:	c3                   	ret    

c0106385 <_fifo_map_swappable>:
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
//将最近被用到的页面添加到算法所维护的次序队列。
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0106385:	55                   	push   %ebp
c0106386:	89 e5                	mov    %esp,%ebp
c0106388:	83 ec 38             	sub    $0x38,%esp
    list_entry_t *head=(list_entry_t*) mm->sm_priv;//获取页访问情况的链表头
c010638b:	8b 45 08             	mov    0x8(%ebp),%eax
c010638e:	8b 40 14             	mov    0x14(%eax),%eax
c0106391:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *entry=&(page->pra_page_link);//获取最近被使用到的页面
c0106394:	8b 45 10             	mov    0x10(%ebp),%eax
c0106397:	83 c0 18             	add    $0x18,%eax
c010639a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(entry != NULL && head != NULL);
c010639d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01063a1:	74 06                	je     c01063a9 <_fifo_map_swappable+0x24>
c01063a3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01063a7:	75 16                	jne    c01063bf <_fifo_map_swappable+0x3a>
c01063a9:	68 80 be 10 c0       	push   $0xc010be80
c01063ae:	68 9e be 10 c0       	push   $0xc010be9e
c01063b3:	6a 32                	push   $0x32
c01063b5:	68 b3 be 10 c0       	push   $0xc010beb3
c01063ba:	e8 9d b3 ff ff       	call   c010175c <__panic>
c01063bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01063c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01063c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01063c8:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01063cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01063ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01063d1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01063d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c01063d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01063da:	8b 40 04             	mov    0x4(%eax),%eax
c01063dd:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01063e0:	89 55 dc             	mov    %edx,-0x24(%ebp)
c01063e3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01063e6:	89 55 d8             	mov    %edx,-0x28(%ebp)
c01063e9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01063ec:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01063ef:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01063f2:	89 10                	mov    %edx,(%eax)
c01063f4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01063f7:	8b 10                	mov    (%eax),%edx
c01063f9:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01063fc:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01063ff:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106402:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106405:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0106408:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010640b:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010640e:	89 10                	mov    %edx,(%eax)
    list_add(head, entry);//头插，将最近被用到的页面添加到记录页访问情况的链表

    //record the page access situlation
    /*LAB3 EXERCISE 2: YOUR CODE*/
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
    return 0;
c0106410:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106415:	c9                   	leave  
c0106416:	c3                   	ret    

c0106417 <_fifo_swap_out_victim>:
 *                            then set the addr of addr of this page to ptr_page.
 */
//查询哪个页面需要被换出。
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
c0106417:	55                   	push   %ebp
c0106418:	89 e5                	mov    %esp,%ebp
c010641a:	83 ec 28             	sub    $0x28,%esp
    list_entry_t *head=(list_entry_t*) mm->sm_priv;//获取按访问时间排序的链表
c010641d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106420:	8b 40 14             	mov    0x14(%eax),%eax
c0106423:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(head != NULL);
c0106426:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010642a:	75 16                	jne    c0106442 <_fifo_swap_out_victim+0x2b>
c010642c:	68 c7 be 10 c0       	push   $0xc010bec7
c0106431:	68 9e be 10 c0       	push   $0xc010be9e
c0106436:	6a 43                	push   $0x43
c0106438:	68 b3 be 10 c0       	push   $0xc010beb3
c010643d:	e8 1a b3 ff ff       	call   c010175c <__panic>
    assert(in_tick==0);
c0106442:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106446:	74 16                	je     c010645e <_fifo_swap_out_victim+0x47>
c0106448:	68 d4 be 10 c0       	push   $0xc010bed4
c010644d:	68 9e be 10 c0       	push   $0xc010be9e
c0106452:	6a 44                	push   $0x44
c0106454:	68 b3 be 10 c0       	push   $0xc010beb3
c0106459:	e8 fe b2 ff ff       	call   c010175c <__panic>
    list_entry_t *le = head->prev; //找到要被换出的页（即链表尾，找的是第一次访问时间最远的页）
c010645e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106461:	8b 00                	mov    (%eax),%eax
c0106463:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(head != le);
c0106466:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106469:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010646c:	75 16                	jne    c0106484 <_fifo_swap_out_victim+0x6d>
c010646e:	68 df be 10 c0       	push   $0xc010bedf
c0106473:	68 9e be 10 c0       	push   $0xc010be9e
c0106478:	6a 46                	push   $0x46
c010647a:	68 b3 be 10 c0       	push   $0xc010beb3
c010647f:	e8 d8 b2 ff ff       	call   c010175c <__panic>
    struct Page *p = le2page(le,pra_page_link); //找到page结构的head
c0106484:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106487:	83 e8 18             	sub    $0x18,%eax
c010648a:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010648d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106490:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0106493:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106496:	8b 40 04             	mov    0x4(%eax),%eax
c0106499:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010649c:	8b 12                	mov    (%edx),%edx
c010649e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c01064a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01064a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01064a7:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01064aa:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01064ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01064b0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01064b3:	89 10                	mov    %edx,(%eax)
    list_del(le);
    assert (p != NULL);
c01064b5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01064b9:	75 16                	jne    c01064d1 <_fifo_swap_out_victim+0xba>
c01064bb:	68 ea be 10 c0       	push   $0xc010beea
c01064c0:	68 9e be 10 c0       	push   $0xc010be9e
c01064c5:	6a 49                	push   $0x49
c01064c7:	68 b3 be 10 c0       	push   $0xc010beb3
c01064cc:	e8 8b b2 ff ff       	call   c010175c <__panic>
    *ptr_page = p;
c01064d1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01064d4:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01064d7:	89 10                	mov    %edx,(%eax)
    /* Select the victim */
    /*LAB3 EXERCISE 2: YOUR CODE*/
    //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
    //(2)  set the addr of addr of this page to ptr_page
    return 0;
c01064d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01064de:	c9                   	leave  
c01064df:	c3                   	ret    

c01064e0 <_fifo_check_swap>:

static int
_fifo_check_swap(void) {
c01064e0:	55                   	push   %ebp
c01064e1:	89 e5                	mov    %esp,%ebp
c01064e3:	83 ec 08             	sub    $0x8,%esp
    cprintf("write Virt Page c in fifo_check_swap\n");
c01064e6:	83 ec 0c             	sub    $0xc,%esp
c01064e9:	68 f4 be 10 c0       	push   $0xc010bef4
c01064ee:	e8 8b 9d ff ff       	call   c010027e <cprintf>
c01064f3:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x3000 = 0x0c;
c01064f6:	b8 00 30 00 00       	mov    $0x3000,%eax
c01064fb:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==4);
c01064fe:	a1 04 8a 12 c0       	mov    0xc0128a04,%eax
c0106503:	83 f8 04             	cmp    $0x4,%eax
c0106506:	74 16                	je     c010651e <_fifo_check_swap+0x3e>
c0106508:	68 1a bf 10 c0       	push   $0xc010bf1a
c010650d:	68 9e be 10 c0       	push   $0xc010be9e
c0106512:	6a 56                	push   $0x56
c0106514:	68 b3 be 10 c0       	push   $0xc010beb3
c0106519:	e8 3e b2 ff ff       	call   c010175c <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c010651e:	83 ec 0c             	sub    $0xc,%esp
c0106521:	68 2c bf 10 c0       	push   $0xc010bf2c
c0106526:	e8 53 9d ff ff       	call   c010027e <cprintf>
c010652b:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x1000 = 0x0a;
c010652e:	b8 00 10 00 00       	mov    $0x1000,%eax
c0106533:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==4);
c0106536:	a1 04 8a 12 c0       	mov    0xc0128a04,%eax
c010653b:	83 f8 04             	cmp    $0x4,%eax
c010653e:	74 16                	je     c0106556 <_fifo_check_swap+0x76>
c0106540:	68 1a bf 10 c0       	push   $0xc010bf1a
c0106545:	68 9e be 10 c0       	push   $0xc010be9e
c010654a:	6a 59                	push   $0x59
c010654c:	68 b3 be 10 c0       	push   $0xc010beb3
c0106551:	e8 06 b2 ff ff       	call   c010175c <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0106556:	83 ec 0c             	sub    $0xc,%esp
c0106559:	68 54 bf 10 c0       	push   $0xc010bf54
c010655e:	e8 1b 9d ff ff       	call   c010027e <cprintf>
c0106563:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x4000 = 0x0d;
c0106566:	b8 00 40 00 00       	mov    $0x4000,%eax
c010656b:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==4);
c010656e:	a1 04 8a 12 c0       	mov    0xc0128a04,%eax
c0106573:	83 f8 04             	cmp    $0x4,%eax
c0106576:	74 16                	je     c010658e <_fifo_check_swap+0xae>
c0106578:	68 1a bf 10 c0       	push   $0xc010bf1a
c010657d:	68 9e be 10 c0       	push   $0xc010be9e
c0106582:	6a 5c                	push   $0x5c
c0106584:	68 b3 be 10 c0       	push   $0xc010beb3
c0106589:	e8 ce b1 ff ff       	call   c010175c <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c010658e:	83 ec 0c             	sub    $0xc,%esp
c0106591:	68 7c bf 10 c0       	push   $0xc010bf7c
c0106596:	e8 e3 9c ff ff       	call   c010027e <cprintf>
c010659b:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x2000 = 0x0b;
c010659e:	b8 00 20 00 00       	mov    $0x2000,%eax
c01065a3:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==4);
c01065a6:	a1 04 8a 12 c0       	mov    0xc0128a04,%eax
c01065ab:	83 f8 04             	cmp    $0x4,%eax
c01065ae:	74 16                	je     c01065c6 <_fifo_check_swap+0xe6>
c01065b0:	68 1a bf 10 c0       	push   $0xc010bf1a
c01065b5:	68 9e be 10 c0       	push   $0xc010be9e
c01065ba:	6a 5f                	push   $0x5f
c01065bc:	68 b3 be 10 c0       	push   $0xc010beb3
c01065c1:	e8 96 b1 ff ff       	call   c010175c <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c01065c6:	83 ec 0c             	sub    $0xc,%esp
c01065c9:	68 a4 bf 10 c0       	push   $0xc010bfa4
c01065ce:	e8 ab 9c ff ff       	call   c010027e <cprintf>
c01065d3:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x5000 = 0x0e;
c01065d6:	b8 00 50 00 00       	mov    $0x5000,%eax
c01065db:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==5);
c01065de:	a1 04 8a 12 c0       	mov    0xc0128a04,%eax
c01065e3:	83 f8 05             	cmp    $0x5,%eax
c01065e6:	74 16                	je     c01065fe <_fifo_check_swap+0x11e>
c01065e8:	68 ca bf 10 c0       	push   $0xc010bfca
c01065ed:	68 9e be 10 c0       	push   $0xc010be9e
c01065f2:	6a 62                	push   $0x62
c01065f4:	68 b3 be 10 c0       	push   $0xc010beb3
c01065f9:	e8 5e b1 ff ff       	call   c010175c <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c01065fe:	83 ec 0c             	sub    $0xc,%esp
c0106601:	68 7c bf 10 c0       	push   $0xc010bf7c
c0106606:	e8 73 9c ff ff       	call   c010027e <cprintf>
c010660b:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x2000 = 0x0b;
c010660e:	b8 00 20 00 00       	mov    $0x2000,%eax
c0106613:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==5);
c0106616:	a1 04 8a 12 c0       	mov    0xc0128a04,%eax
c010661b:	83 f8 05             	cmp    $0x5,%eax
c010661e:	74 16                	je     c0106636 <_fifo_check_swap+0x156>
c0106620:	68 ca bf 10 c0       	push   $0xc010bfca
c0106625:	68 9e be 10 c0       	push   $0xc010be9e
c010662a:	6a 65                	push   $0x65
c010662c:	68 b3 be 10 c0       	push   $0xc010beb3
c0106631:	e8 26 b1 ff ff       	call   c010175c <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0106636:	83 ec 0c             	sub    $0xc,%esp
c0106639:	68 2c bf 10 c0       	push   $0xc010bf2c
c010663e:	e8 3b 9c ff ff       	call   c010027e <cprintf>
c0106643:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x1000 = 0x0a;
c0106646:	b8 00 10 00 00       	mov    $0x1000,%eax
c010664b:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==6);
c010664e:	a1 04 8a 12 c0       	mov    0xc0128a04,%eax
c0106653:	83 f8 06             	cmp    $0x6,%eax
c0106656:	74 16                	je     c010666e <_fifo_check_swap+0x18e>
c0106658:	68 d9 bf 10 c0       	push   $0xc010bfd9
c010665d:	68 9e be 10 c0       	push   $0xc010be9e
c0106662:	6a 68                	push   $0x68
c0106664:	68 b3 be 10 c0       	push   $0xc010beb3
c0106669:	e8 ee b0 ff ff       	call   c010175c <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c010666e:	83 ec 0c             	sub    $0xc,%esp
c0106671:	68 7c bf 10 c0       	push   $0xc010bf7c
c0106676:	e8 03 9c ff ff       	call   c010027e <cprintf>
c010667b:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x2000 = 0x0b;
c010667e:	b8 00 20 00 00       	mov    $0x2000,%eax
c0106683:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==7);
c0106686:	a1 04 8a 12 c0       	mov    0xc0128a04,%eax
c010668b:	83 f8 07             	cmp    $0x7,%eax
c010668e:	74 16                	je     c01066a6 <_fifo_check_swap+0x1c6>
c0106690:	68 e8 bf 10 c0       	push   $0xc010bfe8
c0106695:	68 9e be 10 c0       	push   $0xc010be9e
c010669a:	6a 6b                	push   $0x6b
c010669c:	68 b3 be 10 c0       	push   $0xc010beb3
c01066a1:	e8 b6 b0 ff ff       	call   c010175c <__panic>
    cprintf("write Virt Page c in fifo_check_swap\n");
c01066a6:	83 ec 0c             	sub    $0xc,%esp
c01066a9:	68 f4 be 10 c0       	push   $0xc010bef4
c01066ae:	e8 cb 9b ff ff       	call   c010027e <cprintf>
c01066b3:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x3000 = 0x0c;
c01066b6:	b8 00 30 00 00       	mov    $0x3000,%eax
c01066bb:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==8);
c01066be:	a1 04 8a 12 c0       	mov    0xc0128a04,%eax
c01066c3:	83 f8 08             	cmp    $0x8,%eax
c01066c6:	74 16                	je     c01066de <_fifo_check_swap+0x1fe>
c01066c8:	68 f7 bf 10 c0       	push   $0xc010bff7
c01066cd:	68 9e be 10 c0       	push   $0xc010be9e
c01066d2:	6a 6e                	push   $0x6e
c01066d4:	68 b3 be 10 c0       	push   $0xc010beb3
c01066d9:	e8 7e b0 ff ff       	call   c010175c <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c01066de:	83 ec 0c             	sub    $0xc,%esp
c01066e1:	68 54 bf 10 c0       	push   $0xc010bf54
c01066e6:	e8 93 9b ff ff       	call   c010027e <cprintf>
c01066eb:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x4000 = 0x0d;
c01066ee:	b8 00 40 00 00       	mov    $0x4000,%eax
c01066f3:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==9);
c01066f6:	a1 04 8a 12 c0       	mov    0xc0128a04,%eax
c01066fb:	83 f8 09             	cmp    $0x9,%eax
c01066fe:	74 16                	je     c0106716 <_fifo_check_swap+0x236>
c0106700:	68 06 c0 10 c0       	push   $0xc010c006
c0106705:	68 9e be 10 c0       	push   $0xc010be9e
c010670a:	6a 71                	push   $0x71
c010670c:	68 b3 be 10 c0       	push   $0xc010beb3
c0106711:	e8 46 b0 ff ff       	call   c010175c <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0106716:	83 ec 0c             	sub    $0xc,%esp
c0106719:	68 a4 bf 10 c0       	push   $0xc010bfa4
c010671e:	e8 5b 9b ff ff       	call   c010027e <cprintf>
c0106723:	83 c4 10             	add    $0x10,%esp
    *(unsigned char *)0x5000 = 0x0e;
c0106726:	b8 00 50 00 00       	mov    $0x5000,%eax
c010672b:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==10);
c010672e:	a1 04 8a 12 c0       	mov    0xc0128a04,%eax
c0106733:	83 f8 0a             	cmp    $0xa,%eax
c0106736:	74 16                	je     c010674e <_fifo_check_swap+0x26e>
c0106738:	68 15 c0 10 c0       	push   $0xc010c015
c010673d:	68 9e be 10 c0       	push   $0xc010be9e
c0106742:	6a 74                	push   $0x74
c0106744:	68 b3 be 10 c0       	push   $0xc010beb3
c0106749:	e8 0e b0 ff ff       	call   c010175c <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c010674e:	83 ec 0c             	sub    $0xc,%esp
c0106751:	68 2c bf 10 c0       	push   $0xc010bf2c
c0106756:	e8 23 9b ff ff       	call   c010027e <cprintf>
c010675b:	83 c4 10             	add    $0x10,%esp
    assert(*(unsigned char *)0x1000 == 0x0a);
c010675e:	b8 00 10 00 00       	mov    $0x1000,%eax
c0106763:	0f b6 00             	movzbl (%eax),%eax
c0106766:	3c 0a                	cmp    $0xa,%al
c0106768:	74 16                	je     c0106780 <_fifo_check_swap+0x2a0>
c010676a:	68 28 c0 10 c0       	push   $0xc010c028
c010676f:	68 9e be 10 c0       	push   $0xc010be9e
c0106774:	6a 76                	push   $0x76
c0106776:	68 b3 be 10 c0       	push   $0xc010beb3
c010677b:	e8 dc af ff ff       	call   c010175c <__panic>
    *(unsigned char *)0x1000 = 0x0a;
c0106780:	b8 00 10 00 00       	mov    $0x1000,%eax
c0106785:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==11);
c0106788:	a1 04 8a 12 c0       	mov    0xc0128a04,%eax
c010678d:	83 f8 0b             	cmp    $0xb,%eax
c0106790:	74 16                	je     c01067a8 <_fifo_check_swap+0x2c8>
c0106792:	68 49 c0 10 c0       	push   $0xc010c049
c0106797:	68 9e be 10 c0       	push   $0xc010be9e
c010679c:	6a 78                	push   $0x78
c010679e:	68 b3 be 10 c0       	push   $0xc010beb3
c01067a3:	e8 b4 af ff ff       	call   c010175c <__panic>
    return 0;
c01067a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01067ad:	c9                   	leave  
c01067ae:	c3                   	ret    

c01067af <_fifo_init>:


static int
_fifo_init(void)
{
c01067af:	55                   	push   %ebp
c01067b0:	89 e5                	mov    %esp,%ebp
    return 0;
c01067b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01067b7:	5d                   	pop    %ebp
c01067b8:	c3                   	ret    

c01067b9 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c01067b9:	55                   	push   %ebp
c01067ba:	89 e5                	mov    %esp,%ebp
    return 0;
c01067bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01067c1:	5d                   	pop    %ebp
c01067c2:	c3                   	ret    

c01067c3 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
c01067c3:	55                   	push   %ebp
c01067c4:	89 e5                	mov    %esp,%ebp
c01067c6:	b8 00 00 00 00       	mov    $0x0,%eax
c01067cb:	5d                   	pop    %ebp
c01067cc:	c3                   	ret    

c01067cd <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c01067cd:	55                   	push   %ebp
c01067ce:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01067d0:	8b 45 08             	mov    0x8(%ebp),%eax
c01067d3:	8b 15 e0 ab 12 c0    	mov    0xc012abe0,%edx
c01067d9:	29 d0                	sub    %edx,%eax
c01067db:	c1 f8 02             	sar    $0x2,%eax
c01067de:	69 c0 39 8e e3 38    	imul   $0x38e38e39,%eax,%eax
}
c01067e4:	5d                   	pop    %ebp
c01067e5:	c3                   	ret    

c01067e6 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c01067e6:	55                   	push   %ebp
c01067e7:	89 e5                	mov    %esp,%ebp
    return page2ppn(page) << PGSHIFT;
c01067e9:	ff 75 08             	pushl  0x8(%ebp)
c01067ec:	e8 dc ff ff ff       	call   c01067cd <page2ppn>
c01067f1:	83 c4 04             	add    $0x4,%esp
c01067f4:	c1 e0 0c             	shl    $0xc,%eax
}
c01067f7:	c9                   	leave  
c01067f8:	c3                   	ret    

c01067f9 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c01067f9:	55                   	push   %ebp
c01067fa:	89 e5                	mov    %esp,%ebp
    return page->ref;
c01067fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01067ff:	8b 00                	mov    (%eax),%eax
}
c0106801:	5d                   	pop    %ebp
c0106802:	c3                   	ret    

c0106803 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0106803:	55                   	push   %ebp
c0106804:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0106806:	8b 45 08             	mov    0x8(%ebp),%eax
c0106809:	8b 55 0c             	mov    0xc(%ebp),%edx
c010680c:	89 10                	mov    %edx,(%eax)
}
c010680e:	90                   	nop
c010680f:	5d                   	pop    %ebp
c0106810:	c3                   	ret    

c0106811 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c0106811:	55                   	push   %ebp
c0106812:	89 e5                	mov    %esp,%ebp
c0106814:	83 ec 10             	sub    $0x10,%esp
c0106817:	c7 45 fc cc ab 12 c0 	movl   $0xc012abcc,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010681e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106821:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0106824:	89 50 04             	mov    %edx,0x4(%eax)
c0106827:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010682a:	8b 50 04             	mov    0x4(%eax),%edx
c010682d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106830:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c0106832:	c7 05 d4 ab 12 c0 00 	movl   $0x0,0xc012abd4
c0106839:	00 00 00 
}
c010683c:	90                   	nop
c010683d:	c9                   	leave  
c010683e:	c3                   	ret    

c010683f <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c010683f:	55                   	push   %ebp
c0106840:	89 e5                	mov    %esp,%ebp
c0106842:	83 ec 48             	sub    $0x48,%esp
// 传进来的第一个参数是某个连续地址的空闲块的起始页
    // 第二个参数是页个数
    assert(n > 0);
c0106845:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0106849:	75 16                	jne    c0106861 <default_init_memmap+0x22>
c010684b:	68 6c c0 10 c0       	push   $0xc010c06c
c0106850:	68 72 c0 10 c0       	push   $0xc010c072
c0106855:	6a 48                	push   $0x48
c0106857:	68 87 c0 10 c0       	push   $0xc010c087
c010685c:	e8 fb ae ff ff       	call   c010175c <__panic>
    struct Page *p = base;
c0106861:	8b 45 08             	mov    0x8(%ebp),%eax
c0106864:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0106867:	eb 6c                	jmp    c01068d5 <default_init_memmap+0x96>
        assert(PageReserved(p)); // 判断此页是否为保留页
c0106869:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010686c:	83 c0 04             	add    $0x4,%eax
c010686f:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0106876:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106879:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010687c:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010687f:	0f a3 10             	bt     %edx,(%eax)
c0106882:	19 c0                	sbb    %eax,%eax
c0106884:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return oldbit != 0;
c0106887:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c010688b:	0f 95 c0             	setne  %al
c010688e:	0f b6 c0             	movzbl %al,%eax
c0106891:	85 c0                	test   %eax,%eax
c0106893:	75 16                	jne    c01068ab <default_init_memmap+0x6c>
c0106895:	68 9d c0 10 c0       	push   $0xc010c09d
c010689a:	68 72 c0 10 c0       	push   $0xc010c072
c010689f:	6a 4b                	push   $0x4b
c01068a1:	68 87 c0 10 c0       	push   $0xc010c087
c01068a6:	e8 b1 ae ff ff       	call   c010175c <__panic>
        p->flags = p->property = 0; // flag位与块内空闲页个数初始化
c01068ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01068ae:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c01068b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01068b8:	8b 50 08             	mov    0x8(%eax),%edx
c01068bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01068be:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0); // page->ref = val;
c01068c1:	83 ec 08             	sub    $0x8,%esp
c01068c4:	6a 00                	push   $0x0
c01068c6:	ff 75 f4             	pushl  -0xc(%ebp)
c01068c9:	e8 35 ff ff ff       	call   c0106803 <set_page_ref>
c01068ce:	83 c4 10             	add    $0x10,%esp
default_init_memmap(struct Page *base, size_t n) {
// 传进来的第一个参数是某个连续地址的空闲块的起始页
    // 第二个参数是页个数
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c01068d1:	83 45 f4 24          	addl   $0x24,-0xc(%ebp)
c01068d5:	8b 55 0c             	mov    0xc(%ebp),%edx
c01068d8:	89 d0                	mov    %edx,%eax
c01068da:	c1 e0 03             	shl    $0x3,%eax
c01068dd:	01 d0                	add    %edx,%eax
c01068df:	c1 e0 02             	shl    $0x2,%eax
c01068e2:	89 c2                	mov    %eax,%edx
c01068e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01068e7:	01 d0                	add    %edx,%eax
c01068e9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01068ec:	0f 85 77 ff ff ff    	jne    c0106869 <default_init_memmap+0x2a>
        assert(PageReserved(p)); // 判断此页是否为保留页
        p->flags = p->property = 0; // flag位与块内空闲页个数初始化
        set_page_ref(p, 0); // page->ref = val;
    }
    base->property = n;
c01068f2:	8b 45 08             	mov    0x8(%ebp),%eax
c01068f5:	8b 55 0c             	mov    0xc(%ebp),%edx
c01068f8:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base); // 将其标记为已占有的物理内存空间
c01068fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01068fe:	83 c0 04             	add    $0x4,%eax
c0106901:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
c0106908:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010690b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010690e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106911:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
c0106914:	8b 15 d4 ab 12 c0    	mov    0xc012abd4,%edx
c010691a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010691d:	01 d0                	add    %edx,%eax
c010691f:	a3 d4 ab 12 c0       	mov    %eax,0xc012abd4
    list_add(&free_list, &(base->page_link)); // 运用头插法将空闲块插入链表
c0106924:	8b 45 08             	mov    0x8(%ebp),%eax
c0106927:	83 c0 10             	add    $0x10,%eax
c010692a:	c7 45 f0 cc ab 12 c0 	movl   $0xc012abcc,-0x10(%ebp)
c0106931:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0106934:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106937:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010693a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010693d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0106940:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0106943:	8b 40 04             	mov    0x4(%eax),%eax
c0106946:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106949:	89 55 d0             	mov    %edx,-0x30(%ebp)
c010694c:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010694f:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0106952:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0106955:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0106958:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010695b:	89 10                	mov    %edx,(%eax)
c010695d:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0106960:	8b 10                	mov    (%eax),%edx
c0106962:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0106965:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0106968:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010696b:	8b 55 c8             	mov    -0x38(%ebp),%edx
c010696e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0106971:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106974:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0106977:	89 10                	mov    %edx,(%eax)
}
c0106979:	90                   	nop
c010697a:	c9                   	leave  
c010697b:	c3                   	ret    

c010697c <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c010697c:	55                   	push   %ebp
c010697d:	89 e5                	mov    %esp,%ebp
c010697f:	83 ec 58             	sub    $0x58,%esp
    // 边界情况检查
    assert(n > 0);
c0106982:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0106986:	75 16                	jne    c010699e <default_alloc_pages+0x22>
c0106988:	68 6c c0 10 c0       	push   $0xc010c06c
c010698d:	68 72 c0 10 c0       	push   $0xc010c072
c0106992:	6a 58                	push   $0x58
c0106994:	68 87 c0 10 c0       	push   $0xc010c087
c0106999:	e8 be ad ff ff       	call   c010175c <__panic>
    if (n > nr_free) {
c010699e:	a1 d4 ab 12 c0       	mov    0xc012abd4,%eax
c01069a3:	3b 45 08             	cmp    0x8(%ebp),%eax
c01069a6:	73 0a                	jae    c01069b2 <default_alloc_pages+0x36>
        return NULL;
c01069a8:	b8 00 00 00 00       	mov    $0x0,%eax
c01069ad:	e9 49 01 00 00       	jmp    c0106afb <default_alloc_pages+0x17f>
    }
    struct Page *page = NULL;
c01069b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c01069b9:	c7 45 f0 cc ab 12 c0 	movl   $0xc012abcc,-0x10(%ebp)
    // 若list_next == &free_list代表该循环双向链表被查询完毕
    while ((le = list_next(le)) != &free_list) {
c01069c0:	eb 1c                	jmp    c01069de <default_alloc_pages+0x62>
        struct Page *p = le2page(le, page_link) ;// 由list_entry_t结构转换为Page结构，找到该page结构的头地址
c01069c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01069c5:	83 e8 10             	sub    $0x10,%eax
c01069c8:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if (p->property >= n) {
c01069cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01069ce:	8b 40 08             	mov    0x8(%eax),%eax
c01069d1:	3b 45 08             	cmp    0x8(%ebp),%eax
c01069d4:	72 08                	jb     c01069de <default_alloc_pages+0x62>
            page = p; // 如果该空闲块里面的空闲页个数满足要求，就找到了
c01069d6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01069d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c01069dc:	eb 18                	jmp    c01069f6 <default_alloc_pages+0x7a>
c01069de:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01069e1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01069e4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01069e7:	8b 40 04             	mov    0x4(%eax),%eax
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    // 若list_next == &free_list代表该循环双向链表被查询完毕
    while ((le = list_next(le)) != &free_list) {
c01069ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01069ed:	81 7d f0 cc ab 12 c0 	cmpl   $0xc012abcc,-0x10(%ebp)
c01069f4:	75 cc                	jne    c01069c2 <default_alloc_pages+0x46>
            page = p; // 如果该空闲块里面的空闲页个数满足要求，就找到了
            break;
        }
    }
    // 匹配空闲块成功后的处理
    if (page != NULL) {
c01069f6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01069fa:	0f 84 f8 00 00 00    	je     c0106af8 <default_alloc_pages+0x17c>
        //list_del(&(page->page_link)); //将此块取出
        // 如果空闲页个数比要求的多
        if (page->property > n) {
c0106a00:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106a03:	8b 40 08             	mov    0x8(%eax),%eax
c0106a06:	3b 45 08             	cmp    0x8(%ebp),%eax
c0106a09:	0f 86 98 00 00 00    	jbe    c0106aa7 <default_alloc_pages+0x12b>
            struct Page *p = page + n;
c0106a0f:	8b 55 08             	mov    0x8(%ebp),%edx
c0106a12:	89 d0                	mov    %edx,%eax
c0106a14:	c1 e0 03             	shl    $0x3,%eax
c0106a17:	01 d0                	add    %edx,%eax
c0106a19:	c1 e0 02             	shl    $0x2,%eax
c0106a1c:	89 c2                	mov    %eax,%edx
c0106a1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106a21:	01 d0                	add    %edx,%eax
c0106a23:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            p->property = page->property - n;
c0106a26:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106a29:	8b 40 08             	mov    0x8(%eax),%eax
c0106a2c:	2b 45 08             	sub    0x8(%ebp),%eax
c0106a2f:	89 c2                	mov    %eax,%edx
c0106a31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106a34:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p); // 标为已使用块
c0106a37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106a3a:	83 c0 04             	add    $0x4,%eax
c0106a3d:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
c0106a44:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0106a47:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0106a4a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106a4d:	0f ab 10             	bts    %edx,(%eax)
            list_add(&(page->page_link), &(p->page_link)); // 将page->page_link插到p->page_link的头部
c0106a50:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106a53:	83 c0 10             	add    $0x10,%eax
c0106a56:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106a59:	83 c2 10             	add    $0x10,%edx
c0106a5c:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0106a5f:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0106a62:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106a65:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0106a68:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106a6b:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0106a6e:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0106a71:	8b 40 04             	mov    0x4(%eax),%eax
c0106a74:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0106a77:	89 55 c4             	mov    %edx,-0x3c(%ebp)
c0106a7a:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0106a7d:	89 55 c0             	mov    %edx,-0x40(%ebp)
c0106a80:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0106a83:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0106a86:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0106a89:	89 10                	mov    %edx,(%eax)
c0106a8b:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0106a8e:	8b 10                	mov    (%eax),%edx
c0106a90:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0106a93:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0106a96:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0106a99:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0106a9c:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0106a9f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0106aa2:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0106aa5:	89 10                	mov    %edx,(%eax)
        }
        list_del(&(page->page_link)); //从链表中删除
c0106aa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106aaa:	83 c0 10             	add    $0x10,%eax
c0106aad:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0106ab0:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0106ab3:	8b 40 04             	mov    0x4(%eax),%eax
c0106ab6:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0106ab9:	8b 12                	mov    (%edx),%edx
c0106abb:	89 55 b0             	mov    %edx,-0x50(%ebp)
c0106abe:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0106ac1:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0106ac4:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0106ac7:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0106aca:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0106acd:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0106ad0:	89 10                	mov    %edx,(%eax)
        nr_free -= n;
c0106ad2:	a1 d4 ab 12 c0       	mov    0xc012abd4,%eax
c0106ad7:	2b 45 08             	sub    0x8(%ebp),%eax
c0106ada:	a3 d4 ab 12 c0       	mov    %eax,0xc012abd4
        ClearPageProperty(page);
c0106adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106ae2:	83 c0 04             	add    $0x4,%eax
c0106ae5:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c0106aec:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0106aef:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0106af2:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106af5:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
c0106af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106afb:	c9                   	leave  
c0106afc:	c3                   	ret    

c0106afd <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c0106afd:	55                   	push   %ebp
c0106afe:	89 e5                	mov    %esp,%ebp
c0106b00:	81 ec a8 00 00 00    	sub    $0xa8,%esp
    assert(n > 0);
c0106b06:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0106b0a:	75 16                	jne    c0106b22 <default_free_pages+0x25>
c0106b0c:	68 6c c0 10 c0       	push   $0xc010c06c
c0106b11:	68 72 c0 10 c0       	push   $0xc010c072
c0106b16:	6a 79                	push   $0x79
c0106b18:	68 87 c0 10 c0       	push   $0xc010c087
c0106b1d:	e8 3a ac ff ff       	call   c010175c <__panic>
    struct Page *p = base;
c0106b22:	8b 45 08             	mov    0x8(%ebp),%eax
c0106b25:	89 45 f4             	mov    %eax,-0xc(%ebp)
    struct Page *pp = base;  // previous page in the free_list
c0106b28:	8b 45 08             	mov    0x8(%ebp),%eax
c0106b2b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for (; p != base + n; p ++) {
c0106b2e:	e9 8c 00 00 00       	jmp    c0106bbf <default_free_pages+0xc2>
        assert(!PageReserved(p) && !PageProperty(p));
c0106b33:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106b36:	83 c0 04             	add    $0x4,%eax
c0106b39:	c7 45 b8 00 00 00 00 	movl   $0x0,-0x48(%ebp)
c0106b40:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106b43:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0106b46:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0106b49:	0f a3 10             	bt     %edx,(%eax)
c0106b4c:	19 c0                	sbb    %eax,%eax
c0106b4e:	89 45 b0             	mov    %eax,-0x50(%ebp)
    return oldbit != 0;
c0106b51:	83 7d b0 00          	cmpl   $0x0,-0x50(%ebp)
c0106b55:	0f 95 c0             	setne  %al
c0106b58:	0f b6 c0             	movzbl %al,%eax
c0106b5b:	85 c0                	test   %eax,%eax
c0106b5d:	75 2c                	jne    c0106b8b <default_free_pages+0x8e>
c0106b5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106b62:	83 c0 04             	add    $0x4,%eax
c0106b65:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
c0106b6c:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106b6f:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0106b72:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0106b75:	0f a3 10             	bt     %edx,(%eax)
c0106b78:	19 c0                	sbb    %eax,%eax
c0106b7a:	89 45 a8             	mov    %eax,-0x58(%ebp)
    return oldbit != 0;
c0106b7d:	83 7d a8 00          	cmpl   $0x0,-0x58(%ebp)
c0106b81:	0f 95 c0             	setne  %al
c0106b84:	0f b6 c0             	movzbl %al,%eax
c0106b87:	85 c0                	test   %eax,%eax
c0106b89:	74 16                	je     c0106ba1 <default_free_pages+0xa4>
c0106b8b:	68 b0 c0 10 c0       	push   $0xc010c0b0
c0106b90:	68 72 c0 10 c0       	push   $0xc010c072
c0106b95:	6a 7d                	push   $0x7d
c0106b97:	68 87 c0 10 c0       	push   $0xc010c087
c0106b9c:	e8 bb ab ff ff       	call   c010175c <__panic>
        p->flags = 0;
c0106ba1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106ba4:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c0106bab:	83 ec 08             	sub    $0x8,%esp
c0106bae:	6a 00                	push   $0x0
c0106bb0:	ff 75 f4             	pushl  -0xc(%ebp)
c0106bb3:	e8 4b fc ff ff       	call   c0106803 <set_page_ref>
c0106bb8:	83 c4 10             	add    $0x10,%esp
static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    struct Page *pp = base;  // previous page in the free_list
    for (; p != base + n; p ++) {
c0106bbb:	83 45 f4 24          	addl   $0x24,-0xc(%ebp)
c0106bbf:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106bc2:	89 d0                	mov    %edx,%eax
c0106bc4:	c1 e0 03             	shl    $0x3,%eax
c0106bc7:	01 d0                	add    %edx,%eax
c0106bc9:	c1 e0 02             	shl    $0x2,%eax
c0106bcc:	89 c2                	mov    %eax,%edx
c0106bce:	8b 45 08             	mov    0x8(%ebp),%eax
c0106bd1:	01 d0                	add    %edx,%eax
c0106bd3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0106bd6:	0f 85 57 ff ff ff    	jne    c0106b33 <default_free_pages+0x36>
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    p = base;
c0106bdc:	8b 45 08             	mov    0x8(%ebp),%eax
c0106bdf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    base->property = n;
c0106be2:	8b 45 08             	mov    0x8(%ebp),%eax
c0106be5:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106be8:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0106beb:	8b 45 08             	mov    0x8(%ebp),%eax
c0106bee:	83 c0 04             	add    $0x4,%eax
c0106bf1:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
c0106bf8:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0106bfb:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0106bfe:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106c01:	0f ab 10             	bts    %edx,(%eax)
c0106c04:	c7 45 e4 cc ab 12 c0 	movl   $0xc012abcc,-0x1c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0106c0b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106c0e:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c0106c11:	89 45 ec             	mov    %eax,-0x14(%ebp)
    // 根据地址从小到大开始找
    while ((le != &free_list) && ((p = le2page(le, page_link)) < base)) {
c0106c14:	eb 15                	jmp    c0106c2b <default_free_pages+0x12e>
        pp = p;
c0106c16:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106c19:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106c1c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106c1f:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0106c22:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106c25:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0106c28:	89 45 ec             	mov    %eax,-0x14(%ebp)
    p = base;
    base->property = n;
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
    // 根据地址从小到大开始找
    while ((le != &free_list) && ((p = le2page(le, page_link)) < base)) {
c0106c2b:	81 7d ec cc ab 12 c0 	cmpl   $0xc012abcc,-0x14(%ebp)
c0106c32:	74 11                	je     c0106c45 <default_free_pages+0x148>
c0106c34:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106c37:	83 e8 10             	sub    $0x10,%eax
c0106c3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106c3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106c40:	3b 45 08             	cmp    0x8(%ebp),%eax
c0106c43:	72 d1                	jb     c0106c16 <default_free_pages+0x119>
        pp = p;
        le = list_next(le);
    }

    if ((base + base->property == p) && (pp + pp->property == base)) {
c0106c45:	8b 45 08             	mov    0x8(%ebp),%eax
c0106c48:	8b 50 08             	mov    0x8(%eax),%edx
c0106c4b:	89 d0                	mov    %edx,%eax
c0106c4d:	c1 e0 03             	shl    $0x3,%eax
c0106c50:	01 d0                	add    %edx,%eax
c0106c52:	c1 e0 02             	shl    $0x2,%eax
c0106c55:	89 c2                	mov    %eax,%edx
c0106c57:	8b 45 08             	mov    0x8(%ebp),%eax
c0106c5a:	01 d0                	add    %edx,%eax
c0106c5c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0106c5f:	0f 85 97 00 00 00    	jne    c0106cfc <default_free_pages+0x1ff>
c0106c65:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106c68:	8b 50 08             	mov    0x8(%eax),%edx
c0106c6b:	89 d0                	mov    %edx,%eax
c0106c6d:	c1 e0 03             	shl    $0x3,%eax
c0106c70:	01 d0                	add    %edx,%eax
c0106c72:	c1 e0 02             	shl    $0x2,%eax
c0106c75:	89 c2                	mov    %eax,%edx
c0106c77:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106c7a:	01 d0                	add    %edx,%eax
c0106c7c:	3b 45 08             	cmp    0x8(%ebp),%eax
c0106c7f:	75 7b                	jne    c0106cfc <default_free_pages+0x1ff>
        pp->property += (base->property + p->property);
c0106c81:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106c84:	8b 50 08             	mov    0x8(%eax),%edx
c0106c87:	8b 45 08             	mov    0x8(%ebp),%eax
c0106c8a:	8b 48 08             	mov    0x8(%eax),%ecx
c0106c8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106c90:	8b 40 08             	mov    0x8(%eax),%eax
c0106c93:	01 c8                	add    %ecx,%eax
c0106c95:	01 c2                	add    %eax,%edx
c0106c97:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106c9a:	89 50 08             	mov    %edx,0x8(%eax)
        ClearPageProperty(base);
c0106c9d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ca0:	83 c0 04             	add    $0x4,%eax
c0106ca3:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0106caa:	89 45 94             	mov    %eax,-0x6c(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0106cad:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0106cb0:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0106cb3:	0f b3 10             	btr    %edx,(%eax)
        ClearPageProperty(p);
c0106cb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106cb9:	83 c0 04             	add    $0x4,%eax
c0106cbc:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
c0106cc3:	89 45 98             	mov    %eax,-0x68(%ebp)
c0106cc6:	8b 45 98             	mov    -0x68(%ebp),%eax
c0106cc9:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0106ccc:	0f b3 10             	btr    %edx,(%eax)
c0106ccf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106cd2:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0106cd5:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0106cd8:	8b 40 04             	mov    0x4(%eax),%eax
c0106cdb:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0106cde:	8b 12                	mov    (%edx),%edx
c0106ce0:	89 55 a0             	mov    %edx,-0x60(%ebp)
c0106ce3:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0106ce6:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0106ce9:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0106cec:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0106cef:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0106cf2:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0106cf5:	89 10                	mov    %edx,(%eax)
        list_del(le);
c0106cf7:	e9 92 01 00 00       	jmp    c0106e8e <default_free_pages+0x391>
    }
    else if (base + base->property == p) {
c0106cfc:	8b 45 08             	mov    0x8(%ebp),%eax
c0106cff:	8b 50 08             	mov    0x8(%eax),%edx
c0106d02:	89 d0                	mov    %edx,%eax
c0106d04:	c1 e0 03             	shl    $0x3,%eax
c0106d07:	01 d0                	add    %edx,%eax
c0106d09:	c1 e0 02             	shl    $0x2,%eax
c0106d0c:	89 c2                	mov    %eax,%edx
c0106d0e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d11:	01 d0                	add    %edx,%eax
c0106d13:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0106d16:	0f 85 b3 00 00 00    	jne    c0106dcf <default_free_pages+0x2d2>
        base->property += p->property;
c0106d1c:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d1f:	8b 50 08             	mov    0x8(%eax),%edx
c0106d22:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106d25:	8b 40 08             	mov    0x8(%eax),%eax
c0106d28:	01 c2                	add    %eax,%edx
c0106d2a:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d2d:	89 50 08             	mov    %edx,0x8(%eax)
        ClearPageProperty(p);
c0106d30:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106d33:	83 c0 04             	add    $0x4,%eax
c0106d36:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0106d3d:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
c0106d43:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
c0106d49:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0106d4c:	0f b3 10             	btr    %edx,(%eax)
        list_add_before(le, &(base->page_link));
c0106d4f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d52:	8d 50 10             	lea    0x10(%eax),%edx
c0106d55:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106d58:	89 45 c0             	mov    %eax,-0x40(%ebp)
c0106d5b:	89 55 88             	mov    %edx,-0x78(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0106d5e:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0106d61:	8b 00                	mov    (%eax),%eax
c0106d63:	8b 55 88             	mov    -0x78(%ebp),%edx
c0106d66:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0106d69:	89 45 80             	mov    %eax,-0x80(%ebp)
c0106d6c:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0106d6f:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0106d75:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c0106d7b:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0106d7e:	89 10                	mov    %edx,(%eax)
c0106d80:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c0106d86:	8b 10                	mov    (%eax),%edx
c0106d88:	8b 45 80             	mov    -0x80(%ebp),%eax
c0106d8b:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0106d8e:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0106d91:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
c0106d97:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0106d9a:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0106d9d:	8b 55 80             	mov    -0x80(%ebp),%edx
c0106da0:	89 10                	mov    %edx,(%eax)
c0106da2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106da5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0106da8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106dab:	8b 40 04             	mov    0x4(%eax),%eax
c0106dae:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106db1:	8b 12                	mov    (%edx),%edx
c0106db3:	89 55 90             	mov    %edx,-0x70(%ebp)
c0106db6:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0106db9:	8b 45 90             	mov    -0x70(%ebp),%eax
c0106dbc:	8b 55 8c             	mov    -0x74(%ebp),%edx
c0106dbf:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0106dc2:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0106dc5:	8b 55 90             	mov    -0x70(%ebp),%edx
c0106dc8:	89 10                	mov    %edx,(%eax)
c0106dca:	e9 bf 00 00 00       	jmp    c0106e8e <default_free_pages+0x391>
        list_del(le);
    }
    else if (pp + pp->property == base) {
c0106dcf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106dd2:	8b 50 08             	mov    0x8(%eax),%edx
c0106dd5:	89 d0                	mov    %edx,%eax
c0106dd7:	c1 e0 03             	shl    $0x3,%eax
c0106dda:	01 d0                	add    %edx,%eax
c0106ddc:	c1 e0 02             	shl    $0x2,%eax
c0106ddf:	89 c2                	mov    %eax,%edx
c0106de1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106de4:	01 d0                	add    %edx,%eax
c0106de6:	3b 45 08             	cmp    0x8(%ebp),%eax
c0106de9:	75 35                	jne    c0106e20 <default_free_pages+0x323>
        pp->property += base->property;
c0106deb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106dee:	8b 50 08             	mov    0x8(%eax),%edx
c0106df1:	8b 45 08             	mov    0x8(%ebp),%eax
c0106df4:	8b 40 08             	mov    0x8(%eax),%eax
c0106df7:	01 c2                	add    %eax,%edx
c0106df9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106dfc:	89 50 08             	mov    %edx,0x8(%eax)
        ClearPageProperty(base);
c0106dff:	8b 45 08             	mov    0x8(%ebp),%eax
c0106e02:	83 c0 04             	add    $0x4,%eax
c0106e05:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c0106e0c:	89 85 74 ff ff ff    	mov    %eax,-0x8c(%ebp)
c0106e12:	8b 85 74 ff ff ff    	mov    -0x8c(%ebp),%eax
c0106e18:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0106e1b:	0f b3 10             	btr    %edx,(%eax)
c0106e1e:	eb 6e                	jmp    c0106e8e <default_free_pages+0x391>
    }
    else {
        list_add_before(le, &(base->page_link));
c0106e20:	8b 45 08             	mov    0x8(%ebp),%eax
c0106e23:	8d 50 10             	lea    0x10(%eax),%edx
c0106e26:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106e29:	89 45 bc             	mov    %eax,-0x44(%ebp)
c0106e2c:	89 95 70 ff ff ff    	mov    %edx,-0x90(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0106e32:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0106e35:	8b 00                	mov    (%eax),%eax
c0106e37:	8b 95 70 ff ff ff    	mov    -0x90(%ebp),%edx
c0106e3d:	89 95 6c ff ff ff    	mov    %edx,-0x94(%ebp)
c0106e43:	89 85 68 ff ff ff    	mov    %eax,-0x98(%ebp)
c0106e49:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0106e4c:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0106e52:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
c0106e58:	8b 95 6c ff ff ff    	mov    -0x94(%ebp),%edx
c0106e5e:	89 10                	mov    %edx,(%eax)
c0106e60:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
c0106e66:	8b 10                	mov    (%eax),%edx
c0106e68:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
c0106e6e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0106e71:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
c0106e77:	8b 95 64 ff ff ff    	mov    -0x9c(%ebp),%edx
c0106e7d:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0106e80:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
c0106e86:	8b 95 68 ff ff ff    	mov    -0x98(%ebp),%edx
c0106e8c:	89 10                	mov    %edx,(%eax)
    }

    nr_free += n;
c0106e8e:	8b 15 d4 ab 12 c0    	mov    0xc012abd4,%edx
c0106e94:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106e97:	01 d0                	add    %edx,%eax
c0106e99:	a3 d4 ab 12 c0       	mov    %eax,0xc012abd4
}
c0106e9e:	90                   	nop
c0106e9f:	c9                   	leave  
c0106ea0:	c3                   	ret    

c0106ea1 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0106ea1:	55                   	push   %ebp
c0106ea2:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0106ea4:	a1 d4 ab 12 c0       	mov    0xc012abd4,%eax
}
c0106ea9:	5d                   	pop    %ebp
c0106eaa:	c3                   	ret    

c0106eab <basic_check>:

static void
basic_check(void) {
c0106eab:	55                   	push   %ebp
c0106eac:	89 e5                	mov    %esp,%ebp
c0106eae:	83 ec 38             	sub    $0x38,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0106eb1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0106eb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106ebb:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106ebe:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106ec1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0106ec4:	83 ec 0c             	sub    $0xc,%esp
c0106ec7:	6a 01                	push   $0x1
c0106ec9:	e8 d7 0c 00 00       	call   c0107ba5 <alloc_pages>
c0106ece:	83 c4 10             	add    $0x10,%esp
c0106ed1:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106ed4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0106ed8:	75 19                	jne    c0106ef3 <basic_check+0x48>
c0106eda:	68 d5 c0 10 c0       	push   $0xc010c0d5
c0106edf:	68 72 c0 10 c0       	push   $0xc010c072
c0106ee4:	68 ab 00 00 00       	push   $0xab
c0106ee9:	68 87 c0 10 c0       	push   $0xc010c087
c0106eee:	e8 69 a8 ff ff       	call   c010175c <__panic>
    assert((p1 = alloc_page()) != NULL);
c0106ef3:	83 ec 0c             	sub    $0xc,%esp
c0106ef6:	6a 01                	push   $0x1
c0106ef8:	e8 a8 0c 00 00       	call   c0107ba5 <alloc_pages>
c0106efd:	83 c4 10             	add    $0x10,%esp
c0106f00:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106f03:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106f07:	75 19                	jne    c0106f22 <basic_check+0x77>
c0106f09:	68 f1 c0 10 c0       	push   $0xc010c0f1
c0106f0e:	68 72 c0 10 c0       	push   $0xc010c072
c0106f13:	68 ac 00 00 00       	push   $0xac
c0106f18:	68 87 c0 10 c0       	push   $0xc010c087
c0106f1d:	e8 3a a8 ff ff       	call   c010175c <__panic>
    assert((p2 = alloc_page()) != NULL);
c0106f22:	83 ec 0c             	sub    $0xc,%esp
c0106f25:	6a 01                	push   $0x1
c0106f27:	e8 79 0c 00 00       	call   c0107ba5 <alloc_pages>
c0106f2c:	83 c4 10             	add    $0x10,%esp
c0106f2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106f32:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106f36:	75 19                	jne    c0106f51 <basic_check+0xa6>
c0106f38:	68 0d c1 10 c0       	push   $0xc010c10d
c0106f3d:	68 72 c0 10 c0       	push   $0xc010c072
c0106f42:	68 ad 00 00 00       	push   $0xad
c0106f47:	68 87 c0 10 c0       	push   $0xc010c087
c0106f4c:	e8 0b a8 ff ff       	call   c010175c <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0106f51:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106f54:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0106f57:	74 10                	je     c0106f69 <basic_check+0xbe>
c0106f59:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106f5c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0106f5f:	74 08                	je     c0106f69 <basic_check+0xbe>
c0106f61:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106f64:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0106f67:	75 19                	jne    c0106f82 <basic_check+0xd7>
c0106f69:	68 2c c1 10 c0       	push   $0xc010c12c
c0106f6e:	68 72 c0 10 c0       	push   $0xc010c072
c0106f73:	68 af 00 00 00       	push   $0xaf
c0106f78:	68 87 c0 10 c0       	push   $0xc010c087
c0106f7d:	e8 da a7 ff ff       	call   c010175c <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0106f82:	83 ec 0c             	sub    $0xc,%esp
c0106f85:	ff 75 ec             	pushl  -0x14(%ebp)
c0106f88:	e8 6c f8 ff ff       	call   c01067f9 <page_ref>
c0106f8d:	83 c4 10             	add    $0x10,%esp
c0106f90:	85 c0                	test   %eax,%eax
c0106f92:	75 24                	jne    c0106fb8 <basic_check+0x10d>
c0106f94:	83 ec 0c             	sub    $0xc,%esp
c0106f97:	ff 75 f0             	pushl  -0x10(%ebp)
c0106f9a:	e8 5a f8 ff ff       	call   c01067f9 <page_ref>
c0106f9f:	83 c4 10             	add    $0x10,%esp
c0106fa2:	85 c0                	test   %eax,%eax
c0106fa4:	75 12                	jne    c0106fb8 <basic_check+0x10d>
c0106fa6:	83 ec 0c             	sub    $0xc,%esp
c0106fa9:	ff 75 f4             	pushl  -0xc(%ebp)
c0106fac:	e8 48 f8 ff ff       	call   c01067f9 <page_ref>
c0106fb1:	83 c4 10             	add    $0x10,%esp
c0106fb4:	85 c0                	test   %eax,%eax
c0106fb6:	74 19                	je     c0106fd1 <basic_check+0x126>
c0106fb8:	68 50 c1 10 c0       	push   $0xc010c150
c0106fbd:	68 72 c0 10 c0       	push   $0xc010c072
c0106fc2:	68 b0 00 00 00       	push   $0xb0
c0106fc7:	68 87 c0 10 c0       	push   $0xc010c087
c0106fcc:	e8 8b a7 ff ff       	call   c010175c <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0106fd1:	83 ec 0c             	sub    $0xc,%esp
c0106fd4:	ff 75 ec             	pushl  -0x14(%ebp)
c0106fd7:	e8 0a f8 ff ff       	call   c01067e6 <page2pa>
c0106fdc:	83 c4 10             	add    $0x10,%esp
c0106fdf:	89 c2                	mov    %eax,%edx
c0106fe1:	a1 20 8a 12 c0       	mov    0xc0128a20,%eax
c0106fe6:	c1 e0 0c             	shl    $0xc,%eax
c0106fe9:	39 c2                	cmp    %eax,%edx
c0106feb:	72 19                	jb     c0107006 <basic_check+0x15b>
c0106fed:	68 8c c1 10 c0       	push   $0xc010c18c
c0106ff2:	68 72 c0 10 c0       	push   $0xc010c072
c0106ff7:	68 b2 00 00 00       	push   $0xb2
c0106ffc:	68 87 c0 10 c0       	push   $0xc010c087
c0107001:	e8 56 a7 ff ff       	call   c010175c <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0107006:	83 ec 0c             	sub    $0xc,%esp
c0107009:	ff 75 f0             	pushl  -0x10(%ebp)
c010700c:	e8 d5 f7 ff ff       	call   c01067e6 <page2pa>
c0107011:	83 c4 10             	add    $0x10,%esp
c0107014:	89 c2                	mov    %eax,%edx
c0107016:	a1 20 8a 12 c0       	mov    0xc0128a20,%eax
c010701b:	c1 e0 0c             	shl    $0xc,%eax
c010701e:	39 c2                	cmp    %eax,%edx
c0107020:	72 19                	jb     c010703b <basic_check+0x190>
c0107022:	68 a9 c1 10 c0       	push   $0xc010c1a9
c0107027:	68 72 c0 10 c0       	push   $0xc010c072
c010702c:	68 b3 00 00 00       	push   $0xb3
c0107031:	68 87 c0 10 c0       	push   $0xc010c087
c0107036:	e8 21 a7 ff ff       	call   c010175c <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c010703b:	83 ec 0c             	sub    $0xc,%esp
c010703e:	ff 75 f4             	pushl  -0xc(%ebp)
c0107041:	e8 a0 f7 ff ff       	call   c01067e6 <page2pa>
c0107046:	83 c4 10             	add    $0x10,%esp
c0107049:	89 c2                	mov    %eax,%edx
c010704b:	a1 20 8a 12 c0       	mov    0xc0128a20,%eax
c0107050:	c1 e0 0c             	shl    $0xc,%eax
c0107053:	39 c2                	cmp    %eax,%edx
c0107055:	72 19                	jb     c0107070 <basic_check+0x1c5>
c0107057:	68 c6 c1 10 c0       	push   $0xc010c1c6
c010705c:	68 72 c0 10 c0       	push   $0xc010c072
c0107061:	68 b4 00 00 00       	push   $0xb4
c0107066:	68 87 c0 10 c0       	push   $0xc010c087
c010706b:	e8 ec a6 ff ff       	call   c010175c <__panic>

    list_entry_t free_list_store = free_list;
c0107070:	a1 cc ab 12 c0       	mov    0xc012abcc,%eax
c0107075:	8b 15 d0 ab 12 c0    	mov    0xc012abd0,%edx
c010707b:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010707e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0107081:	c7 45 e4 cc ab 12 c0 	movl   $0xc012abcc,-0x1c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0107088:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010708b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010708e:	89 50 04             	mov    %edx,0x4(%eax)
c0107091:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107094:	8b 50 04             	mov    0x4(%eax),%edx
c0107097:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010709a:	89 10                	mov    %edx,(%eax)
c010709c:	c7 45 d8 cc ab 12 c0 	movl   $0xc012abcc,-0x28(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c01070a3:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01070a6:	8b 40 04             	mov    0x4(%eax),%eax
c01070a9:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c01070ac:	0f 94 c0             	sete   %al
c01070af:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c01070b2:	85 c0                	test   %eax,%eax
c01070b4:	75 19                	jne    c01070cf <basic_check+0x224>
c01070b6:	68 e3 c1 10 c0       	push   $0xc010c1e3
c01070bb:	68 72 c0 10 c0       	push   $0xc010c072
c01070c0:	68 b8 00 00 00       	push   $0xb8
c01070c5:	68 87 c0 10 c0       	push   $0xc010c087
c01070ca:	e8 8d a6 ff ff       	call   c010175c <__panic>

    unsigned int nr_free_store = nr_free;
c01070cf:	a1 d4 ab 12 c0       	mov    0xc012abd4,%eax
c01070d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
c01070d7:	c7 05 d4 ab 12 c0 00 	movl   $0x0,0xc012abd4
c01070de:	00 00 00 

    assert(alloc_page() == NULL);
c01070e1:	83 ec 0c             	sub    $0xc,%esp
c01070e4:	6a 01                	push   $0x1
c01070e6:	e8 ba 0a 00 00       	call   c0107ba5 <alloc_pages>
c01070eb:	83 c4 10             	add    $0x10,%esp
c01070ee:	85 c0                	test   %eax,%eax
c01070f0:	74 19                	je     c010710b <basic_check+0x260>
c01070f2:	68 fa c1 10 c0       	push   $0xc010c1fa
c01070f7:	68 72 c0 10 c0       	push   $0xc010c072
c01070fc:	68 bd 00 00 00       	push   $0xbd
c0107101:	68 87 c0 10 c0       	push   $0xc010c087
c0107106:	e8 51 a6 ff ff       	call   c010175c <__panic>

    free_page(p0);
c010710b:	83 ec 08             	sub    $0x8,%esp
c010710e:	6a 01                	push   $0x1
c0107110:	ff 75 ec             	pushl  -0x14(%ebp)
c0107113:	e8 f9 0a 00 00       	call   c0107c11 <free_pages>
c0107118:	83 c4 10             	add    $0x10,%esp
    free_page(p1);
c010711b:	83 ec 08             	sub    $0x8,%esp
c010711e:	6a 01                	push   $0x1
c0107120:	ff 75 f0             	pushl  -0x10(%ebp)
c0107123:	e8 e9 0a 00 00       	call   c0107c11 <free_pages>
c0107128:	83 c4 10             	add    $0x10,%esp
    free_page(p2);
c010712b:	83 ec 08             	sub    $0x8,%esp
c010712e:	6a 01                	push   $0x1
c0107130:	ff 75 f4             	pushl  -0xc(%ebp)
c0107133:	e8 d9 0a 00 00       	call   c0107c11 <free_pages>
c0107138:	83 c4 10             	add    $0x10,%esp
    assert(nr_free == 3);
c010713b:	a1 d4 ab 12 c0       	mov    0xc012abd4,%eax
c0107140:	83 f8 03             	cmp    $0x3,%eax
c0107143:	74 19                	je     c010715e <basic_check+0x2b3>
c0107145:	68 0f c2 10 c0       	push   $0xc010c20f
c010714a:	68 72 c0 10 c0       	push   $0xc010c072
c010714f:	68 c2 00 00 00       	push   $0xc2
c0107154:	68 87 c0 10 c0       	push   $0xc010c087
c0107159:	e8 fe a5 ff ff       	call   c010175c <__panic>

    assert((p0 = alloc_page()) != NULL);
c010715e:	83 ec 0c             	sub    $0xc,%esp
c0107161:	6a 01                	push   $0x1
c0107163:	e8 3d 0a 00 00       	call   c0107ba5 <alloc_pages>
c0107168:	83 c4 10             	add    $0x10,%esp
c010716b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010716e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0107172:	75 19                	jne    c010718d <basic_check+0x2e2>
c0107174:	68 d5 c0 10 c0       	push   $0xc010c0d5
c0107179:	68 72 c0 10 c0       	push   $0xc010c072
c010717e:	68 c4 00 00 00       	push   $0xc4
c0107183:	68 87 c0 10 c0       	push   $0xc010c087
c0107188:	e8 cf a5 ff ff       	call   c010175c <__panic>
    assert((p1 = alloc_page()) != NULL);
c010718d:	83 ec 0c             	sub    $0xc,%esp
c0107190:	6a 01                	push   $0x1
c0107192:	e8 0e 0a 00 00       	call   c0107ba5 <alloc_pages>
c0107197:	83 c4 10             	add    $0x10,%esp
c010719a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010719d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01071a1:	75 19                	jne    c01071bc <basic_check+0x311>
c01071a3:	68 f1 c0 10 c0       	push   $0xc010c0f1
c01071a8:	68 72 c0 10 c0       	push   $0xc010c072
c01071ad:	68 c5 00 00 00       	push   $0xc5
c01071b2:	68 87 c0 10 c0       	push   $0xc010c087
c01071b7:	e8 a0 a5 ff ff       	call   c010175c <__panic>
    assert((p2 = alloc_page()) != NULL);
c01071bc:	83 ec 0c             	sub    $0xc,%esp
c01071bf:	6a 01                	push   $0x1
c01071c1:	e8 df 09 00 00       	call   c0107ba5 <alloc_pages>
c01071c6:	83 c4 10             	add    $0x10,%esp
c01071c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01071cc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01071d0:	75 19                	jne    c01071eb <basic_check+0x340>
c01071d2:	68 0d c1 10 c0       	push   $0xc010c10d
c01071d7:	68 72 c0 10 c0       	push   $0xc010c072
c01071dc:	68 c6 00 00 00       	push   $0xc6
c01071e1:	68 87 c0 10 c0       	push   $0xc010c087
c01071e6:	e8 71 a5 ff ff       	call   c010175c <__panic>

    assert(alloc_page() == NULL);
c01071eb:	83 ec 0c             	sub    $0xc,%esp
c01071ee:	6a 01                	push   $0x1
c01071f0:	e8 b0 09 00 00       	call   c0107ba5 <alloc_pages>
c01071f5:	83 c4 10             	add    $0x10,%esp
c01071f8:	85 c0                	test   %eax,%eax
c01071fa:	74 19                	je     c0107215 <basic_check+0x36a>
c01071fc:	68 fa c1 10 c0       	push   $0xc010c1fa
c0107201:	68 72 c0 10 c0       	push   $0xc010c072
c0107206:	68 c8 00 00 00       	push   $0xc8
c010720b:	68 87 c0 10 c0       	push   $0xc010c087
c0107210:	e8 47 a5 ff ff       	call   c010175c <__panic>

    free_page(p0);
c0107215:	83 ec 08             	sub    $0x8,%esp
c0107218:	6a 01                	push   $0x1
c010721a:	ff 75 ec             	pushl  -0x14(%ebp)
c010721d:	e8 ef 09 00 00       	call   c0107c11 <free_pages>
c0107222:	83 c4 10             	add    $0x10,%esp
c0107225:	c7 45 e8 cc ab 12 c0 	movl   $0xc012abcc,-0x18(%ebp)
c010722c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010722f:	8b 40 04             	mov    0x4(%eax),%eax
c0107232:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0107235:	0f 94 c0             	sete   %al
c0107238:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c010723b:	85 c0                	test   %eax,%eax
c010723d:	74 19                	je     c0107258 <basic_check+0x3ad>
c010723f:	68 1c c2 10 c0       	push   $0xc010c21c
c0107244:	68 72 c0 10 c0       	push   $0xc010c072
c0107249:	68 cb 00 00 00       	push   $0xcb
c010724e:	68 87 c0 10 c0       	push   $0xc010c087
c0107253:	e8 04 a5 ff ff       	call   c010175c <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0107258:	83 ec 0c             	sub    $0xc,%esp
c010725b:	6a 01                	push   $0x1
c010725d:	e8 43 09 00 00       	call   c0107ba5 <alloc_pages>
c0107262:	83 c4 10             	add    $0x10,%esp
c0107265:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0107268:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010726b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010726e:	74 19                	je     c0107289 <basic_check+0x3de>
c0107270:	68 34 c2 10 c0       	push   $0xc010c234
c0107275:	68 72 c0 10 c0       	push   $0xc010c072
c010727a:	68 ce 00 00 00       	push   $0xce
c010727f:	68 87 c0 10 c0       	push   $0xc010c087
c0107284:	e8 d3 a4 ff ff       	call   c010175c <__panic>
    assert(alloc_page() == NULL);
c0107289:	83 ec 0c             	sub    $0xc,%esp
c010728c:	6a 01                	push   $0x1
c010728e:	e8 12 09 00 00       	call   c0107ba5 <alloc_pages>
c0107293:	83 c4 10             	add    $0x10,%esp
c0107296:	85 c0                	test   %eax,%eax
c0107298:	74 19                	je     c01072b3 <basic_check+0x408>
c010729a:	68 fa c1 10 c0       	push   $0xc010c1fa
c010729f:	68 72 c0 10 c0       	push   $0xc010c072
c01072a4:	68 cf 00 00 00       	push   $0xcf
c01072a9:	68 87 c0 10 c0       	push   $0xc010c087
c01072ae:	e8 a9 a4 ff ff       	call   c010175c <__panic>

    assert(nr_free == 0);
c01072b3:	a1 d4 ab 12 c0       	mov    0xc012abd4,%eax
c01072b8:	85 c0                	test   %eax,%eax
c01072ba:	74 19                	je     c01072d5 <basic_check+0x42a>
c01072bc:	68 4d c2 10 c0       	push   $0xc010c24d
c01072c1:	68 72 c0 10 c0       	push   $0xc010c072
c01072c6:	68 d1 00 00 00       	push   $0xd1
c01072cb:	68 87 c0 10 c0       	push   $0xc010c087
c01072d0:	e8 87 a4 ff ff       	call   c010175c <__panic>
    free_list = free_list_store;
c01072d5:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01072d8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01072db:	a3 cc ab 12 c0       	mov    %eax,0xc012abcc
c01072e0:	89 15 d0 ab 12 c0    	mov    %edx,0xc012abd0
    nr_free = nr_free_store;
c01072e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01072e9:	a3 d4 ab 12 c0       	mov    %eax,0xc012abd4

    free_page(p);
c01072ee:	83 ec 08             	sub    $0x8,%esp
c01072f1:	6a 01                	push   $0x1
c01072f3:	ff 75 dc             	pushl  -0x24(%ebp)
c01072f6:	e8 16 09 00 00       	call   c0107c11 <free_pages>
c01072fb:	83 c4 10             	add    $0x10,%esp
    free_page(p1);
c01072fe:	83 ec 08             	sub    $0x8,%esp
c0107301:	6a 01                	push   $0x1
c0107303:	ff 75 f0             	pushl  -0x10(%ebp)
c0107306:	e8 06 09 00 00       	call   c0107c11 <free_pages>
c010730b:	83 c4 10             	add    $0x10,%esp
    free_page(p2);
c010730e:	83 ec 08             	sub    $0x8,%esp
c0107311:	6a 01                	push   $0x1
c0107313:	ff 75 f4             	pushl  -0xc(%ebp)
c0107316:	e8 f6 08 00 00       	call   c0107c11 <free_pages>
c010731b:	83 c4 10             	add    $0x10,%esp
}
c010731e:	90                   	nop
c010731f:	c9                   	leave  
c0107320:	c3                   	ret    

c0107321 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0107321:	55                   	push   %ebp
c0107322:	89 e5                	mov    %esp,%ebp
c0107324:	81 ec 88 00 00 00    	sub    $0x88,%esp
    int count = 0, total = 0;
c010732a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0107331:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0107338:	c7 45 ec cc ab 12 c0 	movl   $0xc012abcc,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c010733f:	eb 60                	jmp    c01073a1 <default_check+0x80>
        struct Page *p = le2page(le, page_link);
c0107341:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107344:	83 e8 10             	sub    $0x10,%eax
c0107347:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        assert(PageProperty(p));
c010734a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010734d:	83 c0 04             	add    $0x4,%eax
c0107350:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
c0107357:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010735a:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010735d:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0107360:	0f a3 10             	bt     %edx,(%eax)
c0107363:	19 c0                	sbb    %eax,%eax
c0107365:	89 45 a8             	mov    %eax,-0x58(%ebp)
    return oldbit != 0;
c0107368:	83 7d a8 00          	cmpl   $0x0,-0x58(%ebp)
c010736c:	0f 95 c0             	setne  %al
c010736f:	0f b6 c0             	movzbl %al,%eax
c0107372:	85 c0                	test   %eax,%eax
c0107374:	75 19                	jne    c010738f <default_check+0x6e>
c0107376:	68 5a c2 10 c0       	push   $0xc010c25a
c010737b:	68 72 c0 10 c0       	push   $0xc010c072
c0107380:	68 e2 00 00 00       	push   $0xe2
c0107385:	68 87 c0 10 c0       	push   $0xc010c087
c010738a:	e8 cd a3 ff ff       	call   c010175c <__panic>
        count ++, total += p->property;
c010738f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0107393:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107396:	8b 50 08             	mov    0x8(%eax),%edx
c0107399:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010739c:	01 d0                	add    %edx,%eax
c010739e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01073a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01073a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01073a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01073aa:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c01073ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01073b0:	81 7d ec cc ab 12 c0 	cmpl   $0xc012abcc,-0x14(%ebp)
c01073b7:	75 88                	jne    c0107341 <default_check+0x20>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
c01073b9:	e8 88 08 00 00       	call   c0107c46 <nr_free_pages>
c01073be:	89 c2                	mov    %eax,%edx
c01073c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01073c3:	39 c2                	cmp    %eax,%edx
c01073c5:	74 19                	je     c01073e0 <default_check+0xbf>
c01073c7:	68 6a c2 10 c0       	push   $0xc010c26a
c01073cc:	68 72 c0 10 c0       	push   $0xc010c072
c01073d1:	68 e5 00 00 00       	push   $0xe5
c01073d6:	68 87 c0 10 c0       	push   $0xc010c087
c01073db:	e8 7c a3 ff ff       	call   c010175c <__panic>

    basic_check();
c01073e0:	e8 c6 fa ff ff       	call   c0106eab <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c01073e5:	83 ec 0c             	sub    $0xc,%esp
c01073e8:	6a 05                	push   $0x5
c01073ea:	e8 b6 07 00 00       	call   c0107ba5 <alloc_pages>
c01073ef:	83 c4 10             	add    $0x10,%esp
c01073f2:	89 45 dc             	mov    %eax,-0x24(%ebp)
    assert(p0 != NULL);
c01073f5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01073f9:	75 19                	jne    c0107414 <default_check+0xf3>
c01073fb:	68 83 c2 10 c0       	push   $0xc010c283
c0107400:	68 72 c0 10 c0       	push   $0xc010c072
c0107405:	68 ea 00 00 00       	push   $0xea
c010740a:	68 87 c0 10 c0       	push   $0xc010c087
c010740f:	e8 48 a3 ff ff       	call   c010175c <__panic>
    assert(!PageProperty(p0));
c0107414:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107417:	83 c0 04             	add    $0x4,%eax
c010741a:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
c0107421:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0107424:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0107427:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010742a:	0f a3 10             	bt     %edx,(%eax)
c010742d:	19 c0                	sbb    %eax,%eax
c010742f:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return oldbit != 0;
c0107432:	83 7d a0 00          	cmpl   $0x0,-0x60(%ebp)
c0107436:	0f 95 c0             	setne  %al
c0107439:	0f b6 c0             	movzbl %al,%eax
c010743c:	85 c0                	test   %eax,%eax
c010743e:	74 19                	je     c0107459 <default_check+0x138>
c0107440:	68 8e c2 10 c0       	push   $0xc010c28e
c0107445:	68 72 c0 10 c0       	push   $0xc010c072
c010744a:	68 eb 00 00 00       	push   $0xeb
c010744f:	68 87 c0 10 c0       	push   $0xc010c087
c0107454:	e8 03 a3 ff ff       	call   c010175c <__panic>

    list_entry_t free_list_store = free_list;
c0107459:	a1 cc ab 12 c0       	mov    0xc012abcc,%eax
c010745e:	8b 15 d0 ab 12 c0    	mov    0xc012abd0,%edx
c0107464:	89 45 80             	mov    %eax,-0x80(%ebp)
c0107467:	89 55 84             	mov    %edx,-0x7c(%ebp)
c010746a:	c7 45 d0 cc ab 12 c0 	movl   $0xc012abcc,-0x30(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0107471:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107474:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0107477:	89 50 04             	mov    %edx,0x4(%eax)
c010747a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010747d:	8b 50 04             	mov    0x4(%eax),%edx
c0107480:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107483:	89 10                	mov    %edx,(%eax)
c0107485:	c7 45 d8 cc ab 12 c0 	movl   $0xc012abcc,-0x28(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c010748c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010748f:	8b 40 04             	mov    0x4(%eax),%eax
c0107492:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0107495:	0f 94 c0             	sete   %al
c0107498:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c010749b:	85 c0                	test   %eax,%eax
c010749d:	75 19                	jne    c01074b8 <default_check+0x197>
c010749f:	68 e3 c1 10 c0       	push   $0xc010c1e3
c01074a4:	68 72 c0 10 c0       	push   $0xc010c072
c01074a9:	68 ef 00 00 00       	push   $0xef
c01074ae:	68 87 c0 10 c0       	push   $0xc010c087
c01074b3:	e8 a4 a2 ff ff       	call   c010175c <__panic>
    assert(alloc_page() == NULL);
c01074b8:	83 ec 0c             	sub    $0xc,%esp
c01074bb:	6a 01                	push   $0x1
c01074bd:	e8 e3 06 00 00       	call   c0107ba5 <alloc_pages>
c01074c2:	83 c4 10             	add    $0x10,%esp
c01074c5:	85 c0                	test   %eax,%eax
c01074c7:	74 19                	je     c01074e2 <default_check+0x1c1>
c01074c9:	68 fa c1 10 c0       	push   $0xc010c1fa
c01074ce:	68 72 c0 10 c0       	push   $0xc010c072
c01074d3:	68 f0 00 00 00       	push   $0xf0
c01074d8:	68 87 c0 10 c0       	push   $0xc010c087
c01074dd:	e8 7a a2 ff ff       	call   c010175c <__panic>

    unsigned int nr_free_store = nr_free;
c01074e2:	a1 d4 ab 12 c0       	mov    0xc012abd4,%eax
c01074e7:	89 45 cc             	mov    %eax,-0x34(%ebp)
    nr_free = 0;
c01074ea:	c7 05 d4 ab 12 c0 00 	movl   $0x0,0xc012abd4
c01074f1:	00 00 00 

    free_pages(p0 + 2, 3);
c01074f4:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01074f7:	83 c0 48             	add    $0x48,%eax
c01074fa:	83 ec 08             	sub    $0x8,%esp
c01074fd:	6a 03                	push   $0x3
c01074ff:	50                   	push   %eax
c0107500:	e8 0c 07 00 00       	call   c0107c11 <free_pages>
c0107505:	83 c4 10             	add    $0x10,%esp
    assert(alloc_pages(4) == NULL);
c0107508:	83 ec 0c             	sub    $0xc,%esp
c010750b:	6a 04                	push   $0x4
c010750d:	e8 93 06 00 00       	call   c0107ba5 <alloc_pages>
c0107512:	83 c4 10             	add    $0x10,%esp
c0107515:	85 c0                	test   %eax,%eax
c0107517:	74 19                	je     c0107532 <default_check+0x211>
c0107519:	68 a0 c2 10 c0       	push   $0xc010c2a0
c010751e:	68 72 c0 10 c0       	push   $0xc010c072
c0107523:	68 f6 00 00 00       	push   $0xf6
c0107528:	68 87 c0 10 c0       	push   $0xc010c087
c010752d:	e8 2a a2 ff ff       	call   c010175c <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c0107532:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107535:	83 c0 48             	add    $0x48,%eax
c0107538:	83 c0 04             	add    $0x4,%eax
c010753b:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c0107542:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0107545:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0107548:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010754b:	0f a3 10             	bt     %edx,(%eax)
c010754e:	19 c0                	sbb    %eax,%eax
c0107550:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0107553:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0107557:	0f 95 c0             	setne  %al
c010755a:	0f b6 c0             	movzbl %al,%eax
c010755d:	85 c0                	test   %eax,%eax
c010755f:	74 0e                	je     c010756f <default_check+0x24e>
c0107561:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107564:	83 c0 48             	add    $0x48,%eax
c0107567:	8b 40 08             	mov    0x8(%eax),%eax
c010756a:	83 f8 03             	cmp    $0x3,%eax
c010756d:	74 19                	je     c0107588 <default_check+0x267>
c010756f:	68 b8 c2 10 c0       	push   $0xc010c2b8
c0107574:	68 72 c0 10 c0       	push   $0xc010c072
c0107579:	68 f7 00 00 00       	push   $0xf7
c010757e:	68 87 c0 10 c0       	push   $0xc010c087
c0107583:	e8 d4 a1 ff ff       	call   c010175c <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c0107588:	83 ec 0c             	sub    $0xc,%esp
c010758b:	6a 03                	push   $0x3
c010758d:	e8 13 06 00 00       	call   c0107ba5 <alloc_pages>
c0107592:	83 c4 10             	add    $0x10,%esp
c0107595:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c0107598:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
c010759c:	75 19                	jne    c01075b7 <default_check+0x296>
c010759e:	68 e4 c2 10 c0       	push   $0xc010c2e4
c01075a3:	68 72 c0 10 c0       	push   $0xc010c072
c01075a8:	68 f8 00 00 00       	push   $0xf8
c01075ad:	68 87 c0 10 c0       	push   $0xc010c087
c01075b2:	e8 a5 a1 ff ff       	call   c010175c <__panic>
    assert(alloc_page() == NULL);
c01075b7:	83 ec 0c             	sub    $0xc,%esp
c01075ba:	6a 01                	push   $0x1
c01075bc:	e8 e4 05 00 00       	call   c0107ba5 <alloc_pages>
c01075c1:	83 c4 10             	add    $0x10,%esp
c01075c4:	85 c0                	test   %eax,%eax
c01075c6:	74 19                	je     c01075e1 <default_check+0x2c0>
c01075c8:	68 fa c1 10 c0       	push   $0xc010c1fa
c01075cd:	68 72 c0 10 c0       	push   $0xc010c072
c01075d2:	68 f9 00 00 00       	push   $0xf9
c01075d7:	68 87 c0 10 c0       	push   $0xc010c087
c01075dc:	e8 7b a1 ff ff       	call   c010175c <__panic>
    assert(p0 + 2 == p1);
c01075e1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01075e4:	83 c0 48             	add    $0x48,%eax
c01075e7:	3b 45 c4             	cmp    -0x3c(%ebp),%eax
c01075ea:	74 19                	je     c0107605 <default_check+0x2e4>
c01075ec:	68 02 c3 10 c0       	push   $0xc010c302
c01075f1:	68 72 c0 10 c0       	push   $0xc010c072
c01075f6:	68 fa 00 00 00       	push   $0xfa
c01075fb:	68 87 c0 10 c0       	push   $0xc010c087
c0107600:	e8 57 a1 ff ff       	call   c010175c <__panic>

    p2 = p0 + 1;
c0107605:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107608:	83 c0 24             	add    $0x24,%eax
c010760b:	89 45 c0             	mov    %eax,-0x40(%ebp)
    free_page(p0);
c010760e:	83 ec 08             	sub    $0x8,%esp
c0107611:	6a 01                	push   $0x1
c0107613:	ff 75 dc             	pushl  -0x24(%ebp)
c0107616:	e8 f6 05 00 00       	call   c0107c11 <free_pages>
c010761b:	83 c4 10             	add    $0x10,%esp
    free_pages(p1, 3);
c010761e:	83 ec 08             	sub    $0x8,%esp
c0107621:	6a 03                	push   $0x3
c0107623:	ff 75 c4             	pushl  -0x3c(%ebp)
c0107626:	e8 e6 05 00 00       	call   c0107c11 <free_pages>
c010762b:	83 c4 10             	add    $0x10,%esp
    assert(PageProperty(p0) && p0->property == 1);
c010762e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107631:	83 c0 04             	add    $0x4,%eax
c0107634:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c010763b:	89 45 94             	mov    %eax,-0x6c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010763e:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0107641:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0107644:	0f a3 10             	bt     %edx,(%eax)
c0107647:	19 c0                	sbb    %eax,%eax
c0107649:	89 45 90             	mov    %eax,-0x70(%ebp)
    return oldbit != 0;
c010764c:	83 7d 90 00          	cmpl   $0x0,-0x70(%ebp)
c0107650:	0f 95 c0             	setne  %al
c0107653:	0f b6 c0             	movzbl %al,%eax
c0107656:	85 c0                	test   %eax,%eax
c0107658:	74 0b                	je     c0107665 <default_check+0x344>
c010765a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010765d:	8b 40 08             	mov    0x8(%eax),%eax
c0107660:	83 f8 01             	cmp    $0x1,%eax
c0107663:	74 19                	je     c010767e <default_check+0x35d>
c0107665:	68 10 c3 10 c0       	push   $0xc010c310
c010766a:	68 72 c0 10 c0       	push   $0xc010c072
c010766f:	68 ff 00 00 00       	push   $0xff
c0107674:	68 87 c0 10 c0       	push   $0xc010c087
c0107679:	e8 de a0 ff ff       	call   c010175c <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c010767e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0107681:	83 c0 04             	add    $0x4,%eax
c0107684:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
c010768b:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010768e:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0107691:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0107694:	0f a3 10             	bt     %edx,(%eax)
c0107697:	19 c0                	sbb    %eax,%eax
c0107699:	89 45 88             	mov    %eax,-0x78(%ebp)
    return oldbit != 0;
c010769c:	83 7d 88 00          	cmpl   $0x0,-0x78(%ebp)
c01076a0:	0f 95 c0             	setne  %al
c01076a3:	0f b6 c0             	movzbl %al,%eax
c01076a6:	85 c0                	test   %eax,%eax
c01076a8:	74 0b                	je     c01076b5 <default_check+0x394>
c01076aa:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01076ad:	8b 40 08             	mov    0x8(%eax),%eax
c01076b0:	83 f8 03             	cmp    $0x3,%eax
c01076b3:	74 19                	je     c01076ce <default_check+0x3ad>
c01076b5:	68 38 c3 10 c0       	push   $0xc010c338
c01076ba:	68 72 c0 10 c0       	push   $0xc010c072
c01076bf:	68 00 01 00 00       	push   $0x100
c01076c4:	68 87 c0 10 c0       	push   $0xc010c087
c01076c9:	e8 8e a0 ff ff       	call   c010175c <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c01076ce:	83 ec 0c             	sub    $0xc,%esp
c01076d1:	6a 01                	push   $0x1
c01076d3:	e8 cd 04 00 00       	call   c0107ba5 <alloc_pages>
c01076d8:	83 c4 10             	add    $0x10,%esp
c01076db:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01076de:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01076e1:	83 e8 24             	sub    $0x24,%eax
c01076e4:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c01076e7:	74 19                	je     c0107702 <default_check+0x3e1>
c01076e9:	68 5e c3 10 c0       	push   $0xc010c35e
c01076ee:	68 72 c0 10 c0       	push   $0xc010c072
c01076f3:	68 02 01 00 00       	push   $0x102
c01076f8:	68 87 c0 10 c0       	push   $0xc010c087
c01076fd:	e8 5a a0 ff ff       	call   c010175c <__panic>
    free_page(p0);
c0107702:	83 ec 08             	sub    $0x8,%esp
c0107705:	6a 01                	push   $0x1
c0107707:	ff 75 dc             	pushl  -0x24(%ebp)
c010770a:	e8 02 05 00 00       	call   c0107c11 <free_pages>
c010770f:	83 c4 10             	add    $0x10,%esp
    assert((p0 = alloc_pages(2)) == p2 + 1);
c0107712:	83 ec 0c             	sub    $0xc,%esp
c0107715:	6a 02                	push   $0x2
c0107717:	e8 89 04 00 00       	call   c0107ba5 <alloc_pages>
c010771c:	83 c4 10             	add    $0x10,%esp
c010771f:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0107722:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0107725:	83 c0 24             	add    $0x24,%eax
c0107728:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c010772b:	74 19                	je     c0107746 <default_check+0x425>
c010772d:	68 7c c3 10 c0       	push   $0xc010c37c
c0107732:	68 72 c0 10 c0       	push   $0xc010c072
c0107737:	68 04 01 00 00       	push   $0x104
c010773c:	68 87 c0 10 c0       	push   $0xc010c087
c0107741:	e8 16 a0 ff ff       	call   c010175c <__panic>

    free_pages(p0, 2);
c0107746:	83 ec 08             	sub    $0x8,%esp
c0107749:	6a 02                	push   $0x2
c010774b:	ff 75 dc             	pushl  -0x24(%ebp)
c010774e:	e8 be 04 00 00       	call   c0107c11 <free_pages>
c0107753:	83 c4 10             	add    $0x10,%esp
    free_page(p2);
c0107756:	83 ec 08             	sub    $0x8,%esp
c0107759:	6a 01                	push   $0x1
c010775b:	ff 75 c0             	pushl  -0x40(%ebp)
c010775e:	e8 ae 04 00 00       	call   c0107c11 <free_pages>
c0107763:	83 c4 10             	add    $0x10,%esp

    assert((p0 = alloc_pages(5)) != NULL);
c0107766:	83 ec 0c             	sub    $0xc,%esp
c0107769:	6a 05                	push   $0x5
c010776b:	e8 35 04 00 00       	call   c0107ba5 <alloc_pages>
c0107770:	83 c4 10             	add    $0x10,%esp
c0107773:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0107776:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010777a:	75 19                	jne    c0107795 <default_check+0x474>
c010777c:	68 9c c3 10 c0       	push   $0xc010c39c
c0107781:	68 72 c0 10 c0       	push   $0xc010c072
c0107786:	68 09 01 00 00       	push   $0x109
c010778b:	68 87 c0 10 c0       	push   $0xc010c087
c0107790:	e8 c7 9f ff ff       	call   c010175c <__panic>
    assert(alloc_page() == NULL);
c0107795:	83 ec 0c             	sub    $0xc,%esp
c0107798:	6a 01                	push   $0x1
c010779a:	e8 06 04 00 00       	call   c0107ba5 <alloc_pages>
c010779f:	83 c4 10             	add    $0x10,%esp
c01077a2:	85 c0                	test   %eax,%eax
c01077a4:	74 19                	je     c01077bf <default_check+0x49e>
c01077a6:	68 fa c1 10 c0       	push   $0xc010c1fa
c01077ab:	68 72 c0 10 c0       	push   $0xc010c072
c01077b0:	68 0a 01 00 00       	push   $0x10a
c01077b5:	68 87 c0 10 c0       	push   $0xc010c087
c01077ba:	e8 9d 9f ff ff       	call   c010175c <__panic>

    assert(nr_free == 0);
c01077bf:	a1 d4 ab 12 c0       	mov    0xc012abd4,%eax
c01077c4:	85 c0                	test   %eax,%eax
c01077c6:	74 19                	je     c01077e1 <default_check+0x4c0>
c01077c8:	68 4d c2 10 c0       	push   $0xc010c24d
c01077cd:	68 72 c0 10 c0       	push   $0xc010c072
c01077d2:	68 0c 01 00 00       	push   $0x10c
c01077d7:	68 87 c0 10 c0       	push   $0xc010c087
c01077dc:	e8 7b 9f ff ff       	call   c010175c <__panic>
    nr_free = nr_free_store;
c01077e1:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01077e4:	a3 d4 ab 12 c0       	mov    %eax,0xc012abd4

    free_list = free_list_store;
c01077e9:	8b 45 80             	mov    -0x80(%ebp),%eax
c01077ec:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01077ef:	a3 cc ab 12 c0       	mov    %eax,0xc012abcc
c01077f4:	89 15 d0 ab 12 c0    	mov    %edx,0xc012abd0
    free_pages(p0, 5);
c01077fa:	83 ec 08             	sub    $0x8,%esp
c01077fd:	6a 05                	push   $0x5
c01077ff:	ff 75 dc             	pushl  -0x24(%ebp)
c0107802:	e8 0a 04 00 00       	call   c0107c11 <free_pages>
c0107807:	83 c4 10             	add    $0x10,%esp

    le = &free_list;
c010780a:	c7 45 ec cc ab 12 c0 	movl   $0xc012abcc,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0107811:	eb 1d                	jmp    c0107830 <default_check+0x50f>
        struct Page *p = le2page(le, page_link);
c0107813:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107816:	83 e8 10             	sub    $0x10,%eax
c0107819:	89 45 b4             	mov    %eax,-0x4c(%ebp)
        count --, total -= p->property;
c010781c:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0107820:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0107823:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0107826:	8b 40 08             	mov    0x8(%eax),%eax
c0107829:	29 c2                	sub    %eax,%edx
c010782b:	89 d0                	mov    %edx,%eax
c010782d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107830:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107833:	89 45 b8             	mov    %eax,-0x48(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0107836:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0107839:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c010783c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010783f:	81 7d ec cc ab 12 c0 	cmpl   $0xc012abcc,-0x14(%ebp)
c0107846:	75 cb                	jne    c0107813 <default_check+0x4f2>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
c0107848:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010784c:	74 19                	je     c0107867 <default_check+0x546>
c010784e:	68 ba c3 10 c0       	push   $0xc010c3ba
c0107853:	68 72 c0 10 c0       	push   $0xc010c072
c0107858:	68 17 01 00 00       	push   $0x117
c010785d:	68 87 c0 10 c0       	push   $0xc010c087
c0107862:	e8 f5 9e ff ff       	call   c010175c <__panic>
    assert(total == 0);
c0107867:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010786b:	74 19                	je     c0107886 <default_check+0x565>
c010786d:	68 c5 c3 10 c0       	push   $0xc010c3c5
c0107872:	68 72 c0 10 c0       	push   $0xc010c072
c0107877:	68 18 01 00 00       	push   $0x118
c010787c:	68 87 c0 10 c0       	push   $0xc010c087
c0107881:	e8 d6 9e ff ff       	call   c010175c <__panic>
}
c0107886:	90                   	nop
c0107887:	c9                   	leave  
c0107888:	c3                   	ret    

c0107889 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0107889:	55                   	push   %ebp
c010788a:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010788c:	8b 45 08             	mov    0x8(%ebp),%eax
c010788f:	8b 15 e0 ab 12 c0    	mov    0xc012abe0,%edx
c0107895:	29 d0                	sub    %edx,%eax
c0107897:	c1 f8 02             	sar    $0x2,%eax
c010789a:	69 c0 39 8e e3 38    	imul   $0x38e38e39,%eax,%eax
}
c01078a0:	5d                   	pop    %ebp
c01078a1:	c3                   	ret    

c01078a2 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c01078a2:	55                   	push   %ebp
c01078a3:	89 e5                	mov    %esp,%ebp
    return page2ppn(page) << PGSHIFT;
c01078a5:	ff 75 08             	pushl  0x8(%ebp)
c01078a8:	e8 dc ff ff ff       	call   c0107889 <page2ppn>
c01078ad:	83 c4 04             	add    $0x4,%esp
c01078b0:	c1 e0 0c             	shl    $0xc,%eax
}
c01078b3:	c9                   	leave  
c01078b4:	c3                   	ret    

c01078b5 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c01078b5:	55                   	push   %ebp
c01078b6:	89 e5                	mov    %esp,%ebp
c01078b8:	83 ec 08             	sub    $0x8,%esp
    if (PPN(pa) >= npage) {
c01078bb:	8b 45 08             	mov    0x8(%ebp),%eax
c01078be:	c1 e8 0c             	shr    $0xc,%eax
c01078c1:	89 c2                	mov    %eax,%edx
c01078c3:	a1 20 8a 12 c0       	mov    0xc0128a20,%eax
c01078c8:	39 c2                	cmp    %eax,%edx
c01078ca:	72 14                	jb     c01078e0 <pa2page+0x2b>
        panic("pa2page called with invalid pa");
c01078cc:	83 ec 04             	sub    $0x4,%esp
c01078cf:	68 00 c4 10 c0       	push   $0xc010c400
c01078d4:	6a 5f                	push   $0x5f
c01078d6:	68 1f c4 10 c0       	push   $0xc010c41f
c01078db:	e8 7c 9e ff ff       	call   c010175c <__panic>
    }
    return &pages[PPN(pa)];
c01078e0:	8b 0d e0 ab 12 c0    	mov    0xc012abe0,%ecx
c01078e6:	8b 45 08             	mov    0x8(%ebp),%eax
c01078e9:	c1 e8 0c             	shr    $0xc,%eax
c01078ec:	89 c2                	mov    %eax,%edx
c01078ee:	89 d0                	mov    %edx,%eax
c01078f0:	c1 e0 03             	shl    $0x3,%eax
c01078f3:	01 d0                	add    %edx,%eax
c01078f5:	c1 e0 02             	shl    $0x2,%eax
c01078f8:	01 c8                	add    %ecx,%eax
}
c01078fa:	c9                   	leave  
c01078fb:	c3                   	ret    

c01078fc <page2kva>:

static inline void *
page2kva(struct Page *page) {
c01078fc:	55                   	push   %ebp
c01078fd:	89 e5                	mov    %esp,%ebp
c01078ff:	83 ec 18             	sub    $0x18,%esp
    return KADDR(page2pa(page));
c0107902:	ff 75 08             	pushl  0x8(%ebp)
c0107905:	e8 98 ff ff ff       	call   c01078a2 <page2pa>
c010790a:	83 c4 04             	add    $0x4,%esp
c010790d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107910:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107913:	c1 e8 0c             	shr    $0xc,%eax
c0107916:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107919:	a1 20 8a 12 c0       	mov    0xc0128a20,%eax
c010791e:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0107921:	72 14                	jb     c0107937 <page2kva+0x3b>
c0107923:	ff 75 f4             	pushl  -0xc(%ebp)
c0107926:	68 30 c4 10 c0       	push   $0xc010c430
c010792b:	6a 66                	push   $0x66
c010792d:	68 1f c4 10 c0       	push   $0xc010c41f
c0107932:	e8 25 9e ff ff       	call   c010175c <__panic>
c0107937:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010793a:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c010793f:	c9                   	leave  
c0107940:	c3                   	ret    

c0107941 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c0107941:	55                   	push   %ebp
c0107942:	89 e5                	mov    %esp,%ebp
c0107944:	83 ec 08             	sub    $0x8,%esp
    if (!(pte & PTE_P)) {
c0107947:	8b 45 08             	mov    0x8(%ebp),%eax
c010794a:	83 e0 01             	and    $0x1,%eax
c010794d:	85 c0                	test   %eax,%eax
c010794f:	75 14                	jne    c0107965 <pte2page+0x24>
        panic("pte2page called with invalid pte");
c0107951:	83 ec 04             	sub    $0x4,%esp
c0107954:	68 54 c4 10 c0       	push   $0xc010c454
c0107959:	6a 71                	push   $0x71
c010795b:	68 1f c4 10 c0       	push   $0xc010c41f
c0107960:	e8 f7 9d ff ff       	call   c010175c <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0107965:	8b 45 08             	mov    0x8(%ebp),%eax
c0107968:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010796d:	83 ec 0c             	sub    $0xc,%esp
c0107970:	50                   	push   %eax
c0107971:	e8 3f ff ff ff       	call   c01078b5 <pa2page>
c0107976:	83 c4 10             	add    $0x10,%esp
}
c0107979:	c9                   	leave  
c010797a:	c3                   	ret    

c010797b <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c010797b:	55                   	push   %ebp
c010797c:	89 e5                	mov    %esp,%ebp
c010797e:	83 ec 08             	sub    $0x8,%esp
    return pa2page(PDE_ADDR(pde));
c0107981:	8b 45 08             	mov    0x8(%ebp),%eax
c0107984:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107989:	83 ec 0c             	sub    $0xc,%esp
c010798c:	50                   	push   %eax
c010798d:	e8 23 ff ff ff       	call   c01078b5 <pa2page>
c0107992:	83 c4 10             	add    $0x10,%esp
}
c0107995:	c9                   	leave  
c0107996:	c3                   	ret    

c0107997 <page_ref>:

static inline int
page_ref(struct Page *page) {
c0107997:	55                   	push   %ebp
c0107998:	89 e5                	mov    %esp,%ebp
    return page->ref;
c010799a:	8b 45 08             	mov    0x8(%ebp),%eax
c010799d:	8b 00                	mov    (%eax),%eax
}
c010799f:	5d                   	pop    %ebp
c01079a0:	c3                   	ret    

c01079a1 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c01079a1:	55                   	push   %ebp
c01079a2:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c01079a4:	8b 45 08             	mov    0x8(%ebp),%eax
c01079a7:	8b 55 0c             	mov    0xc(%ebp),%edx
c01079aa:	89 10                	mov    %edx,(%eax)
}
c01079ac:	90                   	nop
c01079ad:	5d                   	pop    %ebp
c01079ae:	c3                   	ret    

c01079af <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c01079af:	55                   	push   %ebp
c01079b0:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c01079b2:	8b 45 08             	mov    0x8(%ebp),%eax
c01079b5:	8b 00                	mov    (%eax),%eax
c01079b7:	8d 50 01             	lea    0x1(%eax),%edx
c01079ba:	8b 45 08             	mov    0x8(%ebp),%eax
c01079bd:	89 10                	mov    %edx,(%eax)
    return page->ref;
c01079bf:	8b 45 08             	mov    0x8(%ebp),%eax
c01079c2:	8b 00                	mov    (%eax),%eax
}
c01079c4:	5d                   	pop    %ebp
c01079c5:	c3                   	ret    

c01079c6 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c01079c6:	55                   	push   %ebp
c01079c7:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c01079c9:	8b 45 08             	mov    0x8(%ebp),%eax
c01079cc:	8b 00                	mov    (%eax),%eax
c01079ce:	8d 50 ff             	lea    -0x1(%eax),%edx
c01079d1:	8b 45 08             	mov    0x8(%ebp),%eax
c01079d4:	89 10                	mov    %edx,(%eax)
    return page->ref;
c01079d6:	8b 45 08             	mov    0x8(%ebp),%eax
c01079d9:	8b 00                	mov    (%eax),%eax
}
c01079db:	5d                   	pop    %ebp
c01079dc:	c3                   	ret    

c01079dd <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c01079dd:	55                   	push   %ebp
c01079de:	89 e5                	mov    %esp,%ebp
c01079e0:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c01079e3:	9c                   	pushf  
c01079e4:	58                   	pop    %eax
c01079e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01079e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01079eb:	25 00 02 00 00       	and    $0x200,%eax
c01079f0:	85 c0                	test   %eax,%eax
c01079f2:	74 0c                	je     c0107a00 <__intr_save+0x23>
        intr_disable();
c01079f4:	e8 2f ba ff ff       	call   c0103428 <intr_disable>
        return 1;
c01079f9:	b8 01 00 00 00       	mov    $0x1,%eax
c01079fe:	eb 05                	jmp    c0107a05 <__intr_save+0x28>
    }
    return 0;
c0107a00:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107a05:	c9                   	leave  
c0107a06:	c3                   	ret    

c0107a07 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0107a07:	55                   	push   %ebp
c0107a08:	89 e5                	mov    %esp,%ebp
c0107a0a:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0107a0d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0107a11:	74 05                	je     c0107a18 <__intr_restore+0x11>
        intr_enable();
c0107a13:	e8 09 ba ff ff       	call   c0103421 <intr_enable>
    }
}
c0107a18:	90                   	nop
c0107a19:	c9                   	leave  
c0107a1a:	c3                   	ret    

c0107a1b <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0107a1b:	55                   	push   %ebp
c0107a1c:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0107a1e:	8b 45 08             	mov    0x8(%ebp),%eax
c0107a21:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0107a24:	b8 23 00 00 00       	mov    $0x23,%eax
c0107a29:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0107a2b:	b8 23 00 00 00       	mov    $0x23,%eax
c0107a30:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0107a32:	b8 10 00 00 00       	mov    $0x10,%eax
c0107a37:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0107a39:	b8 10 00 00 00       	mov    $0x10,%eax
c0107a3e:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0107a40:	b8 10 00 00 00       	mov    $0x10,%eax
c0107a45:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0107a47:	ea 4e 7a 10 c0 08 00 	ljmp   $0x8,$0xc0107a4e
}
c0107a4e:	90                   	nop
c0107a4f:	5d                   	pop    %ebp
c0107a50:	c3                   	ret    

c0107a51 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0107a51:	55                   	push   %ebp
c0107a52:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0107a54:	8b 45 08             	mov    0x8(%ebp),%eax
c0107a57:	a3 44 8a 12 c0       	mov    %eax,0xc0128a44
}
c0107a5c:	90                   	nop
c0107a5d:	5d                   	pop    %ebp
c0107a5e:	c3                   	ret    

c0107a5f <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0107a5f:	55                   	push   %ebp
c0107a60:	89 e5                	mov    %esp,%ebp
c0107a62:	83 ec 10             	sub    $0x10,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0107a65:	b8 00 70 12 c0       	mov    $0xc0127000,%eax
c0107a6a:	50                   	push   %eax
c0107a6b:	e8 e1 ff ff ff       	call   c0107a51 <load_esp0>
c0107a70:	83 c4 04             	add    $0x4,%esp
    ts.ts_ss0 = KERNEL_DS;
c0107a73:	66 c7 05 48 8a 12 c0 	movw   $0x10,0xc0128a48
c0107a7a:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0107a7c:	66 c7 05 68 7a 12 c0 	movw   $0x68,0xc0127a68
c0107a83:	68 00 
c0107a85:	b8 40 8a 12 c0       	mov    $0xc0128a40,%eax
c0107a8a:	66 a3 6a 7a 12 c0    	mov    %ax,0xc0127a6a
c0107a90:	b8 40 8a 12 c0       	mov    $0xc0128a40,%eax
c0107a95:	c1 e8 10             	shr    $0x10,%eax
c0107a98:	a2 6c 7a 12 c0       	mov    %al,0xc0127a6c
c0107a9d:	0f b6 05 6d 7a 12 c0 	movzbl 0xc0127a6d,%eax
c0107aa4:	83 e0 f0             	and    $0xfffffff0,%eax
c0107aa7:	83 c8 09             	or     $0x9,%eax
c0107aaa:	a2 6d 7a 12 c0       	mov    %al,0xc0127a6d
c0107aaf:	0f b6 05 6d 7a 12 c0 	movzbl 0xc0127a6d,%eax
c0107ab6:	83 e0 ef             	and    $0xffffffef,%eax
c0107ab9:	a2 6d 7a 12 c0       	mov    %al,0xc0127a6d
c0107abe:	0f b6 05 6d 7a 12 c0 	movzbl 0xc0127a6d,%eax
c0107ac5:	83 e0 9f             	and    $0xffffff9f,%eax
c0107ac8:	a2 6d 7a 12 c0       	mov    %al,0xc0127a6d
c0107acd:	0f b6 05 6d 7a 12 c0 	movzbl 0xc0127a6d,%eax
c0107ad4:	83 c8 80             	or     $0xffffff80,%eax
c0107ad7:	a2 6d 7a 12 c0       	mov    %al,0xc0127a6d
c0107adc:	0f b6 05 6e 7a 12 c0 	movzbl 0xc0127a6e,%eax
c0107ae3:	83 e0 f0             	and    $0xfffffff0,%eax
c0107ae6:	a2 6e 7a 12 c0       	mov    %al,0xc0127a6e
c0107aeb:	0f b6 05 6e 7a 12 c0 	movzbl 0xc0127a6e,%eax
c0107af2:	83 e0 ef             	and    $0xffffffef,%eax
c0107af5:	a2 6e 7a 12 c0       	mov    %al,0xc0127a6e
c0107afa:	0f b6 05 6e 7a 12 c0 	movzbl 0xc0127a6e,%eax
c0107b01:	83 e0 df             	and    $0xffffffdf,%eax
c0107b04:	a2 6e 7a 12 c0       	mov    %al,0xc0127a6e
c0107b09:	0f b6 05 6e 7a 12 c0 	movzbl 0xc0127a6e,%eax
c0107b10:	83 c8 40             	or     $0x40,%eax
c0107b13:	a2 6e 7a 12 c0       	mov    %al,0xc0127a6e
c0107b18:	0f b6 05 6e 7a 12 c0 	movzbl 0xc0127a6e,%eax
c0107b1f:	83 e0 7f             	and    $0x7f,%eax
c0107b22:	a2 6e 7a 12 c0       	mov    %al,0xc0127a6e
c0107b27:	b8 40 8a 12 c0       	mov    $0xc0128a40,%eax
c0107b2c:	c1 e8 18             	shr    $0x18,%eax
c0107b2f:	a2 6f 7a 12 c0       	mov    %al,0xc0127a6f

    // reload all segment registers
    lgdt(&gdt_pd);
c0107b34:	68 70 7a 12 c0       	push   $0xc0127a70
c0107b39:	e8 dd fe ff ff       	call   c0107a1b <lgdt>
c0107b3e:	83 c4 04             	add    $0x4,%esp
c0107b41:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0107b47:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0107b4b:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c0107b4e:	90                   	nop
c0107b4f:	c9                   	leave  
c0107b50:	c3                   	ret    

c0107b51 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0107b51:	55                   	push   %ebp
c0107b52:	89 e5                	mov    %esp,%ebp
c0107b54:	83 ec 08             	sub    $0x8,%esp
    pmm_manager = &default_pmm_manager;
c0107b57:	c7 05 d8 ab 12 c0 e4 	movl   $0xc010c3e4,0xc012abd8
c0107b5e:	c3 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0107b61:	a1 d8 ab 12 c0       	mov    0xc012abd8,%eax
c0107b66:	8b 00                	mov    (%eax),%eax
c0107b68:	83 ec 08             	sub    $0x8,%esp
c0107b6b:	50                   	push   %eax
c0107b6c:	68 80 c4 10 c0       	push   $0xc010c480
c0107b71:	e8 08 87 ff ff       	call   c010027e <cprintf>
c0107b76:	83 c4 10             	add    $0x10,%esp
    pmm_manager->init();
c0107b79:	a1 d8 ab 12 c0       	mov    0xc012abd8,%eax
c0107b7e:	8b 40 04             	mov    0x4(%eax),%eax
c0107b81:	ff d0                	call   *%eax
}
c0107b83:	90                   	nop
c0107b84:	c9                   	leave  
c0107b85:	c3                   	ret    

c0107b86 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0107b86:	55                   	push   %ebp
c0107b87:	89 e5                	mov    %esp,%ebp
c0107b89:	83 ec 08             	sub    $0x8,%esp
    pmm_manager->init_memmap(base, n);
c0107b8c:	a1 d8 ab 12 c0       	mov    0xc012abd8,%eax
c0107b91:	8b 40 08             	mov    0x8(%eax),%eax
c0107b94:	83 ec 08             	sub    $0x8,%esp
c0107b97:	ff 75 0c             	pushl  0xc(%ebp)
c0107b9a:	ff 75 08             	pushl  0x8(%ebp)
c0107b9d:	ff d0                	call   *%eax
c0107b9f:	83 c4 10             	add    $0x10,%esp
}
c0107ba2:	90                   	nop
c0107ba3:	c9                   	leave  
c0107ba4:	c3                   	ret    

c0107ba5 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0107ba5:	55                   	push   %ebp
c0107ba6:	89 e5                	mov    %esp,%ebp
c0107ba8:	83 ec 18             	sub    $0x18,%esp
    struct Page *page=NULL;
c0107bab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    
    while (1)
    {
         local_intr_save(intr_flag);
c0107bb2:	e8 26 fe ff ff       	call   c01079dd <__intr_save>
c0107bb7:	89 45 f0             	mov    %eax,-0x10(%ebp)
         {
              page = pmm_manager->alloc_pages(n);
c0107bba:	a1 d8 ab 12 c0       	mov    0xc012abd8,%eax
c0107bbf:	8b 40 0c             	mov    0xc(%eax),%eax
c0107bc2:	83 ec 0c             	sub    $0xc,%esp
c0107bc5:	ff 75 08             	pushl  0x8(%ebp)
c0107bc8:	ff d0                	call   *%eax
c0107bca:	83 c4 10             	add    $0x10,%esp
c0107bcd:	89 45 f4             	mov    %eax,-0xc(%ebp)
         }
         local_intr_restore(intr_flag);
c0107bd0:	83 ec 0c             	sub    $0xc,%esp
c0107bd3:	ff 75 f0             	pushl  -0x10(%ebp)
c0107bd6:	e8 2c fe ff ff       	call   c0107a07 <__intr_restore>
c0107bdb:	83 c4 10             	add    $0x10,%esp

         if (page != NULL || n > 1 || swap_init_ok == 0) break;
c0107bde:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107be2:	75 28                	jne    c0107c0c <alloc_pages+0x67>
c0107be4:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
c0107be8:	77 22                	ja     c0107c0c <alloc_pages+0x67>
c0107bea:	a1 08 8a 12 c0       	mov    0xc0128a08,%eax
c0107bef:	85 c0                	test   %eax,%eax
c0107bf1:	74 19                	je     c0107c0c <alloc_pages+0x67>
         
         extern struct mm_struct *check_mm_struct;
         //cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
         swap_out(check_mm_struct, n, 0);
c0107bf3:	8b 55 08             	mov    0x8(%ebp),%edx
c0107bf6:	a1 f8 aa 12 c0       	mov    0xc012aaf8,%eax
c0107bfb:	83 ec 04             	sub    $0x4,%esp
c0107bfe:	6a 00                	push   $0x0
c0107c00:	52                   	push   %edx
c0107c01:	50                   	push   %eax
c0107c02:	e8 9f d6 ff ff       	call   c01052a6 <swap_out>
c0107c07:	83 c4 10             	add    $0x10,%esp
    }
c0107c0a:	eb a6                	jmp    c0107bb2 <alloc_pages+0xd>
    //cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
c0107c0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0107c0f:	c9                   	leave  
c0107c10:	c3                   	ret    

c0107c11 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0107c11:	55                   	push   %ebp
c0107c12:	89 e5                	mov    %esp,%ebp
c0107c14:	83 ec 18             	sub    $0x18,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0107c17:	e8 c1 fd ff ff       	call   c01079dd <__intr_save>
c0107c1c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0107c1f:	a1 d8 ab 12 c0       	mov    0xc012abd8,%eax
c0107c24:	8b 40 10             	mov    0x10(%eax),%eax
c0107c27:	83 ec 08             	sub    $0x8,%esp
c0107c2a:	ff 75 0c             	pushl  0xc(%ebp)
c0107c2d:	ff 75 08             	pushl  0x8(%ebp)
c0107c30:	ff d0                	call   *%eax
c0107c32:	83 c4 10             	add    $0x10,%esp
    }
    local_intr_restore(intr_flag);
c0107c35:	83 ec 0c             	sub    $0xc,%esp
c0107c38:	ff 75 f4             	pushl  -0xc(%ebp)
c0107c3b:	e8 c7 fd ff ff       	call   c0107a07 <__intr_restore>
c0107c40:	83 c4 10             	add    $0x10,%esp
}
c0107c43:	90                   	nop
c0107c44:	c9                   	leave  
c0107c45:	c3                   	ret    

c0107c46 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0107c46:	55                   	push   %ebp
c0107c47:	89 e5                	mov    %esp,%ebp
c0107c49:	83 ec 18             	sub    $0x18,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0107c4c:	e8 8c fd ff ff       	call   c01079dd <__intr_save>
c0107c51:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0107c54:	a1 d8 ab 12 c0       	mov    0xc012abd8,%eax
c0107c59:	8b 40 14             	mov    0x14(%eax),%eax
c0107c5c:	ff d0                	call   *%eax
c0107c5e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0107c61:	83 ec 0c             	sub    $0xc,%esp
c0107c64:	ff 75 f4             	pushl  -0xc(%ebp)
c0107c67:	e8 9b fd ff ff       	call   c0107a07 <__intr_restore>
c0107c6c:	83 c4 10             	add    $0x10,%esp
    return ret;
c0107c6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0107c72:	c9                   	leave  
c0107c73:	c3                   	ret    

c0107c74 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0107c74:	55                   	push   %ebp
c0107c75:	89 e5                	mov    %esp,%ebp
c0107c77:	57                   	push   %edi
c0107c78:	56                   	push   %esi
c0107c79:	53                   	push   %ebx
c0107c7a:	83 ec 7c             	sub    $0x7c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0107c7d:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0107c84:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0107c8b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0107c92:	83 ec 0c             	sub    $0xc,%esp
c0107c95:	68 97 c4 10 c0       	push   $0xc010c497
c0107c9a:	e8 df 85 ff ff       	call   c010027e <cprintf>
c0107c9f:	83 c4 10             	add    $0x10,%esp
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0107ca2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0107ca9:	e9 fc 00 00 00       	jmp    c0107daa <page_init+0x136>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0107cae:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0107cb1:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107cb4:	89 d0                	mov    %edx,%eax
c0107cb6:	c1 e0 02             	shl    $0x2,%eax
c0107cb9:	01 d0                	add    %edx,%eax
c0107cbb:	c1 e0 02             	shl    $0x2,%eax
c0107cbe:	01 c8                	add    %ecx,%eax
c0107cc0:	8b 50 08             	mov    0x8(%eax),%edx
c0107cc3:	8b 40 04             	mov    0x4(%eax),%eax
c0107cc6:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0107cc9:	89 55 bc             	mov    %edx,-0x44(%ebp)
c0107ccc:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0107ccf:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107cd2:	89 d0                	mov    %edx,%eax
c0107cd4:	c1 e0 02             	shl    $0x2,%eax
c0107cd7:	01 d0                	add    %edx,%eax
c0107cd9:	c1 e0 02             	shl    $0x2,%eax
c0107cdc:	01 c8                	add    %ecx,%eax
c0107cde:	8b 48 0c             	mov    0xc(%eax),%ecx
c0107ce1:	8b 58 10             	mov    0x10(%eax),%ebx
c0107ce4:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0107ce7:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0107cea:	01 c8                	add    %ecx,%eax
c0107cec:	11 da                	adc    %ebx,%edx
c0107cee:	89 45 b0             	mov    %eax,-0x50(%ebp)
c0107cf1:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0107cf4:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0107cf7:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107cfa:	89 d0                	mov    %edx,%eax
c0107cfc:	c1 e0 02             	shl    $0x2,%eax
c0107cff:	01 d0                	add    %edx,%eax
c0107d01:	c1 e0 02             	shl    $0x2,%eax
c0107d04:	01 c8                	add    %ecx,%eax
c0107d06:	83 c0 14             	add    $0x14,%eax
c0107d09:	8b 00                	mov    (%eax),%eax
c0107d0b:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0107d0e:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0107d11:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0107d14:	83 c0 ff             	add    $0xffffffff,%eax
c0107d17:	83 d2 ff             	adc    $0xffffffff,%edx
c0107d1a:	89 c1                	mov    %eax,%ecx
c0107d1c:	89 d3                	mov    %edx,%ebx
c0107d1e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0107d21:	89 55 80             	mov    %edx,-0x80(%ebp)
c0107d24:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107d27:	89 d0                	mov    %edx,%eax
c0107d29:	c1 e0 02             	shl    $0x2,%eax
c0107d2c:	01 d0                	add    %edx,%eax
c0107d2e:	c1 e0 02             	shl    $0x2,%eax
c0107d31:	03 45 80             	add    -0x80(%ebp),%eax
c0107d34:	8b 50 10             	mov    0x10(%eax),%edx
c0107d37:	8b 40 0c             	mov    0xc(%eax),%eax
c0107d3a:	ff 75 84             	pushl  -0x7c(%ebp)
c0107d3d:	53                   	push   %ebx
c0107d3e:	51                   	push   %ecx
c0107d3f:	ff 75 bc             	pushl  -0x44(%ebp)
c0107d42:	ff 75 b8             	pushl  -0x48(%ebp)
c0107d45:	52                   	push   %edx
c0107d46:	50                   	push   %eax
c0107d47:	68 a4 c4 10 c0       	push   $0xc010c4a4
c0107d4c:	e8 2d 85 ff ff       	call   c010027e <cprintf>
c0107d51:	83 c4 20             	add    $0x20,%esp
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0107d54:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0107d57:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107d5a:	89 d0                	mov    %edx,%eax
c0107d5c:	c1 e0 02             	shl    $0x2,%eax
c0107d5f:	01 d0                	add    %edx,%eax
c0107d61:	c1 e0 02             	shl    $0x2,%eax
c0107d64:	01 c8                	add    %ecx,%eax
c0107d66:	83 c0 14             	add    $0x14,%eax
c0107d69:	8b 00                	mov    (%eax),%eax
c0107d6b:	83 f8 01             	cmp    $0x1,%eax
c0107d6e:	75 36                	jne    c0107da6 <page_init+0x132>
            if (maxpa < end && begin < KMEMSIZE) {
c0107d70:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107d73:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107d76:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0107d79:	77 2b                	ja     c0107da6 <page_init+0x132>
c0107d7b:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0107d7e:	72 05                	jb     c0107d85 <page_init+0x111>
c0107d80:	3b 45 b0             	cmp    -0x50(%ebp),%eax
c0107d83:	73 21                	jae    c0107da6 <page_init+0x132>
c0107d85:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0107d89:	77 1b                	ja     c0107da6 <page_init+0x132>
c0107d8b:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0107d8f:	72 09                	jb     c0107d9a <page_init+0x126>
c0107d91:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
c0107d98:	77 0c                	ja     c0107da6 <page_init+0x132>
                maxpa = end;
c0107d9a:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0107d9d:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0107da0:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0107da3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0107da6:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0107daa:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0107dad:	8b 00                	mov    (%eax),%eax
c0107daf:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0107db2:	0f 8f f6 fe ff ff    	jg     c0107cae <page_init+0x3a>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0107db8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0107dbc:	72 1d                	jb     c0107ddb <page_init+0x167>
c0107dbe:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0107dc2:	77 09                	ja     c0107dcd <page_init+0x159>
c0107dc4:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c0107dcb:	76 0e                	jbe    c0107ddb <page_init+0x167>
        maxpa = KMEMSIZE;
c0107dcd:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0107dd4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0107ddb:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107dde:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107de1:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0107de5:	c1 ea 0c             	shr    $0xc,%edx
c0107de8:	a3 20 8a 12 c0       	mov    %eax,0xc0128a20
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0107ded:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
c0107df4:	b8 ec ab 12 c0       	mov    $0xc012abec,%eax
c0107df9:	8d 50 ff             	lea    -0x1(%eax),%edx
c0107dfc:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0107dff:	01 d0                	add    %edx,%eax
c0107e01:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0107e04:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0107e07:	ba 00 00 00 00       	mov    $0x0,%edx
c0107e0c:	f7 75 ac             	divl   -0x54(%ebp)
c0107e0f:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0107e12:	29 d0                	sub    %edx,%eax
c0107e14:	a3 e0 ab 12 c0       	mov    %eax,0xc012abe0

    for (i = 0; i < npage; i ++) {
c0107e19:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0107e20:	eb 2f                	jmp    c0107e51 <page_init+0x1dd>
        SetPageReserved(pages + i);
c0107e22:	8b 0d e0 ab 12 c0    	mov    0xc012abe0,%ecx
c0107e28:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107e2b:	89 d0                	mov    %edx,%eax
c0107e2d:	c1 e0 03             	shl    $0x3,%eax
c0107e30:	01 d0                	add    %edx,%eax
c0107e32:	c1 e0 02             	shl    $0x2,%eax
c0107e35:	01 c8                	add    %ecx,%eax
c0107e37:	83 c0 04             	add    $0x4,%eax
c0107e3a:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
c0107e41:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0107e44:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0107e47:	8b 55 90             	mov    -0x70(%ebp),%edx
c0107e4a:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
c0107e4d:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0107e51:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107e54:	a1 20 8a 12 c0       	mov    0xc0128a20,%eax
c0107e59:	39 c2                	cmp    %eax,%edx
c0107e5b:	72 c5                	jb     c0107e22 <page_init+0x1ae>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0107e5d:	8b 15 20 8a 12 c0    	mov    0xc0128a20,%edx
c0107e63:	89 d0                	mov    %edx,%eax
c0107e65:	c1 e0 03             	shl    $0x3,%eax
c0107e68:	01 d0                	add    %edx,%eax
c0107e6a:	c1 e0 02             	shl    $0x2,%eax
c0107e6d:	89 c2                	mov    %eax,%edx
c0107e6f:	a1 e0 ab 12 c0       	mov    0xc012abe0,%eax
c0107e74:	01 d0                	add    %edx,%eax
c0107e76:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c0107e79:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
c0107e80:	77 17                	ja     c0107e99 <page_init+0x225>
c0107e82:	ff 75 a4             	pushl  -0x5c(%ebp)
c0107e85:	68 d4 c4 10 c0       	push   $0xc010c4d4
c0107e8a:	68 e9 00 00 00       	push   $0xe9
c0107e8f:	68 f8 c4 10 c0       	push   $0xc010c4f8
c0107e94:	e8 c3 98 ff ff       	call   c010175c <__panic>
c0107e99:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0107e9c:	05 00 00 00 40       	add    $0x40000000,%eax
c0107ea1:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0107ea4:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0107eab:	e9 69 01 00 00       	jmp    c0108019 <page_init+0x3a5>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0107eb0:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0107eb3:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107eb6:	89 d0                	mov    %edx,%eax
c0107eb8:	c1 e0 02             	shl    $0x2,%eax
c0107ebb:	01 d0                	add    %edx,%eax
c0107ebd:	c1 e0 02             	shl    $0x2,%eax
c0107ec0:	01 c8                	add    %ecx,%eax
c0107ec2:	8b 50 08             	mov    0x8(%eax),%edx
c0107ec5:	8b 40 04             	mov    0x4(%eax),%eax
c0107ec8:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0107ecb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0107ece:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0107ed1:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107ed4:	89 d0                	mov    %edx,%eax
c0107ed6:	c1 e0 02             	shl    $0x2,%eax
c0107ed9:	01 d0                	add    %edx,%eax
c0107edb:	c1 e0 02             	shl    $0x2,%eax
c0107ede:	01 c8                	add    %ecx,%eax
c0107ee0:	8b 48 0c             	mov    0xc(%eax),%ecx
c0107ee3:	8b 58 10             	mov    0x10(%eax),%ebx
c0107ee6:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107ee9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107eec:	01 c8                	add    %ecx,%eax
c0107eee:	11 da                	adc    %ebx,%edx
c0107ef0:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0107ef3:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c0107ef6:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0107ef9:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107efc:	89 d0                	mov    %edx,%eax
c0107efe:	c1 e0 02             	shl    $0x2,%eax
c0107f01:	01 d0                	add    %edx,%eax
c0107f03:	c1 e0 02             	shl    $0x2,%eax
c0107f06:	01 c8                	add    %ecx,%eax
c0107f08:	83 c0 14             	add    $0x14,%eax
c0107f0b:	8b 00                	mov    (%eax),%eax
c0107f0d:	83 f8 01             	cmp    $0x1,%eax
c0107f10:	0f 85 ff 00 00 00    	jne    c0108015 <page_init+0x3a1>
            if (begin < freemem) {
c0107f16:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0107f19:	ba 00 00 00 00       	mov    $0x0,%edx
c0107f1e:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0107f21:	72 17                	jb     c0107f3a <page_init+0x2c6>
c0107f23:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0107f26:	77 05                	ja     c0107f2d <page_init+0x2b9>
c0107f28:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0107f2b:	76 0d                	jbe    c0107f3a <page_init+0x2c6>
                begin = freemem;
c0107f2d:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0107f30:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0107f33:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c0107f3a:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0107f3e:	72 1d                	jb     c0107f5d <page_init+0x2e9>
c0107f40:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0107f44:	77 09                	ja     c0107f4f <page_init+0x2db>
c0107f46:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c0107f4d:	76 0e                	jbe    c0107f5d <page_init+0x2e9>
                end = KMEMSIZE;
c0107f4f:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0107f56:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0107f5d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107f60:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107f63:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0107f66:	0f 87 a9 00 00 00    	ja     c0108015 <page_init+0x3a1>
c0107f6c:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0107f6f:	72 09                	jb     c0107f7a <page_init+0x306>
c0107f71:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0107f74:	0f 83 9b 00 00 00    	jae    c0108015 <page_init+0x3a1>
                begin = ROUNDUP(begin, PGSIZE);
c0107f7a:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
c0107f81:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0107f84:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0107f87:	01 d0                	add    %edx,%eax
c0107f89:	83 e8 01             	sub    $0x1,%eax
c0107f8c:	89 45 98             	mov    %eax,-0x68(%ebp)
c0107f8f:	8b 45 98             	mov    -0x68(%ebp),%eax
c0107f92:	ba 00 00 00 00       	mov    $0x0,%edx
c0107f97:	f7 75 9c             	divl   -0x64(%ebp)
c0107f9a:	8b 45 98             	mov    -0x68(%ebp),%eax
c0107f9d:	29 d0                	sub    %edx,%eax
c0107f9f:	ba 00 00 00 00       	mov    $0x0,%edx
c0107fa4:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0107fa7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0107faa:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0107fad:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0107fb0:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0107fb3:	ba 00 00 00 00       	mov    $0x0,%edx
c0107fb8:	89 c3                	mov    %eax,%ebx
c0107fba:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
c0107fc0:	89 de                	mov    %ebx,%esi
c0107fc2:	89 d0                	mov    %edx,%eax
c0107fc4:	83 e0 00             	and    $0x0,%eax
c0107fc7:	89 c7                	mov    %eax,%edi
c0107fc9:	89 75 c8             	mov    %esi,-0x38(%ebp)
c0107fcc:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
c0107fcf:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107fd2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107fd5:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0107fd8:	77 3b                	ja     c0108015 <page_init+0x3a1>
c0107fda:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0107fdd:	72 05                	jb     c0107fe4 <page_init+0x370>
c0107fdf:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0107fe2:	73 31                	jae    c0108015 <page_init+0x3a1>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0107fe4:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0107fe7:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0107fea:	2b 45 d0             	sub    -0x30(%ebp),%eax
c0107fed:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c0107ff0:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0107ff4:	c1 ea 0c             	shr    $0xc,%edx
c0107ff7:	89 c3                	mov    %eax,%ebx
c0107ff9:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107ffc:	83 ec 0c             	sub    $0xc,%esp
c0107fff:	50                   	push   %eax
c0108000:	e8 b0 f8 ff ff       	call   c01078b5 <pa2page>
c0108005:	83 c4 10             	add    $0x10,%esp
c0108008:	83 ec 08             	sub    $0x8,%esp
c010800b:	53                   	push   %ebx
c010800c:	50                   	push   %eax
c010800d:	e8 74 fb ff ff       	call   c0107b86 <init_memmap>
c0108012:	83 c4 10             	add    $0x10,%esp
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
c0108015:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0108019:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010801c:	8b 00                	mov    (%eax),%eax
c010801e:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0108021:	0f 8f 89 fe ff ff    	jg     c0107eb0 <page_init+0x23c>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
c0108027:	90                   	nop
c0108028:	8d 65 f4             	lea    -0xc(%ebp),%esp
c010802b:	5b                   	pop    %ebx
c010802c:	5e                   	pop    %esi
c010802d:	5f                   	pop    %edi
c010802e:	5d                   	pop    %ebp
c010802f:	c3                   	ret    

c0108030 <enable_paging>:

static void
enable_paging(void) {
c0108030:	55                   	push   %ebp
c0108031:	89 e5                	mov    %esp,%ebp
c0108033:	83 ec 10             	sub    $0x10,%esp
    lcr3(boot_cr3);
c0108036:	a1 dc ab 12 c0       	mov    0xc012abdc,%eax
c010803b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    asm volatile ("mov %0, %%cr0" :: "r" (cr0) : "memory");
}

static inline void
lcr3(uintptr_t cr3) {
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c010803e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108041:	0f 22 d8             	mov    %eax,%cr3
}

static inline uintptr_t
rcr0(void) {
    uintptr_t cr0;
    asm volatile ("mov %%cr0, %0" : "=r" (cr0) :: "memory");
c0108044:	0f 20 c0             	mov    %cr0,%eax
c0108047:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr0;
c010804a:	8b 45 f4             	mov    -0xc(%ebp),%eax

    // turn on paging
    uint32_t cr0 = rcr0();
c010804d:	89 45 f8             	mov    %eax,-0x8(%ebp)
    cr0 |= CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP;
c0108050:	81 4d f8 2f 00 05 80 	orl    $0x8005002f,-0x8(%ebp)
    cr0 &= ~(CR0_TS | CR0_EM);
c0108057:	83 65 f8 f3          	andl   $0xfffffff3,-0x8(%ebp)
c010805b:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010805e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile ("pushl %0; popfl" :: "r" (eflags));
}

static inline void
lcr0(uintptr_t cr0) {
    asm volatile ("mov %0, %%cr0" :: "r" (cr0) : "memory");
c0108061:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108064:	0f 22 c0             	mov    %eax,%cr0
    lcr0(cr0);
}
c0108067:	90                   	nop
c0108068:	c9                   	leave  
c0108069:	c3                   	ret    

c010806a <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c010806a:	55                   	push   %ebp
c010806b:	89 e5                	mov    %esp,%ebp
c010806d:	83 ec 28             	sub    $0x28,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0108070:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108073:	33 45 14             	xor    0x14(%ebp),%eax
c0108076:	25 ff 0f 00 00       	and    $0xfff,%eax
c010807b:	85 c0                	test   %eax,%eax
c010807d:	74 19                	je     c0108098 <boot_map_segment+0x2e>
c010807f:	68 06 c5 10 c0       	push   $0xc010c506
c0108084:	68 1d c5 10 c0       	push   $0xc010c51d
c0108089:	68 12 01 00 00       	push   $0x112
c010808e:	68 f8 c4 10 c0       	push   $0xc010c4f8
c0108093:	e8 c4 96 ff ff       	call   c010175c <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c0108098:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c010809f:	8b 45 0c             	mov    0xc(%ebp),%eax
c01080a2:	25 ff 0f 00 00       	and    $0xfff,%eax
c01080a7:	89 c2                	mov    %eax,%edx
c01080a9:	8b 45 10             	mov    0x10(%ebp),%eax
c01080ac:	01 c2                	add    %eax,%edx
c01080ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01080b1:	01 d0                	add    %edx,%eax
c01080b3:	83 e8 01             	sub    $0x1,%eax
c01080b6:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01080b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01080bc:	ba 00 00 00 00       	mov    $0x0,%edx
c01080c1:	f7 75 f0             	divl   -0x10(%ebp)
c01080c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01080c7:	29 d0                	sub    %edx,%eax
c01080c9:	c1 e8 0c             	shr    $0xc,%eax
c01080cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c01080cf:	8b 45 0c             	mov    0xc(%ebp),%eax
c01080d2:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01080d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01080d8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01080dd:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c01080e0:	8b 45 14             	mov    0x14(%ebp),%eax
c01080e3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01080e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01080e9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01080ee:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c01080f1:	eb 57                	jmp    c010814a <boot_map_segment+0xe0>
        pte_t *ptep = get_pte(pgdir, la, 1);
c01080f3:	83 ec 04             	sub    $0x4,%esp
c01080f6:	6a 01                	push   $0x1
c01080f8:	ff 75 0c             	pushl  0xc(%ebp)
c01080fb:	ff 75 08             	pushl  0x8(%ebp)
c01080fe:	e8 9d 01 00 00       	call   c01082a0 <get_pte>
c0108103:	83 c4 10             	add    $0x10,%esp
c0108106:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c0108109:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c010810d:	75 19                	jne    c0108128 <boot_map_segment+0xbe>
c010810f:	68 32 c5 10 c0       	push   $0xc010c532
c0108114:	68 1d c5 10 c0       	push   $0xc010c51d
c0108119:	68 18 01 00 00       	push   $0x118
c010811e:	68 f8 c4 10 c0       	push   $0xc010c4f8
c0108123:	e8 34 96 ff ff       	call   c010175c <__panic>
        *ptep = pa | PTE_P | perm;
c0108128:	8b 45 14             	mov    0x14(%ebp),%eax
c010812b:	0b 45 18             	or     0x18(%ebp),%eax
c010812e:	83 c8 01             	or     $0x1,%eax
c0108131:	89 c2                	mov    %eax,%edx
c0108133:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108136:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0108138:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c010813c:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c0108143:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c010814a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010814e:	75 a3                	jne    c01080f3 <boot_map_segment+0x89>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
c0108150:	90                   	nop
c0108151:	c9                   	leave  
c0108152:	c3                   	ret    

c0108153 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c0108153:	55                   	push   %ebp
c0108154:	89 e5                	mov    %esp,%ebp
c0108156:	83 ec 18             	sub    $0x18,%esp
    struct Page *p = alloc_page();
c0108159:	83 ec 0c             	sub    $0xc,%esp
c010815c:	6a 01                	push   $0x1
c010815e:	e8 42 fa ff ff       	call   c0107ba5 <alloc_pages>
c0108163:	83 c4 10             	add    $0x10,%esp
c0108166:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c0108169:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010816d:	75 17                	jne    c0108186 <boot_alloc_page+0x33>
        panic("boot_alloc_page failed.\n");
c010816f:	83 ec 04             	sub    $0x4,%esp
c0108172:	68 3f c5 10 c0       	push   $0xc010c53f
c0108177:	68 24 01 00 00       	push   $0x124
c010817c:	68 f8 c4 10 c0       	push   $0xc010c4f8
c0108181:	e8 d6 95 ff ff       	call   c010175c <__panic>
    }
    return page2kva(p);
c0108186:	83 ec 0c             	sub    $0xc,%esp
c0108189:	ff 75 f4             	pushl  -0xc(%ebp)
c010818c:	e8 6b f7 ff ff       	call   c01078fc <page2kva>
c0108191:	83 c4 10             	add    $0x10,%esp
}
c0108194:	c9                   	leave  
c0108195:	c3                   	ret    

c0108196 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c0108196:	55                   	push   %ebp
c0108197:	89 e5                	mov    %esp,%ebp
c0108199:	83 ec 18             	sub    $0x18,%esp
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c010819c:	e8 b0 f9 ff ff       	call   c0107b51 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c01081a1:	e8 ce fa ff ff       	call   c0107c74 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c01081a6:	e8 b7 04 00 00       	call   c0108662 <check_alloc_page>

    // create boot_pgdir, an initial page directory(Page Directory Table, PDT)
    boot_pgdir = boot_alloc_page();
c01081ab:	e8 a3 ff ff ff       	call   c0108153 <boot_alloc_page>
c01081b0:	a3 24 8a 12 c0       	mov    %eax,0xc0128a24
    memset(boot_pgdir, 0, PGSIZE);
c01081b5:	a1 24 8a 12 c0       	mov    0xc0128a24,%eax
c01081ba:	83 ec 04             	sub    $0x4,%esp
c01081bd:	68 00 10 00 00       	push   $0x1000
c01081c2:	6a 00                	push   $0x0
c01081c4:	50                   	push   %eax
c01081c5:	e8 8e 1f 00 00       	call   c010a158 <memset>
c01081ca:	83 c4 10             	add    $0x10,%esp
    boot_cr3 = PADDR(boot_pgdir);
c01081cd:	a1 24 8a 12 c0       	mov    0xc0128a24,%eax
c01081d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01081d5:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01081dc:	77 17                	ja     c01081f5 <pmm_init+0x5f>
c01081de:	ff 75 f4             	pushl  -0xc(%ebp)
c01081e1:	68 d4 c4 10 c0       	push   $0xc010c4d4
c01081e6:	68 3e 01 00 00       	push   $0x13e
c01081eb:	68 f8 c4 10 c0       	push   $0xc010c4f8
c01081f0:	e8 67 95 ff ff       	call   c010175c <__panic>
c01081f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01081f8:	05 00 00 00 40       	add    $0x40000000,%eax
c01081fd:	a3 dc ab 12 c0       	mov    %eax,0xc012abdc

    check_pgdir();
c0108202:	e8 7e 04 00 00       	call   c0108685 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c0108207:	a1 24 8a 12 c0       	mov    0xc0128a24,%eax
c010820c:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c0108212:	a1 24 8a 12 c0       	mov    0xc0128a24,%eax
c0108217:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010821a:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0108221:	77 17                	ja     c010823a <pmm_init+0xa4>
c0108223:	ff 75 f0             	pushl  -0x10(%ebp)
c0108226:	68 d4 c4 10 c0       	push   $0xc010c4d4
c010822b:	68 46 01 00 00       	push   $0x146
c0108230:	68 f8 c4 10 c0       	push   $0xc010c4f8
c0108235:	e8 22 95 ff ff       	call   c010175c <__panic>
c010823a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010823d:	05 00 00 00 40       	add    $0x40000000,%eax
c0108242:	83 c8 03             	or     $0x3,%eax
c0108245:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    //linear_addr KERNBASE~KERNBASE+KMEMSIZE = phy_addr 0~KMEMSIZE
    //But shouldn't use this map until enable_paging() & gdt_init() finished.
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0108247:	a1 24 8a 12 c0       	mov    0xc0128a24,%eax
c010824c:	83 ec 0c             	sub    $0xc,%esp
c010824f:	6a 02                	push   $0x2
c0108251:	6a 00                	push   $0x0
c0108253:	68 00 00 00 38       	push   $0x38000000
c0108258:	68 00 00 00 c0       	push   $0xc0000000
c010825d:	50                   	push   %eax
c010825e:	e8 07 fe ff ff       	call   c010806a <boot_map_segment>
c0108263:	83 c4 20             	add    $0x20,%esp

    //temporary map: 
    //virtual_addr 3G~3G+4M = linear_addr 0~4M = linear_addr 3G~3G+4M = phy_addr 0~4M     
    boot_pgdir[0] = boot_pgdir[PDX(KERNBASE)];
c0108266:	a1 24 8a 12 c0       	mov    0xc0128a24,%eax
c010826b:	8b 15 24 8a 12 c0    	mov    0xc0128a24,%edx
c0108271:	8b 92 00 0c 00 00    	mov    0xc00(%edx),%edx
c0108277:	89 10                	mov    %edx,(%eax)

    enable_paging();
c0108279:	e8 b2 fd ff ff       	call   c0108030 <enable_paging>

    //reload gdt(third time,the last time) to map all physical memory
    //virtual_addr 0~4G=liear_addr 0~4G
    //then set kernel stack(ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c010827e:	e8 dc f7 ff ff       	call   c0107a5f <gdt_init>

    //disable the map of virtual_addr 0~4M
    boot_pgdir[0] = 0;
c0108283:	a1 24 8a 12 c0       	mov    0xc0128a24,%eax
c0108288:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c010828e:	e8 58 09 00 00       	call   c0108beb <check_boot_pgdir>

    print_pgdir();
c0108293:	e8 4e 0d 00 00       	call   c0108fe6 <print_pgdir>
    
    kmalloc_init();
c0108298:	e8 0b de ff ff       	call   c01060a8 <kmalloc_init>

}
c010829d:	90                   	nop
c010829e:	c9                   	leave  
c010829f:	c3                   	ret    

c01082a0 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c01082a0:	55                   	push   %ebp
c01082a1:	89 e5                	mov    %esp,%ebp
c01082a3:	83 ec 28             	sub    $0x28,%esp
    pde_t *pdep = &pgdir[PDX(la)];  //尝试获得页表
c01082a6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01082a9:	c1 e8 16             	shr    $0x16,%eax
c01082ac:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01082b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01082b6:	01 d0                	add    %edx,%eax
c01082b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) { //如果获取不成功
c01082bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01082be:	8b 00                	mov    (%eax),%eax
c01082c0:	83 e0 01             	and    $0x1,%eax
c01082c3:	85 c0                	test   %eax,%eax
c01082c5:	0f 85 9f 00 00 00    	jne    c010836a <get_pte+0xca>
        struct Page *page;
        //假如不需要分配或是分配失败
        if (!create || (page = alloc_page()) == NULL) {
c01082cb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01082cf:	74 16                	je     c01082e7 <get_pte+0x47>
c01082d1:	83 ec 0c             	sub    $0xc,%esp
c01082d4:	6a 01                	push   $0x1
c01082d6:	e8 ca f8 ff ff       	call   c0107ba5 <alloc_pages>
c01082db:	83 c4 10             	add    $0x10,%esp
c01082de:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01082e1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01082e5:	75 0a                	jne    c01082f1 <get_pte+0x51>
            return NULL;
c01082e7:	b8 00 00 00 00       	mov    $0x0,%eax
c01082ec:	e9 ca 00 00 00       	jmp    c01083bb <get_pte+0x11b>
        }
        set_page_ref(page, 1); //引用次数加一
c01082f1:	83 ec 08             	sub    $0x8,%esp
c01082f4:	6a 01                	push   $0x1
c01082f6:	ff 75 f0             	pushl  -0x10(%ebp)
c01082f9:	e8 a3 f6 ff ff       	call   c01079a1 <set_page_ref>
c01082fe:	83 c4 10             	add    $0x10,%esp
        uintptr_t pa = page2pa(page);  //得到该页物理地址
c0108301:	83 ec 0c             	sub    $0xc,%esp
c0108304:	ff 75 f0             	pushl  -0x10(%ebp)
c0108307:	e8 96 f5 ff ff       	call   c01078a2 <page2pa>
c010830c:	83 c4 10             	add    $0x10,%esp
c010830f:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE); //物理地址转虚拟地址，并初始化
c0108312:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108315:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108318:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010831b:	c1 e8 0c             	shr    $0xc,%eax
c010831e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0108321:	a1 20 8a 12 c0       	mov    0xc0128a20,%eax
c0108326:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0108329:	72 17                	jb     c0108342 <get_pte+0xa2>
c010832b:	ff 75 e8             	pushl  -0x18(%ebp)
c010832e:	68 30 c4 10 c0       	push   $0xc010c430
c0108333:	68 77 01 00 00       	push   $0x177
c0108338:	68 f8 c4 10 c0       	push   $0xc010c4f8
c010833d:	e8 1a 94 ff ff       	call   c010175c <__panic>
c0108342:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108345:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010834a:	83 ec 04             	sub    $0x4,%esp
c010834d:	68 00 10 00 00       	push   $0x1000
c0108352:	6a 00                	push   $0x0
c0108354:	50                   	push   %eax
c0108355:	e8 fe 1d 00 00       	call   c010a158 <memset>
c010835a:	83 c4 10             	add    $0x10,%esp
        *pdep = pa | PTE_U | PTE_W | PTE_P; //设置控制位
c010835d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108360:	83 c8 07             	or     $0x7,%eax
c0108363:	89 c2                	mov    %eax,%edx
c0108365:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108368:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c010836a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010836d:	8b 00                	mov    (%eax),%eax
c010836f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0108374:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108377:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010837a:	c1 e8 0c             	shr    $0xc,%eax
c010837d:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0108380:	a1 20 8a 12 c0       	mov    0xc0128a20,%eax
c0108385:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0108388:	72 17                	jb     c01083a1 <get_pte+0x101>
c010838a:	ff 75 e0             	pushl  -0x20(%ebp)
c010838d:	68 30 c4 10 c0       	push   $0xc010c430
c0108392:	68 7a 01 00 00       	push   $0x17a
c0108397:	68 f8 c4 10 c0       	push   $0xc010c4f8
c010839c:	e8 bb 93 ff ff       	call   c010175c <__panic>
c01083a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01083a4:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01083a9:	89 c2                	mov    %eax,%edx
c01083ab:	8b 45 0c             	mov    0xc(%ebp),%eax
c01083ae:	c1 e8 0c             	shr    $0xc,%eax
c01083b1:	25 ff 03 00 00       	and    $0x3ff,%eax
c01083b6:	c1 e0 02             	shl    $0x2,%eax
c01083b9:	01 d0                	add    %edx,%eax
    //KADDR(PDE_ADDR(*pdep)):这部分是由页目录项地址得到关联的页表物理地址， 再转成虚拟地址
    //PTX(la)：返回虚拟地址la的页表项索引
    //最后返回的是虚拟地址la对应的页表项入口地址
}
c01083bb:	c9                   	leave  
c01083bc:	c3                   	ret    

c01083bd <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c01083bd:	55                   	push   %ebp
c01083be:	89 e5                	mov    %esp,%ebp
c01083c0:	83 ec 18             	sub    $0x18,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01083c3:	83 ec 04             	sub    $0x4,%esp
c01083c6:	6a 00                	push   $0x0
c01083c8:	ff 75 0c             	pushl  0xc(%ebp)
c01083cb:	ff 75 08             	pushl  0x8(%ebp)
c01083ce:	e8 cd fe ff ff       	call   c01082a0 <get_pte>
c01083d3:	83 c4 10             	add    $0x10,%esp
c01083d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c01083d9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01083dd:	74 08                	je     c01083e7 <get_page+0x2a>
        *ptep_store = ptep;
c01083df:	8b 45 10             	mov    0x10(%ebp),%eax
c01083e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01083e5:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c01083e7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01083eb:	74 1f                	je     c010840c <get_page+0x4f>
c01083ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01083f0:	8b 00                	mov    (%eax),%eax
c01083f2:	83 e0 01             	and    $0x1,%eax
c01083f5:	85 c0                	test   %eax,%eax
c01083f7:	74 13                	je     c010840c <get_page+0x4f>
        return pte2page(*ptep);
c01083f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01083fc:	8b 00                	mov    (%eax),%eax
c01083fe:	83 ec 0c             	sub    $0xc,%esp
c0108401:	50                   	push   %eax
c0108402:	e8 3a f5 ff ff       	call   c0107941 <pte2page>
c0108407:	83 c4 10             	add    $0x10,%esp
c010840a:	eb 05                	jmp    c0108411 <get_page+0x54>
    }
    return NULL;
c010840c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108411:	c9                   	leave  
c0108412:	c3                   	ret    

c0108413 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0108413:	55                   	push   %ebp
c0108414:	89 e5                	mov    %esp,%ebp
c0108416:	83 ec 18             	sub    $0x18,%esp
    if (*ptep & PTE_P){ // 二级页表项存在
c0108419:	8b 45 10             	mov    0x10(%ebp),%eax
c010841c:	8b 00                	mov    (%eax),%eax
c010841e:	83 e0 01             	and    $0x1,%eax
c0108421:	85 c0                	test   %eax,%eax
c0108423:	74 50                	je     c0108475 <page_remove_pte+0x62>
        struct Page *page = pte2page(*ptep); //找到页表项
c0108425:	8b 45 10             	mov    0x10(%ebp),%eax
c0108428:	8b 00                	mov    (%eax),%eax
c010842a:	83 ec 0c             	sub    $0xc,%esp
c010842d:	50                   	push   %eax
c010842e:	e8 0e f5 ff ff       	call   c0107941 <pte2page>
c0108433:	83 c4 10             	add    $0x10,%esp
c0108436:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0){ // 此页的被引用数为0，即无其他进程对此页进行引用
c0108439:	83 ec 0c             	sub    $0xc,%esp
c010843c:	ff 75 f4             	pushl  -0xc(%ebp)
c010843f:	e8 82 f5 ff ff       	call   c01079c6 <page_ref_dec>
c0108444:	83 c4 10             	add    $0x10,%esp
c0108447:	85 c0                	test   %eax,%eax
c0108449:	75 10                	jne    c010845b <page_remove_pte+0x48>
            free_page(page);
c010844b:	83 ec 08             	sub    $0x8,%esp
c010844e:	6a 01                	push   $0x1
c0108450:	ff 75 f4             	pushl  -0xc(%ebp)
c0108453:	e8 b9 f7 ff ff       	call   c0107c11 <free_pages>
c0108458:	83 c4 10             	add    $0x10,%esp
        }
        *ptep = 0; // 该页目录项清零
c010845b:	8b 45 10             	mov    0x10(%ebp),%eax
c010845e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir,la); //当修改的页表是进程正在使用的那些页表，使之无效。
c0108464:	83 ec 08             	sub    $0x8,%esp
c0108467:	ff 75 0c             	pushl  0xc(%ebp)
c010846a:	ff 75 08             	pushl  0x8(%ebp)
c010846d:	e8 f8 00 00 00       	call   c010856a <tlb_invalidate>
c0108472:	83 c4 10             	add    $0x10,%esp
    }
}
c0108475:	90                   	nop
c0108476:	c9                   	leave  
c0108477:	c3                   	ret    

c0108478 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c0108478:	55                   	push   %ebp
c0108479:	89 e5                	mov    %esp,%ebp
c010847b:	83 ec 18             	sub    $0x18,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c010847e:	83 ec 04             	sub    $0x4,%esp
c0108481:	6a 00                	push   $0x0
c0108483:	ff 75 0c             	pushl  0xc(%ebp)
c0108486:	ff 75 08             	pushl  0x8(%ebp)
c0108489:	e8 12 fe ff ff       	call   c01082a0 <get_pte>
c010848e:	83 c4 10             	add    $0x10,%esp
c0108491:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c0108494:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108498:	74 14                	je     c01084ae <page_remove+0x36>
        page_remove_pte(pgdir, la, ptep);
c010849a:	83 ec 04             	sub    $0x4,%esp
c010849d:	ff 75 f4             	pushl  -0xc(%ebp)
c01084a0:	ff 75 0c             	pushl  0xc(%ebp)
c01084a3:	ff 75 08             	pushl  0x8(%ebp)
c01084a6:	e8 68 ff ff ff       	call   c0108413 <page_remove_pte>
c01084ab:	83 c4 10             	add    $0x10,%esp
    }
}
c01084ae:	90                   	nop
c01084af:	c9                   	leave  
c01084b0:	c3                   	ret    

c01084b1 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c01084b1:	55                   	push   %ebp
c01084b2:	89 e5                	mov    %esp,%ebp
c01084b4:	83 ec 18             	sub    $0x18,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c01084b7:	83 ec 04             	sub    $0x4,%esp
c01084ba:	6a 01                	push   $0x1
c01084bc:	ff 75 10             	pushl  0x10(%ebp)
c01084bf:	ff 75 08             	pushl  0x8(%ebp)
c01084c2:	e8 d9 fd ff ff       	call   c01082a0 <get_pte>
c01084c7:	83 c4 10             	add    $0x10,%esp
c01084ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c01084cd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01084d1:	75 0a                	jne    c01084dd <page_insert+0x2c>
        return -E_NO_MEM;
c01084d3:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c01084d8:	e9 8b 00 00 00       	jmp    c0108568 <page_insert+0xb7>
    }
    page_ref_inc(page);
c01084dd:	83 ec 0c             	sub    $0xc,%esp
c01084e0:	ff 75 0c             	pushl  0xc(%ebp)
c01084e3:	e8 c7 f4 ff ff       	call   c01079af <page_ref_inc>
c01084e8:	83 c4 10             	add    $0x10,%esp
    if (*ptep & PTE_P) {
c01084eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01084ee:	8b 00                	mov    (%eax),%eax
c01084f0:	83 e0 01             	and    $0x1,%eax
c01084f3:	85 c0                	test   %eax,%eax
c01084f5:	74 40                	je     c0108537 <page_insert+0x86>
        struct Page *p = pte2page(*ptep);
c01084f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01084fa:	8b 00                	mov    (%eax),%eax
c01084fc:	83 ec 0c             	sub    $0xc,%esp
c01084ff:	50                   	push   %eax
c0108500:	e8 3c f4 ff ff       	call   c0107941 <pte2page>
c0108505:	83 c4 10             	add    $0x10,%esp
c0108508:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c010850b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010850e:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108511:	75 10                	jne    c0108523 <page_insert+0x72>
            page_ref_dec(page);
c0108513:	83 ec 0c             	sub    $0xc,%esp
c0108516:	ff 75 0c             	pushl  0xc(%ebp)
c0108519:	e8 a8 f4 ff ff       	call   c01079c6 <page_ref_dec>
c010851e:	83 c4 10             	add    $0x10,%esp
c0108521:	eb 14                	jmp    c0108537 <page_insert+0x86>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c0108523:	83 ec 04             	sub    $0x4,%esp
c0108526:	ff 75 f4             	pushl  -0xc(%ebp)
c0108529:	ff 75 10             	pushl  0x10(%ebp)
c010852c:	ff 75 08             	pushl  0x8(%ebp)
c010852f:	e8 df fe ff ff       	call   c0108413 <page_remove_pte>
c0108534:	83 c4 10             	add    $0x10,%esp
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0108537:	83 ec 0c             	sub    $0xc,%esp
c010853a:	ff 75 0c             	pushl  0xc(%ebp)
c010853d:	e8 60 f3 ff ff       	call   c01078a2 <page2pa>
c0108542:	83 c4 10             	add    $0x10,%esp
c0108545:	0b 45 14             	or     0x14(%ebp),%eax
c0108548:	83 c8 01             	or     $0x1,%eax
c010854b:	89 c2                	mov    %eax,%edx
c010854d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108550:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c0108552:	83 ec 08             	sub    $0x8,%esp
c0108555:	ff 75 10             	pushl  0x10(%ebp)
c0108558:	ff 75 08             	pushl  0x8(%ebp)
c010855b:	e8 0a 00 00 00       	call   c010856a <tlb_invalidate>
c0108560:	83 c4 10             	add    $0x10,%esp
    return 0;
c0108563:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108568:	c9                   	leave  
c0108569:	c3                   	ret    

c010856a <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c010856a:	55                   	push   %ebp
c010856b:	89 e5                	mov    %esp,%ebp
c010856d:	83 ec 18             	sub    $0x18,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c0108570:	0f 20 d8             	mov    %cr3,%eax
c0108573:	89 45 ec             	mov    %eax,-0x14(%ebp)
    return cr3;
c0108576:	8b 55 ec             	mov    -0x14(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
c0108579:	8b 45 08             	mov    0x8(%ebp),%eax
c010857c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010857f:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0108586:	77 17                	ja     c010859f <tlb_invalidate+0x35>
c0108588:	ff 75 f0             	pushl  -0x10(%ebp)
c010858b:	68 d4 c4 10 c0       	push   $0xc010c4d4
c0108590:	68 c6 01 00 00       	push   $0x1c6
c0108595:	68 f8 c4 10 c0       	push   $0xc010c4f8
c010859a:	e8 bd 91 ff ff       	call   c010175c <__panic>
c010859f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01085a2:	05 00 00 00 40       	add    $0x40000000,%eax
c01085a7:	39 c2                	cmp    %eax,%edx
c01085a9:	75 0c                	jne    c01085b7 <tlb_invalidate+0x4d>
        invlpg((void *)la);
c01085ab:	8b 45 0c             	mov    0xc(%ebp),%eax
c01085ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c01085b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01085b4:	0f 01 38             	invlpg (%eax)
    }
}
c01085b7:	90                   	nop
c01085b8:	c9                   	leave  
c01085b9:	c3                   	ret    

c01085ba <pgdir_alloc_page>:

// pgdir_alloc_page - call alloc_page & page_insert functions to 
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
struct Page *
pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
c01085ba:	55                   	push   %ebp
c01085bb:	89 e5                	mov    %esp,%ebp
c01085bd:	83 ec 18             	sub    $0x18,%esp
    struct Page *page = alloc_page();
c01085c0:	83 ec 0c             	sub    $0xc,%esp
c01085c3:	6a 01                	push   $0x1
c01085c5:	e8 db f5 ff ff       	call   c0107ba5 <alloc_pages>
c01085ca:	83 c4 10             	add    $0x10,%esp
c01085cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c01085d0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01085d4:	0f 84 83 00 00 00    	je     c010865d <pgdir_alloc_page+0xa3>
        if (page_insert(pgdir, page, la, perm) != 0) {
c01085da:	ff 75 10             	pushl  0x10(%ebp)
c01085dd:	ff 75 0c             	pushl  0xc(%ebp)
c01085e0:	ff 75 f4             	pushl  -0xc(%ebp)
c01085e3:	ff 75 08             	pushl  0x8(%ebp)
c01085e6:	e8 c6 fe ff ff       	call   c01084b1 <page_insert>
c01085eb:	83 c4 10             	add    $0x10,%esp
c01085ee:	85 c0                	test   %eax,%eax
c01085f0:	74 17                	je     c0108609 <pgdir_alloc_page+0x4f>
            free_page(page);
c01085f2:	83 ec 08             	sub    $0x8,%esp
c01085f5:	6a 01                	push   $0x1
c01085f7:	ff 75 f4             	pushl  -0xc(%ebp)
c01085fa:	e8 12 f6 ff ff       	call   c0107c11 <free_pages>
c01085ff:	83 c4 10             	add    $0x10,%esp
            return NULL;
c0108602:	b8 00 00 00 00       	mov    $0x0,%eax
c0108607:	eb 57                	jmp    c0108660 <pgdir_alloc_page+0xa6>
        }
        if (swap_init_ok){
c0108609:	a1 08 8a 12 c0       	mov    0xc0128a08,%eax
c010860e:	85 c0                	test   %eax,%eax
c0108610:	74 4b                	je     c010865d <pgdir_alloc_page+0xa3>
            swap_map_swappable(check_mm_struct, la, page, 0);
c0108612:	a1 f8 aa 12 c0       	mov    0xc012aaf8,%eax
c0108617:	6a 00                	push   $0x0
c0108619:	ff 75 f4             	pushl  -0xc(%ebp)
c010861c:	ff 75 0c             	pushl  0xc(%ebp)
c010861f:	50                   	push   %eax
c0108620:	e8 42 cc ff ff       	call   c0105267 <swap_map_swappable>
c0108625:	83 c4 10             	add    $0x10,%esp
            page->pra_vaddr=la;
c0108628:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010862b:	8b 55 0c             	mov    0xc(%ebp),%edx
c010862e:	89 50 20             	mov    %edx,0x20(%eax)
            assert(page_ref(page) == 1);
c0108631:	83 ec 0c             	sub    $0xc,%esp
c0108634:	ff 75 f4             	pushl  -0xc(%ebp)
c0108637:	e8 5b f3 ff ff       	call   c0107997 <page_ref>
c010863c:	83 c4 10             	add    $0x10,%esp
c010863f:	83 f8 01             	cmp    $0x1,%eax
c0108642:	74 19                	je     c010865d <pgdir_alloc_page+0xa3>
c0108644:	68 58 c5 10 c0       	push   $0xc010c558
c0108649:	68 1d c5 10 c0       	push   $0xc010c51d
c010864e:	68 d9 01 00 00       	push   $0x1d9
c0108653:	68 f8 c4 10 c0       	push   $0xc010c4f8
c0108658:	e8 ff 90 ff ff       	call   c010175c <__panic>
            //cprintf("get No. %d  page: pra_vaddr %x, pra_link.prev %x, pra_link_next %x in pgdir_alloc_page\n", (page-pages), page->pra_vaddr,page->pra_page_link.prev, page->pra_page_link.next);
        }

    }

    return page;
c010865d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0108660:	c9                   	leave  
c0108661:	c3                   	ret    

c0108662 <check_alloc_page>:

static void
check_alloc_page(void) {
c0108662:	55                   	push   %ebp
c0108663:	89 e5                	mov    %esp,%ebp
c0108665:	83 ec 08             	sub    $0x8,%esp
    pmm_manager->check();
c0108668:	a1 d8 ab 12 c0       	mov    0xc012abd8,%eax
c010866d:	8b 40 18             	mov    0x18(%eax),%eax
c0108670:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c0108672:	83 ec 0c             	sub    $0xc,%esp
c0108675:	68 6c c5 10 c0       	push   $0xc010c56c
c010867a:	e8 ff 7b ff ff       	call   c010027e <cprintf>
c010867f:	83 c4 10             	add    $0x10,%esp
}
c0108682:	90                   	nop
c0108683:	c9                   	leave  
c0108684:	c3                   	ret    

c0108685 <check_pgdir>:

static void
check_pgdir(void) {
c0108685:	55                   	push   %ebp
c0108686:	89 e5                	mov    %esp,%ebp
c0108688:	83 ec 28             	sub    $0x28,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c010868b:	a1 20 8a 12 c0       	mov    0xc0128a20,%eax
c0108690:	3d 00 80 03 00       	cmp    $0x38000,%eax
c0108695:	76 19                	jbe    c01086b0 <check_pgdir+0x2b>
c0108697:	68 8b c5 10 c0       	push   $0xc010c58b
c010869c:	68 1d c5 10 c0       	push   $0xc010c51d
c01086a1:	68 ea 01 00 00       	push   $0x1ea
c01086a6:	68 f8 c4 10 c0       	push   $0xc010c4f8
c01086ab:	e8 ac 90 ff ff       	call   c010175c <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c01086b0:	a1 24 8a 12 c0       	mov    0xc0128a24,%eax
c01086b5:	85 c0                	test   %eax,%eax
c01086b7:	74 0e                	je     c01086c7 <check_pgdir+0x42>
c01086b9:	a1 24 8a 12 c0       	mov    0xc0128a24,%eax
c01086be:	25 ff 0f 00 00       	and    $0xfff,%eax
c01086c3:	85 c0                	test   %eax,%eax
c01086c5:	74 19                	je     c01086e0 <check_pgdir+0x5b>
c01086c7:	68 a8 c5 10 c0       	push   $0xc010c5a8
c01086cc:	68 1d c5 10 c0       	push   $0xc010c51d
c01086d1:	68 eb 01 00 00       	push   $0x1eb
c01086d6:	68 f8 c4 10 c0       	push   $0xc010c4f8
c01086db:	e8 7c 90 ff ff       	call   c010175c <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c01086e0:	a1 24 8a 12 c0       	mov    0xc0128a24,%eax
c01086e5:	83 ec 04             	sub    $0x4,%esp
c01086e8:	6a 00                	push   $0x0
c01086ea:	6a 00                	push   $0x0
c01086ec:	50                   	push   %eax
c01086ed:	e8 cb fc ff ff       	call   c01083bd <get_page>
c01086f2:	83 c4 10             	add    $0x10,%esp
c01086f5:	85 c0                	test   %eax,%eax
c01086f7:	74 19                	je     c0108712 <check_pgdir+0x8d>
c01086f9:	68 e0 c5 10 c0       	push   $0xc010c5e0
c01086fe:	68 1d c5 10 c0       	push   $0xc010c51d
c0108703:	68 ec 01 00 00       	push   $0x1ec
c0108708:	68 f8 c4 10 c0       	push   $0xc010c4f8
c010870d:	e8 4a 90 ff ff       	call   c010175c <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c0108712:	83 ec 0c             	sub    $0xc,%esp
c0108715:	6a 01                	push   $0x1
c0108717:	e8 89 f4 ff ff       	call   c0107ba5 <alloc_pages>
c010871c:	83 c4 10             	add    $0x10,%esp
c010871f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c0108722:	a1 24 8a 12 c0       	mov    0xc0128a24,%eax
c0108727:	6a 00                	push   $0x0
c0108729:	6a 00                	push   $0x0
c010872b:	ff 75 f4             	pushl  -0xc(%ebp)
c010872e:	50                   	push   %eax
c010872f:	e8 7d fd ff ff       	call   c01084b1 <page_insert>
c0108734:	83 c4 10             	add    $0x10,%esp
c0108737:	85 c0                	test   %eax,%eax
c0108739:	74 19                	je     c0108754 <check_pgdir+0xcf>
c010873b:	68 08 c6 10 c0       	push   $0xc010c608
c0108740:	68 1d c5 10 c0       	push   $0xc010c51d
c0108745:	68 f0 01 00 00       	push   $0x1f0
c010874a:	68 f8 c4 10 c0       	push   $0xc010c4f8
c010874f:	e8 08 90 ff ff       	call   c010175c <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c0108754:	a1 24 8a 12 c0       	mov    0xc0128a24,%eax
c0108759:	83 ec 04             	sub    $0x4,%esp
c010875c:	6a 00                	push   $0x0
c010875e:	6a 00                	push   $0x0
c0108760:	50                   	push   %eax
c0108761:	e8 3a fb ff ff       	call   c01082a0 <get_pte>
c0108766:	83 c4 10             	add    $0x10,%esp
c0108769:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010876c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0108770:	75 19                	jne    c010878b <check_pgdir+0x106>
c0108772:	68 34 c6 10 c0       	push   $0xc010c634
c0108777:	68 1d c5 10 c0       	push   $0xc010c51d
c010877c:	68 f3 01 00 00       	push   $0x1f3
c0108781:	68 f8 c4 10 c0       	push   $0xc010c4f8
c0108786:	e8 d1 8f ff ff       	call   c010175c <__panic>
    assert(pte2page(*ptep) == p1);
c010878b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010878e:	8b 00                	mov    (%eax),%eax
c0108790:	83 ec 0c             	sub    $0xc,%esp
c0108793:	50                   	push   %eax
c0108794:	e8 a8 f1 ff ff       	call   c0107941 <pte2page>
c0108799:	83 c4 10             	add    $0x10,%esp
c010879c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010879f:	74 19                	je     c01087ba <check_pgdir+0x135>
c01087a1:	68 61 c6 10 c0       	push   $0xc010c661
c01087a6:	68 1d c5 10 c0       	push   $0xc010c51d
c01087ab:	68 f4 01 00 00       	push   $0x1f4
c01087b0:	68 f8 c4 10 c0       	push   $0xc010c4f8
c01087b5:	e8 a2 8f ff ff       	call   c010175c <__panic>
    assert(page_ref(p1) == 1);
c01087ba:	83 ec 0c             	sub    $0xc,%esp
c01087bd:	ff 75 f4             	pushl  -0xc(%ebp)
c01087c0:	e8 d2 f1 ff ff       	call   c0107997 <page_ref>
c01087c5:	83 c4 10             	add    $0x10,%esp
c01087c8:	83 f8 01             	cmp    $0x1,%eax
c01087cb:	74 19                	je     c01087e6 <check_pgdir+0x161>
c01087cd:	68 77 c6 10 c0       	push   $0xc010c677
c01087d2:	68 1d c5 10 c0       	push   $0xc010c51d
c01087d7:	68 f5 01 00 00       	push   $0x1f5
c01087dc:	68 f8 c4 10 c0       	push   $0xc010c4f8
c01087e1:	e8 76 8f ff ff       	call   c010175c <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c01087e6:	a1 24 8a 12 c0       	mov    0xc0128a24,%eax
c01087eb:	8b 00                	mov    (%eax),%eax
c01087ed:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01087f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01087f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01087f8:	c1 e8 0c             	shr    $0xc,%eax
c01087fb:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01087fe:	a1 20 8a 12 c0       	mov    0xc0128a20,%eax
c0108803:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0108806:	72 17                	jb     c010881f <check_pgdir+0x19a>
c0108808:	ff 75 ec             	pushl  -0x14(%ebp)
c010880b:	68 30 c4 10 c0       	push   $0xc010c430
c0108810:	68 f7 01 00 00       	push   $0x1f7
c0108815:	68 f8 c4 10 c0       	push   $0xc010c4f8
c010881a:	e8 3d 8f ff ff       	call   c010175c <__panic>
c010881f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108822:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0108827:	83 c0 04             	add    $0x4,%eax
c010882a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c010882d:	a1 24 8a 12 c0       	mov    0xc0128a24,%eax
c0108832:	83 ec 04             	sub    $0x4,%esp
c0108835:	6a 00                	push   $0x0
c0108837:	68 00 10 00 00       	push   $0x1000
c010883c:	50                   	push   %eax
c010883d:	e8 5e fa ff ff       	call   c01082a0 <get_pte>
c0108842:	83 c4 10             	add    $0x10,%esp
c0108845:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0108848:	74 19                	je     c0108863 <check_pgdir+0x1de>
c010884a:	68 8c c6 10 c0       	push   $0xc010c68c
c010884f:	68 1d c5 10 c0       	push   $0xc010c51d
c0108854:	68 f8 01 00 00       	push   $0x1f8
c0108859:	68 f8 c4 10 c0       	push   $0xc010c4f8
c010885e:	e8 f9 8e ff ff       	call   c010175c <__panic>

    p2 = alloc_page();
c0108863:	83 ec 0c             	sub    $0xc,%esp
c0108866:	6a 01                	push   $0x1
c0108868:	e8 38 f3 ff ff       	call   c0107ba5 <alloc_pages>
c010886d:	83 c4 10             	add    $0x10,%esp
c0108870:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0108873:	a1 24 8a 12 c0       	mov    0xc0128a24,%eax
c0108878:	6a 06                	push   $0x6
c010887a:	68 00 10 00 00       	push   $0x1000
c010887f:	ff 75 e4             	pushl  -0x1c(%ebp)
c0108882:	50                   	push   %eax
c0108883:	e8 29 fc ff ff       	call   c01084b1 <page_insert>
c0108888:	83 c4 10             	add    $0x10,%esp
c010888b:	85 c0                	test   %eax,%eax
c010888d:	74 19                	je     c01088a8 <check_pgdir+0x223>
c010888f:	68 b4 c6 10 c0       	push   $0xc010c6b4
c0108894:	68 1d c5 10 c0       	push   $0xc010c51d
c0108899:	68 fb 01 00 00       	push   $0x1fb
c010889e:	68 f8 c4 10 c0       	push   $0xc010c4f8
c01088a3:	e8 b4 8e ff ff       	call   c010175c <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c01088a8:	a1 24 8a 12 c0       	mov    0xc0128a24,%eax
c01088ad:	83 ec 04             	sub    $0x4,%esp
c01088b0:	6a 00                	push   $0x0
c01088b2:	68 00 10 00 00       	push   $0x1000
c01088b7:	50                   	push   %eax
c01088b8:	e8 e3 f9 ff ff       	call   c01082a0 <get_pte>
c01088bd:	83 c4 10             	add    $0x10,%esp
c01088c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01088c3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01088c7:	75 19                	jne    c01088e2 <check_pgdir+0x25d>
c01088c9:	68 ec c6 10 c0       	push   $0xc010c6ec
c01088ce:	68 1d c5 10 c0       	push   $0xc010c51d
c01088d3:	68 fc 01 00 00       	push   $0x1fc
c01088d8:	68 f8 c4 10 c0       	push   $0xc010c4f8
c01088dd:	e8 7a 8e ff ff       	call   c010175c <__panic>
    assert(*ptep & PTE_U);
c01088e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01088e5:	8b 00                	mov    (%eax),%eax
c01088e7:	83 e0 04             	and    $0x4,%eax
c01088ea:	85 c0                	test   %eax,%eax
c01088ec:	75 19                	jne    c0108907 <check_pgdir+0x282>
c01088ee:	68 1c c7 10 c0       	push   $0xc010c71c
c01088f3:	68 1d c5 10 c0       	push   $0xc010c51d
c01088f8:	68 fd 01 00 00       	push   $0x1fd
c01088fd:	68 f8 c4 10 c0       	push   $0xc010c4f8
c0108902:	e8 55 8e ff ff       	call   c010175c <__panic>
    assert(*ptep & PTE_W);
c0108907:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010890a:	8b 00                	mov    (%eax),%eax
c010890c:	83 e0 02             	and    $0x2,%eax
c010890f:	85 c0                	test   %eax,%eax
c0108911:	75 19                	jne    c010892c <check_pgdir+0x2a7>
c0108913:	68 2a c7 10 c0       	push   $0xc010c72a
c0108918:	68 1d c5 10 c0       	push   $0xc010c51d
c010891d:	68 fe 01 00 00       	push   $0x1fe
c0108922:	68 f8 c4 10 c0       	push   $0xc010c4f8
c0108927:	e8 30 8e ff ff       	call   c010175c <__panic>
    assert(boot_pgdir[0] & PTE_U);
c010892c:	a1 24 8a 12 c0       	mov    0xc0128a24,%eax
c0108931:	8b 00                	mov    (%eax),%eax
c0108933:	83 e0 04             	and    $0x4,%eax
c0108936:	85 c0                	test   %eax,%eax
c0108938:	75 19                	jne    c0108953 <check_pgdir+0x2ce>
c010893a:	68 38 c7 10 c0       	push   $0xc010c738
c010893f:	68 1d c5 10 c0       	push   $0xc010c51d
c0108944:	68 ff 01 00 00       	push   $0x1ff
c0108949:	68 f8 c4 10 c0       	push   $0xc010c4f8
c010894e:	e8 09 8e ff ff       	call   c010175c <__panic>
    assert(page_ref(p2) == 1);
c0108953:	83 ec 0c             	sub    $0xc,%esp
c0108956:	ff 75 e4             	pushl  -0x1c(%ebp)
c0108959:	e8 39 f0 ff ff       	call   c0107997 <page_ref>
c010895e:	83 c4 10             	add    $0x10,%esp
c0108961:	83 f8 01             	cmp    $0x1,%eax
c0108964:	74 19                	je     c010897f <check_pgdir+0x2fa>
c0108966:	68 4e c7 10 c0       	push   $0xc010c74e
c010896b:	68 1d c5 10 c0       	push   $0xc010c51d
c0108970:	68 00 02 00 00       	push   $0x200
c0108975:	68 f8 c4 10 c0       	push   $0xc010c4f8
c010897a:	e8 dd 8d ff ff       	call   c010175c <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c010897f:	a1 24 8a 12 c0       	mov    0xc0128a24,%eax
c0108984:	6a 00                	push   $0x0
c0108986:	68 00 10 00 00       	push   $0x1000
c010898b:	ff 75 f4             	pushl  -0xc(%ebp)
c010898e:	50                   	push   %eax
c010898f:	e8 1d fb ff ff       	call   c01084b1 <page_insert>
c0108994:	83 c4 10             	add    $0x10,%esp
c0108997:	85 c0                	test   %eax,%eax
c0108999:	74 19                	je     c01089b4 <check_pgdir+0x32f>
c010899b:	68 60 c7 10 c0       	push   $0xc010c760
c01089a0:	68 1d c5 10 c0       	push   $0xc010c51d
c01089a5:	68 02 02 00 00       	push   $0x202
c01089aa:	68 f8 c4 10 c0       	push   $0xc010c4f8
c01089af:	e8 a8 8d ff ff       	call   c010175c <__panic>
    assert(page_ref(p1) == 2);
c01089b4:	83 ec 0c             	sub    $0xc,%esp
c01089b7:	ff 75 f4             	pushl  -0xc(%ebp)
c01089ba:	e8 d8 ef ff ff       	call   c0107997 <page_ref>
c01089bf:	83 c4 10             	add    $0x10,%esp
c01089c2:	83 f8 02             	cmp    $0x2,%eax
c01089c5:	74 19                	je     c01089e0 <check_pgdir+0x35b>
c01089c7:	68 8c c7 10 c0       	push   $0xc010c78c
c01089cc:	68 1d c5 10 c0       	push   $0xc010c51d
c01089d1:	68 03 02 00 00       	push   $0x203
c01089d6:	68 f8 c4 10 c0       	push   $0xc010c4f8
c01089db:	e8 7c 8d ff ff       	call   c010175c <__panic>
    assert(page_ref(p2) == 0);
c01089e0:	83 ec 0c             	sub    $0xc,%esp
c01089e3:	ff 75 e4             	pushl  -0x1c(%ebp)
c01089e6:	e8 ac ef ff ff       	call   c0107997 <page_ref>
c01089eb:	83 c4 10             	add    $0x10,%esp
c01089ee:	85 c0                	test   %eax,%eax
c01089f0:	74 19                	je     c0108a0b <check_pgdir+0x386>
c01089f2:	68 9e c7 10 c0       	push   $0xc010c79e
c01089f7:	68 1d c5 10 c0       	push   $0xc010c51d
c01089fc:	68 04 02 00 00       	push   $0x204
c0108a01:	68 f8 c4 10 c0       	push   $0xc010c4f8
c0108a06:	e8 51 8d ff ff       	call   c010175c <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0108a0b:	a1 24 8a 12 c0       	mov    0xc0128a24,%eax
c0108a10:	83 ec 04             	sub    $0x4,%esp
c0108a13:	6a 00                	push   $0x0
c0108a15:	68 00 10 00 00       	push   $0x1000
c0108a1a:	50                   	push   %eax
c0108a1b:	e8 80 f8 ff ff       	call   c01082a0 <get_pte>
c0108a20:	83 c4 10             	add    $0x10,%esp
c0108a23:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108a26:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0108a2a:	75 19                	jne    c0108a45 <check_pgdir+0x3c0>
c0108a2c:	68 ec c6 10 c0       	push   $0xc010c6ec
c0108a31:	68 1d c5 10 c0       	push   $0xc010c51d
c0108a36:	68 05 02 00 00       	push   $0x205
c0108a3b:	68 f8 c4 10 c0       	push   $0xc010c4f8
c0108a40:	e8 17 8d ff ff       	call   c010175c <__panic>
    assert(pte2page(*ptep) == p1);
c0108a45:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108a48:	8b 00                	mov    (%eax),%eax
c0108a4a:	83 ec 0c             	sub    $0xc,%esp
c0108a4d:	50                   	push   %eax
c0108a4e:	e8 ee ee ff ff       	call   c0107941 <pte2page>
c0108a53:	83 c4 10             	add    $0x10,%esp
c0108a56:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0108a59:	74 19                	je     c0108a74 <check_pgdir+0x3ef>
c0108a5b:	68 61 c6 10 c0       	push   $0xc010c661
c0108a60:	68 1d c5 10 c0       	push   $0xc010c51d
c0108a65:	68 06 02 00 00       	push   $0x206
c0108a6a:	68 f8 c4 10 c0       	push   $0xc010c4f8
c0108a6f:	e8 e8 8c ff ff       	call   c010175c <__panic>
    assert((*ptep & PTE_U) == 0);
c0108a74:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108a77:	8b 00                	mov    (%eax),%eax
c0108a79:	83 e0 04             	and    $0x4,%eax
c0108a7c:	85 c0                	test   %eax,%eax
c0108a7e:	74 19                	je     c0108a99 <check_pgdir+0x414>
c0108a80:	68 b0 c7 10 c0       	push   $0xc010c7b0
c0108a85:	68 1d c5 10 c0       	push   $0xc010c51d
c0108a8a:	68 07 02 00 00       	push   $0x207
c0108a8f:	68 f8 c4 10 c0       	push   $0xc010c4f8
c0108a94:	e8 c3 8c ff ff       	call   c010175c <__panic>

    page_remove(boot_pgdir, 0x0);
c0108a99:	a1 24 8a 12 c0       	mov    0xc0128a24,%eax
c0108a9e:	83 ec 08             	sub    $0x8,%esp
c0108aa1:	6a 00                	push   $0x0
c0108aa3:	50                   	push   %eax
c0108aa4:	e8 cf f9 ff ff       	call   c0108478 <page_remove>
c0108aa9:	83 c4 10             	add    $0x10,%esp
    assert(page_ref(p1) == 1);
c0108aac:	83 ec 0c             	sub    $0xc,%esp
c0108aaf:	ff 75 f4             	pushl  -0xc(%ebp)
c0108ab2:	e8 e0 ee ff ff       	call   c0107997 <page_ref>
c0108ab7:	83 c4 10             	add    $0x10,%esp
c0108aba:	83 f8 01             	cmp    $0x1,%eax
c0108abd:	74 19                	je     c0108ad8 <check_pgdir+0x453>
c0108abf:	68 77 c6 10 c0       	push   $0xc010c677
c0108ac4:	68 1d c5 10 c0       	push   $0xc010c51d
c0108ac9:	68 0a 02 00 00       	push   $0x20a
c0108ace:	68 f8 c4 10 c0       	push   $0xc010c4f8
c0108ad3:	e8 84 8c ff ff       	call   c010175c <__panic>
    assert(page_ref(p2) == 0);
c0108ad8:	83 ec 0c             	sub    $0xc,%esp
c0108adb:	ff 75 e4             	pushl  -0x1c(%ebp)
c0108ade:	e8 b4 ee ff ff       	call   c0107997 <page_ref>
c0108ae3:	83 c4 10             	add    $0x10,%esp
c0108ae6:	85 c0                	test   %eax,%eax
c0108ae8:	74 19                	je     c0108b03 <check_pgdir+0x47e>
c0108aea:	68 9e c7 10 c0       	push   $0xc010c79e
c0108aef:	68 1d c5 10 c0       	push   $0xc010c51d
c0108af4:	68 0b 02 00 00       	push   $0x20b
c0108af9:	68 f8 c4 10 c0       	push   $0xc010c4f8
c0108afe:	e8 59 8c ff ff       	call   c010175c <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0108b03:	a1 24 8a 12 c0       	mov    0xc0128a24,%eax
c0108b08:	83 ec 08             	sub    $0x8,%esp
c0108b0b:	68 00 10 00 00       	push   $0x1000
c0108b10:	50                   	push   %eax
c0108b11:	e8 62 f9 ff ff       	call   c0108478 <page_remove>
c0108b16:	83 c4 10             	add    $0x10,%esp
    assert(page_ref(p1) == 0);
c0108b19:	83 ec 0c             	sub    $0xc,%esp
c0108b1c:	ff 75 f4             	pushl  -0xc(%ebp)
c0108b1f:	e8 73 ee ff ff       	call   c0107997 <page_ref>
c0108b24:	83 c4 10             	add    $0x10,%esp
c0108b27:	85 c0                	test   %eax,%eax
c0108b29:	74 19                	je     c0108b44 <check_pgdir+0x4bf>
c0108b2b:	68 c5 c7 10 c0       	push   $0xc010c7c5
c0108b30:	68 1d c5 10 c0       	push   $0xc010c51d
c0108b35:	68 0e 02 00 00       	push   $0x20e
c0108b3a:	68 f8 c4 10 c0       	push   $0xc010c4f8
c0108b3f:	e8 18 8c ff ff       	call   c010175c <__panic>
    assert(page_ref(p2) == 0);
c0108b44:	83 ec 0c             	sub    $0xc,%esp
c0108b47:	ff 75 e4             	pushl  -0x1c(%ebp)
c0108b4a:	e8 48 ee ff ff       	call   c0107997 <page_ref>
c0108b4f:	83 c4 10             	add    $0x10,%esp
c0108b52:	85 c0                	test   %eax,%eax
c0108b54:	74 19                	je     c0108b6f <check_pgdir+0x4ea>
c0108b56:	68 9e c7 10 c0       	push   $0xc010c79e
c0108b5b:	68 1d c5 10 c0       	push   $0xc010c51d
c0108b60:	68 0f 02 00 00       	push   $0x20f
c0108b65:	68 f8 c4 10 c0       	push   $0xc010c4f8
c0108b6a:	e8 ed 8b ff ff       	call   c010175c <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0108b6f:	a1 24 8a 12 c0       	mov    0xc0128a24,%eax
c0108b74:	8b 00                	mov    (%eax),%eax
c0108b76:	83 ec 0c             	sub    $0xc,%esp
c0108b79:	50                   	push   %eax
c0108b7a:	e8 fc ed ff ff       	call   c010797b <pde2page>
c0108b7f:	83 c4 10             	add    $0x10,%esp
c0108b82:	83 ec 0c             	sub    $0xc,%esp
c0108b85:	50                   	push   %eax
c0108b86:	e8 0c ee ff ff       	call   c0107997 <page_ref>
c0108b8b:	83 c4 10             	add    $0x10,%esp
c0108b8e:	83 f8 01             	cmp    $0x1,%eax
c0108b91:	74 19                	je     c0108bac <check_pgdir+0x527>
c0108b93:	68 d8 c7 10 c0       	push   $0xc010c7d8
c0108b98:	68 1d c5 10 c0       	push   $0xc010c51d
c0108b9d:	68 11 02 00 00       	push   $0x211
c0108ba2:	68 f8 c4 10 c0       	push   $0xc010c4f8
c0108ba7:	e8 b0 8b ff ff       	call   c010175c <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0108bac:	a1 24 8a 12 c0       	mov    0xc0128a24,%eax
c0108bb1:	8b 00                	mov    (%eax),%eax
c0108bb3:	83 ec 0c             	sub    $0xc,%esp
c0108bb6:	50                   	push   %eax
c0108bb7:	e8 bf ed ff ff       	call   c010797b <pde2page>
c0108bbc:	83 c4 10             	add    $0x10,%esp
c0108bbf:	83 ec 08             	sub    $0x8,%esp
c0108bc2:	6a 01                	push   $0x1
c0108bc4:	50                   	push   %eax
c0108bc5:	e8 47 f0 ff ff       	call   c0107c11 <free_pages>
c0108bca:	83 c4 10             	add    $0x10,%esp
    boot_pgdir[0] = 0;
c0108bcd:	a1 24 8a 12 c0       	mov    0xc0128a24,%eax
c0108bd2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0108bd8:	83 ec 0c             	sub    $0xc,%esp
c0108bdb:	68 ff c7 10 c0       	push   $0xc010c7ff
c0108be0:	e8 99 76 ff ff       	call   c010027e <cprintf>
c0108be5:	83 c4 10             	add    $0x10,%esp
}
c0108be8:	90                   	nop
c0108be9:	c9                   	leave  
c0108bea:	c3                   	ret    

c0108beb <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0108beb:	55                   	push   %ebp
c0108bec:	89 e5                	mov    %esp,%ebp
c0108bee:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0108bf1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0108bf8:	e9 a3 00 00 00       	jmp    c0108ca0 <check_boot_pgdir+0xb5>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0108bfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108c00:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108c03:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108c06:	c1 e8 0c             	shr    $0xc,%eax
c0108c09:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108c0c:	a1 20 8a 12 c0       	mov    0xc0128a20,%eax
c0108c11:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0108c14:	72 17                	jb     c0108c2d <check_boot_pgdir+0x42>
c0108c16:	ff 75 f0             	pushl  -0x10(%ebp)
c0108c19:	68 30 c4 10 c0       	push   $0xc010c430
c0108c1e:	68 1d 02 00 00       	push   $0x21d
c0108c23:	68 f8 c4 10 c0       	push   $0xc010c4f8
c0108c28:	e8 2f 8b ff ff       	call   c010175c <__panic>
c0108c2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108c30:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0108c35:	89 c2                	mov    %eax,%edx
c0108c37:	a1 24 8a 12 c0       	mov    0xc0128a24,%eax
c0108c3c:	83 ec 04             	sub    $0x4,%esp
c0108c3f:	6a 00                	push   $0x0
c0108c41:	52                   	push   %edx
c0108c42:	50                   	push   %eax
c0108c43:	e8 58 f6 ff ff       	call   c01082a0 <get_pte>
c0108c48:	83 c4 10             	add    $0x10,%esp
c0108c4b:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108c4e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108c52:	75 19                	jne    c0108c6d <check_boot_pgdir+0x82>
c0108c54:	68 1c c8 10 c0       	push   $0xc010c81c
c0108c59:	68 1d c5 10 c0       	push   $0xc010c51d
c0108c5e:	68 1d 02 00 00       	push   $0x21d
c0108c63:	68 f8 c4 10 c0       	push   $0xc010c4f8
c0108c68:	e8 ef 8a ff ff       	call   c010175c <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0108c6d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108c70:	8b 00                	mov    (%eax),%eax
c0108c72:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0108c77:	89 c2                	mov    %eax,%edx
c0108c79:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108c7c:	39 c2                	cmp    %eax,%edx
c0108c7e:	74 19                	je     c0108c99 <check_boot_pgdir+0xae>
c0108c80:	68 59 c8 10 c0       	push   $0xc010c859
c0108c85:	68 1d c5 10 c0       	push   $0xc010c51d
c0108c8a:	68 1e 02 00 00       	push   $0x21e
c0108c8f:	68 f8 c4 10 c0       	push   $0xc010c4f8
c0108c94:	e8 c3 8a ff ff       	call   c010175c <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0108c99:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0108ca0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108ca3:	a1 20 8a 12 c0       	mov    0xc0128a20,%eax
c0108ca8:	39 c2                	cmp    %eax,%edx
c0108caa:	0f 82 4d ff ff ff    	jb     c0108bfd <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0108cb0:	a1 24 8a 12 c0       	mov    0xc0128a24,%eax
c0108cb5:	05 ac 0f 00 00       	add    $0xfac,%eax
c0108cba:	8b 00                	mov    (%eax),%eax
c0108cbc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0108cc1:	89 c2                	mov    %eax,%edx
c0108cc3:	a1 24 8a 12 c0       	mov    0xc0128a24,%eax
c0108cc8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0108ccb:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
c0108cd2:	77 17                	ja     c0108ceb <check_boot_pgdir+0x100>
c0108cd4:	ff 75 e4             	pushl  -0x1c(%ebp)
c0108cd7:	68 d4 c4 10 c0       	push   $0xc010c4d4
c0108cdc:	68 21 02 00 00       	push   $0x221
c0108ce1:	68 f8 c4 10 c0       	push   $0xc010c4f8
c0108ce6:	e8 71 8a ff ff       	call   c010175c <__panic>
c0108ceb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108cee:	05 00 00 00 40       	add    $0x40000000,%eax
c0108cf3:	39 c2                	cmp    %eax,%edx
c0108cf5:	74 19                	je     c0108d10 <check_boot_pgdir+0x125>
c0108cf7:	68 70 c8 10 c0       	push   $0xc010c870
c0108cfc:	68 1d c5 10 c0       	push   $0xc010c51d
c0108d01:	68 21 02 00 00       	push   $0x221
c0108d06:	68 f8 c4 10 c0       	push   $0xc010c4f8
c0108d0b:	e8 4c 8a ff ff       	call   c010175c <__panic>

    assert(boot_pgdir[0] == 0);
c0108d10:	a1 24 8a 12 c0       	mov    0xc0128a24,%eax
c0108d15:	8b 00                	mov    (%eax),%eax
c0108d17:	85 c0                	test   %eax,%eax
c0108d19:	74 19                	je     c0108d34 <check_boot_pgdir+0x149>
c0108d1b:	68 a4 c8 10 c0       	push   $0xc010c8a4
c0108d20:	68 1d c5 10 c0       	push   $0xc010c51d
c0108d25:	68 23 02 00 00       	push   $0x223
c0108d2a:	68 f8 c4 10 c0       	push   $0xc010c4f8
c0108d2f:	e8 28 8a ff ff       	call   c010175c <__panic>

    struct Page *p;
    p = alloc_page();
c0108d34:	83 ec 0c             	sub    $0xc,%esp
c0108d37:	6a 01                	push   $0x1
c0108d39:	e8 67 ee ff ff       	call   c0107ba5 <alloc_pages>
c0108d3e:	83 c4 10             	add    $0x10,%esp
c0108d41:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0108d44:	a1 24 8a 12 c0       	mov    0xc0128a24,%eax
c0108d49:	6a 02                	push   $0x2
c0108d4b:	68 00 01 00 00       	push   $0x100
c0108d50:	ff 75 e0             	pushl  -0x20(%ebp)
c0108d53:	50                   	push   %eax
c0108d54:	e8 58 f7 ff ff       	call   c01084b1 <page_insert>
c0108d59:	83 c4 10             	add    $0x10,%esp
c0108d5c:	85 c0                	test   %eax,%eax
c0108d5e:	74 19                	je     c0108d79 <check_boot_pgdir+0x18e>
c0108d60:	68 b8 c8 10 c0       	push   $0xc010c8b8
c0108d65:	68 1d c5 10 c0       	push   $0xc010c51d
c0108d6a:	68 27 02 00 00       	push   $0x227
c0108d6f:	68 f8 c4 10 c0       	push   $0xc010c4f8
c0108d74:	e8 e3 89 ff ff       	call   c010175c <__panic>
    assert(page_ref(p) == 1);
c0108d79:	83 ec 0c             	sub    $0xc,%esp
c0108d7c:	ff 75 e0             	pushl  -0x20(%ebp)
c0108d7f:	e8 13 ec ff ff       	call   c0107997 <page_ref>
c0108d84:	83 c4 10             	add    $0x10,%esp
c0108d87:	83 f8 01             	cmp    $0x1,%eax
c0108d8a:	74 19                	je     c0108da5 <check_boot_pgdir+0x1ba>
c0108d8c:	68 e6 c8 10 c0       	push   $0xc010c8e6
c0108d91:	68 1d c5 10 c0       	push   $0xc010c51d
c0108d96:	68 28 02 00 00       	push   $0x228
c0108d9b:	68 f8 c4 10 c0       	push   $0xc010c4f8
c0108da0:	e8 b7 89 ff ff       	call   c010175c <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0108da5:	a1 24 8a 12 c0       	mov    0xc0128a24,%eax
c0108daa:	6a 02                	push   $0x2
c0108dac:	68 00 11 00 00       	push   $0x1100
c0108db1:	ff 75 e0             	pushl  -0x20(%ebp)
c0108db4:	50                   	push   %eax
c0108db5:	e8 f7 f6 ff ff       	call   c01084b1 <page_insert>
c0108dba:	83 c4 10             	add    $0x10,%esp
c0108dbd:	85 c0                	test   %eax,%eax
c0108dbf:	74 19                	je     c0108dda <check_boot_pgdir+0x1ef>
c0108dc1:	68 f8 c8 10 c0       	push   $0xc010c8f8
c0108dc6:	68 1d c5 10 c0       	push   $0xc010c51d
c0108dcb:	68 29 02 00 00       	push   $0x229
c0108dd0:	68 f8 c4 10 c0       	push   $0xc010c4f8
c0108dd5:	e8 82 89 ff ff       	call   c010175c <__panic>
    assert(page_ref(p) == 2);
c0108dda:	83 ec 0c             	sub    $0xc,%esp
c0108ddd:	ff 75 e0             	pushl  -0x20(%ebp)
c0108de0:	e8 b2 eb ff ff       	call   c0107997 <page_ref>
c0108de5:	83 c4 10             	add    $0x10,%esp
c0108de8:	83 f8 02             	cmp    $0x2,%eax
c0108deb:	74 19                	je     c0108e06 <check_boot_pgdir+0x21b>
c0108ded:	68 2f c9 10 c0       	push   $0xc010c92f
c0108df2:	68 1d c5 10 c0       	push   $0xc010c51d
c0108df7:	68 2a 02 00 00       	push   $0x22a
c0108dfc:	68 f8 c4 10 c0       	push   $0xc010c4f8
c0108e01:	e8 56 89 ff ff       	call   c010175c <__panic>

    const char *str = "ucore: Hello world!!";
c0108e06:	c7 45 dc 40 c9 10 c0 	movl   $0xc010c940,-0x24(%ebp)
    strcpy((void *)0x100, str);
c0108e0d:	83 ec 08             	sub    $0x8,%esp
c0108e10:	ff 75 dc             	pushl  -0x24(%ebp)
c0108e13:	68 00 01 00 00       	push   $0x100
c0108e18:	e8 62 10 00 00       	call   c0109e7f <strcpy>
c0108e1d:	83 c4 10             	add    $0x10,%esp
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0108e20:	83 ec 08             	sub    $0x8,%esp
c0108e23:	68 00 11 00 00       	push   $0x1100
c0108e28:	68 00 01 00 00       	push   $0x100
c0108e2d:	e8 c7 10 00 00       	call   c0109ef9 <strcmp>
c0108e32:	83 c4 10             	add    $0x10,%esp
c0108e35:	85 c0                	test   %eax,%eax
c0108e37:	74 19                	je     c0108e52 <check_boot_pgdir+0x267>
c0108e39:	68 58 c9 10 c0       	push   $0xc010c958
c0108e3e:	68 1d c5 10 c0       	push   $0xc010c51d
c0108e43:	68 2e 02 00 00       	push   $0x22e
c0108e48:	68 f8 c4 10 c0       	push   $0xc010c4f8
c0108e4d:	e8 0a 89 ff ff       	call   c010175c <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0108e52:	83 ec 0c             	sub    $0xc,%esp
c0108e55:	ff 75 e0             	pushl  -0x20(%ebp)
c0108e58:	e8 9f ea ff ff       	call   c01078fc <page2kva>
c0108e5d:	83 c4 10             	add    $0x10,%esp
c0108e60:	05 00 01 00 00       	add    $0x100,%eax
c0108e65:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0108e68:	83 ec 0c             	sub    $0xc,%esp
c0108e6b:	68 00 01 00 00       	push   $0x100
c0108e70:	e8 b2 0f 00 00       	call   c0109e27 <strlen>
c0108e75:	83 c4 10             	add    $0x10,%esp
c0108e78:	85 c0                	test   %eax,%eax
c0108e7a:	74 19                	je     c0108e95 <check_boot_pgdir+0x2aa>
c0108e7c:	68 90 c9 10 c0       	push   $0xc010c990
c0108e81:	68 1d c5 10 c0       	push   $0xc010c51d
c0108e86:	68 31 02 00 00       	push   $0x231
c0108e8b:	68 f8 c4 10 c0       	push   $0xc010c4f8
c0108e90:	e8 c7 88 ff ff       	call   c010175c <__panic>

    free_page(p);
c0108e95:	83 ec 08             	sub    $0x8,%esp
c0108e98:	6a 01                	push   $0x1
c0108e9a:	ff 75 e0             	pushl  -0x20(%ebp)
c0108e9d:	e8 6f ed ff ff       	call   c0107c11 <free_pages>
c0108ea2:	83 c4 10             	add    $0x10,%esp
    free_page(pde2page(boot_pgdir[0]));
c0108ea5:	a1 24 8a 12 c0       	mov    0xc0128a24,%eax
c0108eaa:	8b 00                	mov    (%eax),%eax
c0108eac:	83 ec 0c             	sub    $0xc,%esp
c0108eaf:	50                   	push   %eax
c0108eb0:	e8 c6 ea ff ff       	call   c010797b <pde2page>
c0108eb5:	83 c4 10             	add    $0x10,%esp
c0108eb8:	83 ec 08             	sub    $0x8,%esp
c0108ebb:	6a 01                	push   $0x1
c0108ebd:	50                   	push   %eax
c0108ebe:	e8 4e ed ff ff       	call   c0107c11 <free_pages>
c0108ec3:	83 c4 10             	add    $0x10,%esp
    boot_pgdir[0] = 0;
c0108ec6:	a1 24 8a 12 c0       	mov    0xc0128a24,%eax
c0108ecb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0108ed1:	83 ec 0c             	sub    $0xc,%esp
c0108ed4:	68 b4 c9 10 c0       	push   $0xc010c9b4
c0108ed9:	e8 a0 73 ff ff       	call   c010027e <cprintf>
c0108ede:	83 c4 10             	add    $0x10,%esp
}
c0108ee1:	90                   	nop
c0108ee2:	c9                   	leave  
c0108ee3:	c3                   	ret    

c0108ee4 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0108ee4:	55                   	push   %ebp
c0108ee5:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0108ee7:	8b 45 08             	mov    0x8(%ebp),%eax
c0108eea:	83 e0 04             	and    $0x4,%eax
c0108eed:	85 c0                	test   %eax,%eax
c0108eef:	74 07                	je     c0108ef8 <perm2str+0x14>
c0108ef1:	b8 75 00 00 00       	mov    $0x75,%eax
c0108ef6:	eb 05                	jmp    c0108efd <perm2str+0x19>
c0108ef8:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0108efd:	a2 a8 8a 12 c0       	mov    %al,0xc0128aa8
    str[1] = 'r';
c0108f02:	c6 05 a9 8a 12 c0 72 	movb   $0x72,0xc0128aa9
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0108f09:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f0c:	83 e0 02             	and    $0x2,%eax
c0108f0f:	85 c0                	test   %eax,%eax
c0108f11:	74 07                	je     c0108f1a <perm2str+0x36>
c0108f13:	b8 77 00 00 00       	mov    $0x77,%eax
c0108f18:	eb 05                	jmp    c0108f1f <perm2str+0x3b>
c0108f1a:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0108f1f:	a2 aa 8a 12 c0       	mov    %al,0xc0128aaa
    str[3] = '\0';
c0108f24:	c6 05 ab 8a 12 c0 00 	movb   $0x0,0xc0128aab
    return str;
c0108f2b:	b8 a8 8a 12 c0       	mov    $0xc0128aa8,%eax
}
c0108f30:	5d                   	pop    %ebp
c0108f31:	c3                   	ret    

c0108f32 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0108f32:	55                   	push   %ebp
c0108f33:	89 e5                	mov    %esp,%ebp
c0108f35:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c0108f38:	8b 45 10             	mov    0x10(%ebp),%eax
c0108f3b:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108f3e:	72 0e                	jb     c0108f4e <get_pgtable_items+0x1c>
        return 0;
c0108f40:	b8 00 00 00 00       	mov    $0x0,%eax
c0108f45:	e9 9a 00 00 00       	jmp    c0108fe4 <get_pgtable_items+0xb2>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
c0108f4a:	83 45 10 01          	addl   $0x1,0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
c0108f4e:	8b 45 10             	mov    0x10(%ebp),%eax
c0108f51:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108f54:	73 18                	jae    c0108f6e <get_pgtable_items+0x3c>
c0108f56:	8b 45 10             	mov    0x10(%ebp),%eax
c0108f59:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0108f60:	8b 45 14             	mov    0x14(%ebp),%eax
c0108f63:	01 d0                	add    %edx,%eax
c0108f65:	8b 00                	mov    (%eax),%eax
c0108f67:	83 e0 01             	and    $0x1,%eax
c0108f6a:	85 c0                	test   %eax,%eax
c0108f6c:	74 dc                	je     c0108f4a <get_pgtable_items+0x18>
        start ++;
    }
    if (start < right) {
c0108f6e:	8b 45 10             	mov    0x10(%ebp),%eax
c0108f71:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108f74:	73 69                	jae    c0108fdf <get_pgtable_items+0xad>
        if (left_store != NULL) {
c0108f76:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0108f7a:	74 08                	je     c0108f84 <get_pgtable_items+0x52>
            *left_store = start;
c0108f7c:	8b 45 18             	mov    0x18(%ebp),%eax
c0108f7f:	8b 55 10             	mov    0x10(%ebp),%edx
c0108f82:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c0108f84:	8b 45 10             	mov    0x10(%ebp),%eax
c0108f87:	8d 50 01             	lea    0x1(%eax),%edx
c0108f8a:	89 55 10             	mov    %edx,0x10(%ebp)
c0108f8d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0108f94:	8b 45 14             	mov    0x14(%ebp),%eax
c0108f97:	01 d0                	add    %edx,%eax
c0108f99:	8b 00                	mov    (%eax),%eax
c0108f9b:	83 e0 07             	and    $0x7,%eax
c0108f9e:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0108fa1:	eb 04                	jmp    c0108fa7 <get_pgtable_items+0x75>
            start ++;
c0108fa3:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
c0108fa7:	8b 45 10             	mov    0x10(%ebp),%eax
c0108faa:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108fad:	73 1d                	jae    c0108fcc <get_pgtable_items+0x9a>
c0108faf:	8b 45 10             	mov    0x10(%ebp),%eax
c0108fb2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0108fb9:	8b 45 14             	mov    0x14(%ebp),%eax
c0108fbc:	01 d0                	add    %edx,%eax
c0108fbe:	8b 00                	mov    (%eax),%eax
c0108fc0:	83 e0 07             	and    $0x7,%eax
c0108fc3:	89 c2                	mov    %eax,%edx
c0108fc5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108fc8:	39 c2                	cmp    %eax,%edx
c0108fca:	74 d7                	je     c0108fa3 <get_pgtable_items+0x71>
            start ++;
        }
        if (right_store != NULL) {
c0108fcc:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0108fd0:	74 08                	je     c0108fda <get_pgtable_items+0xa8>
            *right_store = start;
c0108fd2:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0108fd5:	8b 55 10             	mov    0x10(%ebp),%edx
c0108fd8:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0108fda:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108fdd:	eb 05                	jmp    c0108fe4 <get_pgtable_items+0xb2>
    }
    return 0;
c0108fdf:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108fe4:	c9                   	leave  
c0108fe5:	c3                   	ret    

c0108fe6 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0108fe6:	55                   	push   %ebp
c0108fe7:	89 e5                	mov    %esp,%ebp
c0108fe9:	57                   	push   %edi
c0108fea:	56                   	push   %esi
c0108feb:	53                   	push   %ebx
c0108fec:	83 ec 2c             	sub    $0x2c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0108fef:	83 ec 0c             	sub    $0xc,%esp
c0108ff2:	68 d4 c9 10 c0       	push   $0xc010c9d4
c0108ff7:	e8 82 72 ff ff       	call   c010027e <cprintf>
c0108ffc:	83 c4 10             	add    $0x10,%esp
    size_t left, right = 0, perm;
c0108fff:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0109006:	e9 e5 00 00 00       	jmp    c01090f0 <print_pgdir+0x10a>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c010900b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010900e:	83 ec 0c             	sub    $0xc,%esp
c0109011:	50                   	push   %eax
c0109012:	e8 cd fe ff ff       	call   c0108ee4 <perm2str>
c0109017:	83 c4 10             	add    $0x10,%esp
c010901a:	89 c7                	mov    %eax,%edi
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c010901c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010901f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109022:	29 c2                	sub    %eax,%edx
c0109024:	89 d0                	mov    %edx,%eax
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0109026:	c1 e0 16             	shl    $0x16,%eax
c0109029:	89 c3                	mov    %eax,%ebx
c010902b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010902e:	c1 e0 16             	shl    $0x16,%eax
c0109031:	89 c1                	mov    %eax,%ecx
c0109033:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109036:	c1 e0 16             	shl    $0x16,%eax
c0109039:	89 c2                	mov    %eax,%edx
c010903b:	8b 75 dc             	mov    -0x24(%ebp),%esi
c010903e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109041:	29 c6                	sub    %eax,%esi
c0109043:	89 f0                	mov    %esi,%eax
c0109045:	83 ec 08             	sub    $0x8,%esp
c0109048:	57                   	push   %edi
c0109049:	53                   	push   %ebx
c010904a:	51                   	push   %ecx
c010904b:	52                   	push   %edx
c010904c:	50                   	push   %eax
c010904d:	68 05 ca 10 c0       	push   $0xc010ca05
c0109052:	e8 27 72 ff ff       	call   c010027e <cprintf>
c0109057:	83 c4 20             	add    $0x20,%esp
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
c010905a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010905d:	c1 e0 0a             	shl    $0xa,%eax
c0109060:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0109063:	eb 4f                	jmp    c01090b4 <print_pgdir+0xce>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0109065:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109068:	83 ec 0c             	sub    $0xc,%esp
c010906b:	50                   	push   %eax
c010906c:	e8 73 fe ff ff       	call   c0108ee4 <perm2str>
c0109071:	83 c4 10             	add    $0x10,%esp
c0109074:	89 c7                	mov    %eax,%edi
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0109076:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0109079:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010907c:	29 c2                	sub    %eax,%edx
c010907e:	89 d0                	mov    %edx,%eax
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0109080:	c1 e0 0c             	shl    $0xc,%eax
c0109083:	89 c3                	mov    %eax,%ebx
c0109085:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0109088:	c1 e0 0c             	shl    $0xc,%eax
c010908b:	89 c1                	mov    %eax,%ecx
c010908d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0109090:	c1 e0 0c             	shl    $0xc,%eax
c0109093:	89 c2                	mov    %eax,%edx
c0109095:	8b 75 d4             	mov    -0x2c(%ebp),%esi
c0109098:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010909b:	29 c6                	sub    %eax,%esi
c010909d:	89 f0                	mov    %esi,%eax
c010909f:	83 ec 08             	sub    $0x8,%esp
c01090a2:	57                   	push   %edi
c01090a3:	53                   	push   %ebx
c01090a4:	51                   	push   %ecx
c01090a5:	52                   	push   %edx
c01090a6:	50                   	push   %eax
c01090a7:	68 24 ca 10 c0       	push   $0xc010ca24
c01090ac:	e8 cd 71 ff ff       	call   c010027e <cprintf>
c01090b1:	83 c4 20             	add    $0x20,%esp
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c01090b4:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c01090b9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01090bc:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01090bf:	89 d3                	mov    %edx,%ebx
c01090c1:	c1 e3 0a             	shl    $0xa,%ebx
c01090c4:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01090c7:	89 d1                	mov    %edx,%ecx
c01090c9:	c1 e1 0a             	shl    $0xa,%ecx
c01090cc:	83 ec 08             	sub    $0x8,%esp
c01090cf:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c01090d2:	52                   	push   %edx
c01090d3:	8d 55 d8             	lea    -0x28(%ebp),%edx
c01090d6:	52                   	push   %edx
c01090d7:	56                   	push   %esi
c01090d8:	50                   	push   %eax
c01090d9:	53                   	push   %ebx
c01090da:	51                   	push   %ecx
c01090db:	e8 52 fe ff ff       	call   c0108f32 <get_pgtable_items>
c01090e0:	83 c4 20             	add    $0x20,%esp
c01090e3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01090e6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01090ea:	0f 85 75 ff ff ff    	jne    c0109065 <print_pgdir+0x7f>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c01090f0:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c01090f5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01090f8:	83 ec 08             	sub    $0x8,%esp
c01090fb:	8d 55 dc             	lea    -0x24(%ebp),%edx
c01090fe:	52                   	push   %edx
c01090ff:	8d 55 e0             	lea    -0x20(%ebp),%edx
c0109102:	52                   	push   %edx
c0109103:	51                   	push   %ecx
c0109104:	50                   	push   %eax
c0109105:	68 00 04 00 00       	push   $0x400
c010910a:	6a 00                	push   $0x0
c010910c:	e8 21 fe ff ff       	call   c0108f32 <get_pgtable_items>
c0109111:	83 c4 20             	add    $0x20,%esp
c0109114:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0109117:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010911b:	0f 85 ea fe ff ff    	jne    c010900b <print_pgdir+0x25>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0109121:	83 ec 0c             	sub    $0xc,%esp
c0109124:	68 48 ca 10 c0       	push   $0xc010ca48
c0109129:	e8 50 71 ff ff       	call   c010027e <cprintf>
c010912e:	83 c4 10             	add    $0x10,%esp
}
c0109131:	90                   	nop
c0109132:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0109135:	5b                   	pop    %ebx
c0109136:	5e                   	pop    %esi
c0109137:	5f                   	pop    %edi
c0109138:	5d                   	pop    %ebp
c0109139:	c3                   	ret    

c010913a <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c010913a:	55                   	push   %ebp
c010913b:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010913d:	8b 45 08             	mov    0x8(%ebp),%eax
c0109140:	8b 15 e0 ab 12 c0    	mov    0xc012abe0,%edx
c0109146:	29 d0                	sub    %edx,%eax
c0109148:	c1 f8 02             	sar    $0x2,%eax
c010914b:	69 c0 39 8e e3 38    	imul   $0x38e38e39,%eax,%eax
}
c0109151:	5d                   	pop    %ebp
c0109152:	c3                   	ret    

c0109153 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0109153:	55                   	push   %ebp
c0109154:	89 e5                	mov    %esp,%ebp
    return page2ppn(page) << PGSHIFT;
c0109156:	ff 75 08             	pushl  0x8(%ebp)
c0109159:	e8 dc ff ff ff       	call   c010913a <page2ppn>
c010915e:	83 c4 04             	add    $0x4,%esp
c0109161:	c1 e0 0c             	shl    $0xc,%eax
}
c0109164:	c9                   	leave  
c0109165:	c3                   	ret    

c0109166 <page2kva>:
    }
    return &pages[PPN(pa)];
}

static inline void *
page2kva(struct Page *page) {
c0109166:	55                   	push   %ebp
c0109167:	89 e5                	mov    %esp,%ebp
c0109169:	83 ec 18             	sub    $0x18,%esp
    return KADDR(page2pa(page));
c010916c:	ff 75 08             	pushl  0x8(%ebp)
c010916f:	e8 df ff ff ff       	call   c0109153 <page2pa>
c0109174:	83 c4 04             	add    $0x4,%esp
c0109177:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010917a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010917d:	c1 e8 0c             	shr    $0xc,%eax
c0109180:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109183:	a1 20 8a 12 c0       	mov    0xc0128a20,%eax
c0109188:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010918b:	72 14                	jb     c01091a1 <page2kva+0x3b>
c010918d:	ff 75 f4             	pushl  -0xc(%ebp)
c0109190:	68 7c ca 10 c0       	push   $0xc010ca7c
c0109195:	6a 66                	push   $0x66
c0109197:	68 9f ca 10 c0       	push   $0xc010ca9f
c010919c:	e8 bb 85 ff ff       	call   c010175c <__panic>
c01091a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01091a4:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01091a9:	c9                   	leave  
c01091aa:	c3                   	ret    

c01091ab <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
c01091ab:	55                   	push   %ebp
c01091ac:	89 e5                	mov    %esp,%ebp
c01091ae:	83 ec 08             	sub    $0x8,%esp
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
c01091b1:	83 ec 0c             	sub    $0xc,%esp
c01091b4:	6a 01                	push   $0x1
c01091b6:	e8 8a 92 ff ff       	call   c0102445 <ide_device_valid>
c01091bb:	83 c4 10             	add    $0x10,%esp
c01091be:	85 c0                	test   %eax,%eax
c01091c0:	75 14                	jne    c01091d6 <swapfs_init+0x2b>
        panic("swap fs isn't available.\n");
c01091c2:	83 ec 04             	sub    $0x4,%esp
c01091c5:	68 ad ca 10 c0       	push   $0xc010caad
c01091ca:	6a 0d                	push   $0xd
c01091cc:	68 c7 ca 10 c0       	push   $0xc010cac7
c01091d1:	e8 86 85 ff ff       	call   c010175c <__panic>
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
c01091d6:	83 ec 0c             	sub    $0xc,%esp
c01091d9:	6a 01                	push   $0x1
c01091db:	e8 a5 92 ff ff       	call   c0102485 <ide_device_size>
c01091e0:	83 c4 10             	add    $0x10,%esp
c01091e3:	c1 e8 03             	shr    $0x3,%eax
c01091e6:	a3 9c ab 12 c0       	mov    %eax,0xc012ab9c
}
c01091eb:	90                   	nop
c01091ec:	c9                   	leave  
c01091ed:	c3                   	ret    

c01091ee <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
c01091ee:	55                   	push   %ebp
c01091ef:	89 e5                	mov    %esp,%ebp
c01091f1:	83 ec 18             	sub    $0x18,%esp
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c01091f4:	83 ec 0c             	sub    $0xc,%esp
c01091f7:	ff 75 0c             	pushl  0xc(%ebp)
c01091fa:	e8 67 ff ff ff       	call   c0109166 <page2kva>
c01091ff:	83 c4 10             	add    $0x10,%esp
c0109202:	89 c2                	mov    %eax,%edx
c0109204:	8b 45 08             	mov    0x8(%ebp),%eax
c0109207:	c1 e8 08             	shr    $0x8,%eax
c010920a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010920d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109211:	74 0a                	je     c010921d <swapfs_read+0x2f>
c0109213:	a1 9c ab 12 c0       	mov    0xc012ab9c,%eax
c0109218:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010921b:	72 14                	jb     c0109231 <swapfs_read+0x43>
c010921d:	ff 75 08             	pushl  0x8(%ebp)
c0109220:	68 d8 ca 10 c0       	push   $0xc010cad8
c0109225:	6a 14                	push   $0x14
c0109227:	68 c7 ca 10 c0       	push   $0xc010cac7
c010922c:	e8 2b 85 ff ff       	call   c010175c <__panic>
c0109231:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109234:	c1 e0 03             	shl    $0x3,%eax
c0109237:	6a 08                	push   $0x8
c0109239:	52                   	push   %edx
c010923a:	50                   	push   %eax
c010923b:	6a 01                	push   $0x1
c010923d:	e8 83 92 ff ff       	call   c01024c5 <ide_read_secs>
c0109242:	83 c4 10             	add    $0x10,%esp
}
c0109245:	c9                   	leave  
c0109246:	c3                   	ret    

c0109247 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
c0109247:	55                   	push   %ebp
c0109248:	89 e5                	mov    %esp,%ebp
c010924a:	83 ec 18             	sub    $0x18,%esp
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c010924d:	83 ec 0c             	sub    $0xc,%esp
c0109250:	ff 75 0c             	pushl  0xc(%ebp)
c0109253:	e8 0e ff ff ff       	call   c0109166 <page2kva>
c0109258:	83 c4 10             	add    $0x10,%esp
c010925b:	89 c2                	mov    %eax,%edx
c010925d:	8b 45 08             	mov    0x8(%ebp),%eax
c0109260:	c1 e8 08             	shr    $0x8,%eax
c0109263:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109266:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010926a:	74 0a                	je     c0109276 <swapfs_write+0x2f>
c010926c:	a1 9c ab 12 c0       	mov    0xc012ab9c,%eax
c0109271:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0109274:	72 14                	jb     c010928a <swapfs_write+0x43>
c0109276:	ff 75 08             	pushl  0x8(%ebp)
c0109279:	68 d8 ca 10 c0       	push   $0xc010cad8
c010927e:	6a 19                	push   $0x19
c0109280:	68 c7 ca 10 c0       	push   $0xc010cac7
c0109285:	e8 d2 84 ff ff       	call   c010175c <__panic>
c010928a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010928d:	c1 e0 03             	shl    $0x3,%eax
c0109290:	6a 08                	push   $0x8
c0109292:	52                   	push   %edx
c0109293:	50                   	push   %eax
c0109294:	6a 01                	push   $0x1
c0109296:	e8 54 94 ff ff       	call   c01026ef <ide_write_secs>
c010929b:	83 c4 10             	add    $0x10,%esp
}
c010929e:	c9                   	leave  
c010929f:	c3                   	ret    

c01092a0 <switch_to>:
.text
.globl switch_to
switch_to:                      # switch_to(from, to)

    # save from's registers
    movl 4(%esp), %eax          # eax points to from
c01092a0:	8b 44 24 04          	mov    0x4(%esp),%eax
    popl 0(%eax)                # save eip !popl
c01092a4:	8f 00                	popl   (%eax)
    movl %esp, 4(%eax)
c01092a6:	89 60 04             	mov    %esp,0x4(%eax)
    movl %ebx, 8(%eax)
c01092a9:	89 58 08             	mov    %ebx,0x8(%eax)
    movl %ecx, 12(%eax)
c01092ac:	89 48 0c             	mov    %ecx,0xc(%eax)
    movl %edx, 16(%eax)
c01092af:	89 50 10             	mov    %edx,0x10(%eax)
    movl %esi, 20(%eax)
c01092b2:	89 70 14             	mov    %esi,0x14(%eax)
    movl %edi, 24(%eax)
c01092b5:	89 78 18             	mov    %edi,0x18(%eax)
    movl %ebp, 28(%eax)
c01092b8:	89 68 1c             	mov    %ebp,0x1c(%eax)

    # restore to's registers
    movl 4(%esp), %eax          # not 8(%esp): popped return address already
c01092bb:	8b 44 24 04          	mov    0x4(%esp),%eax
                                # eax now points to to
    movl 28(%eax), %ebp
c01092bf:	8b 68 1c             	mov    0x1c(%eax),%ebp
    movl 24(%eax), %edi
c01092c2:	8b 78 18             	mov    0x18(%eax),%edi
    movl 20(%eax), %esi
c01092c5:	8b 70 14             	mov    0x14(%eax),%esi
    movl 16(%eax), %edx
c01092c8:	8b 50 10             	mov    0x10(%eax),%edx
    movl 12(%eax), %ecx
c01092cb:	8b 48 0c             	mov    0xc(%eax),%ecx
    movl 8(%eax), %ebx
c01092ce:	8b 58 08             	mov    0x8(%eax),%ebx
    movl 4(%eax), %esp
c01092d1:	8b 60 04             	mov    0x4(%eax),%esp

    pushl 0(%eax)               # push eip
c01092d4:	ff 30                	pushl  (%eax)

    ret
c01092d6:	c3                   	ret    

c01092d7 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)

    pushl %edx              # push arg
c01092d7:	52                   	push   %edx
    call *%ebx              # call fn
c01092d8:	ff d3                	call   *%ebx

    pushl %eax              # save the return value of fn(arg)
c01092da:	50                   	push   %eax
    call do_exit            # call do_exit to terminate current thread
c01092db:	e8 cc 07 00 00       	call   c0109aac <do_exit>

c01092e0 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c01092e0:	55                   	push   %ebp
c01092e1:	89 e5                	mov    %esp,%ebp
c01092e3:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c01092e6:	9c                   	pushf  
c01092e7:	58                   	pop    %eax
c01092e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01092eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01092ee:	25 00 02 00 00       	and    $0x200,%eax
c01092f3:	85 c0                	test   %eax,%eax
c01092f5:	74 0c                	je     c0109303 <__intr_save+0x23>
        intr_disable();
c01092f7:	e8 2c a1 ff ff       	call   c0103428 <intr_disable>
        return 1;
c01092fc:	b8 01 00 00 00       	mov    $0x1,%eax
c0109301:	eb 05                	jmp    c0109308 <__intr_save+0x28>
    }
    return 0;
c0109303:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109308:	c9                   	leave  
c0109309:	c3                   	ret    

c010930a <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c010930a:	55                   	push   %ebp
c010930b:	89 e5                	mov    %esp,%ebp
c010930d:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0109310:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109314:	74 05                	je     c010931b <__intr_restore+0x11>
        intr_enable();
c0109316:	e8 06 a1 ff ff       	call   c0103421 <intr_enable>
    }
}
c010931b:	90                   	nop
c010931c:	c9                   	leave  
c010931d:	c3                   	ret    

c010931e <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c010931e:	55                   	push   %ebp
c010931f:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0109321:	8b 45 08             	mov    0x8(%ebp),%eax
c0109324:	8b 15 e0 ab 12 c0    	mov    0xc012abe0,%edx
c010932a:	29 d0                	sub    %edx,%eax
c010932c:	c1 f8 02             	sar    $0x2,%eax
c010932f:	69 c0 39 8e e3 38    	imul   $0x38e38e39,%eax,%eax
}
c0109335:	5d                   	pop    %ebp
c0109336:	c3                   	ret    

c0109337 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0109337:	55                   	push   %ebp
c0109338:	89 e5                	mov    %esp,%ebp
    return page2ppn(page) << PGSHIFT;
c010933a:	ff 75 08             	pushl  0x8(%ebp)
c010933d:	e8 dc ff ff ff       	call   c010931e <page2ppn>
c0109342:	83 c4 04             	add    $0x4,%esp
c0109345:	c1 e0 0c             	shl    $0xc,%eax
}
c0109348:	c9                   	leave  
c0109349:	c3                   	ret    

c010934a <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c010934a:	55                   	push   %ebp
c010934b:	89 e5                	mov    %esp,%ebp
c010934d:	83 ec 08             	sub    $0x8,%esp
    if (PPN(pa) >= npage) {
c0109350:	8b 45 08             	mov    0x8(%ebp),%eax
c0109353:	c1 e8 0c             	shr    $0xc,%eax
c0109356:	89 c2                	mov    %eax,%edx
c0109358:	a1 20 8a 12 c0       	mov    0xc0128a20,%eax
c010935d:	39 c2                	cmp    %eax,%edx
c010935f:	72 14                	jb     c0109375 <pa2page+0x2b>
        panic("pa2page called with invalid pa");
c0109361:	83 ec 04             	sub    $0x4,%esp
c0109364:	68 f8 ca 10 c0       	push   $0xc010caf8
c0109369:	6a 5f                	push   $0x5f
c010936b:	68 17 cb 10 c0       	push   $0xc010cb17
c0109370:	e8 e7 83 ff ff       	call   c010175c <__panic>
    }
    return &pages[PPN(pa)];
c0109375:	8b 0d e0 ab 12 c0    	mov    0xc012abe0,%ecx
c010937b:	8b 45 08             	mov    0x8(%ebp),%eax
c010937e:	c1 e8 0c             	shr    $0xc,%eax
c0109381:	89 c2                	mov    %eax,%edx
c0109383:	89 d0                	mov    %edx,%eax
c0109385:	c1 e0 03             	shl    $0x3,%eax
c0109388:	01 d0                	add    %edx,%eax
c010938a:	c1 e0 02             	shl    $0x2,%eax
c010938d:	01 c8                	add    %ecx,%eax
}
c010938f:	c9                   	leave  
c0109390:	c3                   	ret    

c0109391 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0109391:	55                   	push   %ebp
c0109392:	89 e5                	mov    %esp,%ebp
c0109394:	83 ec 18             	sub    $0x18,%esp
    return KADDR(page2pa(page));
c0109397:	ff 75 08             	pushl  0x8(%ebp)
c010939a:	e8 98 ff ff ff       	call   c0109337 <page2pa>
c010939f:	83 c4 04             	add    $0x4,%esp
c01093a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01093a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01093a8:	c1 e8 0c             	shr    $0xc,%eax
c01093ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01093ae:	a1 20 8a 12 c0       	mov    0xc0128a20,%eax
c01093b3:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01093b6:	72 14                	jb     c01093cc <page2kva+0x3b>
c01093b8:	ff 75 f4             	pushl  -0xc(%ebp)
c01093bb:	68 28 cb 10 c0       	push   $0xc010cb28
c01093c0:	6a 66                	push   $0x66
c01093c2:	68 17 cb 10 c0       	push   $0xc010cb17
c01093c7:	e8 90 83 ff ff       	call   c010175c <__panic>
c01093cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01093cf:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01093d4:	c9                   	leave  
c01093d5:	c3                   	ret    

c01093d6 <kva2page>:

static inline struct Page *
kva2page(void *kva) {
c01093d6:	55                   	push   %ebp
c01093d7:	89 e5                	mov    %esp,%ebp
c01093d9:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PADDR(kva));
c01093dc:	8b 45 08             	mov    0x8(%ebp),%eax
c01093df:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01093e2:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01093e9:	77 14                	ja     c01093ff <kva2page+0x29>
c01093eb:	ff 75 f4             	pushl  -0xc(%ebp)
c01093ee:	68 4c cb 10 c0       	push   $0xc010cb4c
c01093f3:	6a 6b                	push   $0x6b
c01093f5:	68 17 cb 10 c0       	push   $0xc010cb17
c01093fa:	e8 5d 83 ff ff       	call   c010175c <__panic>
c01093ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109402:	05 00 00 00 40       	add    $0x40000000,%eax
c0109407:	83 ec 0c             	sub    $0xc,%esp
c010940a:	50                   	push   %eax
c010940b:	e8 3a ff ff ff       	call   c010934a <pa2page>
c0109410:	83 c4 10             	add    $0x10,%esp
}
c0109413:	c9                   	leave  
c0109414:	c3                   	ret    

c0109415 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
c0109415:	55                   	push   %ebp
c0109416:	89 e5                	mov    %esp,%ebp
c0109418:	83 ec 18             	sub    $0x18,%esp
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
c010941b:	83 ec 0c             	sub    $0xc,%esp
c010941e:	6a 68                	push   $0x68
c0109420:	e8 c8 cd ff ff       	call   c01061ed <kmalloc>
c0109425:	83 c4 10             	add    $0x10,%esp
c0109428:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (proc != NULL) {
c010942b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010942f:	0f 84 91 00 00 00    	je     c01094c6 <alloc_proc+0xb1>
        proc->state = PROC_UNINIT; // 设置进程为“初始”态
c0109435:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109438:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
       proc->pid = -1;            // 设置进程pid未初始化的值
c010943e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109441:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
       proc->runs = 0;            // 初始化运行时间
c0109448:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010944b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
       proc->kstack = 0;          // 初始化内核栈地址
c0109452:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109455:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
       proc->need_resched = 0;    // 初始化，不需要调度
c010945c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010945f:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
       proc->parent = NULL;       // 父进程为空
c0109466:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109469:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
       proc->mm = NULL;           // 虚拟内存为空
c0109470:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109473:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
       memset(&(proc->context),0, sizeof(struct context)); // 初始化上下文
c010947a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010947d:	83 c0 1c             	add    $0x1c,%eax
c0109480:	83 ec 04             	sub    $0x4,%esp
c0109483:	6a 20                	push   $0x20
c0109485:	6a 00                	push   $0x0
c0109487:	50                   	push   %eax
c0109488:	e8 cb 0c 00 00       	call   c010a158 <memset>
c010948d:	83 c4 10             	add    $0x10,%esp
       proc->tf = NULL;           // 中断帧指针为空
c0109490:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109493:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
       proc->cr3 = boot_cr3;       // 使用内核页目录表的基址
c010949a:	8b 15 dc ab 12 c0    	mov    0xc012abdc,%edx
c01094a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01094a3:	89 50 40             	mov    %edx,0x40(%eax)
       proc->flags = 0;            // flag为0
c01094a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01094a9:	c7 40 44 00 00 00 00 	movl   $0x0,0x44(%eax)
       memset(proc->name,0,PROC_NAME_LEN); // 进程名为0
c01094b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01094b3:	83 c0 48             	add    $0x48,%eax
c01094b6:	83 ec 04             	sub    $0x4,%esp
c01094b9:	6a 0f                	push   $0xf
c01094bb:	6a 00                	push   $0x0
c01094bd:	50                   	push   %eax
c01094be:	e8 95 0c 00 00       	call   c010a158 <memset>
c01094c3:	83 c4 10             	add    $0x10,%esp

    }
    return proc;
c01094c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01094c9:	c9                   	leave  
c01094ca:	c3                   	ret    

c01094cb <set_proc_name>:

// set_proc_name - set the name of proc
char *
set_proc_name(struct proc_struct *proc, const char *name) {
c01094cb:	55                   	push   %ebp
c01094cc:	89 e5                	mov    %esp,%ebp
c01094ce:	83 ec 08             	sub    $0x8,%esp
    memset(proc->name, 0, sizeof(proc->name));
c01094d1:	8b 45 08             	mov    0x8(%ebp),%eax
c01094d4:	83 c0 48             	add    $0x48,%eax
c01094d7:	83 ec 04             	sub    $0x4,%esp
c01094da:	6a 10                	push   $0x10
c01094dc:	6a 00                	push   $0x0
c01094de:	50                   	push   %eax
c01094df:	e8 74 0c 00 00       	call   c010a158 <memset>
c01094e4:	83 c4 10             	add    $0x10,%esp
    return memcpy(proc->name, name, PROC_NAME_LEN);
c01094e7:	8b 45 08             	mov    0x8(%ebp),%eax
c01094ea:	83 c0 48             	add    $0x48,%eax
c01094ed:	83 ec 04             	sub    $0x4,%esp
c01094f0:	6a 0f                	push   $0xf
c01094f2:	ff 75 0c             	pushl  0xc(%ebp)
c01094f5:	50                   	push   %eax
c01094f6:	e8 40 0d 00 00       	call   c010a23b <memcpy>
c01094fb:	83 c4 10             	add    $0x10,%esp
}
c01094fe:	c9                   	leave  
c01094ff:	c3                   	ret    

c0109500 <get_proc_name>:

// get_proc_name - get the name of proc
char *
get_proc_name(struct proc_struct *proc) {
c0109500:	55                   	push   %ebp
c0109501:	89 e5                	mov    %esp,%ebp
c0109503:	83 ec 08             	sub    $0x8,%esp
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
c0109506:	83 ec 04             	sub    $0x4,%esp
c0109509:	6a 10                	push   $0x10
c010950b:	6a 00                	push   $0x0
c010950d:	68 e4 aa 12 c0       	push   $0xc012aae4
c0109512:	e8 41 0c 00 00       	call   c010a158 <memset>
c0109517:	83 c4 10             	add    $0x10,%esp
    return memcpy(name, proc->name, PROC_NAME_LEN);
c010951a:	8b 45 08             	mov    0x8(%ebp),%eax
c010951d:	83 c0 48             	add    $0x48,%eax
c0109520:	83 ec 04             	sub    $0x4,%esp
c0109523:	6a 0f                	push   $0xf
c0109525:	50                   	push   %eax
c0109526:	68 e4 aa 12 c0       	push   $0xc012aae4
c010952b:	e8 0b 0d 00 00       	call   c010a23b <memcpy>
c0109530:	83 c4 10             	add    $0x10,%esp
}
c0109533:	c9                   	leave  
c0109534:	c3                   	ret    

c0109535 <get_pid>:

// get_pid - alloc a unique pid for process
static int
get_pid(void) {
c0109535:	55                   	push   %ebp
c0109536:	89 e5                	mov    %esp,%ebp
c0109538:	83 ec 10             	sub    $0x10,%esp
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
c010953b:	c7 45 f8 e4 ab 12 c0 	movl   $0xc012abe4,-0x8(%ebp)
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++ last_pid >= MAX_PID) {
c0109542:	a1 78 7a 12 c0       	mov    0xc0127a78,%eax
c0109547:	83 c0 01             	add    $0x1,%eax
c010954a:	a3 78 7a 12 c0       	mov    %eax,0xc0127a78
c010954f:	a1 78 7a 12 c0       	mov    0xc0127a78,%eax
c0109554:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c0109559:	7e 0c                	jle    c0109567 <get_pid+0x32>
        last_pid = 1;
c010955b:	c7 05 78 7a 12 c0 01 	movl   $0x1,0xc0127a78
c0109562:	00 00 00 
        goto inside;
c0109565:	eb 13                	jmp    c010957a <get_pid+0x45>
    }
    if (last_pid >= next_safe) {
c0109567:	8b 15 78 7a 12 c0    	mov    0xc0127a78,%edx
c010956d:	a1 7c 7a 12 c0       	mov    0xc0127a7c,%eax
c0109572:	39 c2                	cmp    %eax,%edx
c0109574:	0f 8c ac 00 00 00    	jl     c0109626 <get_pid+0xf1>
    inside:
        next_safe = MAX_PID;
c010957a:	c7 05 7c 7a 12 c0 00 	movl   $0x2000,0xc0127a7c
c0109581:	20 00 00 
    repeat:
        le = list;
c0109584:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109587:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while ((le = list_next(le)) != list) {
c010958a:	eb 7f                	jmp    c010960b <get_pid+0xd6>
            proc = le2proc(le, list_link);
c010958c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010958f:	83 e8 58             	sub    $0x58,%eax
c0109592:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (proc->pid == last_pid) {
c0109595:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109598:	8b 50 04             	mov    0x4(%eax),%edx
c010959b:	a1 78 7a 12 c0       	mov    0xc0127a78,%eax
c01095a0:	39 c2                	cmp    %eax,%edx
c01095a2:	75 3e                	jne    c01095e2 <get_pid+0xad>
                if (++ last_pid >= next_safe) {
c01095a4:	a1 78 7a 12 c0       	mov    0xc0127a78,%eax
c01095a9:	83 c0 01             	add    $0x1,%eax
c01095ac:	a3 78 7a 12 c0       	mov    %eax,0xc0127a78
c01095b1:	8b 15 78 7a 12 c0    	mov    0xc0127a78,%edx
c01095b7:	a1 7c 7a 12 c0       	mov    0xc0127a7c,%eax
c01095bc:	39 c2                	cmp    %eax,%edx
c01095be:	7c 4b                	jl     c010960b <get_pid+0xd6>
                    if (last_pid >= MAX_PID) {
c01095c0:	a1 78 7a 12 c0       	mov    0xc0127a78,%eax
c01095c5:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c01095ca:	7e 0a                	jle    c01095d6 <get_pid+0xa1>
                        last_pid = 1;
c01095cc:	c7 05 78 7a 12 c0 01 	movl   $0x1,0xc0127a78
c01095d3:	00 00 00 
                    }
                    next_safe = MAX_PID;
c01095d6:	c7 05 7c 7a 12 c0 00 	movl   $0x2000,0xc0127a7c
c01095dd:	20 00 00 
                    goto repeat;
c01095e0:	eb a2                	jmp    c0109584 <get_pid+0x4f>
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid) {
c01095e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095e5:	8b 50 04             	mov    0x4(%eax),%edx
c01095e8:	a1 78 7a 12 c0       	mov    0xc0127a78,%eax
c01095ed:	39 c2                	cmp    %eax,%edx
c01095ef:	7e 1a                	jle    c010960b <get_pid+0xd6>
c01095f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01095f4:	8b 50 04             	mov    0x4(%eax),%edx
c01095f7:	a1 7c 7a 12 c0       	mov    0xc0127a7c,%eax
c01095fc:	39 c2                	cmp    %eax,%edx
c01095fe:	7d 0b                	jge    c010960b <get_pid+0xd6>
                next_safe = proc->pid;
c0109600:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109603:	8b 40 04             	mov    0x4(%eax),%eax
c0109606:	a3 7c 7a 12 c0       	mov    %eax,0xc0127a7c
c010960b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010960e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109611:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109614:	8b 40 04             	mov    0x4(%eax),%eax
    if (last_pid >= next_safe) {
    inside:
        next_safe = MAX_PID;
    repeat:
        le = list;
        while ((le = list_next(le)) != list) {
c0109617:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010961a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010961d:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0109620:	0f 85 66 ff ff ff    	jne    c010958c <get_pid+0x57>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
                next_safe = proc->pid;
            }
        }
    }
    return last_pid;
c0109626:	a1 78 7a 12 c0       	mov    0xc0127a78,%eax
}
c010962b:	c9                   	leave  
c010962c:	c3                   	ret    

c010962d <proc_run>:

// proc_run - make process "proc" running on cpu
// NOTE: before call switch_to, should load  base addr of "proc"'s new PDT
void
proc_run(struct proc_struct *proc) {
c010962d:	55                   	push   %ebp
c010962e:	89 e5                	mov    %esp,%ebp
c0109630:	83 ec 18             	sub    $0x18,%esp
    if (proc != current) {
c0109633:	a1 c8 8a 12 c0       	mov    0xc0128ac8,%eax
c0109638:	39 45 08             	cmp    %eax,0x8(%ebp)
c010963b:	74 6b                	je     c01096a8 <proc_run+0x7b>
        bool intr_flag;
        struct proc_struct *prev = current, *next = proc;
c010963d:	a1 c8 8a 12 c0       	mov    0xc0128ac8,%eax
c0109642:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109645:	8b 45 08             	mov    0x8(%ebp),%eax
c0109648:	89 45 f0             	mov    %eax,-0x10(%ebp)
        local_intr_save(intr_flag);
c010964b:	e8 90 fc ff ff       	call   c01092e0 <__intr_save>
c0109650:	89 45 ec             	mov    %eax,-0x14(%ebp)
        {
            current = proc;
c0109653:	8b 45 08             	mov    0x8(%ebp),%eax
c0109656:	a3 c8 8a 12 c0       	mov    %eax,0xc0128ac8
            load_esp0(next->kstack + KSTACKSIZE);
c010965b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010965e:	8b 40 0c             	mov    0xc(%eax),%eax
c0109661:	05 00 20 00 00       	add    $0x2000,%eax
c0109666:	83 ec 0c             	sub    $0xc,%esp
c0109669:	50                   	push   %eax
c010966a:	e8 e2 e3 ff ff       	call   c0107a51 <load_esp0>
c010966f:	83 c4 10             	add    $0x10,%esp
            lcr3(next->cr3);
c0109672:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109675:	8b 40 40             	mov    0x40(%eax),%eax
c0109678:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("mov %0, %%cr0" :: "r" (cr0) : "memory");
}

static inline void
lcr3(uintptr_t cr3) {
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c010967b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010967e:	0f 22 d8             	mov    %eax,%cr3
            switch_to(&(prev->context), &(next->context));
c0109681:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109684:	8d 50 1c             	lea    0x1c(%eax),%edx
c0109687:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010968a:	83 c0 1c             	add    $0x1c,%eax
c010968d:	83 ec 08             	sub    $0x8,%esp
c0109690:	52                   	push   %edx
c0109691:	50                   	push   %eax
c0109692:	e8 09 fc ff ff       	call   c01092a0 <switch_to>
c0109697:	83 c4 10             	add    $0x10,%esp
        }
        local_intr_restore(intr_flag);
c010969a:	83 ec 0c             	sub    $0xc,%esp
c010969d:	ff 75 ec             	pushl  -0x14(%ebp)
c01096a0:	e8 65 fc ff ff       	call   c010930a <__intr_restore>
c01096a5:	83 c4 10             	add    $0x10,%esp
    }
}
c01096a8:	90                   	nop
c01096a9:	c9                   	leave  
c01096aa:	c3                   	ret    

c01096ab <forkret>:

// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
c01096ab:	55                   	push   %ebp
c01096ac:	89 e5                	mov    %esp,%ebp
c01096ae:	83 ec 08             	sub    $0x8,%esp
    forkrets(current->tf);
c01096b1:	a1 c8 8a 12 c0       	mov    0xc0128ac8,%eax
c01096b6:	8b 40 3c             	mov    0x3c(%eax),%eax
c01096b9:	83 ec 0c             	sub    $0xc,%esp
c01096bc:	50                   	push   %eax
c01096bd:	e8 45 ae ff ff       	call   c0104507 <forkrets>
c01096c2:	83 c4 10             	add    $0x10,%esp
}
c01096c5:	90                   	nop
c01096c6:	c9                   	leave  
c01096c7:	c3                   	ret    

c01096c8 <hash_proc>:

// hash_proc - add proc into proc hash_list
static void
hash_proc(struct proc_struct *proc) {
c01096c8:	55                   	push   %ebp
c01096c9:	89 e5                	mov    %esp,%ebp
c01096cb:	53                   	push   %ebx
c01096cc:	83 ec 24             	sub    $0x24,%esp
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
c01096cf:	8b 45 08             	mov    0x8(%ebp),%eax
c01096d2:	8d 58 60             	lea    0x60(%eax),%ebx
c01096d5:	8b 45 08             	mov    0x8(%ebp),%eax
c01096d8:	8b 40 04             	mov    0x4(%eax),%eax
c01096db:	83 ec 08             	sub    $0x8,%esp
c01096de:	6a 0a                	push   $0xa
c01096e0:	50                   	push   %eax
c01096e1:	e8 09 12 00 00       	call   c010a8ef <hash32>
c01096e6:	83 c4 10             	add    $0x10,%esp
c01096e9:	c1 e0 03             	shl    $0x3,%eax
c01096ec:	05 e0 8a 12 c0       	add    $0xc0128ae0,%eax
c01096f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01096f4:	89 5d f0             	mov    %ebx,-0x10(%ebp)
c01096f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01096fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01096fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109700:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0109703:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109706:	8b 40 04             	mov    0x4(%eax),%eax
c0109709:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010970c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010970f:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109712:	89 55 e0             	mov    %edx,-0x20(%ebp)
c0109715:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0109718:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010971b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010971e:	89 10                	mov    %edx,(%eax)
c0109720:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109723:	8b 10                	mov    (%eax),%edx
c0109725:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109728:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010972b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010972e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0109731:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0109734:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109737:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010973a:	89 10                	mov    %edx,(%eax)
}
c010973c:	90                   	nop
c010973d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0109740:	c9                   	leave  
c0109741:	c3                   	ret    

c0109742 <find_proc>:

// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid) {
c0109742:	55                   	push   %ebp
c0109743:	89 e5                	mov    %esp,%ebp
c0109745:	83 ec 18             	sub    $0x18,%esp
    if (0 < pid && pid < MAX_PID) {
c0109748:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010974c:	7e 5d                	jle    c01097ab <find_proc+0x69>
c010974e:	81 7d 08 ff 1f 00 00 	cmpl   $0x1fff,0x8(%ebp)
c0109755:	7f 54                	jg     c01097ab <find_proc+0x69>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
c0109757:	8b 45 08             	mov    0x8(%ebp),%eax
c010975a:	83 ec 08             	sub    $0x8,%esp
c010975d:	6a 0a                	push   $0xa
c010975f:	50                   	push   %eax
c0109760:	e8 8a 11 00 00       	call   c010a8ef <hash32>
c0109765:	83 c4 10             	add    $0x10,%esp
c0109768:	c1 e0 03             	shl    $0x3,%eax
c010976b:	05 e0 8a 12 c0       	add    $0xc0128ae0,%eax
c0109770:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109773:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109776:	89 45 f4             	mov    %eax,-0xc(%ebp)
        while ((le = list_next(le)) != list) {
c0109779:	eb 19                	jmp    c0109794 <find_proc+0x52>
            struct proc_struct *proc = le2proc(le, hash_link);
c010977b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010977e:	83 e8 60             	sub    $0x60,%eax
c0109781:	89 45 ec             	mov    %eax,-0x14(%ebp)
            if (proc->pid == pid) {
c0109784:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109787:	8b 40 04             	mov    0x4(%eax),%eax
c010978a:	3b 45 08             	cmp    0x8(%ebp),%eax
c010978d:	75 05                	jne    c0109794 <find_proc+0x52>
                return proc;
c010978f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109792:	eb 1c                	jmp    c01097b0 <find_proc+0x6e>
c0109794:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109797:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010979a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010979d:	8b 40 04             	mov    0x4(%eax),%eax
// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid) {
    if (0 < pid && pid < MAX_PID) {
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
        while ((le = list_next(le)) != list) {
c01097a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01097a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01097a6:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01097a9:	75 d0                	jne    c010977b <find_proc+0x39>
            if (proc->pid == pid) {
                return proc;
            }
        }
    }
    return NULL;
c01097ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01097b0:	c9                   	leave  
c01097b1:	c3                   	ret    

c01097b2 <kernel_thread>:

// kernel_thread - create a kernel thread using "fn" function
// NOTE: the contents of temp trapframe tf will be copied to 
//       proc->tf in do_fork-->copy_thread function
int
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
c01097b2:	55                   	push   %ebp
c01097b3:	89 e5                	mov    %esp,%ebp
c01097b5:	83 ec 58             	sub    $0x58,%esp
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));
c01097b8:	83 ec 04             	sub    $0x4,%esp
c01097bb:	6a 4c                	push   $0x4c
c01097bd:	6a 00                	push   $0x0
c01097bf:	8d 45 ac             	lea    -0x54(%ebp),%eax
c01097c2:	50                   	push   %eax
c01097c3:	e8 90 09 00 00       	call   c010a158 <memset>
c01097c8:	83 c4 10             	add    $0x10,%esp
    tf.tf_cs = KERNEL_CS;
c01097cb:	66 c7 45 e8 08 00    	movw   $0x8,-0x18(%ebp)
    tf.tf_ds = tf.tf_es = tf.tf_ss = KERNEL_DS;
c01097d1:	66 c7 45 f4 10 00    	movw   $0x10,-0xc(%ebp)
c01097d7:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c01097db:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
c01097df:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
c01097e3:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
    tf.tf_regs.reg_ebx = (uint32_t)fn;
c01097e7:	8b 45 08             	mov    0x8(%ebp),%eax
c01097ea:	89 45 bc             	mov    %eax,-0x44(%ebp)
    tf.tf_regs.reg_edx = (uint32_t)arg;
c01097ed:	8b 45 0c             	mov    0xc(%ebp),%eax
c01097f0:	89 45 c0             	mov    %eax,-0x40(%ebp)
    tf.tf_eip = (uint32_t)kernel_thread_entry;
c01097f3:	b8 d7 92 10 c0       	mov    $0xc01092d7,%eax
c01097f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
c01097fb:	8b 45 10             	mov    0x10(%ebp),%eax
c01097fe:	80 cc 01             	or     $0x1,%ah
c0109801:	89 c2                	mov    %eax,%edx
c0109803:	83 ec 04             	sub    $0x4,%esp
c0109806:	8d 45 ac             	lea    -0x54(%ebp),%eax
c0109809:	50                   	push   %eax
c010980a:	6a 00                	push   $0x0
c010980c:	52                   	push   %edx
c010980d:	e8 3c 01 00 00       	call   c010994e <do_fork>
c0109812:	83 c4 10             	add    $0x10,%esp
}
c0109815:	c9                   	leave  
c0109816:	c3                   	ret    

c0109817 <setup_kstack>:

// setup_kstack - alloc pages with size KSTACKPAGE as process kernel stack
static int
setup_kstack(struct proc_struct *proc) {
c0109817:	55                   	push   %ebp
c0109818:	89 e5                	mov    %esp,%ebp
c010981a:	83 ec 18             	sub    $0x18,%esp
    struct Page *page = alloc_pages(KSTACKPAGE);
c010981d:	83 ec 0c             	sub    $0xc,%esp
c0109820:	6a 02                	push   $0x2
c0109822:	e8 7e e3 ff ff       	call   c0107ba5 <alloc_pages>
c0109827:	83 c4 10             	add    $0x10,%esp
c010982a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c010982d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109831:	74 1d                	je     c0109850 <setup_kstack+0x39>
        proc->kstack = (uintptr_t)page2kva(page);
c0109833:	83 ec 0c             	sub    $0xc,%esp
c0109836:	ff 75 f4             	pushl  -0xc(%ebp)
c0109839:	e8 53 fb ff ff       	call   c0109391 <page2kva>
c010983e:	83 c4 10             	add    $0x10,%esp
c0109841:	89 c2                	mov    %eax,%edx
c0109843:	8b 45 08             	mov    0x8(%ebp),%eax
c0109846:	89 50 0c             	mov    %edx,0xc(%eax)
        return 0;
c0109849:	b8 00 00 00 00       	mov    $0x0,%eax
c010984e:	eb 05                	jmp    c0109855 <setup_kstack+0x3e>
    }
    return -E_NO_MEM;
c0109850:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
c0109855:	c9                   	leave  
c0109856:	c3                   	ret    

c0109857 <put_kstack>:

// put_kstack - free the memory space of process kernel stack
static void
put_kstack(struct proc_struct *proc) {
c0109857:	55                   	push   %ebp
c0109858:	89 e5                	mov    %esp,%ebp
c010985a:	83 ec 08             	sub    $0x8,%esp
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
c010985d:	8b 45 08             	mov    0x8(%ebp),%eax
c0109860:	8b 40 0c             	mov    0xc(%eax),%eax
c0109863:	83 ec 0c             	sub    $0xc,%esp
c0109866:	50                   	push   %eax
c0109867:	e8 6a fb ff ff       	call   c01093d6 <kva2page>
c010986c:	83 c4 10             	add    $0x10,%esp
c010986f:	83 ec 08             	sub    $0x8,%esp
c0109872:	6a 02                	push   $0x2
c0109874:	50                   	push   %eax
c0109875:	e8 97 e3 ff ff       	call   c0107c11 <free_pages>
c010987a:	83 c4 10             	add    $0x10,%esp
}
c010987d:	90                   	nop
c010987e:	c9                   	leave  
c010987f:	c3                   	ret    

c0109880 <copy_mm>:

// copy_mm - process "proc" duplicate OR share process "current"'s mm according clone_flags
//         - if clone_flags & CLONE_VM, then "share" ; else "duplicate"
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc) {
c0109880:	55                   	push   %ebp
c0109881:	89 e5                	mov    %esp,%ebp
c0109883:	83 ec 08             	sub    $0x8,%esp
    assert(current->mm == NULL);
c0109886:	a1 c8 8a 12 c0       	mov    0xc0128ac8,%eax
c010988b:	8b 40 18             	mov    0x18(%eax),%eax
c010988e:	85 c0                	test   %eax,%eax
c0109890:	74 19                	je     c01098ab <copy_mm+0x2b>
c0109892:	68 70 cb 10 c0       	push   $0xc010cb70
c0109897:	68 84 cb 10 c0       	push   $0xc010cb84
c010989c:	68 ef 00 00 00       	push   $0xef
c01098a1:	68 99 cb 10 c0       	push   $0xc010cb99
c01098a6:	e8 b1 7e ff ff       	call   c010175c <__panic>
    /* do nothing in this project */
    return 0;
c01098ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01098b0:	c9                   	leave  
c01098b1:	c3                   	ret    

c01098b2 <copy_thread>:

// copy_thread - setup the trapframe on the  process's kernel stack top and
//             - setup the kernel entry point and stack of process
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf) {
c01098b2:	55                   	push   %ebp
c01098b3:	89 e5                	mov    %esp,%ebp
c01098b5:	57                   	push   %edi
c01098b6:	56                   	push   %esi
c01098b7:	53                   	push   %ebx
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
c01098b8:	8b 45 08             	mov    0x8(%ebp),%eax
c01098bb:	8b 40 0c             	mov    0xc(%eax),%eax
c01098be:	05 b4 1f 00 00       	add    $0x1fb4,%eax
c01098c3:	89 c2                	mov    %eax,%edx
c01098c5:	8b 45 08             	mov    0x8(%ebp),%eax
c01098c8:	89 50 3c             	mov    %edx,0x3c(%eax)
    *(proc->tf) = *tf;
c01098cb:	8b 45 08             	mov    0x8(%ebp),%eax
c01098ce:	8b 40 3c             	mov    0x3c(%eax),%eax
c01098d1:	8b 55 10             	mov    0x10(%ebp),%edx
c01098d4:	89 d3                	mov    %edx,%ebx
c01098d6:	ba 4c 00 00 00       	mov    $0x4c,%edx
c01098db:	8b 0b                	mov    (%ebx),%ecx
c01098dd:	89 08                	mov    %ecx,(%eax)
c01098df:	8b 4c 13 fc          	mov    -0x4(%ebx,%edx,1),%ecx
c01098e3:	89 4c 10 fc          	mov    %ecx,-0x4(%eax,%edx,1)
c01098e7:	8d 78 04             	lea    0x4(%eax),%edi
c01098ea:	83 e7 fc             	and    $0xfffffffc,%edi
c01098ed:	29 f8                	sub    %edi,%eax
c01098ef:	29 c3                	sub    %eax,%ebx
c01098f1:	01 c2                	add    %eax,%edx
c01098f3:	83 e2 fc             	and    $0xfffffffc,%edx
c01098f6:	89 d0                	mov    %edx,%eax
c01098f8:	c1 e8 02             	shr    $0x2,%eax
c01098fb:	89 de                	mov    %ebx,%esi
c01098fd:	89 c1                	mov    %eax,%ecx
c01098ff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
    proc->tf->tf_regs.reg_eax = 0;
c0109901:	8b 45 08             	mov    0x8(%ebp),%eax
c0109904:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109907:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    proc->tf->tf_esp = esp;
c010990e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109911:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109914:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109917:	89 50 44             	mov    %edx,0x44(%eax)
    proc->tf->tf_eflags |= FL_IF;
c010991a:	8b 45 08             	mov    0x8(%ebp),%eax
c010991d:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109920:	8b 55 08             	mov    0x8(%ebp),%edx
c0109923:	8b 52 3c             	mov    0x3c(%edx),%edx
c0109926:	8b 52 40             	mov    0x40(%edx),%edx
c0109929:	80 ce 02             	or     $0x2,%dh
c010992c:	89 50 40             	mov    %edx,0x40(%eax)

    proc->context.eip = (uintptr_t)forkret;
c010992f:	ba ab 96 10 c0       	mov    $0xc01096ab,%edx
c0109934:	8b 45 08             	mov    0x8(%ebp),%eax
c0109937:	89 50 1c             	mov    %edx,0x1c(%eax)
    proc->context.esp = (uintptr_t)(proc->tf);
c010993a:	8b 45 08             	mov    0x8(%ebp),%eax
c010993d:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109940:	89 c2                	mov    %eax,%edx
c0109942:	8b 45 08             	mov    0x8(%ebp),%eax
c0109945:	89 50 20             	mov    %edx,0x20(%eax)
}
c0109948:	90                   	nop
c0109949:	5b                   	pop    %ebx
c010994a:	5e                   	pop    %esi
c010994b:	5f                   	pop    %edi
c010994c:	5d                   	pop    %ebp
c010994d:	c3                   	ret    

c010994e <do_fork>:
 * @clone_flags: used to guide how to clone the child process
 * @stack:       the parent's user stack pointer. if stack==0, It means to fork a kernel thread.
 * @tf:          the trapframe info, which will be copied to child process's proc->tf
 */
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
c010994e:	55                   	push   %ebp
c010994f:	89 e5                	mov    %esp,%ebp
c0109951:	83 ec 38             	sub    $0x38,%esp
    int ret = -E_NO_FREE_PROC;
c0109954:	c7 45 f4 fb ff ff ff 	movl   $0xfffffffb,-0xc(%ebp)
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
c010995b:	a1 e0 aa 12 c0       	mov    0xc012aae0,%eax
c0109960:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c0109965:	0f 8f 14 01 00 00    	jg     c0109a7f <do_fork+0x131>
        goto fork_out;
    }
    ret = -E_NO_MEM;
c010996b:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)
    //调用alloc_proc，首先获得一块用户信息块。
    if((proc = alloc_proc()) == NULL){
c0109972:	e8 9e fa ff ff       	call   c0109415 <alloc_proc>
c0109977:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010997a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010997e:	0f 84 fe 00 00 00    	je     c0109a82 <do_fork+0x134>
        goto fork_out; //返回
    }
    proc->parent = current; // 设置父进程名字
c0109984:	8b 15 c8 8a 12 c0    	mov    0xc0128ac8,%edx
c010998a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010998d:	89 50 14             	mov    %edx,0x14(%eax)
    // 为进程分配一个内核栈。
    if (setup_kstack(proc) !=0){ //申请一块2*PGSZIE内存用于进程堆栈
c0109990:	83 ec 0c             	sub    $0xc,%esp
c0109993:	ff 75 f0             	pushl  -0x10(%ebp)
c0109996:	e8 7c fe ff ff       	call   c0109817 <setup_kstack>
c010999b:	83 c4 10             	add    $0x10,%esp
c010999e:	85 c0                	test   %eax,%eax
c01099a0:	0f 85 f3 00 00 00    	jne    c0109a99 <do_fork+0x14b>
        goto bad_fork_cleanup_proc; // 返回
    }
    // 复制父进程的内存管理信息到子进程（但内核线程不必做此事）
    if (copy_mm(clone_flags,proc) != 0){
c01099a6:	83 ec 08             	sub    $0x8,%esp
c01099a9:	ff 75 f0             	pushl  -0x10(%ebp)
c01099ac:	ff 75 08             	pushl  0x8(%ebp)
c01099af:	e8 cc fe ff ff       	call   c0109880 <copy_mm>
c01099b4:	83 c4 10             	add    $0x10,%esp
c01099b7:	85 c0                	test   %eax,%eax
c01099b9:	0f 85 c9 00 00 00    	jne    c0109a88 <do_fork+0x13a>
        goto bad_fork_cleanup_kstack; // 返回
    }
    // 复制中断帧和原进程上下文到新进程
    copy_thread(proc,stack,tf);
c01099bf:	83 ec 04             	sub    $0x4,%esp
c01099c2:	ff 75 10             	pushl  0x10(%ebp)
c01099c5:	ff 75 0c             	pushl  0xc(%ebp)
c01099c8:	ff 75 f0             	pushl  -0x10(%ebp)
c01099cb:	e8 e2 fe ff ff       	call   c01098b2 <copy_thread>
c01099d0:	83 c4 10             	add    $0x10,%esp
    bool intr_flag;
    local_intr_save(intr_flag); // 禁止中断，intr_flag置为1
c01099d3:	e8 08 f9 ff ff       	call   c01092e0 <__intr_save>
c01099d8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    // 将新进程添加到进程列表
    {
        proc->pid = get_pid();
c01099db:	e8 55 fb ff ff       	call   c0109535 <get_pid>
c01099e0:	89 c2                	mov    %eax,%edx
c01099e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01099e5:	89 50 04             	mov    %edx,0x4(%eax)
        hash_proc(proc);
c01099e8:	83 ec 0c             	sub    $0xc,%esp
c01099eb:	ff 75 f0             	pushl  -0x10(%ebp)
c01099ee:	e8 d5 fc ff ff       	call   c01096c8 <hash_proc>
c01099f3:	83 c4 10             	add    $0x10,%esp
        list_add(&proc_list,&(proc->list_link));
c01099f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01099f9:	83 c0 58             	add    $0x58,%eax
c01099fc:	c7 45 e8 e4 ab 12 c0 	movl   $0xc012abe4,-0x18(%ebp)
c0109a03:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0109a06:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109a09:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0109a0c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109a0f:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0109a12:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109a15:	8b 40 04             	mov    0x4(%eax),%eax
c0109a18:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0109a1b:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0109a1e:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0109a21:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0109a24:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0109a27:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0109a2a:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0109a2d:	89 10                	mov    %edx,(%eax)
c0109a2f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0109a32:	8b 10                	mov    (%eax),%edx
c0109a34:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0109a37:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0109a3a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0109a3d:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0109a40:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0109a43:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0109a46:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0109a49:	89 10                	mov    %edx,(%eax)
        nr_process ++;
c0109a4b:	a1 e0 aa 12 c0       	mov    0xc012aae0,%eax
c0109a50:	83 c0 01             	add    $0x1,%eax
c0109a53:	a3 e0 aa 12 c0       	mov    %eax,0xc012aae0
    }
    local_intr_restore(intr_flag); // 恢复中断
c0109a58:	83 ec 0c             	sub    $0xc,%esp
c0109a5b:	ff 75 ec             	pushl  -0x14(%ebp)
c0109a5e:	e8 a7 f8 ff ff       	call   c010930a <__intr_restore>
c0109a63:	83 c4 10             	add    $0x10,%esp
    // 唤醒新进程
    wakeup_proc(proc);
c0109a66:	83 ec 0c             	sub    $0xc,%esp
c0109a69:	ff 75 f0             	pushl  -0x10(%ebp)
c0109a6c:	e8 ac 02 00 00       	call   c0109d1d <wakeup_proc>
c0109a71:	83 c4 10             	add    $0x10,%esp

    ret = proc->pid;
c0109a74:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109a77:	8b 40 04             	mov    0x4(%eax),%eax
c0109a7a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109a7d:	eb 04                	jmp    c0109a83 <do_fork+0x135>
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
    int ret = -E_NO_FREE_PROC;
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
        goto fork_out;
c0109a7f:	90                   	nop
c0109a80:	eb 01                	jmp    c0109a83 <do_fork+0x135>
    }
    ret = -E_NO_MEM;
    //调用alloc_proc，首先获得一块用户信息块。
    if((proc = alloc_proc()) == NULL){
        goto fork_out; //返回
c0109a82:	90                   	nop
    // 唤醒新进程
    wakeup_proc(proc);

    ret = proc->pid;
fork_out:
    return ret;
c0109a83:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109a86:	eb 22                	jmp    c0109aaa <do_fork+0x15c>
    if (setup_kstack(proc) !=0){ //申请一块2*PGSZIE内存用于进程堆栈
        goto bad_fork_cleanup_proc; // 返回
    }
    // 复制父进程的内存管理信息到子进程（但内核线程不必做此事）
    if (copy_mm(clone_flags,proc) != 0){
        goto bad_fork_cleanup_kstack; // 返回
c0109a88:	90                   	nop
    ret = proc->pid;
fork_out:
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
c0109a89:	83 ec 0c             	sub    $0xc,%esp
c0109a8c:	ff 75 f0             	pushl  -0x10(%ebp)
c0109a8f:	e8 c3 fd ff ff       	call   c0109857 <put_kstack>
c0109a94:	83 c4 10             	add    $0x10,%esp
c0109a97:	eb 01                	jmp    c0109a9a <do_fork+0x14c>
        goto fork_out; //返回
    }
    proc->parent = current; // 设置父进程名字
    // 为进程分配一个内核栈。
    if (setup_kstack(proc) !=0){ //申请一块2*PGSZIE内存用于进程堆栈
        goto bad_fork_cleanup_proc; // 返回
c0109a99:	90                   	nop
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
c0109a9a:	83 ec 0c             	sub    $0xc,%esp
c0109a9d:	ff 75 f0             	pushl  -0x10(%ebp)
c0109aa0:	e8 60 c7 ff ff       	call   c0106205 <kfree>
c0109aa5:	83 c4 10             	add    $0x10,%esp
    goto fork_out;
c0109aa8:	eb d9                	jmp    c0109a83 <do_fork+0x135>
}
c0109aaa:	c9                   	leave  
c0109aab:	c3                   	ret    

c0109aac <do_exit>:
// do_exit - called by sys_exit
//   1. call exit_mmap & put_pgdir & mm_destroy to free the almost all memory space of process
//   2. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
//   3. call scheduler to switch to other process
int
do_exit(int error_code) {
c0109aac:	55                   	push   %ebp
c0109aad:	89 e5                	mov    %esp,%ebp
c0109aaf:	83 ec 08             	sub    $0x8,%esp
    panic("process exit!!.\n");
c0109ab2:	83 ec 04             	sub    $0x4,%esp
c0109ab5:	68 ad cb 10 c0       	push   $0xc010cbad
c0109aba:	68 3c 01 00 00       	push   $0x13c
c0109abf:	68 99 cb 10 c0       	push   $0xc010cb99
c0109ac4:	e8 93 7c ff ff       	call   c010175c <__panic>

c0109ac9 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
c0109ac9:	55                   	push   %ebp
c0109aca:	89 e5                	mov    %esp,%ebp
c0109acc:	83 ec 08             	sub    $0x8,%esp
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
c0109acf:	a1 c8 8a 12 c0       	mov    0xc0128ac8,%eax
c0109ad4:	83 ec 0c             	sub    $0xc,%esp
c0109ad7:	50                   	push   %eax
c0109ad8:	e8 23 fa ff ff       	call   c0109500 <get_proc_name>
c0109add:	83 c4 10             	add    $0x10,%esp
c0109ae0:	89 c2                	mov    %eax,%edx
c0109ae2:	a1 c8 8a 12 c0       	mov    0xc0128ac8,%eax
c0109ae7:	8b 40 04             	mov    0x4(%eax),%eax
c0109aea:	83 ec 04             	sub    $0x4,%esp
c0109aed:	52                   	push   %edx
c0109aee:	50                   	push   %eax
c0109aef:	68 c0 cb 10 c0       	push   $0xc010cbc0
c0109af4:	e8 85 67 ff ff       	call   c010027e <cprintf>
c0109af9:	83 c4 10             	add    $0x10,%esp
    cprintf("To U: \"%s\".\n", (const char *)arg);
c0109afc:	83 ec 08             	sub    $0x8,%esp
c0109aff:	ff 75 08             	pushl  0x8(%ebp)
c0109b02:	68 e6 cb 10 c0       	push   $0xc010cbe6
c0109b07:	e8 72 67 ff ff       	call   c010027e <cprintf>
c0109b0c:	83 c4 10             	add    $0x10,%esp
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
c0109b0f:	83 ec 0c             	sub    $0xc,%esp
c0109b12:	68 f3 cb 10 c0       	push   $0xc010cbf3
c0109b17:	e8 62 67 ff ff       	call   c010027e <cprintf>
c0109b1c:	83 c4 10             	add    $0x10,%esp
    return 0;
c0109b1f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109b24:	c9                   	leave  
c0109b25:	c3                   	ret    

c0109b26 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
c0109b26:	55                   	push   %ebp
c0109b27:	89 e5                	mov    %esp,%ebp
c0109b29:	83 ec 18             	sub    $0x18,%esp
c0109b2c:	c7 45 e8 e4 ab 12 c0 	movl   $0xc012abe4,-0x18(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0109b33:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109b36:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0109b39:	89 50 04             	mov    %edx,0x4(%eax)
c0109b3c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109b3f:	8b 50 04             	mov    0x4(%eax),%edx
c0109b42:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109b45:	89 10                	mov    %edx,(%eax)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c0109b47:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0109b4e:	eb 26                	jmp    c0109b76 <proc_init+0x50>
        list_init(hash_list + i);
c0109b50:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109b53:	c1 e0 03             	shl    $0x3,%eax
c0109b56:	05 e0 8a 12 c0       	add    $0xc0128ae0,%eax
c0109b5b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109b5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109b61:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0109b64:	89 50 04             	mov    %edx,0x4(%eax)
c0109b67:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109b6a:	8b 50 04             	mov    0x4(%eax),%edx
c0109b6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109b70:	89 10                	mov    %edx,(%eax)
void
proc_init(void) {
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c0109b72:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0109b76:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
c0109b7d:	7e d1                	jle    c0109b50 <proc_init+0x2a>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
c0109b7f:	e8 91 f8 ff ff       	call   c0109415 <alloc_proc>
c0109b84:	a3 c0 8a 12 c0       	mov    %eax,0xc0128ac0
c0109b89:	a1 c0 8a 12 c0       	mov    0xc0128ac0,%eax
c0109b8e:	85 c0                	test   %eax,%eax
c0109b90:	75 17                	jne    c0109ba9 <proc_init+0x83>
        panic("cannot alloc idleproc.\n");
c0109b92:	83 ec 04             	sub    $0x4,%esp
c0109b95:	68 0f cc 10 c0       	push   $0xc010cc0f
c0109b9a:	68 54 01 00 00       	push   $0x154
c0109b9f:	68 99 cb 10 c0       	push   $0xc010cb99
c0109ba4:	e8 b3 7b ff ff       	call   c010175c <__panic>
    }

    idleproc->pid = 0;
c0109ba9:	a1 c0 8a 12 c0       	mov    0xc0128ac0,%eax
c0109bae:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    idleproc->state = PROC_RUNNABLE;
c0109bb5:	a1 c0 8a 12 c0       	mov    0xc0128ac0,%eax
c0109bba:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
    idleproc->kstack = (uintptr_t)bootstack;
c0109bc0:	a1 c0 8a 12 c0       	mov    0xc0128ac0,%eax
c0109bc5:	ba 00 50 12 c0       	mov    $0xc0125000,%edx
c0109bca:	89 50 0c             	mov    %edx,0xc(%eax)
    idleproc->need_resched = 1;
c0109bcd:	a1 c0 8a 12 c0       	mov    0xc0128ac0,%eax
c0109bd2:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    set_proc_name(idleproc, "idle");
c0109bd9:	a1 c0 8a 12 c0       	mov    0xc0128ac0,%eax
c0109bde:	83 ec 08             	sub    $0x8,%esp
c0109be1:	68 27 cc 10 c0       	push   $0xc010cc27
c0109be6:	50                   	push   %eax
c0109be7:	e8 df f8 ff ff       	call   c01094cb <set_proc_name>
c0109bec:	83 c4 10             	add    $0x10,%esp
    nr_process ++;
c0109bef:	a1 e0 aa 12 c0       	mov    0xc012aae0,%eax
c0109bf4:	83 c0 01             	add    $0x1,%eax
c0109bf7:	a3 e0 aa 12 c0       	mov    %eax,0xc012aae0

    current = idleproc;
c0109bfc:	a1 c0 8a 12 c0       	mov    0xc0128ac0,%eax
c0109c01:	a3 c8 8a 12 c0       	mov    %eax,0xc0128ac8

    int pid = kernel_thread(init_main, "Hello world!!", 0);
c0109c06:	83 ec 04             	sub    $0x4,%esp
c0109c09:	6a 00                	push   $0x0
c0109c0b:	68 2c cc 10 c0       	push   $0xc010cc2c
c0109c10:	68 c9 9a 10 c0       	push   $0xc0109ac9
c0109c15:	e8 98 fb ff ff       	call   c01097b2 <kernel_thread>
c0109c1a:	83 c4 10             	add    $0x10,%esp
c0109c1d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if (pid <= 0) {
c0109c20:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0109c24:	7f 17                	jg     c0109c3d <proc_init+0x117>
        panic("create init_main failed.\n");
c0109c26:	83 ec 04             	sub    $0x4,%esp
c0109c29:	68 3a cc 10 c0       	push   $0xc010cc3a
c0109c2e:	68 62 01 00 00       	push   $0x162
c0109c33:	68 99 cb 10 c0       	push   $0xc010cb99
c0109c38:	e8 1f 7b ff ff       	call   c010175c <__panic>
    }

    initproc = find_proc(pid);
c0109c3d:	83 ec 0c             	sub    $0xc,%esp
c0109c40:	ff 75 ec             	pushl  -0x14(%ebp)
c0109c43:	e8 fa fa ff ff       	call   c0109742 <find_proc>
c0109c48:	83 c4 10             	add    $0x10,%esp
c0109c4b:	a3 c4 8a 12 c0       	mov    %eax,0xc0128ac4
    set_proc_name(initproc, "init");
c0109c50:	a1 c4 8a 12 c0       	mov    0xc0128ac4,%eax
c0109c55:	83 ec 08             	sub    $0x8,%esp
c0109c58:	68 54 cc 10 c0       	push   $0xc010cc54
c0109c5d:	50                   	push   %eax
c0109c5e:	e8 68 f8 ff ff       	call   c01094cb <set_proc_name>
c0109c63:	83 c4 10             	add    $0x10,%esp

    assert(idleproc != NULL && idleproc->pid == 0);
c0109c66:	a1 c0 8a 12 c0       	mov    0xc0128ac0,%eax
c0109c6b:	85 c0                	test   %eax,%eax
c0109c6d:	74 0c                	je     c0109c7b <proc_init+0x155>
c0109c6f:	a1 c0 8a 12 c0       	mov    0xc0128ac0,%eax
c0109c74:	8b 40 04             	mov    0x4(%eax),%eax
c0109c77:	85 c0                	test   %eax,%eax
c0109c79:	74 19                	je     c0109c94 <proc_init+0x16e>
c0109c7b:	68 5c cc 10 c0       	push   $0xc010cc5c
c0109c80:	68 84 cb 10 c0       	push   $0xc010cb84
c0109c85:	68 68 01 00 00       	push   $0x168
c0109c8a:	68 99 cb 10 c0       	push   $0xc010cb99
c0109c8f:	e8 c8 7a ff ff       	call   c010175c <__panic>
    assert(initproc != NULL && initproc->pid == 1);
c0109c94:	a1 c4 8a 12 c0       	mov    0xc0128ac4,%eax
c0109c99:	85 c0                	test   %eax,%eax
c0109c9b:	74 0d                	je     c0109caa <proc_init+0x184>
c0109c9d:	a1 c4 8a 12 c0       	mov    0xc0128ac4,%eax
c0109ca2:	8b 40 04             	mov    0x4(%eax),%eax
c0109ca5:	83 f8 01             	cmp    $0x1,%eax
c0109ca8:	74 19                	je     c0109cc3 <proc_init+0x19d>
c0109caa:	68 84 cc 10 c0       	push   $0xc010cc84
c0109caf:	68 84 cb 10 c0       	push   $0xc010cb84
c0109cb4:	68 69 01 00 00       	push   $0x169
c0109cb9:	68 99 cb 10 c0       	push   $0xc010cb99
c0109cbe:	e8 99 7a ff ff       	call   c010175c <__panic>
}
c0109cc3:	90                   	nop
c0109cc4:	c9                   	leave  
c0109cc5:	c3                   	ret    

c0109cc6 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
c0109cc6:	55                   	push   %ebp
c0109cc7:	89 e5                	mov    %esp,%ebp
c0109cc9:	83 ec 08             	sub    $0x8,%esp
    while (1) {
        if (current->need_resched) {
c0109ccc:	a1 c8 8a 12 c0       	mov    0xc0128ac8,%eax
c0109cd1:	8b 40 10             	mov    0x10(%eax),%eax
c0109cd4:	85 c0                	test   %eax,%eax
c0109cd6:	74 f4                	je     c0109ccc <cpu_idle+0x6>
            schedule();
c0109cd8:	e8 7c 00 00 00       	call   c0109d59 <schedule>
        }
    }
c0109cdd:	eb ed                	jmp    c0109ccc <cpu_idle+0x6>

c0109cdf <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0109cdf:	55                   	push   %ebp
c0109ce0:	89 e5                	mov    %esp,%ebp
c0109ce2:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0109ce5:	9c                   	pushf  
c0109ce6:	58                   	pop    %eax
c0109ce7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0109cea:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0109ced:	25 00 02 00 00       	and    $0x200,%eax
c0109cf2:	85 c0                	test   %eax,%eax
c0109cf4:	74 0c                	je     c0109d02 <__intr_save+0x23>
        intr_disable();
c0109cf6:	e8 2d 97 ff ff       	call   c0103428 <intr_disable>
        return 1;
c0109cfb:	b8 01 00 00 00       	mov    $0x1,%eax
c0109d00:	eb 05                	jmp    c0109d07 <__intr_save+0x28>
    }
    return 0;
c0109d02:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109d07:	c9                   	leave  
c0109d08:	c3                   	ret    

c0109d09 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0109d09:	55                   	push   %ebp
c0109d0a:	89 e5                	mov    %esp,%ebp
c0109d0c:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0109d0f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109d13:	74 05                	je     c0109d1a <__intr_restore+0x11>
        intr_enable();
c0109d15:	e8 07 97 ff ff       	call   c0103421 <intr_enable>
    }
}
c0109d1a:	90                   	nop
c0109d1b:	c9                   	leave  
c0109d1c:	c3                   	ret    

c0109d1d <wakeup_proc>:
#include <proc.h>
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
c0109d1d:	55                   	push   %ebp
c0109d1e:	89 e5                	mov    %esp,%ebp
c0109d20:	83 ec 08             	sub    $0x8,%esp
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
c0109d23:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d26:	8b 00                	mov    (%eax),%eax
c0109d28:	83 f8 03             	cmp    $0x3,%eax
c0109d2b:	74 0a                	je     c0109d37 <wakeup_proc+0x1a>
c0109d2d:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d30:	8b 00                	mov    (%eax),%eax
c0109d32:	83 f8 02             	cmp    $0x2,%eax
c0109d35:	75 16                	jne    c0109d4d <wakeup_proc+0x30>
c0109d37:	68 ac cc 10 c0       	push   $0xc010ccac
c0109d3c:	68 e7 cc 10 c0       	push   $0xc010cce7
c0109d41:	6a 09                	push   $0x9
c0109d43:	68 fc cc 10 c0       	push   $0xc010ccfc
c0109d48:	e8 0f 7a ff ff       	call   c010175c <__panic>
    proc->state = PROC_RUNNABLE;
c0109d4d:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d50:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
}
c0109d56:	90                   	nop
c0109d57:	c9                   	leave  
c0109d58:	c3                   	ret    

c0109d59 <schedule>:

void
schedule(void) {
c0109d59:	55                   	push   %ebp
c0109d5a:	89 e5                	mov    %esp,%ebp
c0109d5c:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
c0109d5f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    local_intr_save(intr_flag);
c0109d66:	e8 74 ff ff ff       	call   c0109cdf <__intr_save>
c0109d6b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    {
        current->need_resched = 0;
c0109d6e:	a1 c8 8a 12 c0       	mov    0xc0128ac8,%eax
c0109d73:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
c0109d7a:	8b 15 c8 8a 12 c0    	mov    0xc0128ac8,%edx
c0109d80:	a1 c0 8a 12 c0       	mov    0xc0128ac0,%eax
c0109d85:	39 c2                	cmp    %eax,%edx
c0109d87:	74 0a                	je     c0109d93 <schedule+0x3a>
c0109d89:	a1 c8 8a 12 c0       	mov    0xc0128ac8,%eax
c0109d8e:	83 c0 58             	add    $0x58,%eax
c0109d91:	eb 05                	jmp    c0109d98 <schedule+0x3f>
c0109d93:	b8 e4 ab 12 c0       	mov    $0xc012abe4,%eax
c0109d98:	89 45 e8             	mov    %eax,-0x18(%ebp)
        le = last;
c0109d9b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109d9e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109da1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109da4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0109da7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109daa:	8b 40 04             	mov    0x4(%eax),%eax
        do {
            if ((le = list_next(le)) != &proc_list) {
c0109dad:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109db0:	81 7d f4 e4 ab 12 c0 	cmpl   $0xc012abe4,-0xc(%ebp)
c0109db7:	74 13                	je     c0109dcc <schedule+0x73>
                next = le2proc(le, list_link);
c0109db9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109dbc:	83 e8 58             	sub    $0x58,%eax
c0109dbf:	89 45 f0             	mov    %eax,-0x10(%ebp)
                if (next->state == PROC_RUNNABLE) {
c0109dc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109dc5:	8b 00                	mov    (%eax),%eax
c0109dc7:	83 f8 02             	cmp    $0x2,%eax
c0109dca:	74 0a                	je     c0109dd6 <schedule+0x7d>
                    break;
                }
            }
        } while (le != last);
c0109dcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109dcf:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c0109dd2:	75 cd                	jne    c0109da1 <schedule+0x48>
c0109dd4:	eb 01                	jmp    c0109dd7 <schedule+0x7e>
        le = last;
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
                    break;
c0109dd6:	90                   	nop
                }
            }
        } while (le != last);
        if (next == NULL || next->state != PROC_RUNNABLE) {
c0109dd7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0109ddb:	74 0a                	je     c0109de7 <schedule+0x8e>
c0109ddd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109de0:	8b 00                	mov    (%eax),%eax
c0109de2:	83 f8 02             	cmp    $0x2,%eax
c0109de5:	74 08                	je     c0109def <schedule+0x96>
            next = idleproc;
c0109de7:	a1 c0 8a 12 c0       	mov    0xc0128ac0,%eax
c0109dec:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        next->runs ++;
c0109def:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109df2:	8b 40 08             	mov    0x8(%eax),%eax
c0109df5:	8d 50 01             	lea    0x1(%eax),%edx
c0109df8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109dfb:	89 50 08             	mov    %edx,0x8(%eax)
        if (next != current) {
c0109dfe:	a1 c8 8a 12 c0       	mov    0xc0128ac8,%eax
c0109e03:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0109e06:	74 0e                	je     c0109e16 <schedule+0xbd>
            proc_run(next);
c0109e08:	83 ec 0c             	sub    $0xc,%esp
c0109e0b:	ff 75 f0             	pushl  -0x10(%ebp)
c0109e0e:	e8 1a f8 ff ff       	call   c010962d <proc_run>
c0109e13:	83 c4 10             	add    $0x10,%esp
        }
    }
    local_intr_restore(intr_flag);
c0109e16:	83 ec 0c             	sub    $0xc,%esp
c0109e19:	ff 75 ec             	pushl  -0x14(%ebp)
c0109e1c:	e8 e8 fe ff ff       	call   c0109d09 <__intr_restore>
c0109e21:	83 c4 10             	add    $0x10,%esp
}
c0109e24:	90                   	nop
c0109e25:	c9                   	leave  
c0109e26:	c3                   	ret    

c0109e27 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c0109e27:	55                   	push   %ebp
c0109e28:	89 e5                	mov    %esp,%ebp
c0109e2a:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0109e2d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c0109e34:	eb 04                	jmp    c0109e3a <strlen+0x13>
        cnt ++;
c0109e36:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
c0109e3a:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e3d:	8d 50 01             	lea    0x1(%eax),%edx
c0109e40:	89 55 08             	mov    %edx,0x8(%ebp)
c0109e43:	0f b6 00             	movzbl (%eax),%eax
c0109e46:	84 c0                	test   %al,%al
c0109e48:	75 ec                	jne    c0109e36 <strlen+0xf>
        cnt ++;
    }
    return cnt;
c0109e4a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0109e4d:	c9                   	leave  
c0109e4e:	c3                   	ret    

c0109e4f <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c0109e4f:	55                   	push   %ebp
c0109e50:	89 e5                	mov    %esp,%ebp
c0109e52:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0109e55:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0109e5c:	eb 04                	jmp    c0109e62 <strnlen+0x13>
        cnt ++;
c0109e5e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
c0109e62:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109e65:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0109e68:	73 10                	jae    c0109e7a <strnlen+0x2b>
c0109e6a:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e6d:	8d 50 01             	lea    0x1(%eax),%edx
c0109e70:	89 55 08             	mov    %edx,0x8(%ebp)
c0109e73:	0f b6 00             	movzbl (%eax),%eax
c0109e76:	84 c0                	test   %al,%al
c0109e78:	75 e4                	jne    c0109e5e <strnlen+0xf>
        cnt ++;
    }
    return cnt;
c0109e7a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0109e7d:	c9                   	leave  
c0109e7e:	c3                   	ret    

c0109e7f <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c0109e7f:	55                   	push   %ebp
c0109e80:	89 e5                	mov    %esp,%ebp
c0109e82:	57                   	push   %edi
c0109e83:	56                   	push   %esi
c0109e84:	83 ec 20             	sub    $0x20,%esp
c0109e87:	8b 45 08             	mov    0x8(%ebp),%eax
c0109e8a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109e8d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109e90:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c0109e93:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0109e96:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109e99:	89 d1                	mov    %edx,%ecx
c0109e9b:	89 c2                	mov    %eax,%edx
c0109e9d:	89 ce                	mov    %ecx,%esi
c0109e9f:	89 d7                	mov    %edx,%edi
c0109ea1:	ac                   	lods   %ds:(%esi),%al
c0109ea2:	aa                   	stos   %al,%es:(%edi)
c0109ea3:	84 c0                	test   %al,%al
c0109ea5:	75 fa                	jne    c0109ea1 <strcpy+0x22>
c0109ea7:	89 fa                	mov    %edi,%edx
c0109ea9:	89 f1                	mov    %esi,%ecx
c0109eab:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0109eae:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0109eb1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c0109eb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
c0109eb7:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c0109eb8:	83 c4 20             	add    $0x20,%esp
c0109ebb:	5e                   	pop    %esi
c0109ebc:	5f                   	pop    %edi
c0109ebd:	5d                   	pop    %ebp
c0109ebe:	c3                   	ret    

c0109ebf <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c0109ebf:	55                   	push   %ebp
c0109ec0:	89 e5                	mov    %esp,%ebp
c0109ec2:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c0109ec5:	8b 45 08             	mov    0x8(%ebp),%eax
c0109ec8:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0109ecb:	eb 21                	jmp    c0109eee <strncpy+0x2f>
        if ((*p = *src) != '\0') {
c0109ecd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109ed0:	0f b6 10             	movzbl (%eax),%edx
c0109ed3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109ed6:	88 10                	mov    %dl,(%eax)
c0109ed8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109edb:	0f b6 00             	movzbl (%eax),%eax
c0109ede:	84 c0                	test   %al,%al
c0109ee0:	74 04                	je     c0109ee6 <strncpy+0x27>
            src ++;
c0109ee2:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
c0109ee6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0109eea:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
c0109eee:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0109ef2:	75 d9                	jne    c0109ecd <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
c0109ef4:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0109ef7:	c9                   	leave  
c0109ef8:	c3                   	ret    

c0109ef9 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c0109ef9:	55                   	push   %ebp
c0109efa:	89 e5                	mov    %esp,%ebp
c0109efc:	57                   	push   %edi
c0109efd:	56                   	push   %esi
c0109efe:	83 ec 20             	sub    $0x20,%esp
c0109f01:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f04:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109f07:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109f0a:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
c0109f0d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109f10:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109f13:	89 d1                	mov    %edx,%ecx
c0109f15:	89 c2                	mov    %eax,%edx
c0109f17:	89 ce                	mov    %ecx,%esi
c0109f19:	89 d7                	mov    %edx,%edi
c0109f1b:	ac                   	lods   %ds:(%esi),%al
c0109f1c:	ae                   	scas   %es:(%edi),%al
c0109f1d:	75 08                	jne    c0109f27 <strcmp+0x2e>
c0109f1f:	84 c0                	test   %al,%al
c0109f21:	75 f8                	jne    c0109f1b <strcmp+0x22>
c0109f23:	31 c0                	xor    %eax,%eax
c0109f25:	eb 04                	jmp    c0109f2b <strcmp+0x32>
c0109f27:	19 c0                	sbb    %eax,%eax
c0109f29:	0c 01                	or     $0x1,%al
c0109f2b:	89 fa                	mov    %edi,%edx
c0109f2d:	89 f1                	mov    %esi,%ecx
c0109f2f:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109f32:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0109f35:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
c0109f38:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
c0109f3b:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c0109f3c:	83 c4 20             	add    $0x20,%esp
c0109f3f:	5e                   	pop    %esi
c0109f40:	5f                   	pop    %edi
c0109f41:	5d                   	pop    %ebp
c0109f42:	c3                   	ret    

c0109f43 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c0109f43:	55                   	push   %ebp
c0109f44:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0109f46:	eb 0c                	jmp    c0109f54 <strncmp+0x11>
        n --, s1 ++, s2 ++;
c0109f48:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0109f4c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0109f50:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0109f54:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0109f58:	74 1a                	je     c0109f74 <strncmp+0x31>
c0109f5a:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f5d:	0f b6 00             	movzbl (%eax),%eax
c0109f60:	84 c0                	test   %al,%al
c0109f62:	74 10                	je     c0109f74 <strncmp+0x31>
c0109f64:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f67:	0f b6 10             	movzbl (%eax),%edx
c0109f6a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109f6d:	0f b6 00             	movzbl (%eax),%eax
c0109f70:	38 c2                	cmp    %al,%dl
c0109f72:	74 d4                	je     c0109f48 <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c0109f74:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0109f78:	74 18                	je     c0109f92 <strncmp+0x4f>
c0109f7a:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f7d:	0f b6 00             	movzbl (%eax),%eax
c0109f80:	0f b6 d0             	movzbl %al,%edx
c0109f83:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109f86:	0f b6 00             	movzbl (%eax),%eax
c0109f89:	0f b6 c0             	movzbl %al,%eax
c0109f8c:	29 c2                	sub    %eax,%edx
c0109f8e:	89 d0                	mov    %edx,%eax
c0109f90:	eb 05                	jmp    c0109f97 <strncmp+0x54>
c0109f92:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109f97:	5d                   	pop    %ebp
c0109f98:	c3                   	ret    

c0109f99 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0109f99:	55                   	push   %ebp
c0109f9a:	89 e5                	mov    %esp,%ebp
c0109f9c:	83 ec 04             	sub    $0x4,%esp
c0109f9f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109fa2:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0109fa5:	eb 14                	jmp    c0109fbb <strchr+0x22>
        if (*s == c) {
c0109fa7:	8b 45 08             	mov    0x8(%ebp),%eax
c0109faa:	0f b6 00             	movzbl (%eax),%eax
c0109fad:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0109fb0:	75 05                	jne    c0109fb7 <strchr+0x1e>
            return (char *)s;
c0109fb2:	8b 45 08             	mov    0x8(%ebp),%eax
c0109fb5:	eb 13                	jmp    c0109fca <strchr+0x31>
        }
        s ++;
c0109fb7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
c0109fbb:	8b 45 08             	mov    0x8(%ebp),%eax
c0109fbe:	0f b6 00             	movzbl (%eax),%eax
c0109fc1:	84 c0                	test   %al,%al
c0109fc3:	75 e2                	jne    c0109fa7 <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
c0109fc5:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109fca:	c9                   	leave  
c0109fcb:	c3                   	ret    

c0109fcc <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0109fcc:	55                   	push   %ebp
c0109fcd:	89 e5                	mov    %esp,%ebp
c0109fcf:	83 ec 04             	sub    $0x4,%esp
c0109fd2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109fd5:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0109fd8:	eb 0f                	jmp    c0109fe9 <strfind+0x1d>
        if (*s == c) {
c0109fda:	8b 45 08             	mov    0x8(%ebp),%eax
c0109fdd:	0f b6 00             	movzbl (%eax),%eax
c0109fe0:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0109fe3:	74 10                	je     c0109ff5 <strfind+0x29>
            break;
        }
        s ++;
c0109fe5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
c0109fe9:	8b 45 08             	mov    0x8(%ebp),%eax
c0109fec:	0f b6 00             	movzbl (%eax),%eax
c0109fef:	84 c0                	test   %al,%al
c0109ff1:	75 e7                	jne    c0109fda <strfind+0xe>
c0109ff3:	eb 01                	jmp    c0109ff6 <strfind+0x2a>
        if (*s == c) {
            break;
c0109ff5:	90                   	nop
        }
        s ++;
    }
    return (char *)s;
c0109ff6:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0109ff9:	c9                   	leave  
c0109ffa:	c3                   	ret    

c0109ffb <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0109ffb:	55                   	push   %ebp
c0109ffc:	89 e5                	mov    %esp,%ebp
c0109ffe:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c010a001:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c010a008:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c010a00f:	eb 04                	jmp    c010a015 <strtol+0x1a>
        s ++;
c010a011:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c010a015:	8b 45 08             	mov    0x8(%ebp),%eax
c010a018:	0f b6 00             	movzbl (%eax),%eax
c010a01b:	3c 20                	cmp    $0x20,%al
c010a01d:	74 f2                	je     c010a011 <strtol+0x16>
c010a01f:	8b 45 08             	mov    0x8(%ebp),%eax
c010a022:	0f b6 00             	movzbl (%eax),%eax
c010a025:	3c 09                	cmp    $0x9,%al
c010a027:	74 e8                	je     c010a011 <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
c010a029:	8b 45 08             	mov    0x8(%ebp),%eax
c010a02c:	0f b6 00             	movzbl (%eax),%eax
c010a02f:	3c 2b                	cmp    $0x2b,%al
c010a031:	75 06                	jne    c010a039 <strtol+0x3e>
        s ++;
c010a033:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010a037:	eb 15                	jmp    c010a04e <strtol+0x53>
    }
    else if (*s == '-') {
c010a039:	8b 45 08             	mov    0x8(%ebp),%eax
c010a03c:	0f b6 00             	movzbl (%eax),%eax
c010a03f:	3c 2d                	cmp    $0x2d,%al
c010a041:	75 0b                	jne    c010a04e <strtol+0x53>
        s ++, neg = 1;
c010a043:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010a047:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c010a04e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010a052:	74 06                	je     c010a05a <strtol+0x5f>
c010a054:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c010a058:	75 24                	jne    c010a07e <strtol+0x83>
c010a05a:	8b 45 08             	mov    0x8(%ebp),%eax
c010a05d:	0f b6 00             	movzbl (%eax),%eax
c010a060:	3c 30                	cmp    $0x30,%al
c010a062:	75 1a                	jne    c010a07e <strtol+0x83>
c010a064:	8b 45 08             	mov    0x8(%ebp),%eax
c010a067:	83 c0 01             	add    $0x1,%eax
c010a06a:	0f b6 00             	movzbl (%eax),%eax
c010a06d:	3c 78                	cmp    $0x78,%al
c010a06f:	75 0d                	jne    c010a07e <strtol+0x83>
        s += 2, base = 16;
c010a071:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c010a075:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c010a07c:	eb 2a                	jmp    c010a0a8 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
c010a07e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010a082:	75 17                	jne    c010a09b <strtol+0xa0>
c010a084:	8b 45 08             	mov    0x8(%ebp),%eax
c010a087:	0f b6 00             	movzbl (%eax),%eax
c010a08a:	3c 30                	cmp    $0x30,%al
c010a08c:	75 0d                	jne    c010a09b <strtol+0xa0>
        s ++, base = 8;
c010a08e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010a092:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c010a099:	eb 0d                	jmp    c010a0a8 <strtol+0xad>
    }
    else if (base == 0) {
c010a09b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010a09f:	75 07                	jne    c010a0a8 <strtol+0xad>
        base = 10;
c010a0a1:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c010a0a8:	8b 45 08             	mov    0x8(%ebp),%eax
c010a0ab:	0f b6 00             	movzbl (%eax),%eax
c010a0ae:	3c 2f                	cmp    $0x2f,%al
c010a0b0:	7e 1b                	jle    c010a0cd <strtol+0xd2>
c010a0b2:	8b 45 08             	mov    0x8(%ebp),%eax
c010a0b5:	0f b6 00             	movzbl (%eax),%eax
c010a0b8:	3c 39                	cmp    $0x39,%al
c010a0ba:	7f 11                	jg     c010a0cd <strtol+0xd2>
            dig = *s - '0';
c010a0bc:	8b 45 08             	mov    0x8(%ebp),%eax
c010a0bf:	0f b6 00             	movzbl (%eax),%eax
c010a0c2:	0f be c0             	movsbl %al,%eax
c010a0c5:	83 e8 30             	sub    $0x30,%eax
c010a0c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a0cb:	eb 48                	jmp    c010a115 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
c010a0cd:	8b 45 08             	mov    0x8(%ebp),%eax
c010a0d0:	0f b6 00             	movzbl (%eax),%eax
c010a0d3:	3c 60                	cmp    $0x60,%al
c010a0d5:	7e 1b                	jle    c010a0f2 <strtol+0xf7>
c010a0d7:	8b 45 08             	mov    0x8(%ebp),%eax
c010a0da:	0f b6 00             	movzbl (%eax),%eax
c010a0dd:	3c 7a                	cmp    $0x7a,%al
c010a0df:	7f 11                	jg     c010a0f2 <strtol+0xf7>
            dig = *s - 'a' + 10;
c010a0e1:	8b 45 08             	mov    0x8(%ebp),%eax
c010a0e4:	0f b6 00             	movzbl (%eax),%eax
c010a0e7:	0f be c0             	movsbl %al,%eax
c010a0ea:	83 e8 57             	sub    $0x57,%eax
c010a0ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a0f0:	eb 23                	jmp    c010a115 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c010a0f2:	8b 45 08             	mov    0x8(%ebp),%eax
c010a0f5:	0f b6 00             	movzbl (%eax),%eax
c010a0f8:	3c 40                	cmp    $0x40,%al
c010a0fa:	7e 3c                	jle    c010a138 <strtol+0x13d>
c010a0fc:	8b 45 08             	mov    0x8(%ebp),%eax
c010a0ff:	0f b6 00             	movzbl (%eax),%eax
c010a102:	3c 5a                	cmp    $0x5a,%al
c010a104:	7f 32                	jg     c010a138 <strtol+0x13d>
            dig = *s - 'A' + 10;
c010a106:	8b 45 08             	mov    0x8(%ebp),%eax
c010a109:	0f b6 00             	movzbl (%eax),%eax
c010a10c:	0f be c0             	movsbl %al,%eax
c010a10f:	83 e8 37             	sub    $0x37,%eax
c010a112:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c010a115:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a118:	3b 45 10             	cmp    0x10(%ebp),%eax
c010a11b:	7d 1a                	jge    c010a137 <strtol+0x13c>
            break;
        }
        s ++, val = (val * base) + dig;
c010a11d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010a121:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010a124:	0f af 45 10          	imul   0x10(%ebp),%eax
c010a128:	89 c2                	mov    %eax,%edx
c010a12a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a12d:	01 d0                	add    %edx,%eax
c010a12f:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
c010a132:	e9 71 ff ff ff       	jmp    c010a0a8 <strtol+0xad>
        }
        else {
            break;
        }
        if (dig >= base) {
            break;
c010a137:	90                   	nop
        }
        s ++, val = (val * base) + dig;
        // we don't properly detect overflow!
    }

    if (endptr) {
c010a138:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010a13c:	74 08                	je     c010a146 <strtol+0x14b>
        *endptr = (char *) s;
c010a13e:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a141:	8b 55 08             	mov    0x8(%ebp),%edx
c010a144:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c010a146:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010a14a:	74 07                	je     c010a153 <strtol+0x158>
c010a14c:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010a14f:	f7 d8                	neg    %eax
c010a151:	eb 03                	jmp    c010a156 <strtol+0x15b>
c010a153:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c010a156:	c9                   	leave  
c010a157:	c3                   	ret    

c010a158 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c010a158:	55                   	push   %ebp
c010a159:	89 e5                	mov    %esp,%ebp
c010a15b:	57                   	push   %edi
c010a15c:	83 ec 24             	sub    $0x24,%esp
c010a15f:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a162:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c010a165:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c010a169:	8b 55 08             	mov    0x8(%ebp),%edx
c010a16c:	89 55 f8             	mov    %edx,-0x8(%ebp)
c010a16f:	88 45 f7             	mov    %al,-0x9(%ebp)
c010a172:	8b 45 10             	mov    0x10(%ebp),%eax
c010a175:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c010a178:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c010a17b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c010a17f:	8b 55 f8             	mov    -0x8(%ebp),%edx
c010a182:	89 d7                	mov    %edx,%edi
c010a184:	f3 aa                	rep stos %al,%es:(%edi)
c010a186:	89 fa                	mov    %edi,%edx
c010a188:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010a18b:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c010a18e:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010a191:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c010a192:	83 c4 24             	add    $0x24,%esp
c010a195:	5f                   	pop    %edi
c010a196:	5d                   	pop    %ebp
c010a197:	c3                   	ret    

c010a198 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c010a198:	55                   	push   %ebp
c010a199:	89 e5                	mov    %esp,%ebp
c010a19b:	57                   	push   %edi
c010a19c:	56                   	push   %esi
c010a19d:	53                   	push   %ebx
c010a19e:	83 ec 30             	sub    $0x30,%esp
c010a1a1:	8b 45 08             	mov    0x8(%ebp),%eax
c010a1a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a1a7:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a1aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010a1ad:	8b 45 10             	mov    0x10(%ebp),%eax
c010a1b0:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c010a1b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a1b6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010a1b9:	73 42                	jae    c010a1fd <memmove+0x65>
c010a1bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a1be:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010a1c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a1c4:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010a1c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a1ca:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010a1cd:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a1d0:	c1 e8 02             	shr    $0x2,%eax
c010a1d3:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c010a1d5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010a1d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010a1db:	89 d7                	mov    %edx,%edi
c010a1dd:	89 c6                	mov    %eax,%esi
c010a1df:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010a1e1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c010a1e4:	83 e1 03             	and    $0x3,%ecx
c010a1e7:	74 02                	je     c010a1eb <memmove+0x53>
c010a1e9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010a1eb:	89 f0                	mov    %esi,%eax
c010a1ed:	89 fa                	mov    %edi,%edx
c010a1ef:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c010a1f2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010a1f5:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c010a1f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
c010a1fb:	eb 36                	jmp    c010a233 <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c010a1fd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a200:	8d 50 ff             	lea    -0x1(%eax),%edx
c010a203:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a206:	01 c2                	add    %eax,%edx
c010a208:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a20b:	8d 48 ff             	lea    -0x1(%eax),%ecx
c010a20e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a211:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
c010a214:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a217:	89 c1                	mov    %eax,%ecx
c010a219:	89 d8                	mov    %ebx,%eax
c010a21b:	89 d6                	mov    %edx,%esi
c010a21d:	89 c7                	mov    %eax,%edi
c010a21f:	fd                   	std    
c010a220:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010a222:	fc                   	cld    
c010a223:	89 f8                	mov    %edi,%eax
c010a225:	89 f2                	mov    %esi,%edx
c010a227:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c010a22a:	89 55 c8             	mov    %edx,-0x38(%ebp)
c010a22d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
c010a230:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c010a233:	83 c4 30             	add    $0x30,%esp
c010a236:	5b                   	pop    %ebx
c010a237:	5e                   	pop    %esi
c010a238:	5f                   	pop    %edi
c010a239:	5d                   	pop    %ebp
c010a23a:	c3                   	ret    

c010a23b <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c010a23b:	55                   	push   %ebp
c010a23c:	89 e5                	mov    %esp,%ebp
c010a23e:	57                   	push   %edi
c010a23f:	56                   	push   %esi
c010a240:	83 ec 20             	sub    $0x20,%esp
c010a243:	8b 45 08             	mov    0x8(%ebp),%eax
c010a246:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a249:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a24c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a24f:	8b 45 10             	mov    0x10(%ebp),%eax
c010a252:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010a255:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a258:	c1 e8 02             	shr    $0x2,%eax
c010a25b:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c010a25d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010a260:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a263:	89 d7                	mov    %edx,%edi
c010a265:	89 c6                	mov    %eax,%esi
c010a267:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010a269:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c010a26c:	83 e1 03             	and    $0x3,%ecx
c010a26f:	74 02                	je     c010a273 <memcpy+0x38>
c010a271:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010a273:	89 f0                	mov    %esi,%eax
c010a275:	89 fa                	mov    %edi,%edx
c010a277:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010a27a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010a27d:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c010a280:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
c010a283:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c010a284:	83 c4 20             	add    $0x20,%esp
c010a287:	5e                   	pop    %esi
c010a288:	5f                   	pop    %edi
c010a289:	5d                   	pop    %ebp
c010a28a:	c3                   	ret    

c010a28b <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c010a28b:	55                   	push   %ebp
c010a28c:	89 e5                	mov    %esp,%ebp
c010a28e:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c010a291:	8b 45 08             	mov    0x8(%ebp),%eax
c010a294:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c010a297:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a29a:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c010a29d:	eb 30                	jmp    c010a2cf <memcmp+0x44>
        if (*s1 != *s2) {
c010a29f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010a2a2:	0f b6 10             	movzbl (%eax),%edx
c010a2a5:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010a2a8:	0f b6 00             	movzbl (%eax),%eax
c010a2ab:	38 c2                	cmp    %al,%dl
c010a2ad:	74 18                	je     c010a2c7 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c010a2af:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010a2b2:	0f b6 00             	movzbl (%eax),%eax
c010a2b5:	0f b6 d0             	movzbl %al,%edx
c010a2b8:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010a2bb:	0f b6 00             	movzbl (%eax),%eax
c010a2be:	0f b6 c0             	movzbl %al,%eax
c010a2c1:	29 c2                	sub    %eax,%edx
c010a2c3:	89 d0                	mov    %edx,%eax
c010a2c5:	eb 1a                	jmp    c010a2e1 <memcmp+0x56>
        }
        s1 ++, s2 ++;
c010a2c7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010a2cb:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
c010a2cf:	8b 45 10             	mov    0x10(%ebp),%eax
c010a2d2:	8d 50 ff             	lea    -0x1(%eax),%edx
c010a2d5:	89 55 10             	mov    %edx,0x10(%ebp)
c010a2d8:	85 c0                	test   %eax,%eax
c010a2da:	75 c3                	jne    c010a29f <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
c010a2dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010a2e1:	c9                   	leave  
c010a2e2:	c3                   	ret    

c010a2e3 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c010a2e3:	55                   	push   %ebp
c010a2e4:	89 e5                	mov    %esp,%ebp
c010a2e6:	83 ec 38             	sub    $0x38,%esp
c010a2e9:	8b 45 10             	mov    0x10(%ebp),%eax
c010a2ec:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010a2ef:	8b 45 14             	mov    0x14(%ebp),%eax
c010a2f2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c010a2f5:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a2f8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010a2fb:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010a2fe:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c010a301:	8b 45 18             	mov    0x18(%ebp),%eax
c010a304:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010a307:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a30a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a30d:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010a310:	89 55 f0             	mov    %edx,-0x10(%ebp)
c010a313:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a316:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a319:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a31d:	74 1c                	je     c010a33b <printnum+0x58>
c010a31f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a322:	ba 00 00 00 00       	mov    $0x0,%edx
c010a327:	f7 75 e4             	divl   -0x1c(%ebp)
c010a32a:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010a32d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a330:	ba 00 00 00 00       	mov    $0x0,%edx
c010a335:	f7 75 e4             	divl   -0x1c(%ebp)
c010a338:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a33b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010a33e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010a341:	f7 75 e4             	divl   -0x1c(%ebp)
c010a344:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010a347:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010a34a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010a34d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010a350:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010a353:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010a356:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a359:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c010a35c:	8b 45 18             	mov    0x18(%ebp),%eax
c010a35f:	ba 00 00 00 00       	mov    $0x0,%edx
c010a364:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010a367:	77 41                	ja     c010a3aa <printnum+0xc7>
c010a369:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010a36c:	72 05                	jb     c010a373 <printnum+0x90>
c010a36e:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c010a371:	77 37                	ja     c010a3aa <printnum+0xc7>
        printnum(putch, putdat, result, base, width - 1, padc);
c010a373:	8b 45 1c             	mov    0x1c(%ebp),%eax
c010a376:	83 e8 01             	sub    $0x1,%eax
c010a379:	83 ec 04             	sub    $0x4,%esp
c010a37c:	ff 75 20             	pushl  0x20(%ebp)
c010a37f:	50                   	push   %eax
c010a380:	ff 75 18             	pushl  0x18(%ebp)
c010a383:	ff 75 ec             	pushl  -0x14(%ebp)
c010a386:	ff 75 e8             	pushl  -0x18(%ebp)
c010a389:	ff 75 0c             	pushl  0xc(%ebp)
c010a38c:	ff 75 08             	pushl  0x8(%ebp)
c010a38f:	e8 4f ff ff ff       	call   c010a2e3 <printnum>
c010a394:	83 c4 20             	add    $0x20,%esp
c010a397:	eb 1b                	jmp    c010a3b4 <printnum+0xd1>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c010a399:	83 ec 08             	sub    $0x8,%esp
c010a39c:	ff 75 0c             	pushl  0xc(%ebp)
c010a39f:	ff 75 20             	pushl  0x20(%ebp)
c010a3a2:	8b 45 08             	mov    0x8(%ebp),%eax
c010a3a5:	ff d0                	call   *%eax
c010a3a7:	83 c4 10             	add    $0x10,%esp
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
c010a3aa:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
c010a3ae:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c010a3b2:	7f e5                	jg     c010a399 <printnum+0xb6>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c010a3b4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a3b7:	05 94 cd 10 c0       	add    $0xc010cd94,%eax
c010a3bc:	0f b6 00             	movzbl (%eax),%eax
c010a3bf:	0f be c0             	movsbl %al,%eax
c010a3c2:	83 ec 08             	sub    $0x8,%esp
c010a3c5:	ff 75 0c             	pushl  0xc(%ebp)
c010a3c8:	50                   	push   %eax
c010a3c9:	8b 45 08             	mov    0x8(%ebp),%eax
c010a3cc:	ff d0                	call   *%eax
c010a3ce:	83 c4 10             	add    $0x10,%esp
}
c010a3d1:	90                   	nop
c010a3d2:	c9                   	leave  
c010a3d3:	c3                   	ret    

c010a3d4 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c010a3d4:	55                   	push   %ebp
c010a3d5:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010a3d7:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010a3db:	7e 14                	jle    c010a3f1 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c010a3dd:	8b 45 08             	mov    0x8(%ebp),%eax
c010a3e0:	8b 00                	mov    (%eax),%eax
c010a3e2:	8d 48 08             	lea    0x8(%eax),%ecx
c010a3e5:	8b 55 08             	mov    0x8(%ebp),%edx
c010a3e8:	89 0a                	mov    %ecx,(%edx)
c010a3ea:	8b 50 04             	mov    0x4(%eax),%edx
c010a3ed:	8b 00                	mov    (%eax),%eax
c010a3ef:	eb 30                	jmp    c010a421 <getuint+0x4d>
    }
    else if (lflag) {
c010a3f1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010a3f5:	74 16                	je     c010a40d <getuint+0x39>
        return va_arg(*ap, unsigned long);
c010a3f7:	8b 45 08             	mov    0x8(%ebp),%eax
c010a3fa:	8b 00                	mov    (%eax),%eax
c010a3fc:	8d 48 04             	lea    0x4(%eax),%ecx
c010a3ff:	8b 55 08             	mov    0x8(%ebp),%edx
c010a402:	89 0a                	mov    %ecx,(%edx)
c010a404:	8b 00                	mov    (%eax),%eax
c010a406:	ba 00 00 00 00       	mov    $0x0,%edx
c010a40b:	eb 14                	jmp    c010a421 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c010a40d:	8b 45 08             	mov    0x8(%ebp),%eax
c010a410:	8b 00                	mov    (%eax),%eax
c010a412:	8d 48 04             	lea    0x4(%eax),%ecx
c010a415:	8b 55 08             	mov    0x8(%ebp),%edx
c010a418:	89 0a                	mov    %ecx,(%edx)
c010a41a:	8b 00                	mov    (%eax),%eax
c010a41c:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c010a421:	5d                   	pop    %ebp
c010a422:	c3                   	ret    

c010a423 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c010a423:	55                   	push   %ebp
c010a424:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010a426:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010a42a:	7e 14                	jle    c010a440 <getint+0x1d>
        return va_arg(*ap, long long);
c010a42c:	8b 45 08             	mov    0x8(%ebp),%eax
c010a42f:	8b 00                	mov    (%eax),%eax
c010a431:	8d 48 08             	lea    0x8(%eax),%ecx
c010a434:	8b 55 08             	mov    0x8(%ebp),%edx
c010a437:	89 0a                	mov    %ecx,(%edx)
c010a439:	8b 50 04             	mov    0x4(%eax),%edx
c010a43c:	8b 00                	mov    (%eax),%eax
c010a43e:	eb 28                	jmp    c010a468 <getint+0x45>
    }
    else if (lflag) {
c010a440:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010a444:	74 12                	je     c010a458 <getint+0x35>
        return va_arg(*ap, long);
c010a446:	8b 45 08             	mov    0x8(%ebp),%eax
c010a449:	8b 00                	mov    (%eax),%eax
c010a44b:	8d 48 04             	lea    0x4(%eax),%ecx
c010a44e:	8b 55 08             	mov    0x8(%ebp),%edx
c010a451:	89 0a                	mov    %ecx,(%edx)
c010a453:	8b 00                	mov    (%eax),%eax
c010a455:	99                   	cltd   
c010a456:	eb 10                	jmp    c010a468 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c010a458:	8b 45 08             	mov    0x8(%ebp),%eax
c010a45b:	8b 00                	mov    (%eax),%eax
c010a45d:	8d 48 04             	lea    0x4(%eax),%ecx
c010a460:	8b 55 08             	mov    0x8(%ebp),%edx
c010a463:	89 0a                	mov    %ecx,(%edx)
c010a465:	8b 00                	mov    (%eax),%eax
c010a467:	99                   	cltd   
    }
}
c010a468:	5d                   	pop    %ebp
c010a469:	c3                   	ret    

c010a46a <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c010a46a:	55                   	push   %ebp
c010a46b:	89 e5                	mov    %esp,%ebp
c010a46d:	83 ec 18             	sub    $0x18,%esp
    va_list ap;

    va_start(ap, fmt);
c010a470:	8d 45 14             	lea    0x14(%ebp),%eax
c010a473:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c010a476:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a479:	50                   	push   %eax
c010a47a:	ff 75 10             	pushl  0x10(%ebp)
c010a47d:	ff 75 0c             	pushl  0xc(%ebp)
c010a480:	ff 75 08             	pushl  0x8(%ebp)
c010a483:	e8 06 00 00 00       	call   c010a48e <vprintfmt>
c010a488:	83 c4 10             	add    $0x10,%esp
    va_end(ap);
}
c010a48b:	90                   	nop
c010a48c:	c9                   	leave  
c010a48d:	c3                   	ret    

c010a48e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c010a48e:	55                   	push   %ebp
c010a48f:	89 e5                	mov    %esp,%ebp
c010a491:	56                   	push   %esi
c010a492:	53                   	push   %ebx
c010a493:	83 ec 20             	sub    $0x20,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010a496:	eb 17                	jmp    c010a4af <vprintfmt+0x21>
            if (ch == '\0') {
c010a498:	85 db                	test   %ebx,%ebx
c010a49a:	0f 84 8e 03 00 00    	je     c010a82e <vprintfmt+0x3a0>
                return;
            }
            putch(ch, putdat);
c010a4a0:	83 ec 08             	sub    $0x8,%esp
c010a4a3:	ff 75 0c             	pushl  0xc(%ebp)
c010a4a6:	53                   	push   %ebx
c010a4a7:	8b 45 08             	mov    0x8(%ebp),%eax
c010a4aa:	ff d0                	call   *%eax
c010a4ac:	83 c4 10             	add    $0x10,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010a4af:	8b 45 10             	mov    0x10(%ebp),%eax
c010a4b2:	8d 50 01             	lea    0x1(%eax),%edx
c010a4b5:	89 55 10             	mov    %edx,0x10(%ebp)
c010a4b8:	0f b6 00             	movzbl (%eax),%eax
c010a4bb:	0f b6 d8             	movzbl %al,%ebx
c010a4be:	83 fb 25             	cmp    $0x25,%ebx
c010a4c1:	75 d5                	jne    c010a498 <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
c010a4c3:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c010a4c7:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c010a4ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010a4d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c010a4d4:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010a4db:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a4de:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c010a4e1:	8b 45 10             	mov    0x10(%ebp),%eax
c010a4e4:	8d 50 01             	lea    0x1(%eax),%edx
c010a4e7:	89 55 10             	mov    %edx,0x10(%ebp)
c010a4ea:	0f b6 00             	movzbl (%eax),%eax
c010a4ed:	0f b6 d8             	movzbl %al,%ebx
c010a4f0:	8d 43 dd             	lea    -0x23(%ebx),%eax
c010a4f3:	83 f8 55             	cmp    $0x55,%eax
c010a4f6:	0f 87 05 03 00 00    	ja     c010a801 <vprintfmt+0x373>
c010a4fc:	8b 04 85 b8 cd 10 c0 	mov    -0x3fef3248(,%eax,4),%eax
c010a503:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c010a505:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c010a509:	eb d6                	jmp    c010a4e1 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c010a50b:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c010a50f:	eb d0                	jmp    c010a4e1 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c010a511:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c010a518:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010a51b:	89 d0                	mov    %edx,%eax
c010a51d:	c1 e0 02             	shl    $0x2,%eax
c010a520:	01 d0                	add    %edx,%eax
c010a522:	01 c0                	add    %eax,%eax
c010a524:	01 d8                	add    %ebx,%eax
c010a526:	83 e8 30             	sub    $0x30,%eax
c010a529:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c010a52c:	8b 45 10             	mov    0x10(%ebp),%eax
c010a52f:	0f b6 00             	movzbl (%eax),%eax
c010a532:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c010a535:	83 fb 2f             	cmp    $0x2f,%ebx
c010a538:	7e 39                	jle    c010a573 <vprintfmt+0xe5>
c010a53a:	83 fb 39             	cmp    $0x39,%ebx
c010a53d:	7f 34                	jg     c010a573 <vprintfmt+0xe5>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c010a53f:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
c010a543:	eb d3                	jmp    c010a518 <vprintfmt+0x8a>
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c010a545:	8b 45 14             	mov    0x14(%ebp),%eax
c010a548:	8d 50 04             	lea    0x4(%eax),%edx
c010a54b:	89 55 14             	mov    %edx,0x14(%ebp)
c010a54e:	8b 00                	mov    (%eax),%eax
c010a550:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c010a553:	eb 1f                	jmp    c010a574 <vprintfmt+0xe6>

        case '.':
            if (width < 0)
c010a555:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010a559:	79 86                	jns    c010a4e1 <vprintfmt+0x53>
                width = 0;
c010a55b:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c010a562:	e9 7a ff ff ff       	jmp    c010a4e1 <vprintfmt+0x53>

        case '#':
            altflag = 1;
c010a567:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c010a56e:	e9 6e ff ff ff       	jmp    c010a4e1 <vprintfmt+0x53>
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
            goto process_precision;
c010a573:	90                   	nop
        case '#':
            altflag = 1;
            goto reswitch;

        process_precision:
            if (width < 0)
c010a574:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010a578:	0f 89 63 ff ff ff    	jns    c010a4e1 <vprintfmt+0x53>
                width = precision, precision = -1;
c010a57e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010a581:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010a584:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c010a58b:	e9 51 ff ff ff       	jmp    c010a4e1 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c010a590:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
c010a594:	e9 48 ff ff ff       	jmp    c010a4e1 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c010a599:	8b 45 14             	mov    0x14(%ebp),%eax
c010a59c:	8d 50 04             	lea    0x4(%eax),%edx
c010a59f:	89 55 14             	mov    %edx,0x14(%ebp)
c010a5a2:	8b 00                	mov    (%eax),%eax
c010a5a4:	83 ec 08             	sub    $0x8,%esp
c010a5a7:	ff 75 0c             	pushl  0xc(%ebp)
c010a5aa:	50                   	push   %eax
c010a5ab:	8b 45 08             	mov    0x8(%ebp),%eax
c010a5ae:	ff d0                	call   *%eax
c010a5b0:	83 c4 10             	add    $0x10,%esp
            break;
c010a5b3:	e9 71 02 00 00       	jmp    c010a829 <vprintfmt+0x39b>

        // error message
        case 'e':
            err = va_arg(ap, int);
c010a5b8:	8b 45 14             	mov    0x14(%ebp),%eax
c010a5bb:	8d 50 04             	lea    0x4(%eax),%edx
c010a5be:	89 55 14             	mov    %edx,0x14(%ebp)
c010a5c1:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c010a5c3:	85 db                	test   %ebx,%ebx
c010a5c5:	79 02                	jns    c010a5c9 <vprintfmt+0x13b>
                err = -err;
c010a5c7:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c010a5c9:	83 fb 06             	cmp    $0x6,%ebx
c010a5cc:	7f 0b                	jg     c010a5d9 <vprintfmt+0x14b>
c010a5ce:	8b 34 9d 78 cd 10 c0 	mov    -0x3fef3288(,%ebx,4),%esi
c010a5d5:	85 f6                	test   %esi,%esi
c010a5d7:	75 19                	jne    c010a5f2 <vprintfmt+0x164>
                printfmt(putch, putdat, "error %d", err);
c010a5d9:	53                   	push   %ebx
c010a5da:	68 a5 cd 10 c0       	push   $0xc010cda5
c010a5df:	ff 75 0c             	pushl  0xc(%ebp)
c010a5e2:	ff 75 08             	pushl  0x8(%ebp)
c010a5e5:	e8 80 fe ff ff       	call   c010a46a <printfmt>
c010a5ea:	83 c4 10             	add    $0x10,%esp
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c010a5ed:	e9 37 02 00 00       	jmp    c010a829 <vprintfmt+0x39b>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
c010a5f2:	56                   	push   %esi
c010a5f3:	68 ae cd 10 c0       	push   $0xc010cdae
c010a5f8:	ff 75 0c             	pushl  0xc(%ebp)
c010a5fb:	ff 75 08             	pushl  0x8(%ebp)
c010a5fe:	e8 67 fe ff ff       	call   c010a46a <printfmt>
c010a603:	83 c4 10             	add    $0x10,%esp
            }
            break;
c010a606:	e9 1e 02 00 00       	jmp    c010a829 <vprintfmt+0x39b>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c010a60b:	8b 45 14             	mov    0x14(%ebp),%eax
c010a60e:	8d 50 04             	lea    0x4(%eax),%edx
c010a611:	89 55 14             	mov    %edx,0x14(%ebp)
c010a614:	8b 30                	mov    (%eax),%esi
c010a616:	85 f6                	test   %esi,%esi
c010a618:	75 05                	jne    c010a61f <vprintfmt+0x191>
                p = "(null)";
c010a61a:	be b1 cd 10 c0       	mov    $0xc010cdb1,%esi
            }
            if (width > 0 && padc != '-') {
c010a61f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010a623:	7e 76                	jle    c010a69b <vprintfmt+0x20d>
c010a625:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c010a629:	74 70                	je     c010a69b <vprintfmt+0x20d>
                for (width -= strnlen(p, precision); width > 0; width --) {
c010a62b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010a62e:	83 ec 08             	sub    $0x8,%esp
c010a631:	50                   	push   %eax
c010a632:	56                   	push   %esi
c010a633:	e8 17 f8 ff ff       	call   c0109e4f <strnlen>
c010a638:	83 c4 10             	add    $0x10,%esp
c010a63b:	89 c2                	mov    %eax,%edx
c010a63d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a640:	29 d0                	sub    %edx,%eax
c010a642:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010a645:	eb 17                	jmp    c010a65e <vprintfmt+0x1d0>
                    putch(padc, putdat);
c010a647:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c010a64b:	83 ec 08             	sub    $0x8,%esp
c010a64e:	ff 75 0c             	pushl  0xc(%ebp)
c010a651:	50                   	push   %eax
c010a652:	8b 45 08             	mov    0x8(%ebp),%eax
c010a655:	ff d0                	call   *%eax
c010a657:	83 c4 10             	add    $0x10,%esp
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
c010a65a:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010a65e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010a662:	7f e3                	jg     c010a647 <vprintfmt+0x1b9>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010a664:	eb 35                	jmp    c010a69b <vprintfmt+0x20d>
                if (altflag && (ch < ' ' || ch > '~')) {
c010a666:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010a66a:	74 1c                	je     c010a688 <vprintfmt+0x1fa>
c010a66c:	83 fb 1f             	cmp    $0x1f,%ebx
c010a66f:	7e 05                	jle    c010a676 <vprintfmt+0x1e8>
c010a671:	83 fb 7e             	cmp    $0x7e,%ebx
c010a674:	7e 12                	jle    c010a688 <vprintfmt+0x1fa>
                    putch('?', putdat);
c010a676:	83 ec 08             	sub    $0x8,%esp
c010a679:	ff 75 0c             	pushl  0xc(%ebp)
c010a67c:	6a 3f                	push   $0x3f
c010a67e:	8b 45 08             	mov    0x8(%ebp),%eax
c010a681:	ff d0                	call   *%eax
c010a683:	83 c4 10             	add    $0x10,%esp
c010a686:	eb 0f                	jmp    c010a697 <vprintfmt+0x209>
                }
                else {
                    putch(ch, putdat);
c010a688:	83 ec 08             	sub    $0x8,%esp
c010a68b:	ff 75 0c             	pushl  0xc(%ebp)
c010a68e:	53                   	push   %ebx
c010a68f:	8b 45 08             	mov    0x8(%ebp),%eax
c010a692:	ff d0                	call   *%eax
c010a694:	83 c4 10             	add    $0x10,%esp
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010a697:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010a69b:	89 f0                	mov    %esi,%eax
c010a69d:	8d 70 01             	lea    0x1(%eax),%esi
c010a6a0:	0f b6 00             	movzbl (%eax),%eax
c010a6a3:	0f be d8             	movsbl %al,%ebx
c010a6a6:	85 db                	test   %ebx,%ebx
c010a6a8:	74 26                	je     c010a6d0 <vprintfmt+0x242>
c010a6aa:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010a6ae:	78 b6                	js     c010a666 <vprintfmt+0x1d8>
c010a6b0:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
c010a6b4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010a6b8:	79 ac                	jns    c010a666 <vprintfmt+0x1d8>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c010a6ba:	eb 14                	jmp    c010a6d0 <vprintfmt+0x242>
                putch(' ', putdat);
c010a6bc:	83 ec 08             	sub    $0x8,%esp
c010a6bf:	ff 75 0c             	pushl  0xc(%ebp)
c010a6c2:	6a 20                	push   $0x20
c010a6c4:	8b 45 08             	mov    0x8(%ebp),%eax
c010a6c7:	ff d0                	call   *%eax
c010a6c9:	83 c4 10             	add    $0x10,%esp
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c010a6cc:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010a6d0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010a6d4:	7f e6                	jg     c010a6bc <vprintfmt+0x22e>
                putch(' ', putdat);
            }
            break;
c010a6d6:	e9 4e 01 00 00       	jmp    c010a829 <vprintfmt+0x39b>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c010a6db:	83 ec 08             	sub    $0x8,%esp
c010a6de:	ff 75 e0             	pushl  -0x20(%ebp)
c010a6e1:	8d 45 14             	lea    0x14(%ebp),%eax
c010a6e4:	50                   	push   %eax
c010a6e5:	e8 39 fd ff ff       	call   c010a423 <getint>
c010a6ea:	83 c4 10             	add    $0x10,%esp
c010a6ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a6f0:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c010a6f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a6f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010a6f9:	85 d2                	test   %edx,%edx
c010a6fb:	79 23                	jns    c010a720 <vprintfmt+0x292>
                putch('-', putdat);
c010a6fd:	83 ec 08             	sub    $0x8,%esp
c010a700:	ff 75 0c             	pushl  0xc(%ebp)
c010a703:	6a 2d                	push   $0x2d
c010a705:	8b 45 08             	mov    0x8(%ebp),%eax
c010a708:	ff d0                	call   *%eax
c010a70a:	83 c4 10             	add    $0x10,%esp
                num = -(long long)num;
c010a70d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a710:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010a713:	f7 d8                	neg    %eax
c010a715:	83 d2 00             	adc    $0x0,%edx
c010a718:	f7 da                	neg    %edx
c010a71a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a71d:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c010a720:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010a727:	e9 9f 00 00 00       	jmp    c010a7cb <vprintfmt+0x33d>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c010a72c:	83 ec 08             	sub    $0x8,%esp
c010a72f:	ff 75 e0             	pushl  -0x20(%ebp)
c010a732:	8d 45 14             	lea    0x14(%ebp),%eax
c010a735:	50                   	push   %eax
c010a736:	e8 99 fc ff ff       	call   c010a3d4 <getuint>
c010a73b:	83 c4 10             	add    $0x10,%esp
c010a73e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a741:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c010a744:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010a74b:	eb 7e                	jmp    c010a7cb <vprintfmt+0x33d>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c010a74d:	83 ec 08             	sub    $0x8,%esp
c010a750:	ff 75 e0             	pushl  -0x20(%ebp)
c010a753:	8d 45 14             	lea    0x14(%ebp),%eax
c010a756:	50                   	push   %eax
c010a757:	e8 78 fc ff ff       	call   c010a3d4 <getuint>
c010a75c:	83 c4 10             	add    $0x10,%esp
c010a75f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a762:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c010a765:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c010a76c:	eb 5d                	jmp    c010a7cb <vprintfmt+0x33d>

        // pointer
        case 'p':
            putch('0', putdat);
c010a76e:	83 ec 08             	sub    $0x8,%esp
c010a771:	ff 75 0c             	pushl  0xc(%ebp)
c010a774:	6a 30                	push   $0x30
c010a776:	8b 45 08             	mov    0x8(%ebp),%eax
c010a779:	ff d0                	call   *%eax
c010a77b:	83 c4 10             	add    $0x10,%esp
            putch('x', putdat);
c010a77e:	83 ec 08             	sub    $0x8,%esp
c010a781:	ff 75 0c             	pushl  0xc(%ebp)
c010a784:	6a 78                	push   $0x78
c010a786:	8b 45 08             	mov    0x8(%ebp),%eax
c010a789:	ff d0                	call   *%eax
c010a78b:	83 c4 10             	add    $0x10,%esp
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c010a78e:	8b 45 14             	mov    0x14(%ebp),%eax
c010a791:	8d 50 04             	lea    0x4(%eax),%edx
c010a794:	89 55 14             	mov    %edx,0x14(%ebp)
c010a797:	8b 00                	mov    (%eax),%eax
c010a799:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a79c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c010a7a3:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c010a7aa:	eb 1f                	jmp    c010a7cb <vprintfmt+0x33d>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c010a7ac:	83 ec 08             	sub    $0x8,%esp
c010a7af:	ff 75 e0             	pushl  -0x20(%ebp)
c010a7b2:	8d 45 14             	lea    0x14(%ebp),%eax
c010a7b5:	50                   	push   %eax
c010a7b6:	e8 19 fc ff ff       	call   c010a3d4 <getuint>
c010a7bb:	83 c4 10             	add    $0x10,%esp
c010a7be:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a7c1:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c010a7c4:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c010a7cb:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c010a7cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a7d2:	83 ec 04             	sub    $0x4,%esp
c010a7d5:	52                   	push   %edx
c010a7d6:	ff 75 e8             	pushl  -0x18(%ebp)
c010a7d9:	50                   	push   %eax
c010a7da:	ff 75 f4             	pushl  -0xc(%ebp)
c010a7dd:	ff 75 f0             	pushl  -0x10(%ebp)
c010a7e0:	ff 75 0c             	pushl  0xc(%ebp)
c010a7e3:	ff 75 08             	pushl  0x8(%ebp)
c010a7e6:	e8 f8 fa ff ff       	call   c010a2e3 <printnum>
c010a7eb:	83 c4 20             	add    $0x20,%esp
            break;
c010a7ee:	eb 39                	jmp    c010a829 <vprintfmt+0x39b>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c010a7f0:	83 ec 08             	sub    $0x8,%esp
c010a7f3:	ff 75 0c             	pushl  0xc(%ebp)
c010a7f6:	53                   	push   %ebx
c010a7f7:	8b 45 08             	mov    0x8(%ebp),%eax
c010a7fa:	ff d0                	call   *%eax
c010a7fc:	83 c4 10             	add    $0x10,%esp
            break;
c010a7ff:	eb 28                	jmp    c010a829 <vprintfmt+0x39b>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c010a801:	83 ec 08             	sub    $0x8,%esp
c010a804:	ff 75 0c             	pushl  0xc(%ebp)
c010a807:	6a 25                	push   $0x25
c010a809:	8b 45 08             	mov    0x8(%ebp),%eax
c010a80c:	ff d0                	call   *%eax
c010a80e:	83 c4 10             	add    $0x10,%esp
            for (fmt --; fmt[-1] != '%'; fmt --)
c010a811:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010a815:	eb 04                	jmp    c010a81b <vprintfmt+0x38d>
c010a817:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010a81b:	8b 45 10             	mov    0x10(%ebp),%eax
c010a81e:	83 e8 01             	sub    $0x1,%eax
c010a821:	0f b6 00             	movzbl (%eax),%eax
c010a824:	3c 25                	cmp    $0x25,%al
c010a826:	75 ef                	jne    c010a817 <vprintfmt+0x389>
                /* do nothing */;
            break;
c010a828:	90                   	nop
        }
    }
c010a829:	e9 68 fc ff ff       	jmp    c010a496 <vprintfmt+0x8>
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
            if (ch == '\0') {
                return;
c010a82e:	90                   	nop
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
c010a82f:	8d 65 f8             	lea    -0x8(%ebp),%esp
c010a832:	5b                   	pop    %ebx
c010a833:	5e                   	pop    %esi
c010a834:	5d                   	pop    %ebp
c010a835:	c3                   	ret    

c010a836 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c010a836:	55                   	push   %ebp
c010a837:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c010a839:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a83c:	8b 40 08             	mov    0x8(%eax),%eax
c010a83f:	8d 50 01             	lea    0x1(%eax),%edx
c010a842:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a845:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c010a848:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a84b:	8b 10                	mov    (%eax),%edx
c010a84d:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a850:	8b 40 04             	mov    0x4(%eax),%eax
c010a853:	39 c2                	cmp    %eax,%edx
c010a855:	73 12                	jae    c010a869 <sprintputch+0x33>
        *b->buf ++ = ch;
c010a857:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a85a:	8b 00                	mov    (%eax),%eax
c010a85c:	8d 48 01             	lea    0x1(%eax),%ecx
c010a85f:	8b 55 0c             	mov    0xc(%ebp),%edx
c010a862:	89 0a                	mov    %ecx,(%edx)
c010a864:	8b 55 08             	mov    0x8(%ebp),%edx
c010a867:	88 10                	mov    %dl,(%eax)
    }
}
c010a869:	90                   	nop
c010a86a:	5d                   	pop    %ebp
c010a86b:	c3                   	ret    

c010a86c <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c010a86c:	55                   	push   %ebp
c010a86d:	89 e5                	mov    %esp,%ebp
c010a86f:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010a872:	8d 45 14             	lea    0x14(%ebp),%eax
c010a875:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c010a878:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a87b:	50                   	push   %eax
c010a87c:	ff 75 10             	pushl  0x10(%ebp)
c010a87f:	ff 75 0c             	pushl  0xc(%ebp)
c010a882:	ff 75 08             	pushl  0x8(%ebp)
c010a885:	e8 0b 00 00 00       	call   c010a895 <vsnprintf>
c010a88a:	83 c4 10             	add    $0x10,%esp
c010a88d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c010a890:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010a893:	c9                   	leave  
c010a894:	c3                   	ret    

c010a895 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c010a895:	55                   	push   %ebp
c010a896:	89 e5                	mov    %esp,%ebp
c010a898:	83 ec 18             	sub    $0x18,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c010a89b:	8b 45 08             	mov    0x8(%ebp),%eax
c010a89e:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010a8a1:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a8a4:	8d 50 ff             	lea    -0x1(%eax),%edx
c010a8a7:	8b 45 08             	mov    0x8(%ebp),%eax
c010a8aa:	01 d0                	add    %edx,%eax
c010a8ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a8af:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c010a8b6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010a8ba:	74 0a                	je     c010a8c6 <vsnprintf+0x31>
c010a8bc:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a8bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a8c2:	39 c2                	cmp    %eax,%edx
c010a8c4:	76 07                	jbe    c010a8cd <vsnprintf+0x38>
        return -E_INVAL;
c010a8c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010a8cb:	eb 20                	jmp    c010a8ed <vsnprintf+0x58>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c010a8cd:	ff 75 14             	pushl  0x14(%ebp)
c010a8d0:	ff 75 10             	pushl  0x10(%ebp)
c010a8d3:	8d 45 ec             	lea    -0x14(%ebp),%eax
c010a8d6:	50                   	push   %eax
c010a8d7:	68 36 a8 10 c0       	push   $0xc010a836
c010a8dc:	e8 ad fb ff ff       	call   c010a48e <vprintfmt>
c010a8e1:	83 c4 10             	add    $0x10,%esp
    // null terminate the buffer
    *b.buf = '\0';
c010a8e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a8e7:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c010a8ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010a8ed:	c9                   	leave  
c010a8ee:	c3                   	ret    

c010a8ef <hash32>:
 * @bits:   the number of bits in a return value
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
c010a8ef:	55                   	push   %ebp
c010a8f0:	89 e5                	mov    %esp,%ebp
c010a8f2:	83 ec 10             	sub    $0x10,%esp
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
c010a8f5:	8b 45 08             	mov    0x8(%ebp),%eax
c010a8f8:	69 c0 01 00 37 9e    	imul   $0x9e370001,%eax,%eax
c010a8fe:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (hash >> (32 - bits));
c010a901:	b8 20 00 00 00       	mov    $0x20,%eax
c010a906:	2b 45 0c             	sub    0xc(%ebp),%eax
c010a909:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010a90c:	89 c1                	mov    %eax,%ecx
c010a90e:	d3 ea                	shr    %cl,%edx
c010a910:	89 d0                	mov    %edx,%eax
}
c010a912:	c9                   	leave  
c010a913:	c3                   	ret    

c010a914 <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
c010a914:	55                   	push   %ebp
c010a915:	89 e5                	mov    %esp,%ebp
c010a917:	57                   	push   %edi
c010a918:	56                   	push   %esi
c010a919:	53                   	push   %ebx
c010a91a:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
c010a91d:	a1 80 7a 12 c0       	mov    0xc0127a80,%eax
c010a922:	8b 15 84 7a 12 c0    	mov    0xc0127a84,%edx
c010a928:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
c010a92e:	6b f0 05             	imul   $0x5,%eax,%esi
c010a931:	01 fe                	add    %edi,%esi
c010a933:	bf 6d e6 ec de       	mov    $0xdeece66d,%edi
c010a938:	f7 e7                	mul    %edi
c010a93a:	01 d6                	add    %edx,%esi
c010a93c:	89 f2                	mov    %esi,%edx
c010a93e:	83 c0 0b             	add    $0xb,%eax
c010a941:	83 d2 00             	adc    $0x0,%edx
c010a944:	89 c7                	mov    %eax,%edi
c010a946:	83 e7 ff             	and    $0xffffffff,%edi
c010a949:	89 f9                	mov    %edi,%ecx
c010a94b:	0f b7 da             	movzwl %dx,%ebx
c010a94e:	89 0d 80 7a 12 c0    	mov    %ecx,0xc0127a80
c010a954:	89 1d 84 7a 12 c0    	mov    %ebx,0xc0127a84
    unsigned long long result = (next >> 12);
c010a95a:	a1 80 7a 12 c0       	mov    0xc0127a80,%eax
c010a95f:	8b 15 84 7a 12 c0    	mov    0xc0127a84,%edx
c010a965:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c010a969:	c1 ea 0c             	shr    $0xc,%edx
c010a96c:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010a96f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
c010a972:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
c010a979:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010a97c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010a97f:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010a982:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010a985:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a988:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010a98b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010a98f:	74 1c                	je     c010a9ad <rand+0x99>
c010a991:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a994:	ba 00 00 00 00       	mov    $0x0,%edx
c010a999:	f7 75 dc             	divl   -0x24(%ebp)
c010a99c:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010a99f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a9a2:	ba 00 00 00 00       	mov    $0x0,%edx
c010a9a7:	f7 75 dc             	divl   -0x24(%ebp)
c010a9aa:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010a9ad:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a9b0:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a9b3:	f7 75 dc             	divl   -0x24(%ebp)
c010a9b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010a9b9:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010a9bc:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a9bf:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010a9c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010a9c5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010a9c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
c010a9cb:	83 c4 24             	add    $0x24,%esp
c010a9ce:	5b                   	pop    %ebx
c010a9cf:	5e                   	pop    %esi
c010a9d0:	5f                   	pop    %edi
c010a9d1:	5d                   	pop    %ebp
c010a9d2:	c3                   	ret    

c010a9d3 <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
c010a9d3:	55                   	push   %ebp
c010a9d4:	89 e5                	mov    %esp,%ebp
    next = seed;
c010a9d6:	8b 45 08             	mov    0x8(%ebp),%eax
c010a9d9:	ba 00 00 00 00       	mov    $0x0,%edx
c010a9de:	a3 80 7a 12 c0       	mov    %eax,0xc0127a80
c010a9e3:	89 15 84 7a 12 c0    	mov    %edx,0xc0127a84
}
c010a9e9:	90                   	nop
c010a9ea:	5d                   	pop    %ebp
c010a9eb:	c3                   	ret    
