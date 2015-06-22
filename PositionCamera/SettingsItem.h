//
//  SettingsItem.h
//  PositionCamera
//
//  Created by 张旭 on 15/6/14.
//  Copyright (c) 2015年 3lang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingsItem : NSObject
@property(nonatomic, retain) NSMutableArray* subSettings;
@property(nonatomic, retain) NSString* itemName;
@property(nonatomic, retain) NSValue* itemValue;
@property(nonatomic, assign) SEL itemAction;
@property(nonatomic, assign) BOOL isSubItem;

-(id) initWithItemName:(NSString*)name;
@end
