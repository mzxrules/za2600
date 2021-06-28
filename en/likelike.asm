;==============================================================================
; mzxrules 2021
;==============================================================================

EnLikeLike: SUBROUTINE
    jsr SeekDir
    lda #6
    sta enHp
    lda #EN_LIKE_LIKE_MAIN
    sta enType
    
EnLikeLikeMain: SUBROUTINE
    ; Draw Routine
    lda #>SprE16
    sta enSpr+1
    lda Frame
    lsr
    lsr
    lsr
    and #1
    tax
    lda Mul8,x
    clc 
    adc #<SprE16
    sta enSpr
    
; update stun timer
    lda enStun
    cmp #1
    adc #0
    sta enStun
    asl
    asl
    adc #COLOR_DARKNUT_RED
    sta enColor
    
.checkDamaged
; if collided with weapon && stun == 0,
    lda CXM0P
    bpl .endCheckDamaged
    lda enStun
    cmp #-8
    bmi .endCheckDamaged
    lda #-32
    sta enStun
    lda #SFX_DEF
    sta SfxFlags
    dec enHp
    bne .endCheckDamaged
    jmp EnSysEnDie
.endCheckDamaged
    
    ; Check if player was sucked in
    bit enState
    bvs .lockInPlace
    
    ; Check player hit
    bit enStun
    bmi .endCheckHit
    bit CXPPMM
    bpl .endCheckHit
    lda #-8
    jsr UPDATE_PL_HEALTH
    lda enState
    ora #$40
    sta enState
    lda Frame
    and #$3F
    sta enSuccTimer
.endCheckHit
    
    ; Movement Routine
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
    
.lockInPlace
    lda Frame
    and #$3F
    cmp enSuccTimer
    bne .skipSuccDamage
    lda #-8
    jsr UPDATE_PL_HEALTH
.skipSuccDamage

    lda enX
    sta plX
    lda enY
    sta plY
    rts
    
    LOG_SIZE "EnLikeLike", EnLikeLike