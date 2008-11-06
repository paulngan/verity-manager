<cfsetting enablecfoutputonly="true" />
<cfprocessingdirective pageencoding="utf-8" />
<!--- circuit: app --->
<!--- fuseaction: task --->
<cftry>
<cfset myFusebox.thisPhase = "appinit">
<cfset myFusebox.thisCircuit = "app">
<cfset myFusebox.thisFuseaction = "task">
<cfif myFusebox.applicationStart>
	<cfif not myFusebox.getApplication().applicationStarted>
		<cflock name="#application.ApplicationName#_fusebox_#FUSEBOX_APPLICATION_KEY#_appinit" type="exclusive" timeout="30">
			<cfif not myFusebox.getApplication().applicationStarted>
<!--- fuseaction action="m.initialize" --->
<cfset myFusebox.thisCircuit = "m">
<cfset myFusebox.thisFuseaction = "initialize">
<cfset myFusebox.getApplication().getApplicationData().startTime = "#now()#" />
<cfset myFusebox.thisCircuit = "app">
<cfset myFusebox.thisFuseaction = "task">
				<cfset myFusebox.getApplication().applicationStarted = true />
			</cfif>
		</cflock>
	</cfif>
</cfif>
<!--- do action="m.task_new" --->
<cfset myFusebox.thisPhase = "requestedFuseaction">
<cfset myFusebox.thisCircuit = "m">
<cfset myFusebox.thisFuseaction = "task_new">
<cftry>
<cfoutput><cfinclude template="../../_model/query/qry_collection_list.cfm"></cfoutput>
<cfcatch type="missingInclude"><cfif len(cfcatch.MissingFileName) gte 29 and right(cfcatch.MissingFileName,29) is "query/qry_collection_list.cfm">
<cfthrow type="fusebox.missingFuse" message="missing Fuse" detail="You tried to include a fuse query/qry_collection_list.cfm in circuit m which does not exist (from fuseaction m.task_new).">
<cfelse><cfrethrow></cfif></cfcatch></cftry>
<cftry>
<cfoutput><cfinclude template="../../_model/validate/val_task_new.cfm"></cfoutput>
<cfcatch type="missingInclude"><cfif len(cfcatch.MissingFileName) gte 25 and right(cfcatch.MissingFileName,25) is "validate/val_task_new.cfm">
<cfthrow type="fusebox.missingFuse" message="missing Fuse" detail="You tried to include a fuse validate/val_task_new.cfm in circuit m which does not exist (from fuseaction m.task_new).">
<cfelse><cfrethrow></cfif></cfcatch></cftry>
<cftry>
<cfoutput><cfinclude template="../../_model/action/act_task_new.cfm"></cfoutput>
<cfcatch type="missingInclude"><cfif len(cfcatch.MissingFileName) gte 23 and right(cfcatch.MissingFileName,23) is "action/act_task_new.cfm">
<cfthrow type="fusebox.missingFuse" message="missing Fuse" detail="You tried to include a fuse action/act_task_new.cfm in circuit m which does not exist (from fuseaction m.task_new).">
<cfelse><cfrethrow></cfif></cfcatch></cftry>
<!--- do action="v.task_new" --->
<cfset myFusebox.thisCircuit = "v">
<cftry>
<cfsavecontent variable="body"><cfoutput><cfinclude template="../../_view/dsp_task_new.cfm"></cfoutput></cfsavecontent>
<cfcatch type="missingInclude"><cfif len(cfcatch.MissingFileName) gte 16 and right(cfcatch.MissingFileName,16) is "dsp_task_new.cfm">
<cfthrow type="fusebox.missingFuse" message="missing Fuse" detail="You tried to include a fuse dsp_task_new.cfm in circuit v which does not exist (from fuseaction v.task_new).">
<cfelse><cfrethrow></cfif></cfcatch></cftry>
<cftry>
<cfoutput><cfinclude template="../../_view/lay_template.cfm"></cfoutput>
<cfcatch type="missingInclude"><cfif len(cfcatch.MissingFileName) gte 16 and right(cfcatch.MissingFileName,16) is "lay_template.cfm">
<cfthrow type="fusebox.missingFuse" message="missing Fuse" detail="You tried to include a fuse lay_template.cfm in circuit v which does not exist (from fuseaction v.$postfuseaction).">
<cfelse><cfrethrow></cfif></cfcatch></cftry>
<cfcatch><cfrethrow></cfcatch>
</cftry>
<cfsetting enablecfoutputonly="false" />

