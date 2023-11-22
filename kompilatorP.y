%{/*
-----------------------------------------------------------------------------------------------
DEKLARACJE BIBLIOTEK C + AUTORSKIE NA POTRZEBY KOMPILATORA
-----------------------------------------------------------------------------------------------
*/
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "ST.h"
#include "SM.h"
#include "CG.h"
int errors;

struct lbs 
{
    int for_goto;
    int for_jmp_false;
};

struct lbs *newlblrec()
{
    return (struct lbs *) malloc(sizeof(struct lbs));
}
/*
-----------------------------------------------------------------------------------------------
CZY ZMIENNA WCZESNIEJ ZADEKLAROWANA
-----------------------------------------------------------------------------------------------
*/
install(char *sym_name, int type)
{
    symrec *s;
    s = getsym(sym_name);

    if (s == 0)
    {
        s = putsym(sym_name, type);
    }
    else
    { 
        char tmp_error[255];
        sprintf(tmp_error, "CONST lub VAR  '%s' zostala juz zadeklarowana!!!", sym_name);
        yyerror(tmp_error);
    }
}
/*
-----------------------------------------------------------------------------------------------
CZY ZMIENNA BYLA W OGOLE ZADEKLAROWANA
-----------------------------------------------------------------------------------------------
*/
context_check(enum code_ops operation, char *sym_name)
{
    symrec *identifier;
    identifier = getsym(sym_name);

    if (identifier == 0)
    {
        char tmp_error[255];
        sprintf(tmp_error, "CONST lub VAR '%s' musi byc zadeklarowana zanim jej uzyjemy!!!", sym_name);
        yyerror(tmp_error);
    }
    else
    {
        gen_code(operation, identifier->offset);
    }
}
/*
-----------------------------------------------------------------------------------------------
SPRAGAIN
-----------------------------------------------------------------------------------------------
*/

const_check(enum code_ops operation, char *sym_name)
{
    symrec *identifier;
    identifier = getsym(sym_name);
    
    if (identifier == 0)
    {
        char tmp_error[255];
        sprintf(tmp_error, "CONST lub VAR '%s' musi byc zadeklarowana zanim jej uzyjemy", sym_name);
        yyerror(tmp_error);
    }
    else
    {
        if (identifier->type == 2)
        {
            char tmp_error[255];
            sprintf(tmp_error, "Przypisywanko '%s'", sym_name);
            yyerror(tmp_error);
        }
        else
        {
            gen_code(operation, identifier->offset);
        }
    }
}

int line = 0;
%}

%union {
    int intval;
    char *id;
    struct lbs *lbls;
}

%start program
%token CONST VAR
%token START END
%token <intval> NUM
%token <id> IDENTIFIER
%token ASSIGN
%token SEMICOLON
%token <lbls> IF WHILE
%token THEN ELSE DO
%token READ WRITE
%token EQ NEQ LT GT LET GET
%left MINUS PLUS
%left MUL DIV MOD

%%

program: CONST            cdeclarations        VAR            vdeclarations        START            commands        END { YYACCEPT; }
;

cdeclarations: cdeclarations IDENTIFIER EQ NUM {
install($2, 2);
gen_code(komenda_SET, $4);
context_check(komenda_STORE, $2);
           }
|
;

vdeclarations: vdeclarations IDENTIFIER { install($2, 1); }
|
;

commands: commands command
|
;

command: IDENTIFIER ASSIGN expression SEMICOLON { const_check(komenda_STORE, $1); }
| IF condition { $1 = (struct lbs *) newlblrec(); $1->for_jmp_false = reserve_loc(); }
THEN commands { $1->for_goto = reserve_loc(); }
ELSE { back_patch($1->for_jmp_false, komenda_JZ, gen_label()); }
commands
END { back_patch($1->for_goto, komenda_JGE, gen_label()); }
| WHILE { $1 = (struct lbs *) newlblrec(); $1->for_goto = gen_label(); }
condition { $1->for_jmp_false = reserve_loc(); }
DO
commands
END { gen_code(komenda_JUMP, $1->for_goto); back_patch($1->for_jmp_false, komenda_JZ, gen_label()); }
| READ IDENTIFIER SEMICOLON { context_check(komenda_READ, $2); }
| WRITE IDENTIFIER SEMICOLON { context_check(komenda_WRITE, $2); }
;

expression: NUM { gen_code(komenda_SET, $1); }
| IDENTIFIER { context_check(komenda_LOAD, $1); }
| IDENTIFIER PLUS IDENTIFIER { context_check(komenda_LOAD, $1); context_check(komenda_ADD, $3); }
| IDENTIFIER MINUS IDENTIFIER { context_check(komenda_LOAD, $1); context_check(komenda_SUB, $3); }
| IDENTIFIER MUL IDENTIFIER {

int start_offset = code_offset;
gen_code(komenda_SET, 0);
gen_code(komenda_STORE, 0);
gen_code(komenda_SET, 1);
gen_code(komenda_STORE, 1);
context_check(komenda_LOAD, $1);
context_check(komenda_SUB, $3);
gen_code(komenda_JZ, start_offset + 13);
context_check(komenda_LOAD, $3);
gen_code(komenda_STORE, 2);
context_check(komenda_LOAD, $1);
gen_code(komenda_STORE, 3);
gen_code(komenda_STORE, 4);
gen_code(komenda_JUMP, start_offset + 18);
context_check(komenda_LOAD, $1);
gen_code(komenda_STORE, 2);
context_check(komenda_LOAD, $3);
gen_code(komenda_STORE, 3);
gen_code(komenda_STORE, 4);
gen_code(komenda_LOAD, 2);
gen_code(komenda_JZ, start_offset + 42);
gen_code(komenda_SET, 1);
gen_code(komenda_ADD, 2);
gen_code(komenda_SUB, 1);
gen_code(komenda_JGE, start_offset + 29);
gen_code(komenda_SET, 1);
gen_code(komenda_STORE, 1);
gen_code(komenda_LOAD, 4);
gen_code(komenda_STORE, 3);
gen_code(komenda_JUMP, start_offset + 18);
gen_code(komenda_LOAD, 2);
gen_code(komenda_SUB, 1);
gen_code(komenda_STORE, 2);
gen_code(komenda_LOAD, 1);
gen_code(komenda_ADD, 1);
gen_code(komenda_STORE, 1);
gen_code(komenda_LOAD, 0);
gen_code(komenda_ADD, 3);
gen_code(komenda_STORE, 0);
gen_code(komenda_LOAD, 3);
gen_code(komenda_ADD, 3);
gen_code(komenda_STORE, 3);
gen_code(komenda_JUMP, start_offset + 18);                      
gen_code(komenda_LOAD, 0);

                                }
    | IDENTIFIER DIV IDENTIFIER {
                               
context_check( komenda_LOAD, $3 );
gen_code( komenda_JZ, gen_label() + 34 );
gen_code( komenda_STORE, 1 );
context_check( komenda_LOAD, $1 );
gen_code( komenda_STORE, 0 );
gen_code( komenda_SET, 0 );
gen_code( komenda_STORE, 2 );
gen_code( komenda_SET, 1 );
gen_code( komenda_ADD, 0 );
gen_code( komenda_SUB, 1 );
gen_code( komenda_JZ, gen_label() + 24 );
gen_code( komenda_SET, 1 );
gen_code( komenda_STORE, 3 );
gen_code( komenda_LOAD, 1 );
gen_code( komenda_STORE, 4 );
gen_code( komenda_SET, 1 );
gen_code( komenda_ADD, 0 );
gen_code( komenda_SUB, 4 );
gen_code( komenda_SUB, 4 );
gen_code( komenda_JZ, gen_label() + 8 );
gen_code( komenda_LOAD, 4 );
gen_code( komenda_ADD, 4 );
gen_code( komenda_STORE, 4 );
gen_code( komenda_LOAD, 3 );
gen_code( komenda_ADD, 3 );
gen_code( komenda_STORE, 3 );
gen_code( komenda_JUMP, gen_label() - 11 );
gen_code( komenda_LOAD, 2 );
gen_code( komenda_ADD, 3 );
gen_code( komenda_STORE, 2 );
gen_code( komenda_LOAD, 0 );
gen_code( komenda_SUB, 4 );
gen_code( komenda_STORE, 0 );
gen_code( komenda_JUMP, gen_label() - 26 );
gen_code( komenda_LOAD, 2 );
                              
                                }
| IDENTIFIER MOD IDENTIFIER {
gen_code(komenda_SET, 0);
gen_code(komenda_STORE, 1);
context_check(komenda_LOAD, $1);
context_check(komenda_SUB, $3);
gen_code(komenda_JZ, code_offset + 32);
gen_code(komenda_SET, 1);
gen_code(komenda_STORE, 0);
context_check(komenda_LOAD, $1);
gen_code(komenda_STORE, 2);
context_check(komenda_LOAD, $3);
gen_code(komenda_STORE, 3);
gen_code(komenda_SET, 1);
gen_code(komenda_ADD, 2);
context_check(komenda_SUB, $3);
gen_code(komenda_JZ, code_offset + 22);
gen_code(komenda_LOAD, 3);
gen_code(komenda_SUB, 2);
gen_code(komenda_JZ, code_offset + 6);
context_check(komenda_LOAD, $3);
gen_code(komenda_STORE, 3);
gen_code(komenda_SET, 1);
gen_code(komenda_STORE, 0);
gen_code(komenda_JUMP, code_offset - 11);
gen_code(komenda_LOAD, 2);
gen_code(komenda_SUB, 3);
gen_code(komenda_STORE, 2);
gen_code(komenda_LOAD, 1);
gen_code(komenda_ADD, 3);
gen_code(komenda_STORE, 1);
gen_code(komenda_LOAD, 3);
gen_code(komenda_ADD, 3);
gen_code(komenda_STORE, 3);
gen_code(komenda_LOAD, 0);
gen_code(komenda_ADD, 0);
gen_code(komenda_STORE, 0);
gen_code(komenda_JUMP, code_offset - 24);
context_check(komenda_LOAD, $1);
gen_code(komenda_SUB, 1);

                                }
;

condition: IDENTIFIER EQ IDENTIFIER {
int start_offset = code_offset;
context_check(komenda_LOAD, $1);
context_check(komenda_SUB, $3);
gen_code(komenda_JGE, code_offset + 5); 
context_check(komenda_LOAD, $3);
context_check(komenda_SUB, $1);
gen_code(komenda_JGE, code_offset + 2); 
gen_code(komenda_JZ, code_offset + 3);
gen_code(komenda_SET, 0);
gen_code(komenda_JUMP, code_offset + 2);
gen_code(komenda_SET, 1);

}
| IDENTIFIER NEQ IDENTIFIER {

context_check(komenda_LOAD, $1);
context_check(komenda_SUB, $3);
gen_code(komenda_JGE, code_offset + 5);
context_check(komenda_LOAD, $3);
context_check(komenda_SUB, $1);
gen_code(komenda_JGE, code_offset + 2);

                                }
| IDENTIFIER LT IDENTIFIER {

context_check(komenda_LOAD, $3);
context_check(komenda_SUB, $1);
                               }
| IDENTIFIER GT IDENTIFIER {

context_check(komenda_LOAD, $1);
context_check(komenda_SUB, $3);
                               }
| IDENTIFIER LET IDENTIFIER {

gen_code(komenda_SET, 1);
context_check(komenda_ADD, $3);
context_check(komenda_SUB, $1);
                                }
| IDENTIFIER GET IDENTIFIER {

gen_code(komenda_SET, 1);
context_check(komenda_ADD, $1);
context_check(komenda_SUB, $3);
                                }
;

%%

int main(int argc, char *argv[])
{
    extern FILE *yyin;
    ++argv; --argc;
    yyin = fopen(argv[0], "r");

    errors = 0;
    yyparse();

    if (errors == 0)
    {
        print_code();
    }
}

void yyerror(char *str)
{ 
    errors++;
    printf("Wkradl sie blad w linii %d: %s\n", yyget_lineno(), str);
}
