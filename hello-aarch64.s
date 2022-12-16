// ARM 8
// gold linker has smallest binary size. others probably can emit smaller
// binaries with custom linker scripts. Their default ones
// are not optimized for hello world programs
// as -march=armv8-a hello-aarch64.s && ld.gold -s -n -o hello a.out
//
// Arm instruction set reference:
//   https://developer.arm.com/documentation/100076/0100/A64-Instruction-Set-Reference
//
// AArch64 has thirty-one 64-bit general-purpose registers X0-X30,
// the bottom halves of which are accessible as W0-W30
//
// Most A64 integer instructions can operato on either type of register
.data                                   // section declaration
msg:
        .string "All your codebase is belong to us\n"       // output string

len = . - msg                           // length of output string

.text                                   // section declaration
                        // we must export the entry point to the ELF linker or
    .global _start      // loader. They conventionally recognize _start as their
                        // entry point. Use ld −e foo to override the default.

square:
        // We're using 32 bit register variants here as eventually we will
        // return this as the exit syscall, and that syscall will want
        // a 32 bit return code
        //
        // Function entry
        sub      sp, sp, #16     // Move stack pointer for locals
                                 // Interpret as "sp = sp - 16"
                                 // 16 bytes will take 2 64 bit locals or
                                 // 4 32 bit locals

        // Function arguments
        str      w0, [sp, #12]   // Store our first (and only) argument on the
                                 // stack. Not specifically necessary, but good safety
                                 // mechanism. We could instead simply:
                                 // mov w8, w0
                                 // mov w9, w0
                                 // mul w0, w8, w9
                                 // This would remove memory access completely,
                                 // but this allows us to demonstrate the
                                 // general pattern we can use for functions
                                 //
                                 // Here we are using the first "32 bit slot" of the
                                 // area we carved out for local variables
                                 // above

        // Function body
        ldr      w8, [sp, #12]   // Load first operand with our argument
        ldr      w9, [sp, #12]   // Load second operand with our argument
        mul      w0, w8, w9      // Do the multiplication
                                 // Interpret as "w0 = w8 * w9"

        // Function exit
        add      sp, sp, #16     // Restore stack pointer
                                 // Interpret as "sp = sp + 16"
        ret                      // Return

_start:

// https://man7.org/linux/man-pages/man2/syscall.2.html
// https://github.com/torvalds/linux/blob/v4.17/include/uapi/asm-generic/unistd.h
        # Hello world to stdout
        mov     x8, #64         // System call (sys_write)
        mov     x0, #1          // first argument: file handle (stdout)
        ldr     x1, =msg        // second argument: pointer to message to write
        ldr     x2, =len        // third argument: message length
        svc     #0              // call kernel

        // Square argc
        ldr     w0, [sp]        // argc is on the stack
                                // this is an eightbyte according to table 3.9
                                // of the System V AMD64 psABI
                                // https://gitlab.com/x86-psABIs/x86-64-ABI
        bl      square          // Square our argc, result in w0
                                // w0 will also be the first argument to sys_exit
                                // w0 is x0 with top 32 bits zeroed
                                // so no need to load

        // exit
        mov     w8, #93         // system call number (sys_exit)
        svc     #0              // call kernel and exit
