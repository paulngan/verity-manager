<cfoutput>
	<cfif attributes.takeaction eq 'true'>
		<cfif attributes.strTask neq 'none'>
			
			<cfschedule action="delete" task = "#attributes.strTask#">

			<cfquery name = "qry_task_delete" datasource = "#dsn#">
				delete from tblSchedules
			    where strTask = '#attributes.strTask#' AND strServer = '#strServer#'
			</cfquery>
			
		</cfif>
	</cfif>
</cfoutput>

