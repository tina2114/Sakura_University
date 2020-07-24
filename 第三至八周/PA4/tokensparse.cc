//
// See copyright.h for copyright notice and limitation of liability
// and disclaimer of warranty provisions.
//
#include "copyright.h"

//////////////////////////////////////////////////////////////////////////////
//
//  tokensparse.cc
//
//  Reads a COOL token stream from a file and builds the abstract syntax tree.
//
//////////////////////////////////////////////////////////////////////////////

#include <stdio.h>     // for Linux system
#include <unistd.h>    // for getopt
#include "cool-io.h"   //includes iostream
#include "cool-tree.h"
#include "utilities.h"  // for fatal_error
#include "cool-parse.h"

//
// These globals keep everything working.
//
FILE *token_file = stdin;		// we read from this file
extern Classes parse_results;	 // list of classes; used for multiple files 
extern Program ast_root;	 // the AST produced by the parse

int curr_lineno;               // needed for lexical analyzer
char *curr_filename = "<stdin>";

extern YYSTYPE cool_yylval;

extern int cool_yylex();
// defined in utilities.cc
extern void dump_cool_token(ostream& out, int lineno, 
			    int token, YYSTYPE yylval);

void handle_flags(int argc, char *argv[]);

int main(int argc, char *argv[]) {
   int token;
   handle_flags(argc, argv);
   while ((token = cool_yylex()) != 0) {
       dump_cool_token(cout, curr_lineno, token, cool_yylval);
   }
   
   return 0;
}

