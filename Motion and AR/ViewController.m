//
//  ViewController.m
//  Motion and AR
//
//  Created by Taylor Wright-Sanson on 12/24/14.
//  Copyright (c) 2014 Taylor Wright-Sanson. All rights reserved.
//

#import "ViewController.h"
@import CoreMotion;

@interface ViewController ()

@property (nonatomic, strong) CMMotionManager * motionManager;
@property (nonatomic, strong) UIView * ball;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

#pragma mark Nothing to change here

float X = 0;
float Y = 0;
float R = 40;

- (void)initBall
{
    self.ball = [[UIView alloc] initWithFrame:CGRectMake(160, 250, R, R)];
    self.ball.layer.cornerRadius = 20;
    self.ball.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.ball];
}

- (void)updateBallWithRoll:(float)roll Pitch:(float)pitch Yaw:(float)yaw accX:(float)accX accY:(float)accY accZ:(float)accZ
{
    NSLog(@"pitch: %f roll: %f yaw: %f", pitch, roll, yaw);
    X += 2 * roll;
    Y += 2 * pitch;

    X *= 0.8;
    Y *= 0.8;

    CGFloat newX = self.ball.frame.origin.x + X;
    CGFloat newY = self.ball.frame.origin.y + Y;

    newX = fmin(self.view.frame.size.width -
                R, fmax(0, newX));
    newY = fmin(self.view.frame.size.height - R, fmax(64, newY));

    CGFloat newR = R + 10 * accZ;

    self.ball.frame = CGRectMake(newX, newY, newR, newR);
}

#pragma mark Assignments

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initBall];
    [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateDeviceMotion) userInfo:nil repeats:YES];

    // TODO: 2.1

    // 2.1 Create a CMMotionManager instance and store it in the property "motionManager"
    self.motionManager = [[CMMotionManager alloc] init];

    // 2.1 Set the motion update interval to 1/60
    self.motionManager.deviceMotionUpdateInterval = 1/60;


    // 2.1 Start updating the motion using the reference frame CMAttitudeReferenceFrameXArbitraryCorrectedZVertical
    [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryCorrectedZVertical];

    // *************************************************************************************************
    // ****************** This way is very jittery and not idea for user movement **********************
    // *************************************************************************************************
    /*
    ViewController * __weak weakSelf = self;
    if (self.motionManager.accelerometerAvailable) {
        self.motionManager.accelerometerUpdateInterval = 0.01f;
        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue]
                                      withHandler:^(CMAccelerometerData *data, NSError *error) {
                                          double rotation = atan2(data.acceleration.x, data.acceleration.y) - M_PI;
                                          weakSelf.imageView.transform = CGAffineTransformMakeRotation(rotation);
                                      }];
    }
    */
    // *************************************************************************************************
    // *************************************************************************************************


    // *************************************************************************************************
    //  Using the gyroscope, Core Motion separates user movement from gravitational acceleration and presents each  as its own property of the CMDeviceMotionData instance that we receive in our handler
    // *************************************************************************************************

    ViewController * __weak weakSelf = self;
    if (self.motionManager.deviceMotionAvailable) {
        self.motionManager.deviceMotionUpdateInterval = 0.01f;
        [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
                                     withHandler:^(CMDeviceMotion *data, NSError *error) {
                                         double rotation = atan2(data.gravity.x, data.gravity.y) - M_PI;
                                         weakSelf.imageView.transform = CGAffineTransformMakeRotation(rotation);
                                     }];
    }
    // *************************************************************************************************
    // *************************************************************************************************



}

-(void)updateDeviceMotion
{
    // TODO: 2.2

    // 2.2 Get the deviceMotion from motionManager
    CMDeviceMotion *motion = self.motionManager.deviceMotion;

    // 2.2 Return if the returned CMDeviceMotion object is nil
    if (!motion) {
        return;
    }

    // 2.2 Get the attitude from CMDeviceMotion
    CMAttitude *attitude = motion.attitude;

    // 2.2 Get the userAcceleration from CMDeviceMotion
    CMAcceleration userAcceleration = motion.userAcceleration;

    // 2.2 Call "updateBallWithRoll:Pitch:Yaw:accX:accY:accZ:" on self with the appropriate arguments
    float roll = attitude.roll;
    float pitch = attitude.pitch;
    float yaw = attitude.yaw;
    float accX = userAcceleration.x;
    float accY = userAcceleration.y;
    float accZ = userAcceleration.z;

    [self updateBallWithRoll:roll Pitch:pitch Yaw:yaw accX:accX accY:accY accZ:accZ];

}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    if(self.motionManager != nil){

        // TODO: 2.3

        // 2.3 Stop updating the motionManager
        [self.motionManager stopDeviceMotionUpdates];

        // 2.3 Set the ivar "motionManager" to nil
        self.motionManager = nil;
        
    }
}

@end
