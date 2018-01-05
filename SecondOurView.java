package info.vasanth.configuration;

import java.io.PrintWriter;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.web.servlet.view.AbstractView;

public class SecondOurView extends AbstractView {

	@Override
	protected void renderMergedOutputModel(Map<String, Object> model, HttpServletRequest request,
			HttpServletResponse response) throws Exception {
 
		 PrintWriter out = response.getWriter();
		 String  name=(String)model.get("uname");
		 out.println(name);
	}

}
