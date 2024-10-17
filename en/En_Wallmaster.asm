;==============================================================================
; mzxrules 2021
;==============================================================================

EN_WALLMASTER_CAPTURE = $80
EN_WALLMASTER_INIT = $01
EN_WALLMASTER_ENTER = $02

En_WallmasterSp: SUBROUTINE
    lda #3
    sta enWallCount,x
    lda #EN_WALLMASTER
    sta enType,x

En_WallmasterReset: SUBROUTINE
    lda #1
    sta enHp,x

    lda #0
    sta enState,x
    sta enStun,x

    lda #$80
    sta en0Y,x
    rts

En_WallmasterInit: SUBROUTINE
; test if the wallmaster should appear
    ldy #0
    lda plY
    cmp #EnBoardYU
    beq .setPosY
    iny
    cmp #EnBoardYD
    beq .setPosY

    lda plX
    cmp #EnBoardXL
    beq .setPosX
    cmp #EnBoardXR
    bne .rts

.setPosX
    sta en0X,x
    lda #32
    sta enWallPhase,x
    ldy #0
    lda plY
    cmp #BoardYC
    bcc .setPosX_Y
    iny
.setPosX_Y
    clc
    lda plY
    adc #2
    and #~#3
    adc .x_off,y
    sta en0Y,x
    bpl .init_final ;jmp
    rts

.setPosY
    sta en0Y,x
    lda .wallphase_start,y
    sta enWallPhase,x

    ldy #0
    lda plX
    cmp #BoardXC
    bcc .setPosY_x
    iny
.setPosY_x
    clc
    lda plX
    adc #2
    and #~#3
    adc .x_off,y
    sta en0X,x
.init_final
    lda #EN_WALLMASTER_INIT | #EN_WALLMASTER_ENTER
    sta enState,x
    lda #-30
    sta enWallTimer,x
.rts
    rts

.wallphase_start
    .byte #0, #32

.x_off
    .byte #28, #-28

En_WallmasterCapture:
    inc enWallPhase,x
    lda enWallPhase,x
    cmp #33
    bne .rts
    jmp SPAWN_AT_DEFAULT

En_Wallmaster: SUBROUTINE
    lda enState,x
    bmi En_WallmasterCapture ; EN_WALLMASTER_CAPTURE
    ror
    bcc En_WallmasterInit
    ror
    bcc .main

.phase_through_wall
    lda enWallPhase,x
    cmp #16
    beq .set_main
    bmi .incWallPhase
    dec enWallPhase,x
    rts
.incWallPhase
    inc enWallPhase,x
    rts

.set_main
    lda #EN_WALLMASTER_INIT
    sta enState,x

.main
    jsr En_WallmasterUpdateTimer
    bne .skip_sink_through_floor

.sink_through_floor
    inc enWallPhase,x
    lda enWallPhase,x
    cmp #32
    bne .rts1
    lda #$0
    sta enState,x
.rts1
    rts
.skip_sink_through_floor

; check damaged
    lda #SLOT_F0_BATTLE
    sta BANK_SLOT
    jsr HbCheckDamaged_CommonRecoil

    lda #SLOT_F0_EN
    sta BANK_SLOT
    lda enHp,x
    bpl .endCheckDamaged
    dec enWallCount,x
    beq .kill
    jmp En_WallmasterReset
.kill
    jmp EnSys_KillEnemyB
.endCheckDamaged

.checkPlayerHit
    bit plState2
    bvc .endCheckHit ; EN_LAST_DRAWN
    bit CXPPMM
    bpl .endCheckHit
    lda #-4
    jsr UPDATE_PL_HEALTH
    lda plState
    ora #PS_LOCK_ALL
    sta plState
    lda plX
    sta en0X,x
    lda plY
    sta en0Y,x
    lda #EN_WALLMASTER_CAPTURE
    ora enState,x
    sta enState,x
    lda #$80
    sta plY
    rts
.endCheckHit

.handleMovement
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
    jsr EnMove_Card_WallCheck
    jsr EnMove_Card_SeekDir
    sty enDir,x
.move
    lda Frame
    ror
    bcc .rts
    jsr EnMoveDir
.rts
    rts

En_WallmasterUpdateTimer: SUBROUTINE
    lda Frame
    and #$7
    cmp #1
    lda enWallTimer,x
    beq .rts
    bcs .skip_timer_lengthen
    adc #-$7
    sta enWallTimer,x
.skip_timer_lengthen
    inc enWallTimer,x
.rts
    rts


    LOG_SIZE "En_Wallmaster", En_WallmasterSp
