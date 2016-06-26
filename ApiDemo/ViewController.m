//
//  ViewController.m
//  ApiDemo
//
//  Created by alafighting on 16/6/22.
//  Copyright © 2016年 Jeesoft. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import <Foundation/Foundation.h>
#import <TargetConditionals.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *labelMessage;
@property (weak, nonatomic) AFHTTPSessionManager *_manager;

@property (strong, nonatomic) UIActionSheet *actionSheet;

@end

@implementation ViewController

NSString *host = @"http://domain/";

@synthesize actionSheet = _actionSheet;

- (AFHTTPSessionManager *) manager {
    if (self._manager == nil) {
        self._manager = [AFHTTPSessionManager manager];
        // 超时时间
        self._manager.requestSerializer.timeoutInterval = 20 * 1000;
    
        // 声明上传参数的数据格式
        self._manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
        // 声明获取到的数据格式
        // JSON -> AFJSONResponseSerializer
        self._manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        self._manager.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain", @"text/html", nil];
    }
    
    return self._manager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickLogin:(id)sender {
    self.labelMessage.text = @"准备";
    // 将请求参数放在请求的字典里
    NSDictionary *param = @{@"username":@"you_name", @"password":@"you_pass"};
    [self.manager GET:[host stringByAppendingString:@"api/login"]
           parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
               // 请求成功
               if(responseObject){
                   NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                   
                   NSLog(@"成功");
                   NSLog(@"\n%@", [ViewController replaceUnicode:str]);
                   self.labelMessage.text = @"成功";
               } else {
                   NSLog(@"无数据");
                   self.labelMessage.text = @"暂无数据";
               }
           } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
               // 请求失败
               // error
               NSLog(@"%@", error);
               self.labelMessage.text = @"失败";
           }];
    
}

- (IBAction)clickTestPost:(id)sender {
    self.labelMessage.text = @"准备";
    // 将请求参数放在请求的字典里
    NSDictionary *param = @{@"username":@"you_name"};
    [self.manager POST:[host stringByAppendingString:@"api/check"]
            parameters:param progress:nil success: ^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                // 请求成功
                if(responseObject){
                    NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                    
                    NSLog(@"成功");
                    NSLog(@"\n%@", [ViewController replaceUnicode:str]);
                    self.labelMessage.text = @"成功";
                } else {
                    NSLog(@"无数据");
                    self.labelMessage.text = @"暂无数据";
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                // 请求失败
                // error
                NSLog(@"%@", error);
                self.labelMessage.text = @"失败";
                
            }];
}

- (IBAction)clickTestUpload:(id)sender {
    self.labelMessage.text = @"准备";
    [self callActionSheetFunc];
}

- (IBAction)clickTestDownload:(id)sender {
    //请求的URL地址
    NSURL *url = [NSURL URLWithString:[host stringByAppendingString:@"apk/application.apk"]];
    
    //创建请求对象
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    //下载任务
    NSURLSessionDownloadTask *task = [self.manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        //下载进度
        NSLog(@"下载进度：%lld％", downloadProgress.completedUnitCount * 100 / downloadProgress.totalUnitCount);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        //下载地址
        NSLog(@"默认下载地址:%@",targetPath);
        
        //设置下载路径，通过沙盒获取缓存地址，最后返回NSURL对象
        NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
        return [NSURL URLWithString:filePath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        //下载完成调用的方法
        NSLog(@"下载完成:%@--%@",response,filePath);
    }];
    
    //开始启动任务
    [task resume];
}



- (void)doTestUpload:(NSData*)imageData {
    self.labelMessage.text = @"开始上传";
    // 将请求参数放在请求的字典里
    NSDictionary *param = @{@"username":@"you_name"};
    
    [self.manager POST:[host stringByAppendingString:@"api/update"]
            parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                [formData appendPartWithFileData:imageData name:@"portrait" fileName:@"portrait.png" mimeType:@"image/*"];
            } progress:^(NSProgress * _Nonnull uploadProgress) {
                long long totalCount = (long long)uploadProgress.totalUnitCount;
                long long curentCount = (long long)uploadProgress.completedUnitCount;
                  NSString *strProgress = [NSString stringWithFormat:@"%lld％  %lld kb", curentCount*100/totalCount, curentCount/1024];
                  
                  // 这里可以获取到目前数据请求的进度
                NSLog(strProgress);
                self.labelMessage.text = strProgress;
              } success: ^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                  // 请求成功
                  if(responseObject){
                      NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                      
                      NSLog(@"成功");
                      NSLog(@"\n%@", [ViewController replaceUnicode:str]);
                      self.labelMessage.text = @"成功";
                  } else {
                      NSLog(@"无数据");
                      self.labelMessage.text = @"暂无数据";
                  }
              } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                  // 请求失败
                  // error
                  NSLog(@"%@", error);
                  self.labelMessage.text = @"失败";
                  
              }];
}

/**
 @ 调用ActionSheet
 */
- (void)callActionSheetFunc{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        self.actionSheet = [[UIActionSheet alloc] initWithTitle:@"选择图像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册选择", nil, nil];
    }else{
        self.actionSheet = [[UIActionSheet alloc] initWithTitle:@"选择图像" delegate:self cancelButtonTitle:@"取消"destructiveButtonTitle:nil otherButtonTitles:@"从相册选择", nil, nil];
    }
    
    self.actionSheet.tag = 1000;
    [self.actionSheet showInView:self.view];
}

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet.tag == 1000) {
        NSUInteger sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        // 判断是否支持相机
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            switch (buttonIndex) {
                case 0:
                    //来源:相机
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                case 1:
                    //来源:相册
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
                case 2:
                    return;
            }
        }
        else {
            if (buttonIndex == 2) {
                return;
            } else {
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
        }
        // 跳转到相机或相册页面
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType = sourceType;
        
        [self presentViewController:imagePickerController animated:YES completion:^{
            
        }];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSData *imageData = UIImagePNGRepresentation(image);
    
    [self doTestUpload:imageData];
}


// unicode解码
+ (NSString *)replaceUnicode:(NSString *)unicodeStr {
    NSString *tempStr1 = [unicodeStr stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData
                                                           mutabilityOption:NSPropertyListImmutable
                                                                     format:NULL
                                                           errorDescription:NULL];
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@"\n"];
}


@end
