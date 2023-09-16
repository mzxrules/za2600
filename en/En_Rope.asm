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

; target next
    lda en0X,x
    lsr
    lsr
    sta enNX,x
    lda en0Y,x
    lsr
    lsr
    sta enNY,x

    jmp En_Rope_Think

En_RopeMain: SUBROUTINE
; update stun timer
    lda enStun,x
    cmp #1
    adc #0
    sta enStun,x

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

.checkDamaged
; if collided with weapon && stun == 0,
    lda enStun,x
    bne .endCheckDamaged
    lda #SLOT_BATTLE
    sta BANK_SLOT
    jsr HbGetPlAtt
    jsr HbPlAttCollide_EnBB

; Get damage
    ldy HbDamage
    lda EnDam_Rope,y
    sta Temp0

    lda #SLOT_EN_A
    sta BANK_SLOT
    lda HbFlags
    beq .endCheckDamaged

.gethit
    lda Temp0 ; fetch damage
    ldy #-32
    sty enStun,x
    clc
    adc enHp,x
    sta enHp,x
    bpl .endCheckDamaged
    jmp EnSysEnDie
.defSfx
    lda #SFX_DEF
    sta SfxFlags
.endCheckDamaged

; Check player hit
    lda enStun,x
    bmi .endCheckHit
    bit CXPPMM
    bpl .endCheckHit
    lda #-4
    jsr UPDATE_PL_HEALTH
.endCheckHit

.ROPE_MOVEMENT
    lda #SLOT_EN_MOV
    sta BANK_SLOT

; update EnMoveNX
    lda enNX,x
    sta EnMoveNX
    lda enNY,x
    sta EnMoveNY

    lda enNX,x
    asl
    asl
    cmp en0X,x
    bne .move
    lda enNY,x
    asl
    asl
    cmp en0Y,x
    bne .move

.solveNextDirection

; What's the plan, snake man?
    jsr EnMov_Card_WallCheck
    lda enState,x
    and #EN_ROPE_ATTACK
    bne .tryContMoveDir

    lda enRopeTimer,x
    bne .tryContMoveDir

; try to attack
.tryAttackX
    lda plX
    lsr
    lsr
    cmp enNX,x
    bne .tryAttackY
    ldy #EN_DIR_U
    lda plY
    cmp en0Y,x
    bpl .setAttackDir
    ldy #EN_DIR_D
    bpl .setAttackDir ; always branch

.tryAttackY
    lda plY
    lsr
    lsr
    cmp enNY,x
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
    jsr EnMov_Card_RandDirIfBlocked
    tya
    cmp enDir,x
    beq .move
    ; hit a wall or something, so reset
    bne .setNewDir
.newDir
    jsr EnMov_Card_RandDir
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