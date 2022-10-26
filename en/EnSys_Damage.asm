;==============================================================================
; mzxrules 2022
;==============================================================================

; Start by checking weapon type
EnSys_Damage: SUBROUTINE
    lda plState2
    and #PS_ACTIVE_ITEM_T
    beq .sword ; 0
    cmp #2
    bpl .highItem ; 2-3
    ; 1

; Bomb (plItemTimer -11)
.bomb
    ldx #-11
    cpx plItemTimer
    bpl .rts
    lda #-2
    rts

; Sword
.sword
    ldx #-3
    bit ITEMV_SWORD3
    bmi .sword3
    bvs .sword2
.sword1
    inx
.sword2
    inx
.sword3
    txa
    rts

.highItem
    bne .flame
; Bow
    lda #0
    rts

; Flame
.flame
    lda #0
.rts
    rts