<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <title>Laravel</title>

        <!-- Fonts -->
        <link href="https://fonts.googleapis.com/css?family=Nunito:200,600" rel="stylesheet">

        <!-- Styles -->
        <style>
            html, body {
                background-color: #fff;
                color: #636b6f;
                font-family: 'Nunito', sans-serif;
                font-weight: 200;
                height: 100vh;
                margin: 0;
                font-family: "Helvetica Neue",Helvetica,Arial,sans-serif;
                line-height: 1.42857143;
            }

            .full-height {
                height: 100vh;
            }

            .flex-center {
                align-items: center;
                display: flex;
                justify-content: center;
            }

            .position-ref {
                position: relative;
            }

            .top-right {
                position: absolute;
                right: 10px;
                top: 18px;
            }

            .content {
                text-align: center;
            }

            .title {
                font-size: 84px;
            }

            .links > a {
                color: #636b6f;
                padding: 0 25px;
                font-size: 13px;
                font-weight: 600;
                letter-spacing: .1rem;
                text-decoration: none;
                text-transform: uppercase;
            }

            .m-b-md {
                margin-bottom: 30px;
            }
            .website-link a {
                background-image: linear-gradient(to bottom right, #ec4a63, #7350c7);
                padding: 15px 50px;
                font-size: 23px;
                color: #fff;
                border-radius: 10px;
                margin: 150px !important;
                text-decoration:none;
            }
        </style>
    </head>
    <body style="background:#2e2f34">
        <div class="flex-center position-ref full-height">
            <div class="content">
                <div class="title m-b-md">
                    <img src="{{ asset('assets/logo-n.png') }}">
                </div>

                <div class="links">
                    <div class="website-link">
                        <a href="https://leuke.app/">Visit Our Main Website</a>
                    </div>
                </div>
            </div>
        </div>
    </body>
</html>
