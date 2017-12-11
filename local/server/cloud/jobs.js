
// --
// Download Youtube Video and save it. 

/*
* Simple Cloud Code Example
*/

Parse.Cloud.job("downloader", function(request, status) {
  
  // the params passed through the start request
  const params = request.params;
  // Headers from the request that triggered the job
  const headers = request.headers;

  // get the parse-server logger
  const log = request.log;

  // Update the Job status message
  status.message("I just started");

  downloadVideo(request, status);

  //.then(function(result) {
    // Mark the job as successful
    // success and error only support string as parameters
    //status.success("I just finished");
  //})
  //.catch(function(error) {
    // Mark the job as errored
    //status.error("There was an error");
  //
  //});

});

function downloadVideo(request, status){

  var path = require('path');
  var s3 = require('s3');

  var s3bucket = "gamves-deployments-mobilehub-352107381";
  var s3key = "AKIAJP4GPKX77DMBF5AQ";
  var s3secret = "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";
  var s3region = "us-east-1"; 
  var s3endpoint = s3bucket  + ".s3.amazonaws.com";

  var client = s3.createClient({
    maxAsyncS3: 20,     // this is the default
    s3RetryCount: 3,    // this is the default
    s3RetryDelay: 1000, // this is the default
    multipartUploadThreshold: 20971520, // this is the default (20 MB)
    multipartUploadSize: 15728640, // this is the default (15 MB)
    s3Options: {
      accessKeyId: s3key,
      secretAccessKey: s3secret,
      region: s3region,
      //endpoint: s3endpoint,
      // sslEnabled: false
      // any other options are passed to new AWS.S3()
      // See: http://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/Config.html#constructor-property
    },
  });

    var ytb_videoId = request.params.ytb_videoId;
    var objectId = request.params.objectId;

    var queryVideos = new Parse.Query("Videos");
    queryVideos.equalTo("objectId", objectId);
   
    queryVideos.find({
        useMasterKey: true,
        success: function(results) {

          if( results.length > 0) 
          {

              var videoObject = results[0];

              var fs = require('fs');
              var youtubedl = require('youtube-dl');
              var video = youtubedl('http://www.youtube.com/watch?v='+ytb_videoId,
                // Optional arguments passed to youtube-dl.
                ['--format=18'],
                // Additional options can be given for calling `child_process.execFile()`.
                { cwd: __dirname });
               
              // Will be called when the download starts.
              //video.on('info', function(info) {
              //  console.log('Download started');
              //  console.log('filename: ' + info.filename);
              //  console.log('size: ' + info.size);
              //});
                
              var videoName = ytb_videoId + '.mp4';

              video.pipe(fs.createWriteStream(videoName));

              video.on('end', function() {
                
                console.log('finished downloading!');

                var params = {
                  localFile: videoName,
                  s3Params: {
                    Bucket: s3bucket,
                    Key: videoName,
                    // other options supported by putObject, except Body and ContentLength.
                    // See: http://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/S3.html#putObject-property
                  },
                };

                var uploader = client.uploadFile(params);
                uploader.on('error', function(err) {
                  console.error("unable to upload:", err.stack);
                });
                uploader.on('progress', function() {
                  console.log("progress", uploader.progressMd5Amount,
                            uploader.progressAmount, uploader.progressTotal);
                });
                uploader.on('end', function() {
                  console.log("done uploading");


                    var ytb_thumbnail_source = videoObject.get("ytb_thumbnail_source");

                    Parse.Cloud.httpRequest({url: ytb_thumbnail_source}).then(function(httpResponse) {
                        
                         var imageBuffer = httpResponse.buffer;
                         var base64 = imageBuffer.toString("base64");
                         var file = new Parse.File(ytb_videoId+".jpg", { base64: base64 });
                    
                         var baseUrl = s3.getPublicUrlHttp(s3bucket, s3key);
                         var uploadedUrl = baseUrl + "/" + videoName;        
                         
                         videoObject.set("thumbnail", file);
                         videoObject.set("s3_source", uploadedUrl);
                         videoObject.set("downloaded", true);

                         videoObject.save(null, { useMasterKey: true } );

                         status.success(uploadedUrl);     
                        
                    }, function(error) {
                        
                        status.error("Error downloading thumbnail"); 

                    });                  

                });

              });            
          }
        }
    });     
}