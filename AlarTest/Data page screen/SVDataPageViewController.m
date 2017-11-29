//
//  SVDataPageViewController.m
//  AlarTestTask
//
//  Created by Dead Inside on 25/11/2017.
//  Copyright © 2017 Sergey Voysyat. All rights reserved.
//

#import "SVDataPageViewController.h"
#import "SVDataRecordTableViewCell.h"
#import "SVMapViewController.h"
#import "SVAPIManager.h"
#import "SVDataPage.h"
#import "SVDataRecord.h"

@interface SVDataPageViewController () <SVAPIManagerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) UIImage *locationIcon;

@property (nonatomic) NSMutableArray *pages;

@property (nonatomic) SVAPIManager *APIManager;

@end

@implementation SVDataPageViewController

static NSString * const kCellReuseIdentifier = @"SVDataRecordTableViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pages = [NSMutableArray array];
    
    self.APIManager = [SVAPIManager defaultManager];
    self.APIManager.delegate = self;
    [self requestNextPage];
    [self.APIManager loadLocationIcon];
    
    [self.tableView registerNib:[UINib nibWithNibName:kCellReuseIdentifier bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kCellReuseIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestNextPage {
    [self.APIManager requestNextPage];
}

#pragma mark - API manager delegate

- (void)didGetRequestedPage:(SVDataPage *)page {
    [self.pages addObject:page];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)didDownloadIcon:(UIImage *)icon {
    self.locationIcon = icon;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}


#pragma mark - UITableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.pages.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    SVDataPage *page = self.pages[section];
    return page.allRecords.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SVDataRecordTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier];
    
    SVDataPage *page = self.pages[indexPath.section];
    SVDataRecord *record = page.allRecords[indexPath.row];
    
    if (self.locationIcon) {
        cell.imageView.image = self.locationIcon;
    }
    cell.nameLabel.text = record.name;
    cell.countryLabel.text = record.country;
    NSLog(@"%lu %lu", indexPath.section, indexPath.row);
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 74.5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SVMapViewController *mvc = [[SVMapViewController alloc] initWithStyle:UITableViewStyleGrouped];
    SVDataPage *page = self.pages[indexPath.section];
    mvc.record = page.allRecords[indexPath.row];
    
    [self showViewController:mvc sender:self];
}

#pragma mark - Scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y + scrollView.bounds.size.height >= scrollView.contentSize.height) {
        [self requestNextPage];
    }
}

@end
