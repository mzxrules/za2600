;==============================================================================
; mzxrules 2024
;==============================================================================

;==============================================================================
; Performs an 8x8 collision test against an 8x8 ball
; returns Carry SET if collision occurs
;==============================================================================
EnCol_Ball: SUBROUTINE
    clc
    lda en0X,x
    sbc blX
    sbc #8-1
    adc #8+8+1
    bcc .rts ;no overlap
    clc
    lda en0Y,x
    sbc blY
    sbc #8-1
    adc #8+8+1
.rts
    rts