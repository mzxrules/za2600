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
    ; Set x to clear flag offset
    tax

    ; If room load this frame, setup new encounter
    bit roomFlags
    bvs .roomLoad ; #RF_EV_LOADED
    bvc .runEncounter

.roomLoad
    ldy roomEN
    lda EnSysEncounter,y
    sta wRoomENFlags
    inc roomEN

    lda rWorldRoomENCount,x
    bpl .resume_encounter
    lda rRoomENFlags
    and #$1F
.resume_encounter
    sta roomENCount

    lda rWorldRoomFlags,x ; get room clear byte
    and #WRF_SV_ENKILL
    beq .runEncounter

    lda #0
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
    ; fetch next encounter
    ldy roomEN
    lda EnSysEncounter,y
    sta enSysType,x
    lda #EN_APPEAR
    sta enType,x
    lda #0
    sta enState,x

; Update encounter cursor if supported
    lda rRoomENFlags
    bmi .rts
    inc roomEN
    rts

EnSysRoomKill: SUBROUTINE
    lda roomId
    and #$7F
    tay
    lda rWorldRoomFlags,y
    ora #WRF_SV_ENKILL
    sta wWorldRoomFlags,y
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
    sta miType,x
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

    ldx #EN_SIZE -2
.loop
    lda EN_START+1,x
    sta EN_START,x
    dex
    dex
    bpl .loop
    lda #EN_NONE
    sta enType+1
    sta miType+1

.rts
    rts
