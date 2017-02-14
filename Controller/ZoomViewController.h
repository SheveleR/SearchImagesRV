//
//  ZoomViewController.h
//  SearchImagesVR
//
//  Created by Виталий Рыжов on 08.02.17.
//  Copyright © 2017 VitaliyRyzhov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZoomViewController : UIViewController<UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIViewControllerAnimatedTransitioning>{
}

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (nonatomic,strong) NSArray *arr_LargeURL;
@property (nonatomic,strong) NSArray *arr_SmallURL;
@property (nonatomic,strong) NSArray *arr_imageName;
@property (nonatomic,strong) NSArray *arr_LargeImgSize;
@property (nonatomic,strong) UICollectionView *cv;
@property (nonatomic,strong) NSIndexPath *indexPathOfCollectionView;
@property (nonatomic) NSInteger row;
@property (nonatomic) CGPoint centerOfCell;



@end
