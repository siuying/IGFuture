#import "Specta.h"
#define EXP_SHORTHAND
#import "Expecta.h"
#import "IGFuture.h"

#define kSleepTime 0.1

SpecBegin(IGFutureSpec)

describe(@"IGFuture", ^{
    describe(@"-initWithLazyBlock:", ^{
        it(@"should use Future as returned object", ^{
            NSDate* now = [NSDate date];
            NSDate* later = (NSDate*) [[IGFuture alloc] initWithLazyBlock:^id{
                return [NSDate date];
            }];
            expect([later timeIntervalSinceDate:now]).to.beCloseToWithin(0.0, 0.005);
        });
        
        it(@"should invoke only when needed", ^{
            NSDate* now = [NSDate date];
            NSDate* later = (NSDate*) [[IGFuture alloc] initWithLazyBlock:^id{
                [NSThread sleepForTimeInterval:kSleepTime];
                return [NSDate date];
            }];
            
            // wait for the background
            [NSThread sleepForTimeInterval:kSleepTime];

            NSDate* middle = [NSDate date];

            // it should block again here
            expect([later timeIntervalSinceDate:now]).to.beCloseToWithin(kSleepTime*2.0, 0.005);
            expect([middle timeIntervalSinceDate:now]).to.beCloseToWithin(kSleepTime, 0.005);
            expect([later timeIntervalSinceDate:middle]).to.beCloseToWithin(kSleepTime, 0.005);
        });
    });

    describe(@"-initWithBlock:", ^{
        it(@"should work in background", ^{
            NSDate* now = [NSDate date];
            NSDate* later = (NSDate*) [[IGFuture alloc] initWithBlock:^id{
                [NSThread sleepForTimeInterval:kSleepTime];
                return [NSDate date];
            }];

            // wait for the background
            [NSThread sleepForTimeInterval:kSleepTime];

            NSDate* middle = [NSDate date];
            expect([later timeIntervalSinceDate:now]).to.beCloseToWithin(kSleepTime, 0.005);
            expect([middle timeIntervalSinceDate:now]).to.beCloseToWithin(kSleepTime, 0.005);
            expect([later timeIntervalSinceDate:middle]).to.beCloseToWithin(0, 0.005);
        });
    });
    
    describe(@"-setCompletionBlock:", ^{
        it(@"run the completion block when the task is completed", ^{
            __block NSDate* targetDate = nil;

            IGFuture* later = [[IGFuture alloc] initWithBlock:^id{
                [NSThread sleepForTimeInterval:kSleepTime];
                return [NSDate date];
            }];

            // this is set after the future complete
            later.completionBlock = ^(NSDate* date) {
                targetDate = date;
            };

            // at this time the task is not completed yet
            expect(targetDate).to.beNil();

            // use `later` will force to wait until the task is completed
            expect(([(NSDate*)later timeIntervalSince1970])).to.equal([targetDate timeIntervalSince1970]);
            expect(targetDate).toNot.beNil();
        });
    });
});

SpecEnd
