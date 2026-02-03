;==============================================================================
; mzxrules 2026
;==============================================================================

HtTask_DisplayLevel: SUBROUTINE
    lda rOSFrameState
    bmi .continue ; #OS_FRAME_VBLANK
.rts
    rts

.continue
    lda #HALT_KERNEL_GAMEVIEW_BLACK
    sta wHaltKernelId

    lda worldId
    sec
    sbc #LV_A1-2
    lsr
    and #$0F
    ora #$A0
    cmp #$AA
    bcs .end
    sta shopPrice+1

    lda #TEXT_MODE_SHOP
    sta wTextMode
    sta mesgDY

    lda #GI_NONE
    sta shopItem+0
    sta shopItem+1
    sta shopItem+2

    lda #MESG_LEVEL
    sta mesgId

    lda #$AA
    sta shopPrice
    sta shopPrice+2

    lda #MESG_CHAR_SPACE
    sta mesgChar+3
    sta mesgChar+4
    sta mesgChar+5

    lda #EN_NPC_LEVEL
    sta enType

    inc Halt_Temp0
    beq .end

    rts
.end
    ldx #$FF
    stx Halt_Temp0
    inx
    stx enType
    stx wTextMode
    jmp Halt_TaskNext
