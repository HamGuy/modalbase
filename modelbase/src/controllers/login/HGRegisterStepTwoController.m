//
//  HGRegisterStepTwoController.m
//  modelbase
//
//  Created by HamGuy on 5/22/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGRegisterStepTwoController.h"
#import "UIAlertView+Block.h"
#import "HGPopContainerView.h"
#import "HGIDHelper.h"
#import "HGLocationPicker.h"
#import "HGUserInfoService.h"
#import "RadioGroup.h"
#import "RadioBox.h"

@interface HGRegisterStepTwoController ()<UITextFieldDelegate,UITextViewDelegate, UIPickerViewDataSource,UIPickerViewDelegate,HGLocationPickerDelegate>

//main
@property (nonatomic, weak) IBOutlet UIScrollView *scrollContainerView;
@property (nonatomic, weak) IBOutlet UIButton *okBtn;

//model
@property (nonatomic, weak) IBOutlet UIView *modelContainerView;
@property (nonatomic, weak) IBOutlet UITextField *realnameField;
@property (nonatomic, weak) IBOutlet UITextField *wechatFiled1;
@property (nonatomic, weak) IBOutlet UITextField *bodyheightField;
@property (nonatomic, weak) IBOutlet UILabel *locationLabel;
//@property (nonatomic, weak) IBOutlet UILabel *birthDayLabel;
@property (nonatomic, weak) IBOutlet UILabel *bwhLabel;
@property (nonatomic, weak) IBOutlet UIButton *bwhButton;
@property (nonatomic, weak) IBOutlet UITextView *descriptionView;
@property (nonatomic, strong) IBOutlet UIView *bwhContinerView;
@property (nonatomic, strong) IBOutlet UIView *dateContainerView;
@property (nonatomic, strong) IBOutlet UIDatePicker *birthdayPicker;
@property (nonatomic, strong) IBOutlet UIPickerView *bwhPicker;
@property (nonatomic, weak) IBOutlet UITextField *phoneField;
@property (nonatomic, strong) NSString *strB;
@property (nonatomic, strong) NSString *strW;
@property (nonatomic, strong) NSString *strH;


//editor 、vip
@property (nonatomic, weak) IBOutlet UIView *editorContainview;
@property (nonatomic, weak) IBOutlet UITextField *realnameField2;
@property (nonatomic, weak) IBOutlet UITextField *wechatField2;
@property (nonatomic, weak) IBOutlet UITextField *titleField;
@property (nonatomic, weak) IBOutlet UITextField *addressFiled;
@property (nonatomic, weak) IBOutlet UITextField *qqField;
@property (nonatomic, weak) IBOutlet UITextView *descriptionView2;
@property (nonatomic, weak) IBOutlet RadioGroup *cateGroup;
@property (nonatomic, weak) IBOutlet RadioBox *personnalRadioBox;
@property (nonatomic, weak) IBOutlet RadioBox *companyRaidoBox;
@property (nonatomic, weak) IBOutlet UITextField *phoneField2;


@property (nonatomic, strong)  UIViewController *leftViewController;
@property (nonatomic, strong) NSArray *bwhScopes;
@property (nonatomic, strong) NSArray* bScops;

@property (nonatomic, assign) RegisterType registerType;

@property (nonatomic, strong) HGUserInfoService *userInfoService;

@end

@implementation HGRegisterStepTwoController

-(id)initWithRegisterType:(RegisterType)type{
    self = [super initWithNibName:@"HGRegisterStepTwoController" bundle:nil];
    if (self) {
        self.title = @"补充信息";
        self.registerType = type;
        self.userInfoService = [[HGUserInfoService alloc] initWithHostName:nil customHeaderFields:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self addbackButtonWithAction:@selector(goBack)];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:tap];
    
//    UITapGestureRecognizer *birthdayTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBirthday:)];
//    [self.birthDayLabel addGestureRecognizer:birthdayTap];
    
    [self configEditView];
    self.scrollContainerView.scrollEnabled = YES;
    self.scrollContainerView.contentSize = CGSizeMake(SCREEN_WIDTH, is_iPhone5 ? SCREEN_HEIGHT  : SCREEN_HEIGHT + (IS_IOS6() ? 60.0f : 40.f));
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.leftViewController = self.mm_drawerController.leftDrawerViewController;
    [self.mm_drawerController setLeftDrawerViewController:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.mm_drawerController setLeftDrawerViewController:self.leftViewController];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

#pragma mark - Private

-(void)configEditView{
    if (self.registerType != RegisterTypeModel) {
        self.modelContainerView.hidden = YES;
        self.editorContainview.hidden = NO;
        
        self.editorContainview.layer.borderColor = [RGBCOLOR(251, 251, 251) CGColor];
        self.editorContainview.layer.borderWidth = 0.5f;
        
        self.descriptionView2.layer.borderColor = [RGBCOLOR(230, 230, 230) CGColor];
        self.descriptionView2.layer.borderWidth = 0.5f;
        
        [RadioGroup appearance].onTintColor = kCommonHoghtedColor;
        [RadioBox appearance].textFont = [UIFont systemFontOfSize:15.f];
        
        self.personnalRadioBox.value = 0;
        self.personnalRadioBox.text = @"个人";
        
        self.companyRaidoBox.value = 1;
        self.companyRaidoBox.text = @"公司";
        
        self.cateGroup.selectValue = 0;
        
    }else{
        self.modelContainerView.hidden = NO;
        self.editorContainview.hidden = YES;
        
        UITapGestureRecognizer *bhwTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBHW:)];
        [self.bwhLabel addGestureRecognizer:bhwTap];
        
        self.modelContainerView.layer.borderColor = [RGBCOLOR(251, 251, 251) CGColor];
        self.modelContainerView.layer.borderWidth = 0.5f;
    
        self.descriptionView.layer.borderColor = [RGBCOLOR(230, 230, 230) CGColor];
        self.descriptionView.layer.borderWidth = 0.5f;
        
        [self.bwhPicker selectRow:9 inComponent:0 animated:NO];
        [self.bwhPicker selectRow:9 inComponent:1 animated:NO];
        [self.bwhPicker selectRow:9 inComponent:2 animated:NO];

    }
}

-(NSString *)currentRole{
    switch (self.registerType) {
        case RegisterTypeModel:
            return @"model";
            break;
        case RegisterTypeEditor:
            return @"editor";
            break;
        case RegisterTypeVIP:
            return @"vip";
            break;
            
        default:
            break;
    }
    return nil;
}

- (BOOL) checkFieldIsNotEmpty:(UITextField *)field emptyMessage:(NSString *)message{
    NSString *fieldText = [field.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([fieldText length] == 0) {
        
        [UIAlertView showNoticeWithTitle:@"错误" message:message cancelButtonTitle:@"确定"];
        [field becomeFirstResponder];
        
        return NO;
    }
    return YES;
}

- (BOOL) checkLabelIsNotEmpty:(UILabel *)field emptyMessage:(NSString *)message{
    NSString *fieldText = [field.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([fieldText length] == 0) {
        
        [UIAlertView showNoticeWithTitle:@"错误" message:message cancelButtonTitle:@"确定"];
        
        return NO;
    }
    return YES;
}

- (BOOL) checkTextViewIsNotEmpty:(UITextView *)field emptyMessage:(NSString *)message{
    NSString *fieldText = [field.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([fieldText length] == 0) {
        
        [UIAlertView showNoticeWithTitle:@"错误" message:message cancelButtonTitle:@"确定"];
        [field becomeFirstResponder];
        return NO;
    }
    return YES;
}

-(BOOL) isValidateInfo{
    BOOL result = NO;
    if (self.registerType == RegisterTypeModel) {
        result = ([self checkFieldIsNotEmpty:self.realnameField emptyMessage:@"真实姓名不能为空"] &&
                  [self checkFieldIsNotEmpty:self.wechatFiled1 emptyMessage:@"微信不能为空"] &&
                  [self checkFieldIsNotEmpty:self.phoneField emptyMessage:@"电话不能为空"] &&
                  [self checkFieldIsNotEmpty:self.bodyheightField emptyMessage:@"身高不能为空"] &&
                  [self checkLabelIsNotEmpty:self.bwhLabel emptyMessage:@"三围不能为空"] &&
                  [self checkLabelIsNotEmpty:self.locationLabel emptyMessage:@"地区不能为空"] &&
                  [self checkTextViewIsNotEmpty:self.descriptionView emptyMessage:@"个人描述不能为空"]);
    }else{
        result = ([self checkFieldIsNotEmpty:self.realnameField2 emptyMessage:@"真实姓名不能为空"] &&
                  [self checkFieldIsNotEmpty:self.wechatField2 emptyMessage:@"微信不能为空"] &&
                  [self checkFieldIsNotEmpty:self.phoneField2 emptyMessage:@"电话不能为空"] &&
                  [self checkFieldIsNotEmpty:self.titleField emptyMessage:@"职务不能为空"] &&
                  [self checkFieldIsNotEmpty:self.addressFiled emptyMessage:@"地址不能为空"] &&
                  [self checkFieldIsNotEmpty:self.qqField emptyMessage:@"QQ不能为空"] &&
                  [self checkTextViewIsNotEmpty:self.descriptionView2 emptyMessage:@"个人描述不能为空"]);
    }
    return result;
}

#pragma mark - Actions

-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)hideKeyboard{
    [self.view endEditing:YES];
}


-(IBAction)submitApply:(id)sender{
    if ([self isValidateInfo]) {
        NSMutableDictionary *dict =[@{} mutableCopy];
        dict[@"role"]=[self currentRole];
        if (self.registerType == RegisterTypeModel) {
            dict[@"name"]=self.realnameField.text;
            dict[@"phone"]=self.phoneField.text;
            dict[@"wexin"]=self.wechatFiled1.text;
            dict[@"height"]=self.bodyheightField.text;
            dict[@"bdimension"]=self.strB;
            dict[@"hdimension"]=self.strH;
            dict[@"wdimension"]=self.strW;
            dict[@"location"]=self.locationLabel.text;
            dict[@"description"]=self.descriptionView.text;
        }else{
            dict[@"name"]=self.realnameField2.text;
            dict[@"type"] = self.cateGroup.selectValue == 0 ? @"personal" : @"company";
            dict[@"phone"]=self.phoneField2.text;
            dict[@"wexin"]=self.wechatField2.text;
            dict[@"position"]=self.titleField.text;
            dict[@"address"]=self.addressFiled.text;
            dict[@"qq"]=self.qqField.text;
            dict[@"description"]=self.descriptionView2.text;
        }
        
        [self loading];
        __weak typeof(self) mySelf = self;
        [self.userInfoService applyRoleWithInfo:dict Successed:^(MKNetworkOperation *completedOperation, id result) {
            [mySelf successedWitnMessage:@"角色申请成功！"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kShouldRefreshUserNotification object:nil];
            [mySelf.navigationController popToRootViewControllerAnimated:YES];
        } error:^(NSError *error) {
            [mySelf failedWithMessage:@"角色申请失败，请稍后重试！" conmpleted:nil];
        }];
    }
}

-(void)tapBirthday:(UITapGestureRecognizer *)gesture{
    [self hideKeyboard];
    self.dateContainerView.top = SCREEN_HEIGHT - self.dateContainerView.height;    [HGPopContainerView showWithView:self.dateContainerView TapToDismiss:NO];
}

-(void)tapBHW:(UITapGestureRecognizer *)gesture{
    [self hideKeyboard];
    [HGPopContainerView showWithView:self.bwhContinerView animtionDuration:0.3f  TapToDismiss:NO];
}

-(IBAction)tapArea:(UITapGestureRecognizer *)gesture{
    [self hideKeyboard];
    HGLocationPicker *picker = [[HGLocationPicker alloc] initWithDelegate:self];
    [HGPopContainerView showWithView:picker animtionDuration:0.3f TapToDismiss:YES];
}

-(IBAction)confirmBirthday:(id)sender{
    [HGPopContainerView dismiss];
    
}

-(IBAction)confirBWH:(id)sender{
    [HGPopContainerView dismiss];
}

-(IBAction)dateChanged:(UIDatePicker *)picker{
}

-(IBAction)bwhChanged:(UIPickerView *)pickerView{
    
}

-(IBAction)cateValueChanged:(RadioGroup *)radioGroup{
    
}

#pragma mark - UITextFiled Delegate
-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField.text.length==0) {
        return;
    }
    if(textField == self.bodyheightField){
        textField.text = [NSString stringWithFormat:@"%@",textField.text];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (self.modelContainerView.hidden) {
        
        if (self.realnameField2 == textField) {
            [self.wechatField2 becomeFirstResponder];
        }
        if (self.titleField == textField) {
            [self.addressFiled becomeFirstResponder];
        }
        if (self.addressFiled == textField) {
            [self.qqField becomeFirstResponder];
        }
        if (self.qqField == textField) {
            [self.descriptionView2 becomeFirstResponder];
        }

    }else{
        if (self.realnameField == textField) {
            [self.wechatField2 becomeFirstResponder];
        }
        if (self.titleField == textField) {
            [self.addressFiled becomeFirstResponder];
        }
        if (self.addressFiled == textField) {
            [self.qqField becomeFirstResponder];
        }
        if (self.qqField == textField) {
            [self.descriptionView2 becomeFirstResponder];
        }

    }
    return YES;
}

#pragma mark - UIPIckviewDatasource
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 3;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return component == 1 ? self.bScops.count : self.bwhScopes.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [NSString stringWithFormat:@"%@", component == 1 ? self.bScops[row] : self.bwhScopes[row]];
}


-(NSArray *)bwhScopes{
    if(_bwhScopes == nil)
    {
        NSMutableArray *data = [NSMutableArray array];
        for (int i = 80; i<=100; i++) {
            [data addObject:[NSString stringWithFormat:@"%d",i]];
        }
        _bwhScopes = data;
    }
    return _bwhScopes;
}

-(NSArray *)bScops{
    if(_bScops == nil)
    {
        NSMutableArray *data = [NSMutableArray array];
        for (int i = 50; i<=100; i++) {
            [data addObject:[NSString stringWithFormat:@"%d",i]];
        }
        _bScops = data;
    }
    return _bScops;
}



#pragma mark - UIPickerView Delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSInteger indexB,indexW,indexH;
    
    indexB = [pickerView selectedRowInComponent:0];
    indexW = [pickerView selectedRowInComponent:1];
    indexH = [pickerView selectedRowInComponent:2];
    
    self.strB = _bwhScopes[indexB];
    self.strW = _bScops[indexW];
    self.strH = _bwhScopes[indexH];
    
    self.bwhLabel.text = [NSString stringWithFormat:@"%@-%@-%@",_strB,_strW,_strH];
}


#pragma mark - Handle keyboard
- (void)keyboardFrameWillChange:(NSNotification *)notification{
    NSDictionary* info = [notification userInfo];
    CGRect kbRectEnd = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationCurve curve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    __block CGFloat destinationY = 0;
    
    BOOL needShow = kbRectEnd.origin.y == SCREEN_HEIGHT;
    
    if (self.modelContainerView.hidden) {
        if ([self.realnameField2 isFirstResponder] || [self.wechatField2 isFirstResponder]) {
            return;
        }else if([self.titleField isFirstResponder]){
            destinationY = needShow ? 15 : ((is_iPhone5)?15:-132);
        }else{
            destinationY = needShow ? 15 : ((is_iPhone5)?-150:-212);
        }
    }else{
        if (![self.descriptionView isFirstResponder]) {
            return;
        }else{
            destinationY = needShow ? 15 : ((is_iPhone5)?-140:-212);
        }
    }
    
    
    __weak typeof(self) mySelf = self;
    [UIView animateWithDuration:duration delay:0 options:curve<<16 animations:^{
        if (mySelf.modelContainerView.hidden) {
            CGRect viewFrame = mySelf.modelContainerView.frame;
            viewFrame.origin.y = destinationY;
            mySelf.editorContainview.frame = viewFrame;
        }else{
            CGRect viewFrame = mySelf.modelContainerView.frame;
            viewFrame.origin.y = destinationY;
            mySelf.modelContainerView.frame = viewFrame;
        }
    } completion:nil];
}

#pragma mark - HGLocationPiker delegate
-(void)locationPicker:(HGLocationPicker *)locationPicker didSelectLocation:(HGLocation *)location{
    self.locationLabel.text = [NSString stringWithFormat:@"%@-%@",location.state,location.city];
    [HGPopContainerView dismiss];
}

@end
