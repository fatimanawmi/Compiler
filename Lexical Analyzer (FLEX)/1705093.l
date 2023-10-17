%option noyywrap

%x STRING
%x COMMENT1
%x COMMENT2

%{
#include <bits/stdc++.h>
#include "1705093.h"
using namespace std;

int line_count = 1;     
SymbolTable sb(7);
string original = "";
string changed = "";
string comment = "";
bool nullstring = false;
int string_line = 0;
int comment_line = 0;
int error_count = 0;
bool tab = false;

ofstream logout;
ofstream tokenout;

void changedString(string s){

	for(int i = 0; i < s.size() ; i++ ){
		if(s[i] == '\\' && s[i+1] == 'a' ){
			changed += "\a";
			i++;
		}
		else if(s[i] == '\\' && s[i+1] == 'n' ){
			changed += "\n";
			i++;
		}
		else if(s[i] == '\\' && s[i+1] == 't' ){
			changed += "\t";
			i++;
		}
		else if(s[i] == '\\' && s[i+1] == '\\' ){
			changed += "\\";
            i++;
		}
		else if(s[i] == '\\' && s[i+1] == '\'' ){
			changed += "\'";
            i++;
		}
		else if(s[i] == '\\' && s[i+1] == 'r' ){
			changed += "\r";
            i++;
		}
		else if(s[i] == '\\' && s[i+1] == 'b' ){
			changed += "\b";
            i++;
		}
		else if(s[i] == '\\' && s[i+1] == 'f' ){
			changed += "\f";
            i++;
		}
		else if(s[i] == '\\' && s[i+1] == 'v' ){
			changed += "\v";
            i++;
		}
		else if(s[i] == '\\' && s[i+1] == '0' ){
			changed += "\0";
            nullstring = true;
            return ;
		}
		else if(s[i] == '\\' && s[i+1] == '\"' ){
			changed += "\"";
            i++;
		}
		else if(s[i] == '\\' && (i == (s.size()-1)) ){
			line_count ++;
			tab = true;
        }
		else{
			changed += s[i];
		}
	}
	
}

%}
CONST_INT [0-9]+
CONST_FLOAT  ([0-9]*\.?[0-9]+|[0-9]+\.)(E[-+]?[0-9]+)?
CONST_CHAR 	'\\\"'|'[^\\\n]'|'\\n'|'\\t'|'\\\\'|'\\''|'\\a'|'\\f'|'\\r'|'\\b'|'\\v'|'\\0'
UNFINISHED_CHAR_ERR	'([^ '\n]|\\')*
ID      [A-Za-z_]+[A-Za-z_0-9]*
INC 	"++"|"--"
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
EMPTY_CHAR   \'\'
CHAR 	\\\"|\\n|\\t|\\\\|[^'(\\)(\n)]|\\a|\\f|\\r|\\b|\\v|\\0|\\'
MULTI_CHAR_CONST_ERR '{CHAR}{CHAR}+'


%%
{WHITESPACE} {}
"if"         { tokenout << "<IF> "; logout << "Line no "<< line_count << ": Token <IF> Lexeme " << yytext << " found" << endl << endl ;}		
"for"        { tokenout << "<FOR> "; logout << "Line no "<< line_count << ": Token <FOR> Lexeme " << yytext << " found" << endl << endl ;}
"do"         { tokenout << "<DO> "; logout << "Line no "<< line_count << ": Token <DO> Lexeme " << yytext << " found" << endl << endl ;}
"int"        { tokenout << "<INT> "; logout << "Line no "<< line_count << ": Token <INT> Lexeme " << yytext << " found" << endl << endl ;}
"float"      { tokenout << "<FLOAT> "; logout << "Line no "<< line_count << ": Token <FLOAT> Lexeme " << yytext << " found" << endl << endl ;}
"void"       { tokenout << "<VOID> "; logout << "Line no "<< line_count << ": Token <VOID> Lexeme " << yytext << " found" << endl << endl ;}
"switch"     { tokenout << "<SWTICH> "; logout << "Line no "<< line_count << ": Token <SWITCH> Lexeme " << yytext << " found" << endl << endl ;}
"default"    { tokenout << "<DEFAULT> "; logout << "Line no "<< line_count << ": Token <DEFAULT> Lexeme " << yytext << " found" << endl << endl ;}
"else"       { tokenout << "<ELSE> "; logout << "Line no "<< line_count << ": Token <ELSE> Lexeme " << yytext << " found" << endl << endl ;}
"while"      { tokenout << "<WHILE> "; logout << "Line no "<< line_count << ": Token <WHILE> Lexeme " << yytext << " found" << endl << endl ;}
"break"      { tokenout << "<BREAK> "; logout << "Line no "<< line_count << ": Token <BREAK> Lexeme " << yytext << " found" << endl << endl ;}
"char"       { tokenout << "<CHAR> "; logout << "Line no "<< line_count << ": Token <CHAR> Lexeme " << yytext << " found" << endl << endl ;}
"double"     { tokenout << "<DOUBLE> "; logout << "Line no "<< line_count << ": Token <DOUBLE> Lexeme " << yytext << " found" << endl << endl ;}
"return"     { tokenout << "<RETURN> "; logout << "Line no "<< line_count << ": Token <RETURN> Lexeme " << yytext << " found" << endl << endl ;}
"case"       { tokenout << "<CASE> "; logout << "Line no "<< line_count << ": Token <CASE> Lexeme " << yytext << " found" << endl << endl ;}
"continue"   { tokenout << "<CONTINUE> "; logout << "Line no "<< line_count << ": Token <CONTINUE> Lexeme " << yytext << " found" << endl << endl ;}

{CONST_INT} {
                tokenout << "<CONST_INT, " << yytext << "> "; logout << "Line no "<< line_count << ": Token <CONST_INT> Lexeme " << yytext << " found" << endl;
                if(sb.Insert(yytext, "CONST_INT")){
					sb.Print_A(logout); logout << endl;
				}
				else {
					logout << endl;
				}

				
             }
{CONST_FLOAT} {
                tokenout << "<CONST_FLOAT, " << yytext << "> "; logout << "Line no "<< line_count << ": Token <CONST_FLOAT> Lexeme " << yytext << " found" << endl;
                if(sb.Insert(yytext, "CONST_FLOAT")){
					sb.Print_A(logout); logout << endl;
				}
				else {
					 logout << endl;
				}
				
             }

{EMPTY_CHAR} {	
				error_count++;
				logout << "Error at line no "<< line_count << ": Empty character constant error " << yytext << endl << endl;	
			}



{CONST_CHAR}  {  	
					
					string s = "";
					s += yytext; 
					if(s[1] == '\\' && s[2] == 'a' ){
						char c = 7;
						tokenout << "<CONST_CHAR, " << c << "> ";
						logout << "Line no "<< line_count << ": Token <CONST_CHAR> Lexeme '\\a' found --> < CONST_CHAR , " << c << "> " << endl;
						if(sb.Insert("'\\a'", "CONST_CHAR")){
							sb.Print_A(logout); logout << endl;
						}
						else {
							logout << endl;
						}
							
					}
					else if(s[1] == '\\' && s[2] == 'n' ){
						char c = 10;
						tokenout << "<CONST_CHAR, " << c << "> ";
						logout << "Line no "<< line_count << ": Token <CONST_CHAR> Lexeme '\\n' found --> < CONST_CHAR , " << c << "> " << endl;
						if(sb.Insert("'\\n'", "CONST_CHAR")){
							sb.Print_A(logout); logout << endl;
						}
						else {
							logout << endl;
						}
							
					}
					else if(s[1] == '\\' && s[2] == 't' ){
						char c = 9;
						tokenout << "<CONST_CHAR, " << c << "> ";
						logout << "Line no "<< line_count << ": Token <CONST_CHAR> Lexeme '\\t' found --> < CONST_CHAR , " << c << "> " << endl;
						if(sb.Insert("'\\t'", "CONST_CHAR")){
							sb.Print_A(logout); logout << endl;
						}
						else {
							logout << endl;
						}
					}
					else if(s[1] == '\\' && s[2] == '\\' ){
						char c = 92;
						tokenout << "<CONST_CHAR, " << c << "> ";
						logout << "Line no "<< line_count << ": Token <CONST_CHAR> Lexeme '\\\\' found --> < CONST_CHAR , " << c << "> " << endl;
						if(sb.Insert("'\\\\'", "CONST_CHAR")){
							sb.Print_A(logout); logout << endl;
						}
						else {
							logout << endl;
						}
					}
					else if(s[1] == '\\' && s[2] == '\'' ){
						char c = 39;
						tokenout << "<CONST_CHAR, " << c << "> ";
						logout << "Line no "<< line_count << ": Token <CONST_CHAR> Lexeme '\\\'' found --> < CONST_CHAR , " << c << "> " << endl;
						if(sb.Insert("'\\\''", "CONST_CHAR")){
							sb.Print_A(logout); logout << endl;
						}
						else {
							logout << endl;
						}
					}
					else if(s[1] == '\\' && s[2] == 'r' ){
						char c = 13;
						tokenout << "<CONST_CHAR, " << c << "> ";
						logout << "Line no "<< line_count << ": Token <CONST_CHAR> Lexeme '\\r' found --> < CONST_CHAR , " << c << "> " << endl;
						if(sb.Insert("'\\r'", "CONST_CHAR")){
							sb.Print_A(logout); logout << endl;
						}
						else {
							logout << endl;
						}
					}
					else if(s[1] == '\\' && s[2] == 'b' ){
						char c = 8;
						tokenout << "<CONST_CHAR, " << c << "> ";
						logout << "Line no "<< line_count << ": Token <CONST_CHAR> Lexeme '\\b' found --> < CONST_CHAR , " << c << "> " << endl;
						if(sb.Insert("'\\b'", "CONST_CHAR")){
							sb.Print_A(logout); logout << endl;
						}
						else {
							logout << endl;
						}
					}
					else if(s[1] == '\\' && s[2] == 'f' ){
						char c = 12;
						tokenout << "<CONST_CHAR, " << c << "> ";
						logout << "Line no "<< line_count << ": Token <CONST_CHAR> Lexeme '\\f' found --> < CONST_CHAR , " << c << "> " << endl;
						if(sb.Insert("'\\f'", "CONST_CHAR")){
							sb.Print_A(logout); logout << endl;
						}
						else {
							logout << endl;
						}
					}
					else if(s[1] == '\\' && s[2] == 'v' ){
						char c = 11;
						tokenout << "<CONST_CHAR, " << c << "> ";
						logout << "Line no "<< line_count << ": Token <CONST_CHAR> Lexeme '\\v' found --> < CONST_CHAR , " << c << "> " << endl;
						if(sb.Insert("'\\v'", "CONST_CHAR")){
							sb.Print_A(logout); logout << endl;
						}
						else {
							logout << endl;
						}
					}
					else if(s[1] == '\\' && s[2] == '0' ){
						char c = 0;
						tokenout << "<CONST_CHAR, " << c << "> ";
						logout << "Line no "<< line_count << ": Token <CONST_CHAR> Lexeme '\\0' found --> < CONST_CHAR , " << c << "> " << endl;
						if(sb.Insert("'\\0'", "CONST_CHAR")){
							sb.Print_A(logout); logout << endl;
						}
						else {
							logout << endl;
						}
					}
					else if(s[1] == '\\' && s[2] == '\"' ){
						char c = 34;
						tokenout << "<CONST_CHAR, " << c << "> ";
						logout << "Line no "<< line_count << ": Token <CONST_CHAR> Lexeme '\\\"' found --> < CONST_CHAR , " << c << "> " << endl;
						if(sb.Insert("'\\\"'", "CONST_CHAR")){
							sb.Print_A(logout); logout << endl;
						}
						else {
							logout << endl;
						}
					}
					else{
						string c = "";
						c += s[1];
						tokenout << "<CONST_CHAR, " << c << "> ";
						logout << "Line no "<< line_count << ": Token <CONST_CHAR> Lexeme "<< s << " found --> < CONST_CHAR , " << c << "> " << endl;
						if(sb.Insert(s, "CONST_CHAR")){
							sb.Print_A(logout); logout << endl;
						}
						else {
							logout << endl;
						}
					}
				}
{MULTI_CHAR_CONST_ERR} {
			error_count++;
			logout << "Error at line no "<< line_count << ": Multi character constant error " << yytext << endl << endl;
		}

{UNFINISHED_CHAR_ERR} {
						error_count++;
						logout << "Error at line no "<< line_count << ": Unterminated character " << yytext << endl << endl ;

					}

{ID}	{
			tokenout << "<ID, " << yytext << "> "; logout << "Line no "<< line_count << ": Token <ID> Lexeme " << yytext << " found" <<endl;
			if(sb.Insert(yytext, "ID")){
				sb.Print_A(logout); logout << endl;
			}
			else {
				logout << endl;
			}
			
		}
				
{INC}	{   tokenout << "<INCOP, " << yytext<<  "> "; logout << "Line no "<< line_count << ": Token <INCOP> Lexeme " << yytext << " found" << endl << endl ;}
{ADD}	{   tokenout << "<ADDOP, "  << yytext<<  "> "; logout << "Line no "<< line_count << ": Token <ADDOP> Lexeme " << yytext << " found" << endl << endl ;}
{MUL}	{   tokenout << "<MULOP, " << yytext<<  "> "; logout << "Line no "<< line_count << ": Token <MULOP> Lexeme " << yytext << " found" << endl << endl ;}
{RELOP}	{	tokenout << "<RELOP, " << yytext<<  "> "; logout << "Line no "<< line_count << ": Token <RELOP> Lexeme " << yytext << " found" << endl << endl ;}
{ASSOP}	{	tokenout << "<ASSIGNOP, " << yytext<<  "> "; logout << "Line no "<< line_count << ": Token <ASSIGNOP> Lexeme " << yytext << " found" << endl << endl ;}
{LOGICOP}	{	tokenout << "<LOGICOP, " << yytext<<  "> "; logout << "Line no "<< line_count << ": Token <LOGICOP> Lexeme " << yytext << " found" << endl << endl ;}
{NOT}	{	tokenout << "<NOT, " << yytext<<  "> "; logout << "Line no "<< line_count << ": Token <NOT> Lexeme " << yytext << " found" << endl << endl ;}
{COMMA}	{	tokenout << "<COMMA, " << yytext<<  "> "; logout << "Line no "<< line_count << ": Token <COMMA> Lexeme " << yytext << " found" << endl << endl ;}
{SEMICOLON}	{	tokenout << "<SEMICOLON, " << yytext<<  "> "; logout << "Line no "<< line_count << ": Token <SEMICOLON> Lexeme " << yytext << " found" << endl << endl ;}
{RPAREN}	{	tokenout << "<RPAREN, " << yytext<<  "> "; logout << "Line no "<< line_count << ": Token <RPAREN> Lexeme " << yytext << " found" << endl << endl ;}
{LPAREN}	{	tokenout << "<LPAREN, " << yytext<<  "> "; logout << "Line no "<< line_count << ": Token <LPAREN> Lexeme " << yytext << " found" << endl << endl ;}
{LCURL}		{	tokenout << "<LCURL, " << yytext<<  "> ";
			    logout << "Line no "<< line_count << ": Token <LCURL> Lexeme " << yytext << " found" << endl << endl ;
			    sb.EnterScope();
			}
{RCURL}		{	tokenout << "<RCURL, " << yytext<<  "> "; 
				logout << "Line no "<< line_count << ": Token <RCURL> Lexeme " << yytext << " found" << endl << endl ;
				sb.ExitScope();
			}
{LTHIRD}	{	tokenout << "<LTHIRD, " << yytext<<  "> "; logout << "Line no "<< line_count << ": Token <LTHIRD> Lexeme " << yytext << " found" << endl << endl ;}
{RTHIRD}	{	tokenout << "<RTHIRD, " << yytext<<  "> "; logout << "Line no "<< line_count << ": Token <RTHIRD> Lexeme " << yytext << " found" << endl << endl ;}

{NEWLINE}	{line_count++;}

\" {
		nullstring = false;
		changed = "";
		original = "";
		string_line = line_count;
		tab = false;
		BEGIN STRING;
	}
	

<STRING>([^(\n)(\")]|\\\")* {
			original += yytext;
			string temp = "";
			temp += yytext;
			if(!nullstring){
				changedString(temp);
			}
			
	}

<STRING>\n {
			if(tab){
				original += yytext;
				tab = false;
			}
			else{
				error_count++;
				line_count++;
				logout << "Error at line no "<< string_line << ": Unterminated String \"" << original << endl ;
				BEGIN INITIAL;
			}
			
		}


<STRING>\" {
				original += yytext;
				changed += "\"";
				tokenout << "<STRING, \"" << changed <<  "> "; 
				logout << "Line no "<< string_line << ": Token <STRING> Lexeme \"" 
				<< original << " found --> <STRING, \"" << changed <<  "> " <<  endl << endl ;
				BEGIN INITIAL;	
	}

<STRING><<EOF>> {
			logout << "Error at line no "<< string_line << ": Unterminated String \"" << original << endl ;
			error_count++;
			BEGIN INITIAL;
			return 0;
	}
"/*" {
		comment = "/*";
		comment_line = line_count;
		BEGIN COMMENT1;
	}

<COMMENT1>\*\/ {
			comment += yytext;
			logout << "Line no "<< comment_line << ": Token <COMMENT> Lexeme " << comment << " found" << endl << endl ;
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
			logout << "Line no "<< comment_line << ": Token <COMMENT> Lexeme " << comment << " found" << endl << endl ;
			line_count++;
			BEGIN INITIAL;
		}	

{TOO_MANY_DECIMAL} {
					error_count++;
					logout << "Error at line no "<< line_count << ": Too many decimal points " << yytext << endl << endl;
				}
{ILL_FORMED} {
			error_count++;
			logout << "Error at line no "<< line_count << ": Ill formed number " << yytext << endl << endl;
			}


{INVALID_SUFFIX_PREFIX} {	
						error_count++;
						logout << "Error at line no "<< line_count << ": Invalid prefix on ID or invalid suffix on Number " << yytext << endl << endl;
					}

. {	
	logout << "Error at line no "<< line_count << ": Unrecognized character " << yytext << endl << endl;
	error_count++;
	}
	
%%

int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	logout.open("1705093_log.txt");
	tokenout.open("1705093_token.txt");

	yyin = fin;
	yylex();
	sb.Print_A(logout);
	logout << endl;
	logout << "Total lines: " << line_count << endl;
	logout << "Total errors: " << error_count << endl;
	fclose(yyin);
	logout.close();
    tokenout.close();
	return 0;
}
