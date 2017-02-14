//
//  PageContentViewController.h
//  SearchImagesVR
//
//  Created by Виталий Рыжов on 08.02.17.
//  Copyright © 2017 VitaliyRyzhov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageContentViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *largeImageView;
@property NSUInteger pageIndex;
@property NSString *titleText;
@property NSString *imageFile;
@property NSString *smallImageUrl;
@end
