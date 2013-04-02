//
//  CEUserDefaultsDriver.h
//  CargoExample
//
//  Created by Wess Cope on 4/2/13.
//  Copyright (c) 2013 Wess Cope. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cargo/CargoStorageDriverProtocol.h>

@interface CEUserDefaultsDriver : NSObject<CargoStorageDriverProtocol>
+ (instancetype)instance;
- (void)saveDocument:(NSDictionary *)document forEntityName:(NSString *)entityName;
- (void)deleteEntityName:(NSString *)entityName;
- (id)getDocumentForEntityName:(NSString *)entityName;
@end
