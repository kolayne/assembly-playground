#!/bin/sh
set -e

gcc -o main.o -c -nostdlib main.c
gcc -o clib.so -shared clib.c

ld -m elf_x86_64 -dynamic-linker /lib64/ld-linux-x86-64.so.2 -o executable main.o clib.so

echo "Built successfully. Running"

set +e

./executable ; echo "Exited with code $?"
