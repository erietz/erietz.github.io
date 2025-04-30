# Ethans 30th B-day Carne Asada Sign up

Please fill out the form below for yourself and for any guests so that I can
know how much meat and beer to acquire.

<iframe src="https://docs.google.com/forms/d/e/1FAIpQLScZlui67uNNLMQIRiHJ89UH3qOmw7ztnPQu62n79CYc9ViW7g/viewform?embedded=true" width="640" height="625" frameborder="0" marginheight="0" marginwidth="0">Loading…</iframe>

## Results

<div id="results"></div>

<script>
  async function fetchSheetData() {
    const sheetId = '1EZWN_BTjgyGhHfaRa7gXy5B-1IghQyxf3zJM6o6tLzw';
    const res = await fetch(`https://docs.google.com/spreadsheets/d/${sheetId}/gviz/tq?tqx=out:json`);
    const text = await res.text();
    const json = JSON.parse(text.substring(47, text.length - 2));
    const tableData = json.table;

    const table = document.createElement("table");
    table.border = "1";
    table.cellPadding = "6";
    table.style.borderCollapse = "collapse";

    const thead = document.createElement("thead");
    const headerRow = document.createElement("tr");
    tableData.cols.forEach(col => {
      const th = document.createElement("th");
      th.textContent = col.label;
      headerRow.appendChild(th);
    });
    thead.appendChild(headerRow);
    table.appendChild(thead);

    const tbody = document.createElement("tbody");
    let yesCount = 0;

    tableData.rows.forEach(row => {
      const tr = document.createElement("tr");
      row.c.forEach((cell, index) => {
        const td = document.createElement("td");
        td.textContent = cell?.f ?? cell?.v ?? "";
        tr.appendChild(td);

        // Check for "Yes" in the third column (index 2)
        if (index === 2 && (cell?.v === "Yes" || cell?.f === "Yes")) {
          yesCount++;
        }
      });
      tbody.appendChild(tr);
    });

    // Add the last row with the "Yes" count
    const lastRow = document.createElement("tr");
    const td1 = document.createElement("td");
    td1.colSpan = tableData.cols.length - 1; // Merge cells for label
    td1.textContent = "Total 'Yes' responses";
    lastRow.appendChild(td1);

    const td2 = document.createElement("td");
    td2.textContent = yesCount;
    lastRow.appendChild(td2);

    tbody.appendChild(lastRow);

    table.appendChild(tbody);

    document.getElementById("results").appendChild(table);
  }

  fetchSheetData();
</script>
