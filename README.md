# Assembly language playground

This is my assembly playground, where I put some files written in the Intel syntax of assembly for
**x86** architecture, **Linux**.

You are VERY WELCOME to open issues (or even PRs?) if you see that I'm doing something in the wrong
way, use anti-patterns or anything! Which is likely, because I'm not guided by any courses or classes,
I just come up with ideas of what I want to code, and code them. Thanks :)

## Compilation (32-bit)

Note that each file of source code is independent of others, so they should be compiled
separately.

32-bit source files are denoted with "\_32" in the end of their filenames (without extension).

```sh
nasm -f elf32 -o source_file.o source_file.s
ld -m elf_i386 -o executable source_file.o
```

If you want to produce a smaller executable, you might want to add `-s --nmagic` to linker
arguments. Read more about their meaning in the manual :)

After that, run the produced `executable` file.

## Compilation (64-bit)

64-bit source files are denoted with "\_64" in the end of their filenames (without extension).

To compile them you need to do the same thing you would do with 32-bit ones, but instead of
`nasm -f elf32` run `nasm -f elf64` and instead of `ld -m elf_i386` run `ld -m elf_x86_64`.
