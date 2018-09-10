
document.addEventListener("LoadVideo", function(event){

      var fanpageId = event.detail.fanpageId;
      var categoryName = event.detail.categoryName;
      var schoolId = event.detail.schoolId;       

      var fanpageObj;
      var appIconFile;
      var schoolShort;

      var queryFanpage = new Parse.Query("Fanpages");             
      queryFanpage.equalTo("objectId", fanpageId);
      queryFanpage.first({
          success: function (fanpage) {
              
              if (fanpage) { 
                    fanpageObj = fanpage;                  
                    searchVideo(fanpage); 
                    getAppIcon();   
                    getSchoolShort();        
              }
          }
      });   

      var videosLenght = 0;      

      function searchVideo(fanpage)
      {           

            var videosRelation = fanpage.relation('videos').query();
            videosRelation.find({
                success: function (videos) {                                   

                    if (videos) {                                 

                      videosLenght = videos.length;
                      var dataJson = [];

                      for (var i = 0; i < videosLenght; ++i) 
                      {
                          item = {};
                          item["id"] = i+1;
                          var objectId = videos[i].id;
                          dataJson.objectId = objectId;
                          item["objectId"] = objectId;                  
                          
                          if (videos[i].get("thumbnail") != undefined){                
                            var thumbnail = videos[i].get("thumbnail");
                            item["thumbnail"] = thumbnail._url;
                          } else {
                            item["thumbnail"] = "https://dummyimage.com/60x60/286090/ffffff.png&text=NA";
                          }
                          
                          var title = videos[i].get("title");
                          item["title"] = title;

                          var description = videos[i].get("description");
                          item["description"] = description;

                          if (videos[i].get("ytb_source") != undefined){
                            var source = videos[i].get("source");
                            item["source"] = source;
                          } else {
                            item["source"] = "https://dummyimage.com/150x60/286090/ffffff.png&text=Not+Available";
                          }
                          dataJson.push(item);
                      }                          

                      var rowIds = [];
                      var grid = $("#gridVideos").bootgrid({                  
                          templates: {
                              header: "<div id=\"{{ctx.id}}\" class=\"{{css.header}}\"><div class=\"row\"><div class=\"col-sm-12 actionBar\"><div class=\"btn\"><div id=\"loader_video\" class=\"loader\"/></div><button id=\"new_video\" type=\"button\" class=\"btn btn-primary\"><span class=\"glyphicon glyphicon-plus-sign\">&nbsp;</span> New video </button> <p class=\"{{css.search}}\"></p><p class=\"{{css.actions}}\"></p></div></div></div>"       
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

                              $("#loader_video").hide(); 
                            
                              $( "#new_video" ).unbind("click").click(function() {

                                    $("#video_title").text("New Video"); 

                                    $('#edit_model_video').modal('show');

                                    //$('#video_spinner').hide();

                                    if (videosLenght==0){
                                        $("#edit_order_video").append(($("<option/>", { html: 0 })));                                     
                                    } else {
                                      videosLenght++;
                                      for (var i = 0; i < videosLenght; i++) {                          
                                        $("#edit_order_video").append(($("<option/>", { html: i })));                                     
                                      }    
                                    } 

                                    $('#schools_viewed_videos').empty();                          
                            
                                    let count = otherSchools.length;                           

                                    for (var i=0; i<count; i++) {                       

                                        let other = otherSchools[i];

                                        let short = other.short;
                                        let name = other.name;

                                        $('#schools_viewed_videos').append('<input name="accesories" type="checkbox" value="'+short+'"/> '+ name +'<br/>');

                                    }
                                    

                              });  
                                         
                            grid.find(".command-edit").unbind("click").on("click", function(e) {

                              //alert("You pressed edit on row: " + $(this).data("row-id"));
                              var ele =$(this).parent();
                              var g_id = $(this).parent().siblings(':first').html();
                              var g_name = $(this).parent().siblings(':nth-of-type(2)').html();

                              console.log(g_id);
                              console.log(g_name);

                              //console.log(grid.data());//
                              $('#edit_model_video').modal('show');

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

                                $("#fanpage_title").text("Edit video - " + a5);                      

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

      $( "#btn_edit_video" ).click(function() {

        saveVideo();

      });

      $( "#edit_youtube_check" ).unbind("click").click(function() {
           

         $('#video_spinner').show();   

         videoUrl = $("#edit_youtube_video_id").val();

         vId = videoUrl.split("watch?v=")[1];                                              

         Parse.Cloud.run("getYoutubeVideoInfo", { videoId: vId }).then(function(result) {    

            console.log("__________________________");                         
            console.log(JSON.stringify(result));       

            title = result.fulltitle;                  
            $("#edit_title_video").val(title);
            desc = result.description;
            $("#edit_description_video").val(desc);
            thumbnailUrl = result.thumbnail;
            $('#img_thumbnail_video').attr('src', thumbnailUrl); 

            upload_date = result.upload_date;
            view_count = result.view_count;
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
        

      function saveVideo() { 

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

                    video.set("categoryName", categoryName);

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
                    //video.set("ytb_like_count", like_count);                      

                    var order = $("#edit_order_video").val();
                    video.set("order", parseInt(order)); 

                    video.set("public", true); 

                    video.set("folder", schoolShort); //Here TODO query School short and put as folder.  

                    video.set("fanpageId", Math.floor(100000 + Math.random() * 900000));              

                    var vrnd = Math.floor(100000 + Math.random() * 900000);
                    video.set("videoId", vrnd);              

                    video.set("fanpageObjId", fanpageObj.id);                     
                    video.set("poster_name", "Gamves Official");       
                    video.set("target", [schoolId]);
                    video.set("source_type", 2);  //YOUTUBE   
                    
                    video.set("target", window.checkChecked("frm_edit", schoolShort));

                    video.save(null, {
                        success: function (savedVideo) {        
                           
                            console.log('Video created successful with name: ' + video.get("title"));
                           
                            $('#edit_model_video').modal('hide');

                            var Notification = Parse.Object.extend("Notifications");         
                            var notification = new Notification();  

                            notification.set("posterName", userAdmin.get("Name"));
                            notification.set("posterAvatar", userAdmin.get("picture"));

                            notification.set("title", video.get("title"));
                            notification.set("description", video.get("description"));         
                            notification.set("cover", video.get("thumbnail"));
                            notification.set("referenceId", video.get("videoId"));
                            notification.set("date", video.get("createdAt"));
                            notification.set("video", video);

                            notification.set("type", type);

                            notification.save(null, {
                                success: function (savedVideo) {
                                  clearField();
                                  searchVideo(fanpage);    
                                },
                                error: function (response, error) {
                                      $('#error_message').html("<p>" + errort + "</p>");
                                      console.log('Error: ' + error.message);
                                }
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
        $("#edit_order_fanpage").empty();
        $('#img_icon_fanpage').attr('src', "https://upload.wikimedia.org/wikipedia/commons/c/ca/1x1.png");             
        $("#img_cover_fanpage").attr('src', "https://upload.wikimedia.org/wikipedia/commons/c/ca/1x1.png");             
      }

      function getAppIcon(){

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

      function getSchoolShort()
      {

          console.log(schoolId);

          var querySchool = new Parse.Query("Schools");             
          querySchool.equalTo("objectId", schoolId);
          querySchool.first({
              success: function (school) {
                  
                  if (school) { 
                        schoolShort = school.get("short");   
                  }
              }
          });           
          
      } 
});

