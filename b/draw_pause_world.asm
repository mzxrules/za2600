;==============================================================================
; mzxrules 2022
;==============================================================================

    INCLUDE "c/draw_data.asm"

DRAW_PAUSE_WORLD:

    ldy PAnim
    sty roomDY
    INCLUDE "c/draw_world_init.asm"
    

KERNEL_PAUSE_WORLD_MAIN: SUBROUTINE ; 192 scanlines
    sta WSYNC
    lda INTIM
    bne KERNEL_PAUSE_WORLD_MAIN
    sta VBLANK
    lda #0
    sta COLUBK
    sta PF0
    sta PF1
    sta PF2

; Skip HUD
    ldy #20
.loop
    sta WSYNC
    dey
    bne .loop

; Pad with black above world view    
    ldx PAnim
    cpx #19
    bpl .skipVerticalShift
.wsyncLoop
    sta WSYNC
    sta WSYNC
    sta WSYNC
    sta WSYNC
    sta WSYNC
    sta WSYNC
    sta WSYNC
    sta WSYNC
    inx
    cpx #19
    bmi .wsyncLoop
.skipVerticalShift

    lda rFgColor
    sta COLUPF
    ldy PAnim
    lda .RoomHeight,y
    tay
KERNEL_PAUSE_WORLD_RESUME:
    jsr PosWorldObjects
    sta WSYNC

    lda #SLOT_SPR_A
    sta BANK_SLOT

    lda #$FF
    sta PF0
    sta PF1
    sta PF2
    lda #1
    sta VDELP0
    
    jsr rKERNEL ; JUMP WORLD KERNEL
    
; Post Kernel
    lda rFgColor
    sta COLUBK
    lda #0
    sta PF1
    sta PF2
    sta GRP1
    sta GRP0
    sta ENAM0
    sta PF0

    sta WSYNC
    sta COLUBK
    sta WSYNC
    sta WSYNC
    sta WSYNC
    rts


.RoomHeight
    .byte 03, 07, 11, 15, 19, 23, 27, 31, 35, 39, 43, 47, 51, 55, 59, 63
    .byte 67, 71, 75, 79    