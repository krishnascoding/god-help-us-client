//
//  ChatMessage.m
//  LiveChatFramework
//
//  Created by Krishna Ramachandran on 5/7/16.
//  Copyright © 2016 Krishna Ramachandran. All rights reserved.
//

#import "ChatMessage.h"

@implementation ChatMessage

- (id)initWithMessage:(NSString *)message isUser:(BOOL)user name:(NSString *)
name andEmail:(NSString *)email {
    self = [super init];
    if (self) {
        // Any custom setup work goes here
        _message = message;
        _isUser = user;
        _name = name;
        _email = email;
        
    }
    return self;
}


@end
