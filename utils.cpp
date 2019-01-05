#include "utils.hpp"

symbol::symbol(int type,const char* value, const string& addr)
{
	this->type = type;
	this->value = std::string(value);
	this->addr = string(addr);
}

symbol::symbol(const symbol& rhs)
{
	this->type = rhs.type;
	this->value = rhs.value;
	this->addr = rhs.addr;
}

symbol::~symbol()
{
}

int symbol::hash() const
{
	int sum = 0;
	for (int i = 0; i < this->value.length(); i++)
		sum += this->value[i] * (i + 1);
	return sum % 101;
}
	
symbol& symbol::operator=(const symbol& rhs)
{
	this->type = rhs.type;
	this->value = rhs.value;
	this->addr = rhs.addr;
	return *this;
}	

bool operator==(const symbol& rhs, const symbol& lhs)
{
	return lhs.value == rhs.value;
}

ostream& operator<<(ostream& o, const symbol& rhs)
{
	o << rhs.value << "@[" << rhs.addr<<"]:"<<rhs.type;
	return o;
}	


symtab::symtab()
{
	this->base_pointer = 0;
	this->current_pointer = 0;
	this->current_input_pointer = 0;
	this->current_output_pointer = 0;
	this->temp_pointer = 0;
	this->current_label = 0;
	
	this->name = string("");
}


int symtab::add_symbol(const symbol& s)
{
	int hash = s.hash();
	auto found = find(syms[hash].begin(), syms[hash].end(), s);
	int ret = -1;
	
	if (found == syms[hash].end())
	{
		syms[hash].push_back(s);
		ret = syms[hash].size() - 1;
	} else {
		ret = (int)(found - syms[hash].begin());
	}
		
	return (hash << 8) | (ret);
	
}
	
symbol& symtab::operator[](const unsigned int index)
{
	return syms[index >> 8][index & 0xFF];
}
	
ostream& operator<<(ostream& o, const symtab& rhs)
{
	for (int i = 0; i < 101; i++)
		if (rhs.syms[i].size() != 0 )
		{
			o << i << ":\t";
			for (int j = 0; j < rhs.syms[i].size(); j++)
				o << rhs.syms[i][j] <<" ";
			o << "\n";
		}
	return o;
}	


string* symtab::new_temp_addr(int size)
{
	this->temp_pointer += size;
	return new string(to_string(size) + string("_temp") + to_string(temp_pointer - size));
}

string* symtab::new_addr(int size)
{
	this->current_pointer += size;
	return new string(to_string(size) + string("_final") + to_string(current_pointer - size));
}

string* symtab::new_input_addr(int size)
{
	this->current_input_pointer += size;
	return new string(to_string(size) + string("_in") + to_string(current_input_pointer - size));
}

string* symtab::new_output_addr(int size)
{
	this->current_output_pointer += size;
	return new string(to_string(size) + string("_out") + to_string(current_output_pointer - size));
}

string* symtab::new_label()
{
	return new string(this->name + string("__aux_lbl") + to_string(current_label++));
}

reg_code::reg_code()
{
	this->code[0] = string("");
	this->code[1] = string("");
	this->code[2] = string("");
	this->code[3] = string("");
}

reg_code& reg_code::operator=(const reg_code& rhs)
{
	this->code[0] = rhs.code[0];
	this->code[1] = rhs.code[1];
	this->code[2] = rhs.code[2];
	this->code[3] = rhs.code[3];	
}

ostream& operator<<(ostream& o, const reg_code& rhs)
{
	o<<left<<setw(12)<<rhs.code[0]<<" | ";
	o<<left<<setw(12)<<rhs.code[1]<<" | ";
	o<<left<<setw(12)<<rhs.code[2]<<" | ";
	o<<left<<rhs.code[3]<<endl;
	return o;
}

ostream& operator<<(ostream& o, const line& rhs)
{
	if	(rhs.label != string(""))
		o<<rhs.label<<":\n";
	
	if (rhs.code != 0)
		o<<*(rhs.code);
	return o;
}