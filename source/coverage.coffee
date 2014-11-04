_ = require 'underscore'
moment = require 'moment'
Q = require 'q'
spreadsheet = require 'edit-google-spreadsheet'

jsforce = require 'jsforce'
options = loginUrl: process.env.sfhost
conn = new jsforce.Connection(options)

num_lines_covered = 0
num_lines_uncovered = 0
count = 0
array_class = new Array()


coverage = (covered, uncovered) ->
  (covered / (covered + uncovered) * 100).toFixed(2)

conn.login process.env.sfid, "#{process.env.sfpass}#{process.env.sftoken}", (err, userInfo)->
  if err
    console.log 'Authentication Error!! Please check if your salesforce account is correct or not.'
    console.log err
    return

  console.log "successfully logged in to salesforce..."

  spreadsheet.load {
    debug: true,
    spreadsheetId: process.env.spreadsheet_id,
    worksheetId: process.env.spreadsheet_sheet_id,
    username: process.env.google_id,
    password: process.env.google_pass,
  }, (err, sheet) ->
    if err
      console.log 'Error!! Please check if parameter of spreadsheet is correct or not. '
      console.log err
      return

    conn.tooling.sobject('ApexCodeCoverage').find (err, records)->
      if err
        console.log 'Unknown Error!! Please let me know this issue with the following error log.'
        console.log err
        return

      console.log "successfully get test coverages..."

      records = _.sortBy records, (e) -> coverage(e.NumLinesCovered, e.NumLinesUncovered)
      records.reduce (promise, cover_rate) ->
        promise.then ->
          array_class[count] = new Array()
          conn.sobject('ApexClass').retrieve cover_rate.ApexClassOrTriggerId, (err,apex)->
            if err
              console.log 'Unknown Error!! Please let me know this issue with the following error log.'
              console.log err
              return

            console.log "successfully get apex data..."

            array_class[count] = [
                count+1,
                apex.attributes.type,
                apex.Name,
                "#{coverage(cover_rate.NumLinesCovered, cover_rate.NumLinesUncovered)}%",
                cover_rate.NumLinesCovered,
                cover_rate.NumLinesUncovered,
                moment(apex.CreatedDate).format('YYYY/MM/DD'),
                apex.CreatedById,
                moment(apex.LastModifiedDate).format('YYYY/MM/DD'),
                apex.LastModifiedById
            ]
        .then (result) ->
          count++
          num_lines_covered += cover_rate.NumLinesCovered
          num_lines_uncovered += cover_rate.NumLinesUncovered

      , Q()
      .then ->
        sheet.add 3: 3: "#{coverage(num_lines_covered, num_lines_uncovered)}%"
        sheet.add 6: 1: array_class

        sheet.send (err)->
          if err
            console.log 'Unknown Error!! Please let me know this issue with the following error log.'
            console.log err
            return

          console.log "Updated spreadsheet successfully"
