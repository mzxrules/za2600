;==============================================================================
; mzxrules 2022
;==============================================================================

RsInit_Del: SUBROUTINE
    ldx roomRS
    lda RsInitH,x
    pha
    lda RsInitL,x
    pha
    rts
    LOG_SIZE "RsInit_Del", RsInit_Del