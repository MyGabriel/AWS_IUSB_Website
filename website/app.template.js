// File: app.template.js

// NOTE: Replace this value AFTER Terraform deploys and prints your API URL

const API_URL = "YOUR_API_GATEWAY_URL_HERE";

async function submitRegistration(event) {
    event.preventDefault(); // prevent form from reloading page

    const formData = {
        firstName: document.getElementById("fname").value,
        lastName: document.getElementById("lname").value,
        email: document.getElementById("email").value,
        password: document.getElementById("password").value,
        studentId: document.getElementById("studentid").value,
        accountType: document.getElementById("accounttype").value,
        country: document.getElementById("country").value,
        phone: document.getElementById("phone").value
    };

    try {
        const res = await fetch(`${API_URL}/register`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify(formData)
        });

        const data = await res.json();

        if (!res.ok) {
            alert("Error: " + (data.message || "Something went wrong"));
            return;
        }

        alert(data.message || "Registration successful!");

    } catch (error) {
        alert("Network or server error: " + error.message);
    }
}



// IU-International University of Applied Sciences
// Course Code: DLBSEPCP01_E
// Author: Gabriel Manu
// Matriculation ID: 9212512