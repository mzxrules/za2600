;==============================================================================
; mzxrules 2023
;==============================================================================
En_Test: SUBROUTINE
/*
    bit enState
    bvs .main
    lda #$40
    sta enX
    sta enY
    sta enState

.main
    lda enStun
    cmp #1
    adc #0
    sta enStun

    lda #SLOT_F0_BATTLE
    sta BANK_SLOT

    jsr HbGetPlAtt
    lda enX
    sta Hb_bb_x
    lda enY
    sta Hb_bb_y
    jsr HbPlAttCollide

    lda #HB_PL_SWORD
    and HbPlFlags
    bne .sword_hit
    lda #HB_PL_BOMB
    and HbPlFlags
    bne .bomb_hit
    lda #HB_PL_ARROW
    and HbPlFlags
    bne .arrow_hit
    beq .continue

.sword_hit
    lda #SEQ_SOLVE_DUR
    sta SeqSolveCur
    bmi .continue

.bomb_hit
    lda #SFX_ITEM_PICKUP_KEY
    sta SfxFlags
    bmi .continue

.arrow_hit
    lda #SFX_EN_DEF
    sta SfxFlags
    bmi .continue

.continue

    lda #SLOT_F0_EN_MOVE
    sta BANK_SLOT
    ldx plX
    ldy plY
    jsr EnMove_Card_WallCheck_TEST
    lda EnMoveBlockedDir
    sta itemRupees

    lda #SLOT_FC_MAIN
    sta BANK_SLOT
*/
    rts