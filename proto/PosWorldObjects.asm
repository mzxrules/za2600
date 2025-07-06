;==============================================================================
; mzxrules 2022
;==============================================================================

;==============================================================================
; PosWorldObjects
;----------
; Sets X position for all TIA objects within the world view
; X position must be between 0-134 ($00 to $86)
; Higher values will waste an extra scanline
; Does not touch Y register
;==============================================================================
PosWorldObjects: SUBROUTINE
    ldx #4
PosWorldObjects_X: SUBROUTINE
    sec            ; 2
    inc blX
.Loop
    sta WSYNC      ; 3
    lda plX,x      ; 4  4 - Offsets by 12 pixels
DivideLoop
    sbc #15        ; 2  6 - each time thru this loop takes 5 cycles, which is
    bcs DivideLoop ; 2  8 - the same amount of time it takes to draw 15 pixels
    eor #7         ; 2 10 - The EOR & ASL statements convert the remainder
    asl            ; 2 12 - of position/15 to the value needed to fine tune
    asl            ; 2 14 - the X position
    asl            ; 2 16
    asl            ; 2 18
    sta.wx HMP0,x  ; 5 23 - store fine tuning of X
    sta RESP0,x    ; 4 27 - set coarse X position of object
;                  ;   67, which is max supported scan cycle
    dex            ; 2 69
    bpl .Loop      ; 3 72

    sta WSYNC
    sta HMOVE
    dec blX
    rts