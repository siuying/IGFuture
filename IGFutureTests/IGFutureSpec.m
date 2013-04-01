#import "Specta.h"
#define EXP_SHORTHAND
#import "Expecta.h"
#import "IGFuture.h"

SpecBegin(IGFutureSpec)

describe(@"IGFuture", ^{
    describe(@"-initWithBlock:", ^{
        it(@"should use Future as returned object", ^{
            NSDate* now = [NSDate date];
            NSDate* later = (NSDate*) [[IGFuture alloc] initWithBlock:^id{
                return [NSDate date];
            }];
            expect([later timeIntervalSinceDate:now]).to.beCloseToWithin(0.0, 0.005);
        });
        
        it(@"should invoke only when needed", ^{
            NSDate* now = [NSDate date];
            NSDate* later = (NSDate*) [[IGFuture alloc] initWithBlock:^id{
                [NSThread sleepForTimeInterval:0.1];
                return [NSDate date];
            }];
            NSDate* middle = [NSDate date];
            expect([middle timeIntervalSinceDate:now]).to.beCloseToWithin(0, 0.005);
            expect([later timeIntervalSinceDate:now]).to.beCloseToWithin(0.1, 0.005);
            expect([later timeIntervalSinceDate:middle]).to.beCloseToWithin(0.1, 0.005);
        });
    });

    describe(@"-initWithBackgroundingBlock:", ^{
        it(@"should work in background", ^{
            NSDate* now = [NSDate date];
            NSDate* later = (NSDate*) [[IGFuture alloc] initWithBackgroundingBlock:^id{
                [NSThread sleepForTimeInterval:0.1];
                return [NSDate date];
            }];

            // wait for the background
            [NSThread sleepForTimeInterval:0.1];

            NSDate* middle = [NSDate date];
            expect([middle timeIntervalSinceDate:now]).to.beCloseToWithin(0.1, 0.005);
            expect([later timeIntervalSinceDate:now]).to.beCloseToWithin(0.1, 0.005);
            expect([later timeIntervalSinceDate:middle]).to.beCloseToWithin(0, 0.005);
        });
    });
});

SpecEnd
