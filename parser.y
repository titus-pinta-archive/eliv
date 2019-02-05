
%code requires{
#include "utils.hpp"
}


%{
#include "parser.tab.hpp"

int type_sizes[] = {1, 1, 4, 4, 4, 4, 4, 4};
int type_size[] = {1, 1, 4, 4, 4, 4, 4, 4};

list<line> final_code;
map<string, symtab*> final_symtabs; 


int yyerror(const char*); //in lexer
int yylex(void); //in lexer

extern symtab* st; //in lexer
extern int num_symtabs; //in main

int num_comp_int = 0;
string base_addr_comp;

%}

%union 
{
	list<line>*		code;
	int				id;
	
}

%start				file 

%token				_EOF

%token				_START
%token				_END

%token				_IF
%token				_FI
%token				_ELSE
%token				_WHILE
%token				_ELIHW
%token				_ASM

%token 				_VOID
%token				_INT
%token				_FLOAT
%token				_CHAR
%token 				_VOIDPOINT
%token				_INTPOINT
%token				_FLOATPOINT
%token				_CHARPOINT

%token	<id>		_ID

%token	<id>		_INTLIT
%token	<id>		_FLOATLIT
%token	<id>		_CHARLIT
%token	<id>		_STRINGLIT


%token				_SEMICOL
%token				_COMMA

%token				_EQ

%right				_POINT
%right				_DEREF

%left				_LSB
%left				_RSB

%left				_LCB
%left				_RCB

%left				_PLUS
%left				_MINUS
%left				_MUL
%left				_DIV
%left				_MODULO
%left				_LPAR
%left				_RPAR


%left				_EQUAL
%left				_NEQ
%left				_LESS
%left				_GR
%left				_AND
%left				_OR
%right				_NOT

%type 	<code>		program

%type	<code>		_expresion
%type	<code>		expresions

%type 	<code>		_formula
%type	<code>		_formulas

%type	<code>		_statement
%type	<code>		statements

%type	<code>		_compound_int

%%

_compound_int:		_INTLIT							{
		st->current_pointer -= 4;
		base_addr_comp = *(st->new_addr(4));
		
		$$ = new list<line>(); 
		line aux; 
		aux.res_addr = base_addr_comp; aux.res_type = 6; 
		
		aux.code = new reg_code();
		aux.code->code[0] = string("mov");
		aux.code->code[1] = (*st)[$1].addr;
		aux.code->code[3] = string("[") + base_addr_comp + string("+") + string("$") + to_string(num_comp_int++) + string("]");
		
		aux.size = 4;
			
		$$->push_back(aux);
		aux.code = 0;
		
	}
	
	|				_compound_int _COMMA _INTLIT	{
		
		st->current_pointer += 4;
		
		$$ = new list<line>(); 
		$$->insert($$->end(), $1->begin(), $1->end());
		line aux; 
		aux.res_addr = base_addr_comp; aux.res_type = 6; 
		
		aux.code = new reg_code();
		aux.code->code[0] = string("mov");
		aux.code->code[1] = (*st)[$3].addr;
		aux.code->code[3] = string("[") + base_addr_comp + string("+") + string("$") + to_string(4 * num_comp_int++) + string("]");
		aux.size = 4;
		
		$$->push_back(aux);
		aux.code = 0;	
	}
	;
	
	
_declaration:		_VOID _ID 				{(*st)[$2].type = 0x0000;	(*st)[$2].addr = *(st->new_addr(1));}
	| 				_CHAR _ID				{(*st)[$2].type = 0x0001; 	(*st)[$2].addr = *(st->new_addr(1));}
	| 				_INT _ID				{(*st)[$2].type = 0x0002; 	(*st)[$2].addr = *(st->new_addr(4));}
	| 				_FLOAT _ID				{(*st)[$2].type = 0x0003; 	(*st)[$2].addr = *(st->new_addr(4));}
	|				_VOIDPOINT _ID 			{(*st)[$2].type = 0x0004; 	(*st)[$2].addr = *(st->new_addr(4));}
	| 				_CHARPOINT _ID 			{(*st)[$2].type = 0x0005;	(*st)[$2].addr = *(st->new_addr(4));}
	| 				_INTPOINT _ID 			{(*st)[$2].type = 0x0006;	(*st)[$2].addr = *(st->new_addr(4));}
	| 				_FLOATPOINT _ID			{(*st)[$2].type = 0x0007;	(*st)[$2].addr = *(st->new_addr(4));}
	|				_VOID _LSB _INTLIT _RSB _ID 				{(*st)[$5].type = 0x0004;	(*st)[$5].addr = *(st->new_addr(4)); st->current_pointer += stoi((*st)[$3].value) - 1;}
	| 				_CHAR _LSB _INTLIT _RSB _ID					{(*st)[$5].type = 0x0005; 	(*st)[$5].addr = *(st->new_addr(4)); st->current_pointer += stoi((*st)[$3].value) - 1;}
	| 				_INT _LSB _INTLIT _RSB _ID					{(*st)[$5].type = 0x0006; 	(*st)[$5].addr = *(st->new_addr(4)); st->current_pointer += stoi((*st)[$3].value) * 4 - 4;}
	| 				_FLOAT _LSB _INTLIT _RSB _ID				{(*st)[$5].type = 0x0007; 	(*st)[$5].addr = *(st->new_addr(4)); st->current_pointer += stoi((*st)[$3].value) * 4 - 4;}
	;

_in_param:			_VOID _ID 				{(*st)[$2].type = 0x0000;	(*st)[$2].addr = *(st->new_input_addr(1));}
	| 				_CHAR _ID				{(*st)[$2].type = 0x0001; 	(*st)[$2].addr = *(st->new_input_addr(1));}
	| 				_INT _ID				{(*st)[$2].type = 0x0002; 	(*st)[$2].addr = *(st->new_input_addr(4));}
	| 				_FLOAT _ID				{(*st)[$2].type = 0x0003; 	(*st)[$2].addr = *(st->new_input_addr(4));}
	|				_VOIDPOINT _ID 			{(*st)[$2].type = 0x0004; 	(*st)[$2].addr = *(st->new_input_addr(4));}
	| 				_CHARPOINT _ID 			{(*st)[$2].type = 0x0005;	(*st)[$2].addr = *(st->new_input_addr(4));}
	| 				_INTPOINT _ID 			{(*st)[$2].type = 0x0006;	(*st)[$2].addr = *(st->new_input_addr(4));}
	| 				_FLOATPOINT _ID			{(*st)[$2].type = 0x0007;	(*st)[$2].addr = *(st->new_input_addr(4));}
	|				_VOID _LSB _INTLIT _RSB _ID 				{(*st)[$5].type = 0x0004;	(*st)[$5].addr = *(st->new_input_addr(4)); st->current_input_pointer += stoi((*st)[$3].value) - 1;}
	| 				_CHAR _LSB _INTLIT _RSB _ID					{(*st)[$5].type = 0x0005; 	(*st)[$5].addr = *(st->new_input_addr(4)); st->current_input_pointer += stoi((*st)[$3].value) - 1;}
	| 				_INT _LSB _INTLIT _RSB _ID					{(*st)[$5].type = 0x0006; 	(*st)[$5].addr = *(st->new_input_addr(4)); st->current_input_pointer += stoi((*st)[$3].value) * 4 - 4;}
	| 				_FLOAT _LSB _INTLIT _RSB _ID				{(*st)[$5].type = 0x0007; 	(*st)[$5].addr = *(st->new_input_addr(4)); st->current_input_pointer += stoi((*st)[$3].value) * 4 - 4;}
	;


	
_in_params:		_in_param 
	| 			_in_params _COMMA _in_param	
	;
	
_formula:		_ID							{$$ = new list<line>(); line aux; aux.res_addr = (*st)[$1].addr; aux.res_type = (*st)[$1].type; aux.code = 0; $$->push_back(aux);}
	|			_INTLIT						{$$ = new list<line>(); line aux; aux.res_addr = (*st)[$1].addr; aux.res_type = 2; aux.code = 0; $$->push_back(aux);}
	|			_FLOATLIT					{$$ = new list<line>(); line aux; aux.res_addr = (*st)[$1].addr; aux.res_type = 3; aux.code = 0; $$->push_back(aux);}
	|			_CHARLIT					{$$ = new list<line>(); line aux; aux.res_addr = (*st)[$1].addr; aux.res_type = 1; aux.code = 0; $$->push_back(aux);}
	|			_LCB _compound_int _RCB		{$$ = new list<line>(); $$->insert($$->end(), $2->begin(), $2->end()); num_comp_int = 0;}
	
	|			_STRINGLIT					{$$ = new list<line>(); 
	
		st->current_pointer -= 4;
	
		string baddr = *(st->new_addr(4));
		string escaped = "";
		int counter = 0;
			
		for(int i = 1; i < (*st)[$1].addr.length() - 1; i++)
		{
			line aux; aux.res_addr = baddr; aux.res_type = 0x0005;
			aux.code = new reg_code();

			if((*st)[$1].addr[i] == '\\')
			{
				switch((*st)[$1].addr[i + 1])
				{
					case 't':
						escaped = to_string('\t');
						break;
								
						case 'n':
						escaped = to_string('\n');
						break;
						
						case 'r':
						escaped = to_string(13);
						break;
						case '\\':

						escaped = to_string('\\');
						break;
						
						default:
						yyerror("Unknown escape char in asm");
						
				}
				i++;
			} else {
				escaped = to_string((*st)[$1].addr[i]);
			}	
			aux.code->code[0] = string("mov");
			aux.code->code[1] = string("$") + escaped;
			aux.code->code[3] = string("[") + baddr + string("+$") + to_string(counter) + string("]");
			aux.size = 1;
			
			$$->push_back(aux);
			aux.code = 0;
			counter++;
			
		}
		
		st->current_pointer += counter - 1;
		
		line aux; aux.res_addr = baddr; aux.res_type = 0x0005;
		aux.code = new reg_code();
		aux.code->code[0] = string("mov");
		aux.code->code[1] = string("$0");
		aux.code->code[3] = string("[") + baddr + string("+$") + to_string(counter) + string("]");
		aux.size = 1;	
		$$->push_back(aux);
		aux.code = 0;
		
	}
	
	|			_LPAR _formula _RPAR		{$$ = new list<line>(); $$->insert($$->end(), $2->begin(), $2->end());}
	
	|			_formula _PLUS _formula		{
		if(($1->rbegin()->res_type & 0xFF) != ($3->rbegin()->res_type  & 0xFF))
		{
			cerr<<$1->rbegin()->res_type << " + " <<$3->rbegin()->res_type;
			yyerror(" Semantyc error: type mismach!");
		}
	
	
		$$ = new list<line>(); $$->insert($$->end(), $1->begin(), $1->end()); $$->insert($$->end(), $3->begin(), $3->end()); 
		line aux;
	
		aux.res_addr = *(st->new_temp_addr(type_sizes[($1->rbegin()->res_type & 0xFF)])); 
	
		aux.res_type = $1->rbegin()->res_type; 
	
		aux.code = new reg_code(); 
		aux.code->code[0] = ($1->rbegin()->res_type & 0xFF) != 0x0003 ? string("add") : string("addf"); 
		aux.code->code[1] = $1->rbegin()->res_addr;
		aux.code->code[2] = $3->rbegin()->res_addr;		
		aux.code->code[3] = aux.res_addr;
		aux.size = type_size[($1->rbegin()->res_type & 0xFF)];
		$$->push_back(aux);
		
		aux.code = 0;

	}
	
	|			_formula _MINUS _formula	{
		if(($1->rbegin()->res_type & 0xFF) != ($3->rbegin()->res_type  & 0xFF))
		{
			cerr<<$1->rbegin()->res_type << " - " <<$3->rbegin()->res_type;
			yyerror(" Semantyc error: type mismach!");
		}
	
	
		$$ = new list<line>(); $$->insert($$->end(), $1->begin(), $1->end()); $$->insert($$->end(), $3->begin(), $3->end()); 
		line aux;
	
		aux.res_addr = *(st->new_temp_addr(type_sizes[($1->rbegin()->res_type & 0xFF)])); 
	
		aux.res_type = $1->rbegin()->res_type; 
	
		aux.code = new reg_code(); 
		aux.code->code[0] = ($1->rbegin()->res_type & 0xFF) != 0x0003 ? string("sub") : string("subf");
		aux.code->code[1] = $1->rbegin()->res_addr;
		aux.code->code[2] = $3->rbegin()->res_addr;		
		aux.code->code[3] = aux.res_addr;
	
		aux.size = type_size[($1->rbegin()->res_type & 0xFF)];
		$$->push_back(aux);
		
		aux.code = 0;

	}
	
	|			_formula _MUL _formula		{
		if(($1->rbegin()->res_type & 0xFF) != ($3->rbegin()->res_type  & 0xFF))
		{
			cerr<<$1->rbegin()->res_type << " * " <<$3->rbegin()->res_type;
			yyerror(" Semantyc error: type mismach!");
		}
	
	
		$$ = new list<line>(); $$->insert($$->end(), $1->begin(), $1->end()); $$->insert($$->end(), $3->begin(), $3->end()); 
		line aux;
	
		aux.res_addr = *(st->new_temp_addr(type_sizes[($1->rbegin()->res_type & 0xFF)])); 
	
		aux.res_type = $1->rbegin()->res_type; 
	
		aux.code = new reg_code(); 
		aux.code->code[0] = ($1->rbegin()->res_type & 0xFF) != 0x0003 ? string("mul") : string("mulf"); 
		aux.code->code[1] = $1->rbegin()->res_addr;
		aux.code->code[2] = $3->rbegin()->res_addr;		
		aux.code->code[3] = aux.res_addr;
	
		aux.size = type_size[($1->rbegin()->res_type & 0xFF)];
		$$->push_back(aux);

		aux.code = 0;
		
	}
	
	|			_formula _DIV _formula		{
		if(($1->rbegin()->res_type & 0xFF) != ($3->rbegin()->res_type  & 0xFF))
		{
			cerr<<$1->rbegin()->res_type << " / " <<$3->rbegin()->res_type;
			yyerror(" Semantyc error: type mismach!");
		}
	
	
		$$ = new list<line>(); $$->insert($$->end(), $1->begin(), $1->end()); $$->insert($$->end(), $3->begin(), $3->end()); 
		line aux;
	
		aux.res_addr = *(st->new_temp_addr(type_sizes[($1->rbegin()->res_type & 0xFF)])); 
	
		aux.res_type = $1->rbegin()->res_type; 
	
		aux.code = new reg_code(); 
		aux.code->code[0] = ($1->rbegin()->res_type & 0xFF) != 0x0003 ? string("div") : string("divf"); 
		aux.code->code[1] = $1->rbegin()->res_addr;
		aux.code->code[2] = $3->rbegin()->res_addr;		
		aux.code->code[3] = aux.res_addr;
		
		aux.size = type_size[($1->rbegin()->res_type & 0xFF)];
		$$->push_back(aux);

		aux.code = 0;
		
	}
	
	|			_formula _MODULO _formula	{
		if(($1->rbegin()->res_type & 0xFF) != ($3->rbegin()->res_type  & 0xFF) && ($3->rbegin()->res_type  & 0xFF) != 0x0002)
		{
			cerr<<$1->rbegin()->res_type << " + " <<$3->rbegin()->res_type << " != 2";
			yyerror(" Semantyc error: type mismach!");
		}
	
	
		$$ = new list<line>(); $$->insert($$->end(), $1->begin(), $1->end()); $$->insert($$->end(), $3->begin(), $3->end()); 
		line aux;
	
		aux.res_addr = *(st->new_temp_addr(type_sizes[($1->rbegin()->res_type & 0xFF)])); 
	
		aux.res_type = $1->rbegin()->res_type; 
	
		aux.code = new reg_code(); 
		aux.code->code[0] = string("mod"); 
		aux.code->code[1] = $1->rbegin()->res_addr;
		aux.code->code[2] = $3->rbegin()->res_addr;		
		aux.code->code[3] = aux.res_addr;
	
		aux.size = type_size[($1->rbegin()->res_type & 0xFF)];
		$$->push_back(aux);

		aux.code = 0;
		
	}

	|			_formula _EQUAL _formula	{
		
		if(($1->rbegin()->res_type & 0xFF) != ($3->rbegin()->res_type  & 0xFF))
		{
			cerr<<$1->rbegin()->res_type << " == " <<$3->rbegin()->res_type;
			yyerror(" Semantyc error: type mismach!");
		}
	
	
		$$ = new list<line>(); $$->insert($$->end(), $1->begin(), $1->end()); $$->insert($$->end(), $3->begin(), $3->end()); 
		line aux1;
	
		aux1.res_addr = *(st->new_temp_addr(type_sizes[($1->rbegin()->res_type & 0xFF)])); 
	
		aux1.res_type = $1->rbegin()->res_type; 
	
		aux1.code = new reg_code(); 
		aux1.code->code[0] = string("sub"); 
		aux1.code->code[1] = $1->rbegin()->res_addr;
		aux1.code->code[2] = $3->rbegin()->res_addr;		
		aux1.code->code[3] = aux1.res_addr;
	
		aux1.size = type_size[($1->rbegin()->res_type & 0xFF)];
		$$->push_back(aux1);
		line aux2;
	
		aux2.res_addr = *(st->new_temp_addr(type_sizes[aux1.res_type])); 
	
		aux2.res_type = aux1.res_type; 
	
		aux2.code = new reg_code(); 
		aux2.code->code[0] = string("not"); 
		aux2.code->code[1] = aux1.res_addr;
		aux2.code->code[3] = aux2.res_addr;
	
		aux2.size = type_size[($1->rbegin()->res_type & 0xFF)];
		$$->push_back(aux2);
		
		aux1.code = 0;
		aux2.code = 0;
		
	}
	
	|			_formula _NEQ	_formula	{
		
		if(($1->rbegin()->res_type & 0xFF) != ($3->rbegin()->res_type  & 0xFF))
		{
			cerr<<$1->rbegin()->res_type << " != " <<$3->rbegin()->res_type;
			yyerror(" Semantyc error: type mismach!");
		}
	
	
		$$ = new list<line>(); $$->insert($$->end(), $1->begin(), $1->end()); $$->insert($$->end(), $3->begin(), $3->end()); 
		line aux;
	
		aux.res_addr = *(st->new_temp_addr(type_sizes[($1->rbegin()->res_type & 0xFF)])); 
	
		aux.res_type = $1->rbegin()->res_type; 
	
		aux.code = new reg_code(); 
		aux.code->code[0] = string("sub"); 
		aux.code->code[1] = $1->rbegin()->res_addr;
		aux.code->code[2] = $3->rbegin()->res_addr;		
		aux.code->code[3] = aux.res_addr;
		
		aux.size = type_size[($1->rbegin()->res_type & 0xFF)];
		$$->push_back(aux);
		
		aux.code = 0;
		
	}
	
	|			_formula _LESS 	_formula	{
		
		if(($1->rbegin()->res_type & 0xFF) != ($3->rbegin()->res_type  & 0xFF))
		{
			cerr<<$1->rbegin()->res_type << " < " <<$3->rbegin()->res_type;
			yyerror(" Semantyc error: type mismach!");
		}
	
	
		$$ = new list<line>(); $$->insert($$->end(), $1->begin(), $1->end()); $$->insert($$->end(), $3->begin(), $3->end()); 
		line aux1;
	
		aux1.res_addr = *(st->new_temp_addr(type_sizes[($1->rbegin()->res_type & 0xFF)])); 
	
		aux1.res_type = $1->rbegin()->res_type; 
	
		aux1.code = new reg_code(); 
		aux1.code->code[0] = string("sub"); 
		aux1.code->code[1] = $1->rbegin()->res_addr;
		aux1.code->code[2] = $3->rbegin()->res_addr;		
		aux1.code->code[3] = aux1.res_addr;
	
		aux1.size = type_size[($1->rbegin()->res_type & 0xFF)];
		$$->push_back(aux1);
		line aux2;
	
		aux2.res_addr = *(st->new_temp_addr(type_sizes[aux1.res_type])); 
	
		aux2.res_type = aux1.res_type; 
	
		aux2.code = new reg_code(); 
		aux2.code->code[0] = string("and"); 
		aux2.code->code[1] = aux1.res_addr;
		aux2.code->code[2] = string("$") + to_string((1 << (8 * (type_sizes[aux1.res_type]) - 1)));
		aux2.code->code[3] = aux2.res_addr;
		aux2.size = type_size[($1->rbegin()->res_type & 0xFF)];
		
		$$->push_back(aux2);
		
		aux1.code = 0;
		aux2.code = 0;
		
	}

	|			_formula _GR 	_formula	{
		
		if(($1->rbegin()->res_type & 0xFF) != ($3->rbegin()->res_type  & 0xFF))
		{
			cerr<<$1->rbegin()->res_type << " > " <<$3->rbegin()->res_type;
			yyerror(" Semantyc error: type mismach!");
		}
	
	
		$$ = new list<line>(); $$->insert($$->end(), $1->begin(), $1->end()); $$->insert($$->end(), $3->begin(), $3->end()); 
		line aux1;
	
		aux1.res_addr = *(st->new_temp_addr(type_sizes[($1->rbegin()->res_type & 0xFF)])); 
	
		aux1.res_type = $1->rbegin()->res_type; 
	
		aux1.code = new reg_code(); 
		aux1.code->code[0] = string("sub"); 
		aux1.code->code[1] = $1->rbegin()->res_addr;
		aux1.code->code[2] = $3->rbegin()->res_addr;		
		aux1.code->code[3] = aux1.res_addr;
	
		aux1.size = type_size[($1->rbegin()->res_type & 0xFF)];
		$$->push_back(aux1);
		line aux2;
	
		aux2.res_addr = *(st->new_temp_addr(type_sizes[aux1.res_type])); 
	
		aux2.res_type = aux1.res_type; 
	
		aux2.code = new reg_code(); 
		aux2.code->code[0] = string("nand"); 
		aux2.code->code[1] = aux1.res_addr;
		aux2.code->code[2] = string("$") + to_string((1 << (8 * (type_sizes[aux1.res_type]) - 1)));
		aux2.code->code[3] = aux2.res_addr;
		aux2.size = type_size[($1->rbegin()->res_type & 0xFF)];
		
		$$->push_back(aux2);
		
		aux1.code = 0;
		aux2.code = 0;
		
	}	
	
	|			_formula _AND	_formula	{
		if(($1->rbegin()->res_type & 0xFF) != ($3->rbegin()->res_type  & 0xFF))
		{
			cerr<<$1->rbegin()->res_type << " && " <<$3->rbegin()->res_type;
			yyerror(" Semantyc error: type mismach!");
		}
	
	
		$$ = new list<line>(); $$->insert($$->end(), $1->begin(), $1->end()); $$->insert($$->end(), $3->begin(), $3->end()); 
		string l1 = *(st->new_label());
		
		line aux0;
	
		aux0.res_addr = *(st->new_temp_addr(type_sizes[($1->rbegin()->res_type & 0xFF)])); 
	
		aux0.res_type = $1->rbegin()->res_type; 
	
		aux0.code = new reg_code(); 
		aux0.code->code[0] = string("mov"); 
		aux0.code->code[1] = $1->rbegin()->res_addr;		
		aux0.code->code[3] = aux0.res_addr;
		
		line aux1;
	
		aux1.res_addr = *(st->new_temp_addr(type_sizes[($1->rbegin()->res_type & 0xFF)])); 
	
		aux1.res_type = $1->rbegin()->res_type; 
	
		aux1.code = new reg_code(); 
		aux1.code->code[0] = string("jnz"); 
		aux1.code->code[1] = aux0.res_addr;		
		aux1.code->code[3] = l1;
		
		line aux2;
	
		aux2.res_addr = *(st->new_temp_addr(type_sizes[($1->rbegin()->res_type & 0xFF)])); 
	
		aux2.res_type = aux1.res_type; 
	
		aux2.code = new reg_code(); 
		aux2.code->code[0] = string("and"); 
		aux2.code->code[1] = $1->rbegin()->res_addr;
		aux2.code->code[2] = $3->rbegin()->res_addr;		
		aux2.code->code[3] = aux0.res_addr;
		
		line aux3;
	
		aux3.res_addr = *(st->new_temp_addr(type_sizes[($1->rbegin()->res_type & 0xFF)])); 
	
		aux3.res_type = $1->rbegin()->res_type; 
		aux3.label = l1;
	
		aux3.code = new reg_code(); 
		aux3.code->code[0] = string("mov"); 
		aux3.code->code[1] = aux1.res_addr;		
		aux3.code->code[3] = aux3.res_addr;
	
		aux3.size = type_size[($1->rbegin()->res_type & 0xFF)];
		$$->push_back(aux0);
		$$->push_back(aux1);
		$$->push_back(aux2);
		$$->push_back(aux3);
		
		aux0.code = 0;
		aux1.code = 0;
		aux2.code = 0;
		aux3.code = 0;

	}
	
	|			_formula _OR	_formula	{
		if(($1->rbegin()->res_type & 0xFF) != ($3->rbegin()->res_type  & 0xFF))
		{
			cerr<<$1->rbegin()->res_type << " || " <<$3->rbegin()->res_type;
			yyerror(" Semantyc error: type mismach!");
		}
	
	
		$$ = new list<line>(); $$->insert($$->end(), $1->begin(), $1->end()); $$->insert($$->end(), $3->begin(), $3->end()); 
		string l1 = *(st->new_label());
		
		line aux0;
	
		aux0.res_addr = *(st->new_temp_addr(type_sizes[($1->rbegin()->res_type & 0xFF)])); 
	
		aux0.res_type = $1->rbegin()->res_type; 
	
		aux0.code = new reg_code(); 
		aux0.code->code[0] = string("mov"); 
		aux0.code->code[1] = $1->rbegin()->res_addr;		
		aux0.code->code[3] = aux0.res_addr;
		
		
		line aux1;
	
		aux1.res_addr = *(st->new_temp_addr(type_sizes[($1->rbegin()->res_type & 0xFF)])); 
	
		aux1.res_type = $1->rbegin()->res_type; 
	
		aux1.code = new reg_code(); 
		aux1.code->code[0] = string("jz"); 
		aux1.code->code[1] = aux0.res_addr;		
		aux1.code->code[3] = l1;
		
		line aux2;
	
		aux2.res_addr = *(st->new_temp_addr(type_sizes[($1->rbegin()->res_type & 0xFF)])); 
	
		aux2.res_type = aux1.res_type; 
	
		aux2.code = new reg_code(); 
		aux2.code->code[0] = string("or"); 
		aux2.code->code[1] = $1->rbegin()->res_addr;
		aux2.code->code[2] = $3->rbegin()->res_addr;		
		aux2.code->code[3] = aux0.res_addr;
		
		line aux3;
	
		aux3.res_addr = *(st->new_temp_addr(type_sizes[($1->rbegin()->res_type & 0xFF)])); 
	
		aux3.res_type = $1->rbegin()->res_type; 
		aux3.label = l1;
	
		aux3.code = new reg_code(); 
		aux3.code->code[0] = string("mov"); 
		aux3.code->code[1] = aux1.res_addr;		
		aux3.code->code[3] = aux3.res_addr;
	
		aux3.size = type_size[($1->rbegin()->res_type & 0xFF)];
		$$->push_back(aux0);
		$$->push_back(aux1);
		$$->push_back(aux2);
		$$->push_back(aux3);
		
		aux0.code = 0;
		aux1.code = 0;
		aux2.code = 0;
		aux3.code = 0;

	}
	
	|			_NOT _formula				{
		
		$$ = new list<line>(); $$->insert($$->end(), $2->begin(), $2->end()); 
		line aux;
	
		aux.res_addr = *(st->new_temp_addr(type_sizes[($2->rbegin()->res_type & 0xFF)])); 
	
		aux.res_type = $2->rbegin()->res_type; 
	
		aux.code = new reg_code(); 
		aux.code->code[0] = string("not"); 
		aux.code->code[1] = $2->rbegin()->res_addr;		
		aux.code->code[3] = aux.res_addr;
	
		aux.size = type_size[($2->rbegin()->res_type & 0xFF)];
		$$->push_back(aux);
		
		aux.code = 0;

	}
	
	|			_POINT _formula				{
		
		$$ = new list<line>(); $$->insert($$->end(), $2->begin(), $2->end()); 
		line aux;
	
		aux.res_addr = *(st->new_temp_addr(type_sizes[($2->rbegin()->res_type & 0xFF)])); 
	
		aux.res_type = $2->rbegin()->res_type + 4; 
	
		aux.code = new reg_code(); 
		aux.code->code[0] = string("lea"); 
		aux.code->code[1] = $2->rbegin()->res_addr;		
		aux.code->code[3] = aux.res_addr;
	
		$$->push_back(aux);
		
		aux.code = 0;

	}
	
	|			_DEREF _formula				{
		
		if(!((($2->rbegin()->res_type & 0xFF) >= 4) && (($2->rbegin()->res_type & 0xFF) <= 7))) 
		{
			cerr<<" ~ " << ($2->rbegin()->res_type);
			yyerror(" Semantyc error: deref nonpointer!");
		}
		
		$$ = new list<line>(); $$->insert($$->end(), $2->begin(), $2->end()); 
		line aux;
	
		aux.res_addr = *(st->new_temp_addr(type_sizes[($2->rbegin()->res_type & 0xFF)])); 
	
		aux.res_type = $2->rbegin()->res_type - 4; 
	
		aux.code = new reg_code(); 
		aux.code->code[0] = string("mov"); 
		aux.code->code[1] = string("[") + $2->rbegin()->res_addr + string("]");		
		aux.code->code[3] = aux.res_addr;
	
		aux.size = 4;
		$$->push_back(aux);
		
		aux.code = 0;

	}
	
	|			_formula _LSB _formula _RSB	{
		
		if(!((($1->rbegin()->res_type & 0xFF) >= 4) && (($1->rbegin()->res_type & 0xFF) <= 7)) || (($3->rbegin()->res_type & 0xFF) != 2)) 
		{
			cerr << ($1->rbegin()->res_type) << "[" << ($3->rbegin()->res_type) <<"]";
			yyerror(" Semantyc error: wrong indexing mode!");
		}
		
		$$ = new list<line>(); $$->insert($$->end(), $3->begin(), $3->end()); $$->insert($$->end(), $1->begin(), $1->end()); 
		
		line aux2;
	
		aux2.res_addr = *(st->new_temp_addr(type_sizes[($3->rbegin()->res_type & 0xFF)])); 
	
		int saux = type_sizes[($3->rbegin()->res_type & 0xFF)];
	
		aux2.res_type = $1->rbegin()->res_type - 4; 
	
		aux2.code = new reg_code(); 
		aux2.code->code[0] = string("mul"); 
		aux2.code->code[1] = $3->rbegin()->res_addr;
		aux2.code->code[2] = string("$") + to_string(saux);		
		aux2.code->code[3] = *(st->new_temp_addr(type_sizes[($3->rbegin()->res_type & 0xFF)]));
	
		aux2.size = 4;
		$$->push_back(aux2);
		
		
		line aux;
	
		aux.res_addr = *(st->new_temp_addr(type_sizes[($1->rbegin()->res_type & 0xFF)])); 
	
		aux.res_type = $1->rbegin()->res_type - 4; 
	
		aux.code = new reg_code(); 
		aux.code->code[0] = string("mov"); 
		aux.code->code[1] = string("[") + $1->rbegin()->res_addr + string("+") + aux2.code->code[3] + string("]");		
		aux.code->code[3] = aux.res_addr;
	
		aux.size = 4;
		$$->push_back(aux);
		
		aux.code = 0;

	}

	;

_formulas:		/* empty */					{$$ = new list<line>();}
	|			_formulas _formula			{$$ = new list<line>(); $$->insert($$->end(), $1->begin(), $1->end()); $$->insert($$->end(), $2->begin(), $2->end());
	
		line aux8;
		aux8.res_addr = *(st->new_output_addr(type_sizes[($2->rbegin()->res_type & 0xFF)]));
		
		aux8.res_type = $2->rbegin()->res_type;
		aux8.code = new reg_code();
		
		aux8.code->code[0] = string("mov");
		aux8.code->code[1] = $2->rbegin()->res_addr;
		aux8.code->code[3] = aux8.res_addr;
		
		$$->push_back(aux8);
		
		aux8.code = 0;
	
	}
	;	
		
_expresion:		_SEMICOL					{$$ = new list<line>();}
	|			_declaration _SEMICOL		{$$ = new list<line>();}
	|			_formula _SEMICOL			{$$ = new list<line>(); $$->insert($$->end(), $1->begin(), $1->end());}
	|			_ID _EQ _formula _SEMICOL	{
		
		if(((*st)[$1].type & 0xFF) != ($3->rbegin()->res_type & 0xFF))
		{
			cerr<<(*st)[$1].type << " = " <<$3->rbegin()->res_type;
			yyerror(" Semantyc error: type mismach!");
		}
		
		
		$$ = new list<line>(); $$->insert($$->end(), $3->begin(), $3->end()); 
		line aux;	
		aux.res_addr = (*st)[$1].addr; 
		
		aux.res_type = (*st)[$1].type; 
		
		aux.code = new reg_code(); 
		aux.code->code[0] = string("mov"); 
		aux.code->code[1] = $3->rbegin()->res_addr; 
		aux.code->code[3] = (*st)[$1].addr;
		
		$$->push_back(aux);
		
		aux.code = 0;
		
	}
	
	|			_DEREF _ID _EQ _formula _SEMICOL					{
		
		
		if(((*st)[$2].type & 0xFF) - 4 != ($4->rbegin()->res_type & 0xFF))
		{
			cerr<<(*st)[$2].type - 4 << " = " <<$4->rbegin()->res_type;
			yyerror(" Semantyc error: type mismach!");
		}
		
		
		$$ = new list<line>(); $$->insert($$->end(), $4->begin(), $4->end()); 
		line aux;	
		aux.res_addr = (*st)[$2].addr; 
		
		aux.res_type = (*st)[$2].type; 
		
		aux.code = new reg_code(); 
		aux.code->code[0] = string("mov"); 
		aux.code->code[1] = $4->rbegin()->res_addr; 
		aux.code->code[3] = string("[") + (*st)[$2].addr + string("]");
		
		$$->push_back(aux);
		
		aux.code = 0;
		
	}
	
	|			_ID _DEREF _LSB _formula _RSB _EQ _formula _SEMICOL	{
		
		if(((*st)[$1].type & 0xFF) - 4 != ($7->rbegin()->res_type & 0xFF))
		{
			cerr<<(*st)[$1].type - 4 << " = " <<$7->rbegin()->res_type;
			yyerror(" Semantyc error: type mismach!");
		}
		
		
		if(($4->rbegin()->res_type & 0xFF) != 0x0002)
		{
			cerr<<(*st)[$1].type << "[" <<$4->rbegin()->res_type << "]";
			yyerror(" Semantyc error: wrong indexing mode!");
		}
		
		$$ = new list<line>(); $$->insert($$->end(), $7->begin(), $7->end()); $$->insert($$->end(), $4->begin(), $4->end()); 
		line aux;	
		aux.res_addr = (*st)[$1].addr; 
		
		aux.res_type = (*st)[$1].type; 
		
		aux.code = new reg_code(); 
		aux.code->code[0] = string("mov"); 
		aux.code->code[1] = $7->rbegin()->res_addr; 
		aux.code->code[3] = string("[") + (*st)[$1].addr + string("+") + $4->rbegin()->res_addr + string("]");
		
		$$->push_back(aux);
		
		aux.code = 0;
		
	}
	
	|			_ID _LPAR _formulas _RPAR	_SEMICOL				{
		
		if(((*st)[$1].type & 0xFF) != 0x0004)
		{
			cerr<<(*st)[$1].type << "()";
			yyerror(" Semantyc error: non callable()");
		}
		
		$$ = new list<line>(); $$->insert($$->end(), $3->begin(), $3->end());
	
		line aux;
		aux.res_addr = string("none");
		
		aux.res_type = 0;
		
		aux.code = new reg_code();
		
		aux.code->code[0] = string("call");
		aux.code->code[3] = (*st)[$1].value;
		
		$$->push_back(aux);
		
		aux.code = 0;
		st->current_output_pointer = 0;
	
	}
	
	|			_ASM _STRINGLIT										{
		$$ = new list<line>();
		line aux;
	
		aux.res_addr = string("none"); 
	
		aux.res_type = -1; 
	
		aux.code = new reg_code(); 
		aux.code->code[0] = string("asm"); 
		aux.code->code[3] = (*st)[$2].value;
	
		$$->push_back(aux);
		
		aux.code = 0;
	}
	
	;

	
expresions:		/* empty */					{$$ = new list<line>();}
	|			expresions _expresion		{$$ = new list<line>(); $$->insert($$->end(), $1->begin(), $1->end()); $$->insert($$->end(), $2->begin(), $2->end());}
	;

_statement:		_expresion											{$$ = new list<line>(); $$->insert($$->end(), $1->begin(), $1->end());}
	|			_IF _formula _SEMICOL expresions _FI _SEMICOL		{
		$$ = new list<line>(); $$->insert($$->end(), $2->begin(), $2->end());

		string l1_aux = *(st->new_label());
		
		line aux0;
	
		aux0.res_addr = *(st->new_temp_addr(type_sizes[($2->rbegin()->res_type & 0xFF)])); 
	
		aux0.res_type = $2->rbegin()->res_type; 
	
		aux0.code = new reg_code(); 
		aux0.code->code[0] = string("jz"); 
		aux0.code->code[1] = $2->rbegin()->res_addr;		
		aux0.code->code[3] = l1_aux;
		
		$$->push_back(aux0);
		
		$$->insert($$->end(), $4->begin(), $4->end());
		line aux1;
	
		aux1.res_addr = string("none"); 
	
		aux1.res_type = -1; 
	
		aux1.code = 0;
		aux1.label = l1_aux;
		
		$$->push_back(aux1);
		
		aux0.code = 0;
	
	}
	
	|			_IF _formula _SEMICOL expresions _ELSE _SEMICOL expresions _FI _SEMICOL		{
		$$ = new list<line>(); $$->insert($$->end(), $2->begin(), $2->end());

		string l1_aux = *(st->new_label());
		string l2_aux = *(st->new_label());
		
		
		line aux0;
	
		aux0.res_addr = *(st->new_temp_addr(type_sizes[($2->rbegin()->res_type & 0xFF)])); 
	
		aux0.res_type = $2->rbegin()->res_type; 
	
		aux0.code = new reg_code(); 
		aux0.code->code[0] = string("jz"); 
		aux0.code->code[1] = $2->rbegin()->res_addr;		
		aux0.code->code[3] = l1_aux;
		
		$$->push_back(aux0);
		
		$$->insert($$->end(), $4->begin(), $4->end());
		
		
		line aux2;
	
		aux2.res_addr = string("none"); 
	
		aux2.res_type = -1; 
	
		aux2.code = new reg_code(); 
		aux2.code->code[0] = string("jmp"); 
		aux2.code->code[3] = l2_aux;
		
		$$->push_back(aux2);
		
		aux2.code = 0;
		
		line aux1;
	
		aux1.res_addr = string("none"); 
	
		aux1.res_type = -1; 
	
		aux1.code = 0;
		aux1.label = l1_aux;
		
		$$->push_back(aux1);
		
		aux0.code = 0;
	
		$$->insert($$->end(), $7->begin(), $7->end());
		
		line aux3;
	
		aux3.res_addr = string("none"); 
	
		aux3.res_type = -1; 
	
		aux3.code = 0;
		aux3.label = l2_aux;
		
		$$->push_back(aux3);
		
	}
	
	|			_WHILE _formula _SEMICOL expresions _ELIHW	_SEMICOL						{
		
		$$ = new list<line>(); 
	
		string l1_aux = *(st->new_label());
		string l2_aux = *(st->new_label());
			
		line aux3;
	
		aux3.res_addr = string("none"); 
	
		aux3.res_type = -1; 
	
		aux3.code = 0;
		aux3.label = l1_aux;
		
		$$->push_back(aux3);
		
		$$->insert($$->end(), $2->begin(), $2->end());
		
		
		line aux0;
	
		aux0.res_addr = string("none"); 
	
		aux0.res_type = -1; 
	
		aux0.code = new reg_code(); 
		aux0.code->code[0] = string("jz"); 
		aux0.code->code[1] = $2->rbegin()->res_addr;		
		aux0.code->code[3] = l2_aux;
		
		$$->push_back(aux0);
		
		$$->insert($$->end(), $4->begin(), $4->end());
		
		
		line aux2;
	
		aux2.res_addr = string("none"); 
	
		aux2.res_type = -1; 
	
		aux2.code = new reg_code(); 
		aux2.code->code[0] = string("jmp"); 
		aux2.code->code[3] = l1_aux;
		
		$$->push_back(aux2);
		
		aux2.code = 0;
		
		line aux1;
	
		aux1.res_addr = string("none"); 
	
		aux1.res_type = -1; 
	
		aux1.code = 0;
		aux1.label = l2_aux;
		
		$$->push_back(aux1);
		
		aux0.code = 0;
		
	}
	;
	
statements:		/*empty*/											{$$ = new list<line>();}
	|			statements	_statement								{$$ = new list<line>(); $$->insert($$->end(), $1->begin(), $1->end()); $$->insert($$->end(), $2->begin(), $2->end());}
	
program:		program _ID _in_params _SEMICOL _START statements _END		{(*st)[$2].type = 0x0004;	(*st)[$2].addr = *(st->new_addr(4)); $$ = new list<line>(); line aux; aux.code = 0; aux.label = string("\n") + (*st)[$2].value; $$->push_back(aux); $$->insert($$->end(), $6->begin(), $6->end()); line aux2; aux2.code = new reg_code(); aux2.code->code[0] = string("ret"); $$->push_back(aux2); aux2.code = 0; final_code.insert(final_code.end(), $$->begin(), $$->end()); final_symtabs.insert(pair<string, symtab*>((*st)[$2].value, st)); st = new symtab(); 	st->name = string("p") + to_string(num_symtabs++);}
	|			program _ID _SEMICOL _START statements _END					{(*st)[$2].type = 0x0004; 	(*st)[$2].addr = *(st->new_addr(4)); $$ = new list<line>(); line aux; aux.code = 0; aux.label = string("\n") + (*st)[$2].value; $$->push_back(aux); $$->insert($$->end(), $5->begin(), $5->end()); line aux2; aux2.code = new reg_code(); aux2.code->code[0] = string("ret"); $$->push_back(aux2); aux2.code = 0; final_code.insert(final_code.end(), $$->begin(), $$->end()); final_symtabs.insert(pair<string, symtab*>((*st)[$2].value, st)); st = new symtab();	st->name = string("p") + to_string(num_symtabs++);}
	|			/* empty */													{;}			
	;

file:			program												{;}
	;
	
%%

int yyerror(string s)
{
  extern int yylineno;	// defined and maintained in lex.c
  extern char *yytext;	// defined and maintained in lex.c
  
  cerr << "ERROR: " << s << " at symbol \"" << yytext;
  cerr << "\" on line " << yylineno << endl;
  exit(1);
}

int yyerror(const char *s)
{
  return yyerror(string(s));
}
