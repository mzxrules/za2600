;==============================================================================
; mzxrules 2025
;==============================================================================


GameStart: BHA_BANK_FALL #SEG_GAME

    lda #%00110001 ; ball size 8, reflect playfield
    sta CTRLPF
    sta VDELBL


    lda #$01
    sta NUSIZ1

    lda #$16
    sta enBossX
    lda #$10
    sta enBossY


    lda #$40
    sta plX
    lda #$10
    sta plY

    lda #$FF
    sta PF0

    lda #$74
    sta COLUP0


    lda #$9A
    sta COLUP1

    lda #SEG_KERNEL
    sta BANK_SLOT

    lda #SEG_SPR
    sta BANK_SLOT

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


; Boss Draw Init


    lda enBossY
    sta enY

    lda Frame
    ror
    bcs .ganon_f1
    jsr GanonFrame0
    jmp .ganon_end
.ganon_f1
    jsr GanonFrame1

    lda Frame
    and #7
    eor #7
    bne .ganon_end

    inc enBossX
    lda enBossX
    cmp #$55
    bcc .ganon_end
    lda #$0D
    sta enBossX

.ganon_end

    lda enX
    sec
    sbc #$0D
    ; divide by 9
    sta ganonKernel
    lsr
    lsr
    lsr
    adc ganonKernel
    ror
    adc ganonKernel
    ror
    adc ganonKernel
    ror
    lsr
    lsr
    lsr
    ; result
    sta ganonKernel

    jsr PlayerInput
    jsr PosWorldObjects

; Init sprite stuffs
    lda #$B0
    sta COLUBK


; Player drawY
    lda plY
    tax

    ldy #7
.plspr_set_loop
    lda Spr_P0,y
    sta wPLSPR_MEM,x
    dex
    dey
    bpl .plspr_set_loop

KERNEL_MAIN:  ; 192 scanlines
    sta WSYNC
    lda INTIM
    bne KERNEL_MAIN
    sta VBLANK
    ldy #14 ; HEIGHT TIMER

.loop
    dey
    sta WSYNC
    sta WSYNC
    bpl .loop

    jsr KERNEL_BOSS4_START

; clean player sprite
    lda #0
    ldy #7
    ldx plY
.plspr_clear_loop
    sta wPLSPR_MEM,x
    dex
    dey
    bpl .plspr_clear_loop

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



GanonFrame0: SUBROUTINE
    lda enBossX
    sta enX

    lda #<SprGanon0 + $30+8
    sec
    sbc enY
    sta enSpr
    lda #>SprGanon0
    sta enSpr+1

    lda #<SprGanon2 + $30+8
    sec
    sbc enY
    sta enSpr2
    lda #>SprGanon2
    sta enSpr2+1

    rts

GanonFrame1: SUBROUTINE
    lda enBossX
    clc
    adc #8
    sta enX

    lda #<SprGanon1 + $30+8
    sec
    sbc enY
    sta enSpr
    lda #>SprGanon1
    sta enSpr+1

    lda #<SprGanon3 + $30+8
    sec
    sbc enY
    sta enSpr2
    lda #>SprGanon3
    sta enSpr2+1
    rts


PlayerInput: SUBROUTINE
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



    ldy #1  ; 0 right, 1 left, 2 down, 3 up
    lda SWCHA
    and #$F0
    asl
    bcc .SetDir
.ContLeft
    dey
    asl
    bcc .SetDir
.ContDown
    ldy #3
    asl
    bcc .SetDir
.ContUp
    dey
    asl
    bcs .ContEnd

.SetDir
    sty plDir
    sty plItemDir
    jmp PlayerMoveDir

.ContEnd
    rts


PlayerMoveDir:
    ldy plDir
PlayerMoveDel:
    lda plX
    clc
    adc EnMoveDeltaX,y
    and #$7F
    sta plX

    lda plY
    clc
    adc EnMoveDeltaY,y
    and #$7F
    sta plY

    rts


EnMoveDeltaX:
    .byte -1,  1,  0,  0 ; cardinals
    .byte -1, -1,  1,  1 ; diagonals
    .byte -4,  4,  0,  0 ; cardinals 4x

EnMoveDeltaY:
    .byte  0,  0,  1, -1 ; cardinals
    .byte  1, -1,  1, -1 ; diagonals
    .byte  0,  0,  4, -4 ; cardinals 4x

    .align 16
Spr_P0
    .byte $FF, $81, $81, $95, $91, $81, $81, $FF