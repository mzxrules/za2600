;==============================================================================
; mzxrules 2023
;==============================================================================
EN_GREAT_FAIRY_DIE = -60
En_GreatFairy: SUBROUTINE
    bit enState
    bmi .run
    lda #$80
    sta enState
    lda #EN_GREAT_FAIRY_DIE
    sta enGFairyDie

.run
; Movement Animation
    lda Frame
    and #$38
    lsr
    lsr
    lsr
    tax
    lsr
    and #1
    tay
    lda En_GreatFairyAnimX,x
    sta enX
    lda En_GreatFairyAnimY,y
    sta enY

; Heal check

    bit enState
    bvs .heal_event_triggered

    ldy plY
    cpy #$1C
    bne .rts

    lda enState
    ora #$40
    sta enState

    lda plState
    ora #PS_LOCK_ALL
    sta plState

    ldx #SFX_PL_HEAL
    bne .rts_is_healing ;jmp

.heal_event_triggered

; test healing
    ldy plHealthMax
    cpy plHealth
    bne .continue_healing
.finish_healing
    lda plState
    and #~PS_LOCK_ALL
    sta plState

; update death timer
    lda enGFairyDie
    cmp #1
    adc #0
    sta enGFairyDie
.rts
    rts
.continue_healing
    ldx #0
    lda Frame
    ror
    bcs .rts ;.rts_is_healing
    inc plHealth
    ldx #SFX_PL_HEAL
.rts_is_healing
    stx SfxFlags
    rts

GFAIRY_X = $40
GFAIRY_Y = $34

En_GreatFairyAnimX:
    .byte GFAIRY_X + 0
    .byte GFAIRY_X + 1
    .byte GFAIRY_X + 2
    .byte GFAIRY_X + 1
    .byte GFAIRY_X + 0
    .byte GFAIRY_X + -1
    .byte GFAIRY_X + -2
    .byte GFAIRY_X + -1

En_GreatFairyAnimY:
    .byte GFAIRY_Y + 0
    .byte GFAIRY_Y + 1