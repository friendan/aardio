# lambda 表达式

lambda 表达式用于定义匿名函数，与普通匿名函数的区别如下：

1. lambda 不需要写 return 语句就可以直接返回一个表达式。

   例如 `lambda() 123` 等价于 `function() return 123`。

2. lambda 的函数体只能是一个表达式，不能使用其他语句或语句块，
   例如 `lambda(){}` 等价于 `function() return {}`

3. lambda 表达式不包含逗号，不会返回多个值。

   例如 `console.log( lambda() 123, 456 )`
   等价于 `console.log( function() { return 123 }, 456 )`

4. lambda 表达式的函数体不是语句，不能包含分隔语句的分号。

   例如 `console.log( lambda() 123; ) `是错误的写法，而 `console.log( function() return 123; );` 则是语法正确的写法（函数是语句，语句可以分号结束）。

5. 不能以 lambda 表达式作为操作数，并直接在右侧写一元操作符（例如调用操作符）。例如 `lambda() 123() ` 这样写是不对的，我们需要用括号将 lambda 转换为普通表达式，语法正确的写法为 `( lambda() 123 )()`。

6. 可选使用希腊字母 λ 代替 lambda 关键字。