
#include "copyright.h"

//此文件实现Cool的语义检查。
//
// 个人理解，代码骨架就是先定义一个Environment(建立各种的符号表)，也就是作用域来
// 约束各个类，方法的作用范围。
// 然后进行一个类型检测，在继承等前提下，对属性，方法的定义和使用
// 是否存在重定义，是否构成cyclic，返回类型是否匹配定义
// 推断类型是否符合等一系列判断。


// 有三种
//通过：
//
//传递1：这不是真正的传递，因为仅检查类。
//构建继承图并检查错误。有
//两个“子”传递：检查类是否未重新定义并继承
//仅来自已定义的类，并检查继承中的循环
//图表。如果在两次之间检测到错误，编译将停止。
//子传递。
//
//步骤2：为每个类构建符号表。这一步完成了
//分开，因为方法和属性具有全局
//作用域-因此，所有方法和属性的绑定都必须是
//在进行类型检查之前已知。
//
//步骤3：继承图---如果是，则称为树
//没有循环-从根开始再次遍历
//类Object。对于每个类，每个属性和方法都是
//经过类型检查。同时，检查标识符是否正确
//定义/使用以及多个定义。不变式是
//维护班级的所有父级在班级之前被检查
//被选中。

#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include "semant.h"
#include "utilities.h"


extern int semant_debug;
extern char *curr_filename;
extern int node_lineno;

//////////////////////////////////////////////////////////////////////
//符号
//
//为了方便起见，此处预定义了大量符号。
//这些符号还包括原始类型和方法名称
//作为运行时系统使用的固定名称。
//////////////////////////////////////////////////////////////////////
static Symbol 
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
// 初始化预定义符号。
//
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

//环境功能。Cool类型检查规则需要四个结构来对X类进行类型检查。
// 这四个项目封装在Environment中：
// a）从方法名称到X的方法定义的映射
// b）从变量（本地和属性）名称到X中定义的映射
// c）从方法名和类名到除X之外的其他类的方法的定义的映射
// d）自我类（X）
// c）使用class_table实现，该表包含所有类从类名
// 到InheritanceNodes（从而到环境）的映射。

// 利用List来实现作用域的辨别，好像在变量创建的时候直接产生了两个point，
// hd()和tl()，在作用域内的操作好像全是储存在hd()和tl()内存范围内的，这样来达到作用域的实现
Environment::Environment(ClassTableP ct, InheritanceNodeP sc):
    method_table(*(new SymbolTable<Symbol,method_class>())),
    var_table(*(new SymbolTable<Symbol,Entry>())),
    class_table(ct),
    self_class(sc)
{
    method_table.enterscope();
    var_table.enterscope();
    var_table.addid(self,SELF_TYPE); // self : SELF_TYPE in all environments
}

Environment::Environment(SymbolTable<Symbol,method_class> mt,
                         SymbolTable<Symbol,Entry> vt,
                         ClassTableP ct,
                         InheritanceNodeP sc):
                         method_table(mt), // copies the method_table
                         var_table(vt), // copies the var_table
                         class_table(ct),
                         self_class(sc)
{
    //为每个方法/变量表推送新的作用域，
    //以便新方法/变量不会与现有方法/变量冲突。
    method_table.enterscope();
    var_table.enterscope();
}

//
//大多数“新”环境是父类环境的重复项，而自我类已被替换。
// 一个很小但很重要的一点是，方法表和var表的结构已复制，
// 因此添加到新环境对原始环境没有影响。
//

EnvironmentP Environment::clone_Environment(InheritanceNodeP n)
{
    return new Environment(method_table,var_table,class_table,n);
}

ostream& Environment::semant_error()
{
    return class_table->semant_error();
}

ostream& Environment::semant_error(tree_node *t)
{
    return class_table->semant_error(self_class->get_filename(),t);
}

InheritanceNodeP Environment::lookup_class(Symbol s)
{
    return class_table->probe(s);
}

void Environment::method_add(Symbol s, method_class *m)
{ method_table.addid(s,m);}

method_class *Environment::method_lookup(Symbol s)
{ return method_table.lookup(s);}

method_class *Environment::method_probe(Symbol s)
{ return method_table.probe(s);}

void Environment::method_enterscope()
{ method_table.enterscope();}

void Environment::method_exitscope()
{ method_table.exitscope();}

void Environment::var_add(Symbol s, Symbol v)
{ var_table.addid(s,v);}

Symbol  Environment::var_lookup(Symbol s)
{ return var_table.lookup(s);}

Symbol Environment::var_probe(Symbol s)
{ return var_table.probe(s);}

void Environment::var_enterscope() { var_table.enterscope();}

void Environment::var_exitscope() { var_table.exitscope();}

Symbol Environment::get_self_type()
{ return self_class->get_name();}

////////////////////////////////////////////////////////////////////
//
// semant_error是用于在语义分析过程中报告错误的重载函数。
// 有三个版本：
// ostream& ClassTable::semant_error()
//
// ostream& ClassTable::semant_error(Class_ c)
//       打印`c'的行号和文件名
// ostream& ClassTable::semant_error(Symbol filename, tree_node *t)
//       打印行号和文件名
//      (行号是从tree_node中提取的)
//
////////////////////////////////////////////////////////////////////

ostream& ClassTable::semant_error(Class_ c)
{ return semant_error(c->get_filename(),c);}

ostream& ClassTable::semant_error(Symbol filename, tree_node *t)
{
    error_stream<<filename<<":"<<t->get_line_number()<<":";
    return semant_error();
}

ostream ClassTable::semant_error()
{
    semant_errors++;
    return error_stream;
}

/////////////////////////////////////////////////////////////////////
//
// 继承图。
//
//以下功能允许创建继承图的节点，
// 并可以从节点设置/检索父节点。
//
////////////////////////////////////////////////////////////////////

InheritanceNode::InheritanceNode(Class_ nd,
                                 Inheritable istatus,
                                 Basicness bstatus):
                                 //拷贝构造函数的使用在这里很重要。
                                 class__class((const class__class &) *nd),
                                 parentnd(Null),
                                 children(Null),
                                 inherit_status(istatus),
                                 basic_status(bstatus),
                                 reach_status(UnReachable),
                                 env(Null)
{}

void InheritanceNode::set_parentnd(InheritanceNodeP p)
{
    assert(parentnd == Null);
    assert(p != Null);
    parentnd = p;
}

InheritanceNodeP inheritanceNode::get_parentnd()
{ return parentnd;}

////////////////////////////////////////////////////////////////////
//
// ClassTable::ClassTable
//
// ClassTable构造函数初始化将符号类映射到继承图节点的符号表。
// 构造函数还安装基本类。
//
// Cool有五个基本类别：
// Object:     The root of the hierarchy; all objects are Objects.
// IO:         一个用于简单字符串和整数输入/输出的类。.
// Int:        Integers
// Bool:       Booleans
// String:     Strings
// 用户定义的类可以从Object和IO继承，
// 但是Int，Bool和String类不能被继承。
//
/////////////////////////////////////////////////////////////////////
ClassTable::ClassTable(Classes classes) : semant_errors(0) , error_stream(cerr)
{
    enterscope(); // 最初，符号表为空
    install_basic_classes(); // 预定义的基本类
    if (semant_debug) cerr<<"Installed basic classes." << endl;
    install_classes(classes); // 用户定义的类
    if (semant_debug)
    {
        cerr << "Installed user-defined classes." <<endl;
        dump();
    }
    check_improper_inheritance(); // 检查简单的继承错误
    if (semant_debug) { cerr << "Checked for simple inheritance errors."<<endl;}
    if (errors()) return;

    build_inheritance_tree(); // 建立完整的继承树
    if (semant_debug) { cerr<<"Built inheritance tree."<<endl;}
    root() -> mark_reachable(); // 查找根类可访问的所有类
    if (semant_debug) { cerr << "Marked reachable classes."<<endl;}
    check_for_cycles(); // 检查它确实是一棵树
    if (semant_debug) { cerr<<"Checked for cycles."<<endl;}
    if (errors()) return;

    build_feature_tables(); // 为每个类构建要素符号表
    if (semant_debug) { cerr << "Built feature tables."<<endl;}
    check_main(); // 检查主类和主方法
    if (semant_debug) { cerr <<"Checked Main Class and method."<<endl;}
    root->type_check_features(); // 输入检查所有表达式
}

void ClassTable::install_basic_classes() {
    // 预定义的基本类
    // The tree package uses these globals to annotate the classes built below.
   // curr_lineno  = 0;
    node_lineno = 0;
    Symbol filename = stringtable.add_string("<basic class>");
    
    // The following demonstrates how to create dummy parse trees to
    // refer to basic Cool classes.  There's no need for method
    // bodies -- these are already built into the runtime system.
    
    // IMPORTANT: The results of the following expressions are
    // stored in local variables.  You will want to do something
    // with those variables at the end of this method to make this
    // code meaningful.

    // 在查找表中安装了一些特殊的类名，但没有安装类列表。
    // 因此，这些类存在，但不属于继承层次结构。
    // No_class充当Object和其他特殊类的父级。
    // SELF_TYPE是自类； 它不能重新定义或继承。
    // prim_slot是代码生成器已知的类。
    //
    addid(No_class, new InheritanceNode(class_(No_class,No_class,nil_Features(),filename),CanInherit,Basic));
    addid(SELF_TYPE,new InheritanceNode(class_(SELF_TYPE,No_class,nil_Features(),filename),
                                        CantInherit,
                                        Basic));
    addid(prim_slot,
          new InheritanceNode(class_(prim_slot,No_class,nil_Features(),filename),
                              CantInherit,
                              Basic));

    // Object类没有父类。 其方法是
    //        abort() : Object    aborts the program 中止程序
    //        type_name() : Str   返回类名的字符串表示形式
    //        copy() : SELF_TYPE  返回对象的副本
    //
    // There is no need for method bodies in the basic classes---these
    // are already built in to the runtime system.

    Class_ Object_class =
	class_(Object, 
	       No_class,
	       append_Features(
			       append_Features(
					       single_Features(method(cool_abort, nil_Formals(), Object, no_expr())),
					       single_Features(method(type_name, nil_Formals(), Str, no_expr()))),
			       single_Features(method(copy, nil_Formals(), SELF_TYPE, no_expr()))),
	       filename);
    install_class(new InheritanceNode(Object_class,CanInherit,Basic));
    // 
    // The IO class inherits from Object. Its methods are
    //        out_string(Str) : SELF_TYPE       writes a string to the output
    //        out_int(Int) : SELF_TYPE            "    an int    "  "     "
    //        in_string() : Str                 reads a string from the input
    //        in_int() : Int                      "   an int     "  "     "
    //
    Class_ IO_class = 
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
	       filename);  
    install_class(new InheritanceNode(IO_class,CanInherit,Basic));
    //
    // The Int class has no methods and only a single attribute, the
    // "val" for the integer. 
    //
    Class_ Int_class =
	class_(Int, 
	       Object,
	       single_Features(attr(val, prim_slot, no_expr())),
	       filename);
    install_class(new InheritanceNode(Int_class,CantInherit,Basic));
    //
    // Bool also has only the "val" slot.
    //
    Class_ Bool_class =
	class_(Bool, Object, single_Features(attr(val, prim_slot, no_expr())),filename);
    install_class(new InheritanceNode(Bool_class,CanInherit,Basic));
    //
    // The class Str has a number of slots and operations:
    //       val                                  the length of the string
    //       str_field                            the string itself
    //       length() : Int                       returns length of the string
    //       concat(arg: Str) : Str               performs string concatenation
    //       substr(arg: Int, arg2: Int): Str     substring selection
    //       
    Class_ Str_class =
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
	       filename);
}
    install_class(new InheritanceNode(Str_class,CanInherit,Basic));

void ClassTable::install_class(InheritanceNodeP nd)
{   // 用户定义的类
    // 此处应该就是获取用户定义的类名
    Symbol name = nd->get_name();
    if(probe(name))  // 探查符号表，检查(name)的顶部范围(个人理解头指针)，找得到就返回信息字段
    {
        InheritanceNodeP old = probe(name);
        if (old->basic()) // 用了个枚举，不是很明白。大概在检查是否重复定义类名？？?
            semant_error(nd) << "Redefinition of basic class" << name <<"."<<endl;
        else
            semant_error(nd) <<"Class" << name<<"was previously defined." <<endl;
        return ;
    }
    //类名是合法的，因此将其添加到类列表和符号表中。
    nds = new List<InheritanceNode>(nd,nds);
    addid(name,nd);
}

//安装所有用户定义的类； 所有这些类都可以继承，并且不是基本类。
void ClassTable::install_classes(Classes cs)
{
    for(int i = cs ->first();cs->more(i);i = cs->next(i))
        install_class(new InheritanceNode(cs->nth(i),CanInherit,NotBasic));
}

//
// ClassTable::check_improper_inheritance
//
// This function checks whether the classes in a ClassTable illegally inherit
// from
//  - a CantInherit class
//  - SELF_TYPE
//  - an undefined class
//
// All of these checks are local (do not require traversing the inheritance
// graph).
//
void ClassTable::check_improper_inheritance()
{  //检查简单的继承错误
    for(List<InheritanceNode> *l = nds; l; l =l->tl())
    {   // 这里先获取它作用域的开头指针，然后应该是获取父类，再获取父类作用域的开头指针
        InheritanceNodeP c = l->hd();
        Symbol parent = c->get_parent();
        InheritanceNode *node = probe(parent);
        // 这里就是父类不存在，就继承错误
        if(!node)
        {
            semant_error(c) <<"class" <<c->get_name()<<"inherits from an undefined class" << parent<<"."<<endl;
            continue;
        }
        // 这里是继承问题，你创建的类无法继承父类(什么情况会出现无法继承父类的情况？)
        if(!node->inherit())
            semant_error(c) <<"Class" << c->get_name() << "cannot inherit class" << parent <<"." << endl;
    }
}

//
// ClassTable::build_inheritance_tree
//
// For each class node in the inheritance graph, set its parent,
// and add the node to the parent's list of child nodes.
//
void ClassTable::build_inheritance_tree()
{  // 建立完整的继承树
    for(List<InheritanceNode> *l = nds;l;l = l->tl())
        set_relations(l->hd());  // 不知道干嘛的，本地没溯源到...不知道为什么
}

//获取一个InheritanceNode并通过类表定位其及其父级的继承节点。
// 父和子指针将适当添加。
void ClassTable::set_relations(InheritanceNodeP nd)
{
    InheritanceNode *parent_node = probe(nd->get_parent());
    nd->set_parentnd(parent_node);
    parent_node->add_child(nd);
}

//仅在mark_reachable执行后才应运行此方法。 如果继承图中存在任何无法访问的类，
// 并且所有本地检查check_improper_inheritance均成功完成，
// 则继承图中将存在一个循环。
void ClassTable::check_for_cycles()
{   // 检测是否是一棵继承树
    for(List<InheritanceNode> *l =nds;l;l = l->tl())
        // 不是很懂reachable()的作用，这种enum进行枚举的都看的不是很懂
        // 大概就是检测是否class a 继承 b , 然后class b又继承class a
        // 这样，构成一个cyclic，是不被允许的。
        if(!(l->hd()->reachable()))
            semant_error(l->hd()) << "Class" <<l->hd()->get_name()
            << ", or an ancestor of" << l->hd()->get_name() <<
            ", is involved in an inheritance cycle." <<endl;
}

void InheritanceNode::add_child(InheitanceNodeP n)
{
    children = new List<InheritanceNode>(n,children);
}

//InheritanceNode :: mark_reachable（）将所有从参数可到达的节点递归标记
// 为Reachable。 最初用Object调用。 该函数可以保证终止，
// 因为如果check_improper_inheritance未发现任何本地错误，
// 则从Object可以访问的继承层次结构的子图不能包含循环。
void InheritanceNode::mark_reachable()
{   // 查找根类可访问的所有类
    reach_status = Reachable; //将当前节点标记为可达
    // process the children
    for(List<InheritanceNode> *kids = children; kids = kids->tl())
        kids->hd()->mark_reachable();
}

////////////////////////////////////////////////////////////////////
// 功能符号表
// 下列函数递归地遍历每个类的每个功能，
// 从而为有关这些类的类的环境添加信息。 在这里捕获到错误，
// 例如在类中重新定义方法/属性名称。
////////////////////////////////////////////////////////////////////
void InheritanceNode::build_feature_tables()
{   // 为每个类构建要素符号表
    // 将类的每个功能添加到类符号表中
    for(int i = features->first();features->more(i);i=features->next(i))
        features->nth(i)->add_to_table(env);

    for(List<InheritanceNode> *l = children; l;l=l->tl())
    {
        // for each child of the current class, we
        l ->hd() ->copy_env(env);   // copy the parent environment
                                    // thus inheriting the parent features
        l->hd() -> build_feature_tables(); // add the child features
    }
}

void InheritanceNode::type_check_features()
{   // 输入检查所有表达式
    if (semant_debug) { cerr<<"Type checking class" << name << endl;}

    for (int i = features->first();features->more(i); i = features->next(i))
        features->nth(i)->tc(env);

    for (List<InheritanceNode> *l = children; l;l=l->tl())
        l->hd()->type_check_features();
}

//分配新的环境结构。 目前仅用于根（对象）类；
// 所有其他类都复制其父级的Environment。
void InheritanceNode::init_env(ClassTableP ct)
{
    env = new Environment(ct,this);
}

void ClassTable::build_feature_tables()
{
    root()->init_env(this);  // create symbol tables for the root class
    root()->build_feature_tables(); // 为根类和所有后代递归构建要素表。
}

InheritanceNodeP ClassTable::root()
{
    return probe(Object);
}

void method_class::add_to_table(EnvironmentP env)
{   // 应该和probe()无差
    if (env->method_probe(name))
    {
        env->semant_error(this) << "Method" << name << " is multiply defined" << endl;
        return;
    }

    // 没溯源到lookup()是个什么函数
    // 盲猜是作用域里的某玩意儿？
    method_class *old = env->method_lookup(name);
    if (old)
    {   // 检测是否返回类型和本身类型相符
        if (old->get_return_type() != return_type)
        {
            env->semant_error(this) << "In redefined method" << name << ",return type"
                                    << return_type << "is different from original return type"
                                    << old - get_return_type()
                                    << "." << endl;
            return;
        }

        // 检测自定义的方法中形参数量是否一致
        if (old->num_formals() != num_formals())
        {
            env->semant_error(this) << "Incompatible number of formal parameters in redefined method"
                                    << name << "." << endl;
            return;
        }

        Formals old_formals = old->get_formals();
        for (int i = formals->first(); formals->more(i); i = formals->next(i))
            // 检测在自定义的方法中它们的参数类型是否匹配(说起来，这里的比较是哪里的比较？)
            if (old_formals->nth(i)->get_type_decl() != formals->nth(i)->get_type_decl())
            {
                env->semant_error(this) << "In redefined method" << name << ", parameter type"
                                        << formals->nth(i)->get_type_decl() << "is different from original type"
                                        << old_formals->nth(i)->get_type_decl()
                                        << endl;
                return;
            }
    }
    env->method_add(name, this);
}

    void attr_class::add_to_table(EnvironmentP env)
    {
        if(name == self)
        {
            env->semant_error(this)<<"self cannot be the name of an attribute" << endl;
            return;
        }

        // 检测属性是否被重复定义
        if (env->var_probe(name))
        {
            env->semant_error(this) << "Attribute" << name << " is multiply defined in class."
            << endl;
            return;
        }

        // 属性不能是继承的类的属性
        if (env->var_lookup(name))
        {
            env->semant_error(this) << "Attribute" << name << " is an attribute of an inherited class." << endl;
            return;
        }
        env->var_add(name,type_decl);
    }

    //检查Main类是否存在，并且可以访问其继承层次结构中的main方法。
    void ClassTable::check_main()
    {
        InheritanceNodeP mainclass = probe(Main);
        if (!mainclass)
            semant_error() << "Class Main is not defined" << endl;
        else
            mainclass->check_main_method();
    }

    // 检查该类是否具有不带参数的main方法。 该方法必须在* in *中定义，
    // 而不是继承到Main类中。
    void InheritanceNode::check_main_method()
    {
        if (!env->method_probe(main_meth))
        {
            env->semant_error(this) << "No 'main' method in class Main" << endl;
            return;
        }
        if (env->method_lookup(main_meth)->num_formals()!=0)
            env->semant_error(this) <<
            "'main' method in class Main should have no arguments." << endl;
    }

    ////////////////////////////////////////////////////////////////////////
//
// 类型运算
//
// type_leq  是X类型<= Y类型吗？
///type_lub  大于X和Y的最具体类型是什么？
//
// 通过处理SELF_TYPE并小心避免避免为未定义的类生成多个错误消息
// （使用这些函数时已经报告了这些错误消息）
// 这些函数会稍微复杂一些。
//
/////////////////////////////////////////////////////////////////////////

int Environment::type_leq(Symbol subtype, Symbol supertype)
{
        // 如果其中一个类不存在，则返回TRUE以减少伪造错误消息的数量。
        // 还为任何t提供No_type <t。
        if (!(lookup_class(supertype)&& lookup_class(subtype)))
            return TRUE;
        // SELF_TYPE <= SELF_TYPE
        if (subtype == SELF_TYPE && supertype == SELF_TYPE) return TRUE;

        // x is not <= SELF_TYPE if x in not SELF_TYPE
        if (supertype == SELF_TYPE) return FALSE;

        // if the lhs is SELF_TYPE , it is promoted here to the self_type of class.
        if (subtype == SELF_TYPE) subtype = get_self_type();

        // x <= y if Y is an acnestor of x in the inheritance hierarchy

        InheritanceNodeP y = lookup_class(supertype);
        for(InheritanceNodeP x = lookup_class (subtype); x; x= x->get_parentnd())
            if(x==y) return TRUE;

    return  FALSE;
}
    Symbol  Environment::type_lub(Symbol t1, Symbol t2)
    {
        //此过程中的测试顺序很重要。
        //
        // 1.如果一种类型未定义（即No_class），则返回另一种
        // 2.如果两种类型均为SELF_TYPE，则返回SELF_TYPE
        // 3.如果其中一个为SELF_TYPE，则将其转换为类的类型
        // 4.在继承图中找到最不常见的祖先。

        if (!lookup_class(t1)) return t2; // if either type is undefined
        if(!lookup_class(t2)) return t1; // return the other.

        if (t1 == t2) return t1; // SELF_TYPE u SELF_TYPE = SELF_TYPE
        if (t1 == SELF_TYPE) t1 = get_self_type();
        if (t2 == SELF_TYPE) t2 = get_self_type();

        InheritanceNodeP  nd;
        for (nd = lookup_class(t1);
             !type_leq(t2,nd->get_name());
             nd = nd->get_parentnd());
        return nd->get_name();
    }

    ///////////////////////////////////////////////////////////////////////////////
//
//  类型检查功能
//
//  对于每个表达式类，都有一个tc方法来对其进行类型检查。
//  tc方法利用先前为每个类构造的环境。
//  该代码非常类似于CoolAid中类型推断规则的结构。
//
///////////////////////////////////////////////////////////////////////////////

void attr_class::tc(EnvironmentP env)
{
        //属性是否定义
        if (!env->lookup_class(type_decl))
            env->semant_error(this) << "Class" << type_decl << "of attribute" << get_name
            << " is undefined." << endl;

        // 推断的类型是否符合
        if (! env->type_leq(init->tc(env),type_decl))
            env->semant_error(this) << "Inferred type" << init->get_type()
            << "of initialization of attribute" << name <<
            " does not conform to declared type" << type_decl << "." <<endl;
}

    void method_class::tc(EnvironmentP env)
    {
        env->var_enterscope();

        for(int i = formals->first(); formals->more(i); i = formals->next(i))
            formals->nth(i)->install_formal(env);

        // 方法 的返回类型是否正确
        if(! env->lookup_class(return_type))
            env->semant_error(this) << "Undefined return type" << return_type <<
            " in method" << name <<"." <<endl;

        // 方法的推断类型是否符合
        if ( env->type_leq(expr->tc(env),return_type))
            env->semant_error(this) << "Inferred return type" << expr->get_type()
            << "of method" << name << "does not conform to declared return type" <<
            return_type << "." << endl;
        env->var_exitscope();
    }

    void formal_class::install_formal(EnvironmentP env)
    {
        // 形参的定义不能有SELF_TYPE类型
        if (type_decl == SELF_TYPE)
            env->semant_error(this) << "Formal parameter" << name <<
            " cannot have type SELF_TYPE." << endl;
        else
        {   // 类的形成有无定义
            if (! env->lookup_class(type_decl))
                env->semant_error(this) << "Class" << type_decl <<
                " of formal parameter" << name << " is undefined." << endl;
        };

        // self不能是形参的名字
        if (name == self)
        {
            env->semant_error(this) << "'self' cannot be the name of a formal parameter."
            << endl;
            return;
        }

        形参有无重复定义
        if (env->var_probe(name))
        {
            env->semant_error(this) << "Formal parameter" << name <<
            " is multiply defined." << endl;
            return;
        }

        env->var_add(name,type_decl);
    }

    Symbol  int_const_class::tc(EnvironmentP)
    {
        type = Int;
        return Int;
    }

    Symbol bool_const_class::tc(EnvironmentP)
    {
        typr = Bool;
        return Bool;
    }

    Symbol string_const_class::tc(EnvironmentP)
    {
        type = Str;
        return Str;
    }

    Symbol plus_class::tc(EnvironmentP env)
    {
        e1->tc(env);
        e2->tc(env);

        if((e1->get_type() != Int) || (e2->get_type() != Int))
            env->semant_error(this) << "non-Int arguments:" << e1->get_type()
            << "-" << e2->get_type() << endl;

        type = Int;
        return Int;
    }

    Symbol mul_class::tc(EnvironmentP env)
    {
        e1->tc(env);
        e2->tc(env);

        if((e1->get_type) != Int || (e2->get_type()!= Int))
            env->semant_error(this) << "non-Int arguments:" << e1->get_type()
            << "*" << e2->get_type() << endl;

        type = Int;
        return Int;
    }

    Symbol divide_class::tc(EnvironmentP env)
    {
        e1->tc(env);
        e2->tc(env);

        if((e1->get_type() != Int) || (e2->get_type() != Int))
            env->semant_error(this) << "non-Int arguments:" << e1->get_type()
            << "/" << e2->get_type() << endl;

        type = Int;
        return Int;
    }

    Symbol neg_class::tc(EnvironmentP env)
    {
        e1->tc(env);

        if(e1->get_type() != Int)
            env ->semant_error(this) << "Argument of '~' has type" << e1->get_type()
            << "instead of Int" << endl;

        type = Int;
        return Int;
    }

    Symbol lt_class::tc(EnvironmentP env)
    {
        e1->tc(env);
        e2->tc(env);

        if ((e1->get_type() != Int) || (e2->get_type() != Int))
            env->semant_error(this) << "non-Int arguments: " << e1->get_type() << " < "
                                    << e2->get_type() << endl;

        type = Bool;
        return Bool;
    }

    Symbol leq_class::tc(EnvironmentP env)
    {
        e1->tc(env);
        e2->tc(env);

        if ((e1->get_type() != Int) || (e2->get_type() != Int))
            env->semant_error(this) << "non-Int arguments: " << e1->get_type() << " <= "
                                    << e2->get_type() << endl;

        type = Bool;
        return Bool;
    }

    Symbol comp_class::tc(EnvironmentP env)
    {
        e1->tc(env);

        if(e1->get_type() != Bool)
            env->semant_error(this) << "Argument of 'not' has type " << e1->get_type()
                                    << " instead of Bool." << endl;

        type = Bool;
        return Bool;
    }

    Symbol object_class::tc(EnvironmentP env)
    {
        if(env->var_lookup(name))
            type = env->var_lookup(name)
        else
        {
            env->semant_error(this) << "Undeclared identifier" << name <<"."
            << endl;
            type = Object;
        }
        return type;
    }

    Symbol no_expr_class::tc(EnvironmentP)
    {
        type = No_type;
        return No_type;
    }

    Symbol new__class::tc(EnvironmentP env)
    {
        if(env->lookup_class(type_name))
            type = type_name;
        else
        {
            env->semant_error(this) << "'new' used with undefined class " <<
                                    type_name << "." << endl;
            type = Object;
        }
        return type;
    }

    Symbol isvoid_class::tc(EnvironmentP env)
    {
        e1->tc(env);
        type = Bool;
        return Bool;
    }

    Symbol eq_class::tc(EnvironmentP env)
    {
        Symbol t1 = e1->tc(env);
        Symbol t2 = e2->tc(env);
        if ((t1 != t2) &&
            ((t1 == Int)  || (t2 == Int) ||
             (t1 == Bool) || (t2 == Bool) ||
             (t1 == Str)  || (t2 == Str)))
            env->semant_error(this) << "Illegal comparison with a basic type." << endl;
        type = Bool;
        return Bool;
    }

    Symbol let_class::tc(EnvironmentP env)
    {

        if (! env->lookup_class(type_decl))
            env->semant_error(this) << "Class " << type_decl <<
                                    " of let-bound identifier " << identifier << " is undefined." << endl;

        if (! env->type_leq(init->tc(env), type_decl))
            env->semant_error(this) << "Inferred type " << init->get_type() <<
                                    " of initialization of " << identifier <<
                                    " does not conform to identifier's declared type " << type_decl << "." <<
                                    endl;
        env->var_enterscope();

        if(identifier == self)
            env->semant_error(this) << "'self' cannot be bound in a 'let' expression."
                                    << endl;
        else
            env->var_add(identifier,type_decl);

        type = body->tc(env);
        env->var_exitscope();
        return type;
    }

    Symbol block_class::tc(EnvironmentP env)
    {
        for(int i = body->first(); body->more(i); i = body->next(i))
            type = body->nth(i)->tc(env);
        return type;
    }

    Symbol assign_class::tc(EnvironmentP env)
    {
        if (name == self)
            env->semant_error(this) << "Cannot assign to 'self'." << endl;

        if (! env->var_lookup(name))
            env->semant_error(this) << "Assignment to undeclared variable " << name
                                    << "." << endl;

        type = expr->tc(env);

        if(! env->type_leq(type, env->var_lookup(name)))
            env->semant_error(this) << "Type " << type <<
                                    " of assigned expression does not conform to declared type " <<
                                    env->var_lookup(name) << " of identifier " << name << "." << endl;

        return type;
    }

    Symbol dispatch_class::tc(EnvironmentP env)
    {
        // Type check the subexpressions first.
        Symbol expr_type = expr->tc(env);
        if (expr_type == SELF_TYPE) expr_type = env->get_self_type();

        for(int i = actual->first(); actual->more(i); i = actual->next(i))
            actual->nth(i)->tc(env);

        InheritanceNode *nd = env->lookup_class(expr_type);
        if (!nd)
        {
            env->semant_error(this) << "Dispatch on undefined class " << expr_type <<
                                    "." << endl;
            type = Object;
            return Object;
        }

        method_class *meth = nd->method_lookup(name);

        if(! meth)
        {
            env->semant_error(this) << "Dispatch to undefined method " << name << "."
                                    << endl;
            type = Object;
            return Object;
        }

        if(actual->len() != meth->num_formals())
            env->semant_error(this) << "Method " << name <<
                                    " called with wrong number of arguments." << endl;
        else
            for(int i = actual->first(); actual->more(i); i = actual->next(i))
                if (! env->type_leq(actual->nth(i)->get_type(),
                                    meth->sel_formal(i)->get_type_decl()))
                    env->semant_error(this) << "In call of method " << name <<
                                            ", type " << actual->nth(i)->get_type() <<
                                            " of parameter " << meth->sel_formal(i)->get_name() <<
                                            " does not conform to declared type " <<
                                            meth->sel_formal(i)->get_type_decl() << "." << endl;

        type = (meth->get_return_type() == SELF_TYPE) ? expr->get_type() :
               meth->get_return_type();
        return type;
    }

    Symbol static_dispatch_class::tc(EnvironmentP env)
    {
        Symbol expr_type = expr->tc(env);
        for(int i = actual->first(); actual->more(i); i = actual->next(i))
            actual->nth(i)->tc(env);

        if(type_name == SELF_TYPE)
        {
            env->semant_error(this) << "Static dispatch to SELF_TYPE." << endl;
            type = Object;
            return Object;
        }

        InheritanceNode *nd = env->lookup_class(type_name);

        if(!nd)
        {
            env->semant_error(this) << "Static dispatch to undefined class " <<
                                    type_name << "." << endl;
            type = Object;
            return Object;
        }

        if(! env->type_leq(expr_type, type_name))
        {
            env->semant_error(this) << "Expression type " << expr_type <<
                                    " does not conform to declared static dispatch type " << type_name <<
                                    "." << endl;
            type = Object;
            return Object;
        }

        method_class *meth = nd->method_lookup(name);

        if(! meth)
        {
            env->semant_error(this) << "Static dispatch to undefined method " << name
                                    << "." << endl;
            type = Object;
            return Object;
        }

        if(actual->len() != meth->num_formals())
            env->semant_error(this) << "Method " << name
                                    << " invoked with wrong number of arguments." << endl;
        else
            for(int i = actual->first(); actual->more(i); i = actual->next(i))
                if (! env->type_leq(actual->nth(i)->get_type(),
                                    meth->sel_formal(i)->get_type_decl()))
                    env->semant_error(this) << "In call of method " << name <<
                                            ", type " << actual->nth(i)->get_type() <<
                                            " of parameter " << meth->sel_formal(i)->get_name() <<
                                            " does not conform to declared type " <<
                                            meth->sel_formal(i)->get_type_decl() << "." << endl;

        type = (meth->get_return_type() == SELF_TYPE) ? expr_type :
               meth->get_return_type();
        return type;
    }

    Symbol cond_class::tc(EnvironmentP env)
    {
        if(pred->tc(env) != Bool)
            env->semant_error(this) << "Predicate of 'if' does not have type Bool.\n";
        Symbol then_type = then_exp->tc(env);
        Symbol else_type = else_exp->tc(env);
        type = env->type_lub(then_type, else_type);
        return type;
    }

    Symbol loop_class::tc(EnvironmentP env)
    {
        if(pred->tc(env) != Bool)
            env->semant_error(this) << "Loop condition does not have type Bool." << endl;
        body->tc(env);
        type = Object;
        return Object;
    }

    Symbol typcase_class::tc(EnvironmentP env)
    {
        type = No_type;
        expr->tc(env);

        for (int i=cases->first(); cases->more(i); i = cases->next(i))
        {
            Case c = cases->nth(i);
            for(int j=cases->first(); j<i; j = cases->next(j))
            {
                if(cases->nth(j)->get_type_decl() == c->get_type_decl())
                {
                    env->semant_error(c) << "Duplicate branch " << c->get_type_decl() <<
                                         " in case statement." << endl;
                    break;
                }
            }

            env->var_enterscope();
            if (! env->lookup_class(c->get_type_decl()))
                env->semant_error(c) << "Class " << c->get_type_decl() <<
                                     " of case branch is undefined." << endl;

            if (c->get_name() == self)
                env->semant_error(c) << "'self' bound in 'case'." << endl;

            if (c->get_type_decl() == SELF_TYPE)
                env->semant_error(c) << "Identifier " << c->get_name() <<
                                     " declared with type SELF_TYPE in case branch." << endl;

            env->var_add(c->get_name(), c->get_type_decl());

            type = env->type_lub(type, c->tc(env));
            env->var_exitscope();
        }
        return type;
    }
// The function which runs the semantic analyser.
    InheritanceNodeP program_class::semant()
    {
        initialize_constants();
        ClassTableP classtable = new ClassTable(classes);

        if (classtable->errors()) {
            cerr << "Compilation halted due to static semantic errors." << endl;
            exit(1);
        }

        return classtable->root();
    }
////////////////////////////////////////////////////////////////////
//
// semant_error is an overloaded function for reporting errors
// during semantic analysis.  There are three versions:
//
//    ostream& ClassTable::semant_error()                
//
//    ostream& ClassTable::semant_error(Class_ c)
//       print line number and filename for `c'
//
//    ostream& ClassTable::semant_error(Symbol filename, tree_node *t)  
//       print a line number and filename
//
///////////////////////////////////////////////////////////////////

ostream& ClassTable::semant_error(Class_ c)
{                                                             
    return semant_error(c->get_filename(),c);
}    

ostream& ClassTable::semant_error(Symbol filename, tree_node *t)
{
    error_stream << filename << ":" << t->get_line_number() << ": ";
    return semant_error();
}

ostream& ClassTable::semant_error()                  
{                                                 
    semant_errors++;                            
    return error_stream;
} 



/*   This is the entry point to the semantic checker.

     Your checker should do the following two things:

     1) Check that the program is semantically correct
     2) Decorate the abstract syntax tree with type information
        by setting the `type' field in each Expression node.
        (see `tree.h')

     You are free to first do 1), make sure you catch all semantic
     errors. Part 2) can be done in a second stage, when you want
     to build mycoolc.
 */
void program_class::semant()
{
    initialize_constants();

    /* ClassTable constructor may do some semantic analysis */
    ClassTable *classtable = new ClassTable(classes);

    /* some semantic analysis code may go here */

    if (classtable->errors()) {
	cerr << "Compilation halted due to static semantic errors." << endl;
	exit(1);
    }
}


