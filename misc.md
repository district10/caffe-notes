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
