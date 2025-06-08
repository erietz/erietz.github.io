const { chromium } = require("@playwright/test");
const net = require("net");
const { spawn } = require("child_process");

/**
 * Probe to see if a port is in use
 */
function isPortInUse(port) {
  return new Promise((resolve) => {
    const tester = net
      .createServer()
      .once("error", (err) =>
        err.code === "EADDRINUSE" ? resolve(true) : resolve(false),
      )
      .once("listening", () =>
        tester.once("close", () => resolve(false)).close(),
      )
      .listen(port);
  });
}

(async () => {
  const port = 8080;
  let serverProcess = null;
  const serverRunning = await isPortInUse(port);

  if (!serverRunning) {
    console.log("Starting local server...");
    serverProcess = spawn("npx", ["http-server", ".", "-p", port], {
      stdio: "inherit",
      shell: true,
    });

    // Wait for the server to be ready
    await new Promise((resolve) => setTimeout(resolve, 2000));
  }

  const browser = await chromium.launch();
  const page = await browser.newPage();

  await page.goto(`http://localhost:${port}/pages/cv.html`, {
    waitUntil: "networkidle",
  });

  await page.pdf({
    path: "./assets/files/rietzCV.pdf",
    format: "Letter",
    printBackground: true,
    displayHeaderFooter: false,
    margin: {
      top: "1.0cm",
      bottom: "1.0cm",
      left: "1.0cm",
      right: "1.0cm",
    },
  });

  await browser.close();
  console.log("PDF generated successfully.");

  if (serverProcess) {
    console.log("Stopping local server...");
    serverProcess.kill();
  }
})();
