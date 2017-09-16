//
//  ViewController.m
//  FilterChinese
//
//  Created by 聂文辉 on 2017/9/16.
//  Copyright © 2017年 snow_nwh. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableDictionary *dataDict;

@end

@implementation ViewController
- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}
- (NSMutableDictionary *)dataDict {
    if (!_dataDict) {
        _dataDict = [NSMutableDictionary dictionary];
    }
    return _dataDict;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSLog(@"%@",NSHomeDirectory());
    //遍历文件夹
    ///http://www.cocoachina.com/bbs/read.php?tid=16646
    [self listFileAtPath:NSHomeDirectory()];
    
    //正则查找中文
    ///http://www.cocoachina.com/ios/20151023/13696.html
    NSString *regular = @"@\"[^\"]*[\u4E00-\u9FA5]+[^\"\n]*?\"";
    NSRegularExpression *regularExpression =
    [[NSRegularExpression alloc] initWithPattern:regular
                                         options:1
                                           error:nil];
    
    NSInteger ChineseIndex = 0;
    
    for (NSString *filePath in self.dataSource) {
        ///https://www.2cto.com/kf/201404/290149.html
        NSString* content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        ///http://blog.csdn.net/yanchen_ing/article/details/46458731
        NSArray *array = [regularExpression matchesInString:content options:NSMatchingReportProgress range:NSMakeRange(0, content.length)];
        
        for (NSTextCheckingResult *match in array) {
            
            for (int i = 0; i < [match numberOfRanges]; i++) {
                NSString *component = [content substringWithRange:[match rangeAtIndex:i]];
                /*
                 //如果不需要某些文字，比如图片名字，就进行以下筛选
                 if ([component rangeOfString:@"不要的符号或字"].location != NSNotFound) {
                 continue;
                 }
                 */
                if ([component hasPrefix:@"@\""]) {
                    component = [component substringFromIndex:2];
                }
                if ([component hasSuffix:@"\""]) {
                    component = [component substringToIndex:component.length-1];
                }
                NSLog(@"%@",component);
                [self.dataDict setValue:[NSString stringWithFormat:@"%ld",ChineseIndex++] forKey:component];
            }
            
        }
    }

    
    //写文件
    NSDictionary *fileDic = [NSDictionary dictionaryWithDictionary:self.dataDict];
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"data.plist"];
    BOOL finished = [fileDic writeToFile:filePath atomically:YES];
    if (finished) {
        NSLog(@"😀😀完成查找😀😀");
    }
}

- (void)listFileAtPath:(NSString *)pathName {
    NSArray *contentOfFolder = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:pathName error:NULL];
    for (NSString *aPath in contentOfFolder) {
        NSString * fullPath = [pathName stringByAppendingPathComponent:aPath];
        if ([fullPath hasSuffix:@".m"] || [fullPath hasSuffix:@".mm"]) {
            [self.dataSource addObject:fullPath];
        }
        BOOL isDir;
        if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDir] && isDir) {
            [self listFileAtPath:fullPath];
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
