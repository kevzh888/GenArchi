// Importer les classes nécessaires du SDK AWS v3
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { ScanCommand } from "@aws-sdk/lib-dynamodb";

// Créer une instance de DynamoDBClient
const client = new DynamoDBClient({ region: "eu-west-3" }); // Spécifiez la région de votre table

export const handler = async (event) => {
  const params = {
    TableName: "QuotesTable", // Remplacez par le nom de votre table DynamoDB
  };

  try {
    // Utiliser ScanCommand pour récupérer tous les éléments
    const command = new ScanCommand(params);
    const data = await client.send(command); // Envoyer la commande

    return {
      statusCode: 200,
      headers: {
        "Access-Control-Allow-Headers": "Content-Type",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "OPTIONS,POST,GET",
      },
      body: JSON.stringify(data.Items), // Retourner les citations
    };
  } catch (error) {
    console.error(error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: "Could not fetch quotes" }),
    };
  }
};
