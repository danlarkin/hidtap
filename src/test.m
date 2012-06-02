CGEventRef callback(CGEventTapProxy proxy,
                    CGEventType type,
                    CGEventRef event,
                    void *refcon) {
  int keyboard =
    CGEventGetIntegerValueField(event, kCGKeyboardEventKeyboardType);
  CGKeyCode keycode =
    (CGKeyCode)CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode);

  printf("Keyboard: %d\tKeycode: %d\t", keyboard, keycode);

  if (type == kCGEventKeyDown) { 
    printf("kCGEventKeyDown");
  } else if (type == kCGEventKeyUp) {
    printf("kCGEventKeyUp");
  } else if (type == kCGEventFlagsChanged) {
    printf("kCGEventFlagsChanged");
  }

  printf("\n");
  fflush(stdout);

  return event;
}

int main (int argc, const char *argv[]) {
  NSRunLoop *loop = [NSRunLoop currentRunLoop];

  CGEventMask mask = CGEventMaskBit(kCGEventKeyDown) |
    CGEventMaskBit(kCGEventKeyUp) |
    CGEventMaskBit(kCGEventFlagsChanged);
  CFMachPortRef tap = CGEventTapCreate (kCGHIDEventTap,
                                        kCGHeadInsertEventTap,
                                        kCGEventTapOptionDefault,
                                        mask,
                                        callback,
                                        NULL);
  if (!tap) {
    printf("Failed to create event tap.\n");
    exit(1);
  }

  [loop addPort:[NSMachPort portWithMachPort:CFMachPortGetPort(tap)]
        forMode:NSDefaultRunLoopMode];

  CGEventTapEnable(tap, YES);

  [loop run];

  return 0;
}
