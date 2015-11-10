//
//  FSQMessageForwarder.h
//
//  Copyright (c) 2015 Foursquare. All rights reserved.
//

@import UIKit;

/**
 You can assign an instance of this class to receive any kind of message, 
 and it will forward all the messages it receives to each of its children in order if they respond to it.
 
 For messages which require a return value, the response of the first child who responds will be used, 
 unless a later child returns YES to messageForwarder:shouldUseResponseForInvocation:
 
 Do not instantiate directly. Use either FSQMessageForwarderWithManagedChildren 
 or FSQMessageForwarderWithEnumerator
 */
@interface FSQMessageForwarder : NSObject
@end

@protocol FSQMessageForwarderEnumeratorGenerator <NSObject>
/**
 This should return an enumerator that goes through all the children of the forwarder.
 
 The forwarder will call this every time it needs to forward a message to get the enumerator.
 
 @param forwarder The forwarder whose children need to be enumerated.
 
 @return An enumerator with the children to forward messages to.
 */
- (NSEnumerator *)childrenEnumeratorForMessageForwarder:(FSQMessageForwarder *)forwarder;
@end

/**
 A concrete FSQMessageForwarder that has a property you can set that it will use to enumerate its children. 
 */
@interface FSQMessageForwarderWithEnumerator : FSQMessageForwarder
/**
 The message forwarder will call the method defined in the generator protocol on this object to get an NSEnumerator
 that it uses to iterate over its children whenever it needs to do so.
 */
@property (nonatomic, weak) id<FSQMessageForwarderEnumeratorGenerator> enumeratorGenerator;
@end

/**
 A concrete FSQMessageForwarder that has methods to manage references to its own children.
 
 Use if you do not want to manage the children yourself.
 
 Weak references all held to all child objects.
 */
@interface FSQMessageForwarderWithManagedChildren : FSQMessageForwarder
- (void)addChildren:(NSArray *)newChildren;
- (void)insertChildren:(NSArray *)newChildren atPosition:(NSInteger)index;
- (void)removeChildren:(NSArray *)childrenToRemove;
- (NSUInteger)numberOfChildren;
- (id)objectAtIndexedSubscript:(NSUInteger)idx;
@end

@protocol FSQMessageForwardee <NSObject>
@optional
/**
 If a forwarded message has a return value, normally the first child to respond's return value is used.
 Later children can override this method and return YES to get their return value used instead.
 
 @param forwarder  The message forwarder receiving/forwarding the message.
 @param invocation The invocation that will be forwarded.
 
 @return YES if the forwarder should use this childs return value for the specified invocation
         in place of any previous children's return values. NO otherwise.
 
 @note If this is the first child to respond, this method is not called and the return value is used.
 @note This has no practical effect if the return value of the invocation is void.
 */
- (BOOL)messageForwarder:(FSQMessageForwarder *)forwarder shouldUseResponseForInvocation:(NSInvocation *)invocation;
@end