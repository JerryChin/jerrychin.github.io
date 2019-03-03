---
title: 正确配置 Spring Boot Security 跨域请求（CORS）
tags:  ["Spring Boot"]
---

如果 Spring Boot 项目引入 Spring Security 组件，单独声明 `CorsConfigurationSource` Bean 并不起作用，这是由于 CORS 预检请求不含 Session ID 而请求首先被 Spring Security 处理并拒绝导致的。

因此，必须明确地[配置](https://docs.spring.io/spring-security/site/docs/5.0.0.RELEASE/reference/htmlsingle/#cors) Spring Security 跨域参数以便正常处理跨域请求，下面是一个配置示例：

```java
@EnableWebSecurity
public class WebSecurityConfig extends WebSecurityConfigurerAdapter {

	@Override
	protected void configure(HttpSecurity http) throws Exception {
		http
			// cors 默认读取名为 corsConfigurationSource Bean 的配置
			.cors().and()
			...
			//其它配置
	}

	@Bean
	CorsConfigurationSource corsConfigurationSource() {
		CorsConfiguration configuration = new CorsConfiguration();
		configuration.setAllowedOrigins(Arrays.asList("https://example.com"));
		configuration.setAllowedMethods(Arrays.asList("GET","POST"));
		UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
		source.registerCorsConfiguration("/**", configuration);
		return source;
	}
}
```
