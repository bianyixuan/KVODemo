//
//  ViewController.m
//  KVODemo
//
//  Created by bianyixuan on 16/3/29.
//  Copyright © 2016年 jzsec-byx. All rights reserved.
//

#import "ViewController.h"
#import "TestModel.h"
#import "TestWrapperModel.h"
#import <objc/runtime.h>
@interface ViewController ()

@end

@implementation ViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.view.backgroundColor=[UIColor whiteColor];
    
    TestModel *testModel=[[TestModel alloc] init];
    
    TestWrapperModel *testWrapperModel=[[TestWrapperModel alloc] init];
    testWrapperModel.testModel=testModel;
    
    [testWrapperModel addObserver:self forKeyPath:@"information" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:(__bridge void * _Nullable)([testWrapperModel class])];

//    [testModel addObserver:self forKeyPath:@"age" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:(__bridge void * _Nullable)([testModel class])];
    
    testModel.name=@"byx";
    testModel.age=@"25";
//    [testModel setValue:@"25" forKey:@"age"];
    
//    [testModel removeObserver:self forKeyPath:@"age"];
    
    [testWrapperModel removeObserver:self forKeyPath:@"information"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CustomDelegate

#pragma mark - event response

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"age"]) {
        Class cls=(__bridge Class)context;
        NSString *className=[NSString stringWithCString:object_getClassName(cls) encoding:NSUTF8StringEncoding];
        NSLog(@"className: %@>>>> , age changed",className);
        
        NSLog(@"old age is : %@",[change objectForKey:@"old"]);
        
        NSLog(@"new age is : %@",[change objectForKey:@"new"]);
        
    }else if ([keyPath isEqualToString:@"information"]){
        Class cls=(__bridge Class)context;
        NSString *className=[NSString stringWithCString:object_getClassName(cls) encoding:NSUTF8StringEncoding];
        NSLog(@"className: %@>>>> , information changed",className);
        
        NSLog(@"old information is : %@",[change objectForKey:@"old"]);
        
        NSLog(@"new information is : %@",[change objectForKey:@"new"]);
    }
    else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - private methods

#pragma mark - getters and setters

-(NSString *)title
{
    return @"KVODemo演示";
}


@end
