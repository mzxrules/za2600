;==============================================================================
; mzxrules 2024
;==============================================================================

;==============================================================================
; PosHudObjects
;----------
; Positions all HUD elements, within two scanlines
;==============================================================================
PosHudObjects_Cycle0:
    sleep 18

PosHudObjects_Cycle18:
    ldx worldId
    lda WorldData_CompassRoom-#LV_MIN,x
    and #7
    eor #7
    sta RESBL       ; 29
    asl
    asl
    asl
    asl
    sta HMBL
    lda roomId
    sec
    sbc MapData_RoomOffsetX-#LV_MIN,x
    sta Temp0

;----------
; Timing Notes:
; $18 2 iter (9) + 15 = 24
; $18
; $60 7 iter (34) + 15 = 49
;----------
    sta WSYNC
    ; 26 cycles start

    lda worldId         ; 3
    ; 7 cycle start
    bpl .dungeon        ; 2/3
    lda #$F             ; 2
    bne .roomIdMask     ; 3 ; jmp
.dungeon
    lda #$7             ; 2
    nop                 ; 2
.roomIdMask
    ; 7 cycle end

    and Temp0           ; 3
    eor #7              ; 2
    asl                 ; 2
    asl                 ; 2
    asl                 ; 2
    asl                 ; 2
    sta HMM0            ; 3
    ; 26 cycles end
    sta RESP1           ; 3 - Map Sprite
    sta RESM0           ; 3 - Player Dot
    ; 18 cycles start
    lda worldId         ; 3
    bpl .MapShift       ; 2/3
    lda #0              ; 2
    beq .SetMapShift    ; 3
.MapShift
    lda #$F0            ; 2
    nop                 ; 2
.SetMapShift
    sta HMP1            ; 3
    lda #0              ; 2
    sta HMP0            ; 3
    ; 18 cycles end
    sta RESP0           ;  - Inventory Sprites

    sta WSYNC
    sta HMOVE
;==============================================================================

    rts