<!---
	- ADD COLLECTION TO DATABASE
	- RUN CFCOLLECTION TAG
	- ADD COLLECTION DIRECTORIES TO DATABASE
- --->
<cfoutput>
	<cfif attributes.takeaction eq true >
	
		<!--- ADD COLLECTION TO DATABASE --->
		<cfquery name = "qry_collection_add" datasource = "#dsn#">

			insert into tblCollections(	strCollectionName,
										strCollectionPath,
										strCollectionRetUrl,
										strCollectionFileExt,
										strExcludedDirectories,
										intCollectionState,
										strServer
									  )
					
			values(	'#attributes.strCollectionName#',
					'#attributes.strCollectionPath#',
					'#attributes.strCollectionRetUrl#',
					'#attributes.strCollectionFileExt#',
					'#attributes.strExcludedDirectories#',
					2,
					'#strServer#'
					)
		</cfquery>
		
		<cfif NOT attributes.collectionexists eq true>
			
			<!--- CREATE COLLECTION ---> 	
			<cfcollection action="CREATE" 
						  collection="#attributes.strCollectionName#" 
						  path="#DefaultVerityFolder#" 
						  language="English">

		</cfif>
	</cfif>
</cfoutput>