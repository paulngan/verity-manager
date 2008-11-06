<cfif attributes.takeaction eq true>
	
	<cfsetting requestTimeOut = '60'>
		
	<cfquery name = "qry_collection_list" datasource = "#dsn#">
	    select *
	      from tblCollections
	     where collection_ID = '#attributes.collection_ID#'
	</cfquery>

	<cfindex action="purge" 
			 collection="#qry_collection_list.strCollectionName#" 
			 key="#qry_collection_list.strCollectionPath#" 
			 type="PATH" 
			 urlpath="#qry_collection_list.strCollectionRetUrl#" 
			 extensions="#qry_collection_list.strCollectionFileExt#" 
			 recurse="Yes"
			 status = "purgeStatus">
			
	<cfquery name = "qry_update_collection_status" datasource = "#dsn#">
		update tblCollections
		   set intCollectionState = 4
		 where collection_ID = '#attributes.collection_ID#'
	</cfquery>
	
</cfif>