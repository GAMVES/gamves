document.addEventListener("LoadFanpage", function(event){

      var catId = event.detail.categoryId;
      var schoolId = event.detail.schoolId;
      var short = event.detail.short;
      
      var selectedItem = [];   
      var selected = -1;
      var categoryPF;
      var categoryName; 

      var fanpageId;
      var fanpageObjs = [];
      var _fId;
      var fanpageIdArray = [];  

      var fanpagetACL = window.loadRole(short);       

      var queryCategory = new Parse.Query("Categories");             
      queryCategory.equalTo("objectId", catId);
      //queryCategory.containedIn("target", [short]);
      queryCategory.first({
          success: function (category) {
              
              if (category) {
                    categoryPF = category
                    categoryName = category.get("name");
                    loadFanpages(category);            
              }
          }
      });
      
      var fanpagesLenght = 0; 

      var MD5 = function(d){result = M(V(Y(X(d),8*d.length)));return result.toLowerCase()};function M(d){for(var _,m="0123456789ABCDEF",f="",r=0;r<d.length;r++)_=d.charCodeAt(r),f+=m.charAt(_>>>4&15)+m.charAt(15&_);return f}function X(d){for(var _=Array(d.length>>2),m=0;m<_.length;m++)_[m]=0;for(m=0;m<8*d.length;m+=8)_[m>>5]|=(255&d.charCodeAt(m/8))<<m%32;return _}function V(d){for(var _="",m=0;m<32*d.length;m+=8)_+=String.fromCharCode(d[m>>5]>>>m%32&255);return _}function Y(d,_){d[_>>5]|=128<<_%32,d[14+(_+64>>>9<<4)]=_;for(var m=1732584193,f=-271733879,r=-1732584194,i=271733878,n=0;n<d.length;n+=16){var h=m,t=f,g=r,e=i;f=md5_ii(f=md5_ii(f=md5_ii(f=md5_ii(f=md5_hh(f=md5_hh(f=md5_hh(f=md5_hh(f=md5_gg(f=md5_gg(f=md5_gg(f=md5_gg(f=md5_ff(f=md5_ff(f=md5_ff(f=md5_ff(f,r=md5_ff(r,i=md5_ff(i,m=md5_ff(m,f,r,i,d[n+0],7,-680876936),f,r,d[n+1],12,-389564586),m,f,d[n+2],17,606105819),i,m,d[n+3],22,-1044525330),r=md5_ff(r,i=md5_ff(i,m=md5_ff(m,f,r,i,d[n+4],7,-176418897),f,r,d[n+5],12,1200080426),m,f,d[n+6],17,-1473231341),i,m,d[n+7],22,-45705983),r=md5_ff(r,i=md5_ff(i,m=md5_ff(m,f,r,i,d[n+8],7,1770035416),f,r,d[n+9],12,-1958414417),m,f,d[n+10],17,-42063),i,m,d[n+11],22,-1990404162),r=md5_ff(r,i=md5_ff(i,m=md5_ff(m,f,r,i,d[n+12],7,1804603682),f,r,d[n+13],12,-40341101),m,f,d[n+14],17,-1502002290),i,m,d[n+15],22,1236535329),r=md5_gg(r,i=md5_gg(i,m=md5_gg(m,f,r,i,d[n+1],5,-165796510),f,r,d[n+6],9,-1069501632),m,f,d[n+11],14,643717713),i,m,d[n+0],20,-373897302),r=md5_gg(r,i=md5_gg(i,m=md5_gg(m,f,r,i,d[n+5],5,-701558691),f,r,d[n+10],9,38016083),m,f,d[n+15],14,-660478335),i,m,d[n+4],20,-405537848),r=md5_gg(r,i=md5_gg(i,m=md5_gg(m,f,r,i,d[n+9],5,568446438),f,r,d[n+14],9,-1019803690),m,f,d[n+3],14,-187363961),i,m,d[n+8],20,1163531501),r=md5_gg(r,i=md5_gg(i,m=md5_gg(m,f,r,i,d[n+13],5,-1444681467),f,r,d[n+2],9,-51403784),m,f,d[n+7],14,1735328473),i,m,d[n+12],20,-1926607734),r=md5_hh(r,i=md5_hh(i,m=md5_hh(m,f,r,i,d[n+5],4,-378558),f,r,d[n+8],11,-2022574463),m,f,d[n+11],16,1839030562),i,m,d[n+14],23,-35309556),r=md5_hh(r,i=md5_hh(i,m=md5_hh(m,f,r,i,d[n+1],4,-1530992060),f,r,d[n+4],11,1272893353),m,f,d[n+7],16,-155497632),i,m,d[n+10],23,-1094730640),r=md5_hh(r,i=md5_hh(i,m=md5_hh(m,f,r,i,d[n+13],4,681279174),f,r,d[n+0],11,-358537222),m,f,d[n+3],16,-722521979),i,m,d[n+6],23,76029189),r=md5_hh(r,i=md5_hh(i,m=md5_hh(m,f,r,i,d[n+9],4,-640364487),f,r,d[n+12],11,-421815835),m,f,d[n+15],16,530742520),i,m,d[n+2],23,-995338651),r=md5_ii(r,i=md5_ii(i,m=md5_ii(m,f,r,i,d[n+0],6,-198630844),f,r,d[n+7],10,1126891415),m,f,d[n+14],15,-1416354905),i,m,d[n+5],21,-57434055),r=md5_ii(r,i=md5_ii(i,m=md5_ii(m,f,r,i,d[n+12],6,1700485571),f,r,d[n+3],10,-1894986606),m,f,d[n+10],15,-1051523),i,m,d[n+1],21,-2054922799),r=md5_ii(r,i=md5_ii(i,m=md5_ii(m,f,r,i,d[n+8],6,1873313359),f,r,d[n+15],10,-30611744),m,f,d[n+6],15,-1560198380),i,m,d[n+13],21,1309151649),r=md5_ii(r,i=md5_ii(i,m=md5_ii(m,f,r,i,d[n+4],6,-145523070),f,r,d[n+11],10,-1120210379),m,f,d[n+2],15,718787259),i,m,d[n+9],21,-343485551),m=safe_add(m,h),f=safe_add(f,t),r=safe_add(r,g),i=safe_add(i,e)}return Array(m,f,r,i)}function md5_cmn(d,_,m,f,r,i){return safe_add(bit_rol(safe_add(safe_add(_,d),safe_add(f,i)),r),m)}function md5_ff(d,_,m,f,r,i,n){return md5_cmn(_&m|~_&f,d,_,r,i,n)}function md5_gg(d,_,m,f,r,i,n){return md5_cmn(_&f|m&~f,d,_,r,i,n)}function md5_hh(d,_,m,f,r,i,n){return md5_cmn(_^m^f,d,_,r,i,n)}function md5_ii(d,_,m,f,r,i,n){return md5_cmn(m^(_|~f),d,_,r,i,n)}function safe_add(d,_){var m=(65535&d)+(65535&_);return(d>>16)+(_>>16)+(m>>16)<<16|65535&m}function bit_rol(d,_){return d<<_|d>>>32-_}     

      function loadFanpages(category)
      {
            var queryFanpage = new Parse.Query("Fanpages");             
            queryFanpage.equalTo("category", category);
            queryFanpage.find({
                success: function (fanpages) {

                    if (fanpages) {                

                      fanpageObjs = fanpages;
                      fanpagesLenght = fanpages.length;
                      var dataJson = [];                                           

                      for (var i = 0; i < fanpagesLenght; ++i) 
                      {
                          item = {};
                          item["id"] = i+1;
                          var objectId = fanpages[i].id;
                          dataJson.objectId = objectId;
                          item["objectId"] = objectId;                  

                          if (fanpages[i].get("pageIcon") != undefined){                
                            var icon = fanpages[i].get("pageIcon");
                            item["icon"] = icon._url;
                          } else {
                            item["icon"] = "https://dummyimage.com/60x60/286090/ffffff.png&text=NA";
                          }

                          var name = fanpages[i].get("pageName");
                          item["name"] = name;
                          var about = fanpages[i].get("pageAbout");
                          item["about"] = about;
                          if (fanpages[i].get("pageCover") != undefined){
                            var cover = fanpages[i].get("pageCover");
                            item["cover"] = cover._url;
                          } else {
                            item["cover"] = "https://dummyimage.com/150x60/286090/ffffff.png&text=Not+Available";
                          }
                          var fpid = fanpages[i].get("fanpageId");  
                          fanpageIdArray.push(fpid);

                          dataJson.push(item);
                      }                          

                      var rowIds = [];
                      var grid = $("#gridFanpage").bootgrid({                  
                          templates: {
                              header: "<div id=\"{{ctx.id}}\" class=\"{{css.header}}\"><div class=\"row\"><div class=\"col-sm-12 actionBar\"><div class=\"btn\"><div id=\"loader_fanpage\" class=\"loader\"/></div><button id=\"new_fanpage\" type=\"button\" class=\"btn btn-primary\"><span class=\"glyphicon glyphicon-plus-sign\">&nbsp;</span> New Fanpage </button> <p class=\"{{css.search}}\"></p><p class=\"{{css.actions}}\"></p></div></div></div>"       
                          }, 
                          caseSensitive: true,
                          selection: true,
                          multiSelect: true,                  
                          formatters: {              
                            "icon": function (column, row) {
                                return "<img src=\"" + row.icon + "\" height=\"30\" width=\"30\"/>";
                            },
                            "cover": function (column, row) {
                                return "<img src=\"" + row.cover + "\" height=\"30\" width=\"150\"/>";
                            },
                            "commands": function(column, row) {
                                return "<button type=\"button\" class=\"btn btn-xs btn-default command-delete\" data-row-id=\"" + row.id + "\"><span class=\"glyphicon glyphicon-trash\"></span></button>&nbsp;" + 
                                       "<button type=\"button\" class=\"btn btn-xs btn-default command-edit\" data-row-id=\"" + row.id + "\"><span class=\"glyphicon glyphicon-edit\"></span></button>&nbsp;";
                            },
                            "images": function(column, row) {
                                var fpid = fanpageIdArray[(row.id-1)];  
                                return "<button type=\"button\ data-fanpage=\"" + fpid + "\" class=\"btn btn-xs btn-default command-images\" data-row-id=\"" + row.id + "\">Images</button>&nbsp;";                                       
                            }                   
                          }               

                      }).on("selected.rs.jquery.bootgrid", function(e, rows) {

                          if ( selectedItem.length > 0) {                       
                               $("#gridFanpage").bootgrid("deselect", [parseInt(selected)]);                                              
                           }

                          var countSelected=0;
                          var rowIds = [];                          
                          for (var i = 0; i < rows.length; i++)
                          {                      
                              rowIds.push(rows[i].id); 
                              fanpageId = rows[i].objectId;                               
                          }              

                          selected = rowIds.join(",");
                          selectedItem.push(selected);   

                          var event = new CustomEvent("LoadVideo", { detail: {
                                    fanpageId: fanpageId,
                                    categoryName: categoryName,
                                    schoolId: schoolId }} );                                    
                          document.dispatchEvent(event);

                      }).on("deselected.rs.jquery.bootgrid", function(e, rows)
                      {
                          var rowIds = [];
                          for (var i = 0; i < rows.length; i++) {
                              rowIds.push(rows[i].id);
                          }

                      }).on("loaded.rs.jquery.bootgrid", function() {

                           $("#loader_fanpage").hide();       

                           $("#input_icon_fanpage").unbind("change").change(function() {
                             loadIconsImage(this);
                          });

                          $("#input_cover_fanpage").unbind("change").change(function() {
                             loadCoverImage(this);
                          });

                          $( "#btn_edit_fanpages" ).unbind("click").click(function() {
                              saveFanpage();
                          }); 

                           $( "#save_albums_container" ).unbind("click").click(function() {
                              saveAlbums();
                          });

                           $("#input_album_fanpage").unbind("change").change(function() {
                              loadAlbumImage(this);
                          });                   

                          $( "#new_fanpage" ).unbind("click").click(function() {        
                           
                                                          
                             $("#fanpage_title").text("New Fanpage"); 

                             $('#edit_modal_fanpage').modal('show');       

                                if (fanpagesLenght==0){
                                    $("#edit_order_fanpage").append(($("<option/>", { html: 0 })));                                     
                                } else {
                                    fanpagesLenght++;
                                    for (var i = 0; i < fanpagesLenght; i++) {                          
                                    $("#edit_order_fanpage").append(($("<option/>", { html: i })));                                     
                                    }    
                                } 
                              
                                $('#schools_viewed_fanpages').empty();                          
                            
                                let count = otherSchools.length;                           

                                for (var i=0; i<count; i++) {                       

                                    let other = otherSchools[i];

                                    let short = other.short;
                                    let name = other.name;

                                    $('#schools_viewed_fanpages').append('<input name="accesories" type="checkbox" value="'+short+'"/> '+ name +'<br/>');

                                }

                          });               

                          grid.find(".command-edit").on("click", function(e) {

                              //alert("You pressed edit on row: " + $(this).data("row-id"));
                              var ele =$(this).parent();
                              var g_id = $(this).parent().siblings(':first').html();
                              var g_name = $(this).parent().siblings(':nth-of-type(2)').html();

                              console.log(g_id);
                              console.log(g_name);

                              //console.log(grid.data());//
                              $('#edit_modal_fanpage').modal('show');

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
                                $("#edit_icon").append(a4);
                                $('#edit_name_fanpage').val(a5);
                                $('#edit_about').val(a6);
                                $('#edit_cover').append(a7);  

                                $("#fanpage_title").text("Edit fanpage - " + a5);                     

                              } else {
                                 alert('Now row selected! First select row, then click edit button');
                              }

                          }).end().find(".command-images").on("click", function(e) {

                                $('#edit_modal_album').modal('show');                                                                 

                                 var row  =$(this).attr('data-row-id'); 

                                 _fId = row-1;

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

    var parseFileIcon; 
    var parseFileCover; 

      function loadIconsImage(input) {
        if (input.files && input.files[0]) {         
          var reader = new FileReader();
          reader.onload = function (e) {
            $('#img_icon_fanpage').attr('src', e.target.result);
          }
          reader.readAsDataURL(input.files[0]);
          var desc = $("#edit_name_fanpage").val();
          var thunbname = "i_" + desc.toLowerCase() + ".png";
          parseFileIcon = new Parse.File(thunbname, input.files[0], "image/png");                   
        }
      }

      function loadCoverImage(input) {
        if (input.files && input.files[0]) { 
          var reader = new FileReader();
          reader.onload = function (e) {
            $('#img_cover_fanpage').attr('src', e.target.result);
          }
          reader.readAsDataURL(input.files[0]);  
          var desc = $("#edit_name_fanpage").val();
          var backname = "s_" + desc.toLowerCase() + ".png";       
          parseFileCover = new Parse.File(backname, input.files[0], "image/png");                    
        }
      }           

      var albumImages = [];

      function loadAlbumImage(input) {
        
        if (input.files && input.files[0]) {           
          var reader = new FileReader();
          reader.onload = function (e) {
            var _img = "<img id src=\"" + e.target.result + "\" height=\"30\" width=\"30\"/>";
            $("#images_countainer").append(_img);            
          }          
          reader.readAsDataURL(input.files[0]);            
          var parseAlbumFile = new Parse.File("albums", input.files[0], "image/png");                    
          albumImages.push(parseAlbumFile);             
        }
      }

      function saveFanpage() {      

          var userQuery = new Parse.Query(Parse.User);
          userQuery.equalTo("username", "gamvesadmin");
          userQuery.first().then(function(user) {    

              var Fanpage = Parse.Object.extend("Fanpages");         

              var fanpage = new Fanpage();

              var categoryRelation = fanpage.relation("category");
              categoryRelation.add(categoryPF);

              var fanpageName = $("#edit_name_fanpage").val();

              fanpage.set("pageName", fanpageName);
              fanpage.set("pageAbout", $("#edit_about").val());
              fanpage.set("pageIcon", parseFileIcon);
              fanpage.set("pageCover", parseFileCover);
              fanpage.set("categoryName", categoryName);             

              var order = $("#edit_order_fanpage").val();          
              fanpage.set("order", parseInt(order));  

              var authorRelation = fanpage.relation("author");
              authorRelation.add(user);             

              fanpage.set("approved", true);
              fanpage.set("posterId" , user.id);
              fanpage.set("fanpageId", Math.floor(Math.random() * 100000));                       

              fanpage.setACL(fanpagetACL);

              var roles = window.getCheckedRole("frm_edit");

              if (roles.length >0) {
                for (var i = 0; i < roles.length; ++i) {
                    fanpage.setACL(roles[i]);
                }                      
              }
                                        
              fanpage.save(null, {
                  success: function (pet) {

                      console.log('Fanpage created successful with name: ' + fanpage.get("pageName"));
                      $('#edit_modal_fanpage').modal('hide');
                      loadFanpages(categoryPF);
                      clearField();

                  },
                  error: function (response, error) {
                      console.log('Error: ' + error.message);
                  }
              });

             }, function(error) {     

              response.error(error);

          }); 


          
      }
      

      function saveAlbums() {

          var Albums = Parse.Object.extend("Albums");              
          
          for (var i=0; i<albumImages.length; i++){           
            
            var album = new Albums();
            album.set("cover", albumImages[i]);
            var fanId = fanpageIdArray[_fId];
            album.set("referenceId", fanId);   
            album.set("type", "Images");

            var name = $('#edit_album_name').val();                      
            var result = MD5(name);
            album.set("imageId", result);      

            album.set("name", name); 

            album.save(null, {
              success: function (albumStored) {
                  
                    var alRelation = fanpageObjs[_fId].relation("albums");
                    alRelation.add(albumStored);

                    fanpageObjs[_fId].save();

              },
              error: function (response, error) {
                  console.log('Error: ' + error.message);
              }

            });
          }

          $('#edit_modal_album').modal('hide');          
          clearField();         
      }

      function clearField() {

          $("#edit_modal_fanpage").find("input[type=text], textarea").val("");
          $("#edit_modal_fanpage").find("input[type=file], textarea").val("");
          //$("#edit_order_fanpage").empty();
          $('#img_icon_fanpage').attr('src', "https://upload.wikimedia.org/wikipedia/commons/c/ca/1x1.png");             
          $("#img_cover_fanpage").attr('src', "https://upload.wikimedia.org/wikipedia/commons/c/ca/1x1.png");             

      }


});