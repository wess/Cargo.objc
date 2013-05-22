//
//  CargoStorageDriverProtocol.h
//  Cargo
//
//  Created by Wess Cope on 3/28/13.
//  Copyright (c) 2013 Wess Cope. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 `CargoStorageDriverProtocol` defines the selectors to be used when creating storage drivers.
 */

@protocol CargoStorageDriverProtocol <NSObject>
///---------------------------------------------------------
/// @name Selectors needed to create custom storage driver.
///---------------------------------------------------------


@required

/**
 Dictionary used to store and read data to/from.
 
 @return Dictionary used for data.
 */
- (NSDictionary *)document;

/**
 All storage drivers must be singletons, and the instance method is how to access the shared instance of the driver.
 
 @return Shared instance of the storage driver.
 */
+ (instancetype)instance;

/**
 Saves a document to desired storage for a specific entity.
 
 @param document    Dictionary to store to the entity.
 
 @param entityName  Name of entity to store values to.
 */
- (void)saveDocument:(NSDictionary *)document forEntityName:(NSString *)entityName;

/**
 Removes an entity from storage.
 
 @param entityName name of entity to remove from storage.
 */
- (void)deleteEntityName:(NSString *)entityName;

@optional

/**
 If implemented, reverts the values for a specific entity to values before the last save was called.
 
 @param entityName  Name of entity to revert values for.
 
 @return YES or NO if entity was succesfully rolled back to previous values.
 */
- (BOOL)revertToLastSaveForEntityName:(NSString *)entityName;

/**
 If implemented, Gets values for backup entity before last save was called.
 
 @return object stored for entity from backup.
 */
- (id)getBackupDocumentForEntityName:(NSString *)entityName;

@end
