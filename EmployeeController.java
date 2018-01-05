package info.vasanth.controller;

import java.util.List;

import javax.validation.Valid;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import info.vasanth.cb.Employee;
import info.vasanth.services.EmployeeServices;

@Controller
@RequestMapping("/emp")
public class EmployeeController {

	@Autowired
	private EmployeeServices employeeServices;

	@RequestMapping(method = RequestMethod.GET)
	public String displayForm(@ModelAttribute Employee employee) {
		//model.addAttribute("employee", new Employee());
		return "emp";

	}

	@RequestMapping(method = RequestMethod.POST)
	public String saveEmployee(@Valid Employee employee, BindingResult error) {

		if (error.getErrorCount() > 0) {
			return "emp";
		} else {
			employeeServices.saveEmployee(employee);
			return "display";
		}

	}

	@RequestMapping(method = RequestMethod.GET, path = "/search")
	public String getAllRecord(Model model) {
		List<Employee> empList = employeeServices.getAllRecord();

		model.addAttribute("empList", empList);
		return "all";

	}

}
