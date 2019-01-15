---
title: 为什么 Java 内部使用 UTF-16 表示字符串？
tags:  ["Programming"]
---

### 背景
许多年前 Unicode 的提出者天真地以为 16 位定长的字符可以容纳地球上所有仍具活力的文字，Java 设计者也深以为然。

参考 Unicode 设计，Java 设计者认为完全可以设计一个双字节数据类型来表达所有 Unicode 字符，于是便有了今天的原始数据类型 `char`。

但后来发现 65,536 个字符根本不足以表达所有文字，Java 5.0 版本既要支持 Unicode 4.0 同时要保证向后兼容性，不得不开始使用 UTF-16 作为内部编码方式，

### UTF-16 编码
Unicode 基本多文种平面（BMP U+0000 to U+FFFF）涵盖了几乎所有现代语言，以及繁多的特殊符号，Java 允许使用单个 `char` 来表示 BMP 内的字符，此时的编码值等于 Unicode 代码点（code point)，这是Java 最初的Unicode 实现，这种编码方式又称之为 UCS-2。

Enough talk, show me the code ! 

我们尝试打印位于 BMP 平面内的[上箭头](https://en.wikipedia.org/wiki/Arrows_(Unicode_block))符号。

首先，查询得知上箭头符号对应的 code point 是 0x2191，直接赋值给 `char`然后打印：
```
char ch = 0x2191; 
System.out.println(ch);
```

输出：

```
↑
```

那么，如何表示辅助多文种平面（SMP U+010000 to U+10FFFF）内的字符呢？

Unicode 从 BMP 平面保留两片连续区域用于表示 SMP 平面内的字符，即可以继续与 UCS-2 编码保持兼容，又能减少空间浪费，毕竟使用 SMP 的场合并不多。

这两片区域分别是 0xD800–0xDBFF （高代理区域）、0xDC00–0xDFFF （低代理区域），编码方式如下：

1. 将代码点减去 0x10000，仅保留低 20 位；
2. 将高 10 位加上 0xD800，得到高代理；
3. 将低 10 位加上 0xDC00，得到低代理；

高代理和低代理共同组成一个代理串（Surrogate Pair）唯一地标识 Unicode SMP 平面上的任一代码点。

Enough talk, show me the code ! 

我们来试试打印 Emoji [笑脸](https://en.wikipedia.org/wiki/Emoticons_(Unicode_block))

```
int lowBits = 0x1F600 - 0x10000;

// 由于char 的长度为 16 位，采用代理对方式表示（surrogate pair）必须使用两个 char，并使用 String 包装
char highSurrogate = (char) ((lowBits >> 10) + 0xD800);
char lowSurrogate = (char) ((lowBits & 0x3FF) + 0xDC00);
System.out.println(new String(new char[]{highSurrogate, lowSurrogate}));

```

输出：

```
😀
```


Java `Character` 类提供很丰富的静态方法实现 Unicode 相关操作，如下所见：

```
// 将代理对转成对应 Unicode code point
Character.toCodePoint(char high, char low)

// 判断 code point 所需字符数
Character.charCount(int codePoint)

// 判断 code point 是否合法


// 判断是否为高位代理（High Surrogate）
Character.isHighSurrogate(char ch)


// 获取高位代理（High Surrogate）
Character.highSurrogate(char ch)


// 判断是否为低位代理（Low Surrogate）
Character.isLowSurrogate(char ch)

// 获取低位代理（Low Surrogate）
Character.lowSurrogate(char ch)

```


### UTF-16 转换 UTF-8

Java `String` 类支持任意编码方式转换，其中就包括 UTF-8 编码：
```
String.getBytes("UTF-8")
```

但该方法缺点也很明显，无法重用已有的 buffer，有些场合下可能十分不便。下面是 Google 实现的UTF-8 编码方法，可以供大家参考：

```java
public class GoogleUTF8 {
    public static int encodeUtf8(CharSequence in, byte[] out, int offset, int length) {
      int utf16Length = in.length();
      int j = offset;
      int i = 0;
      int limit = offset + length;
      // Designed to take advantage of
      // https://wikis.oracle.com/display/HotSpotInternals/RangeCheckElimination
      for (char c; i < utf16Length && i + j < limit && (c = in.charAt(i)) < 0x80; i++) {
        out[j + i] = (byte) c;
      }
      if (i == utf16Length) {
        return j + utf16Length;
      }
      j += i;
      for (char c; i < utf16Length; i++) {
        c = in.charAt(i);
        if (c < 0x80 && j < limit) {
          out[j++] = (byte) c;
        } else if (c < 0x800 && j <= limit - 2) { // 11 bits, two UTF-8 bytes
          out[j++] = (byte) ((0xF << 6) | (c >>> 6));
          out[j++] = (byte) (0x80 | (0x3F & c));
        } else if ((c < Character.MIN_SURROGATE || Character.MAX_SURROGATE < c) && j <= limit - 3) {
          // Maximum single-char code point is 0xFFFF, 16 bits, three UTF-8 bytes
          out[j++] = (byte) ((0xF << 5) | (c >>> 12));
          out[j++] = (byte) (0x80 | (0x3F & (c >>> 6)));
          out[j++] = (byte) (0x80 | (0x3F & c));
        } else if (j <= limit - 4) {
          // Minimum code point represented by a surrogate pair is 0x10000, 17 bits,
          // four UTF-8 bytes
          final char low;
          if (i + 1 == in.length()
                  || !Character.isSurrogatePair(c, (low = in.charAt(++i)))) {
            throw new UnpairedSurrogateException((i - 1), utf16Length);
          }
          int codePoint = Character.toCodePoint(c, low);
          out[j++] = (byte) ((0xF << 4) | (codePoint >>> 18));
          out[j++] = (byte) (0x80 | (0x3F & (codePoint >>> 12)));
          out[j++] = (byte) (0x80 | (0x3F & (codePoint >>> 6)));
          out[j++] = (byte) (0x80 | (0x3F & codePoint));
        } else {
          // If we are surrogates and we're not a surrogate pair, always throw an
          // UnpairedSurrogateException instead of an ArrayOutOfBoundsException.
          if ((Character.MIN_SURROGATE <= c && c <= Character.MAX_SURROGATE)
              && (i + 1 == in.length()
                  || !Character.isSurrogatePair(c, in.charAt(i + 1)))) {
            throw new UnpairedSurrogateException(i, utf16Length);
          }
          throw new ArrayIndexOutOfBoundsException("Failed writing " + c + " at index " + j);
        }
      }
      return j;
    }
}
```


### 参考链接

1. https://docs.oracle.com/javase/specs/jls/se6/html/lexical.html
2. https://docs.oracle.com/javase/tutorial/i18n/text/unicode.html
3. https://softwareengineering.stackexchange.com/questions/174947/why-does-java-use-utf-16-for-internal-string-representation
4. https://www.oracle.com/technetwork/articles/javase/supplementary-142654.html