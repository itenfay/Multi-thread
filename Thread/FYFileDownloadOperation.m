//
//  FYFileDownloadOperation.m
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

#import "FYFileDownloadOperation.h"

@interface FYFileDownloadOperation ()

// 要下载的文件的URL
@property (nonatomic, strong) NSURL *fileURL;

// 使用NSURLSession协调一组相关网络数据传输任务
@property (nonatomic, strong) NSURLSession *sesstion;

// 使用NSURLSessionDataTask进行网络数据的获取
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;

// 定义一个可变的NSMutableData对象，用于添加获取的数据
@property (nonatomic, strong) NSMutableData *fileMutableData;

// 记录要下载文件的总长度
@property (nonatomic, assign) NSUInteger fileTotalLength;

// 记录已经下载了的文件的长度
@property (nonatomic, assign) NSUInteger downloadedLength;

@end

@implementation FYFileDownloadOperation

@synthesize executing = _executing;
@synthesize finished  = _finished;

// executing属性的setter
- (void)setExecuting:(BOOL)executing {
    // 设置executing属性需要手动触发KVO方法进行通知
    [self willChangeValueForKey:@"executing"];
    _executing = executing;
    [self didChangeValueForKey:@"executing"];
}

// executing属性的getter
- (BOOL)isExecuting {
    return _executing;
}

// finished属性的setter
- (void)setFinished:(BOOL)finished {
    // 同上，需要手动触发KVO方法进行通知
    [self willChangeValueForKey:@"finished"];
    _finished = finished;
    [self didChangeValueForKey:@"finished"];
}

// finished属性的getter
- (BOOL)isFinished {
    return _finished;
}

// 返回YES标识为并发Operation
- (BOOL)isAsynchronous {
    return YES;
}

// 内部函数，用于结束任务
- (void)finishTask {
    // 中断网络连接
    //[self.connection cancel];
    [self.sesstion invalidateAndCancel];
    // 设置finished属性为YES，将任务从队列中移除
    // 会调用setter方法，并触发KVO方法进行通知
    self.finished  = YES;
    // 设置executing属性为NO
    self.executing = NO;
}

// 初始化构造函数
- (instancetype)initWithURL:(NSURL *)url {
    if (self = [super init]) {
        self.fileURL          = url;
        
        self.fileMutableData  = [[NSMutableData alloc] init];
        self.fileTotalLength  = 0;
        self.downloadedLength = 0;
    }
    return self;
}

// 重写start方法
- (void)start {
    // 任务开始执行前检查是否被取消，取消就结束任务
    if (self.isCancelled) {
        [self finishTask];
        return;
    }
    
    // 构造NSURLConnection对象，并设置不立即开始，手动开始
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:self.fileURL
                                                  cachePolicy:NSURLRequestReloadIgnoringCacheData
                                              timeoutInterval:20];
    
    // A default session configuration object that defines behavior and policies for a URL session.
    NSURLSessionConfiguration *aURLSessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    self.sesstion = [NSURLSession sessionWithConfiguration:aURLSessionConfig delegate:self delegateQueue:nil];
    self.dataTask = [self.sesstion dataTaskWithRequest:request];
    
    // 判断是否连接，没有连接就结束任务
    if (self.dataTask == nil) {
        [self finishTask];
        return;
    }
    
    // 成功连接到服务器后检查是否取消任务，取消任务就结束
    if (self.isCancelled) {
        [self finishTask];
        return;
    }
    
    // 设置任务开始执行
    self.executing = YES;
    // 开始从服务端获取数据
    [self.dataTask resume];
    
    // 获取当前RunLoop
    //NSRunLoop *currentRunLoop = [NSRunLoop currentRunLoop];
    // 将任务交由RunLoop规划
    //[self.connection scheduleInRunLoop:currentRunLoop forMode:NSRunLoopCommonModes];
    // 开始从服务端获取数据
    //[self.connection start];
    // 判断执行任务的是否为主线程
    //if (currentRunLoop != [NSRunLoop mainRunLoop]) {
    // 不为主线程启动RunLoop
    //CFRunLoopRun();
    //}
}

#pragma mark - NSURLSessionDelegate, NSURLSessionDataDelegate

/* The last message a session receives.  A session will only become
 * invalid because of a systemic error or when it has been
 * explicitly invalidated, in which case the error parameter will be nil.
 */
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
    NSLog(@"%s, error: %@", __FUNCTION__, error);
    // 网络获取失败，调用代理方法
    if ([self.delegate respondsToSelector:@selector(fileDownloadOperation:didFailWithError:)])
    {
        // 需要将代理方法放到主线程中执行，防止代理方法需要修改UI
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate fileDownloadOperation:self didFailWithError:error];
        });
    }
}

/* If implemented, when a connection level authentication challenge
 * has occurred, this delegate will be given the opportunity to
 * provide authentication credentials to the underlying
 * connection. Some types of authentication will apply to more than
 * one request on a given connection to a server (SSL Server Trust
 * challenges).  If this delegate message is not implemented, the
 * behavior will be to use the default handling, which may involve user
 * interaction.
 */
//- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {

//}

/* If an application has received an
 * -application:handleEventsForBackgroundURLSession:completionHandler:
 * message, the session delegate will receive this message to indicate
 * that all messages previously enqueued for this session have been
 * delivered.  At this time it is safe to invoke the previously stored
 * completion handler, or to begin any internal updates that will
 * result in invoking the completion handler.
 */
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    NSLog(@"%s", __FUNCTION__);
}

/* The task has received a response and no further messages will be
 * received until the completion block is called. The disposition
 * allows you to cancel a request or to turn a data task into a
 * download task. This delegate message is optional - if you do not
 * implement it, you can get the response as a property of the task.
 *
 * This method will not be called for background upload tasks (which cannot be converted to download tasks).
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    // 获取并设置将要下载文件的长度大小
    self.fileTotalLength = response.expectedContentLength;
}

/* Notification that a data task has become a download task.  No
 * future messages will be sent to the data task.
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask {
    NSLog(@"%s", __FUNCTION__);
}

/*
 * Notification that a data task has become a bidirectional stream
 * task.  No future messages will be sent to the data task.  The newly
 * created streamTask will carry the original request and response as
 * properties.
 *
 * For requests that were pipelined, the stream object will only allow
 * reading, and the object will immediately issue a
 * -URLSession:writeClosedForStream:.  Pipelining can be disabled for
 * all requests in a session, or by the NSURLRequest
 * HTTPShouldUsePipelining property.
 *
 * The underlying connection is no longer considered part of the HTTP
 * connection cache and won't count against the total number of
 * connections per host.
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didBecomeStreamTask:(NSURLSessionStreamTask *)streamTask API_AVAILABLE(ios(9.0)) {
    NSLog(@"%s", __FUNCTION__);
}

/* Sent when data is available for the delegate to consume.  It is
 * assumed that the delegate will retain and not copy the data.  As
 * the data may be discontiguous, you should use
 * [NSData enumerateByteRangesUsingBlock:] to access it.
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    // 收到数据包后判断任务是否取消，取消则结束任务
    if (self.isCancelled)
    {
        [self finishTask];
        return;
    }
    
    // 添加获取的数据
    [self.fileMutableData appendData:data];
    // 修改已下载文件长度
    self.downloadedLength += [data length];
    
    // 调用回调函数
    if ([self.delegate respondsToSelector:@selector(fileDownloadOperation:downloadProgress:)])
    {
        // 计算下载比例
        double progress = self.downloadedLength * 1.0 / self.fileTotalLength;
        // 同上，放在主线程中调用，防止主线程有修改UI的操作
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate fileDownloadOperation:self downloadProgress:progress];
        });
    }
}

/* Invoke the completion routine with a valid NSCachedURLResponse to
 * allow the resulting data to be cached, or pass nil to prevent
 * caching. Note that there is no guarantee that caching will be
 * attempted for a given resource, and you should not rely on this
 * message to receive the resource data.
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse * _Nullable cachedResponse))completionHandler {
    
}

/* Sent as the last message related to a specific task.  Error may be
 * nil, which implies that no error occurred and this task is complete.
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {
    if (!error)
    {
        // 网络下载完成前检查是否取消任务，取消就结束任务
        if (self.isCancelled)
        {
            [self finishTask];
            return;
        }
        
        // 调用回调函数
        if ([self.delegate respondsToSelector:@selector(fileDownloadOperation:didFinishWithData:)])
        {
            // 同理，放在主线程中调用
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate fileDownloadOperation:self didFinishWithData:self.fileMutableData];
            });
        }
        
        // 下载完成，任务结束
        [self finishTask];
    }
    else
    {
        NSLog(@"%s, error: %@", __FUNCTION__, error);
        // 网络获取失败，调用代理方法
        if ([self.delegate respondsToSelector:@selector(fileDownloadOperation:didFailWithError:)])
        {
            // 需要将代理方法放到主线程中执行，防止代理方法需要修改UI
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate fileDownloadOperation:self didFailWithError:error];
            });
        }
    }
}

@end
