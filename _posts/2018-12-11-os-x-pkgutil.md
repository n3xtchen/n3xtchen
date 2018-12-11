---
layout: post
title:  OsX: 完全卸载攻略（pkg）
date:   2018-12-11 09:40:36 +0800
category: osx
tag: []
---

在 Os X 清理程序过程，遇到 .pkg 是相当头痛的事情，因为安装的文件不在一块，所以手动删不全；对于洁癖的我，是不可容忍的。

幸好，苹果给我留了一条后路，pkguitl，虽然简陋但是够用。

废话少说，看用法。

先看，我们安装了哪些应用；打开终端，输入下面命令：

    ichexw -> pkgutil --pkgs
    ...
    com.apple.pkg.MAContent10_AssetPack_0357_EXS_BassAcousticUprightJazz
	com.apple.pkg.GatekeeperConfigData.16U1642
	com.apple.pkg.GatekeeperConfigData.16U1118
	com.apple.pkg.MAContent10_AssetPack_0320_AppleLoopsChillwave1
	com.apple.pkg.ChineseWordlistUpdate.14U1359
	com.apple.pkg.ChineseWordlistUpdate.14U1365
    net.wisevpn.wiseVPN
	com.rescuetime.RescueTime
	com.youku.mac
	com.silabs.driver.CP210xVCPDriver
	org.virtualbox.pkg.vboxkexts
	com.amazon.Kindle
	com.xiami.client
	com.microsoft.package.Fonts
	com.tinyspeck.slackmacgap
	cx.c3.theunarchiver
	com.apple.pkg.MobileAssets
	com.GoPro.pkg.GoProApp
	com.oracle.jre
	...
	    
可以看到， com.apple 打头的是系统自己的，其他就是自己安装的。

我想要卸载旧版本的 java 包，找出它都被安装到哪里了；输入下面命令：

    ichexw -> pkgutil --files com.oracle.jdk7u80
    Contents
	Contents/Home
	Contents/Home/COPYRIGHT
	Contents/Home/LICENSE
	Contents/Home/README.html
	Contents/Home/THIRDPARTYLICENSEREADME-JAVAFX.txt
	Contents/Home/THIRDPARTYLICENSEREADME.txt
	Contents/Home/bin
	Contents/Home/bin/appletviewer
	Contents/Home/bin/apt
	...

寻找文件的安装根目录：

    ichexw -> pkgutil --file-info com.oracle.jdk7u80
	volume: /
	path: com.oracle.jdk7u80
	ichexw at ichexws-MBPR in /  ○ cd /

删除对应的文件：

	ichexw -> pkgutil --only-files --files com.oracle.jdk7u80 | tr '\n' '\0' | xargs -n 1 -0 sudo rm -i
	
让系统忘记这个 pkg
	
	ichexwe -> sudo pkgutil --forget the-package-name.pkg
	
Happy Ending!




