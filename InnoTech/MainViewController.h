//
//  MainViewController.h
//  InnoTech
//
//  Created by Vladyslav Gusakov on 5/3/16.
//  Copyright © 2016 Vladyslav Gusakov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LCCChatViewController.h"


@interface MainViewController : UITableViewController

@property(nonatomic, strong) LCCChatViewController *chatViewController;

@end
