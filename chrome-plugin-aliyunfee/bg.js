chrome.browserAction.onClicked.addListener(
    function (tab) {
    	chrome.windows.create(
    	{
                    url: 'popup.html#' + tab.windowId,
                    left: 300,
                    top: 200,
                    width: 600,
                    height: 600,
                    type: 'popup'
              });
    }
);