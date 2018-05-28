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

	Parse.Cloud.define("setUserAdmin", function(request, response) {
	    
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

	var _ = require("underscore");

	Parse.Cloud.define("subscribeUsersToChannel", function( request, response ) {
		
		var userIds = request.params.userIds;
		var channelName = request.params.channel;

		_.each(userIds, function(userId) {

			subscribeSingleUserToChannel(userId, channelName, response);

		});
	  
	});


	// --
	// SubscribeMeToChannel

	Parse.Cloud.define("subscribeUserToChannel", function( request, response ) {
		
		var userId = request.params.userIds;
		var channelName = request.params.channel;	
	  
		subscribeSingleUserToChannel(userId, channelName, response);
		
	});


	// --
	// Generic Method for User Subscription

	function subscribeSingleUserToChannel(userId, channelName, response)
	{
	  
		if (!channelName) 
		{
			response.error("Missing parameter: channel")
			return;
		}

		if (!userId) 
		{
			response.error("Missing parameter: userId")
			return;
		}

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
				      response.success(true);
				    },
				    error: function(error) {
				      // An error occurred while saving one of the objects.
				      console.error(error);
				      response.error("An error occurred while updating this user's installations.")
				    },
				  });

			}, error:function(error)
	        {
	        	response.error(error);
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

	Parse.Cloud.define("getYoutubeVideoInfo", function( request, response ) {

		var videoId = request.params.videoId;
		var youtubedl = require('youtube-dl');	

		var video = youtubedl('http://www.youtube.com/watch?v='+videoId,
		  // Optional arguments passed to youtube-dl.
		  ['--format=18'],
		  // Additional options can be given for calling `child_process.execFile()`.
		  { cwd: __dirname });
		 
		// Will be called when the download starts.
		video.on('info', function(info) {
			//console.log('Download started');
			//console.log('filename: ' + info.filename);
			//console.log('size: ' + info.size);		
			// TOMAR SOLO LO NECESARIO
			response.success(info);		
		});

		video.on('error', function error(err) {
	    	console.log('error 2:', err);
	    	response.error(err);
	  	});

	});

	// --
	// Create S3 folder.

	Parse.Cloud.define("createS3Folder", function( request, response ) {

		var folder = request.params.folder;
		
		var now = new Date().getTime();
		var dummyfile = "download/school.txt";		    	

    	var path = require('path');
	    var s3 = require('s3');
	    
	    var s3key = "AKIAJP4GPKX77DMBF5AQ";
	    var s3secret = "H8awJQNdcMS64k4QDZqVQ4zCvkNmAqz9/DylZY9d";
	    var s3region = "us-east-1";  

	    var clientDownload = s3.createClient({
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

		var s3bucket = "gamves/"+folder;
	    var s3endpoint = s3bucket  + ".s3.amazonaws.com";      

		var paramsUploader = { localFile: dummyfile, s3Params: { Bucket: s3bucket, Key: dummyfile, ACL: 'public-read'},};

		var uploader = clientDownload.uploadFile(paramsUploader);

		uploader.on('error', function(err) { 
			//console.error("unable to upload:", err.stack); 

			response.error('Error! ' + "unable to upload: "  +  err.stack);
		});                
		
		uploader.on('progress', function() { console.log("progress", uploader.progressMd5Amount, uploader.progressAmount, uploader.progressTotal); });
		  
		uploader.on('end', function() {

			//callback({"s3bucket":s3bucket, "s3endpoint":s3endpoint});

			response.success({"s3bucket":s3bucket, "s3endpoint":s3endpoint});

		});  
	
	});


	

	