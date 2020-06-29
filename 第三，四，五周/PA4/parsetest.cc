//
// See copyright.h for copyright notice and limitation of liability
// and disclaimer of warranty provisions.
//
#include "copyright.h"

//////////////////////////////////////////////////////////////////////////////
//
//  parsetest.cc
//
//  Reads input from stdin and dumps out the constructed abstract syntax
//  tree if no parse errors were found.
//
//  Option -l produces debugging info of the lexer.
//  Option -p produces debugging info of the parser.
//
//////////////////////////////////////////////////////////////////////////////

#include <stdio.h>     // for Linux system
#include "cool-tree.h"

FILE *fin;             // we read from this file
char *curr_filename;           // the file we are reading
FILE *ast_file = stdin;		// we read from this file
extern Program ast_root; // the root of the abstract syntax tree
Program handle_files(int argc, char *argv[]);
void handle_flags(int argc, char *argv[]);

int main(int argc, char *argv[]) {
  handle_flags(argc,argv);
  ast_root = handle_files(argc,argv);
  ast_root->dump_with_types(cout,0);
  return 0;
}

