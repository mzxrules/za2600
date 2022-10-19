;==============================================================================
; mzxrules 2022
;==============================================================================

RsInit_Del: SUBROUTINE
    ldx roomRS
    lda RoomScriptInitH,x
    pha
    lda RoomScriptInitL,x
    pha
    rts
    LOG_SIZE "RsInit_Del", RsInit_Del