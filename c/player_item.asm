;==============================================================================
; mzxrules 2024
;==============================================================================

FireOffX:
BombOffX:
MagicOffX:
    .byte 10, -4, 3, 3
FireOffY:
BombOffY:
MagicOffY:
    .byte 2, 2, -5, 9

    .byte -2,  4, -8, 8, -8, 4,  4, -8, 8, -8, 4
BombAnimDeltaX:
    .byte -2, -4,  8, 0, -8, 4, -4,  8, 0, -8, 4
BombAnimDeltaY:

PlayerUseArrow: SUBROUTINE
    lda itemRupees
    bne .useArrow
    jmp PlayerEquipSword

.useArrow
    sed
    sec
    sbc #1
    cld
    sta itemRupees
    lda #-32
    sta plItemTimer
    ldy plDir
    sty plItemDir

    lda #SFX_ARROW
    sta SfxFlags
    lda ArrowOff8X,y
    clc
    adc plX
    sta plm0X
    lda ArrowOff8Y,y
    clc
    adc plY
    sta plm0Y
.rts
    rts

PlayerUpdateArrow: SUBROUTINE
    ldy plItemDir
    ldx ObjXYAddr,y
    lda OBJ_PLM0,x
    clc
    adc PlayerXYDist2,y
    sta OBJ_PLM0,x

    cmp PlayerXYBoardLimitL,y
    bmi .offScreen
    cmp PlayerXYBoardLimitH,y
    bpl .offScreen
    rts

.offScreen
    lda #$80
    sta plm0Y
    sta plm0X
    rts

PlayerDrawArrow: SUBROUTINE
; Draw Arrow
    ldy plItemDir
    lda ArrowWidth8,y
    sta wNUSIZ0_T
    lda ArrowHeight8,y
    sta wM0H
    lda plm0X
    sta m0X
    lda plm0Y
    sta m0Y
    rts

PlayerUseCandle: SUBROUTINE
    ; TODO: implement fire check

    lda plItem2Time
    beq .continue
    jmp PlayerUseSword
.continue
; Spawn
    lda #-64
    sta plItem2Time

    lda #PLAYER_FIRE_FX
    sta plState3

    ldx #OBJ_PLM1
    jsr PlayerPlaceNearbyTypeB
    sty plItem2Dir
    rts

PlayerDrawFireFx: SUBROUTINE
    lda #$20
    sta wNUSIZ0_T
    lda plItem2Time
    and #3
    sta wM0H
    lda plm1X
    sta m0X
    lda plm1Y
    sta m0Y
    rts


PlayerUseBomb: SUBROUTINE
    lda itemBombs
    bne .useBomb
    jmp PlayerEquipSword
.useBomb
    sed
    sec
    sbc #1
    cld
    sta itemBombs
    lda #-32
    sta plItemTimer

    ldx #OBJ_PLM0
    jsr PlayerPlaceNearbyTypeB
    sty plItemDir
    rts

PlayerDrawBomb: SUBROUTINE
    cpy #ITEM_ANIM_BOMB_DETONATE
    bmi .draw_initial

.drawBombAnimation
    bne .skipDetonateEffect
    lda #SFX_BOMB
    sta SfxFlags

.skipDetonateEffect
    lda #7
    sta wM0H
    lda #$30
    sta wNUSIZ0_T

    clc
    lda BombAnimDeltaX-$100,y
    adc plm0X
    sta m0X
    clc
    lda BombAnimDeltaY-$100,y
    adc plm0Y
    sta m0Y
    rts
.draw_initial

; Initial Animation state
    lda #$20
    sta wNUSIZ0_T
    lda #3
    sta wM0H
    lda plm0X
    sta m0X
    lda plm0Y
    sta m0Y
    rts


    ;align 4
SwordWidth4:
    .byte $20, $20, $10, $10
SwordWidth8:
    .byte $30, $30, $10, $10
SwordHeight4:
    .byte 1, 1, 3, 3
SwordHeight8:
    .byte 1, 1, 7, 7
ArrowOff4X:
SwordOff4X:
WandOff4X:
    .byte 8, -2, 4, 4
ArrowOff8X:
SwordOff8X:
WandOff8X:
    .byte 8, -6, 4, 4
ArrowOff4Y:
SwordOff4Y:
WandOff4Y:
    .byte 3, 3, -3, 7
ArrowOff8Y:
SwordOff8Y:
WandOff8Y:
    .byte 3, 3, -7, 7


ArrowWidth4:
WandWidth4:
    .byte $20, $20, $00, $00
ArrowWidth8:
WandWidth8:
    .byte $30, $30, $00, $00
ArrowHeight4:
WandHeight4:
    .byte 0, 0, 3, 3
ArrowHeight8:
WandHeight8:
    .byte 0, 0, 7, 7


PlayerEquipSword: SUBROUTINE
    lda plState2
    and #~PS_ACTIVE_ITEM
    sta plState2
PlayerUseSword: SUBROUTINE
    lda ITEMV_SWORD1
    and #[ITEMF_SWORD1 | ITEMF_SWORD2 | ITEMF_SWORD3]
    beq .rts

    lda #<-9
    sta plItemTimer
; Sfx
    lda #SFX_STAB
    sta SfxFlags
.rts
    rts

PlayerUseMeat: SUBROUTINE
    lda plItem2Time
    beq .continue
    jmp PlayerUseSword
.continue
; Spawn
    lda #-64
    sta plItem2Time

    lda #PLAYER_MEAT_FX
    sta plState3

    ldx #OBJ_PLM1
    jsr PlayerPlaceNearbyTypeB
    sty plItem2Dir
    rts

PlayerUseRang:
    rts

PlayerDrawSword: SUBROUTINE
    lda plDir
    sta plItemDir
    cpy #ITEM_ANIM_SWORD_STAB_LONG
    bmi .endSword
    cpy #ITEM_ANIM_SWORD_STAB_SHORT
    beq .drawSword4
    clc
    adc #4 ; Draw Sword 8
.drawSword4
    tay
    lda SwordWidth4,y
    sta wNUSIZ0_T
    lda SwordHeight4,y
    sta wM0H
    lda SwordOff4X,y
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
    lda SwordOff4Y,y
    clc
    adc plY
    sta m0Y
.endSword
.rts
    rts


; Flute State
; plItemDir bvs resumes tornado after room transition
; plItemDir bmi causes the player to appear

PlayerUseFlute: SUBROUTINE
    ; roll back stack
    pla
    pla
    lda #SFX_WARP
    sta SfxFlags
    lda #SLOT_FC_HALT
    sta BANK_SLOT
    jmp HALT_FLUTE_ENTRY

PlayerUpdateFluteFx: SUBROUTINE
    lda plItem2Time
    cmp #-1
    beq .lastFrame
    and #3
    bne .skipTimerInc
    inc plItem2Time
.skipTimerInc
    inc plm1X
    inc plm1X

; Check player collision
; Have fun analyzing this one
    ; x
    lda plm1X
    sbc plX
    adc #7
    bmi .rts
    cmp #12
    bpl .rts
    ; y
    lda plm1Y
    sbc plY
    adc #4
    bmi .rts
    cmp #8
    bpl .rts

; Collided with Tornado
    lda plState
    ora #PS_LOCK_ALL
    sta plState
    lda #$40
    sta plX
    lda #$C0
    sta plY
    lda plItem2Dir
    ora #PS_CATCH_WIND
    sta plItem2Dir
    rts

.lastFrame
    lda plItem2Dir
    and #PS_CATCH_WIND
    beq .rts

    lda plItem2Dir
    and #7
    tax
    lda PlayerFluteDest,x
    sta roomId

    lda roomFlags
    ora #RF_EV_LOAD
    sta roomFlags

    lda #PLAYER_FLUTE_FX2
    sta plState3
.rts
    rts

PlayerUpdateFluteFx2: SUBROUTINE
    lda plItem2Time
    beq PlayerFluteContinueFromTransition
    cmp #-1
    beq .lastFrame
    and #3
    tax
    bne .skipInc
    inc plItem2Time
.skipInc
    inc plm1X
    inc plm1X
    rts


.lastFrame
; Spawn Player
    lda plState
    and #~PS_LOCK_ALL
    sta plState
    lda plItem2Dir
    and #~PS_CATCH_WIND
    sta plItem2Dir
    lda #$34
    sta plX
    lda #$10
    sta plY
    lda #PLAYER_FLUTE_FX
    sta plState3
    rts

PlayerFluteContinueFromTransition: SUBROUTINE
    lda plState
    ora #PS_LOCK_ALL
    sta plState
    lda plItem2Dir
    and #~PS_CATCH_WIND
    sta plItem2Dir
    lda #$10
    sta plm1Y
    lda #0
    sta plm1X
    lda #-40
    sta plItem2Time
    rts


PlayerDrawFluteFx: SUBROUTINE
    lda plItem2Time
    and #3
    tax
    lda plm1Y
    clc
    adc PlayerTornadoAnimOffY-1,x
    sta m0Y
    lda PlayerTornadoAnimWidth-1,x
    sta wNUSIZ0_T
    lda PlayerTornadoAnimHeight-1,x
    sta wM0H
    lda plm1X
    clc
    adc PlayerTornadoAnimOffX-1,x
    sta m0X
    rts


PlayerFluteDest:
    .byte $37, $3C, $74, $45, $0B, $22, $42, $5C

PlayerTornadoAnimOffX:
    .byte 2, -2, 0

PlayerTornadoAnimOffY:
    .byte 2, 4, 0

PlayerTornadoAnimHeight:
    .byte 2, 2, 1

PlayerTornadoAnimWidth:
    .byte $20, $30, $10


PlayerUseWand: SUBROUTINE
    lda ITEMV_WAND
    and #ITEMF_WAND
    beq .rts

; Enable Wand
    lda #<-9
    sta plItemTimer
    lda #SFX_STAB
    sta SfxFlags
.rts
    rts

PlayerUpdateWand: SUBROUTINE
; Set Magic Attack if possible
    lda plItem2Time
    bne .skipSetMagic
    lda plItemTimer
    cmp #ITEM_ANIM_SWORD_STAB_LONG + 3
    bne .skipSetMagic
; Todo: check for book

; Set Magic
    ldx #OBJ_PLM1
    jsr PlayerPlaceNearbyTypeB
    sty plItem2Dir
    lda #PLAYER_WAND_FX
    sta plState3
    lda #-80
    sta plItem2Time
.skipSetMagic
    rts

;==============================================================================
; Position a boxlike item next to the player
;-----------------------
;   X = ObjectId
;   Y returns plDir
;==============================================================================
PlayerPlaceNearbyTypeB: SUBROUTINE
    ldy plDir
    lda plX
    clc
    adc MagicOffX,y
    sta plX,x
    lda plY
    clc
    adc MagicOffY,y
    sta plY,x
    rts


PlayerUpdateWandFx: SUBROUTINE
; handle magic attack logic
    ldy plItem2Dir
    ldx ObjXYAddr,y
    lda OBJ_PLM1,x
    clc
    adc PlayerXYDist2,y
    sta OBJ_PLM1,x
    cmp PlayerXYBoardLimitL,y
    bmi .offScreen
    cmp PlayerXYBoardLimitH,y
    bmi .onScreen
.offScreen
    lda #0
    sta plItem2Time
.onScreen
    rts

PlayerDrawWand: SUBROUTINE
    lda plDir
    sta plItemDir
    cpy #ITEM_ANIM_WAND_STAB_LONG
    bmi .endWand
    cpy #ITEM_ANIM_WAND_STAB_SHORT
    beq .drawWand4
    clc
    adc #4 ; Draw Sword 8
.drawWand4
    tay
    lda WandWidth4,y
    sta wNUSIZ0_T
    lda WandHeight4,y
    sta wM0H
    lda WandOff4X,y
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
    lda WandOff4Y,y
    clc
    adc plY
    sta m0Y
.endWand
    rts

PlayerDrawWandFx: SUBROUTINE
    lda #$20
    sta wNUSIZ0_T
    lda #3
    sta wM0H
    lda plm1X
    sta m0X
    lda plm1Y
    sta m0Y
    rts

PlayerXYDist2:
    .byte 2, -2, -2, 2

PlayerXYBoardLimitL:
    .byte #BoardXL, #BoardXL, #BoardYD, #BoardYD
PlayerXYBoardLimitH:
    .byte #BoardXR, #BoardXR, #BoardYU, #BoardYU

PlayerUpdateMeatFx: SUBROUTINE
    lda Frame
    and #7
    beq .rts
    dec plItem2Time
.rts
    rts

PlayerUpdateSword:
PlayerUpdateSwordFx:
PlayerUpdateNone:
    rts

PlayerDrawMeatFx: SUBROUTINE
    lda #$20
    sta wNUSIZ0_T
    lda #2
    sta wM0H
    lda plm1X
    sta m0X
    lda plm1Y
    sta m0Y
    rts