//
//  SVDataPage.h
//  AlarTestTask
//
//  Created by Dead Inside on 25/11/2017.
//  Copyright © 2017 Sergey Voysyat. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SVDataRecord;

@interface SVDataPage : NSObject

@property (nonatomic, readonly) NSArray *allRecords;

- (void)addRecord:(SVDataRecord *)record;

@end
