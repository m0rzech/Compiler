%{
#include <string.h>
#include "kompilatorP.tab.h"
%}

%option   yylineno

%%

"(*"([^\*]|\*[^\)])+"*)"  {}
"CONST"     { return CONST; }
"VAR"       { return VAR; }
"START"     { return START; }
"IF"        { return IF; }
"THEN"      { return THEN; }
"ELSE"      { return ELSE; }
"END"       { return END; }
"WHILE"     { return WHILE; }
"DO"        { return DO; }
"READ"      { return READ; }
"WRITE"     { return WRITE; }
";"         { return SEMICOLON; }
"+"         { return PLUS; }
"-"         { return MINUS; }
"*"         { return MUL; }
"/"         { return DIV; }
"%"         { return MOD; }
":="        { return ASSIGN; }
"="         { return EQ; }
"!="        { return NEQ; }
"<="        { return LET; }
">="        { return GET; }
"<"         { return LT; }
">"         { return GT; }

[_a-z]+     { yylval.id = (char *) strdup(yytext); return IDENTIFIER; }
[0-9]+      { yylval.intval = atoi(yytext); return NUM; }

[ \t\n]+    {}

.           { yyerror("Nierozpoznany znak w kodzie zrodlowym"); exit(0); }

%%
