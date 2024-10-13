// Importer les classes nécessaires du SDK AWS v3
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { PutCommand } from "@aws-sdk/lib-dynamodb";

// Créer une instance de DynamoDBClient
const client = new DynamoDBClient({ region: "eu-north-1" }); // Spécifiez la région de votre table

export const handler = async (event) => {
  const body = JSON.parse(event.body);
  const quote = body.quote;

  if (!quote) {
    return {
      statusCode: 400,
      body: JSON.stringify({ error: "Quote is required" }),
    };
  }

  const params = {
    TableName: "QuotesTable", // Remplacez par le nom de votre table DynamoDB
    Item: {
      id: Date.now().toString(), // Génération d'un ID unique
      quote: quote,
    },
  };

  try {
    // Utiliser PutCommand pour insérer l'élément
    const command = new PutCommand(params);
    await client.send(command); // Envoyer la commande
    return {
      statusCode: 200,
      headers: {
        "Access-Control-Allow-Headers": "Content-Type",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "OPTIONS,POST,GET",
      },
      body: JSON.stringify({ message: "Quote added successfully" }),
    };
  } catch (error) {
    console.error(error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: "Could not add quote" }),
    };
  }
};
