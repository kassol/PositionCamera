//
//  RegisterInfo.h
//  PositionCamera
//
//  Created by 张旭 on 15/6/10.
//  Copyright (c) 2015年 3lang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RegisterInfo : NSObject

+ (instancetype)sharedRegisterInfo;

- (void)setRegisterSuccess:(BOOL)registersuccess;

- (void)setRegisterEnd;

- (void)setErrorInfo:(NSString *)errorinfo;

- (NSString *)ErrorInfo;

- (BOOL)isRegisterSuccess;

- (BOOL)isRegisterEnd;

@end
