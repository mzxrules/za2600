;==============================================================================
; mzxrules 2024
;==============================================================================

En_Wizrobe: SUBROUTINE
    lda enState,x
    rol
    bcs .init
    bmi .main

.spawn
    jsr Random
    rts

.init
    lda #$80
    sta enState,x
    rts


.main
    rts

En_WizrobeBlue: SUBROUTINE
    lda enState,x
    bmi .main

    lda #$80
    sta enState,x
    jsr Random
    and #3
    sta enDir,x

.main
    rts