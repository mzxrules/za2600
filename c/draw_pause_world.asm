;==============================================================================
; mzxrules 2022
;==============================================================================

    INCLUDE "c/draw_data.asm"

DRAW_PAUSE_WORLD:
    ldy rHaltWorldDY
    sty roomDY
    INCLUDE "c/draw_world_init.asm"

KERNEL_MAIN_PAUSE_WORLD:  ; 192 scanlines
    sta WSYNC
    lda INTIM
    bne KERNEL_MAIN_PAUSE_WORLD
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
    ldx rHaltWorldDY
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
    ldy rHaltWorldDY
    lda .RoomHeight,y
    tay

    jsr PosWorldObjects
    sta WSYNC

    ; y = room height
KERNEL_PAUSE_WORLD_RESUME:
    lda #$FF
    sta PF0
    sta PF1
    sta PF2
    lda #1
    sta VDELP0

    jmp rKERNEL_WORLD ; JUMP WORLD KERNEL
