---
date: "2017-01-23T00:00:00Z"
description: ""
tags: []
title: 踩坑大回放：webpack2 + babel + react + eslint
---

一时兴起，开始 **webpack2**，配置成功，却是比前一个版本人性化了不少；接着添加 **react** + **redux**，结果遇到了一堆坑（一部分是之前遇到），于是有了这篇博客来记录此次踩坑过程。

### #1 Module build failed: SyntaxError: Unexpected token - 无法正常解析JSX

先来看看错误：

	ERROR in ./src/index.js
	Module build failed: SyntaxError: Unexpected token (4:2)
	
	  2 |
	  3 | ReactDOM.render(
	> 4 |   <h1>Hello, world!</h1>,
	    |   ^
	  5 |   document.getElementById('root')
	  6 | )
	  
这个是我的 babel 配置:

	# package.json
	...
	  "babel": {
	    "presets": [
	      "es2015"
	    ]
	  }
	...

因为我的babel 转码规则（presents）中没有 **react**。解决方法：

1. 安装 **react** 转码规则

		$ yarn add -D babel-present-react
	  
2. 配置 **babel**：
		
		# package.json
		...
		  "babel": {
		    "presets": [
		      "es2015", 
		      "react"		# 添加了这一行
		    ]
		  }
		...
		
### #2 error  'React' is defined but never used  no-unused-vars

把错误解决了，紧接着 **eslint** 开始发难，下面是我报错的脚本:

	import React from 'react'
	import { render } from 'react-dom'
	
	render(
	  <h1>Hello, world!</h1>,
	  document.getElementById('root')
	)
	
为了解析 **JSX**，我们需要引入 `React`，这种类似 scala 隐式转换，把强迫症的 **eslint** 弄晕了，下面是我 eslint 的配置：

	# package.json
	...
	  "eslintConfig": {
	    "extends": [
	      "eslint:recommended"
	    ],
	    "env": {
	      "browser": true,
	      "node": true
	    }
	  },
	...
	  
需要为 **eslint** 添加 **react** 规则。解决方法：
	  
1. 安装 **react** 规则：

		$ yarn add -D eslint-plugin-react

2. 修改 **eslint** 配置：

		# package.json
		...  
		  "eslintConfig": {
		    "plugins": ["react"],	# 添加react规则插件
		    "extends": [
		      "eslint:recommended",
		      "plugin:react/recommended"	# 使用react规则
		    ],
		    "env": {
		      "browser": true,
		      "node": true
		    }
		  },
		...
  
 你以为问题已经解决，还没完呢；

### #3 error  Parsing error: The keyword 'import' is reserved
  
 
原因 **es5** 没有 `import` 这个关键词， **eslint** 还不知道通过 **Babel** 使用的 ES6 特性，于是作出如下修改：
  
	# package.json
	...  
	  "eslintConfig": {
	    "parserOptions": {
	      "sourceType": "module",
	      "ecmaFeatures": {
	        "jsx": true
	      }
	    },	# 添加了这几行
	    "plugins": [
	      "react"
	    ],
	    "extends": [
	      "eslint:recommended",
	      "plugin:react/recommended"
	    ],
	    "env": {
	      "browser": true,
	      "node": true
	    }
	  },
	...
	
总算大功告成，🤝