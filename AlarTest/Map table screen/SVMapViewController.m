//
//  SVMapViewController.m
//  AlarTestTask
//
//  Created by Dead Inside on 26/11/2017.
//  Copyright © 2017 Sergey Voysyat. All rights reserved.
//

#import "SVMapViewController.h"
#import "SVMapTableViewCell.h"
#import "SVDataRecord.h"

@interface SVMapViewController () <MKMapViewDelegate>

@property (nonatomic) SVMapTableViewCell *mapCell;

@end

@implementation SVMapViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.mapCell = [[NSBundle mainBundle] loadNibNamed:@"SVMapTableViewCell" owner:self options:nil].firstObject;
        self.mapCell.mapView.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //[self.tableView registerNib:[UINib nibWithNibName:@"SVMapTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"SVMapTableViewCell"];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
}

//- (void)viewWillAppear:(BOOL)animated {
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return self.mapCell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
        
        switch (indexPath.row) {
            case 0: {
                NSString *text = [NSString stringWithFormat:@"ID: %@", self.record.identificator];
                cell.textLabel.text = text;
                break;
            }
            case 1: {
                cell.textLabel.text = self.record.name;
                break;
            }
            case 2: {
                cell.textLabel.text = self.record.country;
                break;
            }
            case 3: {
                NSString *text = [NSString stringWithFormat:@"Широта: %@", self.record.latitude];
                cell.textLabel.text = text;
                break;
            }
            case 4: {
                NSString *text = [NSString stringWithFormat:@"Долгота: %@", self.record.longitude];
                cell.textLabel.text = text;
                break;
            }
            default:
                break;
        }
        
        return cell;
    }
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return tableView.bounds.size.width;
    }
    return 40.0;
}

#pragma mark - Map view delegate

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered {
    if (!self.mapCell.mapLoaded) {
        self.mapCell.mapLoaded = YES;
        
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake([self.record.latitude doubleValue], [self.record.longitude doubleValue]);
        
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        [annotation setCoordinate:location];
        [annotation setTitle:self.record.identificator];
        [mapView addAnnotation:annotation];
        
        [mapView showAnnotations:@[annotation] animated:YES];
    }
}

@end
