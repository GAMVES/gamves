				
		// --
		// Calculate Trending Fanpages. 

		//Parse.Cloud.job("GamvesJobs", function(request, status) {

		Parse.Cloud.define("GamvesJobs", function(request, status) {	

			var fanpageObj;

			new Promise(function(resolve, reject) {

				//- Calculate Trending Fanpages

				calculateTrendingFanpages(function(restulTrending) {			

					if (!restulTrending.error) {					
						resolve();																			
					} else {
						reject(restulTrending.message);
					}

				});

			}).then(function() {			
				
					//- Birthday Daily Check

					birthdayDailyCheck(function(restulBirthday) {

						if (!restulBirthday.error) {
							resolve();		
						} else {
							reject(restulBirthday.message);
						}

					});

			}).then(function() {

	        	var queryFanpage = new Parse.Query("Fanpages");
				queryFanpage.equalTo("pageName", "Fortnite");		

				return queryFanpage.first();

			}).then(function(fanpagePF) {						

				fanpageObj = fanpagePF;

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

						status.success(true);

					} else {
						reject(restulNews.message);
					}

				});


			}).catch(function (fromreject) {

				status.error(fromreject);

			});	

		}); 




		// --
		// Calculate Trending Fanpages. 	

		function calculateTrendingFanpages(callback) {

			var categoryTrending;
			var sortedFavorites = [];
			var isTrending = false;

			var queryCategory = new Parse.Query("Categories");
			queryCategory.equalTo("name", "TRENDING");					
				
			return queryCategory.first().then(function(category) {

				categoryTrending = category;   	

				var queryFavorite = new Parse.Query("Favorites");
				queryFavorite.equalTo("type", 1);	 
				return queryFavorite.find();        

			}).then(function(favorites) {  					

				if( favorites.length > 0) {										

					var totals = {};
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

				    //console.log("----------------------------");
					//console.log(unsortedFavorites);
					//console.log("----------------------------");

					return unsortedFavorites.sort(function(a, b) {return a.count - b.count});	  

			    } else {
			    	
			    	//Remove all
			    	removeAllTrendings(categoryTrending);

			    	//No favorites
			    	callback({"error":false});
			    }

			}).then(function(sorted) {							

				sortedFavorites = sorted;			

				var queryFanpages = new Parse.Query("Fanpages");		 
			    return queryFanpages.find();

			}).then(function(fanpages) {				

				for (var i=0; i < fanpages.length; i++) {

					var fanpage = fanpages[i];	
					isTrending = getTrending(sortedFavorites, fanpage.id);								

					reletionHasTrending(fanpage, isTrending, function(hasTrending, categoryRelation, fanpageCallback, isTrendingCallback){						

						//console.log("----------------------------");
						//console.log(fanpageCallback.get("pageName"));
						//console.log(isTrendingCallback);
						//console.log(hasTrending);						

						//add
						if (isTrendingCallback && !hasTrending) {

							categoryRelation.add(categoryTrending);

						//remove
						} else if (!isTrendingCallback && hasTrending) {

							categoryRelation.remove(categoryTrending);
						}						

						fanpageCallback.save(null, { useMasterKey: true,										
							success: function (savedFanpageCallback) {	 

								callback({"error":false});								

			    			},
							error: function (response, error) {								
							    
							    callback({"error":true, "message":error});

							}
						});
					});		
				}   

			}, function(error) {    			    	
			    callback({"error":true, "message":error});
			});	
		} 


		function reletionHasTrending(fanpage, isTrending, callback) {

			var categoryRelation = fanpage.relation("category");
			var categoryQuery = categoryRelation.query();

			categoryQuery.find({
			    success: function(categories) {		    	

					var hasTrending = false;

					for (var j = 0; j < categories.length; j++) {

						var category = categories[j];			
						if (category.get("name") == "TRENDING") {
							hasTrending = true;
						}
					}
					callback(hasTrending, categoryRelation, fanpage, isTrending);

				},
			    error: function() {

			    }

			});

		};

		function getTrending(sortedFavorites, fanpageId) {

			var trending = [];		

			if (sortedFavorites.length > 4) {

				trending = sortedFavorites.slice(0,4);	    

			} else {

				trending = sortedFavorites;
			}     

			for (var i = 0; i < trending.length; i++) {

				var json = sortedFavorites[i];		

				if (json.objectId == fanpageId) {
					
					return true;
				}				
				
			} 	

			return false;

		}

		function removeAllTrendings(categoryTrending) {			

			var queryFanpages = new Parse.Query("Fanpages");
			 queryFanpages.find().then(function(fanpages) {			 	

				if( fanpages.length > 0) {

			    	for (var i = 0; i < fanpages.length; i++) {

			    		var fanpage = fanpages[i];	

			    		var categoryRelation = fanpage.relation("category");

						findTrendingCategory(fanpage, categoryRelation, function(fanpageCallback, categoryRelationCallback){

							categoryRelationCallback.remove(categoryTrending);
							fanpageCallback.save(null, {useMasterKey:true});

						});		
			    	}           
			   	}	  

			}, function(error) {	    

			    console.log(error);

			});		

		};

		function findTrendingCategory(fanpage, categoryRelation, callback) {

			var categoryQuery = categoryRelation.query();
			categoryQuery.find({
			    success: function(categories) {		    							

					for (var j = 0; j < categories.length; j++) {
						var category = categories[j];					
						if (category.get("name") == "TRENDING") {							
							callback(fanpage, categoryRelation);							
						}
					}					
				},
			    error: function(error) {

			    	console.log(error);
			    }
			});
		}



		// --
	  	// Calculate Trending Fanpages. 	  	

	  	function birthdayDailyCheck(callback) {	  		

	  		var userQuery = new Parse.Query(Parse.User);
			userQuery.containedIn("iDUserType", [2,3]);
			userQuery.find().then(function(usersPF) {				

				let countUsers = usersPF.length;

				var users = [];	

				for (let i=0; i<countUsers; i++) {

					let userPF = usersPF[i];
					let birthday = userPF.get("birthday");				
					let isToday = checkIsToday(birthday);					

					if (isToday) {
						users.push(userPF);						
					}
				}

				if (users.length > 0) {

					var count = 0;
					var countBirthdays = users.lemgth;

					for (var i=0; i<countBirthdays; i++) {

						let user = users[i];

						createBirdayNotifications(user, function(restulTrending) {

							if (count == (countBirthdays-1)) {
								callback({"error":false});
							}			

						});
					}
				
				} else  {

					callback({"error":false});

				}

				
			});
		}	

		function checkIsToday(user_birthday) {		

			var today = new Date();
			var dd = today.getDate();
			var mm = today.getMonth()+1; 
			var yyyy = today.getFullYear();

			if(dd<10) {
			    dd='0'+dd;
			} 

			if(mm<10) {
			    mm='0'+mm;
			} 	

			let todayCompare = yyyy + '-' + mm + '-' + dd;
			var a = new Date(user_birthday);
			var b = new Date(todayCompare);

			let equal;

			if (a.getTime() == b.getTime()) {
				equal = true;
			} else {
				equal = false;
			}	
			return equal;
		}

		function createBirdayNotifications(userPF, callback) {

			var cover;
			var adminUser;

			var userQuery = new Parse.Query(Parse.User);
			userQuery.equalTo("username", "gamvesadmin");
			
		    return userQuery.first().then(function(admin) {

		    	adminUser = admin;

				var queryFanpage = new Parse.Query("Fanpages");
				queryFanpage.equalTo('categoryName', 'PERSONAL');
				queryFanpage.equalTo("posterId", userPF.id);    						

				return queryFanpage.first({useMasterKey:true});

			}).then(function(restulFanpagesPF) {		

				cover = restulFanpagesPF.get("pageCover");

				var friendslQuery = new Parse.Query("Friends");
				friendslQuery.equalTo("userId", userPF.id);
				return friendslQuery.find({useMasterKey:true});

			}).then(function(restulFriendsPF) {		

				let Notifications = Parse.Object.extend("Notifications");	    				
		    	
		    	let userName = userPF.get("Name");

				//- Poster notification											
				
				let friendImage = userPF.get("pictureSmall");

				let notificationBirthday = new Notifications();
				
				let titlePoster = "<b>Happy birthday </b>" + userName + " !!"; 
				let descUser  = "Say hello to " + userName + " in a very special day!"; 

				notificationBirthday.set("posterAvatar", friendImage);
				notificationBirthday.set("title", titlePoster);	
				notificationBirthday.set("description", descUser);	

				let posterName = adminUser.get("Name");				
				notificationBirthday.set("posterName", posterName);				
				notificationBirthday.set("posterId", userPF.id);

				notificationBirthday.set("cover", cover);						
				
				notificationBirthday.set("type", 4);							
				notificationBirthday.save(null, {useMasterKey: true}); 						

				let count = restulFriendsPF.length;				

				for (let i=0; i<count; i++) {
					
					let friendsArray = restulFriendsPF[i].get("friends");

					let countFriends = friendsArray.length;

					console.log("countFriends::: " + countFriends);					

					for (let j=0; j<countFriends; j++){

						let friendId = friendsArray[j];						
						notificationBirthday.add("target", friendId);
					}					

				}

				var today = new Date();
								
				notificationBirthday.set("date", today);	
				notificationBirthday.save(null, {useMasterKey: true}); 

				callback(true);

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
										
										var albumRelation = fanpagePF.relation("albums");
			        					albumRelation.add(albumSaved);	

			        					console.log("__count: " + count + " rows: " + rows);      										

										if (count == (rows-1)) {

											fanpagePF.save(null, {useMasterKey: true});

											callbackUpcoming({"error":false});

											/*removeIfNotExist(ids, fanpageId, function(resutl){

												callbackUpcoming({"error":false});

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

		function removeIfNotExist(ids, fanpageId, callback){			

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
		} 


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
										
										var albumRelation = fanpagePF.relation("albums");
			        					albumRelation.add(albumSaved);	 										

										if (count == (rows-1)) {

											fanpagePF.save(null, {useMasterKey: true});

											callbackNews({"error":false});

											/*removeIfNotExist(ids, fanpageId, function(resutl){

												callbackNews({"error":false});

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