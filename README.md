# Library 📚 uim-http

**HTTP (Hypertext Transfer Protocol)** is a fundamental protocol used for communication between **web clients** (such as browsers) and **web servers**.

**Purpose of HTTP**:

- **Web Communication**: HTTP facilitates communication between clients (like web browsers) and servers (often cloud-based computers).
- **Request-Response Model**: Clients send **HTTP requests**, and servers respond with **HTTP responses** containing data (like HTML pages, images, or JSON).

**How HTTP Works**:

- A typical HTTP request-response cycle:
  1.  The browser requests an HTML page.
  2.  The server returns an HTML file.
  3.  The browser requests additional resources (stylesheets, images, JavaScript files).
  4.  The server responds with the requested resources.
- This cycle repeats as the browser constructs the complete web page.

**Components of HTTP-Based Systems**:

- **Client (User-Agent)**: The tool (usually a browser) that acts on behalf of the user.
- **Web Server**: The server that serves requested documents.
- **Proxies**: Intermediate servers that handle requests and responses between clients and servers.

**XHR (XML Http Request)**:

- All browsers have a built-in **XMLHttpRequest Object (XHR)**.
- XHR is a JavaScript object used to transfer data between a web browser and a web server.
- It enables:
  - Updating a web page without reloading it.
  - Requesting and receiving data after the page loads.
  - Sending data to a server in the background.
- XHR is the underlying concept of **AJAX** (Asynchronous JavaScript and XML) and **JSON**.
