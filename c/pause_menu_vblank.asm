;==============================================================================
; mzxrules 2025
;==============================================================================

PAUSE_MAP_MEM_RESET:
; erase map for next cycle; do it here to avoid running out of cycles
; invert y cursor and setup for memory wipe

    lda #SLOT_RW_F0_DUNG_MAP
    sta BANK_SLOT_RAM

    lda Frame
    and #7
    tax
    ldy Pause_InvertMul5,x
    lda #0

; reset memory for row
ITER   SET 0
    REPEAT 5
    sta wMAP_0+ITER,y
    sta wMAP_1+ITER,y
    sta wMAP_2+ITER,y
    sta wMAP_3+ITER,y
    sta wMAP_4+ITER,y
    sta wMAP_5+ITER,y
ITER    SET ITER+1
    REPEND
    rts

PAUSE_ANIMATE_BLINK: SUBROUTINE
; blink player position on dungeon map
    lda Frame
    and #7
    bne .skipBlink

    ldy worldId
    lda roomId
    and #$F
    sec
    sbc MapData_RoomOffsetX-#LV_MIN,y
    cmp #8
    bcs .skipBlink
    tax

    lda roomId
    and #$7F
    lsr
    lsr
    lsr
    lsr
    tay

    lda MapCurRoomOff,x
    clc
    adc Pause_InvertMul5,y
    tay

    lda #SLOT_RW_F0_DUNG_MAP
    sta BANK_SLOT_RAM
    lda rMAP_0,y
    eor MapCurRoomEor,x
    sta wMAP_0,y
.skipBlink
    rts

Pause_InvertMul5:
    .byte 35, 30, 25, 20
    .byte 15, 10,  5,  0

MapCurRoomOff:
    .byte 0 * #PAUSE_MAP_HEIGHT + 2
    .byte 1 * #PAUSE_MAP_HEIGHT + 2
    .byte 2 * #PAUSE_MAP_HEIGHT + 2
    .byte 2 * #PAUSE_MAP_HEIGHT + 2

    .byte 3 * #PAUSE_MAP_HEIGHT + 2
    .byte 3 * #PAUSE_MAP_HEIGHT + 2
    .byte 4 * #PAUSE_MAP_HEIGHT + 2
    .byte 5 * #PAUSE_MAP_HEIGHT + 2

MapCurRoomEor:
    .byte $02, $10, $80, $04
    .byte $20, $01, $08, $40