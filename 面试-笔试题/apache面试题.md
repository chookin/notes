
## 如何检查 Apache 及其版本?

首先，使用rpm命令来检查Apache是否已经安装. 如果已经安装好了，那就使用httpd -v 命令来检查它的版本.

## 对于“DirectoryIndex”你是怎么理解的?

DirectoryIndex 是当有一个来自主机的请求时Apache首先会去查找的文件. 例如: 客户端发送请求www.example.com, Apache 对此将到站点的文件根目录查找index文件 (首先要展示的文件).

DirectoryIndex 的默认设置是 .html index.html index.php, 如果不是这个名字, 你需要对 httpd.conf 或者 apache2.conf 中的 DirectoryIndex 值做出修改，以将其展示在你的客户端浏览器上.
