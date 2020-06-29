//
// See copyright.h for copyright notice and limitation of liability
// and disclaimer of warranty provisions.
//
#include "copyright.h"

typedef struct env_entry *Environment;

struct env_entry {
  int dummies;
  Environment next;
  Symbol name;
  int order;
};


extern void begin_cgen(char *filename);
extern void end_cgen();

extern void emit_code(char *, ...);
extern void emit_data(char *, ...);
extern void emit_string_constant(unsigned char *str);
extern int  new_label(void);

extern void cons_env(Environment *env, Symbol name);
extern void push_env(Environment *env);
extern void pop_env(Environment *env);
extern int  index_env(Environment env, Symbol name);
extern int  order_env(Environment env, Symbol name);

extern void fatal_error(char *, ...);


