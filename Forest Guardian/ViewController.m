//
//  ViewController.m
//  Forest Guardian
//
//  Created by Luis Alonso Murillo Rojas on 11/4/15.
//  Copyright (c) 2015 TEC. All rights reserved.
//

#import "ViewController.h"
#import "Tiempo.h"


@interface ViewController ()

@property(nonatomic,copy) NSDictionary *meta;
@property(nonatomic,copy) NSArray *notifications;
@property(nonatomic,copy) NSDictionary *response;

@property (nonatomic) BOOL center;
@property (nonatomic) BOOL state;

@property (weak, nonatomic) IBOutlet UIView *mainContainer;
@property (weak, nonatomic) IBOutlet UISearchBar *placesSearch;
@property (weak, nonatomic) IBOutlet UITableView *tableResults;

@property (weak, nonatomic) IBOutlet UILabel *lat_longLabel;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;

@property (weak, nonatomic) IBOutlet UIImageView *alertSymbol;

@property (strong, nonatomic) NSMutableArray *placesList;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _center = NO;
    _state = NO;
    
    _placesList = [[NSMutableArray alloc] init];
    
    [self setUpLocation];
    [self drawMapLayer];
    [self setUpGesture];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(animationToAlertSymbol) userInfo:nil repeats:YES];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:timer forMode:NSDefaultRunLoopMode];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setUpGesture
{
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [tapRecognizer setNumberOfTapsRequired:1];
    [self.mapView addGestureRecognizer:tapRecognizer];
}

-(IBAction) handleTapGesture:(UIGestureRecognizer *) sender {
    CGPoint tapPoint = [sender locationInView:self.mapView];
    NSLog(@"You tapped at %f, %f",
          [self.mapView pixelToCoordinate:tapPoint].latitude,
          [self.mapView pixelToCoordinate:tapPoint].longitude);
    [self.lat_longLabel setText:[NSString stringWithFormat:@"%f,%f", [self.mapView pixelToCoordinate:tapPoint].latitude, [self.mapView pixelToCoordinate:tapPoint].longitude]];
    
    
    
    Tiempo *hotSpot = [[Tiempo alloc] init];
    
    CLLocationDegrees latitude = [self.mapView pixelToCoordinate:tapPoint].latitude;
    CLLocationDegrees longitude = [self.mapView pixelToCoordinate:tapPoint].longitude;
    
    [hotSpot buildTimeof:CLLocationCoordinate2DMake(latitude,longitude) :^(Tiempo *responseObject, NSError *error) {
        if (!error) {
            NSLog(@"Temp: %@", responseObject.temp);
        }
    }];
    
    bool willShow = true;
    for (UIView *subview in self.view.subviews) {    // UIView.subviews
        if (subview.tag == 555) {
            [subview removeFromSuperview];
            willShow = false;
            
        }
    }
    if (willShow){
        [self drawFireLine:CGPointMake(tapPoint.x, tapPoint.y) withangle:-M_PI_2];
        [self drawFireLine:CGPointMake(tapPoint.x, tapPoint.y+150) withangle:-M_PI_2];
        [self drawFireLine:CGPointMake(tapPoint.x, tapPoint.y+300) withangle:-M_PI_2];
        
        [self drawFireLine:CGPointMake(tapPoint.x+20, tapPoint.y) withangle:-M_PI_2];
        [self drawFireLine:CGPointMake(tapPoint.x+20, tapPoint.y+150) withangle:-M_PI_2];
        [self drawFireLine:CGPointMake(tapPoint.x+40, tapPoint.y+300) withangle:-M_PI_2-0.25];
        
        [self drawFireLine:CGPointMake(tapPoint.x-20, tapPoint.y) withangle:-M_PI_2];
        [self drawFireLine:CGPointMake(tapPoint.x-20, tapPoint.y+150) withangle:-M_PI_2];
        [self drawFireLine:CGPointMake(tapPoint.x-40, tapPoint.y+300) withangle:-M_PI_2+0.25];
        
        [self drawLine:CGPointMake(tapPoint.x+60, tapPoint.y) withangle:-M_PI_2];
        [self drawLine:CGPointMake(tapPoint.x+60, tapPoint.y+150) withangle:-M_PI_2];
        [self drawLine:CGPointMake(tapPoint.x+65, tapPoint.y+300) withangle:-M_PI_2];
        
        [self drawLine:CGPointMake(tapPoint.x+80, tapPoint.y) withangle:-M_PI_2];
        [self drawLine:CGPointMake(tapPoint.x+80, tapPoint.y+150) withangle:-M_PI_2];
        [self drawLine:CGPointMake(tapPoint.x+85, tapPoint.y+300) withangle:-M_PI_2];
        
        [self drawLine:CGPointMake(tapPoint.x-60, tapPoint.y) withangle:-M_PI_2];
        [self drawLine:CGPointMake(tapPoint.x-60, tapPoint.y+150) withangle:-M_PI_2];
        [self drawLine:CGPointMake(tapPoint.x-65, tapPoint.y+300) withangle:-M_PI_2];
        
        [self drawLine:CGPointMake(tapPoint.x-80, tapPoint.y) withangle:-M_PI_2];
        [self drawLine:CGPointMake(tapPoint.x-80, tapPoint.y+150) withangle:-M_PI_2];
        [self drawLine:CGPointMake(tapPoint.x-85, tapPoint.y+300) withangle:-M_PI_2];
    }
}


-(void) drawLine: (CGPoint)point withangle:(CGFloat)degree{
    UIImageView* animatedImageView = [[UIImageView alloc] init];
    animatedImageView.animationImages = [NSArray arrayWithObjects:
                                         [UIImage imageNamed:@"flecha1.png"],
                                         [UIImage imageNamed:@"flecha2.png"],
                                         [UIImage imageNamed:@"flecha3.png"], nil];
    animatedImageView.animationDuration = 1.0f;
    animatedImageView.animationRepeatCount = 0;
    [animatedImageView startAnimating];
    animatedImageView.center = point;
    [self.view addSubview: animatedImageView];
    animatedImageView.transform = CGAffineTransformMakeRotation(degree);
    [animatedImageView setBounds:CGRectMake(0, 0,150, 50)];
    animatedImageView.tag = 555;
    
}

-(void) drawFireLine: (CGPoint)point withangle:(CGFloat)degree{
    UIImageView* animatedImageView = [[UIImageView alloc] init];
    animatedImageView.animationImages = [NSArray arrayWithObjects:
                                         [UIImage imageNamed:@"flecha_b1.png"],
                                         [UIImage imageNamed:@"flecha_b2.png"],
                                         [UIImage imageNamed:@"flecha_b3.png"], nil];
    animatedImageView.animationDuration = 1.0f;
    animatedImageView.animationRepeatCount = 0;
    [animatedImageView startAnimating];
    animatedImageView.center = point;
    [self.view addSubview: animatedImageView];
    animatedImageView.transform = CGAffineTransformMakeRotation(degree);
    [animatedImageView setBounds:CGRectMake(0, 0,150, 50)];
    animatedImageView.tag = 555;
}

- (void) setUpLocation
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    if ([self.locationManager respondsToSelector:@selector
         (requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    _location = [locations lastObject];
    if (!_center) {
        self.mapView.centerCoordinate = _location.coordinate;
        _center = YES;
    }
}

- (void) drawMapLayer
{
    [[RMConfiguration sharedInstance] setAccessToken:@"pk.eyJ1IjoiZW1tYW1tMDUiLCJhIjoiM1ZBVExhOCJ9.0uVTeXUebK-S6oBTFpCMmQ"];
    
    RMMapboxSource *tileSource = [[RMMapboxSource alloc]
                                  initWithMapID:@"mapbox.light"];
    
    // set coordinates
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(_location.coordinate.latitude,
                                                               _location.coordinate.longitude);
    
    self.mapView = [[RMMapView alloc] initWithFrame:self.view.bounds
                                      andTilesource:tileSource];
    
    // make map expand to fill screen when rotated
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight |
    UIViewAutoresizingFlexibleWidth;
    
    // set zoom
    self.mapView.zoom = 13;
    
    // center the map to the coordinates
    self.mapView.centerCoordinate = center;
    
    [self.mapView addTileSource:[[RMMapboxSource alloc]
                                 initWithMapID:@"ldiego08.2c02c779"]];
    
    [self.view addSubview:self.mapView];
    
    
}

- (IBAction)onChangeButtonClicked:(id)sender {
}

- (IBAction)returnFromReportFeed:(UIStoryboardSegue*)sender
{}

//Animation

- (void)animationToAlertSymbol
{
    if (self.alertSymbol.hidden) {
        [self.alertSymbol setHidden:NO];
    } else {
        [self.alertSymbol setHidden:YES];
    }
}


@end