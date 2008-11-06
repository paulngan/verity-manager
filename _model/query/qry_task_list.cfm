<cfquery name = "qry_task_list" datasource = "#dsn#">
    select *
      from tblSchedules
		<cfif IsDefined('attributes.strtask')>
			where strTask = '#attributes.strTask#' AND strServer = '#strServer#'
		<cfelse>
		 	where strServer = '#strServer#'
		</cfif>
	order by strTask
</cfquery>

