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

			if (request.removeId) {

				var removeId = request.removeId;

				newRolePF.set("removeId", removeId);
			}

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

			            	//var userRelation = rolePF.relation("users");
							//userRelation.add(userPF);

							rolePF.getUsers().add(userPF);             				

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
  	// Post a Role

	Parse.Cloud.define("AddRoleToObject", function(request, responseRole) {

		var pclassName = request.params.pclassName;		
		var objectId = request.params.objectId;		
	    var role = request.params.role;		

		var queryConfig = new Parse.Query("Config");				   
	    queryConfig.find({
	        useMasterKey: true,
	        success: function(results) {

	        	if( results.length > 0) 
	        	{

					var configObject = results[0];
					
					var _serverUrl = configObject.get("server_url");
					var _appId = configObject.get("app_id");
					var _restApi = configObject.get("rest_api");
					var _mKey = configObject.get("master_key");					

					var _url = _serverUrl + "/classes/" + pclassName + "/" + objectId;	
					console.log("_url: " + _url);

					Parse.Cloud.run("GetObjectRole", { "pclassName": pclassName, "objectId": objectId }).then(function(resutlAcl) {    

						console.log("resutlAcl: " + JSON.stringify(resutlAcl));			
				
						var resutlArray = []; 
						var resutl = JSON.parse( JSON.stringify( resutlAcl ) ); 	
						var keys = Object.keys(resutl);
						var count = keys.length;		        					

				        if (count > 0) {
				            for(var i=0; i<count; i++) {
					        	let key = Object.keys(resutl)[i];
			       				if (key != "*") {			          
			          				let value = Object.values(resutl)[i];   			        
							        let sJson = "\"" + key  + "\":" + JSON.stringify(value);
							        resutlArray.push(sJson);
							    }			          
						    }
						}		    

					    var _body = "{\"ACL\":{"; 
					    for(var i=0; i<resutlArray.length; i++) {							
							_body += resutlArray[i];
							if (i < resutlArray.length) {
								_body += ",";
							}
					    }
					    _body += "\"role:" + role + "\":{\"read\": true,\"write\": true}";
					    _body += "}}";	

					    console.log("_body: " + _body);			

						Parse.Cloud.httpRequest({	
							method: "PUT",				     
					        headers: {
	    						'Content-Type': 'application/json',
	    						'X-Parse-Application-Id': _appId,
	    						'X-Parse-REST-API-Key': _restApi,
	    						'X-Parse-Master-Key': _mKey
	       					},	       
					        url: _url,
					        body: _body,
					        success: function (httpResponse) {
					            console.log(httpResponse.text);
					            responseRole.success(httpResponse.text);
					        },
					        error: function (httpResponse) {
					            console.error('Request failed with response code ' + httpResponse.status);
					            responseRole.error('Request failed with response code ' + httpResponse.status);
					        }
					    });	

					})					
				}

			},
	        error: function(error) {	        	
	            console.log(error);
	            responseRole.error(error);						            
	        }
	    });  	

	});



	// --
  	// Get Object Role

	Parse.Cloud.define("GetObjectRole", function(request, responseAcl) {

		var pclassName = request.params.pclassName;		
		var objectId = request.params.objectId;		

		var objectQuery = new Parse.Query(pclassName);
		objectQuery.equalTo("objectId", objectId);

		objectQuery.first({
	        useMasterKey: true,
	        success: function(objectPF) {           		        	        	

	        	var _acl = objectPF.getACL(); 

	        	let resutl;

	        	if (_acl === null) {
	        		resutl = {};
	        	} else {
	        		resutl = _acl;
	        	}

	        	responseAcl.success(resutl);  

	        },
	        error: function(error) {

	        	console.log("error: " +error); 	       	

		        responseAcl.error("error: " +error);   
	        }      
		});
	});




