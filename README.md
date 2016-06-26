## 案例简介
一个使用iOS开发的API调用

## 说明
> 该案例包含了HTTP的GET、POST及文件上传&下载demo

### 安装环境

- 安装Xcode
> App Store 下载

- 安装CocoaPods
> sudo gem install cocoapods

### 创建项目

- 打开Xcode

- 创建一个新工程
>* 启动Xcode后，在主界面点击“<code>Create a new Xcode project</code>”；或点击菜单栏里的“<code>File -> New -> Project</code>”
>* 选择“<code>iOS -> Application -> Single View Application</code>”，点击“<code>Next</code>”

- 填写工程基本信息
>* <code>Product Name</code> 你的App的名字，建议使用英文字母，最好不要有空格和特殊字符
>* <code>Organization Name</code> 你的组织/公司的名字
>* <code>Organization Identifier</code> 你的组织/公司的唯一标识，一般用你的域名的反向形式
>* <code>Language</code> 选择 Objective-C
>* <code>Device</code> 选择 iPhone，Universal 表示iPhone 和 iPad 都兼容
>* <code>Use Core Data</code>
>* <code>Include Unit Tests</code>
>* <code>Include UI Tests</code>
>* 填完之后，点击<code>Next</code>，进入下一步

### 导入AFNetworking

- 创建<code> Podfile </code>文件
>* 在工程根目录创建名为<code> Podfile </code>的空文件
>* 编辑文件，并输入形如下面的内容
<pre>
platform :ios, '9.0'
pod 'AFNetworking', '~> 3.1.0'
</pre>

- 载入类库
>* 建立podspec索引 <code>pod setup</code>
>* 下载导入 <code>pod install</code>
>* 更新升级 <code>pod update</code>

如果在pod install、或者pod update时，不想升级specs库，可以增加忽略参数
<pre>
pod install --no-repo-update
pod update --no-repo-update
</pre>

### 完成API接口调用

- 准备AFHTTPSessionManager

<pre>
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
</pre>

- GET请求

<pre>
NSMutableDictionary *params = @{@"key1":@"value1",@"key2":@"value2"};

[self.manager GET:@"请求的url" parameters: params progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"成功");
} failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"失败");        
}];
</pre>

- POST请求

<pre>
NSMutableDictionary *params = @{@"key1":@"value1",@"key2":@"value2"};

[self.manager POST:@"请求的url" parameters: params progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"成功");
} failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"失败");        
}];
</pre>

- 文件上传

<pre>
NSMutableDictionary *params = @{@"key1":@"value1",@"key2":@"value2"};

[self.manager POST:@"请求的url" parameters: params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //上传文件
        UIImage *iamge = [UIImage imageNamed:@"文件名.png"];
        NSData *data = UIImagePNGRepresentation(iamge);
        //设置参数
        [formData appendPartWithFileData:data name:@"file" fileName:@"文件名.png" mimeType:@"image/png"];

} progress:^(NSProgress * _Nonnull uploadProgress) {
        //更新上传进度
        long long totalCount = (long long)uploadProgress.totalUnitCount;
        long long curentCount = (long long)uploadProgress.completedUnitCount;
        NSLog(@"%lld", curentCount*100/totalCount);

} success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"成功");

} failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"失败");        

}];
</pre>

- 文件下载

<pre>
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
</pre>
