	require('./jobs');	
	require('./functions');
	require('./acls');	
	require('./users');

	var _admuser = "gamvesadmin";

	// --
	// Run startup script

	Parse.Cloud.define("InitializeGamves", function(request, response) {

		var t = "user_type";
		var d = "description";

		var adminLogged, universePFile;
		var adminRole, schoolRole, userRole, parentRole;

		var app_icon_url = "https://s3.amazonaws.com/gamves/config/gamves.png";					

		Parse.Cloud.httpRequest({url: app_icon_url}).then(function(httpResponse) {
      
           	var imageBuffer = httpResponse.buffer;
           	var base64 = imageBuffer.toString("base64");
           	var iconFile = new Parse.File("gamves.png", { base64: base64 });                                	

           	console.log("--2--");

           	var adminUser = new Parse.User();
			adminUser.set("username", _admuser);
			adminUser.set("name", "Gamves Official");
			adminUser.set("firstName", "Gamves");
			adminUser.set("lastName", "Official");
			adminUser.set("pictureSmall", iconFile);
			adminUser.set("password", "lo vas a lograr");
			adminUser.set(t, -1);				

			adminUser.signUp(null, {useMasterKey: true}).then(function(userLoggedPF) {	

				adminLogged = userLoggedPF;				

				var roleAdminName = "admin";
				var aRole = new Parse.Role(roleAdminName, new Parse.ACL());			

				var aacl = new Parse.ACL();
				aacl.setReadAccess(aRole, true); 
				aacl.setWriteAccess(aRole, true); 

				aRole.setACL(aacl);						   

				return aRole.save(null, {useMasterKey: true});
			
			}).then(function(adminRolePF) {			

				var adminRoleRelation = adminRolePF.relation("users");
				adminRoleRelation.add(adminLogged);
				return adminRolePF.save(null, {useMasterKey: true});

			}).then(function(adminRolePF) {

				adminRole = adminRolePF;	

				var roleSchoolsName = "schools";
				var cRole = new Parse.Role(roleSchoolsName, new Parse.ACL());			

				var cacl = new Parse.ACL();
				cacl.setReadAccess(cRole, true); 
				cacl.setWriteAccess(cRole, true); 

				cRole.setACL(cacl);						   

				return cRole.save(null, {useMasterKey: true});

			}).then(function(schoolRolePF) {

				var schoolRoleRelation = schoolRolePF.relation("users");
				schoolRoleRelation.add(adminLogged);
				return schoolRolePF.save(null, {useMasterKey: true});	

			}).then(function(schoolRolePF) {

				schoolRole = schoolRolePF;

			    var roleUserName = "users";
				var uRole = new Parse.Role(roleUserName, new Parse.ACL());			

				var uacl = new Parse.ACL();
				uacl.setReadAccess(uRole, true); 
				uacl.setWriteAccess(uRole, true); 

				uRole.setACL(uacl);						   

				return uRole.save(null, {useMasterKey: true});

			}).then(function(userRolePF) {						

				var userRoleRelation = userRolePF.relation("users");
				userRoleRelation.add(adminLogged);
				return userRolePF.save(null, {useMasterKey: true});	

			}).then(function(userRolePF) {

				userRole = userRolePF;

			    /*var roleParentName = "parents";
				var pRole = new Parse.Role(roleParentName, new Parse.ACL());			

				var pacl = new Parse.ACL();
				pacl.setReadAccess(pRole, true); 
				pacl.setWriteAccess(pRole, true); 

				pRole.setACL(pacl);						   

				return pRole.save(null, {useMasterKey: true});

			}).then(function(parentRolePF) {						

				var parentRoleRelation = parentRolePF.relation("users");
				parentRoleRelation.add(adminLogged);
				return parentRolePF.save(null, {useMasterKey: true});	

			}).then(function(parentRolePF) {*/	

				//parentRole = parentRolePF;

				var UserTypes = Parse.Object.extend("UserType");					

				var registerMother = new UserTypes();
				registerMother.set(t, 0);
				registerMother.set(d, "Register-Mother");
				registerMother.save(null, {useMasterKey: true});

				var partnerMother = new UserTypes();
				partnerMother.set(t, 1);
				partnerMother.set(d, "Partner-Mother");
				partnerMother.save(null, {useMasterKey: true});

				var son = new UserTypes();
				son.set(t, 2);
				son.set(d, "Son");
				son.save(null, {useMasterKey: true});

				var daughter = new UserTypes();
				daughter.set(t, 3);
				daughter.set(d, "Daughter");
				daughter.save(null, {useMasterKey: true});

				var partnerFather = new UserTypes();
				partnerFather.set(t, 4);
				partnerFather.set(d, "Partner-Father");
				partnerFather.save(null, {useMasterKey: true});

				var registerFather = new UserTypes();
				registerFather.set(t, 5);
				registerFather.set(d, "Register-Father");
				registerFather.save(null, {useMasterKey: true});

				var adminType = new UserTypes();
				adminType.set(t, -1);
				adminType.set(d, "Administrator");	
				return adminType.save(null, {useMasterKey: true});

			}).then(function(adminTypePF) {	

				var adminRelation = adminLogged.relation("userType");
				adminRelation.add(adminTypePF);

				return adminLogged.save(null, {useMasterKey: true});

			}).then(function(userUpdatedPF) {	

				adminLogged = userUpdatedPF;

				//GamvesDev
				var app_id 			= "DinPu5dG42HU12QxN50ES4GVjk1NysN4WXUSy2L5";
				var master_key		= "nfGsBeYvQzd91gN2b7TsBalU63LtFitSDilU5yV0";
				var rest_api 		= "gHSkASeguRjV6M7wu1UrIeePRssQkF7ejzKpGLc2";
				
				var server_url 		= "https://parseapi.back4app.com";											
				
				var hasIcon 		= false;

				//Config
				var Config = Parse.Object.extend("Config");
				var config = new Config();

				config.set("server_url", server_url); 
				config.set("app_id", app_id);
				config.set("master_key", master_key);
				config.set("rest_api", rest_api);
				config.set("app_icon_url", app_icon_url);  
				config.set("iconPicture", iconFile);
				config.set("hasIcon", hasIcon);   
				config.set("badWords", "4r5e|5h1t|5hit|a55|anal|anus|ar5e|arrse|arse|ass|ass-fucker|asses|assfucker|assfukka|asshole|assholes|asswhole|a_s_s|b!tch|b00bs|b17ch|b1tch|ballbag|balls|ballsack|bastard|beastial|beastiality|bellend|bestial|bestiality|bi\+ch|biatch|bitch|bitcher|bitchers|bitches|bitchin|bitching|bloody|blow job|blowjob|blowjobs|boiolas|bollock|bollok|boner|boob|boobs|booobs|boooobs|booooobs|booooooobs|breasts|buceta|bugger|bum|bunny fucker|butt|butthole|buttmuch|buttplug|c0ck|c0cksucker|carpet muncher|cawk|chink|cipa|cl1t|clit|clitoris|clits|cnut|cock|cock-sucker|cockface|cockhead|cockmunch|cockmuncher|cocks|cocksuck|cocksucked|cocksucker|cocksucking|cocksucks|cocksuka|cocksukka|cok|cokmuncher|coksucka|coon|cox|crap|cum|cummer|cumming|cums|cumshot|cunilingus|cunillingus|cunnilingus|cunt|cuntlick|cuntlicker|cuntlicking|cunts|cyalis|cyberfuc|cyberfuck|cyberfucked|cyberfucker|cyberfuckers|cyberfucking|d1ck|damn|dick|dickhead|dildo|dildos|dink|dinks|dirsa|dlck|dog-fucker|doggin|dogging|donkeyribber|doosh|duche|dyke|ejaculate|ejaculated|ejaculates|ejaculating|ejaculatings|ejaculation|ejakulate|f u c k|f u c k e r|f4nny|fag|fagging|faggitt|faggot|faggs|fagot|fagots|fags|fanny|fannyflaps|fannyfucker|fanyy|fatass|fcuk|fcuker|fcuking|feck|fecker|felching|fellate|fellatio|fingerfuck|fingerfucked|fingerfucker|fingerfuckers|fingerfucking|fingerfucks|fistfuck|fistfucked|fistfucker|fistfuckers|fistfucking|fistfuckings|fistfucks|flange|fook|fooker|fuck|fucka|fucked|fucker|fuckers|fuckhead|fuckheads|fuckin|fucking|fuckings|fuckingshitmotherfucker|fuckme|fucks|fuckwhit|fuckwit|fudge packer|fudgepacker|fuk|fuker|fukker|fukkin|fuks|fukwhit|fukwit|fux|fux0r|f_u_c_k|gangbang|gangbanged|gangbangs|gaylord|gaysex|goatse|God|god-dam|god-damned|goddamn|goddamned|hardcoresex|hell|heshe|hoar|hoare|hoer|homo|hore|horniest|horny|hotsex|jack-off|jackoff|jap|jerk-off|jism|jiz|jizm|jizz|kawk|knob|knobead|knobed|knobend|knobhead|knobjocky|knobjokey|kock|kondum|kondums|kum|kummer|kumming|kums|kunilingus|l3i\+ch|l3itch|labia|lust|lusting|m0f0|m0fo|m45terbate|ma5terb8|ma5terbate|masochist|master-bate|masterb8|masterbat*|masterbat3|masterbate|masterbation|masterbations|masturbate|mo-fo|mof0|mofo|mothafuck|mothafucka|mothafuckas|mothafuckaz|mothafucked|mothafucker|mothafuckers|mothafuckin|mothafucking|mothafuckings|mothafucks|mother fucker|motherfuck|motherfucked|motherfucker|motherfuckers|motherfuckin|motherfucking|motherfuckings|motherfuckka|motherfucks|muff|mutha|muthafecker|muthafuckker|muther|mutherfucker|n1gga|n1gger|nazi|nigg3r|nigg4h|nigga|niggah|niggas|niggaz|nigger|niggers|nob|nob jokey|nobhead|nobjocky|nobjokey|numbnuts|nutsack|orgasim|orgasims|orgasm|orgasms|p0rn|pawn|pecker|penis|penisfucker|phonesex|phuck|phuk|phuked|phuking|phukked|phukking|phuks|phuq|pigfucker|pimpis|piss|pissed|pisser|pissers|pisses|pissflaps|pissin|pissing|pissoff|poop|porn|porno|pornography|pornos|prick|pricks|pron|pube|pusse|pussi|pussies|pussy|pussys|rectum|retard|rimjaw|rimming|s hit|s.o.b.|sadist|schlong|screwing|scroat|scrote|scrotum|semen|sex|sh!\+|sh!t|sh1t|shag|shagger|shaggin|shagging|shemale|shi\+|shit|shitdick|shite|shited|shitey|shitfuck|shitfull|shithead|shiting|shitings|shits|shitted|shitter|shitters|shitting|shittings|shitty|skank|slut|sluts|smegma|smut|snatch|son-of-a-bitch|spac|spunk|s_h_i_t|t1tt1e5|t1tties|teets|teez|testical|testicle|tit|titfuck|tits|titt|tittie5|tittiefucker|titties|tittyfuck|tittywank|titwank|tosser|turd|tw4t|twat|twathead|twatty|twunt|twunter|v14gra|v1gra|vagina|viagra|vulva|w00se|wang|wank|wanker|wanky|whoar|whore|willies|willy|xrated|abanto|abrazafarolas|adufe|afloja|alcornoque|alfeñíque|anal|andurriasmo|argentuzo|argentuso|argentucho|arrastracueros|Arse|Arsehole|arseholes|artabán|artaban|ass|asshole|assholes|auschwitz|ausschwitz|aguebonado|aguebonada|agüevonado|agüevonada|asco|asqueroso|asquerosa|aweonado|aweonada|awebonado|awebonada|awevonado|awevonada|baboso|babosa|babosadas|basura|Bellaco|bitch|bizcocho|blow|Blowjob|Bollocks|bolú|bolu|boludo|b0ludo|bolud0|b0lud0|boluda|b0luda|boobs|bufarron|bufarrón|bujarron|bujarrón|buey|Bullshit|buttfuck|buttfucker|cabilla|cabron|cabrón|cabrona|caca|Cachapera|cagalera|cagar|caga|cagante|cagarla|cagaste|cagaste|cagón|cagon|cagona|cancer|cáncer|Carado|caramonda|caramono|caremono|caramondá|caraculo|careculo|carepito|carapito|carapendejo|carependejo|castra|castroso|castrosa|castrante|chacha|chachar|chichar|chichis|chilote|chinga|chinga tu madre|chingadera|chingada|chingado|chíngate|chingate|chingar|chingas|chingaste|chingo|chingon|chingón|chingona|chingues|chinguisa|chinguiza|Chink|Chinky|chiquitingo|chocha|chój|chucha|chuchamadre|chuj|chupalo|chúpalo|chúpala|chupala|chwdp|cipa|cipo|cochon|cochón|cock|Cock|Cocks|Cocksucker|cogas|cojas|coger|cojete|cojón|cojon|cochar|coshar|cocho|comecaca|comepollas|comepoyas|coñazo|coñaso|concha|conchatumadre|conchadetumadre|conxetumare|conxetumadre|conxatumare|conxatumadre|conchetumare|conchatumare|coño|creido|creído|creida|creída|cuca|cueco|Cul|culea|culear|culera|culero|culiado|culiada|culiao|culia|culiad@|culo|Culo|Cum|Cunt|cunts|ctm|csm|Dick|Dickhead|Dicks|encabrona|encabronado|encabronada|emputar|enputar|emputo|enputo|empute|emputado|emputada|enputado|enputada|encular|Enculé|enculer|encula|enculada|enculado|enculo|estafador|estafadora|estupido|estúpido|estupida|estúpida|Faggot|falkland|falklands|fucklands|fuckland|falangista|fascista|Fellatio|fick|fistfuck|follada|follar|follo|follón|follon|Fook|Fooker|Fooking|Fotze|follada|foyada|frei|frijolero|Fuck|Fucker|Fuckers|Fucking|Führer|garcha|gilipolla|guatepeor|jilipolla|gachupín|gachupin|gilipoya|jilipoya|gonorrea|guevon|guevón|guevona|guey|heil|hideputa|hijodeputa|hijoputa|hdp|hitler|Hitler|hueva|huevon|huevón|huevona|HWDP|idiota|imbécil|imbecil|jalabola|Japseye|jeba&H107|jebanie|jebca|jilipollas|Jizz|job|jodan|jodas|jodaz|joder|jodido|jodida|joto|joyo|judenmutter|judensöhne|kaka|caka|kaca|kabron|kabrón|kabrona|Kike|korwa|kórwa|kurwa|kurwia|kutas|leck|leche|lexe|m4nco|macht|maldito|maldita|malnacida|Malnacido|malparida|malparido|Malvinas|mamada|mamadas|mamado|mamalo|mámalo|mamarla|mamaste|mames|mamón|mamon|mamona|manco|manko|manca|maraca|Marica|marico|Maricon|Maricón|maricones|maricona|mariconas|mariconson|mariconsón|mariconzón|mariconzon|mariqueta|mariquis|mayate|meco|mecos|melgambrea|merde|mexicaca|mejicaca|mexicoño|mejicoño|mejicaño|mexicaño|mich|mierda|m1erda|mierdero|mondá|monda|Mong|moraco|motherfucker|Motherfucking|Nazi|neger|negrata|Nègre|negrero|nekrofil|Nigga|Nigger|niggers|Niquer|no mames|odbyt|odjeba&H142o|ojete|ogete|pajear|pajote|Paki|pakis|panocha|Paragua|payaso|payasa|pecheche|peda|pederasta|pedo|pedota|pedota|pedofila|pedófila|pedofilo|pedófilo|pedón|pendeja|pendejear|pendejo|pendejos|pendejas|pelotudo|pel0tud0|pelotuda|pel0tuda|pene|percanta|perra|Perucho|pete|pierdol|pierdolic|pierdolona|Pinacate|pinche|pinches|pinga|pirobo|pito|pitudo|pizda|polla|porno|poronga|poya|Prick|Pricks|prostiputo|prostiputa|prostituir|prostituta|prostituto|proxeneta|pt|pucha|Puñeta|Pussy|puta|Putain|Putaso|Putazo|pute|Pute|Putete|putillo|putiyo|putito|putita|putitos|putitas|Putiza|puto|putos|putón|ql|qli40|qliao|qli4o|qlia0|qliaos|qli40s|qli4os|qlia0s|Queer|raghead|ragheads|rallig|ramera|rape|reculia|reculiao|retardado|retrasado|retrazado|renob|reql|rentafuck|ridiculo|ridículo|ridicula|ridícula|rimjob|rimming|rozpierdala&H107|rozpierdolone|rozpierdolony|rucha&H107|ruchanie|ruha&H107|ruski|ruskoff|ruskov|s-c-v-m|s.hit|s&m|s1ut|sackgesicht|sado-masochistic|sadomaso|sadomasochistic|sadomasoquismo|sadomasoquista|salame|salvatrucha|salvatrusha|salbatrucha|salbatrusha|samckdaddy|sandm|sandnigger|sangron|sangrón|sangrona|sangrones|sangronas|sarasa|sarracena|sarraceno|satan|satán|satánico|satanico|sausagejockey|sc*m|scat|schamhaar|scheiss|schlampe|schleu|schleuh|schlitzauge|schlong|schutzstaffel|schwanz|schwuchtel|scrote|scum|scum!|sh!t|sh!te|sh!tes|sh1\'t|sh1t|sh1te|sh1thead|sh1theads|shadybackroomdealings|shadydealings|shag|shaggers|shaggin|shagging|shat|shawtypimp|sheep-l0ver|sheep-l0vers|sheep-lover|sheep-lovers|sheep-shaggers|sheepl0ver|sheepl0vers|sheeplover|sheepshaggers|sheethead|sheetheads|sheister|shhit|shit|shít|shit4brains|shitass|shitbag|shitbagger|shitbrains|shitbreath|shitcunt|shitdick|shiteater|shited|shitface|shitfaced|shitforbrains|shitfuck|shitfucker|shitfull|shithapens|shithappens|shithead|shithole|shithouse|shiting|shitings|shitoutofluck|shits|shitspitter|shitstabber|shitstabbers|shitstain|shitted|shitter|shitters|shittiest|shitting|shittings|shitty|shiz|shiznit|shortfuck|shortfuck|shyte|sida|s1da|sidoso|s1doso|slag|slanderyou2.blogspot.com|slanteye|slut|slutbag|sluts|slutt|slutting|slutty|slutwear|slutwhore|slutwhore|smackdaddy|smackthemonkey|smagma|smartass|smeg|snortingcoke|sonofabitch|sorete|sonofbitch|soplapollas|soplapoyas|Spacka|Spast|Spasten|Spasti|Spaz|Spunk|Spunkbubble|sranie|subnormal|sucker|sudaca|sudaka|tarado|tarada|tarados|taradas|tarugo|tetas|tetona|tolete|tortillera|tortiyera|torpe|traga|Tranny|Twat|verga|vergasen|vergón|vergon|violar|Violer|Wank|Wanker|weon|weona|wey|wn wehon|wheon|weohn|weonh |w3on|wetback|wyjeb&H107|wyjebac|wyjebany|wypierdol|xuxa|xuxas|Yoruga|zajeba&H107|zajebane|zajebany|zemen|zooplapollas|zoplapollas|zorra|zorriputa|zudaca|zudaka");  										                               
				config.set("colorsChat", "ed1e1e|ed1e8e|ed1ee6|bf1eed|841eed|1e36ed|ed891e|1eb20f|acb20f|10aca6|ac7e10|9911ef|a811ef|ef1184|ef4a11");
				
				return config.save(null, {useMasterKey: true});

			}).then(function(configPF) {


				//--
				// Add admin role to Config and set ACL to a sensitive class

				Parse.Cloud.run("AddRoleToObject", { "pclassName": "Config" , "objectId": configPF.id, "role" : "admin" });

				//--
				// Adding public role for parents 

				Parse.Cloud.run("AddRoleByName", { name: "parent_user" });                  

				loadImagesArray(configPF, function(universeFile){

					return universeFile;

				});	

			}).then(function(pFile) { 

				universePFile = pFile;

				var Profile = Parse.Object.extend("Profile");         

	            profile = new Profile();												
	            profile.set("pictureBackground", universePFile);
				profile.set("bio", "Gamves Administrator");		
				profile.set("backgroundColor", [228, 239, 245]);
				profile.set("userId", adminLogged.id);					

				return profile.save(null, {useMasterKey: true}); 

			}).then(function(profilePF) {                    

            	loadPetsArray( function(universePFile) {

            		Parse.Cloud.run("CreateClasses");

            		response.success(resutl);

            	});           	
			});
		});		
	});	


	Parse.Cloud.define("CreateClasses", function( request, response ) {

		var newClasses = [
		 "Approvals",
		 "Audios",
		 "ChatFeed",
		 "Chats",
		 "FriendsApproval",
		 "Notifications",
		 "UserStatus",
		 "Recommendations",
		 "UserVerified"
		 ];

		for (var i=0; i < newClasses.length; i++) {
			var NewClass = Parse.Object.extend(newClasses[i]);	
			var newClass = new NewClass();
			newClass.save(null, { useMasterKey: true } );
		}		

	});
	

	function loadImagesArray(configPF, callback) {	

		var files = [
			"https://s3.amazonaws.com/gamves/images/personal.png",
			"https://s3.amazonaws.com/gamves/images/personal_background.png",
			"https://s3.amazonaws.com/gamves/images/trending.png",
			"https://s3.amazonaws.com/gamves/images/trending_background.png",    		
			"https://s3.amazonaws.com/gamves/images/universe.png",
			"https://s3.amazonaws.com/gamves/images/image_0.png",
			"https://s3.amazonaws.com/gamves/images/image_1.png",
			"https://s3.amazonaws.com/gamves/images/image_2.png",
			"https://s3.amazonaws.com/gamves/images/image_3.png",
			"https://s3.amazonaws.com/gamves/images/image_4.png",
			"https://s3.amazonaws.com/gamves/images/welcome.png"
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

				var image_0 			= 'c6db094717e232f8f0';
				var image_1 			= '84d0d2b51f2e3c8ba9';
				var image_2 			= '9ed10f7d8aa562616b';
				var image_3 			= '7c2591a73767372af3';
				var image_4 			= 'bbec6d8f987fc64b04';
				var personal 			= '2a05a8c7c83314a78f';
				var personal_background = '3eef7323eec2ca381b';
				var trending 			= 'de45444c2e8a6127a3';
				var trending_background = '162cb6095941216264';
				var universe 			= '3093cdd35eaf6ba21f';
				var welcome 			= 'dca79d3f7006b25a20';
				
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
				} else if (etag.indexOf(welcome) >= 0) {

					name = 'welcome'; 
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

						console.log("id: "+id);
						console.log("count: "+count);

		            	if ( id == (count - 1) ) {

		            		console.log("counted_callback");	            				            	

		            		configPF.save(null, { useMasterKey: true } );	     

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

	function loadPetsArray(callback) {	

		var files = [
			"https://s3.amazonaws.com/gamves/pets/dog.png",
			"https://s3.amazonaws.com/gamves/pets/cat.png",
			"https://s3.amazonaws.com/gamves/pets/chicken.png",
			"https://s3.amazonaws.com/gamves/pets/pig.png"			
			/*"https://s3.amazonaws.com/gamves/images/personal_background.png",
			"https://s3.amazonaws.com/gamves/images/trending.png",
			"https://s3.amazonaws.com/gamves/images/trending_background.png",    		
			"https://s3.amazonaws.com/gamves/images/universe.png",
			"https://s3.amazonaws.com/gamves/images/image_0.png",
			"https://s3.amazonaws.com/gamves/images/image_1.png",
			"https://s3.amazonaws.com/gamves/images/image_2.png",
			"https://s3.amazonaws.com/gamves/images/image_3.png",
			"https://s3.amazonaws.com/gamves/images/image_4.png",
			"https://s3.amazonaws.com/gamves/images/welcome.png"*/
		];

		var count = files.length;		

		for (var i=0; i<count; i++) {

			var imagesArray = [];

			var _url = files[i];
			
			var cd=0, id=0;						

			Parse.Cloud.httpRequest({url: _url}).then(function(httpResponse) {   			

				var headers = httpResponse.headers;
				var etag = headers.etag.trim(); 

				etag.replace(/['"]+/g, '')

				console.log("etag: " + etag);			    			

				var name, description;               

				var image_0 			= '3eb6e5073338bb1eff8807095e72c55c';
				var image_1 			= '8aa2d80695cac2f1ac7151715693cbba';
				var image_2 			= '373be15f6e6f58af9b76704f47790445';
				var image_3 			= 'f8fa92301bbfe323c3f19cd13d2355e7';
				
				/*var image_4 			= 'bbec6d8f987fc64b04';
				var personal 			= '2a05a8c7c83314a78f';
				var personal_background = '3eef7323eec2ca381b';
				var trending 			= 'de45444c2e8a6127a3';
				var trending_background = '162cb6095941216264';
				var universe 			= '3093cdd35eaf6ba21f';
				var welcome 			= 'dca79d3f7006b25a20';*/
				
				if (etag.indexOf(image_0) >= 0) {

					name = 'dog';
					descritpion = 'The friendly dog'; 
				
				} else if (etag.indexOf(image_1) >= 0) {

					name = 'cat';
					descritpion = 'The lovely cat'; 
				
				} else if (etag.indexOf(image_2) >= 0) {

					name = 'chicken';
					descritpion = 'The singing chicken'; 
				
				} else if (etag.indexOf(image_3) >= 0) {

					name = 'pig';				
					descritpion = 'The fat pig'; 
				} 

				/*else if (etag.indexOf(image_4) >= 0) {

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

					
				} else if (etag.indexOf(welcome) >= 0) {

					name = 'welcome'; 
				}*/

				//console.log("name: " + name);
				//console.log("---------------------------------");			    			

				var imageBuffer = httpResponse.buffer;
	            var base64 = imageBuffer.toString("base64");                          

	            var Pet = Parse.Object.extend("Pets");
				var pet = new Pet();

	            var file = new Parse.File(name+".jpg", { base64: base64 }, "image/png");
	            pet.set("image", file);
	            pet.set("name", name); 	
	            pet.set("descritpion", descritpion); 					                       

	            pet.save(null, {											
					success: function (savedImage) {	 						

						console.log("id: "+id);
						console.log("count: "+count);

		            	if ( id == (count - 1) ) {
		            		
		            		callback();
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
	// _User afterSave for email verification into UserVerified class

	Parse.Cloud.afterSave("_User", function(request, response) {

		var userId = request.object.id;
		var iDUserType = request.object.get("user_type"); // request.params.user_type;
		var username = request.object.get("username");
		var schoolShort = request.object.get("schoolShort");

		console.log("username : " + username + " _admuser: " + _admuser ); 	

		console.log("user: " + JSON.stringify(request.object));

		if ( username != _admuser ) {			

			var emailVerified = request.object.get("emailVerified");

			console.log("_User : " + userId); 		

			var userVerifiedQuery = new Parse.Query("UserVerified");
			userVerifiedQuery.equalTo("userId", userId);		

			userVerifiedQuery.find({
		        useMasterKey: true,
		        success: function(results) {

		        	console.log("success"); 

		        	console.log("results.length: " + results.length); 	
		        	       	
		        	if( results.length == 0) {

						setUserVerified(userId, false);					

				    } else {

				    	console.log("schoolShort : " + schoolShort ); 	

				    	if (schoolShort == undefined) { 	

				    		console.log( "schoolShort undefined" ); 				

					    	var verifiedObject = results[0]; 					

							verifiedObject.set("emailVerified", emailVerified);		

							verifiedObject.save(null, { useMasterKey: true } );

							//Add roles 														

							var friendOfRole = "friendOf___" + userId;

							console.log("friendOf___ : " + friendOfRole ); 	

							Parse.Cloud.run("AddRoleByName", { "name": friendOfRole, "removeId": userId}).then(function(familyRolePF) {	

								Parse.Cloud.run("AddUserToRole", { "userId": userId, "role": friendOfRole});									

								Parse.Cloud.run("AddUserToRole", { "userId": userId, "role" : "schools" });	

								if (iDUserType!=2 || iDUserType!=3) { // only parents add this permission			

									Parse.Cloud.run("AddUserToRole", { "userId": userId, "role" : "parent_user" });							
								}

							});						
						
						} else {
							
							Parse.Cloud.run("AddUserToRole", { "userId": userId, "role": schoolShort});							

						}	
					} 

					response.success(true);  

		        },
		        error: function(error) {

		        	console.log("error: " +error); 	
		         
		         	setUserVerified(userId, false);

			        response.success(true);   
		        }      

			});

		} else {

			console.log("username = _admuser"); 	

		}
	});




	function setUserVerified(id, status) {

		var UserVerified = Parse.Object.extend("UserVerified"); 

        var userVerified = new UserVerified();  

        userVerified.set("userId", id);    

        userVerified.set("emailVerified", status);                    

        userVerified.save();  

	}
	// --
	// Update or create Budges

	Parse.Cloud.afterSave("Chats", function(request) {		

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

	    //Add points
		savePointByUserId(userId, 1);

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
		var videoId = request.object.get("videoId");

		if ( source_type == 1 ) { //LOCAL

			saveFanpage(request, function(){});

		} else if ( source_type == 2 || source_type == 3 ) { //YOUTUBE

			if (!removed && downloaded) {

				var ytb_videoId = request.object.get("ytb_videoId");				
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

				if (source_type == 2) {
					saveFanpage(request, function(){});
				}

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
				                          source_type: source_type
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
			}
		} 

		var posterId = request.object.get("posterId");

		//- Save points for Video
		savePointByUserId(posterId, 10);

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
	            var video = youtubedl('http://www.youtube.com/watch?v=' + ytb_videoId, ['--format=18','--restrict-filenames'], { cwd: __dirname }); 

	            var fs = require('fs');	            

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
	// Save Recommendations download thumbnail

	Parse.Cloud.afterSave("Recommendations", function(request) {

		var ytb_thumbnail_source = request.object.get("ytb_thumbnail_source");

		Parse.Cloud.httpRequest({url: ytb_thumbnail_source}).then(function(httpResponse) {
                  
	    	var imageBuffer = httpResponse.buffer;
	       	var base64 = imageBuffer.toString("base64");
	       	var file = new Parse.File(request.object.id+".jpg", { base64: base64 });   

	       	request.object.set("thumbnail", file);            
	       	request.object.save(null, { useMasterKey: true } );     


	  	}, function(error) {                    
	      console.log("Error downloading thumbnail"); 
	  	});
	});


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

		var notificationSaved;		

		if ( (approved==0 || approved==1) && !notified) { 

			var userPF; 

			var Notification = Parse.Object.extend("Notifications");         
	        var notification = new Notification();	

	        var dataPush = [];

			var userQuery = new Parse.Query(Parse.User);
			userQuery.equalTo("objectId", posterId);
		    userQuery.first().then(function(user) {

		    	userPF = user;

		    	notification.set("posterName", user.get("name"));
		    	notification.set("posterAvatar", user.get("picture"));
		    	notification.set("posterId", posterId);

		    	if (type == 1) {

		    		var vtitle = "New video from " + user.get("name");
		    		dataPush.push(vtitle);

			        var videoQuery = new Parse.Query("Videos");
			        videoQuery.equalTo("videoId", referenceId);
			        return videoQuery.first();

			    } else if (type == 2) {

			    	var ftitle = "New fanpage from " + user.get("name");
			    	dataPush.push(ftitle);

			    	var fanpagelQuery = new Parse.Query("Fanpages");
			        fanpagelQuery.equalTo("fanpageId", referenceId);
			        return fanpagelQuery.first();
			    }

		    }).then(function(object) {

		    	var name = userPF.get("name");
		    	var title = "<b>" + name + "</b> has shared a ";

		    	if (type == 1) { //Video

					notification.set("title", title + " video"); //object.get("title"));
		    		notification.set("description", object.get("title")); //object.get("description"));	    		
		    		notification.set("cover", object.get("thumbnail"));
		    		notification.set("referenceId", object.get("videoId"));
		    		notification.set("date", object.get("createdAt"));
		    		notification.set("video", object);

		    	} else if (type == 2) { //Fanpage

		    		notification.set("title", title + " fanpage"); //object.get("pageName"));
		    		notification.set("description", object.get("pageName")); //object.get("pageAbout"));
		    		notification.set("cover", object.get("pageCover"));	    		
		    		notification.set("referenceId", object.get("fanpageId"));
		    		notification.set("date", object.get("createdAt"));
		    		notification.set("fanpage", object);
		    	}

		    	notification.set("type", type);

		    	notification.set("removeId", posterId);

		    	return notification.save(null, {useMasterKey: true});

			}).then(function(savedNotification) {

				let reoleFriend = "friendOf___" + posterId;

				Parse.Cloud.run("AddRoleToObject", { "pclassName": "Notifications", "objectId": savedNotification.id, "role" : reoleFriend });

				notificationSaved = savedNotification;

				var friendslQuery = new Parse.Query("Friends");
			    friendslQuery.equalTo("userId", posterId);
			    return friendslQuery.first();

			}).then(function(friends) {

				var friendsArray = friends.get("friends");
				notificationSaved.set("friends", friendsArray);

				return notificationSaved.save(null, {useMasterKey: true});

			}).then(function(saved) {	

				notificationSaved = saved;

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


	// --
	// Get Location reverse-geocoding.	

	Parse.Cloud.afterSave("Location", function(request) {		

		var hasCoder = request.object.get("hasCoder");
		//console.log("hasCoder: " +hasCoder);
		
		if ( !hasCoder || hasCoder == undefined ) {

			//console.log("Does not hasCoder");
			var geolocation = request.object.get("geolocation");

			var latitude = geolocation.latitude;
			var longitude = geolocation.longitude;			
			let geoAll = latitude  + "," + longitude;

			var url = "https://maps.googleapis.com/maps/api/geocode/json";
			var key = "AIzaSyAi_6G5rwhbTYkqyjo4wjzPJaz1uJYuTHI";			
			var urlParams = url + "?" + "latlng=" + geoAll + "&key=" + key;
			//console.log("urlParams: " + urlParams);

			Parse.Cloud.httpRequest({			
				url: urlParams, 
				method: "GET"				
				}).then(function(httpResponse) {            	

	            	var allAdrs = JSON.parse(httpResponse.text).results[0].formatted_address; //data.results[0].formatted_address;

					console.log("allAdrs: " + allAdrs);

			        var res = allAdrs.split(",");

			        request.object.set("address", res[0]);
			        request.object.set("city", res[1]);
			        request.object.set("state", res[2]);
			        request.object.set("country", res[3]);
			        request.object.set("hasCoder", true);
					request.object.save(); 	            	

				},function(httpResponse) {				  
				  	// error
				  	console.error('Request failed with response code ' + httpResponse.status);
			});

			// Package
			//"node-geocoder": "^3.22.0"

			/*var geocoder = require('geocoder');

			geocoder.reverse( latitude, longitude, function ( err, data ) {

				if(err){

			        console.log(err);
			        //response.error('Error! ' + err);
			    } else {
			        
			        //console.log(data);
			        //response.success(data.results[0].formatted_address);

			        var allAdrs = data.results[0].formatted_address;

			        var res = allAdrs.split(",");

			        request.object.set("address", res[0]);
			        request.object.set("city", res[1]);
			        request.object.set("state", res[2]);
			        request.object.set("country", res[3]);
			        request.object.set("hasCoder", true);
					request.object.save();  

					///AIzaSyAi_6G5rwhbTYkqyjo4wjzPJaz1uJYuTHI

			    }
	  			
			});*/
		}		

	});

	// --
	// count Points for Fanpage

	Parse.Cloud.afterSave("Fanpages", function(request) {

		var posterId = request.object.get("posterId");
		
		savePointByUserId(posterId, 20);

	});

	// --
	// count New Friends

	Parse.Cloud.afterSave("FriendsApproval", function(request) {

		//Save Points
		var posterId = request.object.get("posterId");	

		savePointByUserId(posterId, 5);

		var friendId = request.object.get("friendId");
		var type = request.object.get("type");
		var approved = request.object.get("approved");		

		console.log("-------------------------------");		

		console.log("posterId: " + posterId + " friendId: " + friendId);					

		getUsersObject(posterId, friendId, function(usersArray) {				

		 	var posterPF, friendPF;	

		 	posterPF = usersArray[0];
			friendPF = usersArray[1];					  

			console.log("posterPF: " + posterPF + " friendPF: " + friendPF);						 			 	

			var posterName = posterPF.get("name");				
			var friendName = friendPF.get("name");	 		

			console.log("type: " + type + " approved: " + approved);		

			if ( type == 1 && approved == 0 ) {

				let Notifications = Parse.Object.extend("Notifications");	   

				console.log("posterName: " + posterName + " friendName: " + friendName);					
		    	
				let posterImage = posterPF.get("pictureSmall");			

				let notificationFriendRequest = new Notifications();
				
				let titleNotification = "<b>" + posterName + "</b> sent you a friend request"; 
				let descNotification  = "Start interacting with " + posterName + " , check out the profile, accept his/her friendship and start chatting!"; 				

				notificationFriendRequest.set("posterAvatar", posterImage);
				notificationFriendRequest.set("title", titleNotification);	
				notificationFriendRequest.set("description", descNotification);	
				notificationFriendRequest.set("posterName", posterName);

				//notificationFriendRequest.add("target", friendId);	

				notificationFriendRequest.set("date", request.object.get("createdAt"));								

				//notificationFriendRequest.set("cover", coverPoster);
				notificationFriendRequest.set("posterId", posterPF.id);	

				notificationFriendRequest.set("removeId", posterPF.id);					
				
				notificationFriendRequest.set("type", 3);				

				notificationFriendRequest.save(null, {useMasterKey: true});	

				notificationFriendRequest.save(null, { useMasterKey: true,	
					success: function (notificationSaved) {	

						let reoleFriend = "friendOf___" + friendId;

						Parse.Cloud.run("AddRoleToObject", { "pclassName": "Notifications", "objectId": notificationFriendRequest.id, "role" : reoleFriend });

					},
					error: function (response, error) {											
					    
					    console.log("error: " + error);		
					}
				});

				let objFriend = {
		    		title:titleNotification,
		    		alert:"You have a friend invitation request",
		    		user:posterPF,		    		
		    		data:posterName
		    	};
		    	sendPushToUser(objFriend);	


			} else if ( type == 2 && approved == 2 ) {

				// Friends Roles				

				let rolePoster = "friendOf___" + posterPF.id;

				Parse.Cloud.run("AddUserToRole", { "role": rolePoster, "userId": friendPF.id });

				let roleFriend = "friendOf___" + friendPF.id;

				Parse.Cloud.run("AddUserToRole", { "role": roleFriend, "userId": posterPF.id });				

				// Get Fanpages Images to Create notifications						

				var queryFanpage = new Parse.Query("Fanpages");
				queryFanpage.equalTo('categoryName', 'PERSONAL');
				queryFanpage.containedIn("posterId", [posterId, friendId]);    	

				return queryFanpage.find({useMasterKey:true}).then(function(restulFanpagesPF) {					
				
					let count = restulFanpagesPF.length;   				

					let coverFriend, coverPoster;     		

			    	for (var i=0; i < count; i++) {
				        					                
				        var id = restulFanpagesPF[i].get("posterId");

				        if (id == friendId) {
				        	coverFriend = restulFanpagesPF[i].get("pageCover");
				        } else if (id == posterId) {
				        	coverPoster = restulFanpagesPF[i].get("pageCover");
				        }
				    }			    

			    	let Notifications = Parse.Object.extend("Notifications");				    	

					//- Poster notification											
					
					let friendImage = friendPF.get("pictureSmall");

					let notificationPoster = new Notifications();
					
					let titlePoster = "<b>" + friendName + "</b> accepted your freind's request"; 
					let descPoster  = "Start interacting with " + friendName + " , check out the profile and start chatting!"; 

					
					notificationPoster.set("posterAvatar", friendImage);
					notificationPoster.set("title", titlePoster);	
					notificationPoster.set("description", descPoster);	
					notificationPoster.set("posterName", posterName);
					notificationPoster.set("cover", coverPoster);
					notificationPoster.set("posterId", friendPF.id);		
					notificationPoster.set("removeId", posterId);								
					notificationPoster.set("type", 3);							
					
					//notificationPoster.save(null, {useMasterKey: true});													
				
					let objPoster = {
			    		title:titlePoster,
			    		alert:"You have a new friend!",
			    		user:posterPF,		    		
			    		data:descPoster
			    	};
			    	sendPushToUser(objPoster);

			    	//- Friend notification				    	
			    					
			    	let posterImage = posterPF.get("pictureSmall");		    	

					let notificationFriend = new Notifications();
					
					let titleFriend = "<b>" + posterName + "</b> and you are friends!"; 
					let descFriend  = "Start interacting with " + posterName + " , check out the profile and start chatting!"; 					

					notificationFriend.set("posterAvatar", posterImage);
					notificationFriend.set("title", titleFriend);			
					notificationFriend.set("description", descFriend);	
					notificationFriend.set("posterName", friendName);
					notificationFriend.set("cover", coverFriend);
					notificationFriend.set("posterId", posterPF.id);	
					notificationFriend.set("removeId", friendId);	
					
					notificationFriend.set("type", 3);						
					
					//notificationFriend.save(null, {useMasterKey: true}); 										

					let objFriend = {
			    		title:titleFriend,
			    		alert:"You have a new friend!",
			    		user:friendPF,		    		
			    		data:descFriend
			    	};
			    	sendPushToUser(objFriend);				    	

			    	return Parse.Object.saveAll([notificationPoster, notificationFriend]);

			    }).then(function(restulNotificationsPF) {   

			    	//Notification Reole 			    	
			    	
			    	let notiPoster = restulNotificationsPF[0];
			    	
					notiPoster.set("date", request.object.get("createdAt"));			

					let notiFriend = restulNotificationsPF[1];
					
					notiFriend.set("date", request.object.get("createdAt"));													

					return Parse.Object.saveAll([notiPoster, notiFriend]);

				}).then(function(resutlAll) { 

					let reolePoster = "friendOf___" + posterId;	  

					Parse.Cloud.run("AddRoleToObject", { "pclassName": "Notifications", "objectId": resutlAll[0].id, "role" : reolePoster });					

					let reoleFriend = "friendOf___" + friendId;	  

					Parse.Cloud.run("AddRoleToObject", { "pclassName": "Notifications", "objectId": resutlAll[1].id, "role" : reoleFriend });			     					
					

				});
			}

		});
	});


	function getUsersObject(posterId, friendId, callback) {
		
	    var posterPF, friendPF;	

	    // Query poster user

		var posterQuery = new Parse.Query(Parse.User);		
		posterQuery.equalTo("objectId", posterId);
			
		return posterQuery.first({useMasterKey:true}).then(function(restulPosterPF) {				

			posterPF = restulPosterPF;

			// Query friend user

			var friendQuery = new Parse.Query(Parse.User);		
			friendQuery.equalTo("objectId", friendId);

			return friendQuery.first({useMasterKey:true});

	    }).then(function(restulFriendPF) {   	

			friendPF = restulFriendPF;

			let usersArray = [posterPF,friendPF];

			callback(usersArray)
		
		});

	}



	// --
	// count Likes

	Parse.Cloud.afterSave("Likes", function(request) {

		var userId = request.object.get("userId");
		
		savePointByUserId(userId, 2);

	});


	// --
	// SavePoints for action.	

	function savePointByUserId(userId, points) {

		var userQuery = new Parse.Query(Parse.User);
			userQuery.equalTo("username", "gamvesadmin");
		    userQuery.first().then(function(user) {

	    	if ( user.id != userId ) {

		    	var Points = Parse.Object.extend("Points");
				var point = new Points();
				point.set("userId", userId);
				point.set("points", points);		
				point.save();  
			}

		 });		
	}

	function sendPushToUser(obj) {	

		var title 		 = obj.title;
		var alert 		 = obj.alert;		
		var user 	 	 = obj.user;
		var data 		 = obj.data;
		var notification = obj.notification;

		// Find devices associated with these users
		var pushQuery = new Parse.Query(Parse.Installation);
		pushQuery.matchesQuery('user', user);

		// Send push notification to query
		Parse.Push.send({
		  where: pushQuery,
		  data: {
	          "title":title,
	          "alert":alert,
	          "data":data
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
	   
	}

	// --
	// Update users and create roles upon Family creation

	Parse.Cloud.afterSave("Family", function(request) {			 

		var object = request.object;		

		var familyId = request.object.id;

		var short = object.get("short");		

		var familyRoleName = "familyOf___" + familyId;

		Parse.Cloud.run("AddRoleByName", { "name": familyRoleName, "removeId": familyId }).then(function(familyRolePF) {  			

			var schoolQuery = request.object.relation("school").query();
			schoolQuery.first({useMasterKey:true}).then(function(schoolPF){

				var schoolId = schoolPF.id;

				var shortSchool = schoolPF.get("short");						

				var levelQuery = request.object.relation("level").query();					
				levelQuery.first({useMasterKey:true}).then(function(levelPF){

					var levelId = levelPF.id;

					console.log("famlyId: " + familyId);
					console.log("schoolId: " + schoolId);
					console.log("levelId: " + levelId);

					var usersQuery = request.object.relation("members").query();
					usersQuery.find({useMasterKey:true}).then(function(usersPF){

						for (var i = 0; i < usersPF.length; ++i) 
						{
							
							Parse.Cloud.run("AddUserToRole", { "userId": usersPF.id, "role": familyRoleName});

							usersPF[i].set("schoolId", schoolId);
							usersPF[i].set("familyId", familyId);
							usersPF[i].set("levelId", levelId);
							
							usersPF[i].save(null, {useMasterKey: true});
						}
					});
				});				
			});
		});	
	});

