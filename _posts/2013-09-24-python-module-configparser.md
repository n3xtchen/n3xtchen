---
layout: post
title: "Python 常用模块 - 通用配置configParser"
description: ""
category: Python
tags: [python, module]
---
{% include JB/setup %}

### 生成配置文件

    import ConfigParser

    config = ConfigParser.RawConfigParser()

    config.add_section('Section1')
    config.set('Section1', 'an_int', '15')
    config.set('Section1', 'a_bool', 'true')
    config.set('Section1', 'a_float', '3.1415')
    config.set('Section1', 'baz', 'fun')
    config.set('Section1', 'bar', 'Python')
    config.set('Section1', 'foo', '%(bar)s is %(baz)s!')

    # Writing our configuration file to 'example.cfg'
    with open('example.cfg', 'wb') as configfile:
        config.write(configfile)

### 读取配置

    import ConfigParser

    config = ConfigParser.RawConfigParser()
    config.read('example.cfg')

    # getfloat() raises an exception if the value is not a float
    # getint() and getboolean() also do this for their respective types
    a_float = config.getfloat('Section1', 'a_float')
    an_int = config.getint('Section1', 'an_int')
    print a_float + an_int

    # Notice that the next output does not interpolate '%(bar)s' or '%(baz)s'.
    # This is because we are using a RawConfigParser().
    if config.getboolean('Section1', 'a_bool'):
            print config.get('Section1', 'foo')
