_ = require 'underscore-plus'
QuickjumpView = require './quickjump-view'

module.exports =
  quickjumpViews: []
  editorSubscription: null

  activate: ->
    @editorSubscription = atom.workspaceView.eachEditorView (editor) =>
      if editor.attached and not editor.mini
        quickjumpView = new QuickjumpView(editor)
        editor.on 'editor:will-be-removed', =>
          quickjumpView.remove() unless quickjumpView.hasParent()
          _.remove(@quickjumpViews, quickjumpView)
        @quickjumpViews.push(quickjumpView)

  deactivate: ->
    @editorSubscription?.off()
    @editorSubscription = null
    @quickjumpViews.forEach (quickjumpView) -> quickjumpView.remove()
    @quickjumpViews = []
