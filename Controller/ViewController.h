//
//  ViewController.h
//  SearchImagesVR
//
//  Created by Виталий Рыжов on 08.02.17.
//  Copyright © 2017 VitaliyRyzhov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZoomViewController.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "CHTCollectionViewWaterfallLayout.h"
#define kTagImageView 100

@interface ViewController : UIViewController<UISearchBarDelegate, UICollectionViewDataSource,UINavigationControllerDelegate,UIViewControllerAnimatedTransitioning>
{
    NSMutableArray  *photoTitles;         
    NSMutableArray  *photoSmallImageData;
    NSMutableArray  *photoURLsLargeImage;
    NSMutableArray  *sizeOfLargeImage;
    ZoomViewController *zoomedView;
    
    int pageNumber;
    long int maxImg;
}
@property (nonatomic,weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic,weak) IBOutlet UISearchBar *imageSearch;
@property (nonatomic) NSInteger currentPage;
@property (nonatomic, strong) NSArray *cellSizes;
CGRect AVMakeRectWithAspectRatioInsideRect(CGSize aspectRatio, CGRect boundingRect) NS_AVAILABLE(10_7, 4_0);
@end
