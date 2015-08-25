//
//  CCViewController.m
//  CCNetWorking
//
//  Created by huangcheng on 07/13/2015.
//  Copyright (c) 2015 huangcheng. All rights reserved.
//

#import "CCViewController.h"
#import "CCLoginManager.h"

@interface CCViewController ()<CCAPIManagerParamSourceDelegate,CCAPIManagerCallbackDataReformer,CCAPIManagerApiCallbackDelegate>{
    CCLoginManager *loginmanager;
}

@end

@implementation CCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    loginmanager = [[CCLoginManager alloc]init];
    loginmanager.paramSource = self;
    loginmanager.delegate = self;
    [loginmanager loadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSDictionary *)paramsForApi:(CCAPIBaseManager *)manager{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
    dictionary[@"page"] = @(0);
    dictionary[@"per_page"] = @(20);
    dictionary[@"auction_type"] = @"realtime";
    dictionary[@"token"]= @"87f6550f3981459fc3f6c2458dc9f4b2";
    return dictionary;
}
- (id)manager:(CCAPIBaseManager *)manager reformData:(NSDictionary *)data{
    NSLog(@"data %@",data);
    return data;
}


- (void)managerCallApiDidFailed:(CCAPIBaseManager *)manager{
    NSLog(@"fail %@",manager);
}

- (void)managerCallApiDidSuccess:(CCAPIBaseManager *)manager{
    NSLog(@"success manager %@",manager);
    [manager fetchDataWithReformer:self];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [loginmanager loadData];
}

@end
