;==============================================================================
; mzxrules 2023
;==============================================================================

    INCLUDE "gen/HbPlAtt.asm"
    INCLUDE "gen/hitbox_info.asm"

EnDam_Darknut:
    .byte -1, -2, -3,  0,  0, -4
EnDam_Rope:
    .byte -1, -2, -3, -1, -1, -2

HbGetPlAtt: SUBROUTINE
    lda #0
    sta HbFlags
    sta Hb_aa_Box
    lda m0X
    sta Hb_aa_x
    lda m0Y
    sta Hb_aa_y

    ldy plItemTimer
    beq .rts
    lda plState2
    and #PS_ACTIVE_ITEM
    tax
    lda HbPlAttH,x
    pha
    lda HbPlAttL,x
    pha
.rts
    rts

HbPlWand: SUBROUTINE
HbPlSword: SUBROUTINE
    lda #HB_PL_SWORD
    sta HbFlags
    cpy #ITEM_ANIM_SWORD_STAB_SHORT
    bcs .rts ; if y >= Stab Short
    cpy #ITEM_ANIM_SWORD_STAB_LONG
    bcc .rts ; if y < Stab Short
    ldx plItemDir
    inx
    stx Hb_aa_Box

    ldx #HB_DMG_SWORD3
    bit ITEMV_SWORD3
    bmi .sword3
    bvs .sword2
.sword1
    dex
.sword2
    dex
.sword3
    stx HbDamage
.rts
    rts

HbPlBomb: SUBROUTINE
    cpy #ITEM_ANIM_BOMB_DETONATE
    bcc .rts
    lda #10 ; 8x8 hitbox
    sta Hb_aa_Box
    lda #HB_DMG_BOMB
    sta HbDamage
    lda #HB_PL_BOMB
    sta HbFlags
.rts
    rts

HbPlBow: SUBROUTINE
    lda m0Y
    ldx plItemDir
    inx
    stx Hb_aa_Box
    lda #HB_DMG_ARROW
    sta HbDamage
    lda #HB_PL_ARROW
    sta HbFlags
.rts
    rts

HbPlCandle: SUBROUTINE
    lda #9 ; 4x4 hitbox
    sta Hb_aa_Box
    lda #HB_DMG_FIRE
    sta HbDamage
    lda #HB_PL_FIRE
    sta HbFlags
    rts

HbPlFlute: SUBROUTINE
HbPlMeat: SUBROUTINE
HbPlPotion: SUBROUTINE
    rts


HbPlAttCollide_EnBB:
    lda enX
    sta Hb_bb_x
    lda enY
    sta Hb_bb_y
HbPlAttCollide: SUBROUTINE
    ldx Hb_aa_Box
    beq .no_hit ; null box

.valid_box
    lda Hb_aa_x
    clc
    adc hitbox_aa_ox,x

    sec
    sbc Hb_bb_x
    cmp hitbox_aa_w_plus_bb_w,x
    bcc .pass_x
.no_hit
    lda #0
    sta HbFlags
    rts

.pass_x
    lda Hb_aa_y
    clc
    adc hitbox_aa_oy,x

    sec
    sbc Hb_bb_y
    cmp hitbox_aa_h_plus_bb_h,x
    bcs .no_hit
    lda #HB_PL_ARROW
    and HbFlags
    beq .rts
    lda #$80
    sta m0Y
.rts
    rts