//
//  ZoomViewController.m
//  SearchImagesVR
//
//  Created by Виталий Рыжов on 08.02.17.
//  Copyright © 2017 VitaliyRyzhov. All rights reserved.
//

#import "ZoomViewController.h"
#import "PageContentViewController.h"
#import "ViewController.h"
#import "MHUIImageViewContentViewAnimation.h"
#import <UIImageView+AFNetworking.h>
#import "FlickrPhotoCell.h"
@interface ZoomViewController ()

@end

@implementation ZoomViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(home:)];

    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"pageViewControllerID"];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    
    PageContentViewController *startingViewController = [self viewControllerAtIndex:self.row];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.pageViewController.view.backgroundColor = [UIColor clearColor];
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];

}


-(void)home:(UIBarButtonItem *)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (PageContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    NSLog(@"Index>>>>>>> %lu",(unsigned long)index);

    if (([self.arr_LargeURL count] == 0) || (index >= [self.arr_LargeURL count])) {
        
        NSLog(@"Cont Zero");
        
        return nil;
    }
    
    
    // Create a new view controller and pass suitable data.
    PageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
    pageContentViewController.imageFile = self.arr_LargeURL[index];
    pageContentViewController.smallImageUrl = self.arr_SmallURL[index];
    pageContentViewController.pageIndex = index;
    return pageContentViewController;
}



#pragma mark - Page View Controller Data Source

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    PageContentViewController *controller = self.pageViewController.viewControllers[0];
    self.indexPathOfCollectionView = [NSIndexPath indexPathForItem:controller.pageIndex inSection:0];

    NSLog(@"Index -- %d",(int)self.indexPathOfCollectionView.row);
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;

    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;


    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;

    if (index == NSNotFound) {
        return nil;
    }

    index++;
    if (index == [self.arr_LargeURL count]) {
        return nil;
    }
   return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.arr_LargeURL count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 1;
}

#pragma mark animation
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.5;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    ViewController *fromViewController = (ViewController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    ZoomViewController *toViewController = (ZoomViewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
   
    UIView *containerView = [transitionContext containerView];
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    UICollectionView *collectionView = fromViewController.collectionView;
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:self.indexPathOfCollectionView];
    UIImageView *cellImageView = (UIImageView *)[cell viewWithTag:kTagImageView];
    
    UICollectionViewLayoutAttributes *attributes = [collectionView layoutAttributesForItemAtIndexPath:_indexPathOfCollectionView];
    CGRect cellRect = attributes.frame;
    CGRect cellFrameInSuperview = [collectionView convertRect:cellRect toView:[collectionView superview]];
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    MHUIImageViewContentViewAnimation *cellImageSnapshot = [[MHUIImageViewContentViewAnimation alloc] initWithFrame:cellFrameInSuperview];
    [cellImageSnapshot setBackgroundColor:[UIColor whiteColor]];
    cellImageSnapshot.contentMode = UIViewContentModeScaleAspectFit;


    UIImageView *imgV = [[UIImageView alloc]initWithImage:cellImageView.image];
    [imgV setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[_arr_LargeURL objectAtIndex:_indexPathOfCollectionView.row]]]];

    [cellImageSnapshot setImage:imgV.image];
    [self.view addSubview:cellImageSnapshot];
    
    cellImageView.hidden = YES;
    if(orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        toViewController.view.frame = CGRectMake(0, 64, [transitionContext finalFrameForViewController:toViewController].size.width, [transitionContext finalFrameForViewController:toViewController].size.height -64);
    }
    else if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
    {
        toViewController.view.frame = CGRectMake(0, 32, [transitionContext finalFrameForViewController:toViewController].size.width, [transitionContext finalFrameForViewController:toViewController].size.height - 32);
    }
    
    toViewController.view.alpha = 0;
    toViewController.pageViewController.view.hidden = YES;
    
    [containerView addSubview:toViewController.view];
    [containerView addSubview:cellImageSnapshot];
    
    if(orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            toViewController.view.alpha = 0.0;
            CGRect rect = CGRectMake(0, 64, toViewController.view.frame.size.width, toViewController.view.frame.size.height - 37);
            cellImageSnapshot.frame = rect;
        } completion:^(BOOL finished)
         {
             
         }];

    }
    else if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
    {
        
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            toViewController.view.alpha = 0.0;
            CGRect rect = CGRectMake(0, 32, toViewController.view.frame.size.width, toViewController.view.frame.size.height - 37);
            cellImageSnapshot.frame =rect;
        } completion:^(BOOL finished)
         {
         }];

    }
       
    [UIView animateWithDuration:duration animations:^{
        toViewController.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{

                cellImageSnapshot.transform = CGAffineTransformScale(CGAffineTransformIdentity,1.00,1.00);
            } completion:^(BOOL finished) {
                toViewController.pageViewController.view.hidden = NO;
                cellImageView.hidden = NO;
                [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
                [cellImageSnapshot removeFromSuperview];
            }];
        }];
    }];
}
@end
