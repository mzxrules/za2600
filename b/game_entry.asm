;==============================================================================
; mzxrules 2021
;==============================================================================
    INCLUDE "kworld.asm"

ENTRY: SUBROUTINE ; Address FC00
    CLEAN_START
; wipe ram
    ldy #3
.wipe_rambanks_loop
    sty BANK_SLOT_RAM
.wipeRam
    dex
    sta $F200,x
    sta $F300,x
    bne .wipeRam
    dey
    bpl .wipe_rambanks_loop

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
    txa ; set A to 0

    ; kernel transfer
    ldx #KERNEL_LEN
.initWorldKernMem
    lda KERNEL_WORLD-1,x
    sta wKERNEL-1,x
    dex
    bne .initWorldKernMem
    dey
    bpl .init_ram_loop

ENTRY_START_GAME:
    IFCONST ITEMS
.cheats
    lda #8
    sta itemKeys
    lda #16
    sta itemRupees
    sta itemBombs
    lda #$F0
    sta itemFlags
    lda #$FF
    sta itemFlags+1
    sta itemFlags+2
    ENDIF

    lda #%00110001 ; ball size 8, reflect playfield
    sta CTRLPF
    sta VDELBL

    ; seed RNG
    ; lda INTIM
    ; sta Rand16+1
    ; eor #$FF
    sta Rand16

    ; set ball
    lda #$60
    sta blY

    ; set player stats
    lda #$18
    sta plHealthMax

    jmp MAIN_ENTRY

.ENTRY_RAM_BANKS
    .byte #SLOT_RW0, #SLOT_RW1, #SLOT_RW2