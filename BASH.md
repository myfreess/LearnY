**管道和布尔运算**

一定加空格。

```shell
ps | grep $(whoami) && printf "\n%s\n" done
```

**长命令**

一定加反斜杠分行。

**for**

绝对只用通配符`*`，不用$(ls)。

```shell
for i in $HOME/.bash*; do
    echo $i
done
```

**>**

绝对谨慎使用。

像`cat weather.txt > weather.txt`这种操作万不可为。
