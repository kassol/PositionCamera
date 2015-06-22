//
//  SettingViewController.h
//  PositionCamera
//
//  Created by 张旭 on 15/6/14.
//  Copyright (c) 2015年 3lang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>
#import "CustomTableViewCell.h"
#import "SettingsItem.h"



@interface SettingViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray* _mainSettingItems;
    SettingsItem* _selectedItem;
    DJICamera* _camera;
    
    CameraRecordingFovType _fovType;
    CameraRecordingResolutionType _resolutionType;
}


@property(nonatomic, assign) CameraCaptureMode captureMode;

-(void) setCamera:(DJICamera*)camera;

@end
