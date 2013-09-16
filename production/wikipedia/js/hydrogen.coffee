##
# Wait until the test condition is true or a timeout occurs. Useful for waiting
# on a server response or for a ui change (fadeIn, etc.) to occur.
#
# @param testFx javascript condition that evaluates to a boolean,
# it can be passed in as a string (e.g.: "1 == 1" or "$('#bar').is(':visible')" or
# as a callback function.
# @param onReady what to do when testFx condition is fulfilled,
# it can be passed in as a string (e.g.: "1 == 1" or "$('#bar').is(':visible')" or
# as a callback function.
# @param timeOutMillis the max amount of time to wait. If not specified, 3 sec is used.
# @param failureMsg printed when a waitFor fails. If not specified, prints "'waitFor' timeout."
# @param successMsg printed when a waitFor succeeds. If not specified, prints "'waitFor' success."
##
waitFor = (testFx, onReady, timeOutMillis = 3000, failureMsg = '\'waitFor\' timeout', successMsg = '\'waitFor\' success.') ->
  start = new Date().getTime()
  condition = false
  f = ->
    if (new Date().getTime() - start < timeOutMillis) and not condition
      # If not time-out yet and condition not yet fulfilled
      condition = (if typeof testFx is 'string' then eval testFx else testFx()) #< defensive code
    else
      if not condition
        # If condition still not fulfilled (timeout but condition is 'false')
        console.log failureMsg
        phantom.exit 1
      else
        # Condition fulfilled (timeout and/or condition is 'true')
        console.log successMsg + " in #{new Date().getTime() - start}ms."
        if typeof onReady is 'string' then eval onReady else onReady() #< Do what it's supposed to do once the condition is fulfilled
        clearInterval interval #< Stop this interval
  interval = setInterval f, 250 #< repeat check every 250ms

# load requirements
fs = require 'fs'
system = require 'system'

# copy arguments for mutability
args = system.args.slice(0)

# pre-process arguments to get output file (if provided)
idx = args.indexOf('-w')
if idx isnt -1
  if idx is args.length - 1
    console.log '-w argument provided, but without target output filename'
    phantom.exit()
  outputFilename = args[idx+1]
  args.splice(idx, 2)

# make sure user has provided correct args
if args.length < 2
  console.log "At least one target URL required"
  phantom.exit()
allURLs = args[1]
initialURL = allURLs.split('\n')[0]

# create page
page = require('webpage').create();

page.onConsoleMessage = (msg) ->
  console.log msg

# because navigating (possibly) many pages, need to adapt to page loads
page.onInitialized = () ->
  # inject page w/ JS: jQuery, automate, helium
  if not page.injectJs('jquery.min.js') or not page.injectJs('helium.js') or not page.injectJs('automate.js')
    console.log "Failed to load JavaScript"
    phantom.exit()

previousURL = ""
page.onLoadFinished = () ->
  if previousURL isnt page.url
    console.log "On page: " + page.url
    previousURL = page.url
  # run automate script
  page.evaluate (s) ->
    automate(s)
  , allURLs

# load page from url
page.open initialURL, (status) ->
  if status isnt 'success'
    console.log 'Failed to load page.'
    phantom.exit()

  # reset helium
  page.evaluate -> helium.reset()

  # wait for button to be visible
  waitFor ->
    page.evaluate ->
      $("#cssreportDownloadReport").is ':visible'
  , ->
    report = page.evaluate ->
      # get URL with report encoded
      a = $("#cssreportDownloadReport").attr 'href'
      encoded_data = a.split(',')[1]
      decoded_data = decodeURIComponent escape window.atob encoded_data
      return decoded_data
    # write to file, if possible; else, echo report to console
    console.log "Report downloaded successfully."
    try
      fs.write outputFilename, report, "w"
    catch e
      console.log report
    phantom.exit()
  , 30000
  , "Error generating report."
  , "Report generated"
