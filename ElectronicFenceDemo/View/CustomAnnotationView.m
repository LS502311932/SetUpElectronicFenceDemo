//
//  CustomAnnotationView.m
//  CustomAnnotationDemo
//
//  Created by songjian on 13-3-11.
//  Copyright (c) 2013年 songjian. All rights reserved.
//

#import "CustomAnnotationView.h"
#import "CustomCalloutView.h"
//#import "TitleContentVIew.h"
//#import "BaseHelper.h"
//#import "SKCommonDefine.h"
//#import "UIView+category.h"
//#import "SKNameValueView.h"

#define kWidth  30.f
#define kHeight 30.f

#define kHoriMargin 5.f
#define kVertMargin 5.f

#define kPortraitWidth  30.f
#define kPortraitHeight 20.f

#define kCalloutWidth   280.0f
#define kCalloutHeight  100.0f

@interface CustomAnnotationView ()

@property (nonatomic, strong) UIImageView           *portraitImageView;
//@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel                *stateLabel;
//@property (nonatomic, strong) TitleContentView       *streetLabel;
//@property (nonatomic, strong) SKNameValueView        *timeLabel;
//@property (nonatomic, strong) SKNameValueView        *locationTypeLabel;
@end

@implementation CustomAnnotationView

@synthesize calloutView;
@synthesize portraitImageView   = _portraitImageView;
//@synthesize nameLabel           = _nameLabel;

#pragma mark - Handle Action

- (void)btnAction
{
    CLLocationCoordinate2D coorinate = [self.annotation coordinate];
    
    NSLog(@"coordinate = {%f, %f}", coorinate.latitude, coorinate.longitude);
}

#pragma mark - Override

- (UIImage *)portrait
{
    return self.portraitImageView.image;
}

- (void)setPortrait:(UIImage *)portrait
{
    self.portraitImageView.image = portrait;
}

- (void)setSelected:(BOOL)selected
{
    [self setSelected:selected animated:NO];
}

- (void)setStateString:(NSString *)stateString{
    _stateString = stateString;
}

- (void)setStreetString:(NSString *)streetString{
    _streetString = streetString;
}

- (void)setTimeString:(NSString *)timeString{
    _timeString = timeString;
}

- (void)setTypeString:(NSString *)typeString{
    _typeString = typeString;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (self.selected == selected)
    {
        return;
    }
    
    if (selected)
    {
        if (self.calloutView == nil)
        {
            NSLog(@"_streetString.length = %d",_streetString.length);
            CGFloat streetHeight = 0;
            if (_streetString.length <= 13) {
                
                self.calloutView = [[CustomCalloutView alloc] initWithFrame:CGRectMake(0, 0, kCalloutWidth, kCalloutHeight)];
                streetHeight = 20;
            }else if (_streetString.length <=26 && _streetString.length>13){
                
                self.calloutView = [[CustomCalloutView alloc] initWithFrame:CGRectMake(0, 0, kCalloutWidth, kCalloutHeight+20)];
                streetHeight = 40;
            }else if (_streetString.length <=39 && _streetString.length >26){
                
                self.calloutView = [[CustomCalloutView alloc] initWithFrame:CGRectMake(0, 0, kCalloutWidth, kCalloutHeight+40)];
                streetHeight = 60;
            }else if (_streetString.length <= 52 && _streetString.length >39){
                
                self.calloutView = [[CustomCalloutView alloc] initWithFrame:CGRectMake(0, 0, kCalloutWidth, kCalloutHeight+60)];
                streetHeight = 80;
            }
            /* Construct custom callout. */
            
            self.calloutView.center = CGPointMake(CGRectGetWidth(self.bounds) / 5.f + self.calloutOffset.x+5,-CGRectGetHeight(self.calloutView.bounds) / 2.f + self.calloutOffset.y);
            self.calloutView.backgroundColor = [UIColor clearColor];
            
            _stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(125, 5, 80, 16)];
            _stateLabel.backgroundColor = [UIColor clearColor];
            if ([_stateString isEqualToString:@"未连接"]) {
                _stateLabel.textColor = [UIColor redColor];
            }else{
                _stateLabel.textColor = [UIColor blueColor];
            }
            _stateLabel.font = [UIFont systemFontOfSize:13];
            _stateLabel.text = _stateString;
            [self.calloutView addSubview:_stateLabel];
        }
        [self addSubview:self.calloutView];
    }
    [super setSelected:selected animated:animated];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL inside = [super pointInside:point withEvent:event];
    /* Points that lie outside the receiver’s bounds are never reported as hits,
     even if they actually lie within one of the receiver’s subviews.
     This can occur if the current view’s clipsToBounds property is set to NO and the affected subview extends beyond the view’s bounds.
     */
    if (!inside && self.selected)
    {
        inside = [self.calloutView pointInside:[self convertPoint:point toView:self.calloutView] withEvent:event];
    }
    
    return inside;
}

#pragma mark - Life Cycle

- (id)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.bounds = CGRectMake(0.f, 0.f, kWidth, kHeight);
        
        self.backgroundColor = [UIColor clearColor];
        
        /* Create portrait image view and add to view hierarchy. */
        self.portraitImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kWidth, kHeight)];
        [self addSubview:self.portraitImageView];
        
    }
    
    return self;
}

@end
