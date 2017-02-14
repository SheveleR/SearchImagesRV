//
//  SearchText.h
//  SearchImagesVR
//
//  Created by Виталий Рыжов on 08.02.17.
//  Copyright © 2017 VitaliyRyzhov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class URLS;

@interface SearchText : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSSet *searchUrl;
@end

@interface SearchText (CoreDataGeneratedAccessors)

- (void)addSearchUrlObject:(URLS *)value;
- (void)removeSearchUrlObject:(URLS *)value;
- (void)addSearchUrl:(NSSet *)values;
- (void)removeSearchUrl:(NSSet *)values;

@end
