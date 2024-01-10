;==============================================================================
; mzxrules 2022
;==============================================================================
MI_SPAWN_CARD = $1
MI_SPAWN_ATAN = $2
MI_RUN_CARD = $1^$80
MI_RUN_ATAN = $2^$80
;==============================================================================
; MiSysUpdateCardPos
;----------
; Updates Missile Position via Cardinal Dir
; X = Missile Index
;==============================================================================
MiSysUpdateCardPos: SUBROUTINE
    lda mi0Dir,x
    sta MiSysDir
    and #2
    bne .updateY
.updateX
    lda MiSysDir
    and #1
    beq .left
.right
    inc mi0X,x
    inc mi0X,x
    rts
.left
    dec mi0X,x
    dec mi0X,x
    rts
.updateY
    lda MiSysDir
    and #1
    beq .up
.down
    dec mi0Y,x
    dec mi0Y,x
    rts
.up
    inc mi0Y,x
    inc mi0Y,x
    rts

;==============================================================================
; MiSysUpdateAtanPos
;----------
; Updates Missile Position via Atan2 Dir
; X = Missile Index
;==============================================================================
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

MiSystem: SUBROUTINE
    ldx #1
.loop
    lda miType,x
    beq .continue

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
    lda #0
    sta miType,x
.continue
    dex
    bpl .loop
    rts

MiProcess: SUBROUTINE
.cont1
    cmp #MI_SPAWN_CARD
    bne .cont2
    jmp MiSpawnRock

.cont2
    cmp #MI_SPAWN_ATAN
    bne .cont3
    jmp MiSpawnAtan

.cont3
    cmp #MI_RUN_ATAN
    bne .cont4
    jmp MiSysUpdateAtanPos
.cont4
    cmp #MI_RUN_CARD
    bne .no_update
.cardPos
    jmp MiSysUpdateCardPos
.no_update
    rts


MiSpawnAtan: SUBROUTINE
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
    lda #MI_RUN_ATAN
    sta miType,x
    lda #$80
    sta mi0Xf,x
    sta mi0Yf,x
    rts

; X is missile slot
MiSpawnRock: SUBROUTINE
    lda #MI_RUN_CARD
    sta miType,x
    rts

; X is missile slot
MiPlCol: SUBROUTINE

; Shield HB test
    lda plDir
    and #3
    tay
    lda plX
    sta Hb_aa_x
    lda plY
    sta Hb_aa_y
    lda mi0X,x
    sta Hb_bb_x
    lda mi0Y,x
    sta Hb_bb_y

HbEnAttCollide:
.valid_box
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

    lda enType,x
    cmp #EN_TEST_MISSILE
    bne .skipTestMissileGreen
    lda #COLOR_EN_GREEN
    sta enTestMissileResult,x
.skipTestMissileGreen

    lda #0
    sta miType,x
    lda #SFX_DEF
    sta SfxFlags
    rts

.no_shield_hit
    lda Hb_aa_x
    clc
    adc hitbox2_aa_ox+4

    sec
    sbc Hb_bb_x
    cmp hitbox2_aa_w_plus_bb_w+4
    bcs .no_player_hit

.pass_player_x
    lda Hb_aa_y
    clc
    adc hitbox2_aa_oy+4

    sec
    sbc Hb_bb_y
    cmp hitbox2_aa_h_plus_bb_h+4
    bcc .player_hit
.no_player_hit
    rts

.player_hit
    lda enType,x
    cmp #EN_TEST_MISSILE
    bne .skipTestMissileRed
    lda #COLOR_EN_RED
    sta enTestMissileResult,x
.skipTestMissileRed

    lda #0
    sta miType,x
    lda #-4
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
    rts

    INCLUDE "gen/hitbox_info2.asm"