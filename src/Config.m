#import "Config.h"

@implementation Config

+ (NSArray *) getModifiers {
  CFPropertyListRef props =
    CFPreferencesCopyAppValue(CFSTR("Modifiers"), CFSTR("org.danlarkin.hidtap"));

  if (!props) {
    NSLog(@"error: Can't get \"Modifiers\" key from preferences plist.\n");
    exit(1);
  }

  if (CFGetTypeID(props) != CFArrayGetTypeID()) {
    NSLog(@"error: \"Modifiers\" key from preferences plist isn't an array.\n");
    exit(1);
  }

  return (NSArray *)props;
}

@end
