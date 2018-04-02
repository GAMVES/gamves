	/*
	* Cloud Code 
	*/

	// -- Add Gamves User as Family from Registrant

	//var http = require('http-get');


	Parse.Cloud.define("createGamvesUser", function (request, response) {

		var objects = [];
		var resutlUser;
		var fanpageSaved;
		var albumsArray = [];
		var profile;
		var categorySaved;
		var adminUser;
		
		var iDUserType = request.params.iDUserType;

		var userQuery = new Parse.Query(Parse.User);
		userQuery.equalTo("username", "gamvesadmin");
		
	    return userQuery.first().then(function(admin) {

	    	adminUser = admin;

			var typeQuery = new Parse.Query("UserType");	
	        return typeQuery.get(request.params.userTypeObj);

	    }).then(function(typeObj) {   

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

            profile = new Profile();    

            var dataPhotoBackground = request.params.dataPhotoBackground;
	    	var fileBackground = new Parse.File("background.png", dataPhotoBackground, "image/png");

			profile.set("pictureBackground", fileBackground);

			profile.set("bio", "Your phrase here");		

			profile.set("backgroundColor", [228, 239, 245]);

			return profile.save(null, {useMasterKey: true});

		}).then(function(profileObj) {	        

			profile = profileObj;

	        var user_name = request.params.user_name;	        
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

			user.set("username", user_name);
			user.set("password", user_password);
			user.set("Name", firstName + " " + lastName);
		  	user.set("firstName", firstName);
		  	user.set("lastName", lastName);
			user.set("iDUserType", iDUserType);
			user.set("picture", file);
			user.set("pictureSmall", fileSmall);

			var lobjectId = objects[1].id;

			if (iDUserType==2 || iDUserType==3) { // only son and daughter
				
				user.set("levelObjId", lobjectId);

				//Register			


			} else {				
				user.set("email", user_email);
			}		

			let relationType = user.relation("userType")
		    relationType.add(objects[0]);

		    let relationLevel = user.relation("level")
		    relationLevel.add(objects[1]);

		    var profileRelation = user.relation("profile");
			profileRelation.add(profile);

		    return user.signUp(null, {useMasterKey: true} );
		
	    }).then(function(userSaved) {

	    	resutlUser = userSaved;

	    	profile.set("userId", resutlUser.id);

	    	return profile.save(null, {useMasterKey: true});
		
		}).then(function(profileSaved) {

			profile = profileSaved;

	    	var adminRole = objects[2];

	    	var adminRoleRelation = adminRole.relation("users");
			adminRoleRelation.add(resutlUser);		    	

	    	adminRole.save(null, {useMasterKey: true});	    	

	    	profile.set("userId", resutlUser.objectId);

	        return resutlUser.save(null, {useMasterKey: true});

	    }).then(function(userSaved) {

	    	resutlUser = userSaved;

	    	if ( iDUserType==2 || iDUserType==3 ) {

		    	var queryCategory = new Parse.Query("Categories");
				queryCategory.equalTo('name', 'PERSONAL');
				queryCategory.equalTo('schoolId', request.params.schoolId)
				return queryCategory.first({useMasterKey:true});

	       	 } else {

			 	response.success(userSaved);
			 }

		}).then(function(category) {

			if ( iDUserType==2 || iDUserType==3 ) {		

				categorySaved = category;					                			

				var queryFanpage = new Parse.Query("Fanpages");
				queryFanpage.equalTo('categoryName', 'PERSONAL');			
				return queryFanpage.first({useMasterKey:true});
			}

		}).then(function(fanpagesFound) {

			if ( iDUserType==2 || iDUserType==3 ) {

				var count = 0;
				
				if (fanpagesFound != undefined) {
					count = fanpagesFound.length;
				}			

				if (count > 0) {
					count++;
				}

				//var category = categorySaved;					                				

	        	var Fanpages = Parse.Object.extend("Fanpages");
		    	var fanpage = new Fanpages();

		    	var dataPhotoImage = request.params.dataPhotoImage;
		    	var fileIcon = new Parse.File("icon.png", dataPhotoImage, "image/png");
		    	fanpage.set("pageIcon", fileIcon);

				var dataPhotoBackground = request.params.dataPhotoBackground;
		    	var fileCover = new Parse.File("background.png", dataPhotoBackground, "image/png");

		    	fanpage.set("pageCover", fileCover);

		    	var first_name = request.params.firstName;
		    	fanpage.set("pageName", first_name);

		    	var categoryName = categorySaved.get("name"); 
				
		    	fanpage.set("categoryName", categoryName);	

		    	fanpage.set("approved", true);

		    	var about =  request.params.firstName + "'s fanpage";

				fanpage.set("pageAbout", about);	    			    	

				let relationCategory = fanpage.relation("category");
		    	relationCategory.add(categorySaved);

		    	let relationAuthor = fanpage.relation("author");
		    	relationAuthor.add(adminUser);

		    	fanpage.set("order", count);

		    	fanpage.set("posterId", resutlUser.id);

		    	fanpage.set("fanpageId", Math.floor(Math.random() * 100000));         

		    	return fanpage.save(null, {useMasterKey: true}); 	
		    }			    	            		

		}).then(function(fanpage) {	

			if ( iDUserType==2 || iDUserType==3 ) {

				fanpageSaved = fanpage;

				var queryConfig = new Parse.Query("Config");
				return queryConfig.first({useMasterKey:true});
			}

 		}).then(function(config) {	

 			if ( iDUserType==2 || iDUserType==3 ) {

	            var master = config.get("master_key"); 
				var configRelation = config.relation("images").query();
			    configRelation.ascending("createdAt");	
			    return configRelation.find({useMasterKey:true});

			}

		}).then(function(images) {	
		    
			if ( iDUserType==2 || iDUserType==3 ) {	

				let count = images.length;						

		    	for (var j=0; j <images.length; j++) {
			        					                
			        var fileImage = images[j];

			        var file = fileImage.get("image");
			        var name = fileImage.get("name");

			        var Albums = Parse.Object.extend("Albums");	 		
		    		let album = new Albums();

					album.set("cover", file);		

					var fanpageId = fanpageSaved.get("fanpageId");

		    		album.set("referenceId", fanpageId);
		    		album.set("name", name);

		    		albumsArray.push(album);

		    		if (j==(count-1)) {	
		    			return Parse.Object.saveAll(albumsArray,  {useMasterKey: true});
		    		}	    		
		    	}	  
		    }

	    }).then(function() {	

	    	
			if ( iDUserType==2 || iDUserType==3 ) {		    	

		    	var albumRelation = fanpageSaved.relation("albums");

	    		for (var j=0; j <albumsArray.length; j++) {

	    			if ( albumsArray[j].get("name").indexOf("image_") >= 0 )  {

						albumRelation.add(albumsArray[j]);	
					}
	    		}

	    		return fanpageSaved.save(null, {useMasterKey: true});

	    	}

    	}).then(function(fanpageReSaved) {	

    		var Notification = Parse.Object.extend("Notifications");         
	        var notification = new Notification();		        						

		    notification.set("posterName", resutlUser.get("Name"));
		    notification.set("posterAvatar", resutlUser.get("picture"));		    	

			var ftitle = "Welcome " + resutlUser.get("Name") + " !!";

		    notification.set("title", ftitle);
    		notification.set("description", fanpageReSaved.get("pageAbout"));
    		notification.set("cover", fanpageReSaved.get("pageCover"));	    		
    		notification.set("referenceId", fanpageReSaved.get("fanpageId"));
    		notification.set("date", fanpageReSaved.get("createdAt"));
    		notification.set("fanpage", fanpageReSaved); 
    		notification.set("type", 2);

    		return notification.save(null, {useMasterKey: true});

		}).then(function(object) {

    		if ( iDUserType==2 || iDUserType==3 ) {	

    			response.success(resutlUser); 
    		}

	    }, function(error) {	    

	        response.error(error);

	    });	

	});







	

	