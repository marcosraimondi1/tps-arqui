const http = require("http");
const fs = require("fs");
const path = require("path");
const { exec } = require("child_process");

const python_script = "python ../python/web_interface_debug.py";

const server = http.createServer((req, res) => {
  if (req.url.startsWith("/run_cmd")) {
    let script_args = "";

    // parse query params
    const url = new URL(req.url, `http://${req.headers.host}`);
    const searchParams = url.searchParams;
    searchParams.forEach((value, name) => {
      script_args += `--${name} ${value} `;
    });

    const cmd = python_script + " " + script_args;

    console.log("Running command: " + cmd);

    exec(cmd, (error, stdout, stderr) => {
      if (error) {
        console.log(`Error: ${error.message}`);
        res.writeHead(200, { "Content-Type": "text/plain" });
        res.end(`${cmd} Error: ${stderr}`);
        return;
      }
      console.log(`Command executed successfully: ${stdout}`);
      res.writeHead(200, { "Content-Type": "text/plain" });
      res.end(cmd + " " + stdout);
    });
  } else if (req.url.startsWith("/read_data")) {
    // read json file "data.json"
    const file_path = "./data.json";
    fs.readFile(file_path, (err, content) => {
      if (err) {
        console.log("Error reading file:", err);
        res.writeHead(404, { "Content-Type": "text/plain" });
        res.end("404 Not Found");
      } else {
        res.writeHead(200, { "Content-Type": "application/json" });
        res.end(content, "utf-8");
      }
    });
  } else {
    // Serve static files from the "public" directory
    const filePath = path.join(
      __dirname,
      "public",
      req.url === "/" ? "index.html" : req.url,
    );
    const extname = path.extname(filePath);
    const contentType =
      {
        ".html": "text/html",
        ".js": "text/javascript",
        ".css": "text/css",
      }[extname] || "text/plain";

    fs.readFile(filePath, (err, content) => {
      if (err) {
        res.writeHead(404, { "Content-Type": "text/plain" });
        res.end("404 Not Found");
      } else {
        res.writeHead(200, { "Content-Type": contentType });
        res.end(content, "utf-8");
      }
    });
  }
});

server.listen(8080, () => {
  console.log("Server running at http://localhost:8080/");
});
