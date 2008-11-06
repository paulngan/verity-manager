<cfif attributes.takeaction eq true>

	<!--- IF INDEXING THROUGH THE UPDATE APPLICATION 
	<cfif isdefined('qry_update_collection_variables')>
	
		<cfset collection_ID = qry_update_collection_variables.collection_ID >
		<cfset strCollectionName = qry_update_collection_variables.strCollectionName >
		<cfset strCollectionPath = qry_update_collection_variables.strCollectionPath >
		<cfset strCollectionRetUrl = qry_update_collection_variables.strCollectionRetUrl >
		<cfset strCollectionFileExt = qry_update_collection_variables.strCollectionFileExt >
		<cfset strExcludedDirectories = qry_update_collection_variables.strExcludedDirectories >

	--->
	
	<cfquery name = "qry_collection_list" datasource = "#dsn#">
	    select *
	      from tblCollections
	     where collection_ID = '#attributes.collection_id#'
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


	<!--- ADD START TIME TO DATABASE --->
	<cfquery name = "qry_update_start_time" datasource = "#dsn#">
	    update tblCollections
	       set dDateLastIndexStarted = #createODBCdatetime(Now())#
	     where collection_ID = '#collection_ID#'
	</cfquery>


	<cfquery name = "qry_directories" datasource = "#dsn#">
	    select *
	      from tblDirectories
	     where collection_ID = '#collection_ID#'
	</cfquery>
	

	<!--- Page timeout (seconds) --->
	<cfsetting requesttimeout="#ApplicationRequestTimeout#">

	<!--- Clear out any existing info in collection --->
	<cfindex action="PURGE" collection="#strCollectionName#" status="">
		
	<!--- Loop over all directories to be indexed and add to collection --->
	<cfloop query="qry_directories">

		<!--- Store directory name and parent path in variables 
		<cfset DirectoryName = name>
		<cfset DirectoryParentPath = directory>
		--->
		<!--- 
		If current directory is collection root, then change variable so the ReturnURL path below will be correct (if the directory path doesn't 
		have at least the strCollectionPath contained in it, then it won't replace correctly) 
		<cfif (is_collection_root)>
			<cfset DirectoryName = "">
			<cfset DirectoryParentPath = directory & "\" & name>
		</cfif>
		--->
		<!--- Take site root path and convert into a web path we can add for the url path to the files in the directories 
		<cfset WebPath = DirectoryParentPath>
		<cfset WebPath = Replace(WebPath, strCollectionPath, "", "ALL")>
		<cfset WebPath = Replace(WebPath, "\", "/", "ALL")>
			--->
		<!--- 
		Set return url 
		Updated to use strCollectionRetUrl as base path instead of cgi.server_name since the index is being run from the Verity Manager site - AGS(RH) - 9/24/07
		<cfset ReturnURL = "http://#cgi.server_name##WebPath#/#DirectoryName#"> 
		<cfset ReturnURL = "#strCollectionRetUrl##WebPath#/#DirectoryName#">--->
	
		<!--- 
		Update collection with this directory in loop 
		Updated code to use ReturnURL variable - AGS(RH) - 9/24/07
		<cfindex action="Update" collection="#strCollectionName#" key="#directory#\#name#" type="PATH" urlpath="#strCollectionRetUrl#/#DirectoryName#" extensions="#strCollectionFileExt#" recurse="No">
		
		Added DirectoryExists() test before attempting to update collection with directory - AGS(RH) - 1/9/08 --->
		<cfif DirectoryExists(STRDIRECTORYPATH)>
			<cfindex action="Update" collection="#strCollectionName#" key="#STRDIRECTORYPATH#" type="PATH" urlpath="#strDirectoryReturnURL#" extensions="#strCollectionFileExt#" recurse="No"><!--- 
			
		Otherwise, delete directory from collection in tblDirectories so we don't continue to attempt in future - AGS(RH) - 1/9/08 --->
		<cfelse>
			<cfquery datasource = "#dsn#">
			    delete from tblDirectories	
			     where collection_ID = <cfqueryparam value="#collection_ID#" cfsqltype="CF_SQL_INTEGER">
				   and strDirectoryPath = <cfqueryparam value="#STRDIRECTORYPATH#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
		</cfif>
	</cfloop>

	<!--- ADD END TIME TO DATABASE --->
	<cfquery name = "qry_update_end_time" datasource = "#dsn#">
	    update tblCollections	
	       set 	dDateLastIndexFinished = #createODBCdatetime(Now())#,
				dDateCollectionLastIndexed = #createODBCdatetime(Now())#,
				intCollectionState = 1
	     where collection_ID = '#collection_ID#'
	</cfquery>
</cfif>