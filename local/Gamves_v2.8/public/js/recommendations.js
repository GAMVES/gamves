
document.addEventListener("LoadRecommendations", function(event){

      var fanpageId = event.detail.fanpageId;
      var categoryName = event.detail.categoryName;
      var schoolId = event.detail.schoolId;     
      var short = event.detail.short;  

      var fanpageObj;
      var appIconFile;   

      var familiesArray = [];   

      var parseFileThumbanil;

      loadOtherSchools(schoolId);
      loadRecommendation();
      loadFamilies();

      var recommendationLenght = 0;

      function loadFamilies() 
      {

        var querySchool = new Parse.Query("Schools");    
        console.log(schoolId);         
        querySchool.equalTo("objectId", schoolId);
        querySchool.first({

            success: function (schoolPF) {  

                if (schoolPF) {

                    let levelRelation = schoolPF.relation("levels");
                    let queryLevel = levelRelation.query();

                    queryLevel.find().then(function(levelsPF) {

                        console.log(levelsPF.length);

                        if (levelsPF.length > 0) {

                            for (var j=0; j < levelsPF.length; j++) {

                                let levelPF = levelsPF[j];
                                         
                                let relFamilies = levelPF.relation("families");
                                let queryFamilies = relFamilies.query();
                                queryFamilies.find().then(function(familiesPF) {

                                    if (familiesPF.length > 0) {

                                        for (var i=0; i < familiesPF.length; i++) {

                                            let familyPF = familiesPF[i];

                                            let desc = familyPF.get("description");

                                            console.log("desc: " + desc);

                                            let familyJson = {"desc": desc, "object":familyPF}; 

                                            familiesArray.push(familyJson);

                                        }
                                    }    

                                });
                            }    
                        }
                    });

                }
            },
            error: function (error) {
                console.log("Error: " + error.code + " " + error.message);
            }    


        }); 


      }

      function loadRecommendation()
      {

        var queryRecommendation = new Parse.Query("Recommendations");             
        queryRecommendation.equalTo("type", 2);
        queryRecommendation.find({
            success: function (recommendation) {                                   

                if (recommendation) {                                 

                    recommendationLenght = recommendation.length;
                var dataJson = [];

                for (var i = 0; i < recommendationLenght; ++i) 
                {
                    item = {};
                    item["id"] = i+1;
                    var objectId = recommendation[i].id;
                    dataJson.objectId = objectId;
                    item["objectId"] = objectId;                  
                    
                    if (recommendation[i].get("thumbnail") != undefined){                
                        var thumbnail = recommendation[i].get("thumbnail");
                        item["thumbnail"] = thumbnail._url;
                    } else {
                        item["thumbnail"] = "https://dummyimage.com/60x60/286090/ffffff.png&text=NA";
                    }
                    
                    var title = recommendation[i].get("title");
                    item["title"] = title;

                    var description = recommendation[i].get("description");
                    item["description"] = description;

                    if (recommendation[i].get("ytb_thumbnail_source") != undefined){
                        var source = recommendation[i].get("ytb_thumbnail_source");
                        item["source"] = source;
                    } else {
                        item["source"] = "https://dummyimage.com/150x60/286090/ffffff.png&text=Not+Available";
                    }
                    dataJson.push(item);
                }                          

                var heaaderGridRecommendation = "<div id=\"{{ctx.id}}\" class=\"{{css.header}}\"><div class=\"row\"><div class=\"col-sm-12 actionBar\"><div class=\"btn\"><div id=\"loader_recommendation\" class=\"loader\"/></div>";

                heaaderGridRecommendation += "<button id=\"new_suggestion\" type=\"button\" class=\"btn btn-primary\"><span class=\"glyphicon glyphicon-plus-sign\">&nbsp;</span> New Suggestion </button>&nbsp;&nbsp;";

                heaaderGridRecommendation += "<button id=\"new_recommendation\" type=\"button\" class=\"btn btn-primary\"><span class=\"glyphicon glyphicon-plus-sign\">&nbsp;</span> New Recommendation </button>";

                heaaderGridRecommendation += " <p class=\"{{css.search}}\"></p><p class=\"{{css.actions}}\"></p></div></div></div>";

                var rowIds = [];
                var grid = $("#gridRecommendations").bootgrid({                  
                    templates: {
                        header: heaaderGridRecommendation
                    }, 
                    caseSensitive: true,
                    selection: true,
                    multiSelect: true,                  
                    formatters: {              
                        "thumbnail": function (column, row) {
                            return "<img src=\"" + row.thumbnail + "\" height=\"30\" width=\"30\"/>";
                        },
                        "source": function (column, row) {
                            return "<video src=\"" + row.source + "\" height=\"60\" width=\"150\" type=\"video/mp4\"/>";
                        },
                        "commands": function(column, row) {
                            return "<button type=\"button\" class=\"btn btn-xs btn-default command-delete\" data-row-id=\"" + row.id + "\"><span class=\"glyphicon glyphicon-trash\"></span></button>&nbsp;" + 
                                "<button type=\"button\" class=\"btn btn-xs btn-default command-edit\" data-row-id=\"" + row.id + "\"><span class=\"glyphicon glyphicon-edit\"></span></button>&nbsp;";
                                
                        }                   
                    }     

                }).on("selected.rs.jquery.bootgrid", function(e, rows) {

                    rowIds = [];
                    for (var i = 0; i < rows.length; i++)
                    {
                        rowIds.push(rows[i].id);
                        rowIds.push(rows[i].id);
                    }
                    //alert("Select: " + rowIds.join(","));
                }).on("deselected.rs.jquery.bootgrid", function(e, rows)
                {
                    var rowIds = [];
                    for (var i = 0; i < rows.length; i++)
                    {
                        rowIds.push(rows[i].id);
                    }

                }).on("loaded.rs.jquery.bootgrid", function() {                        

                        $("#loader_recommendation").hide(); 
                        
                        $( "#new_recommendation" ).unbind("click").click(function() {

                                $("#recommendation_title").text("New Recommendation"); 

                                $('#edit_modal_recommendation').modal('show');

                                $('#recommendations_viewed_videos').empty();                          

                                let name = "Schools";

                                $('#recommendations_viewed_videos').append('<input name="accesories" type="checkbox" value=""/> '+ name +'<br/>');
                                

                        });  

                        $( "#new_suggestion" ).unbind("click").click(function() {

                            $("#suggestion_title").text("New Suggestion"); 

                            $('#edit_modal_suggestion').modal('show');

                            $("#input_thumb_screenshot").unbind("change").change(function() {
                                loadThumbImage(this);
                            });

                            var selectList = document.getElementById('dynamic_parents_combo');

                            var length = familiesArray.length;
                            
                            for (var i=0; i<length; i++) {

                                var option = document.createElement("option");

                                 option.value = familiesArray[i].object;
                                 option.text = familiesArray[i].desc;
                                 selectList.appendChild(option);

                     
                            }
               
                        });
                                    
                        grid.find(".command-edit").unbind("click").on("click", function(e) {

                        //alert("You pressed edit on row: " + $(this).data("row-id"));
                        var ele = $(this).parent();
                        var g_id = $(this).parent().siblings(':first').html();
                        var g_name = $(this).parent().siblings(':nth-of-type(2)').html();

                        console.log(g_id);
                        console.log(g_name);

                        //console.log(grid.data());//
                        $('#edit_modal_recommendation').modal('show');

                        if ($(this).data("row-id") >0) {

                            var f = ele.siblings(':first').html();                        
                            var a1 = ele.siblings(':nth-of-type(1)').html();
                            var a2 = ele.siblings(':nth-of-type(2)').html();
                            var a3 = ele.siblings(':nth-of-type(3)');
                            var a4 = ele.siblings(':nth-of-type(4)').html();
                            var a5 = ele.siblings(':nth-of-type(5)').html();
                            var a6 = ele.siblings(':nth-of-type(6)').html();
                            var a7 = ele.siblings(':nth-of-type(7)').html();

                            // collect the data
                            //$('#edit_id').val(ele.siblings(':first').html());                                                
                            $("#edit_thumbnail").append(a4);
                            $('#edit_title').val(a5);
                            $('#edit_description').val(a6);
                            $('#edit_source').append(a7); 

                            //$("#fanpage_title").text("Edit video - " + a5);                      

                        } else {
                            alert('Now row selected! First select row, then click edit button');
                        }

                    }).end().find(".command-delete").on("click", function(e) {                           

                    }).end().find(".command-video").on("click", function(e) {                                  

                    });
                });                     

                } else {
                    console.log("Nothing found, please try again");
                }

                grid.bootgrid("clear");
                grid.bootgrid("append", dataJson);

            },
            error: function (error) {
                console.log("Error: " + error.code + " " + error.message);
            }
        });   
      
    }
       
    var videoUrl, vId, title, desc, thumbnailUrl, upload_date, view_count, tags, duration, category, like_count;
    var parseFileThumb;      

    $( "#btn_edit_recommendation" ).click(function() {

        saveRecommendation();

    });


    $( "#btn_edit_suggestion" ).click(function() {

        saveSuggestion();

    });

    

    $( "#edit_youtube_check_recommendation" ).unbind("click").click(function() {           

        $('#video_spinner').show();   

         videoUrl = $("#edit_youtube_video_id_recommendation").val();

         vId = videoUrl.split("watch?v=")[1];                                              

         Parse.Cloud.run("GetYoutubeVideoInfo", { videoId: vId }).then(function(result) {    

            console.log("__________________________");                         
            console.log(JSON.stringify(result));       

            title = result.fulltitle;                  
            $("#edit_title_recommendation").val(title);
            desc = result.description;
            $("#edit_description_recommendation").val(desc);
            thumbnailUrl = result.thumbnail;
            $('#img_thumbnail_recommendation').attr('src', thumbnailUrl); 

            upload_date = result.upload_date;

            if ( result.view_count != undefined ){ 

              view_count = result.view_count;

            } else {

              view_count = 0;
            }

            
            tags = result.tags;
            duration = result.duration;
            categories = result.categories,
            like_count = result.like_count;                  

         }, function(error) {

            console.log("error :" +errort);
            // error

            $('#error_message').html("<p>" + errort + "</p>");

        });  

      });    

      function saveSuggestion() {

            var Recommendation = Parse.Object.extend("Recommendations");         
            var recommendation = new Recommendation();  

            recommendation.set("title", $("#edit_title_suggestion").val());
            recommendation.set("description", $("#edit_title_suggestion").val());    
     
            recommendation.set("thumbnail", parseFileThumbanil);
     
            //var videoRelation = recommendation.relation("video");
            //videoRelation.add(savedVideo);                                  

            recommendation.set("type", 3); // SUGGESTION

            recommendation.save(null, {
              success: function (savedReccomendation) {                                                                           

                Parse.Cloud.run("AddRoleToObject", { "pclassName": "Recommendations", "objectId": savedReccomendation.id, "role" : role }).then(function(result) {                                                                  

                    $('#edit_modal_suggestion').modal('hide');

                    clearField();
                    loadRecommendation();

                });

              },
              error: function (response, error) {
                    $('#error_message').html("<p>" + errort + "</p>");
                    console.log('Error: ' + error.message);
              }
            }); 


      }    

      function saveRecommendation() {              

          var userQuery = new Parse.Query(Parse.User);         
          userQuery.equalTo("username", "gamvesadmin");
          userQuery.first({
              success: function (userAdmin) {
                  
                  if (userAdmin) { 
                        
                    var VideosRecommendation = Parse.Object.extend("Videos");
                    var videoRecommendation = new VideosRecommendation();              

                    videoRecommendation.set("downloaded", false);
                    videoRecommendation.set("authorized", true);
                    videoRecommendation.set("title", title);
                    videoRecommendation.set("description", desc);
                    videoRecommendation.set("posterId", userAdmin.id);          
                    videoRecommendation.set("poster_name", userAdmin.get("name"));
                    videoRecommendation.set("s3_source", "");
                    videoRecommendation.set("webpage_url", videoUrl);
                    videoRecommendation.set("thumbnail_source", thumbnailUrl);
                    videoRecommendation.set("ytb_videoId", vId);
                    videoRecommendation.set("upload_date", upload_date);
                    videoRecommendation.set("view_count", view_count);       
                    videoRecommendation.set("tags", tags);
                    videoRecommendation.set("duration", duration);         
                    videoRecommendation.set("categories", categories);
                    videoRecommendation.set("public", true);                    
                    videoRecommendation.set("folder", "admvideos");
                    videoRecommendation.set("fanpageId", Math.floor(100000 + Math.random() * 900000));              
                    videoRecommendation.set("videoId", Math.floor(100000 + Math.random() * 900000));              
                    videoRecommendation.set("poster_name", "Gamves Official");                        
                    videoRecommendation.set("source_type", 3);     
                    videoRecommendation.set("approved", true);  

                    videoRecommendation.save(null, {
                        success: function (savedVideo) {                                 

                            window.GetCheckedInclude("frm_edit_recommendation", function(result) {

                              let role;

                              if  (result) {
                                  role = "parent_user";
                              } else {
                                  role = short;
                              }  

                              Parse.Cloud.run("AddRoleToObject", { "pclassName": "Videos", "objectId": savedVideo.id, "role" : role }).then(function(result) {                                                                  
                                  
                                  console.log('Video created successful with name: ' + savedVideo.get("title"));                         

                                  var Recommendation = Parse.Object.extend("Recommendations");         
                                  var recommendation = new Recommendation();  

                                  recommendation.set("title", savedVideo.get("title"));
                                  recommendation.set("description", savedVideo.get("description"));         
                                  recommendation.set("thumbnail", savedVideo.get("thumbnail"));
                                  //recommendation.set("screenshot", parseFileThumbanil);
                                  recommendation.set("referenceId", savedVideo.get("videoId"));                                  
                                  recommendation.set("date", savedVideo.get("createdAt"));

                                  var videoRelation = recommendation.relation("video");
                                  videoRelation.add(savedVideo);                                  

                                  recommendation.set("ytb_thumbnail_source", thumbnailUrl);

                                  recommendation.set("type", 2); // VIDEO

                                  recommendation.save(null, {
                                      success: function (savedReccomendation) {                                                                           

                                        Parse.Cloud.run("AddRoleToObject", { "pclassName": "Recommendations", "objectId": savedReccomendation.id, "role" : role }).then(function(result) {                                                                  

                                            $('#edit_modal_recommendation').modal('hide');

                                            clearField();
                                            loadRecommendation();

                                        });

                                      },
                                      error: function (response, error) {
                                            $('#error_message').html("<p>" + errort + "</p>");
                                            console.log('Error: ' + error.message);
                                      }
                                  });                                   
                                  
                              }, function(error) {
                                  console.log("error :" +errort);                                 
                              });                          
                               
                            });

                        },
                        error: function (response, error) {
                              $('#error_message').html("<p>" + errort + "</p>");
                            console.log('Error: ' + error.message);
                        }
                    });

                  }
              }
          });          
      }         

      function clearField(){
        $("#edit_model_fanpage").find("input[type=text], textarea").val("");
        $("#edit_model_fanpage").find("input[type=file], textarea").val("");
        //$("#edit_order_fanpage").empty();
        $('#img_icon_fanpage').attr('src', "https://upload.wikimedia.org/wikipedia/commons/c/ca/1x1.png");             
        $("#img_cover_fanpage").attr('src', "https://upload.wikimedia.org/wikipedia/commons/c/ca/1x1.png");             
      }

      function getAppIcon() {

        var queryConfig = new Parse.Query("Config");
          queryConfig.first({         
              success: function(results) {

                if( results != undefined) 
                {
                  appIconFile = results.get("app_thumbnail");                  
                }        
              }
          });
      }

      function loadThumbImage(input) {
        if (input.files && input.files[0]) {         
          var reader = new FileReader();
          reader.onload = function (e) {
            $('#img_thumbnail_screenshot').attr('src', e.target.result);
          }
          reader.readAsDataURL(input.files[0]);
          var desc = $("#edit_name").val();
          desc = desc.replace(/[^a-zA-Z ]/g, "");
          desc = desc.replace(" ", "");
          if (hasWhiteSpace(desc))
            desc = desc.replace(" ", "");
          var thunbname = "t_" + desc.toLowerCase() + ".png";
          parseFileThumbanil = new Parse.File(thunbname, input.files[0], "image/png");                   
        }
    }    

});

