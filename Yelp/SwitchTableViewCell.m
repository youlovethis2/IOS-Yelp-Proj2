//
//  SwitchTableViewCell.m
//  Yelp
//
//  Created by Shangqing Zhang on 2/2/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "SwitchTableViewCell.h"

@implementation SwitchTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.codeLabel = [[UILabel alloc] init];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)valueChanged:(id)sender {
    NSString *codeLabelString = [[self codeLabel] text];
    
    if ([sender isOn]) {
        [self.delegate didSelectCodeLabel:codeLabelString];
    } else {
        [self.delegate didDeselectCodeLabel:codeLabelString];
    }
}




@end
