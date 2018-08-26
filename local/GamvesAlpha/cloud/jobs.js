				
		// --
		// Calculate Trending Fanpages. 

		//Parse.Cloud.job("GamvesJobs", function(request, status) {

		Parse.Cloud.define("GamvesJobs", function(request, status) {	

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
						reject(restulTrending.message);
					}

				});

			}).then(function() {				

				//- Fornite Api Upcoming

				getForniteApiUpcoming(function(restulUpcoming) {

					if (!restulUpcoming.error) {						

						status.success(true);		

					} else {
						reject(restulUpcoming.message);
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
	  	// Fornite API 	  		  	

	  	function getForniteApiUpcoming(callback) {			  	

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
                	parseFortniteUpcoming(json, function(callbackFornite) {
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

		function parseFortniteUpcoming(json, callbackUpcoming) {			

			let rows = json.rows;		

			var count = 0;			

			var ids = [];

			for (var i = 0; i < rows; i++) {				

				let item = json.items[i];
				let name = item.name;
				let imageUrl = item.item.image;			

				var fileComplete = imageUrl.substring(imageUrl.lastIndexOf('/')+1);
				var filenameText = fileComplete.replace(/\.[^/.]+$/, "");				

				ids.push(filenameText);				

				var queryFortniteUpcoming = new Parse.Query("FortniteUpcoming");
				queryFortniteUpcoming.equalTo("imageId", filenameText);				

				queryFortniteUpcoming.first({

					success: function(result) {

						if( result == null || result.length == 0 ) {

							Parse.Cloud.httpRequest({url: imageUrl}).then(function(httpResponse) {							

								var fileNameWithExt = imageUrl.substring(imageUrl.lastIndexOf('/')+1);
								var id = fileNameWithExt.replace(/\.[^/.]+$/, "");									

			                   	var imageBuffer = httpResponse.buffer;
			                   	var base64 = imageBuffer.toString("base64");

			                   	let filename = id + ".png";                  	

			                   	var imageFile = new Parse.File(filename, { base64: base64 });                                       

			                   	var FortniteUpcoming = Parse.Object.extend("FortniteUpcoming");
						    	var fortniteUpcoming = new FortniteUpcoming();

						    	fortniteUpcoming.set("name", name);
						    	fortniteUpcoming.set("imageId", id);	
			                   	fortniteUpcoming.set("image", imageFile); 								

			                   	fortniteUpcoming.save(null, { useMasterKey: true,										
									success: function (response) {	 									

										if (count == (rows-1)) {

											removeIfNotExist(ids, function(resutl){

												callbackUpcoming({"error":false});

											});
									   	}
									   	count++;
					    			},
									error: function (response, error) {		

										console.log("error: " + error);						
									    
									    callbackUpcoming({"error":true,"message":error});
									}
								});             
			                                                        
			              		}, function(error) {                    

			              			callbackUpcoming({"error":true,"message":error});            	

			              		});

						
						} else {

							//console.log("count: " + count + " rows: " + rows);

							if (count == (rows-1)) {

								//console.log("COMPLETED");								

		                   		removeIfNotExist(ids, function(resutl) {

									callbackUpcoming({"error":false});

								});
						   	}
							count++;
						}						
					},
					error: function(error) {					

					}
				});
			}
		}

		function removeIfNotExist(ids, callback){

			//console.log("ids: " + ids.length);

			var queryNotUpcoming = new Parse.Query("FortniteUpcoming");			
			queryNotUpcoming.notContainedIn("imageId", ids);
			queryNotUpcoming.find({

				success: function(results) {

					if( results == null || results.length == 0 ) {

						callback();

					} else {

						//console.log("remove: " + JSON.stringify(results));

						Parse.Object.destroyAll(results);

						callback();
					}

				},
				error: function(error) {

					callback();			
				}

			});


		} 