{$, EditorView, WorkspaceView} = require 'atom'
Quickjump = require '../lib/quickjump'
QuickjumpView = require '../lib/quickjump-view'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "QuickJump", ->
  [activationPromise] = []

  beforeEach ->
    atom.workspaceView = new WorkspaceView

    waitsForPromise ->
      atom.workspace.open('sample.js')

    runs ->
      atom.workspaceView.simulateDomAttachment()
      activationPromise = atom.packages.activatePackage('quickjump')

  describe "@activate()", ->
    it "activates quickjump on all existing and future editors (but not on quickjump's own mini editor)", ->
      spyOn(QuickjumpView.prototype, 'initialize').andCallThrough()

      expect(QuickjumpView.prototype.initialize).not.toHaveBeenCalled()

      leftEditor = atom.workspaceView.getActiveView()
      rightEditor = leftEditor.splitRight()

      leftEditor.trigger 'quickjump:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(leftEditor.find('.quickjump')).toExist()
        expect(rightEditor.find('.quickjump')).not.toExist()
        expect(QuickjumpView.prototype.initialize).toHaveBeenCalled()

        autoCompleteView = leftEditor.find('.quickjump').view()
        autoCompleteView.trigger 'core:cancel'
        expect(leftEditor.find('.quickjump')).not.toExist()

        rightEditor.trigger 'quickjump:toggle'
        expect(rightEditor.find('.quickjump')).toExist()

  # describe "@deactivate()", ->
  #   it "removes all quickjump views and doesn't create new ones when new editors are opened", ->
  #     waitsForPromise ->
  #       activationPromise
  #
  #     atom.workspaceView.getActiveView().trigger "quickjump:toggle"
  #
  #     runs ->
  #       expect(atom.workspaceView.getActiveView().find('.quickjump')).toExist()
  #       atom.packages.deactivatePackage('quickjump')
  #       expect(atom.workspaceView.getActiveView().find('.quickjump')).not.toExist()
  #       atom.workspaceView.getActiveView().splitRight()
  #       atom.workspaceView.getActiveView().trigger "quickjump:toggle"
  #       expect(atom.workspaceView.getActiveView().find('.quickjump')).not.toExist()

describe "QuickJump view", ->
  [quickjump, editorView, editor, miniEditor] = []

  beforeEach ->
    atom.workspaceView = new WorkspaceView

    waitsForPromise ->
      atom.workspace.open('sample.js').then (editor) ->
        editorView = new EditorView({editor})

    runs ->
      {editor} = editorView
      quickjump = new QuickjumpView(editorView)
      miniEditor = quickjump.miniEditor

  describe "quickjump:toggle event", ->
    it "show quickjump view and focus its mini-editor", ->
      editorView.attachToDom()
      expect(editorView.find('.quickjump')).not.toExist()

      editorView.trigger "quickjump:toggle"
      expect(editorView.find('.quickjump')).toExist()
      expect(quickjump.editor.isFocused).toBeFalsy()
      expect(quickjump.miniEditor.isFocused).toBeTruthy()

    it "hide quickjump view if already visible", ->
      editorView.attachToDom()
      expect(editorView.find('.quickjump')).not.toExist()
      editorView.trigger "quickjump:toggle"

      expect(editorView.find('.quickjump')).toExist()
      editorView.trigger "quickjump:toggle"

      expect(editorView.find('.quickjump')).not.toExist()

  describe "quickjump:confirm", ->
    it "jump to the closest target", ->
      quickjump.attach()
      miniEditor.setText 'sort'
      miniEditor.trigger 'keyup'
      miniEditor.trigger 'core:confirm'

      pos = quickjump.editor.getCursorBufferPosition()
      expect(pos.row).toEqual 0
      expect(pos.column).toEqual 9

    it "jump to index target", ->
      quickjump.attach()
      miniEditor.setText 'sort'
      miniEditor.trigger 'keyup'
      event = $.Event('keydown');
      event.which = 49;
      miniEditor.trigger event

      pos = quickjump.editor.getCursorBufferPosition()
      expect(pos.row).toEqual 1
      expect(pos.column).toEqual 6
