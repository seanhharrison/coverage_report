coverage_report
===============

Report Job for Salesforce Test Coverages.
Extract test coverages of apex resources to google spreadsheet.

WIP
remaining items 
 - creating new spereadsheet
 
### Preparation : create google spreadsheet template.
convert 'template/CoverageReport.xlsx' to google spreadsheet, and save it.

### Preparation : setup environment variables
setup the following variables

```
sfid=<<your salesforce id>>
sfpass=<<your salesforce pass>>
sftoken=<<your salesforce security token>>
sfhost=<<server host>>  [ https://test.salesforce.com | https://login.salesforce.com ]
spreadsheet_id=<<spreadsheet id>>
spreadsheet_sheet_id=<<spreadsheet sheet id>>
google_id=<<your google docs id>>
google_pass=<<your google docs password>>
```

### Get resources, and resolve dependencies

```
git clone git@github.com:hagasatoshi/coverage_report.git
cd coverage_report
npm install
```

### Build resources

```
grunt coffee
```

### Execute job

```
node build/coverage.js
```

### Result
test coverages are saved on google spreadsheet



