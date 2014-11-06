#!/usr/bin/ruby -w
# -*- coding: utf-8 -*- 

require 'thin'
module Plank
  class Server

    # 常量
    ENVIRONMENT = "development"
    HOST = "localhost"
    PORT = "9292"

    def initialize(args)
      # 初始化
      #  前导 @ 修饰变量说明是实例变量，double @ 是类变量 
      @options = default_options # 配置设定
      # hash[:var] 等同于 hash['var'], 
      @options[:config] = args[0] # 实际取的是 ARGV[0]，它通过 new(ARGV)
      # 这个是文件名，这个例子应该是 test.pu
      @app = build_app
    end

    def start
      server.run @app, @options
    end

    def self.start
      # 类方法，等同于 Server.start
      # Plank::Server.start 
      new(ARGV).start # ARGV 是命令行传入的参数表，它传给了对象本身
    end

    private
    # 下面定义的是私有方法

    def default_options
      # 默认配置
      {
        environmet: ENVIRONMENT,
        Port: PORT,
        Host: HOST
      }
    end

    def build_app
      # 解析应用代码，返回可执行的对象
      Plank::Builder.parse_file(@options[:config])
    end

    def server
      @server ||= Plank::Handler.default
    end

  end

  class Builder

    def initialize(&block)
      instance_eval(&block) if block_given?
    end

    def run(app)
      @run = app
    end

    def to_app
      @run
    end

    def self.parse_file(file)
      # 解析文件
      cfg_file = File.read(file)
      new_from_string(cfg_file)
    end

    def self.new_from_string(builder_script)
      # 执行文本中 Ruby  脚本
      eval "Plank::Builder.new {\n" + builder_script + "\n}.to_app"
    end
  end

  module Handler

    def self.default
      Plank::Handler::Thin
    end

    class Thin
      def self.run(app, options={})
        host = options[:Host]
        port = options[:Port]
        args = [host, port, app, options]
        # *args，可变参数，等同于 ::Thin::Server.new(host, port, app, options)
        server = ::Thin::Server.new(*args)
        server.start
      end
    end
  end

end

