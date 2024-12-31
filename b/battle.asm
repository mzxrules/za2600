;==============================================================================
; mzxrules 2023
;==============================================================================

    INCLUDE "gen/HbPlAtt_DelLUT.asm"
    INCLUDE "gen/hitbox_info.asm"

; HbDamage tables

EnDam_Darknut:
    ; .byte -1, -2, -4,  0,  0, -4
EnDam_Lynel:
EnDam_Rope:
EnDam_Octorok:
EnDam_Wallmaster:
EnDam_Stalfos:
EnDam_Manhandla:
EnDam_Common:
    .byte -1, -2, -4, -1, -1, -4

EnDam_Pols:
    .byte -1, -2, -4, -16, -1, -4

;==============================================================================
; HbGetPlAtt
;----------
; Configures the hitbox and vars for the current player attack
; X = enNum; x is preserved
;
; Updates the following state:
; Hb_aa_Box = Hitbox shape; 0 is NULL box
; Hb_aa_x/y = Hitbox position
; HbPlFlags = Attack Type
; HbDamage  = Attack Damage Id
; HbDir     = Attack direction
;==============================================================================
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
    lda plItemDir
    sta HbDir
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
    lda plItem2Dir
    sta HbDir
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
    lda #HB_PL_WAVE
    sta HbPlFlags
    lda #HITBOX_AA_SQ4
    sta Hb_aa_Box
    lda #HB_DMG_FIRE
    sta HbDamage
    lda plm1X
    sta Hb_aa_x
    lda plm1Y
    sta Hb_aa_y
    rts

HbPlRangFx: SUBROUTINE
    ; TODO - Implement
    rts

HbPlSwordFx: SUBROUTINE
    lda #HB_PL_SWORDFX
    sta HbPlFlags
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
    bcc .lit_bomb
    lda #HITBOX_AA_SQ8 ; 8x8 hitbox
    sta Hb_aa_Box
    lda #HB_DMG_BOMB
    sta HbDamage
    lda #HB_PL_BOMB
    sta HbPlFlags
    rts
.lit_bomb
    lda enType,x
    cmp #EN_BOSS_DON
    bne .rts
    lda #HITBOX_AA_SQ4 ; 4x4 hitbox
    sta Hb_aa_Box
    lda #HB_DMG_BOMB_LIT
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

; Sets 12x12 enemy hitbox
HbManhandla: SUBROUTINE
    lda Hb_aa_Box
    beq .rts
    clc
    adc #HITBOX_BB_MANHANDLA
    sta Hb_aa_Box
.rts
    rts

; Sets 4x4 enemy hitbox
HbEnSq4: SUBROUTINE
    lda Hb_aa_Box
    beq .rts
    clc
    adc #HITBOX_BB_4x4
    sta Hb_aa_Box
.rts
    rts

;==============================================================================
; HbPlAttCollide (Callee manually sets hb_bb_x, hb_bb_y)
; HbPlAttCollide_EnBB (hb_bb_x, hb_bb_y is assigned to en0X, en0Y)
;----------
; Tests if the player attack has collided with EnBB
; - Kills player arrow/swordfx attacks when collided
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
    beq .test_kill_swordfx
    lda #$80
    sta plm0Y
.rts
    rts
.test_kill_swordfx
    lda #HB_PL_SWORDFX
    and HbPlFlags
    beq .rts
    lda #$80
    sta plm1Y
    rts

;==============================================================================
; HbPlAttCollide (Callee manually sets hb_bb_x, hb_bb_y)
; HbPlAttCollide_EnBB (hb_bb_x, hb_bb_y is assigned to en0X, en0Y)
;----------
; Tests if the player attack has collided with EnBB
; - Preserves player arrow/swordfx attacks when collided
; X = enNum
;==============================================================================
HbPlAttCollide_Invisible: SUBROUTINE
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
    rts

;==============================================================================
; HbCheckDamaged_CommonRecoil
;----------
; Performs these common enemy combat operations:
; - Updates enStun
; - Fetches active player attack hitbox
; - Compares it to an 8x8 hitbox at en0X,en0Y
; - Computes battle damage and applies stun/recoil
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
    bpl .rts ; not HB_BOX_HIT

; Handle Darknuts specially
    lda #enType,x
    cmp #EN_POLS
    bne .check_darknut
    ldy HbDamage
    lda EnDam_Pols,y
    jmp .gethit_damage_a

.check_darknut
    cmp #EN_DARKNUT_MAIN
    bne .gethit

; Test if player attack is capable of damaging the Darknut
    lda HbPlFlags
    and #HB_PL_SWORD | #HB_PL_BOMB | #HB_PL_SWORDFX
    beq .immune ; block non-damaging attacks

; Test if player attack hit is blocked by Darknut's shield
    lda enDir,x
    eor #1
    cmp HbDir
    ; bne .gethit
    beq .immune

.gethit
    ldy HbDamage
    lda EnDam_Common,y
.gethit_damage_a
    ldy #SFX_EN_DAMAGE
    clc
    adc enHp,x
    sta enHp,x
    bpl .set_hitsfx
    ldy #SFX_EN_KILL
.set_hitsfx
    sty SfxFlags

    lda HbDir
    and #3
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
    lda #SFX_EN_DEF
    sta SfxFlags
.rts
    rts