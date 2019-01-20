
document.addEventListener("LoadRecommendations", function(event){

      var fanpageId = event.detail.fanpageId;
      var categoryName = event.detail.categoryName;
      var schoolId = event.detail.schoolId;     
      var short = event.detail.short;  

      var fanpageObj;
      var appIconFile;      

      loadOtherSchools(schoolId);
      loadRecommendation();

      var recommendationLenght = 0;

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

                var rowIds = [];
                var grid = $("#gridRecommendations").bootgrid({                  
                    templates: {
                        header: "<div id=\"{{ctx.id}}\" class=\"{{css.header}}\"><div class=\"row\"><div class=\"col-sm-12 actionBar\"><div class=\"btn\"><div id=\"loader_recommendation\" class=\"loader\"/></div><button id=\"new_recommendation\" type=\"button\" class=\"btn btn-primary\"><span class=\"glyphicon glyphicon-plus-sign\">&nbsp;</span> New Recommendation </button> <p class=\"{{css.search}}\"></p><p class=\"{{css.actions}}\"></p></div></div></div>"       
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

                                //$('#video_spinner').hide();

                                /*if (recommendationLenght==0){
                                    $("#edit_order_recommendation").append(($("<option/>", { html: 0 })));                                     
                                } else {
                                    recommendationLenght++;
                                for (var i = 0; i < recommendationLenght; i++) {                          
                                    $("#edit_order_recommendation").append(($("<option/>", { html: i })));                                     
                                }    
                                }*/ 

                                $('#recommendations_viewed_videos').empty();                          
                        
                                /*let count = window.otherSchools.length;                           

                                for (var i=0; i<count; i++) {                       

                                    let other = window.otherSchools[i];

                                    let short = other.short;
                                    let name = other.name;

                                    $('#recommendations_viewed_videos').append('<input name="accesories" type="checkbox" value="'+short+'"/> '+ name +'<br/>');

                                }*/

                                let name = "Schools";

                                $('#recommendations_viewed_videos').append('<input name="accesories" type="checkbox" value=""/> '+ name +'<br/>');
                                

                        });  
                                    
                        grid.find(".command-edit").unbind("click").on("click", function(e) {

                        //alert("You pressed edit on row: " + $(this).data("row-id"));
                        var ele =$(this).parent();
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

      function saveRecommendation() {              

          var userQuery = new Parse.Query(Parse.User);         
          userQuery.equalTo("username", "gamvesadmin");
          userQuery.first({
              success: function (userAdmin) {
                  
                  if (userAdmin) { 
                        
                    var Videos = Parse.Object.extend("Videos");
                    var video = new Videos();              

                    video.set("downloaded", false);
                    video.set("removed", false);
                    video.set("authorized", true);

                    video.set("title", title);
                    video.set("description", desc);                              

                    video.set("posterId", userAdmin.id);          
                    video.set("poster_name", userAdmin.get("Name"));          

                    video.set("s3_source", "");
                    video.set("ytb_source", videoUrl);
                    video.set("ytb_thumbnail_source", thumbnailUrl);
                    video.set("ytb_videoId", vId);

                    video.set("ytb_upload_date", upload_date);  

                    video.set("ytb_view_count", view_count);       
                    video.set("ytb_tags", tags);
                    video.set("ytb_duration", duration);         
                    video.set("ytb_categories", categories);                                          

                    //var order = $("#edit_order_video").val();
                    //video.set("order", parseInt(order)); 

                    video.set("public", true); 

                    video.set("folder", "admvideos"); 

                    video.set("fanpageId", Math.floor(100000 + Math.random() * 900000));              

                    var vrnd = Math.floor(100000 + Math.random() * 900000);
                    video.set("videoId", vrnd);              

                    video.set("poster_name", "Gamves Official");                        

                    video.set("source_type", 3);  //RECOMMENDATION   

                    video.set("approved", true);                 
              
                    video.save(null, {
                        success: function (savedVideo) {                                 

                            window.GetCheckedInclude("frm_edit_recommendation", function(result) {

                              let role;

                              if  (result) {
                                  role = "schools";
                              } else {
                                  role = short;
                              }  

                              Parse.Cloud.run("AddRoleToObject", { "pclassName": "Videos", "objectId": savedVideo.id, "role" : role }).then(function(result) {                                                                  
                                  
                                  console.log('Video created successful with name: ' + video.get("title"));                         

                                  var Recommendation = Parse.Object.extend("Recommendations");         
                                  var recommendation = new Recommendation();  

                                  recommendation.set("title", video.get("title"));
                                  recommendation.set("description", video.get("description"));         
                                  recommendation.set("cover", video.get("thumbnail"));
                                  recommendation.set("referenceId", video.get("videoId"));                                  
                                  recommendation.set("date", video.get("createdAt"));

                                  var videoRelation = recommendation.relation("video");
                                  videoRelation.add(video);                                  

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

      /*function getSchoolShort()
      {

          console.log(schoolId);

          var querySchool = new Parse.Query("Schools");             
          querySchool.equalTo("objectId", schoolId);
          querySchool.first({
              success: function (school) {
                  
                  if (school) { 
                        schoolShort = school.get("short");                           

                        var queryRole = new Parse.Query(Parse.Role);    
                        queryRole.equalTo('name', roleName);    

                        queryRole.first({useMasterKey:true}).then(function(rolePF) {

                            schoolACL = rolePF;

                        });
                  }
              }
          });           
          
      }*/ 
});

