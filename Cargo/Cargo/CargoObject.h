//
//  CargoObject.h
//  Cargo
//
//  Created by Wess Cope on 3/28/13.
//  Copyright (c) 2013 Wess Cope. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CargoObject : NSObject
- (instancetype)initWithEntityName:(NSString *)entityName;
- (id)fetch;
- (id)fetchBackup;
- (void)save;
- (void)delete;
- (void)revertToLast;

+ (Class)CargoStorageDriverClass;
@end
