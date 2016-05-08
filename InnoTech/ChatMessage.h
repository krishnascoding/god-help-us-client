//
//  ChatMessage.h
//  LiveChatFramework
//
//  Created by Krishna Ramachandran on 5/7/16.
//  Copyright © 2016 Krishna Ramachandran. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatMessage : NSObject

@property (nonatomic, strong) NSString *message;
@property (nonatomic) BOOL isUser;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *email;

- (id)initWithMessage:(NSString *)message isUser:(BOOL)user name:(NSString *)
name andEmail:(NSString *)email;

@end
