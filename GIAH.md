### GIAH

> 根据Guile官方文档所写，简述Guile的历史与实现


#### 历史

当然了，真正的Guile的历史是由Hacker们创造的，不是我编的。

首先，GNU Project整出了一种扩展语言，并起名叫它Guile。然后，当时tcl和tk是很火的扩展语言。

RMS，Emacs最早期作者，GNU领导者，著名Lisp厨(Guile基于Scheme，一种Lisp方言)，认为Tcl设计地不好，于是他……反正最后发生了Tcl战争，你懂的。程序员的信仰问题一直难以解决。

#### 实现

> 听说Guile3.0将尝试整一个Python翻译器，可以把Python代码译成Guile代码。

Guile中的所谓Object，实际上是个指针，指向堆上一块实际的数据。String自带长度信息，整数和序对优化过，不是指针。

Guile的垃圾回收由libgc库提供，它只是能工作。每隔一段时间它检查与变量无关的Object并回收。
