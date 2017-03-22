# 简单p2p交易API

## 设计思路

数据层面的设计主要参考“[复式记账法](https://zh.wikipedia.org/wiki/%E5%A4%8D%E5%BC%8F%E7%B0%BF%E8%AE%B0)”：借方、贷方各记一笔，金额相等，互为相反数。

API框架使用了Lina,一个开源的API框架，可以很方便的生成详细且美观的API文档。

所有API接口遵循[restful](http://www.ruanyifeng.com/blog/2014/05/restful_api.html)的设计准则。
