;==============================================================================
; mzxrules 2023
;==============================================================================
En_Test:
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

    lda #SLOT_BATTLE
    sta BANK_SLOT

    jsr HbGetPlAtt
    lda enX
    sta Hb_bb_x
    lda enY
    sta Hb_bb_y
    jsr HbPlAttCollide

    lda #HB_PL_SWORD
    and HbFlags
    bne .sword_hit
    lda #HB_PL_BOMB
    and HbFlags
    bne .bomb_hit
    lda #HB_PL_ARROW
    and HbFlags
    bne .arrow_hit
    beq .continue

.sword_hit
    lda #SFX_SOLVE
    sta SfxFlags
    bmi .continue

.bomb_hit
    lda #SFX_ITEM_PICKUP_KEY
    sta SfxFlags
    bmi .continue

.arrow_hit
    lda #SFX_DEF
    sta SfxFlags
    bmi .continue

.continue

    ldx plX
    ldy plY
    jsr CheckRoomCol
    cmp #0
    beq .no_room_col
    lda #COLOR_DARK_BLUE
    sta enStun
.no_room_col

    lda #SLOT_MAIN
    sta BANK_SLOT
    rts