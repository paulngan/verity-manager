<!--- SET CLASS ATTRIBUTES FOR PAGE TEMPLATE --->
<cfset TopNavSchedule = "on">
	
	<cfquery name = "qry_task_list" datasource = "#dsn#">
	    select *
	      from tblSchedules
		 where strServer = '#strServer#'
	  order by strTask
	</cfquery>

<cfoutput>
<div id="schedule">
	<div id="dashboard">
		<div id="vertical_container" >
			<strong>7 Day Forecast</strong><br /><br />
			
			<cfset listDays = 'Sunday,Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday,Monday,Tuesday,Wednesday,Thursday,Friday,Saturday'>
			<cfset listHours = '00:00,
								01:00,
								02:00,
								03:00,
								04:00,
								05:00,
								06:00,
								07:00,
								08:00,
								09:00,
								10:00,
								11:00,
								12:00,
								13:00,
								14:00,
								15:00,
								16:00,
								17:00,
								18:00,
								19:00,
								20:00,
								21:00,
								22:00,
								23:00'>
								
			<!--- CREATE LIST OF DAYS TO LOOP OVER --->
			<cfset newlistDays = '#listgetat(listdays, dayofweek(now()))#,
								  #listgetat(listdays, dayofweek(now())+1)#,
								  #listgetat(listdays, dayofweek(now())+2)#,
								  #listgetat(listdays, dayofweek(now())+3)#,
								  #listgetat(listdays, dayofweek(now())+4)#,
								  #listgetat(listdays, dayofweek(now())+5)#,
								  #listgetat(listdays, dayofweek(now())+6)#'>
								
			<!--- SET TODAY'S DATE || FOR GETTING TASKS FOR THEIR APPROPRIATE DAY --->
			<cfset today = now()>
										
			<cfloop index = "sDayName" list = "#newlistDays#" delimiters = ",">
				
				<h1 class="accordion_toggle"> 
					#sDayName#
				</h1>
				
				<div class="accordion_content">
					
					<table border="0" cellspacing="0" cellpadding="5" class="schedule">
						<tr style="background-color: ##e0e0e0;" valign="top" class="date"><th align="center" colspan="5">#dateformat(today, 'mmmm d, yyyy')#<br /><br /></th></tr>
						<tr style="background-color: ##f0f0f0;" class="titles">
							<td width="60" align="right"><strong>Time:</strong></td>
							<td width="50"></td>
							<td><strong>Task:</strong></td>
							<td></td>
							<td><strong>Interval:</strong></td>
						</tr>
						
						<!--- START ROW COUNTER || FOR ALTERNATE ROW HIGHLIGHTING --->
						<cfset row = 1>
								
								<!--- ########## BUILD QUERY ########## --->
								<cfquery name = "qry_get_task" datasource = "#dsn#">
								    select *
								      from tblSchedules
									 where strServer = '#strServer#'
								  order by dtStartTimeDWM
								     
								</cfquery>
								<!--- ################################# --->
								
						<cfloop index = "hour" list = "#listHours#" delimiters = ",">
							
								<!--- ########## THE SCHEDULE LOOP ########## --->
								<tr <cfif row eq 0>style="background-color: ##f6f6f6;"</cfif>> 		<!--- // THIS CONTROLS THE ALTERNATING ROW HIGHLIGHTING --->
									
									
									<!--- CELL 1 - LIST THE HOURS OF THE DAY AND BOLD THE CURRENT HOUR --->
									<td valign="top" align="right" class="hour">
										<cfif timeformat(today, 'h tt') eq timeformat(hour, 'h tt') AND dateformat(today, 'mm/dd') eq dateformat(now(), 'mm/dd')>
											<strong>#TimeFormat(hour, 'h:mm tt')#</strong>
										<cfelse>
											#TimeFormat(hour, 'h:mm tt')#
										</cfif>
									</td>
																		
									<td></td>
									
									
									<!--- <TD> 3 - LIST THE TASKS FOR THE HOUR --->
									
									<td align="left" class="task">
										<!--- LOOP OVER QUERY --->
										<cfloop query = "qry_get_task">

											<!--- ##### START FILTER BY INTERVAL:ONCE ##### --->
											<cfif strInterval eq 'once'>
												<!--- FILTER BY EXACT DATE --->
												<cfif dateformat(today, 'mm/dd') eq dateformat(dtStartDate, 'mm/dd')>
													<!--- FILTER BY HOUR --->
													<cfif timeformat(dtStartTimeDWM, 'h tt') eq timeformat(hour, 'h tt') >
														#timeformat(dtStartTimeDWM, 'h:mm')#&nbsp;&nbsp;&nbsp;<cfif len(timeformat(dtStartTimeDWM, 'h:mm')) eq 4>&nbsp;&nbsp;</cfif><strong>#strTask#</strong><br />
													</cfif>
												</cfif>
											</cfif>
											<!--- ##### END FILTER ##### --->
											
											
											
											<!--- ##### START FILTER BY INTERVAL:DAILY ##### --->
											<cfif strInterval eq 'daily'>
												<!--- FILTER BY EXACT DATE --->
												<cfif len(dtEndDate) eq 0>
													<!--- FILTER BY HOUR --->
													<cfif timeformat(dtStartTimeDWM, 'h tt') eq timeformat(hour, 'h tt') >
														#timeformat(dtStartTimeDWM, 'h:mm')#&nbsp;&nbsp;&nbsp;<cfif len(timeformat(dtStartTimeDWM, 'h:mm')) eq 4>&nbsp;&nbsp;</cfif><strong>#strTask#</strong><br />
													</cfif>
												<cfelse>
													<cfif dateformat(dtEndDate, 'mm/dd/yy') gt dateformat(today, 'mm/dd/yy')>
														<!--- FILTER BY HOUR --->
														<cfif timeformat(dtStartTimeDWM, 'h tt') eq timeformat(hour, 'h tt') >
															#timeformat(dtStartTimeDWM, 'h:mm')#&nbsp;&nbsp;&nbsp;<cfif len(timeformat(dtStartTimeDWM, 'h:mm')) eq 4>&nbsp;&nbsp;</cfif><strong>#strTask#</strong><br />
														</cfif>
													</cfif>
												</cfif>
											</cfif>
											<!--- ##### END FILTER ##### --->
											
											
											
											<!--- ##### START FILTER BY INTERVAL:WEEKLY ##### --->
											<cfif strInterval eq 'weekly'>
												<cfif dayofweek(dtStartDate) eq dayofweek(today) >
													<cfif len(dtEndDate) gt 1>
														<cfif week(dtEnddate) gte week(today)>
															<!--- FILTER BY HOUR --->
															<cfif timeformat(dtStartTimeDWM, 'h tt') eq timeformat(hour, 'h tt') >
																#timeformat(dtStartTimeDWM, 'h:mm')#&nbsp;&nbsp;&nbsp;<cfif len(timeformat(dtStartTimeDWM, 'h:mm')) eq 4>&nbsp;&nbsp;</cfif><strong>#strTask#</strong><br />
															</cfif>	
														</cfif>
													<cfelse>
														<!--- FILTER BY HOUR --->
														<cfif timeformat(dtStartTimeDWM, 'h tt') eq timeformat(hour, 'h tt') >
															#timeformat(dtStartTimeDWM, 'h:mm')#&nbsp;&nbsp;&nbsp;<cfif len(timeformat(dtStartTimeDWM, 'h:mm')) eq 4>&nbsp;&nbsp;</cfif><strong>#strTask#</strong><br />
														</cfif>
													</cfif>
												</cfif>
											</cfif>
											<!--- ##### END FILTER ##### --->
				
				
				
											<!--- ##### START FILTER BY INTERVAL:MONTHLY ##### --->
											<cfif strInterval eq 'monthly'>
												<!--- FILTER BY DAY OF THE MONTH --->
												<cfif dateformat(dtStartDate, 'dd') eq dateformat(today, 'dd')>
													<!--- FILTER IF END DATE IS GIVEN --->
													<cfif len(dtEndDate) gt 1>
														<!--- FILTER BY DAY OF THE WEEK --->
														<cfif dateformat(dtEndDate, 'mm/dd/yy') gte dateformat(today, 'mm/dd/yy')>
															<!--- FILTER BY HOUR --->
															<cfif timeformat(dtStartTimeDWM, 'h tt') eq timeformat(hour, 'h tt') >
																#timeformat(dtStartTimeDWM, 'h:mm')#&nbsp;&nbsp;&nbsp;<cfif len(timeformat(dtStartTimeDWM, 'h:mm')) eq 4>&nbsp;&nbsp;</cfif><strong>#strTask#</strong><br />
															</cfif>
														</cfif>
													<cfelse>
														<!--- IF NO END DATE IS GIVEN --->
														<!--- FILTER BY HOUR --->
														<cfif timeformat(dtStartTimeDWM, 'h tt') eq timeformat(hour, 'h tt') >
															#timeformat(dtStartTimeDWM, 'h:mm')#&nbsp;&nbsp;&nbsp;<cfif len(timeformat(dtStartTimeDWM, 'h:mm')) eq 4>&nbsp;&nbsp;</cfif><strong>#strTask#</strong><br />
														</cfif>
													</cfif>
												</cfif>
											</cfif>
											<!--- ##### END FILTER ##### --->
											
											
											
											<!--- ##### START FILTER BY INTERVAL:CUSTOM ##### --->
											<cfset listIntervals = 'once,weekly,monthly'>
											<cfif intIntervalOther gt 0>
												<cfif len(dtEndDate) gt 1>
													<!--- FILTER BY DAY OF THE WEEK --->
													<cfif dateformat(dtEndDate, 'mm/dd/yy') gte dateformat(today, 'mm/dd/yy')>
														<!--- FILTER BY HOUR --->
														<cfif timeformat(dtStartTimeDWM, 'h tt') eq timeformat(hour, 'h tt') >
															#timeformat(dtStartTimeDWM, 'h:mm')#&nbsp;&nbsp;&nbsp;<cfif len(timeformat(dtStartTimeDWM, 'h:mm')) eq 4>&nbsp;&nbsp;</cfif><strong>#strTask#</strong><br />
														</cfif>
													</cfif>
												<cfelse>
													<!--- IF NO END DATE IS GIVEN --->
													<!--- FILTER BY HOUR --->
													<cfif timeformat(dtStartTimeDWM, 'h tt') eq timeformat(hour, 'h tt') >
														#timeformat(dtStartTimeDWM, 'h:mm')#&nbsp;&nbsp;&nbsp;<cfif len(timeformat(dtStartTimeDWM, 'h:mm')) eq 4>&nbsp;&nbsp;</cfif><strong>#strTask#</strong><br />
													</cfif>
												</cfif>
											</cfif>
											<!--- ##### END FILTER ##### --->
											
											
											<!--- // NOTE: COPY THIS ENTIRE LOOP SEGMENT AND PASTE IN THE INTERVAL LOOP AND CHANGE #STRTASK# TO #STRINTERVAL# --->
										</cfloop>
									</td>
								
									<td></td>
								
								
								
									<!--- CELL 3 - DISPLAY THE INTERVAL OF THE TASK--->
									<td class="interval">
										<!--- LOOP OVER QUERY --->
										<cfloop query = "qry_get_task">
											
											<!--- ##### START FILTER BY INTERVAL:ONCE ##### --->
											<cfif strInterval eq 'once'>
												<!--- FILTER BY EXACT DATE --->
												<cfif dateformat(today, 'mm/dd') eq dateformat(dtStartDate, 'mm/dd')>
													<!--- FILTER BY HOUR --->
													<cfif timeformat(dtStartTimeDWM, 'h tt') eq timeformat(hour, 'h tt') >
														#strInterval#<br />
													</cfif>
												</cfif>
											</cfif>
											<!--- ##### END FILTER ##### --->
											
											
											
											<!--- ##### START FILTER BY INTERVAL:DAILY ##### --->
											<cfif strInterval eq 'daily'>
												<!--- FILTER BY EXACT DATE --->
												<cfif len(dtEndDate) eq 0>
													<!--- FILTER BY HOUR --->
													<cfif timeformat(dtStartTimeDWM, 'h tt') eq timeformat(hour, 'h tt') >
														#strInterval#<br />
													</cfif>
												<cfelse>
													<cfif dateformat(dtEndDate, 'mm/dd/yy') gt dateformat(today, 'mm/dd/yy')>
														<!--- FILTER BY HOUR --->
														<cfif timeformat(dtStartTimeDWM, 'h tt') eq timeformat(hour, 'h tt') >
															#strInterval#<br />
														</cfif>
													</cfif>
												</cfif>
											</cfif>
											<!--- ##### END FILTER ##### --->
											
											
											
											<!--- ##### START FILTER BY INTERVAL:WEEKLY ##### --->
											<cfif strInterval eq 'weekly'>
												<cfif dayofweek(dtStartDate) eq dayofweek(today) >
													<cfif len(dtEndDate) gt 1>
														<cfif week(dtEnddate) gte week(today)>
															<!--- FILTER BY HOUR --->
															<cfif timeformat(dtStartTimeDWM, 'h tt') eq timeformat(hour, 'h tt') >
																#strInterval#<br />
															</cfif>	
														</cfif>
													<cfelse>
														<!--- FILTER BY HOUR --->
														<cfif timeformat(dtStartTimeDWM, 'h tt') eq timeformat(hour, 'h tt') >
															#strInterval#<br />
														</cfif>
													</cfif>
												</cfif>
											</cfif>
											<!--- ##### END FILTER ##### --->
				
				
				
											<!--- ##### START FILTER BY INTERVAL:MONTHLY ##### --->
											<cfif strInterval eq 'monthly'>
												<!--- FILTER BY DAY OF THE MONTH --->
												<cfif dateformat(dtStartDate, 'dd') eq dateformat(today, 'dd')>
													<!--- FILTER IF END DATE IS GIVEN --->
													<cfif len(dtEndDate) gt 1>
														<!--- FILTER BY DAY OF THE WEEK --->
														<cfif dateformat(dtEndDate, 'mm/dd/yy') gte dateformat(today, 'mm/dd/yy')>
															<!--- FILTER BY HOUR --->
															<cfif timeformat(dtStartTimeDWM, 'h tt') eq timeformat(hour, 'h tt') >
																#strInterval#<br />
															</cfif>
														</cfif>
													<cfelse>
														<!--- IF NO END DATE IS GIVEN --->
														<!--- FILTER BY HOUR --->
														<cfif timeformat(dtStartTimeDWM, 'h tt') eq timeformat(hour, 'h tt') >
															#strInterval#<br />
														</cfif>
													</cfif>
												</cfif>
											</cfif>
											<!--- ##### END FILTER ##### --->
											
											
											
											<!--- ##### START FILTER BY INTERVAL:CUSTOM ##### --->
											<cfset listIntervals = 'once,weekly,monthly'>
											<cfif intIntervalOther gt 0>
												<cfif len(dtEndDate) gt 1>
													<!--- FILTER BY DAY OF THE WEEK --->
													<cfif dateformat(dtEndDate, 'mm/dd/yy') gte dateformat(today, 'mm/dd/yy')>
														<!--- FILTER BY HOUR --->
														<cfif timeformat(dtStartTimeDWM, 'h tt') eq timeformat(hour, 'h tt') >
															Custom<br />
														</cfif>
													</cfif>
												<cfelse>
													<!--- IF NO END DATE IS GIVEN --->
													<!--- FILTER BY HOUR --->
													<cfif timeformat(dtStartTimeDWM, 'h tt') eq timeformat(hour, 'h tt') >
														Custom<br />
													</cfif>
												</cfif>
											</cfif>
											<!--- ##### END FILTER ##### --->
											
											
											<!--- // NOTE: COPY THIS ENTIRE LOOP SEGMENT AND PASTE IN THE INTERVAL LOOP AND CHANGE #STRTASK# TO #STRINTERVAL# --->
										</cfloop>
									</td>
								
								
								</tr>
			
								<cfif row eq 0><cfset row = 1><cfelse><cfset row = 0></cfif>		<!--- // THIS CONTROLS THE ALTERNATING ROW HIGHLIGHTING --->
								
						</cfloop>
						
					</table>
					<br />
		            <div id="horizontal_container" ></div>
		   		</div>
		
				<!--- SET THE DATE FOR THE NEXT LOOP PROCESS || ADD ONE DAY TO THE CURRENT LOOP DATE --->
				<cfset today = 	DateAdd("d", 1, today)>
			
			</cfloop>

		</div>

	</div>
</div>


</cfoutput>