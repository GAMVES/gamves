    
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

					console.log("getFortniteApi: " + getFortniteApi);

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

				} else {
					reject(restulNews.message);
				}

			});

		}).then(function() {
		
			//- Fornite Api News

			getForniteApiStore(fanpageObj, function(restulStore) {

				if (!restulStore.error) {											
					
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

  		console.log("getForniteApiUpcoming fanpagePF.id : " + fanpagePF.id);

  		var urlApi = "https://fortnite-public-api.theapinetwork.com/prod09/upcoming/get";

		Parse.Cloud.httpRequest({			
			url: urlApi, 
			method: "POST",
			path: ["prod09", "upcoming", "get"],
			headers: {
		    	"content-type": "multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW",
		    	"Authorization": "b02d03a37b28a3acdc0c5615c1ec9378"			    	
		  	}
			}).then(function(httpResponse) {

            	var json = JSON.parse(httpResponse.text);       

            	//console.log("json: " + JSON.stringify(json));

            	parseFortniteUpcoming(fanpagePF.id, json, function(callbackFornite) {

            		//console.log("callbackFornite");

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

	function parseFortniteUpcoming(fanpageId, json, callbackUpcoming) {	

		let rows = json.data.length;			

		var count = 0;			

		var ids = [];

		var upcoming = "Upcoming";

		console.log("rows: " + rows);

		for (var i = 0; i < rows; i++) {				
			

			let itemData = json.data[i];			
			var filenameText = itemData.itemId;

			let item = itemData.item;
			let name = item.name;
			let imageUrl = item.images.background;			
		
			ids.push(filenameText);				

			console.log("name: " + name + " filenameText: " + filenameText + " imageUrl: " + imageUrl);

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

		        					console.log("__countUpcoming: " + count + " rows: " + rows);      										

									if (count == (rows-1)) {

										callbackUpcoming({"error":false});

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
		    	"Authorization": "b02d03a37b28a3acdc0c5615c1ec9378"			    	
		  	}
			}).then(function(httpResponse) {

            	var json = JSON.parse(httpResponse.text);    

            	//console.log("json: " + JSON.stringify(json));

            	parseFortniteNews(fanpagePF.id, json, function(callbackNews) {

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


	function parseFortniteNews(fanpageId, json, callbackNews) {	

		let rows = json.data.length;			

		var count = 0;			

		var ids = [];		

		var news = "News";

		for (var i = 0; i < rows; i++) {								

			let entrie = json.data[i];
			let title = entrie.title;
			let body = entrie.body;
			let imageUrl = entrie.image;

			console.log("title: " + " body: " + body);

			var fileComplete = imageUrl.substring(imageUrl.lastIndexOf('/')+1);
			var filenameText = fileComplete.replace(/\.[^/.]+$/, "");				

			ids.push(filenameText);

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

		        					console.log("__countNews: " + count + " rows: " + rows);      										

									if (count == (rows-1)) {

										callbackNews({"error":false});

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
		    	"Authorization": "b02d03a37b28a3acdc0c5615c1ec9378"			    	
		  	}
			}).then(function(httpResponse) {

            	var json = JSON.parse(httpResponse.text);    

				//console.log("json: " + JSON.stringify(json));

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

	function parseFortniteStore(fanpageId, json, callbackStore) {	

		let rows = json.data.length;			;

		console.log("rows: " + rows);					

		var count = 0;			

		var ids = [];		

		var store = "Store";

		for (var i = 0; i < rows; i++) {								
			
			let itemData = json.data[i];			
			let item = itemData.item;
			let name = item.name;
			let imageUrl = item.images.background;		

			console.log("name: " + name);
		
			var filenameText = itemData.itemId;

			ids.push(filenameText);

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

		        					console.log("__countStore: " + count + " rows: " + rows);      										

									if (count == (rows-1)) {

										callbackStore({"error":false});			

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

	});	

	


