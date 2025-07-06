;==============================================================================
; mzxrules 2025
;==============================================================================
; 32px Boss Prototype


    processor 6502
TIA_BASE_ADDRESS = $00
    INCLUDE "vcs.h"
    INCLUDE "macro.h"
    INCLUDE "zmacros.asm"
    INCLUDE "proto/boss4/vars.asm"

RAMSEG_F0 = $00
RAMSEG_F4 = $40
RAMSEG_F8 = $80
RAMSEG_FC = $C0

BANK_SLOT_RAM   = $3E
BANK_SLOT       = $3F

SEG_GAME    = RAMSEG_FC | 1
SEG_KERNEL  = RAMSEG_F8 | 2
SEG_SPR     = RAMSEG_F0 | 3

SEG_RAM     = RAMSEG_F4 | 0



; ****************************************
; *               BANK 0                 *
; ****************************************

    SEG Bank0
    ORG $0000
    RORG $FC00
    .byte #'T, #'J, #'3, #'E

GameStart: BHA_BANK_FALL #SEG_GAME

ENTRY:
    CLEAN_START
    lda #SEG_RAM
    sta BANK_SLOT_RAM
    lda #0

ENTRY_RAM_CLEAR_L
    dey
    sta $F600,y
    bne ENTRY_RAM_CLEAR_L

    jmp GameStart

    ORG $03FC
    RORG $FFFC
    .word ENTRY
    .word ENTRY


; ****************************************
; *               BANK 1                 *
; ****************************************

    SEG Bank1
    ORG $0400
    RORG $FC00
    .byte #'T, #'J, #'3, #'E

    INCLUDE "proto/boss4/game.asm"
    align 32
    INCLUDE "proto/PosWorldObjects.asm"


; ****************************************
; *               BANK 2                 *
; ****************************************

    SEG Bank1
    ORG $0800
    RORG $F800

    INCLUDE "gen/Boss4Kernel_DelLUT.asm"
    INCLUDE "proto/boss4/kernel.asm"



; ****************************************
; *               BANK 3                 *
; ****************************************

    SEG Bank1
    ORG $0C00,0
    RORG $F000

SprGanon0:
    ds $31
    INCLUDE "spr/spr_ganon_0.asm"

SprGanon2:
    ds $31
    INCLUDE "spr/spr_ganon_2.asm"

    align $100
SprGanon1:
    ds $31
    INCLUDE "spr/spr_ganon_1.asm"

SprGanon3:
    ds $31
    INCLUDE "spr/spr_ganon_3.asm"