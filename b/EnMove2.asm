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

    INCLUDE "gen/EnMoveOrd_WallCheckLUT.asm"