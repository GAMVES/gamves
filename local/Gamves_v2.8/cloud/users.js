	/*
	* Cloud Code 
	*/

	// -- Add Gamves User as Family from Registrant	

	//var moment = require('moment');

	Parse.Cloud.define("createGamvesUser", function (request, response) {

		var objects = [];
		var resutlUser;
		var fanpageSaved;
		var albumsArray = [];
		var profile;
		var categorySaved;
		var adminUser;
		var notificationSaved;
		
		var iDUserType = request.params.user_type;

		var userQuery = new Parse.Query(Parse.User);
		userQuery.equalTo("username", "gamvesadmin");
		
	    return userQuery.first().then(function(admin) {

	    	//console.log("--1--");

	    	adminUser = admin;

			var typeQuery = new Parse.Query("UserType");	
	        return typeQuery.get(request.params.userTypeObj);

	    }).then(function(typeObj) {   

	    	//console.log("--2--");

	        objects.push(typeObj);             

	        var levelQuery = new Parse.Query("Level");
	        levelQuery.equalTo("objectId", request.params.levelObj);
	        return levelQuery.first();

	    }).then(function(levelObj) {

	    	//console.log("--3--");

	    	objects.push(levelObj);       

	    	var queryRole = new Parse.Query(Parse.Role);
			queryRole.equalTo('name', 'admin');
			return queryRole.first({useMasterKey:true});

	    }).then(function(roleObj) {

	    	//console.log("--4--");

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

			//console.log("--5--");

			profile = profileObj;               

	        var user_name 		= request.params.user_name;	        
	        var user_email 		= request.params.user_email;
	    	var user_password 	= request.params.user_password;
	    	var firstName 		= request.params.firstName;
	    	var lastName 		= request.params.lastName;

			console.log("Params : " +
				request.params.user_name  		+ " - " +  
				request.params.user_email 		+ " - " + 
				request.params.user_password 	+ " - " + 
				request.params.firstName  		+ " - " + 
 				request.params.lastName);	    	

	    	//console.log("--5a--");

	        var dataPhotoImage = request.params.dataPhotoImage;
	    	var file = new Parse.File(firstName+"picture.png", dataPhotoImage, "image/png");

	    	//console.log("--5b--");

	    	var dataPhotoImageSmall = request.params.dataPhotoImageSmall;
	    	var fileSmall = new Parse.File(firstName+"small.png", dataPhotoImageSmall, "image/png");

	    	//console.log("--5c--");

	    	var levelObj = request.params.levelObj;
			var userTypeObj = request.params.userTypeObj;				  
	    
			var user = new Parse.User();

			user.set("username", user_name);
			user.set("password", user_password);

			//console.log("--5d--");

			if (request.params.user_birthday) {
				let user_birthday = request.params.user_birthday;
				//let bdate = moment(user_birthday, "yyyy-MM-dd'T'HH:mm:ssZ");
				user.set("birthday", user_birthday);
			}

			//console.log("--5e--");
			
			user.set("name", firstName + " " + lastName);
		  	user.set("firstName", firstName);
		  	user.set("lastName", lastName);
			user.set("user_type", iDUserType);
			user.set("picture", file);
			user.set("pictureSmall", fileSmall);

			//console.log("--5f--");

			var lobjectId = objects[1].id;

			if (iDUserType==2 || iDUserType==3) { // only son and daughter				
				user.set("levelId", lobjectId);
				//Register			
			} else {				
				user.set("email", user_email);
			}			

			//console.log("--5g--");

			let relationType = user.relation("userType")
		    relationType.add(objects[0]);

		    let relationLevel = user.relation("level")
		    relationLevel.add(objects[1]);

		    var profileRelation = user.relation("profile");
			profileRelation.add(profileObj);			

		    return user.signUp(null, {useMasterKey: true} );		 
		
	    }).then(function(userSaved) {	    	        

	    	//console.log("--6--");

	    	resutlUser = userSaved;

	    	if ( iDUserType==2 || iDUserType==3 ) {

		    	var queryCategory = new Parse.Query("Categories");
				queryCategory.equalTo('name', 'PERSONAL');								    
				return queryCategory.first({useMasterKey:true});

	       	 } else {

			 	response.success(userSaved);
			 }

		}).then(function(categoryPF) {

			if ( iDUserType==2 || iDUserType==3 ) {					

				categorySaved = categoryPF;
			}

	    	profile.set("userId", resutlUser.id);

	    	Parse.Cloud.run("AddUserToRole", { "userId": resutlUser.id, "role": request.params.short});		

	    	return profile.save(null, {useMasterKey: true});
		
		}).then(function(profileSaved) {		

			//console.log("--7--");

			profile = profileSaved;		        

	    	var adminRole = objects[2];

	    	var adminRoleRelation = adminRole.relation("users");
			adminRoleRelation.add(resutlUser);		    	

	    	adminRole.save(null, {useMasterKey: true});	    	    	

	        return resutlUser.save(null, {useMasterKey: true});

		}).then(function(userSaved) {	 

			//console.log("--8--");

			resutlUser = userSaved;   	

			if ( iDUserType==2 || iDUserType==3 ) {			        	

			
	        	var Fanpages = Parse.Object.extend("Fanpages");
		    	var fanpage = new Fanpages();

		    	//console.log("--8a--");

		    	var dataPhotoImage = request.params.dataPhotoImage;
		    	var fileIcon = new Parse.File("icon.png", dataPhotoImage, "image/png");
		    	fanpage.set("pageIcon", fileIcon);

		    	//console.log("--8c--");

				var dataPhotoBackground = request.params.dataPhotoBackground;
		    	var fileCover = new Parse.File("background.png", dataPhotoBackground, "image/png");

				//console.log("--8d--");

		    	fanpage.set("pageCover", fileCover);

		    	var first_name = request.params.firstName;
		    	fanpage.set("pageName", first_name);

		    	//console.log("--8e--");

		    	var categoryName = categorySaved.get("name"); 

		    	//console.log("--8f--");
				
		    	fanpage.set("categoryName", categoryName);	

		    	fanpage.set("approved", true);

		    	//console.log("--8g--");

		    	var about =  request.params.firstName + "'s fanpage";

				fanpage.set("pageAbout", about);	    			    	

				let relationCategory = fanpage.relation("category");
		    	relationCategory.add(categorySaved);

		    	//console.log("--8h--");

		    	let relationAuthor = fanpage.relation("author");
		    	relationAuthor.add(adminUser);		    	

		    	//console.log("--8i--");

		    	fanpage.set("posterId", resutlUser.id);

		    	fanpage.set("fanpageId", Math.floor(Math.random() * 100000));         

		    	//console.log("--8j--");

		    	return fanpage.save(null, {useMasterKey: true}); 	
		    }			    	            		

		}).then(function(fanpagePF) {		

			//console.log("--9--");		

			if ( iDUserType==2 || iDUserType==3 ) {	        	     	

				fanpageSaved = fanpagePF;
				var queryConfig = new Parse.Query("Config");
				return queryConfig.first({useMasterKey:true});
			}

 		}).then(function(config) {	

 			//console.log("--10--");

 			if ( iDUserType==2 || iDUserType==3 ) { 				        	      	

	            var master = config.get("master_key"); 
				var configRelation = config.relation("images").query();
			    configRelation.ascending("createdAt");	
			    return configRelation.find({useMasterKey:true});

			}

		}).then(function(images) {	

			//console.log("--11--");
		    
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

					album.set("type", "Images");   			

		    		album.set("referenceId", fanpageId);
		    		album.set("name", name);

		    		albumsArray.push(album);

		    		if (j==(count-1)) {	
		    			return Parse.Object.saveAll(albumsArray,  {useMasterKey: true});
		    		}	    		
		    	}	  
		    }

	    }).then(function() {	

	    	//console.log("--13--");

	    	
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

    		//console.log("--14--");	

    		var Notification = Parse.Object.extend("Notifications");         
	        var notification = new Notification();		        						

		    notification.set("posterName", resutlUser.get("Name"));
		    notification.set("posterAvatar", resutlUser.get("picture"));		    		    	    	

			var ftitle = "<b>Welcome </b>" + resutlUser.get("Name") + " !!";
		    notification.set("title", ftitle);

		    let description = "Welcome to Gamves check out the amazing thins you can do"; 
		    notification.set("description", description);

    		//notification.set("description", fanpageReSaved.get("pageAbout"));

    		notification.set("target", [resutlUser.id]);  

    		//notification.set("cover", fanpageReSaved.get("pageCover"));	    		
    		notification.set("referenceId", fanpageReSaved.get("fanpageId"));
    		notification.set("date", fanpageReSaved.get("createdAt"));
    		notification.set("fanpage", fanpageReSaved); 
			notification.set("posterId", adminUser.id); 				

    		notification.set("type", 6);

    		return notification.save(null, {useMasterKey: true});

		}).then(function(notificationSavedPF) {		

			notificationSaved = notificationSavedPF;        

	        var imagesQuery = new Parse.Query("Images");
	        imagesQuery.equalTo("name", "welcome");
	        return imagesQuery.first();

	    }).then(function(imagePF) {

	    	//console.log("--15--");	

			let image = imagePF.get("image");

			notificationSaved.set("cover", image);	

			return notificationSaved.save(null, {useMasterKey: true});

		}).then(function(obj) {	

			//console.log("--16--");

    		if ( iDUserType==2 || iDUserType==3 ) {	    		

    			response.success(resutlUser); 
    		}

	    }, function(error) {	    

	    	//console.log("--17--");

	        response.error(error);

	    });

	});







	

	