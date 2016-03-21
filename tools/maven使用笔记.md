# 配置repo源

    vi settings
    
    <mirror>
      <id>CN</id>
      <name>OSChina Central</name>
      <url>http://maven.oschina.net/content/groups/public/</url>
      <mirrorOf>central</mirrorOf>
    </mirror>
# 添加jar到本地仓库
```shell
mvn install:install-file -Dfile=lib/CCP_REST_SDK_JAVA_v2.7r.jar -DgroupId=com-cloopen-rest -DartifactId=rest-sdk -Dversion=1.0.0 -Dpackaging=jar -DgeneratePom=true
```

# 语法
## maven依赖关系中Scope的作用
```
在POM 4中，<dependency>中还引入了<scope>，用于管理依赖的部署。目前<scope>可以使用5个值：

    * compile，缺省值，适用于所有阶段，会随着项目一起发布。
    * provided，类似compile，期望JDK、容器或使用者会提供这个依赖。如servlet.jar。
    * runtime，只在运行时使用，如JDBC驱动，适用运行和测试阶段。
    * test，只在测试时使用，用于编译和运行测试代码。不会随项目发布。
    * system，类似provided，需要显式提供包含依赖的jar，Maven不会在Repository中查找它。
```

# 打包
## 设定jdk版本
```xml
 <plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-compiler-plugin</artifactId>
    <version>3.1</version>
    <configuration>
        <source>1.8</source>
        <target>1.8</target>
    </configuration>
</plugin>
```

## 指定source directory和resource directory

```xml
<build>
        <sourceDirectory>src/main/java</sourceDirectory>
        <resources>
            <resource>
                <directory>src/main/resources</directory>
            </resource>
        </resources>
</build>
```

## 拷贝依赖项到指定文件夹
```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-dependency-plugin</artifactId>
    <executions>
        <execution>
            <id>copy</id>
            <phase>package</phase>
            <goals>
                <goal>copy-dependencies</goal>
            </goals>
            <configuration>
                <outputDirectory>
                    ${project.build.directory}/lib
                </outputDirectory>
            </configuration>
        </execution>
    </executions>
</plugin>
```

## 拷贝配置文件等资源文件到指定文件夹
```xml
<plugin>
    <artifactId>maven-resources-plugin</artifactId>
    <version>2.6</version>
    <executions>
        <execution>
            <id>copy-resources</id>
            <phase>package</phase>
            <goals>
                <goal>copy-resources</goal>
            </goals>
            <configuration>
                <outputDirectory>${project.build.directory}/conf</outputDirectory>
                <resources>
                    <resource>
                        <directory>src/main/resources</directory>
                        <filtering>true</filtering>
                    </resource>
                </resources>
            </configuration>
        </execution>
    </executions>
</plugin>
```

## maven-jar-plugin
[maven-jar-plugin](http://maven.apache.org/plugins/maven-jar-plugin)

- Maven Archiver can add the classpath of your project to the manifest. This is done with the <addClasspath\> configuration element.
- Sometimes it is useful to be able to alter the classpath, this can be achieved with the <classpathPrefix\> configuration element.貌似只能添加一个，如添加"conf/:lib/"就加载失败了。
- If you want to create an executable jar file, you need to configure Maven Archiver accordingly. You need to tell it which main class to use. This is done with the <mainClass\> configuration element. 
- exclude files,打包时排除指定文件.

```xml
<plugin>
    <artifactId>maven-jar-plugin</artifactId>
    <configuration>
        <archive>
            <manifest>
                <mainClass>cmri.snapshot.wall.server.PicWallApplication</mainClass>
                <addClasspath>true</addClasspath>
                <classpathPrefix>lib/</classpathPrefix>
            </manifest>
        </archive>
        <excludes>
            <exclude>*.properties</exclude>
            <exclude>*/*.xml</exclude>
        </excludes>
    </configuration>
    <executions>
        <execution>
            <phase>package</phase>
            <goals>
                <goal>test-jar</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

## maven-shade-plugin
可用于把依赖打包到一个jar中。
```xml
 <plugin>
    <!--To fix error: Configuration problem: Unable to locate Spring NamespaceHandler for XML schema namespace [http://www.springframework.org/schema/tx] Offending resource: class path resource [applicationContext.xml]-->
    <!--http://robert-reiz.com/2011/11/14/832/#comment-506-->

    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-shade-plugin</artifactId>
    <version>2.3</version>
    <executions>
        <execution>
            <phase>package</phase>
            <goals>
                <goal>shade</goal>
            </goals>
            <configuration>
                <transformers>
                    <transformer implementation="org.apache.maven.plugins.shade.resource.AppendingTransformer">
                        <resource>META-INF/spring.handlers</resource>
                    </transformer>
                    <transformer implementation="org.apache.maven.plugins.shade.resource.AppendingTransformer">
                        <resource>META-INF/spring.schemas</resource>
                    </transformer>
                </transformers>
            </configuration>
        </execution>
    </executions>
</plugin>
```

# 常见问题
1）打包时出现问题：

    [ERROR] /Users/chookin/project/DaTiBa/Server4.0/trunk/src/com/chinamobile/websurvey/action/PublishAction.java:[1,1] 非法字符: '\ufeff'
解决办法，转换文件为utf8 无bom格式。可以使用sublime打开，然后选择【File】|【Save with Encoding】|[UTF-8].

2) jdk7中，maven 程序包com.sun.image.codec.jpeg不存在的解决方案

```shell
mvn install:install-file -DgroupId=com.sun -DartifactId=rt -Dversion=1.7 -Dpackaging=jar -Dfile=/Library/Java/JavaVirtualMachines/jdk1.7.0_79.jdk/Contents/Home/jre/lib/rt.jar 
mvn install:install-file -DgroupId=com.sun -DartifactId=jce -Dversion=1.7 -Dpackaging=jar -Dfile=/Library/Java/JavaVirtualMachines/jdk1.7.0_79.jdk/Contents/Home/jre/lib/jce.jar 
```

在pox.xml中引入依赖 

```xml
<dependency>
    <groupId>com.sun</groupId>
    <artifactId>rt</artifactId>
    <version>1.7</version>
</dependency>

<dependency>
    <groupId>com.sun</groupId>
    <artifactId>jce</artifactId>
    <version>1.7</version>
</dependency>
```

3) 打包war时报错，Error assembling WAR: webxml attribute is required (or pre-existing WEB-INF/web.xml if executing in update mode)

需要指定web.xml文件的路径。

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-war-plugin</artifactId>
    <version>2.2</version>
    <configuration>
        <webXml>WebRoot/WEB-INF/web.xml</webXml>
    </configuration>
</plugin>
```
