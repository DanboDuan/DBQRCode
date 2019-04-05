//
//  DemoViewController.m
//  Demo
//
//  Created by bob on 2019/2/21.
//  Copyright © 2019 bob. All rights reserved.
//

#import "DemoViewController.h"
#import <DBQRCode/DBQRCodeScanViewController.h>

NSString * const CellReuseIdentifier = @"UITableViewCell_ri";


@interface FeedModel : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *actionVCName;
@property (nonatomic, assign) NSInteger action;

@end

@implementation FeedModel



@end

static NSArray *testFeedList() {
    NSMutableArray *array = [NSMutableArray array];

    [array addObject:({
        FeedModel *model = [FeedModel new];
        model.title = @"Generate QR/Bar Code";
        model.actionVCName = @"GenerateViewController";
        model;
    })];

    [array addObject:({
        FeedModel *model = [FeedModel new];
        model.title = @"Scan QR/Bar Code";
        model.actionVCName = @"ScanViewController";
        model;
    })];

    [array addObject:({
        FeedModel *model = [FeedModel new];
        model.title = @"SDK scan VC";
        model.action = 1;
        model;
    })];

    return array;
}

@interface DemoViewController ()

@property (nonatomic, strong) NSArray *feedList;

@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellReuseIdentifier];
    self.feedList = testFeedList();
    self.navigationItem.title = @"Demo";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Setting" style:(UIBarButtonItemStylePlain) target:self action:@selector(clickRight)];
}

- (void)clickRight {
    NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.feedList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellReuseIdentifier];
    if (!cell) {
        cell = [UITableViewCell new];
    }
    FeedModel *model = [self.feedList objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%zd: %@",(NSInteger)(indexPath.row + 1),model.title];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedModel *model = [self.feedList objectAtIndex:indexPath.row];
    if (model.actionVCName.length) {
        UIViewController *vc = (UIViewController *)[NSClassFromString(model.actionVCName) new];
        vc.navigationItem.title = model.title;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        DBQRCodeScanViewController *vc = [[DBQRCodeScanViewController alloc] initWithCallback:^(NSString * _Nullable code, NSError * _Nullable error) {
            NSLog(@"%@",code);
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end

