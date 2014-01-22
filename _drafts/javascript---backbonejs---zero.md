---
layout: post
title: "Backbone.js - Zero Up"
description: ""
category: javascript
tags: ['js', 'backbone']
---
{% include JB/setup %}

### 从设置开始

让我们定义一些我们将要使用的模板(Boilerplate)标记来指定 Backbone 需要的依赖
。这些模板将可能在将来一直被复用。

    <!DOCTYPE HTML>
    <html>
      <head>
        <meta charset="UTF-8">
        <title>Title</title>
      </head>
      <body>

        <script src="assets/js/jquery.min-1.9.1.js"></script>
        <script src="assets/js/underscore-min.js"></script>
        <script src="assets/js/backbone-min.js"></script>
        <script>
          // Code Here
        </script>
      </body>
    </html>

### 模型(Models)

Backbone 模型包含应用数据以及这个数据的相关逻辑。例如，我们可以使用一个模型
来展示代办事务的概念，包括它的属性，例如标题和完成情况。

    // 声明一个 backbone model类,定义方法
    var Todo  = Backbone.Model.extend({
      // 初始化
      // initialize() 方法将在新实例被创建到时候被调用。
      initialize  : function(){
                      console.log('This model has been initialized.');

                      // 监听整个对象的变化
                      this.on('change', function(){
                        console.log('Model have changed.');
                      });
                      // 只监听单个属性的变化，格式: change:`attr_name`
                      this.on('change:title' function(){
                        console.log('Model Title have changed.');
                      });

                      // 监听对象的验证返回错误
                      this.on('invalid', function(model, error){
                        console.log(error);
                      });
                    },

      // 设置数据属性
      // new Todo({title: '标题', completed : False}), 这样将会给这个对象赋值
      // 否则将如下将会，作为默认值
      default : {
                  title : '',
                  completed : false
                },

      // model验证
      // 默认，验证在调用 save() 方法的时候被调用
      // 或者，调用 unset(),set() 调用是传入 {validate: true} 参数强制调用
      //
      // 验证函数尽可能简练，当然必要时可以复杂。只有在验证无效的时候需要返回信
      // 息。
      //
      // 验证不通过，将错误信息作为 validationError 属性赋值给 model，
      // 可以使用 invaild 事件捕获错误，并且 model 的数据将不会被改变。
      validate: function(attrs){
                  // 验证逻辑在这里
                  if (attrs.title === undefined)
                    return '记住给标题赋值';
                  // 返回错误信息
                }
    });

    var myTodo = new Todo();

    // Model.get() 来获取对象的属性
    myTodo.get('title');  // 返回 ''
    myTodo.get('completed');  // 返回 false

    // 如果你需要读取或者克隆一个model对象的所有数据属性，使用 toJSON() 方法，
    myTodo.toJSON();  // 返回 {title:'', completed:false}

    // Model.set() 设置对象属性
    // 赋值包含一个或多个属性的哈希数组给 model
    //
    // 当这些属性中任何一个改变了 model 的状态(即model 的 default 数据属性),
    // 将会触发绑定在该属性的 change 事件
    myTodo.set('title', '新标题');
    mytodo.set('completed', true);

    myTodo.toJSON();  // 返回 {title:'新标题', completed:true}

    myTodo.set({
      title:'新标题－改', 
      completed:False
    });

    myTodo.toJSON();  // 返回 {title:'新标题－改', completed:False}

    // 传入 {slient: true}, 屏蔽change等事件，但仅仅针对本次操作
    myTodo.set({
      title:'新标题－改', 
      completed:False
    },{
      silent: true
    });

    // 传入 {validate: true}, 强制触发 validate 事件
    myTodo.set({
      title:'新标题－改', 
      completed:False
    },{
      validate: true
    });

### 视图(Views)

Backbone 中的 view 不包含你应用的 HTML 脚本；它保存 model 展示背后的逻辑。
它通过使用 Javascript 模版(例如，Underscore microtemplate，Mustache，
JQuery-tmpl等等)来实现。view 的 render() 将会绑定到 model 的 change() 事件中
，这样视图将实时反应 model 的变化，而不需要全页刷新。

创建一个 view 相对简单一些，和创建 model 类似。

#### el

view 的核心属性是 el；它是 DOM 元素的索引，所有的视图都必须包含。view 可以使
用 el 来编写元素内容，并直接插入到 DOM 中。由于浏览器执行最少数量的重新布局
和渲染，所以更新相当迅速。

