#ifndef utilsh
#define utilsh 1

#include <math.h>
#include <vector>
#include <array>
#include <string>
#include <iostream>
#include <algorithm>
#include <stdio.h>
#include <string>
#include <list>
#include <iomanip>
#include <map>
#include <sstream>
#include <fstream>

using namespace std;

class symbol
{
public:
	int				type;
	std::string 	value;
	std::string		addr;
	
	
	symbol(int type,const char* value, const string& addr);
	symbol(const symbol& rhs);
	
	~symbol();
	
	int hash() const;
	
	symbol& operator=(const symbol& rhs);
	
	friend bool operator==(const symbol& rhs, const symbol& lhs);
	friend ostream& operator<<(ostream& o, const symbol& rhs);
};

class symtab
{
public:
	int base_pointer;
	int current_pointer;
	int current_input_pointer;
	int current_output_pointer;
	int temp_pointer;
	int current_label;


	string name;

	std::array<std::vector<symbol>, 101>		syms;

	symtab();
	
	int add_symbol(const symbol& s);
	
	symbol& operator[](const unsigned int index);
	
	friend ostream& operator<<(ostream& o, const symtab& rhs);
	
	
	
	string* new_temp_addr(int size);
	string* new_addr(int size);
	string* new_input_addr(int size);
	string* new_output_addr(int size);
	string* new_label();

};

class reg_code
{
public:
	std::array<std::string, 4> 	code;
	
	reg_code();
	reg_code(const reg_code& rhs);
	
	reg_code& operator=(const reg_code& rhs);
	friend ostream& operator<<(ostream& o, const reg_code& rhs);
};

class line 
{
public:

	string			label;
	reg_code* 		code;
	string			res_addr;	
	int 			res_type;	
	
	friend ostream& operator<<(ostream& o, const line& rhs);
};


string data_asm(const map<string, symtab*>& final_symtabs);
string text_asm(const list<line>& final_code);



int yyerror(const char*);
#endif