
//**************************************************************
//
// Code generator SKELETON
//
// Read the comments carefully. Make sure to
//    initialize the base class tags in
//       `CgenClassTable::CgenClassTable'
// 仔细阅读评论。 确保在`CgenClassTable :: CgenClassTable'中初始化基类标签

//    Add the label for the dispatch tables to  将调度表的标签添加到
//       `IntEntry::code_def'
//       `StringEntry::code_def'
//       `BoolConst::code_def'
//
//    Add code to emit everyting else that is needed
//       in `CgenClassTable::code'
//   添加代码以发出CgenClassTable :: code中需要的所有其他内容
//
// The files as provided will produce code to begin the code
// segments, declare globals, and emit constants.  You must
// fill in the rest.
// 提供的文件将生成代码以开始代码段，声明全局变量并发出常量。
// 您必须填写其余部分。
//**************************************************************

#include "cgen.h"
#include "cgen_gc.h"

#include <vector>
#include <map>
#include <list>
#include <algorithm>

extern void emit_string_constant(ostream& str, char *s);

// 在handle_flags.h中声明：
extern int cgen_debug;
extern int disable_reg_alloc;

extern int node_lineno;

/**
 *                代码生成
 *  从高层次上讲，代码生成包括：
 *
 *  1.计算继承图
 *  2.以深度优先的顺序将标签分配给所有类
 *  3.确定每个类的属性，临时对象和调度表的布局
 *  4.为全局数据生成代码：常量，调度表，...
 *  5.为每个功能生成代码
 *
 *  （1）主要来自语义分析器。
 */



//
// 使用了语义分析器（semant.cc）中的两个符号。
// 将为新的SELF_TYPE生成特殊代码。
// 名称“ self”还生成与其他引用不同的代码。
// Three symbols from the semantic analyzer (semant.cc) are used.
// If e : No_type, then no code is generated for e.
// Special code is generated for new SELF_TYPE.
// The name "self" also generates code different from other references.
//
//////////////////////////////////////////////////////////////////////
//
// Symbols
//
// For convenience, a large number of symbols are predefined here.
// These symbols include the primitive type and method names, as well
// as fixed names used by the runtime system.
//
// 为了方便起见，此处预定义了大量符号。 这些符号包括原始类型和方法名称，
// 以及运行时系统使用的固定名称。
//////////////////////////////////////////////////////////////////////
Symbol 
       arg,
       arg2,
       Bool,
       concat,
       cool_abort,
       copy,
       Int,
       in_int,
       in_string,
       IO,
       length,
       Main,
       main_meth,
       No_class,
       No_type,
       Object,
       out_int,
       out_string,
       prim_slot,
       self,
       SELF_TYPE,
       Str,
       str_field,
       substr,
       type_name,
       val;
//
// Initializing the predefined symbols.
// 初始化预定义符号。
static void initialize_constants(void)
{
  arg         = idtable.add_string("arg");
  arg2        = idtable.add_string("arg2");
  Bool        = idtable.add_string("Bool");
  concat      = idtable.add_string("concat");
  cool_abort  = idtable.add_string("abort");
  copy        = idtable.add_string("copy");
  Int         = idtable.add_string("Int");
  in_int      = idtable.add_string("in_int");
  in_string   = idtable.add_string("in_string");
  IO          = idtable.add_string("IO");
  length      = idtable.add_string("length");
  Main        = idtable.add_string("Main");
  main_meth   = idtable.add_string("main");
//   _no_class is a symbol that can't be the name of any 
//   user-defined class.
//   _no_class是不能作为任何用户定义类的名称的符号。
  No_class    = idtable.add_string("_no_class");
  No_type     = idtable.add_string("_no_type");
  Object      = idtable.add_string("Object");
  out_int     = idtable.add_string("out_int");
  out_string  = idtable.add_string("out_string");
  prim_slot   = idtable.add_string("_prim_slot");
  self        = idtable.add_string("self");
  SELF_TYPE   = idtable.add_string("SELF_TYPE");
  Str         = idtable.add_string("String");
  str_field   = idtable.add_string("_str_field");
  substr      = idtable.add_string("substr");
  type_name   = idtable.add_string("type_name");
  val         = idtable.add_string("_val");
}

static char *gc_init_names[] =
  { "_NoGC_Init", "_GenGC_Init", "_ScnGC_Init" };
static char *gc_collect_names[] =
  { "_NoGC_Collect", "_GenGC_Collect", "_ScnGC_Collect" };


//  BoolConst is a class that implements code generation for operations
//  on the two booleans, which are given global names here.
//  BoolConst是一个类，它为两个布尔值实现操作生成代码，这两个布尔值在此处具有全局名称。
BoolConst falsebool(FALSE);
BoolConst truebool(TRUE);

// 以下临时名称不会与任何用户定义的名称冲突。
#define TEMP1 "_1"

//*********************************************************
//
// Define method for code generation
// 定义代码生成方法
// This is the method called by the compiler driver
// `cgtest.cc'. cgen takes an `ostream' to which the assembly will be
// emmitted, and it passes this and the class list of the
// code generator tree to the constructor for `CgenClassTable'.
// That constructor performs all of the work of the code
// generator.
// 这是编译器驱动程序cgtest.cc调用的方法。 cgen接受一个“ ostream”，
// 程序集将在该“ ostream”上执行，并将其和代码生成器树的类列表传递
// 给“ CgenClassTable”的构造函数。 该构造函数执行代码生成器的
// 所有工作。
//*********************************************************

void program_class::cgen(ostream &os) 
{
  // spim wants comments to start with '#'
  os << "# start of generated code\n";

  initialize_constants();
  CgenClassTable *codegen_classtable = new CgenClassTable(classes,os);

  os << "\n# end of generated code\n";
}


//////////////////////////////////////////////////////////////////////////////
//
//  emit_* procedures
//  发出*程序
//  emit_X  writes code for operation "X" to the output stream.
//  There is an emit_X for each opcode X, as well as emit_ functions
//  for generating names according to the naming conventions (see emit.h)
//  and calls to support functions defined in the trap handler.
//
//  glow_X将用于操作“ X”的代码写入输出流。 每个操作码X都有一个embed_X，
//  还有用来根据命名约定生成名称（请参见emit.h）
//  和调用以支持在陷阱处理程序中定义的函数的emit_X函数。
//  Register names and addresses are passed as strings.  See `emit.h'
//  for symbolic names you can use to refer to the strings.
//
//////////////////////////////////////////////////////////////////////////////

// mips指令集的基本格式
//        R格式指令
//        标记	  op	     rs	                rt	              rd	       shamt	  funct
//        位数	 31-26	    25-21	          20-16	            15-11	       10-6	       5-0
//        功能	操作符	源操作数寄存器1  源操作数寄存器2	目的操作数寄存器  位移量	操作符附加段

//        L格式指令
//        标记	   op	       rs	           rd	          im
//        位数	 31-26	     25-21	         20-16	         15-0
//        功能	操作符	源操作数寄存器	目的操作数寄存器	立即数

//        J格式指令
//        标记	op	   address
//        位数	31-26	25-0
//        功能	操作符	地址

// R格式指令为纯寄存器指令，所有的操作数（除移位外）均保存在寄存器中。Op字段均为0，使用funct字段区分指令
// I格式指令为带立即数的指令，最多使用两个寄存器，同时包括了load/store指令。使用Op字段区分指令
// J格式指令为长跳转指令，仅有一个立即数操作数。使用Op字段区分指令

// lw $1, offset($2)  lw== load word,这条指令为把2号寄存器里的值加上offset常量，
// 计算出地址，然后拿这个地址的内存的32位字存到$1
// Load 用于把内存中的数据装载到寄存器中。$dest offset($source)
static void emit_load(char *dest_reg, int offset, char *source_reg, ostream& s)
{
  s << LW << dest_reg << " " << offset * WORD_SIZE << "(" << source_reg << ")" 
    << endl;
}

// Store用于把寄存器中的数据存入内存。
static void emit_store(char *source_reg, int offset, char *dest_reg, ostream& s)
{
  s << SW << source_reg << " " << offset * WORD_SIZE << "(" << dest_reg << ")"
      << endl;
}

static void emit_load_imm(char *dest_reg, int val, ostream& s)
{ s << LI << dest_reg << " " << val << endl; }

static void emit_load_address(char *dest_reg, char *address, ostream& s)
{ s << LA << dest_reg << " " << address << endl; }

static void emit_partial_load_address(char *dest_reg, ostream& s)
{ s << LA << dest_reg << " "; }

static void emit_load_bool(char *dest, const BoolConst& b, ostream& s)
{
  emit_partial_load_address(dest,s);
  b.code_ref(s);
  s << endl;
}

static void emit_load_string(char *dest, StringEntry *str, ostream& s)
{
  emit_partial_load_address(dest,s);
  str->code_ref(s);
  s << endl;
}

static void emit_load_int(char *dest, IntEntry *i, ostream& s)
{
  emit_partial_load_address(dest,s);
  i->code_ref(s);
  s << endl;
}

static void emit_move(char *dest_reg, char *source_reg, ostream& s)
{
    if(regEq(dest_reg, source_reg))
    {
        if(cgen_debug) {
            cerr << " Omitting move from"
                 << source_reg << " to " << dest_reg << endl;
            s << "#";
        }
    else return;
    }
    s << MOVE << dest_reg << " " << source_reg << endl;
}

static void emit_neg(char *dest, char *src1, ostream& s)
{ s << NEG << dest << " " << src1 << endl; }

// rd=rs+rt
static void emit_add(char *dest, char *src1, char *src2, ostream& s)
{ s << ADD << dest << " " << src1 << " " << src2 << endl; }

// rd=rs+rt（无符号数）
static void emit_addu(char *dest, char *src1, char *src2, ostream& s)
{ s << ADDU << dest << " " << src1 << " " << src2 << endl; }

// rd=rs+im（无符号数）
static void emit_addiu(char *dest, char *src1, int imm, ostream& s)
{ s << ADDIU << dest << " " << src1 << " " << imm << endl; }

static void emit_div(char *dest, char *src1, char *src2, ostream& s)
{ s << DIV << dest << " " << src1 << " " << src2 << endl; }

static void emit_binop(char* op, char *dest, cha *src1, char *src2, ostream& s)
{ s << op << dest << " " << src1 << " " << src2 << endl;}

static void emit_mul(char *dest, char *src1, char *src2, ostream& s)
{ s << MUL << dest << " " << src1 << " " << src2 << endl; }

static void emit_sub(char *dest, char *src1, char *src2, ostream& s)
{ s << SUB << dest << " " << src1 << " " << src2 << endl; }

static void emit_sll(char *dest, char *src1, int num, ostream& s)
{ s << SLL << dest << " " << src1 << " " << num << endl; }

static void emit_jalr(char *dest, ostream& s)
{ s << JALR << "\t" << dest << endl; }

//jal = jump and link
static void emit_jal(char *address,ostream &s)
{ s << JAL << address << endl; }

static void emit_return(ostream& s)
{ s << RET << endl; }

static void emit_copy(ostream& s)
{ s << JAL << "Object.copy" << endl;}

static void emit_gc_assign(ostream& s)
{ s << JAL << "_GenGC_Assign" << endl; }

static void emit_equality_test(ostream& s)
{ s << JAL << "equality_test" << endl;}

static void emit_case_abort(ostream& s)
{ s << JAL << "_case_abort" << endl;}

static void emit_case_abort2(ostream& s)
{ s << JAL << "_case_abort2" << endl;}

static void emit_dispatch_about(ostream& s)
{ s << JAL << "_dispatch_about" << endl;}

static void emit_disptable_ref(Symbol sym, ostream& s)
{  s << sym << DISPTAB_SUFFIX; }

static void emit_init_ref(Symbol sym, ostream& s)
{ s << sym << CLASSINIT_SUFFIX; }

static void emit_init(Symbol classname, ostream& s)
{
    s << JAL;
    emit_init_ref(classname,s);
    s << endl;
}

static void emit_label_ref(int l, ostream &s)
{ s << "label" << l; }

static void emit_protobj_ref(Symbol sym, ostream& s)
{ s << sym << PROTOBJ_SUFFIX; }

static void emit_method_ref(Symbol classname, Symbol methodname, ostream& s)
{ s << classname << METHOD_SEP << methodname; }

static void emit_label_def(int l, ostream &s)
{
  emit_label_ref(l,s);
  s << ":" << endl;
}

static void emit_beqz(char *source, int label, ostream &s)
{
  s << BEQZ << source << " ";
  emit_label_ref(label,s);
  s << endl;
}

static void emit_beq(char *src1, char *src2, int label, ostream &s)
{
  s << BEQ << src1 << " " << src2 << " ";
  emit_label_ref(label,s);
  s << endl;
}

static void emit_bne(char *src1, char *src2, int label, ostream &s)
{
  s << BNE << src1 << " " << src2 << " ";
  emit_label_ref(label,s);
  s << endl;
}

static void emit_bleq(char *src1, char *src2, int label, ostream &s)
{
  s << BLEQ << src1 << " " << src2 << " ";
  emit_label_ref(label,s);
  s << endl;
}

static void emit_blt(char *src1, char *src2, int label, ostream &s)
{
  s << BLT << src1 << " " << src2 << " ";
  emit_label_ref(label,s);
  s << endl;
}

static void emit_blti(char *src1, int imm, int label, ostream &s)
{
  s << BLT << src1 << " " << imm << " ";
  emit_label_ref(label,s);
  s << endl;
}

static void emit_bgti(char *src1, int imm, int label, ostream &s)
{
  s << BGT << src1 << " " << imm << " ";
  emit_label_ref(label,s);
  s << endl;
}

static void emit_branch(int l, ostream& s)
{
  s << BRANCH;
  emit_label_ref(l,s);
  s << endl;
}

//
// Push a register on the stack. The stack grows towards smaller addresses.
// 将寄存器压入堆栈。 堆栈向较小的地址增长。
static void emit_push(char *reg, ostream& str)
{
  emit_store(reg,0,SP,str); //$sp ,0($reg)
  emit_addiu(SP,SP,-4,str); //sp=sp-4
}

//
// Fetch the integer value in an Int object.
// 在Int对象中获取整数值。
// Emits code to fetch the integer value of the Integer object pointed
// to by register source into the register dest
// 发出代码以将寄存器源指向的Integer对象的整数值提取到寄存器dest中
static void emit_fetch_int(char *dest, char *source, ostream& s)
{ emit_load(dest, DEFAULT_OBJFIELDS, source, s); } //$dest <- $source

// 更新int对象中的整数值
// Emits code to store the integer value contained in register source
// into the Integer object pointed to by dest.
// 发出代码以将寄存器源中包含的整数值存储到dest指向的Integer对象中。
static void emit_store_int(char *source, char *dest, ostream& s)
{ emit_store(source, DEFAULT_OBJFIELDS, dest, s); } // $source <- $dest


static void emit_test_collector(ostream &s)
{
  emit_push(ACC, s);
  emit_move(ACC, SP, s); // stack end
  emit_move(A1, ZERO, s); // allocate nothing
  s << JAL << gc_collect_names[cgen_Memmgr] << endl;
  emit_addiu(SP,SP,4,s);
  emit_load(ACC,0,SP,s);
}

static void emit_gc_check(char *source, ostream &s)
{
  if (source != (char*)A1) emit_move(A1, source, s);
  s << JAL << "_gc_check" << endl;
}

///////////////////////////////////////////////////////////////////////////////
//
//  function_prologue
//  function_epilogue
//
//  这两个函数共同实现了调用约定的被调用方
//
//  需要n个临时变量并将其中的k个放入被调用者保存寄存器（$ s1- $ s6）
//  的堆栈框架具有以下布局：
//  （如果禁用了寄存器的分配，则k=0，否则的话，k = min{n,6}.）
//
//  ----------------
//  | actual arg 1 |
//  |    ...       |
//  | actual arg n |
//  ---------------- (*)
//  | caller's FP  |
//  |   "     self |
//  |   "      RA  |
//  |   "     $s1  |     (被调用者保存寄存器的情况)
//  |     ...      |
//  |   "     $sk  |
//  ---------------- (**)
//  | temporary k+1|
//  |    ...       |
//  | temporary  n | <- FP
//  ----------------
//  调用者负责将实际参数-（（*）上方的部分-）放在堆栈上。
//  在函数输入时，被调用方：
//
//  （1） 保存caller的帧指针，self指针和return地址(*)-(**)
//
//  （2） 在堆栈上为被调用者的临时对象分配空间，如果使用垃圾回收器，
//        则会清除这些临时对象（以便在堆栈上不存在任何垃圾）
//
//   (3)  设置callee的self和FP寄存器。
//
//   在功能退出时，the callee：
//  （1） 恢复调用者的帧指针，自身指针和返回地址
//  （2） 弹出堆栈的被调用者框架，包括实际参数
//
//////////////////////////////////////////////////////////////////////////////

//  在一个函数开始前所要执行的动作
static void function_prologue(CgenEnvironment* env, ostream& s)
{
    int num_temps = env->get_num_temps();
    // 上图中的reg_temps = k，而stack_temps = n-k
    int reg_temps = env->get_register_temps(); // 一共几个寄存器被使用？
    int stack_temps = env->get_stack_temps(); // 栈空间大小？
    assert ((reg_temps + stack_temps) == num_temps); // 总位置？

    // 此处的FP和RA不是很懂是什么
    emit_addiu(SP,SP,-(3 + num_temps) * WORD_SIZE,s); // 分配框架 sp = sp -(3+num_temps)*size
    emit_store(FP,3 + num_temps,SP,s); // 往内存中储存caller的FP  $SP 3+num_temps($FP)
    emit_store(SELF, 2 + num_temps, SP, s); // " " SELF $SP 2+num_temps($FP)
    emit_store(RA, 1+num_temps,SP,s); // " " RA
    emit_addiu(FP,SP,4,s); // 得到新的FP $FP = $SP + 4
    emit_move(SELF, ACC, s); // 设置SELF寄存器

    // 保存被调用者保存的寄存器
    for(int i=0;i<reg_temps;i++){
        // 保存寄存器的第一个插槽位于FP + num_temps-1。
        // 因此，第i个寄存器位于FP + num_temps-i-1
        emit_store(regNames[i],num_temps - i - 1, FP, s); // 保存caller的$si寄存器
    }

    // 清除临时的GC(临时内存吧)
    if(cgen_Memmgr != GC_NOGC)
        for (int i = 0 ; i < stack_temps ; i++)
            emit_store(ZERO, i , FP, s); // 把内存全部置零 $FP i(0)

    if(cgen_Memmgr_Debug == GC_DEBUG)
        emit_gc_check(SELF,s);
}

// 在一个函数结束前所要执行的动作
static void function_epilogue(CgenEnvironment* env, int num_formals,ostream& s)
{
    int num_temps = env->get_num_temps();

    if(cgen_Memmgr_Debug == GC_DEBUG)
        emit_gc_check(ACC, s);

    // 恢复callee-save的寄存器
    int reg_temps = env->get_register_temps();
    for(int i = 0; i < reg_temps;i++)
    {
        emit_load(regNames[i],num_temps -i -1, FP, s); // 恢复caller的$Si
    }

    emit_load(FP,3 + num_temps, SP, s); // 恢复caller的FP
    emit_load(SELF, 2 + num_temps, SP, s); // 恢复caller的SELF
    emit_load(RA,1 + num_temps,SP, s); // 恢复caller的RA

    emit_addiu(SP, SP, (3 + num_temps + num_formals) * WORD_SIZE, s); // $sp = $sp + (3+num_temps+num_formals)*size
    emit_return(s);
}

///////////////////////////////////////////////////////////////////////////////
//
// VarBinding和MethodBinding方法
//
// 从代码生成的角度来看，方法中有五种不同的名称类别：
//
// locals                             存储在堆栈帧的临时区域中
// formal parameters(形参)            存储在框架的实际值中
// self                               在SELF寄存器中
// attribute(属性)                    与SELF提供的地址有偏差
// method(方法)                       地址与调度表之间有一个偏移量
//
// 请参见function_prologue / epilogue下有关框架布局的讨论。
// 对于前四个类别，有用于生成用于分配，引用和更新的代码的不同约定。
// 对于方法，每个方法名称都引用某个祖先类中的方法。
//
// VarBinding是三个派生类的基类：
//
//  AttributeBinding(属性绑定)      记录对象中属性的偏移量。
//  LocalBinding(本地绑定)          记录局部变量或形式参数与帧指针的偏移量。
//                                  由于局部变量和形式变量相对于框架指针放置在不同的区域，
//                                  因此存在创建局部和形式绑定的单独方法。
//  SelfBinding(自我绑定)           The self object.
//
//  VarBinding具有虚拟函数，用于生成用于引用和更新各种变量的代码。
//
//  MethodBindings是由方法名称和定义方法的类组成的对。
//  类的每个方法都需要此信息来定义类的调度表。
//
///////////////////////////////////////////////////////////////////////////////

VarBinding::VarBinding(int i) : offset(i){}

MethodBinding::MethodBinding(Symbol mn, Symbol cn) :
method_name(mn),class_name(cn)
{}
//
//  code_ref生成调度表条目。
//
void MethodBinding::code_ref(ostream& s)
{
    s << WORD;
    emit_method_ref(class_name,method_name,s);
    s << endl;
}

AttributeBinding::AttributeBinding(int i) : VarBinding(i){}

Register AttributeBinding::code_ref(char *dest, ostream &)
{
    if (cgen_debug) cerr << " Attribute store to offset " << offset << endl;
    emit_store(source, offset + DEFAULT_OBJFIELDS, SELF, s); // $source offset+DE(SELF)

    if (cgen_Memmgr_Debug == GC_DEBUG)
        emit_gc_check(source, s);

    if (cgen_Memmgr == GC_GENGC){
        /* 记忆写的地址 */
        emit_addiu(A1, SELF, WORD_SIZE * (offset + DEFAULT_OBJFIELDS), s); // $A1 = SELF + WORD_SIZE * (of + DE)
        emit_gc_check(s);
    }
}

SelfBinding::SelfBinding() : VarBinding(0){}

Register SelfBinding::code_ref(char *dest, ostream &)
{
    emit_move(dest,SELF,s);
    return dest;
}

//
//  如果每次都对自身进行更新，则会导致代码生成错误。
//
void SelfBinding::code_update(char *, ostream &)
{
    cerr << "Cannot assign to self." ;
    exit(1);
}

LocalBinding::LocalBinding(int i, CgenEnvironmentP env) : VarBinding(i)
{
    env = env_;
}

Register LocalBinding::code_ref(char *dest, ostream &)
{
    Register reg = env->get_register(offset); // 寻找该偏移量对应的寄存器
    if (reg != NULL)
    {
        if (cgen_debug) cerr << " Local read from register" << reg <<endl;
        return reg;
    }
    else
    {
        if (cgen_debug) cerr << " Local load from FP offset" << offset <<endl;
        emit_load(dest, offset, FP, s); // $dest offset($FP)
    }
}

void LocalBinding::code_ref_force_dest(char *dest, ostream &os)
{
    Register result = code_ref(dest, s);
    emit_move(dest, result, s); // 如果结果=目标，则省略
}

void LocalBinding::code_update(char *source, ostream &)
{
    Register reg = env->get_register(offset);
    if (reg != NULL)
    {
        if (cgen_debug) cerr << " Local store to register"
                        << reg << endl;
        emit_move(reg, source, s);
    }
    else
    {
        if (cgen_debug) cerr << " Local store to FP offset" << offset << endl;
        emit_store(source, offset, FP, s);
    }
}

Register LocalBinding::get_register()
{
    return env->get_register(offset);
}
///////////////////////////////////////////////////////////////////////////////
//
// coding strings, ints, and booleans
// 编码字符串，整数和布尔值
//
// Cool has three kinds of constants: strings, ints, and booleans.
// This section defines code generation for each type.
// Cool具有三种常量：字符串，整数和布尔值。 本节定义每种类型的代码生成。
//
// All string constants are listed in the global "stringtable" and have
// type StringEntry.  StringEntry methods are defined both for String
// constant definitions and references.
// 所有字符串常量都列在全局“字符串表”中，并且类型为StringEntry。
// 同时为String常量定义和引用定义了StringEntry方法。
//
// All integer constants are listed in the global "inttable" and have
// type IntEntry.  IntEntry methods are defined for Int
// constant definitions and references.
// 所有整数常量都在全局“ inttable”中列出，并且类型为IntEntry。
// IntEntry方法是为Int常量定义和引用定义的。
// Since there are only two Bool values, there is no need for a table.
// The two booleans are represented by instances of the class BoolConst,
// which defines the definition and reference methods for Bools.
// 由于只有两个布尔值，因此不需要表。
// 这两个布尔值由BoolConst类的实例表示，该类定义了Bools的定义和引用方法。
//
///////////////////////////////////////////////////////////////////////////////

//
// Strings
//
void StringEntry::code_ref(ostream& s)
{
  s << STRCONST_PREFIX << index;
}

//
// Emit code for a constant String.
// You should fill in the code naming the dispatch table.
//

void StringEntry::code_def(ostream& s, int stringclasstag)
{
  IntEntryP lensym = inttable.add_int(len);

  // Add -1 eye catcher
  s << WORD << "-1" << endl;

  code_ref(s);  s  << LABEL                                             // label
      << WORD << stringclasstag << endl                                 // tag
      << WORD << (DEFAULT_OBJFIELDS + STRING_SLOTS + (len+4)/4) << endl // size
      << WORD; emit_disptable_ref(idtable.lookup_string(STRINGNAME),s);
      s << endl;                                              // dispatch table
      s << WORD;  lensym->code_ref(s);  s << endl;            // string length
  emit_string_constant(s,str);                                // ascii string
  s << ALIGN;                                                 // align to word
}

//
// StrTable::code_string
// Generate a string object definition for every string constant in the 
// stringtable.
// 为字符串表中的每个字符串常量生成一个字符串对象定义。
void StrTable::code_string_table(ostream& s, int stringclasstag)
{  
  for (List<StringEntry> *l = tbl; l; l = l->tl())
    l->hd()->code_def(s,stringclasstag);
}

//
// Ints
//
void IntEntry::code_ref(ostream &s)
{
  s << INTCONST_PREFIX << index;
}

//
// Emit code for a constant Integer.
// You should fill in the code naming the dispatch table.
//

void IntEntry::code_def(ostream &s, int intclasstag)
{
  // Add -1 eye catcher
  s << WORD << "-1" << endl;

  code_ref(s);  s << LABEL                                // label
      << WORD << intclasstag << endl                      // class tag
      << WORD << (DEFAULT_OBJFIELDS + INT_SLOTS) << endl  // object size
      << WORD; emit_disptable_ref(idtable.lookup_string(INTNAME),s);
      s << endl;                                          // dispatch table
      s << WORD << str << endl;                           // integer value
}


//
// IntTable::code_string_table
// Generate an Int object definition for every Int constant in the
// inttable.
// 为inttable中的每个Int常量生成一个Int对象定义。
void IntTable::code_string_table(ostream &s, int intclasstag)
{
  for (List<IntEntry> *l = tbl; l; l = l->tl())
    l->hd()->code_def(s,intclasstag);
}


//
// Bools
//
BoolConst::BoolConst(int i) : val(i) { assert(i == 0 || i == 1); }

void BoolConst::code_ref(ostream& s) const
{
  s << BOOLCONST_PREFIX << val;
}
  
//
// Emit code for a constant Bool.
// You should fill in the code naming the dispatch table.
//

void BoolConst::code_def(ostream& s, int boolclasstag)
{
  // Add -1 eye catcher
  s << WORD << "-1" << endl;

  code_ref(s);  s << LABEL                                  // label
      << WORD << boolclasstag << endl                       // class tag
      << WORD << (DEFAULT_OBJFIELDS + BOOL_SLOTS) << endl   // object size
      << WORD; emit_disptable_ref(idtable.lookup_string(BOOLNAME),s);
      s << endl;                                            // dispatch table
      s << WORD << val << endl;                             // value (0 or 1)
}

//////////////////////////////////////////////////////////////////////////////
//
//  CgenClassTable methods
//
//////////////////////////////////////////////////////////////////////////////

//
//  为某些基本类及其标签定义全局名称.
//
void CgenClassTable::code_global_data()
{
    Symbol main         = idtable.lookup_string(MAINNAME);
    Symbol string       = idtable.lookup_string(STRINGNAME);
    Symbol integer      = idtable.lookup_string(INTNAME);
    Symbol boolc        = idtable.lookup_string(BOOLNAME);

    str << "\t.data\n" << ALIGN;
    //
    //  必须首先定义以下全局名称。
    //
    str << GLOBAL << CLASSNAMETAB << endl;
    str << GLOBAL ; emit_protobj_ref(main,str); str << endl;
    str << GLOBAL ; emit_protobj_ref(integer,str); str << endl;
    str << GLOBAL ; emit_protobj_ref(string,str); str << endl;
    str << GLOBAL ; falsebool.code_ref(str);    str<<endl;
    str << GLOBAL ; truebool.code_ref(str);     str<<endl;
    str << GLOBAL << INTTAG << endl;
    str << GLOBAL << BOOLTAG << endl;
    str << GLOBAL << STRINGTAG << endl;

    //
    //  我们还需要在代码生成过程中了解Int，String和Bool类的标签。
    //
    str << INTTAG << LABEL
        << WORD << *class_to_tag_table.lookup(integer) << endl;
    str << BOOLTAG << LABEL
        << WORD << *class_to_tag_table.lookup(boolc) << endl;
    str << STRINGTAG << LABEL
        << WORD << *class_to_tag_table.lookup(string) << endl;
}

void CgenClassTable::code_global_text()
{
    str << GLOBAL << HEAP_START << endl
        << HEAP_START << LABEL
        << WORD << 0 << endl;
        << "\t.text" << endl;
        << GLOBAL;
    emit_init_ref(idtable.add_string("Main"),str);
    str << endl << GLOBAL;
    emit_init_ref(idtable.add_string("Int"),str);
    str << endl << GLOBAL;
    emit_init_ref(intable.add_string("String"), str);
    str << endl << GLOBAL;
    emit_init_ref(idtable.add_string("Bool"),str);
    str << endl << GLOBAL;
    emit_method_ref(idtable.add_string("Main"),idtable.add_string("main"),str);
    str << endl ;
}

void CgenClassTable::code_bools()
{
    int boolclasstag = *class_to_tag_table.lookup(idtable.add_string(BOOLNAME));
    falsebool.code_def(str,boolclasstag);
    truebool.code_def(str,boolclasstag);
}

//
//  生成GC选择常量（指向GC函数的指针）
//
void CgenClassTable::code_select_gc()
{
    str << GLOBAL << "_MemMgr_INITALIZER" << endl;
    str << "_MemMgr_INITALIZER:" << endl;
    str << WORD << gc_init_names[cgen_Memmgr] << endl;
    str << GLOBAL << "_MemMgr_COLLECTOR" << endl;
    str << "_MemMgr_COLLECTOR:" << endl;
    str << WORD << gc_collect_names[cgen_Memmgr] << endl;
    str << GLOBAL << "_MemMgr_TEST" << endl;
    str << "_MemMgr_TEST:" << endl;
    str << WORD << (cgen_Memmgr_Test == GC_TEST) << endl;
}

//
//  添加代码生成器所需的常量。
//
void CgenClassTable::code_constants()
{
    stringtable.add_string("");
    inttable.add_string("0");

    int stringclasstag = *class_to_tag_table.lookup(idtable.look_string(STRINGNAME));
    int intclasstag = *class_to_tag_table,lookup(idtable.look_strinng(INTNAME));

    stringtable.code_string_table(str,stringtag);
    inttable.code_strinng_table(str,intclasstag);
    code_bools();
}

//
//  类名表是从类标签->类名的映射。
//
void CgenClassTable::code_table()
{
    str << CLASSNAMETAB << LABEL;
    for(int i =0; i < num_classes; i++)
    {
        StringEntry *c = tag_to_class_table.lookup(i);
        assert(c != NULL);
        str << WORD;
        c->code_ref(str);
        str << endl;
    }
}

//
//  类对象表是从类标签->类原型对象地址的映射
//
void CgenClassTable::code_object_table()
{
    str << CLASSOBJTAB << LABEL;
    for(int i=0; i < num_classes; i++)
    {
        Symbol c = tag_to_class_table.lookup(i);
        assert(c != NULL);
        str << WORD;
        emit_protobj_ref(c,str);
        str << endl << WORD;
        emit_init_ref(c,str);
        str << endl;
    }
}

//
//  CgenClassTable构造函数实际上完成了代码生成的所有工作：
//  构建继承图，计算布局信息并对每个类进行编码。
//
CgenClassTable::CgenClassTable(Classes classes, ostream& s) : nds(NULL) , str(s)
{
    if (cgen_debug) cerr << "Building CgenClassTable" << endl;
    num_classes = 0;

    // 确保各个表都有范围
    class_to_tag_table.enterscope();
    class_to_max_child_tag_table.enterscope();
    tag_to_class_table.enterscope();
    table_of_method_tables.enterscope();

    enterscope();
    install_basic_classes();
    install_class(classes);
    build_inheritance_tree();
    root()->init(0,
                ,*(new SymbolTable<Symbol,int>)
                ,*(new SymbolTable<int,MethodBinding>)
                ,0
                ,*(new SymbolTable<Symbol,VarBinding>)
                ,*(new Symboltable<int,Entry>));
    code();
    exitscope();
}

///////////////////////////////////////////////////////////////////////////
//
// Building the inheritance graph.
// 建立继承图
// A replay of the code from semantic analysis, without the error checking.
// 从语义分析中重播代码，而无需进行错误检查。
///////////////////////////////////////////////////////////////////////////

void CgenClassTable::install_basic_classes()
{
    // 树包使用这些全局变量来注释下面构建的类。
    node_lineno = 0;
    Symbol filename = stringtable.add_string("<basic class>");

    // 在查找表中安装了一些特殊的类名，但没有安装类列表。 因此，这些类存在，但不属于继承层次结构。
    // No_class充当Object和其他特殊类的父级。 SELF_TYPE是自类； 它不能重新定义或继承。
    // prim_slot是代码生成器已知的类。
    addid(No_class,
            new CgenNode(class_(No_class,No_class,nil_Features(),filename),
                    Basic,this));
    addid(SELF_TYPE,
            new CgenNode(class_(SELF_TYPE,No_class,nil_Features(),filename),
                    Basic,this));
    addid(prim_slot,
            new CgenNode(class_(prim_slot,No_class,nil_Features(),filename),
                    Basic,this));
    // Object类没有父类。 其方法是
    // cool_abort() : Object 中止程序
    // type_name() : Str  返回类名称的字符串表示形式
    // copy() : SELF_TYPE  返回对象的副本
    // 基本类中不需要方法主体-这些主体已经内置在运行时系统中。
    //
    install_class(
            new CgenNode(
                    class_(Object,
                            No_class,
                            append_Features(
                            append_Features(
                            single_Features(method(cool_abort,nil_Formals(),Object,no_expr()))
                            single_Features(method(type_name,nil_Formals(),Str,no_expr()))),
                            single_Features(method(copy,nil_Formals(),SELF_TYPE,no_expr()))),
                            filename),
                    Basic,this)
            );

    //
    // IO类继承自Object。 其方法是
    // out_string(Str) : SELF_TYPE  将字符串写入输出
    // out_int(Int) : SELF_TYPE     "   an int "    "   "
    // in_string() : Str    从输入中读取一个字符串
    // in_int() : Int   " an int " " "
    //
    install_class(
            new CgenNode(
                    class_(
                            IO,
                            Object,
                            append_Features(
                            append_Features(
                            append_Features(
                            single_Features(method(out_string,single_Formals(formal(arg,Str))),
                                    SELF_TYPE,no_expr())),
                            single_Features(method(out_int,single_Formals(formal(arg,Int)),
                                    SELF_TYPE,no_expr()))),
                            single_Features(method(in_string,nil_Formals(),Str,no_expr()))),
                            single_Features(method(in_int,nil_Formals(),Int,no_expr()))),
                            filename),
            Basic,this)


//
//  Int类没有方法，只有一个属性，即整数的“ val”。
//
install_class(
        new CgenNode(
                class_(Int,
                        Object,
                        single_Features(attr(val,prim_slot,no_expr())),
                        filename),
Basic,this)
        );

//
//  bool也只有“ val”插槽。
//
install_class(
        new CgenNode(
                class_(Bool,Object,single_Features(attr(val,prim_slot,no_expr())),filename),
                Basic,this)
        );

//
//  Str类具有许多插槽和操作：
//  val                                 字符串的长度
//  str_field                           the string itself
//  length() : Int                      length of the string
//  concat(arg: Str) : Str              字符串串联
//  substr(arg: Int, arg2: Int): Str    子串
install_class(
new CgenNode(
        class_(Str,
               Object,
               append_Features(
                       append_Features(
                               append_Features(
                                       append_Features(
                                               single_Features(attr(val, Int, no_expr())),
                                               single_Features(attr(str_field, prim_slot, no_expr()))),
                                       single_Features(method(length, nil_Formals(), Int, no_expr()))),
                               single_Features(method(concat,
                                                      single_Formals(formal(arg, Str)),
                                                      Str,
                                                      no_expr()))),
                       single_Features(method(substr,
                                              append_Formals(single_Formals(formal(arg, Int)),
                                                             single_Formals(formal(arg2, Int))),
                                              Str,
                                              no_expr()))),
               filename),
        Basic,this));

}

// CgenClassTable::install_class
// CgenClassTable::install_classes
//
// install_classes在符号表中输入类别列表。
// 检查以下可能的错误：
// - a class called SELF_TYPE (class被自身调用，循环?)
// - redefinition of a basic class （基类被重定义)
// - redefinition of another previously defined class (-重新定义另一个先前定义的类)
//
void CgenClassTable::install_class(CgenNodeP nd)
{
    Symbol name = nd->get_name();
    // 此处应该是对类名是否存在上述三种错误进行检测
    if(probe(name))
    {
        return;
    }

    // 类名是合法的，因此将其添加到类列表和符号表中。
    nds = new List<CgenNode>(nd,nds);
    addid(name,nd);
}

void CgenClassTable::install_classes(Classes cs)
{
    for(int i = cs->first();cs->more(i);i=cs->next(i))
        install_class(new CgenNode(cs->nth(i),NotBasic,this));
}

void CgenClassTable::build_inheritance_tree()
{
    for(List<CgenNode> *l = nds;l;l=l->tl())
        set_relations(l->hd());
}

//
// CgenClassTable::set_relations
//
// 获取一个CgenNode并通过类表定位其及其父代的继承节点。 适当添加父和子指针。
//

// nd和其父节点建立关系
void CgenClassTable::set_relations(CgenNodeP nd)
{
    CgenNode *parent_node = probe(nd->get_parent());// ？没看懂
    nd->set_parentnd(parent_node); // 设定nd的父节点为parent_node
    parent_node->add_child(nd); // 确立parent_node的子节点为nd
}

// 添加子节点表？
void CgenNode::add_child(CgenNodeP n)
{
    children = new List<CgenNode>(n,children); //n为List的开始地址，children为List结束地址
}

// 确定父节点？
void CgenNode::set_parentnd(CgenNodeP p)
{
    assert(parentnd == NULL);
    assert(p != NULL);
    parentnd = p;
}

int CgenClassTable::assign_tag(Symbol name)
{
    assert(! class_to_tag_table.lookup(name));
    assert(! tag_to_class_table.lookup(num_classes));

    class_to_tag_table.addid(name,new int(num_classes));
    tag_to_class_table.addid(num_classes,string,stringtable.add_string(name->get_string()));
}

void CgenClassTable::set_max_child(Symbol name, int tag)
{
    assert(! class_to_max_child_tag_table.lookup(name));

    class_to_max_child_tag_table.addid(name,new int(tag));
}
//找最后一个的？
int CgenClassTable::last_tag()
{
    assert(num_classes !=0);
    return num_classes -1;
}

//为那个节点添加方法的？
void CgenClassTable::add_method_table(Symbol name, SymbolTable<int> *method_table)
{
    assert(! table_of_method_tables.lookup(name));
    table_of_method_tables.addid(name,method_table);
}

void CgenClassTable::code()
{
    if (cgen_debug) cerr << "coding global data" << endl;
    code_global_data();

    if (cgen_debug) cerr << "choosing gc" << endl;
    code_select_gc();

    if (cgen_debug) cerr << "coding constants" << endl;
    code_constants();

    if (cgen_debug) cerr << "coding class table" << endl;
    code_class_table();

    if (cgen_debug) cerr << "coding object table" << endl;
    code_object_table();

    if (cgen_debug) cerr << "coding dispatch tables" << endl;
    root()->code_dispatch_table(str);
//
// 检查是否安装了编码原型对象所需的字符串。
//
    assert(inttable.lookup_string("0"));
    assert(stringtable.lookup_string(""));
    assert(idtable.lookup_string(INTNAME));
    assert(idtable.lookup_string(STRINGNAME));
    assert(idtable.lookup_string(BOOLNAME));

    if (cgen_debug) cerr << "coding prototypes" << endl;
    root()->code_prototype_object(str);

    if (cgen_debug) cerr << "coding global text" << endl;
    code_global_text();

    CgenEnvTopLevelP env = new CgenEnvTopLevel(&class_to_tag_table,
                                               &class_to_max_child_tag_table,
                                               &table_of_method_tables,
                                               num_classes);

    if (cgen_debug) cerr << "coding init methods" << endl;
    root()->code_init(str,env);

    if (cgen_debug) cerr << "coding methods" << endl;
    root()->code_methods(str,env);
}

CgenNodeP CgenClassTable::root()
{
    return probe(Object);
}

///////////////////////////////////////////////////////////////////////
//
// CgenNode methods
//
///////////////////////////////////////////////////////////////////////

CgenNode::CgenNode(Class_ c, Basicness bstatus, CgenClassTableP class_table)
    : class__class((const class__class &) *nd),
      parentnd(NULL),
      children(NULL),
      basic_status(bstatus),
      num_methods(0),
      method_name_to_offset_table(),
      method_offset_to_binding_table(),
      first_attribute(0),
      num_attributes(0),
      var_binding_table(),
      attribute_proto_table(),
      class_table(ct)
{}
//
// 使用来自另一个CgenNode（X的父级）的信息初始化CgenNodeX。
//

void CgenNode::init(int nm,
                    SymbolTable<Symbol,int> mntot,
                    SymbolTable<int,MethodBinding> motbt,
                    int fa,
                    SymbolTable<Symbol,VarBinding> vbt,
                    SymbolTable<int,Entry> apt)
{
    num_methods = nm;
    method_name_to_offset_table = mntot;
    method_offset_to_binding_table = motbt;
    first_attribute = fa;
    var_binding_table = vbt;
    attribute_proto_table = apt;


    if (cgen_debug) cerr << "Building CgenNode for " << name << endl;
    class_tag = class_table->assign_tag(name);

    //
    // 方法和属性是从父类继承的。
    // 单独的作用域用于使子属性与父属性保持不同，并允许重新定义方法。
    //
    method_name_to_offset_table.enterscope();
    method_name_to_numtemps_table.enterscope();
    method_offset_to_binding_table.enterscope();
    var_binding_table.enterscope();
    attribute_proto_table.enterscope();

    //
    //  每个类都只关心初始化其自己的属性，因此属性init表不需要父类的信息。
    //
    attribute_init_table = *(new SymbolTable<int,attr_class>);
    attribute_init_table.enterscope();

    // 为类的每个功能生成布局信息
    for(int i = features->first();features->more(i);i = features->next(i))
        features->nth(i)->layout_feature(this);

    //
    //  所有子类的下一个属性将分配给插槽
    //
    int next_attribute = first_attribute + num_attributes;

    //
    //  递归地布置每个子类。
    //  有关父级布局的信息从父级传递到子级。 子类列表也已构建。
    //
    List<CgenNode> *child = children;
    children = NULL;
    for(; child; child = child->tl()){
        child->hd()->init(num_methods,
                method_name_to_numtemps_table,
                method_offset_to_binding_table,
                next_attribute,
                var_binding_table,
                attribute_init_table);
        children = new List<CgenNode>(child->hd(),children); // 反向树的遍历顺序与旧代码相同
    }
    //
    //  记录最大的后代类标记。 因为类的编号顺序是深度优先，
    //  所以如果A的标签位于B的范围内，则类A是B的子类。
    //  B's tag <= A's tag <= (max descendant of B)'s tag
    //

    // 深度优先遍历，也就是查到继承图的最底
    max_child = class_table->last_tag();
    class_table->set_max_child(name,max_child);

    if (cgen_debug) cerr << "For class" << name << " tag is " << class_tag <<
        " and max child is " << max_child << endl;
    //  将方法表添加到方法表的表中
    class_table->add_method_table(name, &method_name_to_offset_table);
}

//
//  layout_method在该类的分配表中分配方法插槽。
//  它还确保更新逆映射偏移量->绑定，并记录方法临时数。
//  必须先在表中查看该方法，因为可以通过继承类重新定义方法。
//
//
void CgenNode::layout_method(Symbol mname, int numtemps)
{
    int offset;

    if (method_name_to_offset_table.lookup(mname))
        offset = *(method_name_to_offset_table.lookup(mname));
    else
        offset = num_methods++;

    if (cgen_debug) cerr << " Method: " << mname << " Class: " << name <<
    " dispatch table offset: " << offset << endl;
    method_name_to_offset_table.addid(mname,new int(offset));
    method_offset_to_binding_table.addid(offset,new MethodBinding(name,mname));
    method_name_to_numtemps_table.addid(name,new int(numtemps));
}

//
//  布局属性为属性分配对象中的位置。
//  无需测试属性是否已经具有由祖先类分配的位置，
//  因为（与方法不同）无法重新定义属性。
//  还将记录信息，以初始化属性和生成类的原型对象。
//
void CgenNode::layout_attribute(Symbol name, attr_class *a, int init)
{
    int offset = first_attribute + num_attributes++;
    var_binding_table.addid(aname,new AttributeBinding(offset));
    if (init) attribute_init_table.addid(offset,a);
    attribute_proto_table.addid(offset,a->get_type_decl());
    if (cgen_debug) cerr << " Attribute: " << aname << " Class: " << name <<
    " offset: " << offset << " initialization : " << (init ?"yes":"no") << endl;
}

void CgenNode::code_disptable_ref(ostream &str)
{
    emit_disptable_ref(name,str);
}

//
//  编写一个类的调度表，然后编写该类的子级的调度表。
//
void CgenNode::code_dispatch_table(ostream & str)
{
    code_disptable_ref(str);
    str << LABEL;
    for(int i = 0; i < num_methods; i++)
        method_offset_to_binding_table.lookup(i)->code_ref(str);

    for(List<CgenNode> *l = children;l;l = l->tl())
        l->hd()->code_dispatch_table(str);
}

void CgenNOde::code_protoobj_ref(ostream& str)
{
    emit_protobj_ref(name,str);
}

void CgenNode::code_prototype_object(ostream &str)
{
    // 将-1标头放入垃圾收集器
    str << WORD << "-1" << endl;

    code_protoobj_ref(str);

    //  原型对象必须具有类的所有属性（包括继承的属性）的插槽。
    //  此类属性的数量是该类的第一个属性索引加上该类中定义的属性的数量。
    int total_attributes = first_attribute + num_attributes;
    str << LABEL
        << WORD << class_tag << endl
        << WORD << (total_attributes + DEFAULT_OBJFIELDS) << endl
        << WORD;
    code_disptable_ref(str);
    str<<endl;

    for(int i : total_attributes)
    {
        str << WORD;

        Symbol type_decl = attribute_proto_table.lookup(i);

        if (idtable.look_string(INTNAME) == type_decl)
            inttable.lookup_string("0")->code_ref(str);
        else if (idtable.lookup_string(STRINGNAME) == type_decl)
            stringtable.lookup_string("")->code_ref(str);
        else if (idtable.lookup_string(BOOLNAME) == type_decl)
            falsebool.code_ref(str);
        else
            str << EMPTYSLOT;
        str << endl;
    }

    for(List<CgenNode> *l = children; l;l=l->tl())
        l->hd()->code_prototype_object(str);
}

//
//  如果该类不是基本类，则为该类中的每个方法生成代码。
//  完成后，递归为每个子类的每个方法生成代码。
//
void CgenNode::code_methods(ostream &str, CgenEnvTopLevelP e)
{
    if (basic_status == NotBasic)
    {
        CgenEnvClassLevelP env = new CgenEnvClassLevel(
                e,&method_name_to_offset_table,var_binding_table.
                name,filename
                );
        for(int i = features->first(); features->more(i);i = features->next(i))
            features->nth(i)->code_method(str,env);
    }

    for(List<CgenNode> *l = children ; l; l = l->tl())
        l->hd()->code_methods(str,e);
}

//
//  复制原型后，此代码称为“新”。
//  该代码必须调用父类的init函数才能初始化继承的属性。
//  它还必须用实际的分派表覆盖dipatch表指针，并执行插槽初始化。
//
//  指向对象的指针在ACC中。
void CgenNode::code_init(ostream &str, CgenEnvTopLevelP e)
{
    int i;

    if (cgen_debug) cerr<< "Coding init method of class " << name <<
        " first attribute: " << first_attribute << " # attribute: "
        << num_attributes << endl;
    code_init_ref(str);
    str << LABEL;

    CalcTempP n = new CalcTemp();
    for(i = first_attribute; i < first_attribute + num_attributes; i++)
        if (attribute_init_table.lookup(i))
            attribute_init_table.lookup(i)->calc_temps(n);
        int num_temps = n->get_max();
        if (cgen_debug) cerr << "Number of temporaries =" << num_temps << endl;

        CgenEnvClassLevelP  classenv =
                new CgenEnvClassLevel(e,
                        &method_name_to_offset_table,
                        var_binding_table,
                        name,
                        filename);

        CgenEnvironmentP env = new CgenEnvironment(classenv, nil_Formals(),num_temps);

        function_prologue(env,str);
        if (this != class_table->root()) // root has no parent
            emit_init(parent,str);
        emit_move(ACC,SELF,str);
        function_epilogue(env,0,str);

        for(List<CgenNode> *l = children ; l; l = l->tl())
            l->hd()->code_init(str,e);
}

/////////////////////////////////////////////////////////////////////////////
//
// Methods for:
// CgenEnvTopLevel
// CgenEnvClassLevel
// CgenEnvironment
//
//  使用为表达式中的免费名称提供含义（即布局信息）的环境来实现表达式的代码生成。
//  除了可用的变量和方法名称之外，还需要提供类名称和文件名（生成运行时错误消息的代码所需要），
//  以及用于生成唯一标签的全局计数器。 此环境由类CgenEnvironment实现。
//
//  CgenEnvironment所需的信息在三个地方维护：
//  一些保存在CgenClassTable中，一些保存在每个类的各个CgenNodes中，
//  而另一些仅保存在单独的方法中。
//  因此，一种方法的CgenEnvironment是分阶段构建的。 对应关系为：
//   CgenClassTable   defines a   CgenEnvTopLevel
//   CgenNode         defines a   CgenEnvClassLevel
//   method_class     defines a   CgenEnvironment
//
//  CgenEnvX类按继承层次结构排列，其中ClassLevel继承自TopLevel，
//  而Environment继承自ClassLevel。 对于TopLevel和ClassLevel类，
//  仅提供构造函数，从而允许将其环境信息不透明地传递到较低级别。
//  CgenEnvironment类提供了用于编码表达式的接口函数。
//
//   CgenEnvTopLevel contributes:
//          a table mapping class names to class tags
//          a table mapping class names to the max tag of any descendant class
//          a table of all method tables (class name -> method name -> offset)
//
//  CgenEnvClassLevel constributes:
//          a table mapping methods in the current class to offsets
//          the class name
//          the name of the file where the class is defined
//          a table mapping variables to VarBindings
//
//  除var_binding_table外，表仅由Environment方法引用。
//  由于表达式具有局部变量，因此将安装新绑定并将其从var_binding_table中删除。
//  因此，CgenEnvironment构造函数将复制var_binding_table结构；
//  所有其他表都是通过指针引用的。
//
//  每种方法都将构建自己的CgenEnvironment。 所需的最终信息是：
//  the formal parameters of the method         方法的形式参数
//  the number of temporary variables needed    所需的临时变量数
//
/////////////////////////////////////////////////////////////////////////////

//
//  next_label是所有CgenEnvironments的成员。 声明为静态（所有实例共享）以确保标签唯一。
//
int CgenEnvironment::next_label = 0;

CgenEnvironment::CgenEnvironment(CgenEnvClassLevelP env, Formals formals, int num_temporaries)
            : CgenEnvClassLevel(*env),num_temps(num_temporaries)
{
    // 第一个本地变量的地址
    next_temp_location = -1 * get_register_temps();

    // 第一个正式文件位于堆栈帧的最高地址，该地址超出了所有临时文件（num_temporaries），
    // 被调用方保存区域（3个字）以及正式文件的末尾（formals-> len（）-1）。
    next_formal = num_temporaries +2 + formals->len();

    // 将所有形式的绑定添加到可变环境
    for(int i = formals->first;formals->more(i);i = formals->netx(i))
        add_formal(formals->nth(i)->get_name());

    //  确保对自我的约束
    var_binding_table.addid(self,new SelfBinding);
}

//
//  利用所给的class name,寻找class tag
//
int CgenEnvironment::lookup_tag(Symbol sym)
{
    int *tag = class_to_tag_table->lookup(sym);
    assert(tag);
    return *tag;
}

//
//  提供class name，找到子类中最大的tag
//
int CgenEnvironment::lookup_child_tag(Symbol sym)
{
    int *tag = class_to_max_child_tag_table->lookup(sym);
    assert(tag);
    return *tag;
}

//
//  给定一个类名和一个方法名，在类的分派表中找到该方法的偏移量。
//  如果类名不是SELF_TYPE，则使用全局方法表。
//  否则，将使用该类的方法表。
int CgenEnvironment::lookup_method(Symbol classname, Symbol methodname)
{
    SymbolTable<Symbol,int> *table =
            (classname == SELF_TYPE) ? method_name_to_offset_table :
                                        table_of_method_tables->lookup(classname);
    assert(table);
    int *offset = table->lookup(methodname);
    assert(offset);
    return *offset;
}

//
//  获取变量的绑定。 假定查找的任何变量实际上应该具有绑定。
//
VarBinding *CgenEnvironment::lookup_var(Symbol sym)
{
    if (cgen_debug) cerr<< " looking up binding for " << sym << endl;
    VarBinding * v = var_binding_table.lookup(sym);
    assert(v);
    return v;
}

//
//  添加局部变量。 负数是寄存器，正数是堆栈插槽。
//
void CgenEnvironment::add_local(Symbol sym)
{
    if (cgen_debug) cerr << " Adding local binding " << sym << " " << next_temp_location << endl;
    var_binding_table.enterscope();

    //
    //  验证表达式的编码与所需临时数量的计算是否一致。
    //
    assert(next_temp_location < get_stack_temps());
    var_binding_table.addid(sym,new LocalBinding(next_temp_location,this));
    next_temp_location++;
}

//
//  添加一个正式参数。 形式分配在堆栈帧的形式区域中递减的内存地址处。
//
void CgenEnvironment::add_formal(Symbol sym)
{
    if (cgen_debug) cerr << " Adding formal binding " << sym << " " << next_temp_location << endl;
    var_binding_table.enterscope();
    var_binding_table.addid(sym, new LocalBinding(next_formal--,this));
}

//
//  删除局部变量，以释放其在堆栈框架中的插槽。
//
void CgenEnvironment::remove_local()
{
    if (cgen_debug) cerr << " Removing local binding." << endl;
    var_binding_table.exitscope();
    --next_temp_location;
}

//
//  分配一个新标签并撞击计数器。 请注意，next_label是静态的，因此保证标签是唯一的。
//
int CgenEnvironment::label()
{
    return next_label++;
}

//
//  由LocalBinding使用。
//  如果将由指定偏移量表示的局部变量存储在寄存器中，则返回该寄存器的名称。
//
//  Returns NULL if
//  1)  禁用寄存器分配
//  2)  偏移量是形式变量
//  3)  偏移量是没有足够寄存器的本地地址
//
//  局部变量存储如下:
//  如果有足够的寄存器将N个存储在本地，则将他们存储在:
//  sN, sN-1, ... s1.
//  否则的话，存储在:
//  s6, s5,  ..., s1, 0($FP), 4($FP), ... 4*(n-6)($FP)
//  负值“偏移”表示它在寄存器中。
//
Register CgenEnvironment::get_register(int offset)
{
    assert(offset >= -1 * get_register_temps());
    if (!disable_reg_alloc && offset < 0){
        int reg = -1 - offset; // ===(-offset-1)
        assert (reg < NUM_REGS);
        return regNames[reg];
    }
    else
        return NULL;
}

//
//  返回我们期望分配给环境中绑定的下一个变量的未分配寄存器。
//  例如 我们在“ let x <-init ...”中使用它来预测新变量x的分配位置，
//  以便将init的结果放在此处。
//  写入未分配寄存器的想法仅能起作用，因为写入目标寄存器是最后完成的操作
//  init->code(s, env, get_next_register())
//  实际上，我们将立即在后缀中分配变量。
Register CgenEnvironment::get_next_register()
{
    return get_register(next_temp_location);
}

//
//  对于函数序言和结语：我们需要多少个寄存器/堆栈插槽？
//

// 临时总数
int CgenEnvironment::get_num_temps()
{
    return num_temps;
}

// 这些临时变量将有多少被放入寄存器中
int CgenEnvironment::get_register_temps()
{
    if (disable_reg_alloc)
        return 0;
    else if (NUM_REGS < num_temps)
        return NUM_REGS;
    else
        return num_temps;
}

//这些临时变量将有多少被压入栈中
int CgenEnvironment::get_stack_temps()
{
    int result = num_temps - get_register_temps();
    assert(result >= 0);
    return result;
}


//***************************************************
//
//  Emit code to start the .text segment and to
//  declare the global names.
//
//***************************************************

void CgenClassTable::code_global_text()
{
  str << GLOBAL << HEAP_START << endl
      << HEAP_START << LABEL 
      << WORD << 0 << endl
      << "\t.text" << endl
      << GLOBAL;
  emit_init_ref(idtable.add_string("Main"), str);
  str << endl << GLOBAL;
  emit_init_ref(idtable.add_string("Int"),str);
  str << endl << GLOBAL;
  emit_init_ref(idtable.add_string("String"),str);
  str << endl << GLOBAL;
  emit_init_ref(idtable.add_string("Bool"),str);
  str << endl << GLOBAL;
  emit_method_ref(idtable.add_string("Main"), idtable.add_string("main"), str);
  str << endl;
}

void CgenClassTable::code_bools(int boolclasstag)
{
  falsebool.code_def(str,boolclasstag);
  truebool.code_def(str,boolclasstag);
}

void CgenClassTable::code_select_gc()
{
  //
  // Generate GC choice constants (pointers to GC functions)
  //
  str << GLOBAL << "_MemMgr_INITIALIZER" << endl;
  str << "_MemMgr_INITIALIZER:" << endl;
  str << WORD << gc_init_names[cgen_Memmgr] << endl;
  str << GLOBAL << "_MemMgr_COLLECTOR" << endl;
  str << "_MemMgr_COLLECTOR:" << endl;
  str << WORD << gc_collect_names[cgen_Memmgr] << endl;
  str << GLOBAL << "_MemMgr_TEST" << endl;
  str << "_MemMgr_TEST:" << endl;
  str << WORD << (cgen_Memmgr_Test == GC_TEST) << endl;
}


//********************************************************
//
// Emit code to reserve space for and initialize all of
// the constants.  Class names should have been added to
// the string table (in the supplied code, is is done
// during the construction of the inheritance graph), and
// code for emitting string constants as a side effect adds
// the string's length to the integer table.  The constants
// are emmitted by running through the stringtable and inttable
// and producing code for each entry.
//
//********************************************************

void CgenClassTable::code_constants()
{
  //
  // Add constants that are required by the code generator.
  //
  stringtable.add_string("");
  inttable.add_string("0");

  stringtable.code_string_table(str,stringclasstag);
  inttable.code_string_table(str,intclasstag);
  code_bools(boolclasstag);
}


CgenClassTable::CgenClassTable(Classes classes, ostream& s) : nds(NULL) , str(s)
{
   stringclasstag = 0 /* Change to your String class tag here */;
   intclasstag =    0 /* Change to your Int class tag here */;
   boolclasstag =   0 /* Change to your Bool class tag here */;

   enterscope();
   if (cgen_debug) cout << "Building CgenClassTable" << endl;
   install_basic_classes();
   install_classes(classes);
   build_inheritance_tree();

   code();
   exitscope();
}

void CgenClassTable::install_basic_classes()
{

// The tree package uses these globals to annotate the classes built below.
  //curr_lineno  = 0;
  Symbol filename = stringtable.add_string("<basic class>");

//
// A few special class names are installed in the lookup table but not
// the class list.  Thus, these classes exist, but are not part of the
// inheritance hierarchy.
// No_class serves as the parent of Object and the other special classes.
// SELF_TYPE is the self class; it cannot be redefined or inherited.
// prim_slot is a class known to the code generator.
//
  addid(No_class,
	new CgenNode(class_(No_class,No_class,nil_Features(),filename),
			    Basic,this));
  addid(SELF_TYPE,
	new CgenNode(class_(SELF_TYPE,No_class,nil_Features(),filename),
			    Basic,this));
  addid(prim_slot,
	new CgenNode(class_(prim_slot,No_class,nil_Features(),filename),
			    Basic,this));

// 
// The Object class has no parent class. Its methods are
//        cool_abort() : Object    aborts the program
//        type_name() : Str        returns a string representation of class name
//        copy() : SELF_TYPE       returns a copy of the object
//
// There is no need for method bodies in the basic classes---these
// are already built in to the runtime system.
//
  install_class(
   new CgenNode(
    class_(Object, 
	   No_class,
	   append_Features(
           append_Features(
           single_Features(method(cool_abort, nil_Formals(), Object, no_expr())),
           single_Features(method(type_name, nil_Formals(), Str, no_expr()))),
           single_Features(method(copy, nil_Formals(), SELF_TYPE, no_expr()))),
	   filename),
    Basic,this));

// 
// The IO class inherits from Object. Its methods are
//        out_string(Str) : SELF_TYPE          writes a string to the output
//        out_int(Int) : SELF_TYPE               "    an int    "  "     "
//        in_string() : Str                    reads a string from the input
//        in_int() : Int                         "   an int     "  "     "
//
   install_class(
    new CgenNode(
     class_(IO, 
            Object,
            append_Features(
            append_Features(
            append_Features(
            single_Features(method(out_string, single_Formals(formal(arg, Str)),
                        SELF_TYPE, no_expr())),
            single_Features(method(out_int, single_Formals(formal(arg, Int)),
                        SELF_TYPE, no_expr()))),
            single_Features(method(in_string, nil_Formals(), Str, no_expr()))),
            single_Features(method(in_int, nil_Formals(), Int, no_expr()))),
	   filename),	    
    Basic,this));

//
// The Int class has no methods and only a single attribute, the
// "val" for the integer. 
//
   install_class(
    new CgenNode(
     class_(Int, 
	    Object,
            single_Features(attr(val, prim_slot, no_expr())),
	    filename),
     Basic,this));

//
// Bool also has only the "val" slot.
//
    install_class(
     new CgenNode(
      class_(Bool, Object, single_Features(attr(val, prim_slot, no_expr())),filename),
      Basic,this));

//
// The class Str has a number of slots and operations:
//       val                                  ???
//       str_field                            the string itself
//       length() : Int                       length of the string
//       concat(arg: Str) : Str               string concatenation
//       substr(arg: Int, arg2: Int): Str     substring
//       
   install_class(
    new CgenNode(
      class_(Str, 
	     Object,
             append_Features(
             append_Features(
             append_Features(
             append_Features(
             single_Features(attr(val, Int, no_expr())),
            single_Features(attr(str_field, prim_slot, no_expr()))),
            single_Features(method(length, nil_Formals(), Int, no_expr()))),
            single_Features(method(concat, 
				   single_Formals(formal(arg, Str)),
				   Str, 
				   no_expr()))),
	    single_Features(method(substr, 
				   append_Formals(single_Formals(formal(arg, Int)), 
						  single_Formals(formal(arg2, Int))),
				   Str, 
				   no_expr()))),
	     filename),
        Basic,this));

}

// CgenClassTable::install_class
// CgenClassTable::install_classes
//
// install_classes enters a list of classes in the symbol table.
//
void CgenClassTable::install_class(CgenNodeP nd)
{
  Symbol name = nd->get_name();

  if (probe(name))
    {
      return;
    }

  // The class name is legal, so add it to the list of classes
  // and the symbol table.
  nds = new List<CgenNode>(nd,nds);
  addid(name,nd);
}

void CgenClassTable::install_classes(Classes cs)
{
  for(int i = cs->first(); cs->more(i); i = cs->next(i))
    install_class(new CgenNode(cs->nth(i),NotBasic,this));
}

//
// CgenClassTable::build_inheritance_tree
//
void CgenClassTable::build_inheritance_tree()
{
  for(List<CgenNode> *l = nds; l; l = l->tl())
      set_relations(l->hd());
}

//
// CgenClassTable::set_relations
//
// Takes a CgenNode and locates its, and its parent's, inheritance nodes
// via the class table.  Parent and child pointers are added as appropriate.
//
void CgenClassTable::set_relations(CgenNodeP nd)
{
  CgenNode *parent_node = probe(nd->get_parent());
  nd->set_parentnd(parent_node);
  parent_node->add_child(nd);
}

void CgenNode::add_child(CgenNodeP n)
{
  children = new List<CgenNode>(n,children);
}

void CgenNode::set_parentnd(CgenNodeP p)
{
  assert(parentnd == NULL);
  assert(p != NULL);
  parentnd = p;
}



void CgenClassTable::code()
{
  if (cgen_debug) cout << "coding global data" << endl;
  code_global_data();

  if (cgen_debug) cout << "choosing gc" << endl;
  code_select_gc();

  if (cgen_debug) cout << "coding constants" << endl;
  code_constants();

//                 Add your code to emit
//                   - prototype objects
//                   - class_nameTab
//                   - dispatch tables
//

  if (cgen_debug) cout << "coding global text" << endl;
  code_global_text();

//                 Add your code to emit
//                   - object initializer
//                   - the class methods
//                   - etc...

}


CgenNodeP CgenClassTable::root()
{
   return probe(Object);
}


///////////////////////////////////////////////////////////////////////
//
// CgenNode methods
//
///////////////////////////////////////////////////////////////////////

CgenNode::CgenNode(Class_ nd, Basicness bstatus, CgenClassTableP ct) :
   class__class((const class__class &) *nd),
   parentnd(NULL),
   children(NULL),
   basic_status(bstatus)
{ 
   stringtable.add_string(name->get_string());          // Add class name to string table
}


//******************************************************************
//
//   Fill in the following methods to produce code for the
//   appropriate expression.  You may add or remove parameters
//   as you wish, but if you do, remember to change the parameters
//   of the declarations in `cool-tree.h'  Sample code for
//   constant integers, strings, and booleans are provided.
//
//*****************************************************************

void assign_class::code(ostream &s) {
}

void static_dispatch_class::code(ostream &s) {
}

void dispatch_class::code(ostream &s) {
}

void cond_class::code(ostream &s) {
}

void loop_class::code(ostream &s) {
}

void typcase_class::code(ostream &s) {
}

void block_class::code(ostream &s) {
}

void let_class::code(ostream &s) {
}

void plus_class::code(ostream &s) {
}

void sub_class::code(ostream &s) {
}

void mul_class::code(ostream &s) {
}

void divide_class::code(ostream &s) {
}

void neg_class::code(ostream &s) {
}

void lt_class::code(ostream &s) {
}

void eq_class::code(ostream &s) {
}

void leq_class::code(ostream &s) {
}

void comp_class::code(ostream &s) {
}

void int_const_class::code(ostream& s)  
{
  //
  // Need to be sure we have an IntEntry *, not an arbitrary Symbol
  //
  emit_load_int(ACC,inttable.lookup_string(token->get_string()),s);
}

void string_const_class::code(ostream& s)
{
  emit_load_string(ACC,stringtable.lookup_string(token->get_string()),s);
}

void bool_const_class::code(ostream& s)
{
  emit_load_bool(ACC, BoolConst(val), s);
}

void new__class::code(ostream &s) {
}

void isvoid_class::code(ostream &s) {
}

void no_expr_class::code(ostream &s) {
}

void object_class::code(ostream &s) {
}


