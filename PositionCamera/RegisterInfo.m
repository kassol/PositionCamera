//
//  RegisterInfo.m
//  PositionCamera
//
//  Created by 张旭 on 15/6/10.
//  Copyright (c) 2015年 3lang. All rights reserved.
//

#import "RegisterInfo.h"

@interface RegisterInfo ()
@property (nonatomic) BOOL isRegisterSuccess;
@property (nonatomic) BOOL isRegisterEnd;
@property (nonatomic) NSString *errorInfo;
@end

@implementation RegisterInfo

static RegisterInfo *instance = nil;

+ (instancetype)sharedRegisterInfo {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    self.isRegisterSuccess = NO;
    self.isRegisterEnd = 0;
    self.errorInfo = @"";
    return self;
}

- (void)setRegisterSuccess:(BOOL)registersuccess {
    _isRegisterSuccess = registersuccess;
}

- (void)setErrorInfo:(NSString *)errorinfo {
    _errorInfo = errorinfo;
}

- (NSString *)ErrorInfo {
    return _errorInfo;
}

- (BOOL)isRegisterSuccess {
    return _isRegisterSuccess;
}

- (void)setRegisterEnd {
    _isRegisterEnd = YES;
}

- (BOOL)isRegisterEnd {
    return _isRegisterEnd;
}

@end
