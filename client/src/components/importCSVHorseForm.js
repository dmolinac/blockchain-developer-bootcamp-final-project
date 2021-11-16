import React from "react";

export class ImportCSVHorseForm extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = { horseid: 0,
                   horsename: "-",
                   wins: 0
                  };

    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);

  }

  handleChange(event) {
    this.setState({ [event.target.name]: event.target.value });
  }

  async handleSubmit(event) {
    const csvhorsedata = this.state.horseid + "," + this.state.horsename + "," + this.state.wins;
    //alert('Importing Horse from CSV: ' + csvhorsedata + " " + this.props.account);
    event.preventDefault();
    this.props.setStateMessage('Importing Horse from CSV: ' + csvhorsedata + "...");
    try {
      this.props.metaturfHorseRacingDataInstance.methods.setHorseFromCSV(csvhorsedata).send({ from: this.props.account }).on('confirmation', (receipt) => {
        this.props.setStateMessage("Horse " + csvhorsedata + " imported successfully from CSV");
        //window.location.reload();
      })
    } catch (error) {
      //alert(`Failed to import.`);
      this.props.setStateMessage('Horse ' + csvhorsedata + " not imported from CSV.");
      console.error(error);
    }
  }

  render() {
    return (
      <form onSubmit={this.handleSubmit}>
        <label> 
          &nbsp;&nbsp;&nbsp;Horse ID:
          <input type="text" name="horseid" value={this.state.horseid} onChange={this.handleChange} />
        </label>
         <label>
          &nbsp;&nbsp;&nbsp;Name:
          <input type="text" name="horsename" value={this.state.horsename} onChange={this.handleChange} />
         </label>
         <label>
          &nbsp;&nbsp;&nbsp;Wins:
          <input type="text" name="wins" value={this.state.wins} onChange={this.handleChange} />
        </label>
        &nbsp;&nbsp;<input type="submit" value="Import horse (CSV)" />
      </form>
    );
  }
}
