;==============================================================================
; mzxrules 2024
;==============================================================================

En_Vire: SUBROUTINE
    lda enState,x
    rol
    bcs .main
    lda #$80
    sta enState,x
    lda #4-1
    sta enHp,x

    jsr Random
    and #3
    sta enDir,x

    jsr Random
    and #$F
    sta enVireStep,x
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

; Adjust en0Y for room collision routines
    lda en0Y,x
    sec
    sbc enVireShiftY,x
    sta en0Y,x

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
    bne .skip_bounce

.transform_into_keese
    lda #EN_VIRE_KEESE
    sta enType,x
    lda #-16
    sta enKeeseThink,x
    rts

.normal_movement
    ldy en0X,x
    lda EnMove_OffgridLUT,y
    bne .move
    ldy en0Y,x
    lda EnMove_OffgridLUT,y
    bne .move

    dec enVireStep,x
    bpl .seek_next
    jsr Random
    and #$F
    sta enVireStep,x

    jsr EnMove_Card_WallCheck
    jsr EnMove_Card_RandDir
    sty enDir,x
    bpl .move

.seek_next
    jsr EnMove_Card_WallCheck
    jsr EnMove_Card_RandDirIfBlocked
    sty enDir,x
.move
    lda Frame
    and #1
    bne .handle_bouncey
    jsr EnMoveDir


.handle_bouncey
    lda enDir,x
    and #2 ; EN_DIR_U / EN_DIR_D
    beq .do_bounce
    lda enVireBounceTimer,x
    beq .skip_bounce

.do_bounce
    ldy enVireBounceTimer,x
    iny
    tya
    and #$0F
    sta enVireBounceTimer,x
.skip_bounce

    ldy enVireBounceTimer,x
    lda En_VireBouncey,y
    sta enVireShiftY,x

; Revert en0Y adjustment for display and hitbox purposes
    lda en0Y,x
    clc
    adc enVireShiftY,x
    sta en0Y,x
    rts



En_VireBouncey:
    .byte 0, 2, 4, 6, 7, 7, 8, 8, 8
    .byte 8, 8, 8, 7, 7, 6, 4, 2, 0