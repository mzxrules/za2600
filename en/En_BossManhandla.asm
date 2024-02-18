;==============================================================================
; mzxrules 2024
;==============================================================================
EN_BOSS_MANHANDLA_END_BOUNCE = #$40

En_BossManhandla: SUBROUTINE
    bit enState
    bmi .main
    lda #$8F
    sta enState

; 4 hp per head
    lda #$40 - $10
    sta enHp
    sta enHp+1
    sta enHp+2
    sta enHp+3

    lda #4
    sta enDir

    lda #$40 ; 40
    sta en0X
    lda #$2C ; 2C
    sta en0Y
    rts
.main

.checkDamaged
    lda #SLOT_F0_BATTLE
    sta BANK_SLOT
    jsr HbGetPlAtt
    jsr HbManhandla

    lda #0
    sta enManhandlaHitFlags

.checkHitLeft
    lda en0Y
    sta Hb_bb_y

    lda en0X
    clc
    adc #-12
    sta Hb_bb_x
    jsr HbPlAttCollide
    lda HbFlags2
    bpl .checkHitRight
    lda #EN_BLOCKED_DIR_L
    sta enManhandlaHitFlags

.checkHitRight
    lda en0X
    clc
    adc #12
    sta Hb_bb_x
    jsr HbPlAttCollide
    lda HbFlags2
    bpl .checkHitUp
    lda #EN_BLOCKED_DIR_R
    ora enManhandlaHitFlags
    sta enManhandlaHitFlags

.checkHitUp
    lda en0X
    sta Hb_bb_x

    lda en0Y
    clc
    adc #12
    sta Hb_bb_y
    jsr HbPlAttCollide
    lda HbFlags2
    bpl .checkHitDown
    lda #EN_BLOCKED_DIR_U
    ora enManhandlaHitFlags
    sta enManhandlaHitFlags

.checkHitDown
    lda en0Y
    clc
    adc #-12
    sta Hb_bb_y
    jsr HbPlAttCollide
    lda HbFlags2
    bpl .checkHitComplete
    lda #EN_BLOCKED_DIR_D
    ora enManhandlaHitFlags
    sta enManhandlaHitFlags

.checkHitComplete

; compute damage dealt per head
    ldy HbDamage
    lda EnDam_Manhandla,y
    asl
    asl
    asl
    asl
    sta HbDamage

    lda #SLOT_F0_EN
    sta BANK_SLOT

    lda enManhandlaInvince
    eor #%1111
    and enManhandlaHitFlags
    and enState
    sta enManhandlaHitFlags
    beq .endCheckDamaged

; update invince flags
    ora enManhandlaInvince
    sta enManhandlaInvince

; reset stun timer
    lda #-32
    sta enManhandlaStun

; update hp
.updateHpLeft
    lda #EN_BLOCKED_DIR_L
    and enManhandlaHitFlags
    beq .updateHpRight

    ldy #EN_DIR_L
    jsr En_BossManhandlaUpdateHp

.updateHpRight
    lda #EN_BLOCKED_DIR_R
    and enManhandlaHitFlags
    beq .updateHpUp

    ldy #EN_DIR_R
    jsr En_BossManhandlaUpdateHp

.updateHpUp
    lda #EN_BLOCKED_DIR_U
    and enManhandlaHitFlags
    beq .updateHpDown

    ldy #EN_DIR_U
    jsr En_BossManhandlaUpdateHp

.updateHpDown
    lda #EN_BLOCKED_DIR_D
    and enManhandlaHitFlags
    beq .testHp

    ldy #EN_DIR_D
    jsr En_BossManhandlaUpdateHp

.testHp
    lda enState
    and #$0F
    bne .endCheckDamaged
    jsr EnSysRoomKill
    jmp EnSysEnDie

.endCheckDamaged

; Check player hit
    lda enManhandlaStun,x
    bmi .endCheckHit
    bit CXPPMM
    bpl .endCheckHit
    lda #-8
    jsr UPDATE_PL_HEALTH
.endCheckHit

    lda enManhandlaStun
    cmp #1
    adc #0
    sta enManhandlaStun
    bne .skipResetInvince
    sta enManhandlaInvince
.skipResetInvince

; Movement
    lda #SLOT_F0_EN_MOVE
    sta BANK_SLOT

    lda #1
    sta Temp3 ; Loop

.movement_loop

; calculate speed factor
    ldy #0
    lda enState
    and #$0F
.loop_bitcount
    lsr
    bcc .skip_count
    iny
.skip_count
    bne .loop_bitcount

    lda En_BossManhandla_Speed-1,y
    sec
    adc enManhandlaSpdFrac
    sta enManhandlaSpdFrac
    bcc .skipMove

.movement
    bit enState ;
    bvs .move ; EN_BOSS_MANHANDLA_END_BOUNCE

    lda enState
    and #3
    tax

    lda en0X
    cmp En_BossManhandla_BoardL,x
    beq .bounce
    cmp En_BossManhandla_BoardR,x
    beq .bounce

    lda enState
    lsr
    lsr
    and #3
    tax

    lda en0Y
    cmp En_BossManhandla_BoardU,x
    beq .bounce
    cmp En_BossManhandla_BoardD,x
    beq .bounce

; Try select new direction
    lda enManhandlaTimer
    bne .move

    ldx enNum
    jsr EnMove_Ord_SeekDir
    jsr Random
    lsr
    bcs .dirSet
    and #$07
    tay

.dirSet
    sty enDir

    lda Rand16
    and #$1F
    adc #$D8
    sta enManhandlaTimer
    bmi .move ; jmp

.bounce
    ldy enDir
    lda EnMoveBounce,y
    sta enDir
    lda enState
    ora #EN_BOSS_MANHANDLA_END_BOUNCE
    sta enState

.move
    lda enManhandlaTimer
    cmp #1
    adc #0
    sta enManhandlaTimer

    lda enState,x
    and #~EN_BOSS_MANHANDLA_END_BOUNCE
    sta enState,x

    ldx enNum
    jsr EnMoveDir
.skipMove
    dec Temp3
    bpl .movement_loop
    rts

En_BossManhandlaUpdateHp: SUBROUTINE
    lda enHp,y
    clc
    adc HbDamage
    sta enHp,y
    bpl .rts
    lda En_BossManhandla_Masks,y
    and enState
    sta enState
.rts
    rts

En_BossManhandla_Speed:
    .byte #$80-1, #$60-1, #$40-1, #$20-1

En_BossManhandla_Masks:
    .byte #~EN_BLOCKED_DIR_L
    .byte #~EN_BLOCKED_DIR_R
    .byte #~EN_BLOCKED_DIR_U
    .byte #~EN_BLOCKED_DIR_D

En_BossManhandla_BoardL:
    .byte #EnBoardXL + 4, #EnBoardXL + 12, #EnBoardXL + 4, #EnBoardXL + 12

En_BossManhandla_BoardR:
    .byte #EnBoardXR - 4, #EnBoardXR - 4, #EnBoardXR - 12, #EnBoardXR - 12

En_BossManhandla_BoardU:
    .byte #EnBoardYU - 4, #EnBoardYU - 12, #EnBoardYU - 4, #EnBoardYU - 12

En_BossManhandla_BoardD:
    .byte #EnBoardYD + 4, #EnBoardYD + 4, #EnBoardYD + 12, #EnBoardYD + 12
