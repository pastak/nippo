generate  = require './generate'

module.exports =
  openInPane: true,
  configDefaults:
    'NippoTemplateFilePath': ''

  activate: (state) ->
    atom.workspaceView.command "Nippo:Generate", => generate()

  deactivate: ->

  serialize: ->
