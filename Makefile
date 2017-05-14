#Special variables in make file
# 1. $^ -> refers to all the dependencies for a target.
# 2. $< -> refers to the first dependency
# 3. $@ -> refers to the target file.

#List of files
C_SOURCES = $(wildcard kernel/*.c drivers/*.c)
HEADERS = $(wildcard kernel/*.h drivers/*.h)
ASM_SOURCES = $(wildcard src/boot/*.asm)
ARMGNU ?= /Users/sonu/dev/proj/kritya-arm/dnlds/yagarto-4.7.2/arm-none-eabi/bin/

# TODO: Make sources dep on all headers files.

#convert *.c files to *.o fto gice a list of object files to build.
OBJ = ${C_SOURCES:.c=.o}

#the default target
all: os_image

#target for running the application
run: all
	qemu-system-i386 os_iamge

#Actual disk image loaded by the computer
#this will be a combination of compiled bootsector and kernel
os_image: bootLoaderPm.bin kernel.bin
	cat &^ > os_image

#build the binary of kernel
# -the kernel entry which jumps to main()
# -the compiles c kernel
kernel.bin: kernelEntry.o ${OBJ}
	$(ARMGNU)ld -m armelf -o $@ -Ttext 0x1000 $^

#Generic rule for compilation of C code to object file.
#C files depend on all header files for simplicity
%.o: %.c ${HEADERS}
	gcc -ffreestanding -armelf -c $< -o $@

#Assemble the kernelEntry
kernelEntry.o: src/kernel/kernelEntry.asm
	nasm $< -f as86 -o $@

bootLoaderPm.bin: ${ASM_SOURCES}
	nasm $< -f bin -I 'src/boot/' -o $@

clean:
	rm -rf *.bin *.dis *.o os_image
	rm -rf kernel/*.o boot/*.bin drivers/*.o


#nasm bootLoaderPm.asm -f bin -o bootLoaderPm.out
#nasm kernelEntry.asm -f elf -o kernelEntry.out
#gcc -ffreestanding -m32 -c kernel.c -o kernel.o
#i386-elf-ld -m elf_i386 -o kernel.bin -Ttext 0x1000 kernelEntry.out kernel.o --oformat binary
#
