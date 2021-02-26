# Hylang

**Hylang**是一种Python方言。

Hylang有print，而且支持format-string这种数据类型。。

```hy
=> (setv foo 42)
=> foo
42
=> (print f"foo:{foo}")
foo:42
```

**Note:**`print`的返回值永远是`None`，和`Null`一个意思。它的类型也是`Nonetype`。

Hylang有Lambda函数。而且可以写得很长。例如，这里有一个阶乘函数(非尾递归)。

```hy
=> (setv metafact (fn[Num] (if 
...(or (= Num 0) (= Num 1)) 1
...(> Num 1) (* Num (foo (- Num 1))))))
=> (metafact 10)
3628800
```

**Note:**Hylang没有尾递归优化：✓。

定义变量使用`setv`，Lambda表达式用`fn`创建。不过，参数会放在`[]`里。

在Hylang中不用写显式的`else if`，一个布尔表达式后跟要执行的表达式就行了。


