/* Definition section */
%{
	#include <stdio.h>
	#include <stdlib.h>
        int line_num = 0;
        int comment_num = 0;
%}

/* Define regular expression label */

letter [a-zA-Z]
digit [0-9]

ws [\t\n]+
id {letter}+({letter}|{digit})*
number ([1-9]{digit}+)|{digit}+

/* no * */
a ({ws}|[\40-\51\53-\176]) 

/* no * / */
c ({ws}|[\40-\51\53-\56\58-\176])

any ([\40-\170])

c_comment "/""*"{a}*("*"+{c}{a}*)*"*"+"/"

cpp_comment "/""/"{any}*

I_CONST ("="([\40]*([\53]|[\55])[\40]*{number}|{number}))|{number}
F_CONST (([\53]|[\55])[\40]*{number}"."{digit}+)|({number}"."{digit}+)

/* no \ " */
b ([\40-\41\43-\133\135-\170])

STR_CONST [\42]({b}|[\134]{any})+[\42]

/* Rules section */
%%

{c_comment}     { printf("%s \t C Comment\n", yytext); 
                    for(int i = 0; i < yyleng; i++){
                        if(yytext[i] == '\n'){
                            comment_num++;
                            line_num++;
                        }
                    }
                    comment_num++;
                    }

{cpp_comment}   { printf("%s \t C++ Comment\n", yytext); 
                    comment_num++; }
"+" 	    { printf("%s \t ADD\n", yytext); }
"-"	    { printf("%s \t SUB\n", yytext); }
"*"         { printf("%s \t MUL\n", yytext); }
"/"         { printf("%s \t DIV\n", yytext); }
"%"         { printf("%s \t MOD\n", yytext); }
"++"        { printf("%s \t INC\n", yytext); }
"--"        { printf("%s \t DEC\n", yytext); }
">"         { printf("%s \t MT\n", yytext); }
"<"         { printf("%s \t LT\n", yytext); }
">="        { printf("%s \t MTE\n", yytext); }
"<="        { printf("%s \t LTE\n", yytext); }
"=="        { printf("%s \t EQ\n", yytext); }
"!="        { printf("%s \t NE\n", yytext); }
"["         { printf("%s \t LSB\n", yytext); }
"]"         { printf("%s \t RSB\n", yytext); }
","         { printf("%s \t COMMA\n", yytext); }
";"         { printf("%s \t SEMICOLON\n", yytext); }
"\""        { printf("%s \t QUOTA\n", yytext); }
"print"     { printf("%s \t PRINT\n", yytext); }
"if"        { printf("%s \t IF\n", yytext); }
"else"      { printf("%s \t ELSE\n", yytext); }
"for"       { printf("%s \t FOR\n", yytext); }
"while"     { printf("%s \t WHILE\n", yytext); }
"string"    { printf("%s \t STRING\n", yytext); }
"int"       { printf("%s \t INT\n", yytext); }
"float"     { printf("%s \t FLOAT\n", yytext); }
"="         { printf("%s \t ASGN\n", yytext); }
"+="        { printf("%s \t ADDASGN\n", yytext); }
"-="        { printf("%s \t SUBASGN\n", yytext); }
"*="        { printf("%s \t MULASGN\n", yytext); }
"/="        { printf("%s \t DIVASGN\n", yytext); }
"%="        { printf("%s \t MODASGN\n", yytext); }
"&&"        { printf("%s \t AND\n", yytext); }
"||"        { printf("%s \t OR\n", yytext); }
"!"         { printf("%s \t NOT\n", yytext); }
"("         { printf("%s \t LB\n", yytext); }
")"         { printf("%s \t RB\n", yytext); }
"{"         { printf("%s \t LCB\n", yytext); }
"}"         { printf("%s \t RCB\n", yytext); }
"void"      { printf("%s \t VOID\n", yytext); }
"bool"      { printf("%s \t BOOL\n", yytext); }
"true"      { printf("%s \t TRUE\n", yytext); }
"false"     { printf("%s \t FALSE\n", yytext); }
"return"    { printf("%s \t RET\n", yytext); }
"continue"  { printf("%s \t CONT\n", yytext); }
"break"     { printf("%s \t BREAK\n", yytext); }
{I_CONST}   { if(yytext[0] == '='){
                int b = 1;
                for(int i = 0;i < yyleng; i++){
                    if(i >= yyleng-b-1){
                        yytext[i] = '\0';
                    }
                    if(yytext[i+b] == ' ')
                        b += 1;
                    yytext[i] = yytext[i+b];
                }
              
                printf("= \t ASGN\n");
              }
              printf("%s \t I_CONST\n", yytext); }
{F_CONST}   { printf("%s \t F_CONST\n", yytext); }
{STR_CONST} { printf("\" \t QUOTA\n");
                for(int i = 0; i < yyleng; i++){
                    if(i == yyleng-2){
                        yytext[i] = '\0';
                        break;
                    }
                    yytext[i] = yytext[i+1];
                }
                printf("%s \t STR_CONST\n", yytext); 
                printf("\" \t QUOTA\n");}
{id}	    { printf("%s \t ID\n", yytext); }
\n	    { line_num++; }
\t          {;}
[\40]       {;}

%%

/*	C Code section */
int yywrap(void)
{
    return 1;
}

int main(int argc,char *argv[])
{
	yyin = fopen(argv[1],"r");
	yylex();
	printf("\nParse over, the line number is %d.\n\n", line_num);
	printf("comment: %d lines\n\n", comment_num);

	return 0;
}
