<cfoutput>
	<cfquery name = "qry_collection_list" datasource = "#dsn#">
	    select *
	      from tblCollections
		 where strServer = '#strServer#'
	  order by strCollectionName
	</cfquery>
</cfoutput>