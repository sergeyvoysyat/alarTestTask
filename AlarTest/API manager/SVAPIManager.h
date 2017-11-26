//
//  SVAPIManager.h
//  AlarTestTask
//
//  Created by Dead Inside on 24/11/2017.
//  Copyright © 2017 Sergey Voysyat. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SVDataPage;

@protocol SVAPIManagerDelegate <NSObject>

@optional
- (void)didGetSignInResponse:(BOOL)signedIn error:(NSError *)error;
- (void)didGetRequestedPage:(SVDataPage *)page;
- (void)didDownloadIcon:(UIImage *)icon;

@end

@interface SVAPIManager : NSObject

@property (weak, nonatomic) id <SVAPIManagerDelegate> delegate;

+ (instancetype)defaultManager;

- (void)signInWithUsername:(NSString *)username password:(NSString *)password;
- (void)requestNextPage;
- (void)loadLocationIcon;

@end
