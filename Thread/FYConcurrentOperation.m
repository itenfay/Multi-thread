//
//  FYConcurrentOperation.m
//
//  Created by dyf on 15/8/14.
//  Copyright (c) 2015 dyf.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "FYConcurrentOperation.h"

@implementation FYConcurrentOperation

@synthesize executing = _executing;
@synthesize finished  = _finished;

- (void)start {
    // 在任务开始前设置executing为YES，在此之前可能会进行一些初始化操作
    self.executing = YES;
    
    for (int i = 0; i < 50; i++) {
        /*
         需要在适当的位置判断外部是否调用了cancel方法
         如果被cancel了需要正确的结束任务
         */
        if (self.isCancelled) {
            // 任务被取消正确结束前手动设置状态
            self.executing = NO;
            self.finished  = YES;
            return;
        }
        
        // 输出任务的各个状态以及队列的任务数
        NSLog(@"Task %d %@ Cancel:%d Executing:%d Finished:%d QueueOperationCount:%ld", i, [NSThread currentThread], self.cancelled, self.executing, self.finished, [[NSOperationQueue currentQueue] operationCount]);
        
        [NSThread sleepForTimeInterval:0.1];
    }
    
    NSLog(@"Task Complete.");
    
    // 任务执行完成后手动设置状态
    self.executing = NO;
    self.finished  = YES;
}

- (void)setExecuting:(BOOL)executing {
    // 调用KVO通知
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    // 调用KVO通知
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isExecuting {
    return _executing;
}

- (void)setFinished:(BOOL)finished {
    // 调用KVO通知
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    // 调用KVO通知
    [self didChangeValueForKey:@"isFinished"];
}

- (BOOL)isFinished {
    return _finished;
}

- (BOOL)isAsynchronous {
    return YES;
}

@end
