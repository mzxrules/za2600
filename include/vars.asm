; ****************************************
; * Variables                            *
; ****************************************
    SEG.U VARS_ZERO
    ORG $80
Frame       ds 1
Rand16      ds 2
KernelId    ds 1
plX         ds 1
enX         ds 1
m0X         ds 1
m1X         ds 1
blX         ds 1
plY         ds 1
enY         ds 1
m0Y         ds 1
m1Y         ds 1
blY         ds 1

; KERNEL VARS
; ENH
; M0H
; M1H
; BLH
; NUSIZ0_T   ds 1
; NUSIZ1_T   ds 1
; BgColor    ds 1
; FgColor    ds 1
; PlColor    ds 1
; EnColor    ds 1

plXL        ds 1
plYL        ds 1
plSpr       ds 2 ; plSprOff
enSpr       ds 2 ; enSprOff
plDir       ds 1

worldId     ds 1
worldSX     ds 1 ; respawn X
worldSY     ds 1 ; respawn Y / Rs_Maze state
worldSR     ds 1 ; respawn room / Rs_Maze init
roomId      ds 1
roomTimer   ds 1 ; Shutter animation timer
roomFlags   ds 1
RF_EV_LOAD      = $80 ; 1000_0000 Force Load Room
RF_EV_LOADED    = $40 ; 0100_0000 Room Load happened this frame
RF_EV_ENCLEAR   = $20 ; 0010_0000 Enemy Clear event
RF_NO_ENCLEAR   = $10 ; 0001_0000 Blocks Enemy Cleared from setting Room Cleared
RF_EV_CLEAR     = $08 ; 0000_1000 Room Cleared (Enemies dead, or puzzle solved)
RF_PF_IGNORE    = $04 ; 0000_0100 Room PF ignored in center room
RF_PF_AXIS      = $02 ; 0000_0010 Room PF triggers axis only movement
RF_PF_DARK      = $01 ; 0000_0001 Room is dark
roomDoors   ds 1
    ; xxxx_xx11 N
    ; xxxx_11xx S
    ; xx11_xxxx E
    ; 11xx_xxxx W
roomRS      ds 1
roomEN      ds 1 ; encounter type
roomENCount ds 1 ; num encounters
roomEX      ds 1
roomWA      ds 1
blType      ds 1 ;
roomPush    ds 1 ; Room ball state
blDir       ds 1
plState     ds 1
INPT_FIRE_PREV  = $80 ; 1000_0000 Fire Pressed Last Frame
PS_USE_ITEM     = $40 ; 0100_0000 Use Current Item Event
PS_GLIDE        = $20 ; 0010_0000 Move Until Unblocked
PS_LOCK_MOVE    = $10 ; 0001_0000 Lock Player Movement
PS_P1_WALL      = $08 ; 0000_1000 P1 Is Wall
PS_PF_IGNORE    = $04 ; 0000_0100 Playfield Ignore
PS_LOCK_ALL     = $02 ; 0000_0010 Lock Player
PS_LOCK_AXIS    = $01 ; 0000_0001 Lock Player Axis - Hover Boots
plState2    ds 1
PS_HOLD_ITEM    = $80 ; 1000_0000
                      ; xxxx_1xxx RESERVED
PS_ACTIVE_ITEM  = $07 ; 0000_0111 Mask to fetch current active item
                      ;       000 Sword
                      ;       001 Bombs
                      ;       010 Bow
                      ;       011 Flame
                      ;       100 Flute
                      ;       101 Wand
                      ;       110 Meat?
plStun      ds 1
plHealthMax ds 1
plHealth    ds 1 ; $0 exact for gameover, negative for gameover state is init
plItemTimer ds 1

ITEM_ANIM_SWORD_STAB_LONG   = -7
ITEM_ANIM_SWORD_STAB_SHORT  = -1
ITEM_ANIM_BOMB_DETONATE     = -11 ; Bombs active detonation
ITEM_ANIM_BOMB_BREAKWALL    = -6  ;
plItemDir   ds 1
                      ; 0000_0011 Attack Direction, most items
                      ; 1000_0000 Flute, tornado in on respawn
                      ;
    ORG plItemDir
PauseState  ds 1
itemRupees  ds 1
itemKeys    ds 1 ; Sign bit = Master Key
itemBombs   ds 1
itemTri     ds 1
itemMaps    ds 1 ; Level 2-9
itemFlags   ds 3
; ITEMV_name = item var
; ITEMF_name = item flag
    ITEM SHIELD,        0,$10
    ITEM SWORD1,        0,$20
    ITEM SWORD2,        0,$40
    ITEM SWORD3,        0,$80

    ITEM BOW,           1,$01
    ITEM RAFT,          1,$02
    ITEM BOOTS,         1,$04
    ITEM FLUTE,         1,$08
    ITEM FIRE_MAGIC,    1,$10
    ITEM BRACELET,      1,$20
    ITEM RING_BLUE,     1,$40
    ITEM RING_RED,      1,$80

    ITEM ARROW,         2,$01
    ITEM ARROW_SILVER,  2,$02
    ITEM CANDLE_BLUE,   2,$04
    ITEM CANDLE_RED,    2,$08
    ITEM MEAT,          2,$10
    ITEM NOTE,          2,$20
    ITEM POTION_BLUE,   2,$40
    ITEM POTION_RED,    2,$80

SeqFlags    ds 1
    ; 1xxx_xxxx New Sequence
    ; 11xx_xxxx Play Region Sequence
    ; xxx1_xxxx Reserved for sequence's second channel
    ; xxxx_1111 Sequence
SeqTFrame   ds 2
SeqCur      ds 2
SfxFlags    ds 1
    ; 1xxx_xxxx New Sfx
SfxCur      ds 1

;==============================================================================
; Entity Variables
;==============================================================================
enNum       ds 1
enType      ds 2
en0X        ds 2
en0Y        ds 2
EN_VARS:    ds 16 ; Zero initialized entity vars
EN_VARS_END:
EN_VARS_COUNT = EN_VARS_END - EN_VARS

    ORG EN_VARS
enState     ds 2
EN_NPC_VARIABLES:
; EnShopkeeper enState
                      ; 1xxx_xxxx Init
                      ; x1xx_xxxx Item Bought
GI_EVENT_CAVE   = $20 ; xx1x_xxxx
GI_EVENT_CD     = $10 ; xxx1_xxxx
GI_EVENT_TRI    = $08 ; xxxx_1xxx
GI_EVENT_INIT   = $04 ; xxxx_x1xx
mesgId      ds 1
; Gameover
enInputDelay ds 1
    ORG EN_NPC_VARIABLES + 1
; EnShopkeeper
shopItem    ds 3
shopDigit   ds 3

    ORG EN_NPC_VARIABLES
; En_ClearDrop and En_ItemGet
;enState
CD_UPDATE_B     = $80 ; 1xxx_xxxx
CD_UPDATE_A     = $40 ; x1xx_xxxx
                      ; xx11_11xx GI_EVENT reserved
CD_LAST_UPDATE  = $01 ; Stores last update's active entity
cdBTimer    ds 1
cdAType     ds 1 ; EnType value for ClearDrop, GiItem for ItemGet
cdBType     ds 1 ; GiItem value for ClearDrop, Timer for ItemGet Tri
CD_ITEM_RAND = $FF
cdAX        ds 1
cdBX        ds 1
cdAY        ds 1
cdBY        ds 1

    ORG EN_NPC_VARIABLES
; Great Fairy
;enstate    ; 1xxx_xxxx init
;           ; x1xx_xxxx heal event
enGFairyDie ds 1

; EnemyCommon
    ORG EN_VARS + 2
enNX        ds 2
enNY        ds 2
enHp        ds 2
enStun      ds 2
enDir       ds 2

EN_ENEMY_VARIABLES:
    ORG EN_ENEMY_VARIABLES
; Darknut
enDarknutTemp
                ; xx1x_xxxx = new direction toggle
    ORG EN_ENEMY_VARIABLES
; Wallmaster
enWallPhase ds 1 ; anim timer for phasing through wall
enPX        ds 1 ; posX last frame, after collision check
enPY        ds 1 ; posY last frame, after collision check
    ORG EN_ENEMY_VARIABLES
; Octorok
enOctorokThink  ds 2
enMDX           ds 1
enMDY           ds 1
    ORG EN_ENEMY_VARIABLES
; LikeLike
enLLTimer   ds 1
    ORG EN_ENEMY_VARIABLES
; Rope
enRopeTimer ds 2
enRopeThink ds 2
    ORG EN_ENEMY_VARIABLES
; Gohma
;enState     ds 1
                        ; 1xxx_xxxx = init
                        ; xxxx_x111 = animation state
                        ; xxxx_1xxx = RESERVED
GOHMA_ANIM_0    = $00
GOHMA_ANIM_1    = $02
GOHMA_ANIM_2    = $04
enGohmaTimer ds 1

; Test
    ORG EN_VARS + 1
enTestDir   ds 1
enTestFX    ds 1
enTestFY    ds 1
enTestTimer ds 1

    ORG EN_VARS_END

;==============================================================================

; Missile Vars
mAType      ds 1
mBType      ds 1
mAx         ds 1
mBx         ds 1
mAxf        ds 1
mBxf        ds 1
mAy         ds 1
mBy         ds 1
mAyf        ds 1
mByf        ds 1
mADir       ds 1
mBDir       ds 1
mATimer     ds 1
mBTimer     ds 1

atan2Temp   ds 1

; Kernel_World temps
plDY        ds 1
enDY        ds 1
m0DY        ds 1
m1DY        ds 1
blDY        ds 1
roomDY      ds 1

; Context Temp Vars
Temp0       ds 1
Temp1       ds 1
Temp2       ds 1
Temp3       ds 1
Temp4       ds 1
Temp5       ds 1
TRoomSprB   ds 1 ; LoadRoom sprite bank

    SEG.U VARS_AUD_ZERO
    ORG Temp0 + 1
AUDCT0      ds 1
AUDCT1      ds 1
AUDFT0      ds 1
AUDFT1      ds 1
AUDVT0      ds 1
AUDVT1      ds 1

    SEG.U VARS_PAUSE
; Pause perms must come after VARS_AUD_ZERO temps
    ORG plSpr
PItemSpr0       ds 2
    ORG enSpr
PItemSpr1       ds 2
    ORG plDY
PItemSpr2       ds 2
PItemColors     ds 4
    ORG Temp0 + 1
PCursorLast     ds 1
PCursor         ds 1
    ORG Temp0 + 1
PItemSpr3       ds 2
PGiItems        ds 4

PFrame          ds 1
PAnim           ds 1

    SEG.U VARS_HUD_ZERO
    ORG Temp0
THudMapSpr      ds 2
THudMapPosY     ds 1
THudHealthMaxL  ds 1
THudHealthL     ds 1
THudHealthMaxH  ds 1
THudHealthH     ds 1
THudTemp        ds 1
THudDigits      ds 6
    ORG THudHealthMaxH
THudHealthDisp  ds 1
; == 14 ==

    SEG.U VARS_EN_SYS
    ORG Temp0 + 1
;Temp0          ds 1
EnSysSpawnTry   ds 1
EnSysNext       ds 1
EnSysClearOff   ds 1 ; offset to byte that room clear is stored at
EnSysClearMask  ds 1 ; stores bitmask for room clear flag
EnSysBlockedDir ds 1 ; blocked direction
enNextDir       ds 1
EnSysNextDirSeed    ds 1
EnSysNextDirCount   ds 1
EnSysNX         ds 1
EnSysNY         ds 1

    SEG.U VARS_HB_SYS
    ORG Temp0 + 1
HbDamage        ds 1
HB_DMG_SWORD1   = 0
HB_DMG_SWORD2   = 1
HB_DMG_SWORD3   = 2
HB_DMG_ARROW    = 3
HB_DMG_FIRE     = 4
HB_DMG_BOMB     = 5

HbFlags         ds 1
HB_PL_SWORD     = $01
HB_PL_ARROW     = $02
HB_PL_FIRE      = $04
HB_PL_BOMB      = $08
HB_PL_WAVE      = $10
HB_PL_WAND      = $20
Hb_aa_Box       ds 1
Hb_aa_x         ds 1
Hb_aa_y         ds 1
Hb_bb_x         ds 1
Hb_bb_y         ds 1

    SEG.U VARS_MI_SYS
    ORG Temp0
MiSysDir        ds 1
MiSysDX         ds 1
MiSysDY         ds 1
MiSysAddType    ds 1
MiSysAddX       ds 1
MiSysAddY       ds 1

    SEG.U VARS_SHOP_KERNEL
    ORG Temp0
ShopSpr0    ds 2
ShopSpr1    ds 2
ShopSpr2    ds 2
ShopDrawY   ds 1

    SEG.U VARS_TEXT_ZERO
    ORG Temp0
TextLoop    ds 1
TMesgPtr    ds 2
TextTemp    ds 1
TextReg     ds 12

    echo "-RAM-",$80,(.)
    ORG $FE
PauseSp     ds 2

; Level Data Banks 1 and 2

    ORG $F400
WORLD_T_PF1L    ds 128
WORLD_T_PF1R    ds 128
WORLD_T_PF2     ds 128
WORLD_WA        ds 128 ; Extended wall properties
WORLD_COLOR     ds 128
WORLD_RS        ds 128 ; Room Script
WORLD_EX        ds 128 ; Extra Data (Exits, Items)
WORLD_EN        ds 128 ; Enemy Encounter

; Ram Bank 0
    SEG.U VARS_RAM
    ORG $FA00
wRAM_SEG
wKERNEL     ds KERNEL_LEN
wPF1RoomL   ds ROOM_PX_HEIGHT
wPF2Room    ds ROOM_PX_HEIGHT
wPF1RoomR   ds ROOM_PX_HEIGHT
wRoomClear  ds 256/8            ; All Enemies Defeated flags
    ORG $FB00
wRoomFlag   ds 256

    ORG $F800
rRAM_SEG
rKERNEL     ds KERNEL_LEN
rPF1RoomL   ds ROOM_PX_HEIGHT
rPF2Room    ds ROOM_PX_HEIGHT
rPF1RoomR   ds ROOM_PX_HEIGHT
rRoomClear  ds 256/8            ; All Enemies Defeated flags
    ORG $F900
rRoomFlag   ds 256
    ; all world types
RF_SV_ITEM_GET  = $80 ; 1xxx_xxxx Got Item
    ; overworld only
RF_SV_DESTROY   = $40 ; x1xx_xxxx
    ; dungeons only
    ; xxxx_xxx1 N open
    ; xxxx_x1xx S open
    ; xxx1_xxxx E open
    ; x1xx_xxxx W open

; ****************************************
; * Constants                            *
; ****************************************

KERNEL_LEN  = $90   ; World Kernel length

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
EnBoardXL = BoardXL+8
EnBoardXR = BoardXR-8
EnBoardYU = BoardYU-8
EnBoardYD = BoardYD+8

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

    COLOR UNDEF,        $00,$00
    COLOR BLACK,        $00,$00
    COLOR DARK_GRAY,    $02,$06
    COLOR GRAY,         $06,$0C
    COLOR WHITE,        $0E,$0E

    COLOR EN_RED,       $42,$64
    COLOR EN_BLUE,      $74,$B4
    COLOR EN_ROK_BLUE,  $72,$C4
    COLOR EN_LIGHT_BLUE,$88,$D8 ; Item secondary flicker
    COLOR EN_TRIFORCE,  $2A,$2A
    COLOR EN_BROWN,     $F0,$22

    COLOR PLAYER_00,    $C6,$58
    COLOR PLAYER_01,    $0E,$0E
    COLOR PLAYER_02,    $46,$64

    COLOR PATH,         $3C,$4C
    COLOR GREEN_ROCK,   $D0,$52
    COLOR RED_ROCK,     $42,$64
    COLOR CHOCOLATE,    $F0,$22
    COLOR LIGHT_WATER,  $AE,$9E

    COLOR DARK_BLUE,    $90,$C0
    COLOR LIGHT_BLUE,   $86,$D6 ; World
    COLOR DARK_PURPLE,  $60,$A2
    COLOR PURPLE,       $64,$A6
    COLOR DARK_TEAL,    $B0,$72
    COLOR LIGHT_TEAL,   $B2,$74
    COLOR SACRED,       $1E,$2E ; No good PAL equivalent

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

; Segment Constants
RAMSEG_F0 = $00
RAMSEG_F4 = $40
RAMSEG_F8 = $80
RAMSEG_FC = $C0

BANK_SLOT_RAM   = $3E
BANK_SLOT       = $3F

SLOT_MAIN   = RAMSEG_FC | 1
SLOT_PAUSE  = RAMSEG_FC | 2

SLOT_PF_A   = RAMSEG_F4 | 4
SLOT_PF_B   = RAMSEG_F4 | 5
SLOT_SPR_A  = RAMSEG_F0 | 6
SLOT_SPR_A2 = RAMSEG_F4 | 6

SLOT_W0     = RAMSEG_F4 | 12
SLOT_W1     = RAMSEG_F4 | 13
SLOT_W2     = RAMSEG_F4 | 14

SLOT_RW0    = RAMSEG_F8 | 0
SLOT_RW1    = RAMSEG_F8 | 1
SLOT_RW2    = RAMSEG_F8 | 2

SLOT_SH     = RAMSEG_F0 | 18
SLOT_DRAW   = RAMSEG_F4 | 19
SLOT_TX     = RAMSEG_F0 | 20
SLOT_MG     = RAMSEG_F4 | 8 ; Requires bank divisible by 4

SLOT_ROOM   = RAMSEG_F0 | 21

SLOT_EN_A   = RAMSEG_F0 | 22
SLOT_EN_B   = RAMSEG_F4 | 23

SLOT_AU_A   = RAMSEG_F0 | 24
SLOT_AU_B   = RAMSEG_F4 | 25

SLOT_RS_A   = RAMSEG_F0 | 26
SLOT_RS_B   = RAMSEG_F4 | 27

SLOT_PU_A   = RAMSEG_F0 | 28
SLOT_EN_D   = RAMSEG_F0 | 28

SLOT_RS_INIT = RAMSEG_F0 | 29

SLOT_PL     = RAMSEG_F0 | 30
SLOT_DRAW_PAUSE_WORLD = RAMSEG_F4 | 31
SLOT_DRAW_PAUSE_2 = RAMSEG_F4 | 32

SLOT_BATTLE = RAMSEG_F0 | 33

SEG_SH = SLOT_SH
SEG_34 = RAMSEG_F4 | 34
SEG_35 = RAMSEG_F4 | 35
SEG_NA = SLOT_MAIN