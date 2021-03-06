/* Any copyright is dedicated to the Public Domain.
   http://creativecommons.org/publicdomain/zero/1.0/ */

"use strict";

/* eslint no-unused-vars: [2, {"vars": "local"}] */

const { require } = ChromeUtils.import("resource://devtools/shared/Loader.jsm", {});

const promise = require("promise");
const Store = require("devtools/client/responsive.html/store");

const DevToolsUtils = require("devtools/shared/DevToolsUtils");

const flags = require("devtools/shared/flags");
flags.testing = true;
registerCleanupFunction(() => {
  flags.testing = false;
});
