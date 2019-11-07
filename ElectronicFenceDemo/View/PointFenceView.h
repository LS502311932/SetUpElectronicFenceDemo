//
//  PointFenceView.h
//  ActionSheetPicker-3.0
//
//  Created by 刘帅 on 2018/7/26.
//

#import <MAMapKit/MAMapKit.h>

@interface PointFenceView : MAAnnotationView
@property (nonatomic, copy) NSString *name;

@property (nonatomic, strong) UIImage *portrait;

@property (nonatomic, strong) UIView *calloutView;
@end
