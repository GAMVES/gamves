<?php

/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
    date_default_timezone_set('America/Argentina/Buenos_Aires');
    
    ini_set('max_execution_time', 30000);
    ini_set('memory_limit','50M');

    session_start();

    require_once __DIR__ . '/vendor/autoload.php';

    use Parse\ParseClient;
    use Parse\ParseQuery;
    use Parse\ParseObject;
    use Parse\ParseUser;
    
    $prod = false;
    
    $appId      = '';
    $restApiKey = '';
    $masterKey  = '';
    
    if ($prod)
    {
        $appId      = 'xoDuSZwB8zeftGBwICUwVkTMpWCqLql0sre3X8r2';
        $restApiKey = 'R1kB7O10vyZEqDFVwRWnM4E2HmDulJKa1MsBXgBg';
        $masterKey  = 'dDnAppR2RBxSIZH2NBN6LdmvrNL4ciFrpshXHSoE';
    } else 
    {
        //$appId      = '447738';
        $appId      = '447738';
        //$restApiKey = '';
        //$masterKey  = 'gamvescommunity';
        $masterKey  = 'shalltvnetwork';
    }
    
    //BAck4App
    
    //ParseClient::initialize(
    //        'qmTbd36dChKyopgav1JVUMGx2vnZSVdclkNpK6YU', 
    //        'EuHJd7gSh4OXJl429qz9Da6HkF0J21aFWSvE7cwj', 
    //        'y9gPMZYJ3KsfUwWGnyvkoINJXs33JJ4iM0VWVE0m');
    //ParseClient::setServerURL('https://parseapi.back4app.com', '/');
    
    //Shashido
    
    ParseClient::initialize(
            'lTEkncCXc0jS7cyEAZwAr2IYdABenRsY86KPhzJT', 
            'UQT6P84J17jyXpA9GHEgToLmJgnYhReORoszKsP6', 
            'bfNasoQM6aJ59UPLcSjENMuOsJeKh6R5nPDRzeDY');
    ParseClient::setServerURL('https://pg-app-z97yidopqq2qcec1uhl3fy92cj6zvb.scalabl.cloud/1/', '/');
    
    $facebookAppId = '278298429287067';
    $facebookAppSecret = 'd9271cb326392fe24daacf800d997017';
    
    $fb_api_version = 'v2.9';

    $fb = new Facebook\Facebook([
      'app_id' => $facebookAppId,
      'app_secret' => $facebookAppSecret,
      'default_graph_version' => $fb_api_version,
      ]);
   
    $objectPush = new stdClass();
    $data = '';
    $profile = '';
    
    $process_message = '';
    
    //FACEBOOK PARSE MATCH
        
    $helper = $fb->getRedirectLoginHelper();
    
    try 
    {
      
        $accessToken = $helper->getAccessToken();
      
    } catch(Facebook\Exceptions\FacebookResponseException $e) {
      // When Graph returns an error
      echo 'Graph returned an error: ' . $e->getMessage();
      exit;
    } catch(Facebook\Exceptions\FacebookSDKException $e) {
      // When validation fails or other local issues
      echo 'Facebook SDK returned an error: ' . $e->getMessage();
      exit;
    }

    if (isset($accessToken)) 
    {
        $_SESSION['facebook_access_token'] = (string) $accessToken;  
        
        $fb->setDefaultAccessToken($_SESSION['facebook_access_token']);  

    } elseif ($helper->getError()) 
    {
      exit;
    }
    
   //50043151918
    
    try 
    {
        $user = "josemanuelvigil@gmail.com";
        $pass = "joselon";
        $pfuser = ParseUser::logIn($user, $pass);                     

    } catch (ParseException $ex) {  
        // Execute any logic that should take place if the save fails.
        // error is a ParseException object with an error code and message.
        echo 'Failed to create new object, with error message: ' . $ex->getMessage();
    }
    
    
    
    // OAuth 2.0 client handler
    $oAuth2Client = $fb->getOAuth2Client();        
    // Exchanges a short-lived access token for a long-lived one
    $longLivedAccessToken = $oAuth2Client->getLongLivedAccessToken($_SESSION['facebook_access_token']);

    if ($longLivedAccessToken->isLongLived())
    {
        $_SESSION['facebook_access_token'] = (string) $longLivedAccessToken;
        // setting default access token to be used in script
        $fb->setDefaultAccessToken($_SESSION['facebook_access_token']);

        if (isset($accessToken)) 
        {       

            $oAuth2Client = $fb->getOAuth2Client();

            $longLivedAccessToken = $oAuth2Client->getLongLivedAccessToken($accessToken);

            $fb->setDefaultAccessToken($longLivedAccessToken);              

            $parseAccessToken = new ParseQuery("AccessToken");
            //$longLiveAT = (string) $longLivedAccessToken;
            //$parseAccessToken->equalTo("access_token", $longLiveAT);

            $parseAccessTokenResult = $parseAccessToken->find();   

            if ( count($parseAccessTokenResult) > 0)
            {              
                
                for ($i = 0; $i < count($parseAccessTokenResult); $i++) 
                {
                  $access_token = $parseAccessTokenResult[$i];              
                  $storedAcessToken = base64_decode($access_token->get('access_token'));
                  
                  $longliveAccessToken = (string) $longLivedAccessToken;
                  
                  if ($longliveAccessToken==$storedAcessToken)
                  {
                      
                      $expirationAcessToken = $access_token->get('expiration_date');
                      
                      $time = strtotime($expirationAcessToken);                   
                      
                  } else 
                  {                      
                      storeAccessToken($longLivedAccessToken, $pfuser);                      
                  }
                  
                }

            }  else
            {
                storeAccessToken($longLivedAccessToken, $pfuser);
            }
        }
    }                       
    
   
    // getting basic info about user
    try 
    {

        $profile_request = $fb->get('/me?fields=id,name,first_name,last_name,email');

        $profile = $profile_request->getGraphNode()->asArray();

        $fbuser = $profile_request->getGraphUser();

        $facebokId = $fbuser['id']; 
        
        // Current user
        //$pfuser = ParseUser::logInWithFacebook($fbuser['id'], $_SESSION['facebook_access_token']);              
        
               
          
    } catch(Facebook\Exceptions\FacebookResponseException $e) {
            // When Graph returns an error
            echo 'Graph returned an error: ' . $e->getMessage();
            session_destroy();
            // redirecting user back to app login page
            header("Location: ./");
            exit;
    } catch(Facebook\Exceptions\FacebookSDKException $e) {
            // When validation fails or other local issues
            echo 'Facebook SDK returned an error: ' . $e->getMessage();
            exit;
    }
    
    
    

    ///////////////////
    ///  ACTIONS   ////
    ///////////////////

    $method = $_SERVER['REQUEST_METHOD'];

    if ($method == 'GET') 
    { 
        // LANGUAGE
        $items_in_lang = 0;
        
        // + LANGUAGE
        if(isset($_GET['action']) && $_GET['action'] === 'more_language')
        {
            $items_in_lang = 0;
            if(isset($_SESSION['count_languages']) && !empty($_SESSION['count_languages']))
            {               
                $items_in_lang = $_SESSION['count_languages'];
            } 
            
            $items_in_lang += 1;
            
            $_SESSION["count_languages"] = $items_in_lang;  
            
        // - LANGUAGE
        } elseif(isset($_GET['action']) && $_GET['action'] === 'less_language')
        {
            $items_in_lang = 0;
            if(isset($_SESSION['count_languages']) && !empty($_SESSION['count_languages']))
            {               
                $items_in_lang = $_SESSION['count_languages'];
            }           
            
            $items_in_lang -= 1;
            
            $_SESSION["count_languages"] = $items_in_lang;            
               
        // CATEGORY                
        } elseif(isset($_GET['action']) && $_GET['action'] === 'add_category')
        {

            if(isset($_GET['category_value']))
            {

                $pcategory = new ParseObject("Categories");

                $pcategory->set("description", $_GET['category_value']);

                try 
                {
                    $pcategory->save();
                    echo 'New object created with objectId: ' . $pcategory->getObjectId();

                } catch (ParseException $ex) 
                {  
                  // Execute any logic that should take place if the save fails.
                  // error is a ParseException object with an error code and message.
                  echo 'Failed to create new object, with error message: ' . $ex->getMessage();
                }           

                $process_message = '<br><font color="red">****************** OUTPUT *********************<br>';

                $process_message .=  '<b>'.$_GET['category_value'].'</b> category has been stored.<br>';

                $process_message .= "****************** OUTPUT *********************</font><br><br><br>";

                loadForm($facebokId, $fb, $data, $process_message);

                return;
            }

        // GRAPH QUERY
        } else if(isset($_GET['action']) && $_GET['action'] === 'query_fanpage')
        { 

            if(isset($_GET['fanpageid']))
            {
                
                $facebookPageId = $_GET['fanpageid'];
                
                /// CHECK EXIST
                
                if( $_GET["fanpageid"] || $_GET["fanpageid"] ) 
                {          

                    $queryFanpage = new ParseQuery("Fanpage");
                    
                    $queryFanpage->equalTo("fanpageId", $_GET["fanpageid"]);

                    $fanpageResult = $queryFanpage->find();   
                    
                    if (count($fanpageResult)>0)
                    {
                        $process_message = '<br><font color="red" style="text-transform: uppercase;">';

                        $process_message .=  '<b>ALERT:</b> FanPage number <b>'.$_GET["fanpageid"].'</b> already exists on the backend, please try another.<br>';

                        $process_message .= "</font><br>";

                        loadForm($facebokId, $fb, $data, $process_message);

                        return;
                        
                    }            
                }
                
                $base_url = 'https://graph.facebook.com/';
                //$params = "?fields=id,name,about,link,is_verified,picture,cover,likes,videos{copyrighted,created_time,source,length,title,description,thumbnails}";

                //$params = "?fields=id,name,about,link,is_verified,picture,cover,likes,videos{created_time,source,length,title,description,thumbnails,id}&limit=1";
                
                $params = "?fields=id,name,about,link,is_verified,picture,cover,fan_count,videos{created_time,source,length,title,description,thumbnails,id,likes.limit(1).summary(true)}&limit=10";
                
                $fanquery = $facebookPageId.$params;

                try 
                {
                  
                    $pg_response = $fb->get($fanquery, $_SESSION['facebook_access_token']);
                    
                } catch(Facebook\Exceptions\FacebookResponseException $e) 
                {
                  // When Graph returns an error
                  echo 'Graph returned an error: ' . $e->getMessage();
                  exit;
                } catch(Facebook\Exceptions\FacebookSDKException $e) {
                  // When validation fails or other local issues
                  echo 'Facebook SDK returned an error: ' . $e->getMessage();
                  exit;
                }

                $fanpageobj = new stdClass();

                $graph_response = $pg_response->getGraphObject();                      

                $pg_id      = $graph_response->getProperty('id');
                $pg_name     = $graph_response->getProperty('name');
                $pg_about     = $graph_response->getProperty('about');

                $pg_link     = $graph_response->getProperty('link');

                $pg_verified = $graph_response->getProperty('is_verified');

                $pg_pic      = $graph_response->getProperty('picture');
                $pic_output  = json_decode($pg_pic, true);
                $pg_picture = $pic_output['url'];  

                $pg_cover   = $graph_response->getProperty('cover');
                $cover_output  = json_decode($pg_cover, true);
                $pg_cover_source = $cover_output['source'];
                $pg_cover_id    = $cover_output['id'];

                $pg_likes   = $graph_response->getProperty('fan_count');          
                $pg_videos  = $graph_response->getProperty('videos'); 
                
                ////////////////
                ///  IMAGES   //
                ///////////////            
                  
                $array_images = array();

                // Get photo albums of Facebook page using Facebook Graph API
                $fields = "id,name,cover_photo,count";
                $graphAlbumsAlbLink = "https://graph.facebook.com/{$fb_api_version}/{$facebookPageId}/albums?limit=5&fields={$fields}&access_token={$_SESSION['facebook_access_token']}";

                $jsonAlbumData = file_get_contents($graphAlbumsAlbLink);
                $fbAlbumObj = json_decode($jsonAlbumData, true, 512, JSON_BIGINT_AS_STRING);
              
                $array_albums = array();
            
                foreach($fbAlbumObj as $albumDataRaw)
                {  
                    
                    foreach($albumDataRaw as $albumData)
                    {
                        
                        if( isset( $albumData['id'] ) )
                        { 
                            $album = new stdClass();

                            $album->id = $albumData['id'];
                            
                            $album->fanpageId = $pg_id;

                            if( isset( $albumData['name'] ) )
                            {
                                $album->name = $albumData['name'];
                            }

                            if( isset( $albumData['cover_photo'] ) )
                            {
                             
                                $imageId = $albumData['cover_photo']['id'];

                                $fields = "name,source";
                                $graphImageAlbLink = "https://graph.facebook.com/{$fb_api_version}/{$imageId}/?fields={$fields}&access_token={$_SESSION['facebook_access_token']}";

                                $jsonImageData = file_get_contents($graphImageAlbLink);
                                $fbImageAlbumObj = json_decode($jsonImageData, true, 512, JSON_BIGINT_AS_STRING);

                                if( isset( $fbImageAlbumObj['source'] ) )
                                {
                                    $album->cover = $fbImageAlbumObj['source'];
                                }
                            }

                            array_push($array_albums, $album);
                        }
                    }
                  
                }

                ////////////////
                ///  VIDEOS   //
                ////////////////         
                        
                $video_array_json = $pg_response->getDecodedBody()['videos']; //$graph_response_decode[videos];
                
                $likes_videos = array();
                
                foreach($video_array_json as $likes)
                {
                 
                    foreach($likes as $like)
                    {
                        
                        if (isset($like['id']))    
                        {
                            $id = $like['id'];
                        }
                        
                        if (isset($like['likes']))    
                        {
                            $likesObject = $like['likes'];
                        }
                        
                        if (isset($likesObject['summary']))    
                        {
                            $summaryObject = $likesObject['summary'];
                        }

                        if (isset($summaryObject['total_count']))    
                        {
                            $likesCount = $summaryObject['total_count'];
                        }                                            

                        $likes_videos[$id] = $likesCount;
                    }
                    
                }
                
                $video_array = json_decode($pg_videos, true);               

                $array_videos = array();
                $array_thumbnail = array();

                foreach($video_array as $data)
                {                    
                    $video = new stdClass();                                                                        
                            
                    $created_time   = $data['created_time'];       
                    
                    $fbdate         = $created_time['date'];  
                    $date           = new DateTime($fbdate);
                    
                    $timezone       = $created_time['timezone'];

                    if( isset( $data['source'] ) )
                    {                         
                        $source         = $data['source'];
                    }
                    
                    if( isset( $data['length'] ) )
                    {
                        $length         = $data['length'];   
                    }  
                                   

                    $video->fanpageid   = $pg_id;
                    $video->fanpagename = $pg_name;

                    if( isset( $data['title'] ) )
                    {
                        $title      = $data['title'];
                        $video->title       = $title;                        
                    } else 
                    {
                        $video->title = "Multimedia Video";
                    }                                      

                    if( isset( $data['description'] ) )
                    {
                        $description    = $data['description'];                        
                        $video->description = $description;
                    } else 
                    {
                        $video->description = "No current description available.";
                    }               

                    if( isset( $data['id'] ) )
                    {
                        $videoid = $data['id'];
                    }                    
                                    
                    $video_likes = $likes_videos[$videoid];

                    $video->likes = $video_likes;                      

                    if( isset( $data['thumbnails'] ) )
                    {                    
                        $thumbnails     = $data['thumbnails'];              

                        foreach ($thumbnails as $thumb)
                        {
                            $preferred = $thumb["is_preferred"];

                            if ($preferred==true)
                            {                       
                                $thumbnail_id       = $thumb['id'];
                                $thumbnail_height   = $thumb['height'];
                                $thumbnail_width    = $thumb['width'];
                                $thumbnail_uri      = $thumb['uri'];

                                $video->thumbnail_id        = $thumbnail_id;
                                $video->thumbnail_height    = (int)$thumbnail_height;
                                $video->thumbnail_width     = (int)$thumbnail_width;
                                $video->thumbnail_uri       = $thumbnail_uri;                          

                            }                            
                        } 
                    }

                    //$video->copyrighted = (bool)$copyrighted;
                    $video->date        = $date;
                    $video->timezone    = $timezone;
                    $video->source      = $source;
                    $video->length      = floatval($length);                                      
                    $video->videoid     = $videoid;    

                    array_push($array_videos, $video);  

                }

                $fanpageobj->fanpageId      = $facebookPageId;   
                //$fanpageobj->id             = floatval($pg_id);
                $fanpageobj->name           = $pg_name;
                $fanpageobj->about          = $pg_about;
                $fanpageobj->link           = $pg_link;
                $fanpageobj->verified       = $pg_verified;                        
                $fanpageobj->pic            = $pg_picture;
                $fanpageobj->cover          = $pg_cover_source;        
             
                $fanpageobj->likes          = $pg_likes; //floatval($pg_likes);
                $fanpageobj->videos         = $array_videos;
                $fanpageobj->albums         = $array_albums;
                                
                $data = "<h4 id='page-title-fetch'>". $pg_name  ."</h4>";

                $data .= "<b>Id            :       </b>". $pg_id    ."<br>";
                $data .= "<b>About         :       </b>". $pg_about  ."<br>";
                $data .= "<b>Url           :       </b><a href="    .$pg_link.">". $pg_link  ."</a><br>";
                $data .= "<b>Verified      :       </b>". $pg_verified  ."<br><br>";
                $data .= "<b>Picture       :       </b><br><img style='width: 80px;' src='"  . $pg_picture            ."'/><br><br>";
                $data .= "<b>Cover         :       </b><br><img style='width: 400px;' src='"  . $pg_cover_source       ."'/><br><br>";
                $data .= "<b>Likes         :       </b>". $pg_likes   ."<br><br>";

                $_SESSION['fanpage'] = serialize($fanpageobj);

            }
        }
        
    } elseif ($method == 'POST') 
    {  
        //POST
        $country = new stdClass();
        $language = new stdClass();
        $category = new stdClass();      
        $array_languages = array();
        
        $adult = false;

        if( $_POST["countries"] || $_POST["countries"] ) 
        { 
            $queryCountries = new ParseQuery("Countries");
            $queryCountries->equalTo("objectId", $_POST["countries"]);           
            $queryCountries->descending("DescRegular");
            $countryResult = $queryCountries->find();           

            for ($i = 0; $i < count($countryResult); $i++) 
            {
              $country = $countryResult[$i];
            }
        }
        
        $combolangcount = 0;
        $languageclass = new stdClass();
        
        if(isset($_SESSION['count_languages']) && !empty($_SESSION['count_languages'])) 
        {
            $combolangcount = $_SESSION["count_languages"];
            for ($q=0; $q<=$combolangcount; $q++ )
            {
                $langpost = $_POST["languages_".$q];                            
                $languageclass = loadLanguage($langpost);   
                $_SESSION['session_language_'.$q] = serialize($languageclass);
            }              
        } else
        {
            $combolangcount = 0;
            $languageclass = loadLanguage($_POST["languages_0"]);  
            $_SESSION['session_language_0'] = serialize($languageclass);
        } 
        
        if( $_POST["categories"] || $_POST["categories"] ) 
        {             
            $queryCategories = new ParseQuery("Categories");
            $queryCategories->equalTo("objectId", $_POST["categories"]);
            $queryCategories->descending("description");            
            $categoriesResult = $queryCategories->find();      
            
            $category_for_video = '';
            for ($i = 0; $i < count($categoriesResult); $i++) 
            {
              $category = $categoriesResult[$i];              
              $category_for_video = $category->get('description');
            }
        }

        if(isset($_POST['isadult']) && 
            $_POST['isadult'] == 'Yes') 
        {
            $adult = true;
        }               

        $fanpageobj  = unserialize($_SESSION['fanpage']);             

        $array_parse_videos = array();

        $videos = new stdClass();

        $pfanpage = new ParseObject("Fanpage");

        
        
        // LAGUAGES.    
        
        $relationLanguage = $pfanpage->getRelation("language");   

        if ($combolangcount==0)
        {    

            $languageclass  = unserialize($_SESSION['session_language_0']);                 
            $language_for_video = $languageclass->language_for_video;
            $relationLanguage->add($languageclass->language);

        } else
        {
            for ($m=0; $m<=$combolangcount; $m++)
            {          
                $languageclass  = unserialize($_SESSION['session_language_'.$m]);                                         
                $language =  $languageclass->language;
                $relationLanguage->add($language);

                if ($m==0)
                {
                    $language_for_video = $languageclass->language_for_video;
                } 
            }
        }  
            
        $relationAlbum = $pfanpage->getRelation("albums");
        
        foreach ($fanpageobj->albums as $albums_unsrl)
        {
            
            $palbum = new ParseObject("Albums"); 
            $palbum->set("albumId", $albums_unsrl->id);
            $palbum->set("name",    $albums_unsrl->name);
            $palbum->set("cover",   $albums_unsrl->cover);
            $palbum->set("fanpageId", $albums_unsrl->fanpageId);
                    
            try 
            {
                $palbum->save();                

            } catch (ParseException $ex) {  
              // Execute any logic that should take place if the save fails.
              // error is a ParseException object with an error code and message.
              echo 'Failed to create new object, with error message: ' . $ex->getMessage();
            }

            $relationAlbum->add($palbum);

        }
        
        $relationVideos = $pfanpage->getRelation("videos");
            
        foreach ($fanpageobj->videos as $videos_unsrl)
        {
            
            $pvideo = new ParseObject("Videos");            
            $pvideo->set("fromId",      $videos_unsrl->fanpageid);
            $pvideo->set("fromName",    $videos_unsrl->fanpagename);
            $pvideo->set("date",        $videos_unsrl->date);
            $pvideo->set("timezone",    $videos_unsrl->timezone);
            $pvideo->set("source",      $videos_unsrl->source);
            $pvideo->set("length",      $videos_unsrl->length);
            $pvideo->set("title",       $videos_unsrl->title);
            
            $pvideo->set("description", $videos_unsrl->description);
            $pvideo->set("videoId",     $videos_unsrl->videoid);            
                       
            $pvideo->set("category",    $category_for_video);
            $pvideo->set("language",    $language_for_video);
            
            $pvideo->set("likes",       $videos_unsrl->likes);

            $pvideo->set("idThumbnail",     $videos_unsrl->thumbnail_id);
            $pvideo->set("thumbnailHeight", $videos_unsrl->thumbnail_height);
            $pvideo->set("thumbnailHeight", $videos_unsrl->thumbnail_height);
            $pvideo->set("thumbnailWidth",  $videos_unsrl->thumbnail_width);
            $pvideo->set("thumbnailUrl",    $videos_unsrl->thumbnail_uri);                    

            try 
            {
                $pvideo->save();                

            } catch (ParseException $ex) {  
              // Execute any logic that should take place if the save fails.
              // error is a ParseException object with an error code and message.
              echo 'Failed to create new object, with error message: ' . $ex->getMessage();
            }

            $relationVideos->add($pvideo);

        }
        
        $pfanpage->set("fanpageId",     $fanpageobj->fanpageId);
        $pfanpage->set("pageName",      $fanpageobj->name);
        $pfanpage->set("pageAbout",     $fanpageobj->about);
        $pfanpage->set("pageLink",      $fanpageobj->link);
        $pfanpage->set("pageIcon",      $fanpageobj->pic);
        $pfanpage->set("pageCover",     $fanpageobj->cover);
        $pfanpage->set("pageLikes",     $fanpageobj->likes);   
        $pfanpage->set("pageIsAdult",   $adult);
        $pfanpage->set("pageVerified",  $fanpageobj->verified);
        $pfanpage->set("isFeatured",    false);

        // Relations :

        $relationCountry = $pfanpage->getRelation("county");
        $relationCountry->add($country);

        $relationCategory = $pfanpage->getRelation("category");
        $relationCategory->add($category); 
        
        
        //IMAGES
  
        try 
        {
            $pfanpage->save();           

        } catch (ParseException $ex) {  
          // Execute any logic that should take place if the save fails.
          // error is a ParseException object with an error code and message.
          echo 'Failed to create new object, with error message: ' . $ex->getMessage();
        }           

        $process_message = '<br><font color="red">****************** OUTPUT *********************<br>';

        $process_message .=  '<b>'.$fanpageobj->name.'</b> with id <b>'.$fanpageobj->fanpageId.'</b> has been stored.<br>';

        $process_message .= "****************** OUTPUT *********************</font><br><br><br>";

    } 
        
    loadForm($facebokId, $fb, $data, $process_message);
    
    echo '<br><br>';
    
    $logoutUrl = $helper->getLogoutUrl('{access-token}', 'https://localhost/shalltvbackend/index_callback.php');
    echo '<a class="mdl-button mdl-js-button mdl-button--raised mdl-button--accent" style="margin-bottom:40px; height: 55px; margin-left: 20px; margin-right: 20px;"href="' . $logoutUrl . '">Logout from Facebook</a>';
    
    //echo '<a href="?action=logout">Logout</a>';
    
    
    function storeAccessToken($longLivedAccessToken, $pfuser)
    {
        
        //DELETE CURRENT.
        $AccessTokenQuery = new ParseQuery("AccessToken");   
        
        $results_access_token = $AccessTokenQuery->find();
        
        try 
        {       
            
            for ($i = 0; $i < count($results_access_token); $i++) 
            {
                $access_token = $results_access_token[$i];
                $access_token->destroy();
            }

        } catch (ParseException $ex) {  
            // Execute any logic that should take place if the save fails.
            // error is a ParseException object with an error code and message.
            echo 'Failed to delete object, with error message: ' . $ex->getMessage();
        }
        
        
        
        $pfacesstoken = new ParseObject("AccessToken");
                
        $longliveaccestoken = (string) $longLivedAccessToken;

        $pfacesstoken->set("access_token", base64_encode($longliveaccestoken)); //$longLivedAccessToken);

        $expirationDate = $longLivedAccessToken->getExpiresAt();

        $pfacesstoken->set("expiration_date", $expirationDate);

        $relationUser = $pfacesstoken->getRelation("user");

        $relationUser->add($pfuser);

        try 
        {
            $pfacesstoken->save();                

        } catch (ParseException $ex) {  
            // Execute any logic that should take place if the save fails.
            // error is a ParseException object with an error code and message.
            echo 'Failed to create new object, with error message: ' . $ex->getMessage();
        }
    }
    
    function get_facebook_json($url) 
    {
        $options = array(
            CURLOPT_RETURNTRANSFER => true,   // return web page
            CURLOPT_HEADER         => false,  // don't return headers
            CURLOPT_FOLLOWLOCATION => true,   // follow redirects
            CURLOPT_MAXREDIRS      => 10,     // stop after 10 redirects
            CURLOPT_ENCODING       => "",     // handle compressed
            CURLOPT_USERAGENT      => "test", // name of client
            CURLOPT_AUTOREFERER    => true,   // set referrer on redirect
            CURLOPT_CONNECTTIMEOUT => 120,    // time-out on connect
            CURLOPT_TIMEOUT        => 120,    // time-out on response
        ); 

        $ch = curl_init($url);
        curl_setopt_array($ch, $options);

         try 
        {
             $content  = curl_exec($ch);                

        } catch (Exception $ex) {  
            // Execute any logic that should take place if the save fails.
            // error is a ParseException object with an error code and message.
            echo 'Failed to get JSON: ' . $ex->getMessage();
        }
       
        curl_close($ch);

        return $content;
    }
   
?>


<?php

  
    function loadForm($facebokId, $fb, $data, $message)
    {
       
        ///////////////
        ///  FORM  ////
        ///////////////
        
        echo "<html>\n";
        echo "<head>\n";
        echo '<script src="https://storage.googleapis.com/code.getmdl.io/1.0.1/material.min.js"></script>';
        echo '<link rel="stylesheet" href="https://storage.googleapis.com/code.getmdl.io/1.0.1/material.indigo-pink.min.css">';
        echo '<link rel="stylesheet" href="https://fonts.googleapis.com/icon?family=Material+Icons">';
        echo "<script src='http://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js'>\n";
        echo "</script>\n";
        
        ///////////////
        /// HEADER ////
        ///////////////
        
        echo '<div class="mdl-layout mdl-js-layout mdl-layout--fixed-header"><header class="mdl-layout__header"><div class="mdl-layout__header-row"><span class="mdl-layout__title" style="font-size: 20px">Shall TV Backend</span></div></header>';
        
        echo '<main class="mdl-layout__content"><div class="page-content">';
        
        //Form
        echo '<br>';
        echo '<div class="demo-card-wide mdl-card mdl-shadow--2dp" style="width: 97%; margin: 0 auto; padding: 20px; margin-bottom: 6px;">';
        
        echo $message;
        
        echo '<form action="" method="post">';
        echo 'FACEBOOK ID: <b>' . $facebokId . '</b>';
        echo '<br>';

        echo '<br>';

        echo 'Country: ';
        echo "<div class='mdl-select mdl-js-select mdl-select--floating-label'><select class='mdl-select__input' name='countries'>n";
        $countries = new ParseQuery("Countries");
        $countries->limit(249);
        $countries->ascending("DescRegular");
        $results_country = $countries->find();

        for ($i = 0; $i < count($results_country); $i++) 
        {
            $country = $results_country[$i];
            echo '<option value="' . $country->getObjectId() . '">' . $country->get("DescRegular") . '</option>'; // Printing from "Categories"
        }

        echo "</select></div>";

        echo '<br>';

        ///  NEW LANGUAGES  ////
        
        if(isset($_SESSION['count_languages']) && !empty($_SESSION['count_languages'])) 
        {
            $combocatamount = $_SESSION["count_languages"]; 
        } else 
        {
            $combocatamount = 0;
        }             
        
        if ($combocatamount==0)
        {
            echo 'Language: ';   
            loadLanguageCombo(0);                        
        } else
        {
            for ($q=0; $q<=$combocatamount; $q++ )
            {
                $r = $q+1;
                echo 'Language '.$r.' :';   
                loadLanguageCombo($q); 
                echo '<br>';
            }
        }
        echo '<br>';
        
        echo '<a class="mdl-button mdl-js-button mdl-button--raised mdl-button--accent" href=\'\' onclick="this.href=\'?action=more_language\'">+</a>';
        echo '<a class="mdl-button mdl-js-button mdl-button--raised mdl-button--accent" href=\'\' onclick="this.href=\'?action=less_language\'">-</a>';
        
        echo '<br><br>';

        echo '<br>';

        echo 'Category: ';
        echo "<div class='mdl-select mdl-js-select mdl-select--floating-label'><select class='mdl-select__input' name='categories'>n";
        $categories = new ParseQuery("Categories");
        $categories->ascending("description");        
        $results_category = $categories->find();
  
        for ($i = 0; $i < count($results_category); $i++) 
        {
            $category = $results_category[$i];
            echo '<option value="' . $category->getObjectId() . '">' . $category->get("description") . '</option>'; // Printing from "Categories"
        }
  
        echo "</select></div>";

        ///  NEW CATEGORY  ////
           
        makeTextInputField('New Catergory', 'newcategory');
        
        echo '<a class="mdl-button mdl-js-button mdl-button--raised mdl-button--accent" href=\'\' onclick="this.href=\'?action=add_category&category_value=\'+document.getElementById(\'newcategory\').value">Add Category</a>';
        
        echo '<br><br>';
        
        echo '<label class="mdl-checkbox mdl-js-checkbox mdl-js-ripple-effect"><input class="mdl-checkbox__input" type="checkbox" name="isadult" value="Yes">Is Adult</input></label>';

        echo '<br><br>';

        echo 'Paste FB ID here:';
        
        ///  FUN PAGE QUERY  ////

        makeTextInputField('Facebook Page ID', 'fbPageId');
        
        echo '<a class="mdl-button mdl-js-button mdl-button--raised mdl-button--accent" href=\'\' onclick="this.href=\'?action=query_fanpage&fanpageid=\'+document.getElementById(\'fbPageId\').value">Fetch Page Info</a>';
       
        echo '<br><br>';

        echo 'FETCHED INFORMATION WILL SHOW BELOW';

        echo '<br><br>';

        echo '<hr>';

        echo $data;

        echo '<hr>';

        echo '<br><br>';

        echo '<button class="mdl-button mdl-js-button mdl-button--raised mdl-button--colored" name="submit" value="3">SAVE TO SERVER</button>';

        echo '</form>';
        
        echo '</div>';
        
        echo '</div>';
        
        echo '</main>';
        
        echo '<style type="text/css">
        .mdl-select {
            position: relative;
            font-size: 16px;
            display: inline-block;
            box-sizing: border-box;
            width: 300px;
            max-width: 100%;
            margin: 0;
            padding: 20px 0;
        }
    
        .mdl-select__input {
            border: none;
            border-bottom: 1px solid rgba(0,0,0, 0.12);
            display: inline-block;
            font-size: 16px;
            margin: 0;
            padding: 4px 0;
            width: 100%;
            background: 16px;
            text-align: left;
            color: inherit;
        }
    
        .mdl-select.is-focused .mdl-select__input {	outline: none; }
        .mdl-select.is-invalid .mdl-select__input {
            border-color: rgb(222, 50, 38);
            box-shadow: none;
        }
    
        .mdl-select.is-disabled .mdl-select__input {
            background-color: transparent;
            border-bottom: 1px dotted rgba(0,0,0, 0.12);
        }
    
        .mdl-select__label {
            bottom: 0;
            color: rgba(0,0,0, 0.26);
            font-size: 16px;
            left: 0;
            right: 0;
            pointer-events: none;
            position: absolute;
            top: 24px;
            width: 100%;
            overflow: hidden;
            white-space: nowrap;
            text-align: left;
        }
    
        .mdl-select.is-dirty .mdl-select__label { visibility: hidden; }
    
        .mdl-select--floating-label .mdl-textfield__label {
            -webkit-transition-duration: 0.2s;
            transition-duration: 0.2s;
            -webkit-transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
            transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
        }
    
        .mdl-select--floating-label.is-focused .mdl-select__label,
        .mdl-select--floating-label.is-dirty .mdl-select__label {
            color: rgb(63,81,181);
            font-size: 12px;
            top: 4px;
            visibility: visible;
        }
    
        .mdl-select--floating-label.is-focused .mdl-select__expandable-holder .mdl-select__label,
        .mdl-select--floating-label.is-dirty .mdl-select__expandable-holder .mdl-select__label {
            top: -16px;
        }
    
        .mdl-select--floating-label.is-invalid .mdl-select__label {
            color: rgb(222, 50, 38);
            font-size: 12px;
        }
    
        .mdl-select__label:after {
            background-color: rgb(63,81,181);
            bottom: 20px;
            content: \'\';
            height: 2px;
            left: 45%;
            position: absolute;
            -webkit-transition-duration: 0.2s;
            transition-duration: 0.2s;
            -webkit-transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
            transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
            visibility: hidden;
            width: 10px;
        }
    
        .mdl-select.is-focused .mdl-select__label:after {
            left: 0;
            visibility: visible;
            width: 100%;
        }
    
        .mdl-select.is-invalid .mdl-select__label:after {
            background-color: rgb(222, 50, 38);
        }
    
        .mdl-select__error {
            color: rgb(222, 50, 38);
            position: absolute;
            font-size: 12px;
            margin-top: 3px;
            visibility: hidden;
        }
    
        .mdl-select.is-invalid .mdl-select__error {
            visibility: visible;
        }
    
        .mdl-select__expandable-holder {
            display: inline-block;
            position: relative;
            margin-left: 32px;
            -webkit-transition-duration: 0.2s;
            transition-duration: 0.2s;
            -webkit-transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
            transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
            display: inline-block;
            max-width: 0.1px;
        }
    
        .mdl-select.is-focused .mdl-select__expandable-holder, .mdl-select.is-dirty .mdl-select__expandable-holder {
            max-width: 600px;
        }
    
        .mdl-select__expandable-holder .mdl-select__label:after {
            bottom: 0;
            
        }</style>';
    
        echo "</head>\n";
        echo "</html>\n";
    
    }
    
    function makeTextInputField($label, $name)
    {
        $text = ucfirst($label);
        echo "
            <div class=\"mdl-textfield mdl-js-textfield mdl-textfield--floating-label\" style='width: 180px; margin-left: 10px; margin-right: 10px;'>
            <input class=\"mdl-textfield__input\" type='text' name='{$name}' id='{$name}' style='width: 160px;' />
            <label class=\"mdl-textfield__label\" for='{$label}'>{$text}</label>
            </div>
        ";
    } 
    
    function loadLanguageCombo($number)
    {        
        echo "<div class='mdl-select mdl-js-select mdl-select--floating-label'><select class='mdl-select__input' name='languages_".$number."'>n";
        
        $languages = new ParseQuery("Languages");
        $languages->limit(184);
        $languages->ascending("Language");
        $results_language = $languages->find();
       
        for ($i = 0; $i < count($results_language); $i++) 
        {
            $language = $results_language[$i];
            echo '<option value="' . $language->getObjectId() . '">' . $language->get("Language") . '</option>'; // Printing from "Categories"
        }

        echo "</select></div>";
    }
    
    function loadLanguage($objectId)
    {        
        $languageclass = new stdClass();

        $queryLanguages = new ParseQuery("Languages");
        $queryLanguages->equalTo("objectId", $objectId);
        $queryLanguages->descending("Language");
        $queryLanguages->limit(200);

        $languageResult = $queryLanguages->find();
        
        if ($languageResult>0)
        {
            for ($l = 0; $l < count($languageResult); $l++) 
            {
              $language = $languageResult[$l];              
              if ($l==0)
              {
                  $language_for_video = $language->get('Language');
                  $languageclass->language_for_video = $language_for_video;
              } 
              $languageclass->language = $language;
              return $languageclass;
            }        
        }
    }

?>    