//
//  YawView.m
//  PositionCamera
//
//  Created by 张旭 on 15/6/14.
//  Copyright (c) 2015年 3lang. All rights reserved.
//

#import "YawView.h"

@interface YawView ()
@property (nonatomic) int currentYaw;
@end

@implementation YawView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    CGRect bounds = self.bounds;
    
    CGPoint center;
    center.x = bounds.origin.x+bounds.size.width/2.0;
    center.y = bounds.origin.y+bounds.size.height/2.0;
    
    float radius = bounds.size.width/2.0-10;
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    
    [path addArcWithCenter:center radius:radius startAngle:0.5*M_PI endAngle:2.5*M_PI clockwise:YES];
    
    path.lineWidth = 1.0;
    [path setLineCapStyle:kCGLineCapRound];
    
    [path moveToPoint:CGPointMake(center.x-radius, center.y)];
    [path addLineToPoint:CGPointMake(center.x-radius*3/4, center.y)];
    
    [path moveToPoint:CGPointMake(center.x+radius, center.y)];
    [path addLineToPoint:CGPointMake(center.x+radius*3/4, center.y)];
    
    [path moveToPoint:CGPointMake(center.x, center.y-radius)];
    [path addLineToPoint:CGPointMake(center.x, center.y-radius*3/4)];
    
    [path moveToPoint:CGPointMake(center.x, center.y+radius)];
    [path addLineToPoint:CGPointMake(center.x, center.y+radius*3/4)];
    
    [path moveToPoint:CGPointMake(center.x-radius*sin(M_PI/4), center.y-radius*cos(M_PI/4))];
    [path addLineToPoint:CGPointMake(center.x-3*radius*sin(M_PI/4)/4, center.y-3*radius*cos(M_PI/4)/4)];
    
    [path moveToPoint:CGPointMake(center.x+radius*sin(M_PI/4), center.y-radius*cos(M_PI/4))];
    [path addLineToPoint:CGPointMake(center.x+3*radius*sin(M_PI/4)/4, center.y-3*radius*cos(M_PI/4)/4)];
    
    [path moveToPoint:CGPointMake(center.x-radius*sin(M_PI/4), center.y+radius*cos(M_PI/4))];
    [path addLineToPoint:CGPointMake(center.x-3*radius*sin(M_PI/4)/4, center.y+3*radius*cos(M_PI/4)/4)];
    
    [path moveToPoint:CGPointMake(center.x+radius*sin(M_PI/4), center.y+radius*cos(M_PI/4))];
    [path addLineToPoint:CGPointMake(center.x+3*radius*sin(M_PI/4)/4, center.y+3*radius*cos(M_PI/4)/4)];
    
    
    [[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] setStroke];
    
    [path moveToPoint:CGPointMake(center.x, center.y)];
    float angle = ((self.currentYaw+1800)/10+90)/360.0*2*M_PI;
    [path addLineToPoint:CGPointMake(center.x+2*radius*cos(angle)/3, center.y+2*radius*sin(angle)/3)];
    
    [path stroke];
}

- (void)setCurrentYaw:(int)yaw {
    _currentYaw = yaw;
}


@end
