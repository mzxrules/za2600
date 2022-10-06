;==============================================================================
; mzxrules 2021
;==============================================================================

EnDarknut: SUBROUTINE
    lda #EN_DARKNUT_MAIN
    sta enType
    jsr Random
    and #3
    sta enDir
    lda #1
    sta enHp
    
EnDarknutMain:
    lda #>SprE0
    sta enSpr+1
; update stun timer
    lda enStun
    cmp #1
    adc #0
    sta enStun
    asl
    asl
    adc #COLOR_EN_RED
    sta enColor
    lda #$F0
    jsr EnSetBlockedDir

.checkDamaged
; if collided with weapon && stun == 0,
    lda CXM0P
    bpl .endCheckDamaged
    lda enStun
    bne .endCheckDamaged
    lda plDir
    cmp enDir
    beq .defSfx
    lda #-32
    sta enStun
    dec enHp
    bne .endCheckDamaged
    jmp EnSysEnDie
.defSfx
    lda #SFX_DEF
    sta SfxFlags
.endCheckDamaged

    ; Check player hit
    bit enStun
    bmi .endCheckHit
    bit CXPPMM
    bpl .endCheckHit
    lda #-8
    jsr UPDATE_PL_HEALTH
.endCheckHit

.checkBlocked
    lda enBlockDir
    ldx enDir
    and Bit8,x
    beq .endCheckBlocked
    jsr NextDir
    jmp .move
.endCheckBlocked

.randDir
    lda enX
    and #7
    bne .move
    lda enY
    and #7
    bne .move
    lda Frame
    eor enBlockDir
    and #$20
    beq .move
    eor enBlockDir
    sta enBlockDir
    jsr NextDir

.move
    ldx enDir
    ldy Mul8,x
    sty enSpr

    lda Frame
    and #1
    beq .rts
    jmp EnMoveDirDel
.rts
    rts
    LOG_SIZE "EnDarknut", EnDarknut