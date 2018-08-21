document.addEventListener("LoadWelcomes", function(event){

    var schoolId = event.detail[0];
    var short = event.detail[1];

    var selectedItem = [];   
    var selected = -1; 
    var welcomesLenght = 0;
    var WelcomeName;
    
    loadWelcomes();

    var parseFileThumbanil;    

    function loadWelcomes()
    {  
        queryWelcome = new Parse.Query("Welcomes");  
        queryWelcome.containedIn("target", [short]);          
        queryWelcome.find({
            success: function (welcomes) {

                if (welcomes) {                

                  welcomesLenght = welcomes.length;
                  var dataJson = [];

                  for (var i = 0; i < welcomesLenght; ++i) 
                  {
                      item = {};
                      item["id"] = i+1;
                      var objectId = welcomes[i].id;
                      dataJson.objectId = objectId;
                      item["objectId"] = objectId;                  
                      if (welcomes[i].get("thumbnail") != undefined){                
                        var thumbnail = welcomes[i].get("thumbnail");
                        item["thumbnail"] = thumbnail._url;
                      } else {
                        item["thumbnail"] = "https://dummyimage.com/60x60/286090/ffffff.png&text=NA";
                      }                      
                      
                      var title = welcomes[i].get("title");
                      item["title"] = title;
                      var description = welcomes[i].get("description");
                      item["description"] = description;
                      
                      dataJson.push(item);
                  }                          

                  var rowIds = [];
                  var grid = $("#gridWelcome").bootgrid({                  
                      templates: {
                          header: "<div id=\"{{ctx.id}}\" class=\"{{css.header}}\"><div class=\"row\"><div class=\"col-sm-12 actionBar\"><div class=\"btn\"><div id=\"loader_Welcome\" class=\"loader\"/></div><button type=\"button\" id=\"new_welcome\" class=\"btn btn-primary\"><span class=\"glyphicon glyphicon-plus-sign\">&nbsp;</span> New Welcome </button> <p class=\"{{css.search}}\"></p><p class=\"{{css.actions}}\"></p></div></div></div>"       
                      }, 
                      caseSensitive: true,
                      selection: true,
                      multiSelect: true,
                      keepSelection: true,
                      rowSelect: true,                
                      formatters: {              
                        "thumbnail": function (column, row) {
                            return "<img src=\"" + row.thumbnail + "\" height=\"30\" width=\"30\"/>";
                        },
                        "commands": function(column, row) {
                            return "<button type=\"button\" class=\"btn btn-xs btn-default command-delete\" data-row-id=\"" + row.id + "\"><span class=\"glyphicon glyphicon-trash\"></span></button>&nbsp;" + 
                                   "<button type=\"button\" class=\"btn btn-xs btn-default command-edit\" data-row-id=\"" + row.id + "\"><span class=\"glyphicon glyphicon-edit\"></span></button>&nbsp;"; 
                                   //"<button type=\"button\" class=\"btn btn-xs btn-default command-fanpage\" data-row-id=\"" + row.id + "\">Fanpages</button>";
                        }                   
                      }  

                  }).on("selected.rs.jquery.bootgrid", function(e, rows) {                     

                       /*if ( selectedItem.length > 0) {                       
                           $("#gridWelcome").bootgrid("deselect", [parseInt(selected)]);                                              
                       }

                      var countSelected=0;
                      var rowIds = [];
                      var WelcomeId;
                      for (var i = 0; i < rows.length; i++)
                      {                      
                          rowIds.push(rows[i].id); 
                          WelcomeId = rows[i].objectId; 
                          WelcomeName = rows[i].name;                              
                      }              

                      selected = rowIds.join(",");
                      selectedItem.push(selected);   

                      var event = new CustomEvent("LoadFanpage", {detail: {
                          WelcomeId: WelcomeId,
                          schoolId: schoolId,
                          short: short
                      }}); //{ detail: WelcomeId });
                      document.dispatchEvent(event);*/                                                              

                     //alert("Select: " + rowIds.join(","));

                  }).on("deselected.rs.jquery.bootgrid", function(e, rows)
                  {
                      var rowIds = [];
                      for (var i = 0; i < rows.length; i++)
                      {
                          rowIds.push(rows[i].id);                      
                      }
                      //alert("Deselect: " + rowIds.join(","));
                  }).on("loaded.rs.jquery.bootgrid", function() {  

                        $("#loader_Welcome").hide();                 

                        $("#input_welcome_thumb_image").unbind("change").change(function() {
                          loadThumbImage(this);
                        });                       

                        $( "#btn_save_welcome" ).unbind("click").click(function() {
                            saveWelcome();
                        });                    

                        $( "#new_welcome" ).unbind("click").click(function() {                            

                            $("#welcome_title").text("New Welcome"); 

                            $('#edit_model_welcome').modal('show');                               

                            if (welcomesLenght==0){
                                $("#edit_order_welcomes").append(($("<option/>", { html: 0 })));                                     
                            } else {
                                welcomesLenght++;
                                for (var i = 0; i < welcomesLenght; i++) {                          
                                $("#edit_order_welcomes").append(($("<option/>", { html: i })));                                     
                                }    
                            }
                            
                            //Other Schools
                            $('#schools_viewed_welcomes').empty();                          
                            
                            let count = otherSchools.length;                           

                            for (var i=0; i<count; i++) {                       

                                let other = otherSchools[i];

                                let shortTarget = other.short;
                                let name = other.name;

                                $('#schools_viewed_welcomes').append('<input name="accesories" type="checkbox" value="' + shortTarget + '"/> '+ name +'<br/>');

                            }
                            
                        }); 

                        /* Executes after data is loaded and rendered */
                        grid.find(".command-edit").on("click", function(e) {

                            //alert("You pressed edit on row: " + $(this).data("row-id"));
                            var ele =$(this).parent();
                            var g_id = $(this).parent().siblings(':first').html();
                            var g_name = $(this).parent().siblings(':nth-of-type(2)').html();

                            console.log(g_id);
                            console.log(g_name);

                            //console.log(grid.data());//
                            $('#edit_model_welcome').modal('show');

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
                                $('#edit_welcome_title').val(a5);
                                $('#edit_welcome_description').val(a6);                                

                                $("#welcome_title").text("Edit Welcome - " + a6);                       

                            } else {
                                alert('Now row selected! First select row, then click edit button');
                            }

                        }).end().find(".command-delete").on("click", function(e) {


                        }).end().find(".command-fanpage").on("click", function(e) {                    


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
    
    function loadThumbImage(input) {
       
        if (input.files && input.files[0]) {         
          var reader = new FileReader();
          reader.onload = function (e) {
            $('#img_thumbnail_welcome').attr('src', e.target.result);
          }
          reader.readAsDataURL(input.files[0]);
          var desc = $("#edit_welcome_title").val();
          var thunbname = "t_" + desc.toLowerCase() + ".png";
          parseFileThumbanil = new Parse.File(thunbname, input.files[0], "image/png");                   
        }
    }    

    function saveWelcome() {            
          
          var Welcome = Parse.Object.extend("Welcomes");         
          var welcome = new Welcome();                       
          
          let title = $("#edit_welcome_title").val();

          welcome.set("title", title);    
          var description = $("#edit_welcome_description").val();
          welcome.set("description", description);                  
            
          welcome.set("thumbnail", parseFileThumbanil);
          welcome.set("target", window.checkChecked("frm_welcome_edit", short));
          
          welcome.save(null, {
              success: function (pet) {
                  console.log('Welcome created successful with name: ' + welcome.get("title"));
                  $('#edit_model_welcome').modal('hide');
                  loadWelcomes();
                  clearField();
              },
              error: function (response, error) {
                  console.log('Error: ' + error.message);
              }
          });
      }

      function clearField(){
          $("#edit_model_welcome").find("input[type=text], textarea").val("");                    
          $('#img_thumbnail_welcome').attr('src', "https://upload.wikimedia.org/wikipedia/commons/c/ca/1x1.png");                       
      }

  });

  



