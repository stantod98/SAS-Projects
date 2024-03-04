/* Generated Code (IMPORT) */
/* Source File: TestSpreadsheet.xlsx */
/* Source Path: /home/u63028660/sasuser.v94 */
/* Code generated on: 1/7/23, 10:15 AM */

%let lib = SDTJAN23;
%let dataRaw = RAW;
%let dataPaid = PAID;

%web_drop_table(&lib..&dataRaw.);


FILENAME REFFILE '/home/u63028660/sasuser.v94/SdT_Jan23_responses.xlsx';

OPTIONS VALIDVARNAME=V7;

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=&lib..&dataRaw.;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=&lib..&dataRaw.; RUN;


%web_open_table(&lib..&dataRaw.);


*IMPORT ADDITIONAL INFO*;

%web_drop_table(&lib..&dataPaid.);


FILENAME REFFILE '/home/u63028660/sasuser.v94/SdT_Jan23_paidInfo.xlsx';

OPTIONS VALIDVARNAME=V7;

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=&lib..&dataPaid.;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=&lib..&dataPaid.; RUN;


%web_open_table(&lib..&dataPaid.);
