#!/bin/sh
ref:
	https://www.cnblogs.com/strugglesometimes/p/4233331.html
	https://www.cnblogs.com/strugglesometimes/p/4233331.html

#first of all
#make: as86: Command not finded
yum install dev86
yum install glibc.i686
yum install glibc-devel.i686
yum install libgcc.i686
#调整警告级别
find ./ -name Makefile -type f -exec sed -i 's/-Wall/-w/g' {} \;

#gas -c -o boot/head.o boot/head.s
#make: gas: Command not found
find ./ -name Makefile -type f -exec sed -i 's/gas/as/g' {} \;

#ot/head.s:43: Error: unsupported instruction `mov'
#这是由于在64位机器上编译的原因，需要告诉编译器，我们要编译32位的code，在所有Makefile的AS后面添加 --32，CFLAGS中加-m32
find ./ -name Makefile -type f -exec sed -i 's/as$/as --32/g' {} \;
find ./ -name Makefile -type f -exec sed -i 's/-O/-O -m32/g' {} \;

#boot/head.s: Assembler messages:
#boot/head.s:231: Error: alignment not a power of 2
#把align n -> align 2^n
sed -i 's/align 2/align 4/g' boot/head.s
sed -i 's/align 3/align 8/g' boot/head.s

#gcc: error: unrecognized command line option ‘-fcombine-regs’
#gcc: error: unrecognized command line option ‘-mstring-insns’
#把这两个删掉即可，现在GCC已经不支持了
find ./ -name Makefile -type f -exec sed -i 's/-fcombine-regs//g' {} \;
find ./ -name Makefile -type f -exec sed -i 's/-mstring-insns//g' {} \;

sed -i 's/int fork/\/\/&/'
sed -i 's/int pause/\/\/&/'
sed -i 's/int sync/\/\/&/'
sed -i 's/int printf/\/\/&/'

#init/main.c:179:12: error: static declaration of ‘printf’ follows non-static declaration
sed -i 's/\(\s\+\)printf/\1printw/g' init/main.c

#最新的GCC规定输入或输出寄存器不能出现在可能被修改的寄存器中，
#目前看到网上的方法是把所有类似问题的可能被修改的寄存器全部删掉
find -type f -exec sed -i 's/:\"\w\{2\}\"\(,\"\w\{2\}\"\)*)/:) /g' {} \;

#make[1]: gld: Command not found
find ./ -name Makefile -type f -exec sed -i 's/gld/ld/g' {} \;
find ./ -name Makefile -type f -exec sed -i 's/=ld$/=ld -m elf_i386 /g' {} \;

#func x multi define
sed -i 's/^extern inline/static inline/g' include/asm/segment.h include/string.h include/linux/mm.h

#../include/asm/segment.h:27: Error: bad register name `%bpl'
sed -i '27 s/\"r\"/\"q\"/' include/asm/segment.h
sed -i '5 s/\"=r\"/\"=q\"/' include/asm/segment.h

find ./ -name Makefile -type f -exec sed -i 's/gar/ar/g' {} \;

find ./ -name Makefile -type f -exec sed -i 's/-O/-O -fleading-underscore/g' {} \;

sed -i 's/^extern inline/static inline/g' kernel/blk_drv/blk.h

#Non-xxx
	#在linux0.12根目录下面的Makefile，修改ld命令，在其后面加上-Ttext 0x0 -e startup_32
	#还是失败，直接屏蔽check code.
