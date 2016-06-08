Android如何设置TextView的行间距、行高。

     Android系统中TextView默认行间距比较窄，不美观。
    我们可以设置每行的行间距，可以通过属性android:lineSpacingExtra或android:lineSpacingMultiplier来做。
在你要设置的TextView中加入如下代码：

1、android:lineSpacingExtra 
设置行间距，如”8dp”。

2、android:lineSpacingMultiplier 
设置行间距的倍数，如”1.5″。


# 自定义button形状

## shape
```
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="rectangle">
    <solid android:color="@color/btn_blue" />
    <corners
        android:bottomLeftRadius="15dip"
        android:bottomRightRadius="15dip"
        android:topLeftRadius="15dip"
        android:topRightRadius="15dip" />
</shape>
```

1. shape用于定义形状，有四种形状(矩形rectangle| 椭圆oval | 直线line | 圆形ring)。
2. solid用于设置填充形状的颜色。
3. corners用于创建圆角（只用于形状是矩形）。
4. topLeftRadius、topRightRadius、bottomLeftRadius、bottomRightRadius分别设置左上，右上，左下，右下圆角的半径。
<gradient>  渐变
Android:startColor  
起始颜色
Android:endColor  
结束颜色             
Android:angle  
渐变角度，0从左到右，90表示从下到上，数值为45的整数倍，默认为0；
Android:type  
渐变的样式 liner线性渐变 radial环形渐变 sweep
<solid >  填充
Android:color  
填充的颜色
<stroke >描边
Android:width 
描边的宽度
Android:color 
描边的颜色
Android:dashWidth
 表示'-'横线的宽度
Android:dashGap 
表示'-'横线之间的距离
<corners >圆角
Android:radius  
圆角的半径 值越大角越圆
Android:topRightRadius  
右上圆角半径
Android:bottomLeftRadius 
右下圆角角半径
Android:topLeftRadius 
左上圆角半径
Android:bottomRightRadius 
左下圆角半径
<padding >填充
android:bottom="1.0dip" 
底部填充
android:left="1.0dip" 
左边填充
android:right="1.0dip" 
右边填充
android:top="0.0dip" 
上面填充

## Selector

简介

根据不同的选定状态来定义不同的现实效果
分为四大属性：
android:state_selected 是选中
android:state_focused 是获得焦点
android:state_pressed 是点击
android:state_enabled 是设置是否响应事件,指所有事件
另：
android:state_window_focused 默认时的背景图片
引用位置：res/drawable/文件的名称.xml

## 3.layer-list   

简介：

将多个图片或上面两种效果按照顺序层叠起来
例子：

[html] view plain copy 在CODE上查看代码片派生到我的代码片
<?xml version="1.0" encoding="utf-8"?>  
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">  
    <item>  
      <bitmap android:src="@drawable/android_red"  
        android:gravity="center" />  
    </item>  
    <item android:top="10dp" android:left="10dp">  
      <bitmap android:src="@drawable/android_green"  
        android:gravity="center" />  
    </item>  
    <item android:top="20dp" android:left="20dp">  
      <bitmap android:src="@drawable/android_blue"  
        android:gravity="center" />  
    </item>  
</layer-list>  
[html] view plain copy 在CODE上查看代码片派生到我的代码片
<ImageView  
    android:layout_height="wrap_content"  
    android:layout_width="wrap_content"  
    android:src="@drawable/layers" />  


# 最后

以上三个标签可以揉合到一块儿来使用，所要实现的效果就是上面三种标签的说明，比如下面这个例子：

```xml
<selector xmlns:android="http://schemas.android.com/apk/res/android">  
    <item android:state_pressed="true">  
        <layer-list>  
            <item android:bottom="8.0dip">  
                <shape>  
                    <solid android:color="#ffaaaaaa" />  
                </shape>  
            </item>  
            <item>  
                <shape>  
                    <corners android:bottomLeftRadius="4.0dip" android:bottomRightRadius="4.0dip" android:topLeftRadius="1.0dip" android:topRightRadius="1.0dip" />  
  
                    <solid android:color="#ffaaaaaa" />  
  
                    <padding android:bottom="1.0dip" android:left="1.0dip" android:right="1.0dip" android:top="0.0dip" />  
                </shape>  
            </item>  
            <item>  
                <shape>  
                    <corners android:bottomLeftRadius="3.0dip" android:bottomRightRadius="3.0dip" android:topLeftRadius="1.0dip" android:topRightRadius="1.0dip" />  
  
                    <solid android:color="@color/setting_item_bgcolor_press" />  
                </shape>  
            </item>  
        </layer-list>  
    </item>  
    <item>  
        <layer-list>  
            <item android:bottom="8.0dip">  
                <shape>  
                    <solid android:color="#ffaaaaaa" />  
                </shape>  
            </item>  
            <item>  
                <shape>  
                    <corners android:bottomLeftRadius="4.0dip" android:bottomRightRadius="4.0dip" android:topLeftRadius="1.0dip" android:topRightRadius="1.0dip" />  
  
                    <solid android:color="#ffaaaaaa" />  
  
                    <padding android:bottom="1.0dip" android:left="1.0dip" android:right="1.0dip" android:top="0.0dip" />  
                </shape>  
            </item>  
            <item>  
                <shape>  
                    <corners android:bottomLeftRadius="3.0dip" android:bottomRightRadius="3.0dip" android:topLeftRadius="1.0dip" android:topRightRadius="1.0dip" />  
  
                    <solid android:color="@color/setting_item_bgcolor" />  
                </shape>  
            </item>  
        </layer-list>  
    </item>  
</selector>  
```

# toolbar 动态折叠
app:layout_scrollFlags是AppBarLayout的属性。

AppBarLayout is a vertical LinearLayout which implements many of the features of material designs app bar concept, namely scrolling gestures.

Children should provide their desired scrolling behavior through setScrollFlags(int) and the associated layout xml attribute: app:layout_scrollFlags.

This view depends heavily on being used as a direct child within a CoordinatorLayout. If you use AppBarLayout within a different ViewGroup, most of it‘s functionality will not work.
