//
//  ViewController.m
//  PPSAndAdonit
//
//  Created by admin on 14/12/5.
//  Copyright (c) 2014年 yxguo. All rights reserved.
//

#import "ViewController.h"
#import "PPSSignatureView.h"
#import <JotTouchSDK/JotTouchSDK.h>

@interface ViewController ()<UIAlertViewDelegate>
{
    PPSSignatureView *_ppsSignView;
}
@property (nonatomic ,strong) UIPopoverController *settingsPopoverController;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    _ppsSignView = [[PPSSignatureView alloc] initWithFrame:self.view.bounds context:context];
    _ppsSignView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:_ppsSignView];
    
    UIButton *snap = [UIButton buttonWithType:UIButtonTypeCustom];
    snap.frame = CGRectMake(self.view.frame.size.width * 0.5 - 100, self.view.frame.size.height - 80, 200, 40);
    snap.backgroundColor = [UIColor redColor];
    [snap setTitle:@"点击获取图片并缩放" forState:UIControlStateNormal];
    [snap setTitle:@"缩放吧" forState:UIControlStateDisabled];
    [snap addTarget:self action:@selector(closePPSAndMovePinchImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:snap];
    
    UIButton *set = [UIButton buttonWithType:UIButtonTypeCustom];
    set.frame = CGRectMake(self.view.frame.size.width - 100, 80, 40, 40);
    set.backgroundColor = [UIColor redColor];
    [set setTitle:@"Seting" forState:UIControlStateNormal];
    [set addTarget:self action:@selector(showSettings:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:set];
    
    [[JotStylusManager sharedInstance] enable];
    [[JotStylusManager sharedInstance] setRejectMode:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector:@selector(connectionChange:)
                                                 name: JotStylusManagerDidChangeConnectionStatus
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)closePPSAndMovePinchImage
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:_ppsSignView.snapshot];
    imageView.frame = _ppsSignView.frame;
    imageView.layer.borderWidth = 1.0f;
    imageView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    imageView.userInteractionEnabled = YES;
    [_ppsSignView removeFromSuperview];
    
    UIPanGestureRecognizer *aPn = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    [imageView addGestureRecognizer:aPn];
    
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc]
                                                        initWithTarget:self
                                                        action:@selector(handlePinch:)];
    [imageView addGestureRecognizer:pinchGestureRecognizer];
    
    [self.view addSubview:imageView];
}

- (void) move:(UIPanGestureRecognizer *)aGesture{
    if (aGesture.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [aGesture locationInView:self.view];
        [self.view bringSubviewToFront:aGesture.view];
        aGesture.view.center=translation;
    }
}

- (void) handlePinch:(UIPinchGestureRecognizer*) recognizer
{
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
}
- (void)connectionChange:(NSNotification *) note
{
    NSString *text;
    switch([[JotStylusManager sharedInstance] connectionStatus])
    {
        case JotConnectionStatusOff:
            text = @"Off";
            break;
        case JotConnectionStatusScanning:
            text = @"Scanning";
            break;
        case JotConnectionStatusPairing:
            text = @"Pairing";
            break;
        case JotConnectionStatusConnected:
            text = @"Connected";
            break;
        case JotConnectionStatusDisconnected:
            text = @"Disconnected";
            break;
        default:
            text = @"";
            break;
    }
//    [settingsButton setTitle: text forState:UIControlStateNormal];
    NSLog(@"%@",text);
}


- (IBAction)showSettings:(id)sender
{
    JotSettingsViewController *settings = [JotSettingsViewController settingsViewController];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:settings];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [navController setModalPresentationStyle:UIModalPresentationFullScreen];
        [navController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
        [[[UIApplication sharedApplication] delegate].window.rootViewController presentViewController:navController animated:YES completion:nil];
    } else {
        if(self.settingsPopoverController){
            [self.settingsPopoverController dismissPopoverAnimated:NO];
        }
        
        self.settingsPopoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
        [self.settingsPopoverController presentPopoverFromRect:[sender frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        
        if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending) {
            navController.navigationBar.tintColor = [UIColor redColor];
        }
        
        [self.settingsPopoverController setPopoverContentSize:CGSizeMake(320, 460) animated:NO];
    }
}

@end
