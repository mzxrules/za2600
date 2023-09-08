;==============================================================================
; mzxrules 2023
;==============================================================================
EnMov_Card_WallCheck_TEST: SUBROUTINE
; adjust x coordinate
    txa
    lsr
    lsr
    sta EnSysNX

; adjust y coordinate
    tya
    lsr
    lsr
    sta EnSysNY

;==============================================================================
; Computes free spaces, cardinal to position (EnSysNX, EnSysNY)
; EnSysBlockedDir stores all blocked directions
; Clobbers X, Y registers
;==============================================================================
EnMov_Card_WallCheck: SUBROUTINE
    lda #0
;EnSetBlockedDir2:
    ldx EnSysNX
    cpx #[EnBoardXR/4]
    bne .setBlockedL
    ora #EN_BLOCKED_DIR_R
.setBlockedL
    cpx #[EnBoardXL/4]
    bne .setBlockedD
    ora #EN_BLOCKED_DIR_L
.setBlockedD
    ldy EnSysNY
    cpy #[EnBoardYD/4]
    bne .setBlockedU
    ora #EN_BLOCKED_DIR_D
.setBlockedU
    cpy #[EnBoardYU/4]
    bne .checkPFHit
    ora #EN_BLOCKED_DIR_U
.checkPFHit
    sta EnSysBlockedDir


;CheckRoomCol_XA:
.dl ; LEFT (-1, 0)
    tya

; todo - determine if bounds check is necessary
    ; cpx #[$04/4 + 1] ; 2
    ; bmi .dl_blocked
    ; cpy #[$10/4] ; 2
    ; bmi .dl_blocked

    cpx #[$60/4 + 1]
    beq .dl_special_right
    cpx #[$20/4 + 1]
    beq .dl_special_left
    clc
    adc room_col8_off-1 -1,x
    tay
    lda rPF1RoomL-2,y
    ora rPF1RoomL-1,y
    and room_col8_mask-1 -1,x
    bne .dl_blocked
    beq .dr

.dl_special_right
    adc #ROOM_PX_HEIGHT -1
.dl_special_left
    tay
    lda rPF1RoomL-2,y
    ora rPF1RoomL-1,y
    ora rPF2Room-2,y
    ora rPF2Room-1,y
    and #1
    beq .dr

.dl_blocked
    lda #EN_BLOCKED_DIR_L
    ora EnSysBlockedDir
    sta EnSysBlockedDir


.dr ; RIGHT (1, 0)
    ldy EnSysNY
    tya

    cpx #[$60/4 - 1]
    beq .dr_special_right
    cpx #[$20/4 - 1]
    beq .dr_special_left
    clc
    adc room_col8_off-1 +1,x
    tay
    lda rPF1RoomL-2,y
    ora rPF1RoomL-1,y
    and room_col8_mask-1 +1,x
    bne .dr_blocked
    beq .dud

.dr_special_right
    adc #ROOM_PX_HEIGHT -1
.dr_special_left
    tay
    lda rPF1RoomL-2,y
    ora rPF1RoomL-1,y
    ora rPF2Room-2,y
    ora rPF2Room-1,y
    and #1
    beq .dud

.dr_blocked
    lda #EN_BLOCKED_DIR_R
    ora EnSysBlockedDir
    sta EnSysBlockedDir

.dud
    ; UP   (0,  1)
    ; DOWN (0, -1)

    ldy EnSysNY
    tya

    cpx #[$60/4]
    beq .dud_special_right
    cpx #[$20/4]
    beq .dud_special_left
    clc
    adc room_col8_off-1,x
    tay
    lda rPF1RoomL-2 +1,y
    ora rPF1RoomL-1 +1,y
    and room_col8_mask-1,x
    beq .dud2
    lda #EN_BLOCKED_DIR_U
    ora EnSysBlockedDir
    sta EnSysBlockedDir
.dud2
    lda rPF1RoomL-2 -1,y
    ora rPF1RoomL-1 -1,y
    and room_col8_mask-1,x
    beq .rts
    lda #EN_BLOCKED_DIR_D
    ora EnSysBlockedDir
    sta EnSysBlockedDir
    rts

.dud_special_right
    adc #ROOM_PX_HEIGHT -1
.dud_special_left
    tay
    lda rPF1RoomL-2 +1,y
    ora rPF1RoomL-1 +1,y
    ora rPF2Room-2 +1,y
    ora rPF2Room-1 +1,y
    and #1
    beq .dud_special_right2
    lda #EN_BLOCKED_DIR_U
    ora EnSysBlockedDir
    sta EnSysBlockedDir
.dud_special_right2
    lda rPF1RoomL-2 -1,y
    ora rPF1RoomL-1 -1,y
    ora rPF2Room-2 -1,y
    ora rPF2Room-1 -1,y
    and #1
    beq .rts
    lda #EN_BLOCKED_DIR_D
    ora EnSysBlockedDir
    sta EnSysBlockedDir
.rts
    rts

;==============================================================================
; Randomly selects a new cardinal direction
; enNX, enNY are update to new destination point
; enNextDir returns new direction
; Clobbers X, Y registers
;==============================================================================
EnMov_Card_RandDir: SUBROUTINE
    lda #3
    sta EnSysNextDirCount
    jsr Random              ; 32
    ldy #0
    cmp #$55
    bcc .select_seed
    iny
    cmp #$AA
    bcc .select_seed
    iny
.select_seed
    and #7
    ora Mul8,y
    sta EnSysNextDirSeed
    and #3
    tay ; enNextDir
.loop
    lda Bit8,y
    and EnSysBlockedDir
    beq .select

    dec EnSysNextDirCount
    bmi .miss
    ldy EnSysNextDirSeed    ; 3
    ldx nextdir_step_lut,y  ; 4
    stx EnSysNextDirSeed
    ldy nextdir_lut,x       ; 4
    bpl .loop
.select
    jsr EnMoveNextDel
.miss
    sty enNextDir
    rts


;==============================================================================
; Attempts to select enDir, then if blocked randomly selects cardinal direction
; enNX, enNY are update to new destination point
; enNextDir returns new direction
; Clobbers X, Y registers
;==============================================================================
EnMov_Card_RandDirIfBlocked:
    lda #3
    sta EnSysNextDirCount
    jsr Random
    ldy #0
    cmp #$55
    bcc .select3
    iny
    cmp #$AA
    bcc .select3
    iny
.select3
    and #4
    ora Mul8,y
    ora enDir,x
    sta EnSysNextDirSeed    ; 3
    ldy enDir,x
    bpl .loop ; JMP


/*
EnSeekCardDir: SUBROUTINE
    ldy #EN_DIR_L
    lda en0X,x
    sec
    sbc plX
    bpl .checkY ; enX - plX >= 0, left
                ; enX - plX <  0, right
    ldy #EN_DIR_R
    ; negate A
    eor #$FF
    adc #1
.checkY
    sta Temp0
    stx EnSysNextDirSeed

    ldy #EN_DIR_D
    lda enY,x
    sec
    sbc plY
    bpl .checkAxis  ; enY - plY >= 0, down
                    ; enY - plY <  0, up
    ldy #EN_DIR_U
    ; negate A
    eor #$FF
    adc #1
.checkAxis
    sta Temp1
    sty EnSysNextDirCount
*/