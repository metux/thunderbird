function run_test()
{
  Components.utils.import("resource://gre/modules/jsdebugger.jsm");
  var xpcInspector = Cc["@mozilla.org/jsinspector;1"].getService(Ci.nsIJSInspector);
  var g = testGlobal("test1");

  var dbg = new Debugger();
  dbg.addDebuggee(g);
  dbg.onDebuggerStatement = function(aFrame) {
    do_check_true(aFrame === dbg.getNewestFrame());
    // Execute from the nested event loop, dbg.getNewestFrame() won't
    // be working anymore.
    do_execute_soon(function() {
      try {
        do_check_true(aFrame === dbg.getNewestFrame());
      } finally {
        xpcInspector.exitNestedEventLoop();
      }
    });
    xpcInspector.enterNestedEventLoop();
  };

  g.eval("function debuggerStatement() { debugger; }; debuggerStatement();");

  dbg.enabled = false;
}