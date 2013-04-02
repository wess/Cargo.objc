//
//  CargoDropboxDriver.m
//  Cargo
//
//  Created by Wess Cope on 4/2/13.
//  Copyright (c) 2013 Wess Cope. All rights reserved.
//

#import "CargoDropboxDriver.h"
#import "Cargo.h"
#import <Dropbox/Dropbox.h>

@interface CargoDropboxDriver()
{
    NSURL *_linkAccountURL;
}

@property (strong, nonatomic) DBAccountManager  *accountManager;
@property (strong, nonatomic) DBAccount         *account;
@property (strong, nonatomic) DBFilesystem      *filesystem;
@property (strong, nonatomic) DBPath            *path;
@property (strong, nonatomic) DBFile            *file;

- (void)writeDocument:(NSDictionary *)document;
@end

@implementation CargoDropboxDriver
@synthesize accountManager  = _accountManager;
@synthesize account         = _account;
@synthesize filesystem      = _filesystem;
@synthesize path            = _path;
@synthesize file            = _file;
@synthesize document        = _document;

+ (instancetype)instance
{
    if(!CargoDropboxAppSecret || !CargoDropboxAppKey)
        @throw [NSException exceptionWithName:@"Cargo Dropbox Error" reason:@"App Key and App Secret are not defined, please see CargoDropboxDriver.h" userInfo:nil];
    
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
    }
    return self;
}

- (void)dealloc
{
    [self.file removeObserver:self];
}

+ (void)setupDropboxLink
{
    CargoDropboxDriver *driver = [CargoDropboxDriver instance];
    driver.accountManager = [[DBAccountManager alloc] initWithAppKey:CargoDropboxAppKey secret:CargoDropboxAppSecret];
    driver.account = driver.accountManager.linkedAccount;
    
    [DBAccountManager setSharedManager:driver.accountManager];
    
    if(driver.account)
    {
        driver.filesystem = [[DBFilesystem alloc] initWithAccount:driver.account];
        [DBFilesystem setSharedFilesystem:driver.filesystem];
    }
    else
    {
        UIViewController *controller = (UIViewController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
        [driver.accountManager linkFromController:controller];
    }
}

- (void)handleDropboxOpenURL:(NSURL *)url
{
    _account = [self.accountManager handleOpenURL:url];
    if(_account)
    {
        _filesystem = [[DBFilesystem alloc] initWithAccount:_account];
        [DBFilesystem setSharedFilesystem:_filesystem];
    }
}

- (void)writeDocument:(NSDictionary *)document
{
    if(!document)
        return;
    
    NSString *error = nil;
    NSData  *plist = [NSPropertyListSerialization dataFromPropertyList:(id)document format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
    
    NSAssert(error == nil, error);

    if(plist)
    {
        DBError *dbError = nil;
        [self.file writeData:plist error:&dbError];
        
        NSAssert(dbError == nil, dbError.debugDescription);
    }
}

#pragma mark - properties -
- (DBPath *)path
{
    if(_path)
        return _path;
    
    _path = [[DBPath root] childPath:@"com.cargo.document.storage.plist"];
    
    return _path;
}

- (DBFile *)file
{
    if(_file)
        return _file;
    
    _file = [self.filesystem openFile:self.path error:nil];
    if(!_file)
    {
        NSError *error = nil;
        _file = [self.filesystem createFile:self.path error:&error];
        
        NSAssert(error == nil, error.debugDescription);
    }
    
    __weak typeof(self) weakSelf = self;
    [_file addObserver:self block:^{
        
        if(!weakSelf.file.newerStatus.cached)
        {
            NSLog(@"Downloading file update");
        }
        else
        {
            [weakSelf.file update:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:CargoDidUpdateEntityNotification object:nil];
        }
    }];
    
    return _file;
}

- (NSDictionary *)document
{
    DBError *error = nil;
    NSData *fileData = [self.file readData:&error];
    
    NSAssert(error == nil, error.debugDescription);
    
    if(!fileData)
    {
        _document = @{};
    }
    else
    {
        NSError *plistError = nil;
        NSPropertyListFormat format;
        NSDictionary *plist = [NSPropertyListSerialization propertyListWithData:fileData options:NSPropertyListImmutable format:&format error:&plistError];
        
        NSAssert(plistError == nil, plistError.debugDescription);
        
        _document = plist;
    }
    
    return _document;
}

#pragma mark - public methods -
- (void)saveDocument:(NSDictionary *)document forEntityName:(NSString *)entityName
{
    NSMutableDictionary *doc = [self.document mutableCopy];
    doc[entityName] = [document copy];
 
    [self writeDocument:doc];
}

- (void)deleteEntityName:(NSString *)entityName
{
    NSMutableDictionary *doc = [self.document mutableCopy];
    [doc removeObjectForKey:entityName];
    
    [self writeDocument:doc];
}

- (id)getDocumentForEntityName:(NSString *)entityName
{
    return self.document[entityName];
}

@end
