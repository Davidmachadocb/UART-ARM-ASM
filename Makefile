all: exe

exe: main.o
	gcc -o $@ $+
	
main.o: main.s
	as -o $@ $<
	
clean:
	rm -vf exe *.o
