/*
  The scanner definition for COOL.
*/
%{
/*
   See copyright.h for copyright notice, limitation of liability,
   and disclaimer of warranty provisions.

   sm 1/27/01:  I have made a rather significant change to PA2:
   We now do *not* require students to collect consecutive error
   characters (instead they are now reported one at a time).
   The ostensible rationale for this requirement was
   that it provides a little experience dealing with the nitty-
   gritty reality of these tools.  However, it has these problems:
     - it offers no diagnostic value
     - can't use '.' to mean "everything else"
     - unfair to C++ students since C makes it difficult to
       put NULL inside strings
     - malloc/etc is so much hacking (since only soln to encoding
       is to collect piecewise)
     - encoding problem means c/java have diff't output
   Therefore I have changed the code below.  I removed quite a bit
   of mechanism.  If one wants to get it back, get a version out of
   CVS that is earlier than 1/27/01.
*/
#include "copyright.h"

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
#define YY_SKIP_YYWRAP

/*
 *   The check is applied before we add characters to the buffer.
 */
#define check_string_overflow \
  if (string_buf_ptr - string_buf >= MAX_STR_CONST) { \
    yylval.error_msg = "String constant too long";  \
    BEGIN(STRING_RECOVER); \
    return (ERROR); }

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;
                               
/* buffer for returning single bad characters, always
 * guaranteed to have a \0 in the 2nd slot */
char bad_char_buf[2] = { 0,0 };

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

%}

NEWLINE [\n]
WHITESPACE [ \t\f\v\r]

TYPESYM   [A-Z][_A-Za-z0-9]*
OBJECTSYM [a-z][_A-Za-z0-9]*

/* added {} to single and illegal, JDD 8/16/96 */
SINGLE  [+/\-*=<\.~,;:()@\}\{]

/* \0 is removed from illegal because it requires special handling */
ILLEGAL	[^\n \t\f\v\rA-Za-z0-9+/\-*=<\.~,;:()@\}\{"\0]
NULL \0
LEGAL   [\n \t\f\v\rA-Za-z0-9+/\-*=<\.~,;:()@\}\{"]

%x COMMENT
%x LINE_COMMENT
%x STRING
	/* To recover from overly long string constants */
%x STRING_RECOVER

/* sm: automatically report coverage holes */
%option nodefault

%%

	int comment_nesting = 0; /* Keep track of nesting level in comments */


{NEWLINE}	        curr_lineno++;
{WHITESPACE}+	        {}
"--"                    { BEGIN(LINE_COMMENT); }
<LINE_COMMENT>{
  .*        {}
  \n        { BEGIN(INITIAL); curr_lineno++; }
  <<EOF>>   { BEGIN(INITIAL); }
}

{SINGLE}	        { return (*yytext); }

 /*
  *  Nested comments
  */

<INITIAL>"(*"		{ BEGIN(COMMENT);
			  comment_nesting++;
			}
<INITIAL>"*)"		{ /* error - unmatched comment */
			  yylval.error_msg = "Unmatched *)";
			  return (ERROR);
                	}

<COMMENT>{
  "(*"		comment_nesting++;
  "*)"		{ comment_nesting--;
		  if (comment_nesting == 0)
			BEGIN(INITIAL);
		}

  [^(*\n]+	/* eat anything that's not a '*', '(', or '\n' */
  "("		/* eat up other '('s */
  "*"		/* eat up other '*'s */

  {NEWLINE}	curr_lineno++;

  <<EOF>>	{ /* error - unterminated comment */
		  yylval.error_msg = "EOF in comment";
		  BEGIN(INITIAL);
		  return (ERROR);
               	}
}

 /*
  *  The multiple-character operators.
  */
"=>"		{ return (DARROW); }
"<="		{ return (LE); }
"<-"		{ return (ASSIGN); }
[0-9][0-9]*     { yylval.symbol = inttable.add_string(yytext,yyleng);
		  return (INT_CONST); }
 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */


[Cc][Aa][Ss][Ee]		{ return (CASE); }
[Cc][Ll][Aa][Ss][Ss] 		{ return (CLASS); }
[Ee][Ll][Ss][Ee]  		{ return (ELSE); }
[Ee][Ss][Aa][Cc]		{ return (ESAC); }
[Ff][Ii]              		{ return (FI); }
[Ii][Ff]  			{ return (IF); }
[Ii][Nn]              		{ return (IN); }
[Ii][Nn][Hh][Ee][Rr][Ii][Tt][Ss] { return (INHERITS); }

  /* [Ii][Ss]  			{ return (IS); } */
[Ii][Ss][Vv][Oo][Ii][Dd]	{ return (ISVOID); }
[Ll][Ee][Tt]             	{ return (LET); }
[Ll][Oo][Oo][Pp]  		{ return (LOOP); }
[Nn][Ee][Ww]			{ return (NEW); }
[Nn][Oo][Tt]  			{ return (NOT); }
[Oo][Ff]			{ return (OF); }
[Pp][Oo][Oo][Ll]  		{ return (POOL); }
[Tt][Hh][Ee][Nn]   		{ return (THEN); }
t[Rr][Uu][Ee]			{ yylval.boolean = 1;
                  		  return (BOOL_CONST); }
f[Aa][Ll][Ss][Ee]		{ yylval.boolean = 0;
				  return (BOOL_CONST); }
[Ww][Hh][Ii][Ll][Ee]           	{ return (WHILE); }

{TYPESYM}	{ yylval.symbol = idtable.add_string(yytext, yyleng); 
		  return (TYPEID); }

{OBJECTSYM}	{ yylval.symbol = idtable.add_string(yytext, yyleng); 
		  return (OBJECTID); }


 /*
  *  String constants (C syntax, taken from lexdoc(1) )
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *  (but note that 'c' can't be the NUL character)
  *
  */


\"      string_buf_ptr = string_buf; BEGIN(STRING);

<STRING>{
\"	{
		  /* saw closing quote - all done */

          BEGIN(INITIAL);
	  if (string_buf_ptr - string_buf >= MAX_STR_CONST)
	  {
	    yylval.error_msg = "String constant too long";
	    return (ERROR);
	  }
          *string_buf_ptr = '\0';
	  yylval.symbol = 
          stringtable.add_string(string_buf,MAX_STR_CONST);
	  return (STR_CONST);
        }

\n      {
          /* error - unterminated string constant */
          /* generate error message */

	  curr_lineno++;
	  yylval.error_msg = "Unterminated string constant";
	  BEGIN(INITIAL);
	  return (ERROR);
        }

<<EOF>> {
          /* error - unterminated string constant */
          /* generate error message */

	  yylval.error_msg = "EOF in string constant";
	  BEGIN(INITIAL);
	  return (ERROR);
        }

\\      {
	  /* matches only if "\" is the last character in the file.*/
	  yylval.error_msg = "backslash at end of file";
	  BEGIN(INITIAL);
	  return (ERROR);
        }

\\n	{ check_string_overflow; *string_buf_ptr++ = '\n'; }
\\t	{ check_string_overflow; *string_buf_ptr++ = '\t'; }
\\b	{ check_string_overflow; *string_buf_ptr++ = '\b'; }
\\f	{ check_string_overflow; *string_buf_ptr++ = '\f'; }

\\\0	{
	  yylval.error_msg = "String contains escaped null character.";
	  BEGIN(STRING_RECOVER);
	  return(ERROR);
        }

\0	{
	  yylval.error_msg = "String contains null character.";
	  BEGIN(STRING_RECOVER);
	  return(ERROR);
        }

\\.     { check_string_overflow; *string_buf_ptr++ = yytext[1]; }
\\\n    { curr_lineno++;
		  check_string_overflow;
		  *string_buf_ptr++ = yytext[1];
		}


[^\\\n\"\0]+	{
                  char *tmp_ptr = yytext;

		  if (string_buf_ptr + yyleng - string_buf >
		      MAX_STR_CONST)
		  {
	            /* Discard previous part of string */
		    string_buf_ptr = string_buf;
		    yylval.error_msg = "String constant too long";
		    BEGIN(STRING_RECOVER);
		    return (ERROR);
		  }
       	          while ( *tmp_ptr )
                    *string_buf_ptr++ = *tmp_ptr++; 
                }
}

<STRING_RECOVER>{
\"	{
	  /* saw closing quote - done with that overly long string */
          BEGIN(INITIAL); /* Continue normally */
        }

\n      {
	  /* end of line while looking for end of overly long string */
	  /* Now we assume that second double quote is missing. */
	  curr_lineno++;
	  BEGIN(INITIAL); /* just continue in normal mode. */
        }

<<EOF>> {
	  /* End of file while recovering from overly long string */
	  yyterminate();
        }

\\.     { /* Need not do anything */ }
\\\n    { curr_lineno++; }

[^\\\n\"]+	{ /* Need not do anything */ } 

\\      { /* backslash at end of file in recovery, ignore */ }
}


{ILLEGAL}|{NULL}        { bad_char_buf[0] = yytext[0];
			  yylval.error_msg = bad_char_buf;
			  return ERROR; }

<<EOF>>			{ yyterminate(); }

%%
