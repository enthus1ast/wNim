#====================================================================
#
#               wNim - Nim's Windows GUI Framework
#                 (c) Copyright 2017-2019 Ward
#
#====================================================================

## An accelerator table allows the application to specify a table of keyboard
## shortcuts for menu or button commands.The accelerator key can be either
## a virtual-key code or a character code. Example:
##
## .. code-block:: Nim
##   var accel = AcceleratorTable()
##   accel.add(wAccelCtrl, wKey_S, wIdSave)
##   accel.add(wAccelNormal, wKey_F1, wIdHelp)
##   accel.add('o', wIdOpen)
##   frame.acceleratorTable = accel
##
## There is also a *wFrame.shortcut()* function can quickly bind a keyboard
## shortcut to an event handler.
#
## :Seealso:
##   `wFrame <wFrame.html>`_

# forward declarations
proc setAcceleratorTable*(self: wWindow, accel: wAcceleratorTable) {.inline.}

const
  wAccelNormal* = 0
  wAccelAlt* = FALT
  wAccelCtrl* = FCONTROL
  wAccelShift* = FSHIFT

type
  wAcceleratorEntry* {.pure.} = object
    ## wAcceleratorEntry is an object used to create an accelerator table.
    flag: int
    keyCode: int
    id: wCommandID
    isChar: bool

converter wAcceleratorEntryToACCEL(x: wAcceleratorEntry): ACCEL =
  result.key = WORD x.keyCode
  result.cmd = WORD x.id
  result.fVirt = BYTE(if x.isChar: 0 else: x.flag or FVIRTKEY)

converter ACCELTOwAcceleratorEntry(x: ACCEL): wAcceleratorEntry =
  result.keyCode = int x.key
  result.id = wCommandID x.cmd
  if (x.fVirt and FVIRTKEY) != 0:
    result.isChar = false
    result.flag = x.fVirt.int and (not FVIRTKEY)
  else:
    result.isChar = true

proc AcceleratorEntry*(flag: int, keyCode: int, id: wCommandID): wAcceleratorEntry
    {.inline.} =
  ## Constructor for virtual-key code accelerator object.
  result = wAcceleratorEntry(flag: flag, keyCode: keyCode, id: id, isChar: false)

proc AcceleratorEntry*(ch: char, id: wCommandID): wAcceleratorEntry {.inline.} =
  ## Constructor for character code accelerator object.
  result = wAcceleratorEntry(keyCode: ch.ord, id: id, isChar: true)

proc set*(self: var wAcceleratorEntry, flag: int, keyCode: int, id: wCommandID)
    {.inline.} =
  ## Sets the virtual-key code accelerator. This proc exists for backward compatibility.
  self = AcceleratorEntry(flag, keyCode, id)

proc set*(self: var wAcceleratorEntry, ch: char, id: wCommandID) {.inline.} =
  ## Sets the character code accelerator. This proc exists for backward compatibility.
  self = AcceleratorEntry(ch, id)

converter tupleTowAcceleratorEntry1*[T: enum|wCommandID](x: (int, int, T)):
    wAcceleratorEntry {.inline.} =
  ## Convert tuple to virtual-key code accelerator object.
  result = AcceleratorEntry(x[0], x[1], wCommandID x[2])

converter tupleTowAcceleratorEntry2*[T: enum|wCommandID](x: (char, T)):
    wAcceleratorEntry {.inline.} =
  ## Convert tuple to character code accelerator object.
  result = AcceleratorEntry(x[0], wCommandID x[1])

proc getHandle(self: wAcceleratorTable): HACCEL =
  # Use internally, generate the accelerator table on the fly.
  if self.mModified:
    if self.mHandle != 0:
      DestroyAcceleratorTable(self.mHandle)

    if self.mAccels.len != 0:
      self.mHandle = CreateAcceleratorTable(addr self.mAccels[0], self.mAccels.len)
    else:
      self.mHandle = 0
    self.mModified = false

  result = self.mHandle

proc add*(self: wAcceleratorTable, entry: wAcceleratorEntry)
    {.validate, inline.} =
  ## Adds an accelerator object to the table.
  self.mAccels.add(ACCEL entry)
  self.mModified = true

proc add*(self: wAcceleratorTable, entries: openarray[wAcceleratorEntry])
    {.validate, inline.} =
  ## Adds multiple accelerator objects to the table.
  for entry in entries:
    self.add(entry)

proc add*(self: wAcceleratorTable, flag: int, keyCode: int, id: wCommandID)
    {.validate, inline.} =
  ## Adds a virtual-key code accelerator object to the table.
  self.add(AcceleratorEntry(flag, keyCode, id))

proc add*(self: wAcceleratorTable, ch: char, id: wCommandID)
    {.validate, inline.} =
  ## Adds a character code accelerator object to the table.
  self.add(AcceleratorEntry(ch, id))

proc del*(self: wAcceleratorTable, index: Natural) {.validate, inline.} =
  ## Deletes the object in the table by index.
  self.mAccels.del(index)
  self.mModified = true

proc clear*(self: wAcceleratorTable) {.validate, inline.} =
  ## Clear the talbe.
  self.mAccels.setLen(0)
  self.mModified = true

iterator items*(self: wAcceleratorTable): wAcceleratorEntry {.validate, inline.} =
  ## Iterate each item in this table.
  for accel in self.mAccels:
    yield wAcceleratorEntry accel

proc final*(self: wAcceleratorTable) =
  ## Default finalizer for wAcceleratorTable.
  # self.mAccels.setLen(0) # not sure is this safe for GC, but it should not need.
  if self.mHandle != 0:
    DestroyAcceleratorTable(self.mHandle)
  self.mHandle = 0

proc init*(self: wAcceleratorTable) {.validate, inline.} =
  ## Initializer.
  self.mAccels = @[]

proc AcceleratorTable*(): wAcceleratorTable {.inline.} =
  ## Constructor.
  new(result, final)
  result.init()

proc init*(self: wAcceleratorTable, entries: openarray[wAcceleratorEntry]) =
  ## Initializer.
  self.mAccels = newSeqOfCap[ACCEL](entries.len)
  for entry in entries:
    self.mAccels.add(ACCEL entry)
  self.mModified = true

proc AcceleratorTable*(entries: openarray[wAcceleratorEntry]):
    wAcceleratorTable {.inline.} =
  ## Construct a accelerator table from an openarray of wAcceleratorEntry.
  new(result, final)
  result.init(entries)

proc init*(self: wAcceleratorTable, window: wWindow) {.validate, inline.} =
  ## Initializer.
  self.init()
  window.setAcceleratorTable(self)

proc AcceleratorTable*(window: wWindow): wAcceleratorTable {.inline.} =
  ## Construct an accelerator table, and attach it to *window*.
  new(result, final)
  result.init(window)

proc init*(self: wAcceleratorTable, window: wWindow,
    entries: openarray[wAcceleratorEntry]) {.validate, inline.} =
  ## Initializer.
  self.init(entries)
  window.setAcceleratorTable(self)

proc AcceleratorTable*(window: wWindow, entries: openarray[wAcceleratorEntry]):
    wAcceleratorTable {.inline.} =
  ## Construct an accelerator table from an openarray of
  ## wAcceleratorEntry, and attach it to *window*.
  new(result, final)
  result.init(window, entries)
