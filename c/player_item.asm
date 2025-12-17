;==============================================================================
; mzxrules 2024
;==============================================================================

BoxOffX:  ; Fire, Bomb, Magic
    .byte -4, 10, 3, 3
BoxOffY:  ; Fire, Bomb, Magic
    .byte 2, 2, 9, -5


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
    lda .WeaponOffX_8px,y
    clc
    adc plX
    sta plm0X
    lda .WeaponOffY_8px,y
    clc
    adc plY
    sta plm0Y
.rts
    rts

.WeaponOffX_8px:
    .byte -6, 8, 4, 4

.WeaponOffY_8px:
    .byte 3, 3, 7, -7

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
    bmi .rts

.offScreen
    lda #$80
    sta plm0Y
    sta plm0X
.rts
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
    jmp PlayerPlaceItemNearbyTypeB

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
    and #~#PS_ACTIVE_ITEM2
    sta plState3
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
    jmp PlayerPlaceItemNearbyTypeB

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
    jmp PlayerPlaceItemNearbyTypeB

PlayerUseRang:
    rts

; Flute State
; plItemDir bvs resumes tornado after room transition
; plItemDir bmi causes the player to appear

PlayerUseFlute: SUBROUTINE
    lda #SFX_WARP
    sta SfxFlags
    ldy #HALT_TYPE_PLAY_FLUTE
    jmp HALT_GAME_FC

PlayerUpdateFluteFx: SUBROUTINE
    lda plItem2Time
    cmp #-1
    beq .lastFrame
    and #3
    bne .skipTimerInc
    inc plItem2Time
.skipTimerInc
; assume plm1X is never negative
    clc
    lda plm1X
    adc #2
    sta plm1X

; Check player collision
; Have fun analyzing this one
    ; x
    ; A plm1X
    sbc plX
    sbc #8-1
    adc #4+8-1
    bcc .rts
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

    lda #HALT_TYPE_RSCR_EAST
    sta wHaltType

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
    and #~#PS_LOCK_ALL
    sta plState
    lda plItem2Dir
    and #~#PS_CATCH_WIND
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
    and #~#PS_CATCH_WIND
    sta plItem2Dir
    lda #$10
    sta plm1Y
    lda #0
    sta plm1X
    lda #-40
    sta plItem2Time
    rts

PlayerFluteDest:
    .byte $37, $3C, $74, $45, $0B, $22, $42, $5C


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
    jsr PlayerPlaceItemNearbyTypeB
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
    jsr PlayerPlaceItemNearbyTypeB
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
;   X = ObjectId (OBJ_PLM0,1)
;   Y returns plDir
;==============================================================================
PlayerPlaceItemNearbyTypeB: SUBROUTINE
    lda plDir
    sta plItemDir-#OBJ_PLM0,x

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
