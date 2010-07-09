@interface Tap : NSObject {
  @private CFMachPortRef tap;
}

+ (Tap*) tapOnRunLoop: (NSRunLoop*)loop;
- (void) stop;
- (CGEventRef) processEvent:(CGEventRef) event withType:(CGEventType) type;

@property (assign) CFMachPortRef tap;

@end
