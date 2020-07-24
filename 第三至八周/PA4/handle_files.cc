//
// See copyright.h for copyright notice and limitation of liability
// and disclaimer of warranty provisions.
//
#include "copyright.h"

#include <stdio.h>
#include <unistd.h>
#include "cool-tree.h"


extern int optind; // used for option processing (man 3 getopt for more info)
extern int cool_yyparse(void); // Entry point to the parser
extern FILE *fin;             // we read from this file
extern int curr_lineno;           // the lexer keeps line # up to date
extern char *curr_filename;           // the file we are reading
extern int omerrs;             // a count of lex and parse errors

extern Classes parse_results;
Classes all_classes = nil_Classes();

void handle_file(char *name) 
{
  int status;

  curr_lineno = 1;
  curr_filename = name;

  fin = fopen(name, "r");
  if (fin == NULL) 
    {
      cerr << "Could not open input file " << name << endl;
      exit(1);
    }
  status = cool_yyparse();
  all_classes = append_Classes(all_classes, parse_results);
  parse_results = nil_Classes();
  fclose(fin);
}

Program handle_files(int argc,char *argv[])
{
  while (optind < argc) {
    handle_file(argv[optind]);
    optind++;
  }

  if (omerrs != 0) {
    cerr << "Compilation halted due to lex and parse errors\n";
    exit(1);
  }

  return program(all_classes);
}
