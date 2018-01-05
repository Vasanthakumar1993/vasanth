package info.vasanth.cb;

import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;
import org.springframework.core.env.Environment;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.DriverManagerDataSource;

@Configuration
@PropertySource("classpath:dp.properties")
public class DbConfiguration {
	@Autowired
	private Environment environment;
	
	@Autowired
	private DataSource dataSource;
	
	@Bean
	public DataSource dataSource()
	{
		DriverManagerDataSource dataSource = new DriverManagerDataSource();
		dataSource.setDriverClassName(environment.getProperty("db.driverClass"));
		dataSource.setUrl(environment.getProperty("db.url"));
		dataSource.setUsername(environment.getProperty("db.userName"));
		dataSource.setPassword(environment.getProperty("db.passWord"));
		return dataSource;	
	}
	@Bean
	public JdbcTemplate jdbcTemplate()
	{
		 JdbcTemplate jdbcTemplate = new JdbcTemplate();
		 jdbcTemplate.setDataSource(dataSource);
		 return jdbcTemplate;
	}

}
