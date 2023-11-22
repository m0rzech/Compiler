BISON=bison
FLEX=flex
GCC=gcc

kompilator: kompilatorP.o kompilatorL.o
	$(GCC) -o kompilator kompilatorP.o kompilatorL.o -lm -lfl

kompilatorP.o: kompilatorP.y ST.h SM.h CG.h
	$(BISON) -d kompilatorP.y
	$(GCC) -c -o kompilatorP.o kompilatorP.tab.c

kompilatorL.o: kompilatorL.l
	$(LEX) kompilatorL.l
	$(GCC) -c -o kompilatorL.o lex.yy.c

clear:
	rm kompilator kompilatorP.tab.h kompilatorP.o kompilatorL.o kompilatorP.tab.c lex.yy.c #a.out kompilatorP.tab.h


