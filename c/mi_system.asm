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
    cmp #EnBoardYU
    bpl .kill
    cmp #EnBoardYD+7
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
    lda plY
    sec
    sbc mi0Y,x
    tay
    lda plX
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

    lda enType,x
    cmp #EN_TEST_MISSILE
    bne .skipTestReset
    lda #0
    sta enTestMissileResult,x

.skipTestReset

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
    ;ldy Hb_aa_Box
    ;beq .no_hit ; null box

.valid_box
    lda Hb_aa_x
    clc
    adc hitbox2_aa_ox,y

    sec
    sbc Hb_bb_x
    cmp hitbox2_aa_w_plus_bb_w,y
    ;bcc .pass_x
    bcs .no_hit
;.no_hit
;    lda #0
;    sta HbFlags
;    rts

.pass_x
    lda Hb_aa_y
    clc
    adc hitbox2_aa_oy,y

    sec
    sbc Hb_bb_y
    cmp hitbox2_aa_h_plus_bb_h,y
    bcs .no_hit

    lda enType,x
    cmp #EN_TEST_MISSILE
    bne .skipTestSet
    lda #COLOR_EN_RED
    sta enTestMissileResult,x
.skipTestSet

.no_hit
    rts

    INCLUDE "gen/hitbox_info2.asm"