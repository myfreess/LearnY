### Undelimited Continuation

call/cc捕获的续延又被称为无界续延，类似goto，一跳了之，无法组合。这背离了函数式编程的基本原则:维持可组合性。scheme中可通过宏使库用户免于直接接触Continuation，典型例子为amb算子，这只是避免问题的办法。后来又有很多人找出种种call/cc不实用的证据，并提出一些更加符合直觉的contorl operator。delimited continuation出现了!

### delimited continuation

有界续延是每个函数式成癮者都必知必会的概念之一。啊，那么什么是有界续延？

从实现上，有界续延非常简单。此处仅举一例：shift/reset

传统的callcc一般捕获整个调用栈,而shift/reset的工作机制不太一样，reset被调用时会在此时的调用栈顶放置一个「隔板」，其后shift被调用时，它只捕获当前栈顶到「隔板」以内的部分。

同样，因为这个「隔板」的存在，对续延的跳转不再是像过去那样，直接覆盖掉当前调用栈了。delimited continuation几乎可以当作「函数」。

例：

```racket
> (+ 1 (reset (+ 4 (shift k (begin (display (k 5)) (newline) 0)))))
9
1
```

看到了吗？在续延k被调用后，(newline) display都可以正常执行。

更多的细节和更多的operator：https://cs.ru.nl/~dfrumin/notes/delim.html

### 哪里变得好用了

http://okmij.org/ftp/continuations/against-callcc.html

前人之述备矣，简而言之，内存用得少了，速度变得快了，而且更顺手了!


### Example

https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Generator

一个实用的例子是实现Generator。你可以看看上面关于JavaScript中Generator的概念和使用，不过也并不重要,实现代码足够简单，不知道什么是Generator也能直观理解。

首先，封装一个叫做Effect的类型及相应谓词，懒得搞用cons也行。

```scheme
;;author : myfreess@github
;;date : 2020 7 30
(use-modules (ice-9 control))
(use-modules (srfi srfi-9))

(define-record-type <effect>
  (make-effect val k)
  eff*k?
  (val elim-val)
  (k elim-k))
```

接着定义Yield，它被用于跳出一个函数并携带你想指定的一个值。

```scheme
(define (Yield x)
  (shift k (make-effect x k)))
```

接下来的步骤有点特殊，Generator在scheme中没有语法层面的支持，以宏代之。

```scheme
(define-syntax G^
  (syntax-rules ()
    [(_ body ...)
     (make-effect '() (λ(_) (reset body ...)))]))

(define (Range n lim)
  (G^ (let loop ((acc n))
        (if (< acc lim)
            (begin (Yield acc)
                   (loop (+ acc 1))) #f))))
```

这和Js的Generator还是有点不一样，它更加functional一点。在实际使用中，人还是要对自己好一点，不要直接使用Generator。


