;==============================================================================
; mzxrules 2024
;==============================================================================

.WorldData_BankOffset:
    REPEAT 6
    .byte 1, 4
    REPEND
    REPEAT 3
    .byte 2, 5
    REPEND
    .byte 0, 3

.WorldData_WorldRomSlot:
    .byte #SLOT_F4_W0, #SLOT_F4_W1, #SLOT_F4_W2
    .byte #SLOT_F4_W3, #SLOT_F4_W4, #SLOT_F4_W5