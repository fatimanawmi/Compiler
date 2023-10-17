%{
#include <bits/stdc++.h>
#include "1705093.h"
#define YYSTYPE SymbolInfo*
using namespace std;

SymbolTable *sb = new SymbolTable(30);
ofstream logout, errorout, code, optimized_code;
SymbolInfo *dec_list = nullptr;
vector<pair<string, string>> param_list ;
vector<string> param_list_assembly ;
vector<string>arg_list;
vector<string>arg_list_assembly ;
vector<string>data_segment;
vector<string>code_line;
int yyparse(void);
int yylex(void);
int labelCount = 0;
int tempCount = 0;
int retcount = 0;
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
string newLabel(){
	string lbl = "L"+to_string(labelCount);
	labelCount++;
	return lbl;
}
string newTemp(){
	string t = "T"+to_string(tempCount);
	tempCount++;
	return t;
}

void splitFunc(string code){
	code_line.clear();
	stringstream split(code);
    string temp;
	while(getline(split, temp, '\n')) {
        if(temp != "" && temp[0] != ';')
            code_line.push_back(temp);
    }
}

void optimize(string code){
	string optimized = "";
	int newline1 = -1, newline2 = -1;
	for(int i = 0 ; i < code_line.size(); i++){
		if(i == code_line.size()-1){
			break;
		}
		if(code_line[i] == code_line[i+1]){
			 code_line.erase(code_line.begin()+i+1);
             if(i == code_line.size()-1)
				break;
		}
		if(code_line[i].substr(0, 4) == "MOV " && code_line[i+1].substr(0, 4) == "MOV " ){
			if(code_line[i].substr(code_line[i].find(",")+1,code_line[i].length()-1-code_line[i].find(",")) == code_line[i+1].substr(4, code_line[i+1].find(",")-4)){
				if(code_line[i+1].substr(code_line[i+1].find(",")+1,code_line[i+1].length()-1-code_line[i+1].find(",")) == code_line[i].substr(4, code_line[i].find(",")-4)){
					code_line.erase(code_line.begin()+i+1);
					i--;
				}
			}
		}
	}
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
				   logout << "Total lines: " << line_count << endl;
				   logout << "Total errors: " << error_count << endl;

				   if(error_count == 0){
					    string code_ =".MODEL SMALL\n.STACK 100H\n.DATA\n";

						string data = "RET_VAR DW ?\n";
						for(int i = 0 ; i < data_segment.size(); i++){
							data += data_segment[i] ;
						}

						code_ += data;
						code_ += "\n.CODE\n\n";
						code_ += $1->getCode();

						string printFunc = "";
						printFunc += "OUTPUT PROC\n\n;PRINTS ANS\nPUSH BX\nPUSH CX\nPUSH DX\n\nMOV BX, AX  ; SAVE AX IN BX\n";
						printFunc += "MOV AX, BX  ; SHIFT BACK BX IN AX\nCMP AX , 0  ; AX < 0?\nJGE POS     ; NO, AX > 0\n";
						printFunc += "; YES, AX < 0\nPUSH AX        ; PRESERVE AX\nMOV DL, '-'\n MOV AH, 2      ;PRINT -\n";
						printFunc += "INT 21H \nPOP AX\nNEG AX         ; NEGATE AX\n\nPOS:\nXOR CX, CX  ; COUNTER\nMOV BX, 10D ; DIVISOR\n"; 
						printFunc += "\nLOOP_:\nXOR DX, DX  ; CLEAR DX\nDIV BX\nPUSH DX\nINC CX\nCMP AX,0\nJNE LOOP_\n\n;CONVERT TO DIGITS AND PRINT\n";
						printFunc += "MOV AH,2\n\nPRINT:\nPOP DX\nOR DL, 30H\nINT 21H\nLOOP PRINT\n\nMOV AH, 2\nMOV DL,0DH\nINT 21H\nMOV DL,0AH\nINT 21H\n;END\nPOP DX\nPOP CX\nPOP BX\nRET\nOUTPUT ENDP\n"; 

						code_ += printFunc;
						code_ += "END MAIN\n";

						code << code_ << endl;
						splitFunc(code_);
						optimize(code_);
						for (int i = 0 ; i < code_line.size(); i++){
							optimized_code << code_line[i] << endl;
						}
				   }
    
				}
	;

program : program unit {
					$$ = new SymbolInfo($1->getName()+ $2->getName(), "unit");
					logout << "Line " << line_count << "\:"  <<" program : program unit" << endl << endl;
					logout << $$->getName() <<  endl << endl ;

					$$->setCode($1->getCode() + $2->getCode() );
				}
	| unit { 	
				$$ = $1;
				logout << "Line " << line_count << "\:"  <<" program : unit" << endl << endl;
				logout << $$->getName() <<  endl << endl ;

				$$->setCode($1->getCode());
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

					 $$->setCode($1->getCode());
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
							bool flag = false;
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

					string func_body = "";

					if($2->getName() == "main"){
						func_body += "MAIN PROC\n;INIITIALISE DS\nMOV AX, @DATA\nMOV DS,AX\n";
						func_body += $7->getCode();
						func_body += "\n;END\nRETURN"+to_string(retcount)+":\nMOV AH, 4CH\nINT 21H\nMAIN ENDP\n";
					}
					else{
						int num = 4; 
						func_body += $2->getName()+ " PROC\n";
						func_body += "PUSH BP\nMOV BP, SP\n";
						for(int i = param_list_assembly.size()-1 ; i > -1; i--){
							 func_body += "MOV AX,[BP+" +to_string(num)+ "]\nMOV "+param_list_assembly[i]+",AX\n";
							 num = num + 2; 
						}
						func_body += $7->getCode();
						func_body += "\nRETURN"+to_string(retcount)+":\nPOP BP\n";
						func_body += "RET " + to_string(param_list_assembly.size()*2)+"\n";
						func_body += $2->getName()+" ENDP\n\n";
						retcount++;
					}

					$$->setCode(func_body);
					param_list_assembly.clear();

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

					string func_body = "";

					if($2->getName() == "main"){
						func_body += "MAIN PROC\n;INIITIALISE DS\nMOV AX, @DATA\nMOV DS,AX\n";
						func_body += $6->getCode();
						func_body += "\n;END\nRETURN"+to_string(retcount)+":\nMOV AH, 4CH\nINT 21H\nMAIN ENDP\n";
					}
					else{
						func_body += $2->getName()+ " PROC\n";
						func_body += $6->getCode();
						func_body += "\nRETURN"+to_string(retcount)+":\nRET\n";
						func_body += $2->getName()+" ENDP\n\n";
						retcount++;
					}

					$$->setCode(func_body);
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

						param_list_assembly.push_back(param_list[i].first+ sb->getCurrentID());

						data_segment.push_back(param_list[i].first+sb->getCurrentID()+" DW ?\n");

						SymbolInfo *temp = new SymbolInfo(param_list[i].first, "ID");
						temp->setVarType(param_list[i].second);
						temp->setmemName(param_list[i].first+sb->getCurrentID());
						sb->Insert(temp);
					}
					param_list.clear();
				}statements RCURL {
				$$ = new SymbolInfo("{\n" + $3->getName() + "}\n", "compound_statement");

				$$->setCode($3->getCode());
				
				logout << "Line " << line_count << "\:"  <<" compound_statement : LCURL statements RCURL" << endl << endl;
				logout << $$->getName() <<  endl << endl;
				sb->Print_A(logout);
				sb->ExitScope(logout);
			}
 		    | LCURL {
					sb->EnterScope(logout);
					for(int i = 0; i < param_list.size(); i++){

						param_list_assembly.push_back(param_list[i].first+ sb->getCurrentID());

						data_segment.push_back(param_list[i].first+sb->getCurrentID()+" DW ?\n");

						SymbolInfo *temp = new SymbolInfo(param_list[i].first, "ID");
						temp->setVarType(param_list[i].second);
						temp->setmemName(param_list[i].first+sb->getCurrentID());
						sb->Insert(temp);
					}
					param_list.clear();
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
								temp->setmemName(temp->getName()+sb->getCurrentID());
								sb->Insert(temp);

								if(temp->getSize() != -1){
									data_segment.push_back(temp->getName()+sb->getCurrentID()+" DW "+ to_string(temp->getSize())+" DUP (?)\n");
								}
								else{
									data_segment.push_back(temp->getName()+sb->getCurrentID()+" DW ?\n");
								}
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
				$$->setCode($1->getCode());
			}
	   | statements statement {
		   		$$ = new SymbolInfo($1->getName()+ $2->getName(), "statements");
				logout << "Line " << line_count << "\:"  <<" statements : statements statement" << endl << endl;
				logout << $$->getName() <<  endl << endl;
				$$->setCode($1->getCode()+$2->getCode());
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
				$$->setCode($1->getCode());
	  		}
	  | compound_statement {
		  		$$ = new SymbolInfo($1->getName(), "statement");
				logout << "Line " << line_count << "\:"  <<" statement : compound_statement" << endl << endl;
				logout << $$->getName() <<  endl << endl;
				$$->setCode($1->getCode());
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

				string code_ ="for("+ $3->getName()+$4->getName()+$5->getName()+")\n";
				string loop = newLabel();
				string end_loop = newLabel();

				if($4->getName() != ";"){
					code_ += $3->getCode()+ loop + ":\n"+$4->getCode()+"CMP "+$4->getmemName() +",0\nJE "+ end_loop + "\n"+$7->getCode()+ $5->getCode() + "JMP "+ loop + "\n"+ end_loop +":\n";
				}
				else{
					code_ += $3->getCode()+ loop + ":\n"+$7->getCode()+ $5->getCode() + "JMP "+ loop + "\n"+ end_loop +":\n";
				}
				$$->setCode(code_);

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

				string code_ = ";if ("+ $3->getName()+")\n";
				string exit_ = newLabel();
				code_ += $3->getCode()+"CMP "+$3->getmemName() +",0\nJE "+ exit_ + "\n"+$5->getCode() + exit_+":\n";
				$$->setCode(code_);
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

				string code_ = ";if ("+ $3->getName()+")\n";
				string exit_ = newLabel();
				string else_ = newLabel();
				code_ += $3->getCode()+"CMP "+$3->getmemName() +",0\nJE "+ else_ + "\n"+$5->getCode() + "JMP "+ exit_ + "\n"+ else_ +":\n"+$7->getCode()+exit_+":\n";
				$$->setCode(code_);
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

				string code_ = ";while ("+ $3->getName()+")\n";
				string loop = newLabel();
				string end_loop = newLabel();
				code_ += loop + ":\n"+$3->getCode()+"CMP "+$3->getmemName() +",0\nJE "+ end_loop + "\n"+$5->getCode() + "JMP "+ loop + "\n"+ end_loop +":\n";
				$$->setCode(code_);
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

				string code_ = ";"+$$->getName()+"\n";
				code_ += "MOV AX,"+temp->getmemName()+ "\nCALL OUTPUT\n";
				$$->setCode(code_);
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

				string code_ = "";
				code_ += $2->getCode();
				code_ += "MOV AX,"+ $2->getmemName()+"\nMOV RET_VAR,AX\nJMP RETURN"+to_string(retcount)+"\n";
				$$->setCode(code_);
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

				$$->setCode($1->getCode());
				$$->setmemName($1->getmemName());
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
					$$->setmemName(temp->getmemName());
					$$->setSize(temp->getSize());
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
					$$->setmemName(temp->getmemName());
					$$->setCode($3->getCode()+"MOV BX,"+$3->getmemName()+"\nADD BX, BX\n");
					$$->setSize(temp->getSize());
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

				$$->setCode($1->getCode());
				$$->setmemName($1->getmemName());
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

				string code_ = "";
				string temp = newTemp();
				data_segment.push_back(temp+ " DW ?\n");
				code_ += $3->getCode()+$1->getCode();
				code_ += ";"+$$->getName()+"\n";
				code_ += "MOV AX,"+ $3->getmemName()+"\n";
				
				if($1->getSize() != -1){
					code_ += "MOV "+ $1->getmemName() + "[BX],AX\n";
				}
				else code_ += "MOV "+ $1->getmemName() + ",AX\n";

				code_ += "MOV "+ temp + ",AX\n";

				$$->setCode(code_);
				$$->setmemName(temp); 
		    }	
	   ;
			
logic_expression : rel_expression 	{
				$$ = new SymbolInfo($1->getName(), "logic_expression");
				logout << "Line " << line_count << "\:"  <<" logic_expression : rel_expression" << endl << endl;
				logout << $$->getName() <<  endl << endl;
				$$->setVarType($1->getVarType());

				$$->setCode($1->getCode());
				$$->setmemName($1->getmemName());
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

				string code_ = "";
				code_ += $1->getCode()+$3->getCode();
				code_ += ";"+$$->getName()+"\n";
				string temp = newTemp();
				data_segment.push_back(temp+ " DW ?\n");
				string istrue = newLabel();
				string isfalse = newLabel();

				if($2->getName() == "&&"){
					code_ += "CMP "+$1->getmemName()+ ",0\nJE "+isfalse + "\nCMP "+$3->getmemName()+ ",0\nJE "+ isfalse;
					code_ += "\nMOV "+temp +",1\nJMP "+istrue +"\n"+isfalse+":\nMOV "+ temp +",0\n"+istrue + ":\n";
				}
				else if($2->getName() == "||"){
					code_ += "CMP "+$1->getmemName()+ ",1\nJE "+istrue + "\nCMP "+$3->getmemName()+ ",1\nJE "+ istrue;
					code_ += "\nMOV "+temp +",0\nJMP "+isfalse +"\n"+istrue+":\nMOV "+ temp +",1\n"+isfalse + ":\n";
				}
				$$->setCode(code_);
				$$->setmemName(temp); 
		    }
		 ;
			
rel_expression	: simple_expression {
				$$ = new SymbolInfo($1->getName(), "rel_expression");
				logout << "Line " << line_count << "\:"  <<" rel_expression : simple_expression" << endl << endl;
				logout << $$->getName() <<  endl << endl;
				$$->setVarType($1->getVarType());

				$$->setCode($1->getCode());
				$$->setmemName($1->getmemName());
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

				string code_ = "";
				code_ += $1->getCode()+$3->getCode();
				code_ += ";"+$$->getName()+"\n";
				string temp = newTemp();
				data_segment.push_back(temp+ " DW ?\n");
				string istrue = newLabel();
				string isfalse = newLabel();

				code_ +="MOV AX," + $1->getmemName()+"\nCMP AX," + $3->getmemName()+"\n";

				if($2->getName() == "<"){
					code_ += "JL " + istrue +"\n";
				}
				else if($2->getName() == "<="){
					code_ += "JLE " + istrue +"\n";
				}
				else if($2->getName() == ">"){
					code_ += "JG " + istrue +"\n";
				}
				else if($2->getName() == ">="){
					code_ += "JGE " + istrue +"\n";
				}
				else if($2->getName() == "=="){
					code_ += "JE " + istrue +"\n";
				}
				else if($2->getName() == "!="){
					code_ += "JNE " + istrue +"\n";
				}

				code_ += "MOV "+ temp +",0\nJMP "+ isfalse + "\n"+ istrue +":\nMOV "+ temp +",1\n" + isfalse + ":\n";

				$$->setCode(code_);
				$$->setmemName(temp);
		    }
		;
				
simple_expression : term {
				$$ = new SymbolInfo($1->getName(), "simple_expression");
				logout << "Line " << line_count << "\:"  <<" simple_expression : term" << endl << endl;
				logout << $$->getName() <<  endl << endl;
				$$->setVarType($1->getVarType());

				$$->setCode($1->getCode());
				$$->setmemName($1->getmemName());
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

				string code_ = "";
				code_ += $1->getCode()+$3->getCode();
				code_ += ";"+$$->getName()+"\n";
				string temp = newTemp();
				data_segment.push_back(temp+ " DW ?\n");


				if($2->getName() == "+"){
					code_ += "MOV AX,"+ $1->getmemName()+"\nADD AX,"+ $3->getmemName()+"\nMOV "+temp+",AX\n";
				}
				else if($2->getName() == "-"){
					code_ += "MOV AX,"+ $1->getmemName()+"\nSUB AX,"+ $3->getmemName()+"\nMOV "+temp+",AX\n";
				}
				$$->setCode(code_);
				$$->setmemName(temp);
			}
		  ;
					
term :	unary_expression {
			$$ = new SymbolInfo($1->getName(), "term");
			logout << "Line " << line_count << "\:"  <<" term : unary_expression" << endl << endl;
			logout << $$->getName() <<  endl << endl;
			$$->setVarType($1->getVarType());

			$$->setCode($1->getCode());
			$$->setmemName($1->getmemName());
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

			string code_ = "";
			code_ += $1->getCode()+$3->getCode();
			code_ += ";"+$$->getName()+"\n";
			string temp = newTemp();
			data_segment.push_back(temp+ " DW ?\n");


			if($2->getName() == "*"){
				code_ += "MOV AX,"+ $1->getmemName()+"\nMOV BX,"+ $3->getmemName()+"\nIMUL BX\nMOV "+temp+",AX\n";
			}
			else{
				code_ += "MOV AX,"+ $1->getmemName()+"\nCWD\nMOV BX,"+ $3->getmemName()+"\nIDIV BX\n";
				if($2->getName() == "/"){
					code_ += "MOV "+temp+",AX\n";
				}
				else if($2->getName() == "%"){
					code_ += "MOV "+temp+",DX\n";
				}
				
			}
			$$->setCode(code_);
			$$->setmemName(temp);
		}
     ;

unary_expression : ADDOP unary_expression  {
			$$ = new SymbolInfo($1->getName()+$2->getName(), "unary_expression");
			logout << "Line " << line_count << "\:"  <<" unary_expression : ADDOP unary_expression" << endl << endl;
			logout << $$->getName() <<  endl << endl;

			if($1->getName() == "+"){
				$$->setCode(";"+$$->getName()+"\n"+$2->getCode());
				$$->setmemName($2->getmemName());
			}
			else{
				string temp = newTemp();
				data_segment.push_back(temp+ " DW ?\n");
				string code_ = ";"+$$->getName()+"\n";
				code_ += $2->getCode();
				code_ += "MOV AX,"+$2->getmemName()+"\nNEG AX\nMOV "+temp+",AX\n";
				$$->setCode(code_);
				$$->setmemName(temp);
			}

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

			string temp = newTemp();
			data_segment.push_back(temp+ " DW ?\n");
			string isZero = newLabel();
			string done = newLabel();
			string code_ = ";"+$$->getName()+"\n";
			code_ += $2->getCode();
			code_ += "CMP "+$2->getmemName()+",0\nJE "+isZero +"\nMOV AX,0\nMOV "+$2->getmemName()+",AX\nJMP "+done+"\n";
			code_ += isZero + ":\nMOV AX,1\nMOV "+$2->getmemName()+",AX\n"+done+":\n";
			$$->setCode(code_);
			$$->setmemName(temp);

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

			$$->setCode($1->getCode());
			$$->setmemName($1->getmemName());
		}
		;
	
factor	: variable {
			$$ = new SymbolInfo($1->getName(), "variable");
			logout << "Line " << line_count << "\:"  <<" factor : variable" << endl << endl;
			logout << $$->getName() <<  endl << endl;
			$$->setVarType($1->getVarType());

			string code_ =  ";"+$$->getName()+"\n";
			string temp = newTemp();
			data_segment.push_back(temp+ " DW ?\n");
			code_ += $1->getCode();
			
			if($1->getSize() != -1){
				code_ += "MOV AX,"+ $1->getmemName() + "[BX]\n";
			}
			else code_ += "MOV AX,"+ $1->getmemName() + "\n";

			code_ += "MOV "+ temp + ",AX\n";

			$$->setCode(code_);
			$$->setmemName(temp); 
		}
	| ID LPAREN argument_list RPAREN {
			$$ = new SymbolInfo($1->getName()+"("+$3->getName()+")", "function");
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

				string code_ = "";
				code_ += $3->getCode();
				code_ += "PUSH AX\nPUSH BX\nPUSH CX\nPUSH DX\n";
				for(int i = 0; i <arg_list_assembly.size(); i++){
					code_ += "PUSH " + arg_list_assembly[i]+"\n" ;
				}
				code_ += "CALL "+ $1->getName()+"\n";
				string temp = newTemp();
				if(check->getVarType() != "void"){
					data_segment.push_back(temp+ " DW ?\n");
					code_ += "MOV AX,RET_VAR\nMOV "+temp +",AX\n";
				}
				code_ += "POP DX\nPOP CX\nPOP BX\nPOP AX\n";
				$$->setmemName(temp);
				$$->setCode(code_);

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
			arg_list_assembly.clear();
		}
	| LPAREN expression RPAREN {
			$$ = new SymbolInfo("("+$2->getName()+")", "variable");
			logout << "Line " << line_count << "\:"  <<" factor : LPAREN expression RPAREN" << endl << endl;
			logout << $$->getName() <<  endl << endl;

			$$->setmemName($2->getmemName());
            $$->setCode($2->getCode());

			if($2->getVarType() == "void"){
				logout << "Error at line "<< line_count << ": Void function used in expression" << endl << endl;
				errorout << "Error at line "<< line_count << ": Void function used in expression" << endl << endl;
				error_count++;
			}
			else{
				$$->setVarType($2->getVarType());
			}
		}
	| CONST_INT {
			$$ = new SymbolInfo($1->getName(), "CONST_INT");
			logout << "Line " << line_count << "\:"  <<" factor : CONST_INT" << endl << endl;
			logout << $$->getName() <<  endl << endl;
			$$->setVarType("int");
			$$->setmemName($1->getName());
		}
	| CONST_FLOAT {
			$$ = new SymbolInfo($1->getName(), "CONST_FLOAT");
			logout << "Line " << line_count << "\:"  <<" factor : CONST_FLOAT" << endl << endl;
			logout << $$->getName() <<  endl << endl;
			$$->setVarType("float");
			$$->setmemName($1->getName());
		}
	| variable INCOP {
			$$ = new SymbolInfo($1->getName()+"++", "variable");
			logout << "Line " << line_count << "\:"  <<" factor : variable INCOP" << endl << endl;
			logout << $$->getName() <<  endl << endl;

			$$->setVarType($1->getVarType());

			string temp = newTemp();
			data_segment.push_back(temp+ " DW ?\n");
			if($1->getSize() != -1){
				$$->setCode(";"+$$->getName()+"\n"+$1->getCode()+"MOV AX,"+ $1->getmemName()+"[BX]\nINC "+ $1->getmemName()+"[BX]\nMOV "+temp+",AX\n");
			}
			else{
				$$->setCode(";"+$$->getName()+"\n"+$1->getCode()+"MOV AX,"+ $1->getmemName()+"\nMOV "+temp+",AX\nINC "+$1->getmemName()+"\n");
			}
			$$->setmemName(temp);
		}
	| variable DECOP {
			$$ = new SymbolInfo($1->getName()+"--", "variable");
			logout << "Line " << line_count << "\:"  <<" factor : variable DECOP" << endl << endl;
			logout << $$->getName() <<  endl << endl;

			$$->setVarType($1->getVarType());

			string temp = newTemp();
			data_segment.push_back(temp+ " DW ?\n");
			if($1->getSize() != -1){
				$$->setCode(";"+$$->getName()+"\n"+$1->getCode()+"MOV AX,"+ $1->getmemName()+"[BX]\nDEC "+ $1->getmemName()+"[BX]\nMOV "+temp+",AX\n");
			}
			else{
				$$->setCode(";"+$$->getName()+"\n"+$1->getCode()+"MOV AX,"+ $1->getmemName()+"\nMOV "+temp+",AX\nDEC "+$1->getmemName()+"\n");
			}
			$$->setmemName(temp);
		}
	;
	
argument_list : arguments {
					$$ = new SymbolInfo($1->getName(), "argument_list");
					logout << "Line " << line_count << "\:"  <<" argument_list : arguments" << endl << endl;
					logout << $$->getName() <<  endl << endl;
					$$->setCode($1->getCode());
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

				$$->setCode($1->getCode()+$3->getCode());
				arg_list_assembly.push_back($3->getmemName());
		  }
	      | logic_expression{
			    $$ = new SymbolInfo($1->getName(), "arguments");
				logout << "Line " << line_count  << "\:"  <<" arguments : logic_expression" << endl << endl;
				logout << $$->getName() <<  endl << endl;
				arg_list.push_back($1->getVarType());

				$$->setCode($1->getCode());
				arg_list_assembly.push_back($1->getmemName());
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
	code.open("code.asm");
	optimized_code.open("optimized_code.asm");

	yyparse();

	fclose(yyin);
	logout.close();
	errorout.close();
	code.close();
	optimized_code.close();

	return 0;
}