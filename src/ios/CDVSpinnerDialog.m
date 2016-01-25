//
//  CDVSpinnerDialog.m
//
//  Created by Domonkos Pál on 2014.01.27..
//
//

#import "CDVSpinnerDialog.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1]

@interface CDVSpinnerDialog () {
    UIActivityIndicatorView *indicator;
    NSString *callbackId;
    NSString *title;
    NSString *message;
    NSNumber *isFixed;
    NSString *color;
}

@property (nonatomic, retain) UIActivityIndicatorView *indicator;
@property (nonatomic, retain) UIView *overlay;
@property (nonatomic, retain) UILabel *messageView;


@end

@implementation CDVSpinnerDialog

@synthesize indicator = _indicator;
@synthesize overlay = _overlay;
@synthesize messageView = _messageView;

-(CGRect)rectForView {
    if ((NSFoundationVersionNumber <= 1047.25 /* 7.1 */) && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        return CGRectMake( 0.0f, 0.0f, [[UIScreen mainScreen]bounds].size.height, [UIScreen mainScreen].bounds.size.width);
    }
    return CGRectMake( 0.0f, 0.0f, [[UIScreen mainScreen]bounds].size.width, [UIScreen mainScreen].bounds.size.height);
}

- (void)handleTapGesture:(UITapGestureRecognizer *)gesture
{
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [result setKeepCallbackAsBool:true];
    if (!isFixed.boolValue) {
        [result setKeepCallbackAsBool:false];
        [self hide];
    }
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
}

- (UIView *)overlay {
    if (!_overlay) {
        _overlay = [[UIView alloc] initWithFrame:self.rectForView];
        _overlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.65];
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicator.center = _overlay.center;
        /*if(color && ![color isEqualToString: @"null"] && ![color isEqualToString: @""]){
            if([color rangeOfString:@"#"].location != NSNotFound){
                color = [color stringByReplacingOccurrencesOfString:@"#" withString:@""];
            }
            unsigned int baseValue;
            [[NSScanner scannerWithString:color] scanHexInt:&baseValue];
            _indicator.color = UIColorFromRGB(baseValue);
        }*/
        [_indicator startAnimating];
        [_overlay addSubview:_indicator];

        _messageView = [[UILabel alloc] initWithFrame: self.rectForView];
        [_messageView setText: message == nil ? title : message];
        //[_messageView setTextColor: [UIColor colorWithRed:1 green:1 blue:1 alpha:0.85]];
        if(color && ![color isEqualToString: @"null"] && ![color isEqualToString: @""]){
            if([color rangeOfString:@"#"].location != NSNotFound){
                color = [color stringByReplacingOccurrencesOfString:@"#" withString:@""];
            }
            unsigned int baseValue;
            [[NSScanner scannerWithString:color] scanHexInt:&baseValue];
            [_messageView setTextColor: UIColorFromRGB(baseValue)];
        }
        [_messageView setBackgroundColor: [UIColor colorWithRed:0 green:0 blue:0 alpha:0]];
        [_messageView setTextAlignment: NSTextAlignmentCenter];
         _messageView.center = (CGPoint){_overlay.center.x, _overlay.center.y + 40};
        [_overlay addSubview:_messageView];

        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [_overlay addGestureRecognizer: tapRecognizer];
    }
    return _overlay;
}


- (void) show:(CDVInvokedUrlCommand*)command {

    callbackId = command.callbackId;

    title = [command argumentAtIndex:0];
    message = [command argumentAtIndex:1];
    isFixed = [command argumentAtIndex:2];
    color = [command argumentAtIndex:3];

    UIViewController *rootViewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];

    [rootViewController.view addSubview:self.overlay];

}

- (void) hide:(CDVInvokedUrlCommand*)command {
    [self hide];
}

- (void) hide {
    if (_overlay) {
        [self.indicator stopAnimating];
        [self.indicator removeFromSuperview];
        [self.messageView removeFromSuperview];
        [self.overlay removeFromSuperview];
        _indicator = nil;
        _messageView = nil;
        _overlay = nil;
    }
}

#pragma mark - PRIVATE METHODS


@end


