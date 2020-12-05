.POSIX:
.PHONY: all clean

all: sar_split

clean:
	rm -f *.o
	rm -f sar_split

sar_split: splitter.o
	$(CC) $^ -o $@ 
	sudo setcap cap_sys_ptrace=eip ./sar_split
