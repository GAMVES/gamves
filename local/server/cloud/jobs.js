

  // --
  // Download Youtube Video and save it. 

  Parse.Cloud.job("CalculateTrendingFanpages", function(request, status) {

        fanpageTrending();

  });

  
  function fanpageTrending() {

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

    	console.log("count: " + favorites.length);

    	if( favorites.length > 0) {					

			var totals = {}

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

	    }

	}).then(function(sorted) { 		

		sortedFavorites = sorted;

		console.log(sortedFavorites);		

		var queryFanpages = new Parse.Query("Fanpages");		 
        return queryFanpages.find();

	}).then(function(fanpages) {

		for (var i=0; i < fanpages.length; i++) {

			var fanpage = fanpages[i];	

			isTrending = getTrending(sortedFavorites, fanpage.id);	

			//console.log("isTrending: " + isTrending);				

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

				fanpageCallback.save(null, { useMasterKey: true } );
			

			});		

		}   


  	}, function(error) {	    

	    response.error(error);

	});	

};	

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

	console.log("remove all");

	var queryFanpages = new Parse.Query("Fanpages");		        

     queryFanpages.find().then(function(fanpages) {

     	console.log("lenght: " + fanpages.length);

    	if( fanpages.length > 0) 
        {

        	for (var i = 0; i < fanpages.length; i++) {

        		var fanpage = fanpages[i];	

        		var categoryRelation = fanpage.relation("category");

				findTrendingCategory(fanpage, categoryRelation, function(fanpageCallback, categoryRelationCallback, ){

					categoryRelationCallback.remove(categoryTrending);

					fanpageCallback.save(null, { useMasterKey: true } );

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

				console.log(category.get("name"));			

				if (category.get("name") == "TRENDING") {

					console.log("REmoving");

					console.log(fanpage.get("pageName"));

					callback(fanpage, categoryRelation);					
					
				}
			}					

		},
	    error: function(error) {

	    	console.log(error);
	    }

	});

}