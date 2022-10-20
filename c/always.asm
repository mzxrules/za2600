;==============================================================================
; mzxrules 2022
;==============================================================================

Mul8:
    .byte 0x00, 0x08, 0x10, 0x18, 0x20, 0x28, 0x30, 0x38, 0x40, 0x48, 0x50, 0x58
Lazy8:
    .byte 0x01, 0x02, 0x04, 0x08
Bit8:
    .byte 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80

    INCLUDE "gen/mesg_digits.asm"
    
MAIN_UNPAUSE:
    lda #SLOT_MAIN
    sta BANK_SLOT
    jmp PAUSE_RETURN

;==============================================================================
; PosWorldObjects
;----------
; Sets X position for all TIA objects within the world view
; X position must be between 0-134 ($00 to $86)
; Higher values will waste an extra scanline
; Does not touch Y register
;==============================================================================
PosWorldObjects: SUBROUTINE
    ldx #4
PosWorldObjects_X: SUBROUTINE
    sec            ; 2
.Loop
    sta WSYNC      ; 3
    lda plX,x      ; 4  4 - Offsets by 12 pixels
DivideLoop
    sbc #15        ; 2  6 - each time thru this loop takes 5 cycles, which is
    bcs DivideLoop ; 2  8 - the same amount of time it takes to draw 15 pixels
    eor #7         ; 2 10 - The EOR & ASL statements convert the remainder
    asl            ; 2 12 - of position/15 to the value needed to fine tune
    asl            ; 2 14 - the X position
    asl            ; 2 16
    asl            ; 2 18
    sta.wx HMP0,X  ; 5 23 - store fine tuning of X
    sta RESP0,X    ; 4 27 - set coarse X position of object
;                  ;   67, which is max supported scan cycle 
    dex            ; 2 69
    bpl .Loop      ; 3 72
    
    sta WSYNC
    sta HMOVE
    rts
    
GiItemColors:
    .byte COLOR_BLACK       ; GiNone
    .byte COLOR_EN_RED      ; GiRecoverHeart
    .byte COLOR_EN_RED      ; GiFairy
    .byte COLOR_EN_BLUE     ; GiBomb

    .byte COLOR_EN_TRIFORCE ; GiRupee
    .byte COLOR_EN_BLUE     ; GiRupee5
    .byte COLOR_EN_TRIFORCE ; GiTriforce
    .byte COLOR_EN_RED      ; GiHeart

    .byte COLOR_EN_TRIFORCE ; GiKey
    .byte COLOR_EN_TRIFORCE ; GiMasterKey
    .byte COLOR_GRAY        ; GiSword2
    .byte COLOR_WHITE       ; GiSword3

    .byte COLOR_EN_BROWN    ; GiBow
    .byte COLOR_EN_BROWN    ; GiRaft
    .byte COLOR_WHITE       ; GiBoots
    .byte COLOR_EN_TRIFORCE ; GiFlute

    .byte COLOR_EN_RED      ; GiFireMagic
    .byte COLOR_EN_RED      ; GiBracelet
    .byte COLOR_EN_BLUE     ; GiRingBlue
    .byte COLOR_EN_RED      ; GiRingRed

    .byte COLOR_EN_TRIFORCE ; GiArrows
    .byte COLOR_WHITE       ; GiArrowsSilver
    .byte COLOR_EN_BLUE     ; GiCandleBlue
    .byte COLOR_EN_RED      ; GiCandleRed
    .byte COLOR_EN_RED      ; GiMeat
    .byte COLOR_EN_BLUE     ; GiNote
    .byte COLOR_EN_BLUE     ; GiPotionBlue
    .byte COLOR_EN_RED      ; GiPotionRed

    .byte COLOR_EN_TRIFORCE ; GiMap
