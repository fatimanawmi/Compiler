#include <bits/stdc++.h>

using namespace std;

class SymbolInfo{
    string name;
    string type;
    string VarType;
    string code;
    string memName;
    bool arr;
    int arr_size;
    bool isFunc;
    bool func_dec;
    bool func_def;
    int paramSize;
    vector<pair <string, string>> param;
    SymbolInfo *next;
public:
    SymbolInfo();
    SymbolInfo(string name,string type);
    void setName(string name);
    string getName();
    void setType(string type);
    string getCode();
    void setCode(string code);
    string getmemName();
    void setmemName(string memName);
    string getType();
    void setArr(bool arr);
    bool getArr();
    void setSize(int arr_size);
    int getSize();
    int getparamSize();
    void setVarType(string type);
    string getVarType();
    SymbolInfo* getNext();
    void setNext(SymbolInfo* next);
    void setParam(string name, string type);
    string getParam(int pos);
    string getParamName(int pos);
    void setFunc(bool isFunc);
    bool getFunc();
    void setDec(bool func_dec);
    bool getDec();
    void setDef(bool func_dec);
    bool getDef();
    ~SymbolInfo();
};

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
    bool Insert(SymbolInfo* sb);
    SymbolInfo* LookUp(string name);
    bool Delete(string name);
    void Print(ofstream &logout);
    ~ScopeTable();
};

//==================================================================================================================

class SymbolTable{
    ScopeTable* currentScope;
    int shape;

public :
    SymbolTable(int n);
    void EnterScope(ofstream &logout);
    void ExitScope(ofstream &logout);
    bool Insert(string name, string type);
    bool Insert(SymbolInfo* sb);
    bool Remove(string name);
    SymbolInfo* LookUp(string name);
    SymbolInfo* LookUpCur(string name);
    void Print_C(ofstream &logout);
    void Print_A(ofstream &logout);
    string getCurrentID();
    ~SymbolTable();
};
