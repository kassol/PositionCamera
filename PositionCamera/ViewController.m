//
//  ViewController.m
//  PositionCamera
//
//  Created by 张旭 on 15/6/5.
//  Copyright (c) 2015年 3lang. All rights reserved.
//

#define DeviceSystemVersion ([[[UIDevice currentDevice] systemVersion] floatValue])
#define iOS8System (DeviceSystemVersion >= 8.0)

#define SCREEN_WIDTH  (iOS8System ? [UIScreen mainScreen].bounds.size.width : [UIScreen mainScreen].bounds.size.height)
#define SCREEN_HEIGHT (iOS8System ? [UIScreen mainScreen].bounds.size.height : [UIScreen mainScreen].bounds.size.width)

#import "ViewController.h"
#import "VideoPreviewer.h"

@interface ViewController ()

@property (strong, nonatomic) DJIDrone* drone;
@property (weak, nonatomic) DJIInspireCamera* camera;
@property (weak, nonatomic) DJIGimbal* gimbal;
@property (nonatomic) int droneAngleValue;
@property (nonatomic) int CameraAngleValue;
@property (weak, nonatomic) IBOutlet UITextField *droneAngle;
@property (weak, nonatomic) IBOutlet UITextField *cameraAngle;
@property (weak, nonatomic) DJIGimbalCapacity *gimbalCapacity;
@property (nonatomic) float pitchMin;
@property (nonatomic) float pitchMax;
@property (nonatomic) float rollMin;
@property (nonatomic) float rollMax;
@property (nonatomic) float yawMin;
@property (nonatomic) float yawMax;
@property (nonatomic) int jobID;
@property (nonatomic) BOOL isStarted;
@property (nonatomic) int currentPitch;
@property (nonatomic) int currentRoll;
@property (nonatomic) int currentYaw;

@property (strong, nonatomic) UIView* previewerView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.jobID = -1;
    self.isStarted = NO;
    self.drone = [[DJIDrone alloc] initWithType:DJIDrone_Inspire];
    self.drone.delegate = self;
    self.camera = (DJIInspireCamera *)self.drone.camera;
    self.camera.delegate = self;
    self.gimbal = self.drone.gimbal;
    self.gimbal.delegate = self;
    self.droneAngle.delegate = self;
    self.cameraAngle.delegate = self;
    self.drone.mainController.mcDelegate = self;
    self.gimbalCapacity = [self.gimbal getGimbalCapacity];
    self.pitchMin = [self.gimbalCapacity minPitchRotationAngle];
    self.pitchMax = [self.gimbalCapacity maxPitchRotationAngle];
    self.rollMin = [self.gimbalCapacity minRollRotationAngle];
    self.rollMax = [self.gimbalCapacity maxRollRotationAngle];
    self.yawMin = [self.gimbalCapacity minYawRotationAngle];
    self.yawMax = [self.gimbalCapacity maxYawRotationAngle];
    self.previewerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.view addSubview:self.previewerView];
    [self.view sendSubviewToBack:self.previewerView];
    self.previewerView.backgroundColor = [UIColor grayColor];
    
    [[VideoPreviewer instance] start];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[VideoPreviewer instance] setView:self.previewerView];
    [self.drone connectToDrone];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.camera startCameraSystemStateUpdates];
    [self.gimbal startGimbalAttitudeUpdates];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.drone disconnectToDrone];
    [self.drone destroy];
}

- (IBAction)captureButtonDidTouch:(id)sender {
    [self.camera startTakePhoto:CameraSingleCapture withResult:^(DJIError *error) {
        if (error.errorCode != ERR_Successed) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error-TakePhoto" message:[[NSString alloc] initWithFormat:@"error : %@", error.errorDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
    }];
    /*static int test = -1;
    ++test;
    char a = 'A'+test;
    NSString *prefixName = [[NSString alloc] initWithFormat:@"%c%c%c_%c", a, a, a];
    [self.camera setCameraPhotoNamePrefix:prefixName withResultBlock:^(DJIError *error) {
        if (error != ERR_Successed) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error-SetPrefix" message:[[NSString alloc] initWithFormat:@"error : %@", error.errorDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        } else {
            
        }
    }];*/
}

- (IBAction)infoButtonDidTouch:(id)sender {
    [self.camera getCameraGps:^(CLLocationCoordinate2D coordinate, DJIError *error) {
        if (error != ERR_Successed) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error-GetCameraGPS" message:[[NSString alloc] initWithFormat:@"error : %@", error.errorDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        } else {
            NSString *message = [[NSString alloc] initWithFormat:@"Latitude is %lf, Longtitude is %lf, \n Pitch is %d, Roll is %d, Yaw is %d", coordinate.longitude, coordinate.latitude, self.gimbal.gimbalAttitude.pitch, self.gimbal.gimbalAttitude.roll, self.gimbal.gimbalAttitude.yaw];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Info" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
    }];
    
}
- (IBAction)currentInfoButtonDidTouch:(id)sender {
    
//    NSString* message = [[NSString alloc]
//                         initWithFormat:@"PitchEnable: %@ , RollEnable: %@ , YawEnable: %@  PitchMin=%lf , PitchMax=%lf  RollMin=%lf , RollMax=%lf  YawMin=%lf , YawMax=%lf currentPitch=%d , currentRoll=%d , currentYaw=%d",
//                         self.gimbalCapacity.pitchAvailable ? @"true" : @"false",
//                         self.gimbalCapacity.rollAvailable ? @"true" : @"false",
//                         self.gimbalCapacity.yawAvailable ? @"true" : @"false",
//                         self.pitchMin,
//                         self.pitchMax,
//                         self.rollMin,
//                         self.rollMax,
//                         self.yawMin,
//                         self.yawMax,
//                         self.currentPitch,
//                         self.currentRoll,
//                         self.currentYaw];
    
    /*UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Info" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
     [alertView show];*/
}

- (IBAction)pitchButtonDidTouch:(id)sender {
    DJIGimbalRotation pitch = {YES, 150, RelativeAngle, RotationForward};
    DJIGimbalRotation roll = {NO, 0, RelativeAngle, RotationForward};
    DJIGimbalRotation yaw = {YES, 0, RelativeAngle, RotationForward};
    
    [self.gimbal setGimbalPitch:pitch Roll:roll Yaw:yaw withResult:^(DJIError *error) {
        if (error == ERR_Successed) {
            
        }
    }];
}

- (IBAction)rollButtonDidTouch:(id)sender {
    self.currentPitch = self.gimbal.gimbalAttitude.pitch;
    self.currentRoll = self.gimbal.gimbalAttitude.roll;
    self.currentYaw = self.gimbal.gimbalAttitude.yaw;
}

- (IBAction)yawButtonDidTouch:(id)sender {
    DJIGimbalRotation pitch = {YES, 0, RelativeAngle, RotationForward};
    DJIGimbalRotation roll = {NO, 0, RelativeAngle, RotationForward};
    DJIGimbalRotation yaw = {YES, 60, RelativeAngle, RotationForward};
    
    [self.gimbal setGimbalPitch:pitch Roll:roll Yaw:yaw withResult:^(DJIError *error) {
        if (error == ERR_Successed) {
            
        }
    }];
}

- (IBAction)startButtonDidTouch:(id)sender {
    if (self.isStarted) {
        return;
    }
    self.isStarted = YES;
    ++self.jobID;
    [self restoreOriginState];
}

- (void)restoreOriginState {
    DJIGimbalRotation pitch = {YES, self.pitchMin, AbsoluteAngle, RotationForward};
    DJIGimbalRotation roll = {NO, 0, RelativeAngle, RotationForward};
    DJIGimbalRotation yaw = {YES, self.yawMin, AbsoluteAngle, RotationForward};
    
    [self.gimbal setGimbalPitch:pitch Roll:roll Yaw:yaw withResult:^(DJIError *error) {
        if (error == ERR_Successed) {
            [self startTakePhotosAtCurrentDroneAngle];
        }
    }];
}

- (void)setPrefix {
    self.currentPitch = self.gimbal.gimbalAttitude.pitch;
    self.currentRoll = self.gimbal.gimbalAttitude.roll;
    self.currentYaw = self.gimbal.gimbalAttitude.yaw;
    
    /*NSDate *currentDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unitFlag = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay;
    
    NSDateComponents *date = [calendar components:unitFlag fromDate:currentDate];*/
    char p = 'A'+(int)(self.currentPitch-self.pitchMin)/(self.CameraAngleValue);
    char y = 'A'+(int)(self.currentYaw-self.yawMin)/(self.droneAngleValue);
    char job = 'A'+self.jobID;
    NSString *prefixName = [[NSString alloc] initWithFormat:@"%c%c_%c", p, y, job];
    NSLog(@"%@", prefixName);
    [self.camera setCameraPhotoNamePrefix:prefixName withResultBlock:^(DJIError *error) {
        if (error != ERR_Successed) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error-SetNamePrefix" message:[[NSString alloc] initWithFormat:@"error : %@", error.errorDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        } else {
            [self.camera startTakePhoto:CameraSingleCapture withResult:^(DJIError *error) {
                if (error != ERR_Successed) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error-TakePhoto" message:[[NSString alloc] initWithFormat:@"error : %@", error.errorDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alertView show];
                } else {
                    if (self.currentPitch == self.pitchMax && self.currentYaw == self.yawMax) {
                        self.isStarted = NO;
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Finish a group of task." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alertView show];
                    } else if (self.currentPitch == self.pitchMax) {
                        [self nextDroneAngle];
                    } else {
                        [self nextCameraAngle];
                    }
                }
            }];
        }
    }];
}

- (void)nextDroneAngle {
    self.currentPitch  = self.gimbal.gimbalAttitude.pitch;
    self.currentRoll = self.gimbal.gimbalAttitude.roll;
    self.currentYaw = self.gimbal.gimbalAttitude.yaw;
    
    DJIGimbalRotation pitch = {YES, self.pitchMin, AbsoluteAngle, RotationForward};
    DJIGimbalRotation roll = {NO, 0, RelativeAngle, RotationForward};
    DJIGimbalRotation yaw = {YES, self.currentYaw+self.droneAngleValue, AbsoluteAngle, RotationForward};
    
    if (yaw.angle > self.yawMax) {
        yaw.angle = self.yawMax;
    }
    [self.gimbal setGimbalPitch:pitch Roll:roll Yaw:yaw withResult:^(DJIError *error) {
        if (error == ERR_Successed) {
            [self startTakePhotosAtCurrentDroneAngle];
        }
    }];
}

- (void)nextCameraAngle {
    self.currentPitch  = self.gimbal.gimbalAttitude.pitch;
    self.currentRoll = self.gimbal.gimbalAttitude.roll;
    self.currentYaw = self.gimbal.gimbalAttitude.yaw;
    
    DJIGimbalRotation pitch = {YES, self.currentPitch+self.CameraAngleValue, AbsoluteAngle, RotationForward};
    DJIGimbalRotation roll = {NO, 0, RelativeAngle, RotationForward};
    DJIGimbalRotation yaw = {YES, 0, RelativeAngle, RotationForward};
    
    if (pitch.angle > self.pitchMax) {
        pitch.angle = self.pitchMax;
    }
    [self.gimbal setGimbalPitch:pitch Roll:roll Yaw:yaw withResult:^(DJIError *error) {
        if (error == ERR_Successed) {
            [self setPrefix];
        }
    }];
}

- (void)startTakePhotosAtCurrentDroneAngle {
    [self setPrefix];
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

#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (textField == self.droneAngle) {
        self.droneAngleValue = (int)(textField.text.floatValue+1e6);
    } else if (textField == self.cameraAngle){
        self.CameraAngleValue = (int)(textField.text.floatValue+1e6);
    }
    return YES;
}

#pragma mark - DJIGimbalDelegate

- (void)gimbalController:(DJIGimbal *)controller didGimbalError:(DJIGimbalError)error {
    if (error == GimbalClamped) {
        NSLog(@"Gimbal Clamped");
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Gimbal Clamped" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    if (error == GimbalErrorNone) {
        NSLog(@"Gimbal Error None");
        
    }
    if (error == GimbalMotorAbnormal) {
        NSLog(@"Gimbal Motor Abnormal");
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Gimbal Motor Abnormal" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    self.isStarted = NO;
}

#pragma mark - DJIDroneDelegate

- (void)droneOnConnectionStatusChanged:(DJIConnectionStatus)status {
    if (status == ConnectionSuccessed) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Info" message:@"connection success" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

@end
