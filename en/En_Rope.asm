;==============================================================================
; mzxrules 2021
;==============================================================================
EN_ROPE_ATTACK = $40

En_Rope: SUBROUTINE
    lda #EN_ROPE_MAIN
    sta enType,x
    jsr Random
    and #3
    sta enDir,x
    lda #1 -1
    sta enHp,x
    lda #-12
    sta enRopeTimer,x
    jmp En_Rope_Think

En_RopeMain: SUBROUTINE
; update attack timer
    lda enRopeTimer,x
    cmp #1
    adc #0
    sta enRopeTimer,x

; update think timer
    lda enRopeThink,x
    cmp #1
    adc #0
    sta enRopeThink,x

; check damaged
    lda #SLOT_F0_BATTLE
    sta BANK_SLOT
    jsr HbCheckDamaged_CommonRecoil

    lda #SLOT_F0_EN
    sta BANK_SLOT
    lda enHp,x
    bpl .endCheckDamaged
    jmp EnSys_KillEnemyB
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

.ROPE_MOVEMENT
    lda #SLOT_F0_EN_MOVE
    sta BANK_SLOT

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
    and #EN_ENEMY_MOVE_RECOIL
    beq .normal_movement
    jmp EnMove_Recoil

.normal_movement
    ldy en0X,x
    lda EnMove_OffgridLUT,y
    bne .move
    ldy en0Y,x
    lda EnMove_OffgridLUT,y
    bne .move

.solveNextDirection

; What's the plan, snake man?
    jsr EnMove_Card_WallCheck
    lda enState,x
    and #EN_ROPE_ATTACK
    bne .tryContMoveDir

    lda enRopeTimer,x
    bne .tryContMoveDir

; try to attack
.tryAttackX
    lda plX
    and #$FC
    cmp en0X,x
    bne .tryAttackY
    ldy #EN_DIR_U
    lda plY
    cmp en0Y,x
    bpl .setAttackDir
    ldy #EN_DIR_D
    bpl .setAttackDir ; always branch

.tryAttackY
    lda plY
    and #$FC
    cmp en0Y,x
    bne .testThink
    ldy #EN_DIR_R
    lda plX
    cmp en0X,x
    bpl .setAttackDir
    ldy #EN_DIR_L
    bpl .setAttackDir ; always branch

.setAttackDir
    sty enDir,x
    lda #EN_ROPE_ATTACK
    sta enState,x
    bpl .tryContMoveDir

.testThink
    lda enRopeThink,x
    beq .newDir

.tryContMoveDir ; We want to continue moving in the current direction
    jsr EnMove_Card_RandDirIfBlocked
    tya
    cmp enDir,x
    beq .move
    ; hit a wall or something, so reset
    bne .setNewDir
.newDir
    jsr EnMove_Card_RandDir
.setNewDir
    sty enDir,x

    lda enState,x
    and #EN_ROPE_ATTACK
    beq .skipResetAttack
    lda #0
    sta enState,x
    lda #-12
    sta enRopeTimer,x
.skipResetAttack
    jsr En_Rope_Think

.move
    lda enState,x
    and #EN_ROPE_ATTACK
    bne .moveNow

    lda Frame
    ror
    bcc .rts
.moveNow
    jsr EnMoveDir

.rts
    rts

En_Rope_Think: SUBROUTINE
    lda Rand16
    and #$1F
    adc #$C0
    sta enRopeThink,x
    rts
    LOG_SIZE "En_Rope", En_Rope