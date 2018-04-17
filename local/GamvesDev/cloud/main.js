	require('./functions');
	require('./jobs');
	//require('./init');
	require('./users');

	/*
	* If you want to use Advanced Cloud Code,
	* exporting of module.exports.app is required.
	* We mount it automaticaly to the Parse Server Deployment.
	* If you don't want to use it just comment module.exports.app
	*/
	//module.exports.app = require('./app');


	// --
	// Run startup script

	Parse.Cloud.define("InitializeGamves", function(request, response) {

		var _admuser = "gamvesadmin";
		var query = new Parse.Query(Parse.User);
	    query.equalTo("username", _admuser);

	    query.find({
	        useMasterKey: true,
	        success: function(results) {

	        	if( results.length == 0 ) 
	        	{					

					var UserTypes = Parse.Object.extend("UserType");

					var t = "idUserType";
					var d = "description";

					var registerMother = new UserTypes();
					registerMother.set(t, 0);
					registerMother.set(d, "Register-Mother");
					registerMother.save();                         

					var spouseMother = new UserTypes();
					spouseMother.set(t, 1);
					spouseMother.set(d, "Spouse-Mother");
					spouseMother.save();

					var son = new UserTypes();
					son.set(t, 2);
					son.set(d, "Son");
					son.save();

					var daughter = new UserTypes();
					daughter.set(t, 3);
					daughter.set(d, "Daughter");
					daughter.save();

					var spouseFather = new UserTypes();
					spouseFather.set(t, 4);
					spouseFather.set(d, "Spouse-Father");
					spouseFather.save();

					var registerFather = new UserTypes();
					registerFather.set(t, 5);
					registerFather.set(d, "Register-Father");
					registerFather.save(); 

					var admin = new UserTypes();
					admin.set(t, -1);
					admin.set(d, "Administrator");					

					admin.save(null, {											
						success: function (adm) {		

							var app_icon_url = "https://s3.amazonaws.com/gamves/config/gamves.png";					

							Parse.Cloud.httpRequest({url: app_icon_url}).then(function(httpResponse) {
	                  
		                       	var imageBuffer = httpResponse.buffer;
		                       	var base64 = imageBuffer.toString("base64");
		                       	var iconFile = new Parse.File("gamves.png", { base64: base64 });                    
		                       
		                       	var user = new Parse.User();
								user.set("username", _admuser);
								user.set("Name", "Gamves Official");
								user.set("firstName", "Gamves");
								user.set("lastName", "Official");
								user.set("pictureSmall", iconFile);
								user.set("password", "lo vas a lograr");
								user.set("iDUserType", -1);

								var adminRelation = user.relation("userType");
					        	adminRelation.add(adm);	

								user.signUp(null, {
									success: function(userLogged) {								  	
									  	
										//var app_id 			= "0123456789";
										//var master_key		= "9876543210";
										//var server_url 		= "http://25.55.180.51:1337/1/";											

										//GamvesDev
										var app_id 			= "PJwimi4PtpAKCpt8UAnDA0QBh5FHLhENew6YQLyI";
										var master_key		= "G8tmbgWc7u2YOZjN1ZhzYPaMHEnoKAAVFHUwn1ot";
										var server_url 		= "https://parseapi.back4app.com";											
										
										var hasIcon 		= false;

										var Config = Parse.Object.extend("Config");
										var config = new Config();

										config.set("server_url", server_url); 
										config.set("app_id", app_id);
										config.set("master_key", master_key);
										config.set("app_icon_url", app_icon_url);  
										user.set("iconPicture", iconFile);
										config.set("hasIcon", hasIcon);                  
										config.save();
										
							        	var queryRole = new Parse.Query(Parse.Role);
										queryRole.equalTo('name', 'admin');
										queryRole.first({useMasterKey:true}).then(function(adminRole){								

											var adminRoleRelation = adminRole.relation("users");
					        				adminRoleRelation.add(userLogged);	

				    						adminRole.save(null, {useMasterKey: true});

				    						loadImagesArray(config, function(universeFile){

				    							var Profile = Parse.Object.extend("Profile");         

									            profile = new Profile();    								            

												profile.set("pictureBackground", universeFile);

												profile.set("bio", "Gamves Administrator");		

												profile.set("backgroundColor", [228, 239, 245]);

												profile.save(null, {useMasterKey: true}, {

								                    success: function(result) {
								                        response.success(resutl);
								                    },
								                    error: function(error) {
								                        response.error(error);
								                    }
								                    
								                });


				    						});

										});	

									},
									error: function(user, error) {
										  // Show the error message somewhere and let the user try again.
										  alert("Error: " + error.code + " " + error.message);
										  response.error("Error: " + error.code + " " + error.message);
									}
								});
		                                                   
		                                                            
		                  }, function(error) {                    
		                      response.error(error);
		                  });

						},
						error: function (response, error) {
						    response.error(error);
						}

					}); 
					
			    } 
	        },
	        error: function(error) {
	           response.error(error);
	        }
	    });

	});

	function loadImagesArray(configPF, callback) {	

		var files = [
			"https://s3.amazonaws.com/gamves/images/personal.jpg",
			"https://s3.amazonaws.com/gamves/images/personal_background.jpg",
			"https://s3.amazonaws.com/gamves/images/trending.jpg",
			"https://s3.amazonaws.com/gamves/images/trending_background.jpg",    		
			"https://s3.amazonaws.com/gamves/images/universe.jpg",
			"https://s3.amazonaws.com/gamves/images/image_0.jpg",
			"https://s3.amazonaws.com/gamves/images/image_1.jpg",
			"https://s3.amazonaws.com/gamves/images/image_2.jpg",
			"https://s3.amazonaws.com/gamves/images/image_3.jpg",
			"https://s3.amazonaws.com/gamves/images/image_4.jpg"
		];

		var count = files.length;

		var universeFile;

		for (var i=0; i<count; i++) {

			var imagesArray = [];

			var _url = files[i];
			
			var cd=0, id=0;

			var configRel = configPF.relation("images");

			var hasUniverse;

			Parse.Cloud.httpRequest({url: _url}).then(function(httpResponse) {   			

				var headers = httpResponse.headers;
				var etag = headers.etag.trim(); 

				etag.replace(/['"]+/g, '')

				console.log("etag: " + etag);			    			

				var name;               

				/*var image_0 = 'b095b76aa6ea61c6f47f7e287b3be47a';
				var image_1 = 'f8c5f0c6fa6f8a8768b8424da17d7d73';
				var image_2 = 'd5daf2d0f3f511077d91f0e760e2306d';
				var image_3 = '5dda529539e9809b9c1ed77c19917b76';
				var image_4 = '34f9a215693a50656ac7828d804bb8d0';
				var personal = '2a05a8c7c83314a78f5d1b5ffd93a9fd';
				var personal_background = '7d24bcd5baa229c759587526ffc00551';
				var trending = 'de45444c2e8a6127a36111e765fbbef9';
				var trending_background = 'c827df1e0148aa260631f6a3699aa25d';
				var universe = '168a0ce67bfda7963843b3a43601b886';*/

				var image_0 			= 'a6ea61c6f47f7e287';
				var image_1 			= 'fa6f8a8768b8424da';
				var image_2 			= 'f3f511077d91f0e76';
				var image_3 			= '39e9809b9c1ed77c1';
				var image_4 			= '693a50656ac7828d8';
				var personal 			= 'c83314a78f5d1b5ff';
				var personal_background = 'baa229c759587526f';
				var trending 			= '2e8a6127a36111e76';
				var trending_background = '0148aa260631f6a36';
				var universe 			= '7bfda7963843b3a43';


				if (etag.indexOf(image_0) >= 0) {

					name = 'image_0';
				} else if (etag.indexOf(image_1) >= 0) {

					name = 'image_1';
				} else if (etag.indexOf(image_2) >= 0) {

					name = 'image_2';
				} else if (etag.indexOf(image_3) >= 0) {

					name = 'image_3';
				} else if (etag.indexOf(image_4) >= 0) {

					name = 'image_4';
				} else if (etag.indexOf(personal) >= 0) {
					
					name = 'personal'; 
				} else if (etag.indexOf(personal_background) >= 0) {

					name = 'personal_background'; 
				} else if (etag.indexOf(trending) >= 0) {

					name = 'trending';  
				} else if (etag.indexOf(trending_background) >= 0) {

					name = 'trending_background'; 
				} else if (etag.indexOf(universe) >= 0) {

					name = 'universe';  

					hasUniverse = true;
				}


				//console.log("name: " + name);
				//console.log("---------------------------------");			    			

				var imageBuffer = httpResponse.buffer;
	            var base64 = imageBuffer.toString("base64");                          

	            var Image = Parse.Object.extend("Images");
				var image = new Image();

	            var file = new Parse.File(name+".jpg", { base64: base64 }, "image/png");
	            image.set("image", file);
	            image.set("name", name); 

	            if (hasUniverse) {
					universeFile = file;
	            }

	            image.save(null, {											
					success: function (savedImage) {	 

						configRel.add(savedImage);

						//console.log("id: "+id);
						//console.log("count: "+count);

		            	if ( id == (count-1) ){	            				            	

		            		configPF.save();	     

		            		callback(universeFile);

		            	}
		            	id++;
	    			},
					error: function (response, error) {
					    console.log('Error: ' + error.message);
					}

				});

				cd++;            	
	   		});    			
		}
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
	            //response.error(error);
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
				//var videoFile = "download/" + ytb_videoId + ".mp4";
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

	    	console.log("llega: " + results);

	    	if( results.length > 0) 
	        {
	            var videoObject = results[0];
	            var fs = require('fs');
	            var youtubedl = require('youtube-dl');
	            var video = youtubedl('http://www.youtube.com/watch?v='+ytb_videoId, ['--format=18'], { cwd: __dirname }); 

	            var fs = require('fs');

	            //checkDirectory("download/", fs, function(error) {  
					
				//var videoName = "download/" + ytb_videoId + '.mp4';

				var videoName = ytb_videoId + '.mp4';

				console.log("videoName: " + videoName);

				video.pipe(fs.createWriteStream(videoName, { flags: 'a' }));

	            //video.pipe(fs.createWriteStream(videoName));

	            video.on('end', function() { 
	            	 
	            	callback({"videoName":videoName, "videoObject":videoObject, });

		        });    


				//});	            
	       }	  

	    }, function(error) {	    

	        response.error(error);

	    });	

	};
	
	/*function checkDirectory(directory, fs, callback) {  	  	  
	  fs.stat(directory, function(err, stats) {	    
	    if (err && err.errno === 34) {	      
	      fs.mkdir(directory, callback);
	    } else {	      
	      callback(err)
	    }
	  });
	}*/

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
		//uploader.on('progress', function() { console.log("progress", uploader.progressMd5Amount, uploader.progressAmount, uploader.progressTotal); });
		  
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

	/*
	Parse.Cloud.afterSave("Favorites", function(request) {
		
		fanpageTrending();
		//categoryOrder();

	});


	Parse.Cloud.afterDelete("Favorites", function(request) {
		
		fanpageTrending();
		//categoryOrder();

	});
	*/









	/*


		var queryCategory = new Parse.Query("Categories");
		
	    queryCategory.equalTo("name", "TRENDING");	   
	    
	    queryCategory.first({
	        useMasterKey: true,
	        success: function(categoryTrending) {


	        	if categoryTrending.length > 0 {

					var queryFavorite = new Parse.Query("Favorites");
					
				    queryFavorite.equalTo("type", 1);	       
				    
				    queryFavorite.find({
				        useMasterKey: true,
				        success: function(favorites) {
				        	
							console.log("count: " + favorites.length);

				        	if( favorites.length > 0) {					

								var totals = {}

								var current = null;
							    var cnt = 0;

							    var unsortedFavorites = [];

							    for (var i = 0; i < favorites.length; i++) {

							    	var id = favorites[i].get("referenceId");
							        
							        if ( id	!= current ) {
							        
							            if (cnt > 0) {

							            	 unsortedFavorites.push({ 
										        "count" : cnt,
										        "objectId"  : current				        
										     });
							            }
							            
							            current = id;

							            cnt = 1;

							        } else {

							            cnt++;
							        }
							    }

							    if (cnt > 0) {				        

							        unsortedFavorites.push({ 
								        "count" : cnt,
								        "objectId"  : current				        
								    });

							    }

							    var sortedFavorites = unsortedFavorites.sort(function(a, b) {return a.count - b.count});


								console.log("----------------------------");

								console.log(sortedFavorites);

								console.log("----------------------------");

						    } 
							

				        },
				        error: function(error) {	            
				            console.log(error);
				        }
				    });

				}

		});

	//}


	function categoryOrder() {


		/*var queryCategory = new Parse.Query("Categories");
		
	    queryCategory.equalTo("name", "PERSONAL");	   
	    
	    queryCategory.first({
	        useMasterKey: true,
	        success: function(category) {

	        	if category.length > 0 {

		        	var queryFavorite = new Parse.Query("Favorites");
			
				    queryFavorite.equalTo("type", 0);

				    queryFavorite.distinct("referenceId", category.id);	   
				    
				    queryFavorite.find({
				        useMasterKey: true,
				        success: function(favorites) {
		        	
							console.log("count: " + favorites.length);

				        	if( favorites.length > 0) {					

								var totals = {}

								var current = null;
							    var cnt = 0;

							    var unsortedFavorites = [];

							    for (var i = 0; i < favorites.length; i++) {

							    	var id = favorites[i].get("referenceId");
							        
							        if ( id	!= current ) {
							        
							            if (cnt > 0) {

							            	 unsortedFavorites.push({ 
										        "count" : cnt,
										        "objectId"  : current				        
										     });
							            }
							            
							            current = id;

							            cnt = 1;

							        } else {

							            cnt++;
							        }
							    }

							    if (cnt > 0) {				        

							        unsortedFavorites.push({ 
								        "count" : cnt,
								        "objectId"  : current				        
								    });

							    }

							    var sortedFavorites = unsortedFavorites.sort(function(a, b) {return a.count - b.count});

							    
							    console.log("----------------------------");

								console.log(sortedFavorites);

								console.log("----------------------------");


							    if sortedFavorites.length > 4 {

							    	var trending = sortedFavorites.slice(0,4);

							    	for (var i = 0; i < trending.length; i++) {

	    								var json = sortedFavorites[i];

	    								json.count;






	    							}


							    }

								

								

						    } 
							

				        },
				        error: function(error) {	            
				            console.log(error);
				        }



				    });

				}

	        }

		});*/


		
	//}


