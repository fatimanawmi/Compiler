yacc -d -y 1705093.y
g++ -w -c -o y.o y.tab.c
flex 1705093.l
g++ -w -c -o l.o lex.yy.c
g++ 1705093.cpp -c
g++ 1705093.o y.o l.o -lfl
./a.out input.c
