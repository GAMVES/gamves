	
	// --
  	// Remove Family and Dependencied by objectId

	Parse.Cloud.define("RemoveFamilyById", function(request, response) {	

		var familyId = request.params.familyId;

		var userQuery = new Parse.Query("Family");
		userQuery.equalTo("objectId", familyId);		        
       
        userQuery.first({
        	useMasterKey: true,
            success: function(familyPF) 
            {

        		let userRelation = familyPF.relation("members");
        		let userQuery = userRelation.query();

        		userQuery.find({
        			useMasterKey: true,
					success: function(members) {																	

		    			//Remove Family Role		    		
						var queryRole = new Parse.Query(Parse.Role);						
						queryRole.equalTo('removeId', familyPF.id);		
						queryRole.find({useMasterKey:true}).then(function(rolesPF) {	    
							for (var i = 0; i < rolesPF.length; ++i) {
								rolesPF[i].destroy({useMasterKey:true});
							}					
						});		

						//ChatFeed for family
						let chatfeedFamilyQuery = new Parse.Query("ChatFeed");	    
		    			chatfeedFamilyQuery.equalTo('removeId', familyId);
		    			chatfeedFamilyQuery.find({useMasterKey:true}).then(function(chatfeeds) {	    				    				
		    				for (var i = 0; i < chatfeeds.length; ++i) {						
								var chatQuery = chatfeeds[i].relation("chats").query();					
								chatQuery.find({useMasterKey:true}).then(function(chatsPF) {
									for (var j = 0; j < chatsPF.length; ++j) {
										chatsPF[j].destroy({useMasterKey:true});
									}							
								});	
								chatfeeds[i].destroy({useMasterKey:true});												
							}
		    			});	    			

		    			//Remove family Memebers
						for (var i = 0; i < members.length; ++i) {
							let userId = members[i].id;
							Parse.Cloud.run("RemoveUserById", { "userId": userId});
						}

						//remove the family
						familyPF.destroy({useMasterKey: true});

						response.succes(true);

					}, error:function(error)
		    		{          		
		    			response.error(error.message);
		        		console.error("Members query. error = " + error.message);
		    		}
		    	})       
	          	

            }, error:function(error)
	        {	     
	        	console.error("userQuery find failed. error = " + error.message);   
	        }
        });	
	})

	// --
  	// Remove User and Dependencied by objectId

	Parse.Cloud.define("RemoveUserById", function(request, response) {	

		var userId = request.params.userId;

		var userQuery = new Parse.Query(Parse.User);
		userQuery.equalTo("objectId", userId);		 
		userQuery.find({useMasterKey: true }).then(function(usersPF) {
			
			for (var i = 0; i < usersPF.length; ++i) 
			{	
				let userPF = usersPF[i];

				//Installations
				var installationQuery = new Parse.Query(Parse.Installation);
				installationQuery.containedIn('user', [userPF]);
				installationQuery.find({useMasterKey:true}).then(function(installations) {					
					for (var i = 0; i < installations.length; ++i) {				
						installations[i].destroy({useMasterKey:true});
					}
				});

				//Sessions
				let sessionQuery = new Parse.Query(Parse.Session);	
				sessionQuery.containedIn('user', [userPF]);	
				sessionQuery.find({useMasterKey:true}).then(function(sessions) {		
					for (var i = 0; i < sessions.length; ++i) {				
						sessions[i].destroy({useMasterKey:true});
					}
				});

				//Algums
				let albumsQuery = new Parse.Query("Albums");	
				albumsQuery.equalTo('posterId', userPF.id);		
				albumsQuery.find({useMasterKey:true}).then(function(albums) {		
					for (var i = 0; i < albums.length; ++i) {
						albums[i].destroy({useMasterKey:true});
					}
				});	

				//Fanpages
				let fanpagesQuery = new Parse.Query("Fanpages");	
				fanpagesQuery.equalTo('posterId', userPF.id);			
				fanpagesQuery.find({useMasterKey:true}).then(function(fanpages) {		
					for (var i = 0; i < fanpages.length; ++i) {
						var albumsQuery = fanpages[i].relation("albums").query();					
						albumsQuery.find({useMasterKey:true}).then(function(albumsPF) {
							for (var j = 0; j < albumsPF.length; ++j) {
								albumsPF[j].destroy({useMasterKey:true});
							}							
						});	
						fanpages[i].destroy({useMasterKey:true});
					}
				});

				//ChatFeed for users
				let chatfeedQuery = new Parse.Query("ChatFeed");	    
    			chatfeedQuery.equalTo('removeId', userPF.id);
    			chatfeedQuery.find({useMasterKey:true}).then(function(chatfeeds) {	    				    				
    				for (var i = 0; i < chatfeeds.length; ++i) {						
						var chatQuery = chatfeeds[i].relation("chats").query();					
						chatQuery.find({useMasterKey:true}).then(function(chatsPF) {
							for (var j = 0; j < chatsPF.length; ++j) {
								chatsPF[j].destroy({useMasterKey:true});
							}							
						});	
						chatfeeds[i].destroy({useMasterKey:true});												
					}
    			});	

    			//History
    			let historyQuery = new Parse.Query("History");	
				historyQuery.equalTo('userId', userPF.id);	
				historyQuery.find({useMasterKey:true}).then(function(histories) {	    						
					for (var i = 0; i < histories.length; ++i) {
						histories[i].destroy({useMasterKey:true});
					}
				});

				//Location
				let locationQuery = new Parse.Query("Location");	
				locationQuery.equalTo('userId', userPF.id);		
				locationQuery.find({useMasterKey:true}).then(function(locations) {	    						
					for (var i = 0; i < locations.length; ++i) {
						locations[i].destroy({useMasterKey:true});
					}
				});

				//Notfication
				let notificationsQuery = new Parse.Query("Notifications");	
				notificationsQuery.equalTo('removeId', userPF.id);		
				notificationsQuery.find({useMasterKey:true}).then(function(notifications) {	    							
					for (var i = 0; i < notifications.length; ++i) {
						notifications[i].destroy({useMasterKey:true});
					}
				});

				//Profile
				let profileQuery = new Parse.Query("Profile");	
				profileQuery.equalTo('userId', userPF.id);			
				profileQuery.find({useMasterKey:true}).then(function(profiles) {	    							
					for (var i = 0; i < profiles.length; ++i) {
						profiles[i].destroy({useMasterKey:true});
					}
				});

				//TimeOnline
				let timeOnlineQuery = new Parse.Query("TimeOnline");	
				timeOnlineQuery.equalTo('userId', userPF.id);	
				timeOnlineQuery.find({useMasterKey:true}).then(function(timeonlines) {	    							
					for (var i = 0; i < timeonlines.length; ++i) {
						timeonlines[i].destroy({useMasterKey:true});
					}
				});

				//Badges
				let badgesQuery = new Parse.Query("Badges");	
				badgesQuery.equalTo('userId', userPF.id);			
				badgesQuery.find({useMasterKey:true}).then(function(badges) {	    							
					for (var i = 0; i < badges.length; ++i) {
						badges[i].destroy({useMasterKey:true});
					}
				});

				//UserStatus
				let userStatusQuery = new Parse.Query("UserStatus");	
				userStatusQuery.equalTo('userId', userPF.id);		
				userStatusQuery.find({useMasterKey:true}).then(function(userstatuses) {	    							
					for (var i = 0; i < userstatuses.length; ++i) {
						userstatuses[i].destroy({useMasterKey:true});
					}
				});

				//UserVerified
				let userVerifiedQuery = new Parse.Query("UserVerified");	
				userVerifiedQuery.equalTo('userId', userPF.id);			
				userVerifiedQuery.find({useMasterKey:true}).then(function(userverifieds) {	    							
					for (var i = 0; i < userverifieds.length; ++i) {
						userverifieds[i].destroy({useMasterKey:true});
					}
				});

				//Points
				let pointsQuery = new Parse.Query("Points");	
				pointsQuery.equalTo('userId', userPF.id);			
				pointsQuery.find({useMasterKey:true}).then(function(pointsPF) {	    							
					for (var i = 0; i < pointsPF.length; ++i) {
						pointsPF[i].destroy({useMasterKey:true});
					}
				});

				//Role
				var queryRole = new Parse.Query(Parse.Role);						
				queryRole.equalTo('removeId', userPF.id);		
				queryRole.find({useMasterKey:true}).then(function(rolesPF) {	    
					for (var i = 0; i < rolesPF.length; ++i) {
						rolesPF[i].destroy({useMasterKey:true});
					}					
				});

				//User
				userPF.destroy({useMasterKey:true});

			}
		});       
    });    
