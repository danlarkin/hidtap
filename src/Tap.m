#import "Tap.h"

CGEventRef callback(CGEventTapProxy proxy,
                    CGEventType type,
                    CGEventRef event,
                    void *refcon) {
  return event;
}

@implementation Tap

@synthesize tap;

+ (Tap*) tapOnRunLoop: (NSRunLoop*)loop {
  Tap *new = [[self alloc] init];

  if (new) {
    new.tap =
      CGEventTapCreate (kCGHIDEventTap,
                        kCGHeadInsertEventTap,
                        kCGEventTapOptionDefault,
                        kCGEventMaskForAllEvents,
                        callback,
                        NULL);
    if (!new.tap) {
      NSLog(@"Failed to create event tap.\n");
      exit (1);
    }

    [loop addPort:[NSMachPort portWithMachPort:CFMachPortGetPort(new.tap)]
          forMode:NSDefaultRunLoopMode];

    CGEventTapEnable (new.tap, true);

  }

  return new;
}

- (void) stop {
  CGEventTapEnable(self.tap, false);
}
@end
