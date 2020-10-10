此篇调试器全程根据V神博客来进行，此处只是进行一番记录。

https://veritas501.space/2017/10/16/%E7%BF%BB%E8%AF%91_%E7%BC%96%E5%86%99%E4%B8%80%E4%B8%AALinux%E8%B0%83%E8%AF%95%E5%99%A8/

### 准备工作

#### 环境安装

首先我们需要下载[Linenoise](https://github.com/antirez/linenoise)和[libelfin](https://github.com/TartanLlama/libelfin/tree/fbreg)，分别运用以下命令进行

```shell
git clone https://github.com/antirez/linenoise
git clone https://github.com/TartanLlama/libelfin
```

Linenoise主要是用来处理我们的命令行输入

libelfin主要是用来解析调试信息

#### main编写

此处运用fork，主要是为了运用ptrace来使得父进程监控子进程，而子进程来负责运行我们需要调试的程序。关于[ptrace](https://github.com/tina2114/Sakura_University/tree/master/%E5%A4%96%E5%8D%A1%E8%B5%9B/PlaidCTF%202020/sandybox)的详解，在我的另一篇blog里有详细赘述，这里就不再进行说明。

这里说明一下execl函数

```c
int execl(const char * path, const char * arg, ...);
```

execl()用来执行参数path 字符串所代表的文件路径, 接下来的参数代表执行该文件时传递过去的argv(0), argv[1], ..., 最后一个参数必须用空指针(NULL)作结束.

```c
void execute_debugee (const std::string& prog_name) {
    if (ptrace(PTRACE_TRACEME, 0, 0, 0) < 0) {
        std::cerr << "Error in ptrace\n";
        return;
    }
    execl(prog_name.c_str(), prog_name.c_str(), nullptr); // c_str()函数返bai回一个指向正规C字符串的指针, 内容与本string串相同.
}

int main(int argc, char* argv[]) {
    if (argc < 2){
        std::cerr << "Program name not specified";
        return -1;
    }

    auto prog = argv[1];

    auto pid = fork();
    if (pid == 0){
        execute_debugee(prog);
    }
    else if (pid >= 1){
        debugger dbg(prog,pid);
        dbg.run();
    }
    return 0;
}
```

#### 添加调试器循环

来创建一个debugger类，循环监听用户的输入

```c
//
// Created by zhz on 2020/10/2.
//

#ifndef DEBUGGER_DEBUGGER_H
#define DEBUGGER_DEBUGGER_H
#include <iostream>

class debugger{
public:
    debugger (std::string prog_name, pid_t pid)
        : m_prog_name {std::move(prog_name)},m_pid{pid} {}

        void run();

private:
    void handle_command(const std::string &line);
    void continue_execution();

    std::string m_prog_name;
    pid_t m_pid;
};

#endif //DEBUGGER_DEBUGGER_H

```

run函数需要等待子进程启动完成，然后持续从linenoise中读取输入，直到遇到EOF。这里说明一下，当被调试的子进程启动完成，会发生SIGTRAP信号，表示这是跟踪or遇到断点。我们可以通过`waitpid`来等待，接收这个信号

```c
void debugger::run() {
    int wait_status;
    auto options = 0;
    waitpid(m_pid,&wait_status,options);

    char* line = nullptr;
    while ((line = linenoise("zdb> ")) != nullptr){ // linenoise实现命令提示符，这里是zdb> ，并返回用户输入缓冲区
        handle_command(line);
        linenoiseHistoryAdd(line); // 将此命令加入到历史，从而可以通过上下键找到它
        linenoiseFree(line); // 将资源释放
    }
}
```

#### 处理输入

这里主要是设置一些与gdb相同的命令，比如break or b，continue or c等。这里暂时只设置continue

```c
void debugger::handle_command(const std::string &line){
    auto args = split(line,' ');
    auto command = args[0];

    if (is_prefix(command,"continue")){
        continue_execution();
    }
    else{
        std::cerr << "Unknown command\n";
    }
}

// 运行子进程，父进程进入等待
void debugger::continue_execution() {
    ptrace(PTRACE_CONT,m_pid, nullptr, nullptr);

    int wait_status;
    auto options = 0;
    waitpid(m_pid,&wait_status,options);
}

// 此处以' '作为分隔符读取
bool is_prefix(const std::string &s, const std::string &of){
    if (s.size() > of.size()) return false;
    return std::equal(s.begin(),s.end(),of.begin()); // 此处使用的是三参数版本，这里可以理解为用of的字符串与s进行匹配，如果全部匹配成功则返回true
}

std::vector<std::string> split(const std::string &s, char delimiter){
    std::vector<std::string> out{};
    std::stringstream ss {s}; // 个人理解，这就是一个流
    std::string item;

    while (std::getline(ss,item,delimiter)){ // 从流中获取数据转换成字符串，delimiter为分隔符
        out.push_back(item);
    }
    return out;
}
```

### 断点

断点分两种：硬件断点和内存断点。硬件断点通常通过设置架构指定的寄存器来设置中断，而内存断点则是通过修改正在执行的代码来设置中断。

此处我们主要实现内存断点，通过在要断点的地址设置int 3，也就是将其改为0xcc。当处理器遇到int 3址里的时候，控制权就被传递给了断点中断处理程序，在linux里是给进程发送了SIGTRAP信号。

至于如何让调试器（也就是父进程）注意到这个信号，还是依靠waitpid。基本流程就是设置断点，运行程序，父进程的waitpid收到SIGTRAP信号。

#### 实现内存断点

这里新构建一个breakpoint类，然后根据需要选择enable启用这个断点或者disable停用这个断点

```c
//
// Created by zhz on 2020/10/3.
//

#ifndef DEBUGGER_BREAKPOINT_H
#define DEBUGGER_BREAKPOINT_H
#include <iostream>

class breakpoint{
public:
    breakpoint() = default;
    breakpoint(pid_t pid, std::intptr_t addr)
        : m_pid{pid}, m_addr{addr}, m_enabled{false}, m_saved_data{} {}

        void enable();
        void disable();

        auto is_enabled() const -> bool { return m_enabled; }
        auto get_address() const -> std::intptr_t {return m_addr; }

private:
    pid_t m_pid;
    std::intptr_t m_addr;
    bool m_enabled;
    uint8_t m_saved_data; //存储断点地址
};


#endif //DEBUGGER_BREAKPOINT_H

```

具体的下断点在enable()

```c
void breakpoint::enable() {
    auto data = ptrace(PTRACE_PEEKDATA, m_pid, m_addr, nullptr);
    m_saved_data = static_cast<uint8_t>(data & 0xff); //保存最低的一字节
    uint64_t int3 = 0xcc;
    uint64_t data_with_int3 = ((data & ~0xff) | int3); // 此处是data的最底一字节& ~0xff，也就是将其置0，再将最低的一字节改为0xcc
    ptrace(PTRACE_POKEDATA, m_pid, m_addr, data_with_int3);

    m_enabled = true;
}
```

取消断点disable()

```c
void breakpoint::disable() {
    auto data = ptrace(PTRACE_PEEKDATA, m_pid, m_addr, nullptr);
    auto restored_data = ((data & ~0xff) | m_saved_data); //将地址里数据的最低一字节改回原本的数据
    ptrace(PTRACE_POKEDATA, m_pid, m_addr, restored_data);

    m_enabled = false;
}
```

#### 调试器增加断点

主要对debugger类做三处修改

1. 为`debugger`添加断点数据结构体
2. 添加`set_breakpoint_at_addr`函数
3. 给`handle_command`函数添加break指令

断点存放在`std::unordered_map<std::intptr_t, breakpoint>`类型的结构体

```c
private:
    void handle_command(const std::string &line);
    void continue_execution();

    std::string m_prog_name;
    std::unordered_map<std::intptr_t,breakpoint> m_breakpoints;
    pid_t m_pid;
```

`set_breakpoint_at_addr`函数创建一个新断点，启用断点，将其放入map中

```c
void debugger::set_brakepoint_at_address(std::intptr_t addr) {
    std::cout << "Set breakpoint at address 0x" << std::hex << addr << std::endl;
    breakpoint bp {m_pid, addr};
    bp.enable();
    m_breakpoints[addr] = bp;
}
```

添加break命令的识别

```c
void debugger::handle_command(const std::string &line){
    auto args = split(line,' ');
    auto command = args[0];

    if (is_prefix(command,"continue")){
        continue_execution();
    }
    else if(is_prefix(command,"break")){
        std::string addr {args[1],2}; // args为你在启用调试器后命令行里输入的参数，类似于b 0x40056a，这里就是取0x40056a
        set_brakepoint_at_address(std::stol(addr,0,16)); // 将其转换为long int类型的16进制数
    }
    else{
        std::cerr << "Unknown command\n";
    }
}
```

### 内存和寄存器

#### 注册寄存器

这里只显示通用寄存器和专用寄存器。这里的每一个寄存器都有其名称和DWARF寄存器编号，以及其在ptrace返回的结构体中的储存位置。DWARF寄存器编号来自[System V x86_64 ABI](https://www.uclibc.org/docs/psABI-x86_64.pdf)。

```c
enum class reg {
    rax,rbx,rcx,rdx,
    rdi,rsi,rbp,rsp,
    r8,r9,r10,r11,
    r12,r13,r14,r15,
    rip,rflags,cs,
    orig_rax,fs_base,
    gs_base,
    fs,gs,ss,ds,es
};

constexpr std::size_t n_registers = 27;  // 寄存器总数

struct reg_descriptor{
    reg r;
    int dwarf_r; // 寄存器编号
    std::string name; // 寄存器名字
};

const std::array<reg_descriptor,n_registers> g_register_descriptors {{
    { reg::r15, 15, "r15"},
    { reg::r14, 14, "r14"},
    { reg::r13, 13, "r13" },
    { reg::r12, 12, "r12" },
    { reg::rbp, 6, "rbp" },
    { reg::rbx, 3, "rbx" },
    { reg::r11, 11, "r11" },
    { reg::r10, 10, "r10" },
    { reg::r9, 9, "r9" },
    { reg::r8, 8, "r8" },
    { reg::rax, 0, "rax" },
    { reg::rcx, 2, "rcx" },
    { reg::rdx, 1, "rdx" },
    { reg::rsi, 4, "rsi" },
    { reg::rdi, 5, "rdi" },
    { reg::orig_rax, -1, "orig_rax" },
    { reg::rip, -1, "rip" },
    { reg::cs, 51, "cs" },
    { reg::rflags, 49, "eflags" },
    { reg::rsp, 7, "rsp" },
    { reg::ss, 52, "ss" },
    { reg::fs_base, 58, "fs_base" },
    { reg::gs_base, 59, "gs_base" },
    { reg::ds, 53, "ds" },
    { reg::es, 50, "es" },
    { reg::fs, 54, "fs" },
    { reg::gs, 55, "gs" },
}};
```

接下来就是针对特定寄存器值的读取和存储，这里先说读取

先通过ptrace将所有寄存器的值全部放入user_regs_struct，因为函数的第二个参数是`reg r`，即一个寄存器的名字，所以这个函数的总体流程是存所有的寄存器值，然后在user_regs_struct中寻找与第二个参数`reg r`相同名字的寄存器的位置，返回user_regs_struct中这个寄存器的值

```c
uint64_t get_register_value(pid_t pid, reg r) {
    user_regs_struct regs;
    ptrace(PTRACE_GETREGS,pid, nullptr,&regs);
    auto it = std::find_if(begin(g_register_descriptors), end(g_register_descriptors),
                           [r](auto&& rd) { return rd.r == r; });
    return *(reinterpret_cast<uint64_t*>(&regs) + (it - begin(g_register_descriptors)));
}
```

存储思路差不多，寻找对应的寄存器的位置，然后赋值

```c
void set_register_value(pid_t pid, reg r, uint64_t value){
    user_regs_struct regs;
    ptrace(PTRACE_GETREGS,pid, nullptr,&regs);
    auto it = std::find_if(begin(g_register_descriptors), end(g_register_descriptors),
                           [r](auto&& rd) { return rd.r == r; });

    *(reinterpret_cast<uint64_t*>(&regs) + (it - begin(g_register_descriptors))) = value;
    ptrace(PTRACE_SETREGS,pid, nullptr,&regs);
}
```

有了对寄存器的存储和读取，接下来我们就需要对指定的寄存器进行寻找了

这里是根据DWARF寄存器编号进行寻找，第二个参数是寄存器的编号

```c
uint64_t get_register_value_from_dwarf_register (pid_t pid, unsigned regnum){
    // 通过编号在g_register_descriptors数组中寻找对应的寄存器
    auto it = std::find_if(begin(g_register_descriptors),end(g_register_descriptors),
                           [regnum](auto&& rd){ return rd.dwarf_r == regnum;});
    if (it == end(g_register_descriptors)){
        throw std::out_of_range{"Unknown dwarf register"};
    }

    return get_register_value(pid, it->r); // 返回对应的reg的value
}
```

根据寄存器名字来进行寻找

```c
// 获取寄存器的名字
std::string get_register_name(reg r) {
    auto it = std::find_if(begin(g_register_descriptors),end(g_register_descriptors),
                           [r](auto&& rd) { return rd.r == r;});
    return it->name;
}
// 根据名字来返回对应的reg
reg get_register_from_name(const std::string& name) {
    auto it = std::find_if(begin(g_register_descriptors),end(g_register_descriptors),
                           [name](auto&& rd) { return rd.name == name;});
    return it->r;
}
```

导出所有寄存器的值

```c
void debugger::dump_registers() {
    for (const auto& rd : g_register_descriptors) {
        // 除去0x一共输出16个字节，如果get_register_value(m_pid,rd.r)未满足16位则前面添加0补齐
        std::cout << rd.name << " 0x"
                             << std::setfill('0') << std::setw(16) << std::hex << get_register_value(m_pid,rd.r) << std::endl;
    }
}
```

#### 显示寄存器

在调试器中加入对应的命令，能够打印所有寄存器，单个寄存器的读写

```c
    else if(is_prefix(command,"register")) {
        if (is_prefix(args[1], "dump")) {
            dump_registers();
        }
        else if (is_prefix(args[1], "read")) {
            std::cout << get_register_value(m_pid,get_register_from_name(args[2])) << std::endl;
        }
        else if (is_prefix(args[1], "write")) {
            std::string val {args[3], 2};
            set_register_value(m_pid, get_register_from_name(args[2]),std::stol(val,0,16));
        }
    }
```

#### 完善断点功能

先补充两个函数，获取rip和给rip赋值的函数

```c
uint64_t debugger::get_pc(){
    return get_register_value(m_pid,reg::rip);
}

void debugger::set_pc(uint64_t pc) {
    set_register_value(m_pid,reg::rip,pc);
}
```

#### 步过断点

总体思路是：假设断点在0x40056a，那么你去执行的时候实际上程序断在了0x40056b，所以你需要将其变回0x40056a，然后判断此处断点是否存在，如果存在，就将rip变为0x40056a，刚好卡在断点上，然后禁用断点，单步步过断点，再重新启用断点

```c
void debugger::step_over_breakpoint() {
    // -1是因为执行跳过了断点
    auto possible_brakepoint_location = get_pc() - 1 ;
    if (m_breakpoints.count(possible_brakepoint_location)) {
        auto& bp = m_breakpoints[possible_brakepoint_location];

        if (bp.is_enabled()) {
            auto previous_instruction_address = possible_brakepoint_location;
            set_pc(previous_instruction_address);

            bp.disable();
            ptrace(PTRACE_SINGLESTEP,m_pid, nullptr, nullptr); // 单步步过
            wait_for_signal();
            bp.enable();
        }
    }
```

重写`continue_execution`函数

```c
void debugger::continue_execution() {
    step_over_breakpoint(); // 单步步过
    ptrace(PTRACE_CONT,m_pid, nullptr, nullptr); // 继续执行子进程
    wait_for_signal(); // 等待子进程信号
}
```

