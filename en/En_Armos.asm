;==============================================================================
; mzxrules 2024
;==============================================================================
EN_ARMOS_STATE_UNFROZEN = #$80
EN_ARMOS_STATE_DOUBLE   = #$02 ; used to draw second armos and stores if alive
EN_ARMOS_STATE_SINGLE   = #$01 ; used to store if base armos is alive

EN_ARMOS_DISPLACE       = #$20 ; units that second Armos is displaced by on x


En_Armos: SUBROUTINE
    lda enState,x
    bmi En_ArmosMain
    ora #EN_ARMOS_STATE_DOUBLE | #EN_ARMOS_STATE_SINGLE
    sta enState,x

    lda #$30
    sta en0X,x
    lda #$34
    sta en0Y,x

    lda enEnemyStep,x
    beq .check_hit
    cmp #1
    adc #0
    sta enEnemyStep,x
    bne .skip_main_start
    lda #EN_ARMOS_STATE_UNFROZEN | #EN_ARMOS_STATE_DOUBLE | #EN_ARMOS_STATE_SINGLE
    sta enState,x
    lda #$0F
    sta enHp,x
    lda #0
.skip_main_start
    asl
    asl
    sta enStun,x
    rts

.check_hit
; Check player hit
    lda enStun,x
    bmi .endCheckHit
    bit plState2
    bvc .endCheckHit ; EN_LAST_DRAWN
    bit CXPPMM
    bpl .endCheckHit
; make player recoil
    clc
    lda #PL_STUN_TIME
    adc plDir
    sta plStun
    lda #SFX_PL_DAMAGE
    sta SfxFlags
    lda #-64
    sta enEnemyStep,x
.endCheckHit
    rts

En_ArmosMain: SUBROUTINE

.checkDamaged
    lda #SLOT_F0_BATTLE
    sta BANK_SLOT

    lda enStun,x
    clc
    adc #4
    bmi .stun_timer_update
    lda #0
.stun_timer_update
    sta enStun,x
    bmi .checkDamaged_testkill ;.endCheckDamaged but we can't reach

; Check primary body combat collision
    jsr HbGetPlAtt
    jsr HbPlAttCollide_EnBB

    lda HbFlags2
    bpl .checkDamaged_secondary ; not HB_BOX_HIT

; Apply damage to base entity
    lda enHp,x
    and #3
    sta enArmosHpTemp
    jsr En_ArmosCalcDamage
    lda enArmosHpTemp
    bmi .kill_single
    lda enHp,x
    and #~$3
    ora enArmosHpTemp
    sta enHp,x
    bpl .checkDamaged_secondary ; jmp

.kill_single
    lda enState,x
    and #~#EN_ARMOS_STATE_SINGLE
    sta enState,x

; Check secondary body combat collision
.checkDamaged_secondary
    lda enState,x
    and #EN_ARMOS_STATE_DOUBLE
    beq .checkDamaged_testkill
    lda Hb_bb_x
    clc
    adc #EN_ARMOS_DISPLACE
    sta Hb_bb_x
    jsr HbPlAttCollide

    lda HbFlags2
    bpl .checkDamaged_testkill ; not HB_BOX_HIT

; Apply damage to secondary entity
    lda enHp,x
    lsr
    lsr
    and #3
    sta enArmosHpTemp
    jsr En_ArmosCalcDamage
    lda enArmosHpTemp
    bmi .kill_double
    asl
    asl
    sta enArmosHpTemp
    lda enHp,x
    and #~$C
    ora enArmosHpTemp
    sta enHp,x
    bpl .checkDamaged_testkill ; jmp

.kill_double
    lda enState,x
    and #~#EN_ARMOS_STATE_DOUBLE
    sta enState,x

.checkDamaged_testkill
    lda #SLOT_F0_EN
    sta BANK_SLOT

    lda enState,x
    and #EN_ARMOS_STATE_DOUBLE | #EN_ARMOS_STATE_SINGLE
    bne .checkDamaged_live
; TODO: Death logic
    jmp EnSys_KillEnemyB
.checkDamaged_live
    eor #$02 ; is exactly 2
    bne .endCheckDamaged
; shift secondary to base
    lda enHp,x
    lsr
    lsr
    sta enHp,x
    lda enState,x
    and #~[#EN_ARMOS_STATE_DOUBLE | #EN_ARMOS_STATE_SINGLE]
    ora #EN_ARMOS_STATE_SINGLE
    sta enState,x
    lda en0X,x
    clc
    adc #EN_ARMOS_DISPLACE
    sta en0X,x
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

.normal_movement
    ldy en0X,x
    lda EnMove_OffgridLUT,y
    bne .move
    ldy en0Y,x
    lda EnMove_OffgridLUT,y
    bne .move

    dec enEnemyStep,x
    bpl .seek_next
    jsr Random
    and #$7
    clc
    adc #2
    sta enEnemyStep,x

    jsr En_Armos_Card_WallCheck
    ldy enDir,x
    lda EnMoveBlockedDir
    ora Bit8,y
    sta EnMoveBlockedDir
    jsr EnMove_Card_RandDir
    sty enDir,x
    bpl .move ; jmp

.seek_next
    jsr En_Armos_Card_WallCheck
    jsr EnMove_Card_SeekDirIfBlocked
    sty enDir,x
.move
    jsr EnMoveDir
.rts
    rts

; enArmosHpTemp stores ArmosHp
En_ArmosCalcDamage: SUBROUTINE
    ldy HbDamage
    lda EnDam_Common,y
    ldy #SFX_EN_DAMAGE
    clc
    adc enArmosHpTemp
    sta enArmosHpTemp
    bpl .set_hitsfx
    ldy #SFX_EN_KILL
.set_hitsfx
    sty SfxFlags
    lda #EN_STUN_TIME
    sta enStun,x
    rts

En_Armos_Card_WallCheck: SUBROUTINE
    ldy #0
    lda enState,x
    and #EN_ARMOS_STATE_DOUBLE
    beq .checkBounds
    iny ; #1

.checkBounds
; Check board boundaries
    lda EnMoveNX
    cmp En_ArmosWallCheckR,y
    lda #0
    bcc .setBlockedL
    ora #EN_BLOCKED_DIR_R
.setBlockedL
    ldx EnMoveNX
    cpx #[EnBoardXL/4] + 1
    bcs .setBlockedD
    ora #EN_BLOCKED_DIR_L
.setBlockedD
    ldx EnMoveNY
    cpx #[EnBoardYD/4] + 1
    bcs .setBlockedU
    ora #EN_BLOCKED_DIR_D
.setBlockedU
    cpx #[EnBoardYU/4]
    bcc .checkPFHit
    ora #EN_BLOCKED_DIR_U
.checkPFHit
    sta EnMoveBlockedDir
    ldx enNum
    rts

En_ArmosWallCheckR:
    .byte #[EnBoardXR/4], #[[EnBoardXR-#EN_ARMOS_DISPLACE]/4]

    LOG_SIZE "En_Armos", En_Armos