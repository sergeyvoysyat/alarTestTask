//
//  SVAPIManager.m
//  AlarTestTask
//
//  Created by Dead Inside on 24/11/2017.
//  Copyright © 2017 Sergey Voysyat. All rights reserved.
//

#import "SVAPIManager.h"
#import "SVDataPage.h"
#import "SVDataRecord.h"

@interface SVAPIManager () <NSURLSessionDelegate, NSURLSessionDataDelegate, NSURLSessionDownloadDelegate>

@property (nonatomic) NSURLSession *session;

@property (nonatomic) NSURLSessionDataTask *signInTask;
@property (nonatomic) NSMutableArray <NSURLSessionDataTask *> *taskQueue;

@property (nonatomic) NSString *userCode;

@property (nonatomic) BOOL isDelegateWaitForPage;
@property (nonatomic) BOOL isNewPageAvailable;
@property (nonatomic) BOOL isPreparingNewPage;
@property (nonatomic) SVDataPage *currentPage;
@property (nonatomic) NSUInteger nextLoadPageIndex;

@end

@implementation SVAPIManager

+ (instancetype)defaultManager {
    static SVAPIManager *manager;
    
    if (!manager) {
        manager = [[SVAPIManager alloc] initPrivate];
    }
    
    return manager;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"SVIAPIManager: singleton" reason:@"Use +defaultManager" userInfo:nil];
}

- (instancetype)initPrivate
{
    self = [super init];
    if (self) {
        self.taskQueue = [NSMutableArray array];
        self.isDelegateWaitForPage = NO;
        self.isNewPageAvailable = NO;
        self.isPreparingNewPage = YES;
        self.nextLoadPageIndex = 1;
        [self initURLSession];
    }
    return self;
}

- (void)initURLSession {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
}

#pragma mark -

- (void)signInWithUsername:(NSString *)username password:(NSString *)password {
    NSURL *URL = [NSURL URLWithString:[self pathFromURLString:@"http://condor.alarstudios.com/test/auth.cgi?" withParameters:@{@"username": username, @"password": password}]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    self.signInTask = [self.session dataTaskWithRequest:request];
    [self.signInTask resume];
}

- (void)fetchDataWithUserCode:(NSString *)code pageIndex:(NSUInteger)pageIndex {
    NSString *p = [NSString stringWithFormat:@"%lu", (unsigned long)pageIndex];
    NSURL *URL = [NSURL URLWithString:[self pathFromURLString:@"http://condor.alarstudios.com/test/data.cgi?" withParameters:@{@"code": self.userCode, @"p": p}]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request];
    [task resume];
}

- (void)loadLocationIcon {
    NSURL *URL = [NSURL URLWithString:@"https://mt.googleapis.com/vt/icon/name=icons/onion/SHARED-mymaps-pin-container_4x.png,icons/onion/1899-blank-shape_pin_4x.png&highlight=0288D1&scale=2.0"];
    
    NSURLSessionDownloadTask *task = [self.session downloadTaskWithURL:URL];
    [task resume];
}

- (NSString *)pathFromURLString:(NSString *)string withParameters:(NSDictionary <NSString *, NSString *> *)parameters {
    NSMutableString *URLString = [[NSMutableString alloc] initWithString:string];
    
    BOOL isFirstParameter = YES;
    for (NSString *k in parameters) {
        if (isFirstParameter) {
            isFirstParameter = NO;
        } else {
            [URLString appendString:@"&"];
        }
        
        [URLString appendString:[NSString stringWithFormat:@"%@=%@", k, parameters[k]]];
    }
    
    return [URLString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
}

- (void)addPageWithJSONData:(NSArray *)array {
    SVDataPage *page = [[SVDataPage alloc] init];
    for (NSDictionary *d in array) {
        SVDataRecord *record = [[SVDataRecord alloc] init];
        record.identificator = d[@"id"];
        record.name = d[@"name"];
        record.country = d[@"country"];
        record.latitude = d[@"lat"];
        record.longitude = d[@"lon"];
        [page addRecord:record];
    }
    self.currentPage = page;
    
    self.isNewPageAvailable = YES;
    self.isPreparingNewPage = NO;
    self.nextLoadPageIndex++;
    if (self.isDelegateWaitForPage) {
        [self sendNeededPageIfAvailable];
    }
}

- (void)requestNextPage {
    self.isDelegateWaitForPage = YES;
    [self sendNeededPageIfAvailable];
}

- (void)sendNeededPageIfAvailable {
    if (self.isNewPageAvailable) {
        self.isDelegateWaitForPage = NO;
        self.isNewPageAvailable = NO;
        
        [self.delegate didGetRequestedPage:self.currentPage];
    } else if (!self.isPreparingNewPage) {
        self.isPreparingNewPage = YES;
        [self fetchDataWithUserCode:self.userCode pageIndex:self.nextLoadPageIndex];
    }
}
#pragma mark - Data Task delegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    NSError *error;
    NSJSONSerialization *JSONResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    if ([dataTask isEqual:self.signInTask]) {
        BOOL signedIn = NO;
        if (!error) {
            NSDictionary *JSONDictionary = (NSDictionary *)JSONResponse;
            NSLog(@"%@", JSONResponse);
            NSLog(@"%@", JSONDictionary);
            NSLog(@"%@", dataTask.originalRequest);
            if ([JSONDictionary[@"status"] isEqualToString:@"ok"]) {
                signedIn = YES;
                self.userCode = JSONDictionary[@"code"];
                
                [self fetchDataWithUserCode:self.userCode pageIndex:0];
            }
        } else {
            #ifdef DEBUG
            NSLog(@"SVAPIManager.URLSession:dataTask:didReceiveData: -> Can't parse JSON with sign in info. Error: %@", error.localizedDescription);
            #endif
        }
        
        [self.delegate didGetSignInResponse:signedIn error:error];
        self.signInTask = nil;
    } else {
        if (!error) {
            NSDictionary *JSONDictionary = (NSDictionary *)JSONResponse;
            NSLog(@"%@", JSONResponse);
            if ([JSONDictionary[@"status"] isEqualToString:@"ok"]) {
                NSArray *fetchedData = JSONDictionary[@"data"];
                
                [self addPageWithJSONData:fetchedData];
            }
        } else {
            #ifdef DEBUG
            NSLog(@"SVAPIManager.URLSession:dataTask:didReceiveData: -> Can't parse JSON with page data. Error: %@", error.localizedDescription);
            #endif
            self.isPreparingNewPage = NO;
            self.isNewPageAvailable = NO;
        }
    }
}

#pragma mark - Download task delegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    if ([session isEqual:self.session]) {
        NSData *imageData = [NSData dataWithContentsOfURL:location];
        UIImage *image = [UIImage imageWithData:imageData];
        if (!image) {
            return;
        }
            
        [self.delegate didDownloadIcon:image];
    }
}

#pragma mark - Session delegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        #ifdef DEBUG
        NSLog(@"SVAPIManager.URLSession:task:didCompleteWithError: -> Error: %@", error.localizedDescription);
        #endif
    }
    
    //
    NSLog(@"did complete task");
    
    if ([task isKindOfClass:[NSURLSessionDataTask class]]) {
        NSURLSessionDataTask *dataTask = (NSURLSessionDataTask *)task;
        if (![dataTask isEqual:self.signInTask] && error) {
            self.isPreparingNewPage = NO;
            self.isNewPageAvailable = NO;
        }
    }
}

@end
