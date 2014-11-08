_ = require 'underscore-plus'
{$, EditorView, View} = require 'atom'

module.exports =
class QuickjumpView extends View
  @activate: -> new GoToLineView

  @content: ->
    @div class: 'select-list popover-list quickjump', =>
      @subview 'miniEditor', new EditorView(mini: yes)

  initialize: (@editorView) ->
    @css
      width: '50px'
      'min-width': '50px'
    {@editor} = @editorView

    @handleEvents()

  handleEvents: ->
    @on 'core:confirm', => @confirm()
    @on 'core:cancel', => @detach()

    @subscribeToCommand @editorView, 'quickjump:toggle', =>
      if @hasParent()
        @detach()
      else
        @attach()

  attach: ->
    @editorView.appendToLinesView(this)
    @setPosition()
    @miniEditor.focus()

  confirm: ->
    @detach()

  setPosition: ->
    {left, top} = @editorView.pixelPositionForScreenPosition @editor.getCursorScreenPosition()
    height = @outerHeight()
    potentialTop = top + @editorView.lineHeight
    @css
      left: left
      top: potentialTop
      bottom: 'inherit'

  restoreFocus: ->
    if @previouslyFocusedElement?.isOnDom()
      @previouslyFocusedElement.focus()
    else
      atom.workspaceView.focus()

  detach: ->
    return unless @hasParent()
    miniEditorFocused = @miniEditor.isFocused
    @miniEditor.setText('')
    super
    @restoreFocus() if miniEditorFocused
