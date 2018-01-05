require('./functions')
require('./jobs')
require('./init')
require('./users')

/*
* If you want to use Advanced Cloud Code,
* exporting of module.exports.app is required.
* We mount it automaticaly to the Parse Server Deployment.
* If you don't want to use it just comment module.exports.app
*/
module.exports.app = require('./app')

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

	} else {
		console.info("createBadgeForUser");
		var userId = members.replace(/"/g, '');
		createBadgeForUser(chatId, lastPoster, userId);
	}

	function createBadgeForUser(chatId, lastPoster, userId) {

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
// Delete downloaded file after saved. 

Parse.Cloud.afterSave("Videos", function(request) {

	
	var downloaded = request.object.get("downloaded");
	var removed = request.object.get("removed");
	var source_type = request.object.get("source_type");


	if ( source_type == 1 ) { //LOCAL

		saveFanpage(request, function(){});

	} else if ( source_type == 2 ) { //YOUTUBE

		if (!removed && downloaded) {

			var ytb_videoId = request.object.get("ytb_videoId");
			var videoFile = ytb_videoId + ".mp4";
			var fs = require('fs'); 
		    fs.unlinkSync(videoFile);
		    if ( !fs.existsSync(videoFile) ) {	      	
		    	request.object.save({ removed : true }, { useMasterKey: true,
			        success: function (response) {
			            response.success(response);
			        },
			        error: function (error) {
			            response.error('Error! ' + error.message);
			        }
			    });
		    } else {
				//DO SOMETHING!! The file has not been removed.
			}

		} else if (!removed && !downloaded) {

			//-- Save video relation into fanpage

			saveFanpage(request, function() {

				var queryConfig = new Parse.Query("Config");				   
			    queryConfig.find({
			        useMasterKey: true,
			        success: function(results) {

			        	if( results.length > 0) 
			        	{

							var configObject = results[0];
							
							var serverUrl = configObject.get("server_url");
							var _appId = configObject.get("app_id");
							var _mKey = configObject.get("master_key");

							var vId       = request.object.get("ytb_videoId");
							var pfVideoId = request.object.id;
						    
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
						          console.log(httpResponse);			 
						      },
						      error: function(httpResponse) {
						          console.log('Error! ' + httpResponse);
						      }

						    });
					    } 
			        },
			        error: function(error) {						            
			            console.log(error);
			        }
			    });  

			});		
		
		} 
	}

});


function saveFanpage(request, callback) {

	var query = new Parse.Query("Fanpages");
	var fanpageId = request.object.get("fanpageObjId");
    query.equalTo("objectId", fanpageId);	   
    
    query.find({
        useMasterKey: true,
        success: function(results) {
        	
        	if( results.length > 0) {
				
				var fanpageObject = results[0];
				console.info("feedObject: " + fanpageObject);
	        	var videoRelation = fanpageObject.relation("videos");
	        	videoRelation.add(request.object);		        	

	        	fanpageObject.save(null, { useMasterKey: true,
                    success: function () {              	                          	
                    	callback();
                    },
                    error: function (error) {
                        console.log('Error! ' + error.message);
                    }
                });   		            
		    } 
        },
        error: function(error) {	            
            console.log(error);
        }
    });
}


// --
// Save Config download image for poster

Parse.Cloud.afterSave("Config", function(request) {

	var app_icon_url = request.object.get("app_icon_url");
	var hasIcon = request.object.get("hasIcon");

	if (!hasIcon) {
		Parse.Cloud.httpRequest({url: app_icon_url}).then(function(httpResponse) {
	                    
		     var imageBuffer = httpResponse.buffer;
		     var base64 = imageBuffer.toString("base64");
		     var file = new Parse.File("gamves.png", { base64: base64 });                    
		     
		     request.object.set("app_thumbnail", file);
		     request.object.set("hasIcon", true);

		     request.object.save(null, { useMasterKey: true } );

		});	
	}	
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

