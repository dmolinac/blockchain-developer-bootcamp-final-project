import React from "react";

export class MintForm extends React.Component {
  
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
    //alert('Minting Horse: ' + this.state.value + " " + this.props.account);
    event.preventDefault();
    this.props.setStateMessage('Minting Token for Horse ' + this.state.value + "...");
    try {
      //this.props.metaturfNFTInstance.methods.mint(this.state.value,this.props.account).send({ from: this.props.account });
      await this.props.metaturfNFTInstance.methods.mint(this.state.value,this.props.account).send({ from: this.props.account })
      .once('receipt', (receipt) => {
        this.props.setStateMessage("Token for horse #" + this.state.value + " minted successfully");
      })
    } catch (error) {
      //alert(`Failed to mint.`);
      this.props.setStateMessage('Token for Horse ' + this.state.value + " not minted.");
      console.error(error);
    }
    
  }

  render() {
    return (
      <form onSubmit={this.handleSubmit}>
        <label>
          Horse ID:&nbsp;
          <input type="text" value={this.state.value} onChange={this.handleChange} />
        </label>
        <input type="submit" value="Mint" />
      </form>
    );
  }
}
