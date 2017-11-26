//
//  SVDataRecord.h
//  AlarTestTask
//
//  Created by Dead Inside on 25/11/2017.
//  Copyright © 2017 Sergey Voysyat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SVDataRecord : NSObject

@property (nonatomic) NSString *identificator;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *country;
@property (nonatomic) NSNumber *latitude;
@property (nonatomic) NSNumber *longitude;

@end
