<cfoutput>
	<cfif attributes.takeaction eq true>
		<cfif Len('attributes.collection_id') lte 1 >
			<cfset attributes.takeaction = false>
			<cfset StructDelete(attributes, 'collection_id')>
		</cfif>
	</cfif>
</cfoutput>