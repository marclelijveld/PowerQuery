let
    //Capture the date range from the parameters
    StartDate = #date(2015, 1, 1),
    EndDate = #date(2025, 12, 31),
    
    //Get the number of dates that will be required for the table
    GetDateCount = Duration.Days(EndDate - StartDate) + 1,
    
    //Take the count of dates and turn it into a list of dates
    GetDateList = List.Dates(StartDate, GetDateCount, #duration(1,0,0,0)),
//Convert the list into a table
    DateListToTable = Table.FromList(GetDateList, Splitter.SplitByNothing(), {"Date"}, null, ExtraValues.Error),
//Create various date attributes from the date column
//Add Date ID Column
    //DateID = Table.AddColumn(DateListToTable, "OrderDateID", each Date.ToText([Date],"YYYYMMDD")),
//Add Year Column
    #"Add YearNumber" = Table.AddColumn(DateListToTable, "Year", each Date.Year([Date])),
//Add Quarter Column
    #"Add QuarterNumber" = Table.AddColumn(#"Add YearNumber" , "Quarter", each "Q" & Number.ToText(Date.QuarterOfYear([Date]))),
//Add Month Number Column
    #"Add MonthNumber" = Table.AddColumn(#"Add QuarterNumber", "Month Number", each Date.Month([Date])),
//Add Month Name Column
    #"Add MonthName" = Table.AddColumn(#"Add MonthNumber" , "Month", each Date.ToText([Date],"MMMM", if (DateTableLanguage) = "English" then "us-EN" else "nl-NL")),
//Add Year Month Column Sequential
    #"Add YearMonth" = Table.AddColumn(#"Add MonthName", "YearMonthNumber", each (([Year] - Date.Year(StartDate)) * 12) + [Month Number]  ),
//Add MonthDays Column
    #"Add MonthDays" = Table.AddColumn(#"Add YearMonth" , "MonthDays", each Date.DaysInMonth([Date])),
//Add MonthDayNumber Column
    #"Add MonthDayNumber" = Table.AddColumn(#"Add MonthDays", "MonthDayNumber", each Date.Day([Date])),
//Add PMDate Column
    #"Add PMDate" = Table.AddColumn(#"Add MonthDayNumber", "PM Date", each Date.AddMonths([Date],-1)),
//Add PQDate Column
    #"Add PQDate" = Table.AddColumn(#"Add PMDate", "PQ Date", each Date.AddQuarters([Date],-1)),
//Add PYDate Column
    #"Add PYDate" = Table.AddColumn(#"Add PQDate", "PY Date", each Date.AddYears([Date],-1)),
//Add ISO week and year
    #"Add ISOYear" = Table.AddColumn(#"Add PYDate", "ISOYear", each Date.Year(Date.AddDays([Date],3-Date.DayOfWeek([Date],1))), type number),
    #"Add RefDate" = Table.AddColumn(#"Add ISOYear" , "RefDate", each #date([ISOYear],1,3)),
    #"Add ISOWeek" = Table.AddColumn(#"Add RefDate" , "ISOWeek", each Number.IntegerDivide(Duration.Days([Date]-[RefDate])+Date.DayOfWeek([RefDate],0)+6,7), type number ),
    #"Add CalendarWeek" = Table.AddColumn(#"Add ISOWeek" , "Week Number", each Number.ToText([ISOYear]) & Number.ToText([ISOWeek],"/00")),
    #"Removed RefDate" = Table.RemoveColumns(#"Add CalendarWeek" ,{"RefDate"}),
//Add Day of Week Column
    #"Add DayOfWeek" = Table.AddColumn(#"Removed RefDate" , "Day of Week", each Date.ToText([Date],"dddd", if (DateTableLanguage) = "English" then "us-EN" else "nl-NL")),
//Add Day Number
    #"Add DayNumber" = Table.AddColumn(#"Add DayOfWeek", "Day Number", each Date.DayOfWeek([Date], Day.Monday)+1, type number),
//Add Year Day Number
    #"Add YearDayNumber" = Table.AddColumn(#"Add DayNumber", "YearDayNumber", each Date.DayOfYear([Date]), type number),
//Add ISO Year Day Number
    #"Add ISOYearDayNumber" = Table.AddColumn(#"Add YearDayNumber" , "ISOYearDayNumber", each ([ISOWeek]-1)*7+[Day Number], type number),
    
    //Change data types
    #"Changed Data Types" = Table.TransformColumnTypes(#"Add ISOYearDayNumber",{{"Date", type date}, {"Year", Int64.Type}, {"Quarter", type text}, {"Month Number", Int64.Type}, {"Month", type text}, {"YearMonthNumber", Int64.Type}, {"MonthDays", Int64.Type}, {"MonthDayNumber", Int64.Type}, {"PM Date", type date}, {"PQ Date", type date}, {"PY Date", type date}, {"ISOYear", Int64.Type}, {"ISOWeek", Int64.Type}, {"Week Number", type text}, {"Day of Week", type text}, {"Day Number", Int64.Type}, {"YearDayNumber", Int64.Type}, {"ISOYearDayNumber", Int64.Type}}),
   
    //Rename columns if necessary, based upon parameter value!
    #"Change Header Language" = if (DateTableLanguage) = "English" then #"Changed Data Types" else Table.RenameColumns(#"Changed Data Types",{{"Date", "Datum"}, {"Year", "Jaar"}, {"Quarter", "Kwartaal"}, {"Month Number", "Maandnummer"}, {"Month", "Maand"}, {"YearMonthNumber", "JaarMaandNummer"}, {"MonthDays", "MaandDagen"}, {"MonthDayNumber", "MaandDagNummer"}, {"PM Date", "PM Datum"}, {"PQ Date", "PQ Datum"}, {"PY Date", "PY Datum"}, {"ISOYear", "ISO Jaar"}, {"ISOWeek", "ISO Week"}, {"Week Number", "Weeknummer"}, {"Day of Week", "Weekdag"}, {"Day Number", "Dagnummer"}, {"YearDayNumber", "JaarDagNummer"}, {"ISOYearDayNumber", "ISO JaarDagNummer"}}),
    #"Filtered Rows" = Table.SelectRows(#"Change Header Language", each [Year] <= Date.Year(DateTime.LocalNow()))
in
    #"Filtered Rows"