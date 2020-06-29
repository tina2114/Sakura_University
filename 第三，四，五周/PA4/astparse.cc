//
// See copyright.h for copyright notice and limitation of liability
// and disclaimer of warranty provisions.
//
#include "copyright.h"

//////////////////////////////////////////////////////////////////////////////
//
//  astparse.cc
//
//  Reads a COOL AST from a file and builds the abstract syntax tree.
//
//////////////////////////////////////////////////////////////////////////////

#include <stdio.h>     // for Linux system
#include <unistd.h>    // for getopt
#include "cool-io.h"
#include "cool-tree.h"
#include "utilities.h"  // for fatal_error

//
// These globals keep everything working.
//
FILE *ast_file = stdin;		// we read from this file
extern Classes parse_results;	 // list of classes; used for multiple files 
extern Program ast_root;	 // the AST produced by the parse

extern int ast_yyparse(void);  // entry point to the parser
int cool_yydebug;              // needed to link with handle_flags
int curr_lineno;               // needed for lexical analyzer

void handle_flags(int argc, char *argv[]);

int main(int argc, char *argv[]) {
  handle_flags(argc, argv);
  int parse_status = ast_yyparse();
  ast_root->dump(cout,0);
  return 0;
}

