var result = {
	ecs : {} ,
	rds : {} ,
	redis : {} ,
	slb : {} ,
	totalNum : 0 ,
	data : [] , 
	point : 1 , 
	startTime : 0 , 
	endTime : 0 ,
	csrf : undefined
};

$(document).ready(function(){
	$("#b_load_resource").click(function(){
		simpleGet('aliyun_ecs_v2.do' , 'ip' , function(data){for ( var key in data ){result.ecs[data[key].InstanceId]=data[key];}});
		simpleGet('aliyun_rds.do' , 'list' , function(data){data.forEach(function(val){result.rds[val.DBInstanceId]=val;result.rds[val.InsId]=val;})});
		simpleGet('aliyun_redis.do' , 'list' , function(data){data.forEach(function(val){result.redis[val.InstanceId]=val;})});
		simpleGet('aliyun_slb.do' , 'list' , function(data){data.forEach(function(val){result.slb[val.LoadBalancerId]=val;})});
	});
	$("#b_run_pre").click(function(){
		init();
		handleOrderList("/order/getOrderList.json" , 1 , result.startTime , result.endTime , {orderStatus : 'PAID'} , function(value){handleOrderDetail(value);result.point++;});
	});
	$("#b_run_post").click(function(){
		init();
		handleOrderList("/consumption/getAfterPayBillList.json" , 1 , result.startTime , result.endTime , {needZeroBill : false} , function(value){handleOrderDetailPost(value ,1);result.point++;});
	});
	$("#b_ecs_no_auto_renew").click(function(){
		handleRenewList(1);
	});
	$("#b_ecs_renew").click(function(){
		getCSRFToken();
		loopIdsFromConsole('modify');
	});
	$("#b_ecs_cancel_renew").click(function(){
		getCSRFToken();
		loopIdsFromConsole('cancel');
	});
});

function loopIdsFromConsole(operation){
	var ids = $("#textareaContent").val().split("\n");
	$("#textareaContent").val("");
	result.data = [];
	ids.forEach(function(id){
		if($.trim(id) != ''){
			$.ajax({
				async : false ,
				cache : false ,
				timeout : 5000 ,
				type : "POST" ,
				url : "https://renew.console.aliyun.com/renew/setAutoRenew.json" ,
				data : { operation : operation , duration : 1 , resourceType : 'ecs' , instIds : id , _csrf_token : result.csrf} ,
				success : function(data){
					pushItem({id : id , result : data.successResponse})
				}
			})
		}
	});
	$("#textareaContent").val(result.data.join(''));
}

function getCSRFToken(){
	if(!result.csrf){
		$.ajax({
			async : false ,
			cache : false ,
			timeout : 5000 , 
			type : "GET" ,  
			url : "https://renew.console.aliyun.com/#/ecs" ,
			data : {} ,
			success : function(data){
				result.csrf = data.match(/SEC_TOKEN\:\s\"(\w+)\"/)[1];
			}
		});	
	}
}

function handleRenewList(pageNum){
	$.ajax({
		async : true ,
		cache : false ,
		timeout : 5000 , 
		type : "GET" ,  
		url : "https://renew.console.aliyun.com/renew/getAvailbleInstances.json" ,
		data : {commodityCode : 'vm' , currentPage : pageNum , pageSize : 50 , searchType : 'instanceId'} ,
		success : function(data){
			result.totalNum = data.pageInfo.total;
			data.data.forEach(function(value){
				if(!value.autoRenewal){
					var ecsInst = result.ecs[value.instanceName] ;
					var item = {Id : value.instanceName , Ip : ecsInst.InnerIp , Status : ecsInst.Status};
					pushItem($.extend(item , ecsInst.Tags));
				}
				result.point++;
			});
			if(result.totalNum > pageNum * 50){
	                    		handleRenewList(pageNum + 1);
	                    	}else{
	                    		pushItem({});
				$("#textareaContent").val(result.data.join(''));
	                    	}
		},
		error :  function(xhr , status , error){
			handleRenewList(pageNum)
		}
	});
}

function init(){
	result.point = 1 ;
	result.startTime = Date.parse($("#st").val())-28800000 ;
	result.endTime = Date.parse($("#et").val())-28800000 ;
}

function handleOrderList(uri , pageNum , startTime , endTime , params , func){
	$.ajax({   
		async : true ,   
	              cache : false ,   
	              timeout : 5000 ,   
	              type : "GET" ,   
	              url : "https://expense.console.aliyun.com" + uri ,   
	              data : $.extend({pageNum : pageNum , pageSize : 20 , startDate : startTime , endDate : endTime , startTime : startTime , endTime : endTime} , params) , 
	              success : function(data){
	              	result.totalNum = data.pageInfo.total;
			data.data.forEach(func);
	                    	if(result.totalNum > pageNum * 20){
	                    		handleOrderList(uri , pageNum + 1 , startTime , endTime , params , func)
	                    	}else{
				$("#textareaContent").val(result.data.join(''));
	                    	}
		},
		error :  function(xhr , status , error){
			handleOrderList(uri , pageNum , startTime ,endTime , params , func);
		}
               }); 
}

function handleOrderDetailPost(value , pageNum){
	$.ajax({   
		async:false,   
		cache:false,   
		timeout:5000,   
		type:"GET",   
		url:"https://expense.console.aliyun.com/consumption/listDetailInstanceByBillRegion.json",   
		data:{billId : value.billId ,pageNum : pageNum , pageSize : 60 }, 
		success:function(data){
			if(!data.successResponse){
				handleOrderDetailPost(value , pageNum);
			}else{
				data.data.forEach(function(bill){
					if(parseFloat(bill.baseConfigMap.requirePayAmount)  !== 0){
						var item = buildItem(value.billId , "afterpay" , bill.baseConfigMap.instanceId , bill.baseConfigMap.requirePayAmount , bill.baseConfigMap.productCode);
						pushItem(item)
					}
				});
				if(pageNum < Math.ceil(data.pageInfo.total / 60)){
					handleOrderDetailPost(value , pageNum +1);
                    			}	
                    		}
		},
		error : function(xhr ,  status , error){
			handleOrderDetailPost(value , pageNum);
		}
	}); 
}

function handleOrderDetail(value){
	$.ajax({   
		async:false ,
		cache:false ,
		timeout:5000 ,
		type:"GET" ,
		url:"https://expense.console.aliyun.com/consumption/getOrderDetail.json" ,   
		data:{orderId : value.orderId} , 
		success:function(data){
			data.data.orderLineList.forEach(function(orderLine){
				if(typeof orderLine.productPurchases === 'undefined'){
					var item = buildItem(value.orderId, value.orderType, orderLine.instanceId, orderLine.originalAmount, orderLine.commodityCode);
					pushItem(item);
				}else{
					orderLine.productPurchases.forEach(function(purchase){
						var item = buildItem(value.orderId, value.orderType, purchase.instanceId, orderLine.tradeAmount/orderLine.quantity, orderLine.commodityCode);
						pushItem(item);
					});	
				}
			});
                    	},
                    	error : function(xhr ,  status , error){
                    		handleOrderDetail(value);
                    	}
               }); 
}

function simpleGet(uri , method , func){
	$.ajax({   
		async : false ,   
		cache : false ,   
		timeout : 5000 ,   
		type : "GET",   
		url : "http://123.57.174.19:81/" + uri ,   
		data : {method : method} , 
		success : func ,
                    	error :  function(xhr,  status, error){
 	                   	simpleGet(uri , method , func);
                 	}
               }); 
}

function buildItem(orderId , orderType , instanceId , price , type){
	var item = {orderId : orderId , orderType : orderType , instanceId : instanceId , price : price , type : type , team : '-'};
	if(typeof item.type === 'undefined' ){
		item.type = '-'
	}else if(item.type === 'rds' || item.type === 'rords'){
		if(result.rds[instanceId])
			item.team = result.rds[instanceId].DBInstanceDescription.substring(0,result.rds[instanceId].DBInstanceDescription.indexOf("_"));	
	}else if(item.type === 'prepaid_kvstore' || item.type === 'kvstore'){
		if(result.redis[instanceId])
			item.team = result.redis[instanceId].InstanceName.substring(0,result.redis[instanceId].InstanceName.indexOf("_"))
	}else if(item.type === 'vm' || item.type === 'ecs'){
		if(result.ecs[instanceId])
			item.team = result.ecs[instanceId].Tags.Team;
	}else if(item.type === 'slb'){
		if(result.slb[instanceId])
			item.team = result.slb[instanceId].LoadBalancerName.substring(0,result.slb[instanceId].LoadBalancerName.indexOf("_"));	
	}
	return item;
}

function pushItem(item){
	var log = [];
	for(t_item_log in item){ 
		log.push(item[t_item_log]);
	}
	$("#progress").val(result.point + "/" + result.totalNum);
	result.data.push(log.join(',')+"\n"); 
}