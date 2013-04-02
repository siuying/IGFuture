//
//  IGFuture.m
//  IGFuture
//
//  Created by Chong Francis on 13年4月2日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import "IGFuture.h"

@implementation IGFuture

-(id) initWithBlock:(IGFutureBlock)futureBlock {
    if ([self initWithLazyBlock:futureBlock]) {
        [self __force];
    }
    return self;
}

-(id) initWithLazyBlock:(IGFutureBlock)futureBlock {
    // calling super is not needed for NSProxy
    if (self) {
        NSString* queueName = [NSString stringWithFormat:@"%@.%d", @"hk.ignition.future", [self hash]];
        _queue = dispatch_queue_create([queueName UTF8String], 0);
        _group = dispatch_group_create();
        _futureBlock = futureBlock;
    }
    return self;
}

-(IGFutureCompletionBlock)completionBlock {
    return _completionBlock;
}

-(void)setCompletionBlock:(IGFutureCompletionBlock)block {
    _completionBlock = block;
}

-(id) __value {
    if (!_running) {
        [self __force];
    }
    dispatch_group_wait(_group, DISPATCH_TIME_FOREVER);
    return _value;
}

#pragma mark - Private

-(void) __force {
    _running = YES;
    dispatch_group_async(_group, _queue, ^{
        _value = _futureBlock();

        if (_completionBlock) {
            _completionBlock(_value);
        }
    });
}

#pragma mark - Proxy Magic

// Reference: http://borkware.com/rants/agentm/elegant-delegation/
-(NSMethodSignature*) methodSignatureForSelector:(SEL)selector {
    id target = [self __value];
	NSMethodSignature *sig = [[target class] instanceMethodSignatureForSelector:selector];
	if(!sig) {
		sig = [NSMethodSignature signatureWithObjCTypes:"@^v^c"];
	}
	return sig;
}

-(void) forwardInvocation:(NSInvocation *)anInvocation {
    id target = [self __value];
    if (target) {
        if ([target respondsToSelector:[anInvocation selector]]) {
            [anInvocation invokeWithTarget:target];
        } else {
            [super forwardInvocation:anInvocation];
        }
    }
}

@end
