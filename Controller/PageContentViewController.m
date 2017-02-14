//
//  PageContentViewController.m
//  SearchImagesVR
//
//  Created by Виталий Рыжов on 08.02.17.
//  Copyright © 2017 VitaliyRyzhov. All rights reserved.
//

#import "PageContentViewController.h"
#import <UIImageView+AFNetworking.h>
#import "Reachability.h"
#define kDefaultUrl_Medium @"https://cdn0.iconfinder.com/data/icons/yooicons_set01_socialbookmarks/512/social_flickr_box.png"

@interface PageContentViewController ()

@end

@implementation PageContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *dummyImage = [UIImage imageNamed:@"Searcher.png"];
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    NSURL *imageURL;
    NSURL *dummyUrl;

    if (networkStatus == NotReachable) {
        imageURL= (NSURL*)_imageFile;
        dummyUrl = (NSURL*)_smallImageUrl;

    }else{
        imageURL= [NSURL URLWithString:_imageFile];
        dummyUrl = [NSURL URLWithString:_smallImageUrl];
    }
    
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:imageURL];
    
   [_largeImageView setImageWithURL:dummyUrl placeholderImage:nil];
    

    
    [_activityIndicator setHidden:NO];
    [_activityIndicator startAnimating];
    
    
    
    [_largeImageView setImageWithURLRequest:imageRequest
                      placeholderImage:nil
                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         [_activityIndicator setHidden:YES];
         [_activityIndicator stopAnimating];
         _largeImageView.image = image;
         
     }
                               failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
     {
         if (_largeImageView.image.size.width == 0) {
             
             NSLog(@"zero size");
             _largeImageView.image = dummyImage;

         }
         
         
         [_activityIndicator setHidden:YES];
         [_activityIndicator stopAnimating];
     }];
}

-(void)viewWillAppear:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onBack:(id)sender {
    
}

@end
