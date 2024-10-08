;==============================================================================
; mzxrules 2022
;==============================================================================

En_BossGohma: SUBROUTINE
    bit enState
    bmi .skipInit
    lda #$40
    sta en0X
    sta en0Y
    lda #[$80 | $00 | GOHMA_ANIM_0]
    sta enState
    jsr Random
    ora #$80
    sta enGohmaTimer
.skipInit
; Weapon Detection
    lda CXM0P
    bpl .endWeaponCollision
    lda plState2
    and #PS_ACTIVE_ITEM
    eor #PLAYER_ARROW
    bne .defSfx
.arrowCollision
    lda plItemDir
    eor #PL_DIR_U
    bne .defSfx
    lda enState
    and #7
    eor #GOHMA_ANIM_2
    bne .defSfx

; Check X hit
    lda m0X
    sec
    sbc #4
    sbc en0X
    cmp #9
    bcs .endWeaponCollision

; Check y hit
    lda m0Y
    sec
    sbc #$100-7
    sec
    sbc en0Y
    cmp #4
    bcs .endWeaponCollision
    lda #$80
    sta m0Y
    ldx enNum
    jsr EnSysRoomKill
    jmp EnSys_KillEnemyB
    bmi .endWeaponCollision ; always branch

.defSfx
    lda #SFX_EN_DEF
    sta SfxFlags
    bmi .endWeaponCollision ; always branch


.endWeaponCollision
; update state
    dec enGohmaTimer
    bne .skipStateChange

    clc
    lda enState
    adc #2
    and #~$08
    sta enState

    and #7
    lsr
    tay

    lda En_BossGohma_AnimTimer,y
    sta enGohmaTimer

.skipStateChange
    lda Frame
    and #1
    beq .endMove
    bit enState
    bvc .left
.right
    inc en0X
    lda en0X
    cmp #$5C
    bne .endMove
    lda enState
    eor #$40
    sta enState
    bne .endMove ; always branch
.left
    dec en0X
    lda en0X
    cmp #$24
    bne .endMove
    lda enState
    eor #$40
    sta enState
    bne .endMove ; always branch

.endMove
    rts


En_BossGohma_AnimTimer:
    .byte $0, $20, $60, $20
    LOG_SIZE "En_BossGohma", En_BossGohma