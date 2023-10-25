---
categories:
- Python
date: "2013-11-25T00:00:00Z"
description: ""
tags:
- python
- django
title: Python Django - simple guide
---

### 一.创建项目

    $ django-admin.py startproject proj_name
    $ tree -L 2 proj_name
    ├── proj_name
    │   ├── __init__.py
    │   ├── __init__.pyc
    │   ├── settings.py
    │   ├── settings.pyc
    │   ├── urls.py
    │   └── wsgi.py
    └── manage.py

> 启动服务器
>       $ cd proj_name
>       $ python manage.py runserver

### 二.数据库配置

    $ vim proj_name/setting.py

    DATABASES = {
        'default': {
                'ENGINE': 'django.db.backends.sqlite3',
                'NAME': 'database.db',
                'USER': '',
                'PASSWORD': '',
                'HOST': '',
                'PORT': '',
            }
    }

### 三.创建模块

    $ python manager.py startapp app_name
    $ tree -L 2 proj_name
    ├── proj_name
    │   ├── __init__.py
    │   ├── __init__.pyc
    │   ├── settings.py
    │   ├── settings.pyc
    │   ├── urls.py
    │   └── wsgi.py
    ├── app_name
    │   ├── __init__.py
    │   ├── models.py
    │   ├── tests.py
    │   └── views.py
    └── manage.py

### 四.激活模块

    $ vim proj_name/settings.py

    INSTALLED_APPS = (
            'django.contrib.auth',
            'django.contrib.contenttypes',
            'django.contrib.sessions',
            'django.contrib.sites',
            'django.contrib.messages',
            'django.contrib.staticfiles',
            # Uncomment the next line to enable the admin:
            # 'django.contrib.admin',
            # Uncomment the next line to enable admin documentation:
            # 'django.contrib.admindocs',
            'app_name',  // 添加这一行
            )

    $ vim proj_name/urls.py

    url(r'^app_name/', include(app_name.urls))

    $ vim app_name/urls.py

    # app_name/urls.py
    from django.conf.urls import patterns, include, url

    urlpatterns = patterns('',
            )

### 五.创建自己的模型(Models)

    $ vim app_name.models.py

    from django.db import models
    
    # Create your models here.
    class Blog(models.Model):
        title   = models.CharField(max_length=50)
        content = models.TextField()


