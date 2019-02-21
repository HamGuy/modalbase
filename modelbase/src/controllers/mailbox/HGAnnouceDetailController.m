//
//  HGAnnouceDetailController.m
//  modelbase
//
//  Created by HamGuy on 7/3/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGAnnouceDetailController.h"
#import "AnnounceMent.h"

@interface HGAnnouceDetailController ()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateTimeLabel;
@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet UITextView *contentView;
@property (nonatomic, weak) IBOutlet UILabel *sendeLael;

@property (nonatomic, strong) AnnounceMent *announcemnet;
@property (nonatomic, strong) UIViewController *leftViewController;

@end

@implementation HGAnnouceDetailController

- (id)initWithAnnouceMnet:(AnnounceMent *)announcement
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.announcemnet = announcement;
        self.title = @"通告";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self addbackButtonWithAction:@selector(goback)];
    self.view.backgroundColor = RGBCOLOR(243, 243, 241);

    self.contentView.layer.borderColor = [RGBCOLOR(251, 251, 251) CGColor];
    self.contentView.layer.borderWidth = 1;
    
    self.titleLabel.text = self.announcemnet.title;
    self.dateTimeLabel.text = self.announcemnet.time;
    self.contentView.text = self.announcemnet.content;
    self.sendeLael.text = self.announcemnet.sender;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.leftViewController = self.mm_drawerController.leftDrawerViewController;
    [self.mm_drawerController setLeftDrawerViewController:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.mm_drawerController setLeftDrawerViewController:self.leftViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)goback{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
