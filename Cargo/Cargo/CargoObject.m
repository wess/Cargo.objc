//
//  CargoObject.m
//  Cargo
//
//  Created by Wess Cope on 3/28/13.
//  Copyright (c) 2013 Wess Cope. All rights reserved.
//

#import "CargoObject.h"
#import "CargoStorageDriverProtocol.h"
#import "CargoiCloudDriver.h"
#import "Cargo.h"

@interface CargoObject()
@property (strong, nonatomic) NSMutableDictionary   *document;
@property (strong, nonatomic) id                    storage;
@property (strong, nonatomic) NSString              *entityName;

- (void)saveObject:(id)object forKey:(NSString *)property;
- (id)getObjectForKey:(NSString *)property;

@end

@implementation CargoObject
static NSString *const CargoSelectorSuffix = @":";

- (void)initializeWithEntityName:(NSString *)entityName;
{
    Class storageClass = [[self class] CargoStorageDriverClass];
    NSAssert([storageClass conformsToProtocol:@protocol(CargoStorageDriverProtocol)], @"Cargo storage drivers must conform to CargoStorageDriverProtocol");

    self.document   = [[NSMutableDictionary alloc] init];
    self.storage    = [storageClass instance];
    self.entityName = [entityName copy];
}

- (instancetype)initWithEntityName:(NSString *)entityName
{
    self = [super init];
    if (self)
        [self initializeWithEntityName:entityName];
    
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self)
        [self initializeWithEntityName:NSStringFromClass([self class])];
    
    return self;
}

- (id)fetch
{
    return [self.storage getDocumentForEntityName:self.entityName];
}

- (id)fetchBackup
{
    return [self.storage getBackupDocumentForEntityName:self.entityName];
}

- (void)save
{
    [self.storage saveDocument:[self.document copy] forEntityName:self.entityName];
}

- (void)delete
{
    [self.storage deleteEntityName:self.entityName];
    self.document = nil;
}

- (void)revertToLast
{
    [self.storage revertToLastSaveForEntityName:self.entityName];
}

+ (Class)CargoStorageDriverClass
{
    @throw [NSException exceptionWithName:@"Cargo Object Error" reason:@"+(Class)CargoStorageDriverClass must return class for storage driver" userInfo:nil];
}

#pragma mark - Private Parts -
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];
    
    if(![self respondsToSelector:aSelector])
    {
        NSString *selectorName  = [NSStringFromSelector(aSelector) lowercaseString];
        signature               = [NSMethodSignature signatureWithObjCTypes:(([selectorName hasSuffix:CargoSelectorSuffix])? "v@:@" : "@@:")];
    }
    
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NSString *selectorName = [NSStringFromSelector([anInvocation selector]) lowercaseString];
    
    if([selectorName hasSuffix:CargoSelectorSuffix])
    {
        NSString *property = [selectorName substringWithRange:NSMakeRange(3, selectorName.length - 4)];
        id invocationValue;
        [anInvocation getArgument:&invocationValue atIndex:2];
        [self saveObject:invocationValue forKey:property];
    }
    else
    {
        id returnValue = [self getObjectForKey:selectorName];
        [anInvocation setReturnValue:&returnValue];
    }
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    [self saveObject:value forKey:key];
}

- (id)valueForKey:(NSString *)key
{
    return [self getObjectForKey:key];
}

- (void)saveObject:(id)object forKey:(NSString *)property
{
    self.document[property] = object;
}

- (id)getObjectForKey:(NSString *)property
{
    return self.document[property];
}

@end
