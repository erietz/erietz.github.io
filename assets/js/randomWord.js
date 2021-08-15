fetch("https://random-words-api.vercel.app/word")
  .then(response => response.json())
  .then(words => {
    const word = words[0];
    document.getElementById("randomWord").innerHTML = word.word;
    document.getElementById("randomDefinition").innerHTML = word.definition;
    document.getElementById("randomPronunciation").innerHTML = word.pronunciation;
  })
  .catch(error => console.error(error));
