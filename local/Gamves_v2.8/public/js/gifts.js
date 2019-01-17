document.addEventListener("LoadGifts", function(event){

    var schoolId = event.detail[0];
    var short = event.detail[1];

    var selectedItem = [];   
    var selected = -1; 
    var giftsLenght = 0;
    var GiftName;
    
    loadGifts();    
    loadOtherSchools(schoolId);

    var parseFileThumbanil; 

    function loadGifts()
    {  
        queryGift = new Parse.Query("Gifts");  
        //queryGift.containedIn("target", [short]);          
        queryGift.find({
            success: function (gifts) {

                if (gifts) {                

                  giftsLenght = gifts.length;
                  var dataJson = [];

                  for (var i = 0; i < giftsLenght; ++i) 
                  {
                      item = {};
                      item["id"] = i+1;
                      var objectId = gifts[i].id;
                      dataJson.objectId = objectId;
                      item["objectId"] = objectId;                  
                      if (gifts[i].get("thumbnail") != undefined){                
                        var thumbnail = gifts[i].get("thumbnail");
                        item["thumbnail"] = thumbnail._url;
                      } else {
                        item["thumbnail"] = "https://dummyimage.com/60x60/286090/ffffff.png&text=NA";
                      }                      
                      
                      var title = gifts[i].get("title");
                      item["title"] = title;
                      var description = gifts[i].get("description");
                      item["description"] = description;

                      var price = gifts[i].get("price");
                      item["price"] = price;
                      var points = gifts[i].get("points");
                      item["points"] = points;

                      dataJson.push(item);
                  }                          

                  var rowIds = [];
                  var grid = $("#gridGift").bootgrid({                  
                      templates: {
                          header: "<div id=\"{{ctx.id}}\" class=\"{{css.header}}\"><div class=\"row\"><div class=\"col-sm-12 actionBar\"><div class=\"btn\"><div id=\"loader_Gift\" class=\"loader\"/></div><button type=\"button\" id=\"new_gift\" class=\"btn btn-primary\"><span class=\"glyphicon glyphicon-plus-sign\">&nbsp;</span> New Gift </button> <p class=\"{{css.search}}\"></p><p class=\"{{css.actions}}\"></p></div></div></div>"       
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
                           $("#gridGift").bootgrid("deselect", [parseInt(selected)]);                                              
                       }

                      var countSelected=0;
                      var rowIds = [];
                      var GiftId;
                      for (var i = 0; i < rows.length; i++)
                      {                      
                          rowIds.push(rows[i].id); 
                          GiftId = rows[i].objectId; 
                          GiftName = rows[i].name;                              
                      }              

                      selected = rowIds.join(",");
                      selectedItem.push(selected);   

                      var event = new CustomEvent("LoadFanpage", {detail: {
                          GiftId: GiftId,
                          schoolId: schoolId,
                          short: short
                      }}); //{ detail: GiftId });
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

                        $("#loader_Gift").hide();                 

                        $("#input_gift_thumb_image").unbind("change").change(function() {
                          loadThumbImage(this);
                        });                       

                        $( "#btn_save_gift" ).unbind("click").click(function() {
                            saveGift();
                        });                    

                        $( "#new_gift" ).unbind("click").click(function() {                            

                            $("#gift_title").text("New Gift"); 

                            $('#edit_modal_gift').modal('show');                               

                            if (giftsLenght==0){
                                $("#edit_order_gifts").append(($("<option/>", { html: 0 })));                                     
                            } else {
                                giftsLenght++;
                                for (var i = 0; i < giftsLenght; i++) {                          
                                $("#edit_order_gifts").append(($("<option/>", { html: i })));                                     
                                }    
                            }
                            
                            //Other Schools
                            $('#schools_viewed_gifts').empty();                          
                            
                            let count = otherSchools.length;                           

                            for (var i=0; i<count; i++) {                       

                                let other = otherSchools[i];

                                let shortTarget = other.short;
                                let name = other.name;

                                $('#schools_viewed_gifts').append('<input name="accesories" type="checkbox" value="' + shortTarget + '"/> '+ name +'<br/>');

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
                            $('#edit_modal_gift').modal('show');

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
                                $('#edit_gift_description').val(a6);
                                $('#edit_backimage').append(a7); 

                                $("#gift_title").text("Edit Gift - " + a6);                       

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
            $('#img_thumbnail_gift').attr('src', e.target.result);
          }
          reader.readAsDataURL(input.files[0]);
          var desc = $("#edit_title").val();
          var thunbname = "t_" + desc.toLowerCase() + ".png";
          parseFileThumbanil = new Parse.File(thunbname, input.files[0], "image/png");                   
        }
    }    

    function saveGift() {            
          
          var Gift = Parse.Object.extend("Gifts");         
          var gift = new Gift();                       
          
          gift.set("title", $("#edit_title").val());    
          var description = $("#edit_gift_description").val();
          gift.set("description", description);

          gift.set("price", parseInt($("#edit_price").val()));    
          gift.set("points", parseInt($("#edit_points").val()));              
            
          gift.set("thumbnail", parseFileThumbanil);
          
          gift.save(null, {
              success: function (giftSavedPF) {

                var shortArray = [];

                window.GetCheckedNames("frm_edit_gift", short, function(array) {

                  shortArray = array;

                  Parse.Cloud.run("AddAclToGift", { "roles": shortArray, "giftId": gift.id }).then(function(result) {                                         

                    console.log('Gift created successful with name: ' + gift.get("title"));
                    $('#edit_modal_gift').modal('hide');
                    loadGifts();
                    clearField();
                  
                  });

                });    

              },
              error: function (response, error) {
                  console.log('Error: ' + error.message);
              }
          });
      }

      function clearField(){
          $("#edit_modal_gift").find("input[type=text], textarea").val("");                    
          $('#img_thumbnail_gift').attr('src', "https://upload.wikimedia.org/wikipedia/commons/c/ca/1x1.png");                       
      }

  });

  



