+ 用while逐行读取文本

```shell
while read i; do
     echo ${i}
	 echo 'Magic Trick'
done < material.txt
```

+ **$($0)**

非常有趣。

+ Wildcard

通配符在变量展开后被处理。
