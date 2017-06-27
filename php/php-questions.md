# ci框架
## Only variable references should be returned by reference

修改`system/core/Common.php`的257行

```php
// return $_config[0] =& $config;
$_config[0] =& $config;
return $_config[0];
```

# php7
## Fatal error: Uncaught Error: Call to undefined function mysql_connect()
> `mysql_*` functions have been removed in PHP7!
> You can use `mysqli_connect($mysql_hostname , $mysql_username)` instead of `mysql_connect($mysql_hostname , $mysql_username)`
