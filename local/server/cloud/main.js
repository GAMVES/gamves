require('./functions')
require('./jobs')

/*
* If you want to use Advanced Cloud Code,
* exporting of module.exports.app is required.
* We mount it automaticaly to the Parse Server Deployment.
* If you don't want to use it just comment module.exports.app
*/
module.exports.app = require('./app')

Parse.Cloud.define("hello", function( request, response ) {
	response.success("hola mundo");
});

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

        // here's our defense against mischief: find the admin role
        // only if the requesting user is an admin

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
// Update or create Budges

Parse.Cloud.afterSave("ChatVideo", function(request) {

	console.info("_________________________________________________________");

	var object = request.object;

	var userId = object.get("userId");
	var chatId = object.get("chatId");
	var message = object.get("message");

	console.info("userId: " + userId + " chatId: " + chatId + " message: " + message);

	var query = new Parse.Query("ChatFeed");
    query.equalTo("chatId", chatId);
   
    query.find({
        useMasterKey: true,
        success: function(results) {

        	if( results.length > 0) 
        	{

				var feedObject = results[0];

				console.info("feedObject: " + feedObject);

	        	var chatRelation = feedObject.relation("chats");
	        	chatRelation.add(object);

	            feedObject.set("lastMessage", message);
	            feedObject.set("lastPoster", userId);

	            feedObject.save(null, { useMasterKey: true } );

		    } 

        },
        error: function(error) {
            error.message("ChatFeed lookup failed");
            response.error(error);
        }

    });
});

// --
// Update or create Budges

Parse.Cloud.afterSave("ChatFeed", function(request) {

	var members = request.object.get("members");
	var chatId = request.object.get("chatId");
	var lastPoster = request.object.get("lastPoster");

	console.info("members: " + members + " chatId: " + chatId + " lastPoster: " + lastPoster);
	
	if (members.includes(","))
	{

		console.info("createBadgeForUsers");

		members = members.substr(1).slice(0, -1);
		members = members.replace(/ /g, '');
		var arrayMembers = members.split(",");	
		
		//createBadgeForUsers(chatId, lastPoster, arrayMembers);

		for (var i = 0; i < arrayMembers.length; ++i) 
		{
			var bUserId = arrayMembers[i];

			var userId = bUserId.replace(/"/g, '');

			createBadgeForUser(chatId, lastPoster, userId);

			//var matchLastPoster = '"' + lastPoster.toString() + '"';

			//if ( bUserId == matchLastPoster )
			//{
				//console.info("ENTRA: " + bUserId);
				//createBadgeForUser(chatId, lastPoster, userId);
			//}
		}

	} else
	{

		console.info("createBadgeForUser");

		var userId = members.replace(/"/g, '');

		createBadgeForUser(chatId, lastPoster, userId);

	}

	function createBadgeForUser(chatId, lastPoster, userId)
	{

		console.info("*************************************");
		console.info("userId: " + userId + " chatId: " + chatId + " lastPoster: " + lastPoster);

	    var query = new Parse.Query("Badges");
	    query.equalTo('chatId', chatId);
	    query.equalTo('userId', userId);

	    var _userId = userId;
	    var _chatId = chatId;
	    var _lastPoster = lastPoster;

	    query.find({
	        useMasterKey: true,
	        success: function(results) {

	            console.info("RESULTS::::: " + results.length);

	            if ( results.length == 0 ) 
	            {

	            	var Badges = Parse.Object.extend("Badges");

					var badge = new Badges();

					console.info("_userId: " + _userId);
					console.info("_chatId: " + _chatId);
					
					badge.save({
	                    userId: _userId,
	                    chatId: _chatId,
	                    seen: true,
	                    amount: 0
	                }, {
	                    success: function(result) {
	                        console.info(result);
	                    },
	                    error: function(error) {
	                        console.info(error);
	                    }
	                });

	            } else 
	            {
					console.info("entra");
	            	console.info("_userId: " + _userId);
					console.info("_chatId: " + _chatId);

	            	var lastAmount = results[0].get("amount");

					//var userId = results.get("userId");

					var matchUserId = _userId.toString();

					var matchLastPoster = '"' + _lastPoster.toString() + '"';

					console.info( "matchUserId: " + matchUserId + " matchLastPoster: " + matchLastPoster );

					var finalAmount = 0;
					var seen = false;

					if ( matchUserId != matchLastPoster )
					{
						lastAmount++;
					} else 
					{
						seen = true;
					}

					finalAmoun = lastAmount;
            		
					results[0].save({
	                    userId: _userId,
	                    chatId: _chatId,
	                    seen: seen,
	                    amount: finalAmoun
	                }, {
	                    success: function(result) {
	                        console.info(result);
	                    },
	                    error: function(error) {
	                        console.info(error);
	                    }
	                });

	            }

	        },
	        error: function(error) {
	        	console.error("ERRROORRR");
	            console.error(error);
	        }
	    });

	}

});


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
// Run job to download video. 

var _appId      = '0123456789';
var _mKey       = "9876543210";

Parse.Cloud.define("postDownloadVideoJob", function( request, response ) {

	var serverUrl = request.params.serverUrl;
	var vId       = request.params.ytb_videoId;
	var pfVideoId = request.params.pfVideoId;
    
    Parse.Cloud.httpRequest({
      method: "POST",
      url: serverUrl + "jobs/downloader",
      headers: {
	    	"X-Parse-Application-Id": _appId,
	    	"X-Parse-Master-Key": _mKey,
	    	"Content-Type": "application/json"
	  },
      body: {
        "ytb_videoId": vId,
        "objectId": pfVideoId            
      },	      
      success: function(httpResponse) {          
          response.success();			 
      },
      error: function(httpResponse) {
          response.error("failed");
      }
    });  
});

// --
// Delete downloaded file after saved. 

Parse.Cloud.afterSave("Videos", function(request) {

	var downloaded = request.object.get("downloaded");
	var removed = request.object.get("removed");

	if (!removed && downloaded) {

		var ytb_videoId = request.object.get("ytb_videoId");

		var queryConfig = new Parse.Query("Config"); 
	    queryConfig.first({	   
	    	useMasterKey: true,     
	        success: function(result) {          

	       	  	var serverUrl = result.get("server_url");
	       	  	var _appId = result.get("app_id");
	       	  	var _mKey = result.get("master_key");
	       	  	var localVideo = serverUrl + ytb_videoId + ".mp4";

				/*Parse.Cloud.httpRequest({
			      method: "DELETE",
			      url: localVideo,
			      headers: {
			    	"X-Parse-Application-Id": _appId,
			    	"X-Parse-Master-Key": _mKey,
			    	"Content-Type": "application/json"
			  	  },	      
			      success: function(httpResponse) {
			          	console.info('Delete succeeded  ' + httpResponse.text);
			           	request.set("removed", true);
	            		request.save(null, { useMasterKey: true } );
			      },
			      error: function(httpResponse) {
			           console.info('Delete failed  ' + localVideo);
			      }
			    }); */

			    var fs = require('fs'); 
			    fs.unlinkSync(ytb_videoId + ".mp4");

	          
			}
		});	

	}
	

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
		response.success(info);		
	});

	video.on('error', function error(err) {
    	console.log('error 2:', err);
    	response.error(err);
  	});

});


Parse.Cloud.define("downloadVideoFromYoutube", function( request, response ) {

	//var members = request.object.get("members");
	//var chatId = request.object.get("chatId");
	//var lastPoster = request.object.get("lastPoster");

	var videoId = request.params.videoId;

	var fs = require('fs');
	var youtubedl = require('youtube-dl');
	var video = youtubedl('http://www.youtube.com/watch?v='+videoId,
	  // Optional arguments passed to youtube-dl.
	  ['--format=18'],
	  // Additional options can be given for calling `child_process.execFile()`.
	  { cwd: __dirname });
	 
	// Will be called when the download starts.
	video.on('info', function(info) {
	  console.log('Download started');
	  console.log('filename: ' + info.filename);
	  console.log('size: ' + info.size);
	});
	 
	video.pipe(fs.createWriteStream('myvideo.mp4'));

	video.on('end', function() {
	  
	  console.log('finished downloading!');

	  var params = {
		  localFile: "myvideo.mp4",
		  s3Params: {
		    Bucket: "gamves.videos",
		    Key: "myvideo.mp4",
		    // other options supported by putObject, except Body and ContentLength.
		    // See: http://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/S3.html#putObject-property
		  },
		};

		var uploader = client.uploadFile(params);
		uploader.on('error', function(err) {
		  console.error("unable to upload:", err.stack);
		});
		uploader.on('progress', function() {
		  console.log("progress", uploader.progressMd5Amount,
		            uploader.progressAmount, uploader.progressTotal);
		});
		uploader.on('end', function() {
		  console.log("done uploading");
		});


	});
  
});

Parse.Cloud.define("uploadVideoToS3", function( request, response ) {

	var video = request.params.video;

	var params = {
		  localFile: video,
		  s3Params: {
		    Bucket: "gamves.videos",
		    Key: video,
		    // other options supported by putObject, except Body and ContentLength.
		    // See: http://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/S3.html#putObject-property
		  },
		};

		var uploader = client.uploadFile(params);
		uploader.on('error', function(err) {
		  console.error("unable to upload:", err.stack);
		});
		uploader.on('progress', function() {
		  console.log("progress", uploader.progressMd5Amount,
		            uploader.progressAmount, uploader.progressTotal);
		});
		uploader.on('end', function() {
		  console.log("done uploading");
		});

});


/*Parse.Cloud.define("saveImageForUser", function( request, response ) {
	
	var userId = request.params.userId;

	var image = request.params.image;
	var imagename = request.params.imagename;

	var imageSmall = request.params.imageSmall;
	var imagesmallname = request.params.imagesmallname;

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

		            //response.success(1);

		            var imageFileSmall = new Parse.File(imagesmallname,imageSmall)
		            imageFileSmall.save(null, {useMasterKey: true})
				    .then(
				        function() {

				        	user.set("picture", image);
							user.set("pictureSmall", imageSmall);
							user.save(null, { useMasterKey: true } );

				        	response.success(true);

						}, 
				        function(error) {
				            response.error(error.message);
				        }
				    );	   	

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

});*/







