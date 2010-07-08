#import "Tap.h"

int main (int argc, const char * argv[]) {
  NSRunLoop *loop = [NSRunLoop currentRunLoop];
  Tap *tap = [Tap tapOnRunLoop:loop];

  [loop run];

  [tap stop]; // <--- never gets reached?

  return 0;
}
