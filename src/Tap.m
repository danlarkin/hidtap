#import "Tap.h"

CGEventRef callback(CGEventTapProxy proxy,
                    CGEventType type,
                    CGEventRef event,
                    void *refcon) {
  Tap *tap = (Tap *)refcon;
  return [tap processEvent:event withType:type];
}

@implementation Tap

@synthesize tap;
@synthesize modifiers;

+ (Tap*) tapOnRunLoop: (NSRunLoop*)loop {
  Tap *new = [[self alloc] init];

  if (new) {
    new.tap =
      CGEventTapCreate (kCGHIDEventTap,
                        kCGHeadInsertEventTap,
                        kCGEventTapOptionDefault,
                        kCGEventMaskForAllEvents,
                        callback,
                        (void *)new);
    if (!new.tap) {
      NSLog(@"Failed to create event tap.\n");
      exit (1);
    }

    [loop addPort:[NSMachPort portWithMachPort:CFMachPortGetPort(new.tap)]
          forMode:NSDefaultRunLoopMode];

    CGEventTapEnable (new.tap, true);

  }

  new.modifiers = [NSMutableDictionary dictionaryWithCapacity:3];

  return new;
}

- (void) stop {
  CGEventTapEnable(self.tap, false);
}

- (CGEventRef) processEvent:(CGEventRef) event withType:(CGEventType) type {
  return event;
}
@end
