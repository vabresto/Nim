discard """
  targets: "c cpp js"
"""

import std/hashes


when not defined(js) and not defined(cpp):
  block:
    var x = 12
    iterator hello(): int {.closure.} =
      yield x

    discard hash(hello)

block hashes:
  block hashing:
    var dummy = 0.0
    doAssert hash(dummy) == hash(-dummy)

  # "VM and runtime should make the same hash value (hashIdentity)"
  block:
    const hi123 = hashIdentity(123)
    doAssert hashIdentity(123) == hi123

  # "VM and runtime should make the same hash value (hashWangYi1)"
  block:
    const wy123 = hashWangYi1(123)
    doAssert wy123 != 0
    doAssert hashWangYi1(123) == wy123


  # "hashIdentity value incorrect at 456"
  block:
    doAssert hashIdentity(456) == 456

  # "hashWangYi1 value incorrect at 456"
  block:
    when Hash.sizeof < 8:
      doAssert hashWangYi1(456) == 1293320666
    else:
      doAssert hashWangYi1(456) == -6421749900419628582

block empty:
  var
    a = ""
    b = newSeq[char]()
    c = newSeq[int]()
    d = cstring""
    e = "abcd"
  doAssert hash(a) == 0
  doAssert hash(b) == 0
  doAssert hash(c) == 0
  doAssert hash(d) == 0
  doAssert hashIgnoreCase(a) == 0
  doAssert hashIgnoreStyle(a) == 0
  doAssert hash(e, 3, 2) == 0

block sameButDifferent:
  doAssert hash("aa bb aaaa1234") == hash("aa bb aaaa1234", 0, 13)
  doAssert hash("aa bb aaaa1234") == hash(cstring"aa bb aaaa1234")
  doAssert hashIgnoreCase("aA bb aAAa1234") == hashIgnoreCase("aa bb aaaa1234")
  doAssert hashIgnoreStyle("aa_bb_AAaa1234") == hashIgnoreCase("aaBBAAAa1234")

block smallSize: # no multibyte hashing
  let
    xx = @['H', 'i']
    ii = @[72'u8, 105]
    ss = "Hi"
  doAssert hash(xx) == hash(ii)
  doAssert hash(xx) == hash(ss)
  doAssert hash(xx) == hash(xx, 0, xx.high)
  doAssert hash(ss) == hash(ss, 0, ss.high)

block largeSize: # longer than 4 characters
  let
    xx = @['H', 'e', 'l', 'l', 'o']
    xxl = @['H', 'e', 'l', 'l', 'o', 'w', 'e', 'e', 'n', 's']
    ssl = "Helloweens"
  doAssert hash(xxl) == hash(ssl)
  doAssert hash(xxl) == hash(xxl, 0, xxl.high)
  doAssert hash(ssl) == hash(ssl, 0, ssl.high)
  doAssert hash(xx) == hash(xxl, 0, 4)
  doAssert hash(xx) == hash(ssl, 0, 4)
  doAssert hash(xx, 0, 3) == hash(xxl, 0, 3)
  doAssert hash(xx, 0, 3) == hash(ssl, 0, 3)

proc main() =


  doAssert hash(0.0) == hash(0)
  doAssert hash(cstring"abracadabra") == 97309975
  doAssert hash(cstring"abracadabra") == hash("abracadabra")

  when sizeof(int) == 8 or defined(js):
    block:
      var s: seq[Hash]
      for a in [0.0, 1.0, -1.0, 1000.0, -1000.0]:
        let b = hash(a)
        doAssert b notin s
        s.add b
    when defined(js):
      doAssert hash(0.345602) == 2035867618
      doAssert hash(234567.45) == -20468103
      doAssert hash(-9999.283456) == -43247422
      doAssert hash(84375674.0) == 707542256
    else:
      doAssert hash(0.345602) == 387936373221941218
      doAssert hash(234567.45) == -8179139172229468551
      doAssert hash(-9999.283456) == 5876943921626224834
      doAssert hash(84375674.0) == 1964453089107524848
  else:
    doAssert hash(0.345602) != 0
    doAssert hash(234567.45) != 0
    doAssert hash(-9999.283456) != 0
    doAssert hash(84375674.0) != 0


static: main()
main()
