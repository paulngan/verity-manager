	
	<!--- ########################################################## --->
	
	<!--- ENVIRONMENT VARIABLES --->
	<cfset request.dsn = "Verity_MGR_SQL">																					<!--- SET DEFAULT DATASOURCE --->
	<cfset dsn = "Verity_MGR_SQL">
	<cfset strServer = "Net1">																							<!--- SET DEFAULT DATASOURCE --->
	<cfset defaultCollectionPath = "C:\inetpub\wwwroot\">																	<!--- SET DEFAULT SITE ROOT ---><!--- 
	<cfset DefaultVerityFolder = 'c:\CFusionMX7\verity\collections'>														<!--- SET SERVER ENVIRONMENT DEFAULTS ---> --->
	<cfset DefaultVerityFolder = 'c:\ColdFusion8\verity\collections'>														<!--- SET SERVER ENVIRONMENT DEFAULTS --->
	<cfset ScheduledTaskURL = 'http://net1.ags.com/verity/index.cfm?fuseaction=app.autoindex&takeaction=true&collection_ID='>	<!--- DEFAULT PATH FOR THE SCHEDULED TASK URL --->		
	<cfset ApplicationRequestTimeout = "1800">


	<!--- ########################################################## --->





	
	
   	<!--- 
	THE TAKEACTION VARIABLE CONTROLS THE CODE FLOW IN THE APPLICATION 
	CIRCUIT (_control/circuit.xml) I USE THIS IN THE FORM ACTION MUCH 
	THE SAME AS YOU WOULD A HIDDEN FUSEACTION IN A FORM INSTEAD OF 
	CREATING A NEW FUSEACTION, I HAVE THE FORM CALL THE ORIGINAL 
	FUSEACTION BUT THEN I ADD A XML IF STATEMENT THAT LOOKS FOR THE 
	TAKACTION VARIABLE IF THE FORM IS BEING VISITED THE FIRST TIME, 
	THE TAKEACTION VARIABLE IS FALSE BY DEFAULT WHEN THE FORM IS
	SUBMITTED THE TAKEACTION VARIABLE IS SET TO TRUE WHEN THE 
	FUSEACTION IS CALLED IN THE CIRCUIT, FUSEBOX SEES THE TAKEACTION 
	AS TRUE IT THEN FOLLOWS THE TAKEACTION IS TRUE PATH IN THE IF 
	STATEMENT 
    --->

	<cfparam name="attributes.takeaction" type="string" default="false">
	<cfparam name="true" type="string" default="true">

	<!--- 
	IN THE lay_template.cfm THERE ARE 2 VARIABLES THAT ARE PLACED IN THE BODY SECTION OF THE PAGE
	THE FIRST IS THE BODY, ANY CONTENT THAT IS BEING CALLED TO FILL THE PAGE, LIKE DSP_ FILES
	THE SECOND IS THE RESULTS VARIABLE WHICH HOLDS ANY CONTENT BEING DYNAMICALLY ADDED TO THE PAGE
	LIKE SEARCH RESULTS OR MESSAGES. --->
		
	<cfparam name="body" type="string" default="">
	<cfparam name="results" type="string" default="">
		

	<cfset mark_check = '&##x2713'>
	<cfset mark_x = '&##215;'>
			
	<cfif FindNoCase("MSIE 7", CGI.HTTP_USER_AGENT)>
		<cfset mark_check = 'o'>
		<cfset mark_x = '&oslash;'>
	</cfif>

		

