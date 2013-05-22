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

+ (instancetype)cargoObjectWithEntityName:(NSString *)entityName document:(NSDictionary *)document;
@end

@implementation CargoObject
@synthesize identifier = _identifier;

static NSString *const CargoSelectorSuffix = @":";
static NSMutableDictionary *generateDictionaryFromPredicate(NSPredicate *predicate)
{
    NSMutableDictionary *params             = [[NSMutableDictionary alloc] init];
    
    if([predicate isKindOfClass:[NSCompoundPredicate class]])
    {
        NSCompoundPredicate *compoundPredicate  = (NSCompoundPredicate *)predicate;
        
        for(NSComparisonPredicate *comparison in compoundPredicate.subpredicates)
            [params setValue:comparison.rightExpression.constantValue forKey:comparison.leftExpression.keyPath];
        
        return params;
    }
    else if([predicate isKindOfClass:[NSComparisonPredicate class]])
    {
        NSComparisonPredicate *comparePredicate = (NSComparisonPredicate *)predicate;
        [params setValue:comparePredicate.rightExpression.constantValue forKey:comparePredicate.leftExpression.keyPath];
        
        return params;
    }
    
    return [NSMutableDictionary new];
}

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
    NSMutableDictionary *document = [[self.storage document] mutableCopy];
    
    if(!document[self.entityName])
        document[self.entityName] = [[NSMutableArray alloc] init];
    
    NSMutableArray *items = (NSMutableArray *)document[self.entityName];
    
    self.document[@"identifier"] = _identifier =  @(items.count + 1);
    
    [items addObject:self.document];
    
    document[self.entityName] = [items copy];
    
    [self.storage saveDocument:[document copy] forEntityName:self.entityName];
}

- (void)delete
{
    if(!self.identifier)
        return;
    
    NSMutableDictionary *document   = [[self.storage document] mutableCopy];
    NSArray *items                  = document[self.entityName];
    
    if(!items || items.count < 1)
        return;
    
    NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"id == %@", self.identifier];
    NSArray *deleteItems    = [items filteredArrayUsingPredicate:predicate];
    

    [((NSMutableArray *)document[self.entityName]) removeObjectsInArray:deleteItems];
    
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

#pragma mark - Class Methods -
+ (instancetype)cargoObjectWithEntityName:(NSString *)entityName document:(NSDictionary *)document;
{
    id this = [[self alloc] initWithEntityName:entityName];
    ((CargoObject *)this).document = [document copy];
    
    return this;
}

+ (id)findInEntity:(NSString *)entityName filter:(id)filter
{
    Class storageClass = [[self class] CargoStorageDriverClass];

    NSAssert([storageClass conformsToProtocol:@protocol(CargoStorageDriverProtocol)], @"Cargo storage drivers must conform to CargoStorageDriverProtocol");
    NSAssert((![filter isKindOfClass:[NSPredicate class]] || ![filter isKindOfClass:[NSDictionary class]]), @"Cargo Find requires a predicate or dictionary to filter on");
    
    id storage                      = [storageClass instance];
    NSMutableDictionary *document   = [[storage document] mutableCopy];
    
    if(!document[entityName])
        document[entityName] = [[NSMutableArray alloc] init];

    NSMutableArray *items = (NSMutableArray *)document[entityName];

    if(items.count < 1)
        return nil;
    
    if([filter isKindOfClass:[NSPredicate class]])
    {
        NSArray *found = [((NSArray *)items) filteredArrayUsingPredicate:((NSPredicate *)filter)];

        if(found.count < 1)
            return nil;
        
        NSMutableArray *foundObjects = [[NSMutableArray alloc] initWithCapacity:found.count];
        [found enumerateObjectsUsingBlock:^(NSDictionary *record, NSUInteger idx, BOOL *stop) {
            [foundObjects addObject:[[self class] cargoObjectWithEntityName:entityName document:record]];
        }];
        
        return foundObjects;
    }
    
    if([filter isKindOfClass:[NSDictionary class]])
    {
        NSMutableArray *foundObjects = [[NSMutableArray alloc] init];

        [items enumerateObjectsUsingBlock:^(NSDictionary *record, NSUInteger idx, BOOL *stop) {
            [[record allKeys] enumerateObjectsUsingBlock:^(id key, NSUInteger idx, BOOL *stop) {
                if([filter[key] isEqual:record[key]])
                    [foundObjects addObject:[[self class] cargoObjectWithEntityName:entityName document:record]];
            }];
        }];
        
        return foundObjects;
    }
    
    
    return nil;
}

+ (void)insert:(NSDictionary *)record intoEntity:(NSString *)entityName
{
    Class storageClass = [[self class] CargoStorageDriverClass];
    NSAssert([storageClass conformsToProtocol:@protocol(CargoStorageDriverProtocol)], @"Cargo storage drivers must conform to CargoStorageDriverProtocol");

    id storage = [storageClass instance];
    
    NSMutableDictionary *document = [[storage document] mutableCopy];
    
    if(!document[entityName])
        document[entityName] = [[NSMutableArray alloc] init];
    
    NSMutableArray *items = (NSMutableArray *)document[entityName];
    
    NSMutableDictionary *mutableRecord = [record mutableCopy];
    mutableRecord[@"identifier"] = @(items.count + 1);
    
    [items addObject:mutableRecord];
    
    document[entityName] = [items copy];
    
    [storage saveDocument:[document copy] forEntityName:entityName];
}


@end
