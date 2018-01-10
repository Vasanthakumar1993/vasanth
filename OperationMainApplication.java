package in.gov.cooptex;

import java.util.Arrays;
import java.util.EnumSet;

import javax.servlet.DispatcherType;
import javax.sql.DataSource;

import org.jasypt.digest.PooledStringDigester;
import org.jasypt.digest.StringDigester;
import org.modelmapper.ModelMapper;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Import;
import org.springframework.context.annotation.ImportResource;
import org.springframework.data.domain.AuditorAware;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.access.expression.method.DefaultMethodSecurityExpressionHandler;
import org.springframework.security.access.expression.method.MethodSecurityExpressionHandler;
import org.springframework.security.config.annotation.method.configuration.EnableGlobalMethodSecurity;

import in.gov.cooptex.core.model.UserMaster;
import in.gov.cooptex.operation.RedisConfiguration;
import in.gov.cooptex.operation.SwaggerConfig;
import in.gov.cooptex.operation.UserAuditAware;
import in.gov.cooptex.security.BasePermissionEvaluator;
import in.gov.cooptex.util.TrackFilter;
import lombok.extern.log4j.Log4j2;

//@SpringBootApplication(scanBasePackages = { "in.gov.cooptex", "in.gov.cooptex.core.dto" })
// @EntityScan(basePackages
// ={"in.gov.cooptex.core.model","in.gov.cooptex.operation.model","in.gov.cooptex.operation.production.model"})
// @EnableJpaRepositories(basePackages = "in.gov.cooptex.core.repository")
@SpringBootApplication
@EnableJpaRepositories
// @EnableJpaRepositories(basePackages = { "in.gov.cooptex.core.repository",
// "in.gov.cooptex.operation.repository" })
@EntityScan
@EnableGlobalMethodSecurity(prePostEnabled = true, securedEnabled = true, jsr250Enabled = true)
@ImportResource("classpath:security.xml")
@EnableJpaAuditing
@Log4j2
@Import(value = { RedisConfiguration.class, SwaggerConfig.class })
public class OperationMainApplication {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		SpringApplication.run(OperationMainApplication.class, args);

	}

	@Bean
	public ModelMapper modelMapper() {
		ModelMapper modelMapper = new ModelMapper();
		modelMapper.getConfiguration().getMatchingStrategy();
		return modelMapper;
	}

	@Bean
	StringDigester PasswordHash() {
		final PooledStringDigester stringDigester = new PooledStringDigester();
		stringDigester.setAlgorithm("SHA-256");
		stringDigester.setIterations(1000);
		stringDigester.setSaltSizeBytes(10);
		stringDigester.setPoolSize(16);
		stringDigester.initialize();
		return stringDigester;

	}

	@Bean
	public FilterRegistrationBean trackFilter() {
		FilterRegistrationBean filterRegBean = new FilterRegistrationBean();
		filterRegBean.setFilter(new TrackFilter());
		filterRegBean.setDispatcherTypes(
				EnumSet.of(DispatcherType.FORWARD, DispatcherType.REQUEST, DispatcherType.ASYNC, DispatcherType.ERROR));
		filterRegBean.setOrder(1);
		filterRegBean.setUrlPatterns(Arrays.asList("/*"));
		return filterRegBean;
	}

	@Bean
	public AuditorAware<UserMaster> auditorAware() {
		UserAuditAware userAuditAware = new UserAuditAware();
		log.info("auditorAware >>>> " + userAuditAware.getCurrentAuditor());
		if (userAuditAware.getCurrentAuditor() != null) {
			log.info("current user >>>> " + userAuditAware.getCurrentAuditor());
		}
		return userAuditAware;
	}

	@Bean
	public JdbcTemplate jdbcTemplate(DataSource dataSource) {
		return new JdbcTemplate(dataSource);
	}

	@Bean
	protected MethodSecurityExpressionHandler expressionHandler() {
		log.info("Inside expressionHandler()");
		DefaultMethodSecurityExpressionHandler expressionHandler = new DefaultMethodSecurityExpressionHandler();
		expressionHandler.setPermissionEvaluator(new BasePermissionEvaluator());

		return expressionHandler;
	}

}