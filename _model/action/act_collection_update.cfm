<cfif attributes.takeaction eq true>

<cfoutput>

	<cfquery name = "qry_update_collection_variables" datasource = "#dsn#">

		update tblCollections
		
		set 	strCollectionPath = '#attributes.strCollectionPath#',
				strCollectionRetUrl = '#attributes.strCollectionRetUrl#',
				strCollectionFileExt = '#attributes.strCollectionFileExt#',
				strExcludedDirectories = '#attributes.strExcludedDirectories#',
				dDateCollectionLastIndexed = #createODBCdatetime(Now())#,
				intCollectionState = 3
			
		where collection_ID = '#attributes.collection_ID#'

	</cfquery>

</cfoutput>

</cfif>