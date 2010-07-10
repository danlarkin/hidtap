#import "Tap.h"
#import "Config.h"

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
  CGKeyCode received_keycode =
    (CGKeyCode)CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode);
  CGEventFlags received_flags = CGEventGetFlags(event);
  int received_keyboard =
    CGEventGetIntegerValueField(event, kCGKeyboardEventKeyboardType);

  for(NSDictionary *modifier_dict in [Config getModifiers]) {
    NSString *keyboard = [modifier_dict valueForKey:@"Keyboard"];
    NSString *modifier = [modifier_dict valueForKey:@"Modifier"];
    NSString *keycode = [modifier_dict valueForKey:@"Keycode"];

    bool this_mod_on = [[self.modifiers valueForKey:modifier] boolValue];

    if(received_keyboard == [keyboard intValue]) {
      if(received_keycode == [keycode intValue]) {
        event = nil;

        CGKeyCode new_modifier = 0;
        if ([modifier isEqualToString:@"Option"]) {
          new_modifier = 58;
        } else if ([modifier isEqualToString:@"Control"]) {
          new_modifier = 59;
        } else if ([modifier isEqualToString:@"Command"]) {
          new_modifier = 55;
        }

        if (type == kCGEventKeyDown) {
          if (!this_mod_on) {
            CGEventRef newEvent =
              CGEventCreateKeyboardEvent(nil, new_modifier, YES);
            CGEventPost(kCGHIDEventTap, newEvent);
            CFRelease(newEvent);
          }
          [self.modifiers setValue:[NSNumber numberWithBool:YES]
                            forKey:modifier];
        } else if (type == kCGEventKeyUp) {
          if (this_mod_on) {
            CGEventRef newEvent =
              CGEventCreateKeyboardEvent(nil, new_modifier, NO);
            CGEventPost(kCGHIDEventTap, newEvent);
            CFRelease(newEvent);
          }
          [self.modifiers setValue:[NSNumber numberWithBool:NO]
                            forKey:modifier];
        }

      } else {
        if (this_mod_on) {
          CGEventSetFlags(event, (received_flags | kCGEventFlagMaskAlternate));
        }
      }

    }

  }

  return event;
}
@end
