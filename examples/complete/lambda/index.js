exports.handler = async (event) => {
  console.debug("input: ", JSON.stringify(event));
  if (event.fail === true) {
    throw new Error("Forced error");
  }
  return {
    statusCode: 200,
    body: JSON.stringify("Hello, World!"),
  };
};
