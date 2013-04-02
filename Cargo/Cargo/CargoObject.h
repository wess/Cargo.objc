//
//  CargoObject.h
//  Cargo
//
//  Created by Wess Cope on 3/28/13.
//  Copyright (c) 2013 Wess Cope. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 `CargoObject` is a class for work with data. It is designed, after CoreData, to let you setup models with custom storage drivers.
 
 ## Subclassing
 When subclassing the following class method is required and tells the `CargoObject` which storage driver to use.
 + (Class)CargoStorageDriverClass
 
 */

@interface CargoObject : NSObject
///-------------------------------------------------------------------------------------------------------------------------------
/// @name Working with model data for storing fetching and reverting data, if optional methods are implemented in storage driver.
///-------------------------------------------------------------------------------------------------------------------------------

/**
 Create an instance of a CargoObject subclass with desired entity name.
 
 @param entityName Name of entity.
 
 @return instancetype Newly created instance of a `CargoObject` subclass.
 
 @note If just `init` is used, `CargoObject` will use the name of the class as the entity name.
 */
- (instancetype)initWithEntityName:(NSString *)entityName;

/**
 Fetches all stored objects for entity.
 
 @return Objects stored for an entity.
 */
- (id)fetch;

/**
 Fetchs the objects stored from a previous document, before the last save was called.
 
 @return Objects stored as a backup from entity state before last save.
 
 @note This selector will not work if the storage driver does not implement the backup selectors.
 */
- (id)fetchBackup;

/**
 Saves the current property values to a specific entity.
 */
- (void)save;

/**
 Deletes entity from storage from current instantiated object.
 */
- (void)delete;

/**
 Restores the values of the entity to values before the last save was called.
 
 @note This selector will not work if the storage driver does not implement the backup selectors.
 */
- (void)revertToLast;

/**
 Tells the `CargoObject` which storage engine to use.
 
 @return Class of storage driver.
 */
+ (Class)CargoStorageDriverClass;
@end
