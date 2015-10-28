var result = { data : [] , runner : 1 , t_runner : 1, pageSize : 10, index : 1 ,endpoint : 1000000000 };
$(document).ready(function(){
	$("#startpoint").val(result.runner);
	$("#b_reset").click(function(){
		result = { data : [] , runner : 1 , t_runner : 1, pageSize : 10, index :1 ,endpoint : 1000000000 };
		$("#startpoint").val(1);
		$("#endpoint").val(0);
		$("#progress").val("0/0");
		$("#textareaContent").val("");
	});
	$("#b_run").click(function(){
		result.t_runner = (result.index-1) * result.pageSize +1 ;
		result.runner = $("#startpoint").val();
		result.endpoint = $("#endpoint").val();
		var st =	Date.parse($("#st").val()) , et = Date.parse($("#et").val());
		handleOrderList(result.index, st , et, true);
	});
	$("#b_collect_ecs").click(function(){
		result.index=1;
		collectECS(1);
	});
	$("#b_collect_rds").click(function(){
                    	result.index=1;		
		collectRDS(1);
	});
	$("#b_collect_kv").click(function(){
		result.index=1;
		collectKV(1);
	});
});

function collectRDS(pageNum){
	$.ajax({   
                    async : true ,   
                    cache : false,   
                    timeout : 5000,   
                    type : "GET",   
                    url : "https://rdsnew.console.aliyun.com/instance/describeDBInstanceList.json",   
                    data : {pageNumber : pageNum , pageSize : result.pageSize , region : "all" }, 
                    success : function(data){
                    	if(pageNum === 1){
                    		result['totalnum'] = data.data.TotalRecordCount;
                    	}
                    	data.data.Items.DBInstance.forEach(function(value){
			progress(result.runner++ + "," + value.RegionId + ",RDS," + value.InsId + ","+ value.DBInstanceDescription.substring(0,value.DBInstanceDescription.indexOf("_"))+ "\n");
                    	});
		if( ++result.index<result.totalnum/result.pageSize+1 ){
			collectRDS(pageNum+1);
                    	}
                    },
                    error :  function( jqXHR,  textStatus, errorThrown){
                    	collectRDS(pageNum);
                    }
               }); 
}

function collectKV(pageNum){
	$.ajax({   
                    async : true ,   
                    cache : false,   
                    timeout : 5000,   
                    type : "GET",   
                    url : "https://kvstore.console.aliyun.com/instance/describeInstances.json",   
                    data : {pageNumber : pageNum , pageSize : result.pageSize }, 
                    success : function(data){
                    	if(pageNum === 1){
                    		result['totalnum'] = data.data.TotalCount;
                    	}
                    	data.data.Instances.KVStoreInstance.forEach(function(value){
			progress(result.runner++ + "," + value.RegionId + ",KV," + value.InstanceId+ ","+ value.InstanceName.substring(0,value.InstanceName.indexOf("_"))+ "\n");
                    	});
		if( ++result.index<result.totalnum/result.pageSize+1 ){
			collectKV(pageNum+1);
                    	}
                    },
                    error :  function( jqXHR,  textStatus, errorThrown){
                    	collectKV(pageNum);
                    }
               }); 	
}

function collectECS(regionIndex , pageNum){
	var regionlist = [ "ap-southeast-1","cn-shenzhen","cn-qingdao","cn-beijing","cn-shanghai","cn-hongkong","cn-hangzhou","us-west-1"];
	if(regionIndex +1 >= regionlist.length){
		return ;
	}
	$.ajax({   
                    async : true ,   
                    cache : false,   
                    timeout : 5000,   
                    type : "GET",   
                    url : "https://ecs.console.aliyun.com/instance/instance/list.json",   
                    data : {pageNumber : pageNum , pageSize : result.pageSize , regionId : regionlist[regionIndex] }, 
                    success : function(data){
                    	if(pageNum === 1){
                    		result['totalnum'] = data.data.TotalCount;
                    	}
                    	data.data.Instances.Instance.forEach(function(value){
			progress(result.runner++ + "," + value.RegionId + ",ECS," + value.InstanceId+ "," + value.Tags.Tag[0].TagValue+"\n");
                    	});
		if( ++result.index<result.totalnum/result.pageSize+1 ){
			collectECS(regionIndex,pageNum+1);
                    	}else{
                    		result.index=1;
                    		collectECS(regionIndex+1,1);
                    	}
                    },
                    error :  function( jqXHR,  textStatus, errorThrown){
                    	collectECS(regionIndex,pageNum);
                    }
               }); 	
}

function handleOrderList(pageNum, startTime, endTime, isFirst){
	$.ajax({   
                    async : true ,   
                    cache : false,   
                    timeout : 5000,   
                    type : "GET",   
                    url : "https://expense.console.aliyun.com/order/getOrderList.json",   
                    data : {pageNum : pageNum , pageSize : result.pageSize , startDate : startTime , endDate : endTime }, 
                    success : function(data){
                    	if(isFirst){
                    		result['totalnum'] = data.pageInfo.total;
                    	}
                    	data.data.forEach(function(value){
			if(result.runner > result.t_runner++ || result.t_runner>=result.endpoint ){
				return;
			}
			handleOrderDetail(value,0);
			result.runner++;
                    	});
		if( ++result.index<result.totalnum/result.pageSize+1 ){
			handleOrderList(pageNum+1,startTime,endTime,false);	
                    	}
                    },
                    error :  function( jqXHR,  textStatus, errorThrown){
                    	handleOrderList(pageNum , startTime ,endTime ,isFirst);
                    }
               }); 
}

function handleOrderDetail(value , jump){
	$.ajax({   
                    async:false,   
                    cache:false,   
                    timeout:5000,   
                    type:"GET",   
                    url:"https://expense.console.aliyun.com/consumption/getOrderDetail.json",   
                    data:{orderId : value.orderId }, 
                    success:function(data){
                    	var instanceId , type, region,team;
                    	var item = buildItem(value);
                    	if(data.data.orderStatus === "PAID"){
                    		if( typeof data.data.orderLineList[0] === 'undefined' ){
				instanceId = undefined ;
				type = "unknown";
				region=undefined;
			}else{
				item['price'] = data.data.orderLineList[0].unitAmount;
				if(typeof data.data.orderLineList[0].instanceId === "undefined"){
					if(data.data.orderLineList[0].productPurchases.length > jump + 1){
						handleOrderDetail( value , jump + 1 );
					}
					instanceId = data.data.orderLineList[0].productPurchases[jump].instanceId;
				}else{
					instanceId = data.data.orderLineList[0].instanceId;
				}
				type = data.data.orderLineList[0].commodityCode;
				if (typeof data.data.orderLineList[0].instanceComponents === "undefined"){
					region = undefined;
				}else{
					data.data.orderLineList[0].instanceComponents.forEach(function(vd){
						if(vd.componentName ==="可用区"){
							region = vd.properties[0].value;
							region = region.substring(0,region.lastIndexOf("-"));
						}
					});
				}
				if(type === "rds" && typeof data.data.orderLineList[0].instanceIds[jump] !== "undefined"){
					team=data.data.orderLineList[0].instanceIds[jump].substring(0,data.data.orderLineList[0].instanceIds[jump].indexOf('_'));
				}
			}
		}else{
			instanceId = undefined;
			type = data.data.orderStatus;
		}
		item['instanceId'] = instanceId;
		item['type'] = type;
		item['region'] = region;
		if(type === "rds"){
			item['teamtag'] = team;
		}else{
			handleInstance(item);	
		}
		result['data'].push(item);
		var t_log = [];
		for(t_item_log in item){ 
			t_log.push(item[t_item_log]);
		}
		progress(t_log.join(',')+"\n");
                    },
                    error : function( jqXHR,  textStatus, errorThrown){
                    	handleOrderDetail(value,jump);
                    }
               }); 
}

function handleInstance(item){
	if(typeof item.instanceId === 'undefined' || typeof item.region === "undefined"){
		item['team'] = "Other-" + item.type;
		return ;
	}	
	var teamtag ;
	$.ajax({   
                    async:false,   
                    cache:false,   
                    timeout:5000,   
                    type:"GET",   
                    url:"https://ecs.console.aliyun.com/instance/instance/list.json",   
                    data:{instanceIds : item.instanceId , regionId : item.region }, 
                    success:function(data){   
		if( typeof data.data.Instances.Instance[0] === 'undefined' ){
			teamtag = "Other-" + item.type;
		}else{
			teamtag = data.data.Instances.Instance[0].Tags.Tag[0].TagValue;		
		} 
                    } ,
                    error : function( jqXHR,  textStatus, errorThrown){
                    	handleInstance(item);
                    }  
               }); 
	item['team'] = teamtag;
}

function buildItem(value){
	var t_item = {} ;
	t_item['index'] = result.runner;
	t_item['orderId'] = value.orderId;
	t_item['orderType'] = value.orderType;
	return t_item;
}

function progress(log){
	$("#progress").val(result.runner + "/" + result.totalnum);
	$("#textareaContent").val($("#textareaContent").val()+log);
	$("#startpoint").val(result.runner);
}