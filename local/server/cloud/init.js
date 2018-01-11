	/*
	* Init
	*/

	// --
	// Run startup script


	RunOnStartUp();

	function RunOnStartUp() {

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

						    var user = new Parse.User();
							user.set("username", _admuser);
							user.set("password", "lo vas a lograr");
							user.set("iDUserType", -1);

							var adminRelation = user.relation("userType");
				        	adminRelation.add(adm);	

							user.signUp(null, {
								success: function(userLogged) {								  	
								  	
									var app_id 			= "0123456789";
									var master_key		= "9876543210";
									var server_url 		= "http://192.168.1.103:1337/1/";	
									var app_icon_url 	= "https://api-parseground.s3.amazonaws.com/deab76060e176261cfdbb8d779dd1e32_gamves_icons_white.png";
									var hasIcon 		= false;

									var Config = Parse.Object.extend("Config");
									var config = new Config();

									config.set("server_url", server_url); 
									config.set("app_id", app_id);
									config.set("master_key", master_key);
									config.set("app_icon_url", app_icon_url);                  
									config.set("hasIcon", hasIcon);                  
									config.save();
									
						        	var queryRole = new Parse.Query(Parse.Role);
									queryRole.equalTo('name', 'admin');
									queryRole.first({useMasterKey:true}).then(function(adminRole){								

										var adminRoleRelation = adminRole.relation("users");
				        				adminRoleRelation.add(userLogged);	

			    						adminRole.save(null, {useMasterKey: true});

			    						loadImagesArray(config);

									});	

								},
								error: function(user, error) {
									  // Show the error message somewhere and let the user try again.
									  alert("Error: " + error.code + " " + error.message);
								}
							});

						},
						error: function (response, error) {
						    console.log('Error: ' + error.message);
						}

					}); 
					
			    } 
	        },
	        error: function(error) {
	            error.message("ChatFeed lookup failed");
	        }
	    });
	}

	function loadImagesArray(configPF) {	

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

    	for (var i=0; i<count; i++) {

    		var imagesArray = [];

    		var _url = files[i];
    		
    		var cd=0, id=0;

    		var configRel = configPF.relation("images");

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

                image.save(null, {											
					success: function (savedImage) {	 

						configRel.add(savedImage);

						//console.log("id: "+id);
						//console.log("count: "+count);

		            	if ( id == (count-1) ){	            				            	

		            		configPF.save();	            		
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


			
