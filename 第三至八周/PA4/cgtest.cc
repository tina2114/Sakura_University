//
// See copyright.h for copyright notice and limitation of liability
// and disclaimer of warranty provisions.
//
#include "copyright.h"

#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include "cool-io.h"
#include "cool-tree.h"
#include "cgen_gc.h"


extern int optind;  // used for option processing (man 3 getopt for more info)
extern char *out_filename;   // name of output assembly
extern Program ast_root;
FILE *fin;             // we read from this file
char *curr_filename;           // the file we are reading

Program handle_files(int argc, char *argv[]);
void handle_flags(int argc, char *argv[]);

int main(int argc, char *argv[]) {
  int firstfile_index;

  handle_flags(argc,argv);
  firstfile_index = optind;

  ast_root = handle_files(argc,argv);
  ast_root->semant();

  if (!out_filename) {   // no -o option
    char *dot = strrchr(argv[firstfile_index], '.');
    if (dot) *dot = '\0'; // strip off file extension
    out_filename = new char[strlen(argv[firstfile_index])+8];
    strcpy(out_filename, argv[firstfile_index]);
    strcat(out_filename, ".s");
  }

  ofstream s(out_filename);
  if (!s)
    {
      cerr << "Cannot open output file " << out_filename << endl;
      exit(1);
    }
  ast_root->cgen(s);
}





