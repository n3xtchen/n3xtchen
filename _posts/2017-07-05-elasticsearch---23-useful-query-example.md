---
layout: post
title: "23 个常见的 ElasticSearch 查询语句"
description: ""
category: elasticsearch
tags: [elasticsearch]
---
{% include JB/setup %}

为了演示不同类型的 **ElasticSearch** 的查询，我们将使用书文档信息的集合（有以下字段：title（标题）, authors（作者）, summary（摘要）, publish_date（发布日期）和 num_reviews（浏览数））。

在这之前，首先我们应该先创建一个新的索引，并批量导入一些文档：


创建索引：

	PUT /bookdb_index
	    { "settings": { "number_of_shards": 1 }}
	    

批量上传文档：

	POST /bookdb_index/book/_bulk
	    { "index": { "_id": 1 }}
	    { "title": "Elasticsearch: The Definitive Guide", "authors": ["clinton gormley", "zachary tong"], "summary" : "A distibuted real-time search and analytics engine", "publish_date" : "2015-02-07", "num_reviews": 20, "publisher": "oreilly" }
	    { "index": { "_id": 2 }}
	    { "title": "Taming Text: How to Find, Organize, and Manipulate It", "authors": ["grant ingersoll", "thomas morton", "drew farris"], "summary" : "organize text using approaches such as full-text search, proper name recognition, clustering, tagging, information extraction, and summarization", "publish_date" : "2013-01-24", "num_reviews": 12, "publisher": "manning" }
	    { "index": { "_id": 3 }}
	    { "title": "Elasticsearch in Action", "authors": ["radu gheorge", "matthew lee hinman", "roy russo"], "summary" : "build scalable search applications using Elasticsearch without having to do complex low-level programming or understand advanced data science algorithms", "publish_date" : "2015-12-03", "num_reviews": 18, "publisher": "manning" }
	    { "index": { "_id": 4 }}
	    { "title": "Solr in Action", "authors": ["trey grainger", "timothy potter"], "summary" : "Comprehensive guide to implementing a scalable search engine using Apache Solr", "publish_date" : "2014-04-05", "num_reviews": 23, "publisher": "manning" }
	    
### 栗子：

#### 1. 基本的匹配查询

有两种方式来执行一个全文匹配查询：

* 使用 Search Lite API，它从 URL 中读取所有的查询参数
* 使用完整 JSON 作为请求体，这样你可以使用完整的 **Elasticsearch DSL**

下面是一个基本的匹配查询，查询任一字段包含 Guide 的记录

	GET /bookdb_index/book/_search?q=guide
	
	[Results]
	"hits": [
	      {
	        "_index": "bookdb_index",
	        "_type": "book",
	        "_id": "1",
	        "_score": 0.28168046,
	        "_source": {
	          "title": "Elasticsearch: The Definitive Guide",
	          "authors": [
	            "clinton gormley",
	            "zachary tong"
	          ],
	          "summary": "A distibuted real-time search and analytics engine",
	          "publish_date": "2015-02-07",
	          "num_reviews": 20,
	          "publisher": "manning"
	        }
	      },
	      {
	        "_index": "bookdb_index",
	        "_type": "book",
	        "_id": "4",
	        "_score": 0.24144039,
	        "_source": {
	          "title": "Solr in Action",
	          "authors": [
	            "trey grainger",
	            "timothy potter"
	          ],
	          "summary": "Comprehensive guide to implementing a scalable search engine using Apache Solr",
	          "publish_date": "2014-04-05",
	          "num_reviews": 23,
	          "publisher": "manning"
	        }
	      }
	    ]

下面是完整 Body 版本的查询，生成相同的内容：

	{
	    "query": {
	        "multi_match" : {
	            "query" : "guide",
	            "fields" : ["_all"]
	        }
	    }
	}
	
`multi_match` 是 `match` 的作为在多个字段运行相同操作的一个速记法。`fields` 属性用来指定查询针对的字段，在这个例子中，我们想要对文档的所有字段进行匹配。两个 **API** 都允许你指定要查询的字段。例如，查询 `title` 字段中包含 `in Action` 的书：

    GET /bookdb_index/book/_search?q=title:in action
    
    [Results]
    "hits": [
          {
            "_index": "bookdb_index",
            "_type": "book",
            "_id": "4",
            "_score": 0.6259885,
            "_source": {
              "title": "Solr in Action",
              "authors": [
                "trey grainger",
                "timothy potter"
              ],
              "summary": "Comprehensive guide to implementing a scalable search engine using Apache Solr",
              "publish_date": "2014-04-05",
              "num_reviews": 23,
              "publisher": "manning"
            }
          },
          {
            "_index": "bookdb_index",
            "_type": "book",
            "_id": "3",
            "_score": 0.5975345,
            "_source": {
              "title": "Elasticsearch in Action",
              "authors": [
                "radu gheorge",
                "matthew lee hinman",
                "roy russo"
              ],
              "summary": "build scalable search applications using Elasticsearch without having to do complex low-level programming or understand advanced data science algorithms",
              "publish_date": "2015-12-03",
              "num_reviews": 18,
              "publisher": "manning"
            }
          }
        ]
然而， 完整的 DSL 给予你灵活创建更复杂查询和指定返回结果的能力（后面，我们会一一阐述）。在下面例子中，我们指定 size 限定返回的结果条数，from 指定起始位子，_source 指定要返回的字段，以及语法高亮

    POST /bookdb_index/book/_search
    {
        "query": {
            "match" : {
                "title" : "in action"
            }
        },
        "size": 2,
        "from": 0,
        "_source": [ "title", "summary", "publish_date" ],
        "highlight": {
            "fields" : {
                "title" : {}
            }
        }
    }
    
    [Results]
    "hits": {
        "total": 2,
        "max_score": 0.9105287,
        "hits": [
          {
            "_index": "bookdb_index",
            "_type": "book",
            "_id": "3",
            "_score": 0.9105287,
            "_source": {
              "summary": "build scalable search applications using Elasticsearch without having to do complex low-level programming or understand advanced data science algorithms",
              "title": "Elasticsearch in Action",
              "publish_date": "2015-12-03"
            },
            "highlight": {
              "title": [
                "Elasticsearch <em>in</em> <em>Action</em>"
              ]
            }
          },
          {
            "_index": "bookdb_index",
            "_type": "book",
            "_id": "4",
            "_score": 0.9105287,
            "_source": {
              "summary": "Comprehensive guide to implementing a scalable search engine using Apache Solr",
              "title": "Solr in Action",
              "publish_date": "2014-04-05"
            },
            "highlight": {
              "title": [
                "Solr <em>in</em> <em>Action</em>"
              ]
            }
          }
        ]
      }
      
注意：对于多个词查询，`match` 允许指定是否使用 `and` 操作符来取代默认的 `or` 操作符。你还可以指定 `mininum_should_match` 选项来调整返回结果的相关程度。具体看后面的例子。

未完待续



> 引用自：[23 USEFUL ELASTICSEARCH EXAMPLE QUERIES](http://distributedbytes.timojo.com/2016/07/23-useful-elasticsearch-example-queries.html)

























