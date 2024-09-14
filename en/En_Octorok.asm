;==============================================================================
; mzxrules 2021
;==============================================================================
EN_OCTOROK_RARE = $2
EN_OCTOROK_FIRING = $1

En_OctorokBlue: SUBROUTINE
    lda enState,x
    ora #EN_OCTOROK_RARE
    sta enState,x

    lda #2 -1
    sta enHp,x

En_Octorok: SUBROUTINE
    lda #EN_OCTOROK_MAIN
    sta enType,x
    jsr Random

    and #3
    sta enDir,x

    jsr En_Octorok_ShootT
    jmp En_Octorok_Think


En_OctorokMain: SUBROUTINE
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

; Movement
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

; What's the plan, octo dad?


; update shoot timer
    lda enOctorokShootT,x
    cmp #1
    adc #0
    sta enOctorokShootT,x

    bne .skip_
    jsr En_Octorok_ShootT
; Toggle Walking/Firing Rock state, update shoot timer
    lda enState,x
    eor #EN_OCTOROK_FIRING
    sta enState,x
    and #1
    beq .rts

    lda #$D0
    sta enOctorokShootT,x
    rts

.skip_

.test_fire_rock
    lda enState,x
    ror
    bcc .walk

; Waiting to fire the rock
    lda enOctorokShootT,x
    cmp #$F0
    bne .end_test_fire_rock

.fire_rock
    lda enDir,x
    sta mi0Dir,x
    SET_A_miType #MI_SPAWN_ROCK, -4
    sta miType,x
    lda en0X,x
    sta mi0X,x
    lda en0Y,x
    sta mi0Y,x
.end_test_fire_rock
    rts


.walk
; update think timer
    lda enOctorokThink,x
    cmp #1
    adc #0
    sta enOctorokThink,x


    ldy en0X,x
    lda EnMove_OffgridLUT,y
    bne .move
    ldy en0Y,x
    lda EnMove_OffgridLUT,y
    bne .move

.solveNextDirection
    jsr EnMove_Card_WallCheck

    lda enOctorokThink,x
    bne .contdir

.newdir
    jsr EnMove_Card_RandDir
    bpl .setNewDir

.contdir
    jsr EnMove_Card_RandDirIfBlocked
    tya
    cmp enDir,x
    beq .move

.setNewDir
    sty enDir,x
    jsr En_Octorok_Think
    rts

.move
    ldx enNum
    lda enState,x
    and #EN_OCTOROK_RARE
    ora #1
    and Frame
    and #3
    beq .rts
    jmp EnMoveDir
.rts
    rts

En_Octorok_Think: SUBROUTINE
    lda Rand16
    and #$1F
    adc #$D8
    sta enOctorokThink,x
    rts

En_Octorok_ShootT: SUBROUTINE
    jsr Random
    and #$F8
    bne .skip
    lda #$80
.skip
    sta enOctorokShootT,x
    rts

/*
ENEMY_ROT:
    .byte #EN_DIR_U, #EN_DIR_D, #EN_DIR_R, #EN_DIR_L ; clockwise spin
    .byte #EN_DIR_D, #EN_DIR_U, #EN_DIR_L, #EN_DIR_R ; counterclock
*/
    LOG_SIZE "En_Octorok", En_Octorok