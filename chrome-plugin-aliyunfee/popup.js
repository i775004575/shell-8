var result = { data : [] , runner : 1 , t_runner : 1, pageSize : 20, index : 1 ,endpoint : 1000000000 , rds : {} , ecs : {} , kvstore : {} , slb: {} };
$(document).ready(function(){
	$("#startpoint").val(result.runner);
	$("#b_reset").click(function(){
		result = { data : [] , runner : 1 , t_runner : 1, pageSize : 10, index :1 ,endpoint : 1000000000 };
		$("#startpoint").val(1);
		$("#endpoint").val(0);
		$("#progress").val("0/0");
		$("#textareaContent").val("");
	});
	$("#b_run_pre").click(function(){
		collectRDS(1);
		collectKV(1);
		collectECS(0,1);
		result.t_runner = (result.index-1) * result.pageSize +1;
		result.runner = $("#startpoint").val();
		result.endpoint = $("#endpoint").val();
		var st =	Date.parse($("#st").val())-28800000 , et = Date.parse($("#et").val())-28800000;
		handleOrderList(result.index, st , et, true);
	});
	$("#b_run_after").click(function(){
		collectRDS(1);
		collectKV(1);
		collectECS(0,1);
		collectSLB();
		result.t_runner = (result.index-1) * result.pageSize +1;
		result.runner = $("#startpoint").val();
		result.endpoint = $("#endpoint").val();
		var st =	Date.parse($("#st").val())-28800000 , et = Date.parse($("#et").val())-28800000;
		handleOrderList4AfterPay(result.index, st , et);
	});
});

function handleOrderList4AfterPay(pageNum, startTime, endTime){
	$.ajax({   
                    async : true ,   
                    cache : false,   
                    timeout : 5000,   
                    type : "GET",   
                    url : "https://expense.console.aliyun.com/consumption/getAfterPayBillList.json",   
                    data : {pageNum : pageNum , pageSize : result.pageSize , startTime : startTime , endTime : endTime , needZeroBill : false , payStatus : "PAY_FINISH" }, 
                    success : function(data){
                    	result['totalnum'] = data.pageInfo.total;
                    	data.data.forEach(function(value){
			if(result.runner > result.t_runner++ || result.t_runner>=result.endpoint ){
				return;
			}
			handleOrderDetail4AfterPay(value,1);
			result.runner++;
                    	});
		if(result.index++<Math.ceil(result.totalnum/result.pageSize) ){
			handleOrderList4AfterPay(pageNum+1,startTime,endTime);	
                    	}
                    },
                    error :  function( jqXHR,  textStatus, errorThrown){
                    	handleOrderList4AfterPay(pageNum , startTime ,endTime);
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
                    data : {pageNum : pageNum , pageSize : result.pageSize , startDate : startTime , endDate : endTime , orderStatus : 'PAID' }, 
                    success : function(data){
                    	if(isFirst){
                    		result['totalnum'] = data.pageInfo.total;
                    	}
                    	data.data.forEach(function(value){
			if(result.runner > result.t_runner++ || result.t_runner>=result.endpoint ){
				return;
			}
			handleOrderDetail(value);
			result.runner++;
                    	});
		if(++result.index<result.totalnum/result.pageSize+1 ){
			handleOrderList(pageNum+1,startTime,endTime,false);	
                    	}
                    },
                    error :  function( jqXHR,  textStatus, errorThrown){
                    	handleOrderList(pageNum , startTime ,endTime ,isFirst);
                    }
               }); 
}

function handleOrderDetail4AfterPay(value,pageNum){
	$.ajax({   
                    async:false,   
                    cache:false,   
                    timeout:5000,   
                    type:"GET",   
                    url:"https://expense.console.aliyun.com/consumption/listDetailInstanceByBillRegion.json",   
                    data:{billId : value.billId ,pageNum : pageNum , pageSize : result.pageSize * 3 }, 
                    success:function(data){
		data.data.forEach(function(bill){
			if(parseFloat(bill.baseConfigMap.requirePayAmount)  !== 0){
				var item = buildItem(value.billId, "afterpay", bill.baseConfigMap.instanceId, bill.baseConfigMap.requirePayAmount, bill.baseConfigMap.productCode);
				handleRegion(item);
				handleTeam(item);
				serialize(item);
			}
		});
		if( pageNum < Math.ceil(data.pageInfo.total/(result.pageSize*3))){
			handleOrderDetail4AfterPay(value,pageNum+1);
                    	}
                    },
                    error : function( jqXHR,  textStatus, errorThrown){
                    	handleOrderDetail4AfterPay(value,pageNum);
                    }
               }); 
}

function handleOrderDetail(value){
	$.ajax({   
                    async:false,   
                    cache:false,   
                    timeout:5000,   
                    type:"GET",   
                    url:"https://expense.console.aliyun.com/consumption/getOrderDetail.json",   
                    data:{orderId : value.orderId }, 
                    success:function(data){
		data.data.orderLineList.forEach(function(orderLine){
			if(typeof orderLine.productPurchases !== 'undefined'){
				orderLine.productPurchases.forEach(function(purchase){
					var item = buildItem(value.orderId, value.orderType, purchase.instanceId, orderLine.tradeAmount/orderLine.quantity, orderLine.commodityCode);
					handleRegion(item,orderLine.instanceComponents);
					handleTeam(item);
					serialize(item);
				});
			}else{
				var item = buildItem(value.orderId, value.orderType, orderLine.instanceId, orderLine.originalAmount, orderLine.commodityCode);
				handleRegion(item,orderLine.instanceComponents);
				handleTeam(item);
				serialize(item);
			}
		});
                    },
                    error : function( jqXHR,  textStatus, errorThrown){
                    	handleOrderDetail(value);
                    }
               }); 
}

function handleRegion(item,instanceComponents){
	if(typeof instanceComponents !== 'undefined'){
		instanceComponents.forEach(function(temp){
			if(temp.componentName === '可用区'){
				item['region'] = temp.properties[0].value.substring(0,temp.properties[0].value.lastIndexOf("-"));
			}
		});
	}
	if(typeof item.region === 'undefined'){
		item['region'] = "unknown";
	}
}

function handleTeam(item){
	if(typeof item.team !== 'undefined'){
		return ;
	}
	if(typeof item.type === 'undefined' ){
		item['team'] = "Other-unknown";
		return ;
	}
	if(typeof item.instanceId === 'undefined' || typeof item.region === 'undefined' ){
		item['team'] = "Other-" + item.type;
		return ;
	}
	if(item.type === 'rds' || item.type === 'rords'){
		item['team'] = result.rds[item.instanceId];
	}else if(item.type === 'prepaid_kvstore'){
		item['team']= result.kvstore[item.instanceId];
	}else if(item.type === 'slb'){
		item['team']= result.slb[item.instanceId];
	}else{
		item['team']= result.ecs[item.instanceId];
	}
	if(typeof item.team === 'undefined'){
		item['team'] = "Other-" + item.type;
	}
}

function buildItem(orderId,orderType,instanceId,price,type){
	var t_item = {} ;
	t_item['index'] = result.runner;
	t_item['orderId'] = orderId;
	t_item['orderType'] = orderType;
	t_item['price'] =price;
	t_item['instanceId'] = instanceId;
	t_item['type'] = type;
	return t_item;
}

function serialize(item){
	var t_log = [];
	for(t_item_log in item){ 
		t_log.push(item[t_item_log]);
	}
	progress(t_log.join(',')+"\n");
}

function progress(log){
	$("#progress").val(result.runner + "/" + result.totalnum);
	$("#textareaContent").val($("#textareaContent").val()+log);
	$("#startpoint").val(result.runner);
}

function collectKV(pageNum){
	var totalnum ;
	$.ajax({   
                    async : false ,   
                    cache : false,   
                    timeout : 5000,   
                    type : "GET",   
                    url : "https://kvstore.console.aliyun.com/instance/describeInstances.json",   
                    data : {pageNumber : pageNum , pageSize : result.pageSize }, 
                    success : function(data){
                    	totalnum = data.data.TotalCount;
                    	data.data.Instances.KVStoreInstance.forEach(function(value){
                    		result.kvstore[value.InstanceId] = value.InstanceName.substring(0,value.InstanceName.indexOf("_")) ;
                    	});
		if( pageNum < Math.ceil(totalnum/result.pageSize) ){
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
	var totalnum ;
	$.ajax({   
                    async : false ,   
                    cache : false,   
                    timeout : 5000,   
                    type : "GET",   
                    url : "https://ecs.console.aliyun.com/instance/instance/list.json",   
                    data : {pageNumber : pageNum , pageSize : result.pageSize * 2 , regionId : regionlist[regionIndex] }, 
                    success : function(data){
                    	totalnum = data.data.TotalCount;
                    	data.data.Instances.Instance.forEach(function(value){
                    		result.ecs[value.InstanceId] = value.Tags.Tag[0].TagValue ;
                    	});
		if( pageNum < Math.ceil(totalnum/(result.pageSize * 2) )){
			collectECS(regionIndex,pageNum+1);
                    	}else{
                    		collectECS(regionIndex+1,1);
                    	}
                    },
                    error :  function( jqXHR,  textStatus, errorThrown){
                    	collectECS(regionIndex,pageNum);
                    }
               }); 	
}

function collectRDS(pageNum){
	var totalnum ;
	$.ajax({   
                    async : false ,   
                    cache : false,   
                    timeout : 5000,   
                    type : "GET",   
                    url : "https://rdsnew.console.aliyun.com/instance/describeDBInstanceList.json",   
                    data : {pageNumber : pageNum , pageSize : result.pageSize , region : "all" }, 
                    success : function(data){
                    	totalnum = data.data.TotalRecordCount;
                    	data.data.Items.DBInstance.forEach(function(value){
                    		result.rds[value.InsId] = value.DBInstanceDescription.substring(0,value.DBInstanceDescription.indexOf("_"));
                    		result.rds[value.DBInstanceId] = value.DBInstanceDescription.substring(0,value.DBInstanceDescription.indexOf("_"));
                    	});
		if( pageNum < Math.ceil(totalnum/result.pageSize) ){
			collectRDS(pageNum + 1);
                    	}
                    },
                    error :  function( jqXHR,  textStatus, errorThrown){
                    	collectRDS(pageNum);
                    }
               }); 
}

function collectSLB(){
	var totalnum ;
	$.ajax({   
                    async : false ,   
                    cache : false,   
                    timeout : 5000,   
                    type : "GET",   
                    url : "https://slbnew.console.aliyun.com/instance/instance/list.json",   
                    data : {regionId : "cn-beijing"}, 
                    success : function(data){
                    	data.data.forEach(function(value){
                    		result.slb[value.LoadBalancerId] = value.LoadBalancerName.substring(0,value.LoadBalancerName.indexOf("_"));
                    	});
                    },
                    error :  function( jqXHR,  textStatus, errorThrown){
                    	collectRDS();
                    }
               }); 
}