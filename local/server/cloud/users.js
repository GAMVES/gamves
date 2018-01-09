	/*
	* Cloud Code 
	*/

	// -- Add Gamves User as Family from Registrant

	//var http = require('http-get');

	var request_promise = require('request-promise');
	var concat = require('concat-stream');
	var fs   = require('fs');

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

				resutlUser = userSaved;
			
		    	var files = [
		    		"https://s3.amazonaws.com/gamves/images/universe.jpg",
		    		"https://s3.amazonaws.com/gamves/images/image_0.jpg",
		    		"https://s3.amazonaws.com/gamves/images/image_1.jpg",
		    		"https://s3.amazonaws.com/gamves/images/image_2.jpg",
		    		"https://s3.amazonaws.com/gamves/images/image_3.jpg",
		    		"https://s3.amazonaws.com/gamves/images/image_4.jpg"
		    	];

		    	
			    var dataArray=[];
			    var promises=[];

			    for (var i = 0; i <files.length; i++) {			        	        
			        let req = request_promise(files[i]);					
					var write = concat(function(data) {						      					
						dataArray.push(data);					
					});
					req.pipe(write);
					promises.push(req);
			    }

			    Promise.all(promises).then(function() {

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

			    	fanpage.save(null, { useMasterKey: true}, {
			              success: function (fanpageSaved) {        
			                 
			                  var albumRelation = fanpageSaved.relation("albums");

						    	for (var j=0; j < dataArray.length; j++) {
						    		
						    		var fanpageId = Math.floor( Math.random() * 100000);			    		
							        					                
							        var fileImage = new Parse.File("image.jpg",  dataArray[i] ); // { base64: base64 });

							        var Albums = Parse.Object.extend("Albums");	 		
						    		let album = new Albums();
									album.set("cover", fileImage);
									album.save(null, {useMasterKey: true});
						    					    		
						    		album.set("fanpageId",fanpageId);
						    		album.save(null, {useMasterKey: true});

						    		albumRelation.add(album);

						    	}

						    	fanpageSaved.save(null, {useMasterKey: true});

			    				response.success(resutlUser);                  
			                                                                                                    
			              },
			              error: function (error) {
			                  response.error(error);
			              }
			         });

			    });
			 
			 } else {

			 	response.success(userSaved);

			 }


	    }, function(error) {

	        response.error(error);

	    });		

	});


	

	

	/*var _ = require('underscore');

	function fileFromUrl(url, name) {
	    return Parse.Cloud.httpRequest({url: url}).then(function(httpResponse) {
	        var imageBuffer = httpResponse.buffer;
	        var base64 = imageBuffer.toString("base64");
	        var file = new Parse.File(name, { base64: base64 });
	        return file.save().then(function() { return file; });
	    }, function(error) {
	        return null; 
	    });
	}

	function filesFromUrls(urls) {
	    var promises = _.map(urls, function (url, index) {
	        return fileFromUrl(url, ''+index);
	    });
	    return Parse.Promise.when(promises).then(function() {
	        return _.toArray(arguments);
	    });
	}

	function convertUrlsToFilesForAlbums(images) {
	  	return filesFromUrls(images).then(function(files) {
	  		var albumsPF = [];
	  		var Albums = Parse.Object.extend("Albums");	
	  		var length = file.length - 1;
	  		for (var i=0; i<length; i++) {
	  			var file = files[i];
	    		let album = new Albums();
				album.set("cover", file);
				album.save(null, {useMasterKey: true});
				albumsPF.push(album);
	  		}
	        return [albumsPF,files[0]];
	    });
	}*/

	