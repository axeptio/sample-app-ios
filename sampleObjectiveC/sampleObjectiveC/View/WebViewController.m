//
//  WebViewController.m
//  sampleObjectiveC
//
//  Created by Noeline PAGESY on 17/04/2024.
//

#import "WebViewController.h"

@import WebKit;

@interface WebViewController ()

@property (retain, nonatomic) WKWebView *webView;
@property (retain, nonatomic) NSURL *url;

@end

@implementation WebViewController

- (id)initWithURL:(NSURL *)url
{
    self = [super init];
    if (self) {
        _url = url;
        [self clearLocalStorageBeforeInit];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _webView = [[WKWebView alloc] initWithFrame:[[self view] bounds]];
    [self.view addSubview:_webView];

    NSURLRequest *urlReq = [NSURLRequest requestWithURL:_url];
    NSLog(@"Opening webview with url: %@", urlReq);
    [_webView loadRequest:urlReq];
}

- (void)clearLocalStorageBeforeInit {
    [[WKWebsiteDataStore defaultDataStore] fetchDataRecordsOfTypes:[WKWebsiteDataStore allWebsiteDataTypes] completionHandler:^(NSArray<WKWebsiteDataRecord *> *records) {
        for (WKWebsiteDataRecord *record in records) {
            [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:record.dataTypes forDataRecords:@[record] completionHandler:^{}];
            NSLog(@"WKWebsiteDataStore record deleted: %@", record);
        }
    }];
}

@end
