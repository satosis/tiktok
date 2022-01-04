<html>
    <head>
        <title><?php echo $username; ?> • <?php echo $description; ?> • Leuke - Short video platform</title>
        
        <meta property="og:type" content="video.other" />
         <meta property="og:url" content="https://leuke.app" /> 
        <meta property="og:title" content="<?php echo $username; ?> • <?php echo $description; ?> • Leuke - Short video platform" />
        <meta property="og:description" content="<?php echo $title; ?>"/>
        <meta property="og:image" content="<?php echo secure_url('storage/videos/'.$user_id.'/thumb/'.$thumb); ?>" />
    </head>
    <body>
       
    </body>

    <script>
       window.location='{{route('openmyapp')}}';
    </script>
</html>