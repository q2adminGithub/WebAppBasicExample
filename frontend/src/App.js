import { useState, useEffect } from 'react';
import './App.css';
import Plot from 'react-plotly.js';
import React from 'react';
import { PrimaryButton, DefaultButton, Spinner } from '@fluentui/react';
import { TextField} from '@fluentui/react/lib/TextField';



function App() {
  const [input, setInput] = useState('');
  const [result, setResult] = useState('');
  const [savedstates, setSavedstates] = useState([]);
  const [ndraws, setNdraws] = useState('');
  const [mean, setMean] = useState('');
  const [sd, setSd] = useState('');
  const [rawdata, setRawData] = useState([]);
  const [isLoading, setIsLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState('');

  /**
   * useEffect hook to fetch and set the saved states from the server.
   */
  useEffect(() => {
    /**
    * Function to asynchronously retrieve saved states from the server.
    */
    const getSavedStates = async () => {
      fetch(`http://127.0.0.1:8080/square/savedstates`,{method: 'GET'})
        .then(response => {
          if (!response.ok) {
            throw new Error('Network response was not ok');
          }
          return response.json();
        })
        .then(retrieved => {
          console.log('initial', retrieved.states);
          // Set the retrieved states in the component's state
          setSavedstates(retrieved.states)
          return retrieved.states;
        })
        .catch(error => {
          console.error('initial Error:', error);
        });
    }
    getSavedStates();
  }, []);

  /**
   * Asynchronous function to calculate the square of a number by making
   * a request to the backend.
   */
  const calculateSquare = async () => {
    fetch(`http://127.0.0.1:8080/square/${parseInt(input)}`,{method: 'GET'})
      .then(response => {
        if (!response.ok) {
          setResult('invalid input value ... nothing returned');
          throw new Error('calculateSquare network response was not ok');
        }
        return response.json();
      })
      .then(retrieved => {
        setResult(retrieved.result);
        console.log('calculateSquare', retrieved, retrieved.result);
      })
      .catch(error => {
        console.error('calculateSquare error:', error);
      });
  }
  /**
   * Asynchronous function to save the current input value, calculate its square, 
   * and fetch the updated list of saved states from the backend.
   */
  const saveState = async () => {
    fetch(`http://127.0.0.1:8080/square/${parseInt(input)}/true`,{method: 'GET'})
      .then(response => {
        if (!response.ok) {
          setResult('invalid input value ... nothing returned');
          throw new Error('saveState network response was not ok');
        }
        return response.json();
      })
      .then(retrieved => {
        setResult(retrieved.result);
        console.log('saveState ', retrieved, retrieved.result);
        return fetch(`http://127.0.0.1:8080/square/savedstates`,{method: 'GET'});
      })
      .then(response => {
        if (!response.ok) {
          throw new Error('getsSavedStates Network response was not ok');
        }
        return response.json();
      })
      .then(retrieved => {
        console.log('getsSavedStates', retrieved);
        retrieved.states.forEach(function (item, index) {
          console.log("retrieved state info ", item, index);
        	});
        setSavedstates(retrieved.states);
      })
      .catch(error => {
        console.error('saveState error:', error);
      });
  }

  /**
   * Asynchronous function to load a saved input value from the backend and
   *  calculate its square.
   */
  const loadState = async (stateid) => {
    fetch(`http://127.0.0.1:8080/square/savedstate/${parseInt(stateid)}`,{method: 'GET'})
      .then(response => {
        if (!response.ok) {
          throw new Error('loadState network response was not ok');
        }
        return response.json();
      })
      .then(retrieved => {
        setInput(parseInt(retrieved.state.input[0]));
        console.log('loadState', retrieved);
        return fetch(`http://127.0.0.1:8080/square/${parseInt(retrieved.state.input[0])}`,{method: 'GET'});
      })
      .then(response => {
        if (!response.ok) {
          throw new Error('calculateSquare network response was not ok');
        }
        return response.json();
      })
      .then(retrieved => {
        setResult(retrieved.result);
        console.log('calculateSquare in loadState', retrieved, retrieved.result);
      })
      .catch(error => {
        console.error('loadState error:', error);
      });
  }

   /**
   * Asynchronous function to delete a saved input value from the backend .
   */
  const deleteState = async (stateid) => {
    fetch(`http://127.0.0.1:8080/square/deletestate/${parseInt(stateid)}`,{method: 'GET'})
      .then(response => {
        if (!response.ok) {
          throw new Error('deleteState network response was not ok');
        }
        return response.json();
      })
      .then(retrieved => {
        console.log('deleteState ', retrieved);
        return fetch(`http://127.0.0.1:8080/square/savedstates`,{method: 'GET'});
      })
      .then(response => {
        if (!response.ok) {
          throw new Error('getSavedStates in deleteState network response was not ok');
        }
        return response.json();
      })
      .then(retrieved => {
        console.log('updated SavedStates', retrieved);
        retrieved.states.forEach(function (item, index) {
          console.log("retrieved state info ", item, index);
        	});
        setSavedstates(retrieved.states);
      })
      .catch(error => {
        console.error('deleteState error:', error);
      });
  }

  /**
   * Asynchronous function to fetch histogram data for a sample of normally distributed random
   * variables from the backend based on specified number of draws, mean and standard deviation.
   */       
  const getHistogram = async () => {
    setIsLoading(true);
    fetch(`http://127.0.0.1:8080/square/hist-raw?ndraws=${parseInt(ndraws)}&mean=${parseFloat(mean)}&sd=${parseFloat(sd)}`, { method: 'GET' })
    .then(response => {
      if (!response.ok) {
        setResult('Invalid input value ... nothing returned');
        throw new Error('getHistogram network response was not ok');
      }
      return response.json();
    })
    .then(data => {
      // Check if 'data' is an array and has the expected structure
      if (Array.isArray(data) && data.length > 0 && data[0].hasOwnProperty('mids') && data[0].hasOwnProperty('counts')) {
        setRawData([
          {
            y: data.map(x => x["counts"]),
            x: data.map(x => x["mids"]),
            type: 'bar'
          }
        ]);
      } else {
        setResult('Invalid data format received from the server');
      }
      setIsLoading(false);
    })
    .catch(error => {
      console.error('getHistogram error:', error);
      setIsLoading(false);
    });
    
    console.log("The response data is ", {rawdata})
  }


  const savedStatesOutput = [];
  for (let i=0; i<savedstates.length; i++) savedStatesOutput.push(
      <li key={savedstates[i].stateid}>{savedstates[i].ts_utc + " UTC"} {'  '} 
      <PrimaryButton onClick={() =>{loadState(savedstates[i].stateid)}}>Load State</PrimaryButton>
      <DefaultButton onClick={() =>{deleteState(savedstates[i].stateid)}}>Delete State</DefaultButton>
      </li>
      );

  const validateNdraws = (value) => {
    const parsedValue = parseInt(value);

    if (isNaN(parsedValue) || parsedValue > 10000) {
      setErrorMessage(' Error - Number of draws (ndraws) should be a valid number and not exceed 10000');
    } else {
      setErrorMessage(' Number of draws is valid.');
      setNdraws(value);
    }

    
  };

  
  return (
    <>
      {/* Main container with two sections: left and right */}
      <div className="split-container">
        {/* Left side of the screen */}
        <div className="left-side">
          {/* Content for the left side of the screen */}
          <h3>Demo 1: Calculation of square in backend and storing of input</h3>
          <p>Enter number and press Calculate Square (optionally Save State)!:</p>
          
          {/* Input field for the number to be squared */}
          <TextField label="Number to be squared" placeholder="Please enter number to be squared here" value={input} onChange={(e) => setInput(e.target.value)} />
          
          {/* Buttons to trigger calculations and state-saving */}
          <PrimaryButton onClick={calculateSquare}>Calculate Square</PrimaryButton>
          <p>Result: {result}</p>
          <PrimaryButton onClick={saveState}>Save State</PrimaryButton>
          
          {/* Display the list of saved states */}
          <p>Saved States:</p>
          <ul>
            {savedStatesOutput}
          </ul>
        </div>
  
        {/* Right side of the screen */}
        <div className="right-side">
          {/* Content for the right side of the screen */}
          <h3>Demo 2: Simulation of normally distributed random variables in backend</h3>
          <p>Enter ndraws, mean, and standard deviation and press Fetch Histogram!:</p>
  
          {/* Input fields for ndraws, mean, and standard deviation */}
          <TextField label="Ndraws" placeholder="Please enter number of draws here" type="number" value={ndraws} onChange={(e) => validateNdraws(e.target.value)} />
          <TextField label="Mean" placeholder="Please enter mean of simulated random variable here" type="number" value={mean} onChange={(e) => setMean(e.target.value)} />
          <TextField label="StdDev" placeholder="Please enter standard deviation of simulated random variable here" type="number" value={sd} onChange={(e) => setSd(e.target.value)} />
          
          {/* Button to trigger fetching histogram data */}
          <PrimaryButton onClick={getHistogram} disabled={isLoading} className="fetchHistogramButton">Fetch Histogram</PrimaryButton>
          
          {/* Display the histogram plot if data is available, otherwise show a loading spinner */}
          {isLoading ? <Spinner label="Loading ..." /> : 
            <Plot
              data={rawdata}
              layout={{
                title: 'Histogram for normal distribution',
                bargap: 0.01,
                autosize: true,
                xaxis: {
                  title: 'x'
                },
                yaxis: {
                  title: 'Frequency'
                },
                useResizeHandler: true,
                responsive: true
              }}
            />
          }
  
          {/* Display status and error message, if any */}
          <p>Status: {errorMessage}</p>
        </div>
      </div>
    </>
  );
  
 }

 export default App;
