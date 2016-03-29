//
//  TestModel.m
//  KVODemo
//
//  Created by bianyixuan on 16/3/29.
//  Copyright © 2016年 jzsec-byx. All rights reserved.
//

#import "TestModel.h"

@implementation TestModel


-(instancetype)init
{
    if (self=[super init]) {
        self.age=@"24";
        self.name=@"bianyixuan";
    }
    return self;
}

@end
