---
layout: post
title: "ReactJS：使用 webpack 部署"
description: ""
category: Javascript
tags: [react, webpack]
---
{% include JB/setup %}


最近我开始使用 **React** 和 **webpack** 进行开发，在效率方面得到了很大的提升。我发现这样的组合让前端开发更加有趣，你们也应该试试。

## 第一部分－安装初始化

我们的第一个初始化安装工作，就是为这个应用创建一个文件夹（我们把它命名 *react-webpack*）；进入，执行它把你的项目初始化成一个 **npm** 包：

	$ npm init

### 安装 react 和 webpack

然后当然需要安装 `react` 的 **npm** 包：

	$ npm install --save react

安装完，再安装我们所有需要开发依赖。为此，我门还需要安装 `webpack` 和 `webpack-dev-server` 来搭建我们的 **App**。我们还需要安装 `jsx-loader` 来让 `webpack` 把 *jsx* 文件转化成 *js* 文件：

	$ npm install --save-dev webpack webpack-dev-server
	$ npm install --save-dev jsx-loader
	
### 你的第一个组件

现在，我们开始编写我们的第一个 **ReactJS** 基本组件，我们称它为 *Hello.jsx*：

	/** @jsx React.DOM */
	'use strict'
	var React = require('react')
	module.exports = React.createClass({
	    displayName: 'HelloReact',
	    render: function(){
	        return <div>Hello React</div>
	    }
	})
	
创建 *index.jsx* 作为我们 **App** 的访问入口：

	/** @jsx React.DOM */
	'use strict'
	var ReactDOM = require('react-dom')
	var Hello = require('./Hello')
	ReactDOM.renderComponent(
		<Hello />,
		document.getElementById('content')
	)

### 配置 webpack

然后，我们需要把所有文件打包到一个单一 *bundle* 文件中，这就是我们使用 **webpack** 的原因。我们需要创建一个 *webpack.config.js* （**webpack** 在启动时要查找的默认文件）。它是这样子的：

	module.exports = {
	    entry: './index.jsx',
	    output: {
	        filename: 'bundle.js', // 这是默认的文件名
	        // 在这个文件夹下我们的 bundle 文件将可用a
	        // 当启动 webpack-dev-server 时，确保 8090 端口可以被使用
	        publicPath: 'http://localhost:8090/assets'
	    },
	    module: {
	        loaders: [
	            {
	                // 告诉 webpack 使用 jsx-loader 来解析所有的 *.jsx 文件
	                test: /\.jsx$/,
	                loader: 'jsx-loader?insertPragma=React.DOM&harmony'
	            }
	        ]
	    },
	    externals: {
	        // don't bundle the 'react' npm package with our bundle.js
	        // but get it from a global 'React' variable
	        'react': 'React'
	    },
	    resolve: {
	        extensions: ['', '.js', '.jsx']
	    }
	}
	
这个 **webpack** 配置都在注释中解释，因此你应该对 **webpack** 有了一些初步的了解。现在已经足够，可以开始编写我们的 *index.html*，然后启动我们的 app。

### index.html

我们需要创建一个 *index.html* 文件，然后提供 web 服务，因此我们需要安装 `http-module`

	$ npm install --save-dev http-server

*index.html* 应该像这样：

	<!DOCTYPE html>
	<html>
	<head>
	    <title>Basic Property Grid</title>
	    <!-- include react -->
	    <script src="./node_modules/react/dist/react-with-addons.js"></script>
	</head>
	<body>
	    <div id="content">
	        <!-- this is where the root react component will get rendered -->
	    </div>
	    <!-- include the webpack-dev-server script so our scripts get reloaded when we make a change -->
	    <!-- we'll run the webpack dev server on port 8090, so make sure it is correct -->
	    <script src="http://localhost:8090/webpack-dev-server.js"></script>
	    <!-- include the bundle that contains all our scripts, produced by webpack -->
	    <!-- the bundle is served by the webpack-dev-server, so serve it also from localhost:8090 -->
	    <script type="text/javascript" src="http://localhost:8090/assets/bundle.js"></script>
	</body>
	</html>
	
注意：*index.html* 需要从 *node_modules* 文件夹中引入 `react` 模块；然后引入 *webpack-dev-server.js* 脚本（它由 `webpack-dev-server` 服务提供，之前我们设置成 8090 端口）。当我们的文件被变更的时候，这个脚本会接收到服务器端的通知，然后载入一个新版本 `bundle` 文件。

最后，我们引入 *bundle.js*(也是由 `webpack-dev-server` 服务提供)。注意：*bundle* 文件存在于缓存中－它不会在你硬盘中创建。这个使得 `webpack-dev-server` 能够快速响应代码变更时重新绑定和载入。

### 准备好启动脚本

最后一件事情就是添加三个脚本实体到 *package.json* 中：

	{
	  "name": "d3-react",
	  "version": "1.0.0",
	  "description": "",
	  "main": "index.js",
	  "scripts": {
	    "start": "npm run serve | npm run dev",
	    "serve": "./node_modules/.bin/http-server -p 8088",
	    "dev": "webpack-dev-server --progress --colors --port 8090"
	  },
	  "author": "",
	  "license": "ISC",
	  "dependencies": {
	    "react-dom": "^0.14.6",
	    "react": "^0.14.6"
	  },
	  "devDependencies": {
	    "http-server": "^0.8.5",
	    "jsx-loader": "^0.13.2",
	    "webpack": "^1.12.11",
	    "webpack-dev-server": "^1.14.1"
	  }
	}
	
我们要做的就是增加三个命令，是它们能通过 `npm run <cmd>` 调用。

* `serve` - `npm run serve` - 在当前目录启动一个 **http** 服务，端口 8080
* `dev` - `npm run dev` - 在端口 8090 启动 `webpack-dev-server` 服务
* `start` - `npm run start` -  先执行 `serve` 再执行 `dev`

### 启动

现在我们都准备好了
	
	$ npm run start

如果一切顺利，你应该可以打开 [http://localhost:8090/webpack-dev-server/](http://localhost:8090/webpack-dev-server/) ，得到一条问候信息：

	Hello React
	
现在如果你使用编辑器改变一行代码，浏览器将会自动重载。

下面是最终的目录结构：

	.
	├── hello.jsx
	├── index.html
	├── index.jsx
	├── node_modules
	├── package.json
	└── webpack.config.js

> 译自：[React with webpack - part 1](http://jslog.com/2014/10/02/react-with-webpack-part-1/)