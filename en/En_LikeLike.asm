;==============================================================================
; mzxrules 2021
;==============================================================================

En_LikeLike: SUBROUTINE
    jsr SeekDir
    lda #6 -1
    sta enHp
    lda #EN_LIKE_LIKE_MAIN
    sta enType

En_LikeLikeMain: SUBROUTINE
; update stun timer
    lda enStun
    cmp #1
    adc #0
    sta enStun

.checkDamaged
; if collided with weapon && stun == 0,
    lda enStun
    cmp #-8
    bmi .endCheckDamaged

    lda #SLOT_BATTLE
    sta BANK_SLOT
    jsr HbGetPlAtt
    jsr HbPlAttCollide_EnBB

; Get damage
    ldx HbDamage
    lda EnDam_Rope,x
    tay

    lda #SLOT_MAIN
    sta BANK_SLOT
    lda HbFlags
    beq .endCheckDamaged

    tya
    ldx #-32
    stx enStun
    ldx #SFX_EN_DAMAGE
    stx SfxFlags
    clc
    adc enHp
    sta enHp
    bpl .endCheckDamaged
    lda plState
    and #~PS_LOCK_MOVE
    sta plState
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
    sta enLLTimer
.endCheckHit

    ; Movement Routine
    lda #$F0
    jsr EnSetBlockedDir
    lda EnSysBlockedDir
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
    lda plState
    ora #PS_LOCK_MOVE
    sta plState

    lda Frame
    and #$3F
    cmp enLLTimer
    bne .skipSuccDamage
    lda #-8
    jsr UPDATE_PL_HEALTH
.skipSuccDamage

    lda enX
    sta plX
    lda enY
    sta plY
    rts

    LOG_SIZE "En_LikeLike", En_LikeLike