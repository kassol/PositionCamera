//
//  ProViewController.m
//  PositionCamera
//
//  Created by 张旭 on 15/6/10.
//  Copyright (c) 2015年 3lang. All rights reserved.
//

#import "ProViewController.h"
#import "VideoPreviewer.h"
#import "LogTableViewCell.h"
#import "YawView.h"
#import "SettingViewController.h"

#define REFRESH_TIME 0.04

#define DeviceSystemVersion ([[[UIDevice currentDevice] systemVersion] floatValue])
#define iOS8System (DeviceSystemVersion >= 8.0)

#define SCREEN_WIDTH  (iOS8System ? [UIScreen mainScreen].bounds.size.width : [UIScreen mainScreen].bounds.size.height)
#define SCREEN_HEIGHT (iOS8System ? [UIScreen mainScreen].bounds.size.height : [UIScreen mainScreen].bounds.size.width)

@interface ProViewController ()
@property (nonatomic, weak) DJIInspireGimbal *mGimbal;
@property (weak, nonatomic) DJIInspireCamera* camera;
@property (weak, nonatomic) IBOutlet UITableView *logView;
@property (nonatomic) BOOL isStarted;
@property (nonatomic, strong) NSMutableArray *logList;
@property (nonatomic) BOOL isBigTask;
@property (weak, nonatomic) IBOutlet UILabel *yawLabel;
@property (weak, nonatomic) IBOutlet YawView *yawView;
@property (nonatomic, strong) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UILabel *cameraLabel;
@property (weak, nonatomic) IBOutlet UILabel *rotateLabel;
@property (nonatomic) int cameraDuration;
@property (nonatomic) int rotateDuration;
@property (nonatomic) float altitude;
@property (weak, nonatomic) IBOutlet UILabel *altitudeLabel;
@property (nonatomic) BOOL isConnected;

@end

@implementation ProViewController
{
    int originYaw;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.logView.delegate = self;
    self.logView.dataSource = self;
    self.logList = [[NSMutableArray alloc] init];
    _drone = [[DJIDrone alloc] initWithType:DJIDrone_Inspire];
    _drone.delegate = self;
    _drone.camera.delegate = self;
    _drone.mainController.mcDelegate = self;
    self.mGimbal = (DJIInspireGimbal *)_drone.gimbal;
    self.camera = (DJIInspireCamera *)_drone.camera;
    
    
    _navigation = (id<DJINavigation>)_drone.mainController;
    
    mInspireCamera = (DJIInspireCamera*)_drone.camera;
    
    mLastWorkMode = CameraWorkModeUnknown;
    
    videoPreviewView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.view addSubview:videoPreviewView];
    [self.view sendSubviewToBack:videoPreviewView];
    videoPreviewView.backgroundColor = [UIColor grayColor];
    [[VideoPreviewer instance] start];
    self.isStarted = NO;
    self.isBigTask = NO;
    self.isConnected = NO;
    [self.yawView setCurrentYaw:-1800];
    self.cameraDuration = 2;
    self.rotateDuration = 3;
    self.altitude = 0;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:REFRESH_TIME target:self selector:@selector(elapse) userInfo:nil repeats:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [[VideoPreviewer instance] setView:videoPreviewView];
    [_drone connectToDrone];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [_drone.camera startCameraSystemStateUpdates];
    [_drone.mainController startUpdateMCSystemState];
}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [_drone.camera stopCameraSystemStateUpdates];
    [_drone.mainController stopUpdateMCSystemState];
    
    [_drone disconnectToDrone];
    [_drone destroy];
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - DJIDroneDelegate

-(void) droneOnConnectionStatusChanged:(DJIConnectionStatus)status
{
    if (status == ConnectionSuccessed) {
        self.isConnected = YES;
    } else {
        self.isConnected = NO;
    }
}


#pragma mark - DJICameraDelegate

-(void) camera:(DJICamera*)camera didReceivedVideoData:(uint8_t*)videoBuffer length:(int)length
{
    uint8_t* pBuffer = (uint8_t*)malloc(length);
    memcpy(pBuffer, videoBuffer, length);
    [[[VideoPreviewer instance] dataQueue] push:pBuffer length:length];
}

-(void) camera:(DJICamera*)camera didUpdateSystemState:(DJICameraSystemState*)systemState
{
}


-(void) camera:(DJICamera *)camera didUpdatePlaybackState:(DJICameraPlaybackState *)playbackState
{
}

-(void) camera:(DJICamera *)camera didGeneratedNewMedia:(DJIMedia *)newMedia
{
    NSLog(@"GenerateNewMedia:%@",newMedia.mediaURL);
}

#pragma mark - DJIMainControllerDelegate

-(void) mainController:(DJIMainController*)mc didMainControlError:(MCError)error
{
    
}

-(void) mainController:(DJIMainController*)mc didUpdateSystemState:(DJIMCSystemState*)state
{
    self.altitude = [state altitude];
}

- (IBAction)plusButtonDidTouch:(id)sender {
    if (!self.isConnected) {
        NSString *message = @"未连接至飞机";
        [self.logList insertObject:message atIndex:0];
        [self.logView reloadData];
        return;
    }
    DJIGimbalRotation pitch = {YES, 150, RelativeAngle, RotationForward};
    DJIGimbalRotation roll = {NO, 0, RelativeAngle, RotationForward};
    DJIGimbalRotation yaw = {YES, 0, RelativeAngle, RotationForward};
    [self.mGimbal setGimbalPitch:pitch Roll:roll Yaw:yaw withResult:nil];
}

- (IBAction)minusButtonDidtouch:(id)sender {
    if (!self.isConnected) {
        NSString *message = @"未连接至飞机";
        [self.logList insertObject:message atIndex:0];
        [self.logView reloadData];
        return;
    }
    DJIGimbalRotation pitch = {YES, 150, RelativeAngle, RotationBackward};
    DJIGimbalRotation roll = {NO, 0, RelativeAngle, RotationBackward};
    DJIGimbalRotation yaw = {YES, 0, RelativeAngle, RotationBackward};
    [self.mGimbal setGimbalPitch:pitch Roll:roll Yaw:yaw withResult:nil];
}

- (IBAction)infoButtonDidTouch:(id)sender {
    if (!self.isConnected) {
        NSString *message = @"未连接至飞机";
        [self.logList insertObject:message atIndex:0];
        [self.logView reloadData];
        return;
    }
    DJIGimbalCapacity *gimbalCapacity = [self.mGimbal getGimbalCapacity];
    
    int currentPitch = self.mGimbal.gimbalAttitude.pitch;
    int currentRoll = self.mGimbal.gimbalAttitude.roll;
    int currentYaw = self.mGimbal.gimbalAttitude.yaw;
    
    
    
    float pitchMin;
    float pitchMax;
    float rollMin;
    float rollMax;
    float yawMin;
    float yawMax;
    pitchMin = [gimbalCapacity minPitchRotationAngle];
    pitchMax = [gimbalCapacity maxPitchRotationAngle];
    rollMin = [gimbalCapacity minRollRotationAngle];
    rollMax = [gimbalCapacity maxRollRotationAngle];
    yawMin = [gimbalCapacity minYawRotationAngle];
    yawMax = [gimbalCapacity maxYawRotationAngle];

    NSString* message = [[NSString alloc]
                         initWithFormat:@" CurrentPitch=%d , CurrentRoll=%d , CurrentYaw=%d",
                         currentPitch,
                         currentRoll,
                         currentYaw];
    [self.logList insertObject:message atIndex:0];
    [self.logView reloadData];
    //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Info" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //[alertView show];
}

- (IBAction)start1ButtonDidTouch:(id)sender {
    
    if (!self.isConnected) {
        NSString *message = @"未连接至飞机";
        [self.logList insertObject:message atIndex:0];
        [self.logView reloadData];
        return;
    }
    
    int currentPitch = self.mGimbal.gimbalAttitude.pitch;
    if (currentPitch < -824) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"请将相机归到水平位" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    if (self.isStarted) {
        return;
    }
    self.isStarted = YES;
    [NSThread detachNewThreadSelector:@selector(downRotateShot) toTarget:self withObject:nil];
    //[self downRotateShot];
}

- (void)upRotateShot {
    int currentPitch = self.mGimbal.gimbalAttitude.pitch;
    NSString *message = [[NSString alloc] initWithFormat:@"云台角度：%d,正在拍照", currentPitch];
    [self.logList insertObject:message atIndex:0];
    [self performSelectorOnMainThread:@selector(tableViewReloadDataOnMainThread:) withObject:self.logView waitUntilDone:YES];
    [self.camera startTakePhoto:CameraSingleCapture withResult:^(DJIError *error) {
        if (error == ERR_Successed) {
        } else {
            NSString *message = [[NSString alloc] initWithFormat:@"error : %@ with code %lu", error.errorDescription, (unsigned long)error.errorCode];
            [self.logList insertObject:message atIndex:0];
            [self performSelectorOnMainThread:@selector(tableViewReloadDataOnMainThread:) withObject:self.logView waitUntilDone:YES];
        }
    }];
    [self nextUpAngle];
}

- (void)nextUpAngle {
    int currentPitch = self.mGimbal.gimbalAttitude.pitch;
    if (currentPitch > -75) {
        self.isStarted = NO;
        /*UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Info" message:@"请旋转机身，开始下一次任务" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];*/
        if (self.isBigTask) {
            [self nextDroneAngle];
            return;
        } else {
            NSString *message = @"请旋转机身,开始下一次任务";
            [self.logList insertObject:message atIndex:0];
            [self performSelectorOnMainThread:@selector(tableViewReloadDataOnMainThread:) withObject:self.logView waitUntilDone:YES];
            return;
        }
    }
    NSString *message = [[NSString alloc] initWithFormat:@"云台角度：%d,正在准备向上旋转云台", currentPitch];
    [self.logList addObject:message];
    [self performSelectorOnMainThread:@selector(tableViewReloadDataOnMainThread:) withObject:self.logView waitUntilDone:YES];
    
    DJIGimbalRotation pitch = {YES, 300, RelativeAngle, RotationForward};
    DJIGimbalRotation roll = {NO, 0, RelativeAngle, RotationForward};
    DJIGimbalRotation yaw = {YES, 0, RelativeAngle, RotationForward};
    [self.mGimbal setGimbalPitch:pitch Roll:roll Yaw:yaw withResult:^(DJIError *error) {
        if (error == ERR_Successed) {
        } else {
            NSString *message = [[NSString alloc] initWithFormat:@"error : %@ with code %lu", error.errorDescription, (unsigned long)error.errorCode];
            [self.logList insertObject:message atIndex:0];
            [self performSelectorOnMainThread:@selector(tableViewReloadDataOnMainThread:) withObject:self.logView waitUntilDone:YES];
        }
    }];
    [self upRotateShot];
}

- (void)nextDownAngle {
    int currentPitch = self.mGimbal.gimbalAttitude.pitch;
    if (currentPitch < -824) {
        /*UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Info" message:@"请旋转机身，开始下一次任务" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];*/
        if (self.isBigTask) {
            [self nextDroneAngle];
            return;
        } else {
            [self restoreOriginPitch];
            self.isStarted = NO;
            NSString *message = @"请旋转机身,开始下一次任务";
            [self.logList insertObject:message atIndex:0];
            [self performSelectorOnMainThread:@selector(tableViewReloadDataOnMainThread:) withObject:self.logView waitUntilDone:YES];
            return;
        }
    }
    
    NSString *message = [[NSString alloc] initWithFormat:@"云台角度：%d,正在准备向下旋转云台", currentPitch];
    [self.logList insertObject:message atIndex:0];
    [self performSelectorOnMainThread:@selector(tableViewReloadDataOnMainThread:) withObject:self.logView waitUntilDone:YES];
    DJIGimbalRotation pitch = {YES, 300, RelativeAngle, RotationBackward};
    DJIGimbalRotation roll = {NO, 0, RelativeAngle, RotationBackward};
    DJIGimbalRotation yaw = {YES, 0, RelativeAngle, RotationBackward};
    [self.mGimbal setGimbalPitch:pitch Roll:roll Yaw:yaw withResult:^(DJIError *error) {
        if (error == ERR_Successed) {
        } else {
            NSString *message = [[NSString alloc] initWithFormat:@"error : %@ with code %lu", error.errorDescription, (unsigned long)error.errorCode];
            [self.logList insertObject:message atIndex:0];
            [self performSelectorOnMainThread:@selector(tableViewReloadDataOnMainThread:) withObject:self.logView waitUntilDone:YES];
        }
    }];
    usleep(self.rotateDuration*1000000);
    [self downRotateShot];
}

- (void)downRotateShot {
    int currentPitch = self.mGimbal.gimbalAttitude.pitch;
    NSString *message = [[NSString alloc] initWithFormat:@"云台角度：%d,正在拍照", currentPitch];
    [self.logList insertObject:message atIndex:0];
    [self performSelectorOnMainThread:@selector(tableViewReloadDataOnMainThread:) withObject:self.logView waitUntilDone:YES];
    [self.camera startTakePhoto:CameraSingleCapture withResult:^(DJIError *error) {
        if (error == ERR_Successed) {
        } else {
            NSString *message = [[NSString alloc] initWithFormat:@"error : %@ with code %lu", error.errorDescription, (unsigned long)error.errorCode];
            [self.logList insertObject:message atIndex:0];
            [self performSelectorOnMainThread:@selector(tableViewReloadDataOnMainThread:) withObject:self.logView waitUntilDone:YES];
        }
    }];
    usleep(self.cameraDuration*1000000);
    [self nextDownAngle];
}

- (IBAction)start2ButtonDidTouch:(id)sender {
    if (self.isStarted) {
        return;
    }
    self.isStarted = YES;
    [NSThread detachNewThreadSelector:@selector(restoreOriginPitch) toTarget:self withObject:nil];
    /*
    int currentPitch = self.mGimbal.gimbalAttitude.pitch;
    if (currentPitch > -75) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Info" message:@"请点击云台向下按钮" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    if (self.isStarted) {
        return;
    }
    self.isStarted = YES;
    [NSThread detachNewThreadSelector:@selector(upRotateShot) toTarget:self withObject:nil];*/
}

- (void)restoreOriginPitch {
    DJIGimbalRotation pitch = {YES, 300, RelativeAngle, RotationForward};
    DJIGimbalRotation roll = {NO, 0, RelativeAngle, RotationForward};
    DJIGimbalRotation yaw = {YES, 0, RelativeAngle, RotationForward};
    while (self.mGimbal.gimbalAttitude.pitch != 0) {
        [self.mGimbal setGimbalPitch:pitch Roll:roll Yaw:yaw withResult:nil];
    }
    pitch.angle = 0;
    
    NSString *message = @"回位成功";
    [self.logList insertObject:message atIndex:0];
    [self performSelectorOnMainThread:@selector(tableViewReloadDataOnMainThread:) withObject:self.logView waitUntilDone:YES];
}

- (IBAction)shotButtonDidTouch:(id)sender {
    if (!self.isConnected) {
        NSString *message = @"未连接至飞机";
        [self.logList insertObject:message atIndex:0];
        [self.logView reloadData];
        return;
    }
    [self.camera startTakePhoto:CameraSingleCapture withResult:^(DJIError *error) {
        if (error.errorCode != ERR_Successed) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error-TakePhoto" message:[[NSString alloc] initWithFormat:@"error : %@", error.errorDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
    }];
}

- (IBAction)entergsstateButtonDidTouch:(id)sender {
    [_navigation enterNavigationModeWithResult:^(DJIError *error) {
        NSString *message = [[NSString alloc] initWithFormat:@"Enter Navigation Mode:%@", error.errorDescription];
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }];
}

- (IBAction)startButtonDidTouch:(id)sender {
    if (self.isStarted) {
        return;
    }
    self.isStarted = YES;
    self.isBigTask = YES;
    originYaw = self.mGimbal.gimbalAttitude.yaw;
    [NSThread detachNewThreadSelector:@selector(shotAtCurrentDroneAngle) toTarget:self withObject:nil];
}

- (void)shotAtCurrentDroneAngle {
    int currentYaw = self.mGimbal.gimbalAttitude.yaw;
    if (abs(currentYaw-originYaw) >= 3600) {
        self.isStarted = NO;
        self.isBigTask = NO;
        NSString *message = @"本次任务已完成";
        [self.logList insertObject:message atIndex:0];
        [self.logView reloadData];
        return;
    }
    int currentpitch = self.mGimbal.gimbalAttitude.pitch;
    NSString *message = [[NSString alloc] initWithFormat:@"机身角度：%d ， 开始本次机身角度拍摄", currentYaw];
    [self.logList insertObject:message atIndex:0];
    [self.logView reloadData];
    if (currentpitch > -450) {
        [self downRotateShot];
    } else {
        [self upRotateShot];
    }
}

- (void)nextDroneAngle {
    id<DJINavigation> navi = (id<DJINavigation>)_drone.mainController;
    DJINavigationFlightControlData ctrlData = {0};
    ctrlData.mPitch = 0;
    ctrlData.mRoll = 0;
    ctrlData.mYaw = 300;
    ctrlData.mThrottle = 0;
    NSString *message = @"正在旋转机身";
    [self.logList insertObject:message atIndex:0];
    [self.logView reloadData];
    [navi sendFlightControlData:ctrlData withResult:nil];
    usleep(1000000);
    [self shotAtCurrentDroneAngle];
}

- (void)tableViewReloadDataOnMainThread:(UITableView *)tableView {
    [tableView reloadData];
}

- (void)elapse {
    int currentYaw = self.mGimbal.gimbalAttitude.yaw;
    NSString *yawText = [[NSString alloc] initWithFormat:@"Yaw:%d", currentYaw];
    self.yawLabel.text = yawText;
    NSString *altitudeText = [[NSString alloc] initWithFormat:@"%.1f M", self.altitude];
    self.altitudeLabel.text = altitudeText;
    [self.yawView setCurrentYaw:currentYaw];
    [self.yawView setNeedsDisplay];
}

- (IBAction)cameraPlusButtonDidTouch:(id)sender {
    if (self.isStarted) {
        return;
    }
    self.cameraDuration += 1;
    if (self.cameraDuration >5) {
        self.cameraDuration = 5;
    }
    NSString *text = [[NSString alloc] initWithFormat:@"%d", self.cameraDuration];
    self.cameraLabel.text = text;
}

- (IBAction)cameraMinusButtonDidTouch:(id)sender {
    if (self.isStarted) {
        return;
    }
    self.cameraDuration -= 1;
    if (self.cameraDuration < 1) {
        self.cameraDuration = 1;
    }
    NSString *text = [[NSString alloc] initWithFormat:@"%d", self.cameraDuration];
    self.cameraLabel.text = text;
}

- (IBAction)rotatePlusButtonDidTouch:(id)sender {
    if (self.isStarted) {
        return;
    }
    self.rotateDuration += 1;
    if (self.rotateDuration > 5) {
        self.rotateDuration = 5;
    }
    NSString *text = [[NSString alloc] initWithFormat:@"%d", self.rotateDuration];
    self.rotateLabel.text = text;
}

- (IBAction)rotateMinusButtonDidtouch:(id)sender {
    if (self.isStarted) {
        return;
    }
    self.rotateDuration -= 1;
    if (self.rotateDuration < 1) {
        self.rotateDuration = 1;
    }
    NSString *text = [[NSString alloc] initWithFormat:@"%d", self.rotateDuration];
    self.rotateLabel.text = text;
}

- (IBAction)settingButtonDidTouch:(id)sender {
    if (!self.isConnected) {
        NSString *message = @"未连接至飞机";
        [self.logList insertObject:message atIndex:0];
        [self.logView reloadData];
        return;
    }
    [self performSegueWithIdentifier:@"SettingSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier  isEqual: @"SettingSegue"]) {
        SettingViewController *toView = (SettingViewController *)segue.destinationViewController;
        [toView setCamera:self.camera];
    }
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.logList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LogTableViewCell *cell = [self.logView dequeueReusableCellWithIdentifier:@"LogCell"];
    
    cell.logLabel.text = [self.logList objectAtIndex:indexPath.row];
    
    return cell;
}

@end
