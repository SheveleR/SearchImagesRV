//
//  ViewController.m
//  SearchImagesVR
//
//  Created by Виталий Рыжов on 08.02.17.
//  Copyright © 2017 VitaliyRyzhov. All rights reserved.
//

#import "ViewController.h"
#import "FlickrPhotoCell.h"
#import "Reachability.h"
#import <AFNetworking/AFNetworking.h>
#import <UIImageView+AFNetworking.h>
#import "ZoomViewController.h"
#import "MHUIImageViewContentViewAnimation.h"
#import <AVFoundation/AVBase.h>
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "URLS.h"
#import "SearchText.h"
#import <CHTCollectionViewWaterfallLayout.h>
#define kFlickrAPIKey @"92aea3c5e788f3f42dd6e5f2d63e39b5"

#define kDefaultUrl_Thumbnail @"http://i.utdstc.com/icons/flickr-android.png"
#define kDefaultUrl_Medium @"https://cdn0.iconfinder.com/data/icons/yooicons_set01_socialbookmarks/512/social_flickr_box.png"



@interface ViewController ()<CHTCollectionViewDelegateWaterfallLayout>

@end

@implementation ViewController

#pragma mark - Accessors

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        layout.headerHeight = 0;
        layout.footerHeight = 0;
        layout.minimumColumnSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        
    }
    return _collectionView;
}

- (NSArray *)cellSizes {
    if (!_cellSizes) {
        _cellSizes = @[
                       [NSValue valueWithCGSize:CGSizeMake(400, 550)],
                       [NSValue valueWithCGSize:CGSizeMake(1000, 665)],
                       [NSValue valueWithCGSize:CGSizeMake(1024, 689)],
                       [NSValue valueWithCGSize:CGSizeMake(640, 427)]
                       ];
    }
    return _cellSizes;
}

- (void)dealloc {
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.imageSearch.placeholder = @"You can search here";
    self.imageSearch.returnKeyType = UIReturnKeyDone;
    self.imageSearch.keyboardType = UIKeyboardTypeNamePhonePad;
   
    photoTitles = [[NSMutableArray alloc] init];
    photoSmallImageData = [[NSMutableArray alloc] init];
    photoURLsLargeImage = [[NSMutableArray alloc] init];
    sizeOfLargeImage = [[NSMutableArray alloc]init];
    pageNumber = 1;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateLayoutForOrientation:[UIApplication sharedApplication].statusBarOrientation];
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self updateLayoutForOrientation:toInterfaceOrientation];
}

- (void)updateLayoutForOrientation:(UIInterfaceOrientation)orientation {
    CHTCollectionViewWaterfallLayout *layout =
    (CHTCollectionViewWaterfallLayout *)self.collectionView.collectionViewLayout;
    layout.columnCount = UIInterfaceOrientationIsPortrait(orientation) ? 3 : 4;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Searchbar Delegates

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}

-(BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if ([text isEqualToString:@" "]) {
        return NO;
    }
    else {
        return YES;
    }

}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    [photoSmallImageData removeAllObjects];
    [photoURLsLargeImage removeAllObjects];
    [photoTitles removeAllObjects];
    [sizeOfLargeImage removeAllObjects];
    pageNumber = 1;

    if (networkStatus == NotReachable)
    {
        NSLog(@"There IS NO internet connection");
        NSMutableArray * urlArray = [self fetchingUrlFromDb:searchBar.text];

        if ([urlArray count] == 0) {
            UIAlertView *alrt = [[UIAlertView alloc]initWithTitle:@"Please Connect to the Internet" message:@"No matches found!!" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
            [alrt show];
        }
        
        for (int i = 0; i < [urlArray count]; i++)
        {
            NSManagedObject *saveUrl = [urlArray objectAtIndex:i];
            NSString *urlStr = [saveUrl valueForKey:@"largeUrls"];
            NSURL * url = [NSURL URLWithString:urlStr];
            [photoURLsLargeImage addObject:url];
            
            NSString *thumbUrlStr = [saveUrl valueForKey:@"smallUrls"];
            NSURL * thumburl = [NSURL URLWithString:thumbUrlStr];
            [photoSmallImageData addObject:thumburl];
        }
        
        [self.collectionView reloadData];
    }
    else
    {
        NSLog(@"Available connection");
        [self searchFlickrPhotos:searchBar.text];
    }

    [searchBar resignFirstResponder];
}

#pragma mark - Flickr

-(void)searchFlickrPhotos:(NSString *)text
{
    //setup by AFNetwork
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&text=%@&per_page=20&extras=url_t,url_m&page=%d&format=json&nojsoncallback=1", kFlickrAPIKey, text,pageNumber++]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             CGFloat total = [[[responseObject objectForKey:@"photos"]objectForKey:@"total"]floatValue];
             NSArray *flickrPhotos = [[responseObject objectForKey:@"photos"] objectForKey:@"photo"];
             [self addDataToArray:flickrPhotos];
             [self createNewEntity:text];

             maxImg = total;
             [self.collectionView reloadData];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error AFNet: %@", error.localizedDescription);
     }];
}

-(void) addDataToArray :(NSArray*) flickrPhotos
{
    for (NSDictionary *photo in flickrPhotos)
    {
        NSString *title = [photo objectForKey:@"title"];
        [photoTitles addObject:(title.length > 0 ? title : @"Untitled")];

        NSString *photoURLString = [photo objectForKey:@"url_t"];
        if (photoURLString == nil) {
            photoURLString = kDefaultUrl_Thumbnail;
        }
        
        [photoSmallImageData addObject:photoURLString];
        
        photoURLString = [photo objectForKey:@"url_m"];
        
        if (photoURLString == nil) {
            photoURLString = kDefaultUrl_Medium;
        }
        
        [photoURLsLargeImage addObject:photoURLString];
        
        CGSize size = CGSizeMake([[photo objectForKey:@"width_m"] floatValue], [[photo objectForKey:@"height_m"]floatValue]);
        NSValue *sizeObj = [NSValue valueWithCGSize:size];
        [sizeOfLargeImage addObject:sizeObj];
    }
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [photoSmallImageData count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];

    
    FlickrPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FlickrCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];

    if ([photoSmallImageData count] == 0)
    {
        return nil;
    }
    
    if (networkStatus == NotReachable) {
        
        [[cell imageView]setImageWithURL:[photoSmallImageData objectAtIndex:indexPath.row]];

    }else {
        
        [[cell imageView]setImageWithURL:[NSURL URLWithString:[photoSmallImageData objectAtIndex:indexPath.row]] placeholderImage:[UIImage imageNamed:@"Searcher.png"]];

    }

    [cell.imageView setTag:kTagImageView];
    if (indexPath.row == [photoSmallImageData count]-1 && pageNumber< maxImg )
    {
        [self searchFlickrPhotos:self.imageSearch.text];
    }
    return cell;
}

#pragma mark  UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [collectionView layoutAttributesForItemAtIndexPath:indexPath];
    CGRect cellRect = attributes.frame;
    CGRect cellFrameInSuperview = [collectionView convertRect:cellRect toView:[collectionView superview]];
    CGPoint point = CGPointMake(cellFrameInSuperview.origin.x + (cellFrameInSuperview.size.width / 2),
                                cellFrameInSuperview.origin.y + (cellFrameInSuperview.size.height / 2)
                                );
    [self.navigationController setDelegate:self];


    zoomedView = [self.storyboard instantiateViewControllerWithIdentifier:@"zoomStoryBoardIdentifier"];
    [zoomedView setArr_LargeURL:photoURLsLargeImage];
    [zoomedView setArr_SmallURL:photoSmallImageData];
    [zoomedView setArr_imageName:photoTitles];
    [zoomedView setArr_LargeImgSize:sizeOfLargeImage];
    [zoomedView setCv:collectionView];
    [zoomedView setIndexPathOfCollectionView:indexPath];
    [zoomedView setRow:indexPath.row];
    [zoomedView setCenterOfCell:point];
    
    [self.navigationController pushViewController:zoomedView animated:YES];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{

}
#pragma mark - CHTCollectionViewDelegateWaterfallLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.cellSizes[indexPath.item % 4] CGSizeValue];
}
#pragma mark - UINavigationControllerDelegate

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    if (operation == UINavigationControllerOperationPush)
    {
        return zoomedView;
    }
    if (operation == UINavigationControllerOperationPop)
    {
        return self;
    }
    return nil;
}

#pragma mark Custom Animation

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return .5;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    ZoomViewController *fromViewController = (ZoomViewController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    ViewController *toViewController = (ViewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    UIImageView *imageView =  (UIImageView*)[[[fromViewController.pageViewController.viewControllers firstObject] view]viewWithTag:506];
    
    if (!imageView.image) {
        NSLog(@"NO Image");
        [imageView setImageWithURL:[NSURL URLWithString:kDefaultUrl_Medium]];
    }

    toViewController.currentPage = fromViewController.indexPathOfCollectionView.row;
    MHUIImageViewContentViewAnimation *cellImageSnapshot;
    
    if(orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        cellImageSnapshot = [[MHUIImageViewContentViewAnimation alloc] initWithFrame:CGRectMake(0, 45.5, fromViewController.view.frame.size.width, fromViewController.view.frame.size.height)];
    }
    else if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
    {
        cellImageSnapshot = [[MHUIImageViewContentViewAnimation alloc] initWithFrame:CGRectMake(0, 32, fromViewController.view.frame.size.width, fromViewController.view.frame.size.height - 37 )];
    }
    
    cellImageSnapshot.contentMode = UIViewContentModeScaleAspectFit;
    cellImageSnapshot.image = imageView.image;
    imageView.hidden = YES;
    
    UIImage *image = imageView.image;
    
    
    [cellImageSnapshot setFrame:AVMakeRectWithAspectRatioInsideRect(image.size, cellImageSnapshot.frame)];
    UICollectionViewLayoutAttributes *attributes = [toViewController.collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:toViewController.currentPage inSection:0]];
    CGRect cellRect = attributes.frame;
    CGRect cellFrameInSuperview = [toViewController.collectionView convertRect:cellRect toView:[toViewController.collectionView superview]];
    
    UIImageView *tempImgView = [[UIImageView alloc] initWithFrame:cellFrameInSuperview];
    
    [tempImgView setBackgroundColor:[UIColor whiteColor]];
    [containerView addSubview:tempImgView];
    [containerView addSubview:cellImageSnapshot];
    [containerView insertSubview:toViewController.view belowSubview:fromViewController.view];
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        fromViewController.view.alpha = 0.0;
        
        cellImageSnapshot.frame =cellFrameInSuperview;
    } completion:^(BOOL finished)
     {
         [tempImgView removeFromSuperview];
         [cellImageSnapshot removeFromSuperview];
         imageView.hidden = NO;
         [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
     }];
}

#pragma mark - CoreData

-(void) createNewEntity :(NSString *)entityName
{
    AppDelegate *appDelegate  = [[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];

    SearchText *searchText = [NSEntityDescription
                                      insertNewObjectForEntityForName:@"SearchText"
                                      inManagedObjectContext:context];
    [searchText setValue:entityName forKey:@"text"];
        
    NSEntityDescription *entityUrlOfText = [NSEntityDescription entityForName:@"URLS" inManagedObjectContext:context];

    for (int i = 0; i < [photoSmallImageData count] ; i++)
    {
        NSManagedObject *newUrl = [[NSManagedObject alloc] initWithEntity:entityUrlOfText insertIntoManagedObjectContext:context];
        [newUrl setValue:[photoURLsLargeImage objectAtIndex:i] forKey:@"largeUrls"];
        [newUrl setValue:[photoSmallImageData objectAtIndex:i] forKey:@"smallUrls"];
        
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Bad idea: %@", [error localizedDescription]);
        }else{
            NSMutableSet *urlOfText = [searchText mutableSetValueForKey:@"urlRelationship"];
            [urlOfText addObject:newUrl];
        }
    }
    [self fetchingUrlFromDb:entityName];
}

-(NSMutableArray *) fetchingUrlFromDb :(NSString *)textSearch
{
    AppDelegate *appDelegate  = [[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"URLS"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"searchUrl.text LIKE[c] %@",textSearch];
    [fetchRequest setPredicate:predicate];
    NSMutableArray * localArr = [[NSMutableArray alloc] initWithArray:[context executeFetchRequest:fetchRequest error:nil]];
    
    return localArr;
}

@end
