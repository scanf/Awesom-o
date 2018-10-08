'use strict'

// This file is required by the index.html file and will
// be executed in the renderer process for that window.
// All of the Node.js APIs are available in this process.
const { ipcRenderer } = require('electron')
const { renderCommands } = require('./src/js/views/index.js')
const { renderConfigure } = require('./src/js/views/configuration.js')
const { renderNewCommand } = require('./src/js/views/new-command.js')
var $ = require('jQuery')

// This is required for the initial load of the index.html file
$('#container').load('../../src/pages/commands.html', function () {
  renderCommands()
})

function pickViewToRender (view) {
  if (view.endsWith('commands.html')) {
    $('#container').load('../../src/pages/commands.html', function () {
      renderCommands()
    })
  } else if (view.endsWith('new-command.html')) {
    $('#container').load('../../src/pages/new-command.html', function () {
      renderNewCommand(renderCommands)
    })
  } else if (view.endsWith('configuration.html')) {
    $('#container').load('../../src/pages/configuration.html', function () {
      renderConfigure()
    })
  }
}

// View changes from the main process
ipcRenderer.on('view', function (event, view) {
  console.log(`view -> (${event}, ${view})`)
  pickViewToRender(view)
})
