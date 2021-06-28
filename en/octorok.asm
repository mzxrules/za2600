;==============================================================================
; mzxrules 2021
;==============================================================================
EnOctorok: SUBROUTINE
    jsr Random
    and #$7F
    ora #$10
    sta enTimer
    and #3
    sta enDir
    lda #1
    sta enHp
    lda #COLOR_OCTOROK_BLUE
    sta enColor
    lda #EN_OCTOROK_MAIN
    sta enType
    
EnOctorokMain:
    lda #>SprE4
    sta enSpr+1
    ldx enDir
    lda Mul8,x
    clc 
    adc #<SprE4
    sta enSpr
    
    lda #1
    bit Frame
    beq .checkBlocked
    ldx enTimer
    bpl .checkBlocked
    dex
    rts
    
.checkBlocked
    lda #$F0
    jsr EnSetBlockedDir
    lda enBlockDir
    ldx enDir
    and Bit8,x
    beq .endCheckBlocked
    jsr NextDir
.endCheckBlocked

    lda Frame
    and #1
    bne .rts
    jsr EnMoveDirDel
.rts
    rts
    
ENEMY_ROT:
   ;.byte 0, 2, 1, 3 ; enemy direction sprite indices
    .byte 2, 3, 1, 0 ; clockwise
    .byte 3, 2, 0, 1 ; counterclock
    
    LOG_SIZE "EnOctorok", EnOctorok