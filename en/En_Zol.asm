;==============================================================================
; mzxrules 2024
;==============================================================================

En_Zol: SUBROUTINE
    lda enState,x
    bmi .main

.init
    lda #2-1
    sta enHp,x

    lda #$80
    sta enState,x
    jsr Random
    and #3
    sta enDir,x

    lda #-2-1
    sta enZolStep,x

    lda #-32
    sta enZolStepTimer,x
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
    jsr EnMove_RecoilMove
    lda enState,x
    and #EN_ENEMY_MOVE_RECOIL
    bne .rts

.transform_into_gel
    lda #EN_ZOL_GEL
    sta enType,x
    lda #0
    sta enState,x
    lda #-16
    sta enGelStepTimer,x
.rts
    rts

.normal_movement
; if off frame, end movement logic
    txa ; enNum
    eor Frame
    and #1
    beq .rts

    lda enZolStepTimer,x
    cmp #1
    adc #0
    sta enZolStepTimer,x
    bne .rts

; timer is zero, we should be moving

; if positioned off grid, continue moving
    ldy en0X,x
    lda EnMove_OffgridLUT,y
    bne .move
    ldy en0Y,x
    lda EnMove_OffgridLUT,y
    bne .move

    jsr EnMove_Card_WallCheck

    lda enZolStep,x
    cmp #1
    adc #0
    sta enZolStep,x
    bne .go_direction
.reset_movement
    lda #-2-1
    sta enZolStep,x
    lda #-32
    sta enZolStepTimer,x

    jsr EnMove_Card_NewDir
    sty enDir,x
    bpl .rts ; jmp


.go_direction
    jsr EnMove_Card_RandDirIfBlocked
    sty enDir,x

.move
    jmp EnMoveDir
