package info.vasanth.services;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import info.vasanth.Dao.EmployeeDao;
import info.vasanth.cb.Employee;

@Service
public class EmployeeServices {
	@Autowired
	private EmployeeDao employeeDao;
	
	public int saveEmployee(Employee employee)
	{
		System.out.println(employee.getSalary()+employee.getName()+employee.getEno());
		Double salary = employee.getSalary();
		salary=(salary*10)/100;
		employee.setSalary(salary);
		return employeeDao.saveEmployee(employee);
	}
	public List<Employee> getAllRecord()
	{
		return employeeDao.getAllEmployee();	
	}
}
