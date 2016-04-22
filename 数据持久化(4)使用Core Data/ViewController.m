//
//  ViewController.m
//  数据持久化(4)使用Core Data
//
//  Created by Azuo on 16/1/7.
//  Copyright © 2016年 Azuo. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

#define Zline         @"Line"
#define ZlineNumber   @"lineNumber"
#define ZlineText     @"lineText"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //获取托管对象的上下文
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [app managedObjectContext];
    
    //获取请求，并实体描述传递给它
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:Zline];

    //执行请求，并把返回每一个Line对象给array，确保返回的是有效数组；
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if(array == nil)
    {
        NSLog(@"返回无效%@",error);
    }
    
    //通过遍历已获取托管对象的数组，并从中提取每个托管对象的LineNumber和LineText
    for(NSManagedObject* object in array)
    {
        int lineNum = [[object valueForKey:ZlineNumber] intValue];
        NSString *lineText = [object valueForKey:ZlineText];
        
        UITextField *textField = self.arraylines[lineNum];
        textField.text = lineText;
    }
    
    UIApplication *application = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(applicationWillResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:application];
}
-(void)applicationWillResignActiveNotification:(NSNotification *)notification
{
    //获取上下文
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [app managedObjectContext];
    
    for(int i=0 ;i<2; i++)
    {
        UITextField *textfield = self.arraylines[i];
        NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:Zline];
        //设置谓词
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%C = %d)",ZlineNumber,i];
        [request setPredicate:predicate];
        
        //获取存储line对象的数组objects;
        NSError *error;
        NSArray *objects = [context executeFetchRequest:request error:&error];
        
        if(objects ==nil)
        {
            NSLog(@"无法获得请求数据%@",error);
        }
        
        NSManagedObject *managedobject = nil;
        if([objects count]>0)
        {
            //提取一个托管对象进行存储【应该是与上面相似的line托管对象!】
            managedobject = [objects objectAtIndex:0];
        }
        else
        {
            //没有已存在的托管对象
            managedobject = [NSEntityDescription insertNewObjectForEntityForName:Zline inManagedObjectContext:context];
        }
        [managedobject setValue:[NSNumber numberWithInt:i] forKey:ZlineNumber];
        [managedobject setValue:textfield.text forKey:ZlineText];
        
        //最后，通知上下文保存其更改
        [app saveContext];
    }
}

@end
