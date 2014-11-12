_ = require 'underscore-plus'
{$, EditorView, View, Point} = require 'atom'

module.exports =
class QuickjumpView extends View
  targets = []

  @content: ->
    @div class: 'select-list popover-list quickjump', =>
      @subview 'miniEditor', new EditorView(mini: yes)

  initialize: (@editorView) ->
    {@editor} = @editorView
    @handleEvents()

  handleEvents: ->
    @on 'core:confirm', (event) => @confirm(0, event.shiftKey)
    @on 'core:cancel', => @detach()

    @subscribeToCommand @editorView, 'quickjump:toggle', =>
      if @hasParent()
        @detach()
      else
        @attach()

    @miniEditor.on 'keydown', (event) =>
      code = event.keyCode or event.which
      # shift key
      if code == 16
        return
      text = @miniEditor.getText()
      # 1 ot 9 key
      if 48 < code < 58 and text
        event.preventDefault()
        event.stopPropagation()
        @confirm(code - 48, event.shiftKey)
      if code == 13 and text
        event.preventDefault()
        event.stopPropagation()
        @confirm(0, event.shiftKey)


    @miniEditor.on 'keyup', (event) =>
      code = event.keyCode or event.which
      # shift key
      if code == 16
        return
      text = @miniEditor.getText()
      if text
          @findTargets(text)
      else
        targets = []
        @clearJumps()

  findTargets: (text) ->
    targets = []
    buffer = @editor.getBuffer()
    cursor = @editor.getCursorBufferPosition()
    targets = targets.concat(@findTargetsInLine buffer.lines[cursor.row], cursor.row, text)
    for idx in [1..buffer.lines.length] when targets.length < 11 and idx < 200
      upPos = cursor.row - idx
      downPos = cursor.row + idx
      if upPos > -1
        targets = targets.concat(@findTargetsInLine buffer.lines[upPos], upPos, text)
      if downPos < buffer.lines.length
        targets = targets.concat(@findTargetsInLine buffer.lines[downPos], downPos, text)
    targets = if targets.length > 10 then targets[0..9] else targets
    @createJumps(targets)

  findTargetsInLine: (line, idx, text)->
    result = []
    pos = line.indexOf(text)
    while pos != -1
      result.push new Point(idx, pos)
      pos = line.indexOf(text, pos + 1)
    result

  createJumps: (targets)->
    @clearJumps()
    for target, idx in targets
      jumpLabel = if idx > 0 then idx else 'Enter'
      jump = $("<div class='qj-jump'>#{jumpLabel}</div>")
      jump.css @editorView.pixelPositionForBufferPosition([target.row, target.column])
      @editorView.find('.scroll-view .overlayer:first').append jump

  clearJumps: ->
    @editorView.find('.qj-jump').remove()

  attach: ->
    @editorView.appendToLinesView(this)
    @setPosition()
    @miniEditor.focus()

  detach: ->
    return unless @hasParent()
    miniEditorFocused = @miniEditor.isFocused
    @miniEditor.setText('')
    super
    @restoreFocus() if miniEditorFocused
    @clearJumps()

  confirm: (idx, shifted)->
    @detach()
    if targets.length > 0
      target = targets[idx]
      @editor.setCursorBufferPosition target
      if shifted
        @editor.selectToEndOfWord()

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
