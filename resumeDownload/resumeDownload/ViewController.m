//
//  ViewController.m
//  resumeDownload
//
//  Created by 吕俊 on 16/2/4.
//  Copyright © 2016年 吕俊. All rights reserved.
//
#define LJFileURL @"http://120.25.226.186:32812/resources/videos/minion_01.mp4"
// 将文件名用md5进行唯一化
#define LJFileName LJFileURL.md5String
// 存取文件的真实路径
#define LJFilePath [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:LJFileName]
// 已经下载文件的长度
#define LJDownloadLength [[[NSFileManager defaultManager] attributesOfItemAtPath:LJFilePath error:nil][NSFileSize] integerValue]


// 总长度存储的路径
#define LJTotalLengthFullPath [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"totalLength.json"]


#import "ViewController.h"
#import "NSString+Hash.h"

@interface ViewController () <NSURLSessionDataDelegate>
/** 进度条*/
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
/** session对象*/
@property (nonatomic, strong) NSURLSession *session;
/** data任务*/
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
/** 文件流*/
@property (nonatomic, strong) NSOutputStream *stream;
/** 文件的总长度*/
@property (nonatomic, assign) NSInteger totalLength;
@end

@implementation ViewController

/**
 *  懒加载
 */
- (NSURLSession *)session
{
    // 对session进行配置
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}
- (NSOutputStream *)stream
{
    if (!_stream) {
        _stream = [NSOutputStream outputStreamToFileAtPath:LJFilePath append:YES];
    }
    return _stream;
}


- (NSURLSessionDataTask *)dataTask
{
    if (!_dataTask) {
        
        self.totalLength = [[NSDictionary dictionaryWithContentsOfFile:LJTotalLengthFullPath][LJFileName] integerValue];
        if (self.totalLength && LJDownloadLength ==  self.totalLength) {
            NSLog(@"文件已经下载过了");
            return nil;
        }
        // 创建请求
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:LJFileURL]];
        
        // 设置请求头
        NSString *range = [NSString stringWithFormat:@"bytes=%zd-", LJDownloadLength];
        
        [request setValue:range forHTTPHeaderField:@"Range"];

        
        _dataTask = [self.session dataTaskWithRequest:request];
    }
    return _dataTask;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@", LJFilePath);
}
- (IBAction)start:(id)sender {
    [self.dataTask resume];
}
- (IBAction)pause:(id)sender {
    [self.dataTask suspend];
}

#pragma mark -<NSURLSessoinDataDelegate>

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    // 打开流
    [self.stream open];
    // 允许接受响应
    completionHandler(NSURLSessionResponseAllow);
    
    // 获取文件的总长度
    self.totalLength = [response.allHeaderFields[@"Content-Length"] integerValue] + LJDownloadLength;
    
    // 存储总长度
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:LJTotalLengthFullPath];
    // 如果存储的总长度为0，则初始化字典
    if (dict == nil) dict = [NSMutableDictionary dictionary];
    
    // 将总长度添加到字典中
    dict[LJFileName] = @(self.totalLength);
    // 将拿到的总长度写到文件中
    [dict writeToFile:LJTotalLengthFullPath atomically:YES];

}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    // 写入文件
    [self.stream write:data.bytes maxLength:data.length];
        // 下载进度
    self.progressView.progress = 1.0 * LJDownloadLength / self.totalLength;
    
    NSLog(@"%f", self.progressView.progress);
}
// 下载接受后
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    // 关闭流
    [self.stream close];
    self.stream = nil;
    
    // 清除task任务
    self.dataTask = nil;
}

@end
