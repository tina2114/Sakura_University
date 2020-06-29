/* A Bison parser, made by GNU Bison 1.875.  */

/* Skeleton parser for Yacc-like parsing with Bison,
   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002 Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place - Suite 330,
   Boston, MA 02111-1307, USA.  */

/* As a special exception, when this file is copied by Bison into a
   Bison output file, you may use that output file without restriction.
   This special exception was added by the Free Software Foundation
   in version 1.24 of Bison.  */

/* Written by Richard Stallman by simplifying the original so called
   ``semantic'' parser.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output.  */
#define YYBISON 1

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 0

/* Using locations.  */
#define YYLSP_NEEDED 1

/* If NAME_PREFIX is specified substitute the variables and functions
   names.  */
#define yyparse cool_yyparse
#define yylex   cool_yylex
#define yyerror cool_yyerror
#define yylval  cool_yylval
#define yychar  cool_yychar
#define yydebug cool_yydebug
#define yynerrs cool_yynerrs
#define yylloc cool_yylloc

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     CLASS = 258,
     ELSE = 259,
     FI = 260,
     IF = 261,
     IN = 262,
     INHERITS = 263,
     LET = 264,
     LOOP = 265,
     POOL = 266,
     THEN = 267,
     WHILE = 268,
     CASE = 269,
     ESAC = 270,
     OF = 271,
     DARROW = 272,
     NEW = 273,
     ISVOID = 274,
     STR_CONST = 275,
     INT_CONST = 276,
     BOOL_CONST = 277,
     TYPEID = 278,
     OBJECTID = 279,
     ASSIGN = 280,
     NOT = 281,
     LE = 282,
     ERROR = 283,
     LET_STMT = 285
   };
#endif
#define CLASS 258
#define ELSE 259
#define FI 260
#define IF 261
#define IN 262
#define INHERITS 263
#define LET 264
#define LOOP 265
#define POOL 266
#define THEN 267
#define WHILE 268
#define CASE 269
#define ESAC 270
#define OF 271
#define DARROW 272
#define NEW 273
#define ISVOID 274
#define STR_CONST 275
#define INT_CONST 276
#define BOOL_CONST 277
#define TYPEID 278
#define OBJECTID 279
#define ASSIGN 280
#define NOT 281
#define LE 282
#define ERROR 283
#define LET_STMT 285




/* Copy the first part of user declarations.  */
#line 6 "cool.y"

/*
   See copyright.h for copyright notice, limitation of liability,
   and disclaimer of warranty provisions.
*/
#include "copyright.h"

#include "cool-io.h" //includes iostream
#include "cool-tree.h"
#include "stringtab.h"
#include "utilities.h"

/* Locations */
#define YYLTYPE int              /* the type of locations */
#define cool_yylloc curr_lineno  /* use the curr_lineno from the lexer
                                    for the location of tokens */
extern int node_lineno;          /* set before constructing a tree node
                                    to whatever you want the line number
                                    for the tree node to be */

/* The default action for locations.  Use the location of the first
   terminal/non-terminal and set the node_lineno to that value. */
#define YYLLOC_DEFAULT(Current, Rhs, N)         \
  Current = Rhs[1];                             \
  node_lineno = Current;

#define SET_NODELOC(Current)  \
  node_lineno = Current;

extern char *curr_filename;

void yyerror(char *s);        /*  defined below; called for each parse error */
extern int yylex();           /*  the entry point to the lexer  */
Program ast_root;	      /* the result of the parse  */
Classes parse_results;        /* for use in semantic analysis */
int omerrs = 0;               /* number of erros in lexing and parsing */



/* Enabling traces.  */
#ifndef YYDEBUG
# define YYDEBUG 1
#endif

/* Enabling verbose error messages.  */
#ifdef YYERROR_VERBOSE
# undef YYERROR_VERBOSE
# define YYERROR_VERBOSE 1
#else
# define YYERROR_VERBOSE 0
#endif

#if ! defined (YYSTYPE) && ! defined (YYSTYPE_IS_DECLARED)
#line 46 "cool.y"
typedef union YYSTYPE {
  Boolean boolean;
  Symbol symbol;
  Program program;
  Class_ class_;
  Classes classes;
  Feature feature;
  Features features;
  Formal formal;
  Formals formals;
  Case case_;
  Cases cases;
  Expression expression;
  Expressions expressions;
  char *error_msg;
} YYSTYPE;
/* Line 191 of yacc.c.  */
#line 198 "cool.tab.c"
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif

#if ! defined (YYLTYPE) && ! defined (YYLTYPE_IS_DECLARED)
typedef struct YYLTYPE
{
  int first_line;
  int first_column;
  int last_line;
  int last_column;
} YYLTYPE;
# define yyltype YYLTYPE /* obsolescent; will be withdrawn */
# define YYLTYPE_IS_DECLARED 1
# define YYLTYPE_IS_TRIVIAL 1
#endif


/* Copy the second part of user declarations.  */


/* Line 214 of yacc.c.  */
#line 222 "cool.tab.c"

#if ! defined (yyoverflow) || YYERROR_VERBOSE

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# if YYSTACK_USE_ALLOCA
#  define YYSTACK_ALLOC alloca
# else
#  ifndef YYSTACK_USE_ALLOCA
#   if defined (alloca) || defined (_ALLOCA_H)
#    define YYSTACK_ALLOC alloca
#   else
#    ifdef __GNUC__
#     define YYSTACK_ALLOC __builtin_alloca
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's `empty if-body' warning. */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (0)
# else
#  if defined (__STDC__) || defined (__cplusplus)
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   define YYSIZE_T size_t
#  endif
#  define YYSTACK_ALLOC malloc
#  define YYSTACK_FREE free
# endif
#endif /* ! defined (yyoverflow) || YYERROR_VERBOSE */


#if (! defined (yyoverflow) \
     && (! defined (__cplusplus) \
	 || (YYLTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  short yyss;
  YYSTYPE yyvs;
    YYLTYPE yyls;
};

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (sizeof (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (sizeof (short) + sizeof (YYSTYPE) + sizeof (YYLTYPE))	\
      + 2 * YYSTACK_GAP_MAXIMUM)

/* Copy COUNT objects from FROM to TO.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if 1 < __GNUC__
#   define YYCOPY(To, From, Count) \
      __builtin_memcpy (To, From, (Count) * sizeof (*(From)))
#  else
#   define YYCOPY(To, From, Count)		\
      do					\
	{					\
	  register YYSIZE_T yyi;		\
	  for (yyi = 0; yyi < (Count); yyi++)	\
	    (To)[yyi] = (From)[yyi];		\
	}					\
      while (0)
#  endif
# endif

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack)					\
    do									\
      {									\
	YYSIZE_T yynewbytes;						\
	YYCOPY (&yyptr->Stack, Stack, yysize);				\
	Stack = &yyptr->Stack;						\
	yynewbytes = yystacksize * sizeof (*Stack) + YYSTACK_GAP_MAXIMUM; \
	yyptr += yynewbytes / sizeof (*yyptr);				\
      }									\
    while (0)

#endif

#if defined (__STDC__) || defined (__cplusplus)
   typedef signed char yysigned_char;
#else
   typedef short yysigned_char;
#endif

/* YYFINAL -- State number of the termination state. */
#define YYFINAL  8
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   355

/* YYNTOKENS -- Number of terminals. */
#define YYNTOKENS  46
/* YYNNTS -- Number of nonterminals. */
#define YYNNTS  18
/* YYNRULES -- Number of rules. */
#define YYNRULES  65
/* YYNRULES -- Number of states. */
#define YYNSTATES  153

/* YYTRANSLATE(YYLEX) -- Bison symbol number corresponding to YYLEX.  */
#define YYUNDEFTOK  2
#define YYMAXUTOK   285

#define YYTRANSLATE(YYX) 						\
  ((unsigned int) (YYX) <= YYMAXUTOK ? yytranslate[YYX] : YYUNDEFTOK)

/* YYTRANSLATE[YYLEX] -- Bison symbol number corresponding to YYLEX.  */
static const unsigned char yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
      43,    44,    34,    33,    45,    32,    38,    35,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,    42,    39,
      30,    31,     2,     2,    37,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,    40,     2,    41,    36,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     4,
       5,     6,     7,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      25,    26,    27,    28,     2,    29
};

#if YYDEBUG
/* YYPRHS[YYN] -- Index of the first RHS symbol of rule number YYN in
   YYRHS.  */
static const unsigned char yyprhs[] =
{
       0,     0,     3,     5,     7,     9,    12,    15,    19,    26,
      35,    36,    38,    41,    44,    48,    52,    60,    65,    66,
      69,    72,    76,    80,    82,    86,    90,    97,   101,   108,
     112,   116,   123,   128,   136,   142,   146,   149,   155,   158,
     161,   165,   169,   173,   177,   180,   184,   188,   192,   195,
     199,   201,   203,   205,   207,   210,   213,   216,   220,   224,
     227,   231,   233,   237,   239,   242
};

/* YYRHS -- A `-1'-separated list of the rules' RHS. */
static const yysigned_char yyrhs[] =
{
      47,     0,    -1,    48,    -1,     1,    -1,    49,    -1,     1,
      39,    -1,    48,    49,    -1,    48,     1,    39,    -1,     3,
      23,    40,    50,    41,    39,    -1,     3,    23,     8,    23,
      40,    50,    41,    39,    -1,    -1,    51,    -1,    52,    39,
      -1,     1,    39,    -1,    51,    52,    39,    -1,    51,     1,
      39,    -1,    24,    54,    42,    23,    40,    58,    41,    -1,
      24,    42,    23,    53,    -1,    -1,    25,    58,    -1,    43,
      44,    -1,    43,    55,    44,    -1,    43,     1,    44,    -1,
      56,    -1,    55,    45,    56,    -1,    24,    42,    23,    -1,
      24,    42,    23,    53,     7,    58,    -1,     1,     7,    58,
      -1,    24,    42,    23,    53,    45,    57,    -1,     1,    45,
      57,    -1,    24,    25,    58,    -1,    58,    37,    23,    38,
      24,    60,    -1,    58,    38,    24,    60,    -1,     6,    58,
      12,    58,     4,    58,     5,    -1,    13,    58,    10,    58,
      11,    -1,    40,    59,    41,    -1,     9,    57,    -1,    14,
      58,    16,    62,    15,    -1,    18,    23,    -1,    19,    58,
      -1,    58,    33,    58,    -1,    58,    32,    58,    -1,    58,
      34,    58,    -1,    58,    35,    58,    -1,    36,    58,    -1,
      58,    30,    58,    -1,    58,    31,    58,    -1,    58,    27,
      58,    -1,    26,    58,    -1,    43,    58,    44,    -1,    21,
      -1,    20,    -1,    22,    -1,    24,    -1,    24,    60,    -1,
      58,    39,    -1,     1,    39,    -1,    59,    58,    39,    -1,
      59,     1,    39,    -1,    43,    44,    -1,    43,    61,    44,
      -1,    58,    -1,    61,    45,    58,    -1,    63,    -1,    62,
      63,    -1,    24,    42,    23,    17,    58,    39,    -1
};

/* YYRLINE[YYN] -- source line where rule number YYN was defined.  */
static const unsigned short yyrline[] =
{
       0,   116,   116,   119,   123,   127,   129,   132,   137,   140,
     146,   147,   152,   155,   157,   159,   163,   165,   171,   172,
     176,   178,   180,   185,   187,   191,   195,   197,   199,   201,
     204,   206,   209,   212,   214,   216,   218,   220,   222,   224,
     226,   229,   232,   235,   238,   240,   243,   246,   249,   251,
     253,   255,   257,   259,   261,   268,   270,   272,   274,   278,
     280,   285,   287,   292,   294,   299
};
#endif

#if YYDEBUG || YYERROR_VERBOSE
/* YYTNME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals. */
static const char *const yytname[] =
{
  "$end", "error", "$undefined", "CLASS", "ELSE", "FI", "IF", "IN", 
  "INHERITS", "LET", "LOOP", "POOL", "THEN", "WHILE", "CASE", "ESAC", 
  "OF", "DARROW", "NEW", "ISVOID", "STR_CONST", "INT_CONST", "BOOL_CONST", 
  "TYPEID", "OBJECTID", "ASSIGN", "NOT", "LE", "ERROR", "LET_STMT", "'<'", 
  "'='", "'-'", "'+'", "'*'", "'/'", "'~'", "'@'", "'.'", "';'", "'{'", 
  "'}'", "':'", "'('", "')'", "','", "$accept", "program", "class_list", 
  "class", "optional_feature_list", "feature_list", "feature", 
  "optional_initialization", "formals", "formal_list", "formal", 
  "let_list", "expr", "stmt_list", "actuals", "exp_list", "case_list", 
  "simple_case", 0
};
#endif

# ifdef YYPRINT
/* YYTOKNUM[YYLEX-NUM] -- Internal token number corresponding to
   token YYLEX-NUM.  */
static const unsigned short yytoknum[] =
{
       0,   256,   284,   258,   259,   260,   261,   262,   263,   264,
     265,   266,   267,   268,   269,   270,   271,   272,   273,   274,
     275,   276,   277,   278,   279,   280,   281,   282,   283,   285,
      60,    61,    45,    43,    42,    47,   126,    64,    46,    59,
     123,   125,    58,    40,    41,    44
};
# endif

/* YYR1[YYN] -- Symbol number of symbol that rule YYN derives.  */
static const unsigned char yyr1[] =
{
       0,    46,    47,    47,    48,    48,    48,    48,    49,    49,
      50,    50,    51,    51,    51,    51,    52,    52,    53,    53,
      54,    54,    54,    55,    55,    56,    57,    57,    57,    57,
      58,    58,    58,    58,    58,    58,    58,    58,    58,    58,
      58,    58,    58,    58,    58,    58,    58,    58,    58,    58,
      58,    58,    58,    58,    58,    59,    59,    59,    59,    60,
      60,    61,    61,    62,    62,    63
};

/* YYR2[YYN] -- Number of symbols composing right hand side of rule YYN.  */
static const unsigned char yyr2[] =
{
       0,     2,     1,     1,     1,     2,     2,     3,     6,     8,
       0,     1,     2,     2,     3,     3,     7,     4,     0,     2,
       2,     3,     3,     1,     3,     3,     6,     3,     6,     3,
       3,     6,     4,     7,     5,     3,     2,     5,     2,     2,
       3,     3,     3,     3,     2,     3,     3,     3,     2,     3,
       1,     1,     1,     1,     2,     2,     2,     3,     3,     2,
       3,     1,     3,     1,     2,     6
};

/* YYDEFACT[STATE-NAME] -- Default rule to reduce with in state
   STATE-NUM when YYTABLE doesn't specify something else to do.  Zero
   means the default is an error.  */
static const unsigned char yydefact[] =
{
       0,     3,     0,     0,     0,     4,     5,     0,     1,     0,
       6,     0,     0,     7,     0,     0,     0,     0,     0,     0,
       0,    13,     0,     0,     0,     0,     0,     0,    12,     0,
      18,     0,     0,    20,     0,    23,     0,     8,    15,    14,
       0,     0,    17,    22,     0,    21,     0,     0,     9,     0,
       0,     0,     0,     0,     0,    51,    50,    52,    53,     0,
       0,     0,     0,    19,    25,    24,     0,     0,     0,     0,
      36,     0,     0,    38,    39,     0,     0,    54,    48,    44,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      30,    59,    61,     0,    56,    55,     0,    35,     0,    49,
      47,    45,    46,    41,    40,    42,    43,     0,     0,    16,
       0,    27,    29,    18,     0,     0,     0,    63,    60,     0,
      58,    57,     0,    32,     0,     0,    34,     0,    37,    64,
      62,     0,     0,     0,     0,     0,    31,    33,    26,    28,
       0,     0,    65
};

/* YYDEFGOTO[NTERM-NUM]. */
static const yysigned_char yydefgoto[] =
{
      -1,     3,     4,     5,    17,    18,    19,    42,    24,    34,
      35,    70,    63,    82,    77,   103,   126,   127
};

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
#define YYPACT_NINF -112
static const short yypact[] =
{
      63,   -30,    -7,    21,    69,  -112,  -112,    17,  -112,    32,
    -112,    35,     7,  -112,    43,    47,    31,    49,    27,    52,
       7,  -112,    70,     0,    54,    58,    59,    64,  -112,    61,
      84,    67,    71,  -112,    34,  -112,    91,  -112,  -112,  -112,
      76,   142,  -112,  -112,    93,  -112,    94,    77,  -112,   142,
       5,   142,   142,    96,   142,  -112,  -112,  -112,   -11,   142,
     142,    86,   142,   308,  -112,  -112,   142,   213,     8,    79,
    -112,   179,   233,  -112,    38,   142,   114,  -112,   308,    38,
      85,   269,    41,   242,   142,   142,   142,   142,   142,   142,
     142,   102,   106,   257,   142,   142,     5,   108,   142,   113,
     308,  -112,   308,    44,  -112,  -112,   100,  -112,   282,  -112,
     317,   317,   317,   -15,   -15,    38,    38,   103,    99,  -112,
     161,   308,  -112,    84,   204,   101,    19,  -112,  -112,   142,
    -112,  -112,   120,  -112,   142,    11,  -112,   122,  -112,  -112,
     308,    99,   170,   142,     5,   129,  -112,  -112,   308,  -112,
     142,   295,  -112
};

/* YYPGOTO[NTERM-NUM].  */
static const short yypgoto[] =
{
    -112,  -112,  -112,   143,   132,  -112,   131,    30,  -112,  -112,
     121,   -92,   -49,  -112,  -111,  -112,  -112,    33
};

/* YYTABLE[YYPACT[STATE-NUM]].  What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule which
   number is the opposite.  If zero, do what YYDEFACT says.
   If YYTABLE_NINF, syntax error.  */
#define YYTABLE_NINF -12
static const short yytable[] =
{
      67,    31,    71,    72,   122,    74,    68,   133,    15,     6,
      78,    79,    81,    83,    75,    95,     7,    93,   143,    89,
      90,     8,    91,    92,    32,    11,   100,   102,    26,    69,
     146,    16,    76,   108,   138,   110,   111,   112,   113,   114,
     115,   116,   106,   125,    33,   120,   121,    49,   -10,   124,
      50,    16,   149,    96,    51,    52,   144,    12,    14,    53,
      54,    55,    56,    57,     1,    58,     2,    59,   -11,    -2,
       9,    13,     2,    22,    23,    91,    92,    60,    45,    46,
     140,    61,   107,    20,    62,   142,    21,    80,   128,   129,
      25,    28,    49,    30,   148,    50,    36,    37,    38,    51,
      52,   151,    40,    39,    53,    54,    55,    56,    57,    41,
      58,    43,    59,    44,    47,    48,    64,    66,    32,    73,
      49,    97,    60,    50,   104,   117,    61,    51,    52,    62,
     118,   123,    53,    54,    55,    56,    57,   125,    58,   130,
      59,   132,    76,   137,   141,   145,   150,    10,    49,    27,
      60,    50,    29,   135,    61,    51,    52,    62,   101,   139,
      53,    54,    55,    56,    57,   134,    58,    65,    59,     0,
       0,     0,     0,     0,     0,   147,     0,     0,    60,     0,
       0,     0,    61,     0,     0,    62,     0,     0,    84,    98,
       0,    85,    86,    87,    88,    89,    90,    84,    91,    92,
      85,    86,    87,    88,    89,    90,    84,    91,    92,    85,
      86,    87,    88,    89,    90,   136,    91,    92,     0,     0,
       0,     0,     0,     0,     0,    94,     0,     0,     0,     0,
       0,    84,     0,     0,    85,    86,    87,    88,    89,    90,
      84,    91,    92,    85,    86,    87,    88,    89,    90,    99,
      91,    92,     0,     0,     0,     0,     0,     0,     0,     0,
      84,     0,     0,    85,    86,    87,    88,    89,    90,    84,
      91,    92,    85,    86,    87,    88,    89,    90,     0,    91,
      92,     0,     0,     0,    84,     0,   109,    85,    86,    87,
      88,    89,    90,     0,    91,    92,    84,     0,   119,    85,
      86,    87,    88,    89,    90,     0,    91,    92,   105,    84,
       0,     0,    85,    86,    87,    88,    89,    90,     0,    91,
      92,   131,    84,     0,     0,    85,    86,    87,    88,    89,
      90,     0,    91,    92,   152,    84,     0,     0,    85,    86,
      87,    88,    89,    90,   -12,    91,    92,   -12,   -12,    87,
      88,    89,    90,     0,    91,    92
};

static const short yycheck[] =
{
      49,     1,    51,    52,    96,    54,     1,   118,     1,    39,
      59,    60,    61,    62,    25,     7,    23,    66,     7,    34,
      35,     0,    37,    38,    24,     8,    75,    76,     1,    24,
     141,    24,    43,    82,    15,    84,    85,    86,    87,    88,
      89,    90,     1,    24,    44,    94,    95,     6,    41,    98,
       9,    24,   144,    45,    13,    14,    45,    40,    23,    18,
      19,    20,    21,    22,     1,    24,     3,    26,    41,     0,
       1,    39,     3,    42,    43,    37,    38,    36,    44,    45,
     129,    40,    41,    40,    43,   134,    39,     1,    44,    45,
      41,    39,     6,    23,   143,     9,    42,    39,    39,    13,
      14,   150,    41,    39,    18,    19,    20,    21,    22,    25,
      24,    44,    26,    42,    23,    39,    23,    40,    24,    23,
       6,    42,    36,     9,    39,    23,    40,    13,    14,    43,
      24,    23,    18,    19,    20,    21,    22,    24,    24,    39,
      26,    38,    43,    42,    24,    23,    17,     4,     6,    18,
      36,     9,    20,   123,    40,    13,    14,    43,    44,   126,
      18,    19,    20,    21,    22,     4,    24,    46,    26,    -1,
      -1,    -1,    -1,    -1,    -1,     5,    -1,    -1,    36,    -1,
      -1,    -1,    40,    -1,    -1,    43,    -1,    -1,    27,    10,
      -1,    30,    31,    32,    33,    34,    35,    27,    37,    38,
      30,    31,    32,    33,    34,    35,    27,    37,    38,    30,
      31,    32,    33,    34,    35,    11,    37,    38,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    12,    -1,    -1,    -1,    -1,
      -1,    27,    -1,    -1,    30,    31,    32,    33,    34,    35,
      27,    37,    38,    30,    31,    32,    33,    34,    35,    16,
      37,    38,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      27,    -1,    -1,    30,    31,    32,    33,    34,    35,    27,
      37,    38,    30,    31,    32,    33,    34,    35,    -1,    37,
      38,    -1,    -1,    -1,    27,    -1,    44,    30,    31,    32,
      33,    34,    35,    -1,    37,    38,    27,    -1,    41,    30,
      31,    32,    33,    34,    35,    -1,    37,    38,    39,    27,
      -1,    -1,    30,    31,    32,    33,    34,    35,    -1,    37,
      38,    39,    27,    -1,    -1,    30,    31,    32,    33,    34,
      35,    -1,    37,    38,    39,    27,    -1,    -1,    30,    31,
      32,    33,    34,    35,    27,    37,    38,    30,    31,    32,
      33,    34,    35,    -1,    37,    38
};

/* YYSTOS[STATE-NUM] -- The (internal number of the) accessing
   symbol of state STATE-NUM.  */
static const unsigned char yystos[] =
{
       0,     1,     3,    47,    48,    49,    39,    23,     0,     1,
      49,     8,    40,    39,    23,     1,    24,    50,    51,    52,
      40,    39,    42,    43,    54,    41,     1,    52,    39,    50,
      23,     1,    24,    44,    55,    56,    42,    39,    39,    39,
      41,    25,    53,    44,    42,    44,    45,    23,    39,     6,
       9,    13,    14,    18,    19,    20,    21,    22,    24,    26,
      36,    40,    43,    58,    23,    56,    40,    58,     1,    24,
      57,    58,    58,    23,    58,    25,    43,    60,    58,    58,
       1,    58,    59,    58,    27,    30,    31,    32,    33,    34,
      35,    37,    38,    58,    12,     7,    45,    42,    10,    16,
      58,    44,    58,    61,    39,    39,     1,    41,    58,    44,
      58,    58,    58,    58,    58,    58,    58,    23,    24,    41,
      58,    58,    57,    23,    58,    24,    62,    63,    44,    45,
      39,    39,    38,    60,     4,    53,    11,    42,    15,    63,
      58,    24,    58,     7,    45,    23,    60,     5,    58,    57,
      17,    58,    39
};

#if ! defined (YYSIZE_T) && defined (__SIZE_TYPE__)
# define YYSIZE_T __SIZE_TYPE__
#endif
#if ! defined (YYSIZE_T) && defined (size_t)
# define YYSIZE_T size_t
#endif
#if ! defined (YYSIZE_T)
# if defined (__STDC__) || defined (__cplusplus)
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# endif
#endif
#if ! defined (YYSIZE_T)
# define YYSIZE_T unsigned int
#endif

#define yyerrok		(yyerrstatus = 0)
#define yyclearin	(yychar = YYEMPTY)
#define YYEMPTY		(-2)
#define YYEOF		0

#define YYACCEPT	goto yyacceptlab
#define YYABORT		goto yyabortlab
#define YYERROR		goto yyerrlab1

/* Like YYERROR except do call yyerror.  This remains here temporarily
   to ease the transition to the new meaning of YYERROR, for GCC.
   Once GCC version 2 has supplanted version 1, this can go.  */

#define YYFAIL		goto yyerrlab

#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)					\
do								\
  if (yychar == YYEMPTY && yylen == 1)				\
    {								\
      yychar = (Token);						\
      yylval = (Value);						\
      yytoken = YYTRANSLATE (yychar);				\
      YYPOPSTACK;						\
      goto yybackup;						\
    }								\
  else								\
    { 								\
      yyerror ("syntax error: cannot back up");\
      YYERROR;							\
    }								\
while (0)

#define YYTERROR	1
#define YYERRCODE	256

/* YYLLOC_DEFAULT -- Compute the default location (before the actions
   are run).  */

#ifndef YYLLOC_DEFAULT
# define YYLLOC_DEFAULT(Current, Rhs, N)         \
  Current.first_line   = Rhs[1].first_line;      \
  Current.first_column = Rhs[1].first_column;    \
  Current.last_line    = Rhs[N].last_line;       \
  Current.last_column  = Rhs[N].last_column;
#endif

/* YYLEX -- calling `yylex' with the right arguments.  */

#ifdef YYLEX_PARAM
# define YYLEX yylex (YYLEX_PARAM)
#else
# define YYLEX yylex ()
#endif

/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)			\
do {						\
  if (yydebug)					\
    YYFPRINTF Args;				\
} while (0)

# define YYDSYMPRINT(Args)			\
do {						\
  if (yydebug)					\
    yysymprint Args;				\
} while (0)

# define YYDSYMPRINTF(Title, Token, Value, Location)		\
do {								\
  if (yydebug)							\
    {								\
      YYFPRINTF (stderr, "%s ", Title);				\
      yysymprint (stderr, 					\
                  Token, Value, Location);	\
      YYFPRINTF (stderr, "\n");					\
    }								\
} while (0)

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (cinluded).                                                   |
`------------------------------------------------------------------*/

#if defined (__STDC__) || defined (__cplusplus)
static void
yy_stack_print (short *bottom, short *top)
#else
static void
yy_stack_print (bottom, top)
    short *bottom;
    short *top;
#endif
{
  YYFPRINTF (stderr, "Stack now");
  for (/* Nothing. */; bottom <= top; ++bottom)
    YYFPRINTF (stderr, " %d", *bottom);
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)				\
do {								\
  if (yydebug)							\
    yy_stack_print ((Bottom), (Top));				\
} while (0)


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

#if defined (__STDC__) || defined (__cplusplus)
static void
yy_reduce_print (int yyrule)
#else
static void
yy_reduce_print (yyrule)
    int yyrule;
#endif
{
  int yyi;
  unsigned int yylineno = yyrline[yyrule];
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %u), ",
             yyrule - 1, yylineno);
  /* Print the symbols being reduced, and their result.  */
  for (yyi = yyprhs[yyrule]; 0 <= yyrhs[yyi]; yyi++)
    YYFPRINTF (stderr, "%s ", yytname [yyrhs[yyi]]);
  YYFPRINTF (stderr, "-> %s\n", yytname [yyr1[yyrule]]);
}

# define YY_REDUCE_PRINT(Rule)		\
do {					\
  if (yydebug)				\
    yy_reduce_print (Rule);		\
} while (0)

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args)
# define YYDSYMPRINT(Args)
# define YYDSYMPRINTF(Title, Token, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef	YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   SIZE_MAX < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#if YYMAXDEPTH == 0
# undef YYMAXDEPTH
#endif

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif



#if YYERROR_VERBOSE

# ifndef yystrlen
#  if defined (__GLIBC__) && defined (_STRING_H)
#   define yystrlen strlen
#  else
/* Return the length of YYSTR.  */
static YYSIZE_T
#   if defined (__STDC__) || defined (__cplusplus)
yystrlen (const char *yystr)
#   else
yystrlen (yystr)
     const char *yystr;
#   endif
{
  register const char *yys = yystr;

  while (*yys++ != '\0')
    continue;

  return yys - yystr - 1;
}
#  endif
# endif

# ifndef yystpcpy
#  if defined (__GLIBC__) && defined (_STRING_H) && defined (_GNU_SOURCE)
#   define yystpcpy stpcpy
#  else
/* Copy YYSRC to YYDEST, returning the address of the terminating '\0' in
   YYDEST.  */
static char *
#   if defined (__STDC__) || defined (__cplusplus)
yystpcpy (char *yydest, const char *yysrc)
#   else
yystpcpy (yydest, yysrc)
     char *yydest;
     const char *yysrc;
#   endif
{
  register char *yyd = yydest;
  register const char *yys = yysrc;

  while ((*yyd++ = *yys++) != '\0')
    continue;

  return yyd - 1;
}
#  endif
# endif

#endif /* !YYERROR_VERBOSE */



#if YYDEBUG
/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

#if defined (__STDC__) || defined (__cplusplus)
static void
yysymprint (FILE *yyoutput, int yytype, YYSTYPE *yyvaluep, YYLTYPE *yylocationp)
#else
static void
yysymprint (yyoutput, yytype, yyvaluep, yylocationp)
    FILE *yyoutput;
    int yytype;
    YYSTYPE *yyvaluep;
    YYLTYPE *yylocationp;
#endif
{
  /* Pacify ``unused variable'' warnings.  */
  (void) yyvaluep;
  (void) yylocationp;

  if (yytype < YYNTOKENS)
    {
      YYFPRINTF (yyoutput, "token %s (", yytname[yytype]);
# ifdef YYPRINT
      YYPRINT (yyoutput, yytoknum[yytype], *yyvaluep);
# endif
    }
  else
    YYFPRINTF (yyoutput, "nterm %s (", yytname[yytype]);

  switch (yytype)
    {
      default:
        break;
    }
  YYFPRINTF (yyoutput, ")");
}

#endif /* ! YYDEBUG */
/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

#if defined (__STDC__) || defined (__cplusplus)
static void
yydestruct (int yytype, YYSTYPE *yyvaluep, YYLTYPE *yylocationp)
#else
static void
yydestruct (yytype, yyvaluep, yylocationp)
    int yytype;
    YYSTYPE *yyvaluep;
    YYLTYPE *yylocationp;
#endif
{
  /* Pacify ``unused variable'' warnings.  */
  (void) yyvaluep;
  (void) yylocationp;

  switch (yytype)
    {

      default:
        break;
    }
}


/* Prevent warnings from -Wmissing-prototypes.  */

#ifdef YYPARSE_PARAM
# if defined (__STDC__) || defined (__cplusplus)
int yyparse (void *YYPARSE_PARAM);
# else
int yyparse ();
# endif
#else /* ! YYPARSE_PARAM */
#if defined (__STDC__) || defined (__cplusplus)
int yyparse (void);
#else
int yyparse ();
#endif
#endif /* ! YYPARSE_PARAM */



/* The lookahead symbol.  */
int yychar;

/* The semantic value of the lookahead symbol.  */
YYSTYPE yylval;

/* Number of syntax errors so far.  */
int yynerrs;
/* Location data for the lookahead symbol.  */
YYLTYPE yylloc;



/*----------.
| yyparse.  |
`----------*/

#ifdef YYPARSE_PARAM
# if defined (__STDC__) || defined (__cplusplus)
int yyparse (void *YYPARSE_PARAM)
# else
int yyparse (YYPARSE_PARAM)
  void *YYPARSE_PARAM;
# endif
#else /* ! YYPARSE_PARAM */
#if defined (__STDC__) || defined (__cplusplus)
int
yyparse (void)
#else
int
yyparse ()

#endif
#endif
{
  
  register int yystate;
  register int yyn;
  int yyresult;
  /* Number of tokens to shift before error messages enabled.  */
  int yyerrstatus;
  /* Lookahead token as an internal (translated) token number.  */
  int yytoken = 0;

  /* Three stacks and their tools:
     `yyss': related to states,
     `yyvs': related to semantic values,
     `yyls': related to locations.

     Refer to the stacks thru separate pointers, to allow yyoverflow
     to reallocate them elsewhere.  */

  /* The state stack.  */
  short	yyssa[YYINITDEPTH];
  short *yyss = yyssa;
  register short *yyssp;

  /* The semantic value stack.  */
  YYSTYPE yyvsa[YYINITDEPTH];
  YYSTYPE *yyvs = yyvsa;
  register YYSTYPE *yyvsp;

  /* The location stack.  */
  YYLTYPE yylsa[YYINITDEPTH];
  YYLTYPE *yyls = yylsa;
  YYLTYPE *yylsp;
  YYLTYPE *yylerrsp;

#define YYPOPSTACK   (yyvsp--, yyssp--, yylsp--)

  YYSIZE_T yystacksize = YYINITDEPTH;

  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;
  YYLTYPE yyloc;

  /* When reducing, the number of symbols on the RHS of the reduced
     rule.  */
  int yylen;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yystate = 0;
  yyerrstatus = 0;
  yynerrs = 0;
  yychar = YYEMPTY;		/* Cause a token to be read.  */

  /* Initialize stack pointers.
     Waste one element of value and location stack
     so that they stay on the same level as the state stack.
     The wasted elements are never initialized.  */

  yyssp = yyss;
  yyvsp = yyvs;
  yylsp = yyls;
  goto yysetstate;

/*------------------------------------------------------------.
| yynewstate -- Push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
 yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed. so pushing a state here evens the stacks.
     */
  yyssp++;

 yysetstate:
  *yyssp = yystate;

  if (yyss + yystacksize - 1 <= yyssp)
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYSIZE_T yysize = yyssp - yyss + 1;

#ifdef yyoverflow
      {
	/* Give user a chance to reallocate the stack. Use copies of
	   these so that the &'s don't force the real ones into
	   memory.  */
	YYSTYPE *yyvs1 = yyvs;
	short *yyss1 = yyss;
	YYLTYPE *yyls1 = yyls;

	/* Each stack pointer address is followed by the size of the
	   data in use in that stack, in bytes.  This used to be a
	   conditional around just the two extra args, but that might
	   be undefined if yyoverflow is a macro.  */
	yyoverflow ("parser stack overflow",
		    &yyss1, yysize * sizeof (*yyssp),
		    &yyvs1, yysize * sizeof (*yyvsp),
		    &yyls1, yysize * sizeof (*yylsp),
		    &yystacksize);
	yyls = yyls1;
	yyss = yyss1;
	yyvs = yyvs1;
      }
#else /* no yyoverflow */
# ifndef YYSTACK_RELOCATE
      goto yyoverflowlab;
# else
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
	goto yyoverflowlab;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
	yystacksize = YYMAXDEPTH;

      {
	short *yyss1 = yyss;
	union yyalloc *yyptr =
	  (union yyalloc *) YYSTACK_ALLOC (YYSTACK_BYTES (yystacksize));
	if (! yyptr)
	  goto yyoverflowlab;
	YYSTACK_RELOCATE (yyss);
	YYSTACK_RELOCATE (yyvs);
	YYSTACK_RELOCATE (yyls);
#  undef YYSTACK_RELOCATE
	if (yyss1 != yyssa)
	  YYSTACK_FREE (yyss1);
      }
# endif
#endif /* no yyoverflow */

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;
      yylsp = yyls + yysize - 1;

      YYDPRINTF ((stderr, "Stack size increased to %lu\n",
		  (unsigned long int) yystacksize));

      if (yyss + yystacksize - 1 <= yyssp)
	YYABORT;
    }

  YYDPRINTF ((stderr, "Entering state %d\n", yystate));

  goto yybackup;

/*-----------.
| yybackup.  |
`-----------*/
yybackup:

/* Do appropriate processing given the current state.  */
/* Read a lookahead token if we need one and don't already have one.  */
/* yyresume: */

  /* First try to decide what to do without reference to lookahead token.  */

  yyn = yypact[yystate];
  if (yyn == YYPACT_NINF)
    goto yydefault;

  /* Not known => get a lookahead token if don't already have one.  */

  /* YYCHAR is either YYEMPTY or YYEOF or a valid lookahead symbol.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token: "));
      yychar = YYLEX;
    }

  if (yychar <= YYEOF)
    {
      yychar = yytoken = YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else
    {
      yytoken = YYTRANSLATE (yychar);
      YYDSYMPRINTF ("Next token is", yytoken, &yylval, &yylloc);
    }

  /* If the proper action on seeing token YYTOKEN is to reduce or to
     detect an error, take that action.  */
  yyn += yytoken;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yytoken)
    goto yydefault;
  yyn = yytable[yyn];
  if (yyn <= 0)
    {
      if (yyn == 0 || yyn == YYTABLE_NINF)
	goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  if (yyn == YYFINAL)
    YYACCEPT;

  /* Shift the lookahead token.  */
  YYDPRINTF ((stderr, "Shifting token %s, ", yytname[yytoken]));

  /* Discard the token being shifted unless it is eof.  */
  if (yychar != YYEOF)
    yychar = YYEMPTY;

  *++yyvsp = yylval;
  *++yylsp = yylloc;

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  yystate = yyn;
  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- Do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     `$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];

  /* Default location. */
  YYLLOC_DEFAULT (yyloc, (yylsp - yylen), yylen);
  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
        case 2:
#line 116 "cool.y"
    { /* make sure bison computes location information */
                          yyloc = yylsp[0];
                          ast_root = program(yyvsp[0].classes); }
    break;

  case 3:
#line 119 "cool.y"
    { ast_root = program(nil_Classes()); }
    break;

  case 4:
#line 124 "cool.y"
    { yyval.classes = single_Classes(yyvsp[0].class_);
                  parse_results = yyval.classes; }
    break;

  case 5:
#line 128 "cool.y"
    { yyval.classes = nil_Classes(); }
    break;

  case 6:
#line 130 "cool.y"
    { yyval.classes = append_Classes(yyvsp[-1].classes,single_Classes(yyvsp[0].class_)); 
                  parse_results = yyval.classes; }
    break;

  case 7:
#line 133 "cool.y"
    {  yyval.classes = yyvsp[-2].classes; }
    break;

  case 8:
#line 138 "cool.y"
    { yyval.class_ = class_(yyvsp[-4].symbol,idtable.add_string("Object"),yyvsp[-2].features,
			      stringtable.add_string(curr_filename)); }
    break;

  case 9:
#line 141 "cool.y"
    { yyval.class_ = class_(yyvsp[-6].symbol,yyvsp[-4].symbol,yyvsp[-2].features,stringtable.add_string(curr_filename)); }
    break;

  case 10:
#line 146 "cool.y"
    {  SET_NODELOC(0); yyval.features = nil_Features(); }
    break;

  case 11:
#line 148 "cool.y"
    {  yyval.features = yyvsp[0].features; }
    break;

  case 12:
#line 153 "cool.y"
    {  yyval.features = single_Features(yyvsp[-1].feature); }
    break;

  case 13:
#line 156 "cool.y"
    { yyval.features = nil_Features(); }
    break;

  case 14:
#line 158 "cool.y"
    {  yyval.features = append_Features(yyvsp[-2].features,single_Features(yyvsp[-1].feature)); }
    break;

  case 15:
#line 160 "cool.y"
    {  yyval.features = yyvsp[-2].features; }
    break;

  case 16:
#line 164 "cool.y"
    { yyval.feature = method(yyvsp[-6].symbol,yyvsp[-5].formals,yyvsp[-3].symbol,yyvsp[-1].expression); }
    break;

  case 17:
#line 166 "cool.y"
    { yyval.feature = attr(yyvsp[-3].symbol,yyvsp[-1].symbol,yyvsp[0].expression); }
    break;

  case 18:
#line 171 "cool.y"
    { SET_NODELOC(0); yyval.expression = no_expr(); }
    break;

  case 19:
#line 173 "cool.y"
    { yyval.expression = yyvsp[0].expression; }
    break;

  case 20:
#line 177 "cool.y"
    { yyval.formals = nil_Formals(); }
    break;

  case 21:
#line 179 "cool.y"
    { yyval.formals = yyvsp[-1].formals; }
    break;

  case 22:
#line 181 "cool.y"
    { yyval.formals = nil_Formals();  }
    break;

  case 23:
#line 186 "cool.y"
    {  yyval.formals = single_Formals(yyvsp[0].formal); }
    break;

  case 24:
#line 188 "cool.y"
    { yyval.formals = append_Formals(yyvsp[-2].formals,single_Formals(yyvsp[0].formal)); }
    break;

  case 25:
#line 192 "cool.y"
    {  yyval.formal = formal(yyvsp[-2].symbol,yyvsp[0].symbol); }
    break;

  case 26:
#line 196 "cool.y"
    { yyval.expression = let(yyvsp[-5].symbol,yyvsp[-3].symbol,yyvsp[-2].expression,yyvsp[0].expression); }
    break;

  case 27:
#line 198 "cool.y"
    { yyval.expression = yyvsp[0].expression; }
    break;

  case 28:
#line 200 "cool.y"
    { yyval.expression = let(yyvsp[-5].symbol,yyvsp[-3].symbol,yyvsp[-2].expression,yyvsp[0].expression); }
    break;

  case 29:
#line 202 "cool.y"
    { yyval.expression = yyvsp[0].expression; }
    break;

  case 30:
#line 205 "cool.y"
    { yyval.expression = assign(yyvsp[-2].symbol,yyvsp[0].expression); }
    break;

  case 31:
#line 207 "cool.y"
    { yyloc = yylsp[-2]; SET_NODELOC(yylsp[-2]);
            yyval.expression = static_dispatch(yyvsp[-5].expression,yyvsp[-3].symbol,yyvsp[-1].symbol,yyvsp[0].expressions); }
    break;

  case 32:
#line 210 "cool.y"
    { yyloc = yylsp[-2]; SET_NODELOC(yylsp[-2]);
            yyval.expression = dispatch(yyvsp[-3].expression,yyvsp[-1].symbol,yyvsp[0].expressions); }
    break;

  case 33:
#line 213 "cool.y"
    { yyval.expression = cond(yyvsp[-5].expression,yyvsp[-3].expression,yyvsp[-1].expression); }
    break;

  case 34:
#line 215 "cool.y"
    { yyval.expression = loop(yyvsp[-3].expression,yyvsp[-1].expression); }
    break;

  case 35:
#line 217 "cool.y"
    { yyval.expression = block(yyvsp[-1].expressions); }
    break;

  case 36:
#line 219 "cool.y"
    { yyval.expression = yyvsp[0].expression; }
    break;

  case 37:
#line 221 "cool.y"
    { yyval.expression = typcase(yyvsp[-3].expression,yyvsp[-1].cases); }
    break;

  case 38:
#line 223 "cool.y"
    { yyval.expression = new_(yyvsp[0].symbol); }
    break;

  case 39:
#line 225 "cool.y"
    { yyval.expression = isvoid(yyvsp[0].expression); }
    break;

  case 40:
#line 227 "cool.y"
    { yyloc = yylsp[-1]; SET_NODELOC(yylsp[-1]);
            yyval.expression = plus(yyvsp[-2].expression,yyvsp[0].expression); }
    break;

  case 41:
#line 230 "cool.y"
    { yyloc = yylsp[-1]; SET_NODELOC(yylsp[-1]);
            yyval.expression = sub(yyvsp[-2].expression,yyvsp[0].expression); }
    break;

  case 42:
#line 233 "cool.y"
    { yyloc = yylsp[-1]; SET_NODELOC(yylsp[-1]);
            yyval.expression = mul(yyvsp[-2].expression,yyvsp[0].expression); }
    break;

  case 43:
#line 236 "cool.y"
    { yyloc = yylsp[-1]; SET_NODELOC(yylsp[-1]);
            yyval.expression = divide(yyvsp[-2].expression,yyvsp[0].expression); }
    break;

  case 44:
#line 239 "cool.y"
    { yyval.expression = neg(yyvsp[0].expression); }
    break;

  case 45:
#line 241 "cool.y"
    { yyloc = yylsp[-1]; SET_NODELOC(yylsp[-1]);
            yyval.expression = lt(yyvsp[-2].expression,yyvsp[0].expression); }
    break;

  case 46:
#line 244 "cool.y"
    { yyloc = yylsp[-1]; SET_NODELOC(yylsp[-1]);
            yyval.expression = eq(yyvsp[-2].expression,yyvsp[0].expression); }
    break;

  case 47:
#line 247 "cool.y"
    { yyloc = yylsp[-1]; SET_NODELOC(yylsp[-1]);
            yyval.expression = leq(yyvsp[-2].expression,yyvsp[0].expression); }
    break;

  case 48:
#line 250 "cool.y"
    { yyval.expression = comp(yyvsp[0].expression); }
    break;

  case 49:
#line 252 "cool.y"
    { yyval.expression = yyvsp[-1].expression; }
    break;

  case 50:
#line 254 "cool.y"
    { yyval.expression = int_const(yyvsp[0].symbol); }
    break;

  case 51:
#line 256 "cool.y"
    { yyval.expression = string_const(yyvsp[0].symbol); }
    break;

  case 52:
#line 258 "cool.y"
    { yyval.expression = bool_const(yyvsp[0].boolean); }
    break;

  case 53:
#line 260 "cool.y"
    { yyval.expression = object(yyvsp[0].symbol); }
    break;

  case 54:
#line 262 "cool.y"
    { 
	    Expression self_obj = object(idtable.add_string("self"));
	    yyval.expression = dispatch(self_obj,yyvsp[-1].symbol,yyvsp[0].expressions); 
	  }
    break;

  case 55:
#line 269 "cool.y"
    { yyval.expressions = single_Expressions(yyvsp[-1].expression); }
    break;

  case 56:
#line 271 "cool.y"
    { yyval.expressions = nil_Expressions(); }
    break;

  case 57:
#line 273 "cool.y"
    { yyval.expressions = append_Expressions(yyvsp[-2].expressions,single_Expressions(yyvsp[-1].expression)); }
    break;

  case 58:
#line 275 "cool.y"
    { yyval.expressions = yyvsp[-2].expressions; }
    break;

  case 59:
#line 279 "cool.y"
    {  yyval.expressions = nil_Expressions(); }
    break;

  case 60:
#line 281 "cool.y"
    {  yyval.expressions = yyvsp[-1].expressions; }
    break;

  case 61:
#line 286 "cool.y"
    { yyval.expressions = single_Expressions(yyvsp[0].expression); }
    break;

  case 62:
#line 288 "cool.y"
    { yyval.expressions = append_Expressions(yyvsp[-2].expressions,single_Expressions(yyvsp[0].expression)); }
    break;

  case 63:
#line 293 "cool.y"
    { yyval.cases = single_Cases(yyvsp[0].case_); }
    break;

  case 64:
#line 295 "cool.y"
    { yyval.cases = append_Cases(yyvsp[-1].cases,single_Cases(yyvsp[0].case_)); }
    break;

  case 65:
#line 300 "cool.y"
    { yyval.case_ = branch(yyvsp[-5].symbol,yyvsp[-3].symbol,yyvsp[-1].expression); }
    break;


    }

/* Line 991 of yacc.c.  */
#line 1611 "cool.tab.c"

  yyvsp -= yylen;
  yyssp -= yylen;
  yylsp -= yylen;

  YY_STACK_PRINT (yyss, yyssp);

  *++yyvsp = yyval;
  *++yylsp = yyloc;

  /* Now `shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */

  yyn = yyr1[yyn];

  yystate = yypgoto[yyn - YYNTOKENS] + *yyssp;
  if (0 <= yystate && yystate <= YYLAST && yycheck[yystate] == *yyssp)
    yystate = yytable[yystate];
  else
    yystate = yydefgoto[yyn - YYNTOKENS];

  goto yynewstate;


/*------------------------------------.
| yyerrlab -- here on detecting error |
`------------------------------------*/
yyerrlab:
  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
#if YYERROR_VERBOSE
      yyn = yypact[yystate];

      if (YYPACT_NINF < yyn && yyn < YYLAST)
	{
	  YYSIZE_T yysize = 0;
	  int yytype = YYTRANSLATE (yychar);
	  char *yymsg;
	  int yyx, yycount;

	  yycount = 0;
	  /* Start YYX at -YYN if negative to avoid negative indexes in
	     YYCHECK.  */
	  for (yyx = yyn < 0 ? -yyn : 0;
	       yyx < (int) (sizeof (yytname) / sizeof (char *)); yyx++)
	    if (yycheck[yyx + yyn] == yyx && yyx != YYTERROR)
	      yysize += yystrlen (yytname[yyx]) + 15, yycount++;
	  yysize += yystrlen ("syntax error, unexpected ") + 1;
	  yysize += yystrlen (yytname[yytype]);
	  yymsg = (char *) YYSTACK_ALLOC (yysize);
	  if (yymsg != 0)
	    {
	      char *yyp = yystpcpy (yymsg, "syntax error, unexpected ");
	      yyp = yystpcpy (yyp, yytname[yytype]);

	      if (yycount < 5)
		{
		  yycount = 0;
		  for (yyx = yyn < 0 ? -yyn : 0;
		       yyx < (int) (sizeof (yytname) / sizeof (char *));
		       yyx++)
		    if (yycheck[yyx + yyn] == yyx && yyx != YYTERROR)
		      {
			const char *yyq = ! yycount ? ", expecting " : " or ";
			yyp = yystpcpy (yyp, yyq);
			yyp = yystpcpy (yyp, yytname[yyx]);
			yycount++;
		      }
		}
	      yyerror (yymsg);
	      YYSTACK_FREE (yymsg);
	    }
	  else
	    yyerror ("syntax error; also virtual memory exhausted");
	}
      else
#endif /* YYERROR_VERBOSE */
	yyerror ("syntax error");
    }

  yylerrsp = yylsp;

  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse lookahead token after an
	 error, discard it.  */

      /* Return failure if at end of input.  */
      if (yychar == YYEOF)
        {
	  /* Pop the error token.  */
          YYPOPSTACK;
	  /* Pop the rest of the stack.  */
	  while (yyss < yyssp)
	    {
	      YYDSYMPRINTF ("Error: popping", yystos[*yyssp], yyvsp, yylsp);
	      yydestruct (yystos[*yyssp], yyvsp, yylsp);
	      YYPOPSTACK;
	    }
	  YYABORT;
        }

      YYDSYMPRINTF ("Error: discarding", yytoken, &yylval, &yylloc);
      yydestruct (yytoken, &yylval, &yylloc);
      yychar = YYEMPTY;
      *++yylerrsp = yylloc;
    }

  /* Else will try to reuse lookahead token after shifting the error
     token.  */
  goto yyerrlab2;


/*----------------------------------------------------.
| yyerrlab1 -- error raised explicitly by an action.  |
`----------------------------------------------------*/
yyerrlab1:

  yylerrsp = yylsp;
  *++yylerrsp = yyloc;
  goto yyerrlab2;


/*---------------------------------------------------------------.
| yyerrlab2 -- pop states until the error token can be shifted.  |
`---------------------------------------------------------------*/
yyerrlab2:
  yyerrstatus = 3;	/* Each real token shifted decrements this.  */

  for (;;)
    {
      yyn = yypact[yystate];
      if (yyn != YYPACT_NINF)
	{
	  yyn += YYTERROR;
	  if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYTERROR)
	    {
	      yyn = yytable[yyn];
	      if (0 < yyn)
		break;
	    }
	}

      /* Pop the current state because it cannot handle the error token.  */
      if (yyssp == yyss)
	YYABORT;

      YYDSYMPRINTF ("Error: popping", yystos[*yyssp], yyvsp, yylsp);
      yydestruct (yystos[yystate], yyvsp, yylsp);
      yyvsp--;
      yystate = *--yyssp;
      yylsp--;
      YY_STACK_PRINT (yyss, yyssp);
    }

  if (yyn == YYFINAL)
    YYACCEPT;

  YYDPRINTF ((stderr, "Shifting error token, "));

  *++yyvsp = yylval;
  YYLLOC_DEFAULT (yyloc, yylsp, (yylerrsp - yylsp));
  *++yylsp = yyloc;

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturn;

/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturn;

#ifndef yyoverflow
/*----------------------------------------------.
| yyoverflowlab -- parser overflow comes here.  |
`----------------------------------------------*/
yyoverflowlab:
  yyerror ("parser stack overflow");
  yyresult = 2;
  /* Fall through.  */
#endif

yyreturn:
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif
  return yyresult;
}


#line 303 "cool.y"


/* This function is called automatically when Bison detects a parse error. */
void yyerror(char *s)
{
  extern int curr_lineno;

  cerr << "\"" << curr_filename << "\", line " << curr_lineno << ": " \
    << s << " at or near ";
  print_cool_token(yychar);
  cerr << endl;
  omerrs++;
  if(omerrs>50) { cerr << "More than 50 errors" << endl; exit(1);}
}



