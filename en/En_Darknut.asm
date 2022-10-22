;==============================================================================
; mzxrules 2021
;==============================================================================

En_Darknut: SUBROUTINE
    lda #EN_DARKNUT_MAIN
    sta enType
    jsr Random
    and #3
    sta enDir
    lda #2 -1
    sta enHp
    
En_DarknutMain:
; update stun timer
    lda enStun
    cmp #1
    adc #0
    sta enStun
    lda #$F0
    jsr EnSetBlockedDir

.checkDamaged
; if collided with weapon && stun == 0,
    lda CXM0P
    bpl .endCheckDamaged
    lda enStun
    bne .endCheckDamaged
    lda plItemDir
    cmp enDir
    beq .defSfx
    jsr EnSys_Damage
    bpl .defSfx
    ldx #-32
    stx enStun
    clc
    adc enHp
    sta enHp
    bpl .endCheckDamaged
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
    lda Frame
    and #1
    beq .rts
    ldx enDir
    jmp EnMoveDirDel
.rts
    rts
    LOG_SIZE "En_Darknut", En_Darknut