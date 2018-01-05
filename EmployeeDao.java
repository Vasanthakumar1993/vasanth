package info.vasanth.Dao;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import info.vasanth.cb.Employee;

@Repository
public class EmployeeDao {

	@Autowired
	private JdbcTemplate jdbcTemplate;

	public int saveEmployee(Employee employee) {
		String query = "insert into emp values(?,?,?)";
		return jdbcTemplate.update(query, employee.getEno(), employee.getName(), employee.getSalary());

	}

	public List<Employee> getAllEmployee() {
		String query = "select * from emp";
		return jdbcTemplate.query(query, new RowMapper<Employee>() {
			public Employee mapRow(ResultSet rs, int rowNum) throws SQLException {
				Employee employee = new Employee();
				employee.setEno(rs.getInt(1));
				employee.setName(rs.getString(2));
				employee.setSalary(rs.getDouble(3));
				return employee;
			}
		});

	}
}
