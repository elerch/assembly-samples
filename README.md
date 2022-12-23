Hello world, in Linux, for multiple architectures
=================================================

Architectures
=============

* x86-32
* amd64 (aka x86-64)
* arm7l (32 bit arm)
* aarch64 (64 bit arm)
* riscv64 (RISC-V 64 bit)


Notes
=====

I wanted to create a "real" sample of assembly in different architectures. By
"real", the program should do some actual work, and interface with the operating
system. Real programs typically have "functions", so our program should do that
as well.

This repository serves to provide examples of assembly language implementations
of a hello world program. The program prints a hard coded string, then exits.
The exit code is calculated based on the square of the arguments (think argc
in C). The argument count is inserted into the stack by Linux, and is described
well at [LWN](https://lwn.net/Articles/631631/). Doing this will use a function
to square our argc and interface with Linux to print our string and set the
correct exit code.

Linkers typically set the entry point of the program based on a symbol named
"\_start". In C, the \_start entry point will perform some logistical work
required by the compiler, then transfer control to main. Here in assembly,
we can start work directly.

I have tried to fully annotate each architecture's assembly with suitable
references. I have also left some optimizations out. Transferring function
arguments to memory only to turn around and load them into registers makes
little sense; however, this is a useful pattern, so I have not optimized these
patterns.

