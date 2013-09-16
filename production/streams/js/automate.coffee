automate = (URLs) ->
    helium.init()
    status = switch helium.data.status
      when 0 then "Beginning report"
      when 1 then "Gathering list of stylesheets"
      when 2 then "Loading stylesheets"
      when 3 then "Cross-referencing selectors with DOM"
      when 4 then "Complete"
    console.log status
    ##
    # If Helium is clear, inject target pages.
    # If Helium is in final stages, get ready to download report.
    # And if Helium has a complete report, restart process.
    ##
    if helium.data.status == 0
      setTimeout ->
        if document.querySelector '#cssdetectTextarea'
          document.querySelector('#cssdetectTextarea').innerHTML = URLs
          $('#cssdetectStart').click()
          location.reload()
      , 2000
    else if helium.data.status == 4
      setTimeout ->
        if $("#cssreportDownloadReport").is ':visible'
          $('#cssreportResetID').click()
          location.reload()
      , 2000

runAutomate = (URLs) ->
  if document.readyState == "complete"
    automate URLs
  else
    document.addEventListener "load"
    , -> automate URLs
    , false