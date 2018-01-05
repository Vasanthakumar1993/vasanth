package info.vasanth.configuration;

import java.io.PrintWriter;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.web.servlet.View;

public class OurView implements View {

	public String getContentType() {
		return "text/plain";
	}

	public void render(Map<String, ?> model, HttpServletRequest request, HttpServletResponse response)
			throws Exception {
		PrintWriter out = response.getWriter();
		String name=(String) model.get("uname");
		out.println("ourView is diplaying o/p");
		out.println(name);

	}

}
