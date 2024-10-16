# reduce() 函数  

reduce 是一个经典的无循环函数，在 JavaScript，Python 这些语言中都有相同的函数。
aardio中 reduce 函数的设计，基本与 JavaScript 的用法规则一样，例如空数组不指定初始值报错，指定初始值不跳过第一个数组成员，不指定初始值跳过第一个数组成员（用第一个数组成员作为初始值），初始值可以是任意对象，这些规则全都一样，参数的位置用法都一样。

1. 函数原型：   

	函数对象,错误信息 = reduce(array,reducer, initialValue)
  
2. 函数说明：   
  
	reduce 函数遍历 @array 参数指定的数组中的所有值并回调一个 @reducer 参数指定的函数，每一次回调都会将先前计算的结果作为参数传入并返回新的计算结果，reduce 函数本身则返回汇总后的单个返回值。

	如果 @initialValue 参数指定初始值则从数组索引为 1 的第一个元素开始执行 @reducer 函数。否则，数组索引为 1 的元素将作为初始值，并且从第二个数组元素开始遍历数组执行 @reducer 函数。 

	@reducer 函数的原型为

	```aardio
	function(prev,next,index,arr){  
		/*
		prev 参数为上次调用返回的值或初始值。
		无初始值则取首个成员值为初始值，并自第2个成员开始遍历。
		next 参数为下一个成员值。
		index 参数为下一个成员索引。
		arr 参数为正在遍历的数组,arr 与 owner 参数指向同一对象。
		*/
		return prev + next  //计算并返回新的值
	})
	```
  
3. 调用示例：   
  
	用法1，数组值求和：
	```aardio
	import console;

	var arr = {1;2;3;4;5}
	var value = reduce(arr, lambda(a,b) a + b );

	console.dump(value);
	console.pause(true);
	```

	用法2，将数组中所有值转换为字符串
	```aardio
	import console;

	var arr = {1;22;3;456}

	//将数组中的所有值转换为字符串
	var value = reduce(arr,function(a,b,i){
		a[ i ] = tostring(b)
		return a;
	},{});

	console.dump(value);
	console.pause(true);
	```

	用法3，筛选数组中的值
	```aardio
	import console;

	var arr = {1;22;3;456}

	//筛选出所有小于100的数
	var value = reduce(arr,function(a,b){
		if( b <100) table.push(a,b);
		return a;
	},{});

	console.dump(value);
	console.pause(true);
	```

	用法4，找出数组中最大的值：
	```aardio
	import console;

	var arr = {1;22;3;456}

	//找出数组中最大的值
	var value = reduce(arr,function(a,b){
		return math.max(a,b);
	});

	console.dump(value);
	console.pause(true);
	```

	用法5，解析字符串列表：
	```aardio
	import console;

	var str = /*
	产品:产品名称
	年期:18
	年龄:0
	保额:100000 
	*/

	var contents = string.splitEx(str,"\r\n");
	var info = reduce(contents,function(arr,value){
		s = string.splitEx(value,"\:")
		arr[ s[1] ] = s[2];
		return arr
	},{})

	console.dump(info);//打印结果
	console.pause();
	```

