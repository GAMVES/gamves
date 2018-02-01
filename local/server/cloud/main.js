require('./functions');
require('./jobs');
require('./init');
require('./users');

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
	var folder = request.object.get("folder");


	if ( source_type == 1 ) { //LOCAL

		saveFanpage(request, function(){});

	} else if ( source_type == 2 ) { //YOUTUBE

		if (!removed && downloaded) {

			var ytb_videoId = request.object.get("ytb_videoId");
			var videoFile = "download/" + ytb_videoId + ".mp4";
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

							var paramsDownload =  {
								"ytb_videoId": vId,
						        "objectId": pfVideoId
						    };

							downloadVideo(paramsDownload, function(resutl){

								var videoName = resutl.videoName;
								var videoObject = resutl.videoObject;

								var thumbSource = videoObject.get("ytb_thumbnail_source");

								var paramsUpload =  {
									"videoName": videoName,
							        "folder" : folder 
							    };

								uploadVideo(paramsUpload, function(resutl){

									var s3bucket = resutl.s3bucket;
									var s3endpoint = resutl.s3endpoint;

									Parse.Cloud.httpRequest({url: thumbSource}).then(function(httpResponse) {
                  
				                       var imageBuffer = httpResponse.buffer;
				                       var base64 = imageBuffer.toString("base64");
				                       var file = new Parse.File(ytb_videoId+".jpg", { base64: base64 });                    
				                       var baseUrl = "https://s3.amazonaws.com/" + s3bucket; 
				                       var uploadedUrl = baseUrl + "/" + videoName; 

				                       videoObject.save({                             
				                          removed: false, 
				                          thumbnail: file,
				                          s3_source: uploadedUrl,
				                          downloaded: true,
				                          source_type: 2
				                        }, { useMasterKey: true } );   
				                                                            
				                  	}, function(error) {                    
				                      console.log("Error downloading thumbnail"); 
				                  	});

								});

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

function downloadVideo(params, callback ) {

	var ytb_videoId = params.ytb_videoId;
	var objectId = params.objectId;

    var queryVideos = new Parse.Query("Videos");
    queryVideos.equalTo("objectId", objectId);

    queryVideos.find().then(function(results) {

    	if( results.length > 0) 
        {
            var videoObject = results[0];
            var fs = require('fs');
            var youtubedl = require('youtube-dl');
            var video = youtubedl('http://www.youtube.com/watch?v='+ytb_videoId, ['--format=18'], { cwd: __dirname });             
            var videoName = "download/" + ytb_videoId + '.mp4';

            video.pipe(fs.createWriteStream(videoName));

            video.on('end', function() { 
            	 
            	callback({"videoName":videoName, "videoObject":videoObject, });

	        });   
       }	  

    }, function(error) {	    

        response.error(error);

    });	


};

function uploadVideo(params, callback) {

	var folder = params.folder;
	var videoName = params.videoName;

	var path = require('path');
    var s3 = require('s3');
    
    var s3key = "AKIAJP4GPKX77DMBF5AQ";
    var s3secret = "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";
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

	var s3bucket = "gamves/"+folder+"/videos";
    var s3endpoint = s3bucket  + ".s3.amazonaws.com";      

	var paramsUploader = { localFile: videoName, s3Params: { Bucket: s3bucket, Key: videoName, ACL: 'public-read'},};

	var uploader = clientDownload.uploadFile(paramsUploader);

	uploader.on('error', function(err) { console.error("unable to upload:", err.stack); });                
	uploader.on('progress', function() { console.log("progress", uploader.progressMd5Amount, uploader.progressAmount, uploader.progressTotal); });
	  
	uploader.on('end', function() {

		callback({"s3bucket":s3bucket, "s3endpoint":s3endpoint});

	});  
};

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



Parse.Cloud.afterSave("Approvals", function(request) {

	var approved = request.object.get("approved");
	var notified = request.object.get("notified");

	var type = request.object.get("type");
	var posterId = request.object.get("posterId");
	var title = request.object.get("title");
	var referenceId = request.object.get("referenceId");
	var familyId = request.object.get("familyId");	
	

	if (approved==1 && !notified) { 

		var Notification = Parse.Object.extend("Notifications");         
        var notification = new Notification();	

        var dataPush = [];

		var userQuery = new Parse.Query(Parse.User);
		userQuery.equalTo("objectId", posterId);
	    userQuery.first().then(function(user) {

	    	notification.set("posterName", user.get("Name"));
	    	notification.set("posterAvatar", user.get("picture"));

	    	if (type == 1) {

	    		var vtitle = "New video from " + user.get("Name");
	    		dataPush.push(vtitle);

		        var videoQuery = new Parse.Query("Videos");
		        videoQuery.equalTo("videoId", referenceId);
		        return videoQuery.first();

		    } else if (type == 2) {

		    	var ftitle = "New fanpage from " + user.get("Name");
		    	dataPush.push(ftitle);

		    	var fanpagelQuery = new Parse.Query("Fanpages");
		        fanpagelQuery.equalTo("fanpageId", referenceId);
		        return fanpagelQuery.first();
		    }

	    }).then(function(object) {

	    	if (type == 1) { //Video

				notification.set("title", object.get("title"));
	    		notification.set("description", object.get("description"));	    		
	    		notification.set("cover", object.get("thumbnail"));
	    		notification.set("referenceId", object.get("videoId"));
	    		notification.set("date", object.get("createdAt"));
	    		notification.set("video", object);

	    	} else if (type == 2) { //Fanpage

	    		notification.set("title", object.get("pageName"));
	    		notification.set("description", object.get("pageAbout"));
	    		notification.set("cover", object.get("pageCover"));	    		
	    		notification.set("referenceId", object.get("fanpageId"));
	    		notification.set("date", object.get("createdAt"));
	    		notification.set("fanpage", object);
	    	}

	    	notification.set("type", type);

	    	return notification.save(null, {useMasterKey: true});

		}).then(function(notificationSaved) {

			var familyQuery = new Parse.Query("Family");
	        familyQuery.equalTo("objectId", familyId);
	        return familyQuery.first();

	    }).then(function(family) {	

	    	var levelRelation = family.relation("level").query();
	        return levelRelation.find();

	    }).then(function(levels) {	

			var title = dataPush[0];
			var alert = "this is an alert";
			var level = levels[0];
			var channels = level["id"];
			var data = "";

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
		            
		        	notification.set("notified", true);		            
		            notification.save(null, {useMasterKey: true});

		        },
		        error: function (error) {
		            //response.error('Error! ' + error.message);
		            console.log('Error: ' + error.message);
		        }
		    });


	    }, function(error) {	    

	        response.error(error);

	    });		
	}

});

