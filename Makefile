#Special variables in make file
# 1. $^ -> refers to all the dependencies for a target.
# 2. $< -> refers to the first dependency
# 3. $@ -> refers to the target file.

#List of files
C_SOURCES = $(wildcard kernel/*.c drivers/*.c)
HEADERS = $(wildcard kernel/*.h drivers/*.h)

# TODO: Make sources dep on all headers files.

#convert *.c files to *.o fto gice a list of object files to build.
OBJ = ${C_SOURCES:.c=.o}

#the default target
all: os_image

#target for running the application
run: all
	qemu-system-x86_64 os_iamge

#Actual disk image loaded by the computer
#this will be a combination of compiled bootsector and kernel
os_image: src/boot/bootLoaderPm.bin src/kernel/kernel.bin
	cat &^ > os_image

#build the binary of kernel
# -the kernel entry which jumps to main()
# -compiles compiles c kernel
kernel.bin: src/kernel/kernelEntry.o src/kernel/kernel.o
	ld -o $@ -Ttext 0x1000 $^ --oformat binary

#Generic rule for compilation of C code to object file.
#C files depend on all header files for simplicity
%.o: %.c ${HEADERS}
	gcc -ffreestanding -c $< -o $@

#Assemble the kernelEntry
%.o: %.asm
	nasm $< -f elf64 -o $@

%.bin: %.asm
	nasm $< -f bin -I 'src/boot/' -o $@

clean:
	rm -rf *.bin *.dis *.o os_image
	rm -rf src/kernel/*.o src/boot/*.bin src/drivers/*.o
