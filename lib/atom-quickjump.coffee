AtomQuickjumpView = require './atom-quickjump-view'

module.exports =
  atomQuickjumpView: null

  activate: (state) ->
    @atomQuickjumpView = new AtomQuickjumpView(state.atomQuickjumpViewState)

  deactivate: ->
    @atomQuickjumpView.destroy()

  serialize: ->
    atomQuickjumpViewState: @atomQuickjumpView.serialize()
