;==============================================================================
; mzxrules 2021
;==============================================================================

EnNone:
    lda #$F0
    sta en0Y,x
    rts

;==============================================================================
; ENTITY
;==============================================================================

EnSystem: SUBROUTINE
    ldx roomId
    bmi .rts

    ; If room load this frame, setup new encounter
    bit roomFlags
    bvc .runEncounter ; not #RF_EV_LOADED

.roomLoad
    ldy roomEN
    lda EnSysEncounterTable,y
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
    lda #~#RF_EV_ENCLEAR
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
    beq .spawn_enemy
    inx
    cpx #2
    bne .loop
.rts
    rts

.spawn_enemy
    stx enNum
    ; fetch next encounter
    ldy roomEN
    lda EnSysEncounterTable,y
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
; EnSys_KillEnemyA
;----------
; Kills an Enemy without dropping an item
; X = enNum of Enemy to kill
;==============================================================================
EnSys_KillEnemyA: SUBROUTINE
    dec roomENCount
    bne EnSysDelete
    ; Set room clear flag
    lda #RF_EV_ENCLEAR
    ora roomFlags
    sta roomFlags
    jmp EnSysDelete

;==============================================================================
; EnSys_KillEnemyB
;----------
; Kills an Enemy, potentially dropping an item
; X = enNum of Enemy to kill
;==============================================================================
EnSys_KillEnemyB: SUBROUTINE
    dec roomENCount
    bne .tryDropItem
    ; Set room clear flag
    lda #RF_EV_ENCLEAR
    ora roomFlags
    sta roomFlags
.tryDropItem

    jsr Random
    cmp #99 ; drop rate odds, N out of 256
    bcs EnSysDelete
    jsr Random
    and #$7
    tay
    lda EnRandomDrops,y
; Spawn RNG Item Drop
    sta cdItemType,x
    lda #EN_ITEM
    sta enType,x
    lda #EN_ITEM_TYPE_RNG
    sta enState,x
    lda #EN_ITEM_APPEAR_TIME
    sta cdItemTimer,x
    rts

EnSysDelete:
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


EnRandomDrops:
    .byte #GI_RECOVER_HEART, #GI_FAIRY, #GI_BOMB, #GI_RUPEE5
    .byte #GI_RUPEE, #GI_RUPEE, #GI_RUPEE5, #GI_RUPEE
