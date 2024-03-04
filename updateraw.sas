%let lib = sdtjan23;
%let data = raw;

data rawRenamed;
    length phone_number $40;
    set &lib..&data.;
    
    length regID 8.;
    regID = _n_;
    
    rename Timestamp = regDateTime
           email_address = email
           first_name = firstName
           last_name = lastName
           city = city
           country = country
           dance_role = danceRole
           phone_number = phone
           if_you_are_registering_with_a_pa = partnerName
           /*full_festival_pass_early_bird__*/var10 = festivalPass
           milongas____early_bird___regular = milongas
           workshops___early_bird___regular = workshops
           if_you_are_registering_through_a = promoterName
           place_for_any_questions__wishes = comment
           ;
run;

data rawHardcoded;
    set rawRenamed;
    
    length uniquePID note $200;
    call missing(note);
    uniquePID = strip(firstName) || strip(lastName) || "-" || strip(email);
    
    milongas = prxchange('s/\"//',-1,milongas);
    workshops = prxchange('s/\"//',-1,workshops);
    
    ***HARDCODE CHANGES HERE***;
    if index(phone, "E") > 0 then do;
        phone = "INVALID NUMBER";
    end;
    
    if regID in (4, 22, 33, 74, 77, 142) then do;
        put "WARNING: Person with unique ID: " uniquePID " was removed from dataset";
        delete;
    end;
    
    if regID in (29, 30) then do;
        put "WARNING: Person with unique ID: " uniquePID " has had FESTIVAL PASS changed to MILONGA PASS";
        festivalPass = "NO";
        milongas = "FULL MILONGA PASS";
    end;
    
    
    
    if regID in (134, 135, 136) then do;
        regDateTime = .;
    end;
    
    proc sort; by uniquePID regID;
run;

data paidInfo;
    set &lib..&dataPaid.(keep=first_name last_name city iznos);
    
    rename first_name = firstName
           last_name = lastName
           city = city
           iznos = ammountPaid
           ;

	proc sort nodupkey dupout=paymentDuplicates; by firstName lastName city ammountPaid;
run;

proc sort data=rawHardcoded out=rawSorted;
    by firstName lastName city;
run;

data rawAdded;
    merge rawSorted(in=inraw) paidInfo;
    by firstName lastName city;
    if inraw;
    
    proc sort; by uniquePID regID;
run;

proc sql;
    create table regCount as
    select uniquePID, count(*) as regCount
    from rawAdded
    group by uniquePID
    order by uniquePID
    ;
quit;

data noDuplicates;
    merge rawAdded regCount;
    by uniquePID;
    
    if last.uniquePID then output;
    else if regCount > 1 then put "WARNING: Person with unique ID: " uniquePID " has an outdated
        registration with record number: " regID " and date/time: " regDateTime;
run;

data &lib..rawUpdated;
    set noDuplicates;
run;
