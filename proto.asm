;==============================================================================
; mzxrules 2022
;==============================================================================
; Multi-Sprite Boss Prototype

    processor 6502
TIA_BASE_ADDRESS = $00
    INCLUDE "vcs.h"
    INCLUDE "macro.h"
    INCLUDE "zmacros.asm"

RAMSEG_F0 = $00
RAMSEG_F4 = $40
RAMSEG_F8 = $80
RAMSEG_FC = $C0

BANK_SLOT_RAM   = $3E
BANK_SLOT       = $3F

INPUT_BANK = RAMSEG_F0 | 1

    COLOR UNDEF,        $00,$00
    COLOR BLACK,        $00,$00
    COLOR DARK_GRAY,    $02,$06
    COLOR GRAY,         $06,$0C
    COLOR WHITE,        $0E,$0E

    COLOR EN_RED,       $42,$64
    COLOR EN_BLUE,      $74,$B4
    COLOR EN_ROK_BLUE,  $72,$C4
    COLOR EN_LIGHT_BLUE,$88,$D8 ; Item secondary flicker
    COLOR EN_TRIFORCE,  $2A,$2A
    COLOR EN_BROWN,     $F0,$22

    COLOR PLAYER_00,    $C6,$58
    COLOR PLAYER_01,    $08,$0C
    COLOR PLAYER_02,    $46,$64

    COLOR PATH,         $3C,$4C
    COLOR GREEN_ROCK,   $D0,$52
    COLOR RED_ROCK,     $42,$64
    COLOR CHOCOLATE,    $F0,$22
    COLOR LIGHT_WATER,  $AE,$9E

    COLOR DARK_BLUE,    $90,$C0
    COLOR LIGHT_BLUE,   $86,$D6 ; World
    COLOR DARK_PURPLE,  $60,$A2
    COLOR PURPLE,       $64,$A6
    COLOR DARK_TEAL,    $B0,$72
    COLOR LIGHT_TEAL,   $B2,$74
    COLOR SACRED,       $1E,$2E ; No good PAL equivalent

    COLOR MINIMAP,      $84,$08 ; Different colors
    COLOR HEALTH,       $46,$64

    SEG.U VARS_ZERO
    ORG $80
Frame       ds 1
plX         ds 1
enX         ds 1 ; en sprite X pos
m0X         ds 1
m1X         ds 1
blX         ds 1

plY         ds 1
enY         ds 1
m0Y         ds 1
m1Y         ds 1
blY         ds 1

plSpr       ds 2 ; plSprOff
enSpr       ds 2 ; enSprOff, priority
enSpr2      ds 2 ; enSprOff, secondary

plDY        ds 1 ; Pl DrawY (world and screen)
enDY        ds 1
m0DY        ds 1

enBossX     ds 1 ; real boss X pos
enX2        ds 1 ; en2 sprite x pos

kP0         ds 1
kP1         ds 1

plColor     ds 1
enColor     ds 1

plItemTimer ds 1
plDir       ds 1
plItemDir   ds 1
NUSIZ0_T    ds 1
wM0H        ds 1
plState     ds 1
INPT_FIRE_PREV  = $80 ; 1000_0000 Fire Pressed Last Frame
PS_USE_ITEM     = $40 ; 0100_0000 Use Current Item Event
PS_GLIDE        = $20 ; 0010_0000 Move Until Unblocked
PS_LOCK_MOVE    = $10 ; 0001_0000 Lock Player Movement
PS_P1_WALL      = $08 ; 0000_1000 P1 Is Wall
PS_PF_IGNORE    = $04 ; 0000_0100 Playfield Ignore
PS_LOCK_ALL     = $02 ; 0000_0010 Lock Player
PS_LOCK_AXIS    = $01 ; 0000_0001 Lock Player Axis - Hover Boots

    echo "-RAM-",$80,(.)

;enSpr2      ds 2 ;

; ****************************************
; *               BANK 0                 *
; ****************************************
    SEG Bank0
    ORG $0000
    RORG $FC00

    .byte #'T, #'J, #'3, #'E

ENTRY: SUBROUTINE

    CLEAN_START

    lda INPUT_BANK
    sta BANK_SLOT


    lda #%00110001 ; ball size 8, reflect playfield
    sta CTRLPF
    sta VDELBL

    lda #$40
    sta enBossX
    sta plX

    lda #$10
    sta plY
    lda #$20
    sta enY

    lda #$FF
    sta PF0




    ;TOP_FRAME ;3 37 192 30
VERTICAL_SYNC: ; 3 SCANLINES
    lda #2
    ldx #49
    sta WSYNC
    sta VSYNC
    stx TIM64T ; 41 scanline timer
    inc Frame
    sta WSYNC
    sta WSYNC
    lda #0      ; LoaD Accumulator with 0 so D1=0
    ;sta PF0     ; blank the playfield
    sta PF1
    sta PF2
    sta GRP0    ; blanks player0 if VDELP0 was off
    sta GRP1    ; blanks player0 if VDELP0 was on, player1 if VDELP1 was off
    sta GRP0    ; blanks                           player1 if VDELP1 was on
    sta WSYNC
    sta VSYNC
    ldy #3

    jsr DoThings
    jsr PlayerItem

; Init sprite stuffs
    lda #$B0
    sta COLUBK

; Assign Sprites
BWAH:
    lda Frame
    and #1
    tay

    lda #COLOR_EN_TRIFORCE
    sta COLUP0
    sta COLUP1
    sta enColor

    lda #COLOR_PLAYER_00
    sta plColor

    lda PlSprRollL
    sta plSpr
    lda PlSprRollH
    sta plSpr+1


; Set Gohma Boss Sprites
    lda Frame
    and #$8
    lsr
    lsr
    lsr
    eor Frame
    and #1
    tay

    lda EnSprRollL,y
    sta enSpr
    lda EnSprRollH,y
    sta enSpr+1

    lda EnSprRollL+1,y
    sta enSpr2
    lda EnSprRollH+1,y
    sta enSpr2+1

    lda Frame
    and #1
    tay


    lda ReflectP0,y
    sta REFP0
    lda ReflectP1,y
    sta REFP1


; Init position
    lda BossShift,y
    clc
    adc enBossX
    sta enX

    ldx #1
    jsr PosObject

; Secondary Priority Boss Sprite
    lda BossShift+1,y
    clc
    adc enBossX
    sta enX2
    ldx #0
    jsr PosObject

    lda m0X
    ldx #2
    jsr PosObject

.player_sprite_setup
    lda plSpr
    clc
    adc #8
    sec
    sbc plY
    sta plSpr
    lda plSpr + 1
    sbc #0
    sta plSpr + 1


.enemy_sprite_setup
    lda enSpr       ; #<(SprE0 + 7)
    clc
    adc #9
    sec
    sbc enY
    sta enSpr

    lda enSpr + 1   ; #>(SprE0 + 7)
    sbc #0
    sta enSpr + 1


.enemy_sprite2_setup
    lda enSpr2       ; #<(SprE0 + 7)
    clc
    adc #9
    sec
    sbc enY
    sta enSpr2

    lda enSpr2 + 1   ; #>(SprE0 + 7)
    sbc #0
    sta enSpr2 + 1


; Player drawY
    lda #95+9
    sec
    sbc plY
    sta plDY

; Mi DrawY

    lda #95+8 ;.Spr8WorldOff,y
    sec
    sbc m0Y
    sta m0DY


; En DrawY
    lda #95+10
    sec
    sbc enY
    sta enDY


    lda NUSIZ0_T
    sta NUSIZ0




    sta WSYNC
    sta HMOVE
    sta WSYNC
    lda #0
    sta HMM0
    tax

KERNEL_MAIN:  ; 192 scanlines
    sta WSYNC
    lda INTIM
    bne KERNEL_MAIN
    sta VBLANK
    ldy #95 ; HEIGHT TIMER

    lda #$55
    sta PF1
    sta WSYNC
    lda #0
    sta kP0
    sta kP1
    sta PF1
    sta HMP1
    sta WSYNC
    jmp Standard_Kernel

KERNEL_END:  ; Not actually needed
    sta WSYNC
    sta WSYNC
    jmp OVERSCAN

Standard_Start: SUBROUTINE
    ;cpy #1 ; haven't gotten to post dec
    ;beq KERNEL_END
    stx kP0
    lda enColor
    sec             ; 2
    sta COLUP0
    sta WSYNC       ; 3
    stx GRP0
    lda enX2
                    ; 6 - Offsets by 12 pixels + 6
.DivideLoop
    sbc #15         ; 2  6 - each time thru this loop takes 5 cycles, which is
    bcs .DivideLoop ; 2  8 - the same amount of time it takes to draw 15 pixels
    eor #7          ; 2 10 - The EOR & ASL statements convert the remainder
    asl             ; 2 12 - of position/15 to the value needed to fine tune
    asl             ; 2 14 - the X position
    asl             ; 2 16
    asl             ; 2 18
    sta.w HMP0      ; 4 23 - store fine tuning of X
    sta RESP0       ; 3 27 - set coarse X position of object
;                   ;   67, which is max supported scan cycle
    dey
    sta WSYNC
    sta HMOVE

Standard_Kernel: SUBROUTINE
    sta ENAM0
    lda kP0
    sta GRP0
    lda kP1
    sta GRP1

; boss
    lda #9          ; 2
    dcp enDY        ; 5
    bcs .drawE0     ; 2/3
    lda #0          ; 2
    .byte $2C       ; 3?
.drawE0:
    lda (enSpr),y   ; 5
                    ; -- 18 Cycles
    sta kP1
    bcs .drawE2
    lda #0          ; 2
    .byte $2C       ; 3?
.drawE2:
    lda (enSpr2),y   ; 5
                    ; -- 18 Cycles
    sta kP0
    lda #9
    dcp plDY
    beq Flicker_Start
    sta WSYNC
; LINE 2
    lda wM0H
    dcp m0DY
    lda #1
    adc #0
    dey
    sta WSYNC
    bne Standard_Kernel
    jmp OVERSCAN

Flicker_Start:
    lda #COLOR_PLAYER_00
    sec             ; 2
    stx GRP0
    ;stx ENAM0
    dec m0DY
    dey
    sta WSYNC       ; 3
    sta COLUP0
    lda plX
                    ; 6  4 - Offsets by 12 pixels + 6
.DivideLoop
    sbc #15         ; 2  6 - each time thru this loop takes 5 cycles, which is
    bcs .DivideLoop ; 2  8 - the same amount of time it takes to draw 15 pixels
    eor #7          ; 2 10 - The EOR & ASL statements convert the remainder
    asl             ; 2 12 - of position/15 to the value needed to fine tune
    asl             ; 2 14 - the X position
    asl             ; 2 16
    asl             ; 2 18
    sta.w HMP0      ; 4 23 - store fine tuning of P0
    sta RESP0       ; 3 27 - set coarse X position of P0
;                   ;   67, which is max supported scan cycle
    stx kP0
    lda #0
    sta WSYNC
    sta HMOVE

Flicker_Kernel: SUBROUTINE
    sta ENAM0
    lda kP0
    sta GRP0
    lda kP1
    sta GRP1

; boss
    lda #9          ; 2
    dcp enDY        ; 5
    bcs .drawE0     ; 2/3
    lda #0          ; 2
    .byte $2C       ; 3?
.drawE0:
    lda (enSpr),y   ; 5
                    ; -- 18 Cycles
    sta kP1

; player
    lda #8
    dcp plDY
    bcs .DrawP0
    lda #0
    .byte $2C
.DrawP0:
    lda (plSpr),y
    sta kP0
    bcs .cont
    jmp Standard_Start
.cont
    sta WSYNC
; FLICKER LINE 2
    lda wM0H
    dcp m0DY
    lda #1
    adc #0
    dey
    sta WSYNC
    bne Flicker_Kernel
    jmp OVERSCAN


    LOG_BANK_SIZE "Kernel", KERNEL_MAIN

OVERSCAN: SUBROUTINE ; 30 scanlines
    sta WSYNC
    lda #2
    sta VBLANK
    lda #32
    sta TIM64T ; 27 scanline timer

OVERSCAN_WAIT:
    sta WSYNC
    lda INTIM
    bne OVERSCAN_WAIT

    jmp VERTICAL_SYNC



DoThings: SUBROUTINE
; Input
    lda plState
    cmp #INPT_FIRE_PREV ; Test if fire pressed last frame, store in carry
    and #~[INPT_FIRE_PREV + PS_USE_ITEM] ; mask out button held and use current item event
    ora #$80 ; INPT_FIRE_PREV
    bit INPT4
    bmi .FireNotHit ; Button not pressed
    eor #$80 ; invert flag
    bcc .FireNotHit ; Button held down
    ldx plItemTimer
    bne .FireNotHit ; Item in use
    ora #PS_USE_ITEM
.FireNotHit
    sta plState



    lda SWCHA
    and #$F0
    asl
    bcs .ContLeft
    inc plX
    ldx #0
    stx plDir
    stx plItemDir
.ContLeft
    asl
    bcs .ContDown
    dec plX
    ldx #1
    stx plDir
    stx plItemDir
.ContDown
    asl
    bcs .ContUp
    dec plY
    ldx #2
    stx plDir
    stx plItemDir
.ContUp
    asl
    bcs .ContEnd
    inc plY
    ldx #3
    stx plDir
    stx plItemDir
.ContEnd


;  Boss Movement - Diagonal pattern
/*
    lda Frame
    asl
    asl
    bcs .EnLeft
    inc enBossX
    jmp .EnDown
.EnLeft
    dec enBossX
.EnDown
    asl
    bcs .EnUp
    dec enY
    jmp .EnEnd
.EnUp
    inc enY
.EnEnd
*/
BoardXL = $04
BoardXR = $7C
BoardYU = $50
BoardYD = $08


; test player board bounds
    lda plX
    cmp #BoardXR+1
    bne .plXRSkip
    ldx #BoardXL
    stx plX
.plXRSkip
    cmp #BoardXL-1
    bne .plXLSkip
    ldx #BoardXR
    stx plX
.plXLSkip
    lda plY
    cmp #BoardYU+1
    bne .plYUSkip
    ldx #BoardYD
    stx plY
    lda plY
.plYUSkip
    cmp #BoardYD-1
    bne .plYDSkip
    ldx #BoardYU
    stx plY
.plYDSkip


; Boss Movement - Box pattern
    ;lda Frame3
    ;cmp #2
    lda Frame
    and #1
    bne .EnEnd
    lda Frame
    asl
    asl
    bcs .EnDown
; 2
    asl
    bcs .EnMoveR
; Move UP
    inc enY
    inc enY
    jmp .EnEnd
.EnMoveR
    inc enBossX
    inc enBossX
    jmp .EnEnd


.EnDown
    asl
    bcs .EnLeft
    dec enY
    dec enY
    jmp .EnEnd
.EnLeft
    dec enBossX
    dec enBossX
.EnEnd



    rts




    align 32
PosObject: SUBROUTINE
; Simulate za2600
    sec            ; 2
    sta WSYNC      ; 3
    nop
    nop            ; 4  4 - Offsets by 12 pixels
.DivideLoop
    sbc #15        ; 2  6 - each time thru this loop takes 5 cycles, which is
    bcs .DivideLoop; 2  8 - the same amount of time it takes to draw 15 pixels
    eor #7         ; 2 10 - The EOR & ASL statements convert the remainder
    asl            ; 2 12 - of position/15 to the value needed to fine tune
    asl            ; 2 14 - the X position
    asl            ; 2 16
    asl            ; 2 18
    sta.wx HMP0,x  ; 5 23 - store fine tuning of X
    sta RESP0,x    ; 4 27 - set coarse X position of object
;                  ;   67, which is max supported scan cycle
    rts

    align 64
Spr_P0
    .byte $0, $FF, $81, $81, $95, $91, $81, $81, $FF

; Gohma A
Spr_B0A
    .byte 194, 79, 120,  49, 217, 127,  31,  6,  2,  0

Spr_B0B
    .byte 2, 143, 184, 241, 89, 31, 191, 230, 66, 0

; Gohma Right
Spr_B0_old
    .byte  67, 246,  30, 140, 155, 254, 248, 240, 96, 32

PlSprColor:
    .byte #COLOR_WHITE, #COLOR_WHITE, #COLOR_EN_TRIFORCE

PlSprRollL:
    .byte #<(Spr_P0), #<(Spr_P0)
PlSprRollH:
    .byte #>(Spr_P0), #>(Spr_P0)
EnSprRollL:
    .byte #<(Spr_B0A), #<(Spr_B0B), #<(Spr_B0A)
EnSprRollH:
    .byte #>(Spr_B0A), #>(Spr_B0B), #>(Spr_B0A)

BossShift:
    .byte 0, 8, 0

ReflectP0:
    .byte #%0001100, 0

ReflectP1:
    .byte 0, #%0001100

    LOG_BANK_SIZE "Proto", ENTRY-4

    ORG $03FC
    RORG $FFFC
    .word ENTRY
    .word ENTRY


; ****************************************
; *               BANK ?                 *
; ****************************************
    SEG Bank1
    ORG $0400
    RORG $F000
    INCLUDE "gen/PlItem_DelLUT.asm"

    ;align 4
ArrowWidth4:
SwordWidth4:
    .byte $20, $20, $10, $10
ArrowWidth8:
SwordWidth8:
    .byte $30, $30, $10, $10
ArrowHeight4:
SwordHeight4:
    .byte 1, 1, 3, 3
ArrowHeight8:
SwordHeight8:
    .byte 1, 1, 7, 7
ArrowOff4X:
SwordOff4X:
    .byte 8, -2, 4, 4
ArrowOff8X:
SwordOff8X:
    .byte 8, -6, 4, 4
ArrowOff4Y:
SwordOff4Y:
    .byte 3, 3, -3, 7
ArrowOff8Y:
SwordOff8Y:
    .byte 3, 3, -7, 7

PlayerItem: SUBROUTINE
    ; update player item timer
    lda plItemTimer
    cmp #1
    adc #0
    sta plItemTimer

    ldx #0
    lda PlItemH,x
    pha
    lda PlItemL,x
    pha
    rts

PlayerUseBomb:
PlayerUseArrow:
PlayerUseMeat:
PlayerUseWand:
PlayerUseFlute:
PlayerUseCandle:
PlayerUseRang:
PlayerUseSword: SUBROUTINE
; If Item Button, use item
    bit plState
    bvc .skipSlashSword ;PS_USE_ITEM
    lda #<-9
    sta plItemTimer
    lda plDir
    sta plItemDir
; Sfx
.skipSlashSword
    ldy plItemTimer
    bne .drawSword
    lda #$80
    sta m0Y
    rts

.drawSword
    lda #0
    cpy #-7
    bmi .endSword
    cpy #-1
    beq .drawSword4
    lda #4 ; Draw Sword 8
.drawSword4
    clc
    adc plDir
    tay
    lda SwordWidth4,y
    sta NUSIZ0_T
    lda SwordHeight4,y
    sta wM0H
    lda SwordOff4X,y
    clc
    adc plX
    sta m0X
    lda SwordOff4Y,y
    clc
    adc plY
    sta m0Y
.endSword
    rts

    ORG $FFFF
    RORG $FFFF
    .byte $0