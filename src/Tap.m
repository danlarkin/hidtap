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
    CGEventMask mask = CGEventMaskBit(kCGEventKeyDown) |
      CGEventMaskBit(kCGEventKeyUp) |
      CGEventMaskBit(kCGEventFlagsChanged);
    new.tap =
      CGEventTapCreate (kCGHIDEventTap,
                        kCGHeadInsertEventTap,
                        kCGEventTapOptionDefault,
                        mask,
                        callback,
                        (void *)new);
    if (!new.tap) {
      NSLog(@"Failed to create event tap.\n");
      exit (1);
    }

    [loop addPort:[NSMachPort portWithMachPort:CFMachPortGetPort(new.tap)]
          forMode:NSDefaultRunLoopMode];

    CGEventTapEnable (new.tap, YES);

  }

  new.modifiers = [NSMutableDictionary dictionaryWithCapacity:3];

  return new;
}

- (void) stop {
  CGEventTapEnable(self.tap, NO);
}

- (CGEventRef) processEvent:(CGEventRef) event withType:(CGEventType) type {
  // sometimes OS X sends us a kCGEventTapDisabledByTimeout
  // but, screw them! let's reenable it!
  if (type==kCGEventTapDisabledByTimeout) {
    //NSLog(@"Reenabling tap.");
    CGEventTapEnable(self.tap, YES);
    return event;
  }

  CGKeyCode received_keycode =
    (CGKeyCode)CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode);
  CGEventFlags received_flags = CGEventGetFlags(event);
  int received_keyboard =
    CGEventGetIntegerValueField(event, kCGKeyboardEventKeyboardType);

  static CGEventFlags previous_flags = 0;
  static CGEventFlags unapply_flags = 0;
  CGEventFlags final_flags = received_flags;
  bool update_previous_flags = YES;

  for(NSDictionary *modifier_dict in [Config getModifiers]) {
    NSString *keyboard = [modifier_dict valueForKey:@"Keyboard"];
    NSString *modifier = [modifier_dict valueForKey:@"Modifier"];
    NSString *keycode = [modifier_dict valueForKey:@"Keycode"];

    bool this_mod_on = [[self.modifiers valueForKey:modifier] boolValue];

    CGKeyCode new_modifier = 0;
    int mask = 0;
    if ([modifier isEqualToString:@"Option"]) {
      new_modifier = 58;
      mask = kCGEventFlagMaskAlternate;
    } else if ([modifier isEqualToString:@"Control"]) {
      new_modifier = 62;
      mask = kCGEventFlagMaskControl;
    } else if ([modifier isEqualToString:@"Command"]) {
      new_modifier = 54;
      mask = kCGEventFlagMaskCommand;
    }

    if(received_keyboard == [keyboard intValue]) {
      if(received_keycode == [keycode intValue]) {
        event = nil; // swallow the original event, since we replace
                     // it with our own

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
        } else if (type == kCGEventFlagsChanged) {
          CGEventFlags new_flags = (received_flags & ~previous_flags);
          bool command = (new_flags & kCGEventFlagMaskCommand) != 0;
          bool option = (new_flags & kCGEventFlagMaskAlternate) != 0;
          bool control = (new_flags & kCGEventFlagMaskControl) != 0;
          if (command) {
            unapply_flags = kCGEventFlagMaskCommand;
          } else if (option) {
            unapply_flags = kCGEventFlagMaskAlternate;
          } else if (control) {
            unapply_flags = kCGEventFlagMaskControl;
          } else {
            unapply_flags = 0;
          }

          if (unapply_flags) {
            update_previous_flags = NO;
            [self.modifiers setValue:[NSNumber numberWithBool:YES]
                              forKey:modifier];
          } else {
            [self.modifiers setValue:[NSNumber numberWithBool:NO]
                              forKey:modifier];
          }
        }

      } else {
        if (this_mod_on) {
          final_flags |= mask;
        }
        if (unapply_flags) {
          final_flags &= ~unapply_flags;
        }
      }

    }

  }

  if (update_previous_flags) {
    previous_flags = received_flags;
  }

  if (event) {
    CGEventSetFlags(event, final_flags);
  }

  return event;
}
@end
