;==============================================================================
; mzxrules 2024
;==============================================================================

; Head is base position
EN_BOSS_AQUA_FIRE_STATE = 2

En_BossAqua: SUBROUTINE
    lda enState
    and #$80
    bne .main
    ora #$80
    sta enState
    lda #$3C
    sta en0X
    lda #$3C
    sta en0Y
    lda #6-1
    sta enHp
    lda #-40
    sta enAquaThink
    rts

.main

; check damaged
    lda #SLOT_BATTLE
    sta BANK_SLOT
    jsr HbCheckDamaged_CommonRecoil

    lda #SLOT_EN_A
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
    lda #-8
    jsr UPDATE_PL_HEALTH
.endCheckHit

; behavior
    lda enAquaThink
    cmp #1
    adc #0
    sta enAquaThink

    bne .handleCurState

.nextState
    lda enState
    and #EN_BOSS_AQUA_FIRE_STATE
    bne .end_firing
.begin_firing
    lda #-60
    sta enAquaThink
    lda enState
    ora #EN_BOSS_AQUA_FIRE_STATE
    sta enState
    rts
.end_firing
    lda #-100
    sta enAquaThink
    lda enState
    and #~EN_BOSS_AQUA_FIRE_STATE
    sta enState
    rts

.handleCurState
    lda enState
    and #EN_BOSS_AQUA_FIRE_STATE
    beq .rts
.prepare_to_fire
    lda enAquaThink
    cmp #-40
    beq .fire0
    cmp #-20
    beq .fire1
.rts
    rts

.fire1
    inx
.fire0
    lda #2
    sta miType,x
    ldy en0X
    dey
    dey
    sty mi0X,x
    ldy en0Y
    dey
    dey
    sty mi0Y,x
    rts