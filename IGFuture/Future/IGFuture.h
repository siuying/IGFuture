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

-(id) initWithBlock:(IGFutureBlock)futureBlock;
-(id) initWithBackgroundingBlock:(IGFutureBlock)futureBlock;
-(id) __value;

@end
