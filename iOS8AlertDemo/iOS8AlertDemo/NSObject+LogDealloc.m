#import "NSObject+LogDealloc.h"
#import <objc/runtime.h>

static char __logDeallocAssociatedKey__;

@interface LogDealloc : NSObject
@property (strong) NSString* message;
@end

@implementation NSObject (LogDealloc)

- (void)logOnDealloc
{
    if( objc_getAssociatedObject( self, &__logDeallocAssociatedKey__ ) == nil ) {
        LogDealloc* log = [[LogDealloc alloc] init];
        log.message = NSStringFromClass( self.class );
        objc_setAssociatedObject( self, &__logDeallocAssociatedKey__, log, OBJC_ASSOCIATION_RETAIN );
#if ! __has_feature(objc_arc)
        [log release];
#endif
    }
}

@end

@implementation LogDealloc

- (void)dealloc
{
    NSLog( @"dealloc: %@", self.message );
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

@end