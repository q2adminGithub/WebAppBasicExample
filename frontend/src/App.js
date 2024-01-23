import { useState } from 'react';
import './App.css';
import Plot from 'react-plotly.js';

function App2() {
  const [input, setInput] = useState('');
  const [result, setResult] = useState('');
  const [savedstates, setSavedstates] = useState([]);
  const [ndraws, setNdraws] = useState('');
  const [mean, setMean] = useState('');
  const [sd, setSd] = useState('');
  const [rawdata, setRawData] = useState([]);



  const getSavedStates = async () => {
    fetch(`http://127.0.0.1:8080/square/savedstates`,{method: 'GET'})
      .then(response => {
        if (!response.ok) {
          throw new Error('Network response was not ok');
        }
        return response.json();
      })
      .then(retrieved => {
        console.log('getsSavedStates', retrieved.states);
        retrieved.states.forEach(function (item, index) {
          console.log("TEST", item, index);
        });
        //setSavedstates(retrieved.states)
        return retrieved.states;
      })
      .catch(error => {
        console.error('getsSavedStates Error:', error);
      });
  }
  
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

  const getHistogram = async () => {
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
    })
    .catch(error => {
      console.error('getHistogram error:', error);
    });
    console.log("The response data is ", {rawdata})
  }


  const savedStatesOutput = [];
  for (let i=0; i<savedstates.length; i++) savedStatesOutput.push(
      <li key={savedstates[i].stateid}>{savedstates[i].ts_utc} {'  '} 
      <button onClick={() =>{loadState(savedstates[i].stateid)}}>Load State</button>
      <button onClick={() =>{deleteState(savedstates[i].stateid)}}>Delete State</button>
      </li>
      );

  
  return (
    <>
      <input type="number" value={input} onChange={(e) => setInput(e.target.value)} />
      <button onClick={calculateSquare}>Calculate Square</button>
      <p>Result: {result}</p>
      <button onClick={saveState}>Save State</button>
      <p>Saved States:</p>
      <ul>
        {savedStatesOutput}
      </ul>
      <p>Enter ndraws, mean and standard deviation:</p>
      <input type="number" value={ndraws} onChange={(e) => setNdraws(e.target.value)} />
      <input type="number" value={mean} onChange={(e) => setMean(e.target.value)} />
      <input type="number" value={sd} onChange={(e) => setSd(e.target.value)} />
      <button onClick={getHistogram}>Fetch Histogram</button>
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
    </>
    );
 }

 export default App2;
