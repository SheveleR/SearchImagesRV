//
//  URLS.h
//  SearchImagesVR
//
//  Created by Виталий Рыжов on 08.02.17.
//  Copyright © 2017 VitaliyRyzhov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SearchText;

@interface URLS : NSManagedObject

@property (nonatomic, retain) NSString * largeUrls;
@property (nonatomic, retain) NSString * smallUrls;
@property (nonatomic, retain) SearchText *searchUrl;

@end
