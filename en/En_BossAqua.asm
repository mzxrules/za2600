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
    lda #$60
    sta en0X
    lda #$34
    sta en0Y
    lda #6-1
    sta enHp
    lda #-40
    sta enAquaThink
    lda #EN_DIR_R
    sta enDir
    rts

.main

; check damaged
    lda #SLOT_F0_BATTLE
    sta BANK_SLOT
    jsr HbCheckDamaged_CommonRecoil

    lda #SLOT_F0_EN
    sta BANK_SLOT
    lda enHp,x
    bpl .endCheckDamaged
    jsr EnSysRoomKill
    jmp EnSys_KillEnemyB
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

; Movement
    lda enAquaMoveTimer
    cmp #1
    adc #0
    sta enAquaMoveTimer
    bne .move

    jsr Random
    and #$70
    sec
    sbc #$40
    sta enAquaMoveTimer
    lda enDir
    eor #1
    sta enDir

.move
    lda enAquaMoveTimer
    and #7
    bne .skipMove
    lda en0X
    cmp #$54+1
    bcs .test_x_max
    lda #EN_DIR_R
    sta enDir
    bpl .do_move ; jmp
.test_x_max
    cmp #$6C
    bcc .do_move
    lda #EN_DIR_L
    sta enDir

.do_move
    lda #SLOT_F0_EN_MOVE
    sta BANK_SLOT
    ldx #0
    jsr EnMoveDir

.skipMove

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
    lda #SFX_BOSS_ROAR
    sta SfxFlags
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
    SET_A_miType #MI_SPAWN_BALL, -8
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