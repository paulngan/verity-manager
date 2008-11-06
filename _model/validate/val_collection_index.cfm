<cfoutput>
	<cfif attributes.takeaction eq true>
		<cfif attributes.collection_id eq 'none'>
			<cfset error = true>
			<cfset attributes.takeaction = false>
			<cfset StructDelete(attributes, 'collection_id')>
		</cfif>
	</cfif>
</cfoutput>