//
//  ViewController.m
//  ElectronicFenceDemo
//
//  Created by 刘帅 on 2019/5/7.
//  Copyright © 2019 刘帅. All rights reserved.
//

#import "ViewController.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import "AnimationViewMenu.h"
#import "CustomAnnotationView.h"
#import "PointFenceView.h"
#import "AddOrDeleteModel.h"
#import "AMapTipAnnotation.h"

@interface ViewController ()<MAMapViewDelegate,AMapGeoFenceManagerDelegate,AMapSearchDelegate, UISearchBarDelegate, UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate>
@property (nonatomic, strong) MAMapView             *mapView;
@property (nonatomic, strong) NSMutableArray        *polygons;
@property (nonatomic, strong) UIButton              *fenceButton;
@property (nonatomic, strong) UIButton              *polygonBtn;//多边形
@property (nonatomic, strong) UIButton              *circleBtn;//圆形
@property (nonatomic, strong) UIButton              *saveButton;
@property (nonatomic, strong) UIButton              *clearButton;
@property (nonatomic, strong) UIView                *buttonsView;
@property (nonatomic, strong) UIButton              *increaseButton;
@property (nonatomic, strong) UIButton              *decreaseButton;
@property (nonatomic, strong) UIButton              *finishBtn;
@property (nonatomic, assign) BOOL                  isPolygonFence;
@property (nonatomic, assign) BOOL                  isCircleFence;
@property (nonatomic, assign) BOOL                  isHaveCircle;
@property (nonatomic, assign) BOOL                  isOverEightPoints;
@property (nonatomic, strong) NSString              *radiusNumber;
//一个search对象，用于地理位置逆编码
@property (nonatomic, strong) AMapSearchAPI          *search;

@property (nonatomic, strong) NSMutableArray         *pointArray;
@property (nonatomic, strong) AMapGeoPoint           *pointModel;
@property (nonatomic, strong) NSMutableArray         *showFenceListArray;
@property (nonatomic, strong) NSArray                *circlesArray;

@property (nonatomic, strong) AMapGeoFenceManager    *geoFenceManager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置电子围栏";
    self.view.backgroundColor = [UIColor whiteColor];
    _isPolygonFence = NO;
    _isCircleFence = NO;
    _isOverEightPoints = NO;
    [AMapServices sharedServices].apiKey = @"493ac2a4a7387c8cd791bf71fe64ca77";
    _pointArray = [NSMutableArray array];
    _polygons = [NSMutableArray array];
    self.showFenceListArray = [NSMutableArray array];
    _pointModel = [AMapGeoPoint new];
    ///地图需要v4.5.0及以上版本才必须要打开此选项（v4.5.0以下版本，需要手动配置info.plist）
    [AMapServices sharedServices].enableHTTPS = YES;
    ///初始化地图
    if (is_iPhoneX || IS_IPHONE_Xr || IS_IPHONE_Xs || IS_IPHONE_Xs_Max) {
        _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 84, SCREEN_WIDTH, SCREEN_HEIGHT-84)];
    }else{
        _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, kStatusBarAndNavigationBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT-kStatusBarAndNavigationBarHeight)];
    }
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _mapView.showsCompass= NO; // 设置成NO表示关闭指南针；YES表示显示指南针
    _mapView.showsScale = YES;
    
    //设置MapView的委托为自己
    self.mapView.delegate = self;
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    [self.view addSubview:_mapView];
    ///如果您需要进入地图就显示定位小蓝点，则需要下面两行代码
    //    _mapView.customizeUserLocationAccuracyCircleRepresentation = YES;//是否自定义用户位置精度圈
    _mapView.centerCoordinate = self.mapView.userLocation.coordinate;
    _mapView.pausesLocationUpdatesAutomatically = NO;
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = MAUserTrackingModeFollow;
//    NSLog(@"_mapView.userLocation = %@",_mapView.userLocation);
    //设置定位精度
    _mapView.desiredAccuracy = kCLLocationAccuracyBest;
    [self.mapView setZoomLevel:15 animated:YES];
    
    _fenceButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _fenceButton.frame = CGRectMake(SCREEN_WIDTH - 60, kStatusBarAndNavigationBarHeight+50,50 , 90);
    _fenceButton.titleLabel.lineBreakMode = UILineBreakModeWordWrap;//换行模式自动换行
    [_fenceButton setImage:[UIImage imageNamed:@"icon_weilan"] forState:UIControlStateNormal];
    [_fenceButton setTitle:@"设置围栏" forState:UIControlStateNormal];
    _fenceButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [_fenceButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _fenceButton.titleLabel.numberOfLines = 2;
    _fenceButton.layer.cornerRadius = 5;
    //    _fenceButton.layer.masksToBounds = YES;
    [_fenceButton addTarget:self action:@selector(pressSelectGraphics:) forControlEvents:UIControlEventTouchUpInside];
    [_fenceButton setBackgroundColor:[UIColor whiteColor]];
    _fenceButton.layer.shadowOffset = CGSizeMake(1, 1);
    _fenceButton.layer.shadowOpacity = 0.7;
    _fenceButton.alpha = 0.7;
    _fenceButton.layer.shadowColor =  [UIColor blackColor].CGColor;
    _fenceButton.imageEdgeInsets = UIEdgeInsetsMake(-10,10,30,0);
    [_fenceButton setTitleEdgeInsets:UIEdgeInsetsMake(50, -25, 10, 0)];
    
    [self.view addSubview:_fenceButton];
    [_mapView bringSubviewToFront:_fenceButton];
    [self.view bringSubviewToFront:_fenceButton];
    
    _buttonsView = [[UIView alloc] init];
    _buttonsView.frame = CGRectMake(SCREEN_WIDTH-60, kStatusBarAndNavigationBarHeight+50, 50, 200);
    _buttonsView.backgroundColor = [UIColor whiteColor];
    _buttonsView.layer.cornerRadius = 5;
    _buttonsView.layer.shadowOffset = CGSizeMake(1, 1);
    _buttonsView.layer.shadowOpacity = 0.7;
    _buttonsView.alpha = 0.7;
    _buttonsView.layer.shadowColor =  [UIColor blackColor].CGColor;
    _buttonsView.hidden = YES;
    
    [self.view addSubview:_buttonsView];
    [self.view bringSubviewToFront:_buttonsView];
    
    _circleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _circleBtn.frame = CGRectMake(0, 0, _buttonsView.frame.size.width, _buttonsView.frame.size.height/4 +10);
    [_circleBtn setTitle:@"圆形" forState:UIControlStateNormal];
    [_circleBtn setBackgroundColor:[UIColor whiteColor]];
    [_circleBtn setImage:[UIImage imageNamed:@"yuan"] forState:UIControlStateNormal];
    [_circleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _circleBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    _circleBtn.imageEdgeInsets = UIEdgeInsetsMake(-20, 12, 0, 10);
    _circleBtn.titleEdgeInsets = UIEdgeInsetsMake(25, -25, 0, 0);
    [_circleBtn addTarget:self action:@selector(changeCircle) forControlEvents:UIControlEventTouchUpInside];
    _circleBtn.hidden = YES;
    [_buttonsView addSubview:_circleBtn];
    
    _polygonBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _polygonBtn.frame = CGRectMake(0, _buttonsView.frame.size.height/4+10, _buttonsView.frame.size.width, _buttonsView.frame.size.height/4);
    [_polygonBtn setTitle:@"多边形" forState:UIControlStateNormal];
    [_polygonBtn setBackgroundColor:[UIColor whiteColor]];
    [_polygonBtn setImage:[UIImage imageNamed:@"duobian"] forState:UIControlStateNormal];
    [_polygonBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _polygonBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    _polygonBtn.imageEdgeInsets = UIEdgeInsetsMake(-20, 13, 0, 10);
    _polygonBtn.titleEdgeInsets = UIEdgeInsetsMake(25, -20, 0, 0);
    [_polygonBtn addTarget:self action:@selector(changePolygon) forControlEvents:UIControlEventTouchUpInside];
    _polygonBtn.hidden = YES;
    [_buttonsView addSubview:_polygonBtn];
    
    _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _saveButton.frame = CGRectMake(0, _buttonsView.frame.size.height/2+10, _buttonsView.frame.size.width, _buttonsView.frame.size.height/4-10);
    [_saveButton setTitle:@"完 成" forState:UIControlStateNormal];
    [_saveButton setBackgroundColor:[UIColor whiteColor]];
    [_saveButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_saveButton addTarget:self action:@selector(pressSaveFence) forControlEvents:UIControlEventTouchUpInside];
    _saveButton.hidden = YES;
    [_buttonsView addSubview:_saveButton];
    
    _clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _clearButton.frame = CGRectMake(0, _buttonsView.frame.size.height*3/4+10, _buttonsView.frame.size.width, _buttonsView.frame.size.height/4-10);
    [_clearButton setTitle:@"清 除" forState:UIControlStateNormal];
    [_clearButton setBackgroundColor:[UIColor whiteColor]];
    [_clearButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_clearButton addTarget:self action:@selector(pressClearFence) forControlEvents:UIControlEventTouchUpInside];
    _clearButton.hidden = YES;
    [_buttonsView addSubview:_clearButton];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [self requestFenceList];
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_pointArray removeAllObjects];
    [_polygons removeAllObjects];
    _circlesArray = @[];
    [self pressClearFence];
    [self clear];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

#pragma mark 数据请求
- (void)requestFenceList{
    NSLog(@"requestFenceList");
}

//设置围栏
- (void)pressSelectGraphics:(UIButton *)sender{

    NSLog(@"%d",self.polygons);
    if (self.polygons.count > 0 || self.circlesArray.count >0) {
        [self pressClearFence];
        [_polygons removeAllObjects];
    }
    [self creatPopView];
}

- (void)creatPopView{
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.6 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        _buttonsView.backgroundColor = [UIColor whiteColor];
        [_polygonBtn setBackgroundColor:[UIColor whiteColor]];
        [_circleBtn setBackgroundColor:[UIColor whiteColor]];
        
    } completion:^(BOOL finished) {
        
        _fenceButton.hidden = YES;
        _buttonsView.hidden = NO;
        _polygonBtn.hidden = NO;
        _polygonBtn.enabled = YES;
        _circleBtn.enabled = YES;
        _circleBtn.hidden = NO;
        _saveButton.hidden = NO;
        _clearButton.hidden = NO;
    }];
    
}

- (void)changePolygon{
    
    [UIView animateWithDuration:0.3 animations:^{
        
    } completion:^(BOOL finished) {
        _isPolygonFence = YES;
        _circleBtn.enabled = NO;
    }];
}

- (void)changeCircle{
    
    [UIView animateWithDuration:0.3 animations:^{
        
    } completion:^(BOOL finished) {
        _isCircleFence = YES;
        _polygonBtn.enabled = NO;
    }];
}

- (void)pressSaveFence{
    
    [UIView animateWithDuration:0.3 animations:^{
        
    } completion:^(BOOL finished) {

        if (_isCircleFence == YES) {
            _buttonsView.hidden = YES;
            _polygonBtn.hidden = YES;
            _circleBtn.hidden = YES;
            _saveButton.hidden = YES;
            _clearButton.hidden = YES;
            _fenceButton.hidden = NO;
            [self getCirclePointArray];
        }
        else if (_isPolygonFence == YES){
            if (_pointArray.count < 3) {
//                [BaseHelper showProgressHudWithText:@"必须大于等于三个点"];
                return ;
            }
            _buttonsView.hidden = YES;
            _polygonBtn.hidden = YES;
            _circleBtn.hidden = YES;
            _saveButton.hidden = YES;
            _clearButton.hidden = YES;
            _fenceButton.hidden = NO;
            _isOverEightPoints = NO;
            [self getPolygonPointArray];
        }else{
            _buttonsView.hidden = YES;
            _polygonBtn.hidden = YES;
            _circleBtn.hidden = YES;
            _saveButton.hidden = YES;
            _clearButton.hidden = YES;
            _fenceButton.hidden = NO;
        }
    }];
}

//创建圆形围栏
- (void)getCirclePointArray{
    NSLog(@"+++++完成");
    [self requestAddFence];
}
//创建多边形围栏
- (void)getPolygonPointArray{
    NSLog(@"%d ",self.pointArray.count);
    CLLocationCoordinate2D coordinates[_pointArray.count];
    for (int i=0; i<_pointArray.count; i++) {
        AMapGeoPoint *coorModel = _pointArray[i];
        coordinates[i].latitude = coorModel.latitude;
        coordinates[i].longitude = coorModel.longitude;
        
    }
    MAPolygon *polygon = [MAPolygon polygonWithCoordinates:coordinates count:_pointArray.count];
    
    [self.polygons addObject:polygon];
    NSLog(@"%d",self.polygons);
    [self.mapView addOverlays:self.polygons];
//    [self requestAddFence];
    
}

- (void)pressClearFence{
    
    [UIView animateWithDuration:0.3 animations:^{
        
    } completion:^(BOOL finished) {
        if (_isCircleFence == YES) {
            [self.mapView removeOverlays:self.circlesArray];
        }
        _buttonsView.hidden = YES;
        _polygonBtn.hidden = YES;
        _circleBtn.hidden = YES;
        _saveButton.hidden = YES;
        _clearButton.hidden = YES;
        _fenceButton.hidden = NO;
        _isPolygonFence = NO;
        _isCircleFence = NO;
        _isOverEightPoints = NO;
        [_pointArray removeAllObjects];
        [self clearPointArray];
        [self clear];
    }];
}

- (void)clearPointArray{
    
    NSLog(@"%d ",self.pointArray.count);
    CLLocationCoordinate2D coordinates[_pointArray.count];
    for (int i=0; i<_pointArray.count; i++) {
        AMapGeoPoint *coorModel = _pointArray[i];
        coordinates[i].latitude = coorModel.latitude;
        coordinates[i].longitude = coorModel.longitude;
        
    }
    MAPolygon *polygon = [MAPolygon polygonWithCoordinates:coordinates count:_pointArray.count];
    
    [self.polygons addObject:polygon];
    NSLog(@"%d",self.polygons);
    [_mapView removeAnnotations:_mapView.annotations];
    [_pointArray removeAllObjects];
}
//点击添加大头针
- (void)AddMAPointInMapCoordinate:(CLLocationCoordinate2D)coordinate{
    if (_isPolygonFence == YES) {
        MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
        pointAnnotation.coordinate = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
        [_mapView addAnnotation:pointAnnotation];
        _pointModel = [AMapGeoPoint new];
        _pointModel.latitude = coordinate.latitude;
        _pointModel.longitude = coordinate.longitude;
        NSLog(@"_pointModel = %@",_pointModel);
        [_pointArray addObject:_pointModel];
        if (_pointArray.count == 8) {
            _isOverEightPoints = YES;
        }
        NSLog(@"%@", self.pointArray);
    }
    else if (_isCircleFence == YES){
        MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
        pointAnnotation.coordinate = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
        [_mapView addAnnotation:pointAnnotation];
        _pointModel = [AMapGeoPoint new];
        _pointModel.latitude = coordinate.latitude;
        _pointModel.longitude = coordinate.longitude;
        NSLog(@"_pointModel = %@",_pointModel);
        [_pointArray addObject:_pointModel];
        NSLog(@"%@", self.pointArray);
        
        NSMutableArray *arr = [NSMutableArray array];
        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"提示" message:@"请输入圆形围栏的半径" preferredStyle:UIAlertControllerStyleAlert];
        
        [alertView addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            UITextField * firstKeywordTF = [[UITextField alloc]init];
            firstKeywordTF.keyboardType = UIKeyboardTypeDecimalPad;
            NSArray * textFieldArr = @[firstKeywordTF];
            textFieldArr = alertView.textFields;
            
            UITextField * tf1 = alertView.textFields[0];
            tf1.keyboardType = UIKeyboardTypeDecimalPad;
            _radiusNumber = @"";
            NSLog(@" %@",tf1.text);
            _radiusNumber = tf1.text;
            if (_radiusNumber.intValue <= 0) {
                
                [self clearPointArray];
                return ;
            }else{
                MACircle *circle1 = [MACircle circleWithCenterCoordinate:CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude) radius:[tf1.text floatValue]];
                [self.pointArray addObject:_pointModel];
                [arr addObject:circle1];
                self.circlesArray = [NSArray arrayWithArray:arr];
                [self.mapView addOverlays:self.circlesArray];
            }
        }]];
        [alertView addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.keyboardType = UIKeyboardTypeDecimalPad;
            textField.placeholder = @"圆形围栏半径单位米";
        }];
        [alertView addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
            [self clearPointArray];
        }]];
        
        [self presentViewController:alertView animated:true completion:nil];
    }
}
#pragma mark - MAMapViewDelegate
//自定义大头针的数量样式
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        if (_isPolygonFence == NO && _isCircleFence == NO) {
            CustomAnnotationView*annotationView = (CustomAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
            if (annotationView == nil)
            {
                annotationView = [[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
            }
            annotationView.portrait = [UIImage imageNamed:@"location"];
            annotationView.canShowCallout= NO;//设置气泡可以弹出，默认为NO
            return annotationView;
        }else{
            PointFenceView *annotationView = (PointFenceView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
            if (annotationView == nil)
            {
                annotationView = [[PointFenceView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
            }
            annotationView.canShowCallout= NO;       //设置气泡可以弹出，默认为NO
            return annotationView;
        }
    }
    return nil;
}

/**
 *  单击地图底图调用此接口
 *
 *  @param mapView    地图View
 *  @param coordinate 点击位置经纬度
 */
- (void)mapView:(MAMapView *)mapView didSingleTappedAtCoordinate:(CLLocationCoordinate2D)coordinate {
    NSLog(@"Coordinate = %@",[NSString stringWithFormat:@"coordinate =  {%f, %f}", coordinate.latitude, coordinate.longitude]);
    
    if (_isOverEightPoints == YES) {
        [self limitSetAlert];
        return;
        
    }
    [self AddMAPointInMapCoordinate:coordinate];
    
}
- (void)limitSetAlert{
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"提示" message:@"矩形围栏最多设置8个点" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAct = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"I Know");
    }];
    [alertView addAction:okAct];
    [self presentViewController:alertView animated:true completion:nil];
}
/*!
 @brief 当选中一个annotation views时调用此接口
 @param mapView 地图View
 @param view 选中的annotation views
 */
- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view {
    NSLog(@"点击");
}

/*!
 @brief 拖动annotation view时view的状态变化，ios3.2以后支持
 @param mapView 地图View
 @param view annotation view
 @param newState 新状态
 @param oldState 旧状态
 */
- (void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view didChangeDragState:(MAAnnotationViewDragState)newState fromOldState:(MAAnnotationViewDragState)oldState {
    NSLog(@"拖动");
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MAPolygon class]])
    {
        MAPolygonRenderer *polygonRenderer = [[MAPolygonRenderer alloc] initWithPolygon:overlay];
        polygonRenderer.lineWidth   = 4.f;
        polygonRenderer.strokeColor = [UIColor redColor];
        polygonRenderer.fillColor   = [[UIColor redColor] colorWithAlphaComponent:0.3];
        
        return polygonRenderer;
    }
    else if ([overlay isKindOfClass:[MACircle class]])
    {
        MACircleRenderer *circleRenderer = [[MACircleRenderer alloc] initWithCircle:overlay];
        
        circleRenderer.lineWidth   = 4.f;
        circleRenderer.strokeColor = [UIColor redColor];
        circleRenderer.fillColor   = [[UIColor redColor] colorWithAlphaComponent:0.3];
        return circleRenderer;
    }
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SearchUtility

/* 清除annotations & overlays */
- (void)clear
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.pointArray removeAllObjects];
}

- (void)clearAndShowAnnotationWithTip:(AMapTip *)tip
{
    /* 清除annotations & overlays */
    //    [self clear];
    
    if (tip.uid != nil && tip.location != nil) /* 可以直接在地图打点  */
    {
        AMapTipAnnotation *annotation = [[AMapTipAnnotation alloc] initWithMapTip:tip];
        [self.mapView addAnnotation:annotation];
        [self.mapView setCenterCoordinate:annotation.coordinate];
        [self.mapView selectAnnotation:annotation animated:YES];
    }
}

//输入提示回调.
//- (void)onInputTipsSearchDone:(AMapInputTipsSearchRequest *)request response:(AMapInputTipsSearchResponse *)response
//{
//    if (response.count == 0)
//    {
//        return;
//    }
//}


- (void)requestAddFence{
    
    AddOrDeleteModel *model = [[AddOrDeleteModel alloc] init];

    if (_pointArray.count >2) {
        model.name = @"新多边形围栏";
        model.shape = @"Polygon";
        model.elementNum = [NSString stringWithFormat:@"%d",_pointArray.count];
        NSString *elementStr = @"";
        if (_pointArray.count == 3) {
            AMapGeoPoint *pointModel = _pointArray[0];
            NSString *latitude = [NSString stringWithFormat:@"%f",pointModel.latitude];
            NSString *longitude = [NSString stringWithFormat:@"%f",pointModel.longitude];
            model.element1 = [[latitude stringByAppendingString:@","] stringByAppendingString:longitude];
            
            AMapGeoPoint *pointModel1 = _pointArray[1];
            NSString *latitude1 = [NSString stringWithFormat:@"%f",pointModel1.latitude];
            NSString *longitude1 = [NSString stringWithFormat:@"%f",pointModel1.longitude];
            model.element2 = [[latitude1 stringByAppendingString:@","] stringByAppendingString:longitude1];
            
            AMapGeoPoint *pointModel2 = _pointArray[2];
            NSString *latitude2 = [NSString stringWithFormat:@"%f",pointModel2.latitude];
            NSString *longitude2 = [NSString stringWithFormat:@"%f",pointModel2.longitude];
            model.element3 = [[latitude2 stringByAppendingString:@","] stringByAppendingString:longitude2];
        }
        else if (_pointArray.count == 4){
            AMapGeoPoint *pointModel = _pointArray[0];
            NSString *latitude = [NSString stringWithFormat:@"%f",pointModel.latitude];
            NSString *longitude = [NSString stringWithFormat:@"%f",pointModel.longitude];
            model.element1 = [[latitude stringByAppendingString:@","] stringByAppendingString:longitude];
            
            AMapGeoPoint *pointModel1 = _pointArray[1];
            NSString *latitude1 = [NSString stringWithFormat:@"%f",pointModel1.latitude];
            NSString *longitude1 = [NSString stringWithFormat:@"%f",pointModel1.longitude];
            model.element2 = [[latitude1 stringByAppendingString:@","] stringByAppendingString:longitude1];
            
            AMapGeoPoint *pointModel2 = _pointArray[2];
            NSString *latitude2 = [NSString stringWithFormat:@"%f",pointModel2.latitude];
            NSString *longitude2 = [NSString stringWithFormat:@"%f",pointModel2.longitude];
            model.element3 = [[latitude2 stringByAppendingString:@","] stringByAppendingString:longitude2];
            
            AMapGeoPoint *pointModel3 = _pointArray[3];
            NSString *latitude3 = [NSString stringWithFormat:@"%f",pointModel3.latitude];
            NSString *longitude3 = [NSString stringWithFormat:@"%f",pointModel3.longitude];
            model.element4 = [[latitude3 stringByAppendingString:@","] stringByAppendingString:longitude3];
        }
        else if (_pointArray.count == 5){
            AMapGeoPoint *pointModel = _pointArray[0];
            NSString *latitude = [NSString stringWithFormat:@"%f",pointModel.latitude];
            NSString *longitude = [NSString stringWithFormat:@"%f",pointModel.longitude];
            model.element1 = [[latitude stringByAppendingString:@","] stringByAppendingString:longitude];
            
            AMapGeoPoint *pointModel1 = _pointArray[1];
            NSString *latitude1 = [NSString stringWithFormat:@"%f",pointModel1.latitude];
            NSString *longitude1 = [NSString stringWithFormat:@"%f",pointModel1.longitude];
            model.element2 = [[latitude1 stringByAppendingString:@","] stringByAppendingString:longitude1];
            
            AMapGeoPoint *pointModel2 = _pointArray[2];
            NSString *latitude2 = [NSString stringWithFormat:@"%f",pointModel2.latitude];
            NSString *longitude2 = [NSString stringWithFormat:@"%f",pointModel2.longitude];
            model.element3 = [[latitude2 stringByAppendingString:@","] stringByAppendingString:longitude2];
            
            AMapGeoPoint *pointModel3 = _pointArray[3];
            NSString *latitude3 = [NSString stringWithFormat:@"%f",pointModel3.latitude];
            NSString *longitude3 = [NSString stringWithFormat:@"%f",pointModel3.longitude];
            model.element4 = [[latitude3 stringByAppendingString:@","] stringByAppendingString:longitude3];
            
            AMapGeoPoint *pointModel4 = _pointArray[4];
            NSString *latitude4 = [NSString stringWithFormat:@"%f",pointModel4.latitude];
            NSString *longitude4 = [NSString stringWithFormat:@"%f",pointModel4.longitude];
            model.element5 = [[latitude4 stringByAppendingString:@","] stringByAppendingString:longitude4];
        }
        else if (_pointArray.count == 6){
            AMapGeoPoint *pointModel = _pointArray[0];
            NSString *latitude = [NSString stringWithFormat:@"%f",pointModel.latitude];
            NSString *longitude = [NSString stringWithFormat:@"%f",pointModel.longitude];
            model.element1 = [[latitude stringByAppendingString:@","] stringByAppendingString:longitude];
            
            AMapGeoPoint *pointModel1 = _pointArray[1];
            NSString *latitude1 = [NSString stringWithFormat:@"%f",pointModel1.latitude];
            NSString *longitude1 = [NSString stringWithFormat:@"%f",pointModel1.longitude];
            model.element2 = [[latitude1 stringByAppendingString:@","] stringByAppendingString:longitude1];
            
            AMapGeoPoint *pointModel2 = _pointArray[2];
            NSString *latitude2 = [NSString stringWithFormat:@"%f",pointModel2.latitude];
            NSString *longitude2 = [NSString stringWithFormat:@"%f",pointModel2.longitude];
            model.element3 = [[latitude2 stringByAppendingString:@","] stringByAppendingString:longitude2];
            
            AMapGeoPoint *pointModel3 = _pointArray[3];
            NSString *latitude3 = [NSString stringWithFormat:@"%f",pointModel3.latitude];
            NSString *longitude3 = [NSString stringWithFormat:@"%f",pointModel3.longitude];
            model.element4 = [[latitude3 stringByAppendingString:@","] stringByAppendingString:longitude3];
            
            AMapGeoPoint *pointModel4 = _pointArray[4];
            NSString *latitude4 = [NSString stringWithFormat:@"%f",pointModel4.latitude];
            NSString *longitude4 = [NSString stringWithFormat:@"%f",pointModel4.longitude];
            model.element5 = [[latitude4 stringByAppendingString:@","] stringByAppendingString:longitude4];
            
            AMapGeoPoint *pointModel5 = _pointArray[5];
            NSString *latitude5 = [NSString stringWithFormat:@"%f",pointModel5.latitude];
            NSString *longitude5 = [NSString stringWithFormat:@"%f",pointModel5.longitude];
            model.element6 = [[latitude5 stringByAppendingString:@","] stringByAppendingString:longitude5];
        }
        else if (_pointArray.count == 7){
            AMapGeoPoint *pointModel = _pointArray[0];
            NSString *latitude = [NSString stringWithFormat:@"%f",pointModel.latitude];
            NSString *longitude = [NSString stringWithFormat:@"%f",pointModel.longitude];
            model.element1 = [[latitude stringByAppendingString:@","] stringByAppendingString:longitude];
            
            AMapGeoPoint *pointModel1 = _pointArray[1];
            NSString *latitude1 = [NSString stringWithFormat:@"%f",pointModel1.latitude];
            NSString *longitude1 = [NSString stringWithFormat:@"%f",pointModel1.longitude];
            model.element2 = [[latitude1 stringByAppendingString:@","] stringByAppendingString:longitude1];
            
            AMapGeoPoint *pointModel2 = _pointArray[2];
            NSString *latitude2 = [NSString stringWithFormat:@"%f",pointModel2.latitude];
            NSString *longitude2 = [NSString stringWithFormat:@"%f",pointModel2.longitude];
            model.element3 = [[latitude2 stringByAppendingString:@","] stringByAppendingString:longitude2];
            
            AMapGeoPoint *pointModel3 = _pointArray[3];
            NSString *latitude3 = [NSString stringWithFormat:@"%f",pointModel3.latitude];
            NSString *longitude3 = [NSString stringWithFormat:@"%f",pointModel3.longitude];
            model.element4 = [[latitude3 stringByAppendingString:@","] stringByAppendingString:longitude3];
            
            AMapGeoPoint *pointModel4 = _pointArray[4];
            NSString *latitude4 = [NSString stringWithFormat:@"%f",pointModel4.latitude];
            NSString *longitude4 = [NSString stringWithFormat:@"%f",pointModel4.longitude];
            model.element5 = [[latitude4 stringByAppendingString:@","] stringByAppendingString:longitude4];
            
            AMapGeoPoint *pointModel5 = _pointArray[5];
            NSString *latitude5 = [NSString stringWithFormat:@"%f",pointModel5.latitude];
            NSString *longitude5 = [NSString stringWithFormat:@"%f",pointModel5.longitude];
            model.element6 = [[latitude5 stringByAppendingString:@","] stringByAppendingString:longitude5];
            
            AMapGeoPoint *pointModel6 = _pointArray[6];
            NSString *latitude6 = [NSString stringWithFormat:@"%f",pointModel6.latitude];
            NSString *longitude6 = [NSString stringWithFormat:@"%f",pointModel6.longitude];
            model.element7 = [[latitude6 stringByAppendingString:@","] stringByAppendingString:longitude6];
        }
        else if (_pointArray.count == 8){
            AMapGeoPoint *pointModel = _pointArray[0];
            NSString *latitude = [NSString stringWithFormat:@"%f",pointModel.latitude];
            NSString *longitude = [NSString stringWithFormat:@"%f",pointModel.longitude];
            model.element1 = [[latitude stringByAppendingString:@","] stringByAppendingString:longitude];
            
            AMapGeoPoint *pointModel1 = _pointArray[1];
            NSString *latitude1 = [NSString stringWithFormat:@"%f",pointModel1.latitude];
            NSString *longitude1 = [NSString stringWithFormat:@"%f",pointModel1.longitude];
            model.element2 = [[latitude1 stringByAppendingString:@","] stringByAppendingString:longitude1];
            
            AMapGeoPoint *pointModel2 = _pointArray[2];
            NSString *latitude2 = [NSString stringWithFormat:@"%f",pointModel2.latitude];
            NSString *longitude2 = [NSString stringWithFormat:@"%f",pointModel2.longitude];
            model.element3 = [[latitude2 stringByAppendingString:@","] stringByAppendingString:longitude2];
            
            AMapGeoPoint *pointModel3 = _pointArray[3];
            NSString *latitude3 = [NSString stringWithFormat:@"%f",pointModel3.latitude];
            NSString *longitude3 = [NSString stringWithFormat:@"%f",pointModel3.longitude];
            model.element4 = [[latitude3 stringByAppendingString:@","] stringByAppendingString:longitude3];
            
            AMapGeoPoint *pointModel4 = _pointArray[4];
            NSString *latitude4 = [NSString stringWithFormat:@"%f",pointModel4.latitude];
            NSString *longitude4 = [NSString stringWithFormat:@"%f",pointModel4.longitude];
            model.element5 = [[latitude4 stringByAppendingString:@","] stringByAppendingString:longitude4];
            
            AMapGeoPoint *pointModel5 = _pointArray[5];
            NSString *latitude5 = [NSString stringWithFormat:@"%f",pointModel5.latitude];
            NSString *longitude5 = [NSString stringWithFormat:@"%f",pointModel5.longitude];
            model.element6 = [[latitude5 stringByAppendingString:@","] stringByAppendingString:longitude5];
            
            AMapGeoPoint *pointModel6 = _pointArray[6];
            NSString *latitude6 = [NSString stringWithFormat:@"%f",pointModel6.latitude];
            NSString *longitude6 = [NSString stringWithFormat:@"%f",pointModel6.longitude];
            model.element7 = [[latitude6 stringByAppendingString:@","] stringByAppendingString:longitude6];
            
            AMapGeoPoint *pointModel7 = _pointArray[7];
            NSString *latitude7 = [NSString stringWithFormat:@"%f",pointModel7.latitude];
            NSString *longitude7 = [NSString stringWithFormat:@"%f",pointModel7.longitude];
            model.element8 = [[latitude7 stringByAppendingString:@","] stringByAppendingString:longitude7];
        }
    }
    else{
        if (_radiusNumber.intValue <=0 || _circlesArray.count <= 0) {
            return;
        }
        model.shape = @"Round";
        model.elementNum = @"2";
        model.name = @"新圆形围栏";
        NSString *latitude = [NSString stringWithFormat:@"%f",_pointModel.latitude];
        NSString *longitude = [NSString stringWithFormat:@"%f",_pointModel.longitude];
        model.element1 = [[latitude stringByAppendingString:@","] stringByAppendingString:longitude];
        model.element2 = _radiusNumber;
    }
}

@end
