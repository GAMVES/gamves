	/*
	* Cloud Code 
	*/

	// -- Add Gamves User as Family from Registrant

	//var http = require('http-get');


	Parse.Cloud.define("createGamvesUser", function (request, response) {

		var objects = [];
		var resutlUser;
		
		var iDUserType = request.params.iDUserType;

	    var typeQuery = new Parse.Query("UserType");
	    return typeQuery.get(request.params.userTypeObj).then(function(typeObj) {

	        objects.push(typeObj);

	        var levelQuery = new Parse.Query("Level");
	        levelQuery.equalTo("objectId", request.params.levelObj);
	        return levelQuery.first();

	    }).then(function(levelObj) {

	    	objects.push(levelObj);

	    	var queryRole = new Parse.Query(Parse.Role);
			queryRole.equalTo('name', 'admin');
			return queryRole.first({useMasterKey:true});

	    }).then(function(roleObj) {

			objects.push(roleObj);

			var Profile = Parse.Object.extend("Profile");         

            var profile = new Profile();    

            var dataPhotoBackground = request.params.dataPhotoBackground;
	    	var fileBackground = new Parse.File("background.png", dataPhotoBackground, "image/png");

			profile.set("pictureBackground", fileBackground);

			profile.set("bio", "Your phrase here");		

			profile.set("backgroundColor", [228, 239, 245]);

			return profile.save(null, {useMasterKey: true})

		}).then(function(profileObj) {

	        objects.push(profileObj);

	        var user_name = request.params.user_name;
	        var user_user_name = request.params.user_user_name;
	        var user_email = request.params.user_email;
	    	var user_password = request.params.user_password;
	    	var firstName = request.params.firstName;
	    	var lastName = request.params.lastName;

	        var dataPhotoImage = request.params.dataPhotoImage;
	    	var file = new Parse.File(firstName+"picture.png", dataPhotoImage, "image/png");

	    	var dataPhotoImageSmall = request.params.dataPhotoImageSmall;
	    	var fileSmall = new Parse.File(firstName+"small.png", dataPhotoImageSmall, "image/png");

	    	var levelObj = request.params.levelObj;
			var userTypeObj = request.params.userTypeObj;	
	    
			var user = new Parse.User();

			user.set("username", user_user_name);
			user.set("password", user_password);
			user.set("Name", user_user_name);
		  	user.set("firstName", firstName);
		  	user.set("lastName", lastName);
			user.set("iDUserType", iDUserType);
			user.set("picture", file);
			user.set("pictureSmall", fileSmall);

			var lobjectId = objects[1].id;

			if (iDUserType==2 || iDUserType==3) { // only son and daughter
				
				user.set("levelObjId", lobjectId);	
			} else {				
				user.set("email", user_email);
			}		

			let relationType = user.relation("userType")
		    relationType.add(objects[0]);

		    let relationLevel = user.relation("level")
		    relationLevel.add(objects[1]);

		    var profileRelation = user.relation("profile");
			profileRelation.add(objects[3]);

		    return user.signUp(null, {useMasterKey: true} );
		
	    }).then(function(userSaved) {

	    	var adminRole = objects[2];

	    	var adminRoleRelation = adminRole.relation("users");
			adminRoleRelation.add(userSaved);		    	

	    	adminRole.save(null, {useMasterKey: true});

	    	var profile = objects[3]; 

	    	profile.set("userId", userSaved.objectId);

	        return userSaved.save(null, {useMasterKey: true});

	    }).then(function(userSaved) {	

			if ( iDUserType==2 || iDUserType==3 ) {

				var queryConfig = new Parse.Query("Config");				   
			    queryConfig.find({
			        useMasterKey: true,
			        success: function(results) {

			        if( results.length > 0) 
			        {
			        	var config = results[0];

			        	var configRelation = config.relation("images");
			        	configRelation.ascending("createdAt");	

			            configRelation.find({
			                success: function (images) {    					        	

								var queryCategory = new Parse.Query("Categories");
								queryCategory.equalTo('description', 'PERSONAL');
								queryCategory.equalTo('schoolId', request.params.schoolId);

								queryCategory.first({useMasterKey:true}).then(function(category) {		

							    	let count = dataArray.length;
							    	
							    	var Fanpages = Parse.Object.extend("Fanpages");
							    	var fanpage = new Fanpages();

							    	var dataPhotoImage = request.params.dataPhotoImage;
							    	var fileIcon = new Parse.File("icon.png", dataPhotoImage, "image/png");
							    	fanpage.set("pageIcon", fileIcon);

									var dataPhotoBackground = request.params.dataPhotoBackground;
							    	var fileCover = new Parse.File("background.png", dataPhotoBackground, "image/png");

							    	fanpage.set("pageCover", fileCover);

							    	var user_user_name = request.params.user_user_name;
							    	fanpage.set("pageName", user_user_name);

							    	var categoryName = category["description"]; 
									
							    	fanpage.set("categoryName", categoryName);

							    	var categoryRelation = fanpage.relation("category");
							    	categoryRelation.add(category);

							    	fanpage.save(null, {
							              success: function (fanpageSaved) {        
							                 
							                  var albumRelation = fanpageSaved.relation("albums");

										    	for (var j=0; j <images.length; j++) {
										    		
										    		var fanpageId = Math.floor( Math.random() * 100000);			    		
											        					                
											        var fileImage = images[j];

											        var Albums = Parse.Object.extend("Albums");	 		
										    		let album = new Albums();

													album.set("cover", fileImage);															    					    		
										    		album.set("fanpageId",fanpageId);					    		

										    		album.save(null, {
											            success: function (albumSaved) {  

											              	albumRelation.add(albumSaved);

											              	if (j==(dataArray-1)) {

												              	fanpageSaved.save(null, {useMasterKey: true});

								    							response.success(resutlUser);   
								    						}

											        	},
											            error: function (error) {
											            	response.error(error);
											            }
											         });
										    	}		              

							              },
							              error: function (error) {
							                  response.error(error);
							              }

									});

						         });

						    },
				                error: function (error) {
				                    console.log("Error: " + error.code + " " + error.message);
				                }
				            });  

				    	}
				    },
			        error: function(error) {						            
			            console.log(error);
			        }
			    }); 
			 
			 } else {

			 	response.success(userSaved);

			 }

	    }, function(error) {

	        response.error(error);

	    });		

	});
	

	