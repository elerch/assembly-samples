// ARM 7l - 32 bit arm. Used on 32 bit hardware or 64 bit hardware with 32 bit
// linux (e.g. most raspbian as of 2022)
//
// gold linker has smallest binary size. others probably can emit smaller
// binaries with custom linker scripts. Their default ones
// are not optimized for hello world programs
// as hello-arm7l.s && ld.gold -s -n -o hello a.out
.data                                   // section declaration
msg:
        .string "All your codebase is belong to us\n"       // output string

len = . - msg                           // length of output string

.text                                   // section declaration
                        // we must export the entry point to the ELF linker or
    .global _start      // loader. They conventionally recognize _start as their
                        // entry point. Use ld −e foo to override the default.

square:
        // Function entry
        sub      sp, sp, #4      // Move stack pointer for locals

        // Function arguments
        str      r0, [sp]        // Store return address in stack memory
                                 // not specifically necessary, but good safety
                                 // mechanism. We could instead simply ignore
                                 // the str/ldr operations here and just go
                                 // for it
                                 //
                                 // This would remove memory access completely,
                                 // but this allows us to demonstrate the
                                 // general pattern we can use for functions


        // Function body
        ldr      r0, [sp]        // Load first operand with our argument
        mul      r1, r0, r0      // Do the multiplication
        mov      r0, r1          // Move result to return register

        // Function exit
        add      sp, sp, #4      // Restore stack pointer
        bx       lr              // Return

_start:

// https://man7.org/linux/man-pages/man2/syscall.2.html
// Syscall numbers captured from https://syscalls.w3challs.com/?arch=arm_strong
// arm syscall table here:
// https://github.com/torvalds/linux/blob/v4.19/arch/arm/tools/syscall.tbl
        # Hello world to stdout
        mov     r7, #4          // System call (sys_write)
        mov     r0, #1          // first argument: file handle (stdout)
        ldr     r1, =msg        // second argument: pointer to message to write
        ldr     r2, =len        // third argument: message length
        swi     #0              // call kernel. We are using Linux's EABI -
                                // the embedded application binary interface
                                // which is more consistent with the way it is
                                // done in other architectures

        // Square argc
        ldr     r0, [sp]        // argc is on the stack
                                // this is an eightbyte according to table 3.9
                                // of the System V AMD64 psABI
                                // https://gitlab.com/x86-psABIs/x86-64-ABI
        bl      square          // Square our argc, result in r0
                                // r0 will also be the first argument to sys_exit
                                // so no need to load

        // exit
        mov     r7, #1          // system call number (sys_exit)
        swi     #0              // call kernel and exit
