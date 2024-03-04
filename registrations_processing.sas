%let lib = SDTJAN23;
%let festivalVar = ;
%let milongaVar = ;
%let workshopVar = ;
%let wrokshopsList = ws1 ws2 ws3 ws4;
%let earlyBirdEndDT = 30/11/2022;
%let earlyBirdEndDT_Plovdiv = 15/12/2022;

%let EBfullPassPrice = 120;
%let fullPassPrice = 150;

%let EBmilongaPassPrice = 70;
%let milongaPassPrice = 90;

%let EBwsPassPrice = 55;
%let wsPassPrice = 75;

%let EBws1Price = 15;
%let EBws2Price = 15;
%let EBws3Price = 15;
%let EBws4Price = 15;
%let ws1Price = 20;
%let ws2Price = 20;
%let ws3Price = 20;
%let ws4Price = 20;

%let EBthursdayNightPrice = 1.5;
%let EBfridayNightPrice = 20;
%let EBsaturdayDayPrice = 10;
%let EBsaturdayNightPrice = 20;
%let EBsundayDayPrice = 10;
%let EBsundayNightPrice = 15;
%let EBmondayNightPrice = 1.5;
%let thursdayNightPrice = 1.5;
%let fridayNightPrice = 25;
%let saturdayDayPrice = 15;
%let saturdayNightPrice = 25;
%let sundayDayPrice = 15;
%let sundayNightPrice = 20;
%let mondayNightPrice = 1.5;



data _null_;
    call symput("ebEnd", put(input(substr(strip("&earlyBirdEndDT"), 1, 10), ddmmyy10.), best.));
    call symput("ebEnd_Plovdiv",
                put(input(substr(strip("&earlyBirdEndDT_Plovdiv"), 1, 10), ddmmyy10.), best.));
run;



*Remove multiple registrations. Rename columns.
*Manually add exceptions via program updateRaw. Use addInfo for aditional information.
*Out data is rawUpdatedAdded;



%macro addPrice(eventType=, eventName=, eventKey=, EBprice=, price=);
    
    if strip("&eventType.") = "M" then do;
        if index(upcase(milongas), upcase("&eventKey.")) > 0 then do;
            if missing(milongasAttending) then milongasAttending = "&eventKey.";
            else milongasAttending = strip(milongasAttending) || "; &eventKey.";
            totalPrice = totalPrice + ifn(earlyBird = "YES", &EBprice., &price.);
        end;
    end;
    else if strip("&eventType.") = "W" then do;
        if index(upcase(workshops), upcase("&eventKey.")) > 0 then do;
            if missing(wsAttending) then wsAttending = "&eventKey.";
            else wsAttending = strip(wsAttending) || "; &eventKey.";
            totalPrice = totalPrice + ifn(earlyBird = "YES", &EBprice., &price.);
        end;
    end;
    
%mend addPrice;

%macro addToOutData(eventType=, eventName=, eventKey=);
    
    if strip("&eventType.") = "M" then do;
        if index(upcase(milongas), upcase("&eventKey.")) > 0 then do;
            output &eventName.;
        end;
    end;
    else if strip("&eventType.") = "W" then do;
        if index(upcase(workshops), upcase("&eventKey.")) > 0 then do;
            output &eventName.;
        end;
    end;
    
%mend addToOutdata;



data input;
    set &lib..rawUpdated;
    
    length totalPrice regDate 8. fullName $100 paid earlyBird attended $20 milongasAttending wsAttending $300;
    
    call missing(milongasAttending, wsAttending);
    
    totalPrice = 0;
    
    call missing(attended);
    
    fullName = strip(lastName) || " " || strip(firstName);
    
    regDate = datepart(regDateTime);
    
    earlyBird = ifc(regDate > ifn(strip(upcase(city)) = "PLOVDIV", &ebEnd_plovdiv., &ebEnd.), "NO", "YES");
    
    if upcase(strip(festivalPass)) = "YES" or
       (index(upcase(strip(milongas)), "FULL MILONGA PASS") > 0 and
       index(upcase(strip(workshops)), "FULL WORKSHOP PASS") > 0) then do;
        totalPrice = ifn(earlyBird = "YES", &EBfullPassPrice., &fullPassPrice.);
        milongasAttending = "FULL PASS";
        wsAttending = "FULL PASS";
    end;
    else do;
	    if index(upcase(strip(milongas)), "FULL MILONGA PASS") > 0 then do;
	        totalPrice = totalPrice + ifn(earlyBird = "YES", &EBmilongaPassPrice., &milongaPassPrice.);
	        milongasAttending = "FULL PASS";
	    end;
	    else do;
	        %addPrice(eventType = M
                    , eventName = %str(thursdayNight)
                    , eventKey  = %str(Thursday welcome)
                    , EBprice   = &EBthursdayNightPrice.
                    , price     = &thursdayNightPrice.
	        );
	        %addPrice(eventType = M
                    , eventName = %str(fridayNight)
                    , eventKey  = %str(Friday Gran)
                    , EBprice   = &EBfridayNightPrice.
                    , price     = &fridayNightPrice.
	        );
	        %addPrice(eventType = M
                    , eventName = %str(saturdayDay)
                    , eventKey  = %str(Saturday Daily)
                    , EBprice   = &EBsaturdayDayPrice.
                    , price     = &saturdayDayPrice.
	        );
	        %addPrice(eventType = M
                    , eventName = %str(saturdayNight)
                    , eventKey  = %str(Saturday Gran)
                    , EBprice   = &EBsaturdayNightPrice.
                    , price     = &saturdayNightPrice.
	        );
	        %addPrice(eventType = M
                    , eventName = %str(sundayDay)
                    , eventKey  = %str(Sunday Daily)
                    , EBprice   = &EBsundayDayPrice.
                    , price     = &sundayDayPrice.
	        );
	        %addPrice(eventType = M
                    , eventName = %str(sundayNight)
                    , eventKey  = %str(Sunday Gran)
                    , EBprice   = &EBsundayNightPrice.
                    , price     = &sundayNightPrice.
	        );
	        %addPrice(eventType = M
                    , eventName = %str(mondayNight)
                    , eventKey  = %str(Monday goodbye)
                    , EBprice   = &EBmondayNightPrice.
                    , price     = &mondayNightPrice.
	        );
	    end;
	    
	    if index(upcase(strip(workshops)), "FULL WORKSHOP PASS") > 0 then do;
	        totalPrice = totalPrice + ifn(earlyBird = "YES", &EBwsPassPrice., &wsPassPrice.);
	        wsAttending = "FULL PASS";
	    end;
	    else do;
	        %addPrice(eventType = W
                    , eventName = %str(ws1)
                    , eventKey  = %str(WS1)
                    , EBprice   = &EBws1Price.
                    , price     = &ws1Price.
	        );
	        %addPrice(eventType = W
                    , eventName = %str(ws2)
                    , eventKey  = %str(WS2)
                    , EBprice   = &EBws2Price.
                    , price     = &ws2Price.
	        );
	        %addPrice(eventType = W
                    , eventName = %str(ws3)
                    , eventKey  = %str(WS3)
                    , EBprice   = &EBws3Price.
                    , price     = &ws3Price.
	        );
	        %addPrice(eventType = W
                    , eventName = %str(ws4)
                    , eventKey  = %str(WS4)
                    , EBprice   = &EBws4Price.
                    , price     = &ws4Price.
	        );
	    end;
    end;
    
    if ammountPaid >= totalPrice then paid = "YES";
    else paid = "NO";
         
    if not ((strip(country) in ("Greece", "Turkey", "Romania", "Denmark")) or
       strip(city) in ("Plovdiv", "Dubai"))
       and missing(ammountPaid) and earlyBird = "YES" and not missing(regDateTime) then do;
        note = "Late payment - regular price";
    end;
    
    proc sort; by city fullName;
run;

data thursdayNight fridayNight saturdayDay saturdayNight sundayDay sundayNight mondayNight ws1 ws2 ws3 ws4;
    retain fullName city danceRole totalPrice paid attended note;
    set input;
    
    if upcase(strip(festivalPass)) = "YES" then do;
        totalPrice = ifn(earlyBird = "YES", &EBfullPassPrice., &fullPassPrice.);
        output;
    end;
    else do;
	    if index(upcase(strip(milongas)), "FULL MILONGA PASS") > 0 then do;
	        output thursdayNight fridayNight saturdayDay saturdayNight sundayDay sundayNight mondayNight;
	    end;
	    else do;
	        %addToOutData(eventType = M
	                    , eventName = %str(thursdayNight)
	                    , eventKey  = %str(Thursday welcome)
	        );
	        %addToOutData(eventType = M
	                    , eventName = %str(fridayNight)
	                    , eventKey  = %str(Friday Gran)
	        );
	        %addToOutData(eventType = M
	                    , eventName = %str(saturdayDay)
	                    , eventKey  = %str(Saturday Daily)
	        );
	        %addToOutData(eventType = M
	                    , eventName = %str(saturdayNight)
	                    , eventKey  = %str(Saturday Gran)
	        );
	        %addToOutData(eventType = M
	                    , eventName = %str(sundayDay)
	                    , eventKey  = %str(Sunday Daily)
	        );
	        %addToOutData(eventType = M
	                    , eventName = %str(sundayNight)
	                    , eventKey  = %str(Sunday Gran)
	        );
	        %addToOutData(eventType = M
	                    , eventName = %str(mondayNight)
	                    , eventKey  = %str(Monday goodbye)
	        );
	    end;
	    
	    if index(upcase(strip(workshops)), "FULL WORKSHOP PASS") > 0 then do;
	        output ws1 ws2 ws3 ws4;
	    end;
	    else do;
	        %addToOutData(eventType = W
	                    , eventName = %str(ws1)
	                    , eventKey  = %str(WS1)
	        );
	        %addToOutData(eventType = W
	                    , eventName = %str(ws2)
	                    , eventKey  = %str(WS2)
	        );
	        %addToOutData(eventType = W
	                    , eventName = %str(ws3)
	                    , eventKey  = %str(WS3)
	        );
	        %addToOutData(eventType = W
	                    , eventName = %str(ws4)
	                    , eventKey  = %str(WS4)
	        );
	    end;
    end;
    
    keep fullName city danceRole totalPrice paid attended note;
run;

data allRegistrations;
    retain fullName phone email regDateTime city milongasAttending
           wsAttending promoterName earlyBird totalPrice ammountPaid paid note;
    set input;
    keep fullName phone regDateTime danceRole city milongasAttending
         wsAttending promoterName earlyBird totalPrice ammountPaid paid note;
run;

%macro countByRole(eventName=);

	proc sql;
	    create table roleCounts&eventName. as
	    select danceRole, count(*) as roleCount
	    from &eventName.
	    group by danceRole
	    ;
	quit;

%mend countByRole;

%countByRole(eventName = thursdayNight);
%countByRole(eventName = fridayNight);
%countByRole(eventName = saturdayDay);
%countByRole(eventName = saturdayNight);
%countByRole(eventName = sundayDay);
%countByRole(eventName = sundayNight);
%countByRole(eventName = mondayNight);
%countByRole(eventName = ws1);
%countByRole(eventName = ws2);
%countByRole(eventName = ws3);
%countByRole(eventName = ws4);
%countByRole(eventName = allRegistrations);


*Adding eveything to adequate library and export;

%macro addAndExportRC(lib=SDTJAN23, data=, dataLabel=);
    
    data &lib..&data.(label = "&dataLabel.");
        set &data.;
    run;
    
    proc export
        data=&lib..&data.
        dbms=xlsx
        outfile="/home/u63028660/sasuser.v94/&data..xlsx"
        replace;
    run;
    
%mend addAndExportRC;

%addAndExportRC(data = roleCountsThursdayNight, dataLabel = Role Count Thursday Welcome Milonga);
%addAndExportRC(data = roleCountsFridayNight, dataLabel = Role Count Friday Gran Milonga);
%addAndExportRC(data = roleCountsSaturdayDay, dataLabel = Role Count Saturday Daily Milonga);
%addAndExportRC(data = roleCountsSaturdayNight, dataLabel = Role Count Saturday Gran Milonga);
%addAndExportRC(data = roleCountsSundayDay, dataLabel = Role Count Sunday Daily Milonga);
%addAndExportRC(data = roleCountsSundayNight, dataLabel = Role Count Sunday Gran Milonga);
%addAndExportRC(data = roleCountsMondayNight, dataLabel = Role Count Monday Goodbye Milonga);
%addAndExportRC(data = roleCountsWs1, dataLabel = Role Count Workshop 1);
%addAndExportRC(data = roleCountsWs2, dataLabel = Role Count Workshop 2);
%addAndExportRC(data = roleCountsWs3, dataLabel = Role Count Workshop 3);
%addAndExportRC(data = roleCountsWs4, dataLabel = Role Count Workshop 4);
%addAndExportRC(data = roleCountsAllRegistrations, dataLabel = Total Role Count);

%macro addAndExport(lib=SDTJAN23, data=, dataLabel=);
    
    data &lib..&data.(label = "&dataLabel.");
        set &data.;
        drop danceRole;
        
        proc sort; by fullName;
    run;
    
    proc export
        data=&lib..&data.
        dbms=xlsx
        outfile="/home/u63028660/sasuser.v94/&data..xlsx"
        replace;
    run;
    
%mend addAndExport;

%addAndExport(data = thursdayNight, dataLabel = Thursday Welcome Milonga);
%addAndExport(data = fridayNight, dataLabel = Friday Gran Milonga);
%addAndExport(data = saturdayDay, dataLabel = Saturday Daily Milonga);
%addAndExport(data = saturdayNight, dataLabel = Saturday Gran Milonga);
%addAndExport(data = sundayDay, dataLabel = Sunday Daily Milonga);
%addAndExport(data = sundayNight, dataLabel = Sunday Gran Milonga);
%addAndExport(data = mondayNight, dataLabel = Monday Goodbye Milonga);
%addAndExport(data = ws1, dataLabel = Workshop 1);
%addAndExport(data = ws2, dataLabel = Workshop 2);
%addAndExport(data = ws3, dataLabel = Workshop 3);
%addAndExport(data = ws4, dataLabel = Workshop 4);
%addAndExport(data = allRegistrations, dataLabel = All Registrations);
