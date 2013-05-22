//
//  CEUserDefaultsDriver.m
//  CargoExample
//
//  Created by Wess Cope on 4/2/13.
//  Copyright (c) 2013 Wess Cope. All rights reserved.
//

#import "CEUserDefaultsDriver.h"

@implementation CEUserDefaultsDriver
+ (instancetype)instance
{
    static id _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    
    return _instance;
}

- (void)saveDocument:(NSDictionary *)document forEntityName:(NSString *)entityName
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setObject:document forKey:entityName];
    [defaults synchronize];
}

- (void)deleteEntityName:(NSString *)entityName
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults removeObjectForKey:entityName];
    [defaults synchronize];
}

- (id)getDocumentForEntityName:(NSString *)entityName
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:entityName];
}
@end
