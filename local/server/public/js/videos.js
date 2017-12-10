
document.addEventListener("LoadVideo", function(event){

      var fanpageId = event.detail;
      var fanpageObj;

      var queryFanpage = new Parse.Query("Fanpage");             
      queryFanpage.equalTo("objectId", fanpageId);
      queryFanpage.first({
          success: function (fanpage) {
              
              if (fanpage) { 
                    fanpageObj = fanpage;                  
                    searchVideo(fanpage)            
              }
          }
      });
      
      function searchVideo(fanpage)
      {           

            var videosRelation = fanpage.relation('videos').query();
            videosRelation.find({
                success: function (videos) {                                   

                    if (videos) {                

                      var clength = videos.length;
                      var dataJson = [];

                      for (var i = 0; i < clength; ++i) 
                      {
                          item = {};
                          item["id"] = i+1;
                          var objectId = videos[i].id;
                          dataJson.objectId = objectId;
                          item["objectId"] = objectId;                  
                          
                          if (videos[i].get("thumbnailUrl") != undefined){                
                            var thumbnail = videos[i].get("thumbnailUrl");
                            item["thumbnail"] = thumbnail;
                          } else {
                            item["thumbnail"] = "https://dummyimage.com/60x60/286090/ffffff.png&text=NA";
                          }
                          
                          var title = videos[i].get("title");
                          item["title"] = title;

                          var description = videos[i].get("description");
                          item["description"] = description;

                          if (videos[i].get("source") != undefined){
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
                              header: "<div id=\"{{ctx.id}}\" class=\"{{css.header}}\"><div class=\"row\"><div class=\"col-sm-12 actionBar\"><button id=\"new_video\" type=\"button\" class=\"btn btn-primary\"><span class=\"glyphicon glyphicon-plus-sign\">&nbsp;</span> New video </button> <p class=\"{{css.search}}\"></p><p class=\"{{css.actions}}\"></p></div></div></div>"       
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

                          $( "#new_video" ).click(function() {
                
                            $('#edit_model_video').modal('show');

                          });                 

                          grid.find(".command-edit").on("click", function(e) {

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

                              } else {
                                 alert('Now row selected! First select row, then click edit button');
                              }

                          }).end().find(".command-delete").on("click", function(e) {                           

                          }).end().find(".command-video").on("click", function(e) {                                  

                          });
                      });

                      grid.bootgrid("append", dataJson);

                    } else {
                        console.log("Nothing found, please try again");
                    }

                },
                error: function (error) {
                    console.log("Error: " + error.code + " " + error.message);
                }
            });             
      

              $( "#btn_thumb_image" ).click(function() {
                  alert("");
              });

              
              $( "#btn_back_image" ).click(function() {
                alert("");
              });


              $( "#edit_youtube_check" ).click(function() {
                  
                  var videoId = $("#edit_youtube_video_id").val();                    

                  var url = "https://www.youtube.com/oembed?url=http://www.youtube.com/watch?v=" + videoId + "&format=json";
              
                  var jsonResult;

                  $.ajax({
                       type: "GET",
                       url: url,
                       processData: true,
                       data: {},
                       dataType: "json",
                     error: function(e){

                        var error = e; 
                        console.log(e);                    

                     },
                     success: function (data) {

                        var d = data;
                         
                      }
                  });

                   
              });                 


      }  

   
});