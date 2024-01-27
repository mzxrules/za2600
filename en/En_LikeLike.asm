;==============================================================================
; mzxrules 2021
;==============================================================================
EN_LIKELIKE_LOCK = #$40
EN_LIKELIKE_THINK = #$01
En_LikeLike: SUBROUTINE
    lda #EN_LIKE_LIKE_MAIN
    sta enType,x

    lda #10 -1
    sta enHp,x
    rts

En_LikeLikeMain: SUBROUTINE
; check damaged
    lda #SLOT_F0_BATTLE
    sta BANK_SLOT
    jsr HbCheckDamaged_CommonRecoil

    lda #SLOT_F0_EN
    sta BANK_SLOT
    lda enHp,x
    bpl .endCheckDamaged
    lda plState
    and #~PS_LOCK_MOVE
    sta plState
    jmp EnSysEnDie
.endCheckDamaged

    ; Check if player was sucked in
    lda enState,x
    and #EN_LIKELIKE_LOCK
    beq .playerhit

.lockInPlace
    lda plState
    ora #PS_LOCK_MOVE
    sta plState

    lda Frame
    cmp enLLTimer,x
    bne .skipSuccDamage
    lda #-8
    jsr UPDATE_PL_HEALTH
.skipSuccDamage

    lda en0X,x
    sta plX
    lda en0Y,x
    sta plY
    rts

.playerhit
    ; Check player hit
    lda enStun,x
    bmi .endCheckHit
    bit plState2
    bvc .endCheckHit ; EN_LAST_DRAWN
    bit CXPPMM
    bpl .endCheckHit
    lda #-8
    jsr UPDATE_PL_HEALTH
    lda plState
    and #PS_LOCK_MOVE
    bne .endCheckHit

    lda enState,x
    ora #EN_LIKELIKE_LOCK
    sta enState,x
    lda Frame
    sta enLLTimer,x
.endCheckHit

; Movement Routine
    lda #SLOT_F0_EN_MOV
    sta BANK_SLOT

    lda enLLThink,x
    cmp #1
    adc #0
    sta enLLThink,x

; update EnMoveNX/NY
    lda en0X,x
    lsr
    lsr
    sta EnMoveNX
    lda en0Y,x
    lsr
    lsr
    sta EnMoveNY

; check recoil movement
    lda enState,x
    and #EN_ENEMY_MOVE_RECOIL | #EN_LIKELIKE_LOCK
    cmp #EN_ENEMY_MOVE_RECOIL
    bne .normal_movement
    jmp EnMov_Recoil

.normal_movement
    ldy en0X,x
    lda en_offgrid_lut,y
    bne .move
    ldy en0Y,x
    lda en_offgrid_lut,y
    bne .move

.solveNextDirection
    jsr EnMov_Card_WallCheck

    lda enLLThink,x
    bne .contdir

.newdir
    jsr EnMov_Card_NewDir
    bpl .setNewDir

.contdir
    jsr EnMov_Card_ContDir
    tya
    cmp enDir,x
    beq .move

.setNewDir
    sty enDir,x
    lda Rand16
    and #$1F
    adc #$D0
    sta enLLThink,x

.move
    lda Frame
    and #1
    bne .rts
    jsr EnMoveDir
.rts
    rts

    LOG_SIZE "En_LikeLike", En_LikeLike