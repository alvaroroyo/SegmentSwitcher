//
//  ILRunkeeper.m
//  RunkeeperSwitch
//
//  Created by Alvaro Royo on 30/4/16.
//  Copyright © 2016 alvaroroyo. All rights reserved.
//

#import "SegmentSwitcher.h"
@import NotificationCenter;

#define ANIMATION_DURATION 0.3
#define ANIMATION_SPRING_DAMPING 0.75
#define ANIMATION_INITIAL_SPRING_VELOCITY 0

@interface SegmentSwitcher ()

@property (strong,nonatomic) UIView *backgroundView;
@property (strong,nonatomic) UIView *buttonControl;

@property (strong,nonatomic) UIView *titleMaskView;

@property (strong,nonatomic) UILabel *lblLeftText;
@property (strong,nonatomic) UILabel *lblRightText;
@property (strong,nonatomic) UILabel *lblSelectedLeftText;
@property (strong,nonatomic) UILabel *lblSelectedRightText;

@property (assign) CGRect initialFrame;
@property (assign) CGRect afterFrame;

@property (strong,nonatomic) UIGestureRecognizer *panGesture;
@property (nonatomic) CGRect inFrame;

@end

@implementation SegmentSwitcher

-(id)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        
        self.backgroundColor = [UIColor clearColor];
        
        /* -- Runkeeper background -- */
        self.backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        self.backgroundView.backgroundColor = [UIColor orangeColor]; //Set to black in future
        self.backgroundView.layer.cornerRadius = self.backgroundView.bounds.size.height / 2;
        [self addSubview:self.backgroundView];
        
        /* -- Left Text -- */
        self.lblLeftText = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width / 2, self.bounds.size.height)];
        self.lblLeftText.textAlignment = NSTextAlignmentCenter;
        self.lblLeftText.textColor = [UIColor whiteColor];
        self.lblLeftText.text = @"Prueba";
        [self addSubview:self.lblLeftText];
        
        /* -- Right Text -- */
        self.lblRightText = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.lblLeftText.bounds), 0, self.bounds.size.width / 2, self.bounds.size.height)];
        self.lblRightText.textAlignment = NSTextAlignmentCenter;
        self.lblRightText.textColor = [UIColor whiteColor];
        self.lblRightText.text = @"Prueba";
        [self addSubview:self.lblRightText];
        
        /* -- Button control -- */
        self.buttonControl = [[UIView alloc]initWithFrame:CGRectMake(2, 2, self.bounds.size.width / 2 - 4, self.bounds.size.height - 4)];
        self.buttonControl.backgroundColor = [UIColor whiteColor];
        self.buttonControl.layer.cornerRadius = self.buttonControl.bounds.size.height / 2;
        [self addSubview:self.buttonControl];
        
        /* -- Selected content -- */
        self.titleMaskView = [[UIView alloc]initWithFrame:CGRectMake(2, 2, self.bounds.size.width / 2 - 4, self.bounds.size.height - 4)];
        self.titleMaskView.layer.cornerRadius = self.titleMaskView.bounds.size.height / 2;
        self.titleMaskView.backgroundColor = [UIColor orangeColor];
        UIView *selectedLblContent = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        selectedLblContent.layer.mask = self.titleMaskView.layer;
        selectedLblContent.layer.masksToBounds = YES;
        [self addSubview:selectedLblContent];
        
        /* -- Selected left text -- */
        self.lblSelectedLeftText = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width / 2, self.bounds.size.height)];
        self.lblSelectedLeftText.textAlignment = NSTextAlignmentCenter;
        self.lblSelectedLeftText.textColor = [UIColor orangeColor];
        self.lblSelectedLeftText.text = @"Prueba";
        [selectedLblContent addSubview:self.lblSelectedLeftText];
        
        /* -- Selected Right Text -- */
        self.lblSelectedRightText = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.lblSelectedLeftText.bounds), 0, self.bounds.size.width / 2, self.bounds.size.height)];
        self.lblSelectedRightText.textAlignment = NSTextAlignmentCenter;
        self.lblSelectedRightText.textColor = [UIColor orangeColor];
        self.lblSelectedRightText.text = @"Prueba";
        [selectedLblContent addSubview:self.lblSelectedRightText];
        
        /* -- TAP GESTURE -- */
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapEvent:)];
        [self addGestureRecognizer:tapGesture];
        
        /* -- PAN GESTURE -- */
        self.panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panEvent:)];
        [self addGestureRecognizer:self.panGesture];
    }
    return self;
}

#pragma mark - GESTURES
-(void)tapEvent:(UITapGestureRecognizer *)gestureRecognizer{
    if([gestureRecognizer locationInView:self].x < self.bounds.size.width / 2.0){
        [self setSelectedIndexAt:0];
    }else{
        [self setSelectedIndexAt:1];
    }
}

-(void)panEvent:(UIPanGestureRecognizer *)gestureRecognizer{
    if(gestureRecognizer.state == UIGestureRecognizerStateChanged){
        int touchRest = 50; //Touch correction.
        CGFloat gestureLocation = [gestureRecognizer locationInView:self].x - touchRest;
        CGFloat maxX = self.frame.size.width - 2 - self.buttonControl.frame.size.width;
        CGFloat minX = 2;
        
        if(gestureLocation < maxX && gestureLocation > minX){
            self.buttonControl.frame = CGRectMake([gestureRecognizer locationInView:self].x - touchRest, self.buttonControl.frame.origin.y, self.buttonControl.frame.size.width, self.buttonControl.frame.size.height);
            self.titleMaskView.frame = self.buttonControl.frame;
        }
        
    }else if(gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateFailed || gestureRecognizer.state == UIGestureRecognizerStateCancelled){
        
        if(self.buttonControl.center.x >= (self.bounds.origin.x + CGRectGetMaxX(self.bounds)) / 2){
            [self setSelectedIndexAt:1];
        }else{
            [self setSelectedIndexAt:0];
        }
        
    }
}

#pragma mark - VIEW METHODS:
-(void)setSelectedIndexAt:(NSInteger)index{
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:0
         usingSpringWithDamping:ANIMATION_SPRING_DAMPING
          initialSpringVelocity:ANIMATION_INITIAL_SPRING_VELOCITY
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationCurveEaseOut
                     animations:^{
                         if(index == 1){
                             self.buttonControl.frame = CGRectMake(CGRectGetMaxX(self.lblLeftText.bounds) + 2, 2, self.buttonControl.bounds.size.width,self.buttonControl.bounds.size.height);
                             self.titleMaskView.frame = self.buttonControl.frame;
                         }else{
                             self.buttonControl.frame = CGRectMake(2, 2, self.buttonControl.bounds.size.width,self.buttonControl.bounds.size.height);
                             self.titleMaskView.frame = self.buttonControl.frame;
                         }
                     }
                     completion:^(BOOL finished) {
                         [self.delegate segment:self DidChangeIndex:index];
                     }
     ];
}

#pragma mark - PROPERTIES SETTERS:
-(void)setLeftText:(NSString *)leftText{
    self.lblLeftText.text = leftText;
    self.lblSelectedLeftText.text = leftText;
}
-(void)setRightText:(NSString *)rightText{
    self.lblRightText.text = rightText;
    self.lblSelectedRightText.text = rightText;
}

-(void)setTextColor:(UIColor *)textColor{
    self.lblLeftText.textColor = textColor;
    self.lblRightText.textColor = textColor;
}
-(void)setSelectedTextColor:(UIColor *)selectedTextColor{
    self.lblSelectedRightText.textColor = selectedTextColor;
    self.lblSelectedLeftText.textColor = selectedTextColor;
}

-(void)setTextFont:(UIFont *)textFont{
    self.lblLeftText.font = textFont;
    self.lblRightText.font = textFont;
    self.lblSelectedLeftText.font = textFont;
    self.lblSelectedRightText.font = textFont;
}

-(void)setBackgroundColor:(UIColor *)backgroundColor{
    self.backgroundView.backgroundColor = backgroundColor;
}
-(void)setSelectedBackgroundColor:(UIColor *)selectedBackgroundColor{
    self.buttonControl.backgroundColor = selectedBackgroundColor;
}

-(void)setLeftSelectedTextColor:(UIColor *)leftSelectedTextColor{
    self.lblSelectedLeftText.textColor = leftSelectedTextColor;
}
-(void)setRightSelectedTextColor:(UIColor *)rightSelectedTextColor{
    self.lblSelectedRightText.textColor = rightSelectedTextColor;
}

-(void)setBackgroundViewBorderWidth:(CGFloat)backgroundViewBorderWidth{
    self.backgroundView.layer.borderWidth = backgroundViewBorderWidth;
}
-(void)setBackgroundViewBorderColor:(UIColor *)backgroundViewBorderColor{
    self.backgroundView.layer.borderColor = backgroundViewBorderColor.CGColor;
}

-(void)setVibrancyBackground:(BOOL)vibrancyBackground{
    if(vibrancyBackground){
        
        self.backgroundColor = [UIColor clearColor];
        
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        
        UIVibrancyEffect *vibrancy = [UIVibrancyEffect effectForBlurEffect:blur];
        
        UIVisualEffectView *backgroundBlur = [[UIVisualEffectView alloc]initWithEffect:blur];
        backgroundBlur.frame = self.backgroundView.bounds;
        backgroundBlur.layer.cornerRadius = backgroundBlur.bounds.size.height / 2;
        backgroundBlur.layer.masksToBounds = YES;
        
        UIVisualEffectView *backgroundVibrancy = [[UIVisualEffectView alloc]initWithEffect:vibrancy];
        backgroundVibrancy.frame = self.backgroundView.bounds;
        backgroundVibrancy.layer.cornerRadius = backgroundVibrancy.bounds.size.height / 2;
        backgroundVibrancy.layer.masksToBounds = YES;
        
        [self.backgroundView addSubview:backgroundBlur];
        [self.backgroundView addSubview:backgroundVibrancy];
        
    }
}
@end
