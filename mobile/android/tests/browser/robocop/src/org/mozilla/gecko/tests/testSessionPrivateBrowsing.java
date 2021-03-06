package org.mozilla.gecko.tests;

import org.mozilla.gecko.Actions;
import org.mozilla.gecko.GeckoApp;
import org.mozilla.gecko.Tabs;
import org.mozilla.gecko.tests.helpers.GeckoHelper;
import org.mozilla.gecko.util.BundleEventListener;
import org.mozilla.gecko.util.EventCallback;
import org.mozilla.gecko.util.GeckoBundle;

public class testSessionPrivateBrowsing extends UITest implements BundleEventListener {
    private static final String PRIVATE_TABS_EVENT = "PrivateBrowsing:Data";
    private static final String FLUSH_TABS_EVENT = "Session:FlushTabs";

    private volatile TestStage mTestStage;
    private boolean mWait = true;

    public void testSessionPrivateBrowsing() {
        GeckoHelper.blockForDelayedStartup();

        // Attempt to get the session store into a known idle state by flushing any possibly
        // still pending writes.
        runTestCycle(TestStage.SETUP);

        // Flushing with no pending writes should yield a "no change" message.
        runTestCycle(TestStage.NO_CHANGE);

        // Flushing with a pending write, but no private tabs open, should yield "null" private
        // tab data.
        openNewTab(false);
        runTestCycle(TestStage.NO_PRIVATE_TABS);

        // After opening a private tab, the private tabs session string we receive shouldn't be
        // emtpy anymore.
        openNewTab(true);
        runTestCycle(TestStage.SOME_PRIVATE_TABS);
    }

    private void openNewTab(final boolean privateTab) {
        // WaitHelper#waitForPageLoad does some additional checks which we don't require, so in
        // order to speed things up (see below), we do our own custom waiting to make sure the
        // new tab has been opened in Gecko as well.
        Actions.EventExpecter pageLoad =
                getActions().expectGlobalEvent(Actions.EventType.UI, "Content:DOMTitleChanged");
        // We only have a limited window of time in which we can manually flush the pending session
        // store writes before they are written out automatically. Opening new tabs the Robocop way
        // by actually clicking the corresponding menu item is currently rather slow, so we bypass
        // this and open them directly.
        if (privateTab) {
            Tabs.getInstance().addPrivateTab();
        } else {
            Tabs.getInstance().addTab();
        }
        pageLoad.blockForEvent();
        pageLoad.unregisterListener();
    }

    private void runTestCycle(final TestStage testStage) {
        mTestStage = testStage;
        ((GeckoApp) getActivity()).getAppEventDispatcher()
                .registerGeckoThreadListener(this, PRIVATE_TABS_EVENT);
        getActions().sendGlobalEvent(FLUSH_TABS_EVENT, null);
        synchronized (this) {
            while (mWait) {
                try {
                    wait();
                } catch (InterruptedException e) { }
            }
            mWait = true;
        }
    }


    @Override
    public void handleMessage(String event, GeckoBundle message, EventCallback callback) {
        mAsserter.is(event, PRIVATE_TABS_EVENT, "received " + PRIVATE_TABS_EVENT + " event");

        switch (mTestStage) {
            case NO_CHANGE:
                getAsserter().ok(message.getBoolean("noChange"),
                        "got expected no change event", null);
                break;

            case NO_PRIVATE_TABS:
                getAsserter().ok(!message.containsKey("noChange"),
                        "didn't get no change event", null);
                getAsserter().ok(message.getString("session") == null,
                        "got empty private tabs data",null);
                break;

            case SOME_PRIVATE_TABS:
                getAsserter().ok(message.getString("session") != null,
                        "got some private tabs data",null);
                break;
        }

        ((GeckoApp) getActivity()).getAppEventDispatcher()
                .unregisterGeckoThreadListener(this, PRIVATE_TABS_EVENT);
        synchronized (this) {
            mWait = false;
            notifyAll();
        }
    }

    private enum TestStage {
        SETUP,
        NO_CHANGE,
        NO_PRIVATE_TABS,
        SOME_PRIVATE_TABS,
    }
}
