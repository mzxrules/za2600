;==============================================================================
; mzxrules 2024
;==============================================================================
En_NpcGiveOne: SUBROUTINE
    lda #SEG_SH
    sta BANK_SLOT

    ldx roomEX
    ldy shopRoom
    lda rWorldRoomFlags,y
    bpl .skip_SetItemGet ; WRF_SV_ITEM_GET
; player already has item
    lda #NPC_INIT | #NPC_ITEM_GOT
    sta enState
.skip_SetItemGet

    bit enState
    bvs .rts ; #NPC_ITEM_GOT
    bmi .main ; #NPC_INIT

.init
    lda #[#NPC_INIT | #NPC_SPR_MAN]
    sta enState

.main
    bit CXPPMM
    bpl .rts
    cpx #CV_RUPEES100
    bcc .maxHealthTest
.rupee
    lda NpcGiveOneData-#CV_SWORD1,x
    jsr AddRupees
    bne .give_item ; jmp
.maxHealthTest
    lda plHealthMax
    cmp NpcGiveOneData-#CV_SWORD1,x
    bcc .rts
.give_item
    lda rWorldRoomFlags,y
    ora #WRF_SV_ITEM_GET
    sta wWorldRoomFlags,y
; Trigger ItemGet
    lda #[#NPC_INIT | #NPC_ITEM_GOT | #NPC_CAVE | #NPC_SPR_MAN]
    sta enState

    lda #0
    sta KernelId
    lda NpcGiveOneItems-#CV_SWORD1,x
    sta cdAType
    jmp ItemGet

.rts
    rts

NpcGiveOneItems:
    .byte GI_SWORD1
    .byte GI_SWORD2
    .byte GI_SWORD3
    .byte GI_NOTE
    .byte GI_RUPEE
    .byte GI_RUPEE
    .byte GI_RUPEE


NpcGiveOneData:
; plHealthMax requirements
    .byte #0
    .byte #5*8
    .byte #12*8
    .byte #0
; secret rupee amounts minus 1
    .byte $39 ; $40 -> Rupee100
    .byte $11 ; $12 -> Rupee30
    .byte $04 ; $05 -> Rupee10