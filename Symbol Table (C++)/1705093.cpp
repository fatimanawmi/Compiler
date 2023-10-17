#include <bits/stdc++.h>

using namespace std;

class SymbolInfo{
    string name;
    string type;
    SymbolInfo *next;
public:
    SymbolInfo();
    SymbolInfo(string name,string type);
    void setName(string name);
    string getName();
    void setType(string type);
    string getType();
    SymbolInfo* getNext();
    void setNext(SymbolInfo* next);
    ~SymbolInfo();
};
SymbolInfo::SymbolInfo(){}
SymbolInfo::SymbolInfo(string name, string type){
    this->name = name;
    this->type = type;
    next = nullptr;
}
void SymbolInfo::setName(string name){
    this->name = name;
}
string SymbolInfo::getName(){
    return name;
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
SymbolInfo::~SymbolInfo(){

}
//==================================================================================================================
class ScopeTable{
    int total_buckets;
    string id;
    SymbolInfo **Arr;
    ScopeTable *parentScope;
    int currentScopeNum;
    int hash_func(string str);
public:
    string getId();
    ScopeTable(int n);
    int getCurrentScopeNum();
    void incCurrentScopeNum();
    ScopeTable* getparentScope();
    void setparentScope(ScopeTable* parent);
    void setId(string i);
    bool Insert(string name, string type);
    SymbolInfo* LookUp(string name);
    bool Delete(string name);
    void Print();
    ~ScopeTable();
};
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
        cout <<"Inserted in ScopeTable# " << id << " at position "<< index << "," << pos << endl;
        return true;
    }
    else{
        SymbolInfo* temp = Arr[index];
        SymbolInfo* prev;
        int pos = 0;
        while(temp != nullptr){
            if(temp->getName() == name){
                cout << "< " << temp->getName() << " : " << temp->getType() << " > already exists in current ScopeTable" << endl;
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
            cout <<"Inserted in ScopeTable# " << id << " at position "<< index << "," << pos << endl;
            return true;
        }

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
                cout << "Found in ScopeTable# " << id <<" at position "<< index << "," << pos << endl;
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
        cout <<"Not found"<<endl;
        return false;
    }
    else{
        SymbolInfo* temp = Arr[index];
        SymbolInfo* prev = nullptr;
        int pos = 0;
        while(temp != nullptr){
            if(temp->getName() == name){
                cout << "Found in ScopeTable# " << id <<" at position "<< index << "," << pos << endl;
                cout << "Deleted Entry "<< index << "," << pos <<" from current ScopeTable" <<endl;
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
        cout <<"Not found"<<endl;
        return false;
    }

}
void ScopeTable::Print(){
    cout << endl << endl;
    cout << "ScopeTable # " << id << endl;
    for(int i = 0; i < total_buckets; i++){
        cout << i << " --> ";
        if(Arr[i] != nullptr){
            cout << " < " << Arr[i]->getName() << " : " << Arr[i]->getType() << " > ";
            if(Arr[i]->getNext() != nullptr){
                SymbolInfo* temp = Arr[i]->getNext();
                int pos = 0;
                while(temp != nullptr){
                    cout << " < " << temp->getName() << " : " << temp->getType() << " > ";
                    temp = temp->getNext();
                }
            }
        }
        cout << endl;
    }
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
class SymbolTable{
    ScopeTable* currentScope;
    int shape;
    int globalScopeCount;
public :
    SymbolTable(int n);
    void EnterScope();
    void ExitScope();
    bool Insert(string name, string type);
    bool Remove(string name);
    SymbolInfo* LookUp(string name);
    void Print_C();
    void Print_A();
    ~SymbolTable();
};
SymbolTable::SymbolTable(int n){
    globalScopeCount = 1;
    currentScope = new ScopeTable(n);
    currentScope->setId(to_string(globalScopeCount));
    shape = n;
}
void SymbolTable::EnterScope(){
    if(currentScope != nullptr){
        ScopeTable* newScope = new ScopeTable(shape);
        newScope->setparentScope(currentScope);
        currentScope->incCurrentScopeNum();
        int scopeNum = currentScope->getCurrentScopeNum();
        newScope->setId(to_string(scopeNum));
        currentScope = newScope;
        cout << "New ScopeTable with id " << currentScope->getId() << " created"<< endl;
    }
    else{
        globalScopeCount++;
        currentScope = new ScopeTable(shape);
        currentScope->setId(to_string(globalScopeCount));
        cout << "New ScopeTable with id " << currentScope->getId() << " created"<< endl;
    }
}
void SymbolTable::ExitScope(){
    if(currentScope != nullptr){
        ScopeTable* temp;
        temp = currentScope;
        currentScope = temp->getparentScope();
        cout << "ScopeTable with id " << temp->getId() << " removed" << endl;
        delete temp;
    }
    else{
        cout << "There is no current scope."<<endl;
    }

}
bool SymbolTable::Insert(string name, string type){
    if(currentScope == nullptr)
        return false;
    if(currentScope->Insert(name, type))
        return true;
    else return false;
}
bool SymbolTable::Remove(string name){
    if(currentScope == nullptr){
        cout << "There is no current scope."<<endl;
        return false;
    }
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
    cout << "Not Found" << endl;
    return nullptr;
}
void SymbolTable::Print_C(){
    if(currentScope != nullptr)
        currentScope->Print();
}
void SymbolTable::Print_A(){
    ScopeTable* temp = currentScope;
    while(temp != nullptr ){
        temp->Print();
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



int main(){
    freopen ("input.txt","r",stdin);
    freopen ("output.txt","w",stdout);
    int n;
    cin >> n;
    SymbolTable* st = new SymbolTable(n);
    char input;
    while(cin >> input){
        cout << input ;
        if( input == 'I'){
            string name, type;
            cin >> name >> type ;
            cout <<" "<< name <<" "<< type ;
            cout << endl << endl;
            bool in = st->Insert(name, type);
            if(!in){
                cout << "Insertion failed." << endl;
            }
        }
        else if(input == 'L'){
            string name;
            cin>> name;
            cout << " "<< name;
            cout << endl << endl;
            st->LookUp(name);
        }
        else if(input == 'D'){
            string name;
            cin >> name;
            cout <<" "<< name;
            cout << endl << endl;
            st->Remove(name);
        }
        else if(input == 'P'){
            char type;
            cin >> type;
            cout << " "<<type ;
            if(type == 'A'){
                st->Print_A();
            }
            else if(type == 'C'){
                st->Print_C();
            }
        }
        else if(input == 'S'){
            cout << endl << endl;
            st->EnterScope();
        }
        else if(input == 'E'){
            cout << endl << endl;
            st->ExitScope();
        }
        else{
            cout << "Wrong command." << endl;
        }
        cout << endl;
    }
    return 0;
}
