package info.vasanth.configuration;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.ServletRegistration.Dynamic;

import org.springframework.web.WebApplicationInitializer;
import org.springframework.web.context.support.AnnotationConfigWebApplicationContext;
import org.springframework.web.servlet.DispatcherServlet;

public class SpringwebInitializer implements WebApplicationInitializer {

	public void onStartup(ServletContext servletContext) throws ServletException {

		AnnotationConfigWebApplicationContext container=new AnnotationConfigWebApplicationContext();
		container.register(SprinBeanConfiguration.class);
		container.setServletContext(servletContext);
		Dynamic servlet=servletContext.addServlet("spring",new DispatcherServlet(container));
		servlet.addMapping("/");
		servlet.setLoadOnStartup(1);
		container.close();
	}
}


