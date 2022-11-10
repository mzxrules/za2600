;==============================================================================
; mzxrules 2021
;==============================================================================
    INCLUDE "kworld.asm"

ENTRY: SUBROUTINE ; Address FC00
    CLEAN_START
    sta BANK_SLOT ; load copy of bank to F000
    jmp ENTRY_INIT ; jump to F000 address space

ENTRY_INIT: SUBROUTINE ; Address F000
    ldy #SLOT_MAIN
    sty BANK_SLOT

; initialize extended ram
    ldy #2 ; ram banks to init

.init_ram_loop
    lda .ENTRY_RAM_BANKS,y
    sta BANK_SLOT_RAM
    txa

.wipeRamA
    dex
    sta wRAM_SEG,x
    bne .wipeRamA

.wipeRamB
    dex
    sta wRAM_SEG + $100,x
    bne .wipeRamB

    ; kernel transfer
    ldx #KERNEL_LEN
.initWorldKernMem
    lda KERNEL_WORLD-1,x
    sta wKERNEL-1,x
    dex
    bne .initWorldKernMem
    dey
    bpl .init_ram_loop

    jmp MAIN_INIT

.ENTRY_RAM_BANKS
    .byte #SLOT_RW0, #SLOT_RW1, #SLOT_RW2