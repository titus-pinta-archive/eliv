%option noyywrap

%{
#include "utils.hpp"
#include "parser.tab.hpp"


using namespace std;
	
	
symtab* st = new symtab();

	
int yylineno = 1;
	
%}

DIGIT		[0-9]
INTEGER 	[1-9]{DIGIT}*|0
FLOAT		{INTEGER}\.{INTEGER}|\.{INTEGER}
CHAR		\'.\'
STRING		\".*\"
ID      	[a-z_][a-z0-9_]*

%%

\/\/.*$		{/*comments*/ }

[ \t]*		{}

[\n]		{ yylineno++;	}




{INTEGER} 	{yylval.id = st->add_symbol(symbol(0xFF01, yytext, string("$") + string(yytext))); return _INTLIT;}

{FLOAT} 	{float aux = atof(yytext); yylval.id = st->add_symbol(symbol(0xFF02, yytext, string("$") + to_string(*((int*)&aux)))); return _FLOATLIT;}

{CHAR} 		{yylval.id = st->add_symbol(symbol(0xFF03, yytext, string("$") + to_string((int) yytext[1]))); return _CHARLIT;}

{STRING} 	{yylval.id = st->add_symbol(symbol(0xFF04, yytext, string(yytext))); return _STRINGLIT;}



"start"		{return _START; /*baisic keywords*/}

"end"		{return _END;}


"if"		{return _IF; /*control keywords*/}

"fi"		{return _FI;}

"else"		{return _ELSE;}

"while"		{return _WHILE;}

"elihw"		{return _ELIHW;}

"_ASM_"		{return _ASM;}


"void"		{return _VOID; /*types*/}

"char"		{return _CHAR;}

"int"		{return _INT;}

"float"		{return _FLOAT;}

"void^"		{return _VOIDPOINT;}

"char^"		{return _CHARPOINT;}

"int^"		{return _INTPOINT;}

"float^"	{return _FLOATPOINT;}


"^"			{return _POINT; /*pointers*/}

"~"			{return _DEREF;}



"+"			{return _PLUS;  /*arithmetic*/}

"*"			{return _MUL;}

"/"			{return _DIV;}

"-"			{return _MINUS;}

"%"			{return _MODULO;}


"="			{return _EQ; /*assignment*/}


"&&"		{return _AND; /*logic*/}

"||"		{return _OR;}

"!"			{return _NOT;}

"=="		{return _EQUAL;}

"!="		{return _NEQ;}

"<"			{return _LESS;}

">"			{return _GR;}


"("			{return _LPAR; /*paranthesis*/}

")"			{return _RPAR;}

"["			{return _LSB;}

"]"			{return _RSB;}

"{"			{return _LCB;}

"}"			{return _RCB;}



";"			{return _SEMICOL; /*separators*/}

","			{return _COMMA;}

{ID}		{yylval.id = st->add_symbol(symbol(0x0000, yytext, string("nalloc"))); return _ID;}

.			{ cout << "SCANNER "; yyerror(yytext); exit(1);	}

%%
