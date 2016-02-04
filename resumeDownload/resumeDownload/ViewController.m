//
//  ViewController.m
//  resumeDownload
//
//  Created by 吕俊 on 16/2/4.
//  Copyright © 2016年 吕俊. All rights reserved.
//

#import "ViewController.h"

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

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (IBAction)start:(id)sender {
}
- (IBAction)pause:(id)sender {
}
@end
