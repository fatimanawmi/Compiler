#include "1705093.h"
using namespace std;

SymbolInfo::SymbolInfo(){}
SymbolInfo::SymbolInfo(string name, string type){
    this->name = name;
    this->type = type;
    next = nullptr;
    VarType = "";
    arr = false;
    arr_size = -1;
    isFunc = false;
    func_dec = false;
    func_def = false;
    paramSize = -1;
}
void SymbolInfo::setName(string name){
    this->name = name;
}
string SymbolInfo::getName(){
    return name;
}
void SymbolInfo::setVarType(string VarType){
    this->VarType = VarType;
}
string SymbolInfo::getVarType(){
    return VarType;
}
void SymbolInfo::setType(string type){
    this->type = type;
}
string SymbolInfo::getType(){
    return type;
}
SymbolInfo* SymbolInfo::getNext(){
    return next;
}
void SymbolInfo::setNext(SymbolInfo* next){
    this->next = next;
}
void SymbolInfo::setArr(bool arr){
    this->arr = arr;
}
bool SymbolInfo::getArr(){
    return arr;
}
void SymbolInfo::setSize(int arr_size){
    this->arr_size = arr_size;
}
int SymbolInfo::getSize(){
    return arr_size;
}
int SymbolInfo::getparamSize(){
    if(paramSize == -1){
        return 0;
    }
    else return paramSize;
}
void SymbolInfo::setParam(string name, string type){
    param.push_back(make_pair(name, type));
    if(paramSize == -1) paramSize = 1;
    else paramSize++;
}
string SymbolInfo::getParam(int pos){
    return param[pos].second;
}
string SymbolInfo::getParamName(int pos){
    return param[pos].first;
}
void SymbolInfo::setFunc(bool isFunc){
    this->isFunc = isFunc;
}
bool SymbolInfo::getFunc(){
    return isFunc;
}
void SymbolInfo::setDec(bool func_dec){
    this->func_dec = func_dec;
}
bool SymbolInfo::getDec(){
    return func_dec;
}
void SymbolInfo::setDef(bool func_def){
    this->func_def = func_def;
}
bool SymbolInfo::getDef(){
    return func_def;
}
SymbolInfo::~SymbolInfo(){
    param.clear();
}

//==================================================================================================================

ScopeTable::ScopeTable(int n){
    total_buckets = n;
    parentScope = nullptr;
    Arr = new SymbolInfo*[total_buckets];
    for(int i = 0 ; i < total_buckets; i++){
       Arr[i] = nullptr;
    }
    currentScopeNum = 0;
}
int ScopeTable::getCurrentScopeNum(){ return currentScopeNum ;}
void ScopeTable::incCurrentScopeNum(){ currentScopeNum++;}
ScopeTable* ScopeTable::getparentScope(){ return parentScope; }
void ScopeTable::setparentScope(ScopeTable* parent){
    parentScope = parent;
}
void ScopeTable::setId(string i){
    if(parentScope != nullptr)
        id = parentScope->getId() + "." + i;
    else
        id = i;
}
string ScopeTable::getId(){ return id; }
bool ScopeTable::Insert(string name, string type){
    int index = hash_func(name);
    if(Arr[index] == nullptr){
        SymbolInfo* curr = new SymbolInfo(name, type);
        curr->setNext(nullptr);
        Arr[index] = curr;
        int pos = 0;
       /// cout <<"Inserted in ScopeTable# " << id << " at position "<< index << "," << pos << endl;
        return true;
    }
    else{
        SymbolInfo* temp = Arr[index];
        SymbolInfo* prev;
        int pos = 0;
        while(temp != nullptr){
            if(temp->getName() == name){
               // cout << "< " << temp->getName() << " : " << temp->getType() << " > already exists in current ScopeTable" << endl;
                return false;
            }
            prev = temp;
            temp = temp->getNext();
            pos++;
        }
        if(temp == nullptr){
            SymbolInfo* curr = new SymbolInfo(name, type);
            curr->setNext(nullptr);
            prev->setNext(curr);
           /// cout <<"Inserted in ScopeTable# " << id << " at position "<< index << "," << pos << endl;
            return true;
        }
        else return false;

    }
}
bool ScopeTable::Insert(SymbolInfo* sb){
    int index = hash_func(sb->getName());
    if(Arr[index] == nullptr){
        sb->setNext(nullptr);
        Arr[index] = sb;
        return true;
    }
    else{
        SymbolInfo* temp = Arr[index];
        SymbolInfo* prev;
        int pos = 0;
        while(temp != nullptr){
            if(temp->getName() == sb->getName()){
                return false;
            }
            prev = temp;
            temp = temp->getNext();
            pos++;
        }
        if(temp == nullptr){
            sb->setNext(nullptr);
            prev->setNext(sb);
            return true;
        }
        else return false;
    }
}
SymbolInfo* ScopeTable::LookUp(string name){
    int index = hash_func(name);
    if(Arr[index] == nullptr){
        return nullptr;
    }
    else{
        SymbolInfo* temp = Arr[index];
        int pos = 0;
        while(temp != nullptr){
            if(temp->getName() == name){
                //cout << "Found in ScopeTable# " << id <<" at position "<< index << "," << pos << endl;
                return temp;
            }
            pos++;
            temp = temp->getNext();
        }
        return nullptr;
    }

}
bool ScopeTable::Delete(string name){
    int index = hash_func(name);
    if(Arr[index] == nullptr){
        //cout <<"Not found"<<endl;
        return false;
    }
    else{
        SymbolInfo* temp = Arr[index];
        SymbolInfo* prev = nullptr;
        int pos = 0;
        while(temp != nullptr){
            if(temp->getName() == name){
               /// cout << "Found in ScopeTable# " << id <<" at position "<< index << "," << pos << endl;
               /// cout << "Deleted Entry "<< index << "," << pos <<" from current ScopeTable" <<endl;
                if(prev != nullptr && temp->getNext()!= nullptr){
                    prev->setNext(temp->getNext());
                }
                else if(prev == nullptr && temp->getNext()!= nullptr){
                    Arr[index] = temp->getNext();
                }
                else if(prev == nullptr && temp->getNext()== nullptr){
                    Arr[index] = nullptr;
                }
                else if(prev != nullptr && temp->getNext()== nullptr){
                    prev->setNext(nullptr);
                }
                delete temp;
                return true;
            }
            pos++;
            prev = temp;
            temp = temp->getNext();
        }
        //cout <<"Not found"<<endl;
        return false;
    }

}
void ScopeTable::Print(ofstream &logout){
    logout << endl;
    logout << "ScopeTable # " << id << endl;
    for(int i = 0; i < total_buckets; i++){
        if(Arr[i] != nullptr){
            logout << " " <<i << " --> ";
            logout << "< " << Arr[i]->getName() << " , " << Arr[i]->getType() << " > ";
            if(Arr[i]->getNext() != nullptr){
                SymbolInfo* temp = Arr[i]->getNext();
                int pos = 0;
                while(temp != nullptr){
                    logout << "< " << temp->getName() << " , " << temp->getType() << " > ";
                    temp = temp->getNext();
                }
            }
            logout << endl;
        }
        
    }
    logout << endl << endl;
}
int ScopeTable::hash_func(string str){
        unsigned int sum = 0;
        for(int i = 0 ; i < str.size(); i++){
            sum += str[i];
        }
        return (sum % total_buckets);
}
ScopeTable::~ScopeTable(){
    parentScope = nullptr;
    for(int i = 0 ; i < total_buckets; i++){
        if(Arr[i] == nullptr)
            delete Arr[i];
        else{
            SymbolInfo* temp = Arr[i]->getNext();
            SymbolInfo* del;
            delete Arr[i];
            while(temp != nullptr){
                del = temp;
                temp = temp->getNext();
                delete del;
            }
        }
    }
}

//==================================================================================================================

SymbolTable::SymbolTable(int n){
    int scopeNum = 1;
    currentScope = new ScopeTable(n);
    currentScope->setId(to_string(scopeNum));
    shape = n;
}
void SymbolTable::EnterScope(ofstream &logout){
    ScopeTable* newScope = new ScopeTable(shape);
    newScope->setparentScope(currentScope);
    currentScope->incCurrentScopeNum();
    int scopeNum = currentScope->getCurrentScopeNum();
    newScope->setId(to_string(scopeNum));
    currentScope = newScope;
    //logout << "New ScopeTable with id " << currentScope->getId() << " created"<< endl;
}
void SymbolTable::ExitScope(ofstream &logout){
    ScopeTable* temp;
    temp = currentScope;
    currentScope = temp->getparentScope();
    //logout << "ScopeTable with id " << temp->getId() << " removed" << endl;
    delete temp;
}
bool SymbolTable::Insert(string name, string type){
    if(currentScope->Insert(name, type)){
        return true;
    }
    else return false;
}
bool SymbolTable::Insert(SymbolInfo* sb){
    if(currentScope->Insert(sb)){
        return true;
    }
    else return false;
}
bool SymbolTable::Remove(string name){
    if(currentScope->Delete(name)) return true;
    return false;
}
SymbolInfo* SymbolTable::LookUp(string name){
    ScopeTable* temp = currentScope;
    SymbolInfo* check ;
    while(temp != nullptr ){
        check = temp->LookUp(name) ;
        if( check != nullptr){
            return check;
        }
        temp = temp->getparentScope();
    }
    //cout << "Not Found" << endl;
    return nullptr;
}
SymbolInfo* SymbolTable::LookUpCur(string name){
    if(currentScope != nullptr){
        return currentScope->LookUp(name);
    }
    return nullptr;
}
void SymbolTable::Print_C(ofstream &logout){
    currentScope->Print(logout);
}
void SymbolTable::Print_A(ofstream &logout){
    ScopeTable* temp = currentScope;
    while(temp != nullptr ){
        temp->Print(logout);
        temp = temp->getparentScope();
    }
}
SymbolTable::~SymbolTable(){
    ScopeTable* del;
    ScopeTable* temp = currentScope;
    while(temp != nullptr ){
        del = temp;
        temp = temp->getparentScope();
        delete del;
    }
}

