{WorkspaceView} = require 'atom'
AtomQuickjump = require '../lib/quickjump'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "QuickJump", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('quickjump')

  describe "when the quickjump:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.quickjump')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.commands.dispatch atom.workspaceView.element, 'quickjump:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.quickjump')).toExist()
        atom.commands.dispatch atom.workspaceView.element, 'quickjump:toggle'
        expect(atom.workspaceView.find('.quickjump')).not.toExist()
