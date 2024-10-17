;==============================================================================
; mzxrules 2024
;==============================================================================

;==============================================================================
; Selects a diagonal direction headed towards room center
; X = enNum
; enDir,x is updated
;==============================================================================
EnMove_Ord_SetSeekCenter: SUBROUTINE
    lda en0Y,x
    sec
    sbc #BoardYC
    and #$80
    sta EnMoveTemp0

    lda #BoardXC
    sec
    sbc en0X,x
    clc
    rol
    lda EnMoveTemp0
    rol
    rol
    tay
    lda EnMoveBounceDiagonal,y
    sta enDir,x
    rts

;==============================================================================
; Tests if flying enemy hits the board boundaries
; X = enNum
; Y = next unblocked direction
;==============================================================================
EnMove_Ord_WallCheck: SUBROUTINE
    lda #EnBoardXR

;==============================================================================
; Tests if flying enemy hits the board boundaries
; A = Custom EnBoardXR value
; X = enNum
; Y = next unblocked direction
;==============================================================================
EnMove_Ord_WallCheck_BoardXR: SUBROUTINE
    sta EnMoveOrdBoardXR
    ldy enDir,x

.check_left
    lda en0X,x
    cmp #EnBoardXL
    bcs .check_right

    lda EnMoveOrd_WallCheckLUT+$00,y
    tay

.check_right
    lda en0X,x
    cmp EnMoveOrdBoardXR ;#EnBoardXR
    bcc .check_up

    lda EnMoveOrd_WallCheckLUT+$08,y
    tay

.check_up
    lda en0Y,x
    cmp #EnBoardYU
    bcc .check_down

    lda EnMoveOrd_WallCheckLUT+$10,y
    tay

.check_down
    lda en0Y,x
    cmp #EnBoardYD
    bcs .rts

    lda EnMoveOrd_WallCheckLUT+$18,y
    tay

.rts
    rts

;==============================================================================
; Selects a new direction based on the shortest path to the player
; X = enNum
;==============================================================================
EnMove_Ord_SeekDir: SUBROUTINE
    lda #0
    sta EnMoveSeekFlags

    lda en0X,x
    sec
    sbc plX
    sta EnMoveTemp0 ; enX - plX >= 0, left
                    ; enX - plX <  0, right

    rol EnMoveSeekFlags
    bit EnMoveTemp0
    bpl .checkY
    ; negate A
    eor #$FF
    adc #1
    sta EnMoveTemp0

.checkY
    lda en0Y,x
    sec
    sbc plY
    sta EnMoveTemp1 ; enY - plY >= 0, down
                    ; enY - plY <  0, up

    rol EnMoveSeekFlags
    bit EnMoveTemp1
    bpl .checkAxis
    ; negate A
    eor #$FF
    adc #1
    sta EnMoveTemp1

.checkAxis
    lda EnMoveTemp0
    sec
    sbc EnMoveTemp1 ; abs(xDelta) - abs(yDelta)
    lda EnMoveSeekFlags
    rol
    asl
    asl
    tax
.loop
    inx
    ldy EnMove_SeekDirLUT-1,x
    ldx enNum
    rts

    INCLUDE "gen/EnMoveOrd_WallCheckLUT.asm"