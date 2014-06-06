{allowUnsafeNewFunction} = require 'loophole'
{BufferedProcess} = require 'atom'
vm = require 'vm'  #needed for the Content Security Policy errors when executing JS
fs = require 'fs'
Os = require 'os'
_ = require 'underscore-plus'
Path = require 'path'
nippoTmpPath = Path.join Os.tmpDir(), "nippo.txt"

generateNippo = (gitLogCount=null) ->
  dir = atom.project.getRepo().getWorkingDirectory()
  date = new Date()
  year = date.getFullYear()
  month = if (date.getMonth() + 1) < 10 then '0' + (date.getMonth() + 1) else date.getMonth() + 1
  day = if date.getDate() < 10 then [0, (date.getDate() - 1)].join('') else date.getDate() - 1
  # git log --after=<date>は<date>を含まない
  today = [year, month, day].join('-')
  templateFilePath = Path.join(atom.getConfigDirPath(), 'nippo.txt')
  try
    templateFile = fs.readFileSync(templateFilePath).toString()
  catch
    alert 'You should put nippo template.Open file "' + templateFilePath + '". Save it and retry.'
    fs.writeFileSync templateFilePath, 'please place <%= log %> tag where you write git-log', flag: 'w+'
    atom.workspace.open(templateFilePath, split: 'right', activatePane: true)
    return false
  nippoTxt = ''
  new BufferedProcess({
    command: 'git'
    args: ['log', '--oneline', '--after=' + today]
    options:
      cwd: dir
    stderr: (data) ->
      showFile data.toString()
    stdout: (data) ->
      allowUnsafeNewFunction -> nippoTxt =  _.template templateFile, {log:data.toString()}
    exit: (exitCode) ->
      showFile nippoTxt if exitCode == 0
  })
showFile = (nippoTxt) ->
  fs.writeFileSync nippoTmpPath, nippoTxt, flag: 'w+'
  console.log nippoTmpPath
  atom.workspace.open(nippoTmpPath, split: 'right', activatePane: true)

module.exports = generateNippo
