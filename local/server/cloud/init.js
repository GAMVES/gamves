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
								  
								  	console.log("LLEGA");
								  	
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
											
										console.log("entra");
										console.log(adminRole);										

										var adminRoleRelation = adminRole.relation("users");
				        				adminRoleRelation.add(userLogged);	

			    						adminRole.save(null, {useMasterKey: true});

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


			
