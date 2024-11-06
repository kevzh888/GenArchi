// Define the S3 URL where the API Gateway URL is stored
const s3Url = 'https://ga-s3bucket-quotes-app.s3.amazonaws.com/api_gateway_url.txt';
var apiGatewayUrl = "";

async function fetchApiGatewayUrl() {
  try {
    // Fetch the API Gateway URL from the S3 object
    const response = await fetch(s3Url, {
      method: "GET",
      headers: {
        "Content-Type": "text/plain",
        "Access-Control-Allow-Headers": "Content-Type",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "OPTIONS,POST,GET",
      }
    });

    // Check if the response is successful
    if (!response.ok) {
      throw new Error('Failed to fetch the API Gateway URL.');
    }

    // Get the text (URL) from the response
    apiGatewayUrl = await response.text();

    // Use the URL in your API request
    console.log('API Gateway URL:', apiGatewayUrl);

    // Fetch quotes after the API Gateway URL is loaded
    fetchQuotes();
  } catch (error) {
    console.error('Error:', error);
  }
}

// Call the function to fetch and use the API Gateway URL
fetchApiGatewayUrl();

// Fetch and display the quotes
async function fetchQuotes() {
  try {
    const response = await fetch(`${apiGatewayUrl}/getQuotes`, {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Headers": "Content-Type",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "OPTIONS,POST,GET",
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
    await fetch(`${apiGatewayUrl}/createQuote`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Headers": "Content-Type",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "OPTIONS,POST,GET",
      },
      body: JSON.stringify({ quote: newQuote }),
    });
    quoteInput.value = ""; // Clear the input field
    fetchQuotes(); // Refresh the quotes list
  } catch (error) {
    console.error("Error adding quote:", error);
  }
}
