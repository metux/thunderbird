// Copyright (C) 2015 André Bargull. All rights reserved.
// This code is governed by the BSD license found in the LICENSE file.

/*---
esid: sec-arraybuffer.prototype.slice
es6id: 24.1.4.3
description: >
  ArrayBuffer.prototype.slice.name is "slice".
info: |
  ArrayBuffer.prototype.slice ( start, end )

  17 ECMAScript Standard Built-in Objects:
    Every built-in Function object, including constructors, that is not
    identified as an anonymous function has a name property whose value
    is a String.

    Unless otherwise specified, the name property of a built-in Function
    object, if it exists, has the attributes { [[Writable]]: false,
    [[Enumerable]]: false, [[Configurable]]: true }.
includes: [propertyHelper.js]
---*/

assert.sameValue(ArrayBuffer.prototype.slice.name, "slice");

verifyNotEnumerable(ArrayBuffer.prototype.slice, "name");
verifyNotWritable(ArrayBuffer.prototype.slice, "name");
verifyConfigurable(ArrayBuffer.prototype.slice, "name");

reportCompare(0, 0);
