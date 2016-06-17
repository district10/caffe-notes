## [Caffe | Caffe Tutorial](http://caffe.berkeleyvision.org/tutorial/)

-   Philosophy

-   Tour

    +   [Nets, Layers, and Blobs](http://caffe.berkeleyvision.org/tutorial/net_layer_blob.html): the anatomy of a Caffe model.

        在 caffe 的模型里，layer 是一层层定义，从下往上是 data to loss 的过程。数据和其导数在网络层中前后传播，
        通过的就是 blob，它既是 array，又是 unified memeroy interface for the network（就像 struct）。

        层（layer）是来自“模型”和“计算”。
        网（net）来自 layer 和 layer 的连接。

        说 blob，就是说它如何在 layer 和 net 里存储和沟通（communicate）。

        blob 首先是数据存储的 wrapper，屏蔽了 CPU 和 GPU 之间的 gap，可以定义为：
        “blob is an N-dimensional array stored in a C-contiguous fashion.”。

        可以存储图片，模型参数（model parameters），已经 derivatives for optimization（优化过程中的产生的数据？）。

        既然是 N-dim array，其计算方式为：For example, in a 4D blob, the value
        at index (n, k, h, w) is physically located at index
        `((n * K + k) * H + h) * W + w`，并没有什么独特的。

        上面的 K，H，W 是 k，h，w 的个数。看成 RGB 图片的话，就是 w,h 是宽和高，
        k 是 channel 数目也就是 3，n 是批处理的个数，也就是一次处理多少张图片。
        如果从右向左看，w,h 正好对饮 OpenCV 坐标里的 x 和 y。不同的是 OpenCV 里，
        图片的 rgb 通常都放在一起，而不是一个 channel 一个 channel 分开。

        -   Number / N is the batch size of the data. Batch processing achieves
            better throughput for communication and device processing. For an
            ImageNet training batch of 256 images N = 256.
        -   Channel / K is the feature dimension e.g. for RGB images K = 3.

        上面是说 Number（N）是数据批处理的尺寸。Channel（K）是 feature 的维度。

        caffe 原来就是做图像的，所以一般都是 4D，但也可以是其他维度比如 2D。

        Parameter blob dimensions vary according to the type and configuration
        of the layer. For a convolution layer with 96 filters of 11 x 11
        spatial dimension and 3 inputs the blob is 96 x 3 x 11 x 11.

        如上面，filter 的 96 x 3 x 11 x 11 一定要理解。

        For an inner product / fully-connected layer with 1000 output channels
        and 1024 input channels the parameter blob is 1000 x 1024.

        `不太理解为什么要这么定义！`{.todo}

        blob 里有两大部分，一个是 data，一个是 diff，前者是我们传进去的数据，后者是
        网络自己训练出来的 gradient。这些数据可以在 CPU 中，也可以在 GPU 中，
        数据访问可以是 const 方式，也可以是 mutable。

        ```cpp
        const Dtype* cpu_data() const;
        Dtype* mutable_cpu_data();
        ```

        再复杂一点，If you want to check out when a Blob will copy data, here is an illustrative example:

        ```cpp
        // Assuming that data are on the CPU initially, and we have a blob.
        // const Dtype* foo;
        // Dtype* bar;
        // foo = blob.gpu_data(); // data copied cpu->gpu.
        // foo = blob.cpu_data(); // no data copied since both have up-to-date contents.
        // bar = blob.mutable_gpu_data(); // no data copied.
        // // ... some operations ...
        // bar = blob.mutable_gpu_data(); // no data copied when we are still on GPU.
        // foo = blob.cpu_data(); // data copied gpu->cpu, since the gpu side has modified the data
        // foo = blob.gpu_data(); // no data copied since both have up-to-date contents
        // bar = blob.mutable_cpu_data(); // still no data copied.
        // bar = blob.mutable_gpu_data(); // data copied cpu->gpu.
        // bar = blob.mutable_cpu_data(); // data copied gpu->cpu.
        ```

        The layer is the essence of a model and the fundamental unit of
        computation. Layers convolve filters, pool, take inner products, apply
        nonlinearities like rectified-linear and sigmoid and other elementwise
        transformations, normalize, load data, and compute losses like softmax
        and hinge. See the layer catalogue for all operations. Most of the
        types needed for state-of-the-art deep learning tasks are there.

        ![A layer takes input through bottom connections and makes output
            through top connections.](http://caffe.berkeleyvision.org/tutorial/fig/layer.jpg)

        每个 layer 有三种重要的计算：setup，forward 和 backward。

        -   setup 是初始化时候用的，初始化 layer 以及 layer 的连接。只会调用一次。
        -   forward，从下往上；
        -   backward，从上往下；

        其中 forward/backward 都有 cpu 和 gpu 的各自实现。
        （YangQing Jia 的 caffe2 里准备把 forward/backward 整合成为一个 run。）

        Layers have two key responsibilities for the operation of the network
        as a whole: a forward pass that takes the inputs and produces the
        outputs, and a backward pass that takes the gradient with respect to
        the output, and computes the gradients with respect to the parameters
        and to the inputs, which are in turn back-propagated to earlier layers.
        These passes are simply the composition of each layer’s forward and
        backward.

        网就是一个 DAG（有向无环图）。
        ![](http://caffe.berkeleyvision.org/tutorial/fig/logreg.jpg)

        ```json
        name: "LogReg"
        layer {
          name: "mnist"
          type: "Data"
          top: "data"
          top: "label"
          data_param {
            source: "input_leveldb"
            batch_size: 64
          }
        }
        layer {
          name: "ip"
          type: "InnerProduct"
          bottom: "data"
          top: "ip"
          inner_product_param {
            num_output: 2
          }
        }
        layer {
          name: "loss"
          type: "SoftmaxWithLoss"
          bottom: "ip"
          bottom: "label"
          top: "loss"
        }
        ```

        首先调用 `Net::Init()`{.cpp} 来初始化，立面会分别调用 layer 的
        `layer.SetUp()`{.cpp} 来初始化 layer。整个网络的构造（construction）是
        device agnostic（屏蔽了 CPU/GPU 的区别）。可以用 `Caffe::mode()`{.cpp}
        来查询模式，用 `Caffe::set_mode()`{.cpp} 来设置。

        模型用我纯文本定义在 `.prototxt` 文件（plaintext protocol buffer schema）里，
        训练后存成二进制文件 `.caffemodel`（binaryproto）。

        The model format is defined by the protobuf schema in [caffe.proto](https://github.com/BVLC/caffe/blob/master/src/caffe/proto/caffe.proto).
        The source file is mostly self-explanatory so one is encouraged to check it out.

        Caffe 用了 google 的 google protocal buffer，因为它的 txt 和 binary 等价，便于阅读，
        而且有 C++ 和 python 的接口。

    +   [Forward / Backward](http://caffe.berkeleyvision.org/tutorial/forward_backward.html): the essential computations of layered compositional models.

        ![](http://caffe.berkeleyvision.org/tutorial/fig/forward_backward.png)

        ![](http://caffe.berkeleyvision.org/tutorial/fig/forward.jpg){width=45%}
        ![](http://caffe.berkeleyvision.org/tutorial/fig/backward.jpg){width=45%}

        These computations follow immediately from defining the model: Caffe
        plans and carries out the forward and backward passes for you.

        -   The `Net::Forward()` and `Net::Backward()` methods carry out the
            respective passes while `Layer::Forward()` and `Layer::Backward()`
            compute each step.
        -   Every layer type has `forward_{cpu,gpu}()` and `backward_{cpu,gpu}()`
            methods to compute its steps according to the mode of computation.
            A layer may only implement CPU or GPU mode due to constraints or
            convenience.

        solver 可以优化模型，听过 forward 产生 output 和 loss，通过 backward 生成
        模型的 gradient，然后把 gradient 考虑进模型通过试图修改 weights 来降低 loss。

        Division of labor between the Solver, Net, and Layer keep Caffe modular and open to development.

        上面这句话是说 solver 和 net 和 layer 各司其职，保证了 caffe 的模块化，
        使得它便于在原有基础上修改和再开发。

        更多参见：[Caffe | Layer Catalogue](http://caffe.berkeleyvision.org/tutorial/layers.html)。这里介绍了
        各层的参数配置。

    +   [Loss](http://caffe.berkeleyvision.org/tutorial/loss.html): the task to be learned is defined by the loss.

        机器学习里学习就是 loss 驱动的，loss 也常被称为 error，cost 以及 objective function（这个很牵强了，这是恰好你的
        objective 是降低 loss 而已。）。

        A loss function specifies the goal of learning by mapping **parameter settings**
        (i.e., the current network weights) to a scalar value specifying the “badness”
        of these parameter settings. Hence, the goal of learning is to find a
        setting of the weights that minimizes the loss function.

        loss 函数对当前网络的参数的好坏评价（用 badness 来衡量）是优化网络的基本出发。

        一个常用的 loss 函数就是 SoftmaxWithLoss，是“一个对其他”（one-versus-all），这样的一层
        可以用如下定义：

        ```json
        layer {
          name: "loss"
          type: "SoftmaxWithLoss"
          bottom: "pred"
          bottom: "label"
          top: "loss"
        }
        ```

        这个 top 是一个标量（scalar），也就是没有 shape 的（是不是可以把 shape 看成 `[]`）。

        这里有点凌乱。说是带有 `Loss` 后缀的 layer type 的层其实都可以算 loss（不只是最上面一层），
        而且默认的时候 layer 的第一个 top，的 loss weight 是 1，其他为 0。

        The final loss in Caffe, then, is computed by summing the total
        weighted loss over the network, as in the following pseudo-code:

        ```
        loss := 0
        for layer in layers:
          for top, loss_weight in layer.tops, layer.loss_weights:
              loss += loss_weight * sum(top)
        ```

        `这部分一定要好好理解清楚。`{.todo}

    +   [Solver](caffe.berkeleyvision.org/tutorial/solver.html): the solver coordinates model optimization.

        *   Stochastic Gradient Descent (type: `SGD`),
        *   AdaDelta (type: `AdaDelta`),
        *   Adaptive Gradient (type: `AdaGrad`),
        *   Adam (type: `Adam`),
        *   Nesterov’s Accelerated Gradient (type: `Nesterov`) and
        *   RMSprop (type: `RMSProp`)

        solver 通过不断调用 forward/backward，调整 parameters 来降低 loss。
        还可以周期性 test networks，还可以不断生成 model 和 solver state。
        比如 HUD 来进行边缘提取的时候，就生成了很多 `hud_iter_1000.caffemodel` 和
        `hud_iter_1000.solverstate` 文件。

        *   calls network forward to compute the output and loss
        *   calls network backward to compute the gradients
        *   incorporates the gradients into parameter updates **according to the solver method**
        *   updates the solver state according to learning rate, history, and method

        `然后下面讲了不同 solver 使用的方法（一堆数学公式），以后再细看。`{.todo}

    +   Layer Catalogue: the layer is the fundamental unit of modeling and computation – Caffe’s catalogue includes layers for state-of-the-art models.
    +   Interfaces: command line, Python, and MATLAB Caffe.
    +   Data: how to caffeinate data for model input.



## 关于 prototxt

这里讲得很详细：[Caffe | Layer Catalogue](http://caffe.berkeleyvision.org/tutorial/layers.html)。

介绍了每个层有哪些 required 参数，有哪些 optional 参数。
头文件，以及 CPU/GPU 实现的文件。

```bash
>>> ls src/caffe/layers/*loss*.cpp
src/caffe/layers/contrastive_loss_layer.cpp
src/caffe/layers/euclidean_loss_layer.cpp
src/caffe/layers/hinge_loss_layer.cpp
src/caffe/layers/infogain_loss_layer.cpp
src/caffe/layers/loss_layer.cpp
src/caffe/layers/multinomial_logistic_loss_layer.cpp
src/caffe/layers/sigmoid_cross_entropy_loss_layer.cpp
src/caffe/layers/softmax_loss_layer.cpp

>>> ls src/caffe/layers/*loss*.cu
src/caffe/layers/contrastive_loss_layer.cu
src/caffe/layers/euclidean_loss_layer.cu
src/caffe/layers/sigmoid_cross_entropy_loss_layer.cu
src/caffe/layers/softmax_loss_layer.cu
```

-   Vision Layers
    +   卷积层, `Convolution`

    +   池化层, `Pooling`

        池化方法有 MAX, AVE, or STOCHASTIC

    +   Local Response Normalization, `LRN`

        The local response normalization layer performs a kind of “lateral
        inhibition” by normalizing over local input regions. In ACROSS_CHANNELS
        mode, the local regions extend across nearby channels, but have no
        spatial extent (i.e., they have shape local_size x 1 x 1). In
        WITHIN_CHANNEL mode, the local regions extend spatially, but are in
        separate channels (i.e., they have shape 1 x local_size x local_size).
        Each input value is divided by (1+(α/n)∑ix2i)β, where n is the size of
        each local region, and the sum is taken over the region centered at
        that value (zero padding is added where necessary).

-   Loss Layers

    +   Softmax, `SoftmaxWithLoss`

    +   Sum-of-Squares / Euclidean, `EuclideanLoss`

    +   Hinge / Margin, `HingeLoss`

-   Activation / Neuron Layers

    In general, activation / Neuron layers are element-wise operators, taking
    one bottom blob and producing one top blob of the same size. In the layers
    below, we will ignore the input and out sizes as they are identical: { input,
    output: n * c * h * w }.

    +   ReLU / Rectified-Linear and Leaky-ReLU, `ReLU`

        max(0, x)

    +   Sigmoid, `Sigmoid`

        sigmoid(x)

    +   TanH / Hyperbolic Tangent, `TanH`

    +   Absolute Value, `AbsVal`

    +   Power, `Power`

        `power(x, power=1, scale=1, shift=0) = (shift+scale*x)^power`

    +   BNLL, `BNLL`

        The BNLL (binomial normal log likelihood) layer computes the output as
        `log(1 + exp(x))` for each input element x.

-   Data Layers

    Data enters Caffe through data layers: they lie at the bottom of nets. Data
    can come from efficient databases (LevelDB or LMDB), directly from memory,
    or, when efficiency is not critical, from files on disk in HDF5 or common
    image formats.

    +   Database, `Data`

    +   In-Memory, `MemoryData`

    +   HDF5 Input, `HDF5Data`

    +   HDF5 Output, `HDF5Output`

    +   Images, `ImageData`

        source: name of a text file, with each line giving an image filename and label

    +   Dummy, `DummyData`

        `DummyData` is for development and debugging. See `DummyDataParam`.

-   Common Layers

    +   Inner Product, `InnerProduct`

        The InnerProduct layer (also usually referred to as the fully connected
        layer) treats the input as a simple vector and produces an output in
        the form of a single vector (with the blob’s height and width set to
        1).

    +   Splitting, `Split`
    +   Flattening, `Flatten`
    +   Reshape, `Reshape`

        As another example, specifying `reshape_param { shape { dim: 0 dim: -1 } }`
        makes the layer behave in exactly the same way as the Flatten
        layer.

    +   Concatenation, `Concat`
    +   Slicing
    +   Elementwise Operations
    +   ArgMax
    +   SoftMax
    +   Mean-Variance Normalization

---

To create a Caffe model you need to define the model architecture in a protocol buffer definition file (prototxt).

refs and see also

-   [caffe/caffe.proto at master · BVLC/caffe](https://github.com/BVLC/caffe/blob/master/src/caffe/proto/caffe.proto)

[Caffe | Feature extraction with Caffe C++ code.](http://caffe.berkeleyvision.org/gathered/examples/feature_extraction.html)
