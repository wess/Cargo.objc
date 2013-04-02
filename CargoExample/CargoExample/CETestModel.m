//
//  CETestModel.m
//  CargoExample
//
//  Created by Wess Cope on 3/28/13.
//  Copyright (c) 2013 Wess Cope. All rights reserved.
//

#import "CETestModel.h"
#import "CEUserDefaultsDriver.h"

@implementation CETestModel
@dynamic firstname;
@dynamic lastname;

+ (Class)CargoStorageDriverClass
{
    return [CEUserDefaultsDriver class];
}

@end
