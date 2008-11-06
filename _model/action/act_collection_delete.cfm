<cfif attributes.takeaction eq true>
	
	<cfset collection_ID = attributes.strCollectionName>


	<!--- DELETE ASSOCIATED TASKS --->
	<cftry>
		<cfquery name = "qry_collection_tasks" datasource = "#dsn#">
		    select strTask
		      from tblSchedules
		     where collection_id = '#collection_ID#'
		</cfquery>
	
		<cfif qry_collection_tasks.recordcount>
			<cfloop query = "qry_collection_tasks">
				<cfschedule action="delete" task = "#strTask#">
			</cfloop>
		</cfif>
	<cfcatch>Error Deleting Task</cfcatch>
	
	</cftry>




	<!--- DELETE COLLECTION FROM COLDFUSION --->	
	<cftry>		
		<cfquery name = "qry_collection_list" datasource = "#dsn#">
		    select strCollectionName, strCollectionPath
		      from tblCollections
		     where collection_id = '#collection_id#'
		</cfquery>
	
		<cfset strCollectionName = qry_collection_list.strCollectionName>
	
		<cfcollection 	action = "delete"
						collection = "#qry_collection_list.strCollectionName#"
						path = "#qry_collection_list.strCollectionPath#"
						language = "English">

		<cfcatch>Error Deleting Collection</cfcatch>
	</cftry>
	
	
	
	<!--- DELETE COLLECTION FROM DATABASE --->
	<cftry>	
		<cfquery name = "qry_directories_delete" datasource = "#dsn#">
			delete from tblDirectories
		     where collection_ID = '#collection_ID#'
		</cfquery>
	
		<cfcatch>Error Deleting Directory Record</cfcatch>
	</cftry>
	
	
	
	<!--- DELETE COLLECTION FROM DATABASE --->
	<cftry>	
		<cfquery name = "qry_collection_delete" datasource = "#dsn#">
			delete from tblCollections
		     where collection_ID = '#collection_ID#'
		</cfquery>
	
		<cfcatch>Error Deleting Collection Record</cfcatch>
	</cftry>
			
</cfif>