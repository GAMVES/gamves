document.addEventListener("LoadCategories", function(event){

    var schoolId = event.detail;

    var selectedItem = [];   
    var selected = -1; 
    var categoriesLenght = 0;
    var categoryName;

    loadCategories();

    var parseFileThumbanil; 
    var parseFileBackImage; 

    function loadCategories()
    {
  
        queryCategory = new Parse.Query("Categories");  
        queryCategory.equalTo("schoolId", schoolId);          
        queryCategory.find({
            success: function (categories) {

                if (categories) {                

                  categoriesLenght = categories.length;
                  var dataJson = [];

                  for (var i = 0; i < categoriesLenght; ++i) 
                  {
                      item = {};
                      item["id"] = i+1;
                      var objectId = categories[i].id;
                      dataJson.objectId = objectId;
                      item["objectId"] = objectId;                  
                      if (categories[i].get("thumbnail") != undefined){                
                        var thumbnail = categories[i].get("thumbnail");
                        item["thumbnail"] = thumbnail._url;
                      } else {
                        item["thumbnail"] = "https://dummyimage.com/60x60/286090/ffffff.png&text=NA";
                      }
                      var order = categories[i].get("order");
                      item["order"] = order;
                      var description = categories[i].get("name");
                      item["description"] = description;
                      if (categories[i].get("backImage") != undefined){
                        var backImage = categories[i].get("backImage");
                        item["backImage"] = backImage._url;
                      } else {
                        item["backImage"] = "https://dummyimage.com/150x60/286090/ffffff.png&text=Not+Available";
                      }
                      dataJson.push(item);
                  }                          

                  var rowIds = [];
                  var grid = $("#gridCategory").bootgrid({                  
                      templates: {
                          header: "<div id=\"{{ctx.id}}\" class=\"{{css.header}}\"><div class=\"row\"><div class=\"col-sm-12 actionBar\"><div class=\"btn\"><div id=\"loader_category\" class=\"loader\"/></div><button type=\"button\" id=\"new_category\" class=\"btn btn-primary\"><span class=\"glyphicon glyphicon-plus-sign\">&nbsp;</span> New Category </button> <p class=\"{{css.search}}\"></p><p class=\"{{css.actions}}\"></p></div></div></div>"       
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
                        "backImage": function (column, row) {
                            return "<img src=\"" + row.backImage + "\" height=\"30\" width=\"150\"/>";
                        },
                        "commands": function(column, row) {
                            return "<button type=\"button\" class=\"btn btn-xs btn-default command-delete\" data-row-id=\"" + row.id + "\"><span class=\"glyphicon glyphicon-trash\"></span></button>&nbsp;" + 
                                   "<button type=\"button\" class=\"btn btn-xs btn-default command-edit\" data-row-id=\"" + row.id + "\"><span class=\"glyphicon glyphicon-edit\"></span></button>&nbsp;"; 
                                   //"<button type=\"button\" class=\"btn btn-xs btn-default command-fanpage\" data-row-id=\"" + row.id + "\">Fanpages</button>";
                        }                   
                      }  

                  }).on("selected.rs.jquery.bootgrid", function(e, rows) {                     

                       if ( selectedItem.length > 0) {                       
                           $("#gridCategory").bootgrid("deselect", [parseInt(selected)]);                                              
                       }

                      var countSelected=0;
                      var rowIds = [];
                      var categoryId;
                      for (var i = 0; i < rows.length; i++)
                      {                      
                          rowIds.push(rows[i].id); 
                          categoryId = rows[i].objectId; 
                          categoryName = rows[i].name;                              
                      }              

                      selected = rowIds.join(",");
                      selectedItem.push(selected);   

                      var event = new CustomEvent("LoadFanpage", { detail: categoryId });
                      document.dispatchEvent(event);                                                              

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

                        $("#loader_category").hide();                 

                        $("#input_thumb_image").unbind("change").change(function() {
                          loadThumbImage(this);
                        });

                        $("#input_back_image").unbind("change").change(function() {
                          loadBackImage(this);
                        });

                        $( "#btn_edit_category" ).unbind("click").click(function() {
                            saveCategory();
                        });                    

                        $( "#new_category" ).unbind("click").click(function() {

                          $("#category_title").text("New Category"); 

                          $('#edit_model_category').modal('show');                               

                          if (categoriesLenght==0){
                              $("#edit_order_categories").append(($("<option/>", { html: 0 })));                                     
                          } else {
                            categoriesLenght++;
                            for (var i = 0; i < categoriesLenght; i++) {                          
                              $("#edit_order_categories").append(($("<option/>", { html: i })));                                     
                            }    
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
                          $('#edit_model_category').modal('show');

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
                            $('#edit_order_categories').val(a5);
                            $('#edit_description').val(a6);
                            $('#edit_backimage').append(a7); 

                            $("#category_title").text("Edit category - " + a6);                       

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
            $('#img_thumbnail').attr('src', e.target.result);
          }
          reader.readAsDataURL(input.files[0]);
          var desc = $("#edit_description").val();
          var thunbname = "t_" + desc.toLowerCase() + ".png";
          parseFileThumbanil = new Parse.File(thunbname, input.files[0], "image/png");                   
        }
    }

    function loadBackImage(input) {
        if (input.files && input.files[0]) { 
          var reader = new FileReader();
          reader.onload = function (e) {
            $('#img_back').attr('src', e.target.result);
          }
          reader.readAsDataURL(input.files[0]);  
          var desc = $("#edit_description").val();
          var backname = "b_" + desc.toLowerCase() + ".png";       
          parseFileBackImage = new Parse.File(backname, input.files[0], "image/jpg");                    
        }
    }

      function saveCategory() {          

          var Category = Parse.Object.extend("Categories");         
          var cat = new Category();    
          cat.set("schoolId", schoolId);
          cat.set("thumbnail", parseFileThumbanil);
          cat.set("name", $("#edit_description").val());
          var order = $("#edit_order_categories").val();
          cat.set("order", parseInt(order));         
          cat.set("backImage", parseFileBackImage);
          cat.save(null, {
              success: function (pet) {
                  console.log('Category created successful with name: ' + cat.get("pageName"));
                  $('#edit_model_category').modal('hide');
                  loadCategories();
                  clearField();
              },
              error: function (response, error) {
                  console.log('Error: ' + error.message);
              }
          });
      }

      function clearField(){
          $("#edit_model_category").find("input[type=text], textarea").val("");
          $("#edit_model_category").find("input[type=file], textarea").val("");
          $("#edit_order_categories").empty();
          $('#img_thumbnail').attr('src', "https://upload.wikimedia.org/wikipedia/commons/c/ca/1x1.png");             
          $("#img_back").attr('src', "https://upload.wikimedia.org/wikipedia/commons/c/ca/1x1.png");             
      }

  });

  



