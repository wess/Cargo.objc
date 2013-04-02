//
//  CargoiCloudDriver.m
//  Cargo
//
//  Created by Wess Cope on 3/28/13.
//  Copyright (c) 2013 Wess Cope. All rights reserved.
//

#import "CargoiCloudDriver.h"
#import "Cargo.h"

@interface CargoiCloudDriver()
@property (strong, nonatomic) NSMutableDictionary   *documents;

- (void)handleExternalUpdates:(NSNotification *)notification;
- (NSString *)backupNameForEntityName:(NSString *)entityName;
@end

@implementation CargoiCloudDriver
+ (instancetype)instance
{
    static id _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    
    return _instance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        NSAssert([NSUbiquitousKeyValueStore defaultStore], @"iCloud must be enabled to use Cargo.");
        
        self.documents  = [[[NSUbiquitousKeyValueStore defaultStore] dictionaryRepresentation] mutableCopy];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleExternalUpdates:) name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:nil];
        
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString *)backupNameForEntityName:(NSString *)entityName
{
    return [NSString stringWithFormat:@"%@.backup", entityName];
}

- (void)handleExternalUpdates:(NSNotification *)notification
{
    NSDictionary *externalDocuments = [[NSUbiquitousKeyValueStore defaultStore] dictionaryRepresentation];
    
    __weak typeof(self) weakSelf = self;
    [externalDocuments enumerateKeysAndObjectsUsingBlock:^(NSString *entityName, NSDictionary *doc, BOOL *stop) {
        NSString *backupEntityName           = [self backupNameForEntityName:entityName];
        weakSelf.documents[backupEntityName] = [weakSelf.documents[entityName] mutableCopy];
        weakSelf.documents[entityName]       = [doc mutableCopy];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:CargoDidUpdateEntityNotification object:entityName];
        
    }];
}

- (id)getDocumentForEntityName:(NSString *)entityName
{
    return self.documents[entityName];
}

- (id)getBackupDocumentForEntityName:(NSString *)entityName
{
    NSString *backupName = [self backupNameForEntityName:entityName];
    return self.documents[backupName];
}

- (void)saveDocument:(NSDictionary *)document forEntityName:(NSString *)entityName
{
    if(self.documents[entityName])
    {
        NSString *backupName        = [self backupNameForEntityName:entityName];
        self.documents[backupName]  = [self.documents[entityName] mutableCopy];
    }
    
    self.documents[entityName] = [document mutableCopy];
    
    [[NSUbiquitousKeyValueStore defaultStore] setObject:document forKey:entityName];
    [[NSUbiquitousKeyValueStore defaultStore] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CargoDidSaveEntityNotification object:entityName];
}

- (void)deleteEntityName:(NSString *)entityName
{
    [self.documents removeObjectForKey:entityName];
    [[NSUbiquitousKeyValueStore defaultStore] removeObjectForKey:entityName];
}

- (BOOL)revertToLastSaveForEntityName:(NSString *)entityName
{
    NSString *backupName        = [self backupNameForEntityName:entityName];
    NSMutableDictionary *backup = self.documents[backupName];
    
    if(!backupName)
        return NO;
    
    self.documents[entityName] = [backup mutableCopy];
    [self saveDocument:backup forEntityName:entityName];
    
    return YES;
}

@end
