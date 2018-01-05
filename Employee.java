package info.vasanth.cb;

import javax.validation.constraints.NotEmpty;
import javax.validation.constraints.NotNull;

public class Employee {

	@NotNull(message="eno is mandatory")
	private Integer eno;
	@NotEmpty(message="name is mandatory")
	private String name;
	@NotNull(message="salary is mandatory")
	private Double salary;
	public Integer getEno() {
		return eno;
	}
	public void setEno(Integer eno) {
		this.eno = eno;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public Double getSalary() {
		return salary;
	}
	public void setSalary(Double salary) {
		this.salary = salary;
	}
	
}
