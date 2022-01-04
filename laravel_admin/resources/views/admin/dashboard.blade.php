@extends('layouts.admin')
@section('content')
<?php $graph=array();
        foreach($d_arr as $k => $v){ 
          $graph[]='{
            "month": "'.$k.'",
            "value": '.$v.'
          }';
        }  ?>
<script>
  $(document).ready(function() {
  
  // seo ecommerce start
  $(function() {
  
    var chart = AmCharts.makeChart("r-barchart", {
      "type": "serial",
      "theme": "light",
      "marginTop": 0,
      "marginRight": 0,
      "dataProvider": [<?php echo implode(', ',$graph); ?>],
        "valueAxes": [{
          "axisAlpha": 0,
                 "gridAlpha": 0,
                "dashLength": 6,
                "position": "left"
              }],
              "graphs": [{
                "id": "g1",
                "balloonText": "[[category]]<br><b><span style='font-size:14px;'>[[value]]</span></b>",
                "bullet": "round",
                "bulletSize": 8,
                 "fillAlphas": 0.1,
                "lineColor": "#448aff",
                "lineThickness": 2,
                "negativeLineColor": "#ff5252",
                "type": "smoothedLine",
                "valueField": "value"
              }],
              "chartScrollbar": {
                "graph": "g1",
                "gridAlpha": 0,
                "color": "#888888",
                "scrollbarHeight": 55,
                "backgroundAlpha": 0,
                "selectedBackgroundAlpha": 0.1,
                "selectedBackgroundColor": "#888888",
                "graphFillAlpha": 0,
                "autoGridCount": true,
                "selectedGraphFillAlpha": 0,
                "graphLineAlpha": 0.2,
                "graphLineColor": "#c2c2c2",
                "selectedGraphLineColor": "#888888",
                "selectedGraphLineAlpha": 1
              },
              "chartCursor": {
                "categoryBalloonDateFormat": "YYYY-MM",
                "cursorAlpha": 0,
                "valueLineEnabled": true,
                "valueLineBalloonEnabled": true,
                "valueLineAlpha": 0.5,
                "fullWidth": true
              },
               "dataDateFormat": "YYYY-MM",
              "categoryField": "month",
              "categoryAxis": {
                "minPeriod": "YYYY-MM",
                "gridAlpha": 0,
                "parseDates": false,
              },
            });
    chart.zoomToIndexes(Math.round(chart.dataProvider.length * 0.1), Math.round(chart.dataProvider.length * 1));
  });
    // seo ecommerce end
  });
</script>
<section>
	<div class="container-fluid">
		<div class="row">
			<div class="col-lg-4 ">
				<a href="{{ route('admin.candidates.show',[1]) }}">
					<div class="card revenue">                   				
						<div>
							<h6>Total Users</h6>
							<h2>{{$total_active_candidates}}</h2>
							<p>Active</p>
							<i class="fa fa-users" aria-hidden="true"></i>
						</div>                   					
					</div> 
				</a>                  				
			</div>
		
			<div class="col-lg-4">
				<a href="{{ url('videos') }}">
					<div class="card orders">                   				
						<div>
							<h6>Total Videos</h6>
							<h2>{{$total_active_videos}}</h2>
								<p>Active</p>
							<i class="fa fa-video-camera" aria-hidden="true"></i>
						</div>                   					
					</div>  
				</a>                 				
			</div>
		
			<div class="col-lg-4">
				<a href="{{ url('sounds')}}">
					<div class="card sales">                   				
						<div>
							<h6>Total Sounds</h6>
							<h2>{{$total_sounds}}</h2>
								<p>Active</p>
							<i class="fa fa-music" aria-hidden="true"></i>
						</div>                   					
					</div> 
				</a> 		
			</div>
		</div>
	</div>
</section>

<div class="clearfix"></div>
<br>

<section>
	<div class="container-fluid">
		<div class="row">
			<div class="col-lg-12">
				<div class="card table-card">
					<div class="card-header borderless ">
						<h3>Registration Analytics</h3> 
					</div>
					<div class="card-body">
						<div id="r-barchart" style="height: 375px"></div>
					</div>
				</div>
			</div>
		</div>
	</div>
</section>
<section>
	<div class="container-fluid">
		<div class="row">
			<div class="col-lg-12">
				<div class="card table-card">
                  	<div class="card-header borderless ">
                        <h3>Active Candidates</h3> 
                    </div>
                  	<div class="card-body table-responsive">
						<table class="table table-striped table-main">
						    <thead>
						      <tr>
                           <th>Username</th>
                           <th>First Name</th>
                           <th>Last Name</th>
                           <th>Gender</th>
                           <th>Country</th>
                           <th>Added Date</th> 
						      </tr>
						    </thead>
						    <tbody>
							<?php if($total_active_candidates > 0){
							foreach($active_candidates as $candidate){ ?>
                                <tr>
                                    <td>                                                      
                                       <div class="d-inline-block align-middle">
                                          <?php if($candidate->user_dp ==""){ ?>
                                             <img src="{{ asset('assets/images/profile.png') }}" alt="user image" class="img-radius img-40 align-top m-r-15">
                                          <?php }elseif(stripos($candidate->user_dp,'https://')!==false){ ?>
                                             <img src="<?php echo $candidate->user_dp; ?>" alt="user image" class="img-radius img-40 align-top m-r-15">
                                          <?php }else{ ?>
                                             <img src="<?php echo url(config('app.profile_path')).'/'.$candidate->user_id.'/'.$candidate->user_dp; ?>" alt="user image" class="img-radius img-40 align-top m-r-15">
                                          <?php } ?>
                                          <div class="d-inline-block">
                                             <h6><?php echo $candidate->fname." ".$candidate->lname; ?></h6>
                                             <p class="text-muted m-b-0"><?php echo $candidate->email; ?></p>
                                          </div>
                                       </div>
                                    </td>
                                    <td><?php echo $candidate->fname; ?></td>
                                    <td><?php echo $candidate->lname; ?></td>
                                    <td><?php if($candidate->gender=='f'){ echo 'Female'; }elseif($candidate->gender=='m'){ echo "Male"; }else{ echo "Others"; }; ?></td>
                                    <td><?php echo $candidate->country; ?></td>
                                    <td><?php echo date('d F Y',strtotime($candidate->created_at)); ?></td>
                                </tr>
								 <?php } 
								 }else{?>
								<tr>
									<td colspan="6" class="text-center">No Record ...</td>
								</tr>
								 <?php } ?>
						    </tbody>
						</table>
					</div>					
				</div>					
			</div>
				
			<div class="col-lg-12">
				<div class="card table-card">
                  	<div class="card-header borderless ">
                        <h3>Inactive Candidates</h3> 
                    </div>
                  	<div class="card-body table-responsive">
						<table class="table table-striped table-main">
						    <thead>
						      <tr>
                           <th>Username</th>
                           <th>First Name</th>
                           <th>Last Name</th>
                           <th>Gender</th>
                           <th>Country</th>
                           <th>Added Date</th> 
						      </tr>
						    </thead>
						    <tbody>
								<?php if($total_pending_candidates > 0){
								foreach($pending_candidates as $candidate){ ?>
                                 <tr>
                                    <td>                                                      
                                       <div class="d-inline-block align-middle">
                                          <?php if($candidate->user_dp ==""){ ?>
                                             <img src="{{ asset('assets/images/profile.png') }}" alt="user image" class="img-radius img-40 align-top m-r-15">
                                          <?php }elseif(stripos($candidate->user_dp,'https://')!==false){ ?>
                                             <img src="<?php echo $candidate->user_dp; ?>" alt="user image" class="img-radius img-40 align-top m-r-15">
                                          <?php }else{ ?>
                                             <img src="<?php echo url(config('app.profile_path')).'/'.$candidate->user_id.'/'.$candidate->user_dp; ?>" alt="user image" class="img-radius img-40 align-top m-r-15">
                                          <?php } ?>
                                          <div class="d-inline-block">
                                             <h6><?php echo $candidate->fname." ".$candidate->lname; ?></h6>
                                             <p class="text-muted m-b-0"><?php echo $candidate->email; ?></p>
                                          </div>
                                       </div>
                                    </td>
                                    <td><?php echo $candidate->fname; ?></td>
                                    <td><?php echo $candidate->lname; ?></td>
                                    <td><?php if($candidate->gender=='f'){ echo 'Female'; }elseif($candidate->gender=='m'){ echo "Male"; }else{ echo "Others"; }; ?></td>
                                    <td><?php echo $candidate->country; ?></td>
                                    <td><?php echo date('d F Y',strtotime($candidate->created_at)); ?></td>
                                 </tr>
								 <?php } 
								 }else{?>
									<tr>
										<td colspan="6" class="text-center">No Record ...</td>
									</tr>
								 <?php }?>
						    </tbody>
						</table>
					</div>					
				</div>					
			</div>
		</div>
	</div>
</section>
			
</div>
</div>
</div>
</div>
</section>
@endsection		
		
	