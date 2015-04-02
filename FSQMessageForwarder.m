//
//  FSQMessageForwarder.m
//
//  Copyright (c) 2015 Foursquare. All rights reserved.
//

#import "FSQMessageForwarder.h"

@interface NSInvocation (Copy)
- (id)copy;
@end 

@implementation FSQMessageForwarder


- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    BOOL superValue = [super conformsToProtocol:aProtocol];
    
    if (!superValue) {
        return [self iterateWithChildren:^(id child, BOOL *stop) {
            if ([child conformsToProtocol:aProtocol]) {
                *stop = YES;
            }
        }];
    }
    
    return superValue;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    BOOL superValue = [super respondsToSelector:aSelector];
    
    if (!superValue) {
        return [self iterateWithChildren:^(id child, BOOL *stop) {
            if ([child respondsToSelector:aSelector]) {
                *stop = YES;
            }
        }];
    }
    
    return superValue;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    __block NSMethodSignature *superValue = [super methodSignatureForSelector:aSelector];
    
    if (!superValue) {
        [self iterateWithChildren:^(id child, BOOL *stop) {
            if ([child respondsToSelector:aSelector]) {
                superValue = [child methodSignatureForSelector:aSelector];
                *stop = YES;
            }
        }];
    }
    
    return superValue;
}

- (BOOL)__useReturnValueFromObject:(id)obj forInvocation:(NSInvocation *)invocation {
    if ([obj respondsToSelector:@selector(messageForwarder:shouldUseResponseForInvocation:)]) {
        return [obj messageForwarder:self shouldUseResponseForInvocation:invocation];
    }
    else {
        return NO;
    }
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    
    __block NSInvocation *copiedInvocation = nil;
    __block BOOL childResponded = NO;
    
    [self iterateWithChildren:^(id child, BOOL *stop) {
        if ([child respondsToSelector:[anInvocation selector]]) {
            
            
            if (!childResponded || [self __useReturnValueFromObject:child forInvocation:anInvocation]) {
                // If this is the first child to respond, or the forwardee wants its return value to override any 
                // previous invocation, use the original invocation directly.
                [anInvocation invokeWithTarget:child];
            }
            else {
                
                if (!copiedInvocation) {
                    // Don't want to send the real invocation a second time because the return value will get
                    // overriden. So for all future children who respond after the first, send them a copy
                    // of the invocation where the return value will not be used.
                    
                    copiedInvocation = [anInvocation copy];
                }
                
                [copiedInvocation invokeWithTarget:child];
            }
    
            if (!childResponded) {
                childResponded = YES;
            }
        }
    }];
}

- (BOOL)iterateWithChildren:(void (^)(id child, BOOL *stop))block {
    // Subclasses implement
    return NO;
}

@end

@implementation FSQMessageForwarderWithEnumerator

- (BOOL)iterateWithChildren:(void (^)(id child, BOOL *stop))block {
    NSEnumerator *enumerator = [self.enumeratorGenerator childrenEnumeratorForMessageForwarder:self];
    if (enumerator) {
        id child;
        BOOL stop = NO;
        while (!stop
               && ((child = [enumerator nextObject])) != nil) {
            block(child, &stop);
        }
        return stop;
    }
    else {
        return NO;
    }
    
}

@end

@interface FSQMessageForwarderWithManagedChildren()
@property (nonatomic, retain) NSMutableArray *children;
@end

@implementation FSQMessageForwarderWithManagedChildren

- (instancetype)init {
    if ((self = [super init])) {
        _children = [NSMutableArray new];
    }
    return self;
}

- (BOOL)iterateWithChildren:(void (^)(id child, BOOL *stop))block {
    BOOL stop = NO;
    
    for (NSValue *childValue in _children) {
        id child = [childValue nonretainedObjectValue];
        
        block(child, &stop);
        
        if (stop) {
            return YES;
        }
    }
    
    return NO;
}

- (void)addChildren:(NSArray *)newChildren {
    for (id newChild in newChildren) {
        [_children addObject:[NSValue valueWithNonretainedObject:newChild]];
    }
}

- (void)insertChildren:(NSArray *)newChildren atPosition:(NSInteger)index {
    if (index > _children.count) {
        index = _children.count;
    }
    
    NSInteger offset = 0;
    for (id newChild in newChildren) {
        [_children insertObject:[NSValue valueWithNonretainedObject:newChild] atIndex:(index + offset)];
        ++offset;
    }
}

- (void)removeChildren:(NSArray *)childrenToRemove {
    [_children removeObjectsAtIndexes:[_children indexesOfObjectsPassingTest:^BOOL(NSValue *obj, NSUInteger idx, BOOL *stop) {
        id childValue = [obj nonretainedObjectValue];
        return (!childValue || [childrenToRemove containsObject:[obj nonretainedObjectValue]]);
    }]];
}

- (NSUInteger)numberOfChildren {
    return self.children.count;
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx {
    return [self.children[idx] nonretainedObjectValue];
}

@end


@implementation NSInvocation (Copy)

- (id)copy {
    NSInvocation *newInvocation = [NSInvocation invocationWithMethodSignature:self.methodSignature];
    NSUInteger numberOfArguments = [[self methodSignature] numberOfArguments];
    
    [newInvocation setTarget:self.target];
    [newInvocation setSelector:self.selector];
    
    if (numberOfArguments > 2) {
        NSInteger argumentIndex = 2;
        for (; argumentIndex < numberOfArguments; argumentIndex++) {
            
            const char *argumentType = [self.methodSignature getArgumentTypeAtIndex:argumentIndex];
            NSUInteger argumentLength = 0;
            NSGetSizeAndAlignment(argumentType, &argumentLength, NULL);
            
            void *argumentBuffer = malloc(argumentLength);
            [self getArgument:argumentBuffer atIndex:argumentIndex];
            [newInvocation setArgument:argumentBuffer atIndex:argumentIndex];
            free(argumentBuffer);
        }
    }
    
    return newInvocation;
}

@end
