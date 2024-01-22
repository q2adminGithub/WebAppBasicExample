import { useState } from 'react';
import logo from './logo.svg';
import './App.css';

function App2() {
  const [input, setInput] = useState('');
  const [result, setResult] = useState('');
  const [savedstates, setSavedstates] = useState([]);

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
    </>
  );
}

 export default App2;
