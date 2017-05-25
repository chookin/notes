
## css层叠
介绍一下标准的CSS的盒子模型？低版本IE的盒子模型有什么不同的？

```
（1）有两种， IE 盒子模型、W3C 盒子模型；
（2）盒模型： 内容(content)、填充(padding)、边界(margin)、 边框(border)；
（3）区  别： IE的content部分把 border 和 padding计算了进去;
```

## 什么是CSS Hack?

一般来说是针对不同的浏览器写不同的CSS,就是 CSS Hack。
IE浏览器Hack一般又分为三种，条件Hack、属性级Hack、选择符Hack（详细参考CSS文档：css文档）。例如：

```css
/*1、条件Hack*/
<!--[if IE]>
  <style>
        .test{color:red;}
  </style>
<![endif]-->
/*2、属性Hack*/
.test{
color:#090\9; /* For IE8+ */
*color:#f00;  /* For IE7 and earlier */
_color:#ff0;  /* For IE6 and earlier */
}
/*3、选择符Hack*/
* html .test{color:#090;}       /* For IE6 and earlier */
* + html .test{color:#ff0;}     /* For IE7 */
```
