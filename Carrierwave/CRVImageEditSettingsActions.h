//
//  CRVImageEditToolbar.h
//  Carrierwave
//
//  Created by Paweł Białecki on 12.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

@import Foundation;

/**
 *  The CRVImageEditSettingsActions protocol provides a common interface for customizing the settings view on the CRVImageEdit screen.
 */
@protocol CRVImageEditSettingsActions <NSObject>

@required

@property (strong, nonatomic) UIView *doneTriggerView;

/**
 *  Action for canceling image editing. Default implementation as UIButton UIControlEventTouchUpInside event.
 */
- (SEL)cancelAction;

/**
 *  Action that tells that image editing is done. Default implementation as UIButton UIControlEventTouchUpInside event.
 */
- (SEL)doneAction;

/**
 *  Action for showing UIAlertController that selects the cropping frame's aspect ratio. Default implementation as UIButton UIControlEventTouchUpInside event.
 */
- (SEL)ratioAction;

@optional

@property (strong, nonatomic) UIView *ratioTriggerView;

@end
