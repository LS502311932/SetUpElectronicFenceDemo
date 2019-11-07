//
//  CustomAnnotationView.h
//  CustomAnnotationDemo
//
//  Created by songjian on 13-3-11.
//  Copyright (c) 2013年 songjian. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>

@interface CustomAnnotationView : MAAnnotationView

@property (nonatomic, strong) UIImage *portrait;

@property (nonatomic, strong) UIView *calloutView;
@property (nonatomic, strong) NSString *stateString;
@property (nonatomic, strong) NSString *streetString;
@property (nonatomic, strong) NSString *timeString;
@property (nonatomic, strong) NSString *typeString;
@end
