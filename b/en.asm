;==============================================================================
; mzxrules 2021
;==============================================================================

;==============================================================================
; Tests room collision
; X = x position
; Y = y position (move to reg a?)
; returns A != 0 if collision occurs
; y position must not be in range 0-3
;==============================================================================
CheckRoomCol: SUBROUTINE
; adjust x coordinate
    txa
    lsr
    lsr
    tax

; adjust y coordinate
    tya
    lsr
    lsr
    tay
; A stores adjusted y coord

CheckRoomCol_XA:
    tya

    cpx #[$04/4] ; 2
    bmi .rts     ; 2
    cmp #[$10/4] ; 2
    bmi .rts     ; 2

    cpx #[$60/4]
    beq .special_right
    cpx #[$20/4]
    beq .special_left
    clc
    adc room_col8_off-1,x
    tay
    lda rPF1RoomL-2,y
    ora rPF1RoomL-1,y
    and room_col8_mask-1,x
    rts

.special_right
    adc #ROOM_PX_HEIGHT -1
.special_left
    tax
    lda rPF1RoomL-2,x
    ora rPF1RoomL-1,x
    ora rPF2Room-2,x
    ora rPF2Room-1,x
    and #1

.rts
    rts


EnNone:
    lda #$F0
    sta en0Y,x
    rts

;==============================================================================
; ENTITY
;==============================================================================

EnSysEncounter:
    .byte EN_NONE, EN_OCTOROK, EN_OCTOROK, EN_ROPE
    .byte EN_ROPE, EN_DARKNUT, EN_DARKNUT, EN_BOSS_GOHMA
    .byte EN_WALLMASTER, EN_TEST_MISSILE, EN_LIKE_LIKE, EN_BOSS_GLOCK
    .byte EN_WATERFALL, EN_ROLLING_ROCK
EnSysEncounterCount:
    .byte 0, 1, 2, 1
    .byte 2, 1, 2, 1
    .byte 1, 1, 1, 1
    .byte 1, 2, 0, 0

ClearDropSystem: SUBROUTINE
    lda enType
    bne .ClearDropSystem_rts
    lda roomFlags
    and #RF_EV_ENCLEAR | #RF_EV_CLEAR
    beq .ClearDropSystem_rts

    ldy #EN_CLEAR_DROP
    sty enType
    ldx #0
    stx enState
    stx cdBTimer
    stx cdAType
    stx cdBType

    and #RF_EV_ENCLEAR
    beq .ClearDropSystem_rts
    dec cdBType ; CD_ITEM_RAND

.ClearDropSystem_rts

EnSystem: SUBROUTINE
    lda roomId
    bmi .rts
    ; precompute room clear flag helpers because it's annoying
    lsr
    lsr
    lsr
    sta EnSysClearOff
    lda roomId
    and #7
    tax
    lda Bit8,x
    sta EnSysClearMask

    ; Set x to clear flag offset
    ldx EnSysClearOff
    ; Set y to encounterId
    ldy roomEN

    ; If room load this frame, setup new encounter
    bit roomFlags
    bvs .checkRoomClear ; #RF_EV_LOADED

    ; Else, if enemy clear event flag set, set enemy clear flag
    lda roomFlags
    and #RF_EV_ENCLEAR
    beq .runEncounter ; flag not set, run encounter

    lda rRoomClear,x
    ora EnSysClearMask
    sta wRoomClear,x
    bne .runEncounter ; should always branch

    ; Test if room wasn't cleared
.checkRoomClear
    lda #0
    sta roomENCount
    ; check room clear state
    lda rRoomClear,x ; get room clear byte
    and EnSysClearMask
    bne .runEncounter

    lda EnSysEncounterCount,y
    sta roomENCount

.runEncounter
    ; toggle off enemy clear event
    lda #~RF_EV_ENCLEAR
    and roomFlags
    sta roomFlags

    ; test if the player is being positioned in the room
    lda #PS_LOCK_ALL
    bit plState
    bne .rts

    ; return if...
    ; There are 0 encounters left
    ; There is 1 encounter left and enType is already slotted
    ldx #0
.loop
    cpx roomENCount
    beq .rts
    lda enType,x
    beq .cont
    inx
    cpx #2
    bne .loop
.rts
    rts

.cont
    stx enNum
    ; store next encounter
    lda EnSysEncounter,y
    sta enSysType,x
    lda #EN_APPEAR
    sta enType,x
    lda #0
    sta enState,x
    rts

;==============================================================================
; EnSysEnDie
;----------
; Kills an Enemy
; X = enNum of Enemy to kill
;==============================================================================
EnSysEnDie: SUBROUTINE
    dec roomENCount
    bne .continueEncounter
    ; Set room clear flag
    lda #RF_EV_ENCLEAR
    ora roomFlags
    sta roomFlags
    ; set random item drop position
    lda enX
    sta cdBX
    lda enY
    sta cdBY

.continueEncounter
    lda #$80
    sta en0Y,x
    lda #EN_NONE
    sta enType,x
    cpx #0
    beq EnSysCleanShift
.rts
    rts

EnSysCleanShift: SUBROUTINE
    lda enType
    bne .rts
    ldx enType+1
    beq .rts
    stx enType

    ldx #EN_VARS_COUNT + 6 -2
.loop
    lda EN_VARS-6+1,x
    sta EN_VARS-6,x
    dex
    dex
    bpl .loop
    lda #EN_NONE
    sta enType+1

.rts
    rts
