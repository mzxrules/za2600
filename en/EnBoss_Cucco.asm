;==============================================================================
; mzxrules 2021
;==============================================================================

EnBoss_Cucco: SUBROUTINE
    lda #>SprE24
    sta enSpr+1
    lda #<SprE24
    sta enSpr
    lda #%0111
    sta wNUSIZ1_T
    lda #$0a
    sta wEnColor
    lda #15
    sta wENH
    lda enState
    bmi .skipInit
    ora #$80
    sta enState
.skipInit
    lda #$40
    sta enX
    sta enY
    rts

    lda Frame
    bne .rts
    jsr EnSysEnDie
    lda #0
    sta wNUSIZ1_T
.rts
    rts

    LOG_SIZE "EnBoss_Cucco", EnBoss_Cucco