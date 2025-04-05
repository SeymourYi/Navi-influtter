package org.websoctktest.interceptors;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import java.util.Map;

@Component
public class LoginIntercepton implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler)
            throws Exception {
        String token = request.getHeader("Authorization");
        try {
            System.out.println(token);
            return true;
        } catch (Exception e) {
            response.setStatus(401);
            return false;
        }
    }

    // @Override
    // public void afterCompletion(HttpServletRequest request, HttpServletResponse
    // response, Object handler, Exception ex) throws Exception {
    // ThreadLocalUtil.remove();
    // }
}
