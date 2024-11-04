const { chromium } = require('@playwright/test');

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();

  await page.goto('http://localhost:8080/pages/cv.html', { waitUntil: 'networkidle' });

  await page.pdf({
    path: './assets/files/rietzCV.pdf',
    format: 'Letter',
    printBackground: true,
    displayHeaderFooter: false,
    margin: {
      top: '1.5cm',
      botton: '1.5cm',
      left: '1.5cm',
      right: '1.5cm',
    }
  });

  await browser.close();
  console.log('PDF generated successfully.');
})();
