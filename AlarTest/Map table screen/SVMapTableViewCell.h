//
//  SVMapTableViewCell.h
//  AlarTestTask
//
//  Created by Dead Inside on 26/11/2017.
//  Copyright © 2017 Sergey Voysyat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface SVMapTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) BOOL mapLoaded;

@end
