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

	// --
  	// Fornite API Calls	

	Parse.Cloud.define("ForniteAPICalls", function(request, status) {				

		var queryFanpage = new Parse.Query("Fanpages");
		queryFanpage.equalTo("pageName", "Fortnite");
		queryFanpage.first({useMasterKey:true}).then(function(fanpagePF) {					

			let albumRelation = fanpagePF.relation("albums");
			let queryAlbum = albumRelation.query();
			queryAlbum.find({

				success: function(albumsPF) {

					console.log("albumsPF.length: " + albumsPF.length);

					if( albumsPF == null || albumsPF.length == 0 ) {

						getFortniteApi(fanpagePF,  function() {

							//status.success(true);

							saveAlbumsFanpageRelation(fanpagePF, function(restultSave) {

								if (!restultSave.error) {

									status.success(true);
								}

							});

						});

						//status.error("empty");

					} else {						

						//Parse.Object.destroyAll(albumsPF);

						for (var j = 0; j < albumsPF.length; j++) {

							var albumPF = albumsPF[j];			
							albumPF.destroy();
						}

						getFortniteApi(fanpagePF,  function() {

							//status.success(true);

							saveAlbumsFanpageRelation(fanpagePF, function(restultSave) {

								if (!restultSave.error) {

									status.success(true);
								}

							});

						});
						
					}

				},
				error: function(error) {

					getFortniteApi(fanpagePF,  function() {

						status.success(true);

					});
				}
			});		
		});	
	}); 	

	function saveAlbumsFanpageRelation(fanpagePF, callback) {

		var albumRelation = fanpagePF.relation("albums");

		var typesArray = ["Upcoming","News","Store"];	

		var queryAlbums = new Parse.Query("Albums");
		queryAlbums.containedIn("type", typesArray);
		queryAlbums.find({

			success: function(albumsPF) {

				for (var j = 0; j < albumsPF.length; j++) {

					var album = albumsPF[j];	
					albumRelation.add(album);			
					
				}
				//fanpagePF.save(null, { useMasterKey: true});

				fanpagePF.save(null, { useMasterKey: true,	

					success: function (fanpagePFSaved) {

						callback({"error":false});					

					},
					error: function (response, error) {			

						callback({"error":true, "message":error});
					}
				});

			},
			error: function(error) {
			
				callback({"error":true, "message":error});

			}		

		});
	}


	function getFortniteApi(fanpage, callback) {

		var fanpageObj = fanpage;

		new Promise(function(resolve, reject) {		

			//- Fornite Api Upcoming

			getForniteApiUpcoming(fanpageObj, function(restulUpcoming) {

				if (!restulUpcoming.error) {						

					resolve();			

					//status.success(true);

				} else {
					reject(restulUpcoming.message);
				}

			});

		}).then(function() {

			//- Fornite Api News

			getForniteApiNews(fanpageObj, function(restulNews) {

				if (!restulNews.error) {						

					resolve();	

					//status.success(true);

				} else {
					reject(restulNews.message);
				}

			});

		}).then(function() {

			//- Fornite Api News

			getForniteApiStore(fanpageObj, function(restulStore) {

				if (!restulStore.error) {											

					//status.success(true);

					callback();

				} else {
					reject(restulStore.message);
				}

			});	


		}).catch(function (fromreject) {

			status.error(fromreject);

		});	
		
	}

	// --
  	// Fornite API Upcoming	  	 	  	

  	function getForniteApiUpcoming(fanpagePF, callback) {

  		var urlApi = "https://fortnite-public-api.theapinetwork.com/prod09/upcoming/get";

		Parse.Cloud.httpRequest({			
			url: urlApi, 
			method: "POST",
			path: ["prod09", "upcoming", "get"],
			headers: {
		    	"content-type": "multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW",
		    	"Authorization": "2042874b0743fbddd6c73065680fa75e"			    	
		  	}
			}).then(function(httpResponse) {

            	var json = JSON.parse(httpResponse.text);                 	

            	parseFortniteUpcoming(fanpagePF, json, function(callbackFornite) {

            		console.log("callbackFornite");

					if (!callbackFornite.error) {
						callback({"error":false});
					} else {
						callback({"error":true,"message":callbackFornite.message});
					} 
				});

			},function(httpResponse) {				  
			  	// error
			  	console.error('Request failed with response code ' + httpResponse.status);
		});

	}	

	function parseFortniteUpcoming(fanpagePF, json, callbackUpcoming) {	

		let rows = json.rows;			

		var count = 0;			

		var ids = [];

		var upcoming = "Upcoming";

		for (var i = 0; i < rows; i++) {				

			let item = json.items[i];
			let name = item.name;
			let imageUrl = item.item.image;			

			var fileComplete = imageUrl.substring(imageUrl.lastIndexOf('/')+1);
			var filenameText = fileComplete.replace(/\.[^/.]+$/, "");				

			ids.push(filenameText);				

			//console.log("name: " + name + " filenameText: " + filenameText + " imageUrl: " + imageUrl);

			var fanpageId = fanpagePF.get("fanpageId");
			//var albumRelation = fanpagePF.relation("albums");

			//console.log(" fanpageId :: Fornite: " + fanpageId);

			var queryAlbum = new Parse.Query("Albums");
			queryAlbum.equalTo("referenceId", fanpageId);
			queryAlbum.equalTo("imageId", filenameText);
			queryAlbum.equalTo("type", upcoming);

			queryAlbum.first({

				success: function(result) {	

					//console.log("result: " + result);    			

					if( result == null || result.length == 0 ) {

						Parse.Cloud.httpRequest({url: imageUrl}).then(function(httpResponse) {							

							var fileNameWithExt = imageUrl.substring(imageUrl.lastIndexOf('/')+1);
							var id = fileNameWithExt.replace(/\.[^/.]+$/, "");									

		                   	var imageBuffer = httpResponse.buffer;
		                   	var base64 = imageBuffer.toString("base64");

		                   	let filename = id + ".png";                  	

		                   	var imageFile = new Parse.File(filename, { base64: base64 });                                       

		                   	var Albums = Parse.Object.extend("Albums");
					    	var album = new Albums();

					    	album.set("name", name);
					    	album.set("imageId", id);
					    	album.set("referenceId", fanpageId);	
		                   	album.set("cover", imageFile); 
		                   	album.set("type", upcoming); 								

		                   	album.save(null, { useMasterKey: true,	

								success: function (albumSaved) {
																		
		        					//albumRelation.add(albumSaved);	

		        					console.log("__countUpcoming: " + count + " rows: " + rows);      										

									if (count == (rows-1)) {

										callbackUpcoming({"error":false});

										/*fanpagePF.save(null, { useMasterKey: true,	

											success: function (fanpagePFSaved) {

												callbackUpcoming({"error":false});

											},
											error: function (response, error) {			

												callbackUpcoming({"error":true, "message":error});
											}
										});*/ 									

								   	}
								   	count++;
				    			},
								error: function (response, error) {		

									//console.log("error: " + error);						
								    
								    callbackUpcoming({"error":true,"message":error});
								}
							});             
		                                                        
		              		}, function(error) {                    

		              			callbackUpcoming({"error":true,"message":error});            	

		              		});

					
					} else {

						//console.log("count: " + count + " rows: " + rows);

						if (count == (rows-1)) {							

							callbackUpcoming({"error":false});

	                   		/*removeIfNotExist(ids, fanpageId, function(resutl) {

								callbackUpcoming({"error":false});

							});*/
					   	}
						count++;
					}	

				},
				error: function(error) {
					
				}
			});
		}
	}

	/*function removeIfNotExist(ids, fanpageId, callback){			

		var queryAlbum = new Parse.Query("Albums");	
		queryAlbum.equalTo("referenceId", fanpageId);		
		queryAlbum.notContainedIn("imageId", ids);
		queryAlbum.find({

			success: function(results) {

				if( results == null || results.length == 0 ) {

					callback();

				} else {						

					Parse.Object.destroyAll(results);
					callback();
				}

			},
			error: function(error) {

				callback();			
			}
		});
	}*/


	// --
  	// Fornite API News	  	 	  	

  	function getForniteApiNews(fanpagePF, callback) {

  		console.log("fanpagePF.id: " + fanpagePF.id);      	

  		var urlApi = "https://fortnite-public-api.theapinetwork.com/prod09/br_motd/get";

		Parse.Cloud.httpRequest({			
			url: urlApi, 
			method: "POST",
			path: ["prod09","br_motd","get"],
			headers: {
		    	"content-type": "multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW",
		    	"Authorization": "2042874b0743fbddd6c73065680fa75e"			    	
		  	}
			}).then(function(httpResponse) {

            	var json = JSON.parse(httpResponse.text);    

            	parseFortniteNews(fanpagePF, json, function(callbackNews) {

            		console.log("callbackNews");

					if (!callbackNews.error) {
						callback({"error":false});
					} else {
						callback({"error":true,"message":callbackNews.message});
					} 
				});

			},function(httpResponse) {				  
			  	// error
			  	console.error('Request failed with response code ' + httpResponse.status);
		});
	}	


	function parseFortniteNews(fanpagePF, json, callbackNews) {	

		let rows = json.entries.length;			

		var count = 0;			

		var ids = [];			

		var news = "News";

		for (var i = 0; i < rows; i++) {								

			let entrie = json.entries[i];
			let title = entrie.title;
			let body = entrie.body;
			let imageUrl = entrie.image;

			console.log("title: " + " body: " + body);

			var fileComplete = imageUrl.substring(imageUrl.lastIndexOf('/')+1);
			var filenameText = fileComplete.replace(/\.[^/.]+$/, "");				

			ids.push(filenameText);

			var fanpageId = fanpagePF.get("fanpageId");	
			//var albumRelation = fanpagePF.relation("albums");							

			var queryAlbum = new Parse.Query("Albums");
			queryAlbum.equalTo("referenceId", fanpageId);
			queryAlbum.equalTo("imageId", filenameText);	
			queryAlbum.equalTo("type", news);

			queryAlbum.first({

				success: function(result) {

					//console.log("result: " + result);

					if( result == null || result.length == 0 ) {

						Parse.Cloud.httpRequest({url: imageUrl}).then(function(httpResponse) {							

							var fileNameWithExt = imageUrl.substring(imageUrl.lastIndexOf('/')+1);
							var id = fileNameWithExt.replace(/\.[^/.]+$/, "");									

		                   	var imageBuffer = httpResponse.buffer;
		                   	var base64 = imageBuffer.toString("base64");

		                   	let filename = id + ".png";                  	

		                   	var imageFile = new Parse.File(filename, { base64: base64 });                                       

		                   	var Albums = Parse.Object.extend("Albums");
					    	var album = new Albums();

					    	album.set("name", title);
					    	album.set("description", body);
					    	album.set("imageId", id);
					    	album.set("referenceId", fanpageId);	
		                   	album.set("cover", imageFile); 
		                   	album.set("type", news); 								

		                   	album.save(null, { useMasterKey: true,	

								success: function (albumSaved) {									
									
		        					//albumRelation.add(albumSaved);	 										

		        					console.log("__countNews: " + count + " rows: " + rows);      										

									if (count == (rows-1)) {

										callbackNews({"error":false});

										/*fanpagePF.save(null, { useMasterKey: true,	

											success: function (fanpagePFSaved) {

												callbackNews({"error":false});

											},
											error: function (response, error) {			

												callbackNews({"error":true, "message":error});
											}
										});*/  									

								   	}
								   	count++;				

				    			},
								error: function (response, error) {												
								    
								    callbackNews({"error":true,"message":error});
								}
							});             
		                                                        
		              		}, function(error) {                    

		              			callbackUpcoming({"error":true,"message":error});            	

		              		});

					
					} else {						

						if (count == (rows-1)) {								

							callbackUpcoming({"error":false});
	                   		
					   	}
						count++;
					}						
				},
				error: function(error) {					

				}
			});
		}
	}


	// --
  	// Fornite API News	  	 	  	

  	function getForniteApiStore(fanpagePF, callback) {

  		console.log("fanpagePF.id: " + fanpagePF.id);      	

  		var urlApi = "https://fortnite-public-api.theapinetwork.com/prod09/store/get";

		Parse.Cloud.httpRequest({			
			url: urlApi, 
			method: "POST",
			path: ["prod09","store","get"],
			headers: {
		    	"content-type": "multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW",
		    	"Authorization": "2042874b0743fbddd6c73065680fa75e"			    	
		  	}
			}).then(function(httpResponse) {

            	var json = JSON.parse(httpResponse.text);    

            	parseFortniteStore(fanpagePF, json, function(callbackStore) {

            		console.log("callbackStore");

					if (!callbackStore.error) {
						callback({"error":false});
					} else {
						callback({"error":true,"message":callbackStore.message});
					} 
				});

			},function(httpResponse) {				  
			  	// error
			  	console.error('Request failed with response code ' + httpResponse.status);
		});
	}	

	function parseFortniteStore(fanpagePF, json, callbackStore) {	

		let rows = json.rows;

		console.log("rows: " + rows);					

		var count = 0;			

		var ids = [];			

		var store = "Store";

		for (var i = 0; i < rows; i++) {								
			
			let item = json.items[i];
			let name = item.name;
			let imageUrl = item.item.image;			

			console.log("name: " + name);

			var fileComplete = imageUrl.substring(imageUrl.lastIndexOf('/')+1);
			var filenameText = fileComplete.replace(/\.[^/.]+$/, "");				

			ids.push(filenameText);

			var fanpageId = fanpagePF.get("fanpageId");	
			//var albumRelation = fanpagePF.relation("albums");							

			var queryAlbum = new Parse.Query("Albums");
			queryAlbum.equalTo("referenceId", fanpageId);
			queryAlbum.equalTo("imageId", filenameText);	
			queryAlbum.equalTo("type", store);

			queryAlbum.first({

				success: function(result) {					

					if( result == null || result.length == 0 ) {

						Parse.Cloud.httpRequest({url: imageUrl}).then(function(httpResponse) {							

							var fileNameWithExt = imageUrl.substring(imageUrl.lastIndexOf('/')+1);
							var id = fileNameWithExt.replace(/\.[^/.]+$/, "");									

		                   	var imageBuffer = httpResponse.buffer;
		                   	var base64 = imageBuffer.toString("base64");

		                   	let filename = id + ".png";                  	

		                   	var imageFile = new Parse.File(filename, { base64: base64 });                                       

		                   	var Albums = Parse.Object.extend("Albums");
					    	var album = new Albums();

					    	album.set("name", name);
					    	//album.set("description", body);
					    	album.set("imageId", id);
					    	album.set("referenceId", fanpageId);	
		                   	album.set("cover", imageFile); 
		                   	album.set("type", store); 								

		                   	album.save(null, { useMasterKey: true,	

								success: function (albumSaved) {									
									
		        					//albumRelation.add(albumSaved);	 										

		        					console.log("__countStore: " + count + " rows: " + rows);      										

									if (count == (rows-1)) {

										callbackStore({"error":false});

										/*fanpagePF.save(null, { useMasterKey: true,	

											success: function (fanpagePFSaved) {

												callbackStore({"error":false});

											},
											error: function (response, error) {			

												callbackStore({"error":true, "message":error});
											}
										});*/  									

								   	}
								   	count++;	
									
				    			},
								error: function (response, error) {												
								    
								    callbackStore({"error":true,"message":error});
								}
							});             
		                                                        
		              		}, function(error) {                    

		              			callbackStore({"error":true,"message":error});            	

		              		});

					
					} else {						

						if (count == (rows-1)) {								

							callbackStore({"error":false});
					   	}
						count++;
					}						
				},
				error: function(error) {					

				}
			});
		}
	}


	// --
  	// Fornite API Calls	

	Parse.Cloud.define("ForniteAuth", function(request, response) {

  		var urlApi = "https://account-public-service-prod03.ol.epicgames.com/account/api/oauth/token";

		Parse.Cloud.httpRequest({			
			url: urlApi, 
			method: "POST",			
			headers: {
		    	'Authorization':'basic MzRhMDJjZjhmNDQxNGUyOWIxNTkyMTg3NmRhMzZmOWE6ZGFhZmJjY2M3Mzc3NDUwMzlkZmZlNTNkOTRmYzc2Y2Y=',			  
		    	'content-type':'application/x-www-form-urlencode'
		  	},
		  	body: {
		  		'grant_type':'password',
				'includePerms':'false',
				'username':'josemanuelvigil@gmail.com',
				'password':'Clemen1234'				
		    }
			}).then( function(httpResponse) {

				console.log("SUCCESS");

				console.log(httpResponse.text); // SUCCESS

            	var hash = httpResponse.text;

            	response.success('hash: ' + hash);

			},function(httpResponse) {				  
			  
			  	console.log("ERROR");			  	

			  	console.log("headers :" + httpResponse.headers); 

			  	console.log("data:" + httpResponse.data); 

			  	response.error('Error: ' + httpResponse.status);
		});

	})	

	// --
  	// Remove Family and Dependencied by objectId

	Parse.Cloud.define("RemoveFamilyById", function(request, response) {	

		var familyId = request.params.familyId;

		var userQuery = new Parse.Query("Family");
		userQuery.equalTo("objectId", familyId);		        
       
        userQuery.first({
        	useMasterKey: true,
            success: function(familyPF) 
            {

        		let userRelation = familyPF.relation("members");
        		let userQuery = userRelation.query();

        		userQuery.find({
        			useMasterKey: true,
					success: function(members) {											

						//Remove family ChatFeed							    			
						let chatfeedQuery = new Parse.Query("ChatFeed");	    
		    			chatfeedQuery.equalTo('remove', familyPF.id);
		    			chatfeedQuery.find({useMasterKey:true}).then(function(chatfeeds) {	    				    				
		    				for (var i = 0; i < chatfeeds.length; ++i) {						
								var chatQuery = chatfeeds[i].relation("chats").query();					
								chatQuery.find({useMasterKey:true}).then(function(chatsPF) {
									for (var j = 0; j < chatsPF.length; ++j) {
										chatsPF[j].destroy({useMasterKey:true});
									}							
								});	
								chatfeeds[i].destroy({useMasterKey:true});												
							}
		    			});


		    			//Remove Family Role		    		
						var queryRole = new Parse.Query(Parse.Role);						
						queryRole.equalTo('removeId', familyPF.id);		
						queryRole.find({useMasterKey:true}).then(function(rolesPF) {	    
							for (var i = 0; i < rolesPF.length; ++i) {
								rolesPF[i].destroy({useMasterKey:true});
							}					
						});		    			

		    			//Remove family Memebers
						for (var i = 0; i < members.length; ++i) {
							let userId = members[i].id;
							Parse.Cloud.run("RemoveUserById", { "userId": userId});
						}

						//remove the family
						familyPF.destroy({useMasterKey: true});

						response.succes(true);

					}, error:function(error)
		    		{          		
		    			response.error(error.message);
		        		console.error("Members query. error = " + error.message);
		    		}
		    	})       
	          	

            }, error:function(error)
	        {	     
	        	console.error("userQuery find failed. error = " + error.message);   
	        }
        });	
	})

	// --
  	// Remove User and Dependencied by objectId

	Parse.Cloud.define("RemoveUserById", function(request, response) {	

		var userId = request.params.userId;

		var userQuery = new Parse.Query(Parse.User);
		userQuery.equalTo("objectId", userId);		 
		userQuery.find({useMasterKey: true }).then(function(usersPF) {
			
			for (var i = 0; i < usersPF.length; ++i) 
			{	
				let userPF = usersPF[i];

				//Installations
				var installationQuery = new Parse.Query(Parse.Installation);
				installationQuery.containedIn('user', [userPF]);
				installationQuery.find({useMasterKey:true}).then(function(installations) {					
					for (var i = 0; i < installations.length; ++i) {				
						installations[i].destroy({useMasterKey:true});
					}
				});

				//Sessions
				let sessionQuery = new Parse.Query(Parse.Session);	
				sessionQuery.containedIn('user', [userPF]);	
				sessionQuery.find({useMasterKey:true}).then(function(sessions) {		
					for (var i = 0; i < sessions.length; ++i) {				
						sessions[i].destroy({useMasterKey:true});
					}
				});

				//Algums
				let albumsQuery = new Parse.Query("Albums");	
				albumsQuery.equalTo('posterId', userPF.id);		
				albumsQuery.find({useMasterKey:true}).then(function(albums) {		
					for (var i = 0; i < albums.length; ++i) {
						albums[i].destroy({useMasterKey:true});
					}
				});	

				//Fanpages
				let fanpagesQuery = new Parse.Query("Fanpages");	
				fanpagesQuery.equalTo('posterId', userPF.id);			
				fanpagesQuery.find({useMasterKey:true}).then(function(fanpages) {		
					for (var i = 0; i < fanpages.length; ++i) {
						var albumsQuery = fanpages[i].relation("albums").query();					
						albumsQuery.find({useMasterKey:true}).then(function(albumsPF) {
							for (var j = 0; j < albumsPF.length; ++j) {
								albumsPF[j].destroy({useMasterKey:true});
							}							
						});	
						fanpages[i].destroy({useMasterKey:true});
					}
				});

				//ChatFeed
				let chatfeedQuery = new Parse.Query("ChatFeed");	    
    			chatfeedQuery.equalTo('remove', userPF.id);
    			chatfeedQuery.find({useMasterKey:true}).then(function(chatfeeds) {	    				    				
    				for (var i = 0; i < chatfeeds.length; ++i) {						
						var chatQuery = chatfeeds[i].relation("chats").query();					
						chatQuery.find({useMasterKey:true}).then(function(chatsPF) {
							for (var j = 0; j < chatsPF.length; ++j) {
								chatsPF[j].destroy({useMasterKey:true});
							}							
						});	
						chatfeeds[i].destroy({useMasterKey:true});												
					}
    			});	

    			//History
    			let historyQuery = new Parse.Query("History");	
				historyQuery.equalTo('userId', userPF.id);	
				historyQuery.find({useMasterKey:true}).then(function(histories) {	    						
					for (var i = 0; i < histories.length; ++i) {
						histories[i].destroy({useMasterKey:true});
					}
				});

				//Location
				let locationQuery = new Parse.Query("Location");	
				locationQuery.equalTo('userId', userPF.id);		
				locationQuery.find({useMasterKey:true}).then(function(locations) {	    						
					for (var i = 0; i < locations.length; ++i) {
						locations[i].destroy({useMasterKey:true});
					}
				});

				//Notfication
				let notificationsQuery = new Parse.Query("Notifications");	
				notificationsQuery.equalTo('removeId', userPF.id);		
				notificationsQuery.find({useMasterKey:true}).then(function(notifications) {	    							
					for (var i = 0; i < notifications.length; ++i) {
						notifications[i].destroy({useMasterKey:true});
					}
				});

				//Profile
				let profileQuery = new Parse.Query("Profile");	
				profileQuery.equalTo('userId', userPF.id);			
				profileQuery.find({useMasterKey:true}).then(function(profiles) {	    							
					for (var i = 0; i < profiles.length; ++i) {
						profiles[i].destroy({useMasterKey:true});
					}
				});

				//TimeOnline
				let timeOnlineQuery = new Parse.Query("TimeOnline");	
				timeOnlineQuery.equalTo('userId', userPF.id);	
				timeOnlineQuery.find({useMasterKey:true}).then(function(timeonlines) {	    							
					for (var i = 0; i < timeonlines.length; ++i) {
						timeonlines[i].destroy({useMasterKey:true});
					}
				});

				//Badges
				let badgesQuery = new Parse.Query("Badges");	
				badgesQuery.equalTo('userId', userPF.id);			
				badgesQuery.find({useMasterKey:true}).then(function(badges) {	    							
					for (var i = 0; i < badges.length; ++i) {
						badges[i].destroy({useMasterKey:true});
					}
				});

				//UserStatus
				let userStatusQuery = new Parse.Query("UserStatus");	
				userStatusQuery.equalTo('userId', userPF.id);		
				userStatusQuery.find({useMasterKey:true}).then(function(userstatuses) {	    							
					for (var i = 0; i < userstatuses.length; ++i) {
						userstatuses[i].destroy({useMasterKey:true});
					}
				});

				//UserVerified
				let userVerifiedQuery = new Parse.Query("UserVerified");	
				userVerifiedQuery.equalTo('userId', userPF.id);			
				userVerifiedQuery.find({useMasterKey:true}).then(function(userverifieds) {	    							
					for (var i = 0; i < userverifieds.length; ++i) {
						userverifieds[i].destroy({useMasterKey:true});
					}
				});

				//Points
				let pointsQuery = new Parse.Query("Points");	
				pointsQuery.equalTo('userId', userPF.id);			
				pointsQuery.find({useMasterKey:true}).then(function(pointsPF) {	    							
					for (var i = 0; i < pointsPF.length; ++i) {
						pointsPF[i].destroy({useMasterKey:true});
					}
				});

				//Role
				var queryRole = new Parse.Query(Parse.Role);						
				queryRole.equalTo('removeId', userPF.id);		
				queryRole.find({useMasterKey:true}).then(function(rolesPF) {	    
					for (var i = 0; i < rolesPF.length; ++i) {
						rolesPF[i].destroy({useMasterKey:true});
					}					
				});

				//User
				userPF.destroy({useMasterKey:true});

			}
		});       
    });    



