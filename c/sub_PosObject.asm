;==============================================================================
; PosObject
; include where needed, must be page aligned
; A = position
; X = object to position
;==============================================================================
    sec            ; 2
    sta WSYNC      ; 3
.DivideLoop
    sbc #15        ; 2  6 - each time thru this loop takes 5 cycles, which is
    bcs .DivideLoop; 2  8 - the same amount of time it takes to draw 15 pixels
    eor #7         ; 2 10 - The EOR & ASL statements convert the remainder
    asl            ; 2 12 - of position/15 to the value needed to fine tune
    asl            ; 2 14 - the X position
    asl            ; 2 16
    asl            ; 2 18
    sta.wx HMP0,X  ; 5 23 - store fine tuning of X
    sta RESP0,X    ; 4 27 - set coarse X position of object
;                  ;   67, which is max supported scan cycle
    rts