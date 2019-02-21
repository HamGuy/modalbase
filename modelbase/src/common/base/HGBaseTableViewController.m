//
//  HGBaseTableViewController.m
//  modelbase
//
//  Created by HamGuy on 5/17/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGBaseTableViewController.h"

@interface HGBaseTableViewController (){
    BOOL isLoading;
}

@end

@implementation HGBaseTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.numberOfSections = 1;
    self.nextPage = 1;
    
    self.tableView.backgroundColor = RGBCOLOR(243, 243, 241);
    
    self.loading = NO;
    
    if (!self.isDisablePull) {
        [self setupRefreshControl];
    }
}

-(void)setupRefreshControl{
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshedByPullingTable:) forControlEvents:UIControlEventValueChanged];
}

-(void) refreshedByPullingTable:(id) sender {
    self.loading = YES;
    [self doRefresh];
}


-(void)setDisablePull:(BOOL)disablePull{
    if (_disablePull == disablePull) {
        return;
    }
    _disablePull = disablePull;
    if (disablePull) {
        self.refreshControl = nil;
    }else{
        [self setupRefreshControl];
    }
}

-(void) doRefresh {
    self.loading = YES;
}

-(void) loadMore {
}


-(void) setLoading:(BOOL)loading
{
    isLoading = loading;
    
    if (_disablePull) {
        return;
    }
    
    if (loading) {
        [self.refreshControl beginRefreshing];
    }else {
        [self.refreshControl endRefreshing];
    }
}
-(BOOL) loading
{
    return isLoading;
}



-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView  {
    return self.numberOfSections + 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section  {
    if(section == self.numberOfSections && !self.endReached)
        return 1;
    return 0;
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    if(indexPath.section == self.numberOfSections)  {
        static NSString *CellIdentifier = @"LoadingCell";
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil)
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            UIActivityIndicatorView *newSpin = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            newSpin.tag = 1234;
            [newSpin startAnimating];
            [newSpin setFrame:CGRectMake(280, 12, 20, 20) ];
            [cell addSubview:newSpin];
            cell.backgroundColor = [UIColor clearColor];
            cell.textLabel.text = NSLocalizedString(@"正在加载…", @"");
            cell.textLabel.textColor = [UIColor colorWithRed:102/255.f green:102/255.f blue:102/255.f alpha:1.0];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.font = [UIFont systemFontOfSize:12];
            cell.textLabel.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
		}
        
        UIActivityIndicatorView *newSpin = (UIActivityIndicatorView *)[cell viewWithTag:1234];
        [newSpin startAnimating];
        
        [self loadMore];
        
		return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == self.numberOfSections) {
        return 44.0f;
    }
    return 0.0f;
}

-(UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

-(void) loadDatas:(BOOL) isFirstPage
{
    self.loading = YES;
}

-(UIView *)nilResultViewWithMessage:(NSString *)message
{
    CGSize size = [message sizeWithFont:[UIFont systemFontOfSize:14.f] constrainedToSize:CGSizeMake(320, MAXFLOAT)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,0, size.width, size.height+15)];
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = RGBCOLOR(136, 136, 136);
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:14];
    label.text = message;
    return label;
}

@end
