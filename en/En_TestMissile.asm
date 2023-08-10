;==============================================================================
; mzxrules 2021
;==============================================================================
En_TestMissile: SUBROUTINE
    lda #$80
    and enState,x
    bne .run
    lda #$80
    sta enState,x
    rts
.run
    lda miType,x
    bne .rts
    lda #3
    sta miType,x
    lda en0X,x
    sta mi0X,x
    lda en0Y,x
    sta mi0Y,x

.rts
    rts