package info.vasanth.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.View;

import info.vasanth.configuration.OurView;
import info.vasanth.configuration.SecondOurView;
@Controller
public class FirstController {

	@RequestMapping(path="/view",method = RequestMethod.GET)
	public View doSomeWork(Model model) {

		String uname="vasanth";
		OurView view = new OurView();
		 model.addAttribute("uname",uname);
		return view;
	}
	

	@RequestMapping(path="/sview",method = RequestMethod.GET)
	public View doWork(Model model) {

		String uname="vasanth";
		OurView view = new OurView();
		 model.addAttribute("uname",uname);
		 SecondOurView ourView = new SecondOurView();
		 
		return ourView;
	}
	

}
