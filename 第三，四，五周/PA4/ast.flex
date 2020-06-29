/*
 *  A scanner definition for COOL ASTs.
 */
%{
#include "ast-parse.h"
#include "stringtab.h"
#include "utilities.h"

/* The compiler assumes these identifiers. */
#define yylval ast_yylval
#define yylex  ast_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */
#define yywrap() 1

extern FILE *ast_file; /* we read from this file */

#define yy_fread fread

// bhackett:
// uncomment the following to get line # tracking during parsing
// for debugging purposes. the change to YY_READ_BUF_SIZE is a hack
// so that the lexer's position will be somewhere close to the parser
// rather than having skipped ahead hundreds of lines
/*
#define YY_READ_BUF_SIZE 20
extern int current_line;
int fread_track_line(void *ptr, size_t size, size_t nitems, FILE *stream)
{
  int result = fread(ptr, size, nitems, stream);
  if (result < 0)
    return result;

  assert(size == 1);
  char *buf = (char*)ptr;
  for (int pos = 0; pos < result; pos++)
  {
    if (buf[pos] == '\n')
      current_line++;
  }

  return result;
}
#undef yy_fread
#define yy_fread fread_track_line
*/

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = yy_fread( (char*)buf, sizeof(char), max_size, ast_file)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int verbose_flag;

extern YYSTYPE ast_yylval;

YYSTYPE cool_yylval;  /* needed to link ast code with utilities.cc */

%}

WHITESPACE [ \t\b\f\v\r\n]

SYM   [A-Za-z][_A-Za-z0-9]*

%x STRING
%%

{WHITESPACE}+	        {}
[0-9][0-9]*     { yylval.symbol = inttable.add_string(yytext,yyleng);
		  return (INT_CONST); }

#[0-9]*         { yylval.lineno = atoi(yytext + 1); 
		  return (LINENO); }

_program 		{ return(PROGRAM); }
_class			{ return(CLASS); }
_method			{ return(METHOD); }
_attr			{ return(ATTR); }
_formal			{ return(FORMAL); }
_branch			{ return(BRANCH); }
_assign			{ return(ASSIGN); }
_static_dispatch	{ return(STATIC_DISPATCH); }
_dispatch		{ return(DISPATCH); }
_cond			{ return(COND); }
_loop			{ return(LOOP); }
_typcase		{ return(TYPCASE); }
_block			{ return(BLOCK); }
_let			{ return(LET); }
_plus			{ return(PLUS); }
_sub			{ return(SUB); }
_mul			{ return(MUL); }
_divide			{ return(DIVIDE); }
_neg			{ return(NEG); }
_lt			{ return(LT); }
_eq			{ return(EQ); }
_leq			{ return(LEQ); }
_comp			{ return(COMP); }
_int			{ return(INT); }
_string			{ return(STR); }
_bool			{ return(BOOL); }
_new			{ return(NEW); }
_isvoid			{ return(ISVOID); }
_no_expr		{ return(NO_EXPR); }
_no_type		{ return(NO_TYPE); }
_object			{ return(OBJECT); }

[:()]			{ return(*yytext); }


{SYM}		{ yylval.symbol = idtable.add_string(yytext, yyleng); 
		  return (ID); }


 /*
  *  String constants (C syntax, taken from lexdoc(1) )
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */


\"      string_buf_ptr = string_buf; BEGIN(STRING);

<STRING>\"	{
		  /* saw closing quote - all done */

                  BEGIN(INITIAL);
                  *string_buf_ptr = '\0';
		  yylval.symbol = 
	               stringtable.add_string(string_buf,MAX_STR_CONST);
		  return (STR_CONST);
                }

<STRING>\\n	{ *string_buf_ptr++ = '\n'; }
<STRING>\\t	{ *string_buf_ptr++ = '\t'; }
<STRING>\\b	{ *string_buf_ptr++ = '\b'; }
<STRING>\\f	{ *string_buf_ptr++ = '\f'; }
<STRING>\\\\	{ *string_buf_ptr++ = '\\'; }
<STRING>\\\"    { *string_buf_ptr++ = '\"'; }

<STRING>\\[0-9]* { 
	/* unprintable characters are represented as octal numbers */
		   *string_buf_ptr++ = strtol(yytext+1,0,8);
		 }

<STRING>.	{ *string_buf_ptr++ = yytext[0]; }

<<EOF>>		{ yyterminate(); }

%%
