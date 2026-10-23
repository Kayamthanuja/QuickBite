 🍔 QuickBite – Online Food Delivery Web Application

 🎯 Project Objective

The objective of QuickBite is to develop a user-friendly online food delivery platform that simplifies restaurant discovery, food ordering, online payments, and order management. The application integrates email OTP authentication, session management, and the Razorpay payment gateway to provide a complete food ordering experience.

This project demonstrates practical implementation of Java web development, database connectivity, authentication, payment integration, and modular application architecture.

 📖 About the Project

QuickBite is a Java-based online food delivery web application that allows customers to explore restaurants, browse food menus, add items to their cart, place orders, and make online payments through Razorpay.

The application supports email OTP authentication, session-based user management, restaurant and menu browsing, checkout, order tracking, and administrative functionality. It is developed using Java, JSP, Servlets, JDBC, and MySQL, with a layered architecture that separates the presentation, controller, and database access layers.

 👩‍💻 Project Information

- **Project Name:** QuickBite
- **Project Type:** Online Food Delivery Web Application
- **Backend:** Java, JSP, Servlets, JDBC
- **Frontend:** JSP, HTML, CSS, JavaScript where applicable
- **Database:** MySQL
- **Web Server:** Apache Tomcat
- **Payment Gateway:** Razorpay
- **Authentication:** Email OTP and session management
- **IDE:** Eclipse

 ✨ Key Features

 👤 Customer Features

- User registration and login
- Email OTP-based authentication and verification
- Session management for authenticated users
- Restaurant browsing and cuisine-based filtering
- Restaurant search functionality
- Food menu browsing
- Add, update, and remove items from the shopping cart
- Automatic calculation of order totals and applicable charges
- Checkout and order placement
- Razorpay payment gateway integration
- Order history and order details
- Order status tracking
- User profile management

 🛠️ Admin Features

- Admin authentication and dashboard
- Restaurant management
- Restaurant information management
- Administrative profile functionality
- Access to admin-specific pages and operations

 🚚 Delivery Features

- Dedicated delivery dashboard
- Access to delivery-related order information and functionality

 🧰 Technologies Used

- **Java** – Backend development
- **JSP & Servlets** – Dynamic web pages and request handling
- **HTML & CSS** – User interface and styling
- **JDBC** – Database connectivity
- **MySQL** – Data storage
- **Razorpay** – Online payment integration
- **Email OTP** – User authentication
- **Apache Tomcat** – Application server
- **Eclipse IDE** – Development environment


🏗️ Application Architecture

QuickBite follows a layered architecture that separates the user interface, request handling, business operations, and database access.


                 Customer / Admin
                        |
                        v
                     JSP Pages
                  (Presentation)
                        |
                        v
                  Java Servlets
                   (Controller)
                        |
                        v
                    DAO Layer
                        |
                        v
                DAO Implementations
                        |
                        v
                  JDBC / SQL
                        |
                        v
                  MySQL Database


 Architecture Components

- **Model Layer:** Represents application entities such as users, restaurants, menu items, orders, and order items.
- **DAO Layer:** Defines the database operations required by the application.
- **DAOImpl Layer:** Implements database operations using JDBC and SQL queries.
- **Controller Layer:** Handles incoming requests, coordinates application operations, and forwards or redirects users to the appropriate pages.
- **Utility Layer:** Contains reusable utilities, including the database connection class.
- **Presentation Layer:** Uses JSP, HTML, CSS, and JavaScript where applicable to display dynamic content and provide user interactions.
- **External Integrations:** Email OTP supports authentication, while Razorpay provides online payment functionality.

 📂 Project Structure

The following structure represents the main folders and files in the QuickBite Eclipse Dynamic Web Project.


QuickBite/
│
├── src/
│   └── main/
│       ├── java/
│       │   ├── com.tap.controller/
│       │   ├── com.tap.DAO/
│       │   ├── com.tap.DAOImpl/
│       │   ├── com.tap.model/
│       │   └── com.tap.util/
│       │
│       └── webapp/
│           │
│           ├── CSS/
│           │   ├── adminDashboard.css
│           │   ├── adminNavbar.css
│           │   ├── adminRestaurants.css
│           │   ├── cart.css
│           │   ├── checkout.css
│           │   ├── common.css
│           │   ├── deliveryDashboard.css
│           │   ├── footer.css
│           │   ├── login.css
│           │   ├── menu.css
│           │   ├── navbar.css
│           │   ├── orderDetails.css
│           │   ├── orders.css
│           │   ├── orderStatus.css
│           │   ├── profile.css
│           │   ├── restaurant.css
│           │   └── signup.css
│           │
│           ├── JS/
│           ├── META-INF/
│           ├── WEB-INF/
│           │
│           ├── AdminDashboard.jsp
│           ├── adminNavbar.jsp
│           ├── AdminProfile.jsp
│           ├── AdminRestaurants.jsp
│           ├── Cart.jsp
│           ├── Checkout.jsp
│           ├── DeliveryDashboard.jsp
│           ├── footer.jsp
│           ├── forgot-password.jsp
│           ├── index.html
│           ├── Login.jsp
│           ├── Menu.jsp
│           ├── navbar.jsp
│           ├── OrderDetails.jsp
│           ├── Orders.jsp
│           ├── OrderStatus.jsp
│           ├── Profile.jsp
│           ├── Restaurant.jsp
│           └── Signup.jsp
│
├── build/
├── Referenced Libraries/
└── README.md


*Note: This is a simplified representation based on the visible Eclipse project structure. Eclipse may display Java source folders under the logical heading `Java Resources`. The exact contents may vary depending on the files committed to GitHub.*

🔐 Authentication and Session Management

QuickBite implements email OTP-based authentication to support email verification during the authentication process.

- Email-based OTP verification
- Session management for authenticated users
- Authentication state maintained during navigation
- Separate customer and administrative functionality

Session management helps maintain a user's authentication state while navigating through the application.

 💳 Razorpay Payment Integration

QuickBite integrates the Razorpay payment gateway to provide an online payment option during checkout.

The payment integration connects the checkout process with Razorpay, allowing customers to complete payments as part of the food ordering workflow.

 🗄️ Database Design

QuickBite uses MySQL as its relational database and JDBC for database connectivity.

 Main Database Entities

| Entity | Purpose |
|---|---|
| User | Stores user account and role-related information |
| Restaurant | Stores restaurant names, cuisine types, addresses, ratings, and availability |
| Menu | Stores food item names, descriptions, prices, availability, and restaurant associations |
| Order | Stores customer orders and order-related information |
| Order Items | Stores individual food items and quantities associated with an order |

The DAO and DAO implementation layers separate database operations from the presentation layer and help organize data access logic.

 ⚙️ Installation and Setup

 Prerequisites

Install the following software before running the application:

- Java Development Kit (JDK)
- Eclipse IDE for Enterprise Java and Web Developers
- Apache Tomcat
- MySQL Server
- MySQL Workbench (optional)
- Razorpay account and API credentials for payment testing
- Access to the email service configured for OTP functionality

 Step 1: Clone the Repository

  git clone https://github.com/YOUR-USERNAME/YOUR-REPOSITORY.git


Replace the placeholder URL with your actual GitHub repository URL.

 Step 2: Import the Project into Eclipse

1. Open Eclipse IDE.
2. Navigate to **File → Import**.
3. Select **Existing Projects into Workspace**.
4. Browse to the cloned QuickBite project directory.
5. Import the project into your workspace.

 Step 3: Configure the Database

1. Start the MySQL server.
2. Create the database required by the application.
3. Execute the database schema and data insertion scripts, if included in the repository.
4. Configure the database URL, username, and password in the `DBConnection` utility class or the appropriate configuration file.

 Step 4: Configure External Services

- Configure the email service and credentials required for OTP delivery.
- Configure the Razorpay API credentials required for payment testing.
- Store sensitive credentials securely and do not commit them to GitHub.

 Step 5: Configure Apache Tomcat

1. Add Apache Tomcat to Eclipse.
2. Associate the QuickBite project with the server.
3. Verify the Java version, web application configuration, and dependencies.
4. Clean and rebuild the project if necessary.

 Step 6: Run the Application

1. Right-click the project in Eclipse.
2. Select **Run As → Run on Server**.
3. Select the configured Apache Tomcat server.
4. Open the deployed application using its configured context path in your browser.

The exact URL depends on the Tomcat configuration and the application's deployed context path.

 🔒 Security Considerations

- Do not publish database passwords, email credentials, OTP service secrets, or Razorpay secret keys.
- Validate user input on the server side.
- Use prepared statements for database queries.
- Protect authenticated pages using session checks and appropriate authorization.
- Verify Razorpay payment results on the server side using the appropriate payment verification process.
- Avoid committing private user information or production credentials to GitHub.

📄 License

This project is intended for learning, development, and demonstration purposes. Add a license file if you wish to specify the terms under which the project may be used, modified, or distributed.

This project is intended for learning, development, and demonstration purposes. Add a license file if you wish to specify the terms under which the project may be used, modified, or distributed.
