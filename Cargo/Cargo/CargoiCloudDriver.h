//
//  CargoiCloudDriver.h
//  Cargo
//
//  Created by Wess Cope on 3/28/13.
//  Copyright (c) 2013 Wess Cope. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CargoStorageDriverProtocol.h"

@class CargoObject;
@interface CargoiCloudDriver : NSObject<CargoStorageDriverProtocol>
+ (instancetype)instance;
- (void)saveDocument:(NSDictionary *)document forEntityName:(NSString *)entityName;
- (BOOL)revertToLastSaveForEntityName:(NSString *)entityName;
- (void)deleteEntityName:(NSString *)entityName;
- (id)getDocumentForEntityName:(NSString *)entityName;
- (id)getBackupDocumentForEntityName:(NSString *)entityName;
@end
