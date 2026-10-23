package com.tap.util;

import org.mindrot.jbcrypt.BCrypt;

public class HashGen {
	public static void main(String[] args) {
		for (String p : new String[] { "Admin@123", "SuperAdmin@123", "Delivery@123" }) {
			System.out.println(p + "=" + BCrypt.hashpw(p, BCrypt.gensalt()));
		}
	}
}
