//
//  Product.h
//  InnoTech
//
//  Created by Vladyslav Gusakov on 5/3/16.
//  Copyright © 2016 Vladyslav Gusakov. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface Product : NSObject

@property (retain, nonatomic) NSString *name;
@property (retain, nonatomic) NSString *shortDescription;
@property (retain, nonatomic) NSString *imageURL;
@property (retain, nonatomic) NSString *image;
@property (retain, nonatomic) NSString *urlString;

-(instancetype) initWithName:(NSString *)name description:(NSString*) descr image: (NSString *) image;

@end
