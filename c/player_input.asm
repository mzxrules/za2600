;==============================================================================
; mzxrules 2022
;==============================================================================

PlayerPause: SUBROUTINE
    bit INPT1
    bmi .skipCheckForPause
    lda plItemTimer
    bmi .skipCheckForPause
; Check Flute Warp in
    lda plState3
    and #[PS_ACTIVE_ITEM2 & $FE]
    cmp #PLAYER_FLUTE_FX
    bne .noWarpIn
    bit plItem2Dir ; PS_CATCH_WIND
    bmi .skipCheckForPause
.noWarpIn
; Check death
    ldx plHealth
    dex
    bmi .skipCheckForPause
    lda #SLOT_FC_PAUSE
    sta BANK_SLOT
    jmp PAUSE_ENTRY
.skipCheckForPause
    rts

PlayerInput: SUBROUTINE
    ; test if player locked
    lda #PS_LOCK_ALL
    bit plState
    beq .InputContinue
    lda plState
    and #~PS_USE_ITEM
    sta plState
    lda plState2
    and #PS_ACTIVE_ITEM
    bne .rts2
    sta plItemTimer
.rts2
    rts
.InputContinue
    ; Test and update fire button state and related flags
    lda plState
    cmp #INPT_FIRE_PREV ; Test if fire pressed last frame, store in carry
    and #~[INPT_FIRE_PREV + PS_USE_ITEM] ; mask out button held and use current item event
    ora #$80 ; INPT_FIRE_PREV
    bit INPT4
    bmi .FireNotHit ; Button not pressed
    eor #$80 ; invert flag
    bcc .FireNotHit ; Button held down
    ldx plItemTimer
    bne .FireNotHit ; Item in use
    ora #PS_USE_ITEM
.FireNotHit
    sta plState

; Player Recoil
    lda plStun
    bpl .noRecoil
    cmp #PL_STUN_RT
    bcs .noRecoil
    lsr
    lsr
    and #3
    tax
    lda PlayerStunColors,x
    sta wPlColor

    lda plStun
    and #3
    tay ; plRecoilDir
    ldx ObjXYAddr,y         ; 4
    lda OBJ_PL,x            ; 4
    clc
    adc PlayerRecoilDist,y  ; 4*
    sta OBJ_PL,x            ; 4
; clamp recoil movement to board bounds
    ldx plX
    ldy plY
.recoilL
    cpx #BoardXL
    bcs .recoilR
    ldx #BoardXL
.recoilR
    cpx #BoardXR
    bcc .recoilD
    ldx #BoardXR
.recoilD
    cpy #BoardYD
    bcs .recoilU
    ldy #BoardYD
.recoilU
    cpy #BoardYU
    bcc .recoilSetPlXY
    ldy #BoardYU
.recoilSetPlXY
    stx plX
    sty plY
    rts
.noRecoil
    lda plState
    ldx #COLOR_PLAYER_02
    bit ITEMV_RING_RED
    bmi .setPlColor
    ldx #COLOR_PLAYER_01
    bvs .setPlColor
    ldx #COLOR_PLAYER_00
.setPlColor
    stx wPlColor

    and #PS_LOCK_MOVE_EN | #PS_LOCK_MOVE_IT
    bne .rts

    lda SWCHA
    and #$F0

ContRight:
    asl
    bcs ContLeft
    lda plY
    and #(GRID_STEP - 1)
    beq MovePlayerRight
    and #(GRID_STEP / 2)
    beq MovePlayerDown
    jmp MovePlayerUp

MovePlayerRight:
    lda plState
    lsr ; PS_LOCK_AXIS
    bcc .MovePlayerRightFr
    lda #2
    bit plDir
    bne .rts
.MovePlayerRightFr
    lda #PL_DIR_R
    sta plDir
    inc plX
.rts
    rts ;jmp ContFin

ContLeft:
    asl
    bcs ContDown
    lda plY
    and #(GRID_STEP - 1)
    beq MovePlayerLeft
    and #(GRID_STEP / 2)
    beq MovePlayerDown
    jmp MovePlayerUp

MovePlayerLeft:
    lda plState
    lsr ; PS_LOCK_AXIS
    bcc .MovePlayerLeftFr
    lda #2
    bit plDir
    bne .rts
.MovePlayerLeftFr
    lda #PL_DIR_L
    sta plDir
    dec plX
    rts ;jmp ContFin

ContDown:
    asl
    bcs ContUp
    lda plX
    and #(GRID_STEP - 1)
    beq MovePlayerDown
    and #(GRID_STEP / 2)
    beq MovePlayerLeft
    jmp MovePlayerRight

MovePlayerDown:
    lda plState
    lsr ; PS_LOCK_AXIS
    bcc .MovePlayerDownFr
    lda #2
    bit plDir
    beq .rts
.MovePlayerDownFr
    lda #PL_DIR_D
    sta plDir
    dec plY
    rts ;jmp ContFin

ContUp:
    asl
    bcs ContFin
    lda plX
    and #(GRID_STEP - 1)
    beq MovePlayerUp
    and #(GRID_STEP / 2)
    beq MovePlayerLeft
    jmp MovePlayerRight

MovePlayerUp:
    lda plState
    lsr ; PS_LOCK_AXIS
    bcc .MovePlayerUpFr
    lda #2
    bit plDir
    beq .rts
.MovePlayerUpFr
    lda #PL_DIR_U
    sta plDir
    inc plY

ContFin:
    rts

PlayerRecoilDist:
    .byte 2, -2, -2, 2

PlayerStunColors:
    .byte #COLOR_PLAYER_00, #COLOR_PLAYER_02, #COLOR_PLAYER_01, #COLOR_EN_BLACK

    LOG_SIZE "Input", PlayerInput

PlayerItem: SUBROUTINE
    ; update player item timers
    lda plItemTimer
    cmp #1
    adc #0
    sta plItemTimer
    bne .skipUnlock
    lda plState
    and #~PS_LOCK_MOVE_IT
    sta plState
.skipUnlock

    lda plItem2Time
    cmp #1
    adc #0
    sta plItem2Time

    jsr PlayerUseItem
    jsr PlayerUpdateItem
    jsr PlayerUpdateSecondaryItem
    jsr PlayerDrawItem
    rts

PlayerUseItem: SUBROUTINE
    bit plState
    bvc .rts ;PS_USE_ITEM
    lda plState2
    and #PS_ACTIVE_ITEM
    tax
    lda PlUseItemH,x
    pha
    lda PlUseItemL,x
    pha
.rts
    rts

PlayerUpdateItem: SUBROUTINE
    ldy plItemTimer
    beq .rts
    lda plState2
    and #PS_ACTIVE_ITEM
    tax
    lda PlUpdateItemH,x
    pha
    lda PlUpdateItemL,x
    pha
.rts
    rts

PlayerUpdateSecondaryItem: SUBROUTINE
    lda plState3
    and #PS_ACTIVE_ITEM2
    tax
    cpx #PLAYER_FLUTE_FX2
    beq .forceWarpIn
    ldy plItem2Time
    beq .rts
.forceWarpIn
    lda PlUpdateItemH+8,x
    pha
    lda PlUpdateItemL+8,x
    pha
.rts
    rts

PlayerDrawItem: SUBROUTINE
    ldy plItemTimer ; Expected in some draw functions
    beq .drawSecondary
    lda plItem2Time
    ror
    bcs .drawSecondary

    lda plState2
    and #PS_ACTIVE_ITEM
    tax
    lda PlDrawItemH,x
    pha
    lda PlDrawItemL,x
    pha
    rts
.drawSecondary
    lda plItem2Time
    beq .noDraw
    lda plState3
    and #PS_ACTIVE_ITEM2
    tax
    lda PlDrawItemH+8,x
    pha
    lda PlDrawItemL+8,x
    pha
    rts

PlayerDrawNone:
.noDraw
    lda #$80
    sta m0Y
    rts
