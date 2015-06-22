//
//  CustomTableViewCell.m
//  PositionCamera
//
//  Created by 张旭 on 15/6/14.
//  Copyright (c) 2015年 3lang. All rights reserved.
//

#import "CustomTableViewCell.h"

@implementation CustomTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.cornerRadius = 3.0;
        self.layer.borderWidth = 1.2;
        self.textLabel.textColor = [UIColor blackColor];
    }
    
    return self;
}

- (void)changeStyle {
    self.backgroundColor = [UIColor clearColor];
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.cornerRadius = 3.0;
    self.layer.borderWidth = 1.2;
    self.textLabel.textColor = [UIColor blackColor];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.settingItem = nil;
    self.accessoryType = UITableViewCellAccessoryNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
