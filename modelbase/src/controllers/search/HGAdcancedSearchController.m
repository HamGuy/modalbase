//
//  HGAdcancedSearchController.m
//  modelbase
//
//  Created by HamGuy on 7/6/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGAdcancedSearchController.h"

@interface HGAdcancedSearchController ()<UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *minHeightField;
@property (nonatomic, weak) IBOutlet UITextField *maxHeightField;

@property (nonatomic, weak) IBOutlet UITextField *minChestField;
@property (nonatomic, weak) IBOutlet UITextField *maxChestField;


@property (nonatomic, weak) IBOutlet UITextField *minWaistlineField;
@property (nonatomic, weak) IBOutlet UITextField *maxWaistlineField;


@property (nonatomic, weak) IBOutlet UITextField *minHiplineField;
@property (nonatomic, weak) IBOutlet UITextField *maxHiplineField;

@property (nonatomic, strong) UIViewController *leftViewController;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollview;

@end

@implementation HGAdcancedSearchController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"高级搜索";
    [self addbackButtonWithAction:@selector(goBack)];
    // Do any additional setup after loading the view from its nib.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
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

#pragma mark - Private
-(NSString *)validDataForUItextFiled:(UITextField *)textfield{
    NSString *text = textfield.text.length > 0 ? textfield.text : @"0";
    return text;
}

-(void)hideKeyboard{
    [self.minChestField resignFirstResponder];
    [self.minHeightField resignFirstResponder];
    [self.minHiplineField resignFirstResponder];
    [self.minWaistlineField resignFirstResponder];
    [self.maxWaistlineField resignFirstResponder];
    [self.maxHiplineField resignFirstResponder];
    [self.maxHeightField resignFirstResponder];
    [self.maxChestField resignFirstResponder];
}

#pragma mark - Action
-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)performAdvancedSearch:(id)sender{
    NSDictionary *userInfo = @{@"requesttype": @"searchdetail",
                               @"heightlow":[self validDataForUItextFiled:self.minHeightField],
                               @"heighthigh":[self validDataForUItextFiled:self.maxHeightField],
                               @"blow":[self validDataForUItextFiled:self.minChestField],
                               @"bhigh":[self validDataForUItextFiled:self.maxChestField],
                               @"hlow":[self validDataForUItextFiled:self.minHiplineField],
                               @"hhigh":[self validDataForUItextFiled:self.minHiplineField],
                               @"wlow":[self validDataForUItextFiled:self.minWaistlineField],
                               @"whigh":[self validDataForUItextFiled:self.maxWaistlineField]};
    [[NSNotificationCenter defaultCenter] postNotificationName:KAdvacenedSearch object:nil userInfo:userInfo];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UItextField Delegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (range.location>2) {
        textField.text = @"999";
        return NO;
    }
    return YES;
}

#pragma mark - Handle keyboard
- (void)keyboardFrameWillChange:(NSNotification *)notification{
    if ([self.minHeightField isFirstResponder] || [self.maxHeightField isFirstResponder]) {
        return;
    }
    
    NSDictionary* info = [notification userInfo];
    CGRect kbRectEnd = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationCurve curve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    __weak typeof(self) mySelf = self;
    
    [UIView animateWithDuration:duration delay:0 options:curve<<16 animations:^{
        if (kbRectEnd.origin.y==SCREEN_HEIGHT) {
            [mySelf.scrollview setContentOffset:CGPointMake(0, 0) animated:YES];
        } else{
            [mySelf.scrollview setContentOffset:CGPointMake(0, 100) animated:YES];
        }
    } completion:nil];
}

@end
