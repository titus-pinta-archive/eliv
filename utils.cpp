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
	o<<left<<setw(20)<<rhs.code[0]<<" | ";
	o<<left<<setw(20)<<rhs.code[1]<<" | ";
	o<<left<<setw(20)<<rhs.code[2]<<" | ";
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

string current_label_name = string("");

string get_size(string addr)
{
	return addr.substr(0, addr.find("_"));	
}

string data_asm(const map<string, symtab*>& final_symtabs)
{
	string ret = string(".section .data\n");
	for (auto itr = final_symtabs.begin(); itr != final_symtabs.end(); ++itr)
	{
		for (int i = 0; i < 101; i++)
		if (itr->second->syms[i].size() != 0 )
		{
			for (int j = 0; j < itr->second->syms[i].size(); j++)
				if(itr->second->syms[i][j].type < 0xFF)
					if (itr->second->syms[i][j].type < 0x05) 
					{
						ret += string("\t") + itr->first + string("_") + itr->second->syms[i][j].addr + string(":\t .skip ") + get_size(itr->second->syms[i][j].addr) +  string("\n");
					} else {
						ret += string("\t") + itr->first + string("_") + itr->second->syms[i][j].addr + string(":\t .skip 256\n");
					}
		}
	}
	ret += string("\ttemp_vals: .skip 1024\n");
	ret += string("\tparam_vals: .skip 1024\n\n");
	return ret;
	
}

string reg_a(int size){
	switch(size){
		case 1:
			return string("%al");
		case 2:
			return string("%ax");
		case 4:
			return string("%eax");
			
		default:
			return string("%eax");
	}
}
string reg_b(int size){
	switch(size){
		case 1:
			return string("%bl");
		case 2:
			return string("%bx");
		case 4:
			return string("%ebx");
		default:
			return string("%ebx");
	}
}

string reg_c(int size){
	switch(size){
		case 1:
			return string("%cl");
		case 2:
			return string("%cx");
		case 4:
			return string("%ecx");
		default:
			return string("%ecx");
	}
}

string reg_d(int size){
	switch(size){
		case 1:
			return string("%dl");
		case 2:
			return string("%dx");
		case 4:
			return string("%edx");
		default:
			return string("%edx");
	}
}

string get_suffix(int size){
	switch(size){
		case 1:
			return string("b");
		case 2:
			return string("s");
		case 4:
			return string("l");
		default:
			return string("l");
	}
}

string get_real_addr(string addr)
{
	if(addr[0] == '$')
		return addr;
	string aux = addr.substr(addr.find("_"), addr.length() - 1);
	string ret = string("");
	if(aux[1] == 'i')
	{
		int base = stoi(aux.substr(3, aux.length() - 1));
		ret += string("param_vals+") + to_string(base);
	} else if(aux[1] == 'o')
	{
		int base = stoi(aux.substr(4, aux.length() - 1));
		ret += string("param_vals+") + to_string(base);
	} else if(aux[1] == 't')
	{
		int base = stoi(aux.substr(5, aux.length() - 1));
		ret += string("temp_vals + ") + to_string(+base);
	} else
		ret = current_label_name + string("_") + addr;
	
	return ret;
}

string code_from_line(const line& line)
{
	string ret = string("");
	if	(line.label != string(""))
	{
		
		if(line.label.find("__") >= line.label.length())
		{
			ret = string("\t.section .rdata,\"dr\"\n\n\t.text\n\t.globl ") + line.label.substr(1, line.label.length()) + ("\n\t.def ") + line.label.substr(1, line.label.length()) + ("; .scl 2; .type 32; .endef\n\t.seh_proc ") + line.label.substr(1, line.label.length()) + ("\n");
			ret += line.label + string(":\n");
			ret += string("\tpushq %rbp\n\t.seh_pushreg %rbp\n\tmovq %rsp, %rbp\n\t.seh_setframe %rbp, 0\n\tsubq $32, %rsp\n\t.seh_stackalloc 32\n\t.seh_endprologue\n\n");
			current_label_name = line.label.substr(1, line.label.length() - 1);
		} else {
			ret += line.label + string(":\n");
		}
	}
	
	
	if (line.code != 0)
	{
		if(line.code->code[0] == "mov")
		{
			int auxp = 0;
			if(line.code->code[1][0] == '[')
			{
				if((auxp = line.code->code[1].find("+")) < line.code->code[1].length())
				{
					string ra = reg_a(4);
					string rb = reg_b(4);
					
					ret += string("\tlea ") + get_real_addr(line.code->code[1].substr(1, auxp - 1)) + string(", ") + rb + string("\n");
					ret += string("\tmov ") + get_real_addr(line.code->code[1].substr(auxp + 1, line.code->code[1].length() - auxp - 2)) + string(", ") + ra + string("\n");
					ret += string("\tadd ") + ra + string(", ") + rb + string("\n");
					if (line.size != -1)
						ra = reg_a(line.size);
					else
						ra = reg_a(stoi(get_size(line.code->code[3])));
					ret += string("\tmov (") + rb + string("), ") + ra + string("\n");
					ret += string("\tmov ") + ra + string(", ") + get_real_addr(line.code->code[3]) + string("\n"); 
				} else {
					string rb = reg_b(stoi(get_size(line.code->code[1].substr(1, line.code->code[1].length() - 1))));
					ret += string("\tlea ") + get_real_addr(line.code->code[1].substr(1, line.code->code[1].length() - 2)) + string(", ") + rb + string("\n");
					string ra;
					if (line.size != -1)
						ra = reg_a(line.size);
					else
						ra = reg_a(stoi(get_size(line.code->code[3])));
					ret += string("\tmov (") + rb + string("), ") + ra + string("\n");
					ret += string("\tmov ") + ra + string(", ") + get_real_addr(line.code->code[3]) + string("\n");   
				}
			}else if(line.code->code[3][0] == '[')
			{
				
				if((auxp = line.code->code[3].find("+")) < line.code->code[3].length())
				{
					
					string ra = reg_a(4);
					string rb = reg_b(4);
					
					ret += string("\tlea ") + get_real_addr(line.code->code[3].substr(1, auxp - 1)) + string(", ") + rb + string("\n");
					ret += string("\tmov ") + get_real_addr(line.code->code[3].substr(auxp + 1, line.code->code[3].length() - auxp - 2)) + string(", ") + ra + string("\n");
					ret += string("\tadd ") + ra + string(", ") + rb + string("\n");
					if (line.size != -1)
						ra = reg_a(line.size);
					else
						ra = reg_a(stoi(get_size(line.code->code[1])));
					ret += string("\tmov ") + get_real_addr(line.code->code[1]) + string(", ") + ra + string("\n");   
					ret += string("\tmov ") + ra + string(", (") + rb + string(")\n");
				} else {
					string rb = reg_b(stoi(get_size(line.code->code[3].substr(1, line.code->code[3].length() - 1))));
					ret += string("\tlea ") + get_real_addr(line.code->code[3].substr(1, line.code->code[3].length() - 2)) + string(", ") + rb + string("\n");
					string ra;
					if (line.size != -1)
						ra = reg_a(line.size);
					else
						ra = reg_a(stoi(get_size(line.code->code[1])));
					ret += string("\tmov ") + get_real_addr(line.code->code[1]) + string(", ") + ra + string("\n");   
					ret += string("\tmov ") + ra + string(", (") + rb + string(")\n");  
				}
			} else if(line.code->code[1][0] == '$')
			{
				ret += string("\tmov") + get_suffix(stoi(get_size(line.code->code[3]))) + string(" ") + get_real_addr(line.code->code[1]) + string(", ") + get_real_addr(line.code->code[3]) + string("\n");
			} else {
				string ra = reg_a(stoi(get_size(line.code->code[1])));
				ret += string("\tmov ") + get_real_addr(line.code->code[1]) + string(", ") + ra + string("\n");
				ret += string("\tmov ") + ra + string(", ") + get_real_addr(line.code->code[3]) + string("\n");
			}
		
		} else if(line.code->code[0] == "lea")
		{
			int size = stoi(get_size(line.code->code[1]));
			string ra = reg_a(4);
			ret += string("\tlea ") + get_real_addr(line.code->code[1]) + string(", ") + ra + string("\n");
			ret += string("\tmov ") + ra + string(", ") + get_real_addr(line.code->code[3]) + string("\n");
			
			
		} else if(line.code->code[0] == "add")
		{
			int size = line.size != -1 ? line.size : line.code->code[1][0] != '$' ? stoi(get_size(line.code->code[1])) : stoi(get_size(line.code->code[2]));
			string ra = reg_a(size);
			string rb = reg_b(size);
			ret += string("\tmov ") + get_real_addr(line.code->code[1]) + string(", ") + ra + string("\n");
			ret += string("\tmov ") + get_real_addr(line.code->code[2]) + string(", ") + rb + string("\n");
			ret += string("\tadd ") + rb + string(", ") + ra + string("\n");
			ret += string("\tmov ") + ra + string(", ") + get_real_addr(line.code->code[3]) + string("\n");
		} else if(line.code->code[0] == "sub")
		{
			int size = line.size != -1 ? line.size : line.code->code[1][0] != '$' ? stoi(get_size(line.code->code[1])) : stoi(get_size(line.code->code[2]));
			string ra = reg_a(size);
			string rb = reg_b(size);
			ret += string("\tmov ") + get_real_addr(line.code->code[1]) + string(", ") + ra + string("\n");
			ret += string("\tmov ") + get_real_addr(line.code->code[2]) + string(", ") + rb + string("\n");
			ret += string("\tsub ") + rb + string(", ") + ra + string("\n");
			ret += string("\tmov ") + ra + string(", ") + get_real_addr(line.code->code[3]) + string("\n");
		} else if(line.code->code[0] == "mul")
		{
			int size = line.size != -1 ? line.size : line.code->code[1][0] != '$' ? stoi(get_size(line.code->code[1])) : stoi(get_size(line.code->code[2]));
			string ra = reg_a(size);
			string rb = reg_b(size);
			ret += string("\tmov ") + get_real_addr(line.code->code[1]) + string(", ") + ra + string("\n");
			ret += string("\tmov ") + get_real_addr(line.code->code[2]) + string(", ") + rb + string("\n");
			ret += string("\timul ") + rb + string("\n");
			ret += string("\tmov ") + ra + string(", ") + get_real_addr(line.code->code[3]) + string("\n");
		} else if(line.code->code[0] == "div")
		{
			int size = line.size != -1 ? line.size : line.code->code[1][0] != '$' ? stoi(get_size(line.code->code[1])) : stoi(get_size(line.code->code[2]));
			string ra = reg_a(size);
			string rb = reg_b(size);
			ret += string("\tmov ") + get_real_addr(line.code->code[1]) + string(", ") + ra + string("\n");
			ret += string("\tmov ") + get_real_addr(line.code->code[2]) + string(", ") + rb + string("\n");
			ret += size == 4 ? string("\tcdq\n") : string("\tcbw\n"); 
			ret += string("\tidiv ") + rb + string("\n");
			ret += string("\tmov ") + ra + string(", ") + get_real_addr(line.code->code[3]) + string("\n");
		} else if(line.code->code[0] == "mod")
		{
			int size = line.size != -1 ? line.size : line.code->code[1][0] != '$' ? stoi(get_size(line.code->code[1])) : stoi(get_size(line.code->code[2]));
			string ra = reg_a(size);
			string rb = reg_b(size);
			string rd = reg_d(size);
			ret += string("\tmov ") + get_real_addr(line.code->code[1]) + string(", ") + ra + string("\n");
			ret += string("\tmov ") + get_real_addr(line.code->code[2]) + string(", ") + rb + string("\n");
			ret += size == 4 ? string("\tcdq\n") : string("\tcbw\n"); 
			ret += string("\tidiv ") + rb + string(", ") + ra + string("\n");
			ret += string("\tmov ") + rd + string(", ") + get_real_addr(line.code->code[3]) + string("\n");
		}
		else if(line.code->code[0] == "and")
		{
			int size = line.size != -1 ? line.size : line.code->code[1][0] != '$' ? stoi(get_size(line.code->code[1])) : stoi(get_size(line.code->code[2]));
			string ra = reg_a(size);
			string rb = reg_b(size);
			ret += string("\tmov ") + get_real_addr(line.code->code[1]) + string(", ") + ra + string("\n");
			ret += string("\tmov ") + get_real_addr(line.code->code[2]) + string(", ") + rb + string("\n");
			ret += string("\tand ") + rb + string(", ") + ra + string("\n");
			ret += string("\tmov ") + ra + string(", ") + get_real_addr(line.code->code[3]) + string("\n");
		} else if(line.code->code[0] == "or")
		{
			int size = line.size != -1 ? line.size : line.code->code[1][0] != '$' ? stoi(get_size(line.code->code[1])) : stoi(get_size(line.code->code[2]));
			string ra = reg_a(size);
			string rb = reg_b(size);
			ret += string("\tmov ") + get_real_addr(line.code->code[1]) + string(", ") + ra + string("\n");
			ret += string("\tmov ") + get_real_addr(line.code->code[2]) + string(", ") + rb + string("\n");
			ret += string("\tor ") + rb + string(", ") + ra + string("\n");
			ret += string("\tmov ") + ra + string(", ") + get_real_addr(line.code->code[3]) + string("\n");
		} else if(line.code->code[0] == "not")
		{
			int size = line.size != -1 ? line.size : stoi(get_size(line.code->code[1]));
			string ra = reg_a(size);
			ret += string("\tmov ") + get_real_addr(line.code->code[1]) + string(", ") + ra + string("\n");
			ret += string("\tnot ") + ra + string("\n");
			ret += string("\tmov ") + ra + string(", ") + get_real_addr(line.code->code[3]) + string("\n");
		} else if(line.code->code[0] == "jz")
		{
			string ra = reg_a(stoi(get_size(line.code->code[1])));
			ret += string("\tmov") + get_suffix(stoi(get_size(line.code->code[1]))) + string(" ") + get_real_addr(line.code->code[1]) + string(", ") + ra + string("\n");
			ret += string("\tcmp $0, ") + ra + string("\n");
			ret += string("\tjz ") + line.code->code[3] + string("\n");
		} else if(line.code->code[0] == "jmp")
		{
			ret += string("\tjmp ") + line.code->code[3] + string("\n");
		} else if(line.code->code[0] == "call")
		{
			ret += string("\tcall ") + line.code->code[3] + string("\n");
		} else if(line.code->code[0] == "ret")
		{
			ret += string("\n\n\taddq $32, %rsp\n\tpopq %rbp\n\tret\n\t.seh_endproc\n");
		}else if(line.code->code[0] == "asm")
		{
			string copy_source = line.code->code[3];
			int length = copy_source.length();
			for(int i = 0; i < length; i++)
				if(copy_source[i] == '\\')
				{
					switch(copy_source[i + 1])
					{
						case 't':
							ret += string("\t");
							break;
							
						case 'n':
							ret += string("\n");
							break;
						case '\\':
							ret += string("\\");
						
						default:
							yyerror("Unknown escape char in asm");
					
					}
					i++;
				} else if(copy_source[i] != '"') {
					ret += string(1, copy_source[i]);
				}
			ret += string("\n");
		} else {
			cerr << "Not yet suported op from 3 addr code " << line.code->code[0] << "\n";
			yyerror("Not yet suported op");
			exit(1);
		}
		
	}
	return ret;
}

string text_asm(const list<line>& final_code)
{	
	string ret = string("");
	for (auto itr = final_code.begin(); itr != final_code.end(); ++itr)
		if (itr != final_code.end())
		{	
			ret += code_from_line(*itr);
		}
	
	ret += string("\n\n");
	return ret;		
}