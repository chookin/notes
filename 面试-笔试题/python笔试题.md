
- 元组转字符串,去除开始和结束的括弧,并去除多余的`,`, `'`, `"`
例如,

```
('id', ) -> id
('id', 'name') -> id, name
```

```python
def tuple2string(obj):
    str_obj = str(obj)
    str_obj = str_obj.replace("'", '').replace('"', '')
    str_obj = re.sub("^\(", "", str_obj)
    str_obj = re.sub("\)$", "", str_obj)
    str_obj = re.sub(",$", "", str_obj)
    return str_obj
```
