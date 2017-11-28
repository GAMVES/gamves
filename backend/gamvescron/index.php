<!DOCTYPE html>
<!--
To change this license header, choose License Headers in Project Properties.
To change this template file, choose Tools | Templates
and open the template in the editor.
-->

<?php


    ini_set('max_execution_time', 20000);
    ini_set('memory_limit','50M');

    require_once __DIR__ . '/vendor/autoload.php';

    session_start();

    use Parse\ParseClient;
    use Parse\ParseQuery;
    use Parse\ParseObject;
    use Parse\ParseUser;
    use Parse\ParseFile;
    
    //$prod = $argv[1];       
    
    $appId      = '';
    $restApiKey = '';
    $masterKey  = '';      
    
    //if ($prod)
    //{
    //    $appId      = 'xoDuSZwB8zeftGBwICUwVkTMpWCqLql0sre3X8r2';
    //    $restApiKey = 'R1kB7O10vyZEqDFVwRWnM4E2HmDulJKa1MsBXgBg';
    //    $masterKey  = 'dDnAppR2RBxSIZH2NBN6LdmvrNL4ciFrpshXHSoE';
    //} else 
    //{
    //    $appId      = '447738';
    //    $appId      = '447738';
    //    $restApiKey = '';
    //    $masterKey  = 'gamvescommunity';
    //    $masterKey  = 'shalltvnetwork';
    //}
    
    //ParseClient::initialize($appId, $restApiKey, $masterKey);
    //ParseClient::setServerURL('http://josevigil.com:1337/shalltv');

    ParseClient::initialize(
            'qmTbd36dChKyopgav1JVUMGx2vnZSVdclkNpK6YU', 
            'EuHJd7gSh4OXJl429qz9Da6HkF0J21aFWSvE7cwj', 
            'y9gPMZYJ3KsfUwWGnyvkoINJXs33JJ4iM0VWVE0m');
    ParseClient::setServerURL('https://parseapi.back4app.com', '/');
    
    $facebookAppId = '278298429287067';
    $facebookAppSecret = 'd9271cb326392fe24daacf800d997017';
    
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
    
    $fb = new Facebook\Facebook(['app_id' => $facebookAppId,'app_secret' => $facebookAppSecret,'default_graph_version' => 'v2.5',]);

    $pfacesstoken = new ParseQuery("AccessToken");      
    $pfacesstoken->descending("createdAt");
   
    $pfacesstoken->equalTo("user", $pfuser);
    
    $results_acess_token = $pfacesstoken->find();          
    $indext = count($results_acess_token) -1;
    
    if (count($results_acess_token)>0)
    {
        $access_token = $results_acess_token[$indext];
        $base64Token = $access_token->get("access_token");    
        $accessToken = base64_decode($base64Token);      
        $fb->setDefaultAccessToken($accessToken); // sets our access token as the access token when we call something using the SDK, which we are going to do now.
    } else 
    {
        
    }
    
    
     
    if (isset($accessToken)) 
    {
        $_SESSION['facebook_access_token'] = (string) $accessToken;      

    } elseif ($helper->getError()) 
    {
      exit;
    }
    
    try 
    {

        $profile_request = $fb->get('/me?fields=name,first_name,last_name,email');

        $profile = $profile_request->getGraphNode()->asArray();

        $fbuser = $profile_request->getGraphUser();

        // Current user
        //$pfuser = ParseUser::logInWithFacebook($fbuser['id'], $_SESSION['facebook_access_token']);

        //$facebokId = $fbuser['id'];

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
    
    //////////////////////////////
    ///  QUERY ALL CATEGORIES   //
    //////////////////////////////
    
    $categories = new ParseQuery("Categories");
    $categories->ascending("description");        
    $results_category = $categories->find();
    
    $array_categories   = array();    
    $array_catimages    = array();
    
    for ($t = 0; $t < count($results_category); $t++) 
    {
        $category = $results_category[$t];        
        array_push($array_categories, $category);
    }  
    
    //////////////////////
    ///  MAIN PROCESS   //
    //////////////////////
    
    $pfunpage = new ParseQuery("FanPage");      
    $pfunpage->ascending("createdAt");   
    $results_funpage = $pfunpage->find();    
    
    $countfan = count($results_funpage);
    $arraydesc = array(); 
    
    echo "\n";
    echo "********************************************************";
    echo "\n";
    
    echo '$countfan: '.$countfan."\n"; 
    
    echo "\n";
    echo "********************************************************";
    echo "\n";      
    
    for ($i = 0; $i < $countfan; $i++) 
    {
        
        $fanpage = $results_funpage[$i];
        $funpageId = $fanpage->get("fanpageId");  
        
        echo '///    i: '.$i.' funpageId: '.$funpageId."\n"; 
        
        ////////////////////////
        ///  QUERY FAN PAGE   //
        ////////////////////////
        
        $base_url = 'https://graph.facebook.com/';               
        
	//$params = "?fields=id,name,about,link,is_verified,picture,cover,likes,videos{created_time,source,length,title,description,thumbnails,id,likes.limit(0).summary(true)}";
        
        $params = "?fields=id,name,about,link,is_verified,picture,cover,fan_count,videos{created_time,source,length,title,description,thumbnails,id,likes.limit(1).summary(true)}&limit=10";

        $fanquery = $funpageId.$params;      

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

        $graph_response = $pg_response->getGraphObject();

        $fanpageobj = new stdClass();
        
        $pg_id      = $graph_response->getProperty('id');    
        $pg_name      = $graph_response->getProperty('name');    
        $pg_videos  = $graph_response->getProperty('videos'); 
        
        $pg_cover   = $graph_response->getProperty('cover');
        $cover_output  = json_decode($pg_cover, true);
        $pg_cover_source = $cover_output['source'];

        //$fanpage_likes    = $graph_response['likes'];  
        
        $fanpage_likes   = $graph_response->getProperty('fan_count');          
        
        $relationLanguage           = $fanpage->getRelation("language");        
        $queryrelationLanguage      = $relationLanguage->getQuery();
        $results_relationlanguage   = $queryrelationLanguage->find();    
        $relang     = $results_relationlanguage[0];          
        $language   = $relang->get("Language");                 
    
        $pg_pic      = $graph_response->getProperty('picture');
        $pic_output  = json_decode($pg_pic, true);
        $pg_picture = $pic_output['url']; 
        
        $pg_about     = $graph_response->getProperty('about');
        
        //////////////////////////////
        ///  MATCH CATEGORY IMAGE  //
        ///////////////////////////// 
        
        echo '///   MATCH CATEGORY IMAGE'."\n";
        
        $relationCategory           = $fanpage->getRelation("category");        
        $queryrelationCategory      = $relationCategory->getQuery();
        $results_relationcategory   = $queryrelationCategory->find();    
        
        $countcat = count($results_relationcategory);   
        
        $relcat = $results_relationcategory[0];
        
        shuffle($array_categories);

        $countcatori = count($array_categories);

        $category_desc = "";          
               
        for ($j = 0; $j < $countcatori; $j++) 
        {
            $cat = $array_categories[$j];

            if ($relcat==$cat)
            {              
                
                $category_desc  = $cat->get("description");
                $category_cover = $cat->get("cover");

                $catimagesobj = new stdClass();
                $catimagesobj->cover            = $pg_cover_source;
                //$catimagesobj->pic            = $pg_picture;
                $catimagesobj->cat              = $cat; 
                $catimagesobj->likes            = $fanpage_likes;   
                $catimagesobj->categorydesc     = $category_desc;         
                                
                $count = count($arraydesc);
                
                // SORT REPEATED
                if (in_array($category_desc, $arraydesc)) 
                {                       
                    if ($category_cover != $pg_cover_source)                    
                    {
                       $array_catimages[$category_desc] = $catimagesobj; 
                    }
                    
                } else 
                {     
                    array_push($arraydesc, $category_desc); 
                    $array_catimages[$category_desc] = $catimagesobj;                     
                }   
                
            }
        }        

        $video_array = json_decode($pg_videos, true);

        ////////////////
        ///  LIKES   //
        ///////////////
        
        echo '///   LIKES'."\n";

        /*$likes_array = array();

        $videourl = "https://graph.facebook.com/".$funpageId."/videos?fields=source,description,likes.limit(0).summary(true)&access_token="; 
    
        $url = $videourl.$accessToken;  

        $response = get_facebook_json($url);
        $resLikes = array();
        $resLikes = json_decode($response, true);       

        foreach($resLikes as $datalikes)
        {      
            foreach($datalikes as $likes)
            {                 
                if( isset( $likes['id'] ) )
                {    
                    $video_like_id  = $likes['id'];
                    $summary        = $likes['likes']['summary'];
                    $total_count    = $summary['total_count'];
                    $likes_array[$video_like_id] = $total_count;
                    
                    echo '---   like: '.$video_like_id."\n";
                }
            }
        }*/
        
        $likes_videos = array();
        
        if (isset($pg_response->getDecodedBody()['videos']))    
        {
        
            $video_array_json = $pg_response->getDecodedBody()['videos']; //$graph_response_decode[videos];

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
        }
        
        ////////////////
        ///  VIDEOS   //
        ////////////////
        
        echo '///   VIDEOS'."\n";

        $array_videos = array();
        $array_thumbnail = array();

        foreach($video_array as $data)
        {
            $video = new stdClass();    

            //50043151918                   

            $created_time   = $data['created_time'];
            $fbdate         = $created_time['date'];  
            $date           = new DateTime($fbdate);                          
            
            $timezone       = $created_time['timezone'];

            if( isset( $data['source'] ) )
            {
                
                $source         = $data['source'];
                $length         = $data['length'];

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

                //$description = (isset($data['description']) ? $data['description'] : null);  

                if( isset( $data['description'] ) )
                {
                    $description    = $data['description'];                        
                    $video->description = $description;
                } else 
                {
                    $video->description = "No current description available.";
                }  

                $videoid        = $data['id'];                                    

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

                $video->date        = $date;
                $video->timezone    = $timezone;
                $video->source      = $source;
                $video->length      = floatval($length);

                $video->description = $description;
                $video->videoid     = $videoid;

                $video->categorydesc        = $category_desc;
                $video->language            = $language;

                $video_like_id  = $data['id'];   

                //$like = $likes_array[$video_like_id];
                //$video->likes = floatval($like); 
                
                $video_likes = $likes_videos[$videoid];
                $video->likes = $video_likes;

                array_push($array_videos, $video); 
            
                //echo '***   push video: '.$videoid."\n";  
            }
        }       
        
        //$fanpageobj->id             = floatval($pg_id);
        //$fanpageobj->pic            = $pg_picture;
        $fanpageobj->cover          = $pg_cover_source;        
        $fanpageobj->videos         = $array_videos;

        ///////////////////////
        ///  REMOVE VIDEOS   //
        ///////////////////////
        
        echo '///   REMOVE VIDEOS'."\n";
        
        $relationVideos         = $fanpage->getRelation("videos");
        $queryrelationVideos    = $relationVideos->getQuery();
        $results_relationvieos  = $queryrelationVideos->find();    
        
        $countrelationsvideo = count($results_relationvieos);
        
        for ($y = 0; $y < $countrelationsvideo; $y++) 
        {
            $relvideo = $results_relationvieos[$y];
            $relvideo->destroy();
        }
        
        ///////////////////////////
        ///  APPEND NEW VIDEOS   //
        ///////////////////////////   
        
        echo '///   APPEND NEW VIDEOS   //'."\n";

        foreach ($fanpageobj->videos as $videos_unsrl)
        {

            $pvideo = new ParseObject("Videos");    
            $pvideo->set("fromId",      $videos_unsrl->fanpageid);
            $pvideo->set("fromName",    $videos_unsrl->fanpagename);
            $pvideo->set("date",        $videos_unsrl->date);
            $pvideo->set("timezone",    $videos_unsrl->timezone);
            $pvideo->set("source",      $videos_unsrl->source);
            $pvideo->set("length",      $videos_unsrl->length);            
            
            $pvideo->set("category",    $videos_unsrl->categorydesc);
            $pvideo->set("language",    $videos_unsrl->language);            
            $pvideo->set("likes",       $videos_unsrl->likes);
            
            $pvideo->set("title",       $videos_unsrl->title); 
            
            $pvideo->set("description", $videos_unsrl->description);
            $pvideo->set("videoId",     $videos_unsrl->videoid);

            $pvideo->set("idThumbnail", $videos_unsrl->thumbnail_id);
            $pvideo->set("thumbnailHeight", $videos_unsrl->thumbnail_height);
            $pvideo->set("thumbnailHeight", $videos_unsrl->thumbnail_height);
            $pvideo->set("thumbnailWidth", $videos_unsrl->thumbnail_width);
            $pvideo->set("thumbnailUrl", $videos_unsrl->thumbnail_uri);           

            try 
            {
                $pvideo->save();                

            } catch (ParseException $ex) {  
              // Execute any logic that should take place if the save fails.
              // error is a ParseException object with an error code and message.
              echo 'Failed to create new object, with error message: ' . $ex->getMessage();
            }
            
            try 
            {
                $relationVideos->add($pvideo);               

            } catch (ParseException $ex) {  
              // Execute any logic that should take place if the save fails.
              // error is a ParseException object with an error code and message.
              echo 'Failed to create new object, with error message: ' . $ex->getMessage();
            }

            try 
            {
                $fanpage->save();            

            } catch (ParseException $ex) {  
              // Execute any logic that should take place if the save fails.
              // error is a ParseException object with an error code and message.
              echo 'Failed to create new object, with error message: ' . $ex->getMessage();
            }          
            
            echo '***  save video: '.$videos_unsrl->videoid."\n";
          
        }     
        echo '///   SAVE: '.$funpageId."\n";        
        echo "\n";
        echo "\n";
        
        //////////////////////////////
        ///  UPDATE FANPAGE DATA   ///
        ////////////////////////////// 
        
        $fanpage->set("pageCover",      $pg_cover_source);  
        $fanpage->set("pageIcon",       $pg_picture);  
        $fanpage->set("pageAbout",      $pg_about);  
        $fanpage->set("pageLikes",      $fanpage_likes);
        
        try 
        {
            $fanpage->save();   

        } catch (ParseException $ex) {  
          // Execute any logic that should take place if the save fails.
          // error is a ParseException object with an error code and message.
          echo 'Failed to create new object, with error message: ' . $ex->getMessage();
        }   

                  
    }  
    
    /////////////////////////////////////
    //  APPEND IMAGES TO CATEGORIES   //
    /////////////////////////////////////
	
    echo '///   APPEND IMAGES & LIKES TO CATEGORIES'."\n";
    
    for ($x = 0; $x < count($arraydesc); $x++) 
    {       
        
        $desccat = $arraydesc[$x];
        
        $catimagesobj = $array_catimages[$desccat];                  
              
        $catcover   = $catimagesobj->cover;  
        $likes      = $catimagesobj->likes;  
        $cat        = $catimagesobj->cat;

        $cat->set("cover", $catcover); 
        $cat->set("likes", $likes); 

        try 
        {

            $cat->save();          

        } catch (ParseException $ex) {  
            // Execute any logic that should take place if the save fails.
            // error is a ParseException object with an error code and message.
            echo 'Failed to create new object, with error message: ' . $ex->getMessage();
        }             
              
    }
    
    function convert_datetime_to_timezone($date)
    {
        $fromdate =  str_replace('+00:00', '.000Z', gmdate('c', strtotime("$date 00:00:00 ")));
        return $fromdate;
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

        $content  = curl_exec($ch);

        curl_close($ch);

        return $content;
    }     
    
    exit(0);
    
?>

