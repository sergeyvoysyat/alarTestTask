//
//  SVDataRecordTableViewCell.h
//  AlarTestTask
//
//  Created by Dead Inside on 25/11/2017.
//  Copyright © 2017 Sergey Voysyat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SVDataRecordTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *recordImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *countryLabel;

@end
