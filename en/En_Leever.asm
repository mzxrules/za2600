;==============================================================================
; mzxrules 2024
;==============================================================================
EN_LEEVER_TYPE_RED = $0
EN_LEEVER_TYPE_BLUE = $1
EN_LEEVER_TYPE_MASK = $1

EN_LEEVER_STATE_HIDDEN  = %0000
EN_LEEVER_STATE_DIRT    = %0010
EN_LEEVER_STATE_RISE50  = %0100
EN_LEEVER_STATE_RISEFUL = %0110
EN_LEEVER_STATE_EMERGED = %1000
EN_LEEVER_STATE_MASK    = %1110

En_LeeverDelay:
    .byte -0, -30

En_Leever: SUBROUTINE
    lda enState,x
    bmi En_LeeverRedMain
    lda #EN_LEEVER_TYPE_RED | $80
    sta enState,x
    lda En_LeeverDelay,x
    sta enLeeverTimer,x
    lda #2-1
    sta enHp,x
    rts

En_LeeverRedSpawn: SUBROUTINE
    lda enLeeverTimer,x
    cmp #1
    adc #0
    sta enLeeverTimer,x
    bne .rts
; Get player pos, aligned to enemy movement grid
    ldy plY
    iny
    iny
    tya
    and #~3
    sta enLeeverPly
    ldy plX
    iny
    iny
    tya
    and #~3
    sta enLeeverPlX
    lda plDir
    jsr En_LeeverGetSpawnTryXY
    bpl .do_spawn
    lda plDir
    eor #1
    jsr En_LeeverGetSpawnTryXY
    bmi .rts

.do_spawn
    lda enState,x
    and #~#EN_LEEVER_STATE_MASK
    ora #EN_LEEVER_STATE_DIRT
    sta enState,x
    lda enLeeverTryX
    sta en0X,x
    lda enLeeverTryY
    sta en0Y,x
    lda #-8
    sta enLeeverTimer,x
; if the other enemy is a red leever, stagger it's spawn
    txa
    eor #1
    tax
    lda enType,x
    cmp #EN_LEEVER
    bne .rts
    lda enState,x
    and #EN_LEEVER_STATE_MASK
    bne .rts
    lda #-30
    sta enLeeverTimer,x
.rts
    rts

En_LeeverRedMain: SUBROUTINE
    and #EN_LEEVER_STATE_MASK
    beq En_LeeverRedSpawn

; update state
    jsr En_LeeverUpdateState

    lda enState,x
    and #EN_LEEVER_STATE_RISE50
    beq .endCheckHit

; check damaged
    lda #SLOT_F0_BATTLE
    sta BANK_SLOT
    jsr HbCheckDamaged_CommonRecoil

    lda #SLOT_F0_EN
    sta BANK_SLOT
    lda enHp,x
    bpl .endCheckDamaged
    jmp EnSys_KillEnemyB
.endCheckDamaged

; Check player hit
    lda enStun,x
    bmi .endCheckHit
    bit plState2
    bvc .endCheckHit ; EN_LAST_DRAWN
    bit CXPPMM
    bpl .endCheckHit
    lda #-4
    jsr UPDATE_PL_HEALTH
.endCheckHit

; Movement
    lda #SLOT_F0_EN_MOVE
    sta BANK_SLOT

; update EnMoveNX/NY
    lda en0X,x
    lsr
    lsr
    sta EnMoveNX
    lda en0Y,x
    lsr
    lsr
    sta EnMoveNY

; check recoil movement
    lda enState,x
    and #EN_ENEMY_MOVE_RECOIL
    beq .normal_movement
    jmp EnMove_Recoil

.normal_movement
    lda enState,x
    and #EN_LEEVER_STATE_MASK
    eor #EN_LEEVER_STATE_RISEFUL | #EN_LEEVER_STATE_EMERGED
    bne .rts

    ldy en0X,x
    lda EnMove_OffgridLUT,y
    bne .move
    ldy en0Y,x
    lda EnMove_OffgridLUT,y
    bne .move

    jsr EnMove_Card_WallCheck
    ldy enDir,x
    lda Bit8,y
    and EnMoveBlockedDir
    beq .move
; sink into the ground
    lda enState,x
    and #~#EN_LEEVER_STATE_MASK
    ora #EN_LEEVER_STATE_RISE50 | #EN_LEEVER_STATE_EMERGED
    sta enState,x
    rts

.move
    lda enLeeverSpdFrac,x
    clc
    adc #$60
    sta enLeeverSpdFrac,x
    bcc .rts
    jsr EnMoveDir
.rts
    rts

En_LeeverUpdateState: SUBROUTINE
    lda enLeeverTimer,x
    cmp #1
    adc #0
    sta enLeeverTimer,x
    bne .endUpdateState

    lda enState,x
    and #EN_LEEVER_STATE_MASK
    lsr
    tay
    lda enState,x
    and #~#EN_LEEVER_STATE_MASK
    ora En_LeeverStateNext,y
    sta enState,x
    and #EN_LEEVER_STATE_MASK
    eor #EN_LEEVER_STATE_RISEFUL | #EN_LEEVER_STATE_EMERGED
    beq .endUpdateState
    ldy #-8
    sty enLeeverTimer,x
.endUpdateState
    rts

; A = direction
; returns N = 0 if success, N = 1 if failed
En_LeeverGetSpawnTryXY: SUBROUTINE
    tay
    eor #1
    sta enDir,x
    lda enLeeverPlX
    clc
    adc EnLeeverCheckSpawnDeltaX,y

    cmp #EnBoardXL
    bcc .no_go
    cmp #EnBoardXR+1
    bcs .no_go
    sta enLeeverTryX

    lda enLeeverPly
    clc
    adc EnLeeverCheckSpawnDeltaY,y
    cmp #EnBoardYD
    bcc .no_go
    cmp #EnBoardYU+1
    bcs .no_go
    sta enLeeverTryY
    tay
    ldx enLeeverTryX
    jsr CheckRoomCol
    bne .no_go2
    ldx enNum
    rts

.no_go2
    ldx enNum

.no_go
    lda #$FF
    rts

En_LeeverBlue: SUBROUTINE
    lda enState,x
    bmi En_LeeverBlueMain
    lda #EN_LEEVER_TYPE_BLUE | #$80 | #EN_LEEVER_STATE_RISEFUL
    sta enState,x
    lda #4-1
    sta enHp,x

    jsr Random
    and #$38
    bne .setTimer
    lda #$38
.setTimer
    ora #$C0
    sta enLeeverTimer,x
    rts

En_LeeverBlueFastMove: SUBROUTINE
    lda #SLOT_F0_EN_MOVE
    sta BANK_SLOT

    lda en0X,x
    lsr
    lsr
    sta EnMoveNX
    lda en0Y,x
    lsr
    lsr
    sta EnMoveNY

    ldy en0X,x
    lda EnMove_OffgridLUT,y
    bne .move1
    ldy en0Y,x
    lda EnMove_OffgridLUT,y
    bne .move1

    jsr EnMove_Card_WallCheck
    jsr EnMove_Card_RandDir
    sty enDir,x
    tya
    ora #$8 ; move at 4x speed
    tay
    jmp EnMoveDel
.move1
    jmp EnMoveDir

En_LeeverBlueMain: SUBROUTINE
; update state
    jsr En_LeeverUpdateState
    lda enState,x
    ;and #EN_LEEVER_STATE_MASK
    bne En_LeeverBlueFastMove

    rts

En_LeeverStateNext:
    ; 0000
    .byte 0
    ; 0010
    .byte #EN_LEEVER_STATE_RISE50
    ; 0100
    .byte #EN_LEEVER_STATE_RISEFUL | #EN_LEEVER_STATE_EMERGED
    ; 0110
    .byte #EN_LEEVER_STATE_RISEFUL | #EN_LEEVER_STATE_EMERGED
    ; 1000
    .byte #EN_LEEVER_STATE_RISEFUL | #EN_LEEVER_STATE_EMERGED
    ; 1010
    .byte #EN_LEEVER_STATE_HIDDEN
    ; 1100
    .byte #EN_LEEVER_STATE_DIRT | #EN_LEEVER_STATE_EMERGED
    ; 1110
    .byte #EN_LEEVER_STATE_RISEFUL | #EN_LEEVER_STATE_EMERGED

EnLeeverCheckSpawnDeltaX:
    .byte -24,  24,  0,  0 ; cardinals

EnLeeverCheckSpawnDeltaY:
    .byte  0,  0,  24, -24 ; cardinals