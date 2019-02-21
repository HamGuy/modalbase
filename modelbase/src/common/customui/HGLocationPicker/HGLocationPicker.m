//
//  HGLocationPicker.m
//  modelbase
//
//  Created by HamGuy on 5/30/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGLocationPicker.h"

#define kDuration 0.3

@interface HGLocationPicker ()<UIPickerViewDataSource,UIPickerViewDelegate>{
    HGLocation *location;
}


@property (strong, nonatomic) IBOutlet UIPickerView *locatePicker;
@property (nonatomic, strong) NSArray *provinces;
@property (nonatomic, strong) NSArray *cities;
@property (nonatomic, weak) id<HGLocationPickerDelegate> delegate;
@property (nonatomic, weak) IBOutlet UIButton *okBtn;

@end

@implementation HGLocationPicker

- (id)initWithDelegate:(id<HGLocationPickerDelegate>)delegate
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"HGLocationPicker" owner:self options:nil] objectAtIndex:0];
    if (self) {
        self.delegate = delegate;
        self.locatePicker.dataSource=self;
        self.locatePicker.delegate = self;
        
        //加载数据
        self.provinces = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ProvincesAndCities.plist" ofType:nil]];
        self.cities = [[self.provinces objectAtIndex:0] objectForKey:@"Cities"];
        
        //初始化默认数据
        location = [[HGLocation alloc] init];
        location.state = [[self.provinces objectAtIndex:0] objectForKey:@"State"];
        location.city = [[self.cities objectAtIndex:0] objectForKey:@"city"];
        location.latitude = [[[self.cities objectAtIndex:0] objectForKey:@"lat"] doubleValue];
        location.longitude = [[[self.cities objectAtIndex:0] objectForKey:@"lon"] doubleValue];
    }
    return self;
}

//- (void)showInView:(UIView *) view
//{
//    CATransition *animation = [CATransition  animation];
//    animation.delegate = self;
//    animation.duration = kDuration;
//    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    animation.type = kCATransitionPush;
//    animation.subtype = kCATransitionFromTop;
//    [self setAlpha:1.0f];
//    [self.layer addAnimation:animation forKey:@"DDLocateView"];
//    
//    self.frame = CGRectMake(0, view.frame.size.height - self.frame.size.height, self.frame.size.width, self.frame.size.height);
//    
//    [view addSubview:self];
//}

#pragma mark - PickerView lifecycle

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return [self.provinces count];
            break;
        case 1:
            return [self.cities count];
            break;
        default:
            return 0;
            break;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return [[self.provinces objectAtIndex:row] objectForKey:@"State"];
            break;
        case 1:
            return [[self.cities objectAtIndex:row] objectForKey:@"city"];
            break;
        default:
            return nil;
            break;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    switch (component) {
        case 0:
            self.cities = [[self.provinces objectAtIndex:row] objectForKey:@"Cities"];
            [self.locatePicker selectRow:0 inComponent:1 animated:NO];
            [self.locatePicker reloadComponent:1];
            
            location.state = [[self.provinces objectAtIndex:row] objectForKey:@"State"];
            location.city = [[self.cities objectAtIndex:0] objectForKey:@"city"];
            location.latitude = [[[self.cities objectAtIndex:0] objectForKey:@"lat"] doubleValue];
            location.longitude = [[[self.cities objectAtIndex:0] objectForKey:@"lon"] doubleValue];
            break;
        case 1:
            location.city = [[self.cities objectAtIndex:row] objectForKey:@"city"];
            location.latitude = [[[self.cities objectAtIndex:row] objectForKey:@"lat"] doubleValue];
            location.longitude = [[[self.cities objectAtIndex:row] objectForKey:@"lon"] doubleValue];
            break;
        default:
            break;
    }
}


#pragma mark - Button 

- (IBAction)locate:(id)sender {
    CATransition *animation = [CATransition  animation];
    animation.delegate = self;
    animation.duration = kDuration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromBottom;
    [self setAlpha:0.0f];
    [self.layer addAnimation:animation forKey:@"TSLocateView"];
    [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:kDuration];
    if(self.delegate && [self.delegate respondsToSelector:@selector(locationPicker:didSelectLocation:)]) {
        [self.delegate locationPicker:self didSelectLocation:self.location];
    }
}

-(HGLocation *)location{
    return location;
}

@end
