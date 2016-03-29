//
//  TestWrapperModel.m
//  KVODemo
//
//  Created by bianyixuan on 16/3/29.
//  Copyright © 2016年 jzsec-byx. All rights reserved.
//

#import "TestWrapperModel.h"
#import "TestModel.h"
@implementation TestWrapperModel

-(NSString *)information
{
    return [NSString stringWithFormat:@"%@-%@",[self.testModel name],[self.testModel age]];
}

-(void)setInformation:(NSString *)information
{
    NSArray * array = [information componentsSeparatedByString:@"-"];
    [self.testModel setName:[array objectAtIndex:0]];
    [self.testModel setAge:[array objectAtIndex:1]];
}

+(NSSet *)keyPathsForValuesAffectingInformation
{
    NSSet *keyPaths=[NSSet setWithObjects:@"testModel.name",@"testModel.age",nil];
    return keyPaths;
}



-(void)dealloc
{
    self.testModel=nil;
}

@end
