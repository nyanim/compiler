%{
#include <stdio.h>
#include <stdlib.h>
//#include "symbols.h"
#define YYSTYPE char *

extern FILE * yyin;
extern FILE * yyout;

void yyerror(const char*); 
int yylex();
char * gen_expr(char*,char*,int);
%}

%token K_INT K_ELSE K_IF K_RETURN K_VOID K_WHILE K_PRINTF K_READ
%token ID NO_ID NUM 
%token O_ASSIGN O_COMMA O_SEMI O_LSBRACKER O_RSBRACKER O_LMBRACKER O_RMBRACKER O_LLBRACKER O_RLBRACKER
%token O_ADD O_SUB O_MUL O_DIV O_LESS O_L_EQUAL O_GREATER O_G_EQUAL O_EQUAL O_U_EQUAL
%token COMMENT SPACES U_LEGAL

%left '+' '-'
%left '*' '/'
%right U_neg

%define parse.error verbose 
%locations


%%

Program:
        /**/                                {/**/}
|       Program FunctionDeclare             {/**/}
;

FunctionDeclare:
    ReturnType FunctionName O_LSBRACKER Args O_RSBRACKER O_LLBRACKER FunctionContent O_RLBRACKER {/**/}
;

ReturnType:
    K_INT                       {/**/}
|    K_VOID                      {/**/}
;

FunctionName:
    ID                          {/**/}
;

Args:
    /* empty */             { /* empty */ }
|    Arg                      {/**/}
;

Arg:
    ArgType Id                 {}
|   Arg O_COMMA ArgType Id     {}
;

ArgType:
    K_INT                   {/**/}
;


FunctionContent:
    Stmts                        {/**/}
;

Stmts:
    /* empty */             { /* empty */ }
|   Stmts Stmt              { /* empty */ }
;

Stmt:
    DeclareStmt                 { printf("\n\n"); }
|   AssignStmt                      { /* empty */ }
|   PrintfStmt                       { /* empty */ }
|   ReadStmt                {}
|   CallStmt                { /* empty */ }
|   ReturnStmt              { /* empty */ }
|   IfStmt                  {}
|   WhileStmt               {}
;

IfStmt:
    K_IF O_LSBRACKER E O_RSBRACKER O_LLBRACKER Stmts O_RLBRACKER    {}
|   IfStmt K_ELSE O_LLBRACKER Stmts O_RLBRACKER                     {}
;

WhileStmt:
    K_WHILE O_LSBRACKER E O_RSBRACKER O_LLBRACKER Stmts O_RLBRACKER {}
;

DeclareStmt:
    K_INT Id O_SEMI         { printf("var %s", $2); }
;

AssignStmt:
    Id O_ASSIGN E O_SEMI      { printf("%s = %s",$1,$3); }
|   Id O_ASSIGN CallStmt O_SEMI {}
;

PrintfStmt:
    K_PRINTF O_LSBRACKER Id O_RSBRACKER O_SEMI { printf("print %s\n\n", $3); }
;

ReadStmt:
    K_READ O_LSBRACKER Id O_RSBRACKER O_SEMI    {}
;

CallStmt:
   ID O_LSBRACKER Args O_RSBRACKER    {/**/}
|  CallStmt O_SEMI                     {}
;

ReturnStmt:
    K_RETURN Id O_SEMI                  {/**/}
|   K_RETURN E O_SEMI                 {}
|   K_RETURN O_SEMI                 {}
;

E:
    E O_ADD E                     { $$ = gen_expr($1,$3,1); }
|   E O_SUB E                     {  }
|   E O_MUL E                     {  }
|   E O_DIV E                     {  }
|   O_SUB E %prec U_neg           {  }
|   NUM                         {  }
|   Id                          {  }
|   O_LSBRACKER E O_RSBRACKER       { printf("( %s )\n",$2); }
;

Id:
    ID                          {}
|   ID O_LMBRACKER E O_RMBRACKER    {}
;

%%


char * gen_expr(char * s1,char * s2, int op){
    char op_char;
    if (op == 1){
        op_char = '+';
    }else if (op == 2){
        op_char = '-';
    }
    printf("%s %c %s \n",s1, op_char, s2);
    char * ret = (char*)malloc(sizeof(char)*20);
    strcpy (ret, s1);
    ret[strlen(ret)] = op_char;
    strcat (ret, s2);
    printf("%s",ret);
    return ret;
}

typedef struct node{
    char addr[255];
    char lexeme[255];
    char code[255];
}node;

int main(int argc,char* argv[]) {
	//yyout = fopen( "out.txt", "w" );
    yyin = fopen(argv[1],"r");
	//while(yylex());
    return yyparse();
}