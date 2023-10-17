%{
#include <bits/stdc++.h>
#include "1705093.h"
#define YYSTYPE SymbolInfo*
using namespace std;

SymbolTable *sb = new SymbolTable(30);
ofstream logout, errorout;
SymbolInfo *dec_list = nullptr;
vector<pair<string, string>> param_list ;
vector<string>arg_list;
int yyparse(void);
int yylex(void);

extern int line_count;
extern int error_count;
extern FILE* yyin;

bool ifParam(string name){
	for(int i = 0; i< param_list.size(); i++){
		if(param_list[i].first == name){
			return false;
		}
	}
	return true;
}
bool check_dec(string name){
	if(dec == nullptr) return true;
	SymbolInfo *temp = dec_list;
	while(temp != nullptr){
		if(temp->getName() == name){
			return false;
		}
		temp = temp->getNext();
	}
	return true;
}
void yyerror(char *s)
{
	logout << "Unhandled Syntax Error" << endl;
	errorout << "Unhandled Syntax Error" << endl;
}

%}

%token IF FOR DO INT FLOAT VOID DEFAULT ELSE WHILE CHAR DOUBLE
%token RETURN PRINTLN ID ADDOP MULOP CONST_INT CONST_FLOAT 
%token INCOP DECOP RELOP ASSIGNOP LOGICOP NOT COMMA SEMICOLON RPAREN
%token LPAREN LCURL RCURL LTHIRD RTHIRD 

%nonassoc LOWER_THAN_ELSE 
%nonassoc ELSE

%%

start : program  { $$ = $1;
				   logout << "Line " << line_count << "\:"  <<" start : program" << endl << endl;
				   sb->Print_A(logout);	
				   logout << "Total lines: " <<  line_count << endl;
				   logout << "Total errors: " <<error_count << endl;
				}
	;

program : program unit {
					$$ = new SymbolInfo($1->getName()+ $2->getName(), "unit");
					logout << "Line " << line_count << "\:"  <<" program : program unit" << endl << endl;
					logout << $$->getName() <<  endl << endl ;
				}
	| unit { 	
				$$ = $1;
				logout << "Line " << line_count << "\:"  <<" program : unit" << endl << endl;
				logout << $$->getName() <<  endl << endl ;
			}
	;

unit : var_declaration{
					$$ = new SymbolInfo($1->getName(), "unit");
					logout << "Line " << line_count << "\:"  <<" unit : var_declaration" << endl << endl;
					logout << $$->getName() <<  endl << endl;
				}
     | func_declaration{
					$$ = new SymbolInfo($1->getName(), "unit");
					logout << "Line " << line_count << "\:"  <<" unit : func_declaration" << endl << endl;
					logout << $$->getName() <<  endl << endl;
				}
     | func_definition{
					$$ = new SymbolInfo($1->getName(), "unit");
					logout << "Line " << line_count << "\:"  <<" unit : func_definition" << endl << endl ;
					logout << $$->getName() <<  endl << endl ;
				}
     ;

func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {
					$$ = new SymbolInfo($1->getName()+" "+$2->getName()+"("+$4->getName()+");\n", "func_declaration");
					logout << "Line " << line_count << "\:"  <<" func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON" << endl << endl;
					logout << $$->getName() <<  endl << endl;

					
					
					if(sb->LookUpCur($2->getName()) == nullptr){
						SymbolInfo *temp = new SymbolInfo($2->getName(), "ID");

						for(int i = 0; i < param_list.size(); i++){
							temp->setParam(param_list[i].first, param_list[i].second);
							if((i != 0 && param_list[i].second == "void") || (i == 0 && param_list[i].second == "void" && param_list.size() > 1)){
								logout << "Error at line "<< line_count << ": Invalid use of type \"void\" in parameter declaration of function "<< $2->getName() << endl << endl;
								errorout << "Error at line "<< line_count << ": Invalid use of type \"void\" in parameter declaration of function "<< $2->getName() << endl << endl;
								error_count++;
							}
						}

						temp->setVarType($1->getName());
						temp->setFunc(true);
						temp->setDec(true);
						sb->Insert(temp);
					}
					else{
						logout << "Error at line "<< line_count << ": Multiple declaration of "<< $2->getName() << endl << endl;
						errorout << "Error at line "<< line_count << ": Multiple declaration of "<< $2->getName() << endl << endl;
						error_count++;
					}

					param_list.clear();

					delete $1;
					delete $2;
					delete $4;

				 }
		| type_specifier ID LPAREN RPAREN SEMICOLON {
				$$ = new SymbolInfo($1->getName()+" "+$2->getName()+"();\n", "func_declaration");
				logout << "Line " << line_count << "\:"  <<" func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON" << endl << endl;
				logout << $$->getName() <<  endl << endl;

				if(sb->LookUpCur($2->getName()) == nullptr){
					SymbolInfo *temp = new SymbolInfo($2->getName(), "ID");
					temp->setVarType($1->getName());
					temp->setFunc(true);
					temp->setDec(true);
					sb->Insert(temp);
				}
				else{
						logout << "Error at line "<< line_count << ": Multiple declaration of "<< $2->getName() << endl << endl;
						errorout << "Error at line "<< line_count << ": Multiple declaration of "<< $2->getName() << endl << endl;
						error_count++;
				}

				param_list.clear();
					
				delete $1;
				delete $2;
		}
		;	

func_definition : type_specifier ID LPAREN parameter_list RPAREN{
					
					SymbolInfo* check = sb->LookUpCur($2->getName()) ;

					if( check == nullptr){
						SymbolInfo *temp = new SymbolInfo($2->getName(), "ID");

						for(int i = 0; i < param_list.size(); i++){
							temp->setParam(param_list[i].first, param_list[i].second);
							if((i != 0 && param_list[i].second == "void") || (i == 0 && param_list[i].second == "void" && param_list.size() > 1)){
								logout << "Error at line "<< line_count << ": Invalid use of type \"void\" in parameter declaration of function "<< $2->getName() << endl << endl;
								errorout << "Error at line "<< line_count << ": Invalid use of type \"void\" in parameter declaration of function "<< $2->getName() << endl << endl;
								error_count++;
							}
						}
						temp->setVarType($1->getName());
						temp->setFunc(true);
						temp->setDef(true);
						sb->Insert(temp);
					}
					else if((check != nullptr && !check->getFunc()) || (check != nullptr &&  check->getDef() && check->getFunc())){
						logout << "Error at line "<< line_count << ": Multiple declaration of "<< $2->getName() << endl << endl;
						errorout << "Error at line "<< line_count << ": Multiple declaration of "<< $2->getName() << endl << endl;
						error_count++;
					}
					else if(check != nullptr && check->getFunc() && !check->getDef() & check->getDec()){
						if(check->getVarType() != $1->getName()){
							logout << "Error at line "<< line_count << ": Return type mismatch with function declaration in function "<< $2->getName() << endl << endl;
							errorout << "Error at line "<< line_count << ": Return type mismatch with function declaration in function "<< $2->getName() << endl << endl;
							error_count++;
						}
						else if(check->getparamSize() != param_list.size()){
							bool flag = false;

							if((check->getparamSize() == 1 && param_list.size() == 0 && check->getParam(0) == "void" && check->getParamName(0) == "")||
							  (check->getparamSize() == 0 && param_list.size() == 1 && param_list[0].second == "void" && param_list[0].first == "")){
								flag = true;
							}
							if(!flag){
								logout << "Error at line "<< line_count << ": Total number of arguments mismatch with declaration in function "<< $2->getName() << endl << endl;
								errorout << "Error at line "<< line_count << ": Total number of arguments mismatch with declaration in function "<< $2->getName() << endl << endl;
								error_count++;
							}
						}
						else{
							bool flag = flag;
							for(int i = 0; i < param_list.size(); i++){
								if(param_list[i].second != check->getParam(i)){
									logout << "Error at line "<< line_count << ": " << i+1 << "th argument mismatch with declaration in function "<< $2->getName() << endl << endl;
									errorout << "Error at line "<< line_count << ": " << i+1 << "th argument mismatch with declaration in function "<< $2->getName() << endl << endl;
									error_count++;
									flag = true;
								}
							}
							if(!flag){
								check->setDef(true);
							}
						}
					}
					

				} compound_statement{
					$$ = new SymbolInfo($1->getName()+" "+$2->getName()+"("+$4->getName()+")"+ $7->getName(), "func_definition");
					logout << "Line " << line_count << "\:"  <<" func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement" << endl << endl;
					logout << $$->getName() <<  endl << endl;

					delete $1;
					delete $2;
					delete $4;
					delete $7;
				}
		| type_specifier ID LPAREN RPAREN {
					SymbolInfo* check = sb->LookUpCur($2->getName()) ;

					if( check == nullptr){
						SymbolInfo *temp = new SymbolInfo($2->getName(), "ID");
						temp->setVarType($1->getName());
						temp->setFunc(true);
						temp->setDef(true);
						sb->Insert(temp);
					}
					else if((check != nullptr && !check->getFunc()) || (check != nullptr &&  check->getDef() && check->getFunc())){
						logout << "Error at line "<< line_count << ": Multiple declaration of "<< $2->getName() << endl << endl;
						errorout << "Error at line "<< line_count << ": Multiple declaration of "<< $2->getName() << endl << endl;
						error_count++;
					}
					else if(check != nullptr && check->getFunc() && !check->getDef() & check->getDec()){
						if(check->getVarType() != $1->getName()){
							logout << "Error at line "<< line_count << ": Return type mismatch with function declaration in function "<< $2->getName() << endl << endl;
							errorout << "Error at line "<< line_count << ": Return type mismatch with function declaration in function "<< $2->getName() << endl << endl;
							error_count++;
						}
						else{
							check->setDef(true);
						}
					}
					
				}compound_statement{
					$$ = new SymbolInfo($1->getName()+" "+$2->getName()+"()"+ $6->getName(), "func_definition");
					logout << "Line " << line_count << "\:"  <<" func_definition : type_specifier ID LPAREN RPAREN compound_statement" << endl << endl;
					logout << $$->getName() <<  endl << endl;

					delete $1;
					delete $2;
					delete $6;
		}
 		;	

parameter_list  : parameter_list COMMA type_specifier ID {
					if(ifParam($4->getName())){
						param_list.push_back(make_pair($4->getName(), $3->getName()));
					}
					else{
						logout << "Error at line "<< line_count << ": Multiple declaration of "<< $4->getName() <<" in parameter" << endl << endl;
						errorout <<"Error at line "<< line_count << ": Multiple declaration of "<< $4->getName() <<" in parameter" << endl << endl;
						error_count++;
					}

					$$ = new SymbolInfo($1->getName()+","+$3->getName()+" "+$4->getName(), "parameter_list");
					logout << "Line " << line_count << "\:"  <<" parameter_list : parameter_list COMMA type_specifier ID" << endl << endl;
					logout << $$->getName() <<  endl << endl;

					delete $1;
					delete $3;
					delete $4;					
				}
		| parameter_list COMMA type_specifier	{ 
			$$ = new SymbolInfo($1->getName()+","+$3->getName(), "parameter_list");
			logout << "Line " << line_count << "\:"  <<" parameter_list : parameter_list COMMA type_specifier" << endl << endl;
			logout << $$->getName() <<  endl << endl;

			param_list.push_back(make_pair("", $3->getName()));
			delete $1;
			delete $3;
		}
 		| type_specifier ID {
			if(ifParam($2->getName())){
				param_list.push_back(make_pair($2->getName(), $1->getName()));
			}
			else{
				logout << "Error at line "<< line_count << ": Multiple declaration of "<< $2->getName() <<" in parameter" << endl << endl;
				errorout <<"Error at line "<< line_count << ": Multiple declaration of "<< $2->getName() <<" in parameter" << endl << endl;
				error_count++;

			}

			$$ = new SymbolInfo($1->getName()+" "+$2->getName(), "parameter_list");
			logout << "Line " << line_count << "\:"  <<" parameter_list : type_specifier ID" << endl << endl;
			logout << $$->getName() <<  endl << endl;

			delete $1;
			delete $2;
		}
		| type_specifier {
			$$ = new SymbolInfo($1->getName(), "parameter_list");
			logout << "Line " << line_count << "\:"  <<" parameter_list : type_specifier" << endl << endl;
			logout << $$->getName() <<  endl << endl;

			param_list.push_back(make_pair("", $1->getName()));
			delete $1;
		}
 		;

compound_statement : LCURL {
					sb->EnterScope(logout);
					for(int i = 0; i < param_list.size(); i++){
						SymbolInfo *temp = new SymbolInfo(param_list[i].first, "ID");
						temp->setVarType(param_list[i].second);
						sb->Insert(temp);
					}
					param_list.clear();
				}statements RCURL {
				$$ = new SymbolInfo("{\n" + $3->getName() + "}\n", "compound_statement");

				logout << "Line " << line_count << "\:"  <<" compound_statement : LCURL statements RCURL" << endl << endl;
				logout << $$->getName() <<  endl << endl;
				sb->Print_A(logout);
				sb->ExitScope(logout);
			}
 		    | LCURL {
					sb->EnterScope(logout);
				} RCURL {
				$$ = new SymbolInfo("{}\n", "compound_statement");
				logout << "Line " << line_count << "\:"  <<" compound_statement : LCURL RCURL" << endl << endl;
				logout << $$->getName() <<  endl << endl;
				sb->Print_A(logout);
				sb->ExitScope(logout);
			}
 		    ;
var_declaration : type_specifier declaration_list SEMICOLON{
						$$ = new SymbolInfo($1->getName()+" "+$2->getName()+";\n", "var_declaration");

						if($1->getName() == "void"){
							logout << "Error at line "<< line_count << ": Variable type cannot be void" << endl << endl;
							errorout <<"Error at line "<< line_count << ": Variable type cannot be void" << endl << endl;
							error_count++;
						}
						else{
							while(dec_list != nullptr){
								SymbolInfo* temp = dec_list;
								dec_list = dec_list->getNext();
								temp->setVarType($1->getName());
								temp->setNext(nullptr);
								sb->Insert(temp);
							}
						}
						

						logout << "Line " << line_count << "\:"  <<" var_declaration : type_specifier declaration_list SEMICOLON" << endl << endl;
						logout << $$->getName() <<  endl ;

						
						dec_list = nullptr;
						delete $1;
						delete $2;
				}
 		 ;

type_specifier	: INT { 
							$$ = new SymbolInfo("int", "type_specifier");
							logout << "Line " << line_count << "\:"  << " type_specifier : INT" << endl << endl;
							logout << "int" << endl << endl;
					  }
 		| FLOAT { 
					$$ = new SymbolInfo("float", "type_specifier");
					logout << "Line " << line_count << "\:"  << " type_specifier : FLOAT" << endl << endl;
					logout << "float" << endl << endl;
			    }
 		| VOID { 
					$$ = new SymbolInfo("void", "type_specifier");
					logout << "Line " << line_count << "\:"  << " type_specifier : VOID" << endl << endl;
					logout << "void" << endl << endl;
			   }
 		;	

declaration_list : declaration_list COMMA ID {
						if(sb->LookUpCur($3->getName()) == nullptr && check_dec($3->getName())){
							if(dec_list != nullptr){
								SymbolInfo *temp1 = new SymbolInfo($3->getName(),$3->getType());
								SymbolInfo *temp2 = dec_list;
								while(temp2->getNext() != nullptr){
									temp2 = temp2->getNext();
								}
								temp2->setNext(temp1);
							}
							else dec_list = new SymbolInfo($3->getName(),$3->getType());
						}
						else{
							logout << "Error at line " << line_count << ": Multiple declaration of " << $3->getName() <<endl << endl;
							errorout << "Error at line " << line_count << ": Multiple declaration of " << $3->getName() <<endl << endl;
							error_count++;
						}
						
						$$ = new SymbolInfo($1->getName()+","+$3->getName(), "declaration_list");
						logout << "Line " << line_count << "\:"  <<" declaration_list : declaration_list COMMA ID" << endl << endl;
						logout << $$->getName() <<  endl << endl;

						delete $1;
						delete $3;
					}
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {

				if(sb->LookUpCur($3->getName()) == nullptr && check_dec($3->getName())){
					if(dec_list != nullptr){
						SymbolInfo *temp1 = new SymbolInfo($3->getName(),$3->getType());
						SymbolInfo *temp2 = dec_list;
						while(temp2->getNext() != nullptr){
							temp2 = temp2->getNext();
						}
						temp2->setNext(temp1);
						temp2->getNext()->setArr(true);
						temp2->getNext()->setSize(stoi($5->getName()));
					}
					else{
						dec_list = new SymbolInfo($3->getName(),$3->getType());
						dec_list->setArr(true);
						dec_list->setSize(stoi($5->getName()));
					} 
				}
				else{
					logout << "Error at line " << line_count <<": Multiple declaration of " << $3->getName() <<endl<< endl;
					errorout << "Error at line " << line_count << ": Multiple declaration of " << $3->getName() <<endl<< endl;
					error_count++;
				}

				$$ = new SymbolInfo($1->getName()+","+$3->getName()+"[" + $5->getName() + "]", "declaration_list");
				logout << "Line " << line_count << "\:"  <<" declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD" << endl << endl;
				logout << $$->getName() <<  endl << endl;	

				delete $1;
				delete $3;
				delete $5;
			}
 		  | ID {
					if(sb->LookUpCur($1->getName()) == nullptr && check_dec($1->getName())){
						if(dec_list != nullptr){
							SymbolInfo *temp1 = new SymbolInfo($1->getName(),$1->getType());
							SymbolInfo *temp2 = dec_list;
							while(temp2->getNext() != nullptr){
								temp2 = temp2->getNext();
							}
							temp2->setNext(temp1);
						}
						else{
							dec_list = new SymbolInfo($1->getName(),$1->getType());
						} 
					}
					else{
						logout << "Error at line " << line_count << ": Multiple declaration of " << $1->getName() <<endl<< endl;
						errorout << "Error at line " << line_count << ": Multiple declaration of " << $1->getName() <<endl<< endl;
						error_count++;
					}

					$$ = new SymbolInfo($1->getName(), "declaration_list");
					logout << "Line " << line_count << "\:"  <<" declaration_list : ID" << endl << endl;
					logout << $1->getName() <<  endl << endl;

					delete $1;
			   }
 		  | ID LTHIRD CONST_INT RTHIRD {

				if(sb->LookUpCur($1->getName()) == nullptr && check_dec($1->getName())){
					if(dec_list != nullptr){
						SymbolInfo *temp1 = new SymbolInfo($1->getName(),$1->getType());
						SymbolInfo *temp2 = dec_list;
						while(temp2->getNext() != nullptr){
							temp2 = temp2->getNext();
						}
						temp2->setNext(temp1);
						temp2->getNext()->setArr(true);
						temp2->getNext()->setSize(stoi($3->getName()));
					}
					else{
						dec_list = new SymbolInfo($1->getName(),$1->getType());
						dec_list->setArr(true);
						dec_list->setSize(stoi($3->getName()));
					} 
				}
				else{
					logout << "Error at line " << line_count << ": Multiple declaration of " << $1->getName() <<endl<< endl;
					errorout << "Error at line " << line_count << ": Multiple declaration of " << $1->getName() <<endl<< endl;
					error_count++;
				}

				$$ = new SymbolInfo($1->getName()+"["+$3->getName()+"]", "declaration_list");
				logout << "Line " << line_count << "\:"  <<" declaration_list : ID LTHIRD CONST_INT RTHIRD" << endl << endl;
				logout << $$->getName() <<  endl << endl;

				delete $1;
				delete $3;
			}
 		  ;
statements : statement {
		   		$$ = new SymbolInfo($1->getName(), "statements");
				logout << "Line " << line_count << "\:"  <<" statements : statement" << endl << endl;
				logout << $$->getName() <<  endl << endl;
			}
	   | statements statement {
		   		$$ = new SymbolInfo($1->getName()+ $2->getName(), "statements");
				logout << "Line " << line_count << "\:"  <<" statements : statements statement" << endl << endl;
				logout << $$->getName() <<  endl << endl;
	   		}
	   ;	

statement : var_declaration {
		  		$$ = new SymbolInfo($1->getName(), "statement");
				logout << "Line " << line_count << "\:"  <<" statement : var_declaration" << endl << endl;
				logout << $$->getName() <<  endl << endl;
	  		}
	  | expression_statement {
		  		$$ = new SymbolInfo($1->getName()+"\n", "statement");
				logout << "Line " << line_count << "\:"  <<" statement : expression_statement" << endl << endl;
				logout << $$->getName() <<  endl << endl;
	  		}
	  | compound_statement {
		  		$$ = new SymbolInfo($1->getName(), "statement");
				logout << "Line " << line_count << "\:"  <<" statement : compound_statement" << endl << endl;
				logout << $$->getName() <<  endl << endl;
	  		}
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement {
		  		$$ = new SymbolInfo("for("+ $3->getName()+$4->getName()+$5->getName()+")"+$7->getName(), "statement");
				logout << "Line " << line_count << "\:"  <<" statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement" << endl << endl;
				logout << $$->getName() <<  endl << endl;

				if($5->getVarType() == "void"){
					logout << "Error at line "<< line_count << ": Void function used in expression" << endl << endl;
					errorout << "Error at line "<< line_count << ": Void function used in expression" << endl << endl;
					error_count++;
				}
	  		}
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE {
		  		$$ = new SymbolInfo("if ("+ $3->getName()+")"+$5->getName(), "statement");
				logout << "Line " << line_count << "\:"  <<" statement : IF LPAREN expression RPAREN statement" << endl << endl;
				logout << $$->getName() <<  endl << endl;

				if($3->getVarType() == "void"){
					logout << "Error at line "<< line_count << ": Void function used in expression" << endl << endl;
					errorout << "Error at line "<< line_count << ": Void function used in expression" << endl << endl;
					error_count++;
				}
	  		}
	  | IF LPAREN expression RPAREN statement ELSE statement {
		  		$$ = new SymbolInfo("if ("+ $3->getName()+")"+$5->getName()+"\nelse\n"+$7->getName(), "statement");
				logout << "Line " << line_count << "\:"  <<" statement : IF LPAREN expression RPAREN statement ELSE statement" << endl << endl;
				logout << $$->getName() <<  endl << endl;

				if($3->getVarType() == "void"){
					logout << "Error at line "<< line_count << ": Void function used in expression" << endl << endl;
					errorout << "Error at line "<< line_count << ": Void function used in expression" << endl << endl;
					error_count++;
				}
	  		}
	  | WHILE LPAREN expression RPAREN statement {
		  		$$ = new SymbolInfo("while ("+ $3->getName()+")"+$5->getName(), "statement");
				logout << "Line " << line_count << "\:"  <<" statement : WHILE LPAREN expression RPAREN statement" << endl << endl;
				logout << $$->getName() <<  endl << endl;

				if($3->getVarType() == "void"){
					logout << "Error at line "<< line_count << ": Void function used in expression" << endl << endl;
					errorout << "Error at line "<< line_count << ": Void function used in expression" << endl << endl;
					error_count++;
				}
	  		}
	  | PRINTLN LPAREN ID RPAREN SEMICOLON {
		  		$$ = new SymbolInfo("printf("+ $3->getName()+");\n", "statement");
				logout << "Line " << line_count << "\:"  <<" statement : PRINTLN LPAREN ID RPAREN SEMICOLON" << endl << endl;
				logout << $$->getName() <<  endl << endl;

				SymbolInfo *temp = sb->LookUp($3->getName());

				if(temp == nullptr){
					logout << "Error at line " << line_count << ": Undeclared variable " << $3->getName() << endl << endl;
					errorout << "Error at line " << line_count << ": Undeclared variable " << $3->getName() << endl << endl;
					error_count++;
				}
	  		}
	  | RETURN expression SEMICOLON {
			    $$ = new SymbolInfo("return "+ $2->getName()+";\n", "statement");
				logout << "Line " << line_count << "\:"  <<" statement : RETURN expression SEMICOLON" << endl << endl;
				logout << $$->getName() <<  endl << endl;

				if($2->getVarType() == "void"){
					logout << "Error at line "<< line_count << ": Void function used in expression" << endl << endl;
					errorout << "Error at line "<< line_count << ": Void function used in expression" << endl << endl;
					error_count++;
				}
		    }
	  ;

expression_statement : SEMICOLON	{
				$$ = new SymbolInfo(";", "expression_statement");
				logout << "Line " << line_count << "\:"  <<" expression_statement : SEMICOLON"<< endl << endl;
				logout << $$->getName() <<  endl << endl ;
		    }		
			| expression SEMICOLON {
			    $$ = new SymbolInfo($1->getName()+";", "expression_statement");
				logout << "Line " << line_count << "\:"  <<" expression_statement : expression SEMICOLON" << endl << endl;
				logout << $$->getName() <<  endl << endl << endl;
		    }
			;

variable : ID {
				$$ = new SymbolInfo($1->getName(), "variable");
				logout << "Line " << line_count << "\:"  <<" variable : ID"<< endl << endl;
				logout << $$->getName() <<  endl << endl;
 
				SymbolInfo *temp = sb->LookUp($1->getName());

				if(temp == nullptr){
					logout << "Error at line " << line_count << ": Undeclared variable " << $1->getName() << endl << endl;
					errorout << "Error at line " << line_count << ": Undeclared variable " << $1->getName() << endl << endl;
					error_count++;
				}
				else if(temp->getArr()){
					logout << "Error at line " << line_count << ": Type mismatch, "<< $1->getName() <<" is an array" <<endl << endl;
					errorout << "Error at line " << line_count << ": Type mismatch, "<< $1->getName() <<" is an array" <<endl << endl;
					error_count++;
					$$->setVarType(temp->getVarType());
				}
				else{
					$$->setVarType(temp->getVarType());
				}
		    }		
	 | ID LTHIRD expression RTHIRD {
			    $$ = new SymbolInfo($1->getName()+"["+ $3->getName()+"]", "variable");
				logout << "Line " << line_count << "\:"  <<" variable : ID LTHIRD expression RTHIRD" << endl << endl;
				logout << $$->getName() <<  endl << endl;

				SymbolInfo *temp = sb->LookUp($1->getName());

				if(temp == nullptr){
					logout << "Error at line " << line_count << ": Undeclared variable " << $1->getName() << endl << endl;
					errorout << "Error at line " << line_count << ": Undeclared variable " << $1->getName() << endl << endl;
					error_count++;
				}
				else if(!temp->getArr()){
					logout << "Error at line " << line_count <<"\: "<< $1->getName() << " not an array" << endl << endl;
					errorout << "Error at line " << line_count <<"\: "<< $1->getName() << " not an array" << endl << endl;
					error_count++;
				}
				else{
					$$->setVarType(temp->getVarType());
				}

				if($3->getVarType() == "void"){
					logout << "Error at line "<< line_count << ": Void function used in expression" << endl << endl;
					errorout << "Error at line "<< line_count << ": Void function used in expression" << endl << endl;
					error_count++;
				}
				
				if($3->getVarType() != "int"){
					logout << "Error at line "<< line_count << ": Expression inside third brackets not an integer" << endl << endl;
					errorout << "Error at line "<< line_count << ": Expression inside third brackets not an integer" << endl << endl;
					error_count++;
				}

		    }
	 ;
	 
expression : logic_expression	{
				$$ = new SymbolInfo($1->getName(), "expression");
				logout << "Line " << line_count << "\:"  <<" expression : logic_expression"<< endl << endl;
				logout << $$->getName() <<  endl << endl;
				$$->setVarType($1->getVarType());
		    }
	   | variable ASSIGNOP logic_expression {
			    $$ = new SymbolInfo($1->getName()+ $2->getName()+$3->getName(), "expression");
				logout << "Line " << line_count << "\:"  <<" expression : variable ASSIGNOP logic_expression" << endl << endl;
				logout << $$->getName() <<  endl << endl;
				
				if($3->getVarType() == "void" ){
					logout << "Error at line "<< line_count << ": Void function used in expression" << endl << endl;
					errorout << "Error at line "<< line_count << ": Void function used in expression" << endl << endl;
					error_count++;
				}
				else if(($1->getVarType() != $3->getVarType()) && ($3->getVarType() != "") && ($1->getVarType() != "")){
					if($1->getVarType() != "float" && $3->getVarType() != "int" ){
						logout << "Error at line "<< line_count << ": Type Mismatch" << endl << endl;
						errorout << "Error at line "<< line_count << ": Type Mismatch" << endl << endl;
						error_count++;
					}
				}
				$$->setVarType($1->getVarType());
		    }	
	   ;
			
logic_expression : rel_expression 	{
				$$ = new SymbolInfo($1->getName(), "logic_expression");
				logout << "Line " << line_count << "\:"  <<" logic_expression : rel_expression" << endl << endl;
				logout << $$->getName() <<  endl << endl;
				$$->setVarType($1->getVarType());
		    }
		 | rel_expression LOGICOP rel_expression 	{
			    $$ = new SymbolInfo($1->getName()+ $2->getName()+$3->getName(), "logic_expression");
				logout << "Line " << line_count << "\:"  <<" logic_expression : rel_expression LOGICOP rel_expression" << endl << endl;
				logout << $$->getName() <<  endl << endl;
				if($1->getVarType() == "void" || $3->getVarType() == "void"){
					logout << "Error at line "<< line_count << ": Void function used in expression" << endl << endl;
					errorout << "Error at line "<< line_count << ": Void function used in expression" << endl << endl;
					error_count++;
				}
				$$->setVarType("int");
		    }
		 ;
			
rel_expression	: simple_expression {
				$$ = new SymbolInfo($1->getName(), "rel_expression");
				logout << "Line " << line_count << "\:"  <<" rel_expression : simple_expression" << endl << endl;
				logout << $$->getName() <<  endl << endl;
				$$->setVarType($1->getVarType());
		    }
		| simple_expression RELOP simple_expression	 {
			    $$ = new SymbolInfo($1->getName()+ $2->getName()+$3->getName(), "rel_expression");
				logout << "Line " << line_count << "\:"  <<" rel_expression : simple_expression RELOP simple_expression" << endl << endl;
				logout << $$->getName() <<  endl << endl;
				if($1->getVarType() == "void" || $3->getVarType() == "void"){
					logout << "Error at line "<< line_count << ": Void function used in expression" << endl << endl;
					errorout << "Error at line "<< line_count << ": Void function used in expression" << endl << endl;
					error_count++;
				}

				$$->setVarType("int");
		    }
		;
				
simple_expression : term {
				$$ = new SymbolInfo($1->getName(), "simple_expression");
				logout << "Line " << line_count << "\:"  <<" simple_expression : term" << endl << endl;
				logout << $$->getName() <<  endl << endl;
				$$->setVarType($1->getVarType());
		    }
		  | simple_expression ADDOP term  {
			    $$ = new SymbolInfo($1->getName()+ $2->getName()+$3->getName(), "simple_expression");
				logout << "Line " << line_count << "\:"  <<" simple_expression : simple_expression ADDOP term" << endl << endl;
				logout << $$->getName() <<  endl << endl;

				if($1->getVarType() == "void" || $3->getVarType() == "void"){
					logout << "Error at line "<< line_count << ": Void function used in expression" << endl << endl;
					errorout << "Error at line "<< line_count << ": Void function used in expression" << endl << endl;
					error_count++;
				}
				else if($1->getVarType() == "float" || $3->getVarType() == "float"){
					$$->setVarType("float");
				}
				else $$->setVarType("int");
		    }
		  ;
					
term :	unary_expression {
			$$ = new SymbolInfo($1->getName(), "term");
			logout << "Line " << line_count << "\:"  <<" term : unary_expression" << endl << endl;
			logout << $$->getName() <<  endl << endl;
			$$->setVarType($1->getVarType());
		}
     |  term MULOP unary_expression {
			$$ = new SymbolInfo($1->getName()+ $2->getName()+$3->getName(), "term");
			logout << "Line " << line_count << "\:"  <<" term : term MULOP unary_expression" << endl << endl;
			logout << $$->getName() <<  endl << endl;

			if($3->getName() == "0" && $2->getName() == "%"){
				 logout << "Error at line "<< line_count << ": Modulus by Zero" << endl << endl;
				 errorout << "Error at line "<< line_count << ": Modulus by Zero" << endl << endl;
				 error_count++;
			}
			if($2->getName() == "%"){
				if($1->getVarType() != "int" || $3->getVarType() != "int" ){
					logout << "Error at line "<< line_count << ": Non-Integer operand on modulus operator" << endl << endl;
				 errorout << "Error at line "<< line_count << ": Non-Integer operand on modulus operator" << endl << endl;
				 error_count++;
				}
			}
			if($1->getVarType() == "void" || $3->getVarType() == "void"){
				logout << "Error at line "<< line_count << ": Void function used in expression" << endl << endl;
				errorout << "Error at line "<< line_count << ": Void function used in expression" << endl << endl;
				error_count++;
			}
			else if($1->getVarType() == "float" || $3->getVarType() == "float" ){
				$$->setVarType("float");
			}
			else $$->setVarType("int");
			
			if($2->getName() == "%"){
				$$->setVarType("int");
			}
		}
     ;

unary_expression : ADDOP unary_expression  {
			$$ = new SymbolInfo($1->getName()+$2->getName(), "unary_expression");
			logout << "Line " << line_count << "\:"  <<" unary_expression : ADDOP unary_expression" << endl << endl;
			logout << $$->getName() <<  endl << endl;
			if($2->getVarType() == "void"){
				logout << "Error at line "<< line_count << ": Void function used in expression" << endl << endl;
				errorout << "Error at line "<< line_count << ": Void function used in expression" << endl << endl;
				error_count++;
			}
			else $$->setVarType($2->getVarType());
		}
		| NOT unary_expression {
			$$ = new SymbolInfo("!" +$2->getName(), "unary_expression");
			logout << "Line " << line_count << "\:"  <<" unary_expression : NOT unary_expression" << endl << endl;
			logout << $$->getName() <<  endl << endl;
			if($2->getVarType() == "void"){
				logout << "Error at line "<< line_count << ": Void function used in expression" << endl << endl;
				errorout << "Error at line "<< line_count << ": Void function used in expression" << endl << endl;
				error_count++;
			}
			else $$->setVarType("int");
		}
	    | factor {
			$$ = new SymbolInfo($1->getName(), "unary_expression");
			logout << "Line " << line_count << "\:"  <<" unary_expression : factor" << endl << endl;
			logout << $$->getName() <<  endl << endl;
			$$->setVarType($1->getVarType());
		}
		;
	
factor	: variable {
			$$ = new SymbolInfo($1->getName(), "factor");
			logout << "Line " << line_count << "\:"  <<" factor : variable" << endl << endl;
			logout << $$->getName() <<  endl << endl;
			$$->setVarType($1->getVarType());
		}
	| ID LPAREN argument_list RPAREN {
			$$ = new SymbolInfo($1->getName()+"("+$3->getName()+")", "factor");
			logout << "Line " << line_count << "\:"  <<" factor : ID LPAREN argument_list RPAREN" << endl << endl;
			logout << $$->getName() <<  endl << endl;
			
			SymbolInfo *check = sb->LookUp($1->getName());
			if(check != nullptr && check->getFunc() && check->getDef()){
				if(arg_list.size() == check->getparamSize()){
					for(int i = 0; i < arg_list.size(); i++){
						if(arg_list[i] !=  check->getParam(i)){
							if(arg_list[i] != "int" && check->getParam(i) != "float"){
								logout << "Error at line "<< line_count << "\: " << i+1 << "th argument mismatch in function " << $1->getName()<< endl << endl;
								errorout << "Error at line "<< line_count << "\: " << i+1 << "th argument mismatch in function " << $1->getName()<< endl << endl;
								error_count++;
								break;
							}
						}	
					}
				}
				else{
					logout << "Error at line "<< line_count << "\: Total number of arguments mismatch in function " << $1->getName()<< endl << endl;
					errorout << "Error at line "<< line_count << "\: Total number of arguments mismatch in function " << $1->getName()<< endl << endl;
					error_count++;
				}
				$$->setVarType(check->getVarType());
			}
			else if(check != nullptr && check->getFunc() && !check->getDef()){
					logout << "Error at line "<< line_count << "\: Undefined function " << $1->getName() << endl << endl;
					errorout << "Error at line "<< line_count << "\: Undefined function " << $1->getName() << endl << endl;
					error_count++;
					$$->setVarType(check->getVarType());
			}
			else if(check != nullptr && !check->getFunc()){
				logout << "Error at line "<< line_count << "\: " << $1->getName() << " cannot be used as a function" << endl << endl;
				errorout << "Error at line "<< line_count << "\: " << $1->getName() << " cannot be used as a function" << endl << endl;
				error_count++;
			}
			else if(check == nullptr){
				logout << "Error at line "<< line_count << "\: Undeclared function " << $1->getName() << endl << endl;
				errorout << "Error at line "<< line_count << "\: Undeclared function " << $1->getName() << endl << endl;
				error_count++;
			}
			arg_list.clear();
		}
	| LPAREN expression RPAREN {
			$$ = new SymbolInfo("("+$2->getName()+")", "factor");
			logout << "Line " << line_count << "\:"  <<" factor : LPAREN expression RPAREN" << endl << endl;
			logout << $$->getName() <<  endl << endl;
			if($2->getVarType() == "void"){
				logout << "Error at line "<< line_count << ": Void function used in expression" << endl << endl;
				errorout << "Error at line "<< line_count << ": Void function used in expression" << endl << endl;
				error_count++;
			}
			else 
				$$->setVarType($2->getVarType());
		}
	| CONST_INT {
			$$ = new SymbolInfo($1->getName(), "factor");
			logout << "Line " << line_count << "\:"  <<" factor : CONST_INT" << endl << endl;
			logout << $$->getName() <<  endl << endl;
			$$->setVarType("int");
		}
	| CONST_FLOAT {
			$$ = new SymbolInfo($1->getName(), "factor");
			logout << "Line " << line_count << "\:"  <<" factor : CONST_FLOAT" << endl << endl;
			logout << $$->getName() <<  endl << endl;
			$$->setVarType("float");
		}
	| variable INCOP {
			$$ = new SymbolInfo($1->getName()+"++", "factor");
			logout << "Line " << line_count << "\:"  <<" factor : variable INCOP" << endl << endl;
			logout << $$->getName() <<  endl << endl;
			$$->setVarType($1->getVarType());
		}
	| variable DECOP {
			$$ = new SymbolInfo($1->getName()+"--", "factor");
			logout << "Line " << line_count << "\:"  <<" factor : variable DECOP" << endl << endl;
			logout << $$->getName() <<  endl << endl;
			$$->setVarType($1->getVarType());
		}
	;
	
argument_list : arguments {
					$$ = new SymbolInfo($1->getName(), "argument_list");
					logout << "Line " << line_count << "\:"  <<" argument_list : arguments" << endl << endl;
					logout << $$->getName() <<  endl << endl;
				}
			  |{
				  $$ = new SymbolInfo("", "argument_list");
				  logout << "Line " << line_count << "\:"  <<" argument_list :" << endl << endl;
			  }
			  ;
	
arguments : arguments COMMA logic_expression{
				$$ = new SymbolInfo($1->getName() +","+$3->getName(), "arguments");
				logout << "Line " << line_count  << "\:"  <<" arguments : arguments COMMA logic_expression" << endl << endl;
				logout << $$->getName() <<  endl << endl;
				arg_list.push_back($3->getVarType());
		  }
	      | logic_expression{
			    $$ = new SymbolInfo($1->getName(), "arguments");
				logout << "Line " << line_count  << "\:"  <<" arguments : logic_expression" << endl << endl;
				logout << $$->getName() <<  endl << endl;
				arg_list.push_back($1->getVarType());
		  }
	      ;
 	  
%%

int main(int argc,char *argv[])
{

	if(argc!=2) {
		cout << "Please provide input file name and try again\n";
		return 0;
	}

	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL) {
		cout << "Cannot open specified file\n";
		return 0;
	}

	yyin = fin;

	logout.open("log.txt");
	errorout.open("error.txt");
	

	yyparse();

	fclose(yyin);
	logout.close();
	errorout.close();
	
	return 0;
}