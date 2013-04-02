//
//  IGFuture.h
//  IGFuture
//
//  Created by Chong Francis on 13年4月2日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id(^IGFutureBlock)(void);

@interface IGFuture : NSProxy {
    dispatch_queue_t _queue;
    dispatch_group_t _group;
    BOOL _running;
    IGFutureBlock _futureBlock;
    id _value;
}

// Create a future using a block
// A future will start the work in a background queue asynchronously.
// When the future is needed, and the task is completed, it is returned immediately.
// If the task is not completed, it blocks and wait for finishes.
-(id) initWithBlock:(IGFutureBlock)futureBlock;

// Create a lazy future using a block.
// A lazy future do not start its work until it is needed.
-(id) initWithLazyBlock:(IGFutureBlock)futureBlock;

@end
