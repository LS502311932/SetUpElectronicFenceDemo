//
//  AnimationViewMenu.h
//  ElectronicFenceDemo
//
//  Created by 刘帅 on 2019/5/8.
//  Copyright © 2019 刘帅. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AnimationViewMenu : UIView
@property (nonatomic, assign, getter = isShowing) BOOL show;
@property (nonatomic, strong) UIButton *button1;
@property (nonatomic, strong) UIButton *button2;
@property (nonatomic, assign) NSInteger Tag;
@property (nonatomic, copy) void (^likeButtonClickedOperation)(void);
@property (nonatomic, copy) void (^commentButtonClickedOperation)(void);
@end

NS_ASSUME_NONNULL_END
