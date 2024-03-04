import { Component } from 'react';
import React from 'react';

// take first row and loop over keys
// add the resulting array of keys to the table header
function getHeadings(data) {
    return Object.keys(data[0]).map(key => {
        return <th>{key}</th>;
    });
}
  
// loop over all rows, pass each row dict to getCells
// and add to table row
function getRows(data) {
    return data.map(obj => {
        return <tr>{getCells(obj)}</tr>;
    });
}
  
// loop over a row dict to get <td>s
function getCells(obj) {
    return Object.values(obj).map(value => {
        return <td>{value}</td>;
    });
}

const Datatable = (props) => {
    /*console.log(props.mykey);*/
    return (
        <React.Fragment key={props.mykey}>
            <table>
                <thead><tr>{getHeadings(props.data)}</tr></thead>
                <tbody>{getRows(props.data)}</tbody>
            </table>
        </React.Fragment>
    );
}

export default Datatable;


