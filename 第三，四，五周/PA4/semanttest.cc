//
// See copyright.h for copyright notice and limitation of liability
// and disclaimer of warranty provisions.
//
#include "copyright.h"
#include <stdio.h>
#include "cool-tree.h"

extern Program ast_root; // the root of the abstract syntax tree

FILE *fin;             // we read from this file
char *curr_filename;           // the file we are reading
Program handle_files(int argc, char *argv[]);
void handle_flags(int argc, char *argv[]);

int main(int argc, char *argv[]) {

  handle_flags(argc,argv);
  ast_root = handle_files(argc,argv);
  ast_root->semant();
  ast_root->dump_with_types(cout,0);
  return 0;
}



