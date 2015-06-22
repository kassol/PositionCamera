//
//  SettingsItem.m
//  PositionCamera
//
//  Created by 张旭 on 15/6/14.
//  Copyright (c) 2015年 3lang. All rights reserved.
//

#import "SettingsItem.h"

@implementation SettingsItem

-(instancetype) initWithItemName:(NSString *)name
{
    self = [super init];
    if (self) {
        _itemName = name;
    }
    
    return self;
}

@end
