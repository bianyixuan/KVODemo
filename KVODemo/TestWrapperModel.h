//
//  TestWrapperModel.h
//  KVODemo
//
//  Created by bianyixuan on 16/3/29.
//  Copyright © 2016年 jzsec-byx. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TestModel;
@interface TestWrapperModel : NSObject


@property (nonatomic,strong) TestModel *testModel;

@property (nonatomic,copy) NSString *information;

@end
