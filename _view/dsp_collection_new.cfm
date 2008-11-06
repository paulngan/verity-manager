<!--- SET CLASS ATTRIBUTES FOR PAGE TEMPLATE --->
<cfset TopNavCollections = "on">
<cfset SubNavCollections = "on">
<cfset SubNavAdd = "on">

<!--- SET CLASS ATTRIBUTES --->
<cfparam name="classStrCollectionName" type="string" default="valid">
<cfparam name="classstrCollectionPath" default="valid">
<cfparam name="classstrCollectionRetUrl" default="valid">
	
<!--- FORM VARIABLES --->
<cfparam name="attributes.strcollectionName" type="string" default="">
<cfparam name="attributes.strcollectionPath" type="string" default="#defaultCollectionPath#">
<cfparam name="attributes.strcollectionRetURL" type="string" default="http://">
<cfparam name="attributes.strcollectionFileExt" type="string" default="">
<cfparam name="attributes.strExcludedDirectories" type="string" default="">
<cfparam name="attributes.collectionexists" type="string" default="false">
	
<cfset strcollectionName = attributes.strcollectionName>	
<cfset strcollectionPath = attributes.strcollectionPath>
<cfset strcollectionRetURL = attributes.strcollectionRetURL>	
<cfset strcollectionFileExt = attributes.strcollectionFileExt>
<cfset strExcludedDirectories = attributes.strExcludedDirectories>

<cfparam name="check" type="string" default="off">
<cfif attributes.takeaction eq true>
	<cfset check = 'check'>
</cfif>


<cfoutput>
			<cfdirectory action="LIST" directory="#DefaultVerityFolder#" name="qry_all_collections">

			<form name = "registerCollection" action = "index.cfm" method = "post">

				<input 	name = "fuseaction" 
						type = "hidden"
						value = "app.new"
						class="hidden"> 
						
				<input 	type="hidden" 
						name="collectionexists" 
						value="true" 
						class="hidden">


				<!--- DISPLAY DROP DOWN WITH ALL COLLECTIONS --->	
				<label for="CollectionToUpdate"/>Unregistered Collections</label>	
				<select class="valid" name="strCollectionName">
					<cfif IsDefined('attributes.strCollectionName')>
						<option value="#attributes.strCollectionName#">#attributes.strCollectionName#</option>
					<cfelse>
						<option value="none"></option>
					</cfif>
					<cfloop query = "qry_all_collections">
						
						<cfquery name = "qry_existing_collection" datasource = "#dsn#">
						    select strCollectionName
						      from tblCollections
						     where strCollectionName = '#name#' AND strServer = '#strServer#'
						</cfquery>
						
						<cfif qry_existing_collection.recordcount eq 0>
							<option>#name#</option>
						</cfif>
						
					</cfloop>
				</select>



				<input type="submit" 
						 name="submit" 
						 value="Refresh Page"
						 class="submit">

			</form>



			<br />
	
	

			<form name = "newcollection" action = "index.cfm" method = "post">
				
				
				<!--- SETS THE input REQUIRED ATTRIBUTE TO YES OR NO --->

				<cfset required = "yes">			
				
				<!--- SET FUSEACTIONS AND SET TAKEACTION VARIABLE --->
				
				<input 	class="hidden"
 	 	 	 			type="hidden" 
						name="fuseaction" 
						value="app.new"
						class = "hidden">
				
				<input 	class="hidden"
						type="hidden"
						name="takeaction"
						value="true"
						class = "hidden">
						
				<input 	type="hidden" 
						name="collectionexists" 
						value="#attributes.collectionexists#"
						class="hidden">
				
				
				<sub class="#classStrCollectionName#">*Invalid collection name or this name is in use</sub>
				<sub class="#check#">#mark_check# Successfully <cfif attributes.collectionexists eq true>Registered<cfelse>Added</cfif></sub>
				<label for="strCollectionName"/>Collection Name</label>
				<input 	name = "strCollectionName" 
						type = "text"
						value = "#attributes.strcollectionName#"
						size = "20"
						class="#classStrCollectionName#">
				
				
				<sub class="#classStrCollectionPath#">*Define the collection's path</sub>
				<sub class="#check#">#mark_check# Successfully Added</sub>
				<label for="srCollectionPath"/>Path</label>
				<input name = "strCollectionPath" 
					 type = "text"
					 value = "#attributes.strCollectionPath#"
					 size = "20"
					 class="#classStrCollectionPath#"> 	
				
				
				<sub class="#classstrCollectionRetUrl#">*Define the return url</sub>
				<sub class="#check#">#mark_check# Successfully Added</sub>
				<label for="strCollectionRetUrl"/>Return URL</label>
 				<input name = "strCollectionRetUrl" 
						 type = "text"
						 value = "#attributes.strCollectionRetUrl#"
						 size = "20"
						 class="#classstrCollectionRetUrl#">
				
 				
				<sub class="#check#">#mark_check# Successfully Added</sub>
				<label for="strCollectionFileExt"/>File Extensions (A,B,C)</label>
 				<input name = "strCollectionFileExt" 
						 type = "text"
						 value = "#attributes.strCollectionFileExt#"
						 size = "20"> 
				
				
				<cfif attributes.takeaction eq true>
					<sub class="#check#">#mark_check# Successfully Added</sub>
					<label for="strDirectories"/>Added Directories</label>
					<cfloop query = "qry_collection_directory_list">
						<input 	name = "strDirectories" 
							 	type = "text"
							 	value = "#strDirectoryPath#"
								readonly = "readonly"
								class="directories">
					</cfloop>
				</cfif>
				
				<br />
				
				<sub class="#check#">#mark_check# Successfully Excluded</sub>
				<label for="strExcludedDirectories"/>Excluded Directories (A,B,C)</label>
				<input 	name = "strExcludedDirectories" 
					 	type = "text"
					 	value = "#attributes.strExcludedDirectories#">
	
					 
 						
				<cfif NOT attributes.takeaction eq true>
				<input class="submit"
						 type="submit" 
						 name="submit" 
						 value="Add Collection">
				<cfelse>		
					<label for="dateAdded"/>Date Added</label>
					<input 	name = "dateAdded" 
							type = "text"
							value = "#DateFormat(Now(), "mm/dd/yyyy")#&nbsp;#TimeFormat(Now(), "hh:mm:ss tt")#">	
				</cfif>
				
			</form>
 			
			<br />
			<sub class="confirm" style="display: block">*Collections are not automatically indexed</sub>
			
		
		

</cfoutput>