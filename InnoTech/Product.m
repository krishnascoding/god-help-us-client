//
//  Product.m
//  InnoTech
//
//  Created by Vladyslav Gusakov on 5/3/16.
//  Copyright © 2016 Vladyslav Gusakov. All rights reserved.
//

#import "Product.h"

@implementation Product

-(instancetype) initWithName:(NSString *)name description:(NSString*) descr image: (NSString *) image {
    self = [super init];
    if (self) {
        self.name = name;
        self.shortDescription = descr;
        self.image = image;
    }
    
    return self;
}

@end
