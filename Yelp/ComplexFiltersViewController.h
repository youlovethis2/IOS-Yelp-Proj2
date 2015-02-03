//
//  ComplexFiltersViewController.h
//  Yelp
//
//  Created by Shangqing Zhang on 2/2/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwitchTableViewCell.h"



@protocol ComplexFiltersViewControllerDelegate <NSObject>

- (void)searchForCategory:(NSString *)category
                     sort:(NSString *)sort
                 distance:(NSString *)distance
                     deal:(NSString *)deal;


@end

@interface ComplexFiltersViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, SwitchTableViewCellDelegate>

@property (nonatomic, weak) id<ComplexFiltersViewControllerDelegate> delegate;
@end