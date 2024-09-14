;==============================================================================
; mzxrules 2022
;==============================================================================

;==============================================================================
; MiSystem
;----------
; Updates enemy missiles
;==============================================================================
MiSystem: SUBROUTINE
    ldx #1 ; Loop for 2
.loop
    lda miType,x
    beq .continue ; #MI_NONE
    jsr MiProcess
    jsr MiPlCol

    lda mi0X,x
    cmp #EnBoardXL
    bmi .kill
    cmp #EnBoardXR+7
    bpl .kill

    lda mi0Y,x
    cmp #EnBoardYU+7
    bpl .kill
    cmp #EnBoardYD
    bpl .continue
.kill
    lda #MI_NONE
    sta miType,x
.continue
    dex
    bpl .loop
    rts

;==============================================================================
; MiProcess
;----------
; Processes an enemy missile
; A = miType
;==============================================================================
MiProcess: SUBROUTINE
    and #$0F
    tay
    lda #0
    sta HbDir
    lda MiTypeH,y
    pha
    lda MiTypeL,y
    pha
.rts
    rts


MiMoveDeltaX:
    .byte -2,  2,  0,  0 ; cardinals 2x

MiMoveDeltaY:
    .byte  0,  0,  2, -2 ; cardinals 2x

hitbox2_bb_type:
    .byte #HITBOX2_BB_MISSILE
hitbox2_bb_arrow:
    .byte #HITBOX2_BB_ARROW_L, #HITBOX2_BB_ARROW_R, #HITBOX2_BB_ARROW_U, #HITBOX2_BB_ARROW_D
    .byte #HITBOX2_BB_SQ4

MiRunRock:
    ldy mi0Dir,x
    lda #HITBOX2_BB_MISSILE
    sta HbDir
    bpl MiMoveCardDel ; jmp

MiRunArrow:
    ldy mi0Dir,x
    lda hitbox2_bb_arrow,y
    sta HbDir
    bpl MiMoveCardDel ; jmp

MiRunSword:
MiRunWave:
    ldy mi0Dir,x
    lda #HITBOX2_BB_SQ4
    sta HbDir
    bpl MiMoveCardDel ; jmp

;==============================================================================
; MiMoveCardDel
;----------
; Updates Missile Position via Cardinal Dir
; X = Missile Index
; Y = Missile Direction (cardinal)
;==============================================================================
MiMoveCardDel: SUBROUTINE
    lda mi0X,x      ; 4
    clc             ; 2
    adc MiMoveDeltaX,y   ; 4
    sta mi0X,x      ; 4 (14)

    lda mi0Y,x      ; 4
    clc             ; 2
    adc MiMoveDeltaY,y   ; 4
    sta mi0Y,x      ; 4 (28)

    rts             ; 6 (34)

;==============================================================================
; MiSysUpdateAtanPos
;----------
; Updates Missile Position via Atan2 Dir
; X = Missile Index
;==============================================================================
MiRunBall:
MiSysUpdateAtanPos: SUBROUTINE
    lda mi0Dir,x
    sta MiSysDir
    and #$3F
    tay
    lda Atan2X,y
    sta MiSysDX
    lda Atan2Y,y
    sta MiSysDY

    ldy #1
; Update X
.addDouble
    lda mi0Xf,x
    bit MiSysDir
    bmi .subX
    clc
    adc MiSysDX
    sta mi0Xf,x
    lda mi0X,x
    adc #0
    sta mi0X,x
    jmp .addY
.subX
    sec
    sbc MiSysDX
    sta mi0Xf,x
    lda mi0X,x
    sbc #0
    sta mi0X,x

; Update Y
.addY
    lda mi0Yf,x
    bit MiSysDir
    bvs .subY
    clc
    adc MiSysDY
    sta mi0Yf,x
    lda mi0Y,x
    adc #0
    sta mi0Y,x
    jmp .checkAddY
.subY
    sec
    sbc MiSysDY
    sta mi0Yf,x
    lda mi0Y,x
    sbc #0
    sta mi0Y,x
.checkAddY
    dey
    bpl .addDouble
    rts

MiNone:
MiHit:
MiSpawnRang:
MiRunRang:
    lda #MI_NONE
    sta miType,x
    rts


MiSpawnAtan: SUBROUTINE
MiSpawnBall:
    stx MiSysEnNum

    jsr Random
    and #$07
    bne .skip_middle_y
    lda #4
.skip_middle_y

    clc
    adc plY
    adc #$FC
    sec
    sbc mi0Y,x
    tay

    jsr Random
    and #$07
    bne .skip_middle_x
    lda #4
.skip_middle_x

    clc
    adc plX
    adc #$FC
    sec
    sbc mi0X,x
    tax

    jsr Atan2
    ldx MiSysEnNum
    sta mi0Dir,x
    inc miType,x ; #MI_RUN_BALL
    lda #$80
    sta mi0Xf,x
    sta mi0Yf,x
    rts

; X is missile slot
MiSpawnSword:
MiSpawnArrow:
MiSpawnWave:
MiSpawnRock: SUBROUTINE
    inc miType,x ; #MI_RUN_ROCK
    rts

; X is missile slot
MiPlCol: SUBROUTINE
    lda plX
    sta Hb_aa_x
    lda plY
    sta Hb_aa_y
    lda mi0X,x
    sta Hb_bb_x
    lda mi0Y,x
    sta Hb_bb_y

    lda miType,x
    and #$8
    beq .test_shield_hit

    lda ITEMV_SHIELD
    and #ITEMF_SHIELD
    beq .no_shield_hit

.test_shield_hit
; Player can't shield if attacking
    lda plState
    and #PS_LOCK_MOVE_IT
    bne .no_shield_hit

    lda plDir
    and #3
    clc
    adc HbDir
    tay
    iny

    lda Hb_aa_x
    clc
    adc hitbox2_aa_ox,y

    sec
    sbc Hb_bb_x
    cmp hitbox2_aa_w_plus_bb_w,y
    bcs .no_shield_hit

.pass_x
    lda Hb_aa_y
    clc
    adc hitbox2_aa_oy,y

    sec
    sbc Hb_bb_y
    cmp hitbox2_aa_h_plus_bb_h,y
    bcs .no_shield_hit

/*
    lda enType,x
    cmp #EN_TEST_MISSILE
    bne .skipTestMissileGreen
    lda #COLOR_EN_GREEN
    sta enTestMissileResult,x
.skipTestMissileGreen
*/

    lda #MI_NONE
    sta miType,x
    lda #SFX_DEF
    sta SfxFlags
    rts

.no_shield_hit
    ldy HbDir
    lda Hb_aa_x
    clc
    adc hitbox2_aa_ox,y

    sec
    sbc Hb_bb_x
    cmp hitbox2_aa_w_plus_bb_w,y
    bcs .no_player_hit

.pass_player_x
    lda Hb_aa_y
    clc
    adc hitbox2_aa_oy,y

    sec
    sbc Hb_bb_y
    cmp hitbox2_aa_h_plus_bb_h,y
    bcc .player_hit
.no_player_hit
    rts

.player_hit

; MISSILE_HIT!

; Test if recoil should be computed
    bit plStun
    bmi .player_hit_final ; avoid recoil check

    lda miType,x
    bpl .player_hit_final ; prevent dealing bonkers damage
    lsr
    lsr
    ora #$C0
    and #$FC
    jsr UPDATE_PL_HEALTH

; compute player recoil position (we are already recoiling opposite plDir)
    sec
    lda plX
    sbc mi0X,x
    bpl .storeDX
    sbc #0
    eor #$ff
    clc
.storeDX
    sta MiSysColDX
    lda #$80
    rol ; set A to zero, sec
    sta MiSysColFlag
    lda plY
    sbc mi0Y,x
    bpl .storeDY
    sbc #0
    eor #$ff
    clc
.storeDY
    sta MiSysColDY
    lda MiSysColFlag
    rol
    sta MiSysColFlag ; Current state:
    ; xxxx_xx1x DX is positive (player to right)
    ; xxxx_xxx1 DY is positive (player to up)

    ; if plX is offgrid
    lda plX
    and #1
    bne .recoil_y
    ; if plY is offgrid
    lda plY
    and #1
    bne .recoil_x

.recoil_shortest_dist
    lda MiSysColDX
    cmp MiSysColDY
    bne .recoil_pick_axis

    lda Frame
    and #1
    beq .recoil_y

.recoil_pick_axis
    bcc .recoil_y

.recoil_x
    ; load deltaX, test sign
    lda MiSysColFlag
    and #2
    bne .player_recoil_right
.player_recoil_left
    lda #PL_DIR_R | #PL_STUN_TIME
    sta plStun
    rts
.player_recoil_right
    lda #PL_DIR_L | #PL_STUN_TIME
    sta plStun
    rts

.recoil_y
    ; load deltaY, test sign
    lda MiSysColFlag
    and #1
    bne .player_recoil_up
.player_recoil_down
    lda #PL_DIR_U | #PL_STUN_TIME
    sta plStun
    rts
.player_recoil_up
    lda #PL_DIR_D | #PL_STUN_TIME
    sta plStun

.player_hit_final
    lda #0
    sta miType,x
    rts