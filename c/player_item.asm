;==============================================================================
; mzxrules 2024
;==============================================================================

WeaponWidth:
WeaponWidth_4px_thick:
    .byte $20, $20, $10, $10
WeaponWidth_8px_thick:
    .byte $30, $30, $10, $10
WeaponWidth_4px_thin:
    .byte $20, $20, $00, $00
WeaponWidth_8px_thin:
    .byte $30, $30, $00, $00


WeaponHeight:
WeaponHeight_4px_thick:
    .byte 1, 1, 3, 3
WeaponHeight_8px_thick:
    .byte 1, 1, 7, 7
WeaponHeight_4px_thin:
    .byte 0, 0, 3, 3
WeaponHeight_8px_thin:
    .byte 0, 0, 7, 7

WeaponOffX:
WeaponOffX_4px:
    .byte -2, 8, 4, 4
WeaponOffX_8px:
    .byte -6, 8, 4, 4

WeaponOffY:
WeaponOffY_4px:
    .byte 3, 3, 7, -3
WeaponOffY_8px:
    .byte 3, 3, 7, -7


BoxOffX:  ; Fire, Bomb, Magic
    .byte -4, 10, 3, 3
BoxOffY:  ; Fire, Bomb, Magic
    .byte 2, 2, 9, -5

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
    lda WeaponOffX_8px,y
    clc
    adc plX
    sta plm0X
    lda WeaponOffY_8px,y
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

    cmp PlayerXYBoardLimitMin,y
    bmi .offScreen
    cmp PlayerXYBoardLimitMax,y
    bpl .offScreen
    rts

.offScreen
    lda #$80
    sta plm0Y
    sta plm0X
    rts

PlayerDrawArrow: SUBROUTINE
    ldy plItemDir
    lda WeaponWidth_8px_thin,y
    sta wNUSIZ0_T
    lda WeaponHeight_8px_thin,y
    sta wM0H
    lda plm0X
    sta m0X
    lda plm0Y
    sta m0Y
    rts

PlayerDrawSwordFx: SUBROUTINE
    ldy plItem2Dir
    lda WeaponWidth_4px_thick,y
    sta wNUSIZ0_T
    lda WeaponHeight_4px_thick,y
    sta wM0H
    ldx plm1X
    inx
    stx m0X
    ldx plm1Y
    inx
    stx m0Y
    rts

PlayerUseCandle: SUBROUTINE
    lda ITEMV_CANDLE_RED
    and #ITEMF_CANDLE_RED
    bne .red_candle_used
    lda roomFlags
    ror ; #RF_USED_CANDLE
    bcs .blue_candle_blocked

.red_candle_used
    lda plItem2Time
    beq .continue
.blue_candle_blocked
    jmp PlayerUseSword
.continue
; Spawn
    lda roomFlags
    ora #RF_USED_CANDLE
    sta roomFlags

    lda #-64
    sta plItem2Time

    lda #PLAYER_FIRE_FX
    sta plState3

    ldx #OBJ_PLM1
    jsr PlayerPlaceNearbyTypeB
    sty plItem2Dir
    rts

PlayerUpdateFireFx: SUBROUTINE
    lda plItem2Time
    cmp #-1
    beq .lastFrame
    cmp #-60
    bne .skip_flag_set
    lda rRoomColorFlags
    and #~#RF_WC_ROOM_DARK
    sta wRoomColorFlags
.skip_flag_set
    lda SfxFlags
    beq .set_fire_sfx
    cmp #[#SFX_FIRE & ~#SFX_NEW]
    bne .rts

.set_fire_sfx
    lda #SFX_FIRE
    sta SfxFlags

.rts
    rts
.lastFrame
    lda #0
    sta plItem2Time
    lda plState3
    and #~PS_ACTIVE_ITEM2
    sta plState3
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
    and #$1F
    bne .useBomb
    jmp PlayerEquipSword
.useBomb
    dec itemBombs
    lda #-40
    sta plItemTimer

    ldx #OBJ_PLM0
    jsr PlayerPlaceNearbyTypeB
    sty plItemDir
    rts

PlayerDrawBomb: SUBROUTINE
    lda plm0Y
    bmi .draw_initial
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
    lda plState
    ora #PS_LOCK_MOVE_IT
    sta plState
; Sfx
    lda #SFX_STAB
    sta SfxFlags
.rts
    rts

PlayerUseMeat: SUBROUTINE
    lda ITEMV_MEAT
    and #ITEMF_MEAT
    beq PlayerEquipSword
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
    lda #0
    sta Temp0
    bpl .draw_continue

PlayerDrawWand:
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


; Flute State
; plItemDir bvs resumes tornado after room transition
; plItemDir bmi causes the player to appear

PlayerUseFlute: SUBROUTINE
    lda #SFX_WARP
    sta SfxFlags
    lda #SLOT_FC_HALT
    sta BANK_SLOT
    jmp HALT_PLAY_FLUTE_ENTRY

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
    sta roomIdNext

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
    lda plState
    ora #PS_LOCK_MOVE_IT
    sta plState
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

PlayerUpdateSword:
    lda plHealth
    cmp plHealthMax
    bne .rts
    lda plItem2Time
    bne .rts
    lda plItemTimer
    cmp #ITEM_ANIM_SWORD_STAB_LONG + 3
    bne .rts

    ldx #OBJ_PLM1
    jsr PlayerPlaceNearbyTypeB
    sty plItem2Dir
    lda #PLAYER_SWORD_FX
    sta plState3
    lda #-80
    sta plItem2Time
    ;lda #SFX_STAB2
    ;sta SfxFlags
.rts
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
    adc BoxOffX,y
    sta plX,x
    lda plY
    clc
    adc BoxOffY,y
    sta plY,x
    rts

PlayerUpdateSwordFx: SUBROUTINE
PlayerUpdateWandFx: SUBROUTINE
    ldy plItem2Dir
    ldx ObjXYAddr,y
    lda OBJ_PLM1,x
    clc
    adc PlayerXYDist2,y
    sta OBJ_PLM1,x
    cmp PlayerXYBoardLimitMin,y
    bmi .offScreen
    cmp PlayerXYBoardLimitMax,y
    bmi .onScreen
.offScreen
    lda #0
    sta plItem2Time
.onScreen
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
    .byte -2, 2, 2, -2

PlayerXYBoardLimitMin:
    .byte #BoardXL, #BoardXL, #BoardYD, #BoardYD
PlayerXYBoardLimitMax:
    .byte #BoardXR, #BoardXR, #BoardYU, #BoardYU

PlayerUpdateMeatFx: SUBROUTINE
    ldx plItem2Time
    cpx #$E8
    bcs .rts

    lda Frame
    and #$F
    bne .rts
    txa
    sec
    sbc #$E
    sta plItem2Time
.rts
PlayerUpdateNone:
    rts

PlayerDrawMeatFx: SUBROUTINE
    lda plItem2Time
    cmp #$F0
    bcc .drawNormal
    and #$4
    bne .drawNormal
    jmp PlayerDrawNone
.drawNormal
    lda #$20
    sta wNUSIZ0_T
    lda #2
    sta wM0H
    lda plm1X
    sta m0X
    lda plm1Y
    sta m0Y
    rts