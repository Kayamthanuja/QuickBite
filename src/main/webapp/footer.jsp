
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<footer class="footer">

	<div class="footer-container">

		<div class="footer-section footer-brand">

			<a class="footer-logo"
				href="<%=request.getContextPath()%>/restaurant"> <span
				class="footer-logo-icon">✦</span> QuickBite
			</a>

			<p>Delicious food delivered to your doorstep. Discover your
				favourite restaurants and enjoy every bite.</p>

		</div>

		<div class="footer-section">

			<h3>Company</h3>

			<a href="<%=request.getContextPath()%>/restaurant"> About Us </a> <a
				href="#">Careers</a> <a href="#">Contact Us</a> <a href="#">Partner
				With Us</a>

		</div>

		<div class="footer-section">

			<h3>Help &amp; Support</h3>

			<a href="#">Help Center</a> <a href="#">FAQs</a> <a href="#">Delivery
				Information</a> <a href="#">Cancellation &amp; Refund</a>

		</div>

		<div class="footer-section">

			<h3>Legal</h3>

			<a href="#">Terms &amp; Conditions</a> <a href="#">Privacy Policy</a>

			<a href="#">Cookie Policy</a> <a href="#">Security</a>

		</div>

	</div>

	<div class="footer-bottom">

		<p>
			&copy;
			<%=java.time.Year.now().getValue()%>
			Quick Bite. All rights reserved.
		</p>

		<p>Made with love for food lovers.</p>

	</div>

</footer>

