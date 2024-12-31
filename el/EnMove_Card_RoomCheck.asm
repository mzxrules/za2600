;==============================================================================
; mzxrules 2024
;==============================================================================

;==============================================================================
; Tests room sprite collision
; returns A != 0 if collision occurs
; X is enNum
;==============================================================================
EnMove_Card_RoomCheck: SUBROUTINE
    ldx EnMoveNX
    lda EnMoveNY

;==============================================================================
; Tests room sprite collision
; X = 1/4th x position
; A = 1/4th y position
; returns A != 0 if collision occurs
; X is enNum
;==============================================================================
EnMove_Card_RoomCheck_XA:
    cpx #[$04/4] ; 2
    bmi .fail    ; 2
    cmp #[$10/4] ; 2
    bmi .fail    ; 2
EnMove_Card_RoomCheck_Unsafe:
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
    ldx enNum
    and #$FF
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
    ldx enNum
    and #$FF
    rts
.fail
    ldx enNum
    lda #1
.rts
    rts