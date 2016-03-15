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
