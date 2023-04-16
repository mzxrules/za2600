;==============================================================================
; mzxrules 2021
;==============================================================================
En_Octorok: SUBROUTINE
    jsr Random
    and #$7F
    ora #$10
    sta enTimer
    and #3
    sta enDir
    lda #1
    sta enHp
    lda #COLOR_EN_ROK_BLUE
    sta wEnColor
    lda #EN_OCTOROK_MAIN
    sta enType

En_OctorokMain:
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
    and #$3F
    bne .skipFire
    lda #1
    sta MiSysAddType
    clc
    lda enX
    adc #3
    sta MiSysAddX
    lda enY
    adc #2
    sta MiSysAddY
    ldy enDir
    lda EN_ATAN2_CARDINAL,y
    jsr MiSpawn
.skipFire
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

EN_ATAN2_CARDINAL:
    .byte DEG_180, DEG_000, DEG_090, DEG_270
    LOG_SIZE "En_Octorok", En_Octorok