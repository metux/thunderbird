/* globals startBackground, analytics, communication, makeUuid, Raven, catcher, auth, log */

"use strict";

this.senderror = (function() {
  const exports = {};

  const manifest = browser.runtime.getManifest();

  // Do not show an error more than every ERROR_TIME_LIMIT milliseconds:
  const ERROR_TIME_LIMIT = 3000;

  const messages = {
    REQUEST_ERROR: {
      title: browser.i18n.getMessage("requestErrorTitle"),
      info: browser.i18n.getMessage("requestErrorDetails")
    },
    CONNECTION_ERROR: {
      title: browser.i18n.getMessage("connectionErrorTitle"),
      info: browser.i18n.getMessage("connectionErrorDetails")
    },
    LOGIN_ERROR: {
      title: browser.i18n.getMessage("requestErrorTitle"),
      info: browser.i18n.getMessage("loginErrorDetails")
    },
    LOGIN_CONNECTION_ERROR: {
      title: browser.i18n.getMessage("connectionErrorTitle"),
      info: browser.i18n.getMessage("connectionErrorDetails")
    },
    UNSHOOTABLE_PAGE: {
      title: browser.i18n.getMessage("unshootablePageErrorTitle"),
      info: browser.i18n.getMessage("unshootablePageErrorDetails")
    },
    SHOT_PAGE: {
      title: browser.i18n.getMessage("selfScreenshotErrorTitle")
    },
    MY_SHOTS: {
      title: browser.i18n.getMessage("selfScreenshotErrorTitle")
    },
    EMPTY_SELECTION: {
      title: browser.i18n.getMessage("emptySelectionErrorTitle")
    },
    PRIVATE_WINDOW: {
      title: browser.i18n.getMessage("privateWindowErrorTitle"),
      info: browser.i18n.getMessage("privateWindowErrorDetails")
    },
    generic: {
      title: browser.i18n.getMessage("genericErrorTitle"),
      info: browser.i18n.getMessage("genericErrorDetails"),
      showMessage: true
    }
  };

  communication.register("reportError", (sender, error) => {
    catcher.unhandled(error);
  });

  let lastErrorTime;

  exports.showError = function(error) {
    if (lastErrorTime && (Date.now() - lastErrorTime) < ERROR_TIME_LIMIT) {
      return;
    }
    lastErrorTime = Date.now();
    const id = makeUuid();
    let popupMessage = error.popupMessage || "generic";
    if (!messages[popupMessage]) {
      popupMessage = "generic";
    }
    const title = messages[popupMessage].title;
    let message = messages[popupMessage].info || "";
    const showMessage = messages[popupMessage].showMessage;
    if (error.message && showMessage) {
      if (message) {
        message += "\n" + error.message;
      } else {
        message = error.message;
      }
    }
    if (Date.now() - startBackground.startTime > 5 * 1000) {
      browser.notifications.create(id, {
        type: "basic",
        // FIXME: need iconUrl for an image, see #2239
        title,
        message
      });
    }
  };

  exports.reportError = function(e) {
    log.error("Telemetry disabled. Not sending critical error:", e);
  };

  catcher.registerHandler((errorObj) => {
    if (!errorObj.noPopup) {
      exports.showError(errorObj);
    }
    if (!errorObj.noReport) {
      exports.reportError(errorObj);
    }
  });

  return exports;
})();
