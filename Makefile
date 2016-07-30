#Special variables in make file
# 1. $^ -> refers to all the dependencies for a target.
# 2. $< -> refers to the first dependency
# 3. $@ -> refers to the target file.

#the default target
all: kernel.bin

#link the kernel files together.
kernel.bin : kernelEntry.o kernel.o
	ld -m elf_i386 -o kernel.bin -Ttext 0x1000 $^ --oformat binary

# Build the kernel object file
kernel.o : kernel.c
	gcc -ffreestanding -m32 -c $< -o $@

# Build the kernel entry object file.
kernelEntry.o : kernelEntry.asm
	nasm $< -f elf -o $@


clean:
	rm -f *.bin *.o