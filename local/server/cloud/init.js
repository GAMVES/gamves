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
					var user = new Parse.User();
					user.set("username", _admuser);
					user.set("password", "lo vas a lograr");
					
					var acl = new Parse.ACL();
    				acl.setPublicReadAccess(false);
    				acl.setPublicWriteAccess(false);
    				user.setACL(acl);

					user.signUp(null, {
						success: function(user) {
						  
						  	console.log("LLEGA");
						  	
							var app_id 			= "0123456789";
							var server_url 		= "http://192.168.16.22:1337/1/";	
							var app_icon_url 	= "https://api-parseground.s3.amazonaws.com/deab76060e176261cfdbb8d779dd1e32_gamves_icons_white.png";
							var hasIcon 		= false;

							var Config = Parse.Object.extend("Config");
							var config = new Config();

							config.set("server_url", server_url); 
							config.set("app_id", app_id);
							config.set("app_icon_url", app_icon_url);                  
							config.set("hasIcon", hasIcon);                  

							config.save(null, {
								
								success: function (savedConfig) {

								    initializeClasses();             
								},
								error: function (response, error) {
								    console.log('Error: ' + error.message);
								}

							}); 
						},
						error: function(user, error) {
							  // Show the error message somewhere and let the user try again.
							  alert("Error: " + error.code + " " + error.message);
						}
					});
			    } 
	        },
	        error: function(error) {
	            error.message("ChatFeed lookup failed");
	        }
	    });
	}

	// --
	// Initial script for Config and other classes.

	function initializeClasses() { 

		//var Schools = Parse.Object.extend("Schools");
		//var school = new Schools();
		//school.save();

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


	}	