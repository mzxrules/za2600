;==============================================================================
; mzxrules 2024
;==============================================================================
    processor 6502
TIA_BASE_ADDRESS = $00
    INCLUDE "vcs.h"
    INCLUDE "macro.h"
    INCLUDE "zmacros.asm"

; ****************************************
; * Variables                            *
; ****************************************

    SEG.U VARS
    ORG $80
Frame       ds 1
roomIdNext  ds 1
roomId      ds 1
roomTimer   ds 1
roomFlags   ds 1
RF_EV_LOAD      = $80 ; 1000_0000 Force Load Room
RF_EV_LOADED    = $40 ; 0100_0000 Room Load happened this frame
roomDY      ds 1


; Temps
Temp0           ds 1
Temp1           ds 1
Temp2           ds 1

; Debug
testIndex       = Temp2

; ****************************************
; * Extended RAM                         *
; ****************************************

    ORG $F800
rRAM_SEG
rPF1RoomL           ds ROOM_PX_HEIGHT
rPF2Room            ds ROOM_PX_HEIGHT
rPF1RoomR           ds ROOM_PX_HEIGHT

    ORG $FA00
wRAM_SEG
wPF1RoomL           ds ROOM_PX_HEIGHT
wPF2Room            ds ROOM_PX_HEIGHT
wPF1RoomR           ds ROOM_PX_HEIGHT

ROOM_PX_HEIGHT = 20


; ****************************************
; * Constants                            *
; ****************************************

; Segment Constants
RAMSEG_F0 = $00
RAMSEG_F4 = $40
RAMSEG_F8 = $80
RAMSEG_FC = $C0

BANK_SLOT_RAM   = $3E
BANK_SLOT       = $3F

SLOT_FC_MAIN        = RAMSEG_FC | 0
SLOT_FC_HALT_RSCR   = RAMSEG_FC | 1
SLOT_F4_PF          = RAMSEG_F4 | 2
SLOT_F0_ROOM        = RAMSEG_F0 | 3
SLOT_F4_ROOMSCROLL  = RAMSEG_F4 | 4

SLOT_RW_F0_ROOMSCROLL   = RAMSEG_F0 | 0
SLOT_RW_F8_WX           = RAMSEG_F8 | 1

; ****************************************
; *               BANK 00                *
; ****************************************

    SEG CODE
    ORG $0000
    RORG $FC00
BANK_0

    .byte #'T, #'J, #'3, #'E
    INCLUDE "scroll/Game_Dummy.asm"

    LOG_BANK_SIZE "Main Sim", BANK_0

    ORG $03FC
    RORG $FFFC
    .word (ENTRY)
    .word (ENTRY)

; ****************************************
; *               BANK 01                *
; ****************************************
    ORG $0400
    RORG $FC00
BANK_1

    .byte #'T, #'J, #'3, #'E
    INCLUDE "scroll/Game_HaltRoom.asm"
    INCLUDE "scroll/task_lut.asm"

    LOG_BANK_SIZE "HALT ROOM", BANK_1

; ****************************************
; *               BANK 02                *
; ****************************************
    ORG $0800
    RORG $F400

    INCLUDE "scroll/sprite_data.asm"

; ****************************************
; *               BANK 03                *
; ****************************************

    ORG $0C00
    RORG $F000

    INCLUDE "scroll/room_A.asm"

; ****************************************
; *               BANK 04                *
; ****************************************

    ORG $1000
    RORG $F400
BANK_4

    INCLUDE "scroll/bit_mirror.asm"
    INCLUDE "scroll/TransferA.asm"
    INCLUDE "scroll/TransferB.asm"

    LOG_BANK_SIZE "Scroll", BANK_4

; ****************************************
; *               BANK 07                *
; ****************************************
    ORG $1FFF
    RORG $FFFF
    .byte 0

    END