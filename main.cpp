#include "utils.hpp"
#include "parser.tab.hpp"


int num_symtabs = 1;

extern symtab* st;

extern FILE *yyin, *yyout;
extern int yyparse();

extern list<line> final_code; 
extern map<string, symtab*> final_symtabs;


using namespace std;

int main(int argc, char** argv )
{
	cout<<"\n\n";
	
	st->name = string("p0");
	
	++argv, --argc;
	if ( argc > 0 )
		yyin = fopen( argv[0], "r" );
	else
		cerr << "No input file!";

	yyparse();
	
	cout<<"Symbol tables: \n\n";
	for (auto itr = final_symtabs.begin(); itr != final_symtabs.end(); ++itr)
		cout << itr->first << ":\n" << *(itr->second) << endl;
	
	cout<<"Three address code: \n";
	for (auto itr = final_code.begin(); itr != final_code.end(); ++itr)
		if (itr != final_code.end())
		{
			cout << *itr;
		}	
	
	
	string text = string("\t.file \"") + string(argv[0]) + string("\"\n\n") + data_asm(final_symtabs) + text_asm(final_code);
	cout << "\n\nGAS code: \n" << text;
	
	ofstream ofile;
	ofile.open("__temp.s");
	ofile << text << endl;
	ofile.close();
	
	return 0;

}