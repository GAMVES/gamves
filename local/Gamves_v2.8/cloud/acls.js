	/*
	* ACLS
	*/	

	// --
  	// Add role by name

	Parse.Cloud.define("AddRoleByName", function(request, response) {		

		var params = request.params;
		
   		if (!params.name) {
        	response.error("Missing parameters: name");
        	return response.error("Missing parameters: name"); 
   		}

        var name = request.params.name; 

        var newRole = new Parse.Role(name, new Parse.ACL());      
        newRole.save(null, {useMasterKey: true}).then(function(newRolePF) {	       		        				

			var acl = new Parse.ACL();
			
			acl.setReadAccess(newRolePF, true); 

			acl.setWriteAccess(newRolePF, true); 

			newRolePF.setACL(acl); 

			return newRolePF.save(null, {useMasterKey: true});

		}).then(function(roleFinalPF) {	 

			response.success(roleFinalPF);	

		});
	});


	// --
  	// Add role by name

	Parse.Cloud.define("AddUserToRole", function(request, response) {	

		var roleName = request.params.role;	  
	    var userId = request.params.userId; 

		Parse.Cloud.run("CheckRoleHasUser", { "userId": userId, "role": roleName}).then(function(result) {    

            if (!result) {

            	console.log("roleName: " + roleName + " userId: " + userId);		        
		
				var queryRole = new Parse.Query(Parse.Role);		
				queryRole.equalTo('name', roleName);		

				queryRole.first({useMasterKey:true}).then(function(rolePF) {

			        var userQuery = new Parse.Query(Parse.User);
					userQuery.equalTo("objectId", userId);		        
			       
			        userQuery.first({

			            success: function(userPF) {

			            	var userRelation = rolePF.relation("users");
							userRelation.add(userPF);

							rolePF.save(null, { useMasterKey: true,	

								success: function (roleSaved) {
													
									//let restul = {"result":true, "role":JSON.stringify(roleSaved)}

		        					response.success(rolePF.id);
				    			},
								error: function (response, error) {										
								    
								    response.error("error: "  + error);
								}
							});  
			            }
			        });		
				});

            }  
           
        }, function(error) {
            console.log("error :" + error);       

        });    	   
	});

	// --
  	// Add role to role

	Parse.Cloud.define("AddRoleToRole", function(request, response) {	

		var roleParent = request.params.parent;	  
	    var roleChild = request.params.child; 

    	console.log("roleParent: " + roleParent.id + " roleChild: " + roleChild.id);

    	var roleParentRelation = roleParent.relation("roles");
		roleParentRelation.add(roleChild);		        

		roleParent.save(null, { useMasterKey: true,	

			success: function (roleSaved) {				

				response.success(roleSaved.id);
			},
			error: function (response, error) {										
			    
			    response.error("error: "  + error);
			}
		}); 
          	   
	});


	// --
  	// Check user has role

	Parse.Cloud.define("CheckRoleHasUser", function(request, response) {	    
	    
	    var roleName = request.params.role;	  
	    var userId = request.params.userId; 

	    console.log("roleName:  " + roleName + " userId: " + userId);
		
		var queryRole = new Parse.Query(Parse.Role);		
		queryRole.equalTo('name', roleName);		
		queryRole.first({useMasterKey:true}).then(function(rolePF) {

			console.log( "rolePF id : "  + rolePF.id );			
	    	
	        var role = rolePF;
	        var adminRelation = new Parse.Relation(role, 'users');

	        var queryAdmins = adminRelation.query();
	        
	        queryAdmins.equalTo('objectId', userId);

	        queryAdmins.first({useMasterKey:true}).then(function(userPF) {

	        	if (userPF) {

	        		console.log( "TRUE" );			

					response.success(rolePF.id);

	        	} else {

	        		console.log( "FALSE" );			

					response.success(false);

	        	}

			});	        

	     });
	});

	
	// --
  	// Add role to Category

	Parse.Cloud.define("AddAclToCategory", function(request, response) {	    
	    
	    var category = request.params.category;
	    var rolesArray = request.params.roles;	    

	    var params = request.params;

	    if (!params.category) {
        	response.error("Missing parameters: rolesArray");        	
   		}

   		
	    var roles = new Parse.Role();
		
		var queryRole = new Parse.Query(Parse.Role);	
		queryRole.containedIn("name", rolesArray);
		queryRole.find({
			useMasterKey: true,
			success: function(rolesPF) {              	
				roles = rolesPF;

				var queryCategories = new Parse.Query("Categories");
				queryCategories.equalTo("name", category);         	
		    	queryCategories.first({
					useMasterKey: true,
					success: function(categoryPF) {

						let res = "categoryPF.id " + categoryPF.id;
                        response.success(res);

            			var groupACL = new Parse.ACL();	    	
						for (var i = 0; i < roles.length; i++) {
						  groupACL.setReadAccess(roles[i], true);
						  groupACL.setWriteAccess(roles[i], true);
						}	
						categoryPF.setACL(groupACL);  					

						categoryPF.save(null, { useMasterKey: true,	

							success: function (categoryPFSaved) {									
								response.success(categoryPFSaved.id);
							},
							error: function (response, error) {
								response.error("Error: " + error.code + " " + error.message);
							}
						});

            		},
		            error: function (error) {
		                console.log("Error: " + error.code + " " + error.message);
		                response.error("Error: " + error.code + " " + error.message);
		            }
				});
            },
            error: function (error) {
                console.log("Error: " + error.code + " " + error.message);
                response.error("Error: " + error.code + " " + error.message);
            }
        });
	});


	// --
  	// Add role to Fanpage

	Parse.Cloud.define("AddAclToFanpage", function(request, response) {	    
	    
	    var fanpage = request.params.fanpage;
	    var rolesArray = request.params.roles;	    

	    var params = request.params;

	    if (!params.fanpage) {
        	response.error("Missing parameters: fanpage");        	
   		}

   		// response.success(rolesArray);
   		//console.log("rolesArray: " + rolesArray);   		  			    

	    var roles = new Parse.Role();
		
		var queryRole = new Parse.Query(Parse.Role);	
		queryRole.containedIn("name", rolesArray);
		queryRole.find({
			useMasterKey: true,
			success: function(rolesPF) {              	
				roles = rolesPF;

				//let res = "rolesPF.length " + rolesPF.length;
                //response.success(res);

				var queryFanpage = new Parse.Query("Fanpages");
				queryFanpage.equalTo("pageName", fanpage);         	
		    	queryFanpage.first({
					useMasterKey: true,
					success: function(fanpgaePF) {

						//let res = "fanpgaePF.id " + fanpgaePF.id;
                        //response.success(res);

            			var groupACL = new Parse.ACL();	    	
						for (var i = 0; i < roles.length; i++) {
						  groupACL.setReadAccess(roles[i], true);
						  groupACL.setWriteAccess(roles[i], true);
						}	
						fanpgaePF.setACL(groupACL);  					

						fanpgaePF.save(null, { useMasterKey: true,	

							success: function (fanpagePFSaved) {									
								response.success(fanpagePFSaved.id);
							},
							error: function (response, error) {
								response.error("Error: " + error.code + " " + error.message);
							}
						});

            		},
		            error: function (error) {
		                console.log("Error: " + error.code + " " + error.message);
		                response.error("Error: " + error.code + " " + error.message);
		            }
				});
            },
            error: function (error) {
                console.log("Error: " + error.code + " " + error.message);
                response.error("Error: " + error.code + " " + error.message);
            }
        });
	});

	// --
  	// Add role to Video

	Parse.Cloud.define("AddAclToVideo", function(request, response) {	    
	    
	    var videoId = request.params.videoId;
	    var rolesArray = request.params.roles;	    

	    var params = request.params;

	    if (!params.videoId) {
        	response.error("Missing parameters: videoId");        	
   		}

   		// response.success(rolesArray);
   		//console.log("rolesArray: " + rolesArray);   		  			    

	    var roles = new Parse.Role();
		
		var queryRole = new Parse.Query(Parse.Role);	
		queryRole.containedIn("name", rolesArray);
		queryRole.find({
			useMasterKey: true,
			success: function(rolesPF) {              	
				roles = rolesPF;

				//let res = "rolesPF.length " + rolesPF.length;
                //response.success(res);

				var queryFanpage = new Parse.Query("Videos");
				queryFanpage.equalTo("objectId", videoId);         	
		    	queryFanpage.first({
					useMasterKey: true,
					success: function(videoPF) {

						//let res = "fanpgaePF.id " + fanpgaePF.id;
                        //response.success(res);

            			var groupACL = new Parse.ACL();	    	
						for (var i = 0; i < roles.length; i++) {
						  groupACL.setReadAccess(roles[i], true);
						  groupACL.setWriteAccess(roles[i], true);
						}	
						videoPF.setACL(groupACL);  					

						videoPF.save(null, { useMasterKey: true,	

							success: function (videoPFSaved) {									
								response.success(videoPF.id);
							},
							error: function (response, error) {
								response.error("Error: " + error.code + " " + error.message);
							}
						});

            		},
		            error: function (error) {
		                console.log("Error: " + error.code + " " + error.message);
		                response.error("Error: " + error.code + " " + error.message);
		            }
				});
            },
            error: function (error) {
                console.log("Error: " + error.code + " " + error.message);
                response.error("Error: " + error.code + " " + error.message);
            }
        });
	});

	// --
  	// Add role to Notification

	Parse.Cloud.define("AddAclToNotification", function(request, response) {	    
	    
	    var notificationId = request.params.notificationId;
	    var rolesArray = request.params.roles;	    

	    var params = request.params;

	    if (!params.notificationId) {
        	response.error("Missing parameters: videoId");        	
   		}

   		// response.success(rolesArray);
   		//console.log("rolesArray: " + rolesArray);   		  			    

	    var roles = new Parse.Role();
		
		var queryRole = new Parse.Query(Parse.Role);	
		queryRole.containedIn("name", rolesArray);
		queryRole.find({
			useMasterKey: true,
			success: function(rolesPF) {              	
				roles = rolesPF;

				//let res = "rolesPF.length " + rolesPF.length;
                //response.success(res);

				var queryNotification = new Parse.Query("Notifications");
				queryNotification.equalTo("objectId", notificationId);         	
		    	queryNotification.first({
					useMasterKey: true,
					success: function(notificationPF) {

						//let res = "notificationPF.id " + notificationPF.id;
                        //response.success(res);

            			var groupACL = new Parse.ACL();	    	
						for (var i = 0; i < roles.length; i++) {
						  groupACL.setReadAccess(roles[i], true);
						  groupACL.setWriteAccess(roles[i], true);
						}	
						notificationPF.setACL(groupACL);  					

						notificationPF.save(null, { useMasterKey: true,	

							success: function (notificationPFSaved) {									
								response.success(notificationPFSaved.id);
							},
							error: function (response, error) {
								response.error("Error: " + error.code + " " + error.message);
							}
						});

            		},
		            error: function (error) {
		                console.log("Error: " + error.code + " " + error.message);
		                response.error("Error: " + error.code + " " + error.message);
		            }
				});
            },
            error: function (error) {
                console.log("Error: " + error.code + " " + error.message);
                response.error("Error: " + error.code + " " + error.message);
            }
        });
	});
	

	// --
  	// Add role to Welcome

	Parse.Cloud.define("AddAclToWelcome", function(request, response) {	    
	    
	    var welcomeId = request.params.welcomeId;
	    var rolesArray = request.params.roles;	    

	    var params = request.params;

	    if (!params.welcomeId) {
        	response.error("Missing parameters: welcomeId");        	
   		}

   		// response.success(rolesArray);
   		//console.log("rolesArray: " + rolesArray);   		  			    

	    var roles = new Parse.Role();
		
		var queryRole = new Parse.Query(Parse.Role);	
		queryRole.containedIn("name", rolesArray);
		queryRole.find({
			useMasterKey: true,
			success: function(rolesPF) {              	
				roles = rolesPF;

				//let res = "rolesPF.length " + rolesPF.length;
                //response.success(res);

				var queryWelcome = new Parse.Query("Welcomes");
				queryWelcome.equalTo("objectId", welcomeId);         	
		    	queryWelcome.first({
					useMasterKey: true,
					success: function(welcomePF) {

						//let res = "welcomePF.id " + welcomePF.id;
                        //response.success(res);

            			var groupACL = new Parse.ACL();	    	
						for (var i = 0; i < roles.length; i++) {
						  groupACL.setReadAccess(roles[i], true);
						  groupACL.setWriteAccess(roles[i], true);
						}	
						welcomePF.setACL(groupACL);  					

						welcomePF.save(null, { useMasterKey: true,	

							success: function (welcomePFSaved) {									
								response.success(welcomePFSaved.id);
							},
							error: function (response, error) {
								response.error("Error: " + error.code + " " + error.message);
							}
						});

            		},
		            error: function (error) {
		                console.log("Error: " + error.code + " " + error.message);
		                response.error("Error: " + error.code + " " + error.message);
		            }
				});
            },
            error: function (error) {
                console.log("Error: " + error.code + " " + error.message);
                response.error("Error: " + error.code + " " + error.message);
            }
        });
	});


	// --
  	// Add role to Gift

	Parse.Cloud.define("AddAclToGift", function(request, response) {	    
	    
	    var giftId = request.params.giftId;
	    var rolesArray = request.params.roles;	    

	    var params = request.params;

	    if (!params.giftId) {
        	response.error("Missing parameters: giftId");        	
   		}

   		// response.success(rolesArray);
   		//console.log("rolesArray: " + rolesArray);   		  			    

	    var roles = new Parse.Role();
		
		var queryRole = new Parse.Query(Parse.Role);	
		queryRole.containedIn("name", rolesArray);
		queryRole.find({
			useMasterKey: true,
			success: function(rolesPF) {              	
				roles = rolesPF;

				//let res = "rolesPF.length " + rolesPF.length;
                //response.success(res);

				var queryGift = new Parse.Query("Gifts");
				queryGift.equalTo("objectId", giftId);         	
		    	queryGift.first({
					useMasterKey: true,
					success: function(giftPF) {

						//let res = "giftPF.id " + giftPF.id;
                        //response.success(res);

            			var groupACL = new Parse.ACL();	    	
						for (var i = 0; i < roles.length; i++) {
						  groupACL.setReadAccess(roles[i], true);
						  groupACL.setWriteAccess(roles[i], true);
						}	
						giftPF.setACL(groupACL);  					

						giftPF.save(null, { useMasterKey: true,	

							success: function (giftPFSaved) {									
								response.success(giftPFSaved.id);
							},
							error: function (response, error) {
								response.error("Error: " + error.code + " " + error.message);
							}
						});

            		},
		            error: function (error) {
		                console.log("Error: " + error.code + " " + error.message);
		                response.error("Error: " + error.code + " " + error.message);
		            }
				});
            },
            error: function (error) {
                console.log("Error: " + error.code + " " + error.message);
                response.error("Error: " + error.code + " " + error.message);
            }
        });
	});


