---
categories:
- data_analytics
date: "2016-12-03T00:00:00Z"
description: ""
tags:
- R
- python
title: 'Jupyter: Os X 下修改默认打开的浏览器'
---

由于 **Os X** 默认浏览器 **Safari** 下，Jupyter 的样式会有异常，只好切换到 **Chrome** 上了。

1. 生成用户根目录下的配置文件，如果你在的用户根目录下能找到这个文件 *~/.jupyter/jupyter_notebook_config.py*，则忽略此步骤；默认情况下，木有这个文件的，命令如下：

		$ jupyter notebook --generate-config
	
2. 修改 *~/.jupyter/jupyter_notebook_config.py* 配置表中的 `c.NotebookApp.browser` 值，我使用的是 **Chrome**：

		... # 我的这个配置在第86行
		c.NotebookApp.browser = 'open -a /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome %s'
		# c.NotebookApp.browser = 'open -a {这里替换成你要使用的浏览器app所在路径} %s'
		...
		
> #### 测试你的打开浏览器的脚本是否可用
> 		$ open -a {这里替换成你要使用的浏览器app所在路径}
> 这是浏览器会自动弹出，否则你得检查一下的浏览器安装路径是不是写错（应该不可能没装好吧，^_^）
		
搞定，你就可以用你最喜欢的浏览器上开发了
		
> 参考： [Changing browser for IPython Notebook from system default](http://stackoverflow.com/questions/16704588/changing-browser-for-ipython-notebook-from-system-default)







