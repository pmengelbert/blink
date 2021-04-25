.PHONY: clean

zblink: zblink.o
	ld -o zblink zblink.o

zblink.o: clean
	as -o zblink.o blink.s

clean:
	rm zblink zblink.o || true

