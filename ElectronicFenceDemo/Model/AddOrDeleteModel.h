//
//  AddOrDeleteModel.h
//  ElectronicFenceDemo
//
//  Created by 刘帅 on 2019/5/9.
//  Copyright © 2019 刘帅. All rights reserved.
//

#import <JSONModel/JSONModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface AddOrDeleteModel : JSONModel
@property (nonatomic, strong) NSString              *shape;
@property (nonatomic, strong) NSString              *elementNum;//2圆形、大于二是多边形
@property (nonatomic, strong) NSString              *cycle;
@property (nonatomic, strong) NSString              *name;
@property (nonatomic, strong) NSString              *areaNumber;
@property (nonatomic, strong) NSString              *element1;
@property (nonatomic, strong) NSString              *element2;
@property (nonatomic, strong) NSString<Optional>    *element3;
@property (nonatomic, strong) NSString<Optional>    *element4;
@property (nonatomic, strong) NSString<Optional>    *element5;
@property (nonatomic, strong) NSString<Optional>    *element6;
@property (nonatomic, strong) NSString<Optional>    *element7;
@property (nonatomic, strong) NSString<Optional>    *element8;
@end

NS_ASSUME_NONNULL_END
