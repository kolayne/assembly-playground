# Assembly language playground

This is my assembly playground, where I put some files written in the Intel syntax of assembly for
**x86** architecture, **Linux**.

You are VERY WELCOME to open issues (or even PRs?) if you see that I'm doing something in the wrong
way, use anti-patterns or anything! Which is likely, because I'm not guided by any courses or classes,
I just come up with ideas of what I want to code, and code them. Thanks :)

## Compilation (32-bit)

Note that each file of source code is independent of others, so they should be compiled
separately

```sh
nasm -f elf32 -o source_file.o source_file.s
ld -m elf_i386 -o executable source_file.o
```

After that, run the produced `executable` file
