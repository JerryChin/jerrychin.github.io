---
title: 简述 Spring Security 框架及其不足
tags:  ["Spring"]
---


### 简介

Spring Security 是一个拥有高度可定制或的认证和授权机制的安全框架，同时更是守护基于 Spring 应用「事实上的」安全标准。

它支持开箱即用，只需简单配置即可保护应用远离黑客攻击，支持以下功能：

* 防护会话固定攻击（Session Fixation）、点击劫持（Clickjacking）以及跨站请求伪造（CSRF）等常见攻击
* 支持表单登录、OAuth 2.0 登录
* 认证方式多种多样，支持基于内存(In-Memory)认证、基于JDBC 数据库认证、基于 LDAP 认证或者自定义的认证方式
* 集成 Servlet API，支持 HttpServletRequest.logout() login() 等方法
* 记住我认证

完整介绍可以参考[Spring Security 白皮书](https://docs.spring.io/spring-security/site/docs/5.1.4.RELEASE/reference/htmlsingle/)。

### 认证与授权

上述功能可能仍然不满足实际需要，因此有必要了解 Spring Security 认证和授权大体流程以便实现定制化。

有的读者可能认为认证与授权是一回事，实际上两者的界限非常清晰。认证是指验证登录用户身份是否合法，而授权则是验证用户能否访问的指定资源。

Spring Security 认证流程如下：

1. 用户输入用户名和密码，形成用户名和密码令牌 `UsernamePasswordAuthenticationToken`；
2. 将令牌传递给认证管理器（`AuthenticationManager`）验证是否有效；
3. 认证成功后，认证管理器返回一个包含必需信息的认证令牌；
4. 此时调用 `SecurityContextHolder.getContext().setAuthentication(…​)` 方法为用户建立安全上下文，放入刚刚得到的认证令牌。

Spring Security 授权流程如下：

1. 从安全上下文容器（`SecurityContextHolder`）获取认证令牌 (`Authentication` )；
2. 通过在安全元信息源（`SecurityMetadataSource`）中查找对比用户的认证令牌 (`Authentication` )来判断当前请求申请公开资源还是安全资源；
3. 如果是安全资源，则询问访问控制器（`AccessDecisionManager`）是否允许访问；
4. 如果是开放资源，则直接允许访问。

Spring Security 通过 Web 安全配置适配器 `WebSecurityConfigurerAdapter` 来暴露配置接口，可配置项极其丰富。具体如何配置以及每项配置用途可参看刚刚提到的白皮书或 Javadoc。

### Ajax 登录

Spring Security 默认支持表单登录，如果你的项目使用 Ajax 来实现用户登录则需要按以下步骤进行配置。


1. 首先，继承 Web 安全配置适配器 `WebSecurityConfigurerAdapter` 来配置 `HttpSecurity` 对象，这个对象主要用来配置 HTTP 认证和授权相关选项。


我们要配置的地方比较多比较杂，因此提供如下参考代码：

```java
package me.jerrychin.spring.security.demo;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;

/**
 * 配置应用安全相关功能
 */
@EnableWebSecurity
public class SecurityConfig extends WebSecurityConfigurerAdapter {
	private static final Logger logger = LogManager.getLogger(SecurityConfig.class);

	@Override
	protected void configure(HttpSecurity http) throws Exception {
		// 暂时禁用 csrf
		http.csrf().disable().authorizeRequests()
				// 允许访问 /public 下方所有路径
				.antMatchers("/public/**").permitAll()
				.and()
				.formLogin() // 开启表单登录（我们实际上是通过 Ajax 来登录）
				.loginPage("/login/page") // 登录主页，由于我们是 Ajax 登录，这里的主页实际上一串 JSON
				.failureUrl("/login/fail") // 失败时，重定向客户端用户到此地址。failureForwardUrl 和 failureUrl 只能设置一个
				.successForwardUrl("/login/success") // 认证成功对于的处理页面（注意这里的 FORWARD 时内部转跳）
				.failureForwardUrl("/login/fail") // 认证失败对于的处理页面（注意这里的 FORWARD 时内部转跳）
				.loginProcessingUrl("/login") // 处理登录 POST 请求的接口名，Spring Security 已经帮我们实现
				.passwordParameter("password") // 密码对应的参数名
				.usernameParameter("username") // 用户名对应的参数名
				
				// 允许访问所有登录相关的URL
				.permitAll();
	}
	
		@Override
    protected void configure(AuthenticationManagerBuilder auth) throws Exception {
		
		// 你可以使用这里配置的用户凭据登录
        auth.inMemoryAuthentication().withUser("user").password("password").roles("USER")
               .and().withUser("admin").password("password").roles("USER", "ADMIN");
    }
	
}

```

上述配置出现了多个 URL，这些 URL对应的接口都是需要我们自己来实现。比如认证失败，我们肯定想向客户端返回相应的错误代码和原因。


下面的代码实现了上述 URL以便 Spring Security 适时调用，主要目的是向客户端响应合适的 JSON 认证结果。

```java
package me.jerrychin.spring.security.demo;

import com.alibaba.fastjson.JSONObject;
import com.eques.eqhome.commons.ErrorCode;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.WebAttributes;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Ajax 形式的登录控制器，主要用于响应认证成功或失败
 *
 *
 * @author Jerry Chin
 */
@Controller
@ResponseBody
@RequestMapping(path = "/login")
public class LoginController {
	private static final Logger logger = LogManager.getLogger(LoginController.class);

    // 登录主页
	@RequestMapping("/page")
	public JSONObject handleLoginPage() {

		JSONObject object = new JSONObject();
		object.put("reason", "未登录");
		object.put("code", 100);
		return object;
	}

    // 登录成功
	@RequestMapping("/success")
	public JSONObject handleSuccessLogin(HttpServletRequest request, HttpServletResponse response) {

		JSONObject object = new JSONObject();
		object.put("reason", "登录成功");
		object.put("code", 0);

		return object;
	}

    // 登录失败
	@RequestMapping("/fail")
	public JSONObject handleFailLogin(HttpServletRequest request) {
		
		AuthenticationException ex = (AuthenticationException) request.getAttribute(WebAttributes.AUTHENTICATION_EXCEPTION);
		
		JSONObject object = new JSONObject();
		if (ex instanceof BadCredentialsException) {
			object.put("reason", "账号或密码错误");
			object.put("code", ErrorCode.UNAUTHORIZED.code);
		} else {
			object.put("reason", "未知错误");
			object.put("code", ErrorCode.UNKNOWN.code);
		}

		return object;
	}
}
```

这里其实省略了很多步骤，比如如何建立 Spring Security 项目环境，由于这些事情跟本文关系不大，所以你必须自己搞定。


###动态授权

Spring Security 的授权配置十分灵活，但存在一个致命缺陷————无法动态更新授权配置，这代表什么意思呢？
很简单，一旦应用启动则无法修改或重新加载新的授权配置，除非....重启应用！这显然太沙雕了。

不过，Spring Security 提供了强大的定制化接口，就看你动手能力强不强了。

...待续未完


