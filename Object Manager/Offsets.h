//
//  Offsets.h
//  Object Manager
//
//  Created by tropic on 06/11/13.
//  Copyright (c) 2013 Wauw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Offsets : NSObject

// THIS FILE IS FOR FUTURE IMPLEMENTATION
//
// OFFSET FOR 5.4.1 17538

enum eGeneral {
    WoWVersion                  = 0x0,
    Build                       = 17538
};

enum eObjectManager {
    objMgrPointer               = 0x16D594C,
    FirstObject                 = 0xCC,
    NextObject                  = 0x30,
    LocalGUID                   = 0x0
};

enum eObject {
    Type                        = 0x0,
    GUID                        = 0x0,
    DynamicFlags                = 0x0,
    EntryID                     = 0x0
};

enum eUnitBaseFields {
    NamePointer                 = 0x0,
    NameOffset                  = 0x0,

    BaseField_Level             = 0x0,
    BaseField_CurrentHealth     = 0x0,
    BaseField_MaxHealth         = 0x0,
    BaseField_CurrentMana       = 0x0,
    BaseField_MaxMana           = 0x0,
    
    BaseField_Faction           = 0x0,
    
    BaseField_XLocation         = 0x828,
    BaseField_YLocation         = BaseField_XLocation+4,
    BaseField_ZLocation         = BaseField_YLocation+4,
    BaseField_Facing_Horizontal = BaseField_ZLocation+4,
    BaseField_Facing_Vertical   = BaseField_Facing_Horizontal+4,
    
    BaseField_RunSpeed_Current  = 0x0,
    BaseField_RunSpeed_Walk     = 0x0,
    BaseField_RunSpeed_Max      = 0x0,
    BaseField_RunSpeed_Back     = 0x0,
    BaseField_AirSpeed_Max      = 0x0,
};

enum ePlayerClass {
    ClassNone                   = 0,
    Warrior                     = 1,
    Paladin                     = 2,
    Hunter                      = 3,
    Rogue                       = 4,
    Priest                      = 5,
    DeathKnight                 = 6,
    Shaman                      = 7,
    Mage                        = 8,
    Warlock                     = 9,
    Druid                       = 11,
};

enum eObjectType {
    Item                        = 1,
    Container                   = 2,
    Unit                        = 3,
    Player                      = 4,
    GameObject                  = 5,
    DynamicObject               = 6,
    Corpse                      = 7,
    AiGroup                     = 8,
    AreaTrigger                 = 9
};

enum eUnitDynamicFlags {
    Invisible                   = 0x0,
    Dead                        = 0x0,
    IsTappedByAllThreatList     = 0x0,
    Lootable                    = 0x0,
    None                        = 0x0,
    ReferAFriendLinked          = 0x0,
    SpecialInfo                 = 0x0,
    TaggedByMe                  = 0x0,
    TaggedByOther               = 0x0,
    TrackUnit                   = 0x0,
};

@end
