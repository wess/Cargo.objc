//
//  CargoDropboxDriver.h
//  Cargo
//
//  Created by Wess Cope on 4/2/13.
//  Copyright (c) 2013 Wess Cope. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CargoStorageDriverProtocol.h"

static NSString *const CargoDropboxAppKey       = @"";
static NSString *const CargoDropboxAppSecret    = @"";

@class CargoObject;
@interface CargoDropboxDriver : NSObject<CargoStorageDriverProtocol>
@property (readonly, nonatomic) NSDictionary *document;

+ (instancetype)instance;
+ (void)setupDropboxLink;
- (void)handleDropboxOpenURL:(NSURL *)url;
- (void)saveDocument:(NSDictionary *)document forEntityName:(NSString *)entityName;
- (void)deleteEntityName:(NSString *)entityName;
- (id)getDocumentForEntityName:(NSString *)entityName;

@end
