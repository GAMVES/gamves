<?php

/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */


require_once __DIR__ . '/vendor/autoload.php';

// Pull access token from the file/db
$access_token = "access token from file or db";
$facebook->setAccessToken($access_token); // sets our access token as the access token when we call something using the SDK, which we are going to do now.

$config = array('appId' => 'xxx','secret' => 'xxx');

$params = array('scope'=>'user_likes,publish_actions,email,publish_stream,manage_pages');
$facebook = new Facebook($config);
$user = $facebook->getUser();
if($facebook->getUser()) {
    try {

        $user_profile = $facebook->api('/me');
    } catch(FacebookApiException $e) {
        $login_url = $facebook->getLoginUrl($params);
        error_log($e->getType());
        error_log($e->getMessage());
    }   
}
else {
    $login_url = $facebook->getLoginUrl($params);
}    

$page_id = "xxxxxxxxxxxxx";
$page_access_token = "";
$result = $facebook->api("/me/accounts");
foreach($result["data"] as $page) {
    if($page["id"] == $page_id) {
        $page_access_token = $page["access_token"];
        //echo '<br>';
        //echo "2. ".$page_access_token;
        break;
    }
}

$args = array(
    'access_token'  => $page_access_token,
    'message'       => stripslashes($image_caption).$animaged_gif,
    'name' => stripslashes($image_caption).$animaged_gif,
    'link' => "http://www.xxx.com/images.php?i=".$image_name,
    'picture' => "http://www.xxx.com/thumbnails/".$image_name.".png",
    'actions' => array(
            'name' => 'See Pic',
             'link' => "http://www.xxx.com/images.php?i=".$image_name
    )
);
$post = $facebook->api("/$page_id/feed","post",$args);
?>