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
    if (self = [self initWithBlock:futureBlock completionBlock:nil runsInBackground:YES]) {
    }
    return self;
}

-(id) initWithBlock:(IGFutureBlock)futureBlock completionBlock:(IGFutureCompletionBlock)completionBlock {
    if (self = [self initWithBlock:futureBlock completionBlock:completionBlock runsInBackground:YES]) {
    }
    return self;
}

-(id) initWithLazyBlock:(IGFutureBlock)futureBlock {
    if (self = [self initWithBlock:futureBlock completionBlock:nil runsInBackground:NO]) {
    }
    return self;
}

-(id) initWithLazyBlock:(IGFutureBlock)futureBlock completionBlock:(IGFutureCompletionBlock)completionBlock {
    if (self = [self initWithBlock:futureBlock completionBlock:completionBlock runsInBackground:NO]) {
    }
    return self;
}

-(id) initWithBlock:(IGFutureBlock)futureBlock completionBlock:(IGFutureCompletionBlock)completionBlock runsInBackground:(BOOL)runsInBackground {
    // calling super is not needed for NSProxy
    if (self) {
        NSString* queueName = [NSString stringWithFormat:@"%@.%d", @"hk.ignition.future", [self hash]];
        _queue = dispatch_queue_create([queueName UTF8String], 0);
        _group = dispatch_group_create();
        _futureBlock = futureBlock;
        _completionBlock = completionBlock;
        
        if (runsInBackground) {
            [self __force];
        }
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
    
    if (_exception) {
        [NSException raise:_exception.name format:@"%@", _exception.reason];
    }

    return _value;
}

#pragma mark - Private

-(void) __force {
    _running = YES;
    dispatch_group_async(_group, _queue, ^{
        @try {
            _value = _futureBlock();            
        }
        @catch (NSException *exception) {
            _exception = exception;
        }

        if (_completionBlock) {
            _completionBlock(_value);
        }
    });
}

#pragma mark - Proxy Magic

-(NSMethodSignature*) methodSignatureForSelector:(SEL)selector {
    id target = [self __value];
    if ([target respondsToSelector:selector]) {
        return [target methodSignatureForSelector:selector];
    }
	return [super methodSignatureForSelector:selector];
}

-(void) forwardInvocation:(NSInvocation *)invocation {
    id target = [self __value];
    if (target && [target respondsToSelector:[invocation selector]]) {
        [invocation invokeWithTarget:target];
    } else  {
        [super forwardInvocation:invocation];
    }
}

@end
