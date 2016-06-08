[TOC]
# html

- Doctype作用？标准模式与兼容模式各有什么区别?
```
（1）<!DOCTYPE>声明位于位于HTML文档中的第一行，处于 <html> 标签之前。告知浏览器的解析器用什么文档标准解析这个文档。DOCTYPE不存在或格式不正确会导致文档以兼容模式呈现。

（2）标准模式的排版 和JS运作模式都是以该浏览器支持的最高标准运行。在兼容模式中，页面以宽松的向后兼容的方式显示,模拟老式浏览器的行为以防止站点无法工作。
```

- 页面导入样式时，使用link和@import有什么区别？
```
（1）link属于XHTML标签，除了加载CSS外，还能用于定义RSS, 定义rel连接属性等作用；而@import是CSS提供的，只能用于加载CSS;

（2）页面被加载的时，link会同时被加载，而@import引用的CSS会等到页面被加载完再加载;

（3）import是CSS2.1 提出的，只在IE5以上才能被识别，而link是XHTML标签，无兼容问题;
```

# css
- 行内元素有哪些?块级元素有哪些?CSS的盒模型?
块级元素：div p h1 h2 h3 h4 form ul
行内元素: a b br i span input select
Css盒模型:内容，border ,margin，padding

- css层叠
- 介绍一下标准的CSS的盒子模型？低版本IE的盒子模型有什么不同的？
```
（1）有两种， IE 盒子模型、W3C 盒子模型；
（2）盒模型： 内容(content)、填充(padding)、边界(margin)、 边框(border)；
（3）区  别： IE的content部分把 border 和 padding计算了进去;

如果不加 DOCTYPE 声明，那么各个浏览器会根据自己的行为去理解网页，即 IE 浏览器会采用 IE 盒子模型去解释你的盒子，而 FF 会采用标准 W3C 盒子模型解释你的盒子，所以网页在不同的浏览器中就显示的不一样了。反之，如果加上了 DOCTYPE 声明，那么所有浏览器都会采用标准 W3C 盒子模型去解释你的盒子
```

# javascript
Javascript里面所有的数据类型都是对象（object），Brendan Eich把new命令引入了Javascript，用来从原型对象生成一个实例对象。new命令后面跟的不是类，而是构造函数。用构造函数生成实例对象，有一个缺点，那就是无法共享属性和方法。考虑到这一点，<font color='red'>Brendan Eich决定为构造函数设置一个prototype属性,这个属性指向另一个对象,这个对象的所有属性和方法，都会被构造函数的实例继承</font>。实例对象一旦创建，将自动引用prototype对象的属性和方法。也就是说，实例对象的属性和方法，分成两种，一种是本地的，另一种是引用的。
```js
function DOG(name){
    this.name = name;
}
DOG.prototype = { species : '犬科' };
var dogA = new DOG('大毛');
var dogB = new DOG('二毛');
alert(dogA.species); // 犬科
alert(dogB.species); // 犬科
// 现在，species属性放在prototype对象里，是两个实例对象共享的。只要修改了prototype对象，就会同时影响到两个实例对象。
DOG.prototype.species = '猫科';
alert(dogA.species); // 猫科
alert(dogB.species); // 猫科
```

- 介绍js的基本数据类型。
Undefined、Null、Boolean、Number、String
- JavaScript原型，原型链 ? 有什么特点？
```
每个对象都会在其内部初始化一个属性，就是prototype(原型)，当我们访问一个对象的属性时，
如果这个对象内部不存在这个属性，那么他就会去prototype里找这个属性，这个prototype又会有自己的prototype，
于是就这样一直找下去，也就是我们平时所说的原型链的概念。
关系：instance.constructor.prototype = instance.__proto__

特点：
JavaScript对象是通过引用来传递的，我们创建的每个新对象实体中并没有一份属于自己的原型副本。当我们修改原型时，与之相关的对象也会继承这一改变。


 当我们需要一个属性的时，Javascript引擎会先看当前对象中是否有这个属性， 如果没有的话，
 就会查找他的Prototype对象是否有这个属性，如此递推下去，一直检索到 Object 内建对象。
    function Func(){}
    Func.prototype.name = "Sean";
    Func.prototype.getInfo = function() {
      return this.name;
    }
    var person = new Func();//现在可以参考var person = Object.create(oldObject);
    console.log(person.getInfo());//它拥有了Func的属性和方法
    //"Sean"
    console.log(Func.prototype);
    // Func { name="Sean", getInfo=function()}
```

- 闭包
子函数能被外部调用到，则该作用连上的所有变量都会被保存下来。
- 你如何组织自己的代码？是使用模块模式，还是使用经典继承的方法？
    - 对内：模块模式
    - 对外：继承

- JavaScript中的继承是如何工作的
子构造函数中执行父构造函数，并用call\apply改变this;克隆父构造函数原型上的方法
- 尽可能详尽的解释AJAX的工作原理
    - 创建ajax对象（XMLHttpRequest/ActiveXObject(Microsoft.XMLHttp)）
    - 判断数据传输方式(GET/POST)
    - 打开链接 open()
    - 发送 send()
    - 当ajax对象完成第四步（onreadystatechange）数据接收完成，判断http响应状态（status）200-300之间或者304（缓存）执行回调函数
- 对象继承
- ajax请求的时候get 和post方式的区别
- json和字符串之间的转化
```js
JSON字符串转换为JSON对象:
var obj =eval('('+ str +')');
var obj = str.parseJSON();
var obj = JSON.parse(str);

JSON对象转换为JSON字符串：
var last=obj.toJSONString();
var last=JSON.stringify(obj);
```

# 开发经验
- 你如何优化自己的代码
    - 代码重用
    - 避免全局变量（命名空间，封闭空间，模块化mvc..）
    - 拆分函数避免函数过于臃肿
    - 注释
- 什么是FOUC(Flash Of Unrendered Content)？你如何来避免FOUC？
    - 普通js：由于css引入使用了@import 或者存在多个style标签以及css文件在页面底部引入使得css文件加载在html之后导致页面闪烁、花屏。解决办法：用link加载css文件，放在head标签里面。
    - angular: 浏览器和angular渲染页面都需要消耗一定的时间。这里的间隔可能很小，甚至让人感觉不到区别；但也可能很长，这样会导致让我们的用户看到了没有被渲染过的页面。为了避免FOUC，首先需要页面元素的渲染逻辑，并结合以下几个命令：
        - ng-cloak指令是angular的内置指令，它的作用是隐藏所有被它包含的元素；在浏览器加载和编译渲染完成之后，angular会自动删除ngCloak元素属性，这样这个元素就会变成可见的。
        - ng-bind是angular里面另一个内置的用于操作绑定页面数据的指令。我们可以使用ng-bind代替{{ }}的形式绑定元素到页面上； 使用ng-bind替代{{  }}可以防止未被渲染的{{ }}就展示给用户了，使用ng-bind渲染的空元素替代{{ }}会显得友好很多。
        - resolve 当在不同的页面之间使用routes（路由）的时候，我们有另外的方式防止页面在数据被完全加载到route之前被渲染。在route（路由）里使用resolve可以让我们在route（路由）被完全加载之前获取我们需要加载的数据。当数据被加载成功之后，路由就会改变而页面也会呈现给用户；数据没有被加载成功route就不会改变，



# 参考

- [AngularJS 防止页面闪烁的方法](http://my.oschina.net/tanweijie/blog/295255?fromerr=NyGjeQMy)
- [Javascript继承机制的设计思想](http://www.ruanyifeng.com/blog/2011/06/designing_ideas_of_inheritance_mechanism_in_javascript.html)
- [Javascript 面向对象编程（一）：封装](http://www.ruanyifeng.com/blog/2010/05/object-oriented_javascript_encapsulation.html)
