const fileInput = document.getElementById("file");
const baudrateInput = document.getElementById("baudrate");
const portInput = document.getElementById("port");
const sendUartInput = document.getElementById("uart");
const healthButton = document.getElementById("health");

const consoleOutput = document.getElementById("console-output");
const ifid = document.getElementById("ifid");
const idex = document.getElementById("idex");
const exmem = document.getElementById("exmem");
const memwb = document.getElementById("memwb");
const registers = document.getElementById("regs-container");
const mem = document.getElementById("mem-container");

window.addEventListener("load", function () {
  updateState();
  setInterval(updateState, 500); // Actualiza cada 1 segundo
});

function updateState() {
  readData().then((data) => {
    if (data) {
      ifid.innerHTML = "";
      ifid.appendChild(parseObjectAsList(data.if_id));

      idex.innerHTML = "";
      idex.appendChild(parseObjectAsList(data.id_ex));

      exmem.innerHTML = "";
      exmem.appendChild(parseObjectAsList(data.ex_mem));

      memwb.innerHTML = "";
      memwb.appendChild(parseObjectAsList(data.mem_wb));

      registers.innerHTML = "";
      registers.appendChild(parseRegs(data.registers));

      mem.innerHTML = "";
      mem.appendChild(parseMem(data.mem));
    }
  });
}

function parseRegs(regs) {
  const list = document.createElement("ul");
  list.className = "reg-list";
  regs.forEach((element, index) => {
    const li = document.createElement("li");
    li.innerText = `R${index} = ${element}`;
    list.appendChild(li);
  });
  return list;
}

function parseMem(mem) {
  const list = document.createElement("ul");
  list.className = "mem-list";

  const li0 = document.createElement("li");
  li0.innerText = "Address: Data";
  list.appendChild(li0);

  mem.forEach((element) => {
    const li = document.createElement("li");
    li.innerText = `${element.address}: ${element.data}`;
    list.appendChild(li);
  });

  return list;
}

function parseObjectAsList(obj) {
  const list = document.createElement("ul");
  list.className = "latch-list";
  for (const key in obj) {
    const li = document.createElement("li");
    li.innerText = `${key}: ${obj[key]}`;
    list.appendChild(li);
  }
  return list;
}

function sendUart() {
  const baudrate = baudrateInput.value;
  const port = portInput.value;
  const toSend = sendUartInput.value;

  runCmd({ port: port, baudrate: baudrate, senduart: toSend }).then(
    (output) => {
      if (output) {
        console.log("Command executed successfully:", output);
        consoleOutput.innerText = output;
      }
    },
  );
}

function checkHealth() {
  runCmd({ health: "" }).then((output) => {
    if (output) {
      console.log("Command executed successfully:", output);
      consoleOutput.innerText = output;
    }
  });
}

function stop() {
  const baudrate = baudrateInput.value;
  const port = portInput.value;

  runCmd({ port: port, baudrate: baudrate, stopdebug: "" }).then((output) => {
    if (output) {
      console.log("Command executed successfully:", output);
      consoleOutput.innerText = output;
    }
  });
}

function step() {
  const baudrate = baudrateInput.value;
  const port = portInput.value;

  runCmd({ port: port, baudrate: baudrate, stepdebug: "" }).then((output) => {
    if (output) {
      console.log("Command executed successfully:", output);
      consoleOutput.innerText = output;
    }
  });
}

function startDebug() {
  const baudrate = baudrateInput.value;
  const port = portInput.value;

  runCmd({ port: port, baudrate: baudrate, startdebug: "" }).then((output) => {
    if (output) {
      console.log("Command executed successfully:", output);
      consoleOutput.innerText = output;
    }
  });
}

function runCont() {
  const baudrate = baudrateInput.value;
  const port = portInput.value;

  runCmd({ port: port, baudrate: baudrate, runcontinuous: "" }).then(
    (output) => {
      if (output) {
        console.log("Command executed successfully:", output);
        consoleOutput.innerText = output;
      }
    },
  );
}

function loadFile() {
  const file_path = fileInput.value;
  const baudrate = baudrateInput.value;
  const port = portInput.value;

  runCmd({ port: port, baudrate: baudrate, loadfile: file_path }).then(
    (output) => {
      if (output) {
        console.log("Command executed successfully:", output);
        consoleOutput.innerText = output;
      }
    },
  );
}

// Function to call the /run_cmd endpoint with optional query parameters
async function runCmd(params = {}) {
  // Convert params object to URL query string
  const queryString = new URLSearchParams(params).toString();
  const url = `/run_cmd${queryString ? `?${queryString}` : ""}`;

  try {
    const response = await fetch(url);
    if (!response.ok) {
      throw new Error(`Error: ${response.statusText}`);
    }
    const result = await response.text();
    console.log("Command Output:", result);
    return result;
  } catch (error) {
    console.error("Error running command:", error);
    return null;
  }
}

// Function to fetch data from the /read_data endpoint
async function readData() {
  try {
    const response = await fetch("/read_data");
    if (!response.ok) {
      throw new Error(`Error: ${response.statusText}`);
    }
    const data = await response.json();
    console.log("Data from server:", data);
    return data;
  } catch (error) {
    console.error("Error reading data:", error);
    return null;
  }
}
