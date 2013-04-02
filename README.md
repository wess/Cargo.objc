# Cargo
Cargo is a simplified key/value (document style) storage engine that is flexible and easy to customize using storage drivers that follow the Cargo storage driver protocol.

# Setup
To use Cargo, just copy the project file and link against libCargo.a, then include <Cargo/Cargo.h> in your files.

## Storage Driver
Cargo has made it easy to create custom storage drivers, iCloud and Dropbox are included as well as one for NSUserdefaults in the CargoExample project.

First in our header file, we setup the required methods that CargoObject will use in order to work with data, and where/how to store it.

```objectivec

// MyStorageEngine.h

#import <Cargo/CargoStorageDriverProtocol.h>

@interface MyStorageEngine : NSObject<CargoStorageDriverProtocol>
+ (instancetype)instance;
- (void)saveDocument:(NSDictionary *)document forEntityName:(NSString *)entityName;
- (void)deleteEntityName:(NSString *)entityName;
- (id)getDocumentForEntityName:(NSString *)entityName;
@end


// MyStorageEngine.m

#import “MyStorageEngine.h”

@implementation MyStorageEngine

// Setup our singleton so CargoObject can get an instance of it at any time.
+ (instancetype)instance
{
    static id _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    
    return _instance;
}

// When our CargoObject saves, we want our driver to store our document in
// our user defaults with a specific name, or key.
- (void)saveDocument:(NSDictionary *)document forEntityName:(NSString *)entityName
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setObject:document forKey:entityName];
}

// Handles deleting an entity, or a CargoObject, from our defined storage.
- (void)deleteEntityName:(NSString *)entityName
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:entityName];
}

// When our CargoObject wants to fetch data, our driver will use this method
// to retreive our data.
- (id)getDocumentForEntityName:(NSString *)entityName
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:entityName];
}
@end

```

## CargoObject
Cargo has an NSObject subclass called CargoObject that is subclassed with dynamic properties, just like NSManagedObject, and will use the defined driver to work with our stored data.

```objectivec

// MyObject.h
#import <Cargo/CargoObject.h>

@interface MyObject : CargoObject
@property (strong, nonatomic) NSString *firstname;
@property (strong, nonatomic) NSString *lastname;
@end

// MyObject.m
#import "MyObject.”h
#import "MyStorageEngine.h”

@implementation MyObject
@dynamic firstname;
@dynamic lastname;

+ (Class)CargoStorageDriverClass
{
    return [MyStorageEngine class];
}

@end


```

## Notes
Cargo is still in it’s early stages, but is working well. All suggestions are welcome.

## Developer info
* [Github](http://www.github.com/wess)
* [@WessCope](http://www.twitter.com/wesscope)

## License
Read LICENSE file for more info.