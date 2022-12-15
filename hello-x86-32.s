# as --32 hello-x86-32.s && ld.gold -m32 -s -n -o hello a.out
.data                                   # section declaration
msg:
        .string "All your codebase is belong to us\n"       # our dear string

len = . - msg                           # length of our dear string

.text                                   # section declaration
                        # we must export the entry point to the ELF linker or
    .global _start      # loader. They conventionally recognize _start as their
                        # entry point. Use ld −e foo to override the default.

# https://stackoverflow.com/questions/3683144/linux-64-command-line-parameters-in-assembly
# https://wiki.cdot.senecacollege.ca/wiki/X86_64_Register_and_Instruction_Quick_Start
square:
        pushl    %ebp            # Save ebp - this must be restored at end of call
        movl     %esp, %ebp      # Update base pointer from current stack pointer
                                 # 8 bytes above ebp is our first parameter
                                 # (4 bytes above is our return address)
                                 # In this case, _start is not explictly adding
                                 # our parameter to the stack as that is being
                                 # done prior to us being exec'd in the first place
                                 # There is a good diagram of this in the calling
                                 # convention section on https://www.cs.virginia.edu/~evans/cs216/guides/x86.html
        movl     8(%ebp), %eax   # Move stack memory into eax for multiplication
        imull    8(%ebp), %eax   # Do multiplication
        popl     %ebp            # Restore rbp for return (eax/rax has return val)
        ret                      # Return

_start:

# Linux syscalls for 32 bit:
# https://github.com/torvalds/linux/blob/master/arch/x86/entry/syscalls/syscall_32.tbl
# write our string to stdout
        movl    $4,%eax         # system call number (sys_write)
        movl    $1,%ebx         # first argument: file handle (stdout)
        movl    $msg,%ecx       # second argument: pointer to message to write
        movl    $len,%edx       # third argument: message length
        int     $0x80           # call kernel and exit
                                # argc is stored in (%esp)
        movl    (%esp),%edi     # See: https://wiki.cdot.senecacollege.ca/wiki/X86_64_Register_and_Instruction_Quick_Start
                                # The above instruction is part of the calling convention,
                                # so left here, but it's useless/unnecessary and can be removed
        call    square          # Square our argc, result in %eax
        movl    %eax,%ebx       # mov %eax to the first syscall argument (exit code)
        movl    $1,%eax         # system call number (sys_exit)
        int     $0x80           # call kernel
