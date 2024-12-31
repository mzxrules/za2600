;==============================================================================
; mzxrules 2024
;==============================================================================

;==============================================================================
; Checks if the spaces cardinal to position (EnMoveNX, EnMoveNY) are
; out of bounds
; EnMoveBlockedDir stores all blocked directions
; X = enNum
; Clobbers Y register
;==============================================================================
EnMove_Card_BorderCheck: SUBROUTINE
    lda #0
; Check board boundaries
    ldx EnMoveNX
    cpx #[EnBoardXR/4]
    bcc .testBlockedL
    ora #EN_BLOCKED_DIR_R
.testBlockedL
    cpx #[EnBoardXL/4] + 1
    bcs .testBlockedD
    ora #EN_BLOCKED_DIR_L
.testBlockedD
    ldy EnMoveNY
    cpy #[EnBoardYD/4] + 1
    bcs .testBlockedU
    ora #EN_BLOCKED_DIR_D
.testBlockedU
    cpy #[EnBoardYU/4]
    bcc .checkPFHit
    ora #EN_BLOCKED_DIR_U
.checkPFHit
    sta EnMoveBlockedDir
    ldx enNum
    rts