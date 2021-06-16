function convert() {
    var energy = document.getElementById("energy").value;

    kcal_per_mol = (energy*627.5094740631).toExponential(5)
    kJ_per_mol = (energy*2625.4996394799).toExponential(5)
    eV = (energy*27.211386245988).toExponential(5)
    wavenumber = (energy*219474.63136320).toExponential(5)

    var table = "<table>"
    table += "<tr> <th>Energy</th> <th>Units</th> </tr>"
    table += `<tr> <td>${energy}</td> <td>hartrees</td> </tr>`

    table += `<tr> <td>${kcal_per_mol}</td> <td> kcal mol<sup>-1</sub> </tr>`
    table += `<tr> <td>${kJ_per_mol}</td>   <td> kJ mol<sup>-1</sub> </tr>`
    table += `<tr> <td>${eV}</td>           <td> eV </tr>`
    table += `<tr> <td>${wavenumber}</td>   <td> cm <sup>-1</sup> </tr>`
    table += "</table>"
    table += "<br/>"
    table += "Aren't you glad you used this today!"

    document.getElementById("output").innerHTML = table;
    return false;
}
