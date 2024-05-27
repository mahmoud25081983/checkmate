exports = async function(authEvent) {
    console.log(JSON.stringify(authEvent, null, 2)); // Log the authEvent object

  // Get the user ID and other relevant information from the auth event
  const user = authEvent.user;
  
  // Define the database and collection
  const mongodb = context.services.get("mongodb-atlas");
  const usersCollection = mongodb.db("checkmate").collection("Users");

  // Construct the user document to insert
  const userDocument = {
    _id: user.id,
    email: user.data.email,
    createTime: new Date(),
    password: user.data.password
    // Add other user attributes as needed
  };

  // Insert the user document into the collection
  try {
    await usersCollection.insertOne(userDocument);
    console.log(`User ${user.id} added to the users collection`);
  } catch (error) {
    console.error(`Failed to add user ${user.id} to the users collection: ${error}`);
  }
};