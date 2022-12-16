# gold linker has smallest binary size. others probably can emit smaller
# binaries with custom linker scripts. Their default ones
# are not optimized for hello world programs
# as hello-riscv64.s && ld -s -n -o hello a.out
.data                                   # section declaration
msg:
        .string "All your codebase is belong to us\n"       # output string

len = . - msg                           # length of output string

.text                                   # section declaration
                        # we must export the entry point to the ELF linker or
    .global _start      # loader. They conventionally recognize _start as their
                        # entry point. Use ld −e foo to override the default.

# RISC-V register reference:
# https://xuanxuanblingbling.github.io/assets/pic/riscv/register.png
# RISC-V instruction cheat sheet:
# https://risc-v.guru/instructions/

square:
        # Function entry
        addi     sp, sp, -32     # Move stack pointer for locals
                                 # 32 bytes gives us (32/8 =) 4 64 slots to use
                                 # We will only store our return address/frame pointer
        sd       ra, 24(sp)      # Store return address in stack memory
        sd       s0, 16(sp)      # Store frame pointer in stack memory
        addi     s0, sp, 32      # Capture original stack pointer in s0
                                 # Interpret as s0 = sp + 32

        # Function arguments
        sw       a0, -20(s0)     # Save first argument (num) to stack
                                 # Be aware that we're now subtracting rather
                                 # than adding because we just changed s0
                                 # A long version of this would be sd a0, -24(s0)

        # Function body
        lw       a0, -20(s0)     # Load first argument (num) from stack
                                 # This save/load is to make sure we have a copy
                                 # of the original argument, which is not important
                                 # here, but would be if this was a more serious
                                 # function. We could just have easily comment
                                 # out both instructions and avoid memory access

        mulw     a0, a0, a0      # Actually do the multiplication.

        # Function exit
        ld       ra, 24(sp)      # Restore return address from stack
        ld       s0, 16(sp)      # Restore frame pointer from stack memory
        addi     sp, sp, 32      # Restore stack pointer
        ret                      # Return

_start:

# https://man7.org/linux/man-pages/man2/syscall.2.html
# https://github.com/torvalds/linux/blob/v4.17/include/uapi/asm-generic/unistd.h
        # Hello world to stdout
        li      a7, 64          # System call (sys_write)
        li      a0, 1           # first argument: file handle (stdout)
        lla     a1, msg         # second argument: pointer to message to write
        li      a2, len         # third argument: message length
        scall                   # call kernel

        # Square argc
        ld      a0, (sp)        # argc is on the stack
                                # https://www.reddit.com/r/RISCV/comments/p2na17/command_line_arguments_in_assembly/
        call    square          # Square our argc, result in a0
                                # a0 will also be the first argument to sys_exit
                                # so no need to load

        # exit
        li      a7, 93          # system call number (sys_exit)
        scall                   # call kernel and exit
