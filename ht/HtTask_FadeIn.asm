;==============================================================================
; mzxrules 2026
;==============================================================================

WORLD_COLOR_FG_F0 = [[WorldColorsFg & #$03FF] | $F000]
WORLD_COLOR_BG_F0 = [[WorldColorsBg & #$03FF] | $F000]

HtTask_FadeIn: SUBROUTINE
    lda Halt_TaskTemp
    bmi .init_fadein
    lda rOSFrameState
    bmi .continue ; # OS_FRAME_VBLANK
.rts
    rts
.init_fadein
    lda roomIdNext
    sta roomId

    lda #0
    sta Halt_TaskTemp
    sta wFgColor
    sta wBgColor
    lda #HALT_KERNEL_GAMEVIEW_NOPL
    sta wHaltKernelId
    lda #-16
    sta Halt_Temp0
    rts
.continue
    inc Halt_Temp0
    lda #SLOT_F0_MAIN_DRAW
    sta BANK_SLOT

    lda rRoomColorFlags
    and #$3F
    tax

    lda WORLD_COLOR_FG_F0,x
    and #$0F
    clc
    adc Halt_Temp0
    bmi .fg_zero
    lda WORLD_COLOR_FG_F0,x
    clc
    adc Halt_Temp0
    bne .fg_set ; jmp

.fg_zero
    lda #0
.fg_set
    sta wFgColor

    lda WORLD_COLOR_BG_F0,x
    and #$0F
    clc
    adc Halt_Temp0
    bmi .bg_zero
    lda WORLD_COLOR_BG_F0,x
    clc
    adc Halt_Temp0
    bne .bg_set ; jmp

.bg_zero
    lda #0
.bg_set
    sta wBgColor

    lda Halt_Temp0
    beq .return
    rts

.return
    lda #HALT_KERNEL_GAMEVIEW
    sta wHaltKernelId

    lda #-18
    sta roomTimer
    ldx #$FF
    txs
    inx ; #0
    stx wHaltType
    jmp MAIN_LOADROOM_RETURN
