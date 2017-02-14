//
//  MHUIImageViewContentViewAnimation.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 30.12.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import "MHUIImageViewContentViewAnimation.h"

@interface MHUIImageViewContentViewAnimation ()

@property (nonatomic,readwrite) CGRect      changedFrameWrapper;
@property (nonatomic,readwrite) CGRect      changedFrameImage;
@property (nonatomic,strong)    UIImageView *imageView;

@end

@implementation MHUIImageViewContentViewAnimation
@synthesize sizeOfImage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:self.imageView];

        self.clipsToBounds = YES;
    }
    return self;
}

-(void)animateToViewMode:(UIViewContentMode)contenMode
                forFrame:(CGRect)frame
            withDuration:(float)duration
              afterDelay:(float)delay
                finished:(void (^)(BOOL finished))finishedBlock{

    switch (contenMode) {
        case UIViewContentModeScaleAspectFill:{
            [self initToScaleAspectFillToFrame:frame];
            [UIView animateWithDuration:duration animations:^{
                [self animateToScaleAspectFill];
            } completion:^(BOOL finished) {
                [self animateFinishToScaleAspectFill];
                if(finishedBlock){
                    finishedBlock(YES);
                }
            }];
        }
            break;
        case UIViewContentModeScaleAspectFit:{
            [self initToScaleAspectFitToFrame:frame];
            [UIView animateWithDuration:duration animations:^{
                [self animateToScaleAspectFit];
            } completion:^(BOOL finished) {
                

                if(finishedBlock){
                    finishedBlock(YES);
                }
                    
                
            }];
        }
            break;
            
        default:
            break;
    }
    
}
-(void)checkImageViewHasImage{
    if (!self.imageView.image) {

        UIView *view = [[UIView alloc] initWithFrame:self.imageView.frame];
        view.backgroundColor = [UIColor whiteColor];
    }
}
 
- (void)initToScaleAspectFitToFrame:(CGRect)newFrame{
    [self checkImageViewHasImage];
    float ratioImage = (self.imageView.image.size.width)/(self.imageView.image.size.height);
    NSLog(@"ImgViewFrame %f -- %f",self.imageView.image.size.width,self.imageView.image.size.height);
    
    ratioImage  = self.sizeOfImage.width/self.sizeOfImage.height;
    NSLog(@"ImgViewFrameNew %f",ratioImage);


    NSLog(@"initToScaleAspectFitToFrame Rect is: %@",NSStringFromCGRect(newFrame));

    self.imageView.contentMode = UIViewContentModeScaleAspectFit;

    self.changedFrameImage = CGRectMake(0, 0, newFrame.size.width, newFrame.size.height);
    NSLog(@"initToScaleAspectFitToFrame self.changedFrameImage Rect is: %@",NSStringFromCGRect(self.changedFrameImage));

    self.changedFrameWrapper = newFrame;
    
}

- (void)initToScaleAspectFillToFrame:(CGRect)newFrame{
    NSLog(@"initToScaleAspectFillToFrame Rect is: %@",NSStringFromCGRect(newFrame));

    float ratioImg = (self.imageView.image.size.width) / (self.imageView.image.size.height);
    ratioImg = 1;
    if ([self choiseFunctionWithRationImg:ratioImg forFrame:newFrame]) {
        self.changedFrameImage = CGRectMake( - (newFrame.size.height * ratioImg - newFrame.size.width) / 2.0f, 0, newFrame.size.height * ratioImg, newFrame.size.height);
    }else{
        self.changedFrameImage = CGRectMake(0, - (newFrame.size.width / ratioImg - newFrame.size.height) / 2.0f, newFrame.size.width, newFrame.size.width / ratioImg);
    }
    self.changedFrameWrapper = newFrame;
    NSLog(@"initToScaleAspectFillToFrame changedFrameWrapper Rect is: %@",NSStringFromCGRect(self.changedFrameWrapper));

}
- (void)animateToScaleAspectFit{
    self.imageView.frame = _changedFrameImage;
    NSLog(@"animateToScaleAspectFit Rect is: %@",NSStringFromCGRect(self.imageView.frame));

    [super setFrame:_changedFrameWrapper];
}

- (void)animateToScaleAspectFill
{
    self.imageView.frame = _changedFrameImage;
    NSLog(@"animateToScaleAspectFill Rect is: %@",NSStringFromCGRect(self.imageView.frame));

    [super setFrame:_changedFrameWrapper];
}

- (void)animateFinishToScaleAspectFill{
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.frame  = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    NSLog(@"animateFinishToScaleAspectFill Rect is: %@",NSStringFromCGRect(self.imageView.frame));

}

-(UIImage*)imageMH{
    return self.imageView.image;
}

- (void)setImage:(UIImage *)image{
    
    self.imageView.image = image;
}

- (UIImage *)image{
    return nil;
}

- (void)setContentMode:(UIViewContentMode)contentMode{
    self.imageView.contentMode = contentMode;
}

- (UIViewContentMode)contentMode{
    return self.imageView.contentMode;
}

- (void)setFrame:(CGRect)frame{
    
    
    [super setFrame:frame];
    self.imageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    
}

- (BOOL)choiseFunctionWithRationImg:(float)ratioImage forFrame:(CGRect)newFrame{
    BOOL resultat = NO;
    NSLog(@"choiseFunctionWithRationImg Rect is: %@",NSStringFromCGRect(newFrame));

    float ratioSelf = (newFrame.size.width)/(newFrame.size.height);
    if (ratioImage < 1) {
        if (ratioImage > ratioSelf ) resultat = true;
    }else{
        if (ratioImage > ratioSelf ) resultat = true;
    }
    return resultat;
}
@end