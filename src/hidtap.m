#import "Tap.h"
#import "Config.h"

int main (int argc, const char * argv[]) {
  NSArray *modifiers = [Config getModifiers];

  if ([modifiers count] == 0) {
    NSLog(@"No Modifiers Configured, exiting.");
    exit(0);
  }

  NSLog(@"Configured Modifiers:");
  for(NSDictionary *modifier in [Config getModifiers]) {
    NSLog(@"Keyboard: %@\tModifier: %@\tKeycode: %@",
          [modifier valueForKey:@"Keyboard"],
          [modifier valueForKey:@"Modifier"],
          [modifier valueForKey:@"Keycode"]);
  }

  NSRunLoop *loop = [NSRunLoop currentRunLoop];
  Tap *tap = [Tap tapOnRunLoop:loop];

  [loop run];

  [tap stop]; // <--- never gets reached?

  return 0;
}
