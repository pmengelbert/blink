.PHONY: clean push

zblink: zblink.o
	PATH=/usr/arm-linux-gnueabihf/bin ld -o zblink zblink.o

zblink.o: clean
	PATH=/usr/arm-linux-gnueabihf/bin as -o zblink.o blink.s

clean:
	rm zblink zblink.o || true

push: zblink
	scp zblink pi@10.1.10.10:blink
