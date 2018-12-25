---
title: Self-autowiring with Spring Boot as a Standalone Application (SBSA)
tags:  ["Programming"]
---

There's a convenient utility class [`SpringBeanAutowiringSupport`](https://docs.spring.io/spring/docs/5.0.9.RELEASE/javadoc-api/org/springframework/web/context/support/SpringBeanAutowiringSupport.html) introduced since 2.5.1 that can be used to autowire self-instantiated classes, it contains two static methods which I'll explain next.

### [processInjectionBasedOnCurrentContext](https://docs.spring.io/spring/docs/5.0.9.RELEASE/javadoc-api/org/springframework/web/context/support/SpringBeanAutowiringSupport.html#processInjectionBasedOnCurrentContext-java.lang.Object-)

This method is tailored to Spring-based web application, does not work well with SBSA, because it use ContextLoader to locate the current WebApplicationContext, but SBSA use a custom context loader.


### [processInjectionBasedOnServletContext](https://docs.spring.io/spring/docs/5.0.9.RELEASE/javadoc-api/org/springframework/web/context/support/SpringBeanAutowiringSupport.html#processInjectionBasedOnServletContext-java.lang.Object-javax.servlet.ServletContext-)

This one requires that we have explicitly reference to the current servlet context, 


```java
@SpringBootApplication
public class Application implements ServletContextInitializer {
    
    private static ServletContext servletContext;
    
    
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
    
    
    public void onStartup(ServletContext servletContext) throws ServletException {
        // save reference to our servlet context, 
        // so later we can retrieve Spring ApplicationContext from it.
        Application.servletContext = servletContext;
    }
    
    public static ServletContext getServletContext() {
        return Application.servletContext;
    }
}
```

Now, we have access to the servlet context, or we can use ServletContext with it to autowire our dummy class.


```java

class Example {
    
    @Autowire
    private Service service;
    
    Example() {
        SpringBeanAutowiringSupport.processInjectionBasedOnServletContext(this, 
            Application.getServletContext()
        );
    }
}

```

We're done, I hope you find it helpful!