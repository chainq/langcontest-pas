#!/usr/bin/env bash

set -o errexit

FPC="$HOME/DevPriv/fpc-bin/x86_64-embedded/lib/fpc/3.3.1"
FPC_UNITS="$FPC/units/x86_64-embedded/*"
FPC_BIN="$FPC/ppcrossx64"


"$FPC_BIN" -Tembedded -O2 -XX -CX -al \
    -k"-z max-page-size=0x10" \
    -XP"x86_64-linux-gnu-" \
    -Fu"$FPC_UNITS" \
    langcontest.pas

# hack - strip and get rid of the .data section,
# which only contains the compiler signature
strip --remove-section=.data langcontest.elf

#cat boot_elf.bin langcontest.elf >disk.img
