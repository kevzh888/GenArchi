// Define the S3 URL where the API Gateway URL is stored
const s3Url = 'https://l4aa3eml9i.execute-api.eu-west-3.amazonaws.com/quotes'

async function init() {
  try {
    // Use the URL in your API request
    console.log('API Gateway URL:', s3Url);

    // Fetch quotes after the API Gateway URL is loaded
    fetchQuotes();
  } catch (error) {
    console.error('Error:', error);
  }
}

// Call the function to fetch and use the API Gateway URL
init();

// Fetch and display the quotes
async function fetchQuotes() {
  try {
    const response = await fetch(`${s3Url}/getQuotes`, {
      method: "GET",
      headers: {
        "Content-Type": "application/json"
      }
    });
    const quotes = await response.json();
    const quotesList = document.getElementById("quotes-list");
    quotesList.innerHTML = quotes
      .map((quote) => `<li>${quote.quote}</li>`)
      .join("");
  } catch (error) {
    console.error("Error fetching quotes:", error);
  }
}

// Add a new quote
async function addQuote() {
  const quoteInput = document.getElementById("new-quote");
  const newQuote = quoteInput.value;

  if (!newQuote) {
    alert("Please enter a quote.");
    return;
  }

  try {
    await fetch(`${s3Url}/createQuote`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({ quote: newQuote })
    });
    quoteInput.value = ""; // Clear the input field
    fetchQuotes(); // Refresh the quotes list
  } catch (error) {
    console.error("Error adding quote:", error);
  }
}
