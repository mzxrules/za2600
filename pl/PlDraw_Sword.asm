;==============================================================================
; mzxrules 2024
;==============================================================================

PlDraw_Sword: SUBROUTINE
    lda #0
    sta Temp0
    bpl .draw_continue

PlDraw_Wand:
    lda #8
    sta Temp0
    bpl .draw_continue

.draw_continue
    lda plDir
    sta plItemDir
    ora Temp0
    cpy #ITEM_ANIM_SWORD_STAB_LONG
    bmi .endSword
    cpy #ITEM_ANIM_SWORD_STAB_SHORT
    beq .drawSword4
    clc
    ora #4 ; Draw Sword 8
.drawSword4
    tay
    lda WeaponWidth,y
    sta wNUSIZ0_T
    lda WeaponHeight,y
    sta wM0H

; the next tables are only 8 bytes each
    tya
    and #7
    tay

    lda WeaponOffX,y
    clc
    adc plX
.x_underflow_fix
    cmp #$C0
    bcc .skip_fix
    lda #$20
    sta wNUSIZ0_T
    lda #-2 -1
    adc plX
.skip_fix
    sta m0X
    lda WeaponOffY,y
    clc
    adc plY
    sta m0Y
.endSword
.rts
    rts
