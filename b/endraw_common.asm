;==============================================================================
; mzxrules 2024
;==============================================================================

;==============================================================================
; Sets position and color variables, overriding with stun colors
; A = EnColor
; X = EnNum
; Y is untouched
;==============================================================================
EnDraw_PosAndStunColor: SUBROUTINE
    sta EnDrawColor
    lda enStun,x
    asl
    asl
    adc EnDrawColor
EnDraw_PosAndColor: SUBROUTINE
    sta wEnColor

EnDraw_Pos: SUBROUTINE
    lda en0X,x
    sta enX
    lda en0Y,x
    sta enY
    rts

EnDraw_SmallMissile: SUBROUTINE
    lda miType,x
    bpl .rts

    clc
    lda mi0X,x
    adc #3+1
    sta m1X
    clc
    lda mi0Y,x
    adc #3
    sta m1Y

; 2x2 missile
    lda #1
    sta wM1H
    lda rNUSIZ1_T
    ora %10000
    sta wNUSIZ1_T
.rts
    rts