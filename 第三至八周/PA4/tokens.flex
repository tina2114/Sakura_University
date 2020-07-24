/*
 *  A scanner definition for COOL token stream
 */
%{
#include "cool-parse.h"
#include "stringtab.h"
#include "utilities.h"

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */
#define yywrap() 1

extern FILE *token_file; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, token_file)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int verbose_flag;
extern int curr_lineno;
extern char* curr_filename;

static int prevstate;

%}

WHITESPACE [ \t\b\f\v\r\n]

SYM   [A-Za-z][_A-Za-z0-9]*
SINGLE  [+/\-*=<\.~,;:()@\}\{]

%x TOKEN STR ERR INT BOOL TYPSYM OBJSYM STRING
%%

<INITIAL,TOKEN,STR,ERR,INT,BOOL,TYPSYM,OBJSYM>{WHITESPACE}+	        {}

#[0-9]+              { curr_lineno = atoi(yytext + 1); BEGIN(TOKEN); }
#name{WHITESPACE}*\" { string_buf_ptr = string_buf; prevstate = INITIAL; BEGIN(STRING); }

<TOKEN>{
  CLASS	     { BEGIN(INITIAL); return CLASS; }
  ELSE       { BEGIN(INITIAL); return ELSE; }
  FI	     { BEGIN(INITIAL); return FI; }
  IF         { BEGIN(INITIAL); return IF; }
  IN         { BEGIN(INITIAL); return IN; }
  INHERITS   { BEGIN(INITIAL); return INHERITS; }
  LET        { BEGIN(INITIAL); return LET; }
  LOOP       { BEGIN(INITIAL); return LOOP; }
  POOL       { BEGIN(INITIAL); return POOL; }
  THEN       { BEGIN(INITIAL); return THEN; }
  WHILE      { BEGIN(INITIAL); return WHILE; }
  ASSIGN     { BEGIN(INITIAL); return ASSIGN; }
  CASE       { BEGIN(INITIAL); return CASE; }
  ESAC       { BEGIN(INITIAL); return ESAC; }
  OF         { BEGIN(INITIAL); return OF; }
  DARROW     { BEGIN(INITIAL); return DARROW; }
  NEW        { BEGIN(INITIAL); return NEW; }
  LE         { BEGIN(INITIAL); return LE; }
  NOT        { BEGIN(INITIAL); return NOT; }
  ISVOID     { BEGIN(INITIAL); return ISVOID; }

  STR_CONST  { BEGIN(STR); }
  INT_CONST  { BEGIN(INT); }
  BOOL_CONST { BEGIN(BOOL); }
  TYPEID     { BEGIN(TYPSYM); }
  OBJECTID   { BEGIN(OBJSYM); }
  ERROR	     { BEGIN(ERR); }

  \'{SINGLE}\' { BEGIN(INITIAL); return *(yytext + 1); }

  .	     { YY_FATAL_ERROR("unmatched text in token lexer; token expected"); }
}

<STR>\"	          { string_buf_ptr = string_buf; prevstate = STR; BEGIN(STRING); }
<STR>.            { YY_FATAL_ERROR("unmatched text in token lexer; string constant expected"); }

<ERR>\"	          { string_buf_ptr = string_buf; prevstate = ERR; BEGIN(STRING); }
<ERR>.            { YY_FATAL_ERROR("unmatched text in token lexer; error message expected"); }

<INT>[0-9][0-9]*  { yylval.symbol = inttable.add_string(yytext,yyleng);
		    BEGIN(INITIAL);
		    return (INT_CONST); }
<INT>.            { YY_FATAL_ERROR("unmatched text in token lexer; int constant expected"); }

<BOOL>true	  { yylval.boolean = 1; BEGIN(INITIAL); return BOOL_CONST; }
<BOOL>false	  { yylval.boolean = 0; BEGIN(INITIAL); return BOOL_CONST; }
<BOOL>.           { YY_FATAL_ERROR("unmatched text in token lexer; bool constant expected"); }

<TYPSYM>{SYM}	  { yylval.symbol = idtable.add_string(yytext, yyleng); 
		    BEGIN(INITIAL); return (TYPEID); }
<TYPSYM>.         { YY_FATAL_ERROR("unmatched text in token lexer; type symbol expected"); }

<OBJSYM>{SYM}	  { yylval.symbol = idtable.add_string(yytext, yyleng); 
		    BEGIN(INITIAL); return (OBJECTID); }
<OBJSYM>.         { YY_FATAL_ERROR("unmatched text in token lexer; object symbol expected"); }

<STRING>{
  \"	{	  /* saw closing quote - all done */

                  BEGIN(INITIAL);
                  *string_buf_ptr = '\0';
		  if (prevstate == STR) {
		      yylval.symbol = 
			     stringtable.add_string(string_buf,MAX_STR_CONST);
  		      return (STR_CONST);
                  } else if (prevstate == ERR) {
		      yylval.error_msg = strdup(string_buf);
		      return ERROR;
                  } else if (prevstate == INITIAL) {
		      curr_filename = strdup(string_buf);
		  } else {
		      YY_FATAL_ERROR("unknown state");
		  }
                }

  \\n	{ *string_buf_ptr++ = '\n'; }
  \\t	{ *string_buf_ptr++ = '\t'; }
  \\b	{ *string_buf_ptr++ = '\b'; }
  \\f	{ *string_buf_ptr++ = '\f'; }
  \\\\	{ *string_buf_ptr++ = '\\'; }
  \\\"  { *string_buf_ptr++ = '\"'; }

  \\[0-3][0-7][0-7] { 
	   /* unprintable characters are represented as octal numbers */
	     *string_buf_ptr++ = strtol(yytext+1,0,8);
	   }

  .	{ *string_buf_ptr++ = yytext[0]; }
}

<<EOF>>		{ yyterminate(); }

.		{ YY_FATAL_ERROR("unmatched text in token lexer; line number expected"); }

%%
