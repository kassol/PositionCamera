//
//  ProViewController.h
//  PositionCamera
//
//  Created by 张旭 on 15/6/10.
//  Copyright (c) 2015年 3lang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>

@interface ProViewController : UIViewController<DJIDroneDelegate, DJICameraDelegate, DJIMainControllerDelegate, UITableViewDataSource, UITableViewDelegate>
{
    DJIDrone* _drone;
    DJIInspireCamera* mInspireCamera;
    UIView* videoPreviewView;
    
    DJICameraSystemState* mCameraSystemState;
    DJICameraPlaybackState* mCameraPlaybackState;
    CameraWorkMode mLastWorkMode;
    
    id<DJINavigation> _navigation;
}

@end
