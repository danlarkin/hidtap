@interface Tap : NSObject {
  @private CFMachPortRef tap;
}

+ (Tap*) tapOnRunLoop: (NSRunLoop*)loop;
- (void) stop;

@property (assign) CFMachPortRef tap;

@end
