package org.example.websoctktest.config;


import org.example.websoctktest.interceptors.LoginIntercepton;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
@Configuration
public class WebConfig implements WebMvcConfigurer {
    @Autowired
    private LoginIntercepton loginIntercepton;


    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(loginIntercepton).excludePathPatterns("/user/login","/user/register","/user/check","/user/SmsSender","/ws/**", "/topic/**", "/chat/**","/app/**");
    }
}
