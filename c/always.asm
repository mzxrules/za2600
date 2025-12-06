;==============================================================================
; mzxrules 2022
;==============================================================================

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
    inc blX
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
    sta.wx HMP0,x  ; 5 23 - store fine tuning of X
    sta RESP0,x    ; 4 27 - set coarse X position of object
;                  ;   67, which is max supported scan cycle
    dex            ; 2 69
    bpl .Loop      ; 3 72

    sta WSYNC
    sta HMOVE
    dec blX
    rts

Bit8:
    .byte 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80

GiItemColors:
    .byte COLOR_EN_BLACK    ; GiNone
    .byte COLOR_EN_RED      ; GiRecoverHeart
    .byte COLOR_EN_RED      ; GiFairy
    .byte COLOR_EN_BLUE     ; GiBomb

    .byte COLOR_EN_TRIFORCE ; GiRupee
    .byte COLOR_EN_BLUE     ; GiRupee5
    .byte COLOR_EN_TRIFORCE ; GiTriforce
    .byte COLOR_EN_RED      ; GiHeart

    .byte COLOR_EN_TRIFORCE ; GiKey
    .byte COLOR_EN_TRIFORCE ; GiMasterKey

    .byte COLOR_EN_BROWN    ; GiShield
    .byte COLOR_EN_TRIFORCE ; GiFlute

    .byte COLOR_EN_RED      ; GiMeat
    .byte COLOR_EN_BROWN    ; GiSword1
    .byte COLOR_EN_GRAY_L   ; GiSword2
    .byte COLOR_EN_WHITE    ; GiSword3

    .byte COLOR_EN_BLUE     ; GiWand
    .byte COLOR_EN_RED      ; GiBook
    .byte COLOR_EN_BLUE     ; GiRang
    .byte COLOR_EN_BROWN    ; GiRaft

    .byte COLOR_EN_WHITE    ; GiBoots
    .byte COLOR_EN_RED      ; GiBracelet
    .byte COLOR_EN_BLUE     ; GiRingBlue
    .byte COLOR_EN_RED      ; GiRingRed

    .byte COLOR_EN_BROWN    ; GiBow
    .byte COLOR_EN_TRIFORCE ; GiArrow
    .byte COLOR_EN_WHITE    ; GiArrowSilver
    .byte COLOR_EN_BLUE     ; GiCandleBlue

    .byte COLOR_EN_RED      ; GiCandleRed
    .byte COLOR_EN_BLUE     ; GiNote
    .byte COLOR_EN_BLUE     ; GiPotionBlue
    .byte COLOR_EN_RED      ; GiPotionRed

    .byte COLOR_EN_TRIFORCE ; GiMap
    .byte COLOR_EN_TRIFORCE ; GiCompass
    .byte COLOR_EN_BROWN    ; GiBowArrow
    .byte COLOR_EN_WHITE    ; GiBowArrowSilver
    .byte COLOR_PF_PURPLE   ; GiWandBook


GiItemSpr:
    .byte $00   ; GiNone
    .byte $08   ; GiRecoverHeart
    .byte $10   ; GiFairy
    .byte $18   ; GiBomb

    .byte $20   ; GiRupee
    .byte $20   ; GiRupee5
    .byte $28   ; GiTriforce
    .byte $30   ; GiHeart

    .byte $38   ; GiKey
    .byte $40   ; GiMasterKey

    .byte $D0   ; GiShield
    .byte $70   ; GiFlute

    .byte $A0   ; GiMeat
    .byte $48   ; GiSword1
    .byte $48   ; GiSword2
    .byte $50   ; GiSword3

    .byte $78   ; GiWand
    .byte $E0   ; GiBook
    .byte $C8   ; GiRang
    .byte $60   ; GiRaft

    .byte $68   ; GiBoots
    .byte $80   ; GiBracelet
    .byte $88   ; GiRingBlue
    .byte $88   ; GiRingRed

    .byte $58   ; GiBow
    .byte $90   ; GiArrow
    .byte $90   ; GiArrowSilver
    .byte $98   ; GiCandleBlue

    .byte $98   ; GiCandleRed
    .byte $A8   ; GiNote
    .byte $B0   ; GiPotionBlue
    .byte $B0   ; GiPotionRed

    .byte $B8   ; GiMap
    .byte $D8   ; GiCompass
    .byte $C0   ; GiBowArrow
    .byte $C0   ; GiBowArrowSilver

    .byte $78   ; GiWandBook

Mul8:
    .byte 0x00, 0x08, 0x10, 0x18, 0x20, 0x28, 0x30, 0x38
    .byte 0x40, 0x48, 0x50, 0x58, 0x60, 0x68, 0x70, 0x78
    .byte 0x80, 0x88, 0x90, 0x98

VERTICAL_SYNC: SUBROUTINE
    lda #$80
    sta m0Y
    sta m1Y
    lda #SLOT_F0_SPR_HUD
    sta BANK_SLOT
    lda #OS_FRAME_VBLANK | #$02
    sta wOSFrameState
    ldx #49
    sta WSYNC
    sta VSYNC
    stx TIM64T ; 41 scanline timer
    inc Frame
    jsr PosHudObjects_Cycle18

    lda #0      ; LoaD Accumulator with 0 so D1=0
    ; disable VDEL for HUD drawing
    sta VDELP0
    sta VDELP1
    ;sta PF0     ; blank the playfield
    ;sta PF1
    ;sta PF2
    ;sta GRP0    ; blanks player0 if VDELP0 was off
    ;sta GRP1    ; blanks player0 if VDELP0 was on, player1 if VDELP1 was off
    ;sta GRP0    ; blanks                           player1 if VDELP1 was on
    sta WSYNC
    sta VSYNC
    rts
    LOG_SIZE "VERTICAL SYNC", VERTICAL_SYNC

MAIN_LOADROOM_RETURN: BHA_BANK_JMP #SLOT_FC_MAIN, LOADROOM_RETURN
MAIN_UNPAUSE: BHA_BANK_JMP #SLOT_FC_MAIN, PAUSE_RETURN
MAIN_DUNG_ENT: BHA_BANK_JMP #SLOT_FC_MAIN, SPAWN_AT_DEFAULT
MAIN_CAVE_ENT: BHA_BANK_JMP #SLOT_FC_MAIN, ALWAYS_RTS
HALT_GAME_FC: BHA_BANK_JMP #SLOT_FC_HALT, HALT_GAME
MAIN_RESPAWN: BHA_BANK_JMP #SLOT_FC_MAIN, RESPAWN

EnItemDraw: SUBROUTINE ; y == itemDraw
    lda #>SprItem0
    sta enSpr+1
    lda GiItemColors,y
    tax
    cpy #GI_TRIFORCE+1
    bpl .skipItemColor
    lda Frame
    and #$10
    beq .skipItemColor
    ldx #COLOR_EN_LIGHT_BLUE
.skipItemColor
    stx wEnColor
    lda GiItemSpr,y
    clc
    adc #<SprItem0
    sta enSpr
ALWAYS_RTS:
    rts

PlayerStunColors:
    .byte #COLOR_PLAYER_00, #COLOR_PLAYER_02, #COLOR_PLAYER_01, #COLOR_EN_BLACK