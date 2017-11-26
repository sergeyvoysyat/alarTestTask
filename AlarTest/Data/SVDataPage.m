//
//  SVDataPage.m
//  AlarTestTask
//
//  Created by Dead Inside on 25/11/2017.
//  Copyright © 2017 Sergey Voysyat. All rights reserved.
//

#import "SVDataPage.h"
#import "SVDataRecord.h"

@interface SVDataPage ()

@property (nonatomic) NSMutableArray *records;

@end

@implementation SVDataPage

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.records = [NSMutableArray array];
    }
    return self;
}

- (NSArray *)allRecords {
    return self.records;
}

- (void)addRecord:(SVDataRecord *)record {
    [self.records addObject:record];
}

@end
