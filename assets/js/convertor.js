function convert(event) {
    var energy = document.getElementById("energy").value;

    kcal_per_mol = (energy*627.5094740631).toExponential(5)
    kJ_per_mol = (energy*2625.4996394799).toExponential(5)
    eV = (energy*27.211386245988).toExponential(5)
    wavenumber = (energy*219474.63136320).toExponential(5)

    var string = `${energy} hartrees is equal to: <br/>`
    string += "<br/>"
    string += `${kcal_per_mol} $\\frac{kcal}{mol}$ <br/>`
    string += `${kJ_per_mol}   $\\frac{kJ}{mol}$ <br/>`
    string += `${eV}           eV <br/>`
    string += `${wavenumber}   $cm^{-1}$ <br/>`
    string += "<br/>"
    string += "Aren't you glad you used this today!"

    document.getElementById("output").innerHTML = string;
    MathJax.Hub.Queue(["Typeset", MathJax.Hub, 'output']);
    // MathJax.Hub.Queue(["Typeset",MathJax.Hub]);

    event.preventDefault();
}
