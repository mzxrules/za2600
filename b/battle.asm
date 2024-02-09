;==============================================================================
; mzxrules 2023
;==============================================================================

    INCLUDE "gen/HbPlAtt_DelLUT.asm"
    INCLUDE "gen/hitbox_info.asm"

; HbDamage tables

EnDam_Darknut:
    .byte -1, -2, -4,  0,  0, -4
EnDam_Lynel:
EnDam_Rope:
EnDam_Octorok:
EnDam_Wallmaster:
EnDam_Stalfos:
EnDam_Manhandla:
EnDam_Common:
    .byte -1, -2, -4, -1, -1, -4

HbGetPlAtt: SUBROUTINE
    lda #0
    sta HbPlFlags
    sta Hb_aa_Box
    lda m0X
    sta Hb_aa_x
    lda m0Y
    sta Hb_aa_y

    lda plItemTimer
    beq .hbFxTimeTest

    lda plItem2Time
    beq .hbStandard
    ror
    bcs .hbFx

.hbStandard
    lda plState2
    and #PS_ACTIVE_ITEM
    tay
    lda HbPlAttH,y
    pha
    lda HbPlAttL,y
    pha
    ldy plItemTimer
.rts
    rts
.hbFxTimeTest
    lda plItem2Time
    beq .rts
.hbFx
    lda plState3
    and #PS_ACTIVE_ITEM2
    tay
    lda HbPlAttH+8,y
    pha
    lda HbPlAttL+8,y
    pha
HbPlRangFx:
HbPlNone:
    rts

HbPlWand: SUBROUTINE
    lda #HB_PL_SWORD
    sta HbPlFlags
    cpy #ITEM_ANIM_WAND_STAB_SHORT
    bcs .rts ; if y >= Stab Short
    cpy #ITEM_ANIM_WAND_STAB_LONG
    bcc .rts ; if y < Stab Short
    ldy plItemDir
    iny ; HITBOX_AA_SWORD + plItemDir
    sty Hb_aa_Box
    lda #HB_DMG_SWORD2
    sta HbDamage
.rts
    rts

HbPlWandFx: SUBROUTINE
    lda #HITBOX_AA_SQ4
    sta Hb_aa_Box
    lda #HB_DMG_FIRE
    sta HbDamage
    lda plm1X
    sta Hb_aa_x
    lda plm1Y
    sta Hb_aa_y
    rts

HbPlSwordFx: SUBROUTINE
    lda #HITBOX_AA_SQ4
    sta Hb_aa_Box
    ldy #0
    lda plItem2Dir
    cmp #2
    bcc .applyMod
    iny
.applyMod
    lda Hb_aa_x,y
    sec
    sbc #1
    sta Hb_aa_x,y
    jmp SetHbSwordDamage

HbPlSword: SUBROUTINE
    lda #HB_PL_SWORD
    sta HbPlFlags
    cpy #ITEM_ANIM_SWORD_STAB_SHORT
    bcs .rts ; if y >= Stab Short
    cpy #ITEM_ANIM_SWORD_STAB_LONG
    bcc .rts ; if y < Stab Short
    ldy plItemDir
    iny ; HITBOX_AA_SWORD + plItemDir
    sty Hb_aa_Box

SetHbSwordDamage:
    ldy #HB_DMG_SWORD3
    bit ITEMV_SWORD3
    bmi .sword3
    bvs .sword2
.sword1
    dey
.sword2
    dey
.sword3
    sty HbDamage
.rts
    rts

HbPlBomb: SUBROUTINE
    cpy #ITEM_ANIM_BOMB_DETONATE
    bcc .rts
    lda #HITBOX_AA_SQ8 ; 8x8 hitbox
    sta Hb_aa_Box
    lda #HB_DMG_BOMB
    sta HbDamage
    lda #HB_PL_BOMB
    sta HbPlFlags
.rts
    rts

HbPlBow: SUBROUTINE
    ldy plItemDir
    iny ; HITBOX_AA_SWORD + plItemDir
    sty Hb_aa_Box
    lda #HB_DMG_ARROW
    sta HbDamage
    lda #HB_PL_ARROW
    sta HbPlFlags
.rts
    rts

HbPlFireFx:
    lda #HITBOX_AA_SQ4 ; 4x4 hitbox
    sta Hb_aa_Box
    lda #HB_DMG_FIRE
    sta HbDamage
    lda #HB_PL_FIRE
    sta HbPlFlags
    rts

; Sets 12x12 hitbox
HbManhandla: SUBROUTINE
    lda Hb_aa_Box
    beq .rts
    clc
    adc #HITBOX_AA_COUNT
    sta Hb_aa_Box
.rts
    rts

;==============================================================================
; HbPlAttCollide
; HbPlAttCollide_EnBB
;----------
; Calculates whether player attack has collided with EnBB
; X = enNum
;==============================================================================
HbPlAttCollide_EnBB:
    lda en0X,x
    sta Hb_bb_x
    lda en0Y,x
    sta Hb_bb_y
HbPlAttCollide: SUBROUTINE
    lda #HB_BOX_HIT
    sta HbFlags2
    ldy Hb_aa_Box
    beq .no_hit ; null box

.valid_box
    lda Hb_aa_x
    clc
    adc hitbox_aa_ox,y

    sec
    sbc Hb_bb_x
    cmp hitbox_aa_w_plus_bb_w,y
    bcc .pass_x
.no_hit
    lda #0
    sta HbFlags2 ; clear HB_BOX_HIT
    rts

.pass_x
    lda Hb_aa_y
    clc
    adc hitbox_aa_oy,y

    sec
    sbc Hb_bb_y
    cmp hitbox_aa_h_plus_bb_h,y
    bcs .no_hit
; Kill the player arrow if it hit something
    lda #HB_PL_ARROW
    and HbPlFlags
    beq .rts
    lda #$80
    sta m0Y
.rts
    rts

;==============================================================================
; HbCheckDamaged_CommonRecoil
;----------
; Performs enemy damage check and effective state changes
; X = enNum
;==============================================================================
HbCheckDamaged_CommonRecoil: SUBROUTINE
; update stun timer
    lda enStun,x
    bpl .checkDamaged
    clc
    adc #4
    bmi .skip
    lda #0
.skip
    sta enStun,x
    rts

.checkDamaged
; if collided with weapon && stun >= 0,
    jsr HbGetPlAtt
    jsr HbPlAttCollide_EnBB

; If no hit
    lda HbFlags2
    bpl .rts ; HB_BOX_HIT

    lda #enType,x
    cmp #EN_DARKNUT_MAIN
    bne .gethit

; Test if darknut takes damage
    lda HbPlFlags
    and #HB_PL_SWORD | #HB_PL_BOMB
    beq .immune ; block non-damaging attacks

; Test if item hit Darknut's shield
    ldy enDir,x
    cpy plItemDir
    ; bne .gethit
    beq .immune

/*
    ; Test if sword hit shield
    and #HB_PL_SWORD
    bne .immune
    ; Bomb hit shield
    lda #-2
    bmi .gethit_override_damage ;jmp
*/

.gethit
    ldy HbDamage
    lda EnDam_Common,y
.gethit_override_damage
    clc
    adc enHp,x
    sta enHp,x

    ldy #SFX_EN_DAMAGE
    sty SfxFlags

    lda plItemDir
    and #3
    eor #1
    clc
    adc #(-32*4)
    sta enStun,x
    lda enState,x
    ora #EN_ENEMY_MOVE_RECOIL
    sta enState,x
    rts

.immune
    lda HbPlFlags
    and #HB_PL_FIRE
    bne .rts
    lda #SFX_DEF
    sta SfxFlags
.rts
    rts