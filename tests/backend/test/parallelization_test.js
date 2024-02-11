const sendTaskRequest = async endpoint => {
    console.time(endpoint);
  
    console.log(`[START] Send request to /square/${endpoint}?ndraws=3000&mean=4&sd=3`);
  
    await fetch(`http://localhost:8080/square/${endpoint}?ndraws=3000&mean=4&sd=3`).then(res => res.json());
  
    console.timeEnd(endpoint);
    console.log(`[END] Request completed to /square/${endpoint}?ndraws=3000&mean=4&sd=3`);
  };
  
  (async () => {
  
    console.log("\nComparing performance WITH FUTURE PROMISE...");
  
    await Promise.all([
      sendTaskRequest("hist-raw-slow"),
      sendTaskRequest("hist-raw"),
    ]);
  })();