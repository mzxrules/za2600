;==============================================================================
; mzxrules 2023
;==============================================================================
EnMove_Card_WallCheck_TEST: SUBROUTINE
; adjust x coordinate
    txa
    lsr
    lsr
    sta EnMoveNX

; adjust y coordinate
    tya
    lsr
    lsr
    sta EnMoveNY


;==============================================================================
; Computes free spaces, cardinal to position (EnMoveNX, EnMoveNY)
; EnMoveBlockedDir stores all blocked directions
; X = enNum
; Clobbers Y register
;==============================================================================
EnMove_Card_WallCheck: SUBROUTINE
    lda #0
; Check board boundaries
    ldx EnMoveNX
    cpx #[EnBoardXR/4]
    bne .setBlockedL
    ora #EN_BLOCKED_DIR_R
.setBlockedL
    cpx #[EnBoardXL/4]
    bne .setBlockedD
    ora #EN_BLOCKED_DIR_L
.setBlockedD
    ldy EnMoveNY
    cpy #[EnBoardYD/4]
    bne .setBlockedU
    ora #EN_BLOCKED_DIR_D
.setBlockedU
    cpy #[EnBoardYU/4]
    bne .checkPFHit
    ora #EN_BLOCKED_DIR_U
.checkPFHit
    sta EnMoveBlockedDir


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
    ora EnMoveBlockedDir
    sta EnMoveBlockedDir


.dr ; RIGHT (1, 0)
    ldy EnMoveNY
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
    ora EnMoveBlockedDir
    sta EnMoveBlockedDir

.dud
    ; UP   (0,  1)
    ; DOWN (0, -1)

    ldy EnMoveNY
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
    ora EnMoveBlockedDir
    sta EnMoveBlockedDir
.dud2
    lda rPF1RoomL-2 -1,y
    ora rPF1RoomL-1 -1,y
    and room_col8_mask-1,x
    beq .rts
    lda #EN_BLOCKED_DIR_D
    ora EnMoveBlockedDir
    sta EnMoveBlockedDir
    ldx enNum
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
    ora EnMoveBlockedDir
    sta EnMoveBlockedDir
.dud_special_right2
    lda rPF1RoomL-2 -1,y
    ora rPF1RoomL-1 -1,y
    ora rPF2Room-2 -1,y
    ora rPF2Room-1 -1,y
    and #1
    beq .rts
    lda #EN_BLOCKED_DIR_D
    ora EnMoveBlockedDir
    sta EnMoveBlockedDir
.rts
    ldx enNum
    rts


;==============================================================================
; Randomly selects a new cardinal direction
; enNextDir returns new direction
; X = enNum
; Y = enNextDir
;==============================================================================
EnMove_Card_RandDir: SUBROUTINE
    lda #3
    sta EnMoveRandDirCount
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
    sta EnMoveRandDirSeed
    and #3
    tay ; enNextDir
.loop
    lda Bit8,y
    and EnMoveBlockedDir
    beq .select

    dec EnMoveRandDirCount
    bmi .miss
    ldy EnMoveRandDirSeed   ; 3
    ldx nextdir_step_lut,y  ; 4
    stx EnMoveRandDirSeed
    ldy nextdir_lut,x       ; 4
    bpl .loop
.select
.miss
    ldx enNum
    sty enNextDir
    rts

;==============================================================================
; Attempts to select enDir, then if blocked randomly selects cardinal direction
; enNextDir returns new direction
; X = enNum
; Y = enNextDir
;==============================================================================
EnMove_Card_RandDirIfBlocked:
    lda #3
    sta EnMoveRandDirCount
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
    sta EnMoveRandDirSeed   ; 3
    ldy enDir,x
    bpl .loop ; JMP


;==============================================================================
; Selects a new direction based on the shortest path to the player, but only
; If the current path is blocked
; X = enNum
; Y = enNextDir
;==============================================================================
EnMove_Card_SeekDirIfBlocked: SUBROUTINE
    ldy enDir,x
    lda Bit8,y
    and EnMoveBlockedDir
    beq .found_dir

;==============================================================================
; Selects a new direction based on the shortest path to the player
; X = enNum
; Y = enNextDir
;==============================================================================
EnMove_Card_SeekDir:
    lda #0
    sta EnMoveSeekFlags

    lda en0X,x
    sec
    sbc plX
    sta Temp0   ; enX - plX >= 0, left
                ; enX - plX <  0, right

    rol EnMoveSeekFlags
    bit Temp0
    bpl .checkY
    ; negate A
    eor #$FF
    adc #1
    sta Temp0

.checkY
    lda en0Y,x
    sec
    sbc plY
    sta Temp1   ; enY - plY >= 0, down
                ; enY - plY <  0, up

    rol EnMoveSeekFlags
    bit Temp1
    bpl .checkAxis
    ; negate A
    eor #$FF
    adc #1
    sta Temp1

.checkAxis
    lda Temp0
    sec
    sbc Temp1 ; abs(xDelta) - abs(yDelta)
    lda EnMoveSeekFlags
    rol
    asl
    asl
    tax
.loop
    inx
    ldy EnMove_SeekDirLUT-1,x
    lda Bit8,y
    and EnMoveBlockedDir
    bne .loop
.found_dir
    ldx enNum
    sty enNextDir
    rts

EnMove_Card_NewDir: SUBROUTINE
    lda Rand16
    and #2
    bne .contdir_seek
    jmp EnMove_Card_RandDir
.contdir_seek
    jmp EnMove_Card_SeekDir

EnMove_Card_ContDir: SUBROUTINE
    lda Rand16
    and #2
    bne .contdir_seek
    jmp EnMove_Card_RandDirIfBlocked
.contdir_seek
    jmp EnMove_Card_SeekDirIfBlocked

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
    sta Temp0   ; enX - plX >= 0, left
                ; enX - plX <  0, right

    rol EnMoveSeekFlags
    bit Temp0
    bpl .checkY
    ; negate A
    eor #$FF
    adc #1
    sta Temp0

.checkY
    lda en0Y,x
    sec
    sbc plY
    sta Temp1   ; enY - plY >= 0, down
                ; enY - plY <  0, up

    rol EnMoveSeekFlags
    bit Temp1
    bpl .checkAxis
    ; negate A
    eor #$FF
    adc #1
    sta Temp1

.checkAxis
    lda Temp0
    sec
    sbc Temp1 ; abs(xDelta) - abs(yDelta)
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

;==============================================================================
; Applies recoil movement, if applicable
; X = enNum
;==============================================================================
EnMove_Recoil: SUBROUTINE
    lda enStun,x
    bmi .doThings
.end_recoil
    lda enState,x
    and #~EN_ENEMY_MOVE_RECOIL
    sta enState,x
.rts
    rts
.doThings
    cmp #EN_STUN_RT
    bcs .end_recoil
    and #3
    sta Temp0 ; enRecoilDir
    and #2
    bne .recoil_ud
.recoil_lr
    ; if not x grid aligned
    ldy en0Y,x
    lda EnMove_OffgridLUT,y
    bne .end_recoil

    lda enStun,x
    cmp #EN_STUN_TIME1
    bcs .tryMove

    ldy en0X,x
    lda EnMove_OffgridLUT,y
    clc
    adc en0X,x
    sta en0X,x
    rts

.recoil_ud
    ; if not y grid aligned
    ldy en0X,x
    lda EnMove_OffgridLUT,y
    bne .end_recoil

    lda enStun,x
    cmp #EN_STUN_TIME1
    bcs .tryMove

    ldy en0Y,x
    lda EnMove_OffgridLUT,y
    clc
    adc en0Y,x
    sta en0Y,x
    rts

.tryMove
    jsr EnMove_Card_WallCheck
    ldy Temp0
    lda Bit8,y
    and EnMoveBlockedDir
    bne .rts
.moveDel
    lda #8
    clc
    adc Temp0
    tay
    jmp EnMoveDel