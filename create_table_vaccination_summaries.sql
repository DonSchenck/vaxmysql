USE vaxdb;
GO
CREATE TABLE vaccination_summaries (
	location_code     char(  2 ),
	reporting_date    char( 10 ),
	vaccination_count int,
	PRIMARY KEY ( location_code, reporting_date )
);
GO