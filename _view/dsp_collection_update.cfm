<cfoutput>
	
	<!--- SET CLASS ATTRIBUTES FOR PAGE TEMPLATE --->
	<cfset TopNavCollections = "on">
	<cfset SubNavCollections = "on">
	<cfset SubNavUpdate = "on">
	
	<!--- SET CLASS ATTRIBUTES --->
	<cfparam name="classStrCollectionName" type="string" default="valid">
	<cfparam name="classstrCollectionPath" default="valid">
	<cfparam name="classstrCollectionRetUrl" default="valid">

	<!--- FORM VARIABLES --->
	<cfparam name="attributes.strcollectionName" type="string" default="">
	<cfparam name="attributes.strcollectionPath" type="string" default="#defaultCollectionPath#">
	<cfparam name="attributes.strcollectionRetURL" type="string" default="">
	<cfparam name="attributes.strcollectionFileExt" type="string" default="">
	<cfparam name="attributes.strExcludedDirectories" type="string" default="">

	<cfset strcollectionName = attributes.strcollectionName>	
	<cfset strcollectionPath = attributes.strcollectionPath>
	<cfset strcollectionRetURL = attributes.strcollectionRetURL>	
	<cfset strcollectionFileExt = attributes.strcollectionFileExt>
	<cfset strExcludedDirectories = attributes.strExcludedDirectories>
	
	<cfparam name="check" type="string" default="off">
	<cfif attributes.takeaction eq true>
		<cfset check = 'check'>
	</cfif>
	
	<!---
	////////////////////////////////////////////////////////////////////////////////////
	
		GET COLLECTION VARIABLES FOR THE SUBMITTED COLLECTIONTOUPDATE VARIABLE BELOW 
		
	//////////////////////////////////////////////////////////////////////////////////// --->
	
	
	
	<cfif IsDefined('attributes.CollectionToUpdate')>
		
		<cfquery name = "Collection" datasource = "#dsn#">
		    select *
		      from tblCollections
		     where collection_ID = #attributes.CollectionToUpdate#
		</cfquery>
	
	</cfif>
	
	<cfif attributes.takeaction eq 'true' OR isDefined('attributes.collection_ID')>
		
		<cfquery name = "Collection" datasource = "#dsn#">
		    select *
		      from tblCollections
		     where collection_ID = #attributes.collection_ID#
		</cfquery>
	
	</cfif>

		<cfparam name="collection.collection_ID" default="">
		<cfparam name="collection.strCollectionName" default="">
		<cfparam name="collection.strCollectionPath" default="">
		<cfparam name="collection.strCollectionRetUrl" default="">
		<cfparam name="collection.strCollectionFileExt" default="">
		<cfparam name="collection.strExcludedDirectories" default="">



	<!---
	/////////////////////////////////////////////////////////////////////////////////////////////////////////

	THIS FORM IS MADE UP OF 2 FORMS (ORDERED BY HOW YOU SEE IT IN THE CODE)
	
	1) COLLECTIONTOUPDATE -  USER CHOOSES A COLLECTION TO UPDATE / PAGE REFRESHES AUTOMATICALLY
	2) COLLECTION VARIABLES FORM -  THE VARIABLES FOR THE COLLECTION ARE DISPLAYED AND USER IS ABLE TO EDIT THEN SUBMIT
	

	////////////////////////////////////////////////////////////////////////////////////////////////////////// --->


			

		
		
		<!---	/////////////////////////////////////////////////////
			
										SECTION 1 
					
				///////////////////////////////////////////////////// --->
		
		
		<cfquery name = "qry_collection_list" datasource = "#dsn#">
		    select strCollectionName, collection_ID
		      from tblCollections
		     where strServer = '#strServer#'
		  order by strCollectionName
		     
		</cfquery>
		

		<form name = "ChooseCollection" action = "index.cfm" method = "post" format = "flash" width="290" height="130">
	
			<input name = "fuseaction" 
					 type = "hidden"
					 value = "app.update"
					 class="hidden"> 
		
	
			<!--- DISPLAY DROP DOWN WITH ALL COLLECTIONS --->	
			<label for="CollectionToUpdate"/>Collection</label>	
			<select class="valid" name="CollectionToUpdate">
				
				<cfif IsDefined('attributes.CollectionToUpdate')>
					<option value="#attributes.CollectionToUpdate#">#collection.strCollectionName#</option>
				<cfelse>
					<option value="none"></option>
				</cfif>
				<cfloop query = "qry_collection_list">
					<option value="#collection_ID#">#strCollectionName#</option>
				</cfloop>
			</select>
			
	
		
			<input type="submit" 
					 name="submit" 
					 value="Refresh Page"
					 class="submit">
	
		</form>
	
		
		
		<br />

		<!---	/////////////////////////////////////////////////////
			
										SECTION 2
					
				///////////////////////////////////////////////////// --->	
		
			

		<form name = "newcollection" action = "index.cfm" method = "post">

			<input class="hidden"
	 	 	 			 type="hidden" 
					 name="fuseaction" 
					 value="app.update">

			<input class="hidden"
					 type="hidden"
					 name="takeaction"
					 value="true">
					
			<input class = "hidden"
					 type = "hidden"
					 name = "collection_ID"
					 value = "#collection.collection_ID#">
					
			
			<sub class="#check#">#mark_check# Successfully Updated</sub>
			<label for="strCollectionName"/>Name</label>
			<input name = "strCollectionName" 
					 type = "text"
					readonly = "readonly"
					 value = "#collection.strcollectionName#"
					 class="#classStrCollectionName#">

			<sub class="#check#">#mark_check# Successfully Updated</sub>
			<label for="strCollectionPath"/>Path</label>
			<input name = "strCollectionPath" 
					 type = "text"
					 value = "#collection.strCollectionPath#"
					 class="#classStrCollectionPath#"> 	
			<sub class="#classStrCollectionPath#">Define the collection's path</sub>

			<sub class="#check#">#mark_check# Successfully Updated</sub>
			<label for="strCollectionRetUrl"/>Return URL</label>
			<input 	name = "strCollectionRetUrl" 
					type = "text"
					value = "#collection.strCollectionRetUrl#"
					class="#classstrCollectionRetUrl#">

			<sub class="#check#">#mark_check# Successfully Updated</sub>
			<label for="strCollectionFileExt"/>File Extensions (A,B,C)</label>
			<input 	name = "strCollectionFileExt" 
					type = "text"
					value = "#collection.strCollectionFileExt#"> 
			
			<cfif attributes.takeaction eq true>
				<sub class="#check#">#mark_check# Successfully Added</sub>
				<label for="strDirectories"/>Added Directories</label>
				<cfloop query = "qry_collection_directory_list">
					
					<cfset strDirectoryPathNew = Replace(strDirectoryPath, defaultCollectionPath, "", "ALL")>

					<input 	name = "strDirectories" 
						 	type = "text"
						 	value = "#strDirectoryPathNew#"
							readonly = "readonly"
							class="directories">
				</cfloop>
			</cfif>	
			<br />
			
			<sub class="#check#">#mark_check# Successfully Updated</sub>
			<label for="strExcludedDirectories"/>Excluded Directories (A,B,C)</label>
			<input name = "strExcludedDirectories" 
					 type = "text"
					 value = "#collection.strExcludedDirectories#"
					 size = "20"> 

			<cfif attributes.takeaction neq 'true'>
				<input class="submit"
						 type="submit" 
						 name="submit" 
						 value="Update Collection">
			</cfif>
			
			

		</form>

		<br />
		 <sub class="confirm" style="display:block">*Updating a collection does not reindex the collection</sub>

	
</fieldset>

	

</cfoutput>