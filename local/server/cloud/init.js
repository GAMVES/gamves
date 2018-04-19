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
										config.set("badWords", "4r5e|5h1t|5hit|a55|anal|anus|ar5e|arrse|arse|ass|ass-fucker|asses|assfucker|assfukka|asshole|assholes|asswhole|a_s_s|b!tch|b00bs|b17ch|b1tch|ballbag|balls|ballsack|bastard|beastial|beastiality|bellend|bestial|bestiality|bi\+ch|biatch|bitch|bitcher|bitchers|bitches|bitchin|bitching|bloody|blow job|blowjob|blowjobs|boiolas|bollock|bollok|boner|boob|boobs|booobs|boooobs|booooobs|booooooobs|breasts|buceta|bugger|bum|bunny fucker|butt|butthole|buttmuch|buttplug|c0ck|c0cksucker|carpet muncher|cawk|chink|cipa|cl1t|clit|clitoris|clits|cnut|cock|cock-sucker|cockface|cockhead|cockmunch|cockmuncher|cocks|cocksuck|cocksucked|cocksucker|cocksucking|cocksucks|cocksuka|cocksukka|cok|cokmuncher|coksucka|coon|cox|crap|cum|cummer|cumming|cums|cumshot|cunilingus|cunillingus|cunnilingus|cunt|cuntlick|cuntlicker|cuntlicking|cunts|cyalis|cyberfuc|cyberfuck|cyberfucked|cyberfucker|cyberfuckers|cyberfucking|d1ck|damn|dick|dickhead|dildo|dildos|dink|dinks|dirsa|dlck|dog-fucker|doggin|dogging|donkeyribber|doosh|duche|dyke|ejaculate|ejaculated|ejaculates|ejaculating|ejaculatings|ejaculation|ejakulate|f u c k|f u c k e r|f4nny|fag|fagging|faggitt|faggot|faggs|fagot|fagots|fags|fanny|fannyflaps|fannyfucker|fanyy|fatass|fcuk|fcuker|fcuking|feck|fecker|felching|fellate|fellatio|fingerfuck|fingerfucked|fingerfucker|fingerfuckers|fingerfucking|fingerfucks|fistfuck|fistfucked|fistfucker|fistfuckers|fistfucking|fistfuckings|fistfucks|flange|fook|fooker|fuck|fucka|fucked|fucker|fuckers|fuckhead|fuckheads|fuckin|fucking|fuckings|fuckingshitmotherfucker|fuckme|fucks|fuckwhit|fuckwit|fudge packer|fudgepacker|fuk|fuker|fukker|fukkin|fuks|fukwhit|fukwit|fux|fux0r|f_u_c_k|gangbang|gangbanged|gangbangs|gaylord|gaysex|goatse|God|god-dam|god-damned|goddamn|goddamned|hardcoresex|hell|heshe|hoar|hoare|hoer|homo|hore|horniest|horny|hotsex|jack-off|jackoff|jap|jerk-off|jism|jiz|jizm|jizz|kawk|knob|knobead|knobed|knobend|knobhead|knobjocky|knobjokey|kock|kondum|kondums|kum|kummer|kumming|kums|kunilingus|l3i\+ch|l3itch|labia|lust|lusting|m0f0|m0fo|m45terbate|ma5terb8|ma5terbate|masochist|master-bate|masterb8|masterbat*|masterbat3|masterbate|masterbation|masterbations|masturbate|mo-fo|mof0|mofo|mothafuck|mothafucka|mothafuckas|mothafuckaz|mothafucked|mothafucker|mothafuckers|mothafuckin|mothafucking|mothafuckings|mothafucks|mother fucker|motherfuck|motherfucked|motherfucker|motherfuckers|motherfuckin|motherfucking|motherfuckings|motherfuckka|motherfucks|muff|mutha|muthafecker|muthafuckker|muther|mutherfucker|n1gga|n1gger|nazi|nigg3r|nigg4h|nigga|niggah|niggas|niggaz|nigger|niggers|nob|nob jokey|nobhead|nobjocky|nobjokey|numbnuts|nutsack|orgasim|orgasims|orgasm|orgasms|p0rn|pawn|pecker|penis|penisfucker|phonesex|phuck|phuk|phuked|phuking|phukked|phukking|phuks|phuq|pigfucker|pimpis|piss|pissed|pisser|pissers|pisses|pissflaps|pissin|pissing|pissoff|poop|porn|porno|pornography|pornos|prick|pricks|pron|pube|pusse|pussi|pussies|pussy|pussys|rectum|retard|rimjaw|rimming|s hit|s.o.b.|sadist|schlong|screwing|scroat|scrote|scrotum|semen|sex|sh!\+|sh!t|sh1t|shag|shagger|shaggin|shagging|shemale|shi\+|shit|shitdick|shite|shited|shitey|shitfuck|shitfull|shithead|shiting|shitings|shits|shitted|shitter|shitters|shitting|shittings|shitty|skank|slut|sluts|smegma|smut|snatch|son-of-a-bitch|spac|spunk|s_h_i_t|t1tt1e5|t1tties|teets|teez|testical|testicle|tit|titfuck|tits|titt|tittie5|tittiefucker|titties|tittyfuck|tittywank|titwank|tosser|turd|tw4t|twat|twathead|twatty|twunt|twunter|v14gra|v1gra|vagina|viagra|vulva|w00se|wang|wank|wanker|wanky|whoar|whore|willies|willy|xrated|abanto|abrazafarolas|adufe|afloja|alcornoque|alfeñíque|anal|andurriasmo|argentuzo|argentuso|argentucho|arrastracueros|Arse|Arsehole|arseholes|artabán|artaban|ass|asshole|assholes|auschwitz|ausschwitz|aguebonado|aguebonada|agüevonado|agüevonada|asco|asqueroso|asquerosa|aweonado|aweonada|awebonado|awebonada|awevonado|awevonada|baboso|babosa|babosadas|basura|Bellaco|bitch|bizcocho|blow|Blowjob|Bollocks|bolú|bolu|boludo|b0ludo|bolud0|b0lud0|boluda|b0luda|boobs|bufarron|bufarrón|bujarron|bujarrón|buey|Bullshit|buttfuck|buttfucker|cabilla|cabron|cabrón|cabrona|caca|Cachapera|cagalera|cagar|caga|cagante|cagarla|cagaste|cagaste|cagón|cagon|cagona|cancer|cáncer|Carado|caramonda|caramono|caremono|caramondá|caraculo|careculo|carepito|carapito|carapendejo|carependejo|castra|castroso|castrosa|castrante|chacha|chachar|chichar|chichis|chilote|chinga|chinga tu madre|chingadera|chingada|chingado|chíngate|chingate|chingar|chingas|chingaste|chingo|chingon|chingón|chingona|chingues|chinguisa|chinguiza|Chink|Chinky|chiquitingo|chocha|chój|chucha|chuchamadre|chuj|chupalo|chúpalo|chúpala|chupala|chwdp|cipa|cipo|cochon|cochón|cock|Cock|Cocks|Cocksucker|cogas|cojas|coger|cojete|cojón|cojon|cochar|coshar|cocho|comecaca|comepollas|comepoyas|coñazo|coñaso|concha|conchatumadre|conchadetumadre|conxetumare|conxetumadre|conxatumare|conxatumadre|conchetumare|conchatumare|coño|creido|creído|creida|creída|cuca|cueco|Cul|culea|culear|culera|culero|culiado|culiada|culiao|culia|culiad@|culo|Culo|Cum|Cunt|cunts|ctm|csm|Dick|Dickhead|Dicks|encabrona|encabronado|encabronada|emputar|enputar|emputo|enputo|empute|emputado|emputada|enputado|enputada|encular|Enculé|enculer|encula|enculada|enculado|enculo|estafador|estafadora|estupido|estúpido|estupida|estúpida|Faggot|falkland|falklands|fucklands|fuckland|falangista|fascista|Fellatio|fick|fistfuck|follada|follar|follo|follón|follon|Fook|Fooker|Fooking|Fotze|follada|foyada|frei|frijolero|Fuck|Fucker|Fuckers|Fucking|Führer|garcha|gilipolla|guatepeor|jilipolla|gachupín|gachupin|gilipoya|jilipoya|gonorrea|guevon|guevón|guevona|guey|heil|hideputa|hijodeputa|hijoputa|hdp|hitler|Hitler|hueva|huevon|huevón|huevona|HWDP|idiota|imbécil|imbecil|jalabola|Japseye|jeba&H107|jebanie|jebca|jilipollas|Jizz|job|jodan|jodas|jodaz|joder|jodido|jodida|joto|joyo|judenmutter|judensöhne|kaka|caka|kaca|kabron|kabrón|kabrona|Kike|korwa|kórwa|kurwa|kurwia|kutas|leck|leche|lexe|m4nco|macht|maldito|maldita|malnacida|Malnacido|malparida|malparido|Malvinas|mamada|mamadas|mamado|mamalo|mámalo|mamarla|mamaste|mames|mamón|mamon|mamona|manco|manko|manca|maraca|Marica|marico|Maricon|Maricón|maricones|maricona|mariconas|mariconson|mariconsón|mariconzón|mariconzon|mariqueta|mariquis|mayate|meco|mecos|melgambrea|merde|mexicaca|mejicaca|mexicoño|mejicoño|mejicaño|mexicaño|mich|mierda|m1erda|mierdero|mondá|monda|Mong|moraco|motherfucker|Motherfucking|Nazi|neger|negrata|Nègre|negrero|nekrofil|Nigga|Nigger|niggers|Niquer|no mames|odbyt|odjeba&H142o|ojete|ogete|pajear|pajote|Paki|pakis|panocha|Paragua|payaso|payasa|pecheche|peda|pederasta|pedo|pedota|pedota|pedofila|pedófila|pedofilo|pedófilo|pedón|pendeja|pendejear|pendejo|pendejos|pendejas|pelotudo|pel0tud0|pelotuda|pel0tuda|pene|percanta|perra|Perucho|pete|pierdol|pierdolic|pierdolona|Pinacate|pinche|pinches|pinga|pirobo|pito|pitudo|pizda|polla|porno|poronga|poya|Prick|Pricks|prostiputo|prostiputa|prostituir|prostituta|prostituto|proxeneta|pt|pucha|Puñeta|Pussy|puta|Putain|Putaso|Putazo|pute|Pute|Putete|putillo|putiyo|putito|putita|putitos|putitas|Putiza|puto|putos|putón|ql|qli40|qliao|qli4o|qlia0|qliaos|qli40s|qli4os|qlia0s|Queer|raghead|ragheads|rallig|ramera|rape|reculia|reculiao|retardado|retrasado|retrazado|renob|reql|rentafuck|ridiculo|ridículo|ridicula|ridícula|rimjob|rimming|rozpierdala&H107|rozpierdolone|rozpierdolony|rucha&H107|ruchanie|ruha&H107|ruski|ruskoff|ruskov|s-c-v-m|s.hit|s&m|s1ut|sackgesicht|sado-masochistic|sadomaso|sadomasochistic|sadomasoquismo|sadomasoquista|salame|salvatrucha|salvatrusha|salbatrucha|salbatrusha|samckdaddy|sandm|sandnigger|sangron|sangrón|sangrona|sangrones|sangronas|sarasa|sarracena|sarraceno|satan|satán|satánico|satanico|sausagejockey|sc*m|scat|schamhaar|scheiss|schlampe|schleu|schleuh|schlitzauge|schlong|schutzstaffel|schwanz|schwuchtel|scrote|scum|scum!|sh!t|sh!te|sh!tes|sh1\'t|sh1t|sh1te|sh1thead|sh1theads|shadybackroomdealings|shadydealings|shag|shaggers|shaggin|shagging|shat|shawtypimp|sheep-l0ver|sheep-l0vers|sheep-lover|sheep-lovers|sheep-shaggers|sheepl0ver|sheepl0vers|sheeplover|sheepshaggers|sheethead|sheetheads|sheister|shhit|shit|shít|shit4brains|shitass|shitbag|shitbagger|shitbrains|shitbreath|shitcunt|shitdick|shiteater|shited|shitface|shitfaced|shitforbrains|shitfuck|shitfucker|shitfull|shithapens|shithappens|shithead|shithole|shithouse|shiting|shitings|shitoutofluck|shits|shitspitter|shitstabber|shitstabbers|shitstain|shitted|shitter|shitters|shittiest|shitting|shittings|shitty|shiz|shiznit|shortfuck|shortfuck|shyte|sida|s1da|sidoso|s1doso|slag|slanderyou2.blogspot.com|slanteye|slut|slutbag|sluts|slutt|slutting|slutty|slutwear|slutwhore|slutwhore|smackdaddy|smackthemonkey|smagma|smartass|smeg|snortingcoke|sonofabitch|sorete|sonofbitch|soplapollas|soplapoyas|Spacka|Spast|Spasten|Spasti|Spaz|Spunk|Spunkbubble|sranie|subnormal|sucker|sudaca|sudaka|tarado|tarada|tarados|taradas|tarugo|tetas|tetona|tolete|tortillera|tortiyera|torpe|traga|Tranny|Twat|verga|vergasen|vergón|vergon|violar|Violer|Wank|Wanker|weon|weona|wey|wn wehon|wheon|weohn|weonh |w3on|wetback|wyjeb&H107|wyjebac|wyjebany|wypierdol|xuxa|xuxas|Yoruga|zajeba&H107|zajebane|zajebany|zemen|zooplapollas|zoplapollas|zorra|zorriputa|zudaca|zudaka");  										                
										config.save();
										
							        	var queryRole = new Parse.Query(Parse.Role);
										queryRole.equalTo('name', 'admin');
										queryRole.first({useMasterKey:true}).then(function(adminRole){								

											var adminRoleRelation = adminRole.relation("users");
					        				adminRoleRelation.add(userLogged);	

				    						adminRole.save(null, {useMasterKey: true});

				    						loadImagesArray(config, function(universeImage){

				    							var Profile = Parse.Object.extend("Profile");         

									            profile = new Profile();    								            

												profile.set("pictureBackground", universeImage);

												profile.set("bio", "Gamves Administrator");		

												profile.set("backgroundColor", [228, 239, 245]);

												profile.save(null, {useMasterKey: true});


				    						});

										});	

									},
									error: function(user, error) {
										  // Show the error message somewhere and let the user try again.
										  alert("Error: " + error.code + " " + error.message);
									}
								});
		                                                   
		                                                            
		                  }, function(error) {                    
		                      status.error("Error downloading thumbnail"); 
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

    	var universeImage;

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
					universeImage = image;
                }

                image.save(null, {											
					success: function (savedImage) {	 

						configRel.add(savedImage);

						//console.log("id: "+id);
						//console.log("count: "+count);

		            	if ( id == (count-1) ){	            				            	

		            		configPF.save();	     

		            		callback(universeImage);

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


			
