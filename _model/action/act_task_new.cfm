<cfoutput>
<cfif attributes.takeaction eq 'true'>
	
	<cfquery name = "qry_get_collection_name" datasource = "#dsn#">
	    select strCollectionName
	      from tblCollections
	     where collection_ID = '#attributes.collection_ID#'
	</cfquery>
	
	<cfset strCollectionName = qry_get_collection_name.strCollectionName>
		
	<!--- SET THE PARAMETERS INCASE SOMETHING IS MISSING --->
	<cfparam name="attributes.strTask" type="string" default="">
	<cfparam name="attributes.collection_ID" type="string" default="">
	<cfparam name="attributes.dtStartDate" type="string" default="">
	<cfparam name="attributes.dtEndDate" type="string" default="">
	<cfparam name="attributes.dtStartTimeOnce" type="string" default="">
	<cfparam name="attributes.strScheduleType" type="string" default="">
	<cfparam name="attributes.strInterval" type="string" default="">
	<cfparam name="attributes.dtStartTimeDWM" type="string" default="">
	<cfparam name="attributes.intIntervalOther" type="string" default="">
	<cfparam name="attributes.dtStartTimeCustom" type="string" default="">
	<cfparam name="attributes.dtEndTimeCustom" type="string" default="">
	<cfparam name="attributes.strOperation" type="string" default="">
	<cfparam name="attributes.intPort" type="string" default="">
	<cfparam name="attributes.strScheduledURL" type="string" default="">
	<cfparam name="attributes.strUsername" type="string" default="">
	<cfparam name="attributes.strPassword" type="string" default="">
	<cfparam name="attributes.intRequestTimeout" type="string" default="">
	<cfparam name="attributes.strProxyServer" type="string" default="">
	<cfparam name="attributes.intProxyPort" type="string" default="">
	<cfparam name="attributes.chkPublish" type="string" default="">
	<cfparam name="attributes.strPath" type="string" default="">
	<cfparam name="attributes.strFile" type="string" default="">
	<cfparam name="attributes.chkResolveURL" type="string" default="">
	
	<!--- CHANGE THE 'CUSTOM' OPTION TO THE SECONDS THE USER CHOSE --->
	<cfif attributes.strInterval eq 'Custom'>
		<cfset attributes.strInterval = attributes.intIntervalOther>
	</cfif>	

	<!--- INSERT SCHEDULE INFORMATION IN THE DATABASE --->
	<cfquery name = "qry_add_scheduled_task" datasource = "#dsn#">
		INSERT INTO tblSchedules
				(	strTask,
					collection_ID,
					dtStartDate,
					dtEndDate,
					dtStartTimeOnce,
					strScheduleType,
					strInterval,
					dtStartTimeDWM,	
					intIntervalOther,
					dtStartTimeCustom,
					dtEndTimeCustom,
					strOperation,
					intPort,
					strScheduledURL,
					strUsername,
					strPassword,
					intRequestTimeout,
					strProxyServer,
					intProxyPort,
					chkPublish,
					strPath,
					strFile,
					chkResolveURL,
					strServer
				)
		     VALUES (
					'#attributes.strTask#',
					'#collection_ID#',
					'#attributes.dtStartDate#',
					'#attributes.dtEndDate#',
					'#attributes.dtStartTimeOnce#',
					'#attributes.strScheduleType#',
					'#attributes.strInterval#',
					'#attributes.dtStartTimeDWM#',
					'#attributes.intIntervalOther#',
					'#attributes.dtStartTimeCustom#',
					'#attributes.dtEndTimeCustom#',
					'#attributes.strOperation#',
					'#attributes.intPort#',
					'#ScheduledTaskURL##collection_ID#',
					'#attributes.strUsername#',
					'#attributes.strPassword#',
					'#attributes.intRequestTimeout#',
					'#attributes.strProxyServer#',
					'#attributes.intProxyPort#',
					'#attributes.chkPublish#',
					'#attributes.strPath#',
					'#attributes.strFile#',
					'#attributes.chkResolveURL#',
					'#strServer#')
	</cfquery>




	<!--- GRAB SCHEDULE INFORMATION FROM THE DATABASE --->
	<cfquery name = "qry_get_task" datasource = "#dsn#">
	    select *
	      from tblSchedules
	     where strTask = '#attributes.strTask#' AND strServer = '#strServer#'
	</cfquery>


		<cfset strTask = "#qry_get_task.strTask#">
		<cfset collection_ID = "#qry_get_task.collection_ID#">
		<cfset dtStartDate = "#qry_get_task.dtStartDate#">
		<cfset dtEndDate = "#qry_get_task.dtEndDate#">
		<cfset dtStartTimeOnce = "#qry_get_task.dtStartTimeOnce#">
		<cfset strScheduleType = "#qry_get_task.strScheduleType#">
		<cfset strInterval = "#qry_get_task.strInterval#">
		<cfset dtStartTimeDWM = "#qry_get_task.dtStartTimeDWM#">
		<cfset intIntervalOther = "#qry_get_task.intIntervalOther#">
		<cfset dtStartTimeCustom = "#qry_get_task.dtStartTimeCustom#">
		<cfset dtEndTimeCustom = "#qry_get_task.dtEndTimeCustom#">
		<cfset strOperation = "#qry_get_task.strOperation#">
		<cfset intPort = "#qry_get_task.intPort#">
		<cfset strScheduledURL = "#qry_get_task.strScheduledURL#">
		<cfset strUsername = "#qry_get_task.strUsername#">
		<cfset strPassword = "#qry_get_task.strPassword#">
		<cfset intRequestTimeout = "#qry_get_task.intRequestTimeout#">
		<cfset strProxyServer = "#qry_get_task.strProxyServer#">
		<cfset intProxyPort = "#qry_get_task.intProxyPort#">
		<cfset chkPublish = "#qry_get_task.chkPublish#">
		<cfset strPath = "#qry_get_task.strPath#">
		<cfset strFile = "#qry_get_task.strFile#">
		<cfset chkResolveURL = "#qry_get_task.chkResolveURL#">
		
		
	<!--- RUN THE CFSCHEDULE TAG --->

	<cfschedule action = "update"
				task = "#strTask#"
				operation = "HTTPRequest"
				startDate = "#dtStartDate#"
				startTime = "#dtStartTimeDWM#"
				url = "#strScheduledURL#"
				endDate = "#dtEndDate#"
				endTime = "#dtEndTimeCustom#"
				interval = "#strInterval#"
				requestTimeOut = "1200"
				username = "#strUsername#"
				password = "#strPassword#">
</cfif>
</cfoutput>