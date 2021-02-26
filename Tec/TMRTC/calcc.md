# callcc

`callcc`是Scheme中一种古怪但有用的流程控制结构，示例如下:

```scheme
scheme@(guile-user)> (+ 23 (call/cc (lambda(k) (k 19) (display "foo"))))
$1 = 42
#不是巧合
```

`(display "foo")`完全没有执行，Lambda表达式从表面上看也没有被调用，所以发生了个啥?

看来得对表达式做点处理了，先把`call/cc`拿出来，用一个`{continuation}`代替它。

```
(+ 23 {continuation})
```

现在来看看`call/cc`，它是一个函数对象，调用时必须以另一个函数对象为参数。

```scheme
(call/cc (lambda(k) (k 19) (display "foo")))
```

`cc`是current-continuation(当前续延)的缩写，先不管它，来看看`k`吧，此时此刻`k`是一条管道，上端位于表达式`(lambda(k) ……)`内。

使用`k`必须把它当做一个单参数函数，在示例中参数是19，当19顺着`k`内壁滑向下端时………下端是`{continuation}`。现在原表达式完整了，圆润了。

```scheme
(+ 23 19)
```

所以结果是42。

管道`k`只能在相应的Lambda表达式内调用，然而也可以不调用。不调用时,`call/cc`会把Lambda表达式的返回值放到`{continuation}`的位置。

```scheme
(+ 23 (call/cc (lambda(k) (display "foo") 19)))
```

当`k`被当做单参数函数在Lambda表达式内调用之后，因为原表达式已经补全了，所以相应的lambda表达式会立刻被弃用，所以`(display "foo")`没有执行。

这还不是全部。`k`可以看做一个Lisp对象，类型是`continuation`。所以还有另一种鬼搞方式。

```scheme
scheme@(guile-user)> (define cc '())
scheme@(guile-user)> (+ 23 (call/cc (lambda(k) (set! cc k) 19)))
$3 = 42
scheme@(guile-user)> (cc 1)
$4 = 24
scheme@(guile-user)> cc
$5 = #<continuation b5067590>
scheme@(guile-user)> (cc (* 1 19))
$6 = 42
```

这么鬼搞，先给`k`换个名字，改称`cc`。同时又让`cc`这个管道可复用。现在，所有传给`cc`的参数都会被放到`{continuation}`的位置。但是求值之后原表达式仍然在那里，没有任何改变，等待着从`cc`上端落下的下一个Lisp对象。(cc和函数真d很像!)

我用了管道一词，但这是不对的，只因为我喜欢Unix。实质上，在第一个例子中当call/cc调用其参数时，原表达式会被完整地复制到`k`中。包括原表达式作用域内的变量和函数。举个栗子。

```scheme
scheme@(guile-user)> (define incr (lambda(x) (+ x 1)))
scheme@(guile-user)> (+ (incr (call/cc (lambda(k) (set! incr (lambda(x) (+ x 2))) (k 41)))))
$1 = 42
```

这很像闭包，所以它会使用更多的RAM，唉。

[1]想一想:一个continuation内部的赋值运算完全不影响外部,这是真d吗？

```scheme
scheme@(guile-user)> (def cc)
scheme@(guile-user)> (+ ((lambda() (set! cc 42) 41)) (call/cc (lambda(k) (set! cc k) (k 1))))
$1 = 42
scheme@(guile-user)> cc
$2 = #<continuation b5dd0510>
scheme@(guile-user)> (cc 1)
$3 = 42
scheme@(guile-user)> cc
$4 = #<continuation b5dd0510>
```

处于continuation中的define完全可用。为什么[1]中的`set!`没起作用?

```scheme
(define x (call/cc (lambda(x) x))) 
(define y (call/cc x))
scheme@(guile-user)> (x 42)
scheme@(guile-user)> y
$5 = 42
scheme@(guile-user)> x
$6 = #<continuation b4dca190>
```

能理解吗？当然可以。

```scheme
scheme@(guile-user)> (define x (call/cc (lambda (x) x)))
scheme@(guile-user)> x
$1 = #<continuation b4cd9270>
scheme@(guile-user)> (define y (call/cc x))    
scheme@(guile-user)> x
$2 = #<continuation b4d719a0>
```


**Note**

Guile的Man手册里明确介绍了以下事实:

call/cc抽出当前continuation的方法是 _复制整个栈，当continuation被调用时再把这个复制品复制回去。_ 所以，当continuation被调用时，外层表达式会直接原地销毁。

原文: _Basically continuation are captured by a block copy of stack, and resumed by copying back._

**继续**

撒，一个continuation会捕获当前的栈，栈中充满了Lisp对象，那么，仔细想想，一个continuation的返回值是完全由输入决定的吗？

不见得，记得`reverse!`吗?记得`hash-set!`吗?

```scheme
scheme@(guile-user)> (make-hash-table 1)$1 = #<hash-table b5cb70a0 0/31>
scheme@(guile-user)> (hash-set! $1 'end 42)
$2 = 42
scheme@(guile-user)> (def foo 'f)
scheme@(guile-user)> (+ (call/cc (lambda(k) (set! foo k) 0)) (hash-ref $1 'end))$3 = 42
scheme@(guile-user)> foo
$4 = #<continuation b4dc92d0>
scheme@(guile-user)> (foo 0)
$5 = 42
scheme@(guile-user)> (hash-set! $1 'end 13)
$6 = 13
scheme@(guile-user)> (foo 0)        
$7 = 13
```

GuileMan文档有言，这样的代码不是`continuation-safe`的，然。

赋值者，continuation不可无之，没有side effect的continuation是不完整的，但是，滥用副作用，只怕人身上这区区数十千克的水不够哭。

然而，此故事还有个后续，为我们展示了eager eval在Guile中的表现。

```scheme
scheme@(guile-user)> (+ (hash-ref $1 'end) (call/cc (lambda(k) (set! foo k) 0)))$8 = 13
scheme@(guile-user)> foo
$9 = #<continuation b5477930>
scheme@(guile-user)> (foo 0)
$10 = 13
scheme@(guile-user)> (hash-set! $1 'end 42)
$11 = 42
scheme@(guile-user)> (foo 0)
$12 = 13
```

时不我待呀。



