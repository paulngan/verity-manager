<cfset attributes.strCollectionName = 'Lehi_October_Testc'>

<cfquery name = "qry_collection_list" datasource = "#dsn#">
    select collection_ID
      from tblCollections
     where strCollectionName = '#attributes.strCollectionName#' AND strServer = '#strServer#'
</cfquery>

<cfset collection_ID = #qry_collection_list.collection_ID#>
	
<cfquery name = "qry_collection_directory_list" datasource = "#dsn#">
    select *
      from tblDirectories
	 where Collection_ID = '#collection_ID#'
</cfquery>

<cfloop query = "qry_collection_directory_list">
	
	<cfset strDirectoryPath = Replace(strDirectoryPath, defaultCollectionPath, "", "ALL")>

	<input 	name = "strDirectories" 
		 	    type = "text"
		 	    value = "#strDirectoryPath#"
			    readonly = "readonly"
			    class="directories">
</cfloop>