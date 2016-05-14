//
//  SegmentSwitcher
//
//  Created by Alvaro Royo on 30/4/16.
//  Copyright © 2016 alvaroroyo. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SegmentSwitcherDelegate;

@interface SegmentSwitcher : UIView <UIGestureRecognizerDelegate>

@property (nonatomic,weak) id<SegmentSwitcherDelegate> delegate;

@property (strong,nonatomic) NSString *leftText;
@property (strong,nonatomic) NSString *rightText;

@property (strong,nonatomic) UIColor *leftSelectedTextColor;
@property (strong,nonatomic) UIColor *rightSelectedTextColor;

@property (strong,nonatomic) UIColor *textColor;
@property (strong,nonatomic) UIColor *selectedTextColor;
@property (strong,nonatomic) UIFont *textFont;

@property (strong,nonatomic) UIColor *backgroundColor;
@property (strong,nonatomic) UIColor *selectedBackgroundColor;

@property (nonatomic) CGFloat backgroundViewBorderWidth;
@property (strong,nonatomic) UIColor *backgroundViewBorderColor;

@property (nonatomic) BOOL vibrancyBackground;

@property (nonatomic) BOOL vibrancyBorder;

@end

@protocol SegmentSwitcherDelegate <NSObject>

/*!
 Delegate method.
 Send the Runkeeper object like sender param and the selected index.
 */
@required
-(void)segment:(SegmentSwitcher *)sender DidChangeIndex:(NSInteger)index;

@end
