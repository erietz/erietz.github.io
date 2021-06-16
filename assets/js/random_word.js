async function fetchAsync (url) {
  let response = await fetch(url);
  let data = await response.json();
  return data;
}

var response = fetchAsync("https://random-words-api.vercel.app/word");

response.then(function(tmp) {
  var word = tmp[0]['word'];
  var definition = tmp[0]['definition'];

  document.getElementById("outputWord").innerHTML = word;
  document.getElementById("outputDefinition").innerHTML = definition;
})
