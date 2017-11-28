<?php
 
/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
 
    session_start();
 
    require_once __DIR__ . '/vendor/autoload.php';
 
 
    $facebookAppId = '278298429287067';
    $facebookAppSecret = 'd9271cb326392fe24daacf800d997017';
     
    $fb = new Facebook\Facebook([
      'app_id' => $facebookAppId,
      'app_secret' => $facebookAppSecret,
      'default_graph_version' => 'v2.9',
    ]);
 
    $helper = $fb->getRedirectLoginHelper();
     
    $loginUrl = $helper->getLoginUrl('http://localhost/gamvesbackend/index_callback.php');
 
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
     
    echo '<br>';
    echo '<div class="demo-card-wide mdl-card mdl-shadow--2dp" style="width: 97%; margin: 0 auto; padding: 20px; margin-bottom: 6px;">';
    echo '<img src="https://f983810c0515b678821cca2327fde7ea08fa71ca-www.googledrive.com/host/0B1r2LBJZZYW0M2NiaGgwZUlEMUU" style="margin: 0px auto; width: 450px;"></img>';
    echo '<a class="mdl-button mdl-js-button mdl-button--raised mdl-button--colored" style="margin-bottom: 20px;" href="' . htmlspecialchars($loginUrl) . '">Log in with Facebook</a>';
    echo '<style type="text/css">
    .demo-card-wide {
        background: url(\'https://cd910e88fb747075d550b72ec6f031157d041d48-www.googledrive.com/host/0B1r2LBJZZYW0NVpFbWlaN2U5TEE\') center / cover;
    }
    </style>';
    echo "</head>\n";
    echo "</html>\n";
     
?>
