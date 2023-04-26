;==============================================================================
; mzxrules 2021
;==============================================================================
Rs_GameOver: SUBROUTINE
    lda enInputDelay ; replaced if init taken
    ldx plHealth
    bne .skipInit
    dec plHealth
    stx wBgColor
    stx wFgColor
    stx enType
    stx enType+1
    stx roomFlags
    stx mesgId
    inx
    stx KernelId
    inx
    stx plState ; PS_LOCK_ALL

    ldx #RS_GAME_OVER
    stx roomRS
    ldx #$80
    stx plY

    ldx #MS_PLAY_OVER
    stx SeqFlags
    lda #-$20 ; input delay timer
.skipInit
    cmp #1
    adc #0
    sta enInputDelay
    bne .rts
    bit INPT4
    bmi .rts
    jmp RESPAWN
.rts
    rts