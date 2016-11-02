[TOC]

# 引言
Android apps are a bit different from ordinary Java applications, because they’re build around Activities and Fragments, which both have lifecycles that determine the state of the app. When learning Android it’s not about learning how to code, it’s more about understanding the way Android works. That means that you’ll spend the majority of the time learning about Activity lifecycles, Fragments, ListViews, Bundles and other important Android concepts.

Remember to start out by doing simple apps like a tip calculator or a unit conversion app. Then expand to more difficult areas like GPS or networking.



google提供了Android Support Library package 系列的包来保证来高版本sdk开发的向下兼容性.

- Android Support v4:  这个包是为了照顾1.6及更高版本而设计的，这个包是使用最广泛的，eclipse新建工程时，都默认带有了。
- Android Support v7:  这个包是为了考虑照顾2.1及以上版本而设计的，但不包含更低，故如果不考虑1.6,我们可以采用再加上这个包，另外注意，v7是要依赖v4这个包的，即，两个得同时被包含。
- Android Support v13  :这个包的设计是为了android 3.2及更高版本的，一般我们都不常用，平板开发中能用到。


# 显示


# 组件
## Application类

Application和Activity,Service一样是Android框架的一个系统组件，当Android程序启动时系统会创建一个Application对象，用来存储系统的一些信息。

Android系统自动会为每个程序运行时创建一个Application类的对象且只创建一个，所以Application可以说是单例（singleton）模式的一个类。

通常我们是不需要指定一个Application的，系统会自动帮我们创建，如果需要创建自己的Application，那也很简单！创建一个类继承Application并在AndroidManifest.xml文件中的application标签中进行注册（只需要给application标签增加name属性，并添加自己的 Application的名字即可）。

启动Application时，系统会创建一个PID，即进程ID，所有的Activity都会在此进程上运行。那么我们在Application创建的时候初始化全局变量，同一个应用的所有Activity都可以取到这些全局变量的值，换句话说，我们在某一个Activity中改变了这些全局变量的值，那么在同一个应用的其他Activity中值就会改变。

Application对象的生命周期是整个程序中最长的，它的生命周期就等于这个程序的生命周期。因为它是全局的单例的，所以在不同的Activity,Service中获得的对象都是同一个对象。所以可以通过Application来进行一些，如：数据传递、数据共享和数据缓存等操作。

应用场景：

在Android中，可以通过继承Application类来实现应用程序级的全局变量，这种全局变量方法相对静态类更有保障，直到应用的所有Activity全部被destory掉之后才会被释放掉。
继承Application类，主要重写里面的onCreate（）方法（android.app.Application包的onCreate（）才是真正的Android程序的入口点），就是创建的时候，初始化变量的值。然后在整个应用中的各个文件中就可以对该变量进行操作了。

只需要调用Context的 getApplicationContext或者Activity的getApplication方法来获得一个Application对象，然后再得到相应的成员变量即可。它是代表我们的应用程序的类，使用它可以获得当前应用的主题和资源文件中的内容等，这个类更灵活的一个特性就是可以被我们继承，来添加我们自己的全局属性。
```java
public class FirstActivity extends Activity{
    @Override
    public void onCreate(Bundle savedInstanceState){
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        
        CustomApplication app = (CustomApplication) getApplication(); // 获得CustomApplication对象
        ...
    }
}
```

# 控件

## layout
- 隐藏
```
LinearLayout one = (LinearLayout) findViewById(R.id.one);
one.setVisibility(View.GONE);
I suggest that you use GONE insteady of INVISIBLE in the onclick event because with  View.GONE the place for the layout will not be visible and the application will not appear to have unused space in it unlike the View.INVISIBLE that will leave the gap that is intended for the the layout
```

- 通过`android:layout_weight="1"`使得该组件铺满剩余的空间。
- android:gravity：这个是针对控件里的元素来说的，用来控制元素在该控件里的显示位置。
- android:layout_gravity：这个是针对控件本身而言，用来控制该控件在包含该控件的父控件中的位置。

## Fragment
1、Fragment的产生与介绍


Android运行在各种各样的设备中，有小屏幕的手机，超大屏的平板甚至电视。针对屏幕尺寸的差距，很多情况下，都是先针对手机开发一套app，然后拷贝一份，修改布局以适应什么超级大屏的。难道无法做到一个app可以同时适应手机和平板吗？答案是，当然有，那就是Fragment.Fragment出现的初衷就是为了解决这样的问题。

你可以把Fragment当成Activity一个界面的一部分，甚至Activity的界面由完全不同的Fragment组成，更帅气的是Fragment有自己的声明周期和接收、处理用户的事件，这样就不必要在一个Activity里面写一堆事件、控件的代码了。更为重要的是，你可以动态的添加、替换、移除某个Fragment。
2、Fragment的生命周期

Fragment必须是依存于Activity而存在的，因此Activity的生命周期会直接影响到Fragment的生命周期。

Fragment比Activity多了几个额外的生命周期回调函数：
```java
onAttach(Activity);　　//当Activity与Fragment发生关联时调用
onCreateView(LayoutInflater,ViewGroup,Bundle);　　//创建该Fragment的视图
onActivityCreate(bundle);　　//当Activity的onCreate()；方法返回时调用
onDestoryView();　　//与onCreateView相对应，当改Fragment被移除时调用
onDetach();　　//与onAttach()相对应，当Fragment与Activity的关联被取消时调用
```
注意：除了onCreateView，其他的所有方法如果你重写了，必须调用父类对于该方法的实现。


# 序列化

## Differences between Serialization and Parcelable

Parcelable and Serialization are used for marshaling and unmarshaling Java objects.  Differences between the two are often cited around implementation techniques and performance results. From my experience, I have come to identify the following differences in both the approaches:

- Parcelable is well documented in the Android SDK; serialization on the other hand is available in Java. It is for this very reason that Android developers prefer Parcelable over the Serialization technique.
- In Parcelable, developers write custom code for marshaling and unmarshaling so it creates less garbage objects in comparison to Serialization. The performance of Parcelable over Serialization dramatically improves (around two times faster), because of this custom implementation.
- Serialization is a marker interface, which implies the user cannot marshal the data according to their requirements. In Serialization, a marshaling operation is performed on a Java Virtual Machine (JVM) using the Java reflection API. This helps identify the Java objects member and behavior, but also ends up creating a lot of garbage objects. Due to this, the Serialization process is slow in comparison to Parcelable.


```
How to pass a parcelable object that contains a list of objects?

If class Product is compatible with parcelable protocol, following should work according to documentation.

products = new ArrayList<Product>();
in.readList(products,null);
```

## 其他
- 去掉Activity的头部标题栏`android:theme="@style/AppTheme.NoActionBar"`
```xml
 <style name="AppTheme.NoActionBar">
    <item name="windowActionBar">false</item>
    <item name="windowNoTitle">true</item>
</style>
```

## Palette
Palette是什么？
它能让你从图像中提取突出的颜色。这个类能提取以下突出的颜色：
Vibrant(充满活力的)
Vibrant dark(充满活力的黑)
Vibrant light(充满活力的亮)
Muted(柔和的)
Muted dark(柔和的黑)
Muted lighr(柔和的亮)
如何使用？
要提取这些颜色，在你加载图片的后台线程中传递一个位图对象给Palette.generate()静态方法。如果你不适用线程，则调用Palette.generateAsync()方法并且提供一个监听器去替代。
你可以在Palette类中使用getter方法来从检索突出的颜色，比如Palette.getVibrantColor。

如果是Android Studio 要在你的项目中使用Palette类，增加下面的Gradle依赖到你的程序的模块(module)中：
```java
dependencies {  
    ...  
    compile 'com.android.support:palette-v7:21.0.+'  
}
```

# 网络
## volley
https://android.googlesource.com/platform/frameworks/volley

>Google I/O 2013上，Volley发布。它是Android平台上的网络通信库，能使网络通信更快，更简单，更健壮。

通过 Volley 去请求网络需要分三步。
1、通过 Volley 类来新建一个新的请求队列：
```java
RequestQueue mRequestQueue = Volley.newRequestQueue(this);
```compileSdkVersion

2、新建一个请求对象，并且设置好各项具体参数，比如url、http method以及监听结果的listeners
```java
StringRequest loginRequest = new StringRequest(Request.Method.POST, url, new Response.Listener<String>() {//2.new 一个请求
    @Override
    public void onResponse(String s) {//这里是返回正确反馈的接口（只要请求成功反馈的数据都这这里）
        //数据处理反馈（可以这这里处理服务器返回的数据）
        DealResponseFromServer(s);//json数据的解析和用户反馈
        Log.i("TAG",s);
    }
}, new Response.ErrorListener() {
    @Override
    public void onErrorResponse(VolleyError volleyError) {
    //volley 有专门处理error的库，下面就是调用了其中的一些，可以方便调试的时候查找到错误
        Log.d(TAG, "Volley returned error________________:" + volleyError);
        Class klass = volleyError.getClass();
        if(klass == com.android.volley.AuthFailureError.class) {
            Log.d(TAG,"AuthFailureError");
            Toast.makeText(context,"未授权，请重新登录",Toast.LENGTH_LONG).show();
        } else if(klass == com.android.volley.NetworkError.class) {
            Log.d(TAG,"NetworkError");
            Toast.makeText(context,"网络连接错误，请重新登录",Toast.LENGTH_LONG).show();
        } else if(klass == com.android.volley.NoConnectionError.class) {
            Log.d(TAG,"NoConnectionError");
        } else if(klass == com.android.volley.ServerError.class) {
            Log.d(TAG,"ServerError");
            Toast.makeText(context,"服务器未知错误，请重新登录",Toast.LENGTH_LONG).show();
        } else if(klass == com.android.volley.TimeoutError.class) {
            Log.d(TAG,"TimeoutError");
            Toast.makeText(context,"连接超时，请重新登录",Toast.LENGTH_LONG).show();
        } else if(klass == com.android.volley.ParseError.class) {
            Log.d(TAG,"ParseError");
        } else if(klass == com.android.volley.VolleyError.class) {
            Log.d(TAG,"General error");
        }
        Toast.makeText(context,"登录失败",Toast.LENGTH_LONG).show();
    }
})
{
    //这里是添加请求头的地方重写了getHeaders() 方法(发送设么请求头要根据自己实际开发需要设定)
    @Override
    public Map<String, String> getHeaders()  {
        HashMap<String, String> header = new HashMap<String, String>();
        header.put("Accept","application/json");
        header.put("Content-Type","application/x-www-form-urlencoded");
        return header;
    }

    //这里是发送参数的地方，重写了 getParams() 方法（传什么参数给服务器也是实际你自己修改）
     @Override
    protected Map<String, String> getParams() {
     HashMap<String, String> map = new HashMap<String, String>();

       //如果出现空指针异常或者是登录失败，先检查这里有木有传进来你要发送的用户名和密码。
       //所以在执行get数据方法之前一定要先存数据（set方法）
        map.put("username", User_Local.getUsername());
        map.put("password", User_Local.getPassword());
        return map;
    }
};
//设置超时重新请求
loginRequest.setRetryPolicy(new DefaultRetryPolicy(5000, DefaultRetryPolicy.DEFAULT_MAX_RETRIES,
        DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));
//设置标签，方便在stop(){}里面取消对应的volley 请求
loginRequest.setTag("POST");
```

3、将请求添加到队列
```java
mRequestQueue.add(jr);
```

# 广播
广播是系统中消息的一种变种；就是当一个事件发生时，比如，系统突然断网，系统就发一个广播消息给所有的接收者，所有的接收者在得到这个消息之后，就知道，啊哦，现在没网络了，我的程序应该怎么办，比如显示默认图片、提示用户等。BroadcastReceiver就是一个广播消息接收者。
广播之间信息的传递是通过Intent对象来传递的。
## 静态注册
什么叫静态注册呢，就是利用XML来注册。
## 动态注册
利用代码来注册的就叫动态注册。
静态注册的程序，无论该程序是否启动，都会当广播到来时接收，并处理。而动态注册的程序只有在程序运行时才会收到广播消息，程序不运行了，它就收不到了。

# 调试

- [Accessing localhost:port from Android emulator](http://stackoverflow.com/questions/6760585/accessing-localhostport-from-android-emulator)
```
You can access your host machine with the IP address "10.0.2.2".

This has been designed in this way by the Android team. So your webserver can perfectly run at localhost and from your Android app you can access it via "http://10.0.2.2:<hostport>".
```

# 问题

- 调试程序时出错，minSdk(API 23,N preview ) != deviceSdk(API 23)

删除project，重建，注意选择版本。

- Apache HttpClient Android (Gradle) 找不到`org.apache.http.cookie.Cookie`等，添加httpclient依赖也不行，解决办法：
[在app的build.gradle中添加](http://stackoverflow.com/questions/26024908/apache-httpclient-android-gradle)：
```
android{
    useLibrary  'org.apache.http.legacy'
}
```

- java.lang.NumberFormatException: Color value '@drawable/' must start with #
```
Remove the '-' in the file name.

NOTE: '-' is not a valid file-based resource name character: File-based resource names must contain only lowercase a-z, 0-9, or underscore
```

还有种原因是资源文件不是png格式的。

- 在首次连接手机调试时，报错`This adb server's $ADB_VENDOR_KEYS is not set`
执行如下命令
```
run "adb kill-server"
run "adb start-server"
Reconnect the device
run "adb devices"
```
之后手机会提示是否允许调试，选择是即可。

- 自动更新安装失败

Android replace application fails to install

It was cause by the apks being signed with different keys. One was debug and the other was release key. 


# 参考

- [我是如何自学Android，资料分享](http://www.jianshu.com/p/2ee0e74abbdf)
- [Android Fragment 深度解析](http://www.cnblogs.com/Gaojiecai/p/4084252.html)
- [android loginDemo +WebService用户登录验证](http://blog.csdn.net/meng425841867/article/details/8501848)
- [详解用户登录流程——Volley 请求](http://blog.csdn.net/nana129/article/details/47834315)
- [Android中关于Volley的使用（五）从RequestQueue开始来深入认识Volley](http://www.cnblogs.com/android100/p/Android-Volley5.html)
- [网络请求库Volley详解](http://www.jcodecraeer.com/a/anzhuokaifa/androidkaifa/2015/0526/2934.html)
- [Android中Application类用法](http://www.cnblogs.com/renqingping/archive/2012/10/24/Application.html)
- [Android 记住密码和自动登录界面的实现（SharedPreferences 的用法）](http://blog.csdn.net/liuyiming_/article/details/7704923)
- [Android保存用户名和密码](http://blog.csdn.net/u011109042/article/details/18239583)
- [BroadcastReceiver详解](http://blog.csdn.net/harvic880925/article/details/38710901)
- [Android Support v4、v7、v13的区别和应用场景](http://my.oschina.net/chengliqun/blog/148451)
- [PARCELABLE VS. JAVA SERIALIZATION IN ANDROID APP DEVELOPMENT](http://www.3pillarglobal.com/insights/parcelable-vs-java-serialization-in-android-app-development)
- [Parcelable vs Serializable](http://www.developerphil.com/parcelable-vs-serializable/)
- [Android使用序列化接口Parcelable、Serializable](http://my.oschina.net/u/242041/blog/206997)
- [Android Volley完全解析(一)，初识Volley的基本用法](http://blog.csdn.net/guolin_blog/article/details/17482095)
- [Android Volley完全解析(二)，使用Volley加载网络图片](http://blog.csdn.net/guolin_blog/article/details/17482165)
- [PullToRefreshListView 应用讲解](http://blog.csdn.net/mmjiajia132/article/details/40397813)
- [Fragments之间的交互](http://hukai.me/android-training-course-in-chinese/basics/fragments/communicating.html)
