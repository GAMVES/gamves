	/*
	* Cloud Code 
	*/

	// -- Send push notification.

	Parse.Cloud.define("push", function (request, response) {
	    
		var title = request.params.title;
		var alert = request.params.alert;
		var channels = request.params.channels;
		var data = request.params.data;

	    Parse.Push.send({
	        channels:[channels],
	        data: {
	          "title": title,
	          "alert": alert,
	          "data": data
	        }
	    }, {
	        useMasterKey: true,
	        success: function () {
	            response.success('Success!');
	        },
	        error: function (error) {
	            response.error('Error! ' + error.message);
	        }
	    });

	});
	
	// --
	// Set user to admin role.

	Parse.Cloud.define("setUserAdminRole", function(request, response) {
	    
	    console.info("llega");
	    var user;
	    var userQuery = new Parse.Query(Parse.User);

	    return userQuery.get(request.userId).then(function(result) {

	        user = result;
	        var roleQuery = new Parse.Query(Parse.Role);
	        roleQuery.equalTo("name", "admin");
	        roleQuery.equalTo("users", request.user);

	        return roleQuery.first();

	    }).then(function(role) {

	        if (!role) 
	        {
	            return Parse.Promise.error("only admins can add admins");
	        }
	        
	        Parse.Cloud.useMasterKey();
	        var relation = role.relation("users");
	        relation.add(user);
	        
	        return role.save();

	    }).then(function(result) {

	        response.success(result);

	    }, function(error) {

	        response.error(error);

	    });
	});


	// --
	// Subscribe users array to channels for new chat. 	

	Parse.Cloud.define("subscribeUsersToChannel", function( request, response ) {
		
		var userIds = request.params.userIds;
		var channelName = request.params.channel;
		var chatObjectId = request.params.chatObjectId;		
		var removeId = request.params.removeId;		

		var chatOfRole = "chatOf___" + chatObjectId;

		console.log("chatOfRole: " + chatOfRole );

		Parse.Cloud.run("AddRoleByName", { "name":chatOfRole, "chatObjectId":chatObjectId, "removeId":removeId}).then(function(chatRolePF) {	

			for (var i=0; i<userIds.length; i++) {
	                
	            var userId = userIds[i];													

				Parse.Cloud.run("AddUserToRole", { "userId": userId, "role": chatOfRole }).then(function(result) {      							

					Parse.Cloud.run("AddRoleToObject", { "pclassName": "ChatFeed", "objectId": chatObjectId, "role" : chatOfRole });

					subscribeSingleUserToChannel(userId, channelName, function(callback){

						if (callback) {

							response.success(true);

						} else {

							response.error(callback);
						}
					});
				});
			}
		});	
	});


	// --
	// Generic Method for User Subscription

	function subscribeSingleUserToChannel(userId, channelName, callback)
	{	  

		var userQuery = new Parse.Query(Parse.User);
		userQuery.equalTo("objectId",  userId);
		
		// Find devices associated with these users
		var installationQuery = new Parse.Query(Parse.Installation);
		installationQuery.matchesQuery("user", userQuery);

		installationQuery.find({
			useMasterKey: true,
			success: function(installations) {

				var collect = installations.length;

				for (var i = 0; i < installations.length; ++i) 
				{
					installations[i].addUnique("channels", channelName);
				}

				  // Save all the installations
				  Parse.Object.saveAll(installations, {
				    success: function(installations) {
				      // All the installations were saved.
				      callback(true);
				    },
				    error: function(error) {
				      // An error occurred while saving one of the objects.
				      console.error(error);
				      callback("An error occurred while updating this user's installations.")
				    },
				  });

			}, error:function(error)
	        {
	        	callback(error);
	            console.error("pushQuery find failed. error = " + error.message);
	        }
		});
	}

	// --
	// Save images for user

	Parse.Cloud.define("saveImageForUser", function( request, response ) {
		
		var userId = request.params.userId;
		var image_64 = request.params.image;
		var imagename = request.params.imagename;
		console.info("userId: " + userId + " imagename: " + imagename + " image64: " + image_64);

		var userQuery = new Parse.Query(Parse.User);
		userQuery.equalTo('objectId', userId);

		userQuery.find({
			useMasterKey: true,
			success: function(user) 
			{

				var imageFile = new Parse.File(imagename,image);
				
				imageFile.save(null, {useMasterKey: true})
			    .then(
			        function() {    

			        	var data = {
	        				image64: image_64.buffer.toString('base64')
	    				};    

			            user.set("picture", data);
						
						user.save(null, { useMasterKey: true } );

					    response.success(true);		            	   	

			        }, 
			        function(error) {
			            response.error(error.message);
			        }
			    );			
			
			}, error:function(error)
	        {
	        	response.error(error);
	            console.error("pushQuery find failed. error = " + error.message);
	        }

	     });
	});

	// --
	// Get Video Info.

	Parse.Cloud.define("GetYoutubeVideoInfo", function( request, response ) {		

		var videoId = request.params.videoId;

		Parse.Cloud.httpRequest({											
		
			url: "http://gamves-download.herokuapp.com/api/youtube-video-info", 								
			method: "POST",						  	
		  	body:  {								        
		        "ytb_videoId" : videoId						        		        
		    }

		}).then( function(httpResponse) {

			console.log("VIDEO DOWNLOADING " + httpResponse.text);			

			response.success(JSON.parse(httpResponse.text));	


		},function(httpResponse) {							  
		
			console.log("ERROR DOWNLOADING : " + httpResponse.status);			  	

			response.error(httpResponse.status);
		
		});

	});

	// --
	// Create S3 folder.

	Parse.Cloud.define("CreateS3Folder", function( request, response ) {		

		var s3folder = request.params.folder;	
		
		var filepath = s3folder + ".txt";    	
		var fs = require('fs');

		var fileContent = "School folder for " + s3folder + ". ";		
		
		fs.writeFile(filepath, fileContent, { flag: 'w' }, function(err) {	

		    if (err) {
		    	
		    	response.error('Error! ' +  err);

		    } else {

		    	//console.log("The file was succesfully saved!");	
		    	//createS3FolderWithFile(s3folder, filepath, response);		    	

		    	var path = require('path');
			    var s3 = require('s3');
			    
			    var s3key = "AKIAJP4GPKX77DMBF5AQ";
			    var s3secret = "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";
			    var s3region = "us-east-1";  

			    var clientCreate = s3.createClient({
			      maxAsyncS3: 20,     // this is the default
			      s3RetryCount: 3,    // this is the default
			      s3RetryDelay: 1000, // this is the default
			      multipartUploadThreshold: 20971520, // this is the default (20 MB)
			      multipartUploadSize: 15728640, // this is the default (15 MB)
			      s3Options: {
			        accessKeyId: s3key,
			        secretAccessKey: s3secret,
			        region: s3region,
			      },
			    });   		

			    var bucketName = "gamves";	 

			    //console.log(err, err.stack); // an error occurred

			  	var s3bucket = bucketName + "/" + s3folder;
			    var s3endpoint = s3bucket  + ".s3.amazonaws.com";      

				var paramsUploader = { localFile: filepath, s3Params: { Bucket: s3bucket, Key: filepath, ACL: 'public-read'}, };

				var uploader = clientCreate.uploadFile(paramsUploader);

				uploader.on('error', function(err) { 

					response.error('Error! ' + "unable to upload: "  +  err.stack);
				});                
				
				//uploader.on('progress', function() { console.log("progress", uploader.progressMd5Amount, uploader.progressAmount, uploader.progressTotal); });
				  
				uploader.on('end', function() {			

					response.success({"s3bucket":s3bucket, "s3endpoint":s3endpoint});

				});
				
		    }
		    
		});
	
	});
	

	function savePointByUserId(userId, points) {
		console.log("savePointByUserId");
		var Points = Parse.Object.extend("Points");
		var point = new Points();
		point.set("userId", userId);
		point.set("points", points);		
		point.save();  
	}

	