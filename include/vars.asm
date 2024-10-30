; ****************************************
; * Variables                            *
; ****************************************
    SEG.U VARS_ZERO
    ORG $80
Frame       ds 1
Rand16      ds 2
KernelId    ds 1
; Object coordinates
plX         ds 1
enX         ds 1
m0X         ds 1
m1X         ds 1
blX         ds 1
plm0X       ds 1
plm1X       ds 1

plY         ds 1
enY         ds 1
m0Y         ds 1
m1Y         ds 1
blY         ds 1
plm0Y       ds 1
plm1Y       ds 1
; ObjectId
OBJ_PL      = 0
OBJ_EN      = 1
OBJ_M0      = 2
OBJ_M1      = 3
OBJ_BL      = 4
OBJ_PLM0    = 5
OBJ_PLM1    = 6

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
roomIdNext  ds 1
roomId      ds 1
roomTimer   ds 1 ; Dungeon Shutter / Room animation timer
roomFlags   ds 1
RF_EV_LOAD      = $80 ; 1000_0000 Force Load Room
RF_EV_LOADED    = $40 ; 0100_0000 Room Load happened this frame
RF_EV_ENCLEAR   = $20 ; 0010_0000 Enemy Clear event
RF_NO_ENCLEAR   = $10 ; 0001_0000 Blocks Enemy Cleared from setting Room Cleared
RF_EV_CLEAR     = $08 ; 0000_1000 Room Cleared (Enemies dead, or puzzle solved)
RF_PF_IGNORE    = $04 ; 0000_0100 Room PF ignored in center room
RF_PF_AXIS      = $02 ; 0000_0010 Room PF triggers axis only movement
RF_USED_CANDLE  = $01 ; 0000_0001 Candle was used this room
roomDoors   ds 1
    ; xxxx_xx11 N
    ; xxxx_11xx S
    ; xx11_xxxx E
    ; 11xx_xxxx W
roomRS      ds 1
roomEN      ds 1 ; encounter table index
roomENCount ds 1 ; num enemies left in encounter
roomEX      ds 1
roomWA      ds 1
blType      ds 1 ;
roomPush    ds 1 ; Room ball state
blDir       ds 1
plState     ds 1 ; ---------------
INPT_FIRE_PREV  = $80 ; 1000_0000 Fire Pressed Last Frame
PS_USE_ITEM     = $40 ; 0100_0000 Use Current Item Event
PS_GLIDE        = $20 ; 0010_0000 Move Until Unblocked
PS_LOCK_MOVE_EN = $10 ; 0001_0000 Lock Player Movement (Enemies)
PS_LOCK_MOVE_IT = $08 ; 0000_1000 Lock Player Movement (Items)
PS_PF_IGNORE    = $04 ; 0000_0100 Playfield Ignore
PS_LOCK_ALL     = $02 ; 0000_0010 Lock Player
PS_LOCK_AXIS    = $01 ; 0000_0001 Lock Player Axis - Hover Boots
plState2    ds 1 ; ---------------
PS_HOLD_ITEM    = $80 ; 1000_0000
EN_LAST_DRAWN   = $40 ; 0100_0000 Current Entity was drawn last frame
                      ; xxxx_1xxx RESERVED
PS_ACTIVE_ITEM  = $07 ; 0000_0111 Mask to fetch current active item
                      ;       000 Sword
                      ;       001 Bombs
                      ;       010 Bow
                      ;       011 Flame
                      ;       100 Flute
                      ;       101 Wand
                      ;       110 Meat?
plState3    ds 1 ; ---------------
PS_ACTIVE_ITEM2 = $07 ; 0000_0111 Mask to fetch current secondary item

plStun      ds 1    ; 1111_1100 ; player stun timer
PL_STUN_TIME = [-30*4] ; Frames of invunerability
PL_STUN_TIME1 = PL_STUN_TIME + 4
PL_STUN_RT   = [-24*4] ; End of recoil time
; plRecoilDir       ; 0000_0011 ; recoil direction
plHealthMax ds 1
plHealth    ds 1 ; $0 exact for gameover, negative for gameover state is init
plItemTimer ds 1
plItem2Time ds 1
ITEM_ANIM_SWORD_STAB_LONG   = -7
ITEM_ANIM_SWORD_STAB_SHORT  = -1
ITEM_ANIM_WAND_STAB_LONG    = -7
ITEM_ANIM_WAND_STAB_SHORT   = -1
ITEM_ANIM_BOMB_DETONATE     = -11 ; Bombs active detonation
ITEM_ANIM_BOMB_BREAKWALL    = -6  ;
ITEM_ANIM_FIRE_BURNBUSH     = -5

plItemDir   ds 1
plItem2Dir  ds 1
                      ; 0000_0011 Attack Direction, most items
PS_CATCH_WIND   = $80 ; 1000_0000 Flute, tornado in on respawn
                      ; 0000_0111 Flute selection index
PauseState  = plItemDir
itemRupees  ds 1
itemKeys    ds 1 ; Sign bit = Master Key
itemBombs   ds 1 ; 1100_0000 = bomb capacity
itemTri     ds 1
itemMaps    ds 1 ; Level 2-9
itemCompass ds 1
itemFlags   ds 3
; ITEMV_name = item var
; ITEMF_name = item flag
    ITEM COMPASS_1,     0,$01
    ITEM MAP_1,         0,$02
    ITEM SHIELD,        0,$04
    ITEM FLUTE,         0,$08
    ITEM MEAT,          0,$10
    ITEM SWORD1,        0,$20
    ITEM SWORD2,        0,$40
    ITEM SWORD3,        0,$80

    ITEM WAND,          1,$01
    ITEM BOOK,          1,$02
    ITEM RANG,          1,$04
    ITEM RAFT,          1,$08
    ITEM BOOTS,         1,$10
    ITEM BRACELET,      1,$20
    ITEM RING_BLUE,     1,$40
    ITEM RING_RED,      1,$80

    ITEM BOW,           2,$01
    ITEM ARROW,         2,$02
    ITEM ARROW_SILVER,  2,$04
    ITEM CANDLE_BLUE,   2,$08
    ITEM CANDLE_RED,    2,$10
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
SFX_NEW =   $80 ; 1xxx_xxxx New Sfx
SfxCur      ds 1
SeqSolveCur ds 1 ; Plays secret seq when negative
SEQ_SOLVE_DUR = $B8

;==============================================================================
; Entity Variables
;==============================================================================

; System Reserve Vars
enNum       ds 1
EN_START:
enType      ds 2
miType      ds 2
en0X        ds 1
en1X        ds 1
EN_NPC_FREE1:
mi0X        ds 1
mi1X        ds 1
en0Y        ds 1
en1Y        ds 1
EN_NPC_FREE2:
mi0Y        ds 1
mi1Y        ds 1
EN_ZERO:    ; Zero initialized memory
EN_FREE:    ds 18
    EN_SIZE FREE_MAX
enState     ds 2
EN_END:

EN_ZERO_SIZE    = EN_END - EN_ZERO
EN_FREE_SIZE    = EN_END - EN_FREE
EN_SIZE         = EN_END - EN_START

; -----------------
;  Class NPC
; -----------------
    ORG EN_NPC_FREE1
mesgId      ds 1
npcType     ds 1
    ORG EN_NPC_FREE2
mesgDY      ds 1
mesgLength  ds 1

    ORG EN_FREE
mesgChar    ds 6
MESG_MAX_LENGTH = 24
npcIncRupee ds 1
npcDecRupee ds 1
CLASS_EN_NPC

; -----------------
; Class ENEMY_SPAWN
; -----------------
    ORG EN_FREE
enSysType   ds 2
enSysTimer  ds 2

; -----------------
; Class ENEMY
; -----------------
    ORG EN_FREE
; enState
EN_ENEMY_MOVE_RECOIL = $20 ; triggers recoil movement
enDir       ds 2
mi0Dir      ds 1
mi1Dir      ds 1
enHp        ds 2
enStun      ds 2    ; 1111_1100 ; enemy stun timer, manhandla HP
EN_STUN_TIME = [-32*4] ; Frames of invunerability
EN_STUN_TIME1 = EN_STUN_TIME + 4
EN_STUN_RT   = [-24*4] ; End of recoil time
; enRecoilDir       ; 0000_0011 ; recoil direction
CLASS_EN_ENEMY
; Missile Vars
mi0Xf       ds 1
mi1Xf       ds 1
mi0Yf       ds 1
mi1Yf       ds 1
CLASS_EN_BOSS_SHOOT

;==============================================================================
; Entity Variables - NPC
;==============================================================================

; == Gameover
    ORG CLASS_EN_NPC
enInputDelay ds 1

; == En_NpcAppear
; == En_NpcShop
; == En_NpcGiveOne
    ORG CLASS_EN_NPC
; enState
NPC_INIT        = $80 ; 1xxx_xxxx Init
NPC_ITEM_GOT    = $40 ; x1xx_xxxx Item Bought
NPC_CAVE        = $20 ; xx1x_xxxx Determines roomEX and item fanfare
GI_EVENT_CD     = $10 ; xxx1_xxxx
GI_EVENT_TRI    = $08 ; xxxx_1xxx
GI_EVENT_INIT   = $04 ; xxxx_x1xx
GI_EVENT_RESERVED = $3C
NPC_SPR_MAN     = 0   ; xxxx_xx11 Sprite
NPC_SPR_WOMAN   = 1
NPC_SPR_SHOP    = 2
NPC_SPR_MONSTER = 3
shopPrice   ds 3
shopRoom    ds 1
npcTimer    ds 1 ; xxxx_xx11 Draw if 0
CLASS_NPC_SHOP_COMMON
shopItem    ds 3
    EN_SIZE NPC_SHOP

    ORG CLASS_NPC_SHOP_COMMON
Rng2State   ds 5
NpcGamePrizeTable = Temp2
NpcRupeeDelta     = Temp3
    EN_SIZE NPC_GAME

; == En_ItemGet
; == En_Item
    ORG CLASS_EN_NPC
; enState
CD_UPDATE_B     = $80 ; 1xxx_xxxx
CD_UPDATE_A     = $40 ; x1xx_xxxx
                      ; xx11_11xx GI_EVENT reserved
CD_LAST_UPDATE  = $01 ; Stores last update's active entity
cdItemType  ds 2
cdItemTimer ds 2
    EN_SIZE ITEM

; == En_Stairs
cdStairType ds 2
cdStairPos  ds 2
    EN_SIZE STAIRS

; == Great Fairy
    ORG CLASS_EN_NPC
; enState
;           ; 1xxx_xxxx init
;           ; x1xx_xxxx heal event
enGFairyDie ds 1

;==============================================================================
; Entity Variables - ENEMY
;==============================================================================

; == Base Enemy
; Darknut, Gibdo, Lynel, Octorok, Stalfos
    ORG CLASS_EN_ENEMY
enEnemyStep         ds 2
enEnemySpdFrac      ds 2
enEnemyShootT       ds 2
enEnemyType         ds 2
    EN_SIZE DARKNUT

; == Armos
    ORG CLASS_EN_ENEMY
enEnemyStep         ds 2
enArmosType         ds 2
enArmosHpTemp   = Temp0
    EN_SIZE ARMOS

; == Wallmaster
    ORG CLASS_EN_ENEMY
enWallCount         ds 2 ;
enWallPhase         ds 2 ; anim timer for phasing through wall
enWallTimer         ds 2
    EN_SIZE WALLMASTER

; == Leever
    ORG CLASS_EN_ENEMY
enLeeverTimer       ds 2
enLeeverSpdFrac     ds 2
enLeeverPlX     = Temp0
enLeeverPly     = Temp1
enLeeverTryX    = Temp2
enLeeverTryY    = Temp3
    EN_SIZE LEEVER

; == Goriya
    ORG CLASS_EN_ENEMY
enGoriyaThink       ds 2
enGoriyaStep        ds 2
    EN_SIZE GORIYA

; == LikeLike
    ORG CLASS_EN_ENEMY
enLLTimer           ds 2
enLLThink           ds 2
    EN_SIZE LIKE_LIKE

; == Rope
    ORG CLASS_EN_ENEMY
enRopeTimer         ds 2
enRopeThink         ds 2
    EN_SIZE ROPE

; == Vire
    ORG CLASS_EN_ENEMY
enVireStep          ds 2
enVireShiftY        ds 2
enVireBounceTimer   ds 2
    EN_SIZE VIRE

; == Keese
    ORG CLASS_EN_ENEMY
; enHp
enKeeseThink    ds 2
enKeeseTemp     = Temp0
enKeeseHpTemp   = Temp1
    EN_SIZE KEESE

; == Zol
    ORG CLASS_EN_ENEMY
enZolStep       ds 2
enZolStepTimer  ds 2
    EN_SIZE ZOL

; == Gel
    ORG CLASS_EN_ENEMY
enGelAnim       ds 2
enGelStep       ds 4
enGelStepTimer  ds 4
enGelNum        = Temp0
enGelEnState    = Temp1
enGelHpTemp     = Temp0
enGelTemp       = Temp1
    EN_SIZE GEL

; == Peehat
    ORG CLASS_EN_ENEMY
; enHp
enPeehatVel         ds 2
enPeehatSpeedFrac   ds 2
enPeehatThink       ds 2
enPeehatFlyThink    ds 2
    EN_SIZE PEEHAT

; == Tektite
    ORG CLASS_EN_ENEMY
enTektiteThink      ds 2
enTektiteBounceTime ds 2
enTektiteBounce     ds 2
enTektiteShiftY     ds 2

; == Rolling Rocks
    ORG CLASS_EN_ENEMY
enRollingRockTimer  ds 2
enRollingRockSize   ds 2
    EN_SIZE ROLLING_ROCK

; == Boss Don
    ORG CLASS_EN_ENEMY
enDonStep           ds 2
enDonSpdFrac        ds 2
enDonTimer          ds 2
enDonTemp           = Temp0

;==============================================================================
; Entity Variables - BOSS
;==============================================================================

; == Gohma
    ORG CLASS_EN_BOSS_SHOOT
; enState
                        ; 1xxx_xxxx = init
                        ; xxxx_x111 = animation state
                        ; xxxx_1xxx = RESERVED
GOHMA_ANIM_0    = $00
GOHMA_ANIM_1    = $02
GOHMA_ANIM_2    = $04
enGohmaTimer ds 1
    EN_SIZE BOSS_GOHMA

; == Glock (Trinexx)
    ORG CLASS_EN_BOSS_SHOOT
enGlockTimer        ds 1
enGlockThink        ds 1
enGlockNeck         ds 1
enGlockHeadDir      ds 1
enGlockHeadThink    ds 1
    EN_SIZE BOSS_GLOCK

; == Aqua
    ORG CLASS_EN_BOSS_SHOOT
enAquaTimer         ds 1
enAquaThink         ds 1
enAquaMoveTimer     ds 1
    EN_SIZE BOSS_AQUA

; == Manhandla
    ORG CLASS_EN_BOSS_SHOOT
enManhandlaTimer    ds 1
enManhandlaSpdFrac  ds 1
enManhandlaHitFlags ds 1
enManhandlaStun     ds 1
enManhandlaInvince  ds 1
    EN_SIZE BOSS_MANHANDLA

; == Test
    ORG EN_FREE + 2
enTestDir   ds 1
enTestFX    ds 1
enTestFY    ds 1
enTestTimer ds 1

; == TestMissile
    ORG CLASS_EN_ENEMY
enTestMissileType   ds 2
enTestMissileResult ds 2
enTestMissileTimer  ds 1
enTestMissileCount  ds 1

; == TestColor
    ORG CLASS_EN_NPC
enTestColorBoard    ds 1
enTestColorEn       ds 1
enTestColorEnColor  ds 1
enTestColorPlColor  ds 1

    ORG EN_END

;==============================================================================

; Kernel_World temps
KERNEL_TEMP ds 6
    ORG KERNEL_TEMP
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

    SEG.U VARS_ENDRAW
    ORG Temp0
EnDrawColor ds 1

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
    ORG AUDVT1 + 1
PFrame          ds 1
PAnim           ds 1

    ORG plSpr
PItemSpr0       ds 2
    ORG enSpr
PItemSpr1       ds 2
    ORG KERNEL_TEMP
PItemSpr2       ds 2
PItemColors     ds 4
    ORG KERNEL_TEMP
PMapDrawTemp0   ds 1
PMapDrawTemp1   ds 1
    ORG KERNEL_TEMP
PMapRoomVisit   ds 1
PMapRoomN       ds 1
PMapRoomS       ds 1
PMapRoomE       ds 1
PMapRoomW       ds 1
PMapRoom        ds 1

    ORG Temp0 + 1
PCursorLast     ds 1
PCursor         ds 1
PMapY           ds 1
    ORG Temp0 + 1
PItemSpr3       ds 2
PGiItems        ds 4

    SEG.U VARS_HUD_ZERO
    ORG Temp0
THudMapSpr      ds 2
THudMapPosY     ds 1
THudMapCPosY    ds 1
THudHealthMaxL  ds 1
THudHealthL     ds 1
THudHealthMaxH  ds 1
THudHealthH     ds 1
THudDigits      ds 6
THudHealthDisp  = THudHealthMaxH
; == 14 ==

    SEG.U VARS_ROOMSCROLL
    ORG EN_FREE ; safe space since entity system is not live
roomScrollDY    ds 1
roomScrollTemp = Temp0

    SEG.U VARS_EN_SYS
    ORG Temp0 + 1
EnSysSpawnTry       ds 1
EnSysSpawnX         ds 1
EnSysSpawnY         ds 1

    SEG.U VARS_EN_MOV
    ORG Temp0 + 2
EN_MOVE
EnMoveRandDirSeed   ds 1
EnMoveRandDirCount  ds 1
    ORG EN_MOVE
EnMoveSeekFlags     ds 1
EnMoveNX            ds 1
EnMoveNY            ds 1
EnMoveBlockedDir    ds 1
EnMoveOrdBoardXR = EnMoveBlockedDir
EnMoveNextDir       ds 1
EnMoveTemp0         ds 1
EnMoveTemp1         ds 1

    SEG.U VARS_HB_SYS
    ORG Temp0 + 2
HbDamage        ds 1
HB_DMG_SWORD1   = 0
HB_DMG_SWORD2   = 1
HB_DMG_SWORD3   = 2
HB_DMG_ARROW    = 3
HB_DMG_FIRE     = 4
HB_DMG_BOMB     = 5
HB_DMG_BOMB_LIT = 7 ; EN_BOSS_DON specific

HbPlFlags       ds 1
HB_PL_SWORD     = $01
HB_PL_ARROW     = $02
HB_PL_FIRE      = $04
HB_PL_BOMB      = $08
HB_PL_WAVE      = $10
HB_PL_WAND      = $20
HB_PL_SWORDFX   = $40
HB_PL_RANG      = $80
HbFlags2        ds 1
HB_BOX_HIT      = $80
HbDir           ds 1
Hb_aa_Box       ds 1
Hb_aa_x         ds 1
Hb_aa_y         ds 1
Hb_bb_x         ds 1
Hb_bb_y         ds 1

    SEG.U VARS_MI_SYS
    ORG Temp0
MiSysEnNum      ds 1
MiSysDir        ds 1
MiSysDX         ds 1
MiSysDY         ds 1
MiSysColDX      ds 1
MiSysColDY      ds 1
MiSysColFlag    ds 1
atan2Temp       ds 1

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

; ****************************************
; * Level Data ROM Banks                 *
; ****************************************

    ORG $F400
WORLD_T_PF1L    ds 128
WORLD_T_PF1R    ds 128
WORLD_T_PF2     ds 128
WORLD_WA        ds 128 ; Extended wall properties
WORLD_COLOR     ds 128
WORLD_RS        ds 128 ; Room Script
WORLD_EX        ds 128 ; Extra Data (Exits, Items)
WORLD_EN        ds 128 ; Enemy Encounter

; ****************************************
; * Extended RAM 0-2 - World Data        *
; ****************************************
    SEG.U VARS_RAM
    ORG $F800
 RW RAM_SEG, = .
 RW KERNEL_WORLD,       ds KERNEL_WORLD_LEN
 RW PF1RoomL,           ds ROOM_PX_HEIGHT
 RW PF2Room,            ds ROOM_PX_HEIGHT
 RW PF1RoomR,           ds ROOM_PX_HEIGHT
 RW RoomColorFlags,     ds 1
RF_WC_ROOM_BOOT = $80
RF_WC_ROOM_DARK = $40
 RW RoomENFlags,        ds 1
 RW RoomPF2Type,        ds 1
 ROOM_PF2 TRIFORCE, 35

 RW HaltKernelDraw,     ds 2
 RW HaltKernelId,       ds 1
 RW HaltVState,         ds 1 ; negative is Vertical Blank, else Overscan
HALT_VSTATE_TOP = #$80
 RW HaltFrame,          ds 1
 RW HaltType,           ds 1
HALT_TYPE_RSCR_NONE     = 0
HALT_TYPE_RSCR_WEST     = 1
HALT_TYPE_RSCR_EAST     = 2
HALT_TYPE_RSCR_NORTH    = 3
HALT_TYPE_RSCR_SOUTH    = 4
HALT_TYPE_PLAY_FLUTE         = 5
HALT_TYPE_ENTER_DUNG    = 6
HALT_TYPE_ENTER_CAVE    = 7
 RW HaltTask,           ds 1
 RW HaltWorldDY,        ds 1
RW_WORLD        = .

    ORG $F900
 RW WorldRoomENCount,   ds 128
 RW WorldRoomFlags,     ds 128

    ; rWorldRoomFlags all world types
WRF_SV_ITEM_GET = $80 ; 1xxx_xxxx Got Item
WRF_SV_VISIT    = $20 ; xx1x_xxxx Visited Room
WRF_SV_ENKILL   = $08 ; xxxx_1xxx Enemy Cleared
    ; overworld only
WRF_SV_DESTROY  = $40 ; x1xx_xxxx
    ; dungeons only
WRF_SV_OPEN_N    = $01 ; xxxx_xxx1 N open
WRF_SV_OPEN_S    = $04 ; xxxx_x1xx S open
WRF_SV_OPEN_E    = $10 ; xxx1_xxxx E open
WRF_SV_OPEN_W    = $40 ; x1xx_xxxx W open

; ****************************************
; * Extended RAM - Pause Bank 3          *
; ****************************************
PAUSE_MAP_HEIGHT = 40

    ORG $F000
 RW MAP_0,      ds PAUSE_MAP_HEIGHT
 RW MAP_1,      ds PAUSE_MAP_HEIGHT
 RW MAP_2,      ds PAUSE_MAP_HEIGHT
 RW MAP_3,      ds PAUSE_MAP_HEIGHT
 RW MAP_4,      ds PAUSE_MAP_HEIGHT
 RW MAP_5,      ds PAUSE_MAP_HEIGHT

; ****************************************
; * Extended RAM 4 - KERNEL48            *
; ****************************************
    ORG $F400
 RW KERNEL48,   ds KERNEL48_LEN

; ****************************************
; * Extended RAM 5 - RoomScroll          *
; ****************************************
    SEG.U VARS_RAM
    ORG $F000
 RW PF_SCROLLA, ds ROOM_PX_HEIGHT
 RW PF_SCROLLB, ds ROOM_PX_HEIGHT
    ORG $F002
; Offsetting these by 2 allows transfer
; logic to shave off cycles
 RW PF1_0A,     ds ROOM_PX_HEIGHT
 RW PF1_0B,     ds ROOM_PX_HEIGHT
 RW PF2_0A,     ds ROOM_PX_HEIGHT
 RW PF2_0B,     ds ROOM_PX_HEIGHT
 RW PF0_1A,     ds ROOM_PX_HEIGHT
 RW PF0_1B,     ds ROOM_PX_HEIGHT
 RW PF1_1A,     ds ROOM_PX_HEIGHT
 RW PF1_1B,     ds ROOM_PX_HEIGHT
 RW PF2_1A,     ds ROOM_PX_HEIGHT
 RW PF2_1B,     ds ROOM_PX_HEIGHT

    ORG $F100
 RW COLUPF_A,   ds ROOM_PX_HEIGHT
 RW COLUPF_B,   ds ROOM_PX_HEIGHT
 RW COLUBK_A,   ds ROOM_PX_HEIGHT
 RW COLUBK_B,   ds ROOM_PX_HEIGHT
