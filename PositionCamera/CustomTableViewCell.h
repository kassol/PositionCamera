//
//  CustomTableViewCell.h
//  PositionCamera
//
//  Created by 张旭 on 15/6/14.
//  Copyright (c) 2015年 3lang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>
#import "SettingsItem.h"

@interface CustomTableViewCell : UITableViewCell
@property(nonatomic, retain) SettingsItem* settingItem;
- (void)changeStyle;
@end
