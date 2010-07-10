@interface Tap : NSObject {
@private
  CFMachPortRef tap;
  NSMutableDictionary *modifiers;
}

+ (Tap*) tapOnRunLoop: (NSRunLoop*)loop;
- (void) stop;
- (CGEventRef) processEvent:(CGEventRef) event withType:(CGEventType) type;

@property (assign) CFMachPortRef tap;
@property (assign) NSMutableDictionary *modifiers;

@end
