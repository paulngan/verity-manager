<cfsetting enablecfoutputonly="true" />
<cfprocessingdirective pageencoding="utf-8" />
<!--- circuit: app --->
<!--- fuseaction: search --->
<cftry>
<cfset myFusebox.thisPhase = "appinit">
<cfset myFusebox.thisCircuit = "app">
<cfset myFusebox.thisFuseaction = "search">
<cfif myFusebox.applicationStart>
	<cfif not myFusebox.getApplication().applicationStarted>
		<cflock name="#application.ApplicationName#_fusebox_#FUSEBOX_APPLICATION_KEY#_appinit" type="exclusive" timeout="30">
			<cfif not myFusebox.getApplication().applicationStarted>
<!--- fuseaction action="m.initialize" --->
<cfset myFusebox.thisCircuit = "m">
<cfset myFusebox.thisFuseaction = "initialize">
<cfset myFusebox.getApplication().getApplicationData().startTime = "#now()#" />
<cfset myFusebox.thisCircuit = "app">
<cfset myFusebox.thisFuseaction = "search">
				<cfset myFusebox.getApplication().applicationStarted = true />
			</cfif>
		</cflock>
	</cfif>
</cfif>
<!--- do action="m.collection_search" --->
<cfset myFusebox.thisPhase = "requestedFuseaction">
<cfset myFusebox.thisCircuit = "m">
<cfset myFusebox.thisFuseaction = "collection_search">
<cftry>
<cfoutput><cfinclude template="../../_model/query/qry_collection_search.cfm"></cfoutput>
<cfcatch type="missingInclude"><cfif len(cfcatch.MissingFileName) gte 31 and right(cfcatch.MissingFileName,31) is "query/qry_collection_search.cfm">
<cfthrow type="fusebox.missingFuse" message="missing Fuse" detail="You tried to include a fuse query/qry_collection_search.cfm in circuit m which does not exist (from fuseaction m.collection_search).">
<cfelse><cfrethrow></cfif></cfcatch></cftry>
<!--- do action="m.collection_list" --->
<cfset myFusebox.thisFuseaction = "collection_list">
<cftry>
<cfoutput><cfinclude template="../../_model/query/qry_collection_list.cfm"></cfoutput>
<cfcatch type="missingInclude"><cfif len(cfcatch.MissingFileName) gte 29 and right(cfcatch.MissingFileName,29) is "query/qry_collection_list.cfm">
<cfthrow type="fusebox.missingFuse" message="missing Fuse" detail="You tried to include a fuse query/qry_collection_list.cfm in circuit m which does not exist (from fuseaction m.collection_list).">
<cfelse><cfrethrow></cfif></cfcatch></cftry>
<!--- do action="v.collection_search" --->
<cfset myFusebox.thisCircuit = "v">
<cfset myFusebox.thisFuseaction = "collection_search">
<cftry>
<cfsavecontent variable="body"><cfoutput><cfinclude template="../../_view/dsp_collection_search.cfm"></cfoutput></cfsavecontent>
<cfcatch type="missingInclude"><cfif len(cfcatch.MissingFileName) gte 25 and right(cfcatch.MissingFileName,25) is "dsp_collection_search.cfm">
<cfthrow type="fusebox.missingFuse" message="missing Fuse" detail="You tried to include a fuse dsp_collection_search.cfm in circuit v which does not exist (from fuseaction v.collection_search).">
<cfelse><cfrethrow></cfif></cfcatch></cftry>
<cftry>
<cfoutput><cfinclude template="../../_view/lay_template.cfm"></cfoutput>
<cfcatch type="missingInclude"><cfif len(cfcatch.MissingFileName) gte 16 and right(cfcatch.MissingFileName,16) is "lay_template.cfm">
<cfthrow type="fusebox.missingFuse" message="missing Fuse" detail="You tried to include a fuse lay_template.cfm in circuit v which does not exist (from fuseaction v.$postfuseaction).">
<cfelse><cfrethrow></cfif></cfcatch></cftry>
<cfcatch><cfrethrow></cfcatch>
</cftry>
<cfsetting enablecfoutputonly="false" />

