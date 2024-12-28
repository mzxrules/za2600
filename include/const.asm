; ****************************************
; * Constants                            *
; ****************************************

KERNEL_WORLD_LEN = $A9 ; World Kernel length
KERNEL48_LEN     = $68 ; 48 pix kernel length

CV_LV_START     = #CV_END_LIST+1
LV_MIN          = $6E ; lowest worldId value

ROOM_PX_HEIGHT      = 20 ; height of room in pixels
ROOM_SPR_HEIGHT     = 16 ; height of room sprite sheet
ROOM_SPR_SHEET      = 16 ; width of room sprite sheet in 8 bit sprites
ROOM_HEIGHT         = [(8*ROOM_PX_HEIGHT)/2-1] ; Screen visible height of play
TEXT_ROOM_PX_HEIGHT = 16 ; height of room in pixels, when text is displayed
TEXT_ROOM_HEIGHT    = [(8*TEXT_ROOM_PX_HEIGHT)/2-1] ;
SHOP_ROOM_PX_HEIGHT = 13 ; height of room in pixels
SHOP_ROOM_HEIGHT    = [(8*SHOP_ROOM_PX_HEIGHT)/2-1] ;
GRID_STEP           = 4 ; unit grid that the player should snap to
MAX_LOCKS           = 16

BoardXL = $04
BoardXR = $7C
BoardYU = $50
BoardYD = $08
BoardXC = [BoardXL + BoardXR] / 2 ; $40
BoardYC = [BoardYU + BoardYD] / 2 ; $2C
EnBoardXL = BoardXL+8 ; $0C
EnBoardXR = BoardXR-8 ; $74
EnBoardYU = BoardYU-8 ; $48
EnBoardYD = BoardYD+8 ; $10

; U/D, pX $3C-$44
; L/R, pY $28-$30
BoardDungDoorNSX = $3C ; leftmost plX to pass N/S door check
BoardDungDoorEWY = $28 ; bottom plY to pass E/W door check
BoardDungDoorNY = $48+1
BoardDungDoorSY = $10-1
BoardDungDoorWX = $0C-1
BoardDungDoorEX = $74+1

; BombWall dimensions
; check wall at frame ITEM_ANIM_BOMB_BREAKWALL
; N wall, y >= $45. x mid is $41 so +-12?
; S wall, y <= $13
; E wall, x >= $76. y mid is $2C so +-12?
; W wall, x <= $10
BoardBreakwallNSX1 = $35      ; leftmost m0X for N/S breakwall
BoardBreakwallNSX2 = $35 + 24 ; rightmost m0X for N/S breakwall
BoardBreakwallEWY1 = $20      ; bottom most m0Y for E/W breakwall
BoardBreakwallEWY2 = $20 + 24 ; top most    m0Y for E/W breakwall
BoardBreakwallNY = $45
BoardBreakwallSY = $13
BoardBreakwallWX = $10
BoardBreakwallEX = $76


;ItemTimerSword  =  ; counts up to 0

; Color Index
CI_EN_RED       = 0
CI_EN_GREEN     = 2
CI_EN_BLUE      = 4
CI_EN_YELLOW    = 6
CI_EN_WHITE     = 8
CI_EN_BLACK     = 10

    COLOR UNDEF,        $00,$00
    COLOR BLACK,        $00,$00
    COLOR WHITE,        $0E,$0E

    COLOR PLAYER_00,    $C6,$58
    COLOR PLAYER_01,    $AE,$9A
    COLOR PLAYER_02,    $46,$66

    COLOR EN_RED,       $44,$64
    COLOR EN_RED_L,     $4A,$6A
    COLOR EN_GREEN,     $DA,$5C
    COLOR EN_BLUE,      $74,$B4
    COLOR EN_BLUE_L,    $8C,$BC
    COLOR EN_YELLOW,    $24,$24
    COLOR EN_YELLOW_L,  $2A,$2A

    COLOR EN_BLACK,     $00,$00
    COLOR EN_GRAY_D,    $02,$06
    COLOR EN_GRAY_L,    $06,$0C
    COLOR EN_WHITE,     $0E,$0E

    COLOR EN_ROK_BLUE,  $72,$C4
    COLOR EN_LIGHT_BLUE,$88,$D8 ; Item secondary flicker
    COLOR EN_TRIFORCE,  $2A,$2A
    COLOR EN_BROWN,     $F0,$22

    COLOR PF_BLACK,     $00,$00
    COLOR PF_GRAY_D,    $02,$06
    COLOR PF_GRAY_L,    $06,$0C
    COLOR PF_WHITE,     $0E,$0E

    COLOR PF_PATH,      $3C,$4C
    COLOR PF_GREEN,     $D0,$52
    COLOR PF_RED,       $40,$60
    COLOR PF_CHOCOLATE, $F0,$22
    COLOR PF_WATER,     $7C,$BA

    COLOR PF_BLUE_D,    $90,$C0
    COLOR PF_BLUE_L,    $86,$D6 ; World
    COLOR PF_PURPLE_D,  $60,$A2
    COLOR PF_PURPLE,    $64,$A6
    COLOR PF_TEAL_D,    $B0,$72
    COLOR PF_TEAL_L,    $B2,$74
    COLOR PF_SACRED,    $1E,$2E ; No good PAL equivalent

    COLOR MINIMAP,      $84,$08 ; Different colors
    COLOR HEALTH,       $46,$64

MS_PLAY_NONE    = $80
MS_PLAY_DUNG    = $81
MS_PLAY_GI      = $82
MS_PLAY_OVER    = $83
MS_PLAY_THEME   = $84 ; Overworld Theme with intro
MS_PLAY_THEME_L = $85 ; Overworld Theme without intro
MS_PLAY_RSEQ    = $40 | MS_PLAY_THEME   ; Plays region local sequence
MS_PLAY_RSEQ_L  = $40 | MS_PLAY_THEME_L ; Plays region local sequence
MS_PLAY_FINAL   = $86
MS_PLAY_TRI     = $87

; ATAN2 Lookup Constants
ATAN2_SIGNX     = $80
ATAN2_SIGNY     = $40
DEG_000         = $01
DEG_090         = $08
DEG_180         = DEG_000 | ATAN2_SIGNX
DEG_270         = DEG_090 | ATAN2_SIGNY

ROOM_MAZE_1 = $1B
ROOM_MAZE_2 = $61


; ****************************************
; * Segment Constants                    *
; ****************************************

RAMSEG_F0 = $00
RAMSEG_F4 = $40
RAMSEG_F8 = $80
RAMSEG_FC = $C0

; Slot registers
BANK_SLOT_RAM   = $3E
BANK_SLOT       = $3F

SLOT_FC_IDENT   = $FFFF ; not consistently used

SLOT_FC_MAIN    = RAMSEG_FC | 1
SLOT_FC_PAUSE   = RAMSEG_FC | 2
SLOT_FC_HALT    = RAMSEG_FC | 3

SLOT_F4_MESG        = RAMSEG_F4 | 4 ; Requires bank divisible by 4
SLOT_F4_MAIN_DRAW   = RAMSEG_F4 | 8
SLOT_F0_TEXT        = RAMSEG_F0 | 9
SLOT_F0_SHOP        = RAMSEG_F0 | 10

SLOT_F0_ROOM    = RAMSEG_F0 | 11
SLOT_F4_ROOM2   = SEG_55

SLOT_F4_PF_OVER = RAMSEG_F4 | 12
SLOT_F4_PF_DUNG = RAMSEG_F4 | 13
SLOT_F0_SPR0    = RAMSEG_F0 | 14
SLOT_F4_SPR0    = RAMSEG_F4 | 14
SLOT_F0_SPR1    = RAMSEG_F0 | 15
SLOT_F0_SPR2    = RAMSEG_F0 | 16
SLOT_F0_SPR_HUD = RAMSEG_F0 | 17
SLOT_F4_SPR_HUD = RAMSEG_F4 | 17

SLOT_F4_W0      = RAMSEG_F4 | 18
SLOT_F4_W1      = RAMSEG_F4 | 19
SLOT_F4_W2      = RAMSEG_F4 | 20
SLOT_F4_W3      = RAMSEG_F4 | 21
SLOT_F4_W4      = RAMSEG_F4 | 22
SLOT_F4_W5      = RAMSEG_F4 | 23

SLOT_F4_PAUSE_DRAW_WORLD    = RAMSEG_F4 | 24
SLOT_F4_PAUSE_DRAW_MENU1    = RAMSEG_F4 | 24
SLOT_F4_PAUSE_DRAW_MENU2    = RAMSEG_F4 | 25
SLOT_F0_PAUSE_MENU_MAP      = RAMSEG_F0 | 26
SLOT_F4_PAUSE_MENU_MAP      = RAMSEG_F4 | 26

SLOT_F4_ROOMSCROLL          = RAMSEG_F4 | 27
SLOT_F4_ROOMSCROLL_WE       = RAMSEG_F4 | 55
SEG_HRB_ENTER_LOC           = RAMSEG_F4 | 55
SEG_HRT_FLUTE               = RAMSEG_F4 | 55

SLOT_F4_PLDRAW  = RAMSEG_F4 | 28
SLOT_F0_PL      = RAMSEG_F0 | 29
SLOT_F4_PL2     = RAMSEG_F4 | 30

SLOT_F0_EN      = RAMSEG_F0 | 31
SLOT_F0_ENDRAW  = RAMSEG_F0 | 32
SLOT_F0_PU      = RAMSEG_F0 | 32
SLOT_F0_RS_INIT = RAMSEG_F0 | 33
SLOT_F0_RS0     = RAMSEG_F0 | 34
SLOT_F4_RS1     = RAMSEG_F4 | 35
SLOT_F4_RS_DEST = RAMSEG_F4 | 35

SLOT_F0_AU0     = RAMSEG_F0 | 36
SLOT_F4_AU1     = RAMSEG_F4 | 37
SLOT_F0_AU2     = RAMSEG_F0 | 38

SLOT_F0_BATTLE  = RAMSEG_F0 | 39
SLOT_F0_EN_MOVE = RAMSEG_F0 | 40
SLOT_F0_MISSILE = RAMSEG_F0 | 41
SLOT_F0_EN_MOVE2 = RAMSEG_F0 | 51

; En Segments
SEG_NA = SLOT_FC_MAIN
SEG_HA = SLOT_FC_HALT
SEG_SH = SLOT_F0_SHOP
SEG_42 = RAMSEG_F4 | 42
SEG_43 = RAMSEG_F4 | 43
SEG_44 = RAMSEG_F4 | 44
SEG_45 = RAMSEG_F4 | 45
SEG_46 = RAMSEG_F4 | 46
SEG_47 = RAMSEG_F4 | 47
SEG_48 = RAMSEG_F4 | 48
SEG_49 = RAMSEG_F4 | 49
SEG_50 = RAMSEG_F4 | 50
SEG_52 = RAMSEG_F4 | 52
SEG_53 = RAMSEG_F4 | 53

SEG_55 = RAMSEG_F4 | 55


SLOT_RW_F8_W0   = RAMSEG_F8 | 0
SLOT_RW_F8_W1   = RAMSEG_F8 | 1
SLOT_RW_F8_W2   = RAMSEG_F8 | 2

SLOT_RW_F0_DUNG_MAP = RAMSEG_F0 | 3

SLOT_RW_F0_KERNEL48 = RAMSEG_F0 | 4
SLOT_RW_F4_KERNEL48 = RAMSEG_F4 | 4
SLOT_RW_F8_KERNEL48 = RAMSEG_F8 | 4
SLOT_RW_FC_KERNEL48 = RAMSEG_FC | 4

SLOT_RW_F0_ROOMSCROLL = RAMSEG_F0 | 5
