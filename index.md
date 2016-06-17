# Caffe 笔记

注：

:   ipython notebook 十分好用，这里的一些笔记直接写在了 notebook 里，存在 GitHub 上。
    关于如何使用 notebook，可以参考我的博客：
    [远程使用 Jupyter Notebook （iPython Notebook）](http://tangzx.qiniudn.com/post-0109-remote-jupyter.html)[^remote-jupyter]。

```bash
# 在服务器上（当然你也可以 ssh 进入服务器运行 ipython notebook）
ipython notebook --no-browser --port=8889

# 沟通服务器和本机的两个 port
ssh -N -f -L localhost:8888:localhost:8889 tzx@192.168.1.106

# 最后用浏览器打开本地 localhost:8888 就可以看到服务器运行的 notebook 了
```

---

-   [暂未归类笔记](misc.html){title=misc.md}

## Caffe

My fork: [district10/caffe-rc3: Play with caffe.](https://github.com/district10/caffe-rc3)

:   注解过的 notebook：^[虽然 GitHub 现在支持显示 `.ipynb` 文件，我还是更喜欢 jupyter 提供的 nbviewer 链接。]

    -   [00-classification.ipynb](http://nbviewer.jupyter.org/github/district10/caffe-rc3/blob/master/examples/00-classification.ipynb)
    -   [01-learning-lenet.ipynb](http://nbviewer.jupyter.org/github/district10/caffe-rc3/blob/master/examples/01-learning-lenet.ipynb)
    -   [02-brewing-logreg.ipynb](http://nbviewer.jupyter.org/github/district10/caffe-rc3/blob/master/examples/02-brewing-logreg.ipynb)
    -   [03-fine-tuning.ipynb](http://nbviewer.jupyter.org/github/district10/caffe-rc3/blob/master/examples/03-fine-tuning.ipynb)
    -   [net_surgery.ipynb](http://nbviewer.jupyter.org/github/district10/caffe-rc3/blob/master/examples/net_surgery.ipynb)
    -   [detection.ipynb](http://nbviewer.jupyter.org/github/district10/caffe-rc3/blob/master/examples/detection.ipynb)

    接口说明：

    -   [python interface](python-interface.html){title=python-interface.md}
    -   [matlab interface](matlab-interface.html){title=matlab-interface.md}

## HED 边缘检测

My fork: [district10/hed](https://github.com/district10/hed)

:   这里有两份注释过的笔记：

    -   [HED-tutorial.ipynb](http://nbviewer.jupyter.org/github/district10/hed/blob/master/examples/hed/HED-tutorial.ipynb)

        一个用 pretrained 的 model 来测试，得到边缘结果图。这个例子运行起来很快。

    -   [solve.ipynb](http://nbviewer.jupyter.org/github/district10/hed/blob/master/examples/hed/solve.ipynb)

        训练 model。当然，训练起来很慢。需要 days，不是 hours。

[^remote-jupyter]: 简单说，分为三步：

    ```bash
    # 在服务器上（当然你也可以 ssh 进入服务器运行 ipython notebook）
    ipython notebook --no-browser --port=8889

    # 沟通服务器和本机的两个 port
    ssh -N -f -L localhost:8888:localhost:8889 tzx@192.168.1.106

    # 最后用浏览器打开本地 localhost:8888 就可以看到服务器运行的 notebook 了
    ```
