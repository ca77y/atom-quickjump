{WorkspaceView} = require 'atom'
AtomQuickjump = require '../lib/atom-quickjump'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "AtomQuickjump", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('atom-quickjump')

  describe "when the atom-quickjump:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.atom-quickjump')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.commands.dispatch atom.workspaceView.element, 'atom-quickjump:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.atom-quickjump')).toExist()
        atom.commands.dispatch atom.workspaceView.element, 'atom-quickjump:toggle'
        expect(atom.workspaceView.find('.atom-quickjump')).not.toExist()
