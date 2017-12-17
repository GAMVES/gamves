	/*
	* Cloud Code 
	*/

	// -- Add Gamves User as Family from Registrant

	Parse.Cloud.define("createGamvesUser", function (request, response) {

		var objects = [];

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
	        
	        var user_name = request.params.user_name;
	        var user_user_name = request.params.user_user_name;
	    	var user_password = request.params.user_password;
	    	var firstName = request.params.firstName;
	    	var lastName = request.params.lastName;
	    	var iDUserType = request.params.iDUserType;
	    

	        var dataPhotoImage = request.params.dataPhotoImage;
	    	var file = new Parse.File(firstName+".png", dataPhotoImage, "image/png");

	    	var dataPhotoImageSmall = request.params.dataPhotoImageSmall;
	    	var fileSmall = new Parse.File(firstName+"Small.png", dataPhotoImageSmall, "image/png");

	    	var levelObj = request.params.levelObj;
			var userTypeObj = request.params.userTypeObj;	
	    
			var user = new Parse.User();
			
			user.set("username", user_name);
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
			}		

			let relationType = user.relation("userType")
		    relationType.add(objects[0]);

		    let relationLevel = user.relation("level")
		    relationLevel.add(objects[1]);

		    return user.signUp(null, {useMasterKey: true});
		
	    }).then(function(userSaved) {

	    	var adminRole = objects[2];

	    	adminRole.add(userSaved);

	    	adminRole.save(null, {useMasterKey: true});

	        response.success(userSaved);

	    }, function(error) {

	        response.error(error);

	    });		

	});

	