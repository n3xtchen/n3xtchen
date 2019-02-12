---
layout: post
title: "极简教程: 使用 matplotlib 绘制 GIF 动图"
date:   2019-02-12 13:46:13 +0800
category: "python"
---

开门见山，直接上例子：

![gif 动图](http://p.aybe.me/blog/line.gif "gif 动图")

有如下特点：

1. 散点图的部分是不变的；线是移动的
2. X  轴标题每一祯改变一次

## DEMO 的环境

- Ubuntu 18.04.2 LTS
- conda 4.6.3
- Python 3.7.2

## 创建 virtualenv

    ichexw at n3xt-Studio -> conda create --name matplot-gif python=3.7
    ichexw at n3xt-Studio -> conda activate matplot-gif

## 安装必要的依赖

### 安装 matplotlib

    (matplotlib-gif) ichexw at n3xt-Studio -> conda install matplotlib


### 安装 imagemagick

    (matplotlib-gif) ichexw at n3xt-Studio -> conda install -c conda-forge imagemagick

## 代码实现

```Python
import sys
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation

# 创建图层和布局
fig, ax = plt.subplots()
fig.set_tight_layout(True)

# 查看图标的尺寸。如果你保存成 gif 的时候，你需要提供 DPI
print('fig size: {0} DPI, size in inches {1}'.format(
    fig.get_dpi(), fig.get_size_inches()))

# 绘制一个散点图（不会重绘），和初始的线
x = np.arange(0, 20, 0.1)
ax.scatter(x, x + np.random.normal(0, 3.0, len(x)))
line, = ax.plot(x, x - 5, 'r-', linewidth=2)

def update(i):
    label = 'timestep {0}'.format(i)
    print(label)
    
    # 更新线和坐标轴标签
    line.set_ydata(x - 5 + i)
    ax.set_xlabel(label)
    
    # 返回要重绘的对象
    return line, ax

if __name__ == '__main__':
    # FunAnimation 将会在每一帧执行一次 update
    # frames: 帧数
    # interval: 每帧的间隔
    anim = FuncAnimation(fig, update, frames=np.arange(0, 10), interval=200)
	if len(sys.argv) > 1 and sys.argv[1] == 'save':
        # 如果第一参数是 save，教会保存成 gif
        # **重点**
        # dpi: 保存的尺寸
        # writer: 使用的渲染器，我们制定成 imagemagick
        anim.save('line.gif', dpi=80, writer='imagemagick')
    else:
        # 否则直接展示
        plt.show()
```

