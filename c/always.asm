;==============================================================================
; mzxrules 2022
;==============================================================================

    INCLUDE "gen/mesg_digits.asm"

MAIN_UNPAUSE: BHA_BANK_JMP #SLOT_FC_MAIN, PAUSE_RETURN

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
    sta.wx HMP0,x  ; 5 23 - store fine tuning of X
    sta RESP0,x    ; 4 27 - set coarse X position of object
;                  ;   67, which is max supported scan cycle
    dex            ; 2 69
    bpl .Loop      ; 3 72

    sta WSYNC
    sta HMOVE
    rts

Mul8:
    .byte 0x00, 0x08, 0x10, 0x18, 0x20, 0x28, 0x30, 0x38, 0x40, 0x48, 0x50, 0x58
Lazy8:
    .byte 0x01, 0x02, 0x04, 0x08
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

VERTICAL_SYNC: SUBROUTINE
    lda #2
    ldx #49
    sta WSYNC
    sta VSYNC
    stx TIM64T ; 41 scanline timer
    inc Frame

    ldx worldId
    lda WorldCompassRoom,x
    and #7
    eor #7
    asl
    asl
    asl
    sta RESBL
    asl
    sta HMBL

;==============================================================================
; PosHudObjects
;----------
; Positions all HUD elements within a single scanline
;----------
; Timing Notes:
; $18 2 iter (9) + 15 = 24
; $18
; $60 7 iter (34) + 15 = 49
;==============================================================================
PosHudObjects:
    sta WSYNC
    ; 26 cycles start

    lda worldId         ; 3
    ; 7 cycle start
    bne .dungeon        ; 2/3
    lda #$F             ; 2
    bne .roomIdMask     ; 3
.dungeon
    lda #$7             ; 2
    nop                 ; 2
.roomIdMask
    ; 7 cycle end

    and roomId          ; 3
    eor #7              ; 2
    asl                 ; 2
    asl                 ; 2
    asl                 ; 2
    asl                 ; 2
    sta HMM0            ; 3
    ; 26 cycles end
    sta RESP1           ; 3 - Map Sprite
    sta RESM0           ; 3 - Player Dot
    ; 18 cycles start
    lda worldId         ; 3
    bne .MapShift       ; 2/3
    lda #0              ; 2
    beq .SetMapShift    ; 3
.MapShift
    lda #$F0            ; 2
    nop                 ; 2
.SetMapShift
    sta HMP1            ; 3
    lda #0              ; 2
    sta HMP0            ; 3
    ; 18 cycles end
    sta RESP0           ;  - Inventory Sprites

    sta WSYNC
    sta HMOVE
;==============================================================================

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
EnItem:
ALWAYS_RTS:
    rts


WorldBankOff:
    .byte 0, 1, 1, 1, 1, 1, 1, 2, 2, 2

WorldRom:
    .byte #SLOT_F4_W0, #SLOT_F4_W1, #SLOT_F4_W2

WorldRam:
    .byte #SLOT_RW_F8_W0, #SLOT_RW_F8_W1, #SLOT_RW_F8_W2

WorldRoomSprites:
    .byte #SLOT_F4_PF_OVER, #SLOT_F4_PF_DUNG, #SLOT_F4_PF_DUNG

WorldCompassRoom:
    .byte $00
    .byte $36
    .byte $0D
    .byte $3D
    .byte $03
    .byte $14
    .byte $0C
    .byte $23
    .byte $24
    .byte $3A