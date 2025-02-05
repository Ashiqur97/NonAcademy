function generateTable() {
    const numberInput = document.getElementById('numberInput').value;
    const outputDiv = document.getElementById('output');

    // Validation
    if (numberInput === "" || isNaN(numberInput)) {
        outputDiv.innerHTML = "<p style='color: red;'>Please enter a valid number!</p>";
        return;
    }

    const number = parseInt(numberInput);
    if (number <= 0) {
        outputDiv.innerHTML = "<p style='color: red;'>Please enter a number greater than 0!</p>";
        return;
    }

    // Generate Table
    let table = `<h3>Multiplication Table for ${number}</h3>`;
    for (let i = 1; i <= 10; i++) {
        table += `<p>${number} x ${i} = ${number * i}</p>`;
    }

    outputDiv.innerHTML = table;
}