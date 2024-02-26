;==============================================================================
; mzxrules 2024
;==============================================================================
En_NpcGame: SUBROUTINE
    lda #SEG_SH
    sta BANK_SLOT
    ldx roomEX
    bit enState
    bvs .game_end
    bmi En_NpcGameMain

.init
    lda #0
    sta npcIncRupee
    sta npcDecRupee

.init_money_game
    ldy #2
.loop_seedRng2
    lda Frame,y
    sta Rng2State,y
    dey
    bpl .loop_seedRng2

    lda #1
    sta KernelId
    lda #[#NPC_INIT | #NPC_SPR_MAN]
    sta enState
    rts

.game_end
    jmp NpcShop_UpdateRupees

En_NpcGameMain: SUBROUTINE
    jsr Rng2
; TODO Implement rupee check
    jsr En_NpcShopGetSelction
    cpx #-1
    beq .rts
    jmp En_NpcGame_PlayGame
.rts
    rts

; X = Selected Slot
En_NpcGame_PlayGame: SUBROUTINE
    stx Temp1 ; selected item
    jsr Rng2
    ldy #3
    cmp #0
    beq .select_triple
    dey
    cmp #$55+1
    bcc .select_triple
    dey
    cmp #$AA+1
    bcc .select_triple
    dey
.select_triple
    jsr Rng2
    ror
    and #3
    tax ; win/lose value
    tya
    rol
    sta Temp0 ; reward pattern
    asl
    clc
    adc Temp0 ; index * 3
    sta Temp0 ; reward pattern offset

; configure reward lookup table
    lda En_NpcGame_WinPrize,x
    sta NpcGamePrizeTable + 0
    lda En_NpcGame_LosPrize,x
    sta NpcGamePrizeTable + 1
    lda #MONEY_PRIZE_LOS_S
    sta NpcGamePrizeTable + 2
    lda #$00
    sta NpcGamePrizeTable + 3

.set_prize
    lda Temp0
    clc
    adc #3
    sbc Temp1
    tay
    lda En_NpcGame_PrizePattern,y
    bne .lose_reward
.win_reward
    lda NpcGamePrizeTable
    sta npcIncRupee
    bpl .init_game_results
.lose_reward
    tax
    lda NpcGamePrizeTable,x
    sta npcDecRupee


.init_game_results
    ldy #2

.loop_init_game_results
    lda #GI_RUPEE
    sta shopItem,y
    ldx Temp0
    lda En_NpcGame_PrizePattern,x
    tax
    lda En_NpcGame_PrizeSymbol,x
    sta mesgChar+3,y
    lda NpcGamePrizeTable,x
    sta shopPrice,y
    inc Temp0
    dey
    bpl .loop_init_game_results

    lda #[#NPC_INIT | #NPC_ITEM_GOT | #NPC_CAVE | #NPC_SPR_MAN]
    sta enState
    lda #2
    sta KernelId
    rts

    include "c/rng2.asm"

; Money Game possibilities
MONEY_WIN = 0
MONEY_LOS = 1
MONEY_N10 = 2
MONEY_NON = 3

MONEY_PRIZE_WIN_S = $10
MONEY_PRIZE_WIN_B = $25
MONEY_PRIZE_LOS_S = $05
MONEY_PRIZE_LOS_B = $20

En_NpcGame_PrizePattern:
    .byte MONEY_WIN, MONEY_N10, MONEY_LOS
    .byte MONEY_N10, MONEY_WIN, MONEY_LOS

    .byte MONEY_WIN, MONEY_LOS, MONEY_N10
    .byte MONEY_LOS, MONEY_WIN, MONEY_N10

    .byte MONEY_N10, MONEY_LOS, MONEY_WIN
    .byte MONEY_LOS, MONEY_N10, MONEY_WIN

    .byte MONEY_NON, MONEY_NON, MONEY_NON
    .byte MONEY_NON, MONEY_NON, MONEY_NON

En_NpcGame_WinPrize:
    .byte #MONEY_PRIZE_WIN_S, #MONEY_PRIZE_WIN_B
    .byte #MONEY_PRIZE_WIN_S, #MONEY_PRIZE_WIN_B
En_NpcGame_LosPrize:
    .byte #MONEY_PRIZE_LOS_S, #MONEY_PRIZE_LOS_S
    .byte #MONEY_PRIZE_LOS_B, #MONEY_PRIZE_LOS_B

En_NpcGame_PrizeSymbol:
    .byte MESG_CHAR_PLUS
    .byte MESG_CHAR_MINUS
    .byte MESG_CHAR_MINUS
    .byte MESG_CHAR_SPACE