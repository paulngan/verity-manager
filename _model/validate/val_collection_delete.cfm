<cfoutput>
	<cfif attributes.takeaction eq true>
		<cfif attributes.strCollectionName eq 'none'>
			<cfset error = true>
			<cfset attributes.takeaction = false>
			<cfset StructDelete(attributes, 'strCollectionName')>
		</cfif>
	</cfif>
</cfoutput>