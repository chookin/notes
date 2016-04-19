# 查看数据库

    show databases;
    use ecomm;
    show collections;
# 查询

    db.site.find({url:'sports.sina.com.cn'})
    db.site.find({"category.name": '体育健身' })
    db.category.find({site:'chinaz', name: '体育健身' })
    db.category.find({site:'jd', leaf:true, url: null})
    db.goods.find({site:'jd', "properties.品牌":'圣牧'})
    db.goods.find({site:'amazon', name:'葡萄酒'})
    db.category.find({site:'amazon', name:'葡萄酒'})
    db.category.find({site:'amazon', name:'红葡萄酒'})	
## 查询指定项

    db.goods.find({site:'jd'},{tag:1,"properties.品牌":1, "_id":0} )
    db.goods.find({site:'jd', "properties.品牌":{"$ne":null}},{tag:1,"properties.品牌":1, "_id":0} )
## distinct

    db.video.distinct('domain')
    [
            "youku.com",
            "lovev.com",
            "v.youku.com",
            "iqiyi.com",
            "vip.iqiyi.com",
            "yule.iqiyi.com",
            "list.iqiyi.com"
    ]
    
    db.video.distinct('site',{'domain':null})
    [ "video.sohu" ]
## exists

    db.category.find({ tag:{ $exists: true }})
    db.category.find({ site: 'tb', tag:{ $exists: true }})
    db.category.find({ site: 'yhd', tag:{ $exists: true }, crawlTime:{ $ne:ISODate("1970-01-01T00:00:00Z")}}).count()
    db.goods.find({site:'yhd',properties:{$exists:true}}).count()
    db.goods.find({ site: 'jd', tag:{ $exists: true }})
    db.goods.find({site:'jd',"properties.品牌":{$exists:true}}).count()
    db.goods.find({site:'tb',"properties.品牌":{$exists:true}})
## gt

    db.proxy.find({validateTime:{$gt:ISODate("2015-03-06T06:23:12.493Z")}})
## lt

    db.category.find({ site:'amazon', crawlTime:{ $gte:ISODate("1971-01-01T00:00:00Z"), $lt: ISODate("2970-01-01T00:00:00Z")} }).count();
## lte

    db.category.find({ site: 'jd', level: 3, crawlTime:{ $lte:ISODate("1970-01-01T00:00:00Z")}}).count()
    db.category.find({ site: 'yhd', level: 3, crawlTime:{ $lte:ISODate("1970-01-01T00:00:00Z")}}).count()
## in

    db.site.find( { "category.name" : { $in: ['广播电视',  '新闻报刊']}})
    db.site.find( { "ranking.alexa": {$in: [69]}})
    db.goods.find({site:'jd', "properties.类别":{$in:['纯牛奶']}})

## limit

    MySQL:
    SELECT * FROM user limit 10,20
    Mongo:
    db.user.find().skip(10).limit(20)

## ne

    db.category.find({site:'amazon',tag:{ $ne:null }}).count()
    db.category.find({ site:'amazon', crawlTime:{ $ne:ISODate("1970-01-01T00:00:00Z")} }).count();
    db.category.find({site:'jd',tag:{$ne:null}}).count()
    db.category.find({site: 'read.baidu', tag:{$ne: null}})
    db.goods.find({site:'jd',tag:{$ne:null}})
    db.goods.find({site:'jd',tag:{$ne:null}}).count()
    db.goods.find({site:'tb',tag:{$ne:null}}).count()
    db.goods.find({site:'tb',"properties.品牌":{$ne:null}}).count()

## sort

    db.book.find({c_code:'6030'}).sort({'properties.readCount':-1})
    db.book.find({c_code:'1001'}).sort({'properties.readCount':-1})
    db.book.find({site:'read.douban', 'properties.keyWords':'android'}).sort({'properties.scoreValue':-1}).limit(1)
## where

    db.site.find({ $where: "this.category.length > 1" })
## 正则

    db.category.find({"name":{$regex:'潮牌'}})
    db.goods.find({"url":{$regex:'mclick'}})
    db.goods.find({"url":{$regex:'detail.tmall'}})
    db.goods.find({"properties.品牌":{$regex:'博龙啤酒'}})
    db.goods.find({"properties.品牌":{$regex:'other/其他'}})
    # 替换换行符
    db.comments.find({content:{$regex:'\n'}}).limit(10)
# 插入

    db.user.insert({‘name’ : ’starlee’, ‘age’ : 25})
# 更新

    # db.collection.update( criteria, objNew, upsert, multi )
    # criteria : update的查询条件，类似sql update查询内where后面的
    # objNew   : update的对象和一些更新的操作符（如$set,$inc...)
    # upsert   : 这个参数的意思是，如果不存在update的记录，是否插入objNew, true为插入，默认是false，不插入。
    # multi    : mongodb默认是false,只更新找到的第一条记录，如果这个参数为true, 就把按条件查出来多条记录全部更
    db.category.update({site:'amazon'}, {$set: {crawlTime:ISODate("1970-01-01T00:00:00Z")}}, false, true)

    db.category.find({site:'yhd', tag:'食品/休闲零食/糖类'})
    db.category.update({site:'yhd', tag:'食品/休闲零食/糖类'}, {$set: {crawlTime:ISODate("1970-01-01T00:00:00Z")}}, false, true)
    db.category.update({site:'yhd'}, {$set: {crawlTime:ISODate("1970-01-01T00:00:00Z")}}, false, true)

# 删除

    db.dropDatabase(); # 删除database
    db.goods.drop()或db.runCommand({"drop","goods"}) # 删除表
    db.category.remove({"site":"jd1"}) # drop records
    # drop field
    db.category.update({},{$unset:{"tag":""}},{multi:true}) 
    db.book.update({},{$unset:{"tag":""}},{multi:true})

# 索引
对于不使用索引的sort()操作，当使用超过32Mb内存时，sort()操作将退出。
## 创建索引

    db.goods.ensureIndex({'site':1}) # 使用ensureIndex来创建索引，1为升序，-1为倒序
    db.runCommand({“dropIndexes”: “goods”, “index”: “site”}) # dropIndexes后面跟的参数是集合名称，index后面跟的参数是索引名称，如果需要删除所有索引，使用”*”即可

## 创建稀疏索引
`db.collection.ensureIndex({a:1},{sparse:true})`

## 创建唯一索引
`db.collection.ensureIndex({a:1},{unique:true})`

## 查看某个表上的所有索引
`db.collection.getIndexes()`

## 删除索引

```
 db.comments.dropIndex({"channel" : 1,
... "appName" : 1,
... "version" : 1});
{ "nIndexesWas" : 3, "ok" : 1 }
```

# group

    db.goods.group({
        key : {
            "properties.品牌" : true
        },
        cond : {
            "properties.品牌" : {"$ne" : null},
            "tag" : {"$ne" : null}
        },
        reduce : function (obj, prev) {
            prev.sum += 1;
            if (!prev.brand) {
                prev.brand = obj.properties.品牌;
            }
            var tag = obj.tag;
            if (prev.tags.indexOf(tag) == -1) {
                prev.tags.push(tag);
            }
        },
        initial : {
            sum : 0, tags:[]
        }
    });

# 数据导出
## mongo + js文件

    mongo 127.0.0.1:27017/ecomm export-category.js >> category.json
其中，export-category.js文件内容为

    var c = db.category.find({ tag:{ $exists: true }}); 
    while(c.hasNext())
    {
        printjson(c.next())
    };
## mongo eval

    mongo 127.0.0.1:27017/ecomm --eval 'var c = db.category.find({ tag:{ $exists: true }}); while(c.hasNext()) {printjson(c.next())}' >> test.json
    mongo 127.0.0.1:27017/ecomm --eval 'var c = db.category.find({ site:"chinaz"}); while(c.hasNext()) {printjson(c.next())}' >> chinaz.json
## mongoexport

    mongoexport --host localhost --db ecomm --collection category --csv --out category.csv --fields name,site,level,url
    mongoexport --host localhost --db ecomm --collection category --csv --out chinaz.csv --fields name,site,level,url -q '{ site:"chinaz"}'
    mongoexport --host localhost --db ecomm --collection site --csv --out sites.csv --fields name,url,ranking,category
    mongoexport --host localhost --db ecomm --collection goods --csv --out goods.csv --fields name,site,tag -q '{"tag":{"$ne":null}}'

# mapreduce
## 调试
调试可以用print输出。注意：调试信息输入到了mongo的日子文件中，而不是直接输出到控制台。
```
var emit = function(key, value) {
    print("emit -> key: " + key + " value: " + tojson(value));
};
```
