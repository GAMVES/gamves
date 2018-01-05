
  $( document ).ready(function() {

    //Parse.initialize("lTEkncCXc0jS7cyEAZwAr2IYdABenRsY86KPhzJT"); 
    //Parse.javaScriptKey = "cRbLP23wEF669kaYy3PGcRWuPRYp6frneKjszJhJ"; 
    //Parse.serverURL = "https://pg-app-z97yidopqq2qcec1uhl3fy92cj6zvb.scalabl.cloud/1/";

    Parse.initialize("0123456789"); 
    
    //Parse.javaScriptKey = "cRbLP23wEF669kaYy3PGcRWuPRYp6frneKjszJhJ"; 

    Parse.serverURL = "http://192.168.16.22:1337/1/";
    //Parse.serverURL = "http://192.168.1.43:1337/1/";

    var currentUser = Parse.User.current();
    if (!currentUser) {
        window.location = "../index.html";
    }

    var selectedItem = [];   
    var selected = -1; 
    var schoolsLenght = 0;
    var schoolName;

     var schoolObjs = [];

    loadschools();

    var parseFileThumbanil;     

    var schoolIdArray = [];
    var _sId;

    function loadschools()
    {
  
        querySchools = new Parse.Query("Schools");      
        querySchools.find({
            success: function (schools) {

                if (schools) {                

                  schoolObjs = schools;
                  schoolsLenght = schools.length;
                  var dataJson = [];

                  for (var i = 0; i < schoolsLenght; ++i) 
                  {
                      item = {};
                      item["id"] = i+1;
                      var objectId = schools[i].id;
                      dataJson.objectId = objectId;
                      item["objectId"] = objectId;                  
                      if (schools[i].get("thumbnail") != undefined){                
                        var thumbnail = schools[i].get("thumbnail");
                        item["thumbnail"] = thumbnail._url;
                      } else {
                        item["thumbnail"] = "https://dummyimage.com/60x60/286090/ffffff.png&text=NA";
                      }                      
                      var name = schools[i].get("name");
                      item["name"] = name;                      
                      dataJson.push(item);
                  }                          

                  var rowIds = [];
                  var grid = $("#gridSchool").bootgrid({                  
                      templates: {
                          header: "<div id=\"{{ctx.id}}\" class=\"{{css.header}}\"><div class=\"row\"><div class=\"col-sm-12 actionBar\"><div class=\"btn\"><div id=\"loader_school\" class=\"loader\"/></div><button type=\"button\" id=\"new_school\" class=\"btn btn-primary\"><span class=\"glyphicon glyphicon-plus-sign\">&nbsp;</span> New school </button> <p class=\"{{css.search}}\"></p><p class=\"{{css.actions}}\"></p></div></div></div>"       
                      }, 
                      caseSensitive: true,
                      selection: true,
                      multiSelect: true,
                      keepSelection: true,
                      rowSelect: true,                
                      formatters: {              
                        "thumbnail": function (column, row) {
                            return "<img src=\"" + row.thumbnail + "\" height=\"30\" width=\"85\"/>";
                        },                        
                        "commands": function(column, row) {
                            return "<button type=\"button\" class=\"btn btn-xs btn-default command-delete\" data-row-id=\"" + row.id + "\"><span class=\"glyphicon glyphicon-trash\"></span></button>&nbsp;" + 
                                   "<button type=\"button\" class=\"btn btn-xs btn-default command-edit\" data-row-id=\"" + row.id + "\"><span class=\"glyphicon glyphicon-edit\"></span></button>&nbsp;"; 
                                   //"<button type=\"button\" class=\"btn btn-xs btn-default command-fanpage\" data-row-id=\"" + row.id + "\">Fanpages</button>";
                        },
                        "grades": function(column, row) {
                            var scid = schoolIdArray[(row.id-1)];  
                            return "<button type=\"button\ data-fanpage=\"" + scid + "\" class=\"btn btn-xs btn-default command-grades\" data-row-id=\"" + row.id + "\">Grades</button>&nbsp;";                                       
                        }                    
                      }  

                  }).on("selected.rs.jquery.bootgrid", function(e, rows) {                     

                       if ( selectedItem.length > 0) {                       
                           $("#gridSchool").bootgrid("deselect", [parseInt(selected)]);                                              
                       }

                      var countSelected=0;
                      var rowIds = [];
                      var schoolId;
                      for (var i = 0; i < rows.length; i++)
                      {                      
                          rowIds.push(rows[i].id); 
                          schoolId = rows[i].objectId; 
                          schoolName = rows[i].name;                              
                      }              

                      selected = rowIds.join(",");
                      selectedItem.push(selected);   

                      var event = new CustomEvent("LoadCategories", { detail: schoolId });
                      document.dispatchEvent(event);                                                              

                     //alert("Select: " + rowIds.join(","));

                  }).on("deselected.rs.jquery.bootgrid", function(e, rows)
                  {
                      var rowIds = [];
                      for (var i = 0; i < rows.length; i++)
                      {
                          rowIds.push(rows[i].id);                      
                      }
                      
                  }).on("loaded.rs.jquery.bootgrid", function() {  

                        $("#loader_school").hide();                 
                    

                        $( "#btn_edit_school" ).unbind("click").click(function() {
                            saveSchool();
                        });  

                        $( "#btn_add_school" ).unbind("click").click(function() {
                           addGrade();
                        }); 

                        $( "#save_grades_container" ).unbind("click").click(function() {
                           saveGrades();
                        });                                          

                        $( "#new_school" ).unbind("click").click(function() {

                          $("#school_title").text("New school"); 

                          $('#edit_model_school').modal('show');                 

                          $("#input_thumb_school").unbind("change").change(function() {
                            loadThumbImage(this);
                          });              

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
                          $('#edit_model_school').modal('show');

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
                            $('#edit_name').val(a6);
                            $('#edit_backimage').append(a7); 

                            $("#school_title").text("Edit school - " + a6);                       

                          } else {
                             alert('Now row selected! First select row, then click edit button');
                          }

                      }).end().find(".command-grades").on("click", function(e) {

                          $('#edit_modal_grade').modal('show');                                                                 

                          var row  =$(this).attr('data-row-id'); 

                          _sId = row-1;

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
            $('#img_thumbnail_school').attr('src', e.target.result);
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

    function hasWhiteSpace(s) {
      return s.indexOf(' ') >= 0;
    }

    function saveSchool() {          

          var Schools = Parse.Object.extend("Schools");         
          var school = new Schools();    
          school.set("thumbnail", parseFileThumbanil);
          school.set("name", $("#edit_name").val());              
          school.save(null, {
              success: function (schoolNew) {
                  console.log('school created successful with name: ' + schoolNew.get("pageName"));
                  $('#edit_model_school').modal('hide');
                  loadschools();
                  clearField();
              },
              error: function (response, error) {
                  console.log('Error: ' + error.message);
              }
          });
      }



      function addGrade() {          

          var gradeName = $('#edit_grade_name').val();
          var gradeNumber = $('#edit_grade_number').val();

          $(".grade_addition").append('<li>' + gradeNumber + " - " + gradeName + '</li>');  

          $('#edit_grade_number').val("");
          $('#edit_grade_name').val("");
      }

      function saveGrades(){

          var Levels = Parse.Object.extend("Level");  

          var optionTexts = [];
          $("#grade_list li").each(function() { optionTexts.push($(this).text()) });

          var lsize = optionTexts.length;
          var count = 1;

          for (var i=0; i<lsize; i++){ 

            var values = optionTexts[i];

            var res = values.split("-");

            var level = new Levels();
            level.set("grade", parseInt(res[0]));
            level.set("description", res[1]);           

            level.save(null, {
              success: function (albumStored) {
                    
                    var schoolObj = schoolObjs[_sId];
                    
                    var alRelation = schoolObj.relation("levels");
                    alRelation.add(albumStored);

                    schoolObj.save(null, {
                      success: function (album) {

                            if (lsize == count) {
                              $('#edit_modal_grade').modal('hide');                
                              clearField(); 
                            }
                            count++;

                      },
                      error: function (response, error) {
                          console.log('Error: ' + error.message);
                      }

                    });

                    


              },
              error: function (response, error) {
                  console.log('Error: ' + error.message);
              }

            });

          } 


      }

      function clearField(){
        $("#edit_model_school").find("input[type=text], textarea").val("");
        $("#edit_model_school").find("input[type=file], textarea").val("");      
        $('#img_thumbnail').attr('src', "https://upload.wikimedia.org/wikipedia/commons/c/ca/1x1.png");             
        $("#img_back").attr('src', "https://upload.wikimedia.org/wikipedia/commons/c/ca/1x1.png");             
      }



  });

 



