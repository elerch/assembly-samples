# gold linker has smallest binary size others probably can emit smaller
# binaries with custom linker scripts. Their default ones
# are not optimized for hello world programs
# as --64 hello-amd64.s && ld.gold -s -n -o hello a.out
.data                                   # section declaration
msg:
        .string "All your codebase is belong to us\n"       # output string

len = . - msg                           # length of output string

.text                                   # section declaration
                        # we must export the entry point to the ELF linker or
    .global _start      # loader. They conventionally recognize _start as their
                        # entry point. Use ld −e foo to override the default.

# https://stackoverflow.com/questions/3683144/linux-64-command-line-parameters-in-assembly
# https://wiki.cdot.senecacollege.ca/wiki/X86_64_Register_and_Instruction_Quick_Start
square:
        pushq    %rbp            # Save rbp - this must be restored at end of call
        movq     %rsp, %rbp      # Update base pointer from current stack pointer
        movq     %rdi,-8(%rbp)   # Move 1st argument (rdi) into stack memory
                                 # This is not strictly necessary here, but
                                 # is done as a way to demonstrate generic handling
                                 # of arguments
        movq     -8(%rbp), %rax  # Move stack memory into rax for multiplication
        imulq    -8(%rbp), %rax  # Do multiplication
                                 # The above 3 instructions could be done with the
                                 # following 2 instructions instead in such a simple
                                 # case:
        #movq     %rdi, %rax      # Move 1st argument (rdi) to rax for processing

        #imulq    %rax, %rax  # Do multiplication
        popq     %rbp            # Restore rbp for return (eax/rax has return val)
        retq                     # Return

_start:

# write our string to stdout
# https://man7.org/linux/man-pages/man2/syscall.2.html
# https://filippo.io/linux-syscall-table/
# https://github.com/torvalds/linux/blob/master/arch/x86/entry/syscalls/syscall_64.tbl
        movq    $1,%rax         # system call number (sys_write)
        movq    $1,%rdi         # first argument: file handle (stdout)
        movq    $msg,%rsi       # second argument: pointer to message to write
        movq    $len,%rdx       # third argument: message length
        syscall                 # call kernel
                                # argc is stored in (%rsp)
                                # this is an eightbyte according to table 3.9
                                # of the System V AMD64 psABI
                                # https://gitlab.com/x86-psABIs/x86-64-ABI
                                #
                                # It is a bit questionable here whether the
                                # upper 32 bits of rdi are cleared when moving
                                # into edi, but this instruction is generated
                                # from compilers, which leads me to "yes".
                                # Documentation also states this (with some exceptions):
                                #
                                # When executing MOV Reg, Sreg, the processor
                                # copies the content of Sreg to the 16 least
                                # significant bits of the general-purpose register.
                                # The upper bits of the destination register
                                # are zero for most IA-32 processors (Pentium 
                                # Pro processors and later) and all Intel 64
                                # processors, with the exception that bits 31:16
                                # are undefined for Intel Quark X1000 processors,
                                # Pentium and earlier processors.
                                #
                                # Above language pulled from MOV documentation
                                # in Vol 2B, Chapter 4:
                                # https://www.intel.com/content/dam/develop/public/us/en/documents/325462-sdm-vol-1-2abcd-3abcd.pdf
                                #
        movl    (%rsp),%edi     # See: https://wiki.cdot.senecacollege.ca/wiki/X86_64_Register_and_Instruction_Quick_Start
        callq   square          # Square our argc, result in %eax
        movq    %rax,%rdi       # mov %eax to the first syscall argument (exit code)
        movq    $60,%rax        # system call number (sys_exit)
        syscall                 # call kernel and exit
