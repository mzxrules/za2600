;==============================================================================
; mzxrules 2024
;==============================================================================


;TOP_FRAME ;3 37 192 30
ROOMSCROLL_VERTICAL_SYNC: ; 3 SCANLINES
    jsr VERTICAL_SYNC

ROOMSCROLL_VERTICAL_BLANK: SUBROUTINE
    jsr HtTask_Run

    lda #SLOT_F4_AU1
    sta BANK_SLOT
    jsr UpdateAudio

    lda #SLOT_F0_ENDRAW
    sta BANK_SLOT
    jsr EnDraw_Del

    lda #SLOT_RW_F0_ROOMSCROLL
    sta BANK_SLOT_RAM

    lda <#KERNEL_SCROLL1
    sta wHaltKernelDraw
    lda >#KERNEL_SCROLL1
    sta wHaltKernelDraw+1

    lda #SLOT_F4_MAIN_DRAW
    sta BANK_SLOT
    jsr POSITION_SPRITES


ROOMSCROLL_OVERSCAN: SUBROUTINE
    sta WSYNC
    lda #2
    sta VBLANK
    lda #36
    sta TIM64T ; 30 scanline timer
    sta wHaltVState
; reset world kernel vars
    lda #7
    sta wENH
    lda #0
    sta wNUSIZ1_T
    sta wREFP1_T

    jsr HtTask_Run

ROOMSCROLL_OVERSCAN_WAIT:
    sta WSYNC
    lda INTIM
    bne ROOMSCROLL_OVERSCAN_WAIT

    jmp ROOMSCROLL_VERTICAL_SYNC


HtTask_ColorFadeTest: SUBROUTINE
    lda Frame
    ;eor #$FF
    ;sec
    ;adc #0
    and #$07
    tay
    ldx FadePF_lut,y
    lda ColorDataPF,x
    sta wCOLUPF_A+19
    ldx FadeBK_lut,y
    lda ColorDataBK,x
    sta wCOLUBK_A+19
    rts


FadeBK_lut:
    .byte $00, $00
FadePF_lut:
    .byte $00, $00, $01, $02, $03, $03, $03


ColorDataPF:
    .byte $00, $F0, $20, $40
ColorDataBK:
    .byte $00, $E0, $A0, $90