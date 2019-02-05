CC			:= g++
LEX     	:= flex
YACC    	:= bison -y

BDIR		:= ../bin

	
$(BDIR)/compiler: 				lexer.yy.cpp parser.tab.hpp parser.tab.cpp main.cpp utils.hpp utils.cpp
	$(CC) $^ -o $@

parser.tab.hpp:	parser.tab.cpp	
	
parser.tab.cpp:	parser.y
	$(YACC) -d -o'$@' $^
	
lexer.yy.cpp:					lexer.lex
	$(LEX) -o'$@' $^	
	
