/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

/* exported install, uninstall, startup, shutdown */

"use strict";

ChromeUtils.import("resource://gre/modules/XPCOMUtils.jsm");
ChromeUtils.import("resource://gre/modules/AddonManager.jsm");
ChromeUtils.import("resource://gre/modules/Services.jsm");
ChromeUtils.import("resource://gre/modules/Timer.jsm");

ChromeUtils.defineModuleGetter(this, "TestRunner",
                               "chrome://mozscreenshots/content/TestRunner.jsm");

function install(data, reason) {
  if (!isAppSupported()) {
    uninstallExtension(data);
    return;
  }

  AddonManager.getAddonByID(data.id, function(addon) {
    // Enable on install in case the user disabled a prior version
    if (addon) {
      addon.userDisabled = false;
    }
  });
}

function startup(data, reason) {
  if (!isAppSupported()) {
    uninstallExtension(data);
    return;
  }

  AddonManager.getAddonByID(data.id, function(addon) {
    let extensionPath = addon.getResourceURI();
    TestRunner.init(extensionPath);
  });
}

function shutdown(data, reason) { }

function uninstall(data, reason) { }

/**
 * @return boolean whether the test suite applies to the application.
 */
function isAppSupported() {
  return true;
}

function uninstallExtension(data) {
  AddonManager.getAddonByID(data.id, function(addon) {
    addon.uninstall();
  });
}
