//
//  HGAppDelegate.m
//  modelbase
//
//  Created by HamGuy on 5/15/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGAppDelegate.h"
#import "HGLeftViewController.h"
#import "HGMMDrawerController.h"
#import "HGShreKitApi.h"
#import <UI7Kit/UI7Kit.h>
#import <UI7Kit/UI7PickerView.h>
#import <UI7Kit/UI7ActionSheet.h>
#import <UI7Kit/UI7SegmentedControl.h>
#import <UI7Kit/UI7SearchBar.h>
#import <MagicalRecord/CoreData+MagicalRecord.h>
#import "HGCurretUserContext.h"
#import "HGLocalAblumsManager.h"
#import "HGSandboxHelper.h"
#import <TestFlightSDK/TestFlight.h>

@implementation HGAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    HGLeftViewController *leftController = [[HGLeftViewController alloc] init];
    _centerController = [[HGNavigationController alloc] initWithRootViewController:self.homeViewController];
    HGMMDrawerController *drawController = [[HGMMDrawerController alloc] initWithCenterViewController:_centerController leftDrawerViewController:leftController];

    [[HGShareKit sharedInstance] registerSinaWeiboKey:kWeiBoKey secret:kWeiBoSecretKey redirect:kRediretUrl];
    [[HGShareKit sharedInstance] registerWechat:kWeChatKey];
    
    if (IS_IOS6()) {
        [UI7View patchIfNeeded];
        [UI7Button patchIfNeeded];
        [UI7AlertView patchIfNeeded];
        [UI7SegmentedControl patchIfNeeded];
        [UI7PickerView patchIfNeeded];
        [UI7SearchBar patchIfNeeded];
        [UI7ActionSheet patchIfNeeded];
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//    NSArray *testList = [[HGLocalAblumsManager sharedInstance] allPicsOfAblum:@"1123456789"];
//    CGFloat test = [HGSandboxHelper getTotalDiskSpace];
    
    
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"modelbasev1.sqlite"];
    
    [self deleteOldSqliteFileIfNeeded:@"modelbase.sqlite"];
    [TestFlight takeOff:@"5238c1e8-e558-45d7-81f0-3f12fb4a6f2c"];
    self.window.backgroundColor = [UIColor whiteColor];
    
    self.window.rootViewController = drawController;
    [self.window makeKeyAndVisible];
    
    
    
    return YES;
}

//-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
//    [[HGShareKit sharedInstance] handleOpenURL:url];
//    return YES;
//}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    [[HGShareKit sharedInstance] handleOpenURL:url];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    [[self centerController].mm_drawerController closeDrawerAnimated:YES
                                                          completion:nil];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //删除临时文件
    [HGSandboxHelper clearTmpDirectory];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //删除临时文件
    [HGSandboxHelper clearTmpDirectory];
    [self createNeedDirectories];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [MagicalRecord cleanUp];
}

#pragma mark - Private
-(void)createNeedDirectories{
    [self createDirectoryIfNeeded:KDownLoadCoverDirectoryName];
    [self createDirectoryIfNeeded:kFileToUplaodDirectoryName];
    [self createDirectoryIfNeeded:kDownloadedDirectoyName];
    [self createDirectoryIfNeeded:kLocalCoverDirectoryName];
    [self createDirectoryIfNeeded:kFileToUploadThumDirectry];
}

-(void)createDirectoryIfNeeded:(NSString *)name{
    if (![[HGSandboxHelper sharedInstance] isDirectoryExist:name]) {
        [[HGSandboxHelper sharedInstance] createDirectory:name];
        NSString *strUrl = [[[HGSandboxHelper sharedInstance] getAppMainDocumentDirectory] stringByAppendingPathComponent:name];
        NSURL *url = [NSURL URLWithString:strUrl];
        //防止iCloud备份
        [self addSkipBackupAttributeToItemAtURL:url];
    }
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)url
{
    if (url == nil) {
        return NO;
    }
    if (([[NSFileManager defaultManager] fileExistsAtPath: [url path]])) {
        NSError *error = nil;
        BOOL success = [url setResourceValue: [NSNumber numberWithBool: YES]
                                      forKey: NSURLIsExcludedFromBackupKey error: &error];
        if(!success){
            DLog(@"Error excluding %@ from backup %@", [url lastPathComponent], error);
        }else{
            DLog(@"Success add with url = %@",url.absoluteString);
        }
        return success;
    }
    return NO;
}

-(void)deleteOldSqliteFileIfNeeded:(NSString *)filePath{
    NSFileManager *fileManeger = [NSFileManager defaultManager];
    NSError *error = nil;
    if ([fileManeger fileExistsAtPath:filePath]) {
        if ([fileManeger isDeletableFileAtPath:filePath]) {
            [fileManeger removeItemAtPath:filePath error:&error];
            if (error) {
                DLog(@"delete sqlite file with error : %@",error);
            }
        }
    }
}


#pragma mark - UIviewControllers
-(HGHomeViewController *)homeViewController{
    if(_homeViewController==nil) {
        _homeViewController = [[HGHomeViewController alloc] init];
    }
    return _homeViewController;
}

-(HGAblumListController *)newsAblumListController{
    if(_newsAblumListController==nil){
        _newsAblumListController = [[HGAblumListController alloc] initWithAblumType:AblumTypeNew];
    }
    return _newsAblumListController;
}

-(HGAblumListController *)recAblumListController{
    if(_recAblumListController==nil){
        _recAblumListController = [[HGAblumListController alloc] initWithAblumType:AblumTypeRec];
    }
    return _recAblumListController;
}

-(HGAblumListController *)vipAblumListController{
    if(_vipAblumListController==nil){
        _vipAblumListController = [[HGAblumListController alloc] initWithAblumType:AblumTypeVip];
    }
    return _vipAblumListController;
}

-(HGAblumListController *)copAblumListController{
    if(_copAblumListController==nil){
        _copAblumListController = [[HGAblumListController alloc] initWithAblumType:AblumTypeCop];
    }
    return _copAblumListController;
}

-(HGMessageListController *)msgListController{
    if(_msgListController == nil){
        _msgListController = [[HGMessageListController alloc] init];
    }
    return  _msgListController;
}

-(HGContactUsController *)contactUsController{
    if(_contactUsController==nil){
        _contactUsController = [[HGContactUsController alloc] init];
    }
    return _contactUsController;
}

-(HGUserCenterController *)userCenterController{
    if(_userCenterController == nil){
        _userCenterController = [[HGUserCenterController alloc] initWithUserName:[HGCurretUserContext sharedInstance].username];
    }
    return _userCenterController;
}

-(HGLoginController *)loginController{
    if(_loginController == nil){
        _loginController = [[HGLoginController alloc] init];
    }
    return _loginController;
}

-(HGSearchController *)searchController{
    if (_searchController == nil) {
        _searchController = [[HGSearchController alloc] init];
    }
    return _searchController;
}
@end
