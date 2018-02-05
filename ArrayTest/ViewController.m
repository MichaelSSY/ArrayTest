//
//  ViewController.m
//  ArrayTest
//
//  Created by weiyun on 2018/2/5.
//  Copyright © 2018年 孙世玉. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic , strong) NSArray *array;
@property (nonatomic , assign) NSInteger count;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //*********************** OC 循环遍历 ***********************//
    self.array = @[@"1",@"2",@"3",@"4",@"5",@"6"];
    self.count = self.array.count;
    [self test6];
}

/**
 *  for循环 慢遍历
 */
- (void)test1
{
    for (NSInteger i = 0; i < self.count; i ++) {
        NSLog(@"%@ ----- %@",self.array[i],[NSThread currentThread]);
    }
    NSLog(@"end");
}

/**
 *  for in 快遍历
 */
- (void)test2
{
    for (NSString *str in self.array) {
        NSLog(@"%@ ----- %@",str,[NSThread currentThread]);
    }
    NSLog(@"end");
}

/**
 *  NSEnumentor
 */
- (void)test3
{
    NSEnumerator *enumer = [self.array objectEnumerator];
    id obj;
    while (obj = [enumer nextObject]) {
        NSLog(@"%@ ----- %@",obj,[NSThread currentThread]);
    }
    NSLog(@"end");
}

/**
 *  block方式遍历
 */
- (void)test4
{
    // 顺序遍历
    [self.array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"%@ ----- %@",obj,[NSThread currentThread]);
    }];
    
    // 倒序遍历
    [self.array enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"%@ ----- %@",obj,[NSThread currentThread]);
    }];
    
    NSLog(@"end");
}

/**
 *  快速迭代 dispatch_apply
 */
- (void)test5
{
    // 将block中的任务，逐个放到queue中，然后进行dispatch_sync执行
    // 多线程同步循环
    // dispatch_apply 是同步的,可以在主线程走任务
    
    dispatch_apply(self.count, dispatch_get_global_queue(0,0), ^(size_t index) {
          NSLog(@"%@ ----- %@",self.array[index],[NSThread currentThread]);
    });
    NSLog(@"end");
    
    /**
     1. index（相当于for循环的i）遍历10次。打印线程的number 为1.3.4.5，其中1表示主线程，非1得为子线程,即开启了主线程和子线程来执行任务。
     2.GCD的遍历为：异步函数&并发队列，必须为并发队列，串行队列无意义；也不能传主队列，因为死锁.
     3.快的原因：异步的并发的队列，自动开启子线程
     */
}

- (void)test6
{
    dispatch_queue_t queue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group =  dispatch_group_create();
    for (NSInteger i = 0; i < self.count; i++) {
        NSLog(@"%ld",(long)i);
        dispatch_group_async(group, queue, ^{
            sleep(5);
            NSLog(@"%ld -- %@",(long)i,[NSThread currentThread]);
        });
    }
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);// 等待queue任务执行完,才往下走;
    dispatch_group_notify(group, queue, ^{ // 往下走,回调block
        NSLog(@"group end");
    });
    
    // dispatch group 只能异步,并且不会在主线程走任务
    
    NSLog(@"end");
}

- (void)test7
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_apply(self.count, dispatch_get_global_queue(0, 0), ^(size_t index) {
            sleep(1);
            NSLog(@"%@ ----- %@",self.array[index],[NSThread currentThread]);
        });
        NSLog(@"end");
    });
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
