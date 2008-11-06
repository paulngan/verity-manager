<cfif attributes.takeaction eq true>
	
	<cfif NOT isDefined('attributes.collection_ID')>
			
		<cfquery name = "qry_collection_ID" datasource = "#dsn#">
		    select collection_ID
		      from tblCollections
		     where strCollectionName = '#attributes.strCollectionName#' AND strServer = '#strServer#'
		</cfquery>
		
		<cfset attributes.collection_ID = qry_collection_ID.collection_ID>
			
	</cfif>
	
	<cfquery name = "qry_collection_list" datasource = "#dsn#">
	    select *
	      from tblCollections
		 where collection_ID = '#attributes.collection_ID#'
	</cfquery>

	<cfset collection_ID = qry_collection_list.collection_ID >
	<cfset strCollectionName = qry_collection_list.strCollectionName >
	<cfset strCollectionPath = qry_collection_list.strCollectionPath >
	<cfset strCollectionRetUrl = qry_collection_list.strCollectionRetUrl >
	<cfset strCollectionFileExt = qry_collection_list.strCollectionFileExt >
	<cfset strExcludedDirectories = qry_collection_list.strExcludedDirectories >


	<!--- 
	Get rid of leading/trailing spaces on each item in list.  If there are spaces, then the ListFindNoCase function below
	won't find the matches properly. - AGS(RH) - 9/24/07 --->
	<cfset strExcludedDirectories_trimmed = strExcludedDirectories>
	<cfloop index="list_item" list="#strExcludedDirectories#">
		<cfset strExcludedDirectories_trimmed = ListAppend(strExcludedDirectories_trimmed, Trim(list_item))>
	</cfloop>

	<!--- Reassign trimmed list back to original variable --->
	<cfset strExcludedDirectories = strExcludedDirectories_trimmed>


	<!--- BEGIN ACTION FILE --->


	<!--- Page timeout (seconds) --->
	<cfsetting requesttimeout="#ApplicationRequestTimeout#">

	<!--- Get all directories (and subdirectories recursively) in site --->
	<cfdirectory action="LIST" directory="#strCollectionPath#" name="qry_directories" recurse="yes">

	<!--- Filter query (which originally contains directories and files) to only contain directories --->
	<cfquery name="qry_directories" dbtype="query">
		select *
		from qry_directories
		where type = 'Dir'
	</cfquery>

	<!--- 
	Get directory name and parent directory path of the directory that is the root of this collection.  We need to manually
	add this to the query, b/c it won't show up automatically.  The query only shows what's inside our directory, not including
	the directory itself.  We still need to index that directory itself, though, so we're adding it manually.  Also, if there
	are no folders excluded, then there won't be anything in our query if we don't manually add this. - AGS(RH) - 8/3/07 --->
	<cfset CollectionRootDirectoryName = ListLast(strCollectionPath, "\")>
	<cfset CollectionRootDirectoryParent = ListDeleteAt(strCollectionPath, ListLen(strCollectionPath, "\"), "\")>

	<!--- Manually add the collection's root folder to query - AGS(RH) - 8/3/07 --->
	<cfset QueryAddRow(qry_directories)>
	<cfset QuerySetCell(qry_directories, "directory", CollectionRootDirectoryParent)>
	<cfset QuerySetCell(qry_directories, "name", CollectionRootDirectoryName)>

	<!--- 
	Create a new column in the query to store whether each directory should be indexed
	Also create a column that marks whether a column is the collection's root folder.  This will only be for the one we manually add
	as described above.  It's needed below when creating the return URL. --->
	<cfset aNewColumnData = ArrayNew(1)>											<!--- Array used to pre-populate new column --->
	<cfset ArraySet(aNewColumnData, 1, qry_directories.recordcount, 1)>				<!--- Fill array with default value of 1 for each record in query --->
	<cfset QueryAddColumn(qry_directories, "index", aNewColumnData)>				<!--- Create column and pre-populate using array --->
	<cfset ArraySet(aNewColumnData, 1, qry_directories.recordcount, 0)>				<!--- Fill array with default value of 1 for each record in query --->
	<cfset aNewColumnData[ArrayLen(aNewColumnData)] = 1>							<!--- Reset last position in array to 1; this is b/c the last item in the query should be the one we added manually, and that is the collection root --->
	<cfset QueryAddColumn(qry_directories, "is_collection_root", aNewColumnData)>	<!--- Create column and pre-populate using array --->

	<!--- Once we encounter a directory we are excluding, we don't want to look in its subdirectories.  This list will have added to it any directories being excluded so we can exclude their subdirectories as well --->
	<!--- VARIABLE WAS MOVED FROM HERE TO THE TOP OF THE FILE --->

	<!--- Loop over all directories --->
	<cfloop query="qry_directories">
		<!--- 
		If directory name is in exclusion list OR if the directory this subdirectory sits in has been added to the 'strExcludedDirectories' list,
		then mark it as not to be indexed. --->
		<cfif ListFindNoCase(strExcludedDirectories, name) OR
			  ListFindNoCase(strExcludedDirectories, directory)>
			<!--- Set 'index' column for this record to false --->
			<cfset QuerySetCell(qry_directories, "index", 0, currentrow)>
			<!--- Add this directory to list so we don't index its subdirectories --->
			<cfset strExcludedDirectories = ListAppend(strExcludedDirectories, directory & "\" & name)>
		</cfif>
	</cfloop>

	<!--- Filter query so we only have directories which should be indexed --->
	<cfquery name="qry_directories" dbtype="query">
		select *
		from qry_directories
		where index = 1
	</cfquery>


	
	<!--- Clear out any existing info in collection 
	<cfindex action="PURGE" collection="#strCollectionName#" status="">--->
		
	<cfquery name = "qry_delete_directories" datasource = "#dsn#">
		delete from tblDirectories
	     where collection_ID = '#attributes.collection_ID#'
	</cfquery>

	<!--- Loop over all directories to be indexed and add to collection --->
	<cfloop query="qry_directories">

		<!--- Store directory name and parent path in variables --->
		<cfset DirectoryName = name>
		<cfset DirectoryParentPath = directory>
		
		<!--- 
		If current directory is collection root, then change variable so the ReturnURL path below will be correct (if the directory path doesn't 
		have at least the strCollectionPath contained in it, then it won't replace correctly) --->
		<cfif (is_collection_root)>
			<cfset DirectoryName = "">
			<cfset DirectoryParentPath = directory & "\" & name>
		</cfif>

		<!--- Take site root path and convert into a web path we can add for the url path to the files in the directories --->
		<cfset WebPath = DirectoryParentPath>
		<cfset WebPath = Replace(WebPath, strCollectionPath, "", "ALL")>
		<cfset WebPath = Replace(WebPath, "\", "/", "ALL")>

		<!--- 
		Set return url 
		Updated to use strCollectionRetUrl as base path instead of cgi.server_name since the index is being run from the Verity Manager site - AGS(RH) - 9/24/07
		<cfset ReturnURL = "http://#cgi.server_name##WebPath#/#DirectoryName#"> --->
		<cfset ReturnURL = "#strCollectionRetUrl##WebPath#/#DirectoryName#">
				
		<cfquery name = "qry_insert_directories" datasource = "#dsn#">
			insert into tblDirectories(strDirectoryPath, collection_ID, strDirectoryReturnURL,strServer)
			values('#directory#\#name#','#collection_ID#','#ReturnURL#','#strServer#')
		</cfquery>

	</cfloop>
	

</cfif>