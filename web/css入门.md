## css选择器

```
选择器                   例子         例子描述                               CSS版本
.class                  .intro      选择 class="intro" 的所有元素。         1
#id                     #firstname  选择 id="firstname" 的所有元素。        1   
*                       *           选择所有元素。                          2
element                 p           选择所有 <p> 元素。                     1
element,element         div,p       选择所有 <div> 元素和所有 <p> 元素。      1
element element         div p       选择 <div> 元素内部的所有 <p> 元素。      1
element>element         div>p       选择父元素为 <div> 元素的所有 <p> 元素。   2
element+element         div+p       选择紧接在 <div> 元素之后的所有 <p> 元素。 2
```

参考：

- [CSS 选择器参考手册](http://www.w3school.com.cn/cssref/css_selectors.asp)

## 三种样式
从CSS 样式代码插入的形式来看基本可以分为以下3种：内联式、嵌入式和外部式三种。

1.内联式css样式，就是把css代码直接写在现有的HTML标签中。由于要将表现和内容混杂在一起，内联样式会损失掉样式表的许多优势。

```html
<p style="color:red";font-size:12px>这里文字是红色。</p>
```

2.嵌入式css样式，或称为内部样式，指在html文件的head标签内声明样式。当单个文档需要特殊的样式时，就应该使用内部样式表。

```html
<head>
  <style type="text/css">
   span{
     color:red;
    }
  </style>
</head>
```

3.外部式css样式(也可称为外联式)就是把css代码写一个单独的外部文件中，这个css样式文件以“.css”为扩展名。通过在html文件的head标签中，使用link引用css文件中定义的样式。如果某个样式表需要被使用许多次，使用外部样式表是最好的选择。

```html
<link href="base.css" rel="stylesheet" type="text/css" />
```

注意：

1. css样式文件名称以有意义的英文字母命名，如 main.css。
2. rel="stylesheet" type="text/css" 是固定写法不可修改。
3. <link>标签位置一般写在<head>标签之内。

## css优先级

多重样式（Multiple Styles）：如果外部样式、内部样式和内联样式同时应用于同一个元素，就是使多重样式的情况。一般情况下，优先级如下：

```
（外部样式）External style sheet <（内部样式）Internal style sheet <（内联样式）Inline style
```

有个例外的情况，就是如果外部样式放在内部样式的后面，则外部样式将覆盖内部样式。

选择器的优先权

1.  内联样式表的权值最高 1000；
2.  ID 选择器的权值为 100
3.  Class 类选择器的权值为 10
4.  HTML 标签选择器的权值为 1

CSS 优先级法则：

- 选择器都有一个权值，权值越大越优先；
- 当权值相等时，后出现的样式表设置要优于先出现的样式表设置；
- 创作者的规则高于浏览者：即网页编写者设置的CSS 样式的优先权高于浏览器所设置的样式；
- 继承的CSS 样式不如后来指定的CSS 样式；
- 在同一组属性设置中标有“!important”规则的优先级最大；
