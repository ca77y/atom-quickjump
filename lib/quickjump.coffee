QuickjumpView = require './quickjump-view'

module.exports =
  quickjumpView: null

  activate: (state) ->
    @quickjumpView = new AtomQuickjumpView(state.quickjumpViewState)

  deactivate: ->
    @quickjumpView.destroy()

  serialize: ->
    quickjumpViewState: @quickjumpView.serialize()
