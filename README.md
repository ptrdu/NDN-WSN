### 内容

NDN-WSN
===================
一个基于NDN思想的无线传感器网络的设计与实现，采用Tinyos实现。
>－使用CTP协议作为底层协议，然后再生成的汇聚树上面构造FIB表与NDN策略。

>－NDN命名规则依据地理位置(传感器节点的经纬度)。不同于传统NDN字符串形式，通过地理位置信息判断数据的转发路径。

项目提供了代码的基本实现以及TOSSIM测试用例。

 - /NDN-WSN/ndn/ －－－－－－－核心代码的实现
 - /NDN-WSN/test/－－－－－－－一个测试用例
 - /NDN-WSN/picture/－－－－－测试截图

----------


/NDN-WSN/ndn
-------------

代码的具体实现，主要分为三个模块：

> - 底层 CTP启动模块，用来启动CTP协议，同时指定根节点。构造汇聚树。
> - 数据读取模块，读取传感器数据。
> - 数据刷新模块，定时刷新网络中FIB表，CS表以及PIT表。
 > - NDN策略模块，核心模块，实现NDN的基本策略，包括FIB表的构造，以及接收Interest包和Data包的处理。
 
**代码结构**
<pre>
<code>
/ndn/config.h
/ndn/content.nc
/ndn/funcitonsP.nc
/ndn/ndn.nc
/ndn/ndnC.nc
/ndn/ndnWsn.nc
/ndn/net.nc
/ndn/netC.nc
/ndn/readData.nc
/ndn/readDataC.nc
/ndn/refresh.nc
/ndn/refreshC.nc
/ndn/strategy.nc
/ndn/strategyP.nc</code>
</pre>
####  CTP启动模块
**具体文件**
<pre>
<code>
/ndn/net.nc
/ndn/netC.nc
</code>
</pre>
　　提供了底层CTP协议的相关功能，启动CTP以及设置根节点。提供net接口，netC模块具体实现接口功能。
#### 数据读取模块
**具体文件**
<pre>
<code>
/ndn/readData.nc
/ndn/readDataC.nc
</code>
</pre>
　　开启传感器读取数据功能。提供readData接口，可以获得三种数据，分别为光强，温度以及湿度。readDataC模块实现接口具体功能。
####  数据刷新模块
**具体文件**
<pre>
<code>
/ndn/refresh.nc
/ndn/refreshC.nc
</code>
</pre>
　　因为CTP协议的特性，无线传感器网络的拓扑结构会因为节点间的通信质量作出相应改变。因此我们需要刷新FIB表从而根据新的拓扑结构重新构造FIB表。
　　同时由于NDN的CS缓冲特性，当有请求新数据Interest包时，会根据规则从就近节点的CS表中构造Data数据包返回，这样会造成无法获得最新的数据，定时刷新CS表和PIT表是为了获取新的数据。
　　提供refresh接口，refreshC模块实现接口具体功能。
#### NDN策略模块
**具体文件**
<pre>
<code>
/ndn/strategy.nc
/ndn/strategyP.nc
</code>
</pre>
　　核心模块，主要包括FIB表的建立以及NDN策略的制定。因为采用的是地理位置的命名形式。不同于以往NDN的字符串匹配规则，我们通过为节点创建路由能力，来完成数据包转发的判断。
　　路由能力实际指的是节点管理区域的范围，表现形式为两个点划出的矩形区域。当查询某一节点的数据发出请求后，收到该请求的节点会根据自己的路由能力判断被查询节点的位置是否在自己的路由能力内，然后进行转发。路由能力的初始值为自己的地理位置。表现形式为一个点。
　　 FIB表的建立：当使用CTP协议构造完一棵汇聚树的时候，开始构建FIB表。每一个节点向自己的父亲节点发送自己的路由能力。节点根据收到的路由能力更新自己的路由能力，同时将收到的路由能力信息加入到自己的FIB表当中。
　　对于Interest包和Data包的处理和传统NDN是一样的。
#### 其它文件
**具体文件**
<pre>
　<code>
/ndn/content.nc
/ndn/funcitonsP.nc
/ndn/ndn.nc
/ndn/ndnC.nc
/ndn/ndnWsn.nc
　</code>
　</pre>
功能性模块和封装模块。

----------
　
/NDN-WSN/test
--------------
测试文件
#### 文件结构
　　测试文件，一个简答的测试用例，构造NDN策略，然后让节点１广播Interest数据包查询节点信息。
　　**代码结构**
　　<pre>
　　<code>
　　/test/Makefile
　　/test/test.py
　　/test/meyer-heavy.txt
　　/test/topo.txt
　　/test/testAppC.nc
　　/test/testC.nc</code>
　　</pre>
　　
　  testC.nc，testAppC.nc和Makefile文件是具体的实现文件，其它文件为TOSSIM仿真文件
#### 仿真测试
将/NDN-WSN/test/文件夹内的文件拷贝到/NDN-WSN/ndn/文件夹内，然后:
<pre>
<code>
make micaz sim
python test.py
</code>
</pre>
执行



