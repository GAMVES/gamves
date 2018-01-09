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

    			var imageBuffer = httpResponse.buffer;
                var base64 = imageBuffer.toString("base64");                

                var name;
                if (cd==0) { 
                	name = "personal";                 
                } else if (cd==1) { 
                	name = "personal_background";                 
                } else if (cd==2) { 
                	name = "trending"; 
                } else if (cd==3) { 
                	name = "trending_background"; 
                } else if (cd==4) { 
                	name = "universe"; 
                } else { 
                	name = "image_" + cd; 
                }                

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

				cd++            	
       		});    			
    	}
	}


			
