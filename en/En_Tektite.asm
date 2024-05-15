;==============================================================================
; mzxrules 2024
;==============================================================================
EN_TEKTITE_TYPE_RED = $0
EN_TEKTITE_TYPE_BLUE = $1
EN_TEKTITE_TYPE_MASK = $1
EN_TEKTITE_BOUNCETIME = #<-$10


En_Tektite:
    lda #EN_TEKTITE_TYPE_RED
    sta enState,x
    bpl .commmon_init
En_TektiteBlue:
    lda #EN_TEKTITE_TYPE_BLUE
    sta enState,x

.commmon_init
    lda #EN_TEKTITE_MAIN
    sta enType,x
    jmp En_TektiteReset

En_TektiteMain: SUBROUTINE

; check damaged
    lda #SLOT_F0_BATTLE
    sta BANK_SLOT
    jsr HbCheckDamaged_CommonRecoil

    lda #SLOT_F0_EN
    sta BANK_SLOT
    lda enHp,x
    bpl .endCheckDamaged
    jmp EnSysEnDie
.endCheckDamaged

; Check player hit
    lda enStun,x
    bmi .endCheckHit
    bit plState2
    bvc .endCheckHit ; EN_LAST_DRAWN
    bit CXPPMM
    bpl .endCheckHit
    lda #-4
    jsr UPDATE_PL_HEALTH
.endCheckHit

.movement
; Adjust en0Y for room collision routines
    lda en0Y,x
    sec
    sbc enTektiteShiftY,x
    sta en0Y,x

    lda enTektiteThink,x
    cmp #1
    adc #0
    sta enTektiteThink,x
    bne .stationary

.bounce
    lda enTektiteBounceTime,x
    cmp #1
    adc #0
    sta enTektiteBounceTime,x
    bmi .do_bounce
    dec enTektiteBounce,x
    bmi En_TektiteReset
    jsr Random
    ora #%100
    and #%111
    sta enDir,x
    lda #EN_TEKTITE_BOUNCETIME
    sta enTektiteBounceTime,x

.do_bounce
    lda Frame
    and #3
    beq .cont_bounce
    lda #SLOT_F0_EN_MOVE2
    sta BANK_SLOT
    jsr EnMove_Ord_WallCheck
    sty enDir,x
    jsr EnMoveDir
.cont_bounce
    ldy enTektiteBounceTime,x
    lda En_TektiteBouncey-EN_TEKTITE_BOUNCETIME,y
    sta enTektiteShiftY,x

.stationary


; Revert en0Y adjustment for display and hitbox purposes
    lda en0Y,x
    clc
    adc enTektiteShiftY,x
    sta en0Y,x
    rts

En_TektiteReset:
    lda #EN_TEKTITE_BOUNCETIME
    sta enTektiteBounceTime,x
    jsr Random
    and #$3F
    adc #$A0
    sta enTektiteThink,x
    jsr Random
    and #7
    clc
    ror
    ora #4
    sta enDir,x

    lda enState,x
    and #1
    eor #1
    beq .set_bounce
    adc #0
.set_bounce
    sta enTektiteBounce,x
    rts

En_TektiteBounce:
    .byte 1, 0


En_TektiteBouncey:
    .byte 0, 2, 4, 6, 7, 7, 8, 8
    .byte 8, 8, 7, 7, 6, 4, 2, 0