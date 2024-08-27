;==============================================================================
; mzxrules 2023
;==============================================================================
DISPLACE = 16
EN_KEESE_END_BOUNCE = $01
EN_KEESE_INIT = $80

En_VireKeese: SUBROUTINE
    lda enKeeseThink,x
    cmp #1
    adc #0
    sta enKeeseThink,x
    bne .rts
    sta enStun,x
    lda #EN_KEESE
    sta enType,x
    lda #3
    sta enHp,x
    lda en0X,x
    sec
    sbc #8
    bpl .set_x
    lda #0
.set_x
    sta en0X,x

    jsr Random
    and #7
    sta enDir,x

    lda #EN_KEESE_INIT
    sta enState,x
.rts
    rts


En_Keese: SUBROUTINE
    lda enState,x
    rol
    bcs .main
    lda #EN_KEESE_INIT
    sta enState,x
    lda #7
    sta enHp,x

    jsr Random
    and #7
    sta enDir,x
    rts

.main

.checkDamaged
    lda #SLOT_F0_BATTLE
    sta BANK_SLOT

    lda enHp,x
    ror
    sta enKeeseHpTemp
    lda #%111
    sta enKeeseTemp
    jsr HbGetPlAtt

.test_001
    jsr HbPlAttCollide_EnBB
    lda HbFlags2
    bpl .test_010 ; not HB_BOX_HIT
    lda #%110
    sta enKeeseTemp
.test_010
    lda Hb_bb_x
    adc #DISPLACE
    sta Hb_bb_x
    ror enKeeseHpTemp
    bcc .test_100
    jsr HbPlAttCollide
    lda HbFlags2
    bpl .test_100 ; not HB_BOX_HIT
    lda #%101
    and enKeeseTemp
    sta enKeeseTemp
.test_100
    lda Hb_bb_x
    adc #DISPLACE
    sta Hb_bb_x
    ror enKeeseHpTemp
    bcc .end_checkhit
    jsr HbPlAttCollide
    lda HbFlags2
    bpl .end_checkhit ; not HB_BOX_HIT
    lda #%011
    and enKeeseTemp
    sta enKeeseTemp

.end_checkhit
; restore common enemy bank
    lda #SLOT_F0_EN
    sta BANK_SLOT

.update_health
    lda enHp,x
    and enKeeseTemp
    cmp enHp,x
    beq .endCheckDamaged
    ldy #SFX_EN_DAMAGE
    sty SfxFlags
    tay ; 3 bits
    clc
    ror
    bcs .setHp
    tay ; 2 bits
    lda #DISPLACE
    adc en0X,x
    sta en0X,x
    tya
    ror
    bcs .setHp
    tay
    lda #DISPLACE
    adc en0X,x
    sta en0X,x
.setHp
    sty enHp,x
    lda enHp,x
    bne .endCheckDamaged
    jmp EnSysEnDie
.endCheckDamaged

; Check player hit
    bit plState2
    bvc .endCheckHit ; EN_LAST_DRAWN
    bit CXPPMM
    bpl .endCheckHit
    lda #-4
    jsr UPDATE_PL_HEALTH
.endCheckHit

; Movement

.bounceTest
    lda #SLOT_F0_EN_MOVE2
    sta BANK_SLOT

    ldy enHp,x
    lda En_Keese_BounceXR-1,y
    jsr EnMove_Ord_WallCheck_BoardXR
    sty enDir,x

.think
    lda enKeeseThink,x
    cmp #1
    adc #0
    sta enKeeseThink,x
    bne .endThink

    jsr Random
    and #7
    sta enDir,x
    lda Rand16
    and #$1F
    adc #$D8
    sta enKeeseThink,x
    bmi .endThink ; jmp


.bounce
    jsr EnMove_Ord_SetSeekCenter
.endThink

.move_logic
    lda Frame
    ror
    bcc .move
    rts

.move

    lda enDir,x
    and #7
    tay
    jmp EnMoveDel

En_Keese_BounceXR
; skip 0 value
; 001
    .byte #EnBoardXR
; 010
    .byte #EnBoardXR-16
    .byte #EnBoardXR-16
; 100
    .byte #EnBoardXR-32
    .byte #EnBoardXR-32
    .byte #EnBoardXR-32
    .byte #EnBoardXR-32
