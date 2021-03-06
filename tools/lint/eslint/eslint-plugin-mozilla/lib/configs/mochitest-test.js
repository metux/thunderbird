// Parent config file for all mochitest files.
"use strict";

module.exports = {
  "env": {
    "browser": true,
    "mozilla/simpletest": true
  },

  // All globals made available in the test environment.
  "globals": {
    // `$` is defined in SimpleTest.js
    "$": false,
    "Assert": false,
    "EventUtils": false,
    "SpecialPowers": false,
    "addLoadEvent": false,
    "add_task": false,
    "executeSoon": false,
    "export_assertions": false,
    "finish": false,
    "gTestPath": false,
    "getRootDirectory": false,
    "getTestFilePath": false,
    "info": false,
    "is": false,
    "isDeeply": false,
    "isnot": false,
    "netscape": false,
    "ok": false,
    "promise": false,
    "registerCleanupFunction": false,
    "requestLongerTimeout": false,
    "todo": false,
    "todo_is": false,
    "todo_isnot": false,
    "waitForClipboard": false,
    "waitForExplicitFinish": false,
    "waitForFocus": false
  },

  "plugins": [
    "mozilla"
  ],

  "rules": {
    "mozilla/import-content-task-globals": "error",
    "mozilla/import-headjs-globals": "error",
    "mozilla/mark-test-function-used": "error",
    // Turn off no-define-cc-etc for mochitests as these don't have Cc etc defined in the
    // global scope.
    "mozilla/no-define-cc-etc": "off",
    "no-shadow": "error"
  }
};
