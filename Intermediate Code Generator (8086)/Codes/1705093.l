%option noyywrap

%x COMMENT1
%x COMMENT2

%{
#include <bits/stdc++.h>
#include "1705093.h"
#define YYSTYPE SymbolInfo*
#include "y.tab.h"

using namespace std;

int line_count = 1;     
int error_count = 0;

int comment_line = 0;
string comment;

extern YYSTYPE yylval;
extern SymbolTable *sb;
extern ofstream logout, errorout;

void yyerror(char *);


%}

CONST_INT [0-9]+
CONST_FLOAT  ([0-9]*\.?[0-9]+|[0-9]+\.)((E[-+]?[0-9]+)|(e[-+]?[0-9]+))?
ID      [A-Za-z_]+[A-Za-z_0-9]*
INCOP 	"++"
DECOP   "--"
ADD    	[+-]
MUL		[*/%]
RELOP	"<"|"<="|">"|">="|"=="|"!="
ASSOP   "="
LOGICOP  "&&"|"||"
COMMA  ,
SEMICOLON ;
RPAREN ")"
LPAREN "("
RCURL "}"
LCURL "{"
LTHIRD "["
RTHIRD "]"
NOT "!"
WHITESPACE [ \t\f\r\v]+ 
NEWLINE \n
TOO_MANY_DECIMAL [0-9]*\.[0-9]+\.([0-9]*\.?)*
ILL_FORMED {CONST_FLOAT}*(\.?[Ee]?)+{CONST_FLOAT}*
INVALID_SUFFIX_PREFIX  {CONST_FLOAT}{ID}+|{CONST_INT}{ID}+|{ID}{CONST_FLOAT}+|{ID}{CONST_INT}+



%%
{WHITESPACE} {}
"if"         {return IF;}	
"for"        {return FOR;}	
"do"         {return DO;}
"int"        {return INT;}
"float"      {return FLOAT;}
"void"       {return VOID;}
"default"    {return DEFAULT;}
"else"       {return ELSE;}
"while"      {return WHILE;}
"char"       {return CHAR;}
"double"     {return DOUBLE;}
"return"     {return RETURN;}
"println"	 {return PRINTLN;}

{CONST_INT} {
                SymbolInfo* si = new SymbolInfo(yytext,"CONST_INT");
				yylval = (YYSTYPE)si;
				return CONST_INT;
             }
{CONST_FLOAT} {
                SymbolInfo* si = new SymbolInfo(yytext,"CONST_FLOAT");
				yylval = (YYSTYPE)si;
				return CONST_FLOAT;
             }

{ID}	{
			SymbolInfo* si = new SymbolInfo(yytext, "ID");
			yylval = (YYSTYPE)si;
			return ID;
		}
				
{INCOP}	{return INCOP;}
{DECOP}	{return DECOP;}
{ADD}	{  
			SymbolInfo *si = new  SymbolInfo(yytext, "ADDOP");
			yylval = (YYSTYPE)si;
			return ADDOP;
		}
{MUL}	{  
			SymbolInfo *si = new  SymbolInfo(yytext,"MULOP");
			yylval = (YYSTYPE)si;
			return MULOP;
		}
{RELOP}	{	
			SymbolInfo *si = new  SymbolInfo(yytext,"RELOP");
			yylval = (YYSTYPE)si;
			return RELOP;
		}
{ASSOP}	{   
			SymbolInfo *si = new  SymbolInfo(yytext,"RELOP");
			yylval = (YYSTYPE)si;
			return ASSIGNOP;
			}
{LOGICOP}	{	
				SymbolInfo *si = new  SymbolInfo(yytext, "LOGICOP");
				yylval = (YYSTYPE)si ;
				return LOGICOP;
			}
{NOT}	{return NOT;}
{COMMA}	{return COMMA;}
{SEMICOLON}	{return SEMICOLON;}
{RPAREN}	{return RPAREN;}
{LPAREN}	{return LPAREN;}
{LCURL}		{return LCURL;}
{RCURL}		{return RCURL;}
{LTHIRD}	{return LTHIRD;}
{RTHIRD}	{return RTHIRD;}

{NEWLINE}	{line_count++;}


"/*" {
		comment = "/*";
		comment_line = line_count;
		BEGIN COMMENT1;
	}

<COMMENT1>\*\/ {
			comment += yytext;
			BEGIN INITIAL;
		}

<COMMENT1>[^(\*)(\\)(\n)]+ {
			comment += yytext;
		}
<COMMENT1>(\n) {
			comment += yytext;
			line_count++;
		}
<COMMENT1>\* {
			comment += yytext;
		}
<COMMENT1>\\ {
			comment += yytext;
		}
<COMMENT1><<EOF>>  {
						logout << "Error at line no "<< comment_line << ": Unterminated Comment " << comment << endl ;
						errorout << "Error at line no "<< comment_line << ": Unterminated Comment " << comment << endl ;
						error_count++;
						BEGIN INITIAL;
						return 0;
					}

\/\/  {
			comment = "//";
			comment_line = line_count ;
			BEGIN COMMENT2;
	}
<COMMENT2>.*\\\n {
			comment += yytext;
			line_count++ ;
	}

<COMMENT2>.*\n {
			yytext[strlen(yytext)-1] = '\0'; 
			comment += yytext;
			line_count++;
			BEGIN INITIAL;
		}	

{TOO_MANY_DECIMAL} {
					error_count++;
					logout << "Error at line no "<< line_count << ": Too many decimal points " << yytext << endl << endl;
					errorout << "Error at line no "<< line_count << ": Too many decimal points " << yytext << endl << endl;
				}
{ILL_FORMED} {
			error_count++;
			logout << "Error at line no "<< line_count << ": Ill formed number " << yytext << endl << endl;
			errorout << "Error at line no "<< line_count << ": Ill formed number " << yytext << endl << endl;
			}


{INVALID_SUFFIX_PREFIX} {	
						error_count++;
						logout << "Error at line no "<< line_count << ": Invalid prefix on ID or invalid suffix on Number " << yytext << endl << endl;
						errorout << "Error at line no "<< line_count << ": Invalid prefix on ID or invalid suffix on Number " << yytext << endl << endl;
					}

. {	
	logout << "Error at line no "<< line_count << ": Unrecognized character " << yytext << endl << endl;
	error_count++;
	}
	
%%


