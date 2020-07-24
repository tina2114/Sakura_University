/*
 *  ast.y
 *              Parser definition for reading Cool abstract syntax trees.
 *
 */
%{
#include "cool-io.h"
#include "cool-tree.h"
#include "stringtab.h"
#include "utilities.h"

void ast_yyerror(char *);
extern int node_lineno;
extern int yylex();           /* the entry point to the lexer  */
Program ast_root;             /* the result of the parse  */
Classes parse_results;        /* for use in parsing multiple files */
int omerrs = 0;               /* number of errors in lexing and parsing */
int current_line = 0;         /* debugging, current line for input file */
%}

/* A union of all the types that can be the result of parsing actions. */
%union {
  int lineno;
  Boolean boolean;
  Symbol symbol;
  Program program;
  Class_ class_;
  Classes classes;
  Feature feature;
  Features features;
  Formal formal;
  Formals formals;
  Case case_;
  Cases cases;
  Expression expression;
  Expressions expressions;
}

/* Declare types for the grammar's non-terminals. */
%type <program> program
%type <classes> class_list
%type <class_> class
%type <features> feature_list optional_feature_list
%type <feature> feature
%type <formals> formals formal_list
%type <formal> formal
%type <expression> expr_aux expr
%type <expressions> actuals expr_list
%type <cases> case_list
%type <case_> simple_case


/* 
   Declare the terminals; a few have types for associated lexemes.
   The token ERROR is never used in the parser; thus, it is a parse
   error when the lexer returns it.
*/
%token PROGRAM CLASS METHOD ATTR FORMAL BRANCH ASSIGN STATIC_DISPATCH DISPATCH 
%token COND LOOP TYPCASE BLOCK LET PLUS SUB MUL DIVIDE NEG LT EQ LEQ
%token COMP INT STR BOOL NEW ISVOID NO_EXPR OBJECT NO_TYPE
%token <symbol>  STR_CONST INT_CONST ID
%token <lineno>  LINENO


%%
/* 
   Save the root of the abstract syntax tree in a global variable.
*/
program	: nothing LINENO PROGRAM class_list 
                { node_lineno = $2; ast_root = program($4); }
        | nothing
                { exit(1); }
        ;

// reset the line number to 1 each time we start a new program
nothing : /* empty input */
                { current_line = 1; }
        ;

class_list
	: class			/* single class */
		{ $$ = single_Classes($1);
                  parse_results = $$; }
	| class_list class	/* several classes */
		{ $$ = append_Classes($1,single_Classes($2)); 
                  parse_results = $$; }
	;

class	: LINENO CLASS ID ID STR_CONST '(' optional_feature_list ')'
		{ node_lineno = $1;
		  $$ = class_($3,$4,$7,$5); }
	;

/* Feature list may be empty, but no empty features in list. */
optional_feature_list:		/* empty */
                {  $$ = nil_Features(); }
        | feature_list
                {  $$ = $1; }
        ;

feature_list
	: feature
		{  $$ = single_Features($1); }
	| feature_list feature   	/* Several features */
		{  $$ = append_Features($1,single_Features($2)); }
	;

feature : LINENO METHOD ID  formals ID expr
		{ node_lineno = $1; $$ = method($3,$4,$5,$6); }
	| LINENO ATTR ID ID expr 
		{ node_lineno = $1; $$ = attr($3,$4,$5); }
	;

formals	:  		/* allow an empty formal list */
		{ $$ = nil_Formals(); }
	| formal_list 
		{ $$ = $1; }
	;

formal_list
	: formal 		 /* One formal */
		{  $$ = single_Formals($1); }            
	| formal_list formal /* Several declarations */
		{ $$ = append_Formals($1,single_Formals($2)); }
	;

formal	: LINENO FORMAL ID ID 
		{  node_lineno = $1; $$ = formal($3,$4); }
	;

expr    : expr_aux ':' ID 
          { $$ = $1;
            $$->set_type($3); }

        | expr_aux ':' NO_TYPE
          { $$ = $1; }
   ;
expr_aux : LINENO ASSIGN ID expr
          { node_lineno = $1; $$ = assign($3,$4); }

        | LINENO STATIC_DISPATCH expr ID ID actuals
          { node_lineno = $1; $$ = static_dispatch($3,$4,$5,$6);}

        | LINENO DISPATCH expr ID actuals
          { node_lineno = $1; $$ = dispatch($3,$4,$5); }

        | LINENO COND expr expr expr
          { node_lineno = $1; $$ = cond($3,$4,$5); }

        | LINENO LOOP expr expr
          { node_lineno = $1; $$ = loop($3,$4); }

        | LINENO BLOCK expr_list
          { node_lineno = $1; $$ = block($3); }

        | LINENO LET ID ID expr expr
          { node_lineno = $1; $$ = let($3,$4,$5,$6); }

        | LINENO TYPCASE expr case_list
          { node_lineno = $1; $$ = typcase($3,$4); }

        | LINENO NEW ID
          { node_lineno = $1; $$ = new_($3); }

        | LINENO ISVOID expr
          { node_lineno = $1; $$ = isvoid($3); }

        | LINENO PLUS expr expr 
          { node_lineno = $1; $$ = plus($3,$4); }

        | LINENO SUB expr expr
          { node_lineno = $1; $$ = sub($3,$4); }

        | LINENO MUL expr expr
          { node_lineno = $1; $$ = mul($3,$4); }

        | LINENO DIVIDE expr expr
          { node_lineno = $1; $$ = divide($3,$4); }

        | LINENO NEG expr
          { node_lineno = $1; $$ = neg($3); }

        | LINENO LT expr expr
          { node_lineno = $1; $$ = lt($3,$4); }

        | LINENO EQ expr expr
          { node_lineno = $1; $$ = eq($3,$4); }

        | LINENO LEQ expr expr
          { node_lineno = $1; $$ = leq($3,$4); }

	| LINENO COMP expr
          { node_lineno = $1; $$ = comp($3); }

        | LINENO INT INT_CONST
          { node_lineno = $1; $$ = int_const($3); }

        | LINENO STR STR_CONST
          { node_lineno = $1; $$ = string_const($3); }

        | LINENO BOOL INT_CONST
          { node_lineno = $1; 
            if (*($3->get_string()) == '1')
	      $$ = bool_const(1); 
	    else
              $$ = bool_const(0);
          }

        | LINENO OBJECT ID 
          { node_lineno = $1; $$ = object($3); }

        | LINENO NO_EXPR
          { node_lineno = $1; $$ = no_expr(); }
        ;

actuals	: '(' ')'
		{  $$ = nil_Expressions(); }
	| '(' expr_list ')'	// List of argument values 
		{  $$ = $2; }
	;

expr_list
	: expr			/* One expression */
		{ $$ = single_Expressions($1); }
	| expr_list expr	/* Several expressions */
		{ $$ = append_Expressions($1,single_Expressions($2)); }
	;

case_list
        : simple_case   	/* One branch */
                { $$ = single_Cases($1); }
        | case_list  simple_case 
                { $$ = append_Cases($1,single_Cases($2)); }
        ;

simple_case
        : LINENO BRANCH ID ID expr 
                { node_lineno = $1; $$ = branch($3,$4,$5); }
        ;


/* end of grammar */
%%

void ast_yyerror(char *msg)
{
   cerr << "Error in ast parsing (line " << current_line << "): ";
   cerr << msg << endl;
   exit(1);
}

