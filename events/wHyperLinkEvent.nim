# forward declaration
proc getVisited*(self: wHyperLinkCtrl, index = -1): bool {.inline.}

DefineIncrement(wEvent_HyperLinkFirst):
  wEvent_HyperLink

proc isHyperLinkEvent(msg: UINT): bool {.inline.} =
  msg == wEvent_HyperLink

method getIndex*(self: wHyperLinkEvent): int {.property, inline.} =
  ## Returns the index of the hyperlink.
  let pnmLink = cast[PNMLINK](mLparam)
  result = pnmLink.item.iLink

method getUrl*(self: wHyperLinkEvent): string {.property, inline.} =
  ## Returns the URL of the hyperlink.
  let pnmLink = cast[PNMLINK](mLparam)
  result = nullTerminated($pnmLink.item.szUrl)

method getLinkId*(self: wHyperLinkEvent): string {.property, inline.} =
  ## Returns the link ID of the hyperlink.
  let pnmLink = cast[PNMLINK](mLparam)
  result = nullTerminated($pnmLink.item.szID)

method getVisited*(self: wHyperLinkEvent): bool {.property, inline.} =
  ## Returns the visited state of the hyperlink.
  # visted state returned from PNMLINK always false?
  result = wHyperLinkCtrl(self.mWindow).getVisited(getIndex())
