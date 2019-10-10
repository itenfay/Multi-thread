//
//  FYFileDownloadOperation.h
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

#import <UIKit/UIKit.h>

/////////////////////////////////////////////////////
// 按照官方文档的要求，实现并发的自定义子类需要重写以下几个方法或属性:
// start方法: 任务加入到队列后，队列会管理任务并在线程被调度后适时调用start方法，start方法就是我们编写的任务，需要注意的是，不论怎样都不允许调用父类的start方法
// isExecuting: 任务是否正在执行，需要手动调用KVO方法来进行通知，这样，其他类如果监听了任务的该属性就可以获取到通知
// isFinished: 任务是否结束，需要手动调用KVO方法来进行通知，队列也需要监听该属性的值，用于判断任务是否结束，由于我们编写的任务很可能是异步的，所以start方法返回也不一定代表任务就结束了，任务结束需要开发者手动修改该属性的值，队列就可以正常的移除任务
// isAsynchronous: 是否并发执行，之前需要使用isConcurrent，但isConcurrent被废弃了，该属性标识是否并发
/////////////////////////////////////////////////////

@class FYFileDownloadOperation;

// 定义一个协议，用于反馈下载状态
@protocol FYFileDownloadDelegate <NSObject>

@optional
- (void)fileDownloadOperation:(FYFileDownloadOperation *)downloadOperation downloadProgress:(double)progress;
- (void)fileDownloadOperation:(FYFileDownloadOperation *)downloadOperation didFinishWithData:(NSData *)data;
- (void)fileDownloadOperation:(FYFileDownloadOperation *)downloadOperation didFailWithError:(NSError *)error;

@end

@interface FYFileDownloadOperation : NSOperation <NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

// 定义executing属性
@property (nonatomic, assign, getter=isExecuting) BOOL executing;
// 定义finished属性
@property (nonatomic, assign, getter=isFinished)  BOOL finished;

// 定义代理对象
@property (nonatomic, weak) id<FYFileDownloadDelegate> delegate;

// 初始化构造函数，文件URL
- (instancetype)initWithURL:(NSURL*)url;

@end
