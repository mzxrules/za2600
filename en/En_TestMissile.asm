;==============================================================================
; mzxrules 2021
;==============================================================================
En_TestMissile: SUBROUTINE
    lda #$80
    and enState,x
    bne .run
    lda #$80
    sta enState,x
    lda #$3C
    sta en0X,x
    sta en0Y,x
    rts
.run
    lda miType,x
    bne .rts

    inc enTestMissileTimer,x
    lda enTestMissileTimer,x
    cmp #20
    bne .rts

    lda #0
    sta enTestMissileResult,x
    sta enTestMissileTimer,x
    lda #2
    sta miType,x
    lda en0X,x
    sta mi0X,x
    lda en0Y,x
    sta mi0Y,x

.rts
    rts