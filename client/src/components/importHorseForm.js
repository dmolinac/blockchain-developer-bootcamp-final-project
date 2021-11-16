import React from "react";

export class ImportHorseForm extends React.Component {
  
  constructor(props) {
    super(props);
    this.state = { value: '' };

    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  handleChange(event) {
    this.setState({value: event.target.value});
  }

  async handleSubmit(event) {
    alert('Importing Horse from race: ' + this.state.value + " " + this.props.account);
    event.preventDefault();
    this.props.setStateMessage('Importing Horse ' + this.state.value + "...");
    try {
      //this.props.metaturfNFTInstance.methods.mint(this.state.value,this.props.account).send({ from: this.props.account });
      this.props.metaturfHorseRacingDataInstance.methods.requestOracleRaceWinner(this.state.value).send({ from: this.props.account }).on('confirmation', (receipt) => {
        this.props.setStateMessage("Horse imported successfully");
        //window.location.reload();
      })
    } catch (error) {
      //alert(`Failed to import.`);
      this.props.setStateMessage('Horse ' + this.state.value + " not imported.");
      console.error(error);
    }
  }

  render() {
    return (
      <form onSubmit={this.handleSubmit}>
        <label>
          Race ID:&nbsp;
          <input type="text" value={this.state.value} onChange={this.handleChange} />
        </label>
        <input type="submit" value="Import horse (Chainlink)" />
      </form>
    );
  }
}
