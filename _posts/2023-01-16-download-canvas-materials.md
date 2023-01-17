---
title: Download Canvas Course Materials
categories:
  - web
  - lifehack
---

## Background

Throughout my time as an online CS student at Oregon State, all of the courses
were delivered via [Canvas](https://github.com/instructure/canvas-lms). After
completing my degree, I still had access to all of the courses that I took and
wanted to download the modules for future reference. Thanks to the instructors
for creating some excellent learning materials.

Initially, I thought exporting each page as pdf would be the ideal route. With
chrome you can save a page as pdf directly from the command line using
something like `chromium-browser --headless --disable-gpu
--print-to-pdf=file1.pdf http://www.example.com/`. However, Canvas requires
two-factor authentication which makes accessing the pages quite difficult. I
also considered using [Puppeteer](https://developer.chrome.com/docs/puppeteer/)
but quickly ran into similar issues and ran out of patience. I finally settled
on saving the pages as html since many of the pages included interactive
javascript content and I had an quick hacky solution in mind.

## Tutorial

The basic idea is to open each link from the "Modules" page into a new browser
tab and save each of them.

<img src="/assets/img/canvasModules.png" alt="canvas modules" class="center" width=400>

You can obtain a list of all the anchor tags on the page from the console with
the following javascript.

```javascript
document.getElementsByClassName("ig-title title item_link")
```

To open each link into a new tab, you can use:


```javascript
Array.from(
	document.getElementsByClassName("ig-title title item_link")
).forEach((e) => window.open(e, "_blank"));
```

However, firefox blocks popups by default. To enable popups go to `Applications
Menu -> Settings -> Privacy and Security -> Permissions -> Block pop-up
windows`. Even after adjusting this setting, firefox will only open 20 popup
windows to open by default. To change this setting, navigate to
`about:config?filter=dom.popup_maximum` and click "Accept the Risk and
Continue". Remember to change this setting back to 20 when you are done.

To automatically save each open tab to an html file, I used the firefox
extension [Save Selected Tabs to
Files](https://addons.mozilla.org/en-US/firefox/addon/save-selected-tabs-to-files/).

Before using the extension, be sure to adjust two more settings. First, tell
firefox not to prompt you where to download each file. `Applications Menu ->
Settings -> Files and Applications -> Always ask where to save files`. Also,
adjust the preferences for the extension to not truncate the file names after
`x` number of characters.

<div class="attention warning">
Opening over 100 tabs at once made the fans on my laptop go nuts and my
computer get really hot.
</div>
